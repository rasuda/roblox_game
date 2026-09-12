local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local activeSeat = nil
local chassis = nil
local stabilizer = nil
local currentSpeed = 0
local heading = 0
local steeringInput = 0
local previousThrottle = 0

local FORWARD_SPEED = 56
local REVERSE_SPEED = 22
local ACCELERATION = 18
local REVERSE_ACCELERATION = 13
local BRAKING = 32
local COAST_DRAG = 4.5
local LOW_SPEED_TURN_RATE = math.rad(68)
local HIGH_SPEED_TURN_RATE = math.rad(32)
local STEERING_RESPONSE = 3.8
local LATERAL_GRIP = 4.2
local INPUT_DEADZONE = 0.08

local function moveTowards(current, target, amount)
	if current < target then
		return math.min(current + amount, target)
	end
	return math.max(current - amount, target)
end

local function beginDriving(seat)
	local car = seat:FindFirstAncestor("VolkswagenNivusGTS2026")
	local carChassis = car and car:FindFirstChild("Chassis")
	local carStabilizer = carChassis and carChassis:FindFirstChild("CarStabilizer")
	if not carChassis or not carStabilizer then
		return
	end

	activeSeat = seat
	chassis = carChassis
	stabilizer = carStabilizer
	local look = chassis.CFrame.LookVector
	heading = math.atan2(-look.X, -look.Z)
	currentSpeed = chassis.AssemblyLinearVelocity:Dot(look)
	steeringInput = 0
	previousThrottle = 0
end

local function stopDriving()
	activeSeat = nil
	chassis = nil
	stabilizer = nil
	currentSpeed = 0
	steeringInput = 0
	previousThrottle = 0
end

local function connectCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.Seated:Connect(function(isSeated, seat)
		if isSeated and seat and seat.Name == "DriverSeat" then
			beginDriving(seat)
		else
			stopDriving()
		end
	end)
end

if player.Character then
	connectCharacter(player.Character)
end
player.CharacterAdded:Connect(connectCharacter)

RunService.Heartbeat:Connect(function(deltaTime)
	if not activeSeat or not chassis or not stabilizer then
		return
	end
	if activeSeat.Occupant == nil then
		stopDriving()
		return
	end

	local rawThrottle = activeSeat.ThrottleFloat
	local rawSteering = activeSeat.SteerFloat
	local throttle = math.abs(rawThrottle) >= INPUT_DEADZONE and rawThrottle or 0
	local steering = math.abs(rawSteering) >= INPUT_DEADZONE and rawSteering or 0
	steeringInput = moveTowards(steeringInput, steering, STEERING_RESPONSE * deltaTime)

	-- Soltar o joystick agora deixa o carro rolar por inercia. Freada forte so
	-- acontece quando o jogador comanda a direcao oposta ao movimento atual.
	if throttle > 0 then
		if currentSpeed < -0.5 then
			currentSpeed = moveTowards(currentSpeed, 0, BRAKING * deltaTime)
		else
			currentSpeed = moveTowards(currentSpeed, throttle * FORWARD_SPEED, ACCELERATION * deltaTime)
		end
	elseif throttle < 0 then
		if currentSpeed > 0.5 then
			currentSpeed = moveTowards(currentSpeed, 0, BRAKING * deltaTime)
		else
			currentSpeed = moveTowards(currentSpeed, throttle * REVERSE_SPEED, REVERSE_ACCELERATION * deltaTime)
		end
	else
		currentSpeed = moveTowards(currentSpeed, 0, COAST_DRAG * deltaTime)
	end

	-- A direcao fica agil devagar e mais progressiva em velocidade alta.
	local absoluteSpeed = math.abs(currentSpeed)
	local normalizedSpeed = math.clamp(absoluteSpeed / FORWARD_SPEED, 0, 1)
	local steeringRate = LOW_SPEED_TURN_RATE + (HIGH_SPEED_TURN_RATE - LOW_SPEED_TURN_RATE) * normalizedSpeed
	local movementSteering = math.clamp(absoluteSpeed / 7, 0, 1)
	local reverseDirection = currentSpeed < -0.5 and -1 or 1
	heading += -steeringInput * steeringRate * movementSteering * reverseDirection * deltaTime

	-- Pequena rolagem visual da carroceria e mergulho ao frear.
	local bodyRoll = -steeringInput * normalizedSpeed * math.rad(3.2)
	local brakingPitch = 0
	if math.abs(currentSpeed) > 0.5 and throttle ~= 0 and math.sign(throttle) ~= math.sign(currentSpeed) then
		brakingPitch = math.rad(1.8)
	elseif math.abs(throttle) > math.abs(previousThrottle) then
		brakingPitch = math.rad(-0.8)
	end
	stabilizer.CFrame = CFrame.Angles(brakingPitch, heading, bodyRoll)
	previousThrottle = throttle

	local direction = CFrame.Angles(0, heading, 0).LookVector
	local verticalSpeed = chassis.AssemblyLinearVelocity.Y
	local horizontalVelocity = Vector3.new(chassis.AssemblyLinearVelocity.X, 0, chassis.AssemblyLinearVelocity.Z)
	local desiredVelocity = direction * currentSpeed
	local gripBlend = 1 - math.exp(-LATERAL_GRIP * deltaTime)
	local correctedVelocity = horizontalVelocity:Lerp(desiredVelocity, gripBlend)
	chassis.AssemblyLinearVelocity = Vector3.new(
		correctedVelocity.X,
		verticalSpeed,
		correctedVelocity.Z
	)
	chassis.AssemblyAngularVelocity = Vector3.zero

	-- Limite de seguranca para o carro nao cair para fora do mapa.
	local position = chassis.Position
	if math.abs(position.X) > 198 or math.abs(position.Z) > 198 then
		local clamped = Vector3.new(
			math.clamp(position.X, -198, 198),
			math.max(position.Y, 1),
			math.clamp(position.Z, -198, 198)
		)
		chassis.CFrame = CFrame.new(clamped) * CFrame.Angles(0, heading, 0)
		chassis.AssemblyLinearVelocity = Vector3.zero
		currentSpeed = 0
	end
end)

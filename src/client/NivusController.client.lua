local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local activeSeat = nil
local chassis = nil
local stabilizer = nil
local currentSpeed = 0
local heading = 0

local FORWARD_SPEED = 62
local REVERSE_SPEED = 25
local ACCELERATION = 44
local BRAKING = 58
local TURN_RATE = math.rad(82)

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
end

local function stopDriving()
	activeSeat = nil
	chassis = nil
	stabilizer = nil
	currentSpeed = 0
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

	local throttle = activeSeat.ThrottleFloat
	local steering = activeSeat.SteerFloat
	local targetSpeed = throttle >= 0 and throttle * FORWARD_SPEED or throttle * REVERSE_SPEED
	local rate = math.abs(targetSpeed) < math.abs(currentSpeed) and BRAKING or ACCELERATION
	currentSpeed = moveTowards(currentSpeed, targetSpeed, rate * deltaTime)

	local speedRatio = math.clamp(math.abs(currentSpeed) / 18, 0.18, 1)
	local reverseDirection = currentSpeed < -0.5 and -1 or 1
	heading += -steering * TURN_RATE * speedRatio * reverseDirection * deltaTime
	stabilizer.CFrame = CFrame.Angles(0, heading, 0)

	local direction = CFrame.Angles(0, heading, 0).LookVector
	local verticalSpeed = chassis.AssemblyLinearVelocity.Y
	chassis.AssemblyLinearVelocity = Vector3.new(
		direction.X * currentSpeed,
		verticalSpeed,
		direction.Z * currentSpeed
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

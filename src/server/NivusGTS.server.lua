local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local world = Workspace:WaitForChild("EmpireStateWorld", 20)
if not world then
	warn("[roblox_game] Não foi possível criar o Nivus GTS: mundo não encontrado.")
	return
end

local oldCar = world:FindFirstChild("VolkswagenNivusGTS2026")
if oldCar then
	oldCar:Destroy()
end

local car = Instance.new("Model")
car.Name = "VolkswagenNivusGTS2026"
car.Parent = world

local WHITE = Color3.fromRGB(232, 234, 233)
local BLACK = Color3.fromRGB(18, 20, 22)
local GLOSS_BLACK = Color3.fromRGB(30, 32, 35)
local GLASS = Color3.fromRGB(43, 62, 72)
local RED = Color3.fromRGB(220, 32, 42)
local DARK_RED = Color3.fromRGB(133, 10, 19)
local SILVER = Color3.fromRGB(175, 181, 184)

local startCFrame = CFrame.new(-28, 2, 154)

local function makePart(className, name, size, relativeCFrame, color, material, canCollide)
	local object = Instance.new(className)
	object.Name = name
	object.Anchored = true
	object.CanCollide = canCollide == true
	object.CanTouch = canCollide == true
	object.Size = size
	object.CFrame = startCFrame * relativeCFrame
	object.Color = color
	object.Material = material or Enum.Material.SmoothPlastic
	object.TopSurface = Enum.SurfaceType.Smooth
	object.BottomSurface = Enum.SurfaceType.Smooth
	object.Parent = car
	return object
end

local function bodyPart(name, size, position, color)
	return makePart("Part", name, size, CFrame.new(position), color or WHITE, Enum.Material.SmoothPlastic, false)
end

-- Chassi e volumes principais, na proporção aproximada 4,27 × 1,76 × 1,50 m.
local chassis = makePart("Part", "Chassis", Vector3.new(6.8, 0.7, 12.8), CFrame.new(0, 0, 0), BLACK, Enum.Material.Metal, true)
car.PrimaryPart = chassis

bodyPart("LowerBody", Vector3.new(6.9, 1.55, 12.2), Vector3.new(0, 1.05, 0), BLACK)
bodyPart("MainBody", Vector3.new(6.65, 1.8, 11.8), Vector3.new(0, 2.05, -0.15), WHITE)
bodyPart("FrontHood", Vector3.new(6.45, 0.65, 3.8), Vector3.new(0, 3.05, -4.45), WHITE)
bodyPart("RearDeck", Vector3.new(6.5, 0.8, 2.25), Vector3.new(0, 3.15, 4.7), WHITE)

-- Cabine cupê, com teto e colunas em preto.
bodyPart("CabinCore", Vector3.new(5.85, 2.35, 6.2), Vector3.new(0, 3.75, 0.65), GLOSS_BLACK)
local roof = bodyPart("BlackRoof", Vector3.new(5.5, 0.42, 5.25), Vector3.new(0, 5.05, 0.8), GLOSS_BLACK)
roof.Material = Enum.Material.Metal

local windshield = makePart(
	"Part",
	"Windshield",
	Vector3.new(5.55, 2.15, 0.22),
	CFrame.new(0, 4.12, -2.3) * CFrame.Angles(math.rad(-24), 0, 0),
	GLASS,
	Enum.Material.Glass,
	false
)
windshield.Transparency = 0.22
windshield.Reflectance = 0.08

local rearWindow = makePart(
	"Part",
	"RearWindow",
	Vector3.new(5.4, 2.05, 0.22),
	CFrame.new(0, 4.08, 3.72) * CFrame.Angles(math.rad(31), 0, 0),
	GLASS,
	Enum.Material.Glass,
	false
)
rearWindow.Transparency = 0.22
rearWindow.Reflectance = 0.08

for _, side in ipairs({-1, 1}) do
	local x = side * 2.98
	local sideWindowFront = makePart("Part", "FrontSideWindow", Vector3.new(0.18, 1.65, 2.4), CFrame.new(x, 4.15, -0.65), GLASS, Enum.Material.Glass, false)
	sideWindowFront.Transparency = 0.2
	local sideWindowRear = makePart("Part", "RearSideWindow", Vector3.new(0.18, 1.55, 2.2), CFrame.new(x, 4.05, 1.85) * CFrame.Angles(math.rad(8), 0, 0), GLASS, Enum.Material.Glass, false)
	sideWindowRear.Transparency = 0.2

	bodyPart("BPillar", Vector3.new(0.25, 2.05, 0.32), Vector3.new(x, 4.12, 0.65), GLOSS_BLACK)
	bodyPart("SideSkirt", Vector3.new(0.3, 0.55, 8.1), Vector3.new(side * 3.45, 1.05, 0.3), BLACK)
	bodyPart("RedSideAccent", Vector3.new(0.12, 0.16, 6.7), Vector3.new(side * 3.62, 1.43, 0.45), RED)

	bodyPart("FrontDoorLine", Vector3.new(0.08, 1.65, 0.1), Vector3.new(side * 3.36, 2.72, -0.55), Color3.fromRGB(92, 95, 96))
	bodyPart("RearDoorLine", Vector3.new(0.08, 1.55, 0.1), Vector3.new(side * 3.36, 2.67, 2.15), Color3.fromRGB(92, 95, 96))
	bodyPart("FrontHandle", Vector3.new(0.15, 0.16, 0.78), Vector3.new(side * 3.48, 3.2, -0.5), GLOSS_BLACK)
	bodyPart("RearHandle", Vector3.new(0.15, 0.16, 0.78), Vector3.new(side * 3.48, 3.12, 2.12), GLOSS_BLACK)

	local mirror = bodyPart("Mirror", Vector3.new(0.72, 0.48, 0.9), Vector3.new(side * 3.65, 4.05, -1.75), GLOSS_BLACK)
	mirror.Material = Enum.Material.Metal
end

-- Rodas GTS diamantadas de 18 polegadas.
local wheelPositions = {
	Vector3.new(-3.48, 0.05, -4.15),
	Vector3.new(3.48, 0.05, -4.15),
	Vector3.new(-3.48, 0.05, 4.0),
	Vector3.new(3.48, 0.05, 4.0),
}

for wheelIndex, position in ipairs(wheelPositions) do
	local tire = makePart("Part", "Tire", Vector3.new(0.72, 3.05, 3.05), CFrame.new(position), BLACK, Enum.Material.Rubber, false)
	tire.Shape = Enum.PartType.Cylinder

	local side = position.X < 0 and -1 or 1
	local rimX = position.X + side * 0.39
	local rim = makePart("Part", "DiamondCutRim", Vector3.new(0.16, 2.15, 2.15), CFrame.new(rimX, position.Y, position.Z), SILVER, Enum.Material.Metal, false)
	rim.Shape = Enum.PartType.Cylinder

	local hub = makePart("Part", "WheelHub", Vector3.new(0.2, 0.58, 0.58), CFrame.new(rimX + side * 0.04, position.Y, position.Z), GLOSS_BLACK, Enum.Material.Metal, false)
	hub.Shape = Enum.PartType.Cylinder

	for spokeIndex = 1, 5 do
		local angle = math.rad((spokeIndex - 1) * 72)
		makePart(
			"Part",
			"WheelSpoke",
			Vector3.new(0.2, 0.25, 1.7),
			CFrame.new(rimX + side * 0.12, position.Y, position.Z) * CFrame.Angles(angle, 0, 0),
			GLOSS_BLACK,
			Enum.Material.Metal,
			false
		)
	end
end

-- Dianteira GTS: grade colmeia, faróis finos, assinatura em LED e detalhe vermelho.
bodyPart("FrontBumper", Vector3.new(6.75, 1.4, 0.65), Vector3.new(0, 1.7, -6.18), WHITE)
local grille = bodyPart("HoneycombGrille", Vector3.new(4.5, 0.92, 0.18), Vector3.new(0, 1.55, -6.55), BLACK)
grille.Material = Enum.Material.Metal
bodyPart("RedFrontAccent", Vector3.new(5.35, 0.16, 0.2), Vector3.new(0, 2.27, -6.57), RED)

for _, x in ipairs({-2.12, 2.12}) do
	local headlight = bodyPart("LEDHeadlight", Vector3.new(1.72, 0.44, 0.2), Vector3.new(x, 2.86, -6.19), Color3.fromRGB(219, 241, 255))
	headlight.Material = Enum.Material.Neon
	bodyPart("DRL", Vector3.new(1.9, 0.1, 0.22), Vector3.new(x, 3.12, -6.18), Color3.fromRGB(240, 249, 255)).Material = Enum.Material.Neon
end
bodyPart("FrontLightBar", Vector3.new(2.35, 0.1, 0.2), Vector3.new(0, 3.05, -6.2), Color3.fromRGB(231, 245, 255)).Material = Enum.Material.Neon

-- Traseira com faixa óptica contínua e para-choque esportivo.
bodyPart("RearBlackPanel", Vector3.new(6.55, 1.05, 0.25), Vector3.new(0, 2.78, 6.12), GLOSS_BLACK)
bodyPart("RearLightBar", Vector3.new(5.9, 0.25, 0.18), Vector3.new(0, 3.02, 6.29), RED).Material = Enum.Material.Neon
for _, x in ipairs({-2.35, 2.35}) do
	bodyPart("TailLamp", Vector3.new(1.25, 0.62, 0.2), Vector3.new(x, 2.95, 6.3), DARK_RED).Material = Enum.Material.Neon
end
bodyPart("RearDiffuser", Vector3.new(5.6, 0.65, 0.35), Vector3.new(0, 1.25, 6.42), SILVER).Material = Enum.Material.Metal
bodyPart("RearRedAccent", Vector3.new(5.85, 0.14, 0.22), Vector3.new(0, 1.72, 6.45), RED)

-- Aerofólio e emblemas.
bodyPart("RearSpoiler", Vector3.new(6, 0.28, 1.2), Vector3.new(0, 5.0, 4.08), GLOSS_BLACK).Material = Enum.Material.Metal
bodyPart("SharkFinAntenna", Vector3.new(0.35, 0.42, 0.8), Vector3.new(0, 5.45, 1.9), GLOSS_BLACK)

local function addBadge(name, text, relativeCFrame, size, textColor)
	local badgePart = makePart("Part", name, size, relativeCFrame, GLOSS_BLACK, Enum.Material.SmoothPlastic, false)
	local surface = Instance.new("SurfaceGui")
	surface.Face = Enum.NormalId.Front
	surface.AlwaysOnTop = true
	surface.Parent = badgePart
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = textColor
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = surface
	return badgePart
end

addBadge("FrontVWBadge", "VW", CFrame.new(0, 2.75, -6.58), Vector3.new(0.9, 0.9, 0.12), Color3.fromRGB(235, 238, 240))
addBadge("RearVWBadge", "VW", CFrame.new(0, 3.55, 6.3) * CFrame.Angles(0, math.rad(180), 0), Vector3.new(0.9, 0.9, 0.12), Color3.fromRGB(235, 238, 240))
addBadge("GTSBadge", "GTS", CFrame.new(2.0, 2.38, -6.59), Vector3.new(0.95, 0.38, 0.1), RED)

-- Assento e interação para dirigir.
local driverSeat = Instance.new("VehicleSeat")
driverSeat.Name = "DriverSeat"
driverSeat.Anchored = true
driverSeat.CanCollide = false
driverSeat.Transparency = 1
driverSeat.Size = Vector3.new(2.1, 1, 2.2)
driverSeat.CFrame = startCFrame * CFrame.new(-1.35, 3.65, 0)
driverSeat.MaxSpeed = 70
driverSeat.TurnSpeed = 1.55
driverSeat.Parent = car

local drivePrompt = Instance.new("ProximityPrompt")
drivePrompt.Name = "DrivePrompt"
drivePrompt.ActionText = "Dirigir"
drivePrompt.ObjectText = "VW Nivus GTS 2026"
drivePrompt.HoldDuration = 0
drivePrompt.MaxActivationDistance = 12
drivePrompt.RequiresLineOfSight = false
drivePrompt.Parent = chassis

drivePrompt.Triggered:Connect(function(player)
	if driverSeat.Occupant then
		return
	end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		driverSeat:Sit(humanoid)
	end
end)

driverSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
	drivePrompt.Enabled = driverSeat.Occupant == nil
end)

local carPosition = startCFrame.Position
local carHeading = 0

RunService.Heartbeat:Connect(function(deltaTime)
	if not driverSeat.Occupant then
		return
	end

	local throttle = driverSeat.ThrottleFloat
	local steering = driverSeat.SteerFloat
	local movementFactor = math.max(math.abs(throttle), 0.22)
	carHeading += -steering * 1.55 * movementFactor * deltaTime

	local direction = CFrame.Angles(0, carHeading, 0).LookVector
	local speed = throttle >= 0 and 70 or 34
	local proposed = carPosition + direction * throttle * speed * deltaTime
	proposed = Vector3.new(
		math.clamp(proposed.X, -195, 195),
		carPosition.Y,
		math.clamp(proposed.Z, -195, 195)
	)

	-- Impede que o carro atravesse o volume principal do edifício.
	local insideBuilding = math.abs(proposed.X) < 49 and math.abs(proposed.Z) < 42
	if not insideBuilding then
		carPosition = proposed
	end

	car:PivotTo(CFrame.new(carPosition) * CFrame.Angles(0, carHeading, 0))
end)

-- Placa de identificação acima do carro estacionado.
local marker = Instance.new("BillboardGui")
marker.Name = "CarMarker"
marker.Size = UDim2.fromOffset(240, 52)
marker.StudsOffset = Vector3.new(0, 7.5, 0)
marker.AlwaysOnTop = true
marker.MaxDistance = 80
marker.Parent = chassis

local markerText = Instance.new("TextLabel")
markerText.Size = UDim2.fromScale(1, 1)
markerText.BackgroundColor3 = Color3.fromRGB(20, 22, 24)
markerText.BackgroundTransparency = 0.18
markerText.Text = "VW NIVUS GTS 2026  •  DIRIGÍVEL"
markerText.TextColor3 = Color3.fromRGB(255, 255, 255)
markerText.TextScaled = true
markerText.Font = Enum.Font.GothamBold
markerText.Parent = marker

local markerCorner = Instance.new("UICorner")
markerCorner.CornerRadius = UDim.new(0, 10)
markerCorner.Parent = markerText

print("[roblox_game] VW Nivus GTS 2026 criado com sucesso.")

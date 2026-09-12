local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local WORLD_NAME = "EmpireStateWorld"
local ORIGINAL_MAP_SIZE = 420
local MAP_LINEAR_SCALE = 5
local MAP_SIZE = ORIGINAL_MAP_SIZE * MAP_LINEAR_SCALE
local MAP_HALF_EXTENT = MAP_SIZE / 2
local MAP_SAFE_LIMIT = MAP_HALF_EXTENT - 55

local previousWorld = Workspace:FindFirstChild(WORLD_NAME)
if previousWorld then
	previousWorld:Destroy()
end

local oldValidationWorld = Workspace:FindFirstChild("ValidationWorld")
if oldValidationWorld then
	oldValidationWorld:Destroy()
end

local world = Instance.new("Folder")
world.Name = WORLD_NAME
world.Parent = Workspace

local carpetControl = ReplicatedStorage:FindFirstChild("MagicCarpetControl")
if not carpetControl then
	carpetControl = Instance.new("RemoteEvent")
	carpetControl.Name = "MagicCarpetControl"
	carpetControl.Parent = ReplicatedStorage
end

local building = Instance.new("Model")
building.Name = "EmpireStateBuilding"
building.Parent = world

local STONE = Color3.fromRGB(171, 166, 151)
local STONE_LIGHT = Color3.fromRGB(196, 190, 171)
local STONE_DARK = Color3.fromRGB(126, 125, 118)
local WINDOW = Color3.fromRGB(69, 105, 124)
local WINDOW_LIT = Color3.fromRGB(255, 210, 112)
local METAL = Color3.fromRGB(135, 143, 146)

local function createPart(parent, name, size, position, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function addWindow(parent, name, size, position, lit)
	local window = createPart(
		parent,
		name,
		size,
		position,
		lit and WINDOW_LIT or WINDOW,
		lit and Enum.Material.Neon or Enum.Material.Glass
	)
	window.CanCollide = false
	window.CanTouch = false
	window.CastShadow = false
	return window
end

local function addTier(name, width, depth, height, bottomY, windowColumnsX, windowColumnsZ, windowRows)
	local tier = Instance.new("Model")
	tier.Name = name
	tier.Parent = building

	createPart(tier, "Structure", Vector3.new(width, height, depth), Vector3.new(0, bottomY + height / 2, 0), STONE, Enum.Material.Limestone)
	createPart(tier, "TopCornice", Vector3.new(width + 1.5, 1.5, depth + 1.5), Vector3.new(0, bottomY + height - 1, 0), STONE_LIGHT, Enum.Material.Limestone)

	local usableHeight = height - 8
	for row = 1, windowRows do
		local y = bottomY + 4 + (row - 0.5) * (usableHeight / windowRows)

		for column = 1, windowColumnsX do
			local x = -width / 2 + column * (width / (windowColumnsX + 1))
			local litFront = ((row * 3 + column * 5) % 7 == 0)
			local litBack = ((row * 5 + column * 2) % 9 == 0)
			addWindow(tier, "FrontWindow", Vector3.new(3.2, 4.5, 0.35), Vector3.new(x, y, depth / 2 + 0.18), litFront)
			addWindow(tier, "BackWindow", Vector3.new(3.2, 4.5, 0.35), Vector3.new(x, y, -depth / 2 - 0.18), litBack)
		end

		for column = 1, windowColumnsZ do
			local z = -depth / 2 + column * (depth / (windowColumnsZ + 1))
			local litRight = ((row * 4 + column * 3) % 8 == 0)
			local litLeft = ((row * 2 + column * 6) % 11 == 0)
			addWindow(tier, "RightWindow", Vector3.new(0.35, 4.5, 3.2), Vector3.new(width / 2 + 0.18, y, z), litRight)
			addWindow(tier, "LeftWindow", Vector3.new(0.35, 4.5, 3.2), Vector3.new(-width / 2 - 0.18, y, z), litLeft)
		end
	end

	return tier
end

-- A base natural mede 5x em cada eixo: 25x a área original. A região urbana
-- existente continua asfaltada e nivelada no centro, sem alterar os edifícios.
local expandedGround = createPart(
	world,
	"ExpandedTerrainBase",
	Vector3.new(MAP_SIZE, 2, MAP_SIZE),
	Vector3.new(0, -1.1, 0),
	Color3.fromRGB(91, 111, 73),
	Enum.Material.Grass
)
expandedGround.CastShadow = false
createPart(world, "Ground", Vector3.new(420, 2, 420), Vector3.new(0, -1, 0), Color3.fromRGB(72, 79, 74), Enum.Material.Asphalt)
createPart(world, "Plaza", Vector3.new(142, 1, 126), Vector3.new(0, 0.05, 0), Color3.fromRGB(184, 181, 168), Enum.Material.Concrete)

for _, z in ipairs({-77, 77}) do
	createPart(world, "Sidewalk", Vector3.new(420, 1, 18), Vector3.new(0, 0.1, z), Color3.fromRGB(154, 154, 150), Enum.Material.Concrete)
end

for _, x in ipairs({-90, 90}) do
	createPart(world, "Sidewalk", Vector3.new(18, 1, 420), Vector3.new(x, 0.1, 0), Color3.fromRGB(154, 154, 150), Enum.Material.Concrete)
end

-- Colinas internas e uma cadeia montanhosa contínua escondem visualmente os
-- limites. Poucos volumes grandes de Terrain mantêm o custo baixo no iPhone.
local terrain = Workspace.Terrain
local mountainStep = 120
local mountainStart = -900
local mountainEnd = 900

local function terrainBall(position, radius, material)
	terrain:FillBall(position, radius, material)
end

local function buildMountainSide(axis, direction)
	local index = 0
	for along = mountainStart, mountainEnd, mountainStep do
		index += 1
		local variation = math.sin(index * 1.71 + (direction > 0 and 0.8 or 2.3))
		local offset = math.cos(index * 2.13) * 24
		local outerRadius = 205 + variation * 32
		local foothillRadius = 82 + math.cos(index * 1.37) * 15
		local outerCoordinate = direction * 930
		local innerCoordinate = direction * 715

		local outerPosition
		local innerPosition
		if axis == "X" then
			outerPosition = Vector3.new(outerCoordinate, outerRadius * 0.08 - 18, along + offset)
			innerPosition = Vector3.new(innerCoordinate, -28, along - offset * 0.5)
		else
			outerPosition = Vector3.new(along + offset, outerRadius * 0.08 - 18, outerCoordinate)
			innerPosition = Vector3.new(along - offset * 0.5, -28, innerCoordinate)
		end

		terrainBall(outerPosition, outerRadius, index % 3 == 0 and Enum.Material.Slate or Enum.Material.Rock)
		terrainBall(innerPosition, foothillRadius, Enum.Material.Grass)
	end
end

buildMountainSide("X", -1)
buildMountainSide("X", 1)
buildMountainSide("Z", -1)
buildMountainSide("Z", 1)

-- A barreira fica embutida nos picos. Ela impede jogadores e carros de chegar
-- ao vazio mesmo que encontrem uma passagem entre os volumes de Terrain.
local boundaries = Instance.new("Model")
boundaries.Name = "MountainBoundaries"
boundaries.Parent = world

local function boundary(name, size, position)
	local wall = createPart(boundaries, name, size, position, Color3.new(1, 1, 1), Enum.Material.SmoothPlastic)
	wall.Transparency = 1
	wall.CanCollide = true
	wall.CanTouch = false
	wall.CanQuery = false
	wall.CastShadow = false
end

local wallHeight = 820
local wallCenterY = wallHeight / 2
local wallPosition = MAP_HALF_EXTENT - 12
boundary("WestBoundary", Vector3.new(18, wallHeight, MAP_SIZE), Vector3.new(-wallPosition, wallCenterY, 0))
boundary("EastBoundary", Vector3.new(18, wallHeight, MAP_SIZE), Vector3.new(wallPosition, wallCenterY, 0))
boundary("NorthBoundary", Vector3.new(MAP_SIZE, wallHeight, 18), Vector3.new(0, wallCenterY, -wallPosition))
boundary("SouthBoundary", Vector3.new(MAP_SIZE, wallHeight, 18), Vector3.new(0, wallCenterY, wallPosition))

-- Corpo escalonado inspirado nas proporções e recuos do Empire State Building.
addTier("Podium", 84, 70, 30, 0, 9, 7, 3)
addTier("LowerSetback", 72, 60, 42, 30, 8, 6, 5)
addTier("MainTower", 58, 48, 105, 72, 7, 5, 13)
addTier("UpperSetbackOne", 48, 40, 40, 177, 6, 4, 5)
addTier("UpperSetbackTwo", 38, 32, 34, 217, 4, 3, 4)
addTier("ObservationTower", 29, 27, 27, 251, 3, 3, 3)
addTier("Crown", 21, 21, 17, 278, 2, 2, 2)

-- Nervuras verticais típicas do desenho Art Deco.
for _, x in ipairs({-25, -19, 19, 25}) do
	createPart(building, "VerticalRib", Vector3.new(1.2, 101, 1), Vector3.new(x, 124, 24.6), STONE_LIGHT, Enum.Material.Limestone)
	createPart(building, "VerticalRib", Vector3.new(1.2, 101, 1), Vector3.new(x, 124, -24.6), STONE_LIGHT, Enum.Material.Limestone)
end

for _, z in ipairs({-19, -13, 13, 19}) do
	createPart(building, "VerticalRib", Vector3.new(1, 101, 1.2), Vector3.new(29.6, 124, z), STONE_LIGHT, Enum.Material.Limestone)
	createPart(building, "VerticalRib", Vector3.new(1, 101, 1.2), Vector3.new(-29.6, 124, z), STONE_LIGHT, Enum.Material.Limestone)
end

-- Entrada principal voltada para a praça.
createPart(building, "EntranceFrame", Vector3.new(22, 16, 2), Vector3.new(0, 8, 36), STONE_DARK, Enum.Material.Marble)
createPart(building, "EntranceGlass", Vector3.new(15, 11, 0.5), Vector3.new(0, 6, 37.1), Color3.fromRGB(52, 79, 91), Enum.Material.Glass)
createPart(building, "EntranceCanopy", Vector3.new(24, 1.2, 8), Vector3.new(0, 13, 39), METAL, Enum.Material.Metal)

-- Terraços de observação e coroamento.
createPart(building, "LowerObservationDeck", Vector3.new(43, 1.5, 37), Vector3.new(0, 250.8, 0), STONE_LIGHT, Enum.Material.Limestone)
createPart(building, "UpperObservationDeck", Vector3.new(25, 1.2, 25), Vector3.new(0, 294.8, 0), METAL, Enum.Material.Metal)

local mastBase = createPart(building, "MastBase", Vector3.new(22, 13, 13), Vector3.new(0, 306, 0), STONE_DARK, Enum.Material.Metal)
mastBase.Shape = Enum.PartType.Cylinder
mastBase.Orientation = Vector3.new(0, 0, 90)

local mastMiddle = createPart(building, "MastMiddle", Vector3.new(31, 7, 7), Vector3.new(0, 332, 0), METAL, Enum.Material.Metal)
mastMiddle.Shape = Enum.PartType.Cylinder
mastMiddle.Orientation = Vector3.new(0, 0, 90)

local antenna = createPart(building, "Antenna", Vector3.new(46, 2.2, 2.2), Vector3.new(0, 370, 0), Color3.fromRGB(188, 194, 196), Enum.Material.Metal)
antenna.Shape = Enum.PartType.Cylinder
antenna.Orientation = Vector3.new(0, 0, 90)

local beacon = createPart(building, "Beacon", Vector3.new(4, 4, 4), Vector3.new(0, 394, 0), Color3.fromRGB(255, 55, 55), Enum.Material.Neon)
beacon.Shape = Enum.PartType.Ball
beacon.CanCollide = false

-- Ponto inicial com visão frontal completa do edifício.
local spawn = Instance.new("SpawnLocation")
spawn.Name = "PlayerSpawn"
spawn.Anchored = true
spawn.Size = Vector3.new(12, 1, 12)
spawn.Position = Vector3.new(0, 0.6, 168)
spawn.Orientation = Vector3.new(0, 180, 0)
spawn.Neutral = true
spawn.Material = Enum.Material.Concrete
spawn.Color = Color3.fromRGB(210, 210, 205)
spawn.Parent = world

-- Tapete voador: o VehicleSeat fornece direção pelo joystick do Roblox.
local carpet = Instance.new("Model")
carpet.Name = "MagicCarpet"
carpet.Parent = world

local carpetStart = Vector3.new(30, 4, 154)
local carpetBase = createPart(carpet, "CarpetBase", Vector3.new(10.5, 0.45, 15.5), carpetStart, Color3.fromRGB(244, 190, 47), Enum.Material.Fabric)
carpetBase.CanCollide = true
carpet.PrimaryPart = carpetBase

local rainbowColors = {
	Color3.fromRGB(232, 48, 54),
	Color3.fromRGB(245, 126, 31),
	Color3.fromRGB(250, 211, 44),
	Color3.fromRGB(75, 184, 72),
	Color3.fromRGB(48, 145, 218),
	Color3.fromRGB(76, 79, 181),
	Color3.fromRGB(153, 67, 173),
}

for index, color in ipairs(rainbowColors) do
	local stripeZ = -6.3 + (index - 1) * 2.1
	local stripe = createPart(carpet, "RainbowStripe", Vector3.new(9.8, 0.16, 2.08), carpetStart + Vector3.new(0, 0.3, stripeZ), color, Enum.Material.Fabric)
	stripe.CanCollide = false
end

for _, x in ipairs({-4.5, -2.7, -0.9, 0.9, 2.7, 4.5}) do
	for _, z in ipairs({-8, 8}) do
		local tassel = createPart(carpet, "Tassel", Vector3.new(0.28, 0.28, 2), carpetStart + Vector3.new(x, 0, z), Color3.fromRGB(244, 200, 73), Enum.Material.Fabric)
		tassel.CanCollide = false
	end
end

local carpetSeat = Instance.new("VehicleSeat")
carpetSeat.Name = "CarpetSeat"
carpetSeat.Anchored = true
carpetSeat.CanCollide = false
carpetSeat.Transparency = 1
carpetSeat.Size = Vector3.new(4, 1, 4)
carpetSeat.Position = carpetStart + Vector3.new(0, 1, 1)
carpetSeat.MaxSpeed = 45
carpetSeat.TurnSpeed = 1.8
carpetSeat.Parent = carpet

local carpetPrompt = Instance.new("ProximityPrompt")
carpetPrompt.Name = "FlyPrompt"
carpetPrompt.ActionText = "Voar"
carpetPrompt.ObjectText = "Tapete voador arco-íris — grátis"
carpetPrompt.HoldDuration = 0
carpetPrompt.MaxActivationDistance = 12
carpetPrompt.RequiresLineOfSight = false
carpetPrompt.Parent = carpetBase

local carpetPosition = carpetStart
local carpetHeading = math.rad(180)
local carpetVertical = 0

local function carpetPlayer()
	local humanoid = carpetSeat.Occupant
	if not humanoid then
		return nil
	end
	return Players:GetPlayerFromCharacter(humanoid.Parent)
end

carpetPrompt.Triggered:Connect(function(player)
	if carpetSeat.Occupant then
		return
	end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		carpetSeat:Sit(humanoid)
	end
end)

carpetSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
	carpetVertical = 0
	carpetPrompt.Enabled = carpetSeat.Occupant == nil
end)

carpetControl.OnServerEvent:Connect(function(player, action, value)
	if carpetPlayer() ~= player then
		return
	end

	if action == "vertical" and type(value) == "number" then
		carpetVertical = math.clamp(value, -1, 1)
	elseif action == "exit" then
		local humanoid = carpetSeat.Occupant
		if humanoid then
			humanoid.Sit = false
		end
	end
end)

RunService.Heartbeat:Connect(function(deltaTime)
	if not carpetSeat.Occupant then
		return
	end

	local throttle = carpetSeat.ThrottleFloat
	local steering = carpetSeat.SteerFloat
	carpetHeading += -steering * 1.8 * deltaTime

	local direction = CFrame.Angles(0, carpetHeading, 0).LookVector
	carpetPosition += direction * throttle * 45 * deltaTime
	carpetPosition += Vector3.new(0, carpetVertical * 28 * deltaTime, 0)
	carpetPosition = Vector3.new(
		math.clamp(carpetPosition.X, -MAP_SAFE_LIMIT, MAP_SAFE_LIMIT),
		math.clamp(carpetPosition.Y, 4, 410),
		math.clamp(carpetPosition.Z, -MAP_SAFE_LIMIT, MAP_SAFE_LIMIT)
	)

	carpet:PivotTo(CFrame.new(carpetPosition) * CFrame.Angles(0, carpetHeading, 0))
end)

-- Iluminação de fim de tarde para destacar pedra, vidro e luzes internas.
Lighting.ClockTime = 17.3
Lighting.Brightness = 2
Lighting.Ambient = Color3.fromRGB(95, 101, 112)
Lighting.OutdoorAmbient = Color3.fromRGB(132, 137, 145)

Players.PlayerAdded:Connect(function(player)
	print(string.format("[roblox_game] Empire State carregado para %s", player.Name))
end)

print("[roblox_game] Primeira versão do Empire State Building carregada com sucesso.")

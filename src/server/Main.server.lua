local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local WORLD_NAME = "EmpireStateWorld"

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

-- Praça e ruas: dão escala ao edifício e criam uma área segura para o jogador.
createPart(world, "Ground", Vector3.new(420, 2, 420), Vector3.new(0, -1, 0), Color3.fromRGB(72, 79, 74), Enum.Material.Asphalt)
createPart(world, "Plaza", Vector3.new(142, 1, 126), Vector3.new(0, 0.05, 0), Color3.fromRGB(184, 181, 168), Enum.Material.Concrete)

for _, z in ipairs({-77, 77}) do
	createPart(world, "Sidewalk", Vector3.new(420, 1, 18), Vector3.new(0, 0.1, z), Color3.fromRGB(154, 154, 150), Enum.Material.Concrete)
end

for _, x in ipairs({-90, 90}) do
	createPart(world, "Sidewalk", Vector3.new(18, 1, 420), Vector3.new(x, 0.1, 0), Color3.fromRGB(154, 154, 150), Enum.Material.Concrete)
end

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

-- Iluminação de fim de tarde para destacar pedra, vidro e luzes internas.
Lighting.ClockTime = 17.3
Lighting.Brightness = 2
Lighting.Ambient = Color3.fromRGB(95, 101, 112)
Lighting.OutdoorAmbient = Color3.fromRGB(132, 137, 145)

Players.PlayerAdded:Connect(function(player)
	print(string.format("[roblox_game] Empire State carregado para %s", player.Name))
end)

print("[roblox_game] Primeira versão do Empire State Building carregada com sucesso.")

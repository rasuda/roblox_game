local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local Builder = require(script.Parent.Builder)
local Complexes = require(script.Parent.Complexes)

local CityBuilder = {}

-- Roblox limita cada eixo de uma Part a 2048 studs. O mapa grande precisa ser
-- dividido em blocos menores para não interromper a geração após limpar o cenário.
local SAFE_PART_LENGTH = 1000

local function addLongParts(parent, name, width, height, length, x, y, color, material)
	local segmentCount = math.ceil(length / SAFE_PART_LENGTH)
	local segmentLength = length / segmentCount
	for index = 1, segmentCount do
		local z = -length / 2 + segmentLength / 2 + (index - 1) * segmentLength
		Builder.part(parent, name .. index, Vector3.new(width, height, segmentLength), CFrame.new(x, y, z), color, material, true)
	end
end

local function addPalm(parent, position, scale, decorativeShadows)
	local model = Builder.model(parent, "Palm")
	local trunkHeight = 22 * scale
	local trunk = Builder.part(model, "Trunk", Vector3.new(2.2 * scale, trunkHeight, 2.2 * scale), CFrame.new(position + Vector3.new(0, trunkHeight / 2, 0)), Color3.fromRGB(117, 78, 45), Enum.Material.Wood, true)
	trunk.CastShadow = decorativeShadows

	for index = 1, 4 do
		local angle = math.rad((index - 1) * 90 + 45)
		local center = position + Vector3.new(math.cos(angle) * 5.5 * scale, trunkHeight + 0.2, math.sin(angle) * 5.5 * scale)
		local leaf = Builder.part(model, "Frond", Vector3.new(9 * scale, 0.6 * scale, 3.3 * scale), CFrame.new(center) * CFrame.Angles(0, -angle, math.rad(index % 2 == 0 and 10 or -10)), Color3.fromRGB(52, 125, 67), Enum.Material.Grass, false)
		leaf.CastShadow = decorativeShadows
	end
	return model
end

local function addStreetLight(parent, position, roadSide, index, config)
	local model = Builder.model(parent, "StreetLight")
	local darkMetal = Color3.fromRGB(48, 50, 57)
	Builder.part(model, "Pole", Vector3.new(1.1, 23, 1.1), CFrame.new(position + Vector3.new(0, 11.5, 0)), darkMetal, Enum.Material.Metal, true).CastShadow = false
	local armDirection = roadSide > 0 and -1 or 1
	Builder.part(model, "Arm", Vector3.new(8, 0.8, 0.8), CFrame.new(position + Vector3.new(armDirection * 3.5, 22.5, 0)), darkMetal, Enum.Material.Metal, false).CastShadow = false
	local lamp = Builder.part(model, "Lamp", Vector3.new(3.5, 0.6, 2.2), CFrame.new(position + Vector3.new(armDirection * 7, 22, 0)), config.Palette.WarmLight, Enum.Material.Neon, false)
	Builder.neon(lamp, config.Palette.WarmLight)

	-- Só uma fração dos postes projeta luz real; os demais usam emissão visual barata.
	if index % 4 == 0 then
		local light = Instance.new("PointLight")
		light.Name = "EfficientStreetGlow"
		light.Color = config.Palette.WarmLight
		light.Brightness = 1.15
		light.Range = 33
		light.Shadows = false
		light.Parent = lamp
		CollectionService:AddTag(light, "CityDynamicLight")
	end
	return model
end

local function addTrafficSignal(parent, position, facesAlongZ)
	local model = Builder.model(parent, "TrafficSignal")
	Builder.part(model, "Pole", Vector3.new(1.2, 18, 1.2), CFrame.new(position + Vector3.new(0, 9, 0)), Color3.fromRGB(54, 56, 61), Enum.Material.Metal, true).CastShadow = false
	local signal = Builder.part(model, "SignalBox", Vector3.new(facesAlongZ and 4 or 2.2, 7, facesAlongZ and 2.2 or 4), CFrame.new(position + Vector3.new(0, 17, 0)), Color3.fromRGB(31, 33, 37), Enum.Material.Metal, false)
	signal.CastShadow = false
	local red = Builder.part(model, "RedSignal", facesAlongZ and Vector3.new(1.3, 1.3, 0.35) or Vector3.new(0.35, 1.3, 1.3), CFrame.new(position + Vector3.new(facesAlongZ and 0 or 1.3, 19, facesAlongZ and 1.3 or 0)), Color3.fromRGB(244, 67, 64), Enum.Material.Neon, false)
	Builder.neon(red, red.Color)
	local green = Builder.part(model, "GreenSignal", facesAlongZ and Vector3.new(1.3, 1.3, 0.35) or Vector3.new(0.35, 1.3, 1.3), CFrame.new(position + Vector3.new(facesAlongZ and 0 or 1.3, 15.5, facesAlongZ and 1.3 or 0)), Color3.fromRGB(68, 209, 109), Enum.Material.Neon, false)
	Builder.neon(green, green.Color)
	return model
end

local function addStaticTraffic(parent, position, color, heading)
	local model = Builder.model(parent, "AmbientTraffic")
	local baseCFrame = CFrame.new(position) * CFrame.Angles(0, heading, 0)
	Builder.part(model, "Chassis", Vector3.new(7, 2.2, 13), baseCFrame * CFrame.new(0, 2.1, 0), color, Enum.Material.SmoothPlastic, true)
	local glass = Builder.part(model, "Cabin", Vector3.new(5.8, 2.4, 6), baseCFrame * CFrame.new(0, 4.2, 0.5), Color3.fromRGB(39, 58, 69), Enum.Material.Glass, false)
	glass.Transparency = 0.12
	for _, x in ipairs({-3.65, 3.65}) do
		for _, z in ipairs({-4.2, 4.2}) do
			local wheel = Builder.part(model, "Wheel", Vector3.new(0.8, 2.7, 2.7), baseCFrame * CFrame.new(x, 1.25, z), Color3.fromRGB(20, 21, 23), Enum.Material.Rubber, false)
			wheel.Shape = Enum.PartType.Cylinder
		end
	end
	return model
end

local function buildTerrain(world, config)
	local terrainFolder = Builder.model(world, "TerrainAndHorizon")
	local size = config.World.Size
	local tileCount = math.ceil(size / SAFE_PART_LENGTH)
	local tileSize = size / tileCount
	for xIndex = 1, tileCount do
		for zIndex = 1, tileCount do
			local x = -size / 2 + tileSize / 2 + (xIndex - 1) * tileSize
			local z = -size / 2 + tileSize / 2 + (zIndex - 1) * tileSize
			Builder.part(terrainFolder, "DesertTile", Vector3.new(tileSize, 8, tileSize), CFrame.new(x, -4, z), config.Palette.Sand, Enum.Material.Sand, true)
		end
	end

	local mountainDistance = config.World.MountainDistance
	for index = 1, 16 do
		local angle = (index / 16) * math.pi * 2
		local distance = mountainDistance + ((index % 3) - 1) * 120
		local height = 180 + (index % 5) * 42
		local width = 340 + (index % 4) * 75
		local position = Vector3.new(math.cos(angle) * distance, height / 2 - 2, math.sin(angle) * distance)
		local mountain = Builder.wedge(terrainFolder, "DistantMountain", Vector3.new(width, height, 250), CFrame.new(position) * CFrame.Angles(0, -angle + math.pi / 2, 0), Color3.fromRGB(128 + index % 3 * 9, 94, 71), Enum.Material.Sandstone, true)
		mountain.CastShadow = false
	end
	return terrainFolder
end

local function buildRoadNetwork(world, config)
	local roads = Builder.model(world, "RoadNetwork")
	local strip = config.Strip
	local halfLength = strip.Length / 2
	addLongParts(roads, "MainStrip", strip.RoadWidth, 1, strip.Length, 0, 0.15, config.Palette.Asphalt, Enum.Material.Asphalt)
	addLongParts(roads, "CenterMedian", strip.MedianWidth, 1.3, strip.Length, 0, 0.85, Color3.fromRGB(125, 119, 102), Enum.Material.Concrete)

	local sidewalkX = strip.RoadWidth / 2 + strip.SidewalkWidth / 2
	for _, side in ipairs({-1, 1}) do
		addLongParts(roads, "StripSidewalk", strip.SidewalkWidth, 1.2, strip.Length, side * sidewalkX, 0.7, config.Palette.Concrete, Enum.Material.Concrete)
	end

	local drivingHalfWidth = (strip.RoadWidth - strip.MedianWidth) / 2
	local laneWidth = drivingHalfWidth / strip.LaneCountPerDirection
	for z = -halfLength + 35, halfLength - 35, 58 do
		for _, side in ipairs({-1, 1}) do
			for lane = 1, strip.LaneCountPerDirection - 1 do
				local x = side * (strip.MedianWidth / 2 + laneWidth * lane)
				local line = Builder.part(roads, "LaneDash", Vector3.new(0.7, 0.12, 25), CFrame.new(x, 0.73, z), Color3.fromRGB(225, 225, 215), Enum.Material.Neon, false)
				line.CastShadow = false
			end
		end
	end

	for z = -1200, 1200, strip.IntersectionSpacing do
		Builder.part(roads, "CrossAvenue", Vector3.new(930, 1.05, 66), CFrame.new(0, 0.24, z), config.Palette.Asphalt, Enum.Material.Asphalt, true)
		for _, x in ipairs({-76, 76}) do
			addTrafficSignal(roads, Vector3.new(x, 0, z + (x > 0 and 27 or -27)), true)
		end
		for x = -430, 430, 48 do
			Builder.part(roads, "CrosswalkMark", Vector3.new(18, 0.1, 2.2), CFrame.new(x, 0.82, z + 27), Color3.fromRGB(222, 219, 204), Enum.Material.Concrete, false).CastShadow = false
		end
	end
	return roads
end

local function buildStreetDecor(world, config)
	local decor = Builder.model(world, "StreetDecor")
	local halfLength = config.Strip.Length / 2
	local sidewalkEdge = config.Strip.RoadWidth / 2 + config.Strip.SidewalkWidth - 4
	local index = 0
	for z = -halfLength + 60, halfLength - 60, config.Density.StreetLightSpacing do
		index += 1
		for _, side in ipairs({-1, 1}) do
			addStreetLight(decor, Vector3.new(side * sidewalkEdge, 1.3, z), side, index + (side > 0 and 2 or 0), config)
		end
	end

	for z = -halfLength + 90, halfLength - 90, config.Density.PalmSpacing do
		local offset = (math.floor((z + halfLength) / config.Density.PalmSpacing) % 2 == 0) and 0 or 32
		for _, side in ipairs({-1, 1}) do
			addPalm(decor, Vector3.new(side * (sidewalkEdge + 13), 1, z + offset), 0.88 + ((index + side) % 3) * 0.07, config.Performance.DecorativeShadows)
		end
	end
	return decor
end

local function buildBackgroundCity(world, config)
	local district = Builder.model(world, "TransitionDistricts")
	local random = Random.new(260905)
	local colors = {
		Color3.fromRGB(159, 145, 129), Color3.fromRGB(122, 135, 146),
		Color3.fromRGB(177, 151, 123), Color3.fromRGB(102, 111, 124),
	}
	for index = 1, config.Density.BackgroundBuildingCount do
		local side = index % 2 == 0 and -1 or 1
		local x = side * random:NextNumber(480, 710)
		local z = random:NextNumber(-1500, 1500)
		local height = random:NextNumber(28, 82) * config.Layout.BuildingHeightScale
		local width = random:NextNumber(45, 90)
		local depth = random:NextNumber(45, 90)
		Builder.building(district, "LowRise" .. index, Vector3.new(x, 0, z), Vector3.new(width, height, depth), colors[index % #colors + 1], config.Palette.WarmLight, 2)
	end

	local trafficColors = {
		Color3.fromRGB(204, 52, 56), Color3.fromRGB(225, 226, 225),
		Color3.fromRGB(38, 93, 157), Color3.fromRGB(38, 39, 42),
	}
	for index = 1, config.Density.TrafficVehicleCount do
		local side = index % 2 == 0 and -1 or 1
		local laneX = side * (13 + (index % 3) * 13)
		local z = -1450 + index * (2900 / config.Density.TrafficVehicleCount)
		addStaticTraffic(district, Vector3.new(laneX, 0.7, z), trafficColors[index % #trafficColors + 1], side > 0 and math.pi or 0)
	end
	return district
end

local function buildComplexes(world, config)
	local complexes = Builder.model(world, "LandmarkComplexes")
	local setback = config.Layout.LandmarkSetback
	local spacing = config.Layout.LandmarkSpacing
	Complexes.buildParis(complexes, Vector3.new(-setback, 0, -2 * spacing), config)
	Complexes.buildMetro(complexes, Vector3.new(setback, 0, -spacing), config)
	Complexes.buildModern(complexes, Vector3.new(-setback, 0, 0), config)
	Complexes.buildDesert(complexes, Vector3.new(setback, 0, spacing), config)
	Complexes.buildTropical(complexes, Vector3.new(-setback, 0, 2 * spacing), config)

	-- Vegetação adicional do resort tropical sem aumentar a densidade na cidade toda.
	for x = -setback - 115, -setback + 115, 46 do
		for _, z in ipairs({2 * spacing + 110, 2 * spacing + 155}) do
			addPalm(complexes, Vector3.new(x, 1, z), 1.05, config.Performance.DecorativeShadows)
		end
	end
	return complexes
end

local function addSpawn(world)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "PlayerSpawn"
	spawn.Anchored = true
	spawn.Size = Vector3.new(14, 1, 14)
	spawn.CFrame = CFrame.new(76, 1.4, -120) * CFrame.Angles(0, math.rad(180), 0)
	spawn.Neutral = true
	spawn.Material = Enum.Material.Neon
	spawn.Color = Color3.fromRGB(70, 203, 177)
	spawn.Parent = world
	return spawn
end

function CityBuilder.clearOldMap(config)
	local terrain = Workspace:FindFirstChildOfClass("Terrain")
	for _, child in ipairs(Workspace:GetChildren()) do
		local keep = child == terrain or child == Workspace.CurrentCamera or child:GetAttribute("PreserveAcrossCityRebuild") == true
		if not keep then
			child:Destroy()
		end
	end
	if terrain then
		terrain:Clear()
	end
end

function CityBuilder.build(config)
	CityBuilder.clearOldMap(config)

	Workspace.FallenPartsDestroyHeight = -200

	local world = Instance.new("Folder")
	world.Name = config.WorldName
	world:SetAttribute("CityVersion", config.Version)
	world.Parent = Workspace

	buildTerrain(world, config)
	buildRoadNetwork(world, config)
	buildComplexes(world, config)
	buildStreetDecor(world, config)
	buildBackgroundCity(world, config)
	addSpawn(world)
	return world
end

return CityBuilder

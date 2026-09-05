local Builder = require(script.Parent.Builder)

local Complexes = {}

local function podium(parent, origin, width, depth, color, accent)
	Builder.part(parent, "Podium", Vector3.new(width, 24, depth), CFrame.new(origin + Vector3.new(0, 12, 0)), color, Enum.Material.Concrete, true)
	local streetDirection = origin.X < 0 and 1 or -1
	local canopy = Builder.part(parent, "EntranceCanopy", Vector3.new(18, 3, 42), CFrame.new(origin + Vector3.new(streetDirection * (width / 2 + 8), 15, 0)), accent, Enum.Material.Neon, false)
	Builder.neon(canopy, accent)
end

local function fountainJet(parent, position, height, color)
	local jet = Builder.part(parent, "FutureWaterJet", Vector3.new(1.2, height, 1.2), CFrame.new(position + Vector3.new(0, height / 2, 0)), color, Enum.Material.Glass, false)
	jet.Transparency = 0.28
	jet:SetAttribute("FountainJet", true)
	return jet
end

function Complexes.buildParis(parent, origin, config)
	local model = Builder.model(parent, "ComplexA_CelesteEuropeanQuarter")
	local heightScale = config.Layout.BuildingHeightScale
	local stone = Color3.fromRGB(207, 190, 158)
	local gold = Color3.fromRGB(255, 180, 62)
	podium(model, origin, 230, 145, stone, gold)
	Builder.building(model, "CelesteGrandHotel", origin + Vector3.new(-45, 24, -15), Vector3.new(135, 190 * heightScale, 72), stone, gold, 8)
	Builder.part(model, "EuropeanPlaza", Vector3.new(56, 1, 132), CFrame.new(origin + Vector3.new(144, 0.8, 0)), Color3.fromRGB(198, 186, 164), Enum.Material.Cobblestone, true)
	Builder.sign(model, "CELESTE", Vector3.new(82, 18, 2), CFrame.new(origin + Vector3.new(24, 145, -15)) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(46, 74, 125), Color3.fromRGB(255, 224, 145))

	local tower = Builder.model(model, "SkyLatticeTower")
	local base = origin + Vector3.new(82, 0, 18)
	local levels = {
		{0, 56, 96},
		{96, 27, 92},
		{188, 12, 72},
		{260, 4, 42},
	}
	for _, level in ipairs(levels) do
		local bottomY, radius, height = level[1], level[2], level[3]
		local nextRadius = math.max(2, radius * 0.48)
		for _, signs in ipairs({{-1, -1}, {-1, 1}, {1, -1}, {1, 1}}) do
			local startPoint = base + Vector3.new(signs[1] * radius, bottomY, signs[2] * radius)
			local endPoint = base + Vector3.new(signs[1] * nextRadius, bottomY + height, signs[2] * nextRadius)
			Builder.beam(tower, "LatticeLeg", startPoint, endPoint, bottomY == 0 and 7 or 4, Color3.fromRGB(116, 91, 61), Enum.Material.Metal)
		end
		Builder.part(tower, "ObservationDeck", Vector3.new(radius * 1.55, 4, radius * 1.55), CFrame.new(base + Vector3.new(0, bottomY + height, 0)), gold, Enum.Material.Metal, false)
	end
	local beacon = Builder.part(tower, "TowerBeacon", Vector3.new(4, 18, 4), CFrame.new(base + Vector3.new(0, 323, 0)), gold, Enum.Material.Neon, false)
	Builder.neon(beacon, gold)
	return model
end

function Complexes.buildMetro(parent, origin, config)
	local model = Builder.model(parent, "ComplexB_MetroSkyline")
	local heightScale = config.Layout.BuildingHeightScale
	local concrete = Color3.fromRGB(134, 142, 155)
	local colors = {
		Color3.fromRGB(235, 86, 75),
		Color3.fromRGB(74, 170, 226),
		Color3.fromRGB(247, 190, 72),
		Color3.fromRGB(182, 98, 221),
	}
	podium(model, origin, 290, 165, Color3.fromRGB(92, 96, 107), colors[2])
	local towers = {
		{-100, -25, 62, 56, 210}, {-38, -35, 54, 60, 285},
		{23, -28, 58, 52, 235}, {82, -42, 48, 58, 175},
		{118, 18, 42, 48, 128}, {-90, 32, 45, 45, 145},
	}
	for index, data in ipairs(towers) do
		Builder.building(model, "MetroTower" .. index, origin + Vector3.new(data[1], 24, data[2]), Vector3.new(data[3], data[5] * heightScale, data[4]), concrete:Lerp(colors[(index - 1) % #colors + 1], 0.12), colors[(index - 1) % #colors + 1], math.floor(data[5] / 38))
	end
	Builder.sign(model, "METRO SKY", Vector3.new(105, 22, 2), CFrame.new(origin + Vector3.new(-147, 112, 0)) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(205, 47, 70), Color3.new(1, 1, 1))

	local coasterZone = Builder.part(model, "FutureCoasterZone", Vector3.new(300, 1, 62), CFrame.new(origin + Vector3.new(0, 1, -118)), Color3.fromRGB(70, 105, 76), Enum.Material.Grass, true)
	coasterZone:SetAttribute("ReservedForExpansion", "RollerCoaster")
	return model
end

function Complexes.buildModern(parent, origin, config)
	local model = Builder.model(parent, "ComplexC_AuroraGlassResort")
	local heightScale = config.Layout.BuildingHeightScale
	local glass = Color3.fromRGB(54, 110, 145)
	local cyan = config.Palette.Cyan
	podium(model, origin, 260, 150, Color3.fromRGB(88, 96, 105), cyan)

	for index, data in ipairs({{-62, 0, 118, 300}, {53, -12, 104, 255}}) do
		local x, z, width, height = data[1], data[2], data[3], data[4] * heightScale
		local tower = Builder.part(model, "CurvedGlassTower" .. index, Vector3.new(width, height, 68), CFrame.new(origin + Vector3.new(x, 24 + height / 2, z)), glass, Enum.Material.Glass, true)
		tower.Transparency = 0.08
		for stripe = 1, 5 do
			local accent = Builder.part(model, "VerticalLight", Vector3.new(2, height * 0.9, 1), CFrame.new(origin + Vector3.new(x - width / 2 + stripe * width / 6, 24 + height / 2, z + 34.6)), cyan, Enum.Material.Neon, false)
			Builder.neon(accent, cyan)
		end
	end
	Builder.sign(model, "AURORA", Vector3.new(100, 22, 2), CFrame.new(origin + Vector3.new(132, 150, 0)) * CFrame.Angles(0, math.rad(90), 0), cyan, Color3.new(1, 1, 1))

	local fountainCenter = origin + Vector3.new(140, 0, 0)
	local basin = Builder.part(model, "GrandFountainBasin", Vector3.new(58, 3, 220), CFrame.new(fountainCenter + Vector3.new(0, 1, 0)), Color3.fromRGB(48, 90, 119), Enum.Material.Slate, true)
	basin:SetAttribute("ReservedForExpansion", "SynchronizedFountainShow")
	local water = Builder.part(model, "FountainWater", Vector3.new(50, 1, 208), CFrame.new(fountainCenter + Vector3.new(0, 3, 0)), Color3.fromRGB(73, 178, 220), Enum.Material.Glass, false)
	water.Transparency = 0.3
	for _, z in ipairs({-125, 125}) do
		Builder.part(model, "FountainGarden", Vector3.new(56, 2, 22), CFrame.new(fountainCenter + Vector3.new(0, 1, z)), Color3.fromRGB(66, 126, 72), Enum.Material.Grass, true)
	end
	for z = -90, 90, 30 do
		fountainJet(model, fountainCenter + Vector3.new(0, 3, z), 10 + (90 - math.abs(z)) * 0.18, Color3.fromRGB(145, 226, 255))
	end
	return model
end

function Complexes.buildDesert(parent, origin, config)
	local model = Builder.model(parent, "ComplexD_SolarisPyramid")
	local sandStone = Color3.fromRGB(191, 143, 67)
	local amber = Color3.fromRGB(255, 150, 34)
	podium(model, origin, 250, 160, Color3.fromRGB(143, 106, 64), amber)
	for level = 0, 11 do
		local width = 205 - level * 15.5
		Builder.part(model, "PyramidTier", Vector3.new(width, 14, width), CFrame.new(origin + Vector3.new(0, 31 + level * 14, -12)), sandStone:Lerp(Color3.new(1, 1, 1), level * 0.008), Enum.Material.Sandstone, true)
	end
	local cap = Builder.part(model, "PyramidCap", Vector3.new(24, 10, 24), CFrame.new(origin + Vector3.new(0, 193, -12)), amber, Enum.Material.Neon, false)
	Builder.neon(cap, amber)
	for _, x in ipairs({-94, 94}) do
		Builder.part(model, "Obelisk", Vector3.new(10, 82, 10), CFrame.new(origin + Vector3.new(x, 65, 69)), sandStone, Enum.Material.Sandstone, true)
		local tip = Builder.part(model, "ObeliskLight", Vector3.new(12, 8, 12), CFrame.new(origin + Vector3.new(x, 108, 69)), amber, Enum.Material.Neon, false)
		Builder.neon(tip, amber)
	end
	Builder.sign(model, "SOLARIS", Vector3.new(92, 20, 2), CFrame.new(origin + Vector3.new(-127, 77, 0)) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(66, 37, 71), amber)
	return model
end

function Complexes.buildTropical(parent, origin, config)
	local model = Builder.model(parent, "ComplexE_OasisCrownResort")
	local heightScale = config.Layout.BuildingHeightScale
	local coral = Color3.fromRGB(225, 137, 101)
	local aqua = Color3.fromRGB(36, 205, 196)
	podium(model, origin, 285, 170, Color3.fromRGB(225, 207, 173), aqua)
	for index, data in ipairs({{-92, -18, 68, 205}, {0, -35, 84, 250}, {92, -18, 68, 205}}) do
		Builder.building(model, "OasisTower" .. index, origin + Vector3.new(data[1], 24, data[2]), Vector3.new(data[3], data[4] * heightScale, 62), coral, aqua, math.floor(data[4] / 34))
	end
	Builder.sign(model, "OASIS CROWN", Vector3.new(125, 22, 2), CFrame.new(origin + Vector3.new(144, 135, 0)) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(18, 91, 104), Color3.fromRGB(242, 255, 224))

	local pool = Builder.part(model, "ResortPool", Vector3.new(50, 2, 210), CFrame.new(origin + Vector3.new(160, 2, 0)), Color3.fromRGB(42, 174, 205), Enum.Material.Glass, false)
	pool.Transparency = 0.18
	return model
end

return Complexes

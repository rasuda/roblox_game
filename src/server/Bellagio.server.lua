local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local world = Workspace:WaitForChild("EmpireStateWorld", 20)
if not world then
	warn("[roblox_game] Nao foi possivel criar o Bellagio: mundo nao encontrado.")
	return
end

local previous = world:FindFirstChild("BellagioHotelAndFountains")
if previous then
	previous:Destroy()
end

local resort = Instance.new("Model")
resort.Name = "BellagioHotelAndFountains"
resort.Parent = world

local HOTEL_X = 120
local HOTEL_Z = -38
local WATER_Y = 1
local LAKE_Z = 78
-- Distancia visual minima entre faces decorativas para evitar z-fighting.
local SURFACE_GAP = 0.12

local CREAM = Color3.fromRGB(220, 204, 169)
local CREAM_LIGHT = Color3.fromRGB(239, 225, 192)
local CREAM_DARK = Color3.fromRGB(170, 147, 108)
local ROOF_GREEN = Color3.fromRGB(59, 102, 91)
local ROOF_DARK = Color3.fromRGB(37, 70, 65)
local WINDOW_BLUE = Color3.fromRGB(57, 90, 111)
local WINDOW_GOLD = Color3.fromRGB(255, 211, 120)
local WATER = Color3.fromRGB(38, 137, 174)
local WATER_JET = Color3.fromRGB(205, 241, 255)
local MARBLE = Color3.fromRGB(226, 218, 197)
local PATH = Color3.fromRGB(169, 157, 137)
local TREE_GREEN = Color3.fromRGB(39, 92, 57)

local function makePart(parent, className, name, size, cframe, color, material, collidable)
	local object = Instance.new(className)
	object.Name = name
	object.Anchored = true
	object.CanCollide = collidable == true
	object.CanTouch = collidable == true
	object.Size = size
	object.CFrame = cframe
	object.Color = color
	object.Material = material or Enum.Material.SmoothPlastic
	object.TopSurface = Enum.SurfaceType.Smooth
	object.BottomSurface = Enum.SurfaceType.Smooth
	object.Parent = parent
	return object
end

local function part(parent, name, size, position, color, material, collidable)
	return makePart(parent, "Part", name, size, CFrame.new(position), color, material, collidable)
end

local hotel = Instance.new("Model")
hotel.Name = "BellagioHotel"
hotel.Parent = resort

-- Podio baixo e continuo, inspirado na base palaciana do resort.
part(hotel, "GrandPodium", Vector3.new(142, 14, 28), Vector3.new(HOTEL_X, 7, HOTEL_Z + 3), CREAM, Enum.Material.Limestone, true)
part(hotel, "PodiumCornice", Vector3.new(146, 2, 31), Vector3.new(HOTEL_X, 13.6, HOTEL_Z + 3), CREAM_LIGHT, Enum.Material.Marble, true)

-- Fachada curva composta por sete torres levemente rotacionadas.
for segment = -3, 3 do
	local absSegment = math.abs(segment)
	local width = segment == 0 and 25 or 21
	local height = 101 - absSegment * 7
	local x = HOTEL_X + segment * 19
	local z = HOTEL_Z + absSegment * 3.3
	local angle = math.rad(-segment * 3.5)
	local panelCFrame = CFrame.new(x, 14 - SURFACE_GAP + height / 2, z) * CFrame.Angles(0, angle, 0)

	makePart(hotel, "Part", "HotelTower", Vector3.new(width, height, 18), panelCFrame, CREAM, Enum.Material.Limestone, true)
	makePart(
		hotel,
		"Part",
		"TowerCornice",
		Vector3.new(width + 1.6, 2.1, 20),
		panelCFrame * CFrame.new(0, height / 2 - 1.2, 0),
		CREAM_LIGHT,
		Enum.Material.Marble,
		true
	)

	local rows = math.floor((height - 10) / 6)
	local columns = segment == 0 and 5 or 4
	for row = 1, rows do
		local localY = -height / 2 + 5.2 + (row - 1) * 6
		for column = 1, columns do
			local localX = -width / 2 + column * (width / (columns + 1))
			local lit = (row * 7 + column * 5 + segment * 3) % 9 == 0
			local window = makePart(
				hotel,
				"Part",
				lit and "LitSuiteWindow" or "SuiteWindow",
				Vector3.new(2.6, 3.7, 0.3),
				panelCFrame * CFrame.new(localX, localY, 9 + 0.15 + SURFACE_GAP),
				lit and WINDOW_GOLD or WINDOW_BLUE,
				lit and Enum.Material.Neon or Enum.Material.Glass,
				false
			)
			window.Transparency = lit and 0.05 or 0.18
			window.CastShadow = false
		end
	end

	-- Mansardas verde-cobre dão a silhueta europeia característica.
	local roof = makePart(
		hotel,
		"WedgePart",
		"CopperRoof",
		Vector3.new(width + 1, 7, 18.5),
		panelCFrame * CFrame.new(0, height / 2 + 3.4, 0),
		ROOF_GREEN,
		Enum.Material.Metal,
		false
	)
	roof.Reflectance = 0.05
end

-- Torre central elevada, cupula e placa do hotel.
part(hotel, "CentralCrown", Vector3.new(31, 15, 21), Vector3.new(HOTEL_X, 122.25, HOTEL_Z), CREAM_LIGHT, Enum.Material.Limestone, true)
local crownRoof = makePart(hotel, "WedgePart", "CentralCopperRoof", Vector3.new(33, 10, 23), CFrame.new(HOTEL_X, 134.62, HOTEL_Z), ROOF_GREEN, Enum.Material.Metal, false)
crownRoof.Reflectance = 0.05

local cupola = part(hotel, "Cupola", Vector3.new(13, 12, 13), Vector3.new(HOTEL_X, 145, HOTEL_Z), ROOF_DARK, Enum.Material.Metal, false)
cupola.Shape = Enum.PartType.Ball
part(hotel, "CupolaSpire", Vector3.new(1.2, 14, 1.2), Vector3.new(HOTEL_X, 156, HOTEL_Z), CREAM_LIGHT, Enum.Material.Metal, false)

local signBase = part(hotel, "BellagioSign", Vector3.new(25, 5.5, 0.8), Vector3.new(HOTEL_X, 27, HOTEL_Z + 17.45), CREAM_DARK, Enum.Material.Marble, false)
local signGui = Instance.new("SurfaceGui")
signGui.Name = "SignGui"
signGui.Face = Enum.NormalId.Back
signGui.AlwaysOnTop = true
signGui.Parent = signBase

local signText = Instance.new("TextLabel")
signText.Size = UDim2.fromScale(1, 1)
signText.BackgroundTransparency = 1
signText.Text = "BELLAGIO"
signText.TextColor3 = Color3.fromRGB(255, 237, 179)
signText.TextStrokeColor3 = Color3.fromRGB(69, 51, 31)
signText.TextStrokeTransparency = 0.25
signText.TextScaled = true
signText.Font = Enum.Font.Garamond
signText.Parent = signGui

-- Grande entrada do hotel. O volume tem escala suficiente para acompanhar a
-- fachada, mas continua leve para funcionar bem no celular.
local lobby = Instance.new("Model")
lobby.Name = "BellagioLobby"
lobby.Parent = hotel

part(lobby, "LobbyFloor", Vector3.new(74, 0.65, 34), Vector3.new(HOTEL_X, 0.39, -4), MARBLE, Enum.Material.Marble, true)
part(lobby, "LeftLobbyWall", Vector3.new(1.4, 18, 34), Vector3.new(HOTEL_X - 36.3, 9.35, -4), CREAM_LIGHT, Enum.Material.Marble, true)
part(lobby, "RightLobbyWall", Vector3.new(1.4, 18, 34), Vector3.new(HOTEL_X + 36.3, 9.35, -4), CREAM_LIGHT, Enum.Material.Marble, true)
part(lobby, "ReceptionWall", Vector3.new(74, 18, 1.2), Vector3.new(HOTEL_X, 9.35, -20.4), CREAM, Enum.Material.Marble, true)

-- Fachada envidracada: tres entradas centrais e vitrines laterais.
for _, side in ipairs({-1, 1}) do
	part(lobby, "EntrancePier", Vector3.new(7.5, 18, 1.4), Vector3.new(HOTEL_X + side * 32.25, 9.35, 12.45), CREAM_LIGHT, Enum.Material.Marble, true)
	local sideGlass = part(lobby, "LobbyWindow", Vector3.new(15.5, 12, 0.34), Vector3.new(HOTEL_X + side * 20.6, 6.65, 13.18), WINDOW_BLUE, Enum.Material.Glass, false)
	sideGlass.Transparency = 0.3
end
part(lobby, "EntranceLintel", Vector3.new(57, 5, 1.4), Vector3.new(HOTEL_X, 15.85, 12.45), CREAM_LIGHT, Enum.Material.Marble, true)

for _, xOffset in ipairs({-10.2, -3.4, 3.4, 10.2}) do
	local door = part(lobby, "GlassEntranceDoor", Vector3.new(6.35, 10.4, 0.3), Vector3.new(HOTEL_X + xOffset, 5.85, 13.2), Color3.fromRGB(79, 125, 145), Enum.Material.Glass, false)
	door.Transparency = 0.38
	part(lobby, "DoorHandle", Vector3.new(0.16, 2.5, 0.24), Vector3.new(HOTEL_X + xOffset + (xOffset < 0 and 2 or -2), 5.8, 13.42), Color3.fromRGB(197, 164, 91), Enum.Material.Metal, false)
end
for _, xOffset in ipairs({-13.55, -6.8, 0, 6.8, 13.55}) do
	part(lobby, "DoorFrame", Vector3.new(0.34, 11.2, 0.56), Vector3.new(HOTEL_X + xOffset, 6.25, 13.04), Color3.fromRGB(75, 66, 52), Enum.Material.Metal, true)
end

-- Faixas decorativas elevadas 0,12 stud sobre o piso evitam faces coplanares.
for _, xOffset in ipairs({-23, 0, 23}) do
	part(lobby, "MarbleInlay", Vector3.new(0.8, 0.08, 30), Vector3.new(HOTEL_X + xOffset, 0.755, -3.6), Color3.fromRGB(165, 126, 68), Enum.Material.Marble, false)
end

local lobbyRoof = part(lobby, "LobbyRoof", Vector3.new(76, 1.6, 35.5), Vector3.new(HOTEL_X, 18.75, -4), CREAM_LIGHT, Enum.Material.Marble, true)
lobbyRoof.Reflectance = 0.04
local domeDrum = part(lobby, "DomeDrum", Vector3.new(5, 31, 31), Vector3.new(HOTEL_X, 21.1, -4), CREAM_DARK, Enum.Material.Limestone, false)
domeDrum.Shape = Enum.PartType.Cylinder
domeDrum.CFrame *= CFrame.Angles(0, 0, math.rad(90))
local entranceDome = part(lobby, "EntranceDome", Vector3.new(27, 11, 27), Vector3.new(HOTEL_X, 24, -4), ROOF_GREEN, Enum.Material.Metal, false)
entranceDome.Shape = Enum.PartType.Ball

-- Placa integrada a fachada, sem texto flutuante sobre a tela.
local entranceSign = part(lobby, "EntranceSign", Vector3.new(23, 3.6, 0.5), Vector3.new(HOTEL_X, 14.1, 13.32), CREAM_DARK, Enum.Material.Marble, false)
local entranceSignGui = Instance.new("SurfaceGui")
entranceSignGui.Face = Enum.NormalId.Back
entranceSignGui.AlwaysOnTop = false
entranceSignGui.Parent = entranceSign
local entranceSignText = Instance.new("TextLabel")
entranceSignText.Size = UDim2.fromScale(1, 1)
entranceSignText.BackgroundTransparency = 1
entranceSignText.Text = "BELLAGIO"
entranceSignText.TextColor3 = Color3.fromRGB(255, 237, 179)
entranceSignText.TextStrokeColor3 = Color3.fromRGB(69, 51, 31)
entranceSignText.TextStrokeTransparency = 0.35
entranceSignText.TextScaled = true
entranceSignText.Font = Enum.Font.Garamond
entranceSignText.Parent = entranceSignGui

-- Balcao de check-in; o restante do lobby permanece vazio nesta etapa.
part(lobby, "ReceptionDesk", Vector3.new(45, 3.4, 3), Vector3.new(HOTEL_X, 2.25, -16.9), CREAM_DARK, Enum.Material.Wood, true)
part(lobby, "ReceptionCountertop", Vector3.new(47, 0.38, 3.8), Vector3.new(HOTEL_X, 4.14, -16.9), MARBLE, Enum.Material.Marble, true)
for _, xOffset in ipairs({-16, -8, 0, 8, 16}) do
	local receptionGlass = part(lobby, "ReceptionArchGlass", Vector3.new(6.3, 8.2, 0.25), Vector3.new(HOTEL_X + xOffset, 9, -19.65), WINDOW_BLUE, Enum.Material.Glass, false)
	receptionGlass.Transparency = 0.35
end

for _, xOffset in ipairs({-27, -18, -9, 0, 9, 18, 27}) do
	for _, zOffset in ipairs({-11, 3, 9}) do
		local ceilingLight = part(lobby, "LobbyCeilingLight", Vector3.new(1.35, 0.18, 1.35), Vector3.new(HOTEL_X + xOffset, 17.84, zOffset), WINDOW_GOLD, Enum.Material.Neon, false)
		local pointLight = Instance.new("PointLight")
		pointLight.Color = Color3.fromRGB(255, 220, 156)
		pointLight.Brightness = 0.8
		pointLight.Range = 12
		pointLight.Parent = ceilingLight
	end
end

-- Porte-cochere monumental com cobertura segmentada, moldura e oito colunas.
for _, xOffset in ipairs({-30, 0, 30}) do
	local canopyGlass = part(lobby, "DropOffCanopyGlass", Vector3.new(29.5, 0.42, 18), Vector3.new(HOTEL_X + xOffset, 15.55, 22), Color3.fromRGB(88, 135, 126), Enum.Material.Glass, false)
	canopyGlass.Transparency = 0.3
end
for _, xOffset in ipairs({-45.4, -15, 15, 45.4}) do
	part(lobby, "CanopyRib", Vector3.new(0.55, 0.95, 18.8), Vector3.new(HOTEL_X + xOffset, 15.58, 22), ROOF_DARK, Enum.Material.Metal, true)
end
for _, zOffset in ipairs({12.6, 31.4}) do
	part(lobby, "CanopyCrossBeam", Vector3.new(91.4, 1, 0.65), Vector3.new(HOTEL_X, 15.58, zOffset), ROOF_DARK, Enum.Material.Metal, true)
end
for _, xOffset in ipairs({-42, -14, 14, 42}) do
	for _, zOffset in ipairs({14.5, 29.5}) do
		local support = part(lobby, "CanopyColumn", Vector3.new(14.4, 1.55, 1.55), Vector3.new(HOTEL_X + xOffset, 7.65, zOffset), CREAM_DARK, Enum.Material.Marble, true)
		support.Shape = Enum.PartType.Cylinder
		support.CFrame *= CFrame.Angles(0, 0, math.rad(90))
		part(lobby, "ColumnBase", Vector3.new(2.5, 0.7, 2.5), Vector3.new(HOTEL_X + xOffset, 0.78, zOffset), CREAM_LIGHT, Enum.Material.Marble, true)
	end
end

-- Patio amplo: os carros entram pela faixa traseira, circulam pela ilha e saem
-- pela faixa dianteira, sem cruzar o caminho principal de pedestres.
local drivewayY = 0.21
part(resort, "HotelMotorCourt", Vector3.new(112, 0.32, 32), Vector3.new(HOTEL_X, drivewayY, 29.5), Color3.fromRGB(118, 85, 61), Enum.Material.Cobblestone, true)
part(resort, "ArrivalDrive", Vector3.new(48, 0.32, 10), Vector3.new(200, drivewayY, 20), Color3.fromRGB(104, 75, 56), Enum.Material.Cobblestone, true)
part(resort, "DepartureDrive", Vector3.new(48, 0.32, 10), Vector3.new(200, drivewayY, 39), Color3.fromRGB(104, 75, 56), Enum.Material.Cobblestone, true)
part(resort, "DriveMedian", Vector3.new(47, 0.72, 5.5), Vector3.new(199.5, 0.57, 29.5), TREE_GREEN, Enum.Material.Grass, true)

local arrivalIsland = part(resort, "ArrivalGarden", Vector3.new(0.72, 22, 22), Vector3.new(HOTEL_X, 0.58, 35), TREE_GREEN, Enum.Material.Grass, true)
arrivalIsland.Shape = Enum.PartType.Cylinder
arrivalIsland.CFrame *= CFrame.Angles(0, 0, math.rad(90))
local islandBorder = part(resort, "ArrivalGardenBorder", Vector3.new(0.5, 24, 24), Vector3.new(HOTEL_X, 0.32, 35), MARBLE, Enum.Material.Marble, true)
islandBorder.Shape = Enum.PartType.Cylinder
islandBorder.CFrame *= CFrame.Angles(0, 0, math.rad(90))
arrivalIsland.CFrame = CFrame.new(HOTEL_X, 0.83, 35) * CFrame.Angles(0, 0, math.rad(90))

-- Meio-fio e marcacoes ficam em alturas diferentes para evitar z-fighting.
part(resort, "HotelCurbFront", Vector3.new(114, 0.58, 1.1), Vector3.new(HOTEL_X, 0.51, 46.05), MARBLE, Enum.Material.Concrete, true)
part(resort, "HotelCurbLeft", Vector3.new(1.1, 0.58, 33), Vector3.new(HOTEL_X - 56.55, 0.51, 29.5), MARBLE, Enum.Material.Concrete, true)
for _, zOffset in ipairs({15.15, 24.85, 34.15, 43.85}) do
	part(resort, "LaneEdge", Vector3.new(47, 0.07, 0.18), Vector3.new(199.5, 0.42, zOffset), Color3.fromRGB(241, 229, 195), Enum.Material.SmoothPlastic, false)
end

-- Pequena guarita de valet, sem NPC por enquanto.
part(resort, "ValetBooth", Vector3.new(6, 5.5, 4.5), Vector3.new(161, 2.95, 39), CREAM_LIGHT, Enum.Material.Marble, true)
local valetWindow = part(resort, "ValetWindow", Vector3.new(4.2, 2.5, 0.26), Vector3.new(161, 3.35, 36.61), WINDOW_BLUE, Enum.Material.Glass, false)
valetWindow.Transparency = 0.3
part(resort, "ValetRoof", Vector3.new(6.7, 0.55, 5.2), Vector3.new(161, 5.85, 39), ROOF_GREEN, Enum.Material.Metal, true)

-- Palmeiras e jardins entre o hotel e o lago.
local function addPalm(x, z, scale)
	local trunk = part(hotel, "PalmTrunk", Vector3.new(11 * scale, 1.2 * scale, 1.2 * scale), Vector3.new(x, 5.5 * scale, z), Color3.fromRGB(112, 78, 46), Enum.Material.Wood, false)
	trunk.Shape = Enum.PartType.Cylinder
	trunk.CFrame *= CFrame.Angles(0, 0, math.rad(90))
	for leaf = 0, 5 do
		local angle = math.rad(leaf * 60)
		local leafPart = part(
			hotel,
			"PalmLeaf",
			Vector3.new(0.7 * scale, 0.35 * scale, 7 * scale),
			Vector3.new(x + math.sin(angle) * 2.4 * scale, 11.4 * scale + leaf * SURFACE_GAP, z + math.cos(angle) * 2.4 * scale),
			TREE_GREEN,
			Enum.Material.Grass,
			false
		)
		leafPart.CFrame *= CFrame.Angles(math.rad(-12), angle, 0)
	end
end

for _, xOffset in ipairs({-68, -56, -44, 44, 56, 68}) do
	addPalm(HOTEL_X + xOffset, 6 + (math.abs(xOffset) - 44) * 0.35, 0.9)
end

-- Lago frontal com agua real e rasa. O piso fica logo abaixo da superficie,
-- permitindo atravessar a fonte sem transformar a area em uma piscina funda.
-- O piso geral termina em Y=0; o fundo do lago fica ligeiramente acima dele.
part(resort, "LakeFoundation", Vector3.new(139, 1.5, 65), Vector3.new(HOTEL_X, -0.75 + SURFACE_GAP, LAKE_Z), MARBLE, Enum.Material.Concrete, true)

local terrain = Workspace.Terrain
terrain.WaterColor = WATER
terrain.WaterTransparency = 0.22
terrain.WaterReflectance = 0.12
terrain.WaterWaveSize = 0.08
terrain.WaterWaveSpeed = 7

local waterCFrame = CFrame.new(HOTEL_X, -1, LAKE_Z)
local waterSize = Vector3.new(132, 4, 60)
terrain:FillBlock(waterCFrame, waterSize, Enum.Material.Air)
terrain:FillBlock(waterCFrame, waterSize, Enum.Material.Water)
part(resort, "LakesidePromenade", Vector3.new(146, 1.2, 13), Vector3.new(HOTEL_X, 0.65, 114.5), PATH, Enum.Material.Cobblestone, true)
part(resort, "LeftLakeWalk", Vector3.new(8, 1.2, 69), Vector3.new(HOTEL_X - 72, 0.65, LAKE_Z), PATH, Enum.Material.Cobblestone, true)
part(resort, "RightLakeWalk", Vector3.new(8, 1.2, 69), Vector3.new(HOTEL_X + 72, 0.65, LAKE_Z), PATH, Enum.Material.Cobblestone, true)

-- Fontes animadas: linhas e arcos com quatro momentos coreografados.
local fountains = Instance.new("Model")
fountains.Name = "DancingFountains"
fountains.Parent = resort

local jets = {}

local function addJet(position, phase, group, maxHeight, width)
	local nozzle = part(fountains, "FountainNozzle", Vector3.new(0.28, 1.15, 1.15), Vector3.new(position.X, WATER_Y + 0.28, position.Z), Color3.fromRGB(54, 68, 74), Enum.Material.Metal, false)
	nozzle.Shape = Enum.PartType.Cylinder
	nozzle.CFrame *= CFrame.Angles(0, 0, math.rad(90))

	local stream = part(fountains, "WaterJet", Vector3.new(1, width, width), position + Vector3.new(0, 0.5, 0), WATER_JET, Enum.Material.Neon, false)
	stream.Shape = Enum.PartType.Cylinder
	stream.Transparency = 0.12
	stream.CastShadow = false

	local light
	if #jets % 4 == 0 then
		light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(155, 220, 255)
		light.Brightness = 1.2
		light.Range = 16
		light.Parent = stream
	end

	table.insert(jets, {
		stream = stream,
		base = position,
		phase = phase,
		group = group,
		maxHeight = maxHeight,
		width = width,
		currentHeight = 1,
		light = light,
	})
end

-- Fileira traseira em arco.
for index = 0, 16 do
	local normalized = index / 16
	local angle = math.rad(200 - normalized * 220)
	local position = Vector3.new(HOTEL_X + math.cos(angle) * 50, WATER_Y, 75 + math.sin(angle) * 20)
	addJet(position, index * 0.42, 1, 23 + (index % 3) * 5, 0.75)
end

-- Fileira frontal e eixo central para o grande final.
for index = -6, 6 do
	addJet(Vector3.new(HOTEL_X + index * 8.2, WATER_Y, 96), index * 0.55, 2, 30 + (6 - math.abs(index)) * 2.5, 0.9)
end

for index = -2, 2 do
	addJet(Vector3.new(HOTEL_X + index * 11, WATER_Y, 73), index * 0.7, 3, 48 - math.abs(index) * 5, 1.15)
end

local elapsed = 0
local updateAccumulator = 0

RunService.Heartbeat:Connect(function(deltaTime)
	elapsed += deltaTime
	updateAccumulator += deltaTime
	if updateAccumulator < 1 / 30 then
		return
	end
	local step = updateAccumulator
	updateAccumulator = 0
	local cycle = elapsed % 24

	for index, jet in ipairs(jets) do
		local normalizedHeight
		if cycle < 7 then
			-- Onda atravessando o lago.
			normalizedHeight = 0.12 + 0.72 * ((math.sin(elapsed * 2.15 - jet.phase) + 1) / 2)
		elseif cycle < 13 then
			-- Alternancia entre as duas fileiras.
			local active = (math.floor((cycle - 7) * 1.6) + jet.group) % 2 == 0
			normalizedHeight = active and (0.62 + 0.25 * math.sin(elapsed * 3 + jet.phase)) or 0.08
		elseif cycle < 19 then
			-- Espiral e pulsacao do centro para as pontas.
			normalizedHeight = 0.15 + 0.8 * math.max(0, math.sin(elapsed * 2.7 + index * 0.48))
		else
			-- Crescendo final, com os cinco jatos centrais dominando.
			local rise = math.clamp((cycle - 19) / 2.2, 0, 1)
			local fall = math.clamp((24 - cycle) / 1.1, 0, 1)
			normalizedHeight = math.min(rise, fall)
			if jet.group == 3 then
				normalizedHeight = math.min(1, normalizedHeight * 1.15)
			end
		end

		local targetHeight = 0.7 + jet.maxHeight * math.clamp(normalizedHeight, 0, 1)
		jet.currentHeight += (targetHeight - jet.currentHeight) * math.clamp(step * 8, 0, 1)
		jet.stream.Size = Vector3.new(jet.currentHeight, jet.width, jet.width)
		jet.stream.CFrame = CFrame.new(jet.base + Vector3.new(0, jet.currentHeight / 2, 0)) * CFrame.Angles(0, 0, math.rad(90))
		jet.stream.Transparency = 0.1 + (1 - normalizedHeight) * 0.22
		if jet.light then
			jet.light.Brightness = 0.5 + normalizedHeight * 1.8
		end
	end
end)

print("[roblox_game] Bellagio e espetaculo das fontes carregados com sucesso.")

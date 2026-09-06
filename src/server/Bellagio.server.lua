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

-- Entrada acessivel: lobby oco, portas atravessaveis e recepcao ainda vazia.
local lobby = Instance.new("Model")
lobby.Name = "BellagioLobby"
lobby.Parent = hotel

part(lobby, "LobbyFloor", Vector3.new(45, 0.55, 21), Vector3.new(HOTEL_X, 0.34, -10), MARBLE, Enum.Material.Marble, true)
part(lobby, "LeftLobbyWall", Vector3.new(1.2, 14, 21), Vector3.new(HOTEL_X - 21.9, 7.25, -10), CREAM_LIGHT, Enum.Material.Marble, true)
part(lobby, "RightLobbyWall", Vector3.new(1.2, 14, 21), Vector3.new(HOTEL_X + 21.9, 7.25, -10), CREAM_LIGHT, Enum.Material.Marble, true)
part(lobby, "ReceptionWall", Vector3.new(45, 14, 1.1), Vector3.new(HOTEL_X, 7.25, -20.15), CREAM, Enum.Material.Marble, true)

-- Fachada frontal dividida para deixar um vao central largo.
for _, side in ipairs({-1, 1}) do
	part(lobby, "EntranceSideWall", Vector3.new(10, 14, 1), Vector3.new(HOTEL_X + side * 17.3, 7.25, 0.15), CREAM_LIGHT, Enum.Material.Marble, true)
	local sideGlass = part(lobby, "EntranceSideGlass", Vector3.new(6.5, 9, 0.3), Vector3.new(HOTEL_X + side * 11.9, 5.2, 0.72), WINDOW_BLUE, Enum.Material.Glass, false)
	sideGlass.Transparency = 0.28
end
part(lobby, "EntranceLintel", Vector3.new(25, 4.2, 1), Vector3.new(HOTEL_X, 12.15, 0.15), CREAM_LIGHT, Enum.Material.Marble, true)

-- Quatro folhas de vidro sem colisao permitem entrar caminhando.
for _, xOffset in ipairs({-8.7, -2.9, 2.9, 8.7}) do
	local door = part(lobby, "GlassEntranceDoor", Vector3.new(5.35, 8.2, 0.28), Vector3.new(HOTEL_X + xOffset, 4.65, 0.78), Color3.fromRGB(77, 119, 139), Enum.Material.Glass, false)
	door.Transparency = 0.38
	part(lobby, "DoorHandle", Vector3.new(0.14, 2.1, 0.22), Vector3.new(HOTEL_X + xOffset + (xOffset < 0 and 1.7 or -1.7), 4.6, 0.98), Color3.fromRGB(197, 164, 91), Enum.Material.Metal, false)
end
for _, xOffset in ipairs({-11.6, -5.8, 0, 5.8, 11.6}) do
	part(lobby, "DoorFrame", Vector3.new(0.28, 9, 0.5), Vector3.new(HOTEL_X + xOffset, 5.05, 0.62), Color3.fromRGB(75, 66, 52), Enum.Material.Metal, true)
end

-- Piso central com faixas embutidas acima do marmore, sem faces coplanares.
for _, xOffset in ipairs({-13, 0, 13}) do
	part(lobby, "MarbleInlay", Vector3.new(0.65, 0.07, 18), Vector3.new(HOTEL_X + xOffset, 0.655, -9.6), Color3.fromRGB(165, 126, 68), Enum.Material.Marble, false)
end

local lobbyRoof = part(lobby, "LobbyRoof", Vector3.new(46, 1.4, 22), Vector3.new(HOTEL_X, 14.45, -10), CREAM_LIGHT, Enum.Material.Marble, true)
lobbyRoof.Reflectance = 0.04
local entranceDome = part(lobby, "EntranceDome", Vector3.new(23, 11, 23), Vector3.new(HOTEL_X, 20, -10), ROOF_GREEN, Enum.Material.Metal, false)
entranceDome.Shape = Enum.PartType.Ball

-- Balcao de check-in; o restante do lobby permanece vazio nesta etapa.
part(lobby, "ReceptionDesk", Vector3.new(27, 3.2, 2.5), Vector3.new(HOTEL_X, 2.15, -17.4), CREAM_DARK, Enum.Material.Wood, true)
part(lobby, "ReceptionCountertop", Vector3.new(29, 0.35, 3.2), Vector3.new(HOTEL_X, 3.86, -17.4), MARBLE, Enum.Material.Marble, true)
for _, xOffset in ipairs({-9, 0, 9}) do
	local receptionGlass = part(lobby, "ReceptionArchGlass", Vector3.new(6.5, 6.5, 0.24), Vector3.new(HOTEL_X + xOffset, 8.1, -19.47), WINDOW_BLUE, Enum.Material.Glass, false)
	receptionGlass.Transparency = 0.35
end

for _, xOffset in ipairs({-14, -7, 0, 7, 14}) do
	for _, zOffset in ipairs({-5.5, -13.5}) do
		local ceilingLight = part(lobby, "LobbyCeilingLight", Vector3.new(1.3, 0.16, 1.3), Vector3.new(HOTEL_X + xOffset, 13.64, zOffset), WINDOW_GOLD, Enum.Material.Neon, false)
		local pointLight = Instance.new("PointLight")
		pointLight.Color = Color3.fromRGB(255, 220, 156)
		pointLight.Brightness = 1.1
		pointLight.Range = 14
		pointLight.Parent = ceilingLight
	end
end

-- Porte-cochere de vidro e metal sobre a area de desembarque.
local canopyGlass = part(lobby, "DropOffCanopyGlass", Vector3.new(52, 0.35, 12), Vector3.new(HOTEL_X, 11.05, 7), Color3.fromRGB(88, 135, 126), Enum.Material.Glass, false)
canopyGlass.Transparency = 0.32
for _, xOffset in ipairs({-26.2, 26.2}) do
	part(lobby, "CanopySideBeam", Vector3.new(0.5, 0.8, 12.5), Vector3.new(HOTEL_X + xOffset, 11.05, 7), ROOF_DARK, Enum.Material.Metal, true)
end
for _, zOffset in ipairs({1, 13}) do
	part(lobby, "CanopyCrossBeam", Vector3.new(53, 0.8, 0.5), Vector3.new(HOTEL_X, 11.05, zOffset), ROOF_DARK, Enum.Material.Metal, true)
end
for _, xOffset in ipairs({-24, 24}) do
	for _, zOffset in ipairs({2.2, 11.8}) do
		local support = part(lobby, "CanopyColumn", Vector3.new(10.5, 1.15, 1.15), Vector3.new(HOTEL_X + xOffset, 5.6, zOffset), CREAM_DARK, Enum.Material.Marble, true)
		support.Shape = Enum.PartType.Cylinder
		support.CFrame *= CFrame.Angles(0, 0, math.rad(90))
	end
end

-- Patio de chegada, com pistas separadas de entrada e saida pela lateral.
local drivewayY = 0.19
part(resort, "HotelMotorCourt", Vector3.new(84, 0.28, 23), Vector3.new(HOTEL_X, drivewayY, 12), Color3.fromRGB(118, 85, 61), Enum.Material.Cobblestone, true)
part(resort, "ArrivalDrive", Vector3.new(48, 0.28, 9), Vector3.new(186, drivewayY, 7), Color3.fromRGB(104, 75, 56), Enum.Material.Cobblestone, true)
part(resort, "DepartureDrive", Vector3.new(48, 0.28, 9), Vector3.new(186, drivewayY, 19), Color3.fromRGB(104, 75, 56), Enum.Material.Cobblestone, true)
part(resort, "DriveMedian", Vector3.new(45, 0.65, 2.4), Vector3.new(185.5, 0.52, 13), TREE_GREEN, Enum.Material.Grass, true)

-- Meio-fio e marcacoes ficam em alturas diferentes para evitar z-fighting.
part(resort, "HotelCurbFront", Vector3.new(86, 0.55, 1), Vector3.new(HOTEL_X, 0.48, 24 + SURFACE_GAP), MARBLE, Enum.Material.Concrete, true)
part(resort, "HotelCurbLeft", Vector3.new(1, 0.55, 24), Vector3.new(HOTEL_X - 42.5 - SURFACE_GAP, 0.48, 12), MARBLE, Enum.Material.Concrete, true)
for _, zOffset in ipairs({4.1, 9.9, 16.1, 21.9}) do
	part(resort, "LaneEdge", Vector3.new(45, 0.06, 0.16), Vector3.new(185.5, 0.37, zOffset), Color3.fromRGB(241, 229, 195), Enum.Material.SmoothPlastic, false)
end

-- Pequena guarita de valet, sem NPC por enquanto.
part(resort, "ValetBooth", Vector3.new(5, 5, 4), Vector3.new(153.5, 2.7, 20), CREAM_LIGHT, Enum.Material.Marble, true)
local valetWindow = part(resort, "ValetWindow", Vector3.new(3.4, 2.3, 0.24), Vector3.new(153.5, 3.15, 17.88), WINDOW_BLUE, Enum.Material.Glass, false)
valetWindow.Transparency = 0.3
part(resort, "ValetRoof", Vector3.new(5.6, 0.5, 4.6), Vector3.new(153.5, 5.42, 20), ROOF_GREEN, Enum.Material.Metal, true)

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

for _, xOffset in ipairs({-57, -45, -32, 32, 45, 57}) do
	addPalm(HOTEL_X + xOffset, HOTEL_Z + 28 + math.abs(xOffset) * 0.06, 0.85)
end

-- Lago frontal com agua real e rasa. O piso fica logo abaixo da superficie,
-- permitindo atravessar a fonte sem transformar a area em uma piscina funda.
-- O piso geral termina em Y=0; o fundo do lago fica ligeiramente acima dele.
part(resort, "LakeFoundation", Vector3.new(139, 1.5, 78), Vector3.new(HOTEL_X, -0.75 + SURFACE_GAP, 63), MARBLE, Enum.Material.Concrete, true)

local terrain = Workspace.Terrain
terrain.WaterColor = WATER
terrain.WaterTransparency = 0.22
terrain.WaterReflectance = 0.12
terrain.WaterWaveSize = 0.08
terrain.WaterWaveSpeed = 7

local waterCFrame = CFrame.new(HOTEL_X, -1, 63)
local waterSize = Vector3.new(132, 4, 72)
terrain:FillBlock(waterCFrame, waterSize, Enum.Material.Air)
terrain:FillBlock(waterCFrame, waterSize, Enum.Material.Water)
part(resort, "LakesidePromenade", Vector3.new(146, 1.2, 13), Vector3.new(HOTEL_X, 0.65, 108), PATH, Enum.Material.Cobblestone, true)
part(resort, "LeftLakeWalk", Vector3.new(8, 1.2, 86), Vector3.new(HOTEL_X - 72, 0.65, 65), PATH, Enum.Material.Cobblestone, true)
part(resort, "RightLakeWalk", Vector3.new(8, 1.2, 86), Vector3.new(HOTEL_X + 72, 0.65, 65), PATH, Enum.Material.Cobblestone, true)

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
	local position = Vector3.new(HOTEL_X + math.cos(angle) * 50, WATER_Y, 59 + math.sin(angle) * 24)
	addJet(position, index * 0.42, 1, 23 + (index % 3) * 5, 0.75)
end

-- Fileira frontal e eixo central para o grande final.
for index = -6, 6 do
	addJet(Vector3.new(HOTEL_X + index * 8.2, WATER_Y, 81), index * 0.55, 2, 30 + (6 - math.abs(index)) * 2.5, 0.9)
end

for index = -2, 2 do
	addJet(Vector3.new(HOTEL_X + index * 11, WATER_Y, 57), index * 0.7, 3, 48 - math.abs(index) * 5, 1.15)
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

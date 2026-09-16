-- Original 2D football-card exhibition. It uses no external images or copied
-- card artwork, keeping the lineup lightweight and reliable on mobile.
local Workspace = game:GetService("Workspace")

local world = Workspace:WaitForChild("EmpireStateWorld", 30)
if not world or not world:WaitForChild("Ground", 30) then
	warn("[roblox_game] Football lineup: ground unavailable")
	return
end

local previous = world:FindFirstChild("FootballLineup")
if previous then previous:Destroy() end

local exhibition = Instance.new("Model")
exhibition.Name = "FootballLineup"
exhibition.Parent = world

local CENTER = Vector3.new(-300, 0, 150)
local FIELD_WIDTH = 120
local FIELD_LENGTH = 190
local FIELD_TOP = 0.24
local GRASS_DARK = Color3.fromRGB(38, 118, 57)
local GRASS_LIGHT = Color3.fromRGB(49, 139, 67)
local WHITE = Color3.fromRGB(245, 245, 235)
local GOLD = Color3.fromRGB(233, 184, 61)
local NAVY = Color3.fromRGB(18, 28, 54)

local function part(name, size, frame, color, material, collide)
	local object = Instance.new("Part")
	object.Name = name
	object.Size = size
	object.CFrame = frame
	object.Color = color
	object.Material = material
	object.Anchored = true
	object.CanCollide = collide == true
	object.CanTouch = collide == true
	object.TopSurface = Enum.SurfaceType.Smooth
	object.BottomSurface = Enum.SurfaceType.Smooth
	object.Parent = exhibition
	return object
end

part(
	"PitchBase",
	Vector3.new(FIELD_WIDTH + 8, 0.3, FIELD_LENGTH + 8),
	CFrame.new(CENTER.X, 0.02, CENTER.Z),
	Color3.fromRGB(30, 82, 43),
	Enum.Material.Grass,
	true
)

-- Alternating grass strips give the pitch depth without textures or assets.
local stripCount = 10
for index = 1, stripCount do
	local stripLength = FIELD_LENGTH / stripCount
	local z = CENTER.Z - FIELD_LENGTH / 2 + stripLength * (index - 0.5)
	part(
		"GrassStrip",
		Vector3.new(FIELD_WIDTH, 0.08, stripLength),
		CFrame.new(CENTER.X, FIELD_TOP - 0.04, z),
		index % 2 == 0 and GRASS_LIGHT or GRASS_DARK,
		Enum.Material.Grass,
		true
	)
end

local function line(name, size, x, z)
	local marking = part(
		name,
		size,
		CFrame.new(CENTER.X + x, FIELD_TOP + 0.035, CENTER.Z + z),
		WHITE,
		Enum.Material.SmoothPlastic,
		false
	)
	marking.CastShadow = false
end

line("TouchlineLeft", Vector3.new(0.45, 0.07, FIELD_LENGTH), -FIELD_WIDTH / 2, 0)
line("TouchlineRight", Vector3.new(0.45, 0.07, FIELD_LENGTH), FIELD_WIDTH / 2, 0)
line("GoalLineNorth", Vector3.new(FIELD_WIDTH, 0.07, 0.45), 0, -FIELD_LENGTH / 2)
line("GoalLineSouth", Vector3.new(FIELD_WIDTH, 0.07, 0.45), 0, FIELD_LENGTH / 2)
line("HalfwayLine", Vector3.new(FIELD_WIDTH, 0.07, 0.45), 0, 0)

local function penaltyBox(prefix, direction)
	local boxDepth = 28
	local boxWidth = 64
	local goalZ = direction * FIELD_LENGTH / 2
	local innerZ = goalZ - direction * boxDepth
	line(prefix .. "BoxEnd", Vector3.new(boxWidth, 0.07, 0.42), 0, innerZ)
	line(prefix .. "BoxLeft", Vector3.new(0.42, 0.07, boxDepth), -boxWidth / 2, goalZ - direction * boxDepth / 2)
	line(prefix .. "BoxRight", Vector3.new(0.42, 0.07, boxDepth), boxWidth / 2, goalZ - direction * boxDepth / 2)
	line(prefix .. "PenaltySpot", Vector3.new(1.2, 0.08, 1.2), 0, goalZ - direction * 20)
end

penaltyBox("North", -1)
penaltyBox("South", 1)

local circle = part(
	"CentreCircle",
	Vector3.new(0.08, 29, 29),
	CFrame.new(CENTER.X, FIELD_TOP + 0.055, CENTER.Z) * CFrame.Angles(0, 0, math.rad(90)),
	WHITE,
	Enum.Material.SmoothPlastic,
	false
)
circle.Shape = Enum.PartType.Cylinder
local circleFill = part(
	"CentreCircleFill",
	Vector3.new(0.1, 27.5, 27.5),
	CFrame.new(CENTER.X, FIELD_TOP + 0.075, CENTER.Z) * CFrame.Angles(0, 0, math.rad(90)),
	GRASS_LIGHT,
	Enum.Material.Grass,
	false
)
circleFill.Shape = Enum.PartType.Cylinder
line("CentreSpot", Vector3.new(1.2, 0.08, 1.2), 0, 0)

local function goal(name, direction)
	local z = CENTER.Z + direction * (FIELD_LENGTH / 2 + 1.5)
	for _, x in ipairs({-14, 14}) do
		part(name .. "Post", Vector3.new(0.7, 7, 0.7), CFrame.new(CENTER.X + x, 3.5, z), WHITE, Enum.Material.Metal, true)
	end
	part(name .. "Crossbar", Vector3.new(28.7, 0.7, 0.7), CFrame.new(CENTER.X, 7, z), WHITE, Enum.Material.Metal, true)
end

goal("NorthGoal", -1)
goal("SouthGoal", 1)

local players = {
	{name = "ALISSON", overall = 89, position = "GK", number = 1, country = "BRASIL", initials = "AB", x = 0, z = 72, accent = Color3.fromRGB(70, 172, 226)},
	{name = "MARCELO", overall = 91, position = "LB", number = 6, country = "BRASIL", initials = "M", x = -43, z = 42, accent = Color3.fromRGB(48, 164, 95)},
	{name = "VAN DIJK", overall = 91, position = "CB", number = 4, country = "HOLANDA", initials = "VD", x = -15, z = 42, accent = Color3.fromRGB(242, 132, 48)},
	{name = "RÚBEN DIAS", overall = 90, position = "CB", number = 3, country = "PORTUGAL", initials = "RD", x = 15, z = 42, accent = Color3.fromRGB(194, 53, 50)},
	{name = "HAKIMI", overall = 89, position = "RB", number = 2, country = "MARROCOS", initials = "AH", x = 43, z = 42, accent = Color3.fromRGB(184, 40, 46)},
	{name = "MODRIĆ", overall = 92, position = "CM", number = 10, country = "CROÁCIA", initials = "LM", x = -32, z = 6, accent = Color3.fromRGB(221, 68, 70)},
	{name = "NEYMAR JR", overall = 93, position = "CAM", number = 10, country = "BRASIL", initials = "NJ", x = 0, z = 1, accent = Color3.fromRGB(54, 177, 91)},
	{name = "DE BRUYNE", overall = 92, position = "CM", number = 17, country = "BÉLGICA", initials = "KD", x = 32, z = 6, accent = Color3.fromRGB(236, 190, 49)},
	{name = "VINI JR.", overall = 94, position = "LW", number = 7, country = "BRASIL", initials = "VJ", x = -40, z = -42, accent = Color3.fromRGB(46, 177, 91)},
	{name = "CRISTIANO RONALDO", overall = 95, position = "ST", number = 7, country = "PORTUGAL", initials = "CR", x = 0, z = -48, accent = Color3.fromRGB(202, 47, 52)},
	{name = "MESSI", overall = 95, position = "RW", number = 10, country = "ARGENTINA", initials = "LM", x = 40, z = -42, accent = Color3.fromRGB(81, 177, 221)},
}

local function addText(parent, text, position, size, font, color, scaled)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = position
	label.Size = size
	label.Text = text
	label.TextColor3 = color
	label.Font = font
	label.TextScaled = scaled ~= false
	label.TextWrapped = true
	label.Parent = parent
	return label
end

local function drawCard(surface, player)
	local root = Instance.new("Frame")
	root.Size = UDim2.fromScale(1, 1)
	root.BackgroundColor3 = NAVY
	root.BorderSizePixel = 0
	root.Parent = surface

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, player.accent),
		ColorSequenceKeypoint.new(0.42, NAVY),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 12, 30)),
	})
	gradient.Rotation = 35
	gradient.Parent = root

	local border = Instance.new("UIStroke")
	border.Thickness = 14
	border.Color = GOLD
	border.Parent = root

	addText(root, tostring(player.overall), UDim2.fromScale(0.05, 0.04), UDim2.fromScale(0.24, 0.13), Enum.Font.GothamBlack, WHITE)
	addText(root, player.position, UDim2.fromScale(0.06, 0.16), UDim2.fromScale(0.22, 0.07), Enum.Font.GothamBold, GOLD)
	addText(root, player.country, UDim2.fromScale(0.03, 0.25), UDim2.fromScale(0.30, 0.06), Enum.Font.GothamBold, WHITE)

	local portrait = Instance.new("Frame")
	portrait.Position = UDim2.fromScale(0.30, 0.10)
	portrait.Size = UDim2.fromScale(0.64, 0.54)
	portrait.BackgroundColor3 = Color3.fromRGB(225, 174, 132)
	portrait.BorderSizePixel = 0
	portrait.Parent = root
	local portraitCorner = Instance.new("UICorner")
	portraitCorner.CornerRadius = UDim.new(0.5, 0)
	portraitCorner.Parent = portrait
	addText(portrait, player.initials, UDim2.fromScale(0.12, 0.18), UDim2.fromScale(0.76, 0.52), Enum.Font.GothamBlack, NAVY)

	local jersey = Instance.new("Frame")
	jersey.Position = UDim2.fromScale(0.22, 0.68)
	jersey.Size = UDim2.fromScale(0.56, 0.25)
	jersey.BackgroundColor3 = player.accent
	jersey.BorderSizePixel = 0
	jersey.Parent = portrait
	local jerseyCorner = Instance.new("UICorner")
	jerseyCorner.CornerRadius = UDim.new(0.25, 0)
	jerseyCorner.Parent = jersey
	addText(jersey, tostring(player.number), UDim2.fromScale(0.2, 0.05), UDim2.fromScale(0.6, 0.9), Enum.Font.GothamBlack, WHITE)

	addText(root, player.name, UDim2.fromScale(0.04, 0.67), UDim2.fromScale(0.92, 0.16), Enum.Font.GothamBlack, WHITE)
	addText(root, player.country .. "  •  #" .. player.number, UDim2.fromScale(0.08, 0.84), UDim2.fromScale(0.84, 0.08), Enum.Font.GothamMedium, GOLD)
end

local cards = Instance.new("Model")
cards.Name = "StartingElevenCards"
cards.Parent = exhibition

for _, player in ipairs(players) do
	local position = CENTER + Vector3.new(player.x, 9.4, player.z)
	local card = part(
		player.name,
		Vector3.new(12, 18, 0.7),
		CFrame.new(position),
		NAVY,
		Enum.Material.SmoothPlastic,
		true
	)
	card.Parent = cards

	for _, face in ipairs({Enum.NormalId.Front, Enum.NormalId.Back}) do
		local surface = Instance.new("SurfaceGui")
		surface.Name = "CardFace"
		surface.Face = face
		surface.CanvasSize = Vector2.new(600, 900)
		surface.LightInfluence = 0.1
		surface.Brightness = 1.3
		surface.Parent = card
		drawCard(surface, player)
	end

	part(
		"CardStand",
		Vector3.new(14, 0.7, 4),
		CFrame.new(position.X, 0.6, position.Z),
		GOLD,
		Enum.Material.Metal,
		true
	).Parent = cards
end

print("[roblox_game] Football field and 11-player card lineup loaded.")

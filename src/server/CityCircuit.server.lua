-- Closed elevated circuit surrounding the urban district.
local Workspace = game:GetService("Workspace")

local world = Workspace:WaitForChild("EmpireStateWorld", 30)
if not world or not world:WaitForChild("Ground", 30) then
	warn("[roblox_game] City circuit: ground unavailable")
	return
end

local old = world:FindFirstChild("CityCircuit")
if old then old:Destroy() end

local circuit = Instance.new("Model")
circuit.Name = "CityCircuit"
circuit.Parent = world

local ROAD = Color3.fromRGB(48, 51, 53)
local BARRIER = Color3.fromRGB(196, 42, 35)
local BARRIER_ALT = Color3.fromRGB(235, 235, 230)
local LINE = Color3.fromRGB(245, 205, 55)
local STEEL = Color3.fromRGB(106, 112, 118)
local ROAD_WIDTH = 42
local ROAD_THICKNESS = 1.2
local SAMPLES_PER_SECTION = 12

local function part(name, size, frame, color, material, collide)
	local object = Instance.new("Part")
	object.Name = name
	object.Size = size
	object.CFrame = frame
	object.Color = color
	object.Material = material
	object.Anchored = true
	object.CanCollide = collide ~= false
	object.TopSurface = Enum.SurfaceType.Smooth
	object.BottomSurface = Enum.SurfaceType.Smooth
	object.Parent = circuit
	return object
end

-- Road centre height is -0.5 at ground level, putting its upper surface at
-- y=0.1 and eliminating a wheel-catching step where the circuit begins rising.
local points = {
	Vector3.new(0, -0.5, -440),
	Vector3.new(250, -0.5, -440),
	Vector3.new(405, 5, -395),
	Vector3.new(475, 17, -245),
	Vector3.new(480, 29, 0),
	Vector3.new(470, 17, 245),
	Vector3.new(400, 5, 385),
	Vector3.new(210, -0.5, 440),
	Vector3.new(0, -0.5, 440),
	Vector3.new(-235, 4, 438),
	Vector3.new(-410, 17, 380),
	Vector3.new(-478, 30, 220),
	Vector3.new(-480, 35, 0),
	Vector3.new(-470, 21, -240),
	Vector3.new(-395, 6, -390),
	Vector3.new(-220, -0.5, -440),
}

local function catmull(p0, p1, p2, p3, t)
	local t2 = t * t
	local t3 = t2 * t
	return 0.5 * ((2 * p1)
		+ (-p0 + p2) * t
		+ (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2
		+ (-p0 + 3 * p1 - 3 * p2 + p3) * t3)
end

local samples = {}
local count = #points
for section = 1, count do
	local p0 = points[(section - 2) % count + 1]
	local p1 = points[section]
	local p2 = points[section % count + 1]
	local p3 = points[(section + 1) % count + 1]
	for step = 0, SAMPLES_PER_SECTION - 1 do
		table.insert(samples, catmull(p0, p1, p2, p3, step / SAMPLES_PER_SECTION))
	end
end

local sampleCount = #samples
for index = 1, sampleCount do
	local previous = samples[(index - 2) % sampleCount + 1]
	local current = samples[index]
	local nextPoint = samples[index % sampleCount + 1]
	local after = samples[(index + 1) % sampleCount + 1]
	local segment = nextPoint - current
	local length = segment.Magnitude
	local midpoint = (current + nextPoint) / 2
	local tangentBefore = (nextPoint - previous).Unit
	local tangentAfter = (after - current).Unit
	local turn = tangentBefore:Cross(tangentAfter).Y
	local bank = math.clamp(turn * 4.8, -0.22, 0.22)
	local frame = CFrame.lookAt(midpoint, nextPoint, Vector3.yAxis) * CFrame.Angles(0, 0, bank)

	part(
		"Road",
		Vector3.new(ROAD_WIDTH, ROAD_THICKNESS, length * 1.08),
		frame,
		ROAD,
		Enum.Material.Asphalt,
		true
	)

	-- Alternating safety barriers emphasize the racing circuit at a distance.
	local barrierColor = index % 2 == 0 and BARRIER or BARRIER_ALT
	local isEntry = midpoint.Z < -430 and math.abs(midpoint.X) < 170
	if not isEntry then
		for _, side in ipairs({-1, 1}) do
			part(
				"SafetyBarrier",
				Vector3.new(1.05, 3.1, length * 1.1),
				frame * CFrame.new(side * (ROAD_WIDTH / 2 - 0.5), 1.8, 0),
				barrierColor,
				Enum.Material.Metal,
				true
			)
		end
	end

	if index % 2 == 0 then
		local stripe = part(
			"CentreLine",
			Vector3.new(0.55, 0.08, math.min(7, length * 0.55)),
			frame * CFrame.new(0, ROAD_THICKNESS / 2 + 0.07, 0),
			LINE,
			Enum.Material.Neon,
			false
		)
		stripe.CastShadow = false
	end

	-- Supports appear only under raised sections, turning both high sides into bridges.
	if midpoint.Y > 4 and index % 5 == 0 then
		local supportHeight = midpoint.Y + ROAD_THICKNESS / 2
		local lateral = frame.RightVector
		for _, side in ipairs({-1, 1}) do
			local supportPosition = midpoint + lateral * side * (ROAD_WIDTH * 0.3)
			part(
				"BridgeSupport",
				Vector3.new(2.2, supportHeight, 2.2),
				CFrame.new(supportPosition.X, supportHeight / 2, supportPosition.Z),
				STEEL,
				Enum.Material.Metal,
				true
			)
		end
	end
end

print(string.format("[roblox_game] Closed city circuit loaded with %d road segments.", sampleCount))

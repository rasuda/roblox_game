-- Deterministic stunt park distributed across the flat map. The fixed seed
-- gives an organic layout while keeping every server identical.
local Workspace = game:GetService("Workspace")

local world = Workspace:WaitForChild("EmpireStateWorld", 30)
if not world or not world:WaitForChild("Ground", 30) then
	warn("[roblox_game] Ramp park: ground unavailable")
	return
end

local old = world:FindFirstChild("RampPark")
if old then old:Destroy() end

local park = Instance.new("Model")
park.Name = "RampPark"
park.Parent = world

local ASPHALT = Color3.fromRGB(62, 66, 68)
local EDGE = Color3.fromRGB(238, 170, 42)
local STEEL = Color3.fromRGB(126, 132, 137)
local random = Random.new(20260916)

local function part(name, size, cframe, color, material, collide)
	local object = Instance.new("Part")
	object.Name = name
	object.Size = size
	object.CFrame = cframe
	object.Color = color
	object.Material = material
	object.Anchored = true
	object.CanCollide = collide ~= false
	object.TopSurface = Enum.SurfaceType.Smooth
	object.BottomSurface = Enum.SurfaceType.Smooth
	object.Parent = park
	return object
end

local function wedge(name, position, width, height, length, yaw)
	local ramp = Instance.new("WedgePart")
	ramp.Name = name
	ramp.Size = Vector3.new(width, height, length)
	ramp.CFrame = CFrame.new(position.X, height / 2, position.Z) * CFrame.Angles(0, yaw, 0)
	ramp.Color = ASPHALT
	ramp.Material = Enum.Material.Asphalt
	ramp.Anchored = true
	ramp.TopSurface = Enum.SurfaceType.Smooth
	ramp.BottomSurface = Enum.SurfaceType.Smooth
	ramp.Parent = park

	-- Bright edges make the ramp direction readable at driving speed.
	for _, side in ipairs({-1, 1}) do
		local marker = part(
			"RampEdge",
			Vector3.new(0.35, math.max(0.18, height * 0.08), length * 0.92),
			ramp.CFrame * CFrame.new(side * (width / 2 - 0.35), height * 0.38, 0),
			EDGE,
			Enum.Material.Neon,
			false
		)
		marker.CastShadow = false
	end
end

local WEST_LOOP_BOTTOM = Vector3.new(-510, -0.48, 430)
local EAST_LOOP_BOTTOM = Vector3.new(510, -0.48, -430)
local LOOP_CLEARANCE = 105
local LOOP_POSITIONS = {WEST_LOOP_BOTTOM, EAST_LOOP_BOTTOM}

local reserved = {}
local function isClear(candidate, clearance)
	-- Keep the city, hotel, vehicle spawn and flying carpet unobstructed.
	if math.abs(candidate.X) < 365 and math.abs(candidate.Z) < 335 then
		return false
	end
	for _, loopPosition in LOOP_POSITIONS do
		if (candidate - loopPosition).Magnitude < LOOP_CLEARANCE then
			return false
		end
	end
	for _, position in reserved do
		if (candidate - position).Magnitude < clearance then
			return false
		end
	end
	return true
end

local function randomPosition(clearance)
	for _ = 1, 100 do
		local candidate = Vector3.new(random:NextNumber(-670, 670), 0, random:NextNumber(-670, 670))
		if isClear(candidate, clearance) then
			table.insert(reserved, candidate)
			return candidate
		end
	end
	return nil
end

local rampTypes = {
	{name = "SmallRamp", width = 18, height = 5, length = 22, count = 10, clearance = 45},
	{name = "MediumRamp", width = 24, height = 10, length = 36, count = 10, clearance = 58},
	{name = "LargeRamp", width = 32, height = 18, length = 58, count = 7, clearance = 78},
	{name = "LongIncline", width = 38, height = 12, length = 76, count = 6, clearance = 92},
}

for _, specification in rampTypes do
	for _ = 1, specification.count do
		local position = randomPosition(specification.clearance)
		if position then
			local yaw = math.rad(random:NextInteger(0, 23) * 15)
			wedge(
				specification.name,
				position,
				specification.width,
				specification.height,
				specification.length,
				yaw
			)
		end
	end
end

local function createLoop(name, bottomPosition, direction, radius, width)
	local loop = Instance.new("Model")
	loop.Name = name
	loop.Parent = park

	direction = Vector3.new(direction.X, 0, direction.Z).Unit
	local up = Vector3.yAxis
	local right = direction:Cross(up).Unit
	local center = bottomPosition + up * radius
	local segments = 28
	local segmentLength = 2 * radius * math.sin(math.pi / segments) * 1.08
	local thickness = 1.15

	for index = 0, segments - 1 do
		local angle = (index + 0.5) * math.pi * 2 / segments
		local radial = direction * math.sin(angle) - up * math.cos(angle)
		local normal = -radial
		local tangent = direction * math.cos(angle) + up * math.sin(angle)
		local position = center + radial * radius
		local frame = CFrame.fromMatrix(position, right, normal, -tangent)

		local road = part(
			"LoopRoad",
			Vector3.new(width, thickness, segmentLength),
			frame,
			ASPHALT,
			Enum.Material.Asphalt,
			true
		)
		road.Parent = loop

		for _, side in ipairs({-1, 1}) do
			local guard = part(
				"LoopGuard",
				Vector3.new(0.8, 3.8, segmentLength),
				frame * CFrame.new(side * (width / 2 - 0.4), 2.1, 0),
				EDGE,
				Enum.Material.Metal,
				true
			)
			guard.Parent = loop
		end
	end

	-- Structural supports clarify the loop and prevent it appearing suspended.
	for _, side in ipairs({-1, 1}) do
		local support = part(
			"LoopSupport",
			Vector3.new(1.4, radius * 2, 1.4),
			CFrame.new(center + right * side * (width / 2 + 2)),
			STEEL,
			Enum.Material.Metal,
			true
		)
		support.Parent = loop
	end
end

-- Dedicated positions keep the loops clear of random ramps and landmarks.
createLoop("WestLoop", WEST_LOOP_BOTTOM, Vector3.new(0, 0, -1), 31, 25)
createLoop("EastLoop", EAST_LOOP_BOTTOM, Vector3.new(1, 0, 0), 34, 27)

print(string.format("[roblox_game] Ramp park loaded with %d stunt parts.", #park:GetDescendants()))

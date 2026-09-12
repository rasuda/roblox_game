-- Loads only the visual geometry of Creator Store asset 4026700014.
-- Every external script and physical behavior is discarded; A-Chassis remains
-- the sole controller, suspension and collision system.
local InsertService = game:GetService("InsertService")
local ASSET_ID = 4026700014
local TARGET_LENGTH = 14.9
local BODY_BOTTOM = -0.88
local BODY_BACK_OFFSET = 0.25

return function(car)
	local ok, package = pcall(InsertService.LoadAsset, InsertService, ASSET_ID)
	if not ok or not package then
		warn("[roblox_game] Could not load Car Body Low-Poly:", package)
		return false
	end

	local visual = Instance.new("Model")
	visual.Name = "CarBodyLowPoly_ThePartModeler"

	-- Copy only renderable parts. No scripts, seats, constraints, remotes,
	-- sounds or joints from the public asset are admitted into the experience.
	for _, object in package:GetDescendants() do
		if object:IsA("BasePart") then
			local part = object:Clone()
			for _, child in part:GetDescendants() do
				if child:IsA("LuaSourceContainer")
					or child:IsA("JointInstance")
					or child:IsA("Constraint")
					or child:IsA("Sound") then
					child:Destroy()
				end
			end
			part.Anchored = true
			part.Massless = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.CastShadow = true
			part.Parent = visual
		end
	end
	package:Destroy()

	if #visual:GetChildren() == 0 then
		visual:Destroy()
		return false
	end

	local sourceBox, sourceSize = visual:GetBoundingBox()
	if sourceSize.X < 0.01 or sourceSize.Y < 0.01 or sourceSize.Z < 0.01 then
		visual:Destroy()
		return false
	end

	-- One scale for every part and offset preserves rotated mesh panels.
	-- Per-axis Size scaling distorts panels whose local axes differ from the body.
	local longOnX = sourceSize.X > sourceSize.Z
	local scale = TARGET_LENGTH / math.max(sourceSize.X, sourceSize.Z)
	for _, part in visual:GetChildren() do
		if part:IsA("BasePart") then
			local relative = sourceBox:ToObjectSpace(part.CFrame)
			local position = relative.Position
			part.Size = part.Size * scale
			for _, mesh in part:GetChildren() do
				if mesh:IsA("SpecialMesh") then
					mesh.Scale = mesh.Scale * scale
					mesh.Offset = mesh.Offset * scale
				end
			end
			part.CFrame = sourceBox
				* CFrame.new(position * scale)
				* relative.Rotation
		end
	end

	local boxCF, boxSize = visual:GetBoundingBox()
	local boxToPivot = boxCF:ToObjectSpace(visual:GetPivot())
	local rotation = CFrame.Angles(0, longOnX and math.rad(90) or 0, 0)
	local desiredBox = car.DriveSeat.CFrame
		* CFrame.new(0, BODY_BOTTOM + boxSize.Y / 2, BODY_BACK_OFFSET)
		* rotation
	visual:PivotTo(desiredBox * boxToPivot)
	visual.Parent = car.Body

	car.DriveSeat.Transparency = 1
	-- Visual cleanup only. Wheel collision, density, position and constraints stay
	-- unchanged; the spring coils are merely hidden.
	for _, wheel in car.Wheels:GetChildren() do
		if wheel:IsA("BasePart") then
			wheel.Color = Color3.fromRGB(22, 22, 24)
			wheel.Transparency = 0
			-- Welded by native A-Chassis initialization to this wheel, not Body.
			local parts = wheel:FindFirstChild("Parts")
			if not parts then
				parts = Instance.new("Model")
				parts.Name = "Parts"
				parts.Parent = wheel
			end
			local function detail(name, size, cf, color, cylinder)
				local p = Instance.new("Part")
				p.Name = name
				p.Size = size
				p.CFrame = cf
				p.Color = color
				p.Material = Enum.Material.SmoothPlastic
				p.Anchored = true
				p.Massless = true
				p.CanCollide = false
				p.CanTouch = false
				p.CanQuery = false
				if cylinder then p.Shape = Enum.PartType.Cylinder end
				p.Parent = parts
			end
			local radius = math.min(wheel.Size.Y, wheel.Size.Z) * 0.35
			for _, side in ipairs({-1, 1}) do
				local hub = wheel.CFrame * CFrame.new(side * (wheel.Size.X / 2 + 0.045), 0, 0)
				detail("RimBarrel", Vector3.new(0.07, radius*2, radius*2), hub,
					Color3.fromRGB(65,70,77), true)
				local face = hub * CFrame.new(side * 0.075,0,0)
				for i=0,7 do
					detail("SilverSpoke", Vector3.new(0.08,radius*0.8,0.12),
						face * CFrame.Angles(i*math.pi/4,0,0) * CFrame.new(0,radius*0.5,0),
						Color3.fromRGB(202,207,215), false)
				end
				detail("HubCap",Vector3.new(0.12,0.3,0.3),face,Color3.fromRGB(180,185,193),true)
			end
		end
		for _, object in wheel:GetDescendants() do
			if object:IsA("SpringConstraint") then
				object.Visible = false
			end
		end
	end
	print(string.format(
		"[roblox_game] Sanitized low-poly body: %d parts; fitted %.1f x %.1f x %.1f",
		#visual:GetChildren(), boxSize.X, boxSize.Y, boxSize.Z
	))
	return true
end

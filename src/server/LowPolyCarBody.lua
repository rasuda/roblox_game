-- Loads only the visual geometry of Creator Store asset 4026700014.
-- Every external script and physical behavior is discarded; A-Chassis remains
-- the sole controller, suspension and collision system.
local InsertService = game:GetService("InsertService")
local ASSET_ID = 4026700014

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

	-- Fit each axis independently. Uniform scaling made this asset too short
	-- because its original height became the limiting dimension.
	local longOnX = sourceSize.X > sourceSize.Z
	local scaleX = (longOnX and 13.6 or 6.25) / sourceSize.X
	local scaleY = 3.55 / sourceSize.Y
	local scaleZ = (longOnX and 6.25 or 13.6) / sourceSize.Z
	for _, part in visual:GetChildren() do
		if part:IsA("BasePart") then
			local relative = sourceBox:ToObjectSpace(part.CFrame)
			local position = relative.Position
			part.Size = Vector3.new(
				part.Size.X * scaleX,
				part.Size.Y * scaleY,
				part.Size.Z * scaleZ
			)
			part.CFrame = sourceBox
				* CFrame.new(position.X * scaleX, position.Y * scaleY, position.Z * scaleZ)
				* relative.Rotation
		end
	end

	local boxCF, boxSize = visual:GetBoundingBox()
	local boxToPivot = boxCF:ToObjectSpace(visual:GetPivot())
	local rotation = CFrame.Angles(0, longOnX and math.rad(90) or 0, 0)
	local desiredBox = car.DriveSeat.CFrame
		* CFrame.new(0, -0.72 + boxSize.Y / 2, 0)
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

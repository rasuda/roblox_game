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

	local _, sourceSize = visual:GetBoundingBox()
	if sourceSize.X < 0.01 or sourceSize.Y < 0.01 or sourceSize.Z < 0.01 then
		visual:Destroy()
		return false
	end

	-- Fit the visual body to the working chassis without moving its wheels.
	local longOnX = sourceSize.X > sourceSize.Z
	local sourceLength = longOnX and sourceSize.X or sourceSize.Z
	local sourceWidth = longOnX and sourceSize.Z or sourceSize.X
	local scale = math.min(14.2 / sourceLength, 6.4 / sourceWidth, 4.1 / sourceSize.Y)
	visual:ScaleTo(scale)
	visual:PivotTo(car.DriveSeat.CFrame * CFrame.Angles(0, longOnX and math.rad(90) or 0, 0))

	local boxCF, boxSize = visual:GetBoundingBox()
	local desiredCenter = car.DriveSeat.CFrame * CFrame.new(0, -0.55 + boxSize.Y / 2, 0)
	local boxToPivot = boxCF:ToObjectSpace(visual:GetPivot())
	visual:PivotTo(desiredCenter * boxToPivot)
	visual.Parent = car.Body

	car.DriveSeat.Transparency = 1
	print(string.format("[roblox_game] Sanitized low-poly body: %d parts, scale %.3f", #visual:GetChildren(), scale))
	return true
end

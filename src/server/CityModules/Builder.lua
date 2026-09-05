local CollectionService = game:GetService("CollectionService")

local Builder = {}

function Builder.part(parent, name, size, cframe, color, material, collide)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.CanCollide = collide ~= false
	part.CanTouch = collide ~= false
	part.CanQuery = collide ~= false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

function Builder.wedge(parent, name, size, cframe, color, material, collide)
	local part = Instance.new("WedgePart")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.CanCollide = collide ~= false
	part.CanTouch = collide ~= false
	part.CanQuery = collide ~= false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

function Builder.model(parent, name)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	return model
end

function Builder.neon(part, nightColor, dayColor)
	part:SetAttribute("NightColor", nightColor or part.Color)
	part:SetAttribute("DayColor", dayColor or (nightColor or part.Color):Lerp(Color3.new(0.3, 0.3, 0.3), 0.5))
	part.CastShadow = false
	part.CanCollide = false
	part.CanTouch = false
	CollectionService:AddTag(part, "CityNightEmissive")
	return part
end

function Builder.sign(parent, text, size, cframe, backgroundColor, textColor)
	local sign = Builder.part(parent, "LightedSign", size, cframe, backgroundColor, Enum.Material.Neon, false)
	Builder.neon(sign, backgroundColor, backgroundColor:Lerp(Color3.new(0.25, 0.25, 0.25), 0.62))

	for _, face in ipairs({Enum.NormalId.Front, Enum.NormalId.Back}) do
		local surface = Instance.new("SurfaceGui")
		surface.Name = "SignFace"
		surface.Face = face
		surface.LightInfluence = 0
		surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		surface.PixelsPerStud = 18
		surface.Parent = sign

		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = textColor or Color3.new(1, 1, 1)
		label.TextScaled = true
		label.Font = Enum.Font.GothamBlack
		label.Parent = surface
	end
	return sign
end

function Builder.beam(parent, name, pointA, pointB, thickness, color, material)
	local midpoint = (pointA + pointB) * 0.5
	local length = (pointB - pointA).Magnitude
	local beam = Builder.part(parent, name, Vector3.new(thickness, thickness, length), CFrame.lookAt(midpoint, pointB), color, material, false)
	beam.CastShadow = false
	return beam
end

function Builder.building(parent, name, position, size, bodyColor, accentColor, windowBands)
	local model = Builder.model(parent, name)
	local body = Builder.part(model, "Facade", size, CFrame.new(position + Vector3.new(0, size.Y / 2, 0)), bodyColor, Enum.Material.Concrete, true)
	body.CastShadow = true

	local crown = Builder.part(model, "Crown", Vector3.new(size.X + 3, 4, size.Z + 3), CFrame.new(position + Vector3.new(0, size.Y + 2, 0)), accentColor, Enum.Material.Metal, false)
	Builder.neon(crown, accentColor)

	local bands = math.max(2, windowBands or math.floor(size.Y / 30))
	for row = 1, bands do
		local y = position.Y + (row / (bands + 1)) * size.Y
		for _, zSide in ipairs({-1, 1}) do
			local band = Builder.part(model, "WindowBand", Vector3.new(size.X * 0.82, 4, 0.35), CFrame.new(position.X, y, position.Z + zSide * (size.Z / 2 + 0.2)), accentColor, Enum.Material.Glass, false)
			Builder.neon(band, accentColor)
		end
		for _, xSide in ipairs({-1, 1}) do
			local band = Builder.part(model, "WindowBand", Vector3.new(0.35, 4, size.Z * 0.82), CFrame.new(position.X + xSide * (size.X / 2 + 0.2), y, position.Z), accentColor, Enum.Material.Glass, false)
			Builder.neon(band, accentColor)
		end
	end
	return model
end

return Builder

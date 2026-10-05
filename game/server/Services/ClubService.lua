local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local ClubService = {}
ClubService.Context = nil
ClubService.World = nil
ClubService.Clubs = {}
ClubService.PlayerClubs = {}
ClubService.UpgradePrompts = {}

local CLUB_CENTERS = {Vector3.new(-135, 0, 190), Vector3.new(135, 0, 190)}
local CLUB_COLORS = {Color3.fromRGB(45, 130, 211), Color3.fromRGB(222, 74, 68)}

local function part(parent, name, size, position, color, material, collide, transparency)
	local object = Instance.new("Part")
	object.Name = name
	object.Size = size
	object.Position = position
	object.Color = color
	object.Material = material or Enum.Material.SmoothPlastic
	object.Anchored = true
	object.CanCollide = collide ~= false
	object.Transparency = transparency or 0
	object.TopSurface = Enum.SurfaceType.Smooth
	object.BottomSurface = Enum.SurfaceType.Smooth
	object.Parent = parent
	return object
end

local function billboard(adornee, text, color, size)
	local gui = Instance.new("BillboardGui")
	gui.Size = size or UDim2.fromOffset(260, 70)
	gui.StudsOffset = Vector3.new(0, 4, 0)
	gui.AlwaysOnTop = true
	gui.Adornee = adornee
	gui.Parent = adornee
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(14, 19, 29)
	label.BackgroundTransparency = 0.15
	label.TextColor3 = color or Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextWrapped = true
	label.Text = text
	label.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = label
	return label
end

function ClubService:BuildWorld()
	local old = Workspace:FindFirstChild("TransferGameWorld")
	if old then old:Destroy() end
	local world = Instance.new("Model")
	world.Name = "TransferGameWorld"
	world.Parent = Workspace
	self.World = world
	part(world, "Ground", Vector3.new(800, 2, 650), Vector3.new(0, -1, 35), Color3.fromRGB(67, 92, 70), Enum.Material.Grass, true)
	part(world, "CentralRoad", Vector3.new(54, 0.25, 520), Vector3.new(0, 0.13, 35), Color3.fromRGB(55, 58, 61), Enum.Material.Asphalt, true)

	local zone = self.Context.Config.Zones.Street
	local zoneFloor = part(world, "StreetZone", zone.Size, zone.Center - Vector3.new(0, 0.45, 0), zone.Color, Enum.Material.Asphalt, true)
	zoneFloor:SetAttribute("ZoneId", "Street")
	local zoneSign = part(world, "StreetZoneSign", Vector3.new(70, 16, 2), Vector3.new(0, 9, -238), Color3.fromRGB(26, 31, 40), Enum.Material.Metal, true)
	billboard(zoneSign, "VÁRZEA STREET\nCONTRATOS", Color3.fromRGB(112, 232, 134), UDim2.fromOffset(330, 95))

	local contractFolder = Instance.new("Folder")
	contractFolder.Name = "Contracts"
	contractFolder.Parent = world
	local guardians = Instance.new("Folder")
	guardians.Name = "Guardians"
	guardians.Parent = world

	for index, center in ipairs(CLUB_CENTERS) do
		local club = Instance.new("Model")
		club.Name = "Club" .. index
		club:SetAttribute("ClubIndex", index)
		club:SetAttribute("OwnerUserId", 0)
		club.Parent = world
		local color = CLUB_COLORS[index]
		part(club, "ClubFloor", Vector3.new(112, 0.5, 102), center + Vector3.new(0, 0.25, 0), Color3.fromRGB(49, 126, 65), Enum.Material.Grass, true)
		local safe = part(club, "SafeZone", Vector3.new(108, 18, 98), center + Vector3.new(0, 9, 0), color, Enum.Material.ForceField, false, 0.88)
		safe.CanQuery = false
		local spawn = part(club, "ClubSpawn", Vector3.new(8, 0.6, 8), center + Vector3.new(0, 0.3, 34), color, Enum.Material.Neon, true)
		local training = part(club, "TrainingPad", Vector3.new(36, 0.35, 22), center + Vector3.new(-28, 0.35, 4), Color3.fromRGB(240, 174, 48), Enum.Material.Neon, true)
		billboard(training, "TREINO DE SPEED", Color3.fromRGB(255, 220, 101), UDim2.fromOffset(220, 55))
		local deposit = part(club, "DepositPad", Vector3.new(30, 0.35, 22), center + Vector3.new(29, 0.35, 4), Color3.fromRGB(65, 224, 138), Enum.Material.Neon, true)
		billboard(deposit, "ASSINAR CONTRATO", Color3.fromRGB(105, 255, 173), UDim2.fromOffset(250, 55))
		local upgrade = part(club, "UpgradeKiosk", Vector3.new(12, 8, 8), center + Vector3.new(-35, 4, -32), color, Enum.Material.Metal, true)
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "TrainingUpgradePrompt"
		prompt.ActionText = "Melhorar treino"
		prompt.ObjectText = "Upgrade $25"
		prompt.MaxActivationDistance = 14
		prompt.HoldDuration = 0.15
		prompt.RequiresLineOfSight = false
		prompt.Parent = upgrade
		self.UpgradePrompts[index] = prompt

		local sign = part(club, "ClubSign", Vector3.new(34, 10, 2), center + Vector3.new(0, 6, -47), color, Enum.Material.Metal, true)
		local signLabel = billboard(sign, "CLUBE DISPONÍVEL", Color3.new(1,1,1), UDim2.fromOffset(300, 80))
		local slots = Instance.new("Folder")
		slots.Name = "LineupSlots"
		slots.Parent = club
		for slotIndex = 1, 6 do
			local row = slotIndex <= 3 and 0 or 1
			local column = (slotIndex - 1) % 3
			local slot = part(slots, "Slot" .. slotIndex, Vector3.new(20, 0.8, 12), center + Vector3.new((column - 1) * 25, 0.5, -18 + row * 15), Color3.fromRGB(31, 38, 48), Enum.Material.Metal, true)
			slot:SetAttribute("SlotIndex", slotIndex)
		end
		self.Clubs[index] = {Model=club, Center=center, SafeZone=safe, Spawn=spawn, TrainingPad=training, DepositPad=deposit, UpgradePrompt=prompt, SignLabel=signLabel, Owner=nil}
	end
end

function ClubService:GetClub(player) return self.PlayerClubs[player] end

function ClubService:IsInsidePart(position, object, padding)
	local localPosition = object.CFrame:PointToObjectSpace(position)
	local half = object.Size / 2 + Vector3.new(padding or 0, padding or 0, padding or 0)
	return math.abs(localPosition.X) <= half.X and math.abs(localPosition.Y) <= half.Y and math.abs(localPosition.Z) <= half.Z
end

function ClubService:IsInOwnSafeZone(player, position)
	local club = self:GetClub(player)
	return club ~= nil and self:IsInsidePart(position, club.SafeZone, 2)
end

function ClubService:IsInAnySafeZone(position)
	for _, club in ipairs(self.Clubs) do
		if self:IsInsidePart(position, club.SafeZone, 2) then return true end
	end
	return false
end

function ClubService:Assign(player)
	if self.PlayerClubs[player] then return self.PlayerClubs[player] end
	for _, club in ipairs(self.Clubs) do
		if not club.Owner then
			club.Owner = player
			club.Model:SetAttribute("OwnerUserId", player.UserId)
			club.SignLabel.Text = "CLUBE DO " .. string.upper(player.DisplayName)
			self.PlayerClubs[player] = club
			player:SetAttribute("ClubIndex", club.Model:GetAttribute("ClubIndex"))
			local function placeCharacter(character)
				local root = character:WaitForChild("HumanoidRootPart", 10)
				if root then character:PivotTo(CFrame.new(club.Spawn.Position + Vector3.new(0, 4, 0), club.Center)) end
			end
			player.CharacterAdded:Connect(placeCharacter)
			if player.Character then task.spawn(placeCharacter, player.Character) end
			return club
		end
	end
	self.Context.Remotes.Notification:FireClient(player, "Servidor cheio: aguardando um clube livre.", "Warning")
	return nil
end

function ClubService:Release(player)
	local club = self.PlayerClubs[player]
	if not club then return end
	club.Owner = nil
	club.Model:SetAttribute("OwnerUserId", 0)
	club.SignLabel.Text = "CLUBE DISPONÍVEL"
	self.PlayerClubs[player] = nil
end

function ClubService:RenderLineup(player, profile, definitions)
	local club = self:GetClub(player)
	if not club then return end
	local byId = {}
	for _, owned in ipairs(profile.OwnedPlayers) do byId[owned.InstanceId] = owned end
	for _, slot in ipairs(club.Model.LineupSlots:GetChildren()) do
		local old = slot:FindFirstChild("PlayerDisplay")
		if old then old:Destroy() end
		local instanceId = profile.ActiveLineup[slot:GetAttribute("SlotIndex")]
		local owned = instanceId and byId[instanceId]
		if owned then
			local definition = definitions[owned.DefinitionId]
			local display = Instance.new("BillboardGui")
			display.Name = "PlayerDisplay"
			display.Size = UDim2.fromOffset(175, 95)
			display.StudsOffset = Vector3.new(0, 4, 0)
			display.AlwaysOnTop = true
			display.Parent = slot
			local label = Instance.new("TextLabel")
			label.Size = UDim2.fromScale(1,1)
			label.BackgroundColor3 = Color3.fromRGB(20,25,38)
			label.TextColor3 = Color3.new(1,1,1)
			label.Text = string.format("%s\n%s %d • $%.1f/s", definition.Name, owned.Edition, owned.Rating, owned.Income)
			label.TextScaled = true
			label.TextWrapped = true
			label.Font = Enum.Font.GothamBold
			label.Parent = display
		end
	end
end

function ClubService:Init(context)
	self.Context = context
	self:BuildWorld()
	Players.PlayerAdded:Connect(function(player) self:Assign(player) end)
	Players.PlayerRemoving:Connect(function(player) self:Release(player) end)
	for _, player in ipairs(Players:GetPlayers()) do self:Assign(player) end
end

return ClubService

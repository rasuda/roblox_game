local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ContractService = {}
ContractService.Context = nil
ContractService.Contracts = {}
ContractService.CarrierContracts = {}
ContractService.Random = Random.new()

local TRANSITIONS = {
	AVAILABLE = {CARRIED=true},
	DROPPED = {CARRIED=true},
	CARRIED = {DROPPED=true, DEPOSITED=true},
	DEPOSITED = {SIGNING=true},
	SIGNING = {SIGNED=true},
	SIGNED = {},
}

local function weightedChoice(random, ids, definitions)
	local total = 0
	for _, id in ipairs(ids) do total += definitions[id].SpawnWeight end
	local roll = random:NextNumber(0, total)
	for _, id in ipairs(ids) do
		roll -= definitions[id].SpawnWeight
		if roll <= 0 then return id end
	end
	return ids[#ids]
end

function ContractService:SetState(record, newState)
	if record.State == newState then return true end
	if not (TRANSITIONS[record.State] and TRANSITIONS[record.State][newState]) then
		warn("[TransferGame] Invalid contract transition", record.State, "->", newState)
		return false
	end
	record.State = newState
	if record.Model and record.Model.Parent then record.Model:SetAttribute("State", newState) end
	return true
end

function ContractService:BuildModel(record, position)
	local definition = self.Context.Config.Players[record.DefinitionId]
	local rarity = self.Context.Config.Rarity.Definitions[definition.Rarity]
	local model = Instance.new("Model")
	model.Name = "Contract_" .. record.Id
	model:SetAttribute("ContractId", record.Id)
	model:SetAttribute("DefinitionId", record.DefinitionId)
	model:SetAttribute("State", record.State)
	model.Parent = self.Context.Services.Club.World.Contracts
	local case = Instance.new("Part")
	case.Name = "ContractCase"
	case.Size = Vector3.new(7, 5, 1.2)
	case.CFrame = CFrame.new(position)
	case.Color = Color3.fromRGB(234, 226, 196)
	case.Material = Enum.Material.SmoothPlastic
	case.Anchored = true
	case.CanCollide = true
	case.Parent = model
	model.PrimaryPart = case
	local stripe = Instance.new("Part")
	stripe.Name = "RarityStripe"
	stripe.Size = Vector3.new(7.2, 0.65, 1.35)
	stripe.CFrame = case.CFrame * CFrame.new(0, 1.75, 0)
	stripe.Color = rarity.Color
	stripe.Material = Enum.Material.Neon
	stripe.Anchored = true
	stripe.CanCollide = false
	stripe.Parent = model
	local gui = Instance.new("BillboardGui")
	gui.Name = "ContractInfo"
	gui.Size = UDim2.fromOffset(230, 95)
	gui.StudsOffset = Vector3.new(0, 4.5, 0)
	gui.AlwaysOnTop = true
	gui.Parent = case
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1,1)
	label.BackgroundColor3 = Color3.fromRGB(17, 22, 32)
	label.BackgroundTransparency = 0.08
	label.TextColor3 = rarity.Color
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextWrapped = true
	label.Text = string.format("%s\n%s • %s", definition.Name, definition.Position, definition.Rarity)
	label.Parent = gui
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "StealContract"
	prompt.ActionText = "Pegar contrato"
	prompt.ObjectText = definition.Name
	prompt.MaxActivationDistance = self.Context.Config.Game.ContractPickupDistance
	prompt.HoldDuration = 0.25
	prompt.RequiresLineOfSight = false
	prompt.Parent = case
	prompt.Triggered:Connect(function(player) self:Pickup(player, record) end)
	record.Model = model
	record.Prompt = prompt
	return model
end

function ContractService:Spawn(definitionId, position)
	local record = {
		Id = self.Context.Services.PlayerData:NewId(),
		DefinitionId = definitionId,
		State = self.Context.Constants.ContractState.AVAILABLE,
		Carrier = nil,
		PickupEnabledAt = 0,
	}
	self.Contracts[record.Id] = record
	self:BuildModel(record, position)
	return record
end

function ContractService:ResetMarket()
	for id, record in pairs(self.Contracts) do
		if record.State == "AVAILABLE" or record.State == "DROPPED" then
			if record.Model then record.Model:Destroy() end
			self.Contracts[id] = nil
		end
	end
	local zone = self.Context.Config.Zones.Street
	for index, position in ipairs(zone.ContractSpawnPoints) do
		local definitionId = weightedChoice(self.Random, zone.PlayerPool, self.Context.Config.Players)
		self:Spawn(definitionId, position + Vector3.new(0, math.sin(index) * 0.05, 0))
	end
end

function ContractService:CarryMultiplier(definition)
	local config = self.Context.Config.Training
	return math.clamp(config.CarryBaseMultiplier - (definition.TransferDifficulty - 1) * config.DifficultyPenalty, config.MinimumCarryMultiplier, 1)
end

function ContractService:Pickup(player, record)
	if not player.Parent or self.CarrierContracts[player] then return end
	if record.State ~= "AVAILABLE" and record.State ~= "DROPPED" then return end
	if os.clock() < record.PickupEnabledAt then return end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid or humanoid.Health <= 0 or not record.Model or not record.Model.PrimaryPart then return end
	if (root.Position - record.Model.PrimaryPart.Position).Magnitude > self.Context.Config.Game.ContractPickupDistance + 3 then return end
	if not self:SetState(record, self.Context.Constants.ContractState.CARRIED) then return end

	record.Carrier = player
	self.CarrierContracts[player] = record
	record.Prompt.Enabled = false
	for _, object in ipairs(record.Model:GetDescendants()) do
		if object:IsA("BasePart") then object.CanCollide = false end
	end
	local definition = self.Context.Config.Players[record.DefinitionId]
	local multiplier = self:CarryMultiplier(definition)
	player:SetAttribute("CarriedContract", definition.Name)
	player:SetAttribute("CarryMultiplier", multiplier)
	self.Context.Services.PlayerData:SetCharacterSpeed(player, multiplier)
	self.Context.Services.PlayerData:Push(player)
	self.Context.Services.Guardian:AddTarget(player)
	self.Context.Remotes.Notification:FireClient(player, "Contrato roubado! Volte ao seu clube.", "Warning")
end

function ContractService:Drop(player, reason)
	local record = self.CarrierContracts[player]
	if not record or record.State ~= "CARRIED" then return false end
	if not self:SetState(record, self.Context.Constants.ContractState.DROPPED) then return false end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local position = root and (root.Position + root.CFrame.LookVector * 4 + Vector3.new(0, 1.8, 0)) or self.Context.Config.Zones.Street.Center + Vector3.new(0, 3, 0)
	record.Model:PivotTo(CFrame.new(position))
	record.Carrier = nil
	record.PickupEnabledAt = os.clock() + self.Context.Config.Game.ContractDropCooldown
	self.CarrierContracts[player] = nil
	player:SetAttribute("CarriedContract", nil)
	player:SetAttribute("CarryMultiplier", nil)
	self.Context.Services.PlayerData:SetCharacterSpeed(player)
	self.Context.Services.PlayerData:Push(player)
	self.Context.Services.Guardian:RemoveTarget(player)
	task.delay(self.Context.Config.Game.ContractDropCooldown, function()
		if record.Model and record.State == "DROPPED" then
			record.Prompt.Enabled = true
			for _, object in ipairs(record.Model:GetDescendants()) do
				if object:IsA("BasePart") then object.CanCollide = object == record.Model.PrimaryPart end
			end
		end
	end)
	if player.Parent then self.Context.Remotes.Notification:FireClient(player, "Contrato derrubado: " .. (reason or "interceptado"), "Warning") end
	return true
end

function ContractService:RollEdition()
	local total = 0
	for _, edition in pairs(self.Context.Config.Economy.Editions) do total += edition.Weight end
	local roll = self.Random:NextNumber(0, total)
	for name, edition in pairs(self.Context.Config.Economy.Editions) do
		roll -= edition.Weight
		if roll <= 0 then return name end
	end
	return "Normal"
end

function ContractService:CompleteSigning(player, signingId)
	local pending = self.Context.Services.PlayerData:RemovePendingSigning(player, signingId)
	if not pending then return end
	local definition = self.Context.Config.Players[pending.DefinitionId]
	local instance = {
		InstanceId = self.Context.Services.PlayerData:NewId(),
		DefinitionId = pending.DefinitionId,
		Rating = pending.Rating,
		Edition = pending.Edition,
		AcquiredAt = os.time(),
		OwnerUserId = player.UserId,
	}
	instance.Income = self.Context.Services.Economy:CalculateInstanceIncome(instance)
	self.Context.Services.PlayerData:AddOwnedPlayer(player, instance)
	self.Context.Services.Economy:Refresh(player)
	local profile = self.Context.Services.PlayerData:Get(player)
	if profile then self.Context.Services.Club:RenderLineup(player, profile, self.Context.Config.Players) end
	self.Context.Remotes.Reveal:FireClient(player, {
		Name=definition.Name, Position=definition.Position, Rating=instance.Rating,
		Rarity=definition.Rarity, Edition=instance.Edition, Income=instance.Income,
	})
	self.Context.Remotes.Notification:FireClient(player, definition.Name .. " assinou com seu clube!", "Success")
end

function ContractService:SchedulePending(player, pending)
	local delaySeconds = math.max(0, pending.CompletesAt - os.time())
	task.delay(delaySeconds, function()
		if player.Parent and self.Context.Services.PlayerData:Get(player) then self:CompleteSigning(player, pending.SigningId) end
	end)
end

function ContractService:Deposit(player, record)
	if record ~= self.CarrierContracts[player] or record.State ~= "CARRIED" then return end
	if not self:SetState(record, self.Context.Constants.ContractState.DEPOSITED) then return end
	self.Context.Services.Guardian:RemoveTarget(player)
	self.CarrierContracts[player] = nil
	player:SetAttribute("CarriedContract", nil)
	player:SetAttribute("CarryMultiplier", nil)
	self.Context.Services.PlayerData:SetCharacterSpeed(player)
	if record.Model then record.Model:Destroy() end
	record.Model = nil
	self.Contracts[record.Id] = nil
	self:SetState(record, self.Context.Constants.ContractState.SIGNING)
	local definition = self.Context.Config.Players[record.DefinitionId]
	local pending = {
		SigningId = self.Context.Services.PlayerData:NewId(), DefinitionId = record.DefinitionId,
		Rating = self.Random:NextInteger(definition.RatingMin, definition.RatingMax),
		Edition = self:RollEdition(), CompletesAt = os.time() + definition.SigningTime,
	}
	self.Context.Services.PlayerData:AddPendingSigning(player, pending)
	self.Context.Services.PlayerData:Push(player, {SigningName=definition.Name, SigningEndsAt=pending.CompletesAt})
	self.Context.Remotes.Notification:FireClient(player, "Signing iniciado: " .. definition.Name, "Info")
	self:SchedulePending(player, pending)
end

function ContractService:Tick()
	for player, record in pairs(self.CarrierContracts) do
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if not player.Parent or not root or not humanoid or humanoid.Health <= 0 then
			self:Drop(player, "jogador indisponível")
		else
			record.Model:PivotTo(root.CFrame * CFrame.new(0, 1.8, 3.2))
			local club = self.Context.Services.Club:GetClub(player)
			if club and (root.Position - club.DepositPad.Position).Magnitude <= self.Context.Config.Game.DepositRadius then
				self:Deposit(player, record)
			end
		end
	end
end

function ContractService:BindPlayer(player)
	task.spawn(function()
		local profile = self.Context.Services.PlayerData:WaitForProfile(player, 15)
		if not profile then return end
		for _, pending in ipairs(table.clone(profile.PendingSignings)) do self:SchedulePending(player, pending) end
		self.Context.Services.Club:RenderLineup(player, profile, self.Context.Config.Players)
	end)
	local function bindCharacter(character)
		local humanoid = character:WaitForChild("Humanoid", 10)
		if humanoid then humanoid.Died:Connect(function() self:Drop(player, "você caiu") end) end
	end
	player.CharacterAdded:Connect(bindCharacter)
	if player.Character then task.spawn(bindCharacter, player.Character) end
end

function ContractService:Init(context)
	self.Context = context
	Players.PlayerAdded:Connect(function(player) self:BindPlayer(player) end)
	Players.PlayerRemoving:Connect(function(player) self:Drop(player, "jogador saiu") end)
	for _, player in ipairs(Players:GetPlayers()) do self:BindPlayer(player) end
	RunService.Heartbeat:Connect(function() self:Tick() end)
end

return ContractService

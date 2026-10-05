local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

local PlayerDataService = {}
PlayerDataService.Profiles = {}
PlayerDataService.Context = nil
PlayerDataService.Store = nil

local function deepCopy(value)
	if type(value) ~= "table" then return value end
	local copy = {}
	for key, child in pairs(value) do copy[key] = deepCopy(child) end
	return copy
end

function PlayerDataService:DefaultProfile()
	local config = self.Context.Config
	return {
		SchemaVersion = config.Game.SchemaVersion,
		Money = config.Economy.StartingMoney,
		Speed = config.Training.BaseWalkSpeed,
		TrainingLevel = 1,
		Boots = "Basic",
		OwnedPlayers = {},
		ActiveLineup = {},
		PendingSignings = {},
		Album = {},
		UnlockedZones = {Street = true},
		Settings = {},
	}
end

function PlayerDataService:Reconcile(profile)
	local defaults = self:DefaultProfile()
	if type(profile) ~= "table" then return defaults end
	for key, value in pairs(defaults) do
		if profile[key] == nil or type(profile[key]) ~= type(value) then
			profile[key] = deepCopy(value)
		end
	end
	profile.SchemaVersion = self.Context.Config.Game.SchemaVersion
	profile.Money = math.max(0, tonumber(profile.Money) or 0)
	profile.Speed = math.clamp(tonumber(profile.Speed) or defaults.Speed, defaults.Speed, self.Context.Config.Training.MaximumWalkSpeed)
	profile.TrainingLevel = math.clamp(math.floor(tonumber(profile.TrainingLevel) or 1), 1, #self.Context.Config.Training.LevelMultipliers)
	return profile
end

function PlayerDataService:Get(player)
	return self.Profiles[player]
end

function PlayerDataService:WaitForProfile(player, timeout)
	local deadline = os.clock() + (timeout or 10)
	repeat
		local profile = self.Profiles[player]
		if profile then return profile end
		task.wait()
	until os.clock() >= deadline or not player.Parent
	return nil
end

function PlayerDataService:GetSnapshot(player)
	local profile = self:Get(player)
	if not profile then return nil end
	local pending = profile.PendingSignings[1]
	local pendingDefinition = pending and self.Context.Config.Players[pending.DefinitionId]
	return {
		Money = profile.Money,
		Speed = profile.Speed,
		TrainingLevel = profile.TrainingLevel,
		Boots = profile.Boots,
		OwnedCount = #profile.OwnedPlayers,
		IncomePerSecond = player:GetAttribute("IncomePerSecond") or 0,
		CarriedContract = player:GetAttribute("CarriedContract") or "",
		Zone = player:GetAttribute("CurrentZone") or "Club",
		Training = player:GetAttribute("Training") == true,
		SigningName = pendingDefinition and pendingDefinition.Name or "",
		SigningEndsAt = pending and pending.CompletesAt or 0,
	}
end

function PlayerDataService:Push(player, extra)
	if not player.Parent then return end
	local snapshot = self:GetSnapshot(player)
	if not snapshot then return end
	for key, value in pairs(extra or {}) do snapshot[key] = value end
	self.Context.Remotes.StateUpdate:FireClient(player, snapshot)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local money = leaderstats:FindFirstChild("Money")
		local speed = leaderstats:FindFirstChild("Speed")
		if money then money.Value = math.floor(snapshot.Money) end
		if speed then speed.Value = math.floor(snapshot.Speed * 10 + 0.5) / 10 end
	end
end

function PlayerDataService:SetCharacterSpeed(player, multiplier)
	local profile = self:Get(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if profile and humanoid then humanoid.WalkSpeed = profile.Speed * (multiplier or 1) end
end

function PlayerDataService:AddMoney(player, amount)
	local profile = self:Get(player)
	if not profile or type(amount) ~= "number" or amount <= 0 then return false end
	profile.Money += amount
	self:Push(player)
	return true
end

function PlayerDataService:SpendMoney(player, amount)
	local profile = self:Get(player)
	if not profile or type(amount) ~= "number" or amount < 0 or profile.Money < amount then return false end
	profile.Money -= amount
	self:Push(player)
	return true
end

function PlayerDataService:SetSpeed(player, speed)
	local profile = self:Get(player)
	if not profile then return end
	profile.Speed = math.clamp(speed, self.Context.Config.Training.BaseWalkSpeed, self.Context.Config.Training.MaximumWalkSpeed)
	self:SetCharacterSpeed(player, player:GetAttribute("CarryMultiplier") or 1)
	self:Push(player)
end

function PlayerDataService:AddPendingSigning(player, pending)
	local profile = self:Get(player)
	if not profile then return false end
	table.insert(profile.PendingSignings, pending)
	return true
end

function PlayerDataService:RemovePendingSigning(player, signingId)
	local profile = self:Get(player)
	if not profile then return nil end
	for index, pending in ipairs(profile.PendingSignings) do
		if pending.SigningId == signingId then return table.remove(profile.PendingSignings, index) end
	end
	return nil
end

function PlayerDataService:AddOwnedPlayer(player, instance)
	local profile = self:Get(player)
	if not profile then return false end
	table.insert(profile.OwnedPlayers, instance)
	profile.Album[instance.DefinitionId] = true
	if #profile.ActiveLineup < self.Context.Config.Game.MaxActivePlayers then
		table.insert(profile.ActiveLineup, instance.InstanceId)
	end
	self:Push(player)
	return true
end

function PlayerDataService:Save(player)
	local profile = self:Get(player)
	if not profile then return true end
	local payload = deepCopy(profile)
	local success, message = pcall(function()
		self.Store:UpdateAsync("player_" .. player.UserId, function()
			return payload
		end)
	end)
	if not success then warn("[TransferGame] Save failed for", player.Name, message) end
	return success
end

function PlayerDataService:Load(player)
	local loaded
	local success, message = pcall(function()
		loaded = self.Store:GetAsync("player_" .. player.UserId)
	end)
	if not success then warn("[TransferGame] DataStore unavailable; using session data for", player.Name, message) end
	if not player.Parent then return end
	local profile = self:Reconcile(loaded)
	self.Profiles[player] = profile

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Parent = leaderstats
	local speed = Instance.new("NumberValue")
	speed.Name = "Speed"
	speed.Parent = leaderstats

	player:SetAttribute("ProfileLoaded", true)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid", 10)
		if humanoid then humanoid.WalkSpeed = profile.Speed end
	end)
	if player.Character then self:SetCharacterSpeed(player) end
	self:Push(player)
end

function PlayerDataService:Init(context)
	self.Context = context
	self.Store = DataStoreService:GetDataStore(context.Config.Game.DataStoreName)
	Players.PlayerAdded:Connect(function(player) task.spawn(function() self:Load(player) end) end)
	Players.PlayerRemoving:Connect(function(player)
		self:Save(player)
		self.Profiles[player] = nil
	end)
	for _, player in ipairs(Players:GetPlayers()) do task.spawn(function() self:Load(player) end) end

	task.spawn(function()
		while task.wait(context.Config.Game.AutosaveSeconds) do
			for player in pairs(self.Profiles) do task.spawn(function() self:Save(player) end) end
		end
	end)
	game:BindToClose(function()
		for player in pairs(self.Profiles) do self:Save(player) end
	end)
end

function PlayerDataService:NewId()
	return HttpService:GenerateGUID(false)
end

return PlayerDataService

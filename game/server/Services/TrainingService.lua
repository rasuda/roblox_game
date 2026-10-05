local Players = game:GetService("Players")

local TrainingService = {}
TrainingService.Context = nil

local function horizontalDistance(a, b)
	return (Vector3.new(a.X, 0, a.Z) - Vector3.new(b.X, 0, b.Z)).Magnitude
end

function TrainingService:UpdatePrompt(club)
	local owner = club.Owner
	if not owner then
		club.UpgradePrompt.ObjectText = "Aguardando dono"
		return
	end
	local profile = self.Context.Services.PlayerData:Get(owner)
	if not profile then return end
	local cost = self.Context.Config.Economy.TrainingUpgradeCosts[profile.TrainingLevel]
	club.UpgradePrompt.ObjectText = cost and ("Upgrade $" .. cost) or "Treino no máximo"
end

function TrainingService:BuyUpgrade(player, club)
	if club.Owner ~= player then
		self.Context.Remotes.Notification:FireClient(player, "Este upgrade pertence a outro clube.", "Warning")
		return
	end
	local data = self.Context.Services.PlayerData
	local profile = data:Get(player)
	if not profile then return end
	local cost = self.Context.Config.Economy.TrainingUpgradeCosts[profile.TrainingLevel]
	if not cost then
		self.Context.Remotes.Notification:FireClient(player, "Treinamento já está no nível máximo.", "Info")
		return
	end
	if not data:SpendMoney(player, cost) then
		self.Context.Remotes.Notification:FireClient(player, "Dinheiro insuficiente para o upgrade.", "Warning")
		return
	end
	profile.TrainingLevel += 1
	data:Push(player)
	self:UpdatePrompt(club)
	self.Context.Remotes.Notification:FireClient(player, "Treinamento melhorado para o nível " .. profile.TrainingLevel .. "!", "Success")
end

function TrainingService:Tick(player, deltaTime)
	local club = self.Context.Services.Club:GetClub(player)
	local profile = self.Context.Services.PlayerData:Get(player)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not club or not profile or not root then return end
	local pad = club.TrainingPad
	local inside = horizontalDistance(root.Position, pad.Position) <= math.min(pad.Size.X, pad.Size.Z) * 0.55
	player:SetAttribute("Training", inside)
	if not inside or player:GetAttribute("CarriedContract") ~= nil then
		self.Context.Services.PlayerData:Push(player, {Training=false})
		return
	end
	local trainingConfig = self.Context.Config.Training
	if profile.Speed >= trainingConfig.MaximumWalkSpeed then return end
	local levelMultiplier = trainingConfig.LevelMultipliers[profile.TrainingLevel] or 1
	local boots = self.Context.Config.Equipment[profile.Boots] or self.Context.Config.Equipment.Basic
	local gain = trainingConfig.BaseGainPerSecond * levelMultiplier * boots.TrainingMultiplier * deltaTime
	self.Context.Services.PlayerData:SetSpeed(player, profile.Speed + gain)
end

function TrainingService:Init(context)
	self.Context = context
	for _, club in ipairs(context.Services.Club.Clubs) do
		club.UpgradePrompt.Triggered:Connect(function(player) self:BuyUpgrade(player, club) end)
	end
	task.spawn(function()
		while true do
			local delta = task.wait(context.Config.Game.TrainingTickSeconds)
			for _, player in ipairs(Players:GetPlayers()) do self:Tick(player, delta) end
			for _, club in ipairs(context.Services.Club.Clubs) do self:UpdatePrompt(club) end
		end
	end)
end

return TrainingService

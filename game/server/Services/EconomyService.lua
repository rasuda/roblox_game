local Players = game:GetService("Players")

local EconomyService = {}
EconomyService.Context = nil

function EconomyService:CalculateInstanceIncome(instance)
	local config = self.Context.Config
	local definition = config.Players[instance.DefinitionId]
	if not definition then return 0 end
	local rarity = config.Rarity.Definitions[definition.Rarity]
	local edition = config.Editions.Definitions[instance.Edition] or config.Editions.Definitions.Normal
	local ratingMultiplier = 1 + math.max(0, instance.Rating - config.Economy.RatingBaseline) * config.Economy.RatingIncomePerPoint
	return definition.BaseIncome * rarity.IncomeMultiplier * ratingMultiplier * edition.Multiplier
end

function EconomyService:GetIncomePerSecond(player)
	local profile = self.Context.Services.PlayerData:Get(player)
	if not profile then return 0 end
	local byId = {}
	for _, instance in ipairs(profile.OwnedPlayers) do byId[instance.InstanceId] = instance end
	local total = 0
	for _, instanceId in ipairs(profile.ActiveLineup) do
		local instance = byId[instanceId]
		if instance then
			instance.Income = self:CalculateInstanceIncome(instance)
			total += instance.Income
		end
	end
	local multiplier = self.Context.Config.Economy.CashMultipliers[(profile.Upgrades.CashMultiplier or 0)+1] or 1
	return total * multiplier
end

function EconomyService:Refresh(player)
	local income = self:GetIncomePerSecond(player)
	player:SetAttribute("IncomePerSecond", income)
	self.Context.Services.PlayerData:Push(player, {IncomePerSecond=income})
	return income
end

function EconomyService:SellWeakest(player)
	local profile=self.Context.Services.PlayerData:Get(player) if not profile or #profile.OwnedPlayers==0 then return end
	local weakestIndex,weakest
	for index,instance in ipairs(profile.OwnedPlayers) do if not weakest or (instance.Income or self:CalculateInstanceIncome(instance))<(weakest.Income or self:CalculateInstanceIncome(weakest)) then weakestIndex,weakest=index,instance end end
	if not weakest then return end table.remove(profile.OwnedPlayers,weakestIndex)
	for index,id in ipairs(profile.ActiveLineup) do if id==weakest.InstanceId then table.remove(profile.ActiveLineup,index) break end end
	local value=math.max(1,math.floor(self:CalculateInstanceIncome(weakest)*self.Context.Config.Upgrades.SellReturnMultiplier))
	self.Context.Services.PlayerData:AddMoney(player,value) self:Refresh(player) self.Context.Services.Club:RenderLineup(player,profile)
	self.Context.Remotes.Notification:FireClient(player,"Released weakest player for $"..value..".","Success")
end

function EconomyService:Init(context)
	self.Context = context
	context.Remotes.SellWeakest.OnServerEvent:Connect(function(player) self:SellWeakest(player) end)
	task.spawn(function()
		while task.wait(context.Config.Game.EconomyTickSeconds) do
			for _, player in ipairs(Players:GetPlayers()) do
				if context.Services.PlayerData:Get(player) then
					local income = self:Refresh(player)
					if income > 0 then context.Services.PlayerData:AddMoney(player, income * context.Config.Game.EconomyTickSeconds) end
				end
			end
		end
	end)
end

return EconomyService

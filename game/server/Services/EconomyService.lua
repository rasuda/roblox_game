local Players = game:GetService("Players")

local EconomyService = {}
EconomyService.Context = nil

function EconomyService:CalculateInstanceIncome(instance)
	local config = self.Context.Config
	local definition = config.Players[instance.DefinitionId]
	if not definition then return 0 end
	local rarity = config.Rarity.Definitions[definition.Rarity]
	local edition = config.Economy.Editions[instance.Edition] or config.Economy.Editions.Normal
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
	return total
end

function EconomyService:Refresh(player)
	local income = self:GetIncomePerSecond(player)
	player:SetAttribute("IncomePerSecond", income)
	self.Context.Services.PlayerData:Push(player, {IncomePerSecond=income})
	return income
end

function EconomyService:Init(context)
	self.Context = context
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

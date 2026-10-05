local TransferWindowService = {}
TransferWindowService.Context = nil
TransferWindowService.TimeLeft = 0

function TransferWindowService:Refresh()
	self.Context.Services.Contracts:ResetMarket()
	self.TimeLeft = self.Context.Config.Game.TransferWindowSeconds
	self.Context.Remotes.Notification:FireAllClients("A janela de transferências foi renovada!", "Info")
	for _, record in pairs(self.Context.Services.Contracts.Contracts) do
		local definition = self.Context.Config.Players[record.DefinitionId]
		if definition and definition.Rarity == "Star" then
			self.Context.Remotes.Notification:FireAllClients("Um jogador STAR apareceu na Várzea Street!", "Rare")
			break
		end
	end
end

function TransferWindowService:Init(context)
	self.Context = context
	self:Refresh()
	task.spawn(function()
		while true do
			context.Remotes.TransferWindow:FireAllClients(self.TimeLeft)
			task.wait(1)
			self.TimeLeft -= 1
			if self.TimeLeft <= 0 then self:Refresh() end
		end
	end)
end

return TransferWindowService

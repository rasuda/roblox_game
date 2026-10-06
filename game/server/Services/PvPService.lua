local Players = game:GetService("Players")

local PvPService = {}
PvPService.Context = nil
PvPService.LastUse = {}

function PvPService:FindTarget(attacker, origin)
	local bestPlayer, bestDistance
	for carrier in pairs(self.Context.Services.Contracts.Carried) do
		if carrier ~= attacker then
			local root = carrier.Character and carrier.Character:FindFirstChild("HumanoidRootPart")
			local humanoid = carrier.Character and carrier.Character:FindFirstChildOfClass("Humanoid")
			if root and humanoid and humanoid.Health > 0 and not self.Context.Services.Club:IsInAnySafeZone(root.Position) then
				local distance = (root.Position - origin).Magnitude
				if distance <= self.Context.Config.Game.SlideTackleRange and (not bestDistance or distance < bestDistance) then
					bestPlayer, bestDistance = carrier, distance
				end
			end
		end
	end
	return bestPlayer
end

function PvPService:SlideTackle(player)
	local now = os.clock()
	local cooldown = self.Context.Config.Game.SlideTackleCooldown
	if now - (self.LastUse[player] or -cooldown) < cooldown then return end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid or humanoid.Health <= 0 or self.Context.Services.Club:IsInAnySafeZone(root.Position) then return end
	self.LastUse[player] = now
	root.AssemblyLinearVelocity += root.CFrame.LookVector * 18
	local target = self:FindTarget(player, root.Position)
	if not target then
		self.Context.Remotes.Notification:FireClient(player, "Slide tackle: no carrier in range.", "Info")
		return
	end
	local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return end
	if self.Context.Services.Contracts:Drop(target, "slide tackle by " .. player.DisplayName) then
		local direction = targetRoot.Position - root.Position
		if direction.Magnitude < 0.05 then direction = root.CFrame.LookVector else direction = direction.Unit end
		targetRoot.AssemblyLinearVelocity += direction * self.Context.Config.Game.SlideKnockback + Vector3.new(0, 12, 0)
		local profile=self.Context.Services.PlayerData:Get(player) if profile then profile.Statistics.Tackles+=1 end
		self.Context.Remotes.Notification:FireClient(player, "Contract intercepted!", "Success")
	end
end

function PvPService:Init(context)
	self.Context = context
	context.Remotes.SlideTackle.OnServerEvent:Connect(function(player)
		self:SlideTackle(player)
	end)
	Players.PlayerRemoving:Connect(function(player) self.LastUse[player] = nil end)
end

return PvPService

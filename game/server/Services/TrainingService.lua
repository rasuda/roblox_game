local Players=game:GetService("Players")
local Service={Context=nil}
local function horizontal(a,b) return (Vector3.new(a.X,0,a.Z)-Vector3.new(b.X,0,b.Z)).Magnitude end

function Service:NextBoot(profile)
	local equipment=self.Context.Config.Equipment local current=table.find(equipment.Order,profile.Boots) or 1
	local id=equipment.Order[current+1] return id,id and equipment.Definitions[id]
end
function Service:NextSlot(profile)
	for _,count in ipairs(self.Context.Config.Economy.SlotUpgradeOrder) do if count>profile.SlotCount then return count,self.Context.Config.Economy.SlotUpgradeCosts[count] end end
end

function Service:RefreshKiosks(club)
	local p=club.Owner and self.Context.Services.PlayerData:Get(club.Owner) if not p then return end
	local trainingCost=self.Context.Config.Economy.TrainingUpgradeCosts[p.TrainingLevel]
	club.Kiosks.TrainingUpgrade.ObjectText=trainingCost and ("Training Lv."..(p.TrainingLevel+1).."  $"..trainingCost) or "Training MAX"
	local bootId,boot=self:NextBoot(p) club.Kiosks.BootsUpgrade.ObjectText=boot and (boot.DisplayName.."  $"..boot.Price) or "Boots MAX"
	local slots,cost=self:NextSlot(p) club.Kiosks.SlotsUpgrade.ObjectText=slots and (slots.." Slots  $"..cost) or "Slots MAX"
	local signingCost=self.Context.Config.Economy.SigningSpeedUpgradeCosts[(p.Upgrades.SigningSpeed or 0)+1]
	club.Kiosks.SigningUpgrade.ObjectText=signingCost and ("Faster Signing  $"..signingCost) or "Signing MAX"
	local cashCost=self.Context.Config.Economy.CashMultiplierUpgradeCosts[(p.Upgrades.CashMultiplier or 0)+1]
	club.Kiosks.CashUpgrade.ObjectText=cashCost and ("Cash Boost  $"..cashCost) or "Cash MAX"
end

function Service:Buy(player,club,kind)
	if club.Owner~=player then self.Context.Remotes.Notification:FireClient(player,"This kiosk belongs to another club.","Warning") return end
	local data=self.Context.Services.PlayerData local p=data:Get(player) if not p then return end
	local cost,successText
	if kind=="Training" then
		cost=self.Context.Config.Economy.TrainingUpgradeCosts[p.TrainingLevel] if not cost then return end
		if data:Spend(player,cost) then p.TrainingLevel+=1 successText="Training upgraded to Lv."..p.TrainingLevel end
	elseif kind=="Boots" then
		local id,boot=self:NextBoot(p) if not boot then return end cost=boot.Price
		if data:Spend(player,cost) then p.Boots=id successText="Equipped "..boot.DisplayName end
	elseif kind=="Slots" then
		local count,nextCost=self:NextSlot(p) if not count then return end cost=nextCost
		if data:Spend(player,cost) then p.SlotCount=count successText="Club expanded to "..count.." slots" self.Context.Services.Club:RenderLineup(player,p) end
	elseif kind=="Signing" then
		cost=self.Context.Config.Economy.SigningSpeedUpgradeCosts[(p.Upgrades.SigningSpeed or 0)+1] if not cost then return end
		if data:Spend(player,cost) then p.Upgrades.SigningSpeed+=1 successText="Signing speed upgraded" end
	elseif kind=="Cash" then
		cost=self.Context.Config.Economy.CashMultiplierUpgradeCosts[(p.Upgrades.CashMultiplier or 0)+1] if not cost then return end
		if data:Spend(player,cost) then p.Upgrades.CashMultiplier+=1 successText="Club income multiplier upgraded" end
	end
	if successText then data:Push(player) self.Context.Remotes.Notification:FireClient(player,successText,"Success")
	else self.Context.Remotes.Notification:FireClient(player,"You need $"..tostring(cost or 0)..".","Warning") end self:RefreshKiosks(club)
end

function Service:Tick(player,dt)
	local club=self.Context.Services.Club:GetClub(player) local p=self.Context.Services.PlayerData:Get(player)
	local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart") if not club or not p or not root then return end
	local active=horizontal(root.Position,club.Training.Position)<=math.min(club.Training.Size.X,club.Training.Size.Z)*.58 and not player:GetAttribute("CarriedContract")
	if player:GetAttribute("Training")~=active then player:SetAttribute("Training",active) self.Context.Services.PlayerData:Push(player) end
	if not active or p.Speed>=self.Context.Config.Training.MaximumWalkSpeed then return end
	local level=self.Context.Config.Training.LevelMultipliers[p.TrainingLevel] or 1
	local boots=self.Context.Config.Equipment.Definitions[p.Boots] or self.Context.Config.Equipment.Definitions.Basic
	self.Context.Services.PlayerData:SetSpeed(player,p.Speed+self.Context.Config.Training.BaseGainPerSecond*level*boots.TrainingMultiplier*dt)
end

function Service:Init(context)
	self.Context=context
	for _,club in ipairs(context.Services.Club.Clubs) do
		club.Kiosks.TrainingUpgrade.Triggered:Connect(function(p) self:Buy(p,club,"Training") end)
		club.Kiosks.BootsUpgrade.Triggered:Connect(function(p) self:Buy(p,club,"Boots") end)
		club.Kiosks.SlotsUpgrade.Triggered:Connect(function(p) self:Buy(p,club,"Slots") end)
		club.Kiosks.SigningUpgrade.Triggered:Connect(function(p) self:Buy(p,club,"Signing") end)
		club.Kiosks.CashUpgrade.Triggered:Connect(function(p) self:Buy(p,club,"Cash") end)
	end
	task.spawn(function() while true do local dt=task.wait(context.Config.Game.TrainingTickSeconds) for _,p in ipairs(Players:GetPlayers()) do self:Tick(p,dt) end for _,club in ipairs(context.Services.Club.Clubs) do self:RefreshKiosks(club) end end end)
end
return Service

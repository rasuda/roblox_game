local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Service={Context=nil,Contracts={},Carried={},Random=Random.new()}
local ALLOWED={AVAILABLE={CARRIED=true},DROPPED={CARRIED=true,AVAILABLE=true},CARRIED={DROPPED=true,DEPOSITED=true},DEPOSITED={SIGNING=true},SIGNING={SIGNED=true},SIGNED={}}

local function choose(random,ids,definitions)
	local total=0 for _,id in ipairs(ids) do total+=definitions[id].SpawnWeight end local roll=random:NextNumber(0,total)
	for _,id in ipairs(ids) do roll-=definitions[id].SpawnWeight if roll<=0 then return id end end return ids[#ids]
end

function Service:SetState(record,newState)
	if record.State==newState then return true end if not (ALLOWED[record.State] and ALLOWED[record.State][newState]) then warn("Invalid contract transition",record.State,newState) return false end
	record.State=newState if record.Model and record.Model.Parent then record.Model:SetAttribute("State",newState) end return true
end

function Service:BuildModel(record,position)
	local d=self.Context.Config.Players[record.DefinitionId] local rarity=self.Context.Config.Rarity.Definitions[d.Rarity]
	local model=Instance.new("Model") model.Name="Contract_"..record.Id model:SetAttribute("ContractId",record.Id) model:SetAttribute("State",record.State) model.Parent=self.Context.Services.Club.World.Contracts
	local pedestal=Instance.new("Part") pedestal.Name="Pedestal" pedestal.Size=Vector3.new(9,1,7) pedestal.CFrame=CFrame.new(position) pedestal.Color=Color3.fromRGB(25,31,42) pedestal.Material=Enum.Material.Metal pedestal.Anchored=true pedestal.Parent=model
	local card=Instance.new("Part") card.Name="Card" card.Size=Vector3.new(7,9,1) card.CFrame=pedestal.CFrame*CFrame.new(0,5,0) card.Color=Color3.fromRGB(16,20,29) card.Material=Enum.Material.SmoothPlastic card.Anchored=true card.CanCollide=false card.Parent=model model.PrimaryPart=pedestal
	local trim=Instance.new("Part") trim.Name="Rarity" trim.Size=Vector3.new(7.3,.5,1.25) trim.CFrame=card.CFrame*CFrame.new(0,4,0) trim.Color=rarity.Color trim.Material=Enum.Material.Neon trim.Anchored=true trim.CanCollide=false trim.Parent=model
	local gui=Instance.new("SurfaceGui") gui.Face=Enum.NormalId.Front gui.CanvasSize=Vector2.new(420,540) gui.Parent=card
	local label=Instance.new("TextLabel") label.Size=UDim2.fromScale(1,1) label.BackgroundTransparency=1 label.TextColor3=rarity.Color label.Font=Enum.Font.GothamBlack label.TextScaled=true label.TextWrapped=true
	label.Text=string.format("%s\n\n%s  •  %s\n%s\n\nSTEAL CONTRACT",string.upper(d.Name),d.Position,d.Country,d.Rarity) label.Parent=gui
	local prompt=Instance.new("ProximityPrompt") prompt.ActionText="Steal contract" prompt.ObjectText=d.Name prompt.MaxActivationDistance=self.Context.Config.Game.ContractPickupDistance prompt.HoldDuration=.2 prompt.RequiresLineOfSight=false prompt.Parent=pedestal
	prompt.Triggered:Connect(function(player) self:Pickup(player,record) end) record.Model=model record.Prompt=prompt return model
end

function Service:Spawn(zoneId,definitionId,position)
	local record={Id=self.Context.Services.PlayerData:NewId(),ZoneId=zoneId,DefinitionId=definitionId,State="AVAILABLE",Carrier=nil,PickupEnabledAt=0,OriginalPosition=position,DropToken=0}
	self.Contracts[record.Id]=record self:BuildModel(record,position) return record
end

function Service:ResetMarket()
	for id,record in pairs(self.Contracts) do if record.State=="AVAILABLE" or record.State=="DROPPED" then if record.Model then record.Model:Destroy() end self.Contracts[id]=nil end end
	for zoneId,zone in pairs(self.Context.Config.Zones) do
		local pool={} for id,d in pairs(self.Context.Config.Players) do if d.Zone==zoneId then table.insert(pool,id) end end
		for index,position in ipairs(zone.ContractSpawnPoints) do self:Spawn(zoneId,choose(self.Random,pool,self.Context.Config.Players),position+Vector3.new(0,index*.02,0)) end
	end
end

function Service:CarryMultiplier(definition)
	local c=self.Context.Config.Training return math.clamp(c.CarryBaseMultiplier-(definition.TransferWeight-1)*c.WeightPenalty,c.MinimumCarryMultiplier,1)
end

function Service:Pickup(player,record)
	if not player.Parent or self.Carried[player] or (record.State~="AVAILABLE" and record.State~="DROPPED") or os.clock()<record.PickupEnabledAt then return end
	local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart") local humanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	local profile=self.Context.Services.PlayerData:Get(player) local zone=self.Context.Config.Zones[record.ZoneId]
	if not root or not humanoid or humanoid.Health<=0 or not profile or profile.Speed<zone.RequiredSpeed or not record.Model or not record.Model.PrimaryPart then return end
	if (root.Position-record.Model.PrimaryPart.Position).Magnitude>self.Context.Config.Game.ContractPickupDistance+3 then return end
	if not self:SetState(record,"CARRIED") then return end
	record.Carrier=player record.DropToken+=1 self.Carried[player]=record record.Prompt.Enabled=false
	for _,o in ipairs(record.Model:GetDescendants()) do if o:IsA("BasePart") then o.CanCollide=false end end
	local d=self.Context.Config.Players[record.DefinitionId] local multiplier=self:CarryMultiplier(d)
	player:SetAttribute("CarriedContract",d.Name) player:SetAttribute("CarryMultiplier",multiplier) profile.Statistics.ContractsStolen+=1
	self.Context.Services.PlayerData:SetCharacterSpeed(player,multiplier) self.Context.Services.PlayerData:Push(player)
	self.Context.Services.Guardian:AddTarget(record.ZoneId,player) self.Context.Remotes.Notification:FireClient(player,"Run! "..zone.GuardianName.." is chasing you.","Warning")
end

function Service:ReturnDropped(record,token)
	task.delay(self.Context.Config.Game.DroppedReturnSeconds,function()
		if record.State=="DROPPED" and record.DropToken==token and record.Model and record.Model.Parent then
			self:SetState(record,"AVAILABLE") record.Model:PivotTo(CFrame.new(record.OriginalPosition)) record.Prompt.Enabled=true
			for _,o in ipairs(record.Model:GetDescendants()) do if o:IsA("BasePart") then o.CanCollide=o==record.Model.PrimaryPart end end
		end
	end)
end

function Service:Drop(player,reason)
	local record=self.Carried[player] if not record or record.State~="CARRIED" or not self:SetState(record,"DROPPED") then return false end
	local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart") local position=root and root.Position+root.CFrame.LookVector*4+Vector3.new(0,2,0) or record.OriginalPosition
	record.Model:PivotTo(CFrame.new(position)) record.Carrier=nil record.DropToken+=1 record.PickupEnabledAt=os.clock()+self.Context.Config.Game.ContractDropCooldown self.Carried[player]=nil
	player:SetAttribute("CarriedContract",nil) player:SetAttribute("CarryMultiplier",nil) self.Context.Services.PlayerData:SetCharacterSpeed(player) self.Context.Services.PlayerData:Push(player)
	self.Context.Services.Guardian:RemoveTarget(record.ZoneId,player)
	local token=record.DropToken task.delay(self.Context.Config.Game.ContractDropCooldown,function() if record.State=="DROPPED" and record.DropToken==token and record.Model then record.Prompt.Enabled=true end end)
	self:ReturnDropped(record,token) if player.Parent then self.Context.Remotes.Notification:FireClient(player,"Contract dropped: "..(reason or "intercepted"),"Warning") end return true
end

function Service:RollRating(d)
	local a=self.Random:NextNumber() local b=self.Random:NextNumber() local centered=(a+b)/2
	local rating=math.floor(d.RatingMin+(d.RatingMax-d.RatingMin)*centered+.5)
	if self.Random:NextNumber()<.025 then rating=math.min(99,rating+self.Random:NextInteger(2,5)) end return rating
end
function Service:RollEdition()
	local defs=self.Context.Config.Editions.Definitions local total=0 for _,e in pairs(defs) do total+=e.Weight end local roll=self.Random:NextNumber(0,total)
	for name,e in pairs(defs) do roll-=e.Weight if roll<=0 then return name end end return "Normal"
end

function Service:CompleteSigning(player,id)
	local pending=self.Context.Services.PlayerData:RemovePending(player,id) if not pending then return end local d=self.Context.Config.Players[pending.DefinitionId]
	local instance={InstanceId=self.Context.Services.PlayerData:NewId(),DefinitionId=pending.DefinitionId,Rating=pending.Rating,Potential=pending.Potential,Edition=pending.Edition,AcquiredAt=os.time(),OwnerUserId=player.UserId}
	instance.Income=self.Context.Services.Economy:CalculateInstanceIncome(instance) self.Context.Services.PlayerData:AddOwned(player,instance) self.Context.Services.Economy:Refresh(player)
	local profile=self.Context.Services.PlayerData:Get(player) if profile then self.Context.Services.Club:RenderLineup(player,profile) end
	self.Context.Remotes.Reveal:FireClient(player,{Name=d.Name,Country=d.Country,Position=d.Position,Rating=instance.Rating,Rarity=d.Rarity,Edition=instance.Edition,Income=instance.Income})
end
function Service:Schedule(player,pending) task.delay(math.max(0,pending.CompletesAt-os.time()),function() if player.Parent and self.Context.Services.PlayerData:Get(player) then self:CompleteSigning(player,pending.SigningId) end end) end

function Service:Deposit(player,record)
	if record~=self.Carried[player] or not self:SetState(record,"DEPOSITED") then return end self.Context.Services.Guardian:RemoveTarget(record.ZoneId,player) self.Carried[player]=nil
	player:SetAttribute("CarriedContract",nil) player:SetAttribute("CarryMultiplier",nil) self.Context.Services.PlayerData:SetCharacterSpeed(player)
	if record.Model then record.Model:Destroy() end record.Model=nil self.Contracts[record.Id]=nil self:SetState(record,"SIGNING")
	local d=self.Context.Config.Players[record.DefinitionId] local p=self.Context.Services.PlayerData:Get(player) local signingReduction=1-(p.Upgrades.SigningSpeed or 0)*self.Context.Config.Upgrades.SigningSpeedPerLevel
	local pending={SigningId=self.Context.Services.PlayerData:NewId(),DefinitionId=record.DefinitionId,Rating=self:RollRating(d),Potential=self.Random:NextInteger(1,10),Edition=self:RollEdition(),CompletesAt=os.time()+math.max(2,math.floor(d.SigningTime*signingReduction))}
	self.Context.Services.PlayerData:AddPending(player,pending) self.Context.Remotes.Notification:FireClient(player,"Signing "..d.Name.."…","Success") self:Schedule(player,pending)
end

function Service:Tick()
	for player,record in pairs(self.Carried) do
		local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart") local humanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if not player.Parent or not root or not humanoid or humanoid.Health<=0 then self:Drop(player,"carrier unavailable")
		else record.Model:PivotTo(root.CFrame*CFrame.new(0,1.8,3.4)) if self.Context.Services.Club:IsInOwnSafeZone(player,root.Position) then self:Deposit(player,record) end end
	end
end

function Service:BindPlayer(player)
	task.spawn(function() local profile=self.Context.Services.PlayerData:WaitForProfile(player,15) if not profile then return end for _,pending in ipairs(table.clone(profile.PendingSignings)) do self:Schedule(player,pending) end self.Context.Services.Club:RenderLineup(player,profile) end)
	local function bind(character) local humanoid=character:WaitForChild("Humanoid",10) if humanoid then humanoid.Died:Connect(function() self:Drop(player,"knocked out") end) end end
	player.CharacterAdded:Connect(bind) if player.Character then task.spawn(bind,player.Character) end
end
function Service:Init(context)
	self.Context=context Players.PlayerAdded:Connect(function(p) self:BindPlayer(p) end) Players.PlayerRemoving:Connect(function(p) self:Drop(p,"left server") end)
	for _,p in ipairs(Players:GetPlayers()) do self:BindPlayer(p) end RunService.Heartbeat:Connect(function() self:Tick() end)
end
return Service

local Players=game:GetService("Players")
local DataStoreService=game:GetService("DataStoreService")
local HttpService=game:GetService("HttpService")

local Service={Context=nil,Store=nil,Profiles={},Saving={},SessionId=HttpService:GenerateGUID(false)}
local function copy(value) if type(value)~="table" then return value end local result={} for k,v in pairs(value) do result[k]=copy(v) end return result end

function Service:DefaultProfile()
	return {SchemaVersion=self.Context.Config.Game.SchemaVersion,Money=self.Context.Config.Economy.StartingMoney,Speed=self.Context.Config.Training.BaseWalkSpeed,
		TrainingLevel=1,Boots="Basic",ClubLevel=1,SlotCount=self.Context.Config.Game.StartingSlots,OwnedPlayers={},ActiveLineup={},PendingSignings={},Album={},
		Upgrades={SigningSpeed=0,CashMultiplier=0},Settings={},Statistics={ContractsStolen=0,Tackles=0,MoneyEarned=0},
		Meta={SessionId="",LeaseExpires=0,Revision=0,LastSave=0}}
end

function Service:Reconcile(profile)
	local defaults=self:DefaultProfile() if type(profile)~="table" then return defaults end
	for k,v in pairs(defaults) do if profile[k]==nil or type(profile[k])~=type(v) then profile[k]=copy(v) end end
	for k,v in pairs(defaults.Upgrades) do if profile.Upgrades[k]==nil then profile.Upgrades[k]=v end end
	for k,v in pairs(defaults.Statistics) do if profile.Statistics[k]==nil then profile.Statistics[k]=v end end
	profile.SchemaVersion=defaults.SchemaVersion profile.Money=math.max(0,tonumber(profile.Money) or 0)
	profile.Speed=math.clamp(tonumber(profile.Speed) or defaults.Speed,defaults.Speed,self.Context.Config.Training.MaximumWalkSpeed)
	profile.SlotCount=math.clamp(tonumber(profile.SlotCount) or defaults.SlotCount,defaults.SlotCount,self.Context.Config.Game.MaximumSlots)
	return profile
end

function Service:Get(player) return self.Profiles[player] end
function Service:WaitForProfile(player,timeout) local deadline=os.clock()+(timeout or 12) repeat if self.Profiles[player] then return self.Profiles[player] end task.wait() until os.clock()>deadline or not player.Parent end
function Service:NewId() return HttpService:GenerateGUID(false) end

function Service:GetSnapshot(player)
	local profile=self:Get(player) if not profile then return nil end
	local pending=profile.PendingSignings[1] local pendingDef=pending and self.Context.Config.Players[pending.DefinitionId]
	return {Money=profile.Money,Speed=profile.Speed,TrainingLevel=profile.TrainingLevel,Boots=profile.Boots,ClubLevel=profile.ClubLevel,SlotCount=profile.SlotCount,
		OwnedCount=#profile.OwnedPlayers,IncomePerSecond=player:GetAttribute("IncomePerSecond") or 0,CarriedContract=player:GetAttribute("CarriedContract") or "",
		CurrentZone=player:GetAttribute("CurrentZone") or "Club",Training=player:GetAttribute("Training") == true,Album=copy(profile.Album),
		SigningName=pendingDef and pendingDef.Name or "",SigningEndsAt=pending and pending.CompletesAt or 0,Upgrades=copy(profile.Upgrades)}
end

function Service:Push(player,extra)
	if not player.Parent then return end local snapshot=self:GetSnapshot(player) if not snapshot then return end
	for k,v in pairs(extra or {}) do snapshot[k]=v end self.Context.Remotes.StateUpdate:FireClient(player,snapshot)
	local stats=player:FindFirstChild("leaderstats") if stats then stats.Money.Value=math.floor(snapshot.Money) stats.Speed.Value=math.floor(snapshot.Speed*10+.5)/10 end
end

function Service:SetCharacterSpeed(player,multiplier)
	local profile=self:Get(player) local humanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if profile and humanoid then humanoid.WalkSpeed=profile.Speed*(multiplier or 1) end
end
function Service:AddMoney(player,amount)
	local p=self:Get(player) if not p or type(amount)~="number" or amount<=0 then return false end
	p.Money+=amount p.Statistics.MoneyEarned+=amount self:Push(player) return true
end
function Service:Spend(player,amount)
	local p=self:Get(player) if not p or type(amount)~="number" or amount<0 or p.Money<amount then return false end
	p.Money-=amount self:Push(player) return true
end
function Service:SetSpeed(player,value)
	local p=self:Get(player) if not p then return end p.Speed=math.clamp(value,self.Context.Config.Training.BaseWalkSpeed,self.Context.Config.Training.MaximumWalkSpeed)
	self:SetCharacterSpeed(player,player:GetAttribute("CarryMultiplier") or 1) self:Push(player)
end
function Service:AddPending(player,pending) local p=self:Get(player) if not p then return false end table.insert(p.PendingSignings,pending) self:Push(player) return true end
function Service:RemovePending(player,id) local p=self:Get(player) if not p then return end for i,v in ipairs(p.PendingSignings) do if v.SigningId==id then return table.remove(p.PendingSignings,i) end end end
function Service:AddOwned(player,instance)
	local p=self:Get(player) if not p then return false end table.insert(p.OwnedPlayers,instance) p.Album[instance.DefinitionId]=true
	if #p.ActiveLineup<p.SlotCount then table.insert(p.ActiveLineup,instance.InstanceId) end self:Push(player) return true
end

function Service:Save(player,release)
	local profile=self:Get(player) if not profile or self.Saving[player] then return true end self.Saving[player]=true local payload=copy(profile)
	payload.Meta.SessionId=release and "" or self.SessionId payload.Meta.LeaseExpires=release and 0 or os.time()+120 payload.Meta.Revision=(payload.Meta.Revision or 0)+1 payload.Meta.LastSave=os.time()
	local success,message=pcall(function() self.Store:UpdateAsync("player_"..player.UserId,function(current)
		if type(current)=="table" and current.Meta and current.Meta.SessionId~="" and current.Meta.SessionId~=self.SessionId and (current.Meta.LeaseExpires or 0)>os.time() then return current end
		return payload
	end) end)
	if success then profile.Meta=payload.Meta end
	self.Saving[player]=nil if not success then warn("[Transfer Rivals] save failed",player.Name,message) end return success
end
function Service:Load(player)
	local loaded,acquired local success,message=pcall(function() loaded=self.Store:UpdateAsync("player_"..player.UserId,function(current)
		current=type(current)=="table" and current or self:DefaultProfile() local meta=current.Meta or {}
		if meta.SessionId and meta.SessionId~="" and meta.SessionId~=self.SessionId and (meta.LeaseExpires or 0)>os.time() then acquired=false return current end
		acquired=true current.Meta={SessionId=self.SessionId,LeaseExpires=os.time()+120,Revision=meta.Revision or 0,LastSave=meta.LastSave or 0} return current
	end) end)
	if not success then warn("[Transfer Rivals] session-only data",player.Name,message) end if not player.Parent then return end
	if success and acquired==false then player:Kick("Your club data is already open in another server. Try again in two minutes.") return end
	local profile=self:Reconcile(loaded) self.Profiles[player]=profile
	local stats=Instance.new("Folder") stats.Name="leaderstats" stats.Parent=player
	local money=Instance.new("IntValue") money.Name="Money" money.Parent=stats
	local speed=Instance.new("NumberValue") speed.Name="Speed" speed.Parent=stats
	player:SetAttribute("ProfileLoaded",true)
	local function apply(character) local humanoid=character:WaitForChild("Humanoid",10) if humanoid then humanoid.WalkSpeed=profile.Speed end end
	player.CharacterAdded:Connect(apply) if player.Character then task.spawn(apply,player.Character) end self:Push(player)
end

function Service:Init(context)
	self.Context=context self.Store=DataStoreService:GetDataStore(context.Config.Game.DataStoreName)
	Players.PlayerAdded:Connect(function(player) task.spawn(function() self:Load(player) end) end)
	Players.PlayerRemoving:Connect(function(player) self:Save(player,true) self.Profiles[player]=nil end)
	for _,player in ipairs(Players:GetPlayers()) do task.spawn(function() self:Load(player) end) end
	task.spawn(function() while task.wait(context.Config.Game.AutosaveSeconds) do for player in pairs(self.Profiles) do task.spawn(function() self:Save(player) end) end end end)
	game:BindToClose(function() for player in pairs(self.Profiles) do self:Save(player,true) end end)
end
return Service

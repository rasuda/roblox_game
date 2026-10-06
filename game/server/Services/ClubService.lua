local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local ClubService = {Context=nil,World=nil,Clubs={},PlayerClubs={},LastZoneNotice={}}
local BASE_X = {-300,-180,-60,60,180,300}
local BASE_COLORS = {
	Color3.fromRGB(46,135,222),Color3.fromRGB(222,71,68),Color3.fromRGB(64,184,113),
	Color3.fromRGB(224,154,45),Color3.fromRGB(154,81,219),Color3.fromRGB(45,190,201),
}

local function part(parent,name,size,position,color,material,collide,transparency)
	local p=Instance.new("Part") p.Name=name p.Size=size p.Position=position p.Color=color
	p.Material=material or Enum.Material.SmoothPlastic p.Anchored=true p.CanCollide=collide~=false
	p.Transparency=transparency or 0 p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent
	return p
end

local function billboard(adornee,text,color,size,offset)
	local gui=Instance.new("BillboardGui") gui.Name="Display" gui.Size=size or UDim2.fromOffset(280,80)
	gui.StudsOffset=offset or Vector3.new(0,5,0) gui.AlwaysOnTop=true gui.Parent=adornee
	local label=Instance.new("TextLabel") label.Size=UDim2.fromScale(1,1) label.BackgroundColor3=Color3.fromRGB(13,18,28)
	label.BackgroundTransparency=.08 label.TextColor3=color or Color3.new(1,1,1) label.Font=Enum.Font.GothamBlack
	label.TextScaled=true label.TextWrapped=true label.Text=text label.Parent=gui
	local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,10) c.Parent=label
	return label
end

local function inside(position,object,padding)
	local localPosition=object.CFrame:PointToObjectSpace(position)
	local half=object.Size/2+Vector3.new(padding or 0,padding or 0,padding or 0)
	return math.abs(localPosition.X)<=half.X and math.abs(localPosition.Y)<=half.Y and math.abs(localPosition.Z)<=half.Z
end

function ClubService:BuildWorld()
	local old=Workspace:FindFirstChild("FootballTransferWorld") if old then old:Destroy() end
	local world=Instance.new("Model") world.Name="FootballTransferWorld" world.Parent=Workspace self.World=world
	part(world,"Ground",Vector3.new(820,2,1120),Vector3.new(0,-1,-240),Color3.fromRGB(43,55,48),Enum.Material.Grass,true)
	part(world,"MainRoad",Vector3.new(90,.3,1030),Vector3.new(0,.15,-250),Color3.fromRGB(50,53,57),Enum.Material.Asphalt,true)

	local contracts=Instance.new("Folder") contracts.Name="Contracts" contracts.Parent=world
	local guardians=Instance.new("Folder") guardians.Name="Guardians" guardians.Parent=world
	local zonesFolder=Instance.new("Folder") zonesFolder.Name="Zones" zonesFolder.Parent=world
	local order={"Street","Academy","National","World"}
	for _,zoneId in ipairs(order) do
		local zone=self.Context.Config.Zones[zoneId]
		local floor=part(zonesFolder,zoneId.."Floor",zone.Size,zone.Center-Vector3.new(0,.45,0),zone.Color,Enum.Material.Asphalt,true)
		floor:SetAttribute("ZoneId",zoneId)
		local sign=part(zonesFolder,zoneId.."Sign",Vector3.new(90,15,2),zone.Center+Vector3.new(0,9,-82),Color3.fromRGB(17,22,32),Enum.Material.Metal,true)
		billboard(sign,string.format("%s\nSPEED %d+",zone.DisplayName,zone.RequiredSpeed),Color3.fromRGB(242,211,79),UDim2.fromOffset(380,100))
		if zone.Order>1 then
			local gate=part(zonesFolder,zoneId.."Gate",Vector3.new(700,12,3),zone.Center+Vector3.new(0,6,90),zone.Color,Enum.Material.ForceField,false,.72)
			billboard(gate,"REQUIRES SPEED "..zone.RequiredSpeed,Color3.new(1,1,1),UDim2.fromOffset(310,60),Vector3.new(0,3,0))
		end
	end

	for index,x in ipairs(BASE_X) do
		local center=Vector3.new(x,0,165)
		local color=BASE_COLORS[index]
		local model=Instance.new("Model") model.Name="Club"..index model:SetAttribute("OwnerUserId",0) model.Parent=world
		part(model,"ClubFloor",Vector3.new(108,.5,106),center+Vector3.new(0,.25,0),Color3.fromRGB(43,125,61),Enum.Material.Grass,true)
		local safe=part(model,"SafeZone",Vector3.new(106,20,102),center+Vector3.new(0,10,0),color,Enum.Material.ForceField,false,.9)
		local spawn=part(model,"SpawnPad",Vector3.new(9,.5,9),center+Vector3.new(0,.3,39),color,Enum.Material.Neon,true)
		local training=part(model,"Training",Vector3.new(38,.35,21),center+Vector3.new(-28,.35,11),Color3.fromRGB(243,165,42),Enum.Material.Neon,true)
		billboard(training,"SPRINT TRAINING",Color3.fromRGB(255,225,119),UDim2.fromOffset(210,50))
		local deposit=part(model,"Deposit",Vector3.new(38,.35,21),center+Vector3.new(28,.35,11),Color3.fromRGB(56,226,135),Enum.Material.Neon,true)
		billboard(deposit,"SIGN CONTRACT",Color3.fromRGB(118,255,178),UDim2.fromOffset(210,50))
		local sign=part(model,"ClubSign",Vector3.new(38,10,2),center+Vector3.new(0,6,-49),color,Enum.Material.Metal,true)
		local signLabel=billboard(sign,"AVAILABLE CLUB",Color3.new(1,1,1),UDim2.fromOffset(300,78))

		local kiosks={}
		for kioskIndex,info in ipairs({{"TrainingUpgrade",-42,"TRAIN"},{"BootsUpgrade",-21,"BOOTS"},{"SlotsUpgrade",0,"SLOTS"},{"SigningUpgrade",21,"SIGNING"},{"CashUpgrade",42,"CASH"}}) do
			local kiosk=part(model,info[1],Vector3.new(12,7,9),center+Vector3.new(info[2],3.5,-36),color,Enum.Material.Metal,true)
			local prompt=Instance.new("ProximityPrompt") prompt.Name=info[1].."Prompt" prompt.ActionText="Upgrade"
			prompt.ObjectText=info[3] prompt.MaxActivationDistance=13 prompt.HoldDuration=.15 prompt.RequiresLineOfSight=false prompt.Parent=kiosk
			kiosks[info[1]]=prompt
		end

		local slots=Instance.new("Folder") slots.Name="LineupSlots" slots.Parent=model
		for slotIndex=1,20 do
			local row=math.floor((slotIndex-1)/5) local column=(slotIndex-1)%5
			local slot=part(slots,"Slot"..slotIndex,Vector3.new(16,.35,9),center+Vector3.new((column-2)*19,.45,-17+row*10),Color3.fromRGB(27,33,43),Enum.Material.Metal,true)
			slot:SetAttribute("SlotIndex",slotIndex)
		end
		self.Clubs[index]={Index=index,Model=model,Center=center,Safe=safe,Spawn=spawn,Training=training,Deposit=deposit,SignLabel=signLabel,Kiosks=kiosks,Owner=nil}
	end
end

function ClubService:GetClub(player) return self.PlayerClubs[player] end
function ClubService:IsInAnySafeZone(position) for _,club in ipairs(self.Clubs) do if inside(position,club.Safe,2) then return true end end return false end
function ClubService:IsInOwnSafeZone(player,position) local club=self:GetClub(player) return club and inside(position,club.Safe,2) or false end
function ClubService:GetZoneAt(position)
	for id,zone in pairs(self.Context.Config.Zones) do
		if math.abs(position.X-zone.Center.X)<=zone.Size.X/2 and math.abs(position.Z-zone.Center.Z)<=zone.Size.Z/2 then return id,zone end
	end
	return "Club",nil
end

function ClubService:Assign(player)
	if self.PlayerClubs[player] then return self.PlayerClubs[player] end
	for _,club in ipairs(self.Clubs) do if not club.Owner then
		club.Owner=player club.Model:SetAttribute("OwnerUserId",player.UserId) club.SignLabel.Text="CLUB OF "..string.upper(player.DisplayName)
		self.PlayerClubs[player]=club player:SetAttribute("ClubIndex",club.Index)
		local function place(character) local root=character:WaitForChild("HumanoidRootPart",10) if root then character:PivotTo(CFrame.new(club.Spawn.Position+Vector3.new(0,4,0),Vector3.new(0,3,-80))) end end
		player.CharacterAdded:Connect(place) if player.Character then task.spawn(place,player.Character) end return club
	end end
	player:Kick("This test server supports six clubs.")
end

function ClubService:Release(player)
	local club=self.PlayerClubs[player] if not club then return end
	club.Owner=nil club.Model:SetAttribute("OwnerUserId",0) club.SignLabel.Text="AVAILABLE CLUB" self.PlayerClubs[player]=nil
end

function ClubService:RenderLineup(player,profile)
	local club=self:GetClub(player) if not club then return end
	local ownedById={} for _,owned in ipairs(profile.OwnedPlayers) do ownedById[owned.InstanceId]=owned end
	for _,slot in ipairs(club.Model.LineupSlots:GetChildren()) do
		local old=slot:FindFirstChild("Footballer") if old then old:Destroy() end
		local index=slot:GetAttribute("SlotIndex") local instanceId=profile.ActiveLineup[index] local owned=instanceId and ownedById[instanceId]
		if owned and index<=profile.SlotCount then
			local definition=self.Context.Config.Players[owned.DefinitionId] local rarity=self.Context.Config.Rarity.Definitions[definition.Rarity]
			local display=Instance.new("Model") display.Name="Footballer" display.Parent=slot
			local body=part(display,"Body",Vector3.new(2.5,4,1.6),slot.Position+Vector3.new(0,2.5,0),rarity.Color,Enum.Material.SmoothPlastic,false)
			part(display,"Head",Vector3.new(2,2,2),slot.Position+Vector3.new(0,5.3,0),Color3.fromRGB(204,157,117),Enum.Material.SmoothPlastic,false)
			billboard(body,string.format("%s\n%d %s • $%.1f/s",definition.Name,owned.Rating,owned.Edition,owned.Income or 0),rarity.Color,UDim2.fromOffset(185,82),Vector3.new(0,4.7,0))
		end
	end
end

function ClubService:EnforceZones()
	for _,player in ipairs(Players:GetPlayers()) do
		local profile=self.Context.Services.PlayerData:Get(player) local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if profile and root then
			local zoneId,zone=self:GetZoneAt(root.Position) player:SetAttribute("CurrentZone",zoneId)
			if zone and profile.Speed+0.01<zone.RequiredSpeed then
				local now=os.clock() if now-(self.LastZoneNotice[player] or 0)>2 then self.LastZoneNotice[player]=now self.Context.Remotes.Notification:FireClient(player,"You need Speed "..zone.RequiredSpeed.." to enter "..zone.DisplayName..".","Warning") end
				root.AssemblyLinearVelocity=Vector3.zero root.CFrame=CFrame.new(root.Position.X,4,zone.Center.Z+zone.Size.Z/2+12)
			end
		end
	end
end

function ClubService:Init(context)
	self.Context=context self:BuildWorld()
	Players.PlayerAdded:Connect(function(player) self:Assign(player) end)
	Players.PlayerRemoving:Connect(function(player) self.LastZoneNotice[player]=nil self:Release(player) end)
	for _,player in ipairs(Players:GetPlayers()) do self:Assign(player) end
	local elapsed=0 RunService.Heartbeat:Connect(function(dt) elapsed+=dt if elapsed>=.25 then self:EnforceZones() elapsed=0 end end)
end

return ClubService

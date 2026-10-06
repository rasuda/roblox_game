local RunService=game:GetService("RunService")
local Service={Context=nil,Guardians={}}
local function part(parent,name,size,cframe,color)
	local p=Instance.new("Part") p.Name=name p.Size=size p.CFrame=cframe p.Color=color p.Material=Enum.Material.SmoothPlastic p.Anchored=true p.CanCollide=false p.Parent=parent return p
end
local function label(root,text)
	local gui=Instance.new("BillboardGui") gui.Size=UDim2.fromOffset(210,58) gui.StudsOffset=Vector3.new(0,7,0) gui.AlwaysOnTop=true gui.Parent=root
	local l=Instance.new("TextLabel") l.Size=UDim2.fromScale(1,1) l.BackgroundColor3=Color3.fromRGB(15,20,29) l.BackgroundTransparency=.12 l.TextColor3=Color3.fromRGB(255,198,55) l.Font=Enum.Font.GothamBlack l.TextScaled=true l.Text=text l.Parent=gui
end
function Service:Build(zoneId,zone)
	local model=Instance.new("Model") model.Name=zoneId.."Guardian" model:SetAttribute("State","IDLE") model.Parent=self.Context.Services.Club.World.Guardians
	local root=part(model,"Root",Vector3.new(4.5,6,3.2),CFrame.new(zone.GuardianSpawn),zone.Color)
	part(model,"Head",Vector3.new(3.5,3.5,3.5),CFrame.new(zone.GuardianSpawn+Vector3.new(0,4.8,0)),Color3.fromRGB(201,154,115))
	part(model,"Vest",Vector3.new(4.8,2.2,3.5),CFrame.new(zone.GuardianSpawn+Vector3.new(0,1.1,0)),Color3.fromRGB(244,172,42)) model.PrimaryPart=root label(root,zone.GuardianName)
	self.Guardians[zoneId]={ZoneId=zoneId,Config=zone,Model=model,Home=zone.GuardianSpawn,Targets={},AlertUntil=0,State="IDLE"}
end
function Service:SetState(g,state) g.State=state g.Model:SetAttribute("State",state) end
function Service:AddTarget(zoneId,player) local g=self.Guardians[zoneId] if g then g.Targets[player]=true g.AlertUntil=os.clock()+.45 self:SetState(g,"ALERT") end end
function Service:RemoveTarget(zoneId,player) local g=self.Guardians[zoneId] if g then g.Targets[player]=nil end end
function Service:Nearest(g,position)
	local best,distance for player in pairs(g.Targets) do local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart") local humanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if not player.Parent or not root or not humanoid or humanoid.Health<=0 or self.Context.Services.Club:IsInAnySafeZone(root.Position) then g.Targets[player]=nil
		else local d=(root.Position-position).Magnitude if not distance or d<distance then best,distance=player,d end end end return best,distance
end
function Service:Move(g,target,speed,dt)
	local current=g.Model:GetPivot().Position local flat=Vector3.new(target.X,g.Home.Y,target.Z) local delta=flat-current if delta.Magnitude<.05 then return true end
	local amount=math.min(delta.Magnitude,speed*dt) local nextPosition=current+delta.Unit*amount g.Model:PivotTo(CFrame.lookAt(nextPosition,flat)) return delta.Magnitude<=amount+.1
end
function Service:TickGuardian(g,dt)
	local current=g.Model:GetPivot().Position local target,distance=self:Nearest(g,current)
	if target then if os.clock()<g.AlertUntil then return end self:SetState(g,"CHASE") local root=target.Character and target.Character:FindFirstChild("HumanoidRootPart") if not root then return end
		if distance and distance<=self.Context.Config.Game.GuardianHitRadius then self:SetState(g,"ATTACK") self.Context.Services.Contracts:Drop(target,g.Config.GuardianName)
			local away=root.Position-current if away.Magnitude<.05 then away=root.CFrame.LookVector else away=away.Unit end root.AssemblyLinearVelocity+=away*36+Vector3.new(0,17,0) g.Targets[target]=nil return end
		self:Move(g,root.Position,g.Config.GuardianSpeed,dt)
	elseif (current-g.Home).Magnitude>1 then self:SetState(g,"RETURN") if self:Move(g,g.Home,g.Config.GuardianSpeed*.9,dt) then self:SetState(g,"IDLE") end else self:SetState(g,"IDLE") end
end
function Service:Init(context)
	self.Context=context for id,zone in pairs(context.Config.Zones) do self:Build(id,zone) end
	local acc=0 RunService.Heartbeat:Connect(function(dt) acc+=dt if acc>=context.Config.Game.GuardianTickSeconds then for _,g in pairs(self.Guardians) do self:TickGuardian(g,acc) end acc=0 end end)
end
return Service

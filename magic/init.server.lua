local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Config=require(script.Config)
local Store=require(script.ProfileStore)
local Visual=require(script.CreatureVisual)
local map=workspace:WaitForChild("FootballTerrain")
while not map:GetAttribute("Ready") do map:GetAttributeChangedSignal("Ready"):Wait() end
local floor=map:WaitForChild("SPACEFloor")
local origin=CFrame.new(floor.Position+Vector3.new(0,2.2,0))
local state="AVAILABLE"
local wild,carrier,prompt
local displays,registered,ticks,lastPositions={},{},{},{}
local closing=false

local function baseOf(player)
 local name=player:GetAttribute("BaseName")
 local base=name and map:FindFirstChild(name)
 if base and base:GetAttribute("OwnerUserId")==player.UserId then return base end
end
local function aliveRoot(player)
 local character=player.Character
 local humanoid=character and character:FindFirstChildOfClass("Humanoid")
 return humanoid and humanoid.Health>0 and character:FindFirstChild("HumanoidRootPart") or nil
end
local function clearCarry(player)
 if carrier~=player then return end
 carrier=nil player:SetAttribute("CarryingCreature",false)
 if wild then wild:Destroy() wild=nil end
 state="RESPAWNING"
end
local spawnWild
local function resetCarry(player)
 if carrier~=player then return end
 clearCarry(player)
 task.delay(1,function() if not closing and state=="RESPAWNING" then spawnWild() end end)
end

spawnWild=function()
 if closing then return end
 if wild then wild:Destroy() end
 wild=Visual.Create(map,origin)
 wild:SetAttribute("State","AVAILABLE") state="AVAILABLE"
 prompt=Instance.new("ProximityPrompt") prompt.ActionText="Pegar"
 prompt.ObjectText=Config.CreatureName.." • 100 ouro/s"
 prompt.HoldDuration=.4 prompt.MaxActivationDistance=Config.PickupDistance
 prompt.RequiresLineOfSight=true prompt.Parent=wild.PrimaryPart
 prompt.Triggered:Connect(function(player)
  local profile=Store.Get(player)
  local root=aliveRoot(player)
  if closing or state~="AVAILABLE" or not profile or not root or not baseOf(player) then return end
  if profile.HasCreature then
   player:SetAttribute("CreatureHint","Seu Pelúcio já está produzindo ouro no castelo.") return
  end
  if (root.Position-wild.PrimaryPart.Position).Magnitude>Config.PickupDistance+2 then return end
  -- No yield between checking availability and reserving the creature.
  state="CARRIED" carrier=player prompt.Enabled=false
  wild:SetAttribute("State",state)
  player:SetAttribute("CarryingCreature",true)
  player:SetAttribute("CreatureHint","Leve o Pelúcio para dentro do seu castelo.")
  lastPositions[player]=root.Position
  Visual.Carry(wild,root)
 end)
end

local function display(player,base)
 local current=displays[player]
 if current and current.Parent==base then return end
 if current then current:Destroy() end
 local foundation=base:FindFirstChild("Foundation")
 if not foundation then return end
 local model=Visual.Create(base,foundation.CFrame*CFrame.new(-6,2.5,3))
 model.Name="OwnedCreature" model:SetAttribute("OwnerUserId",player.UserId)
 local gui=Instance.new("BillboardGui") gui.Size=UDim2.fromOffset(140,36)
 gui.StudsOffset=Vector3.new(0,4,0) gui.MaxDistance=55 gui.Parent=model.PrimaryPart
 local text=Instance.new("TextLabel") text.Size=UDim2.fromScale(1,1)
 text.BackgroundTransparency=.3 text.BackgroundColor3=Color3.fromRGB(32,25,42)
 text.TextColor3=Color3.fromRGB(255,212,78) text.TextSize=14 text.Font=Enum.Font.GothamBold
 text.Text="Pelúcio\n+100 ouro/s" text.Parent=gui
 displays[player]=model
end

local function deposit(player,base)
 local profile=Store.Get(player)
 if not profile or profile.HasCreature or carrier~=player then return end
 profile.HasCreature=true
 clearCarry(player)
 Store.Publish(player) ticks[player]=0
 display(player,base)
 player:SetAttribute("CreatureHint","Pelúcio instalado! +100 moedas de ouro por segundo.")
 task.spawn(Store.Save,player,false)
 task.delay(Config.RespawnSeconds,function()
  if not closing and state=="RESPAWNING" then spawnWild() end
 end)
end

local function joined(player)
 if registered[player] then return end
 local connections={}
 registered[player]=connections
 player:SetAttribute("Gold",0) player:SetAttribute("IncomePerSecond",0)
 player:SetAttribute("DataReady",false) player:SetAttribute("CarryingCreature",false)
 player:SetAttribute("CreatureHint","Busque um Pelúcio na última área preta.")
 table.insert(connections,player.CharacterRemoving:Connect(function() resetCarry(player) end))
 local profile=Store.Load(player)
 if not profile then return end
 if closing or player.Parent~=Players then Store.Save(player,true) return end
 ticks[player]=0
end

Players.PlayerAdded:Connect(function(player) task.spawn(joined,player) end)
Players.PlayerRemoving:Connect(function(player)
 resetCarry(player)
 local connections=registered[player]
 if connections then for _,connection in ipairs(connections) do connection:Disconnect() end end
 registered[player]=nil ticks[player]=nil lastPositions[player]=nil
 if displays[player] then displays[player]:Destroy() displays[player]=nil end
 Store.Save(player,true)
end)
for _,player in ipairs(Players:GetPlayers()) do task.spawn(joined,player) end
spawnWild()

local elapsed=0
RunService.Heartbeat:Connect(function(dt)
 elapsed=elapsed+dt
 if elapsed<.25 or closing then return end
 local interval=elapsed elapsed=0
 for _,player in ipairs(Players:GetPlayers()) do
  local profile=Store.Get(player)
  local base=baseOf(player)
  local root=aliveRoot(player)
  if carrier==player then
   if not profile or not base or not root then resetCarry(player)
   else
    local previous=lastPositions[player]
    lastPositions[player]=root.Position
    -- Reject implausible carry teleports; ordinary walking/jumping is unaffected.
    if previous and (root.Position-previous).Magnitude>40*interval+12 then resetCarry(player)
    else
     local localPosition=base.Foundation.CFrame:PointToObjectSpace(root.Position)
     if math.abs(localPosition.X)<12 and math.abs(localPosition.Z)<9 and localPosition.Y>0 and localPosition.Y<8 then
      deposit(player,base)
     end
    end
   end
  end
  local active=profile and profile.HasCreature and base
  player:SetAttribute("IncomePerSecond",active and Config.IncomePerSecond or 0)
  if active then
   display(player,base)
   ticks[player]=(ticks[player] or 0)+interval
   local seconds=math.floor(ticks[player])
   if seconds>0 then
    ticks[player]=ticks[player]-seconds
    profile.Gold=profile.Gold+seconds*Config.IncomePerSecond
    Store.Publish(player)
   end
  else ticks[player]=0 end
 end
end)

task.spawn(function()
 while not closing do
  task.wait(Config.AutosaveSeconds)
  if not closing then
   for _,player in ipairs(Players:GetPlayers()) do task.spawn(Store.Save,player,false) end
  end
 end
end)
game:BindToClose(function()
 closing=true
 local pending=0
 for _,player in ipairs(Players:GetPlayers()) do
  pending=pending+1
  task.spawn(function() Store.Save(player,true) pending=pending-1 end)
 end
 local deadline=os.clock()+25
 while pending>0 and os.clock()<deadline do task.wait(.1) end
end)

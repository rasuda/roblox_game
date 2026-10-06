local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local ContextActionService=game:GetService("ContextActionService")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer local root=ReplicatedStorage:WaitForChild("TransferGame") local remotes=root:WaitForChild("Remotes")
local definitions=require(root.Config.PlayerDefinitions) local zones=require(root.Config.ZoneConfig) local rarities=require(root.Config.RarityConfig)
local state={Money=0,IncomePerSecond=0,Speed=16,OwnedCount=0,SlotCount=6,CarriedContract="",CurrentZone="Club",Training=false,Album={},SigningEndsAt=0,Boots="Basic"}
local transferTime=0

local gui=Instance.new("ScreenGui") gui.Name="TransferRivalsUI" gui.ResetOnSpawn=false gui.Parent=player:WaitForChild("PlayerGui")
local function corner(o,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 12) c.Parent=o end
local function stroke(o,color,t) local s=Instance.new("UIStroke") s.Color=color or Color3.fromRGB(85,103,134) s.Thickness=t or 1 s.Transparency=.2 s.Parent=o end
local function text(parent,name,pos,size,fontSize,align)
	local l=Instance.new("TextLabel") l.Name=name l.Position=pos l.Size=size l.BackgroundTransparency=1 l.Font=Enum.Font.GothamBold l.TextColor3=Color3.new(1,1,1) l.TextSize=fontSize or 18 l.TextXAlignment=align or Enum.TextXAlignment.Left l.Text="" l.Parent=parent return l
end
local function panel(name,pos,size)
	local f=Instance.new("Frame") f.Name=name f.Position=pos f.Size=size f.BackgroundColor3=Color3.fromRGB(12,18,28) f.BackgroundTransparency=.08 f.Parent=gui corner(f,14) stroke(f,Color3.fromRGB(75,207,133),2) return f
end
local function money(value) value=value or 0 if value>=1e12 then return string.format("$%.2fT",value/1e12) elseif value>=1e9 then return string.format("$%.2fB",value/1e9) elseif value>=1e6 then return string.format("$%.2fM",value/1e6) elseif value>=1e3 then return string.format("$%.1fK",value/1e3) end return "$"..math.floor(value) end

local stats=panel("Stats",UDim2.fromScale(.06,.025),UDim2.new(.72,0,0,64))
local moneyLabel=text(stats,"Money",UDim2.fromScale(.03,0),UDim2.fromScale(.3,1),18)
local incomeLabel=text(stats,"Income",UDim2.fromScale(.34,0),UDim2.fromScale(.3,1),17,Enum.TextXAlignment.Center)
local speedLabel=text(stats,"Speed",UDim2.fromScale(.66,0),UDim2.fromScale(.31,1),18,Enum.TextXAlignment.Right)
local albumButton=Instance.new("TextButton") albumButton.AnchorPoint=Vector2.new(1,0) albumButton.Position=UDim2.fromScale(.97,.025) albumButton.Size=UDim2.fromOffset(118,64) albumButton.BackgroundColor3=Color3.fromRGB(39,91,164) albumButton.Font=Enum.Font.GothamBlack albumButton.Text="ALBUM" albumButton.TextColor3=Color3.new(1,1,1) albumButton.TextSize=17 albumButton.Parent=gui corner(albumButton,14)

local objective=panel("Objective",UDim2.fromScale(.08,.125),UDim2.new(.84,0,0,58)) objective.AnchorPoint=Vector2.new(0,0)
local objectiveText=text(objective,"Text",UDim2.fromScale(.03,0),UDim2.fromScale(.94,1),17,Enum.TextXAlignment.Center) objectiveText.TextWrapped=true objectiveText.TextColor3=Color3.fromRGB(252,214,82)
local market=panel("Market",UDim2.fromScale(.755,.225),UDim2.new(.22,0,0,62))
local marketText=text(market,"Text",UDim2.fromScale(.04,0),UDim2.fromScale(.92,1),15,Enum.TextXAlignment.Center) marketText.TextWrapped=true marketText.TextColor3=Color3.fromRGB(108,202,255)
local zonePanel=panel("Zone",UDim2.fromScale(.025,.225),UDim2.new(.29,0,0,62))
local zoneText=text(zonePanel,"Text",UDim2.fromScale(.04,0),UDim2.fromScale(.92,1),15,Enum.TextXAlignment.Center) zoneText.TextWrapped=true

local training=panel("Training",UDim2.fromScale(.025,.48),UDim2.new(.27,0,0,56)) training.Visible=false training.BackgroundColor3=Color3.fromRGB(180,112,31)
local trainingText=text(training,"Text",UDim2.fromScale(.04,0),UDim2.fromScale(.92,1),16,Enum.TextXAlignment.Center) trainingText.Text="TRAINING SPEED"
local tackle=Instance.new("TextButton") tackle.Name="SlideTackle" tackle.AnchorPoint=Vector2.new(1,1) tackle.Position=UDim2.fromScale(.97,.95) tackle.Size=UDim2.fromOffset(126,126) tackle.BackgroundColor3=Color3.fromRGB(225,61,62) tackle.Font=Enum.Font.GothamBlack tackle.Text="SLIDE\nTACKLE" tackle.TextColor3=Color3.new(1,1,1) tackle.TextSize=18 tackle.Parent=gui corner(tackle,63) stroke(tackle,Color3.fromRGB(255,196,70),3)

local toast=panel("Toast",UDim2.fromScale(.15,.76),UDim2.new(.7,0,0,58)) toast.Visible=false
local toastText=text(toast,"Text",UDim2.fromScale(.03,0),UDim2.fromScale(.94,1),17,Enum.TextXAlignment.Center) toastText.TextWrapped=true

local modal=panel("Reveal",UDim2.fromScale(.14,.22),UDim2.new(.72,0,.58,0)) modal.Visible=false stroke(modal,Color3.fromRGB(244,194,51),4)
local revealTitle=text(modal,"Title",UDim2.fromScale(.06,.06),UDim2.fromScale(.88,.22),28,Enum.TextXAlignment.Center) revealTitle.TextColor3=Color3.fromRGB(255,212,62)
local revealBody=text(modal,"Body",UDim2.fromScale(.08,.28),UDim2.fromScale(.84,.48),21,Enum.TextXAlignment.Center) revealBody.TextWrapped=true
local close=Instance.new("TextButton") close.AnchorPoint=Vector2.new(.5,1) close.Position=UDim2.fromScale(.5,.94) close.Size=UDim2.new(.55,0,0,50) close.BackgroundColor3=Color3.fromRGB(49,180,103) close.Font=Enum.Font.GothamBlack close.Text="CONTINUE" close.TextColor3=Color3.new(1,1,1) close.TextSize=18 close.Parent=modal corner(close,12)

local album=panel("AlbumPanel",UDim2.fromScale(.08,.12),UDim2.new(.84,0,.76,0)) album.Visible=false
local albumTitle=text(album,"Title",UDim2.fromScale(.04,.02),UDim2.fromScale(.8,.1),24) albumTitle.Text="PLAYER ALBUM"
local albumClose=Instance.new("TextButton") albumClose.Position=UDim2.fromScale(.86,.025) albumClose.Size=UDim2.fromScale(.1,.09) albumClose.BackgroundColor3=Color3.fromRGB(202,61,61) albumClose.Text="X" albumClose.TextColor3=Color3.new(1,1,1) albumClose.Font=Enum.Font.GothamBlack albumClose.TextSize=20 albumClose.Parent=album corner(albumClose,10)
local scroll=Instance.new("ScrollingFrame") scroll.Position=UDim2.fromScale(.04,.14) scroll.Size=UDim2.fromScale(.92,.70) scroll.BackgroundTransparency=1 scroll.ScrollBarThickness=6 scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y scroll.CanvasSize=UDim2.new() scroll.Parent=album
local grid=Instance.new("UIGridLayout") grid.CellSize=UDim2.new(.48,0,0,72) grid.CellPadding=UDim2.new(.025,0,0,8) grid.Parent=scroll
local sell=Instance.new("TextButton") sell.AnchorPoint=Vector2.new(.5,1) sell.Position=UDim2.fromScale(.5,.96) sell.Size=UDim2.new(.6,0,0,48) sell.BackgroundColor3=Color3.fromRGB(183,74,55) sell.Font=Enum.Font.GothamBlack sell.Text="RELEASE WEAKEST PLAYER" sell.TextColor3=Color3.new(1,1,1) sell.TextSize=16 sell.Parent=album corner(sell,10)

local albumRows={}
local ordered={} for id,d in pairs(definitions) do table.insert(ordered,{Id=id,Definition=d}) end table.sort(ordered,function(a,b) local za=zones[a.Definition.Zone].Order local zb=zones[b.Definition.Zone].Order return za==zb and a.Definition.Name<b.Definition.Name or za<zb end)
for _,entry in ipairs(ordered) do local d=entry.Definition local row=Instance.new("TextLabel") row.BackgroundColor3=Color3.fromRGB(25,32,45) row.Font=Enum.Font.GothamBold row.TextSize=14 row.TextWrapped=true row.TextColor3=Color3.fromRGB(135,145,160) row.Text="?\n"..zones[d.Zone].DisplayName row.Parent=scroll corner(row,9) albumRows[entry.Id]=row end

local function refreshAlbum()
	local total=0 for id,row in pairs(albumRows) do local d=definitions[id] local acquired=state.Album and state.Album[id] if acquired then total+=1 row.Text=d.Name.."\n"..d.Position.." • "..d.Rarity row.TextColor3=rarities.Definitions[d.Rarity].Color else row.Text="?\n"..zones[d.Zone].DisplayName row.TextColor3=Color3.fromRGB(135,145,160) end end
	albumTitle.Text="PLAYER ALBUM  "..total.."/24"
end

local function nextZone()
	for _,id in ipairs({"Academy","National","World"}) do if (state.Speed or 16)<zones[id].RequiredSpeed then return zones[id] end end
end
local function update()
	moneyLabel.Text="MONEY  "..money(state.Money) incomeLabel.Text="+"..money(state.IncomePerSecond).."/s" speedLabel.Text=string.format("SPEED  %.1f",state.Speed or 16)
	training.Visible=state.Training==true local zone=zones[state.CurrentZone] zoneText.Text=zone and zone.DisplayName or "YOUR CLUB"
	local next=nextZone() if next then zoneText.Text..="\nNEXT: "..next.DisplayName.."  "..math.floor(state.Speed).."/"..next.RequiredSpeed else zoneText.Text..="\nALL ZONES UNLOCKED" end
	if state.CarriedContract and state.CarriedContract~="" then objectiveText.Text="RUN TO YOUR CLUB WITH "..string.upper(state.CarriedContract).."!"
	elseif (state.SigningEndsAt or 0)>os.time() then objectiveText.Text=string.format("SIGNING %s… %ds",string.upper(state.SigningName or "PLAYER"),math.max(0,state.SigningEndsAt-os.time()))
	elseif (state.OwnedCount or 0)==0 then objectiveText.Text="STEAL YOUR FIRST CONTRACT IN STREET FOOTBALL"
	else objectiveText.Text="TRAIN, UPGRADE AND STEAL BETTER PLAYERS" end
	marketText.Text=string.format("TRANSFER WINDOW\n%02d:%02d",math.floor(transferTime/60),transferTime%60) refreshAlbum()
end

local toastId=0 local function notify(message,kind) toastId+=1 local id=toastId toastText.Text=message toastText.TextColor3=kind=="Success" and Color3.fromRGB(107,255,162) or (kind=="Warning" and Color3.fromRGB(255,205,78) or (kind=="Rare" and Color3.fromRGB(219,117,255) or Color3.new(1,1,1))) toast.Visible=true toastText.TextTransparency=0 task.delay(3.2,function() if toastId==id then TweenService:Create(toastText,TweenInfo.new(.25),{TextTransparency=1}):Play() task.wait(.28) if toastId==id then toast.Visible=false end end end) end
local lastSlide=0 local function slide() if os.clock()-lastSlide<4 then return end lastSlide=os.clock() remotes.SlideTackle:FireServer() tackle.Text="COOLDOWN" task.delay(4,function() tackle.Text="SLIDE\nTACKLE" end) end
tackle.Activated:Connect(slide) ContextActionService:BindAction("SlideTackle",function(_,input) if input==Enum.UserInputState.Begin then slide() end return Enum.ContextActionResult.Sink end,false,Enum.KeyCode.Q)
albumButton.Activated:Connect(function() album.Visible=not album.Visible end) albumClose.Activated:Connect(function() album.Visible=false end) close.Activated:Connect(function() modal.Visible=false end)
sell.Activated:Connect(function() remotes.SellWeakest:FireServer() end)
remotes.StateUpdate.OnClientEvent:Connect(function(snapshot) for k,v in pairs(snapshot) do state[k]=v end update() end)
remotes.TransferWindow.OnClientEvent:Connect(function(seconds) transferTime=seconds update() end) remotes.Notification.OnClientEvent:Connect(notify)
remotes.Reveal.OnClientEvent:Connect(function(card) revealTitle.Text=card.Name.."  "..card.Rating revealBody.Text=string.format("%s • %s\n%s\n%s EDITION\n\n+%s/s",card.Position,card.Country,card.Rarity,string.upper(card.Edition),money(card.Income)) modal.Visible=true end)
task.spawn(function() while task.wait(1) do if transferTime>0 then transferTime-=1 end update() end end) update()

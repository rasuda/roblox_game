local Players=game:GetService("Players")
local player=Players.LocalPlayer
local gui=Instance.new("ScreenGui") gui.Name="GoldHUD" gui.ResetOnSpawn=false
gui.Parent=player:WaitForChild("PlayerGui")
local panel=Instance.new("Frame") panel.AnchorPoint=Vector2.new(1,0)
panel.Position=UDim2.new(1,-12,0,8) panel.Size=UDim2.new(.65,0,0,100)
panel.BackgroundColor3=Color3.fromRGB(26,22,37) panel.BackgroundTransparency=.16 panel.Parent=gui
local constraint=Instance.new("UISizeConstraint") constraint.MaxSize=Vector2.new(300,100) constraint.Parent=panel
local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,10) corner.Parent=panel
local function line(y,height,size,color)
 local label=Instance.new("TextLabel") label.Position=UDim2.fromOffset(10,y)
 label.Size=UDim2.new(1,-20,0,height) label.BackgroundTransparency=1
 label.Font=Enum.Font.GothamBold label.TextSize=size label.TextColor3=color
 label.TextWrapped=true label.TextXAlignment=Enum.TextXAlignment.Left label.Parent=panel
 return label
end
local gold=line(5,24,19,Color3.fromRGB(255,210,78))
local income=line(29,18,13,Color3.fromRGB(204,234,196))
local hint=line(49,31,12,Color3.fromRGB(240,240,247))
local saving=line(81,15,10,Color3.fromRGB(181,182,197))
local function refresh()
 local ready=player:GetAttribute("DataReady")
 local amount=player:GetAttribute("Gold") or 0
 local formatted=tostring(math.floor(amount)):reverse():gsub("(%d%d%d)","%1."):reverse():gsub("^%.","")
 gold.Text=ready and ("Ouro: "..formatted) or "Carregando ouro..."
 income.Text="+"..tostring(player:GetAttribute("IncomePerSecond") or 0).." moedas/s"
 if player:GetAttribute("WaitingForBase") then hint.Text="Aguardando uma base livre."
 elseif player:GetAttribute("CarryingCreature") then hint.Text="Leve o Pelúcio para dentro do seu castelo."
 elseif player:GetAttribute("HasCreature") then hint.Text="Seu Pelúcio está no castelo."
 else hint.Text=player:GetAttribute("CreatureHint") or "Busque o Pelúcio na última área preta." end
 saving.Text=player:GetAttribute("SaveStatus") or workspace:GetAttribute("MagicStatus") or "Iniciando servidor..."
 if workspace:GetAttribute("MagicError") then
  hint.Text=workspace:GetAttribute("MagicError")
 end
end
for _,attribute in ipairs({"Gold","IncomePerSecond","DataReady","WaitingForBase","CarryingCreature","HasCreature","CreatureHint","SaveStatus"}) do
 player:GetAttributeChangedSignal(attribute):Connect(refresh)
end
refresh()
workspace:GetAttributeChangedSignal("MagicStatus"):Connect(refresh)
workspace:GetAttributeChangedSignal("MagicError"):Connect(refresh)

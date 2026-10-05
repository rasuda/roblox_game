local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("TransferGame"):WaitForChild("Remotes")
local state = {Money=0, IncomePerSecond=0, Speed=16, OwnedCount=0, CarriedContract="", Training=false, SigningEndsAt=0}
local transferTime = 0

local gui = Instance.new("ScreenGui")
gui.Name = "TransferGameUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local function corner(parent, radius)
	local object = Instance.new("UICorner")
	object.CornerRadius = UDim.new(0, radius or 12)
	object.Parent = parent
end

local function stroke(parent, color, thickness)
	local object = Instance.new("UIStroke")
	object.Color = color or Color3.fromRGB(87, 102, 129)
	object.Thickness = thickness or 1
	object.Transparency = 0.25
	object.Parent = parent
end

local function label(parent, name, position, size, textSize, alignment)
	local object = Instance.new("TextLabel")
	object.Name = name
	object.Position = position
	object.Size = size
	object.BackgroundTransparency = 1
	object.Font = Enum.Font.GothamBold
	object.TextColor3 = Color3.new(1,1,1)
	object.TextSize = textSize or 18
	object.TextXAlignment = alignment or Enum.TextXAlignment.Left
	object.Text = ""
	object.Parent = parent
	return object
end

local top = Instance.new("Frame")
top.Name = "Stats"
top.AnchorPoint = Vector2.new(0.5, 0)
top.Position = UDim2.fromScale(0.5, 0.025)
top.Size = UDim2.new(0.86, 0, 0, 66)
top.BackgroundColor3 = Color3.fromRGB(15, 21, 31)
top.BackgroundTransparency = 0.08
top.Parent = gui
corner(top, 16)
stroke(top, Color3.fromRGB(95, 218, 147), 2)

local money = label(top, "Money", UDim2.fromScale(0.035,0), UDim2.fromScale(0.3,1), 19)
local income = label(top, "Income", UDim2.fromScale(0.35,0), UDim2.fromScale(0.3,1), 18, Enum.TextXAlignment.Center)
local speed = label(top, "Speed", UDim2.fromScale(0.66,0), UDim2.fromScale(0.3,1), 19, Enum.TextXAlignment.Right)

local objective = Instance.new("TextLabel")
objective.Name = "Objective"
objective.AnchorPoint = Vector2.new(0.5,0)
objective.Position = UDim2.fromScale(0.5,0.12)
objective.Size = UDim2.new(0.84,0,0,58)
objective.BackgroundColor3 = Color3.fromRGB(16,23,35)
objective.BackgroundTransparency = 0.12
objective.Font = Enum.Font.GothamBold
objective.TextColor3 = Color3.fromRGB(250, 216, 96)
objective.TextSize = 18
objective.TextWrapped = true
objective.Parent = gui
corner(objective,14)

local market = Instance.new("TextLabel")
market.Name = "MarketTimer"
market.AnchorPoint = Vector2.new(1,0)
market.Position = UDim2.new(0.98,0,0.22,0)
market.Size = UDim2.fromOffset(190,55)
market.BackgroundColor3 = Color3.fromRGB(16,23,35)
market.BackgroundTransparency = 0.12
market.Font = Enum.Font.GothamBold
market.TextColor3 = Color3.fromRGB(120,205,255)
market.TextSize = 16
market.TextWrapped = true
market.Parent = gui
corner(market,12)

local training = Instance.new("TextLabel")
training.Name = "Training"
training.AnchorPoint = Vector2.new(0,0.5)
training.Position = UDim2.fromScale(0.025,0.52)
training.Size = UDim2.fromOffset(190,54)
training.BackgroundColor3 = Color3.fromRGB(201,132,37)
training.BackgroundTransparency = 0.08
training.Font = Enum.Font.GothamBlack
training.Text = "TREINANDO SPEED"
training.TextColor3 = Color3.new(1,1,1)
training.TextSize = 16
training.Visible = false
training.Parent = gui
corner(training,12)

local slide = Instance.new("TextButton")
slide.Name = "SlideTackle"
slide.AnchorPoint = Vector2.new(1,1)
slide.Position = UDim2.new(0.97,0,0.95,0)
slide.Size = UDim2.fromOffset(126,126)
slide.BackgroundColor3 = Color3.fromRGB(231,70,68)
slide.BackgroundTransparency = 0.06
slide.Font = Enum.Font.GothamBlack
slide.Text = "SLIDE\nTACKLE"
slide.TextColor3 = Color3.new(1,1,1)
slide.TextSize = 19
slide.Parent = gui
corner(slide,63)
stroke(slide, Color3.fromRGB(255,190,88), 3)

local toast = Instance.new("TextLabel")
toast.Name = "Toast"
toast.AnchorPoint = Vector2.new(0.5,1)
toast.Position = UDim2.fromScale(0.5,0.82)
toast.Size = UDim2.new(0.72,0,0,58)
toast.BackgroundColor3 = Color3.fromRGB(18,24,34)
toast.BackgroundTransparency = 0.06
toast.Font = Enum.Font.GothamBold
toast.TextColor3 = Color3.new(1,1,1)
toast.TextSize = 17
toast.TextWrapped = true
toast.Visible = false
toast.Parent = gui
corner(toast,14)

local reveal = Instance.new("Frame")
reveal.Name = "Reveal"
reveal.AnchorPoint = Vector2.new(0.5,0.5)
reveal.Position = UDim2.fromScale(0.5,0.5)
reveal.Size = UDim2.new(0.72,0,0.58,0)
reveal.BackgroundColor3 = Color3.fromRGB(12,17,27)
reveal.Visible = false
reveal.Parent = gui
corner(reveal,22)
stroke(reveal, Color3.fromRGB(239,195,64), 4)
local revealTitle = label(reveal,"Title",UDim2.fromScale(0.08,0.08),UDim2.fromScale(0.84,0.2),28,Enum.TextXAlignment.Center)
revealTitle.TextColor3 = Color3.fromRGB(255,213,76)
local revealBody = label(reveal,"Body",UDim2.fromScale(0.08,0.28),UDim2.fromScale(0.84,0.5),22,Enum.TextXAlignment.Center)
revealBody.TextWrapped = true
local close = Instance.new("TextButton")
close.AnchorPoint = Vector2.new(0.5,1)
close.Position = UDim2.fromScale(0.5,0.93)
close.Size = UDim2.new(0.55,0,0,52)
close.BackgroundColor3 = Color3.fromRGB(55,177,105)
close.Font = Enum.Font.GothamBold
close.Text = "CONTINUAR"
close.TextColor3 = Color3.new(1,1,1)
close.TextSize = 18
close.Parent = reveal
corner(close,12)
close.Activated:Connect(function() reveal.Visible = false end)

local function formatMoney(value)
	if value >= 1000000 then return string.format("$%.1fM", value/1000000) end
	if value >= 1000 then return string.format("$%.1fK", value/1000) end
	return string.format("$%d", math.floor(value or 0))
end

local function update()
	money.Text = "MONEY  " .. formatMoney(state.Money or 0)
	income.Text = "+" .. formatMoney(state.IncomePerSecond or 0) .. "/s"
	speed.Text = string.format("SPEED  %.1f", state.Speed or 16)
	training.Visible = state.Training == true
	if state.CarriedContract and state.CarriedContract ~= "" then
		objective.Text = "⚠ LEVE O CONTRATO DE " .. string.upper(state.CarriedContract) .. " AO SEU CLUBE"
	elseif (state.SigningEndsAt or 0) > os.time() then
		objective.Text = string.format("ASSINANDO %s… %ds", string.upper(state.SigningName or "JOGADOR"), math.max(0,state.SigningEndsAt-os.time()))
	elseif (state.OwnedCount or 0) == 0 then
		objective.Text = "OBJETIVO: VÁ À VÁRZEA, PEGUE UM CONTRATO E FUJA DO GUARDIAN"
	else
		objective.Text = "TREINE SPEED OU BUSQUE OUTRO CONTRATO"
	end
	market.Text = string.format("TRANSFER WINDOW\n%02d:%02d", math.floor(transferTime/60), transferTime%60)
end

local toastId = 0
local function notify(message, kind)
	toastId += 1
	local id = toastId
	toast.Text = message
	toast.TextColor3 = kind == "Success" and Color3.fromRGB(111,255,165) or (kind == "Warning" and Color3.fromRGB(255,207,91) or (kind == "Rare" and Color3.fromRGB(224,132,255) or Color3.new(1,1,1)))
	toast.Visible = true
	toast.TextTransparency = 0
	task.delay(3.2,function()
		if toastId == id then
			TweenService:Create(toast,TweenInfo.new(0.3),{TextTransparency=1}):Play()
			task.wait(0.32)
			if toastId == id then toast.Visible = false end
		end
	end)
end

local lastSlide = 0
local function useSlide()
	if os.clock() - lastSlide < 4 then return end
	lastSlide = os.clock()
	remotes.SlideTackle:FireServer()
	slide.Text = "COOLDOWN"
	task.delay(4,function() slide.Text = "SLIDE\nTACKLE" end)
end

slide.Activated:Connect(useSlide)
ContextActionService:BindAction("TransferSlideTackle",function(_,inputState)
	if inputState == Enum.UserInputState.Begin then useSlide() end
	return Enum.ContextActionResult.Sink
end,false,Enum.KeyCode.Q)

remotes.StateUpdate.OnClientEvent:Connect(function(snapshot)
	for key,value in pairs(snapshot) do state[key]=value end
	update()
end)
remotes.TransferWindow.OnClientEvent:Connect(function(seconds) transferTime=seconds update() end)
remotes.Notification.OnClientEvent:Connect(notify)
remotes.Reveal.OnClientEvent:Connect(function(card)
	revealTitle.Text = card.Name .. " • " .. card.Rating
	revealBody.Text = string.format("%s\n%s • %s\n+%s por segundo",card.Position,card.Rarity,card.Edition,formatMoney(card.Income))
	reveal.Visible = true
end)

task.spawn(function()
	while task.wait(1) do
		if transferTime > 0 then transferTime -= 1 end
		update()
	end
end)
update()

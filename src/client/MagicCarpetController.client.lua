local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local carpetControl = ReplicatedStorage:WaitForChild("MagicCarpetControl")

local gui = Instance.new("ScreenGui")
gui.Name = "MagicCarpetGui"
gui.ResetOnSpawn = false
gui.Enabled = false
gui.Parent = player:WaitForChild("PlayerGui")

local function createButton(name, text, position, color)
	local button = Instance.new("TextButton")
	button.Name = name
	button.AnchorPoint = Vector2.new(1, 1)
	button.Position = position
	button.Size = UDim2.fromOffset(76, 62)
	button.BackgroundColor3 = color
	button.BackgroundTransparency = 0.15
	button.Text = text
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextScaled = true
	button.Font = Enum.Font.GothamBold
	button.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = button
	return button
end

local upButton = createButton("Up", "▲", UDim2.new(1, -22, 1, -174), Color3.fromRGB(42, 139, 190))
local downButton = createButton("Down", "▼", UDim2.new(1, -22, 1, -102), Color3.fromRGB(42, 139, 190))
local exitButton = createButton("Exit", "SAIR", UDim2.new(1, -108, 1, -102), Color3.fromRGB(180, 62, 62))

local function bindHold(button, direction)
	button.MouseButton1Down:Connect(function()
		carpetControl:FireServer("vertical", direction)
	end)
	button.MouseButton1Up:Connect(function()
		carpetControl:FireServer("vertical", 0)
	end)
	button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			carpetControl:FireServer("vertical", 0)
		end
	end)
end

bindHold(upButton, 1)
bindHold(downButton, -1)
exitButton.Activated:Connect(function()
	carpetControl:FireServer("exit")
end)

local function connectCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.Seated:Connect(function(active, seat)
		gui.Enabled = active and seat ~= nil and seat.Name == "CarpetSeat"
		if not gui.Enabled then
			carpetControl:FireServer("vertical", 0)
		end
	end)
end

if player.Character then
	connectCharacter(player.Character)
end
player.CharacterAdded:Connect(connectCharacter)

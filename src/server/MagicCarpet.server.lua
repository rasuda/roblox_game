local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Config = require(script.Parent.CityModules.CityConfig)
local Builder = require(script.Parent.CityModules.Builder)
local world = Workspace:WaitForChild(Config.WorldName, 30)
if not world then
	warn("[NeonDesertCity] Mundo não encontrado; tapete voador não foi criado.")
	return
end

local carpetControl = ReplicatedStorage:FindFirstChild("MagicCarpetControl")
if not carpetControl then
	carpetControl = Instance.new("RemoteEvent")
	carpetControl.Name = "MagicCarpetControl"
	carpetControl.Parent = ReplicatedStorage
end

local carpet = Builder.model(world, "MagicCarpet")
local carpetStart = Vector3.new(88, 5, -92)
local carpetBase = Builder.part(carpet, "CarpetBase", Vector3.new(10.5, 0.45, 15.5), CFrame.new(carpetStart), Color3.fromRGB(244, 190, 47), Enum.Material.Fabric, true)
carpet.PrimaryPart = carpetBase

local rainbowColors = {
	Color3.fromRGB(232, 48, 54), Color3.fromRGB(245, 126, 31),
	Color3.fromRGB(250, 211, 44), Color3.fromRGB(75, 184, 72),
	Color3.fromRGB(48, 145, 218), Color3.fromRGB(76, 79, 181),
	Color3.fromRGB(153, 67, 173),
}
for index, color in ipairs(rainbowColors) do
	Builder.part(carpet, "RainbowStripe", Vector3.new(9.8, 0.16, 2.08), CFrame.new(carpetStart + Vector3.new(0, 0.3, -6.3 + (index - 1) * 2.1)), color, Enum.Material.Fabric, false)
end

local carpetSeat = Instance.new("VehicleSeat")
carpetSeat.Name = "CarpetSeat"
carpetSeat.Anchored = true
carpetSeat.CanCollide = false
carpetSeat.Transparency = 1
carpetSeat.Size = Vector3.new(4, 1, 4)
carpetSeat.Position = carpetStart + Vector3.new(0, 1, 1)
carpetSeat.MaxSpeed = 45
carpetSeat.TurnSpeed = 1.8
carpetSeat.Parent = carpet

local prompt = Instance.new("ProximityPrompt")
prompt.Name = "FlyPrompt"
prompt.ActionText = "Voar"
prompt.ObjectText = "Tapete voador arco-íris — grátis"
prompt.HoldDuration = 0
prompt.MaxActivationDistance = 12
prompt.RequiresLineOfSight = false
prompt.Parent = carpetBase

local carpetPosition = carpetStart
local carpetHeading = math.pi
local carpetVertical = 0

local function seatedPlayer()
	local humanoid = carpetSeat.Occupant
	return humanoid and Players:GetPlayerFromCharacter(humanoid.Parent) or nil
end

prompt.Triggered:Connect(function(player)
	if carpetSeat.Occupant then return end
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then carpetSeat:Sit(humanoid) end
end)

carpetSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
	carpetVertical = 0
	prompt.Enabled = carpetSeat.Occupant == nil
end)

carpetControl.OnServerEvent:Connect(function(player, action, value)
	if seatedPlayer() ~= player then return end
	if action == "vertical" and type(value) == "number" then
		carpetVertical = math.clamp(value, -1, 1)
	elseif action == "exit" and carpetSeat.Occupant then
		carpetSeat.Occupant.Sit = false
	end
end)

RunService.Heartbeat:Connect(function(deltaTime)
	if not carpetSeat.Occupant then return end
	carpetHeading += -carpetSeat.SteerFloat * 1.8 * deltaTime
	local direction = CFrame.Angles(0, carpetHeading, 0).LookVector
	carpetPosition += direction * carpetSeat.ThrottleFloat * 45 * deltaTime
	carpetPosition += Vector3.new(0, carpetVertical * 28 * deltaTime, 0)
	local limit = Config.World.Size / 2 - 80
	carpetPosition = Vector3.new(math.clamp(carpetPosition.X, -limit, limit), math.clamp(carpetPosition.Y, 4, 520), math.clamp(carpetPosition.Z, -limit, limit))
	carpet:PivotTo(CFrame.new(carpetPosition) * CFrame.Angles(0, carpetHeading, 0))
end)

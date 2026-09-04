local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local WORLD_NAME = "ValidationWorld"

local previousWorld = Workspace:FindFirstChild(WORLD_NAME)
if previousWorld then
	previousWorld:Destroy()
end

local world = Instance.new("Folder")
world.Name = WORLD_NAME
world.Parent = Workspace

local baseplate = Instance.new("Part")
baseplate.Name = "Baseplate"
baseplate.Anchored = true
baseplate.Size = Vector3.new(100, 1, 100)
baseplate.Position = Vector3.new(0, -0.5, 0)
baseplate.Material = Enum.Material.Grass
baseplate.Color = Color3.fromRGB(88, 142, 72)
baseplate.Parent = world

local spawn = Instance.new("SpawnLocation")
spawn.Name = "PlayerSpawn"
spawn.Anchored = true
spawn.Size = Vector3.new(8, 1, 8)
spawn.Position = Vector3.new(0, 0.5, 0)
spawn.Neutral = true
spawn.Material = Enum.Material.Neon
spawn.Color = Color3.fromRGB(255, 170, 0)
spawn.Parent = world

local colors = {
	Color3.fromRGB(255, 89, 89),
	Color3.fromRGB(70, 170, 255),
	Color3.fromRGB(170, 85, 255),
}

for index, color in ipairs(colors) do
	local block = Instance.new("Part")
	block.Name = string.format("TestBlock%d", index)
	block.Anchored = true
	block.Size = Vector3.new(8, 4, 8)
	block.Position = Vector3.new((index - 2) * 14, 2, -20)
	block.Color = color
	block.Parent = world
end

Players.PlayerAdded:Connect(function(player)
	print(string.format("[roblox_game] Processo validado para %s", player.Name))
end)

print("[roblox_game] Mundo de validação carregado com sucesso.")

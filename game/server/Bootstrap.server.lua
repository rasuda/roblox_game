local ReplicatedStorage = game:GetService("ReplicatedStorage")

local root = ReplicatedStorage:WaitForChild("TransferGame")
local configFolder = root:WaitForChild("Config")
local constants = require(root.Shared.Constants)

local remotes = root:FindFirstChild("Remotes") or Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = root
local remoteTable = {}
for _, name in pairs(constants.RemoteNames) do
	local remote = remotes:FindFirstChild(name) or Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = remotes
	remoteTable[name] = remote
end

local context = {
	Constants = constants,
	Config = {
		Game = require(configFolder.GameConfig),
		Zones = require(configFolder.ZoneConfig),
		Rarity = require(configFolder.RarityConfig),
		Players = require(configFolder.PlayerDefinitions),
		Economy = require(configFolder.EconomyConfig),
		Training = require(configFolder.TrainingConfig),
		Equipment = require(configFolder.EquipmentConfig),
		Editions = require(configFolder.EditionConfig),
		Upgrades = require(configFolder.UpgradeConfig),
	},
	Remotes = remoteTable,
	Services = {},
}

local services = script.Parent.Services
context.Services.PlayerData = require(services.PlayerDataService)
context.Services.Club = require(services.ClubService)
context.Services.Economy = require(services.EconomyService)
context.Services.Training = require(services.TrainingService)
context.Services.Contracts = require(services.ContractService)
context.Services.Guardian = require(services.GuardianService)
context.Services.PvP = require(services.PvPService)
context.Services.TransferWindow = require(services.TransferWindowService)

context.Services.PlayerData:Init(context)
context.Services.Club:Init(context)
context.Services.Economy:Init(context)
context.Services.Training:Init(context)
context.Services.Contracts:Init(context)
context.Services.Guardian:Init(context)
context.Services.PvP:Init(context)
context.Services.TransferWindow:Init(context)

print("[Football Transfer Rivals] MVP v2 initialized")

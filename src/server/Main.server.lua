local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local modules = script.Parent:WaitForChild("CityModules")
local Config = require(modules.CityConfig)
local CityBuilder = require(modules.CityBuilder)

local function configureLighting()
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.35
	Lighting.ClockTime = Config.Lighting.StartClockTime
	Lighting.Brightness = 2.2
	Lighting.ExposureCompensation = 0.05
	Lighting.EnvironmentDiffuseScale = 0.35
	Lighting.EnvironmentSpecularScale = 0.7
	Lighting.Ambient = Color3.fromRGB(89, 91, 105)
	Lighting.OutdoorAmbient = Color3.fromRGB(126, 124, 130)
	Lighting.GeographicLatitude = 36

	for _, effectName in ipairs({"CityAtmosphere", "CityBloom", "CityColor"}) do
		local previous = Lighting:FindFirstChild(effectName)
		if previous then previous:Destroy() end
	end

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Name = "CityAtmosphere"
	atmosphere.Density = 0.22
	atmosphere.Offset = 0.15
	atmosphere.Color = Color3.fromRGB(198, 181, 169)
	atmosphere.Decay = Color3.fromRGB(83, 73, 102)
	atmosphere.Glare = 0.1
	atmosphere.Haze = 1.45
	atmosphere.Parent = Lighting

	local bloom = Instance.new("BloomEffect")
	bloom.Name = "CityBloom"
	bloom.Intensity = 0.72
	bloom.Size = 28
	bloom.Threshold = 1.15
	bloom.Parent = Lighting

	local color = Instance.new("ColorCorrectionEffect")
	color.Name = "CityColor"
	color.Brightness = 0.01
	color.Contrast = 0.08
	color.Saturation = 0.08
	color.TintColor = Color3.fromRGB(255, 238, 225)
	color.Parent = Lighting
end

configureLighting()

-- Garante chão e respawn mesmo se uma futura alteração no gerador falhar.
local recoveryPlatform = Instance.new("Part")
recoveryPlatform.Name = "CityRecoveryPlatform"
recoveryPlatform.Anchored = true
recoveryPlatform.Size = Vector3.new(220, 2, 220)
recoveryPlatform.Position = Vector3.new(76, -1, -120)
recoveryPlatform.Color = Color3.fromRGB(183, 63, 63)
recoveryPlatform.Material = Enum.Material.Concrete
recoveryPlatform:SetAttribute("PreserveAcrossCityRebuild", true)
recoveryPlatform.Parent = Workspace

local recoverySpawn = Instance.new("SpawnLocation")
recoverySpawn.Name = "CityRecoverySpawn"
recoverySpawn.Anchored = true
recoverySpawn.Size = Vector3.new(12, 1, 12)
recoverySpawn.Position = Vector3.new(76, 1, -120)
recoverySpawn.Neutral = true
recoverySpawn:SetAttribute("PreserveAcrossCityRebuild", true)
recoverySpawn.Parent = Workspace

local success, result = xpcall(function()
	return CityBuilder.build(Config)
end, debug.traceback)

if not success then
	recoveryPlatform.Color = Color3.fromRGB(225, 55, 55)
	warn("[NeonDesertCity] Falha ao construir a cidade:\n" .. tostring(result))
	return
end

local world = result
recoverySpawn:Destroy()
recoveryPlatform:Destroy()

Players.PlayerAdded:Connect(function(player)
	print(string.format("[NeonDesertCity] MVP carregado para %s", player.Name))
end)

print(string.format("[NeonDesertCity] %s construído com sucesso (%d objetos).", Config.Version, #world:GetDescendants()))

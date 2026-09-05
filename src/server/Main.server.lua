local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

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
local world = CityBuilder.build(Config)

Players.PlayerAdded:Connect(function(player)
	print(string.format("[NeonDesertCity] MVP carregado para %s", player.Name))
end)

print(string.format("[NeonDesertCity] %s construído com sucesso (%d objetos).", Config.Version, #world:GetDescendants()))

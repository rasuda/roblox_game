local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local Config = require(script.Parent.CityModules.CityConfig)

local secondsPerFullDay = Config.Lighting.FullDayMinutes * 60
local lastNightState = nil

local function isNight(clockTime)
	return clockTime >= Config.Lighting.NightStarts or clockTime < Config.Lighting.DayStarts
end

local function applyNightState(night)
	if lastNightState == night then return end
	lastNightState = night

	for _, object in ipairs(CollectionService:GetTagged("CityNightEmissive")) do
		if object:IsA("BasePart") then
			object.Material = night and Enum.Material.Neon or Enum.Material.SmoothPlastic
			local targetColor = object:GetAttribute(night and "NightColor" or "DayColor")
			if typeof(targetColor) == "Color3" then object.Color = targetColor end
		end
	end

	for _, light in ipairs(CollectionService:GetTagged("CityDynamicLight")) do
		if light:IsA("Light") then light.Enabled = night end
	end

	local bloom = Lighting:FindFirstChild("CityBloom")
	if bloom and bloom:IsA("BloomEffect") then bloom.Intensity = night and 1.05 or 0.35 end
	Lighting.ExposureCompensation = night and -0.15 or 0.05
	print("[NeonDesertCity] Iluminação alterada para " .. (night and "noite" or "dia"))
end

Workspace:WaitForChild(Config.WorldName, 30)
task.wait(0.25)
applyNightState(isNight(Lighting.ClockTime))

while Config.Lighting.CycleEnabled do
	task.wait(1)
	Lighting.ClockTime = (Lighting.ClockTime + 24 / secondsPerFullDay) % 24
	applyNightState(isNight(Lighting.ClockTime))
end

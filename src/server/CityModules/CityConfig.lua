local Config = {
	WorldName = "NeonDesertCity",
	Version = "Las Vegas inspired MVP 1.0",

	-- Escala principal. Alterar estes valores reorganiza o mapa sem editar os construtores.
	Strip = {
		Length = 3200,
		RoadWidth = 104,
		SidewalkWidth = 22,
		MedianWidth = 8,
		LaneCountPerDirection = 3,
		IntersectionSpacing = 400,
	},

	World = {
		Size = 4600,
		CityHalfWidth = 780,
		MountainDistance = 1850,
	},

	Layout = {
		LandmarkSetback = 275,
		LandmarkSpacing = 560,
		BuildingHeightScale = 1,
	},

	Density = {
		PalmSpacing = 155,
		StreetLightSpacing = 145,
		TrafficVehicleCount = 20,
		BackgroundBuildingCount = 36,
	},

	Lighting = {
		CycleEnabled = true,
		FullDayMinutes = 14,
		StartClockTime = 18.4,
		NightStarts = 18.2,
		DayStarts = 6.2,
	},

	Performance = {
		StreamingMinRadius = 128,
		StreamingTargetRadius = 420,
		DecorativeShadows = false,
		MaxDynamicLights = 28,
	},

	Palette = {
		Sand = Color3.fromRGB(205, 174, 119),
		Asphalt = Color3.fromRGB(38, 41, 48),
		Concrete = Color3.fromRGB(168, 165, 157),
		RoadLine = Color3.fromRGB(235, 221, 171),
		Glass = Color3.fromRGB(54, 94, 120),
		DarkGlass = Color3.fromRGB(25, 45, 63),
		WarmLight = Color3.fromRGB(255, 190, 88),
		Cyan = Color3.fromRGB(42, 224, 235),
		Magenta = Color3.fromRGB(238, 65, 186),
		Violet = Color3.fromRGB(129, 82, 255),
	},
}

return Config

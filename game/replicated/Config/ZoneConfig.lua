return table.freeze({
	Street = {
		Id = "Street", DisplayName = "Várzea Street", Order = 1,
		RecommendedSpeed = 16, GuardianSpeed = 14.5,
		Color = Color3.fromRGB(72, 117, 71),
		Center = Vector3.new(0, 0, -125), Size = Vector3.new(260, 1, 230),
		PlayerPool = {"leo_veloz", "mateo_cruz", "davi_rocha"},
		ContractSpawnPoints = {
			Vector3.new(-72, 2, -92), Vector3.new(0, 2, -185), Vector3.new(72, 2, -92),
		},
		GuardianSpawn = Vector3.new(0, 4, -72),
	},
})

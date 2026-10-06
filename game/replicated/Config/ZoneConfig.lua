local zones = {
	Street = {Id="Street",DisplayName="STREET FOOTBALL",Order=1,RequiredSpeed=16,Center=Vector3.new(0,0,-80),Size=Vector3.new(700,1,180),Color=Color3.fromRGB(65,91,70),GuardianName="Treinador Bravo",GuardianSpeed=18,IncomeScale=1},
	Academy = {Id="Academy",DisplayName="ACADEMY",Order=2,RequiredSpeed=22,Center=Vector3.new(0,0,-285),Size=Vector3.new(700,1,180),Color=Color3.fromRGB(56,88,113),GuardianName="Segurança da Academy",GuardianSpeed=25,IncomeScale=18},
	National = {Id="National",DisplayName="NATIONAL CLUB",Order=3,RequiredSpeed=32,Center=Vector3.new(0,0,-490),Size=Vector3.new(700,1,180),Color=Color3.fromRGB(105,70,53),GuardianName="Mascote Nacional",GuardianSpeed=36,IncomeScale=260},
	World = {Id="World",DisplayName="WORLD ELITE",Order=4,RequiredSpeed=44,Center=Vector3.new(0,0,-695),Size=Vector3.new(700,1,180),Color=Color3.fromRGB(73,58,102),GuardianName="Elite Guardian",GuardianSpeed=49,IncomeScale=4200},
}

for _, zone in pairs(zones) do
	zone.PlayerPool = {}
	zone.ContractSpawnPoints = {
		zone.Center + Vector3.new(-190,3,0),
		zone.Center + Vector3.new(0,3,-25),
		zone.Center + Vector3.new(190,3,0),
	}
	zone.GuardianSpawn = zone.Center + Vector3.new(0,4,45)
end

return table.freeze(zones)

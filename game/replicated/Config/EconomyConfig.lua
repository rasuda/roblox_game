return table.freeze({
	StartingMoney = 0,
	RatingBaseline = 70,
	RatingIncomePerPoint = 0.025,
	Editions = {
		Normal = {Weight=78, Multiplier=1, Color=Color3.fromRGB(210,215,220)},
		Captain = {Weight=14, Multiplier=1.35, Color=Color3.fromRGB(72,153,225)},
		Prime = {Weight=6, Multiplier=1.8, Color=Color3.fromRGB(170,84,219)},
		GoldenBoot = {Weight=2, Multiplier=2.6, Color=Color3.fromRGB(244,196,54)},
	},
	TrainingUpgradeCosts = {25, 90, 300, 1000},
})

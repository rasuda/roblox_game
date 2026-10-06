local definitions = {
	leo_santos={Name="Leo Santos",Position="RW",Country="BRA",Zone="Street",Rarity="Rookie",BaseRating=72,RatingMin=70,RatingMax=79,BaseIncome=2,TransferWeight=1,SigningTime=5},
	mateo_cruz={Name="Mateo Cruz",Position="ST",Country="ARG",Zone="Street",Rarity="Pro",BaseRating=78,RatingMin=73,RatingMax=84,BaseIncome=4,TransferWeight=1.2,SigningTime=6},
	liam_carter={Name="Liam Carter",Position="CM",Country="ENG",Zone="Street",Rarity="Rookie",BaseRating=73,RatingMin=70,RatingMax=80,BaseIncome=2.5,TransferWeight=1.05,SigningTime=5},
	kenji_nakamura={Name="Kenji Nakamura",Position="CAM",Country="JPN",Zone="Street",Rarity="Pro",BaseRating=79,RatingMin=74,RatingMax=85,BaseIncome=5,TransferWeight=1.25,SigningTime=7},
	diego_moreno={Name="Diego Moreno",Position="LB",Country="MEX",Zone="Street",Rarity="Rookie",BaseRating=74,RatingMin=71,RatingMax=80,BaseIncome=3,TransferWeight=1.1,SigningTime=5},
	marco_bellini={Name="Marco Bellini",Position="GK",Country="ITA",Zone="Street",Rarity="Star",BaseRating=82,RatingMin=78,RatingMax=88,BaseIncome=8,TransferWeight=1.45,SigningTime=9},
	rafa_silva={Name="Rafa Silva",Position="LW",Country="BRA",Zone="Academy",Rarity="Pro",BaseRating=81,RatingMin=76,RatingMax=87,BaseIncome=55,TransferWeight=1.4,SigningTime=8},
	lucas_vega={Name="Lucas Vega",Position="ST",Country="ESP",Zone="Academy",Rarity="Star",BaseRating=84,RatingMin=79,RatingMax=90,BaseIncome=80,TransferWeight=1.65,SigningTime=10},
	noah_wilson={Name="Noah Wilson",Position="CB",Country="USA",Zone="Academy",Rarity="Pro",BaseRating=80,RatingMin=75,RatingMax=86,BaseIncome=48,TransferWeight=1.45,SigningTime=8},
	yuri_volkov={Name="Yuri Volkov",Position="GK",Country="UKR",Zone="Academy",Rarity="Star",BaseRating=85,RatingMin=80,RatingMax=91,BaseIncome=95,TransferWeight=1.7,SigningTime=11},
	amin_diallo={Name="Amin Diallo",Position="CDM",Country="SEN",Zone="Academy",Rarity="Pro",BaseRating=82,RatingMin=77,RatingMax=88,BaseIncome=62,TransferWeight=1.5,SigningTime=9},
	tomas_novak={Name="Tomas Novak",Position="RB",Country="CZE",Zone="Academy",Rarity="Elite",BaseRating=87,RatingMin=82,RatingMax=93,BaseIncome=135,TransferWeight=1.9,SigningTime=13},
	andre_ferraz={Name="Andre Ferraz",Position="ST",Country="BRA",Zone="National",Rarity="Star",BaseRating=86,RatingMin=81,RatingMax=92,BaseIncome=850,TransferWeight=1.8,SigningTime=12},
	hugo_laurent={Name="Hugo Laurent",Position="CAM",Country="FRA",Zone="National",Rarity="Elite",BaseRating=89,RatingMin=84,RatingMax=94,BaseIncome=1400,TransferWeight=2.15,SigningTime=15},
	samuel_okoye={Name="Samuel Okoye",Position="CB",Country="NGA",Zone="National",Rarity="Star",BaseRating=87,RatingMin=82,RatingMax=92,BaseIncome=960,TransferWeight=1.95,SigningTime=13},
	enzo_ricci={Name="Enzo Ricci",Position="CM",Country="ITA",Zone="National",Rarity="Elite",BaseRating=90,RatingMin=85,RatingMax=95,BaseIncome=1750,TransferWeight=2.2,SigningTime=16},
	min_joon={Name="Min Joon",Position="RW",Country="KOR",Zone="National",Rarity="Star",BaseRating=88,RatingMin=83,RatingMax=93,BaseIncome=1100,TransferWeight=2,SigningTime=14},
	ivan_petrov={Name="Ivan Petrov",Position="GK",Country="BUL",Zone="National",Rarity="Legend",BaseRating=92,RatingMin=87,RatingMax=97,BaseIncome=2600,TransferWeight=2.5,SigningTime=19},
	thiago_reis={Name="Thiago Reis",Position="LW",Country="BRA",Zone="World",Rarity="Elite",BaseRating=92,RatingMin=87,RatingMax=96,BaseIncome=15000,TransferWeight=2.45,SigningTime=18},
	adrian_kovac={Name="Adrian Kovac",Position="ST",Country="CRO",Zone="World",Rarity="Legend",BaseRating=94,RatingMin=89,RatingMax=98,BaseIncome=28000,TransferWeight=2.9,SigningTime=22},
	malik_aziz={Name="Malik Aziz",Position="CAM",Country="MAR",Zone="World",Rarity="Elite",BaseRating=91,RatingMin=86,RatingMax=96,BaseIncome=13500,TransferWeight=2.4,SigningTime=18},
	erik_lind={Name="Erik Lind",Position="CB",Country="SWE",Zone="World",Rarity="Legend",BaseRating=95,RatingMin=90,RatingMax=99,BaseIncome=34000,TransferWeight=3,SigningTime=24},
	joao_aurora={Name="Joao Aurora",Position="RW",Country="POR",Zone="World",Rarity="Icon",BaseRating=96,RatingMin=91,RatingMax=99,BaseIncome=65000,TransferWeight=3.4,SigningTime=28},
	gabriel_solis={Name="Gabriel Solis",Position="CM",Country="URU",Zone="World",Rarity="Legend",BaseRating=93,RatingMin=88,RatingMax=98,BaseIncome=24000,TransferWeight=2.75,SigningTime=21},
}

local weights = {Rookie=50,Pro=28,Star=14,Elite=6,Legend=1.7,Icon=0.3}
for id, definition in pairs(definitions) do
	definition.Id = id
	definition.SpawnWeight = weights[definition.Rarity]
end

return table.freeze(definitions)

local Lighting=game:GetService("Lighting")
local Workspace=game:GetService("Workspace")

local MAP_NAME="FootballTerrain"
local HUB_CENTER=Vector3.new(0,0,300)
local HUB_SIZE=Vector3.new(650,24,500)
local LANE_WIDTH=300
local SECTION_LENGTH=250
local WALL_HEIGHT=54

local ZONES={
	{Name="FOREST",Floor=Color3.fromRGB(105,219,55),Wall=Color3.fromRGB(144,92,54),Rail=Color3.fromRGB(61,255,70)},
	{Name="JUNGLE",Floor=Color3.fromRGB(84,170,67),Wall=Color3.fromRGB(124,82,48),Rail=Color3.fromRGB(57,241,72)},
	{Name="ICE",Floor=Color3.fromRGB(231,242,247),Wall=Color3.fromRGB(134,94,65),Rail=Color3.fromRGB(188,239,255)},
	{Name="VOLCANO",Floor=Color3.fromRGB(47,44,48),Wall=Color3.fromRGB(78,54,48),Rail=Color3.fromRGB(255,83,28)},
	{Name="OCEAN",Floor=Color3.fromRGB(43,93,178),Wall=Color3.fromRGB(34,74,130),Rail=Color3.fromRGB(52,207,255)},
	{Name="PREHISTORIC",Floor=Color3.fromRGB(215,177,93),Wall=Color3.fromRGB(135,91,48),Rail=Color3.fromRGB(79,235,65)},
	{Name="SPACE",Floor=Color3.fromRGB(16,15,28),Wall=Color3.fromRGB(27,25,48),Rail=Color3.fromRGB(228,104,255)},
}

local function part(parent,name,size,cframe,color,material,collide,transparency)
	local object=Instance.new("Part")
	object.Name=name object.Size=size object.CFrame=cframe object.Color=color
	object.Material=material or Enum.Material.SmoothPlastic object.Anchored=true object.CanCollide=collide~=false
	object.Transparency=transparency or 0 object.TopSurface=Enum.SurfaceType.Smooth object.BottomSurface=Enum.SurfaceType.Smooth object.Parent=parent
	return object
end

local function label(adornee,textValue,color,size)
	local gui=Instance.new("BillboardGui") gui.Size=size or UDim2.fromOffset(280,70) gui.StudsOffset=Vector3.new(0,5,0) gui.AlwaysOnTop=true gui.Parent=adornee
	local text=Instance.new("TextLabel") text.Size=UDim2.fromScale(1,1) text.BackgroundColor3=Color3.fromRGB(16,20,28) text.BackgroundTransparency=.1
	text.Text=textValue text.TextColor3=color text.Font=Enum.Font.GothamBlack text.TextScaled=true text.Parent=gui
	local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,10) corner.Parent=text return text
end

local function border(parent,name,center,size,color,railColor)
	local halfX=size.X/2 local halfZ=size.Z/2 local thickness=12 local y=WALL_HEIGHT/2
	part(parent,name.."LeftWall",Vector3.new(thickness,WALL_HEIGHT,size.Z),CFrame.new(center.X-halfX+thickness/2,y,center.Z),color,Enum.Material.Brick,true)
	part(parent,name.."RightWall",Vector3.new(thickness,WALL_HEIGHT,size.Z),CFrame.new(center.X+halfX-thickness/2,y,center.Z),color,Enum.Material.Brick,true)
	part(parent,name.."LeftRail",Vector3.new(14,3,size.Z),CFrame.new(center.X-halfX+thickness/2,WALL_HEIGHT+1.5,center.Z),railColor,Enum.Material.Neon,false)
	part(parent,name.."RightRail",Vector3.new(14,3,size.Z),CFrame.new(center.X+halfX-thickness/2,WALL_HEIGHT+1.5,center.Z),railColor,Enum.Material.Neon,false)
end

local function endWall(parent,name,z,width,color,railColor,openingWidth)
	local thickness=12 local y=WALL_HEIGHT/2
	if not openingWidth then
		part(parent,name.."Wall",Vector3.new(width,WALL_HEIGHT,thickness),CFrame.new(0,y,z),color,Enum.Material.Brick,true)
		part(parent,name.."Rail",Vector3.new(width,3,14),CFrame.new(0,WALL_HEIGHT+1.5,z),railColor,Enum.Material.Neon,false)
		return
	end
	local side=(width-openingWidth)/2
	for _,direction in ipairs({-1,1}) do
		local x=direction*(openingWidth/2+side/2)
		part(parent,name.."Wall"..direction,Vector3.new(side,WALL_HEIGHT,thickness),CFrame.new(x,y,z),color,Enum.Material.Brick,true)
		part(parent,name.."Rail"..direction,Vector3.new(side,3,14),CFrame.new(x,WALL_HEIGHT+1.5,z),railColor,Enum.Material.Neon,false)
	end
end

local function plotBorder(parent,index,center,color)
	local width,depth=170,132 local rail=4 local y=1.5
	part(parent,"Plot"..index,Vector3.new(width,.4,depth),CFrame.new(center+Vector3.new(0,.22,0)),Color3.fromRGB(115,231,52),Enum.Material.Grass,true)
	part(parent,"Plot"..index.."L",Vector3.new(rail,3,depth),CFrame.new(center+Vector3.new(-width/2,y,0)),color,Enum.Material.Neon,false)
	part(parent,"Plot"..index.."R",Vector3.new(rail,3,depth),CFrame.new(center+Vector3.new(width/2,y,0)),color,Enum.Material.Neon,false)
	part(parent,"Plot"..index.."F",Vector3.new(width,3,rail),CFrame.new(center+Vector3.new(0,y,-depth/2)),color,Enum.Material.Neon,false)
	part(parent,"Plot"..index.."B",Vector3.new(width,3,rail),CFrame.new(center+Vector3.new(0,y,depth/2)),color,Enum.Material.Neon,false)
end

local function arch(parent,zone,center)
	local color=zone.Rail
	part(parent,zone.Name.."ArchLeft",Vector3.new(12,32,12),CFrame.new(center+Vector3.new(-LANE_WIDTH/2+16,16,0)),color,Enum.Material.Neon,true)
	part(parent,zone.Name.."ArchRight",Vector3.new(12,32,12),CFrame.new(center+Vector3.new(LANE_WIDTH/2-16,16,0)),color,Enum.Material.Neon,true)
	local beam=part(parent,zone.Name.."ArchBeam",Vector3.new(LANE_WIDTH-20,10,12),CFrame.new(center+Vector3.new(0,31,0)),Color3.fromRGB(25,30,39),Enum.Material.Metal,true)
	label(beam,zone.Name,zone.Rail,UDim2.fromOffset(300,65))
end

local function decorateZone(parent,zone,index,center)
	local rng=Random.new(8000+index)
	if zone.Name=="FOREST" then
		for i=1,14 do local x=rng:NextNumber(-115,115) local z=rng:NextNumber(-95,95) local trunk=part(parent,"ForestTrunk"..i,Vector3.new(5,rng:NextNumber(10,18),5),CFrame.new(center+Vector3.new(x,7,z)),Color3.fromRGB(104,67,38),Enum.Material.Wood,true)
			part(parent,"ForestCrown"..i,Vector3.new(15,15,15),trunk.CFrame*CFrame.new(0,trunk.Size.Y/2+6,0),Color3.fromRGB(43,129,52),Enum.Material.Grass,false) end
	elseif zone.Name=="JUNGLE" then
		part(parent,"JunglePond",Vector3.new(92,.35,66),CFrame.new(center+Vector3.new(65,.25,10)),Color3.fromRGB(42,155,195),Enum.Material.Glass,false,.18)
		for i=1,9 do local h=rng:NextNumber(8,18) local x=rng:NextNumber(-115,-20) local z=rng:NextNumber(-95,95) part(parent,"JungleRise"..i,Vector3.new(rng:NextNumber(12,25),h,rng:NextNumber(12,25)),CFrame.new(center+Vector3.new(x,h/2,z)),Color3.fromRGB(65,128,55),Enum.Material.Grass,true) end
	elseif zone.Name=="ICE" then
		for i=1,12 do local h=rng:NextNumber(7,25) local x=rng:NextNumber(-120,120) local z=rng:NextNumber(-100,100) local ice=part(parent,"IcePeak"..i,Vector3.new(rng:NextNumber(5,11),h,rng:NextNumber(5,11)),CFrame.new(center+Vector3.new(x,h/2,z))*CFrame.Angles(0,0,rng:NextNumber(-.18,.18)),Color3.fromRGB(172,229,245),Enum.Material.Ice,true,.08) end
	elseif zone.Name=="VOLCANO" then
		part(parent,"LavaRiver",Vector3.new(55,.5,SECTION_LENGTH-30),CFrame.new(center+Vector3.new(42,.3,0))*CFrame.Angles(0,.12,0),Color3.fromRGB(255,76,18),Enum.Material.Neon,false)
		for i=1,12 do local h=rng:NextNumber(3,14) part(parent,"VolcanicRock"..i,Vector3.new(rng:NextNumber(7,18),h,rng:NextNumber(7,18)),CFrame.new(center+Vector3.new(rng:NextNumber(-115,115),h/2,rng:NextNumber(-105,105))),Color3.fromRGB(63,49,48),Enum.Material.Slate,true) end
	elseif zone.Name=="OCEAN" then
		for i=1,7 do local x=rng:NextNumber(-105,105) local z=rng:NextNumber(-100,100) part(parent,"SandIsland"..i,Vector3.new(rng:NextNumber(26,58),2,rng:NextNumber(24,52)),CFrame.new(center+Vector3.new(x,1.1,z)),Color3.fromRGB(223,194,128),Enum.Material.Sand,true) end
	elseif zone.Name=="PREHISTORIC" then
		for i=1,10 do local h=rng:NextNumber(6,20) part(parent,"DesertRock"..i,Vector3.new(rng:NextNumber(9,28),h,rng:NextNumber(8,22)),CFrame.new(center+Vector3.new(rng:NextNumber(-115,115),h/2,rng:NextNumber(-100,100))),Color3.fromRGB(151,100,59),Enum.Material.Sandstone,true) end
	else
		for i=1,28 do local star=part(parent,"Star"..i,Vector3.new(rng:NextNumber(1,3),.2,rng:NextNumber(1,3)),CFrame.new(center+Vector3.new(rng:NextNumber(-125,125),.25,rng:NextNumber(-110,110))),i%4==0 and Color3.fromRGB(197,95,255) or Color3.fromRGB(225,240,255),Enum.Material.Neon,false) star.Shape=Enum.PartType.Ball end
	end
end

local old=Workspace:FindFirstChild(MAP_NAME) if old then old:Destroy() end
local map=Instance.new("Model") map.Name=MAP_NAME map.Parent=Workspace

part(map,"HubIsland",HUB_SIZE,CFrame.new(HUB_CENTER+Vector3.new(0,-12,0)),Color3.fromRGB(151,94,52),Enum.Material.Sandstone,true)
part(map,"HubGrass",Vector3.new(HUB_SIZE.X-20,.5,HUB_SIZE.Z-20),CFrame.new(HUB_CENTER+Vector3.new(0,.25,0)),Color3.fromRGB(105,237,39),Enum.Material.Grass,true)
border(map,"Hub",HUB_CENTER,HUB_SIZE,Color3.fromRGB(151,96,57),Color3.fromRGB(47,255,65))
endWall(map,"HubNorth",HUB_CENTER.Z+HUB_SIZE.Z/2-6,HUB_SIZE.X,Color3.fromRGB(151,96,57),Color3.fromRGB(47,255,65))
endWall(map,"HubSouth",HUB_CENTER.Z-HUB_SIZE.Z/2+6,HUB_SIZE.X,Color3.fromRGB(151,96,57),Color3.fromRGB(47,255,65),LANE_WIDTH)

local plotPositions={Vector3.new(-205,0,385),Vector3.new(0,0,385),Vector3.new(205,0,385),Vector3.new(-205,0,215),Vector3.new(0,0,215),Vector3.new(205,0,215)}
local plotColors={Color3.fromRGB(255,78,72),Color3.fromRGB(63,151,255),Color3.fromRGB(255,201,62),Color3.fromRGB(179,82,238),Color3.fromRGB(52,224,137),Color3.fromRGB(255,125,43)}
for index,position in ipairs(plotPositions) do plotBorder(map,index,position,plotColors[index]) end

local spawn=Instance.new("SpawnLocation") spawn.Name="TerrainSpawn" spawn.Size=Vector3.new(14,1,14) spawn.Position=Vector3.new(0,1,500) spawn.Color=Color3.fromRGB(255,255,255) spawn.Material=Enum.Material.Neon spawn.Anchored=true spawn.Neutral=true spawn.Parent=map

local corridorStart=50
for index,zone in ipairs(ZONES) do
	local center=Vector3.new(0,0,corridorStart-(index-.5)*SECTION_LENGTH)
	part(map,zone.Name.."Island",Vector3.new(LANE_WIDTH,24,SECTION_LENGTH),CFrame.new(center+Vector3.new(0,-12,0)),Color3.fromRGB(126,78,46),Enum.Material.Sandstone,true)
	part(map,zone.Name.."Floor",Vector3.new(LANE_WIDTH-22,.5,SECTION_LENGTH),CFrame.new(center+Vector3.new(0,.25,0)),zone.Floor,zone.Name=="ICE" and Enum.Material.Ice or (zone.Name=="PREHISTORIC" and Enum.Material.Sand or Enum.Material.SmoothPlastic),true)
	border(map,zone.Name,center,Vector3.new(LANE_WIDTH,0,SECTION_LENGTH),zone.Wall,zone.Rail)
	arch(map,zone,Vector3.new(0,0,center.Z+SECTION_LENGTH/2-8)) decorateZone(map,zone,index,center)
end

local finishZ=corridorStart-#ZONES*SECTION_LENGTH-180
part(map,"FinishIsland",Vector3.new(460,24,340),CFrame.new(0,-12,finishZ),Color3.fromRGB(145,90,52),Enum.Material.Sandstone,true)
part(map,"FinishFloor",Vector3.new(440,.5,320),CFrame.new(0,.25,finishZ),Color3.fromRGB(105,237,39),Enum.Material.Grass,true)
border(map,"Finish",Vector3.new(0,0,finishZ),Vector3.new(460,0,340),Color3.fromRGB(146,92,55),Color3.fromRGB(51,255,67))
endWall(map,"FinishNorth",finishZ+170-6,460,Color3.fromRGB(146,92,55),Color3.fromRGB(51,255,67),LANE_WIDTH)
endWall(map,"FinishSouth",finishZ-170+6,460,Color3.fromRGB(146,92,55),Color3.fromRGB(51,255,67))

Lighting.ClockTime=14 Lighting.Brightness=2.2 Lighting.Ambient=Color3.fromRGB(135,145,165) Lighting.OutdoorAmbient=Color3.fromRGB(160,170,185)
Workspace.FallenPartsDestroyHeight=-150
print("[Football Terrain] Reference graybox loaded")

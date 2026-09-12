-- Original, stylized Polo rally body. Pure decoration: A-Chassis welds Body
-- and each wheel's Parts during initialization. Never alter chassis geometry.
return function(car)
 local seat = car.DriveSeat
 local frame = seat.CFrame
 local body = Instance.new("Model")
 body.Name = "PoloRallyBody"
 body.Parent = car.Body
 local white = Color3.fromRGB(235, 240, 246)
 local blue = Color3.fromRGB(20, 67, 166)
 local cyan = Color3.fromRGB(32, 174, 220)
 local black = Color3.fromRGB(20, 24, 30)
 local glass = Color3.fromRGB(63, 91, 110)
 local function part(name, size, cf, color, parent)
  local p = Instance.new("Part")
  p.Name = name
  p.Size = size
  p.CFrame = frame * cf
  p.Color = color
  p.Material = Enum.Material.SmoothPlastic
  p.Anchored = true
  p.Massless = true
  p.CanCollide = false
  p.CanTouch = false
  p.CanQuery = false
  p.TopSurface = Enum.SurfaceType.Smooth
  p.BottomSurface = Enum.SurfaceType.Smooth
  p.Parent = parent or body
  return p
 end
 local function box(name, x,y,z, sx,sy,sz, color)
  return part(name, Vector3.new(sx,sy,sz), CFrame.new(x,y,z), color)
 end
 local function beam(name, a, b, width, depth, color)
  return part(name, Vector3.new(width,depth,(b-a).Magnitude), CFrame.lookAt((a+b)/2,b), color)
 end
 local function label(p, face, text, color)
  local gui = Instance.new("SurfaceGui")
  gui.Name = "Livery"
  gui.Face = face
  gui.CanvasSize = Vector2.new(500,180)
  gui.Parent = p
  local t = Instance.new("TextLabel")
  t.Size = UDim2.fromScale(1,1)
  t.BackgroundTransparency = 1
  t.Text = text
  t.TextColor3 = color
  t.TextScaled = true
  t.Font = Enum.Font.GothamBold
  t.Parent = gui
 end
 -- Hollow cabin, tapered hood and hatch. Leave the seated avatar room.
 box("Floor",0,-0.22,0, 5.8,0.18,12.8,black)
 box("Hood",0,1.35,-4.95, 6.05,0.28,3.65,white)
 box("HoodStripe",0,1.53,-4.95, 1.25,0.06,3.6,blue)
 box("Nose",0,0.6,-6.86, 6.35,1.15,0.38,white)
 box("FrontSplitter",0,-0.12,-7.05, 6.95,0.18,0.75,black)
 box("MainGrille",0,0.35,-7.10, 3.8,0.65,0.12,black)
 box("UpperGrille",0,1.02,-7.10, 3.5,0.26,0.12,black)
 local badge = box("FrontBadge",0,1.03,-7.19,0.55,0.42,0.06,blue)
 label(badge,Enum.NormalId.Front,"VW",white)
 for _,s in ipairs({-1,1}) do
  box("Headlight",s*2.42,1.02,-7.12,1.18,0.3,0.16,Color3.fromRGB(225,242,255))
  box("BrakeDuct",s*2.63,0.35,-7.12,0.65,0.52,0.16,black)
  box("Door",s*3.03,0.73,0,0.18,1.5,6.15,white)
  box("Sill",s*3.2,-0.05,0,0.38,0.3,6.3,blue)
  box("RallyStripe",s*3.17,0.55,0,0.08,0.44,5.8,blue)
  box("AccentStripe",s*3.23,0.88,0,0.06,0.12,5.8,cyan)
  local number = box("DoorNumber",s*3.24,1.18,0.2,0.06,0.52,1.3,blue)
  label(number,s == 1 and Enum.NormalId.Right or Enum.NormalId.Left,"21",white)
  box("Handle",s*3.18,1.35,1.45,0.12,0.12,0.5,black)
  beam("APillar",Vector3.new(s*2.95,1.55,-3.1),Vector3.new(s*2.48,3.72,-1.5),0.18,0.18,white)
  beam("RearPillar",Vector3.new(s*2.48,3.72,3.65),Vector3.new(s*3.0,1.5,5.65),0.38,0.22,white)
  beam("RoofRail",Vector3.new(s*2.5,3.78,-1.5),Vector3.new(s*2.5,3.78,3.7),0.17,0.18,white)
  box("BPillar",s*2.75,2.62,0.95,0.19,2.08,0.18,black)
  box("WindowSill",s*3.01,1.56,0.8,0.18,0.15,7.5,black)
  box("MirrorArm",s*3.22,1.92,-2.4,0.62,0.12,0.16,black)
  box("Mirror",s*3.54,2.03,-2.4,0.46,0.32,0.68,blue)
  -- Open wheel arches: trim follows only the upper semicircle.
  for _,z in ipairs({-5,5}) do
   for i=0,9 do
    local a,b = math.pi*i/10,math.pi*(i+1)/10
    beam("WideArch",Vector3.new(s*3.34,math.sin(a)*1.52,z+math.cos(a)*1.52),
     Vector3.new(s*3.34,math.sin(b)*1.52,z+math.cos(b)*1.52),0.62,0.22,white)
   end
   box("Mudflap",s*2.92,-0.5,z+1.4,1.15,0.95,0.12,black)
  end
 end
 box("Roof",0,3.83,1.08,5.12,0.18,5.5,white)
 box("RoofStripe",0,3.96,1.08,1.25,0.06,5.4,blue)
 box("RoofScoop",0,4.08,-0.5,1.35,0.25,1.2,blue)
 box("ScoopIntake",0,4.09,-1.13,1.07,0.16,0.08,black)
 local windshield = beam("Windshield",Vector3.new(0,1.66,-3.07),Vector3.new(0,3.66,-1.59),4.86,0.08,glass)
 windshield.Transparency = 0.48
 local rear = beam("RearGlass",Vector3.new(0,3.63,3.77),Vector3.new(0,1.73,5.57),4.84,0.08,glass)
 rear.Transparency = 0.3
 box("Hatch",0,1.02,6.39,6.05,1.22,0.4,white)
 box("RearBumper",0,0.07,6.69,6.6,0.6,0.55,blue)
 box("Diffuser",0,-0.3,6.85,4.5,0.18,0.7,black)
 local plate = box("PoloPlate",0,0.85,6.65,2.0,0.4,0.08,black)
 label(plate,Enum.NormalId.Back,"POLO RALLY",white)
 for _,s in ipairs({-1,1}) do
  box("TailLight",s*2.3,1.33,6.65,1.35,0.3,0.13,Color3.fromRGB(205,22,38))
  box("SpoilerSupport",s*2.0,3.64,4.8,0.14,0.8,0.3,black)
  box("SpoilerEnd",s*3.23,4.12,4.95,0.14,0.57,1.05,blue)
 end
 box("RearWing",0,4.05,4.95,6.5,0.16,1.05,black)
 seat.Transparency = 1
 -- Wheels keep their original collision, mass, dimensions and position.
 for _,wheel in ipairs(car.Wheels:GetChildren()) do
  if wheel:IsA("BasePart") then
   wheel.Color = Color3.fromRGB(24,24,26)
   wheel.Transparency = 0
   local decorations = wheel:FindFirstChild("Parts")
   if not decorations then
    decorations = Instance.new("Model")
    decorations.Name = "Parts"
    decorations.Parent = wheel
   end
   local localPos = frame:PointToObjectSpace(wheel.CFrame.Position)
   local s = localPos.X > 0 and 1 or -1
   local hub = CFrame.new(localPos + Vector3.new(s*(wheel.Size.X/2+0.08),0,0))
   local rim = part("RallyRim",Vector3.new(0.12,1.76,1.76),hub,black,decorations)
   rim.Shape = Enum.PartType.Cylinder
   for i=0,11 do
    part("Spoke",Vector3.new(0.14,0.75,0.10),hub*CFrame.Angles(i*math.pi/6,0,0)*CFrame.new(0,0.43,0),white,decorations)
   end
   local cap = part("Hub",Vector3.new(0.18,0.35,0.35),hub,blue,decorations)
   cap.Shape = Enum.PartType.Cylinder
  end
 end
end

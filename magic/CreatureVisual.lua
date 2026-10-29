-- Original low-poly magical treasure creature; no external assets or scripts.
local Visual={}
function Visual.Create(parent,transform)
 local model=Instance.new("Model") model.Name="Pelucio"
 local function piece(name,size,offset,color,shape)
  local p=Instance.new("Part") p.Name=name p.Size=size
  p.CFrame=transform*CFrame.new(offset) p.Color=color p.Shape=shape or Enum.PartType.Ball
  p.Material=Enum.Material.SmoothPlastic p.Anchored=true p.CanCollide=false
  p.CanTouch=false p.CanQuery=false p.Massless=true p.Parent=model
  return p
 end
 local dark=Color3.fromRGB(47,39,60)
 local gold=Color3.fromRGB(248,190,48)
 local root=piece("Body",Vector3.new(2.5,2.8,2),Vector3.new(0,0,0),dark)
 model.PrimaryPart=root
 piece("Head",Vector3.new(2.1,1.8,1.8),Vector3.new(0,1.6,-.3),dark)
 piece("Snout",Vector3.new(1.5,.65,1.2),Vector3.new(0,1.3,-1.35),Color3.fromRGB(165,119,100))
 piece("Pouch",Vector3.new(1.65,1.4,.65),Vector3.new(0,-.25,-.95),Color3.fromRGB(115,78,62))
 for _,side in ipairs({-1,1}) do
  piece("Ear",Vector3.new(.6,.7,.4),Vector3.new(side*.9,2.3,-.1),dark)
  piece("Eye",Vector3.new(.35,.4,.22),Vector3.new(side*.55,1.85,-1.1),Color3.new(1,1,1))
  piece("Pupil",Vector3.new(.16,.22,.12),Vector3.new(side*.55,1.85,-1.23),Color3.new(0,0,0))
  piece("Arm",Vector3.new(.7,1.35,.7),Vector3.new(side*1.2,-.15,-.6),dark)
  piece("Foot",Vector3.new(.85,.45,1.1),Vector3.new(side*.65,-1.45,-.3),Color3.fromRGB(165,119,100))
 end
 piece("GoldCoin",Vector3.new(.7,.7,.18),Vector3.new(0,.1,-1.35),gold)
 piece("Tail",Vector3.new(.8,.7,1.6),Vector3.new(0,-.8,1.2),dark)
 model.Parent=parent
 return model
end
function Visual.Carry(model,root)
 model:PivotTo(root.CFrame*CFrame.new(0,1,-2.5))
 for _,p in ipairs(model:GetDescendants()) do
  if p:IsA("BasePart") then
   p.Anchored=false
   local weld=Instance.new("WeldConstraint") weld.Part0=root weld.Part1=p weld.Parent=p
  end
 end
end
return Visual

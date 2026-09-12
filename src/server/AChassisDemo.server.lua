-- Integration only: the vendor chassis, physics and mobile UI remain original.
local ServerStorage = game:GetService("ServerStorage")
local world = workspace:WaitForChild("EmpireStateWorld", 30)
if not world or not world:WaitForChild("Ground", 30) then
	warn("[roblox_game] A-Chassis: ground unavailable")
	return
end

local template = ServerStorage:WaitForChild("AChassisTemplate", 30)
if not template then return end
local car = template:Clone()
car.Name = "AChassisDemo"
local seat = car:FindFirstChild("DriveSeat")
assert(seat and seat:IsA("VehicleSeat"), "A-Chassis DriveSeat missing")

-- Position before parenting so Initialize runs only at the final spawn point.
car.PrimaryPart = seat
car:PivotTo(CFrame.new(-58, 6, 154))
local box, size = car:GetBoundingBox()
car:PivotTo(car:GetPivot() + Vector3.new(0, 0.5 - (box.Position.Y - size.Y / 2), 0))

local prompt = Instance.new("ProximityPrompt")
prompt.Name = "EnterAChassis"
prompt.ActionText = "Dirigir"
prompt.ObjectText = "A-Chassis • carro de teste"
prompt.MaxActivationDistance = 14
prompt.RequiresLineOfSight = false
prompt.Enabled = false
prompt.Parent = seat
local function updatePrompt()
	prompt.Enabled = not seat.Disabled and seat.Occupant == nil
end
seat:GetPropertyChangedSignal("Disabled"):Connect(updatePrompt)
seat:GetPropertyChangedSignal("Occupant"):Connect(updatePrompt)
prompt.Triggered:Connect(function(player)
	if seat.Disabled or seat.Occupant then return end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if humanoid and root and humanoid.Health > 0 and not humanoid.SeatPart
		and (root.Position - seat.Position).Magnitude <= 18 then
		seat:Sit(humanoid)
	end
end)
car.Parent = world
print("[roblox_game] A-Chassis 1.7.2 demo added; native mobile controls enabled.")

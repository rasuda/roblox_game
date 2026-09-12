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
car.Name = "LowPolyAChassis"
local seat = car:FindFirstChild("DriveSeat")
assert(seat and seat:IsA("VehicleSeat"), "A-Chassis DriveSeat missing")

-- Mobile landscape layout: native driving buttons remain in the lower corners,
-- with the dashboard just above Controls and diagnostics at the screen sides.
local tune = car:FindFirstChild("A-Chassis Tune")
local plugins = tune and tune:FindFirstChild("Plugins")
if plugins then
	local tires = plugins:FindFirstChild("Tires")
	local gForces = plugins:FindFirstChild("GForces")
	if tires and tires:IsA("GuiObject") then
		tires.Visible = true
		tires.AnchorPoint = Vector2.new(0, 0)
		tires.Position = UDim2.fromScale(0, 0)
		tires.Size = UDim2.fromScale(1, 1)
		local tireDisplay = tires:FindFirstChild("Tires")
		if tireDisplay and tireDisplay:IsA("GuiObject") then
			tireDisplay.AnchorPoint = Vector2.new(0.5, 0.5)
			tireDisplay.Position = UDim2.fromScale(0.10, 0.50)
			tireDisplay.Size = UDim2.fromScale(0.031, 0.061)
		end
	end
	if gForces and gForces:IsA("GuiObject") then
		gForces.Visible = true
		gForces.AnchorPoint = Vector2.new(0, 0)
		gForces.Position = UDim2.fromScale(0, 0)
		gForces.Size = UDim2.fromScale(1, 1)
		local accelerometer = gForces:FindFirstChild("Frame")
		if accelerometer and accelerometer:IsA("GuiObject") then
			accelerometer.AnchorPoint = Vector2.new(0.5, 0.5)
			accelerometer.Position = UDim2.fromScale(0.90, 0.50)
			accelerometer.Size = UDim2.fromScale(0.28, 0.123)
		end
	end

	local gauges = plugins:FindFirstChild("Gauges")
	local advanced = gauges and gauges:FindFirstChild("Advanced")
	if advanced and advanced:IsA("GuiObject") then
		advanced.AnchorPoint = Vector2.new(0.5, 1)
		advanced.Position = UDim2.fromScale(0.5, 0.90)
		advanced.Size = UDim2.fromScale(0.28, 0.175)
	end
end

-- Keep mobile steering in Tap mode. Drive starts in Tap mode; making the
-- selector inert prevents switching to Tilt while preserving vendor scripts.
local interface = tune and tune:FindFirstChild("A-Chassis Interface")
local mobile = interface and interface:FindFirstChild("Mobile")
local modeSwitch = mobile and mobile:FindFirstChild("ModeSwitch")
if modeSwitch and modeSwitch:IsA("GuiButton") then
	modeSwitch.Active = false
	modeSwitch.Selectable = false
	modeSwitch.Size = UDim2.fromOffset(0, 0)
	modeSwitch.BackgroundTransparency = 1
	modeSwitch.TextTransparency = 1
	modeSwitch.BorderSizePixel = 0
end

-- Position before parenting so Initialize runs only at the final spawn point.
car.PrimaryPart = seat
car:PivotTo(CFrame.new(-58, 6, 154))
local box, size = car:GetBoundingBox()
car:PivotTo(car:GetPivot() + Vector3.new(0, 0.5 - (box.Position.Y - size.Y / 2), 0))

local prompt = Instance.new("ProximityPrompt")
local bodyLoaded = require(script.Parent.LowPolyCarBody)(car)
if not bodyLoaded then
	warn("[roblox_game] Low-poly asset unavailable; using safe local body.")
	require(script.Parent.PoloRallyBody)(car)
end
prompt.Name = "EnterAChassis"
prompt.ActionText = "Dirigir"
prompt.ObjectText = bodyLoaded and "Carro esportivo" or "Polo Rally (reserva)"
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
print("[roblox_game] Low-poly body loaded on A-Chassis 1.7.2 with native mobile controls.")

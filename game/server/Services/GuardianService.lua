local RunService = game:GetService("RunService")

local GuardianService = {}
GuardianService.Context = nil
GuardianService.Model = nil
GuardianService.Home = nil
GuardianService.Targets = {}
GuardianService.State = "IDLE"
GuardianService.AlertUntil = 0

local function makePart(parent, name, size, cframe, color)
	local object = Instance.new("Part")
	object.Name = name
	object.Size = size
	object.CFrame = cframe
	object.Color = color
	object.Material = Enum.Material.SmoothPlastic
	object.Anchored = true
	object.CanCollide = false
	object.Parent = parent
	return object
end

function GuardianService:SetState(state)
	self.State = state
	if self.Model then self.Model:SetAttribute("State", state) end
end

function GuardianService:Build()
	local zone = self.Context.Config.Zones.Street
	self.Home = zone.GuardianSpawn
	local model = Instance.new("Model")
	model.Name = "StreetGuardian"
	model.Parent = self.Context.Services.Club.World.Guardians
	local root = makePart(model, "Root", Vector3.new(4, 6, 3), CFrame.new(self.Home), Color3.fromRGB(38, 43, 55))
	makePart(model, "Head", Vector3.new(3.4, 3.4, 3.4), CFrame.new(self.Home + Vector3.new(0, 4.7, 0)), Color3.fromRGB(204, 158, 117))
	makePart(model, "Vest", Vector3.new(4.4, 2.2, 3.3), CFrame.new(self.Home + Vector3.new(0, 1, 0)), Color3.fromRGB(245, 176, 45))
	model.PrimaryPart = root
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(190, 52)
	gui.StudsOffset = Vector3.new(0, 7.4, 0)
	gui.AlwaysOnTop = true
	gui.Parent = root
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1,1)
	label.BackgroundColor3 = Color3.fromRGB(18,22,30)
	label.BackgroundTransparency = 0.15
	label.Text = "GUARDIAN"
	label.TextColor3 = Color3.fromRGB(255,198,65)
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.Parent = gui
	self.Model = model
	self:SetState(self.Context.Constants.GuardianState.IDLE)
end

function GuardianService:AddTarget(player)
	self.Targets[player] = true
	self.AlertUntil = os.clock() + 0.55
	self:SetState(self.Context.Constants.GuardianState.ALERT)
end

function GuardianService:RemoveTarget(player)
	self.Targets[player] = nil
end

function GuardianService:GetNearestTarget(position)
	local nearest, nearestDistance
	for player in pairs(self.Targets) do
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if not player.Parent or not root or not humanoid or humanoid.Health <= 0 or self.Context.Services.Club:IsInOwnSafeZone(player, root.Position) then
			self.Targets[player] = nil
		else
			local distance = (root.Position - position).Magnitude
			if not nearestDistance or distance < nearestDistance then nearest, nearestDistance = player, distance end
		end
	end
	return nearest, nearestDistance
end

function GuardianService:MoveToward(targetPosition, speed, deltaTime)
	local current = self.Model:GetPivot().Position
	local flatTarget = Vector3.new(targetPosition.X, self.Home.Y, targetPosition.Z)
	local offset = flatTarget - current
	if offset.Magnitude < 0.05 then return true end
	local movement = math.min(offset.Magnitude, speed * deltaTime)
	local nextPosition = current + offset.Unit * movement
	self.Model:PivotTo(CFrame.lookAt(nextPosition, flatTarget))
	return offset.Magnitude <= movement + 0.1
end

function GuardianService:Tick(deltaTime)
	if not self.Model then return end
	local current = self.Model:GetPivot().Position
	local target, distance = self:GetNearestTarget(current)
	if target then
		if os.clock() < self.AlertUntil then return end
		self:SetState(self.Context.Constants.GuardianState.CHASE)
		local root = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
		if not root then return end
		if distance and distance <= self.Context.Config.Game.GuardianHitRadius then
			self:SetState(self.Context.Constants.GuardianState.ATTACK)
			self.Context.Services.Contracts:Drop(target, "Guardian")
			local away = root.Position - current
			if away.Magnitude < 0.05 then away = root.CFrame.LookVector else away = away.Unit end
			root.AssemblyLinearVelocity += away * 34 + Vector3.new(0, 18, 0)
			self:RemoveTarget(target)
			return
		end
		self:MoveToward(root.Position, self.Context.Config.Zones.Street.GuardianSpeed, deltaTime)
	else
		if (current - self.Home).Magnitude > 1 then
			self:SetState(self.Context.Constants.GuardianState.RETURN)
			if self:MoveToward(self.Home, self.Context.Config.Zones.Street.GuardianSpeed * 0.85, deltaTime) then
				self:SetState(self.Context.Constants.GuardianState.IDLE)
			end
		else
			self:SetState(self.Context.Constants.GuardianState.IDLE)
		end
	end
end

function GuardianService:Init(context)
	self.Context = context
	self:Build()
	local accumulator = 0
	RunService.Heartbeat:Connect(function(deltaTime)
		accumulator += deltaTime
		if accumulator >= context.Config.Game.GuardianTickSeconds then
			self:Tick(accumulator)
			accumulator = 0
		end
	end)
end

return GuardianService

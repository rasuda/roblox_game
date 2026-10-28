local Players=game:GetService("Players")
local map=workspace:WaitForChild("FootballTerrain")
while not map:GetAttribute("Ready") do map:GetAttributeChangedSignal("Ready"):Wait() end

local bases={}
local assigned={}
local connections={}
local function update(base,player)
	base.owner=player
	base.model:SetAttribute("OwnerUserId",player and player.UserId or 0)
	base.model:SetAttribute("OwnerName",player and player.Name or "")
	base.text.Text=player and ("Clube de "..player.DisplayName.."\n@"..player.Name) or "Base disponível"
end

for _,index in ipairs({1,2,3,4,6}) do
	local model=map:WaitForChild("Castle"..index)
	local foundation=model:FindFirstChild("Foundation")
	local spawn=Instance.new("SpawnLocation")
	spawn.Name="OwnerSpawn" spawn.Size=Vector3.new(6,1,6)
	spawn.CFrame=foundation.CFrame*CFrame.new(0,1,-7)
	spawn.Anchored=true spawn.Transparency=1 spawn.CanCollide=false
	spawn.CanTouch=false spawn.CanQuery=false spawn.Enabled=false spawn.Duration=0
	spawn.Parent=model
	local sign=Instance.new("Part") sign.Name="OwnershipSign"
	sign.Size=Vector3.new(1,1,1) sign.CFrame=foundation.CFrame*CFrame.new(0,11,-13)
	sign.Anchored=true sign.Transparency=1 sign.CanCollide=false sign.CanTouch=false sign.CanQuery=false sign.Parent=model
	local gui=Instance.new("BillboardGui") gui.Size=UDim2.fromOffset(170,44)
	gui.MaxDistance=75 gui.AlwaysOnTop=false gui.Parent=sign
	local text=Instance.new("TextLabel") text.Size=UDim2.fromScale(1,1)
	text.BackgroundColor3=Color3.fromRGB(25,30,39) text.BackgroundTransparency=.2
	text.TextColor3=Color3.new(1,1,1) text.TextSize=15 text.Font=Enum.Font.GothamBold text.Parent=gui
	local base={model=model,spawn=spawn,text=text}
	update(base,nil) table.insert(bases,base)
end

local function place(player,character)
	local root=character:WaitForChild("HumanoidRootPart",10)
	local base=assigned[player]
	if root and base and player.Parent==Players and player.Character==character then
		character:PivotTo(base.spawn.CFrame*CFrame.new(0,3,0))
		root.AssemblyLinearVelocity=Vector3.zero
	end
end

local function assign(player)
	if assigned[player] or player.Parent~=Players then return end
	for _,base in ipairs(bases) do
		if not base.owner then
			-- Reserve synchronously before any yielding operation.
			assigned[player]=base update(base,player)
			player:SetAttribute("BaseName",base.model.Name)
			player:SetAttribute("WaitingForBase",false)
			-- Disabled for random spawning; explicit RespawnLocation reserves it.
			player.RespawnLocation=base.spawn
			if player.Character then task.spawn(place,player,player.Character) end
			return
		end
	end
	player:SetAttribute("WaitingForBase",true)
end

local function joined(player)
	if connections[player] then return end
	connections[player]=player.CharacterAdded:Connect(function(character) place(player,character) end)
	assign(player)
end
Players.PlayerAdded:Connect(joined)
Players.PlayerRemoving:Connect(function(player)
	if connections[player] then connections[player]:Disconnect() connections[player]=nil end
	local base=assigned[player]
	assigned[player]=nil player.RespawnLocation=nil
	if base then update(base,nil) end
	for _,waiting in ipairs(Players:GetPlayers()) do
		if waiting~=player and not assigned[waiting] then assign(waiting) end
	end
end)
for _,player in ipairs(Players:GetPlayers()) do joined(player) end

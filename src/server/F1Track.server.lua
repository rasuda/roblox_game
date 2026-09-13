-- Loads the complete Creator Store model after it was added to the experience
-- owner's inventory. Unknown scripts are preserved but disabled until audited.
local InsertService = game:GetService("InsertService")
local Workspace = game:GetService("Workspace")

local ASSET_ID = 17410228045
local TARGET_MAX_SPAN = 600
local TRACK_CENTER = Vector3.new(-420, 0, -380)

local world = Workspace:WaitForChild("EmpireStateWorld", 30)
if not world then
	warn("[roblox_game] F1 track: world unavailable")
	return
end

-- Main finishes the mountain perimeter before this script reserves a flat
-- southwest basin for the circuit.
world:WaitForChild("MountainBoundaries", 30)
Workspace.Terrain:FillBlock(
	CFrame.new(TRACK_CENTER.X, 145, TRACK_CENTER.Z),
	Vector3.new(720, 300, 720),
	Enum.Material.Air
)

local ok, track = pcall(InsertService.LoadAsset, InsertService, ASSET_ID)
if not ok or not track then
	warn("[roblox_game] F1 track could not be loaded:", track)
	return
end

track.Name = "F1RacingTrackMap_THE_OOFDOGI"

local scriptCount = 0
for _, object in track:GetDescendants() do
	if object:IsA("BaseScript") then
		scriptCount += 1
		object.Disabled = true
	end
end

local sourceBox, sourceSize = track:GetBoundingBox()
local horizontalSpan = math.max(sourceSize.X, sourceSize.Z)
if horizontalSpan < 0.01 then
	track:Destroy()
	warn("[roblox_game] F1 track has invalid dimensions")
	return
end

-- Only reduce oversized models. Never enlarge the road because that would
-- make its proportions inconsistent with the A-Chassis car.
if horizontalSpan > TARGET_MAX_SPAN then
	track:ScaleTo(TARGET_MAX_SPAN / horizontalSpan)
end

local boxCF, boxSize = track:GetBoundingBox()
local boxToPivot = boxCF:ToObjectSpace(track:GetPivot())
local desiredBox = CFrame.new(TRACK_CENTER.X, 0.18 + boxSize.Y / 2, TRACK_CENTER.Z)
track:PivotTo(desiredBox * boxToPivot)
track.Parent = world

print(string.format(
	"[roblox_game] F1 track loaded: %.1f x %.1f studs; %d external scripts preserved disabled.",
	boxSize.X,
	boxSize.Z,
	scriptCount
))

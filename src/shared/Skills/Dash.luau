--[[
	Dash - Creates thin diagonal neon lines as the player tweens to a position 20 in front of them
]]
local Dash = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local DASH_DISTANCE = 20
local SEED = os.time() * 1000

--[[
	The Slashes Script: While the dash tween is playing, have a script generate 3-4 thin, rotated Neon parts along the path. Use a random math function (math.random) to angle them diagonally. Use TweenService on these parts to tween their Transparency to 1 and their Size on the X-axis so they look like they are stretching out and vanishing.
]]
	
-- local function createNeonPartLine()
-- end

local function dash(root: Part)
	if not root then
		return
	end

	local target: CFrame = root.CFrame * CFrame.new(0, 0, -DASH_DISTANCE)
	local tweenInfo = TweenInfo.new(
		0.5, 
		Enum.EasingStyle.Quart, 
		Enum.EasingDirection.Out
	)

	local tween = TweenService:Create(root, tweenInfo, {
		CFrame = target,
	})

	-- Disable default physics or collisions by anchoring when dashing
	root.Anchored = true
	tween:Play()

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { root }

	-- Raycast to see if something is blocking the way and cancel the tween if there is
	local raycast = workspace:Raycast(root.Position, root.CFrame.lookVector * DASH_DISTANCE, raycastParams)
	if raycast then
		root.Anchored = false
		tween:Cancel()
	end
	tween.Completed:Connect(function()
		root.Anchored = false
	end)
end

function Dash:ActionStart()
	local character = Players.LocalPlayer.Character :: Model
	local root = character:FindFirstChild("HumanoidRootPart") :: BasePart
	if not root then
		return
	end

	dash(root)
	return {
		Start = root.Position,
		End = root.Position + (root.CFrame.LookVector) * DASH_DISTANCE,
		Seed = SEED,
	}
end

function Dash:ActionBroadcast(player: Player, skill: string, clientData: { any })
end

return Dash
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
	
local function createNeonPartLine(start: CFrame, seed: number)
	-- What's awesome about seeds is I can have each player automatically rebuild this same particle position, orientation, and size by passing the seed to the server
	local random = Random.new(seed)
	local numberOfLines = random:NextInteger(10, 15)
	
	for i = 1, numberOfLines do
		local line = Instance.new("Part")
		line.Material = Enum.Material.Neon
		-- Mix of colors for depth (mostly Cyan, sometimes white)
		line.Color = random:NextNumber() > 0.8 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(93, 0, 255)
		line.Anchored = true
		line.CanCollide = false
		line.CastShadow = false
		line.CanQuery = false
		
		local x = random:NextNumber(-5, 5)
		local y = random:NextNumber(-4, 4)
		local z = random:NextNumber(0, -DASH_DISTANCE)
		
		local tiltX = math.rad(random:NextNumber(-20, 20))
		local tiltY = math.rad(random:NextNumber(-20, 20))
		
		line.CFrame = start 
			* CFrame.new(x, y, z)
			* CFrame.Angles(tiltX, tiltY, 0)
			
		local startLength = random:NextInteger(12, 60)
		local thickness = random:NextNumber(0.1, 0.3)
		line.Size = Vector3.new(thickness, thickness, startLength)
		line.Parent = workspace.VFX
		
		local highlight = Instance.new("Highlight")
		highlight.FillTransparency = 1
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.OutlineTransparency = 0.5
		highlight.Parent = line
		
		local tweenDuration = random:NextNumber(0.5, 1)
		local tweenInfo = TweenInfo.new(
			tweenDuration, 
			Enum.EasingStyle.Quart, 
			Enum.EasingDirection.Out
		)
		local endLength = random:NextInteger(2, 4)
		local goal = {
			CFrame = line.CFrame * CFrame.new(0, 0, -endLength),
			Size = Vector3.new(0, 0, endLength),
			Transparency = 1,
		}
		local tween = TweenService:Create(line, tweenInfo, goal)
		TweenService:Create(highlight, tweenInfo, { OutlineTransparency = 1 }):Play()
		tween:Play()
		
		tween.Completed:Connect(function()
			line:Destroy()
		end)
	end
end

local function dash(root: Part)
	if not root then
		return
	end

	local target: CFrame = root.CFrame * CFrame.new(0, 0, -DASH_DISTANCE)
	local tweenInfo = TweenInfo.new(
		0.2, 
		Enum.EasingStyle.Quart, 
		Enum.EasingDirection.InOut
	)
	local tween = TweenService:Create(root, tweenInfo, {
		CFrame = target,
	})

	-- Disable default physics or collisions by anchoring when dashing
	root.Anchored = true
	tween:Play()

	-- Raycast to see if something is blocking the way and cancel the tween if there is
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { root }
	local raycast = workspace:Raycast(root.Position, root.CFrame.lookVector * DASH_DISTANCE, raycastParams)
	if raycast then
		root.Anchored = false
		tween:Cancel()
		return
	end
 
	local currentSeed = os.clock() * 10000
	-- If we get past the raycast then make the lines
	createNeonPartLine(root.CFrame, currentSeed)

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
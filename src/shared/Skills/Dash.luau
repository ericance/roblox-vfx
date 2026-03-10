--[[
	Dash - Creates thin diagonal neon lines as the player tweens to a position 20 in front of them
]]
local Dash = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local DASH_DISTANCE = 30
-- local SEED = os.time() * 1000

local function createNeonPartLine(start: CFrame, seed: number)
	local random = Random.new(seed)
	local numberOfLines = random:NextInteger(10, 15)
	
	local dashLines = {}
	
	-- Create line
	for i = 1, numberOfLines do
		local line = Instance.new("Part")
		line.Material = Enum.Material.Neon
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
			
		line.Size = Vector3.new(0, 0, 0)
		line.Parent = workspace.VFX
		
		local highlight = Instance.new("Highlight")
		highlight.FillTransparency = 1
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.OutlineTransparency = 0.5
		highlight.Parent = line
		
		table.insert(dashLines, {
			Part = line,
			Highlight = highlight,
			EndLength = random:NextInteger(2, 4)
		})
		
		local growDuration = random:NextNumber(0.25, 0.5)
		local growInfo = TweenInfo.new(
			growDuration, 
			Enum.EasingStyle.Quart, 
			Enum.EasingDirection.Out
		)
		local targetLength = random:NextInteger(12, 60)
		local targetThickness = random:NextNumber(0.05, 0.1)

		TweenService:Create(line, growInfo, {
			Size = Vector3.new(targetThickness, targetThickness, targetLength) 
		}):Play()
	end

	-- Remove line
	task.spawn(function()
		-- Wait longest amount of time possible for grow tween to finish
		task.wait(0.5)

		local highlightDuration = 0.6
		local highlightInfo = TweenInfo.new(highlightDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		for _, data in dashLines do
			TweenService:Create(data.Highlight, highlightInfo, {
				OutlineTransparency = 1 
			}):Play()
		end
		task.wait(highlightDuration)
		
		local vanishDuration = 0.25
		local vanishInfo = TweenInfo.new(vanishDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		for _, data in dashLines do
			local line = data.Part
			TweenService:Create(line, vanishInfo, {
				CFrame = line.CFrame * CFrame.new(0, 0, -data.EndLength),
				Size = Vector3.new(0, 0, data.EndLength),
				Transparency = 1,
			}):Play()
		end
		task.wait(vanishDuration)
		
		for _, data in dashLines do
			data.Part:Destroy()
		end
	end)
	
	print(dashLines)
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
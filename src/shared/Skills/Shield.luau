--[[
	OrbitalShield - Creates protective shields around the player for a duration of time.
]]

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local OrbitingShield = {}
local TAU = math.pi * 2

local function cleanupShield(shields: {Model}, heartbeatConnection: RBXScriptConnection)
	-- Stop heartbeat loop
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
	end
	
	for _, shield in shields do
		if shield then
			task.spawn(function()
				local bluePart = shield.BluePart
				local whitePart = shield.WhitePart
				local tweenInfo = TweenInfo.new(
					0.5, 
					Enum.EasingStyle.Quad, 
					Enum.EasingDirection.Out
				)

				TweenService:Create(bluePart, tweenInfo, {
					Size = Vector3.new(0, 0, 0),
					Transparency = 0	
				}):Play()

				local tween = TweenService:Create(whitePart, tweenInfo, {
					Size = Vector3.new(0, 0, 0),
					Transparency = 0	
				})
				tween:Play()

				shield.Particles.White:Emit()
				shield.Particles.Shiny:Emit()

				tween.Completed:Connect(function()
					shield:Destroy()
				end)
			end)
		end
	end
	
	table.clear(shields)
end

local function spawnShield(shieldTemplate: Model)
	local shield = shieldTemplate:Clone()
	shield.Parent = workspace.VFX

	local bluePart = shield:FindFirstChild("BluePart")
	local whitePart = shield:FindFirstChild("WhitePart")

	local initialSizes = {}
	local startingWidth = 0.1

	initialSizes[bluePart] = bluePart.Size
	initialSizes[whitePart] = whitePart.Size

	bluePart.Size = Vector3.new(startingWidth, initialSizes[bluePart].Y, startingWidth)
	bluePart.Transparency = 1
	whitePart.Size = Vector3.new(startingWidth, initialSizes[whitePart].Y, startingWidth)
	whitePart.Transparency = 1

	task.spawn(function()
		task.wait(1)
		shield.Particles.White:Emit(5)
		shield.Particles.Blue:Emit(5)

		task.wait(0.1)
		local tweenInfo = TweenInfo.new(
			0.5, 
			Enum.EasingStyle.Quad, 
			Enum.EasingDirection.Out
		)

		TweenService:Create(bluePart, tweenInfo, {
			Size = initialSizes[bluePart],
			Transparency = 0	
		}):Play()

		TweenService:Create(whitePart, tweenInfo, {
			Size = initialSizes[whitePart],
			Transparency = 0	
		}):Play()

	end)

	-- Return the shield instantly so that the heartbeat loop starts right away
	return shield
end

local function activateShield(character: Model)
	local root = character:FindFirstChild("HumanoidRootPart") :: Part
	if not root then
		return
	end
	
	local shieldTemplate = workspace.VFX:FindFirstChild("Shield")
	if not shieldTemplate then
		warn("No Shield found in VFX folder")
		return
	end

	local shieldCount = 3
	local duration = 5
	local radius = 10
	local rotationSpeed = 2

	local timePassed = 0
	local activeShields = {}
	
	for i = 1, shieldCount do
		local shield = spawnShield(shieldTemplate)
		table.insert(activeShields, shield)
	end
	
	local heartbeatConnection; heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		timePassed += dt
		
		-- Check if timem ran out or the player dies/disconnects
		if timePassed >= duration or not root.Parent then
			cleanupShield(activeShields, heartbeatConnection)
			return
		end
		
		local currentRootCFrame = root.CFrame
		for i, shield in activeShields do
			local offsetAngle = (i / shieldCount) * (TAU)
			local currentAngle = (timePassed * rotationSpeed) + offsetAngle
			local x = math.cos(currentAngle) * radius
			local z = math.sin(currentAngle) * radius
			
			-- Position
			shield:PivotTo(CFrame.new(currentRootCFrame.Position + Vector3.new(x, 0, z)))
			
			-- Orientation
			shield:PivotTo(CFrame.new(shield:GetPivot().Position, currentRootCFrame.Position))
		end
	end)
end

function OrbitingShield:OnActivate()
	local character = Players.LocalPlayer.Character
	if not character then
		return
	end
	
	activateShield(character)

	return {
		TargetCharacter = character
	}
end

function OrbitingShield:OnMass()
end

return OrbitingShield
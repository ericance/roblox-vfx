--[[
	HomingMissile - A skill that fires a guided explosive after targeting a player
]]

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
	
local HomingMissile = {}

local function createCrosshair(root: BasePart)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "LockOnCrosshair"
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.new(4, 0, 4, 0)

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Size = UDim2.new(1, 0, 1, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://316279304"
	imageLabel.ImageColor3 = Color3.fromRGB(255, 0, 0)
	imageLabel.Parent = billboard

	billboard.Adornee = root
	billboard.Parent = root

	return billboard
end

local function explode(missile: Model, crosshair: BillboardGui?)
	if crosshair ~= nil then
		crosshair:Destroy()
	end
	missile:Destroy()
	-- Debris:AddItem(missile, 1)
end

local function launch(origin: CFrame, target: Model, crosshair: BillboardGui?, shooterCharacter: Model)
	local missileInstance = workspace.VFX:FindFirstChild("Missile")
	if missileInstance == nil then
		warn("No missile found in VFX folder")
		return
	end

	local missile = missileInstance:Clone()
	missile:PivotTo(origin)
	missile.Parent = workspace.VFX
	
	-- dumb fire means going forward (or up) without locking on yet
	local dumbFireDuration = 1
	local lockOnDuration  = 4
	local timePassed = 0
	local speed = 50
	local turnSpeed = 5

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {missile, shooterCharacter}

	local heartbeatConnection; heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		timePassed += dt
		
		local currentCFrame: CFrame = missile:GetPivot() 
		local nextCFrame: CFrame -- where the missile "wants" to go this frame

		if timePassed < dumbFireDuration then
			-- direction = missile:GetPivot().LookVector
			-- Move forward along it's own local Z-axis (LookVector but CFrame)
			nextCFrame = currentCFrame * CFrame.new(0, 0, -speed * dt)
		else
			-- lock onto enemy player, and make sure the enemy player's root part exists
			if target and  target:FindFirstChild("HumanoidRootPart") then
				local targetPosition = target:GetPivot().Position
				local targetCFrame = CFrame.lookAt(currentCFrame.Position, targetPosition)
				local smoothedCFrame = currentCFrame:Lerp(targetCFrame, turnSpeed * dt)
				nextCFrame = smoothedCFrame * CFrame.new(0, 0, -speed * dt)
			else
				-- no target so just fly straight
				heartbeatConnection:Disconnect()
				explode(missile)
				return
			end
		end
		
		-- Time has ran out!
		if timePassed >= lockOnDuration then
			heartbeatConnection:Disconnect()
			explode(missile, crosshair)
		end
		
		-- Check if the missile hits something
		local moveVector = nextCFrame.Position - currentCFrame.Position
		local raycast = workspace:Raycast(currentCFrame.Position, moveVector, raycastParams)
		if raycast then
			-- We hit something!
			heartbeatConnection:Disconnect()
			explode(missile, crosshair)
		else
			-- Continue to go forward
			missile:PivotTo(nextCFrame)
		end
	end)
end

function HomingMissile:OnActivate()
	local character = Players.LocalPlayer.Character
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local mouse = Players.LocalPlayer:GetMouse()
	local origin: CFrame = root.CFrame
	local crosshair: BillboardGui?
	local target: Model?

	if mouse.Target then
		local model = mouse.Target:FindFirstAncestorOfClass("Model") :: Model?
		if model and model:FindFirstChild("Humanoid") then
			target = model
			local otherPlayerRoot = model:FindFirstChild("HumanoidRootPart") :: BasePart?
			if otherPlayerRoot then
				crosshair = createCrosshair(otherPlayerRoot)
			end
		end
	end
	
	launch(origin, target, crosshair, character)

	return {
		Origin = origin,
		Target = target,
	}
end

function HomingMissile:OnMass(player: Player, skill: string, clientData: { any })
	local character = player.Character
	if not character then 
		return
	end
	
	local origin = clientData.Origin
	local target = clientData.Target
	local crosshair: BillboardGui?
	
	if target and target == Players.LocalPlayer.Character then
		local root = target:FindFirstChild("HumanoidRootPart")
		if root then
			crosshair = createCrosshair(root)
		end
	end
	
	launch(origin, target, crosshair, character)
end

return HomingMissile
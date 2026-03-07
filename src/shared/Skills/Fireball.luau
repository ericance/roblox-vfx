--[[
	Fireball - Shoots a fireball towards an enemy that spins and explodes when it hits something, or goes the max distance of 50 studs.
]]

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Fireball = {}

local function explode(orange: MeshPart, yellow: MeshPart, explosionCFrame: CFrame)
	local orangeClone = orange:Clone()
	local yellowClone = yellow:Clone()
	
	-- Anchor them so they stay exactly where the impact happened
	orangeClone.Anchored = true
	yellowClone.Anchored = true
	
	-- Set their starting position to where the fireball died
	orangeClone.CFrame = explosionCFrame
	yellowClone.CFrame = explosionCFrame
	orangeClone.Parent = workspace.VFX
	yellowClone.Parent = workspace.VFX

	-- EasingStyle.Cubic makes it explode outwards fast, then slow down smoothly
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

	local orangeGoal = {Size = Vector3.new(25, 25, 25), Transparency = 1}
	local yellowGoal = {Size = Vector3.new(20, 20, 20), Transparency = 1}
	TweenService:Create(orangeClone, tweenInfo, orangeGoal):Play()
	TweenService:Create(yellowClone, tweenInfo, yellowGoal):Play()
	Debris:AddItem(orangeClone, 1)
	Debris:AddItem(yellowClone, 1)
end

local function shoot(origin: CFrame, target: CFrame, character: Model)--, root: Vector3)
	-- For moving the fireball
	local rotationSpeed = 360 
	local maxDistance = 50
	local distance = 0
	local speed = 50
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {character}

	local fireball: Model = workspace.Fireball:Clone()
	fireball:PivotTo(CFrame.new(origin.Position, target.Position))
	fireball.Parent = workspace.VFX
	local fireballCFrame
	local nextFireballCFrame

	local orangePart = fireball:FindFirstChild("Orange") :: MeshPart
	local yellowPart = fireball:FindFirstChild("Yellow") :: MeshPart
	local heartbeatConnection; heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number) 
		-- Position
		fireballCFrame = fireball:GetPivot()
		local direction = fireballCFrame.LookVector
		nextFireballCFrame = fireballCFrame + (direction * dt * speed)
		fireball:PivotTo(nextFireballCFrame)
		distance += (speed * dt)

		-- Rotation
		orangePart.Orientation += Vector3.new(0, dt * rotationSpeed, 0)

		-- For figuring out if the raycast hits something then 
		local raycast = workspace:Raycast(fireballCFrame.Position, direction * speed * dt, raycastParams)
		if raycast or distance > maxDistance then
			heartbeatConnection:Disconnect()
			explode(orangePart, yellowPart, fireballCFrame)
			fireball:Destroy()
		end
	end)
end

function Fireball:OnActivate()
	local character = Players.LocalPlayer.Character
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local origin = root.CFrame
	local target = Players.LocalPlayer:GetMouse().Hit

	shoot(origin, target, character)
	return {
		Origin = origin,
		Target = target
	}
end

function Fireball:OnMass(player: Player, skill: string, clientData: { any })
	local character = player.Character
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	shoot(clientData.Origin, clientData.Target, character)
end

return Fireball
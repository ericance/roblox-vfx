local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
-- Fireball

local function shoot(origin: CFrame, target: CFrame)--, root: Vector3)
	local maxDistance = 50
	local distance = 0
	local speed = 50

	local fireball: Model = workspace.Fireball:Clone()
	fireball:PivotTo(CFrame.new(origin.Position, target.Position))
	fireball.Parent = workspace.VFX

	local fireballCFrame
	local nextFireballCFrame
	local heartbeatConnection; heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number) 
		distance += (speed * dt)
		fireballCFrame = fireball:GetPivot()
		nextFireballCFrame = fireballCFrame + (fireballCFrame.LookVector * speed * dt)
		fireball:PivotTo(nextFireballCFrame)
		if distance > maxDistance then
			heartbeatConnection:Disconnect()
			fireball:Destroy()
		end
	end)
end

return function(self, character: Model)
	local root = character.HumanoidRootPart :: Part
	local target = Players.LocalPlayer:GetMouse().Hit :: CFrame
	shoot(root.CFrame, target)
end

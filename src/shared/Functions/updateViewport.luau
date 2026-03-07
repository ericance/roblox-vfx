--[[ 
	updateViewport - Clones the viewport passed in, removes the old one, and updates the new one with a consistent offset and angle
]]

return function(viewportFrame)
	if viewportFrame == nil then
		print('no viewport found')
		return
	end

	local viewportFrameClone = viewportFrame:Clone()
	viewportFrameClone.Parent = viewportFrame.Parent
	viewportFrame:Destroy()

	local fireball = workspace.Fireball
	local fireballCFrame = fireball:GetPivot()
	local vpfCamera = Instance.new("Camera")
	local angle = CFrame.Angles(math.rad(-45), 0, 0)
	local offset = CFrame.new(0, 1, 10)

	vpfCamera.CFrame = CFrame.new(fireballCFrame.Position) * angle * offset
	viewportFrameClone.CurrentCamera = vpfCamera
	vpfCamera.Parent = viewportFrameClone
end
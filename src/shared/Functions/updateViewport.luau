--[[ 
	updateViewport - Clones the viewport passed in, removes the old one, and updates the new one with a consistent offset and angle
]]

return function(skillName: string, viewportFrame: ViewportFrame)
	if viewportFrame == nil then
		print('no viewport found')
		return
	end

	local viewportFrameClone = viewportFrame:Clone()
	viewportFrameClone.Parent = viewportFrame.Parent
	viewportFrame:Destroy()

	local skillInstance = workspace.VFX:WaitForChild(skillName)
	if skillInstance == nil then
		warn("No skill found named " .. skillName)
		return
	end

	local instance = skillInstance:Clone()
	local cframe = instance:GetPivot()
	local vpfCamera = Instance.new("Camera")
	local angle = CFrame.Angles(math.rad(-45), 0, 0)
	local offset = CFrame.new(0, 1, 10)

	vpfCamera.CFrame = CFrame.new(cframe.Position) * angle * offset
	viewportFrameClone.CurrentCamera = vpfCamera
	vpfCamera.Parent = viewportFrameClone
	instance.Parent = viewportFrameClone
end
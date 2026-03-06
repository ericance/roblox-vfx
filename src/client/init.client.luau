local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Dependencies
local function loadModules(source: Instance)
	local modules = {}

	for _, module in source:GetChildren() do
		if not module:IsA("ModuleScript") then
			continue
		end
		modules[module.Name] = require(module)
	end

	return modules
end

local Skills = loadModules(ReplicatedStorage.Shared.Skills)

-- Network
local remote = ReplicatedStorage:WaitForChild("Remote") :: RemoteEvent
local fireball = workspace:WaitForChild("Fireball") :: Model


UserInputService.InputBegan:Connect(function(input: InputObject)
	if Players.LocalPlayer == nil or Players.LocalPlayer.Character == nil then
		return
	end

	if input.KeyCode == Enum.KeyCode.Q then
		local position = fireball:GetPivot()
		Skills:Fireball(Players.LocalPlayer.Character)
		remote:FireServer("Fireball", position)
	end
end)

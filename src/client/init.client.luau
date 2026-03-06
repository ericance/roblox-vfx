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

local skills = loadModules(ReplicatedStorage.Shared.Skills)
local player = Players.LocalPlayer

-- Network
local remote = ReplicatedStorage:WaitForChild("Remote") :: RemoteEvent

-- Sending (when you press Q)
UserInputService.InputBegan:Connect(function(input: InputObject, gamepProcessed: boolean)
	if gamepProcessed or not player.Character then
		return
	end

	if input.KeyCode == Enum.KeyCode.Q then
		local character = player.Character
		local root = character:FindFirstChild("HumanoidRootPart")
		if not root then
			return
		end
		
		local origin = root.CFrame
		local target = player:GetMouse().Hit

		-- local position = fireball:GetPivot()
		skills:Fireball(player.Character, origin, target)
		remote:FireServer(origin, target)
	end
end)

-- Receiving (when someone else sends a fireball)
remote.OnClientEvent:Connect(function(shooter: Player, origin: CFrame, target: CFrame)
	if player == shooter then
		return
	end

	skills:Fireball(shooter.Character, origin, target)
end)

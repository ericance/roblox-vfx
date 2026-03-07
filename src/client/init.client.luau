--[[
	Client - The entry point for the Roblox client that sets up UserInput
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Dependencies
local loadModules = require(ReplicatedStorage.Shared.Functions.loadModules)
local Skills = loadModules(ReplicatedStorage.Shared.Skills)

local player = Players.LocalPlayer

-- Network
local Remote = ReplicatedStorage:WaitForChild("Remote") :: RemoteEvent

-- Sending (when you press Q)
UserInputService.InputBegan:Connect(function(input: InputObject, gamepProcessed: boolean)
	if gamepProcessed or not player.Character then
		return
	end

	-- this should fire the skill 
	if input.KeyCode == Enum.KeyCode.Q then
		local character = player.Character
		local root = character:FindFirstChild("HumanoidRootPart")
		if not root then
			return
		end
		
		local origin = root.CFrame
		local target = player:GetMouse().Hit

		-- local position = fireball:GetPivot()
		Skills:Fireball(player.Character, origin, target)
		Remote:FireServer(origin, target)
	end
	
	-- this should switch the skill
	if input.KeyCode == Enum.KeyCode.E then
	end
end)

-- Receiving (when someone else sends a fireball)
Remote.OnClientEvent:Connect(function(shooter: Player, origin: CFrame, target: CFrame)
	if player == shooter then
		return
	end

	Skills:Fireball(shooter.Character, origin, target)
end)

--[[
	Client - The entry point for the Roblox client that sets up UserInput
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Dependencies
local loadModules = require(ReplicatedStorage.Shared.Functions.loadModules)
local updateViewport = require(ReplicatedStorage.Shared.Functions.updateViewport)
local Skills = loadModules(ReplicatedStorage.Shared.Skills)

-- Network
local remote = ReplicatedStorage:WaitForChild("Remote") :: RemoteEvent

-- Variables
local skill: Frame = Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui").Skills:FindFirstChild("1")
local activeSkill = "Dash"
local skillNames = {}
for skillName, _ in pairs(Skills) do
	table.insert(skillNames, skillName)
end
table.sort(skillNames)

local function updateSkillGui(skillName: string)
	updateViewport(skillName, skill.ViewportFrame)
	skill:FindFirstChild("Title").Text = skillName
end
updateSkillGui(activeSkill)

-- Sending (when you press Q)
UserInputService.InputBegan:Connect(function(input: InputObject, gamepProcessed: boolean)
	if gamepProcessed or not Players.LocalPlayer.Character then
		return
	end

	if input.KeyCode == Enum.KeyCode.Q then
		-- activate skill
		local clientData = Skills[activeSkill]:ActionStart()
		remote:FireServer(activeSkill, clientData)
	elseif input.KeyCode == Enum.KeyCode.E then
		-- switch the skill
		local currentIndex = table.find(skillNames, activeSkill)
		if currentIndex then
			-- modulo returns 0 for the same number
			-- so current % total is a perfect loop
			local nextIndex = (currentIndex % #skillNames) + 1
			activeSkill = skillNames[nextIndex]
			updateSkillGui(activeSkill)
		end
	end
end)

-- Receiving (when someone else uses a skill)
remote.OnClientEvent:Connect(function(player: Player, skill: string, clientData: { any })
	if Players.LocalPlayer == player then
		return
	end

	Skills[skill]:ActionBroadcast(player, skill, clientData)
end)

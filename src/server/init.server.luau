local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Dependencies

-- Network
local remote = Instance.new("RemoteEvent") :: RemoteEvent
remote.Name = "Remote"
remote.Parent = ReplicatedStorage

remote.OnServerEvent:Connect(function(player, attack, pivot)
	print(pivot)
end)

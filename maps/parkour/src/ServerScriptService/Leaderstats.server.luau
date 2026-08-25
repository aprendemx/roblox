local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	
	local leaderstats = Instance.new("Folder", player)
	leaderstats.Name = "leaderstats"
	
	local playerStats = Instance.new("Folder", player)
	playerStats.Name = "PlayerStats"
	
	--Valor dentro de leaderstats
	--local Coins = Instance.new("IntValue", leaderstats)
	--Coins.Name = "Coins"
	--Coins.Value = 11
	
	local Fruits = Instance.new("IntValue", leaderstats)
	Fruits.Name = "Fruits"
	Fruits.Value = 0
	
	--Valor dentro de PlayerStats
	--local Gems = Instance.new("IntValue", playerStats)
	--Gems.Name = "Gems"
	--Gems.Value = 0
end)
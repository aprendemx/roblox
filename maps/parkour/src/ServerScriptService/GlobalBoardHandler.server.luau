local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OrderedStores = {}

local MAX_ROWS = 100
local UPDATE_INTERVAL = 60 -- SEGUNDOS
local ROW_TEMPLATE = ReplicatedStorage:WaitForChild("LeaderboardRow")

--Regresa un OrderredDataStore para el score / currency
function getOrderedStore(currencyName)
	if not OrderedStores[currencyName] then
		OrderedStores[currencyName] = DataStoreService:GetOrderedDataStore(currencyName .. "Leaderboard")
	end
	return OrderedStores[currencyName]
end
-- Limpiar el leaderboard
function clearLeaderboard(gui)
	for _, child in ipairs(gui.DataContent:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
end

-- Actualiza el leaderboard en el modelo
function updateLeaderboard(leaderboardModel)
	local background = leaderboardModel:WaitForChild("Background")
	local surfaceGui = background:WaitForChild("SurfaceGui")
	local currencyName = leaderboardModel:WaitForChild("Currency").Value
	local folderName = leaderboardModel:WaitForChild("FolderName").Value
	
	local store = getOrderedStore(currencyName)
	
	local success, pages = pcall(function()
		return store:GetSortedAsync(false, MAX_ROWS)
	end)
	
	if not success then
		warn("Failed to fetch leaderboard for", currencyName)
		return
	end
	
	clearLeaderboard(surfaceGui)
	
	local currentPage = pages:GetCurrentPage()
	
	for rank, entry in ipairs(currentPage) do
		local userId = tonumber(entry.key)
		local value = entry.value
		
		local username = "Unknown"
		pcall(function()
			username = Players:GetNameFromUserIdAsync(userId)
		end)
		
		-- Create a row 
		local row = ROW_TEMPLATE:Clone()
		row.PlayerLabel.Text = username
		row.CurrencyLabel.Text = value
		row.RankLabel.Text = "#" .. rank
		
		-- Color de fila
		if rank == 1 then
			row.BackgroundColor3 = Color3.fromRGB(255, 191, 0)
		elseif rank == 2 then
			row.BackgroundColor3 = Color3.fromRGB(136, 132, 130)
		elseif rank == 3 then
			row.BackgroundColor3 = Color3.fromRGB(136, 99, 74)
		end
		
		row.LayoutOrder = rank
		row.Parent = surfaceGui.DataContent		
	end
	
end

--Guarda todos los stats de players a OrderedDataStore
function saveAllPlayers()
	for _, player in ipairs(Players:GetPlayers()) do
		for _, leaderboardModel in ipairs(workspace.Leaderboards:GetChildren()) do
			if string.match(leaderboardModel.Name, "Leaderboard")
				and leaderboardModel:FindFirstChild("Currency")
				and leaderboardModel:FindFirstChild("FolderName") then
	
				local currency = leaderboardModel.Currency.Value
				local folderName = leaderboardModel.FolderName.Value
				
				local statsFolder = player:FindFirstChild(folderName)
				if not statsFolder then continue end
				
				local stat = statsFolder:FindFirstChild(currency)
				if not stat then continue end
				
				local store = getOrderedStore(currency)
				
				pcall(function()
					-- CAMBIO: Leer el valor guardado anteriormente
					local savedValue = store:GetAsync(player.UserId) or 0

					-- CAMBIO: Solo guardar si el nuevo valor es MAYOR
					if stat.Value > savedValue then
						store:SetAsync(player.UserId, stat.Value)
						print(player.Name, currency, "actualizado:", savedValue, "->", stat.Value)
					end
				end)									
			end
		end
	end
end

while true do
	saveAllPlayers()
	for _, leaderboardModel in ipairs(workspace.Leaderboards:GetChildren()) do
		if string.match(leaderboardModel.Name, "Leaderboard")
			and leaderboardModel:FindFirstChild("Currency")
			and leaderboardModel:FindFirstChild("FolderName")
			and leaderboardModel:FindFirstChild("Background")
			and leaderboardModel.Background:FindFirstChild("SurfaceGui") then
			
			updateLeaderboard(leaderboardModel)
	    end
	end
	print("All leaderboards update.")
	task.wait(UPDATE_INTERVAL)
end
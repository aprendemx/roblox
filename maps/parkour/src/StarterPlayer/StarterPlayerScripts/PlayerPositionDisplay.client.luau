-- LocalScript que muestra la posición del jugador en el tablero de posición
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local leaderstats = player:WaitForChild("leaderstats")
local coins = leaderstats:WaitForChild("Coins", 9999)

-- Esperar a que el tablero de posición exista
local positionBoard = workspace:WaitForChild("PositionBoard")
local positionPanel = positionBoard:FindFirstChild("Panel")

-- Función para actualizar el tablero con la posición del jugador local
local function updateLocalPosition(leaderboardData)
    if not positionPanel then return end
    
    local posGui = positionPanel:FindFirstChild("MainGui")
    if not posGui then return end
    
    local container = posGui:FindFirstChild("Container")
    if not container then return end
    
    local playerNameLabel = container:FindFirstChild("PlayerName")
    local positionLabel = container:FindFirstChild("Position")
    local fruitsLabel = container:FindFirstChild("Fruits")
    
    -- Buscar la posición del jugador local
    local myPosition = #leaderboardData + 1
    local myCoins = coins.Value
    
    for i, data in ipairs(leaderboardData) do
        if data.name == player.Name then
            myPosition = i
            myCoins = data.coins
            break
        end
    end
    
    -- Actualizar los labels
    if playerNameLabel then
        playerNameLabel.Text = "Jugador: " .. player.Name
    end
    if positionLabel then
        positionLabel.Text = "Posición: #" .. myPosition .. " de " .. #leaderboardData
    end
    if fruitsLabel then
        fruitsLabel.Text = "Frutas: " .. myCoins
    end
end

-- Escuchar actualizaciones del servidor
local leaderboardRemote = ReplicatedStorage:WaitForChild("LeaderboardRemote")
leaderboardRemote.OnClientEvent:Connect(function(leaderboardData)
    updateLocalPosition(leaderboardData)
end)

-- También actualizar cuando cambien las monedas
coins.Changed:Connect(function()
    -- Solicitar actualización al servidor
    leaderboardRemote:FireServer("RequestUpdate")
end)
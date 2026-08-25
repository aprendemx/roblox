-- Sistema de detección de puzzle
-- Detecta cuando los objetos correctos se colocan en los triggers correctos
-- Cada jugador tiene su propio puzzle individual

local Players = game:GetService("Players")

-- Configuración de triggers y objetos correctos
local TRIGGERS = {
    ["BoxLuces"] = "Luz",
    ["BoxCamara"] = "Camara",
    ["BoxSonido"] = "Sonido"
}

-- Estado del puzzle por jugador
local playerProgress = {}

-- Rastrear qué jugador tiene cada Tool
local toolOwners = {}

-- Función para verificar si un punto está dentro de un trigger
local function isInTrigger(position, trigger)
    if not trigger then return false end
    
    local triggerPos = trigger.Position
    local triggerSize = trigger.Size
    
    local minX = triggerPos.X - triggerSize.X/2
    local maxX = triggerPos.X + triggerSize.X/2
    local minY = triggerPos.Y - triggerSize.Y/2
    local maxY = triggerPos.Y + triggerSize.Y/2
    local minZ = triggerPos.Z - triggerSize.Z/2
    local maxZ = triggerPos.Z + triggerSize.Z/2
    
    return position.X >= minX and position.X <= maxX and
           position.Y >= minY and position.Y <= maxY and
           position.Z >= minZ and position.Z <= maxZ
end

-- Función para verificar si un jugador completó el puzzle
local function checkPuzzleComplete(player)
    local progress = playerProgress[player]
    if not progress then return false end
    
    return progress.Luz and progress.Camara and progress.Sonido
end

-- Función para mostrar el teleport cuando el puzzle está completo
local function showTeleport(player)
    print("¡" .. player.Name .. " completó el puzzle!")
    -- Aquí irá la lógica para mostrar el teleport
    -- TODO: Mostrar teleport al otro mundo
end

-- Función para manejar cuando un objeto se suelta
local function onObjectDropped(player, tool, position)
    -- Inicializar progreso del jugador si no existe
    if not playerProgress[player] then
        playerProgress[player] = {
            Luz = false,
            Camara = false,
            Sonido = false
        }
    end
    
    -- Verificar en qué trigger cayó
    for triggerName, correctObject in pairs(TRIGGERS) do
        local trigger = workspace:FindFirstChild(triggerName)
        
        if trigger and isInTrigger(position, trigger) then
            -- Verificar si es el objeto correcto
            if tool.Name == correctObject then
                print("¡Correcto! " .. player.Name .. " puso " .. tool.Name .. " en " .. triggerName)
                
                -- Marcar como correcto para este jugador
                playerProgress[player][correctObject] = true
                
                -- Anclar la Tool en su lugar
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    handle.Anchored = true
                end
                
                -- Verificar si completó el puzzle
                if checkPuzzleComplete(player) then
                    showTeleport(player)
                end
                
                return true
            else
                print("Incorrecto: " .. tool.Name .. " no va en " .. triggerName)
            end
        end
    end
    
    return false
end

-- Detectar cuando un jugador equipa una Tool (para rastrear ownership)
local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function(character)
        -- Detectar cuando el personaje agarra una Tool
        character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                toolOwners[child] = player
            end
        end)
    end)
end

-- Conectar para nuevos jugadores
Players.PlayerAdded:Connect(onPlayerAdded)

-- También para jugadores ya existentes
for _, player in Players:GetPlayers() do
    onPlayerAdded(player)
end

-- Detectar cuando una Tool se suelta en el Workspace
workspace.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        -- Esperar un momento para que la Tool se asiente
        task.wait(0.2)
        
        local handle = child:FindFirstChild("Handle")
        if handle then
            -- Obtener el jugador que tenía esta Tool
            local player = toolOwners[child]
            
            if player then
                onObjectDropped(player, child, handle.Position)
            else
                -- Si no sabemos quién la soltó, intentar encontrar al jugador más cercano
                local closestPlayer = nil
                local closestDistance = math.huge
                
                for _, p in Players:GetPlayers() do
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = (p.Character.HumanoidRootPart.Position - handle.Position).Magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = p
                        end
                    end
                end
                
                if closestPlayer and closestDistance < 20 then
                    onObjectDropped(closestPlayer, child, handle.Position)
                end
            end
        end
    end
end)

print("Sistema de puzzle cargado correctamente")
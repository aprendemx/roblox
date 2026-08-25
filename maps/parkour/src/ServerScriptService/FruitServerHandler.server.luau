local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ============================================
-- REMOTE EVENTS
-- ============================================

-- Evento para SUMAR frutas (ya existía)
local collectFruitEvent = ReplicatedStorage:WaitForChild("CollectFruit")

-- Evento para RESTAR score al tocar una "cosa" (nuevo)
local collectBadItemEvent = ReplicatedStorage:WaitForChild("CollectBadItem")

-- ============================================
-- MANEJO DE FRUTAS (SUMA +1 al score)
-- ============================================

-- Cuando un jugador recoge una fruta, se SUMA 1 al score
collectFruitEvent.OnServerEvent:Connect(function(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end
	
	local fruits = leaderstats:FindFirstChild("Fruits")
	if not fruits then return end
	
	-- Sumar 1 fruta (se replica a todos los clientes automáticamente)
	fruits.Value = fruits.Value + 1
	print(player.Name, "recogió una fruta. Total:", fruits.Value)
end)

-- ============================================
-- MANEJO DE "COSAS" (RESTA -1 al score)
-- ============================================

-- Cuando un jugador toca una "cosa", se RESTA 1 al score de frutas
-- El score puede bajar a números negativos (sin límite inferior)
collectBadItemEvent.OnServerEvent:Connect(function(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end
	
	local fruits = leaderstats:FindFirstChild("Fruits")
	if not fruits then return end
	
	-- Restar 1 al score de frutas (puede quedar negativo)
	fruits.Value = fruits.Value - 1
	print(player.Name, "tocó una cosa. Total:", fruits.Value)
end)

print("FruitServerHandler cargado correctamente (frutas + cosas)")
local Player = game.Players.LocalPlayer
local char = Player.Character or Player.CharacterAdded:Wait()

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ============================================
-- REMOTE EVENTS (comunicación cliente-servidor)
-- ============================================

-- Evento para SUMAR frutas (ya existía)
local collectFruitEvent = ReplicatedStorage:WaitForChild("CollectFruit")

-- Evento para RESTAR score al tocar una "cosa" (nuevo)
local collectBadItemEvent = ReplicatedStorage:WaitForChild("CollectBadItem")

-- ============================================
-- FOLDERS DE OBJETOS RECOLECTABLES
-- ============================================

-- Folder de frutas (SUMAN score)
local FrutasFolder = game.Workspace:WaitForChild("Frutas")

-- Folder de "cosas" (RESTAN score)
local OtrosFolder = game.Workspace:WaitForChild("Otros")

-- ============================================
-- SONIDOS
-- ============================================

-- ID del sonido de fruta (sonido positivo al recoger)
local FRUIT_SOUND_ID = "rbxassetid://125300728749098"

-- ID del sonido de "cosa" (sonido negativo al tocar) — cámbialo por el que gustes
local BAD_ITEM_SOUND_ID = "rbxassetid://125300728749098"

-- Precargar sonido de fruta
local fruitSound = Instance.new("Sound")
fruitSound.SoundId = FRUIT_SOUND_ID
fruitSound.Volume = 1
fruitSound.Parent = workspace

-- Precargar sonido de "cosa" (sonido distinto para diferenciar)
local badItemSound = Instance.new("Sound")
badItemSound.SoundId = BAD_ITEM_SOUND_ID
badItemSound.Volume = 1
badItemSound.PlaybackSpeed = 0.7 -- Más lento para sonar diferente a la fruta
badItemSound.Parent = workspace

-- Función para reproducir sonido de fruta
local function playFruitSound()
	fruitSound:Play()
end

-- Función para reproducir sonido de "cosa" (negativo)
local function playBadItemSound()
	badItemSound:Play()
end

-- ============================================
-- DEBOUNCE (evitar recoger el mismo objeto 2 veces)
-- ============================================

-- Frutas ya recogidas
local collectedFruits = {}

-- "Cosas" ya tocadas
local collectedBadItems = {}

-- ============================================
-- CONFIGURACIÓN DE FRUTAS (SUMAN +1 al score)
-- ============================================

-- Función para configurar una fruta
local function setupFruit(fruit)
	-- Solo configurar si se llama "Fruit"
	if fruit.Name == "Fruit" then
		fruit.Touched:Connect(function(hit)
			if hit.Parent == char and not collectedFruits[fruit] then
				collectedFruits[fruit] = true
				
				-- Avisar al servidor para SUMAR la fruta
				collectFruitEvent:FireServer()
				
				-- Ocultar la fruta SOLO para este jugador (local)
				fruit.Transparency = 1
				fruit.CanTouch = false
				playFruitSound()
			end
		end)
	end
end

-- ============================================
-- CONFIGURACIÓN DE "COSAS" (RESTAN -1 al score)
-- ============================================

-- Función para configurar una "cosa" del folder Otros
local function setupBadItem(item)
	-- Solo configurar si se llama "cosa"
	if item.Name == "cosa" then
		item.Touched:Connect(function(hit)
			if hit.Parent == char and not collectedBadItems[item] then
				collectedBadItems[item] = true
				
				-- Avisar al servidor para RESTAR del score de frutas
				collectBadItemEvent:FireServer()
				
				-- Ocultar la "cosa" SOLO para este jugador (local)
				item.Transparency = 1
				item.CanTouch = false
				playBadItemSound()
			end
		end)
	end
end

-- ============================================
-- INICIALIZACIÓN: configurar objetos que ya existen
-- ============================================

-- Configurar todas las frutas que ya existen
for _, item in pairs(FrutasFolder:GetChildren()) do
	if item.Name == "Fruit" then
		setupFruit(item)
	end
end

-- Configurar todas las "cosas" que ya existen
for _, item in pairs(OtrosFolder:GetChildren()) do
	if item.Name == "cosa" then
		setupBadItem(item)
	end
end

-- ============================================
-- EVENTOS: configurar objetos que se agreguen después
-- ============================================

-- Configurar frutas que se agreguen después
FrutasFolder.ChildAdded:Connect(function(child)
	task.wait() -- Esperar un momento para que se configure
	setupFruit(child)
end)

-- Configurar "cosas" que se agreguen después
OtrosFolder.ChildAdded:Connect(function(child)
	task.wait() -- Esperar un momento para que se configure
	setupBadItem(child)
end)
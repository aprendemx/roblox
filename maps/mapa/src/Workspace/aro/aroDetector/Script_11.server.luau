local Players = game:GetService("Players")

local detector = script.Parent -- aroDetector
local aro = detector.Parent -- el Part "aro"
local particulas = aro:FindFirstChild("particle")

local SONIDO_ID = "rbxassetid://135483737426662"
local cooldown = false

detector.Touched:Connect(function(hit)
	-- Si el aro está en tiempo de espera, no hace nada
	if cooldown then return end

	-- Verificamos que lo que tocó el detector sea un Personaje (tenga un Humanoid)
	local character = hit.Parent
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid and humanoid.Health > 0 then
		cooldown = true
		--print("¡Aro atravesado por un jugador! Activando efectos...")

		-- 1. CREAR EL SONIDO 3D (Espacial)
		local sonidoClin = Instance.new("Sound")
		sonidoClin.SoundId = SONIDO_ID
		sonidoClin.Volume = 0.7
		sonidoClin.RollOffMode = Enum.RollOffMode.Linear
		sonidoClin.RollOffMinDistance = 10
		sonidoClin.RollOffMaxDistance = 50

		-- Poner el sonido dentro del aro para que sea 3D
		sonidoClin.Parent = aro
		sonidoClin:Play()

		-- 2. EMITIR PARTÍCULAS
		if particulas then
			particulas:Emit(40)
		end

		-- 3. LIMPIEZA - Borrar el sonido después de que termine
		task.delay(3, function()
			if sonidoClin and sonidoClin.Parent then
				sonidoClin:Destroy()
			end
		end)

		-- 4. TIEMPO DE ESPERA antes de reactivar
		task.wait(2)
		cooldown = false
	end
end)
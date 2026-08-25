-- FloatingEffect - Poner como hijo de un MODELO
-- Efecto de flotación en loop para todo el modelo usando su Pivot

local model = script.Parent
if not model:IsA("Model") then
	warn("FloatingEffect: El parent debe ser un Model")
	return
end

-- ╔══════════════════════════════════════╗
-- ║      CONFIGURACIÓN                   ║
-- ╚══════════════════════════════════════╝

local AMPLITUDE = 25.6       -- Qué tan alto/bajo flota (studs)
local SPEED = 1          -- Velocidad del ciclo de flotado
local CURVE_POWER = 1    -- Curva: >1 = más tiempo en los picos, <1 = más lineal
local TILT_AMOUNT = 1      -- Inclinación sutil al flotar (grados), 0 para desactivar

-- ════════════════════════════════════════

local RunService = game:GetService("RunService")

-- ¡AQUÍ ESTÁ EL CAMBIO!: Guardamos el Pivot original del modelo completo
local originalPivot = model:GetPivot()

local connection
connection = RunService.Heartbeat:Connect(function()
	if not model.Parent then
		connection:Disconnect()
		return
	end

	local t = tick()
	local sinVal = math.sin(t * SPEED)

	-- Tu fórmula de curva matemática (se queda igual porque es buenísima)
	local curved = math.sign(sinVal) * math.abs(sinVal) ^ CURVE_POWER
	local yOffset = curved * AMPLITUDE

	-- Inclinación sutil tipo péndulo
	local tilt = math.sin(t * SPEED + math.pi / 2) * math.rad(TILT_AMOUNT)

	-- ¡LA MAGIA!: Movemos todo el modelo usando su punto de pivote
	local nuevoCFrame = originalPivot * CFrame.new(0, yOffset, 0) * CFrame.Angles(tilt, 0, 0)
	model:PivotTo(nuevoCFrame)
end)
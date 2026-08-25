-- FloatingEffect - Poner como hijo de un BasePart/MeshPart
-- Efecto de flotación en loop con curva para enfatizar la flotabilidad

local object = script.Parent
if not object:IsA("BasePart") then
	warn("FloatingEffect: El parent debe ser un BasePart o MeshPart")
	return
end

-- ╔══════════════════════════════════════╗
-- ║         CONFIGURACIÓN                ║
-- ╚══════════════════════════════════════╝

local AMPLITUDE = 0.6       -- Qué tan alto/bajo flota (studs)
local SPEED = 1.2           -- Velocidad del ciclo de flotado
local CURVE_POWER = 1.6     -- Curva: >1 = más tiempo en los picos (flotabilidad), <1 = más lineal
local TILT_AMOUNT = 0.8     -- Inclinación sutil al flotar (grados), 0 para desactivar

-- ════════════════════════════════════════

local RunService = game:GetService("RunService")

-- Guardar CFrame original como referencia
local originalCFrame = object.CFrame

local connection
connection = RunService.Heartbeat:Connect(function()
	if not object.Parent then
		connection:Disconnect()
		return
	end

	local t = tick()
	local sinVal = math.sin(t * SPEED)

	-- Curva: eleva el seno a una potencia para que el objeto
	-- pase más tiempo cerca de los picos (arriba/abajo),
	-- dando esa sensación de "flotar" en vez de moverse lineal
	local curved = math.sign(sinVal) * math.abs(sinVal) ^ CURVE_POWER

	local yOffset = curved * AMPLITUDE

	-- Inclinación sutil tipo péndulo al flotar
	local tilt = math.sin(t * SPEED + math.pi / 2) * math.rad(TILT_AMOUNT)

	object.CFrame = originalCFrame * CFrame.new(0, yOffset, 0) * CFrame.Angles(tilt, 0, 0)
end)
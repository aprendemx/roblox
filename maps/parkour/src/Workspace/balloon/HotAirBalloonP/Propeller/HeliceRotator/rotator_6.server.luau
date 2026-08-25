-- SpinEffect - Poner como hijo de un MODELO
-- Hace que todo el modelo gire sobre su propio eje de forma suave

local model = script.Parent
if not model:IsA("Model") then
	warn("SpinEffect: El parent debe ser un Model")
	return
end

-- ╔══════════════════════════════════════╗
-- ║      CONFIGURACIÓN                   ║
-- ╚══════════════════════════════════════╝

local TURN_SPEED = 55 -- Velocidad: Grados por segundo que va a girar (ej. 90 = un cuarto de vuelta por segundo)

-- ════════════════════════════════════════

local RunService = game:GetService("RunService")

RunService.Heartbeat:Connect(function(deltaTime)
	if not model.Parent then return end

	-- Calculamos la rotación en base al tiempo transcurrido (para que no dé lag)
	local grados = math.rad(TURN_SPEED * deltaTime)
	local rotacion = CFrame.Angles(grados, 0, 0) -- Cambia el orden si quieres que gire de lado o hacia el frente

	-- Hacemos girar el modelo usando su Pivot original
	model:PivotTo(model:GetPivot() * rotacion)
end)
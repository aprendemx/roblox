-- CONFIGURACIÓN
-- Define la fecha de activación (Año, Mes, Día, Hora, Minuto)
local FECHA_ACTIVACION = {
	year = 2026,
	month = 8,
	day = 31,
	hour = 18,
	min = 0
}

math.randomseed(os.time())

local TIEMPO_ESPERA = math.random(300, 600) -- Tiempo en segundos que esperará DESPUÉS de la fecha para activar el evento


-- FUNCIÓN PARA ACTIVAR EL EVENTO DE GRAVEDAD CERO
local function activarGravedadCero()
	--print("¡Iniciando evento de gravedad cero y desanclaje!")

	-- 1. Cambiar la gravedad del Workspace a 0
	workspace.Gravity = 0

	-- 2. Recorrer todo el Workspace para desanclar las partes
	local todosLosObjetos = workspace:GetDescendants()

	for _, objeto in ipairs(todosLosObjetos) do
		-- Verificar si el objeto es una Parte (Part, MeshPart, WedgePart, etc.)
		if objeto:IsA("BasePart") then
			-- Evitamos desanclar las partes de los personajes de los jugadores de golpe 
			-- para que no se rompa el juego, solo objetos del mapa.
			local esParteDeJugador = objeto:FindFirstAncestorOfClass("Model") and objeto.Parent:FindFirstChildOfClass("Humanoid")

			if not esParteDeJugador and objeto.Name ~= "Terrain" then
				objeto.Anchored = false

				-- Opcional: Darle un pequeño impulso inicial para que floten con gracia
				local impulsoAleatorio = Vector3.new(
					math.random(-5, 5),
					math.random(2, 8),
					math.random(-5, 5)
				)
				objeto.AssemblyLinearVelocity = impulsoAleatorio
			end
		end
	end
end


-- CONTROL DEL TIEMPO (VIDA REAL)
local function verificarFechaYCronometro()
	-- Convertimos la fecha de activación a formato de tiempo UNIX (segundos)
	local tiempoObjetivo = os.time(FECHA_ACTIVACION)

	while true do
		local tiempoActual = os.time() -- Obtiene la hora actual del servidor en UTC
		local dado = math.random(0, 3)
		print(dado)

		if (tiempoActual >= tiempoObjetivo) and (dado == 0) then
			--print("La fecha objetivo ha pasado. Iniciando cuenta regresiva del juego...")
			-- Generar random del 25%
			
			

			-- Esperar el tiempo 'X' aleatorio entre 5 min y 10 min 
			task.wait(TIEMPO_ESPERA)

			-- Ejecutar el caos
			activarGravedadCero()
			break -- Salimos del bucle ya que el evento se activó
		end

		-- Esperar dos minuto antes de volver a revisar la fecha real para no saturar el servidor
		task.wait(120) 
	end
end

-- Iniciar el script
verificarFechaYCronometro()

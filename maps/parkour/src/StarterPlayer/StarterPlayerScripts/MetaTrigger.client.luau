local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local triggerPart = Workspace:WaitForChild("TriggerMeta", 9999) 
local billboard = triggerPart:WaitForChild("BillboardGui")
local textLabel = billboard:WaitForChild("TextLabel")

local yaSeUso = false

triggerPart.Touched:Connect(function(hit)
	if yaSeUso then return end

	local character = hit.Parent
	local player = Players:GetPlayerFromCharacter(character)

	-- Solo reacciona si el jugador que la toca soy YO (el dueño de este LocalScript)
	if player == Players.LocalPlayer then
		yaSeUso = true

		print("Activación local detectada")

		-- Fase 1: Actualizando (Solo tú lo verás naranja)
		triggerPart.Color = Color3.fromRGB(255, 165, 0)
		if textLabel then textLabel.Text = "Llegaste" end
		triggerPart.CanTouch = false
		
		task.wait(2)

		-- Fase 2: Completado (Solo tú lo verás gris)
		triggerPart.Color = Color3.fromRGB(100, 100, 100)
		if textLabel then textLabel.Text = "Felicidades" end

		--print("Sesión local terminada. El script dejará de funcionar hasta que reinicies.")

		-- Al ser LocalScript, esto solo 'muere' para ti en esta partida
		--script:Destroy() 
	end
end)
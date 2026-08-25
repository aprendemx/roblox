local triggerPart = script.Parent
triggerPart.Touched:Connect(function(hit)
	local character = hit.Parent
	local player = Players:GetPlayerFromCharacter(character)
		
		print("me tocó")
	

		-- Cambiar color para indicar que ya se activó
		triggerPart.Color = Color3.fromRGB(255, 165, 0)
		textLabel.Text = "Actualizando..."

		wait(2)

		-- Cambiar a color de "completado"
		triggerPart.Color = Color3.fromRGB(100, 100, 100)
		textLabel.Text = "Actualizado"
	
end)


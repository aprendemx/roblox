local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local score = 0
local numCollects = 8
local teleport = Workspace:WaitForChild("teleportMundo"):WaitForChild("Modelos De Telenstraporte"):WaitForChild("Teleports"):WaitForChild("TpArea"):WaitForChild("TP")
local partGlow = Workspace:WaitForChild("teleportMundo"):WaitForChild("Teleport Pads"):WaitForChild("Pad1"):WaitForChild("GLOW")
local partEmmi = Workspace:WaitForChild("teleportMundo"):WaitForChild("Teleport Pads"):WaitForChild("Pad1"):WaitForChild("ParticleEmitter")
local part = Workspace:WaitForChild("teleportMundo"):WaitForChild("Teleport Pads"):WaitForChild("Pad1"):WaitForChild("Particles")

-- -----------------------------------
-- Puzzle: Luces 
-- -----------------------------------
local toolLuz = Workspace:WaitForChild("toolLuz")
local triggerLuces = Workspace:WaitForChild("BoxLuces") 

local usedLuz = false
local hadLuz = false
local copiaLuz

toolLuz:WaitForChild("Handle"):WaitForChild("ProximityPrompt").Triggered:Connect(function(playerQueActivo)
	-- 1. Verificamos que TÚ fuiste quien presionó la tecla
	if playerQueActivo == localPlayer then

		--print("Has interactuado con el prompt. Entregando herramienta...")
		hadLuz = true
		--print("hadLuz se volvio a true")

		-- 2. Creamos la COPIA para tu mochila
		copiaLuz = toolLuz:Clone()

		--print("hizo clone")

		copiaLuz.Name = "Luz de estudio" -- Le damos nombre único
		copiaLuz:WaitForChild("Handle").CanTouch = true
		copiaLuz:WaitForChild("Handle"):WaitForChild("ProximityPrompt").Enabled = false
		copiaLuz.Parent = localPlayer:WaitForChild("Backpack")
		copiaLuz:WaitForChild("Handle").Anchored = false
		copiaLuz:WaitForChild("particulas"):WaitForChild("ParticleEmitter").Enabled = false

		-- 3. OPCIONAL: Si quieres que se equipe SOLA de inmediato:
		local character = localPlayer.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:EquipTool(copiaLuz)
			end
		end

		-- 4. ESCONDEMOS la original (lo que aprendimos de Descendants)
		-- Para que otros sigan viéndola pero tú ya no
		--toolLuz:WaitForChild("particulas"):WaitForChild("ParticleEmmitter").Enabled = false
		for _, objeto in pairs(toolLuz:GetDescendants()) do
			if objeto:IsA("BasePart") then
				objeto.Transparency = 1
				objeto.CanTouch = false
				objeto.CanCollide = false
			elseif objeto:IsA("BillboardGui") or objeto:IsA("ProximityPrompt") then
				objeto.Enabled = false
			end
		end
		toolLuz:WaitForChild("particulas"):WaitForChild("ParticleEmitter").Enabled = false
	end
end)

triggerLuces.Touched:Connect(function(hit)
	--print(hit.Name)
	if usedLuz then return end

	-- COMPROBACIÓN MAESTRA:
	-- Solo funciona si el objeto que toca es la caja 
	-- Y ADEMÁS el script confirma que TÚ eres el que interactuó con ella (yoLaTengo)
	if hit.Parent == copiaLuz and hadLuz then
		usedLuz = true

		print("¡Caja detectada por MI!")

		-- Cambio de color LOCAL
		triggerLuces.Color = Color3.fromRGB(0, 255, 0)

		-- SONIDO LOCAL
		local sonidoWin = Instance.new("Sound")
		sonidoWin.SoundId = "rbxassetid://113194405128446"
		sonidoWin.Parent = triggerLuces 
		sonidoWin:Play()

		local handle = copiaLuz:FindFirstChild("Handle")
		if handle then
			-- CLONAMOS LOCALMENTE
			local luzDecorativa = handle:Clone()
			luzDecorativa.Name = "LuzDecorativa_Individual"
			luzDecorativa.CFrame = triggerLuces.CFrame
			luzDecorativa.Anchored = true
			luzDecorativa.CanCollide = true
			luzDecorativa.Parent = Workspace

			local prompt = luzDecorativa:FindFirstChildWhichIsA("ProximityPrompt")
			if prompt then prompt:Destroy() end
		end

		-- Desaparece la herramienta SOLO para ti
		copiaLuz:Destroy()

		triggerLuces.CanTouch = false
		task.wait(1.5)
		triggerLuces.Transparency = 1
		
		-- Sumamos Score para el teleport y corroboramos
		score += 1
		if score >= numCollects then
			teleport.Position = Vector3.new(163.122, 15.5, -17.5)
			partGlow.Enabled = true
			partEmmi.Enabled = true
			part.Enabled = true
		end
	end
end)

-- -----------------------------------
-- Puzzle: Cámara
-- -----------------------------------
local toolCam = Workspace:WaitForChild("toolCamara")
local triggerCam = Workspace:WaitForChild("BoxCamara") 

local usedCam = false
local hadCam = false
local copiaCam

toolCam:WaitForChild("Handle"):WaitForChild("ProximityPrompt").Triggered:Connect(function(playerQueActivo)
	-- 1. Verificamos que TÚ fuiste quien presionó la tecla
	if playerQueActivo == localPlayer then

		--print("Has interactuado con el prompt. Entregando herramienta...")
		hadCam = true
		--print("hadLuz se volvio a true")

		-- 2. Creamos la COPIA para tu mochila
		copiaCam = toolCam:Clone()

		--print("hizo clone")

		copiaCam.Name = "Cámara de estudio" -- Le damos nombre único
		copiaCam:WaitForChild("Handle").CanTouch = true
		copiaCam:WaitForChild("Handle"):WaitForChild("ProximityPrompt").Enabled = false
		copiaCam.Parent = localPlayer:WaitForChild("Backpack")
		copiaCam:WaitForChild("Handle").Anchored = false
		copiaCam:WaitForChild("particulas"):WaitForChild("ParticleEmitter").Enabled = false

		-- 3. OPCIONAL: Si quieres que se equipe SOLA de inmediato:
		
		local character = localPlayer.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:EquipTool(copiaCam)
			end
		end

		-- 4. ESCONDEMOS la original (lo que aprendimos de Descendants)
		-- Para que otros sigan viéndola pero tú ya no
		for _, objeto in pairs(toolCam:GetDescendants()) do
			if objeto:IsA("BasePart") then
				objeto.Transparency = 1
				objeto.CanTouch = false
				objeto.CanCollide = false
			elseif objeto:IsA("BillboardGui") or objeto:IsA("ProximityPrompt") then
				objeto.Enabled = false
			end
		end
		toolCam:WaitForChild("particulas"):WaitForChild("ParticleEmitter").Enabled = false
	end
end)

triggerCam.Touched:Connect(function(hit)
	--print(hit.Name)
	if usedCam then return end

	-- COMPROBACIÓN MAESTRA:
	-- Solo funciona si el objeto que toca es la caja 
	-- Y ADEMÁS el script confirma que TÚ eres el que interactuó con ella (yoLaTengo)
	if hit.Parent == copiaCam and hadCam then
		usedCam = true

		print("¡Caja detectada por MI!")

		-- Cambio de color LOCAL
		triggerCam.Color = Color3.fromRGB(0, 255, 0)

		-- SONIDO LOCAL
		local sonidoWin = Instance.new("Sound")
		sonidoWin.SoundId = "rbxassetid://113194405128446"
		sonidoWin.Parent = triggerCam
		sonidoWin:Play()

		local handle = copiaCam:FindFirstChild("Handle")
		if handle then
			-- CLONAMOS LOCALMENTE
			local CamDecorativa = handle:Clone()
			CamDecorativa.Name = "CamDecorativa_Individual"
			CamDecorativa.CFrame = triggerCam.CFrame
			CamDecorativa.Anchored = true
			CamDecorativa.CanCollide = true
			CamDecorativa.Parent = Workspace

			local prompt = CamDecorativa:FindFirstChildWhichIsA("ProximityPrompt")
			if prompt then prompt:Destroy() end
		end

		-- Desaparece la herramienta SOLO para ti
		copiaCam:Destroy()

		triggerCam.CanTouch = false
		task.wait(1.5)
		triggerCam.Transparency = 1
		
		-- Sumamos Score para el teleport y corroboramos
		score += 1
		if score >= numCollects then
			teleport.Position = Vector3.new(163.122, 15.5, -17.5)
			partGlow.Enabled = true
			partEmmi.Enabled = true
			part.Enabled = true
		end
	end
end)

-- -----------------------------------
-- Puzzle: Sonido
-- -----------------------------------
local toolSon = Workspace:WaitForChild("toolSonido")
local triggerSon = Workspace:WaitForChild("BoxSonido") 

local usedSon = false
local hadSon = false
local copiaSon

toolSon:WaitForChild("Handle"):WaitForChild("ProximityPrompt").Triggered:Connect(function(playerQueActivo)
	-- 1. Verificamos que TÚ fuiste quien presionó la tecla
	if playerQueActivo == localPlayer then

		--print("Has interactuado con el prompt. Entregando herramienta...")
		hadSon = true
		--print("hadLuz se volvio a true")

		-- 2. Creamos la COPIA para tu mochila
		copiaSon = toolSon:Clone()

		--print("hizo clone")

		copiaSon.Name = "Sonido de estudio" -- Le damos nombre único
		copiaSon:WaitForChild("Handle").CanTouch = true
		copiaSon:WaitForChild("Handle"):WaitForChild("ProximityPrompt").Enabled = false
		copiaSon.Parent = localPlayer:WaitForChild("Backpack")
		copiaSon:WaitForChild("Handle").Anchored = false
		copiaSon:WaitForChild("particulas"):WaitForChild("ParticleEmitter").Enabled = false

		-- 3. OPCIONAL: Si quieres que se equipe SOLA de inmediato:
		local character = localPlayer.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:EquipTool(copiaSon)
			end
		end

		-- 4. ESCONDEMOS la original (lo que aprendimos de Descendants)
		-- Para que otros sigan viéndola pero tú ya no
		for _, objeto in pairs(toolSon:GetDescendants()) do
			if objeto:IsA("BasePart") then
				objeto.Transparency = 1
				objeto.CanTouch = false
				objeto.CanCollide = false
			elseif objeto:IsA("BillboardGui") or objeto:IsA("ProximityPrompt") then
				objeto.Enabled = false
			end
		end
		toolSon:WaitForChild("particulas"):WaitForChild("ParticleEmitter").Enabled = false
	end
end)

triggerSon.Touched:Connect(function(hit)
	--print(hit.Name)
	if usedSon then return end

	-- COMPROBACIÓN MAESTRA:
	-- Solo funciona si el objeto que toca es la caja 
	-- Y ADEMÁS el script confirma que TÚ eres el que interactuó con ella (yoLaTengo)
	if hit.Parent == copiaSon and hadSon then
		usedSon = true

		print("¡Caja detectada por MI!")

		-- Cambio de color LOCAL
		triggerSon.Color = Color3.fromRGB(0, 255, 0)

		-- SONIDO LOCAL
		local sonidoWin = Instance.new("Sound")
		sonidoWin.SoundId = "rbxassetid://113194405128446"
		sonidoWin.Parent = triggerSon 
		sonidoWin:Play()

		local handle = copiaSon:FindFirstChild("Handle")
		if handle then
			-- CLONAMOS LOCALMENTE
			local sonDecorativa = handle:Clone()
			sonDecorativa.Name = "SonidoDecorativo_Individual"
			sonDecorativa.CFrame = triggerSon.CFrame
			sonDecorativa.Anchored = true
			sonDecorativa.CanCollide = true
			sonDecorativa.Parent = Workspace

			local prompt = sonDecorativa:FindFirstChildWhichIsA("ProximityPrompt")
			if prompt then prompt:Destroy() end
		end

		-- Desaparece la herramienta SOLO para ti
		copiaSon:Destroy()

		triggerSon.CanTouch = false
		task.wait(1.5)
		triggerSon.Transparency = 1
		
		-- Sumamos Score para el teleport y corroboramos
		score += 1
		if score >= numCollects then
			teleport.Position = Vector3.new(163.122, 15.5, -17.5)
			partGlow.Enabled = true
			partEmmi.Enabled = true
			part.Enabled = true
		end
	end
end)

-- -----------------------------------
-- Puzzle: Camara fotográfica
-- -----------------------------------
local toolFoto = Workspace:WaitForChild("toolFoto")
local triggerFoto = Workspace:WaitForChild("BoxFoto") 

local usedFoto = false
local hadFoto = false
local copiaFoto

toolFoto:WaitForChild("Handle"):WaitForChild("ProximityPrompt").Triggered:Connect(function(playerQueActivo)
	
	if playerQueActivo == localPlayer then

		hadFoto = true
		copiaFoto = toolFoto:Clone()


		copiaFoto.Name = "Cámara Fotográfica" -- Le damos nombre único
		copiaFoto:WaitForChild("Handle").CanTouch = true
		copiaFoto:WaitForChild("Handle"):WaitForChild("ProximityPrompt").Enabled = false
		copiaFoto.Parent = localPlayer:WaitForChild("Backpack")
		copiaFoto:WaitForChild("Handle").Anchored = false
		copiaFoto:WaitForChild("particulas"):WaitForChild("ParticleEmitter").Enabled = false

		local character = localPlayer.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:EquipTool(copiaFoto)
			end
		end

		for _, objeto in pairs(toolFoto:GetDescendants()) do
			if objeto:IsA("BasePart") then
				objeto.Transparency = 1
				objeto.CanTouch = false
				objeto.CanCollide = false
			elseif objeto:IsA("BillboardGui") or objeto:IsA("ProximityPrompt") then
				objeto.Enabled = false
			end
		end
		toolFoto:WaitForChild("particulas"):WaitForChild("ParticleEmitter").Enabled = false
	end
end)

triggerFoto.Touched:Connect(function(hit)
	--print(hit.Name)
	if usedFoto then return end

	if hit.Parent == copiaFoto and hadFoto then
		usedFoto = true

		print("¡CamFot detectada por MI!")

		triggerFoto.Color = Color3.fromRGB(0, 255, 0)

		local sonidoWin = Instance.new("Sound")
		sonidoWin.SoundId = "rbxassetid://113194405128446"
		sonidoWin.Parent = triggerFoto 
		sonidoWin:Play()

		local handle = copiaFoto:FindFirstChild("Handle")
		if handle then
			-- CLONAMOS LOCALMENTE
			local fotoDecorativa = handle:Clone()
			fotoDecorativa.Name = "CamFoto_Individual"
			fotoDecorativa.CFrame = triggerFoto.CFrame
			fotoDecorativa.Anchored = true
			fotoDecorativa.CanCollide = true
			fotoDecorativa.Parent = Workspace

			local prompt = fotoDecorativa:FindFirstChildWhichIsA("ProximityPrompt")
			if prompt then prompt:Destroy() end
		end

		-- Desaparece la herramienta SOLO para ti
		copiaFoto:Destroy()

		triggerFoto.CanTouch = false
		task.wait(1.5)
		triggerFoto.Transparency = 1

		-- Sumamos Score para el teleport y corroboramos
		score += 1
		if score >= numCollects then
			teleport.Position = Vector3.new(163.122, 15.5, -17.5)
			partGlow.Enabled = true
			partEmmi.Enabled = true
			part.Enabled = true
		end
	end
end)

-- -----------------------------------
-- Puzzle: Cámara 2
-- -----------------------------------
local toolCam2 = Workspace:WaitForChild("toolcamara2")
local triggerCam2 = Workspace:WaitForChild("BoxCamara2") 

local usedCam2 = false
local hadCam2 = false
local copiaCam2

toolCam2:WaitForChild("Handle"):WaitForChild("ProximityPrompt").Triggered:Connect(function(playerQueActivo)

	if playerQueActivo == localPlayer then

		hadCam2 = true
		copiaCam2 = toolCam2:Clone()


		copiaCam2.Name = "Cámara de video" -- Le damos nombre único
		copiaCam2:WaitForChild("Handle").CanTouch = true
		copiaCam2:WaitForChild("Handle"):WaitForChild("ProximityPrompt").Enabled = false
		copiaCam2.Parent = localPlayer:WaitForChild("Backpack")
		copiaCam2:WaitForChild("Handle").Anchored = false
		copiaCam2:WaitForChild("particulas"):WaitForChild("ParticleEmitter").Enabled = false

		local character = localPlayer.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:EquipTool(copiaCam2)
			end
		end

		for _, objeto in pairs(toolCam2:GetDescendants()) do
			if objeto:IsA("BasePart") then
				objeto.Transparency = 1
				objeto.CanTouch = false
				objeto.CanCollide = false
			elseif objeto:IsA("BillboardGui") or objeto:IsA("ProximityPrompt") then
				objeto.Enabled = false
			end
		end
		toolCam2:WaitForChild("particulas"):WaitForChild("ParticleEmitter").Enabled = false
	end
end)

triggerCam2.Touched:Connect(function(hit)
	--print(hit.Name)
	if usedCam2 then return end

	if hit.Parent == copiaCam2 and hadCam2 then
		usedCam2 = true

		print("¡CamVideo2 detectada por MI!")

		triggerCam2.Color = Color3.fromRGB(0, 255, 0)

		local sonidoWin = Instance.new("Sound")
		sonidoWin.SoundId = "rbxassetid://113194405128446"
		sonidoWin.Parent = triggerCam2 
		sonidoWin:Play()

		local handle = copiaCam2:FindFirstChild("Handle")
		if handle then
			-- CLONAMOS LOCALMENTE
			local cam2Deco = handle:Clone()
			cam2Deco.Name = "CamVideo_Individual"
			cam2Deco.CFrame = triggerCam2.CFrame
			cam2Deco.Anchored = true
			cam2Deco.CanCollide = true
			cam2Deco.Parent = Workspace

			local prompt = cam2Deco:FindFirstChildWhichIsA("ProximityPrompt")
			if prompt then prompt:Destroy() end
		end

		-- Desaparece la herramienta SOLO para ti
		copiaCam2:Destroy()

		triggerCam2.CanTouch = false
		task.wait(1.5)
		triggerCam2.Transparency = 1

		-- Sumamos Score para el teleport y corroboramos
		score += 1
		if score >= numCollects then
			teleport.Position = Vector3.new(163.122, 15.5, -17.5)
			partGlow.Enabled = true
			partEmmi.Enabled = true
			part.Enabled = true
		end
	end
end)

-- -----------------------------------
-- Puzzle: Mini Lamp
-- -----------------------------------
local toolminil = Workspace:WaitForChild("toolminilamp")
local triggerMinil = Workspace:WaitForChild("Boxminilamp") 

local usedMinil = false
local hadMinil = false
local copiaMinil

toolminil:WaitForChild("Handle"):WaitForChild("ProximityPrompt").Triggered:Connect(function(playerQueActivo)

	if playerQueActivo == localPlayer then

		hadMinil = true
		copiaMinil = toolminil:Clone()


		copiaMinil.Name = "Mini Lámpara" -- Le damos nombre único
		copiaMinil:WaitForChild("Handle").CanTouch = true
		copiaMinil:WaitForChild("Handle"):WaitForChild("ProximityPrompt").Enabled = false
		copiaMinil.Parent = localPlayer:WaitForChild("Backpack")
		copiaMinil:WaitForChild("Handle").Anchored = false
		copiaMinil:WaitForChild("particulas"):WaitForChild("ParticleEmitter").Enabled = false

		local character = localPlayer.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:EquipTool(copiaMinil)
			end
		end

		for _, objeto in pairs(toolminil:GetDescendants()) do
			if objeto:IsA("BasePart") then
				objeto.Transparency = 1
				objeto.CanTouch = false
				objeto.CanCollide = false
			elseif objeto:IsA("BillboardGui") or objeto:IsA("ProximityPrompt") then
				objeto.Enabled = false
			end
		end
		toolminil:WaitForChild("particulas"):WaitForChild("ParticleEmitter").Enabled = false
	end
end)

triggerMinil.Touched:Connect(function(hit)
	--print(hit.Name)
	if usedMinil then return end

	if hit.Parent == copiaMinil and hadMinil then
		usedMinil = true

		print("¡Mini lámpara detectada por MI!")

		triggerMinil.Color = Color3.fromRGB(0, 255, 0)

		local sonidoWin = Instance.new("Sound")
		sonidoWin.SoundId = "rbxassetid://113194405128446"
		sonidoWin.Parent = triggerMinil 
		sonidoWin:Play()

		local handle = copiaMinil:FindFirstChild("Handle")
		if handle then
			-- CLONAMOS LOCALMENTE
			local minilDeco = handle:Clone()
			minilDeco.Name = "MiniLamp_Individual"
			minilDeco.CFrame = triggerMinil.CFrame
			minilDeco.Anchored = true
			minilDeco.CanCollide = true
			minilDeco.Parent = Workspace

			local prompt = minilDeco:FindFirstChildWhichIsA("ProximityPrompt")
			if prompt then prompt:Destroy() end
		end

		-- Desaparece la herramienta SOLO para ti
		copiaMinil:Destroy()

		triggerMinil.CanTouch = false
		task.wait(1.5)
		triggerMinil.Transparency = 1

		-- Sumamos Score para el teleport y corroboramos
		score += 1
		if score >= numCollects then
			teleport.Position = Vector3.new(163.122, 15.5, -17.5)
			partGlow.Enabled = true
			partEmmi.Enabled = true
			part.Enabled = true
		end
	end
end)


-- -----------------------------------
-- Puzzle: Mezcladora
-- -----------------------------------
local toolmez = Workspace:WaitForChild("toolmez")
local triggerMez = Workspace:WaitForChild("Boxmez") 

local usedMez = false
local hadMez = false
local copiaMez

toolmez:WaitForChild("Handle"):WaitForChild("ProximityPrompt").Triggered:Connect(function(playerQueActivo)

	if playerQueActivo == localPlayer then

		hadMez = true
		copiaMez = toolmez:Clone()


		copiaMez.Name = "Mezcladora" -- Le damos nombre único
		copiaMez:WaitForChild("Handle").CanTouch = true
		copiaMez:WaitForChild("Handle"):WaitForChild("ProximityPrompt").Enabled = false
		copiaMez.Parent = localPlayer:WaitForChild("Backpack")
		copiaMez:WaitForChild("Handle").Anchored = false
		copiaMez:WaitForChild("particulas"):WaitForChild("ParticleEmitter").Enabled = false

		local character = localPlayer.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:EquipTool(copiaMez)
			end
		end

		for _, objeto in pairs(toolmez:GetDescendants()) do
			if objeto:IsA("BasePart") then
				objeto.Transparency = 1
				objeto.CanTouch = false
				objeto.CanCollide = false
			elseif objeto:IsA("BillboardGui") or objeto:IsA("ProximityPrompt") then
				objeto.Enabled = false
			end
		end
		toolmez:WaitForChild("particulas"):WaitForChild("ParticleEmitter").Enabled = false
	end
end)

triggerMez.Touched:Connect(function(hit)
	--print(hit.Name)
	if usedMez then return end

	if hit.Parent == copiaMez and hadMez then
		usedMez = true

		print("¡Mezcladora detectada por MI!")

		triggerMez.Color = Color3.fromRGB(0, 255, 0)

		local sonidoWin = Instance.new("Sound")
		sonidoWin.SoundId = "rbxassetid://113194405128446"
		sonidoWin.Parent = triggerMez 
		sonidoWin:Play()

		local handle = copiaMez:FindFirstChild("Handle")
		if handle then
			-- CLONAMOS LOCALMENTE
			local mezDeco = handle:Clone()
			mezDeco.Name = "Mezcladora_Individual"
			mezDeco.CFrame = triggerMez.CFrame
			mezDeco.Anchored = true
			mezDeco.CanCollide = true
			mezDeco.Parent = Workspace

			local prompt = mezDeco:FindFirstChildWhichIsA("ProximityPrompt")
			if prompt then prompt:Destroy() end
		end

		-- Desaparece la herramienta SOLO para ti
		copiaMez:Destroy()

		triggerMez.CanTouch = false
		task.wait(1.5)
		triggerMez.Transparency = 1

		-- Sumamos Score para el teleport y corroboramos
		score += 1
		if score >= numCollects then
			teleport.Position = Vector3.new(163.122, 15.5, -17.5)
			partGlow.Enabled = true
			partEmmi.Enabled = true
			part.Enabled = true
		end
	end
end)

-- -----------------------------------
-- Puzzle: Aro
-- -----------------------------------
local toolaro = Workspace:WaitForChild("toolaro")
local triggerAro = Workspace:WaitForChild("BoxAro") 

local usedAro = false
local hadAro = false
local copiaAro

toolaro:WaitForChild("Handle"):WaitForChild("ProximityPrompt").Triggered:Connect(function(playerQueActivo)

	if playerQueActivo == localPlayer then

		hadAro = true
		copiaAro = toolaro:Clone()


		copiaAro.Name = "Aro de Luz" -- Le damos nombre único
		copiaAro:WaitForChild("Handle").CanTouch = true
		copiaAro:WaitForChild("Handle"):WaitForChild("ProximityPrompt").Enabled = false
		copiaAro.Parent = localPlayer:WaitForChild("Backpack")
		copiaAro:WaitForChild("Handle").Anchored = false
		copiaAro:WaitForChild("particulas"):WaitForChild("ParticleEmitter").Enabled = false

		local character = localPlayer.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:EquipTool(copiaAro)
			end
		end

		for _, objeto in pairs(toolaro:GetDescendants()) do
			if objeto:IsA("BasePart") then
				objeto.Transparency = 1
				objeto.CanTouch = false
				objeto.CanCollide = false
			elseif objeto:IsA("BillboardGui") or objeto:IsA("ProximityPrompt") then
				objeto.Enabled = false
			end
		end
		toolaro:WaitForChild("particulas"):WaitForChild("ParticleEmitter").Enabled = false
	end
end)

triggerAro.Touched:Connect(function(hit)
	--print(hit.Name)
	if usedAro then return end

	if hit.Parent == copiaAro and hadAro then
		usedAro = true

		print("¡Aro detectada por MI!")

		triggerAro.Color = Color3.fromRGB(0, 255, 0)

		local sonidoWin = Instance.new("Sound")
		sonidoWin.SoundId = "rbxassetid://113194405128446"
		sonidoWin.Parent = triggerAro 
		sonidoWin:Play()

		local handle = copiaAro:FindFirstChild("Handle")
		if handle then
			-- CLONAMOS LOCALMENTE
			local aroDeco = handle:Clone()
			aroDeco.Name = "Aro_Individual"
			aroDeco.CFrame = triggerAro.CFrame
			aroDeco.Anchored = true
			aroDeco.CanCollide = true
			aroDeco.Parent = Workspace

			local prompt = aroDeco:FindFirstChildWhichIsA("ProximityPrompt")
			if prompt then prompt:Destroy() end
		end

		-- Desaparece la herramienta SOLO para ti
		copiaAro:Destroy()

		triggerAro.CanTouch = false
		task.wait(1.5)
		triggerAro.Transparency = 1

		-- Sumamos Score para el teleport y corroboramos
		score += 1
		if score >= numCollects then
			teleport.Position = Vector3.new(163.122, 15.5, -17.5)
			partGlow.Enabled = true
			partEmmi.Enabled = true
			part.Enabled = true
		end
	end
end)
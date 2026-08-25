-- Sistema de NPCs decorativos (todo en cliente)
-- Detecta proximidad y muestra burbujas de dialogo

local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

-- CONFIGURACION
local TRIGGER_DISTANCE = 15 -- Studs para mostrar la burbuja
local BUBBLE_OFFSET = 4 -- Studs arriba de la cabeza
local ANIMATION_DURATION = 0.3 -- Segundos
local CHECK_INTERVAL = 0.2 -- Segundos entre verificaciones
local BUBBLE_PADDING = 12 -- Padding del texto

-- Estilo de la burbuja
local BUBBLE_COLOR = Color3.new(1, 1, 1)
local BUBBLE_TRANSPARENCY = 0.2
local CORNER_RADIUS = UDim.new(0, 10)
local TEXT_COLOR = Color3.new(0, 0, 0)
local TEXT_SIZE = 20
local FONT = Enum.Font.GothamBold
local DEFAULT_TEXT = "..."

-- Tabla de NPCs y sus estados
local npcs = {}

-- Crear burbuja para un NPC
local function createBubble(npc, text)
	local head = npc:FindFirstChild("Head")
	if not head then return nil end
	
	-- Calcular tamaño del texto
	local textSize = TextService:GetTextSize(
		text,
		TEXT_SIZE,
		FONT,
		Vector2.new(1000, 1000)
	)
	
	local bubbleWidth = textSize.X + BUBBLE_PADDING * 2
	local bubbleHeight = textSize.Y + BUBBLE_PADDING * 2
	
	-- Crear BillboardGui
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "DialogBubble"
	billboardGui.Size = UDim2.new(0, bubbleWidth, 0, bubbleHeight)
	billboardGui.StudsOffset = Vector3.new(0, BUBBLE_OFFSET, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Enabled = false
	billboardGui.ResetOnSpawn = false
	billboardGui.Parent = head
	
	-- Fondo
	local frame = Instance.new("Frame")
	frame.Name = "BubbleFrame"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = BUBBLE_COLOR
	frame.BackgroundTransparency = BUBBLE_TRANSPARENCY
	frame.BorderSizePixel = 0
	frame.Parent = billboardGui
	
	-- Bordes redondeados
	local corner = Instance.new("UICorner")
	corner.CornerRadius = CORNER_RADIUS
	corner.Parent = frame
	
	-- Texto
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.TextColor3 = TEXT_COLOR
	textLabel.TextSize = TEXT_SIZE
	textLabel.Font = FONT
	textLabel.Parent = frame
	
	return billboardGui
end

-- Mostrar burbuja con animacion
local function showBubble(npc)
	local data = npcs[npc]
	if not data or data.isVisible then return end
	
	-- Obtener texto del atributo del NPC
	local text = npc:GetAttribute("DialogText") or DEFAULT_TEXT
	
	-- Crear burbuja si no existe
	if not data.bubble then
		data.bubble = createBubble(npc, text)
	end
	
	local bubble = data.bubble
	if not bubble then return end
	
	local frame = bubble:FindFirstChild("BubbleFrame")
	if not frame then return end
	
	bubble.Enabled = true
	frame.Size = UDim2.new(0, 0, 0, 0)
	frame.BackgroundTransparency = 1
	
	local tween = TweenService:Create(frame, TweenInfo.new(ANIMATION_DURATION, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = BUBBLE_TRANSPARENCY
	})
	tween:Play()
	
	data.isVisible = true
end

-- Ocultar burbuja con animacion
local function hideBubble(npc)
	local data = npcs[npc]
	if not data or not data.isVisible then return end
	
	local bubble = data.bubble
	if not bubble then return end
	
	local frame = bubble:FindFirstChild("BubbleFrame")
	if not frame then
		if bubble.Parent then bubble:Destroy() end
		data.bubble = nil
		data.isVisible = false
		return
	end
	
	local tween = TweenService:Create(frame, TweenInfo.new(ANIMATION_DURATION, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Size = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1
	})
	tween:Play()
	
	tween.Completed:Connect(function()
		if bubble and bubble.Parent then
			bubble.Enabled = false
		end
	end)
	
	data.isVisible = false
end

-- Registrar un NPC
local function registerNPC(npc)
	if npcs[npc] then return end
	npcs[npc] = {
		bubble = nil,
		isVisible = false
	}
end

-- Buscar NPCs en la carpeta NPCs
local function scanForNPCs()
	local npcsFolder = workspace:FindFirstChild("NPCs")
	if not npcsFolder then return end
	
	for _, child in ipairs(npcsFolder:GetChildren()) do
		if child:IsA("Model") and child:FindFirstChild("Humanoid") then
			registerNPC(child)
		end
	end
end

-- Detectar nuevos NPCs
local npcsFolder = workspace:FindFirstChild("NPCs")
if npcsFolder then
	npcsFolder.ChildAdded:Connect(function(child)
		if child:IsA("Model") then
			task.wait(0.1)
			registerNPC(child)
		end
	end)
end

-- Loop principal - verifica distancia
task.spawn(function()
	while task.wait(CHECK_INTERVAL) do
		local character = Player.Character
		if not character then continue end
		
		local playerRoot = character:FindFirstChild("HumanoidRootPart")
		if not playerRoot then continue end
		
		for npc, data in pairs(npcs) do
			local npcRoot = npc.PrimaryPart or npc:FindFirstChild("HumanoidRootPart")
			if npcRoot then
				local distance = (npcRoot.Position - playerRoot.Position).Magnitude
				local isNear = distance <= TRIGGER_DISTANCE
				
				if isNear and not data.isVisible then
					showBubble(npc)
				elseif not isNear and data.isVisible then
					hideBubble(npc)
				end
			end
		end
	end
end)

-- Escanear NPCs al inicio
task.wait(1)
scanForNPCs()

print("[Cliente] Sistema de NPCs decorativos iniciado")
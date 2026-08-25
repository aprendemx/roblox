local scriptObj = script
local parent = script.Parent

local humanoid = parent:WaitForChild("Humanoid")

-- 1. Intentamos buscar el Animator o crearlo si no existe
local animator = humanoid:FindFirstChildWhichIsA("Animator")

if not animator then
	animator = Instance.new("Animator")
	animator.Name = "Animator"
	animator.Parent = humanoid
	print("🛠️ Animator no detectado, se ha creado uno nuevo en: " .. parent.Name)
end

-- 2. Obtenemos la ID desde el atributo
local animId = scriptObj:GetAttribute("AnimID")

if animId and animId ~= "" then
	-- 3. Creamos el objeto Animation
	local animation = Instance.new("Animation")
	animation.AnimationId = animId
	
	-- 4. Cargamos y reproducimos
	local success, track = pcall(function()
		return animator:LoadAnimation(animation)
	end)

	if success and track then
		track.Looped = true
		track:Play()
		print("✅ Animación R6 iniciada correctamente.")
	else
		warn("❌ Error al cargar la animación. Verifica que la ID sea válida para R6.")
	end
else
	warn("⚠️ Falta el atributo 'AnimID' o está vacío en el script de: " .. parent.Name)
end
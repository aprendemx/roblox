--!nocheck
-- ============================================================================
--  DESINFECTANTE DE BACKDOORS  —  correr en el Command Bar de Studio
--  (View -> Command Bar). Abrir cada mapa, pegar esto, Enter. Guardar al final.
--
--  Detecta la familia de troyanos por require injection documentada en
--  security/BACKDOOR.md, mediante firmas únicas del malware.
--
--  MODO SEGURO: con DELETE = false solo IMPRIME lo que borraría (simulación).
--  Revisá la lista. Si coincide con el informe, poné DELETE = true y corré otra vez.
-- ============================================================================

local DELETE = false  -- << poné en true SOLO tras revisar la simulación

-- Firmas exclusivas del malware. Ningún script legítimo contiene estas cadenas.
local SIGNATURES = {
	"TypeLibrary",                 -- variantes LightConfig / Structure
	"getArchetype",
	"ChildReference",
	"NumberPose",                  -- CoreSkyboxSystem / qPerfectionWeld
	"TextureConfigurationSystem",  -- WorkspaceOptimizer
	'GetAttribute("ConfigID")',
	"require(game.CFrame)",        -- AutoWeld
	-- Asset IDs de payload (IoC):
	"104079754833849",
	"123656748896023",
	"139714014570733",
	"95925098868592",
}

local function isMalware(source)
	for _, sig in ipairs(SIGNATURES) do
		if string.find(source, sig, 1, true) then
			return sig
		end
	end
	return nil
end

-- 1) Detección
local flagged = {}
for _, inst in ipairs(game:GetDescendants()) do
	if inst:IsA("LuaSourceContainer") then
		local hit = isMalware(inst.Source)
		if hit then
			table.insert(flagged, { inst = inst, sig = hit })
		end
	end
end

-- 2) Reporte
print(("=== DESINFECTANTE — %d coincidencia(s) ==="):format(#flagged))
for i, f in ipairs(flagged) do
	print(("  [%d] (%s)  %s   << firma: %s"):format(
		i, f.inst.ClassName, f.inst:GetFullName(), f.sig))
end

if #flagged == 0 then
	print(">> Limpio. No se encontraron backdoors en este lugar.")
	return
end

-- 3) Eliminación (solo si DELETE = true)
if not DELETE then
	print(">> SIMULACIÓN. No se borró nada.")
	print(">> Revisá la lista. Si es correcta, poné DELETE = true y corré otra vez.")
	return
end

local removed = 0
for _, f in ipairs(flagged) do
	-- Al destruir un script raíz se van también sus módulos hijos.
	-- El guard evita tocar algo que ya cayó como hijo de otro.
	if f.inst:IsDescendantOf(game) then
		local ok = pcall(function()
			f.inst:Destroy()
		end)
		if ok then
			removed += 1
		end
	end
end

print((">> ELIMINADOS %d instancia(s) raíz. Guardá el lugar (Ctrl+S)."):format(removed))
print(">> Volvé a correr con DELETE = false para confirmar 0 coincidencias.")

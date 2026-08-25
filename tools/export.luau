--!nocheck
-- ============================================================================
--  Exporta los scripts de un .rbxl a una carpeta src/ (convención Rojo).
--
--  Uso:
--    lune run tools/export            -> exporta los 3 mapas
--    lune run tools/export mapa       -> exporta solo ese mapa
--    lune run tools/export laberinto
--    lune run tools/export parkour
-- ============================================================================

local fs = require("@lune/fs")
local process = require("@lune/process")
local roblox = require("@lune/roblox")

-- Mapa lógico -> archivo de origen y carpeta de salida
local MAPS = {
	mapa      = { place = "places/MapaAprende.rbxl",      out = "maps/mapa/src" },
	laberinto = { place = "places/laberintoAprende.rbxl", out = "maps/laberinto/src" },
	parkour   = { place = "places/parkourAprende.rbxl",   out = "maps/parkour/src" },
}

-- Extensión según la clase, siguiendo la convención de Rojo
local function extFor(inst)
	if inst.ClassName == "Script" then
		return ".server.luau"
	elseif inst.ClassName == "LocalScript" then
		return ".client.luau"
	else
		return ".luau" -- ModuleScript
	end
end

-- Ruta jerárquica del script dentro del árbol del juego
local function pathOf(inst, game)
	local parts = {}
	local cur = inst
	while cur and cur ~= game do
		table.insert(parts, 1, cur.Name)
		cur = cur.Parent
	end
	return table.concat(parts, "/")
end

local function exportMap(key, cfg)
	local game = roblox.deserializePlace(fs.readFile(cfg.place))

	-- Se recrea la carpeta desde cero: así los scripts borrados en Studio
	-- desaparecen también del volcado (paridad real con el .rbxl).
	if fs.isDir(cfg.out) then
		fs.removeDir(cfg.out)
	end
	fs.writeDir(cfg.out)

	local used = {} -- rutas ya escritas, para detectar colisiones
	local count, collisions = 0, 0

	for _, desc in game:GetDescendants() do
		if desc:IsA("LuaSourceContainer") then
			local rel = pathOf(desc, game)
			local ext = extFor(desc)
			local full = cfg.out .. "/" .. rel .. ext

			-- BUG CORREGIDO: hermanos con el mismo nombre escribían al mismo
			-- archivo y se pisaban (así se perdieron 11 de 12 qPerfectionWeld).
			-- Ahora, ante una colisión, se agrega un sufijo _2, _3, ...
			if used[full] then
				collisions += 1
				local base = cfg.out .. "/" .. rel
				local n = 2
				repeat
					full = string.format("%s_%d%s", base, n, ext)
					n += 1
				until not used[full]
			end
			used[full] = true

			local dir = full:match("(.*)/[^/]*$")
			if dir then
				fs.writeDir(dir)
			end
			fs.writeFile(full, desc.Source)
			count += 1
		end
	end

	print(string.format(
		"✓ %-10s %3d scripts  (%d colisiones resueltas)  → %s",
		key, count, collisions, cfg.out
	))
end

-- Selección por argumento; sin argumento, exporta todos
local target = process.args[1]
if target then
	local cfg = MAPS[target]
	if not cfg then
		print("Mapa desconocido: " .. target .. "   (opciones: mapa, laberinto, parkour)")
		process.exit(1)
	end
	exportMap(target, cfg)
else
	for _, key in ipairs({ "mapa", "laberinto", "parkour" }) do
		exportMap(key, MAPS[key])
	end
end

--!nocheck
-- Busca instancias por nombre (subcadena, case-insensitive) en los 3 .rbxl.
-- Uso: lune run tools/search-names -- portillo rocio grave tumba
local fs = require("@lune/fs")
local process = require("@lune/process")
local roblox = require("@lune/roblox")

local PLACES = {
	mapa = "places/MapaAprende.rbxl",
	laberinto = "places/laberintoAprende.rbxl",
	parkour = "places/parkourAprende.rbxl",
}

local terms = process.args
if #terms == 0 then terms = { "portillo", "rocio", "roc\u{00ed}o", "grave", "tumba" } end

local function fullName(inst, game)
	local parts = {}
	local cur = inst
	while cur and cur ~= game do
		table.insert(parts, 1, cur.Name)
		cur = cur.Parent
	end
	return table.concat(parts, " / ")
end

for key, path in pairs(PLACES) do
	local game = roblox.deserializePlace(fs.readFile(path))
	print("===== " .. key .. " =====")
	local hits = 0
	for _, inst in game:GetDescendants() do
		local lname = string.lower(inst.Name)
		for _, t in ipairs(terms) do
			if string.find(lname, string.lower(t), 1, true) then
				hits += 1
				print(string.format("  [%s]  %s", inst.ClassName, fullName(inst, game)))
				break
			end
		end
	end
	if hits == 0 then print("  (sin coincidencias)") end
end

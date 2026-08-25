local fs = require("@lune/fs")
local roblox = require("@lune/roblox")

  local game = roblox.deserializePlace(fs.readFile("places/parkourAprende.rbxl"))

local OUT = "maps/parkour/src"
fs.writeDir(OUT)

-- Mapea la clase de script a la extensión que usa la convención Rojo
local function extFor(inst)
    if inst.ClassName == "Script" then return ".server.luau"
    elseif inst.ClassName == "LocalScript" then return ".client.luau"
    else return ".luau" end -- ModuleScript
end

-- Construye la ruta jerárquica del script dentro del árbol
local function pathOf(inst)
    local parts = {}
    local cur = inst
    while cur and cur ~= game do
        table.insert(parts, 1, cur.Name)
        cur = cur.Parent
    end
    return table.concat(parts, "/")
end

local count = 0
for _, desc in game:GetDescendants() do
    if desc:IsA("LuaSourceContainer") then -- Script, LocalScript, ModuleScript
        local rel = pathOf(desc)
        local dir = OUT .. "/" .. rel:match("(.*)/[^/]*$" ) -- carpeta contenedora
        if dir then fs.writeDir(dir) end
        local full = OUT .. "/" .. rel .. extFor(desc)
        fs.writeFile(full, desc.Source)
        count += 1
        print("→ " .. full)
    end
end

print(string.format("\nListo. %d scripts exportados a ./%s", count, OUT))

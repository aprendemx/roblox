# Código muerto y roto (parkour)

> Diagnóstico de scripts que existen pero no se ejecutan (o fallan al ejecutar).
> **No** son malware ni vulnerabilidades: son errores propios / restos de desarrollo.
> A la fecha de este documento **no** se corrigieron; se dejan registrados para decidir.

Todos en `maps/parkour/src/`.

## 1. `StarterPlayer/StarterPlayerScripts/MetaScript.server.luau` — muerto por triplicado

```lua
local triggerPart = script.Parent
triggerPart.Touched:Connect(function(hit)
	local player = Players:GetPlayerFromCharacter(character)  -- Players no declarado
	textLabel.Text = "Actualizando..."                        -- textLabel no declarado
```

- Es un `Script` (servidor) dentro de `StarterPlayerScripts`, contenedor que **solo
  ejecuta `LocalScript`**. Nunca arranca.
- Aunque arrancara: `Players` y `textLabel` no están declarados → error inmediato.
- `script.Parent` es el contenedor, no un `Part` con evento `.Touched` útil.

Parece un intento anterior de lo que hoy hace `MetaTrigger.client.luau` (que sí
funciona). **Candidato a borrar.**

## 2. `ServerScriptService/DataStore.server.luau` — placeholder

```lua
print("Hello world!")
```

Nombre de sistema de guardado, contenido de "hola mundo". No persiste nada.
**Candidato a borrar.**

## 3. `ServerScriptService/Leaderboard.server.luau` — 100% comentado

El archivo entero son comentarios; no hay una sola línea de código vivo. La
funcionalidad real de leaderstats la cubre `Leaderstats.server.luau`.
**Candidato a borrar.**

## 4. `StarterPlayer/StarterPlayerScripts/PlayerPositionDisplay.client.luau` — feature roto

```lua
local coins = leaderstats:WaitForChild("Coins", 9999)   -- "Coins" nunca se crea
```

`Leaderstats.server.luau` crea **`Fruits`**, no `Coins` (la creación de `Coins` está
comentada, líneas 12-14). Entonces este script **se cuelga ~2.7 horas** (el timeout de
9999 s) esperando un valor que no existe, y nunca continúa.

A diferencia de los otros tres, esto **no es basura**: es un *tablero de posición*
inconcluso. Si el tablero nunca mostró nada en el juego, la causa es esta línea.
**Decisión abierta:** terminarlo (cambiar `Coins` → `Fruits` y probar) o descartarlo.

## Resumen

| Script | Estado | Sugerencia |
|---|---|---|
| `MetaScript.server.luau` | No ejecuta (contenedor + vars sin declarar) | Borrar |
| `DataStore.server.luau` | Placeholder `print` | Borrar |
| `Leaderboard.server.luau` | Todo comentado | Borrar |
| `PlayerPositionDisplay.client.luau` | Feature roto (`Coins` inexistente) | Decidir: reparar o borrar |

> Estos scripts viven en `ServerScriptService` / `StarterPlayerScripts`, ramas que Rojo
> **sí** sincroniza. Es decir, se pueden corregir desde `src/` con Rojo, sin pasar por
> Studio (a diferencia de lo que estaba en `Workspace`).

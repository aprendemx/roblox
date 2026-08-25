# Vulnerabilidad: sistema de frutas sin autoridad de servidor (parkour)

> Diagnóstico. **No** implica que el código esté corregido — a la fecha de este
> documento, la vulnerabilidad sigue presente. No es malware de terceros: es un
> error de diseño propio del mapa.

## Dónde

- Servidor: `maps/parkour/src/ServerScriptService/FruitServerHandler.server.luau`
- Cliente: `maps/parkour/src/StarterPlayer/StarterCharacterScripts/CoinScript.client.luau`
- Ranking global afectado: `ServerScriptService/GlobalBoardHandler.server.luau`
  (guarda el puntaje en un `OrderedDataStore` **global**).

## El problema

El servidor suma puntaje confiando ciegamente en el cliente:

```lua
collectFruitEvent.OnServerEvent:Connect(function(player)
	local fruits = player.leaderstats:FindFirstChild("Fruits")
	if not fruits then return end
	fruits.Value = fruits.Value + 1   -- suma sin validar NADA
end)
```

No verifica:
- que la fruta exista,
- que el jugador esté cerca de una fruta,
- que esa fruta no se haya recogido antes.

Toda la lógica de recolección (detectar el toque, ocultar la fruta) vive en el
**cliente** (`CoinScript`), que es territorio del jugador y por lo tanto manipulable.

## Impacto

Un jugador con un exploiter dispara el evento a mano, sin moverse:

```lua
for i = 1, 100000 do
	game.ReplicatedStorage.CollectFruit:FireServer()
end
```

Resultado: puntaje arbitrario. Y como `GlobalBoardHandler` lo persiste en un
`OrderedDataStore` **global**, el valor tramposo queda en el ranking de **todos los
servidores**, de forma permanente. El mismo problema aplica a `CollectBadItem`
(restar puntaje a otros no, pero sí ensuciar el propio / probar límites negativos).

## Principio violado

**El cliente pide, el servidor decide.** Hoy es al revés: el cliente decide cuándo
sumar y el servidor obedece. Nunca hay que confiar en un `FireServer()` para mutar
estado persistente sin validación.

## Opciones de corrección (pendientes de decidir)

### A. Autoridad server-side completa (recomendada)

Mover la recolección al servidor:

- El **servidor** conecta el `.Touched` de cada fruta.
- Al tocar: valida que sea un jugador, calcula distancia real fruta↔jugador,
  y marca la fruta como consumida **en el servidor** (evita doble conteo).
- El cliente queda solo para lo cosmético: sonido y ocultar la fruta localmente.

Cierra el exploit de raíz. Requiere reescribir `CoinScript` (cliente) y
`FruitServerHandler` (servidor).

### B. Validación mínima en el servidor

El cliente sigue avisando, pero antes de sumar el servidor valida:

- que la fruta referida exista y no esté ya consumida,
- que el jugador esté a una distancia plausible de ella,
- un cooldown por jugador para frenar el spam.

Menos reescritura, pero sigue dependiendo del cliente para *elegir* la fruta.
Mitiga, no elimina del todo.

## Notas relacionadas (no forman parte de esta vuln, pero conviene revisar)

- `GlobalBoardHandler`: hace `GetAsync` + `SetAsync` por jugador por leaderboard cada
  60s → riesgo de *throttling* de DataStore con varios jugadores.
- El puntaje puede quedar negativo sin límite inferior (por `CollectBadItem`).

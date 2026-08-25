# Gameplay de los mapas

Descripción del objetivo, mecánicas, interacciones y eventos de cada mapa, inferida
de sus scripts (rama `main`, ya sin malware). Se omiten scripts stock de Roblox
(`Animate`, `Health`, `Sound`, `qPerfectionWeld`) y créditos.

Convención: **disparador** = qué activa la interacción (`Touched`, proximidad, evento
programado, `RemoteEvent`, etc.).

---

## Sistemas compartidos por los tres mapas

- **NPCs con burbuja de diálogo** — `StarterPlayer/StarterPlayerScripts/DecorativeNPCClient.client.luau`.
  Escanea `workspace.NPCs`; por proximidad (loop cada 0.2 s, radio 15 studs) muestra
  un `BillboardGui` animado sobre la cabeza del NPC con el texto de su atributo
  `DialogText`. Todo en cliente, puramente decorativo.
- **Efecto de flotación** — `FloatingEffect.server.luau`. Oscila el `CFrame` de un
  BasePart con curva senoidal + inclinación tipo péndulo (en `Heartbeat`). Decorativo.
- **Teleporte externo "Mundo principal"** — un `TP` con `.Touched` que llama a
  `TeleportService:Teleport(JuegoID, player)` hacia otra experiencia de Roblox.

> Los `JuegoID` de teleporte apuntan a experiencias externas. Conviene verificar que
> sean lugares propios de la institución (ver nota en `security/BACKDOOR.md`).

---

## Mapa `mapa` — Hub social / plaza central

**Objetivo:** no es competitivo. Es un **lobby de exploración** y punto de partida hacia
los otros minijuegos: una plaza poblada de NPCs (avatares de personas reales), zonas
temáticas (un arrecife de coral submarino, aros atravesables tipo circo) y pads de
teleporte. Suma eventos ambientales sorpresa.

### Mecánicas

| Mecánica | Script | Disparador | Qué hace |
|---|---|---|---|
| Aros atravesables | `Workspace/aro/aroDetector/Script.server.luau` (×13, uno por aro) | `Touched` (Humanoid) | Sonido 3D + emite 40 partículas al atravesar. Cooldown 2 s. |
| Teleporte interno a Plaza | `Workspace/PadsToPlaza/TeleportScript.server.luau` | `Touched` (HumanoidRootPart) | Reubica al jugador al `Goal` del pad (+3.25 Y), mismo lugar. |
| Teleporte interno a Minijuegos | `Workspace/PadsToMinigames/TeleportScript.server.luau` | `Touched` (HumanoidRootPart) | Igual, a la zona de minijuegos. |
| Elevación de pergaminos | `Workspace/Cierrecaminos/pergaminos_/PergaminosRise.server.luau` | Temporizado (15 min de sesión) | Sube los pergaminos 15 studs en Y. |

### Teleportes externos

| Pad | JuegoID | Nombre mostrado |
|---|---|---|
| `teleportLaberinto` | `97059722397266` | "El show debe continuar" |
| `teleportNave` | `97059722397266` | "Viaje espacial" *(mismo ID que Laberinto — probable pendiente de actualizar)* |
| `teleportParkour` | `77960067423699` | "Mueve el músculo" |

### NPCs (15 + Aji)

Todos reciben la burbuja de diálogo. Con comportamiento propio:

- **Ori** — copia al NPC la apariencia (`HumanoidDescription`) del último jugador que entra.
- **Karime** — reproduce un emote en loop (animación `15122972413`).
- **Johnny** — ragdoll al morir + cámara adjunta al cuerpo.
- **Adri / Rita** — traen `Fall` (daño por caída) y `SprintScript` (sprint con tecla "0"),
  residuos del free-model; sobre un NPC estático no aportan gameplay.

### Eventos programados

- **Gravedad cero (principal)** — `ServerScriptService/PortilloScript.server.luau`.
  A partir del **31-ago-2026 18:00 UTC**, cada 2 min tira un dado; con 25 % de chance
  espera 300–600 s y entonces pone `Gravity = 0` y desancla todo el mapa (menos jugadores
  y Terrain) con impulso aleatorio. Se dispara una sola vez.
- **Gravedad cero (secundaria)** — `Cierrecaminos/pergaminos_/Grave/LocalScript.client.luau`.
  Fecha **16-jun-2026** (ya pasada). Misma lógica pero como LocalScript (efecto local);
  versión previa/de prueba de la anterior.

### Datos

- **TimePlayedLeaderboard** — `Workspace/TimePlayedLeaderboard/TimePlayedClass.server.luau`
  (config en `Settings.luau`). `OrderedDataStore` `"TopTimePlayed"`: registra minutos
  jugados por `UserId`, incrementa cada 1 min, muestra top 10 (nombre + headshot + tiempo
  `dd:hh:mm`). Muestra el avatar del 1er lugar bailando junto al tablero.

---

## Mapa `laberinto` — Puzzle de recolección (montar un set de estudio)

**Objetivo:** pese al nombre, no es un laberinto de paredes. Es un **puzzle de recolección**:
el jugador junta **8 herramientas de estudio** (luz, cámara, sonido, mezcladora, aro de
luz, etc.) repartidas por el mapa y **coloca cada una en su caja correspondiente**. Al
completar las 8, se activa un pad de teleporte a "Mundo principal". Todo el progreso es
**por jugador** (cada quien resuelve su propia copia).

### El puzzle — `StarterPlayer/StarterPlayerScripts/PuzzleManagerV4.client.luau`

Motor real del juego (LocalScript). 8 sub-puzzles en dos fases:

1. **Recoger** (disparador: `ProximityPrompt` en `toolX.Handle`): clona la herramienta al
   `Backpack` del jugador, la equipa, y oculta la original solo para ese jugador.
2. **Colocar** (disparador: `.Touched` en la caja `BoxX`): al tocar la caja correcta con
   la herramienta equipada, la caja se pone verde, suena un efecto, aparece una versión
   decorativa sobre la caja y `score += 1`.

**Pares herramienta → caja:** Luz→BoxLuces, Cámara→BoxCamara, Sonido→BoxSonido,
Foto→BoxFoto, Cámara2→BoxCamara2, Minilámpara→Boxminilamp, Mezcladora→Boxmez, Aro→BoxAro.

**Victoria:** con `score >= 8`, mueve el teleport `TP` a la posición jugable y enciende
el pad de salida (glow + partículas).

### Otras interacciones

| Elemento | Script | Disparador | Qué hace |
|---|---|---|---|
| Cámara cinemática (activar) | `Workspace/Camera/Camera/S.server.luau` | `ClickDetector` | Clona una GUI a la `PlayerGui` para "entrar" a una vista fija. |
| Cámara cinemática (vista) | `Workspace/Camera/Camera/GUI/Button/V/S.client.luau` | `RenderStepped` / botón | Fija la cámara (`Scriptable`, FOV 90) sobre un punto; un botón o morir la restaura. |
| BoomBox de Jessica | `Workspace/NPCs/Jessica/BoomBox/{Server,Client}` | Equipar + clic (RemoteEvent) | GUI para escribir un ID de canción y reproducirla en loop desde el ítem. Lúdico. |

### Teleporte externo

- `teleportMundo` → **JuegoID `110003379571789`** ("Mundo principal"). Solo se coloca en
  posición jugable al recolectar las 8 herramientas.

### NPCs (11)

Todos decorativos con burbuja de diálogo. **Bobby** copia el avatar del jugador que entra;
**Karime** y **Kenia** hacen emote en loop.

> **Duplicidad a saber:** existe también `ServerScriptService/PuzzleDetector.server.luau`,
> una versión **incompleta** del puzzle (solo 3 objetos, su `showTeleport()` es un `TODO`
> con `print`). El gameplay real lo gobierna `PuzzleManagerV4`. `colorTrigger.client.luau`
> es un efecto visual suelto sobre `BoxLuces`, sin relación con el puzzle.

---

## Mapa `parkour` — Parkour de recolección

**Objetivo:** recorrer un circuito de obstáculos recogiendo frutas (+1) y evitando "cosas"
(−1), con checkpoints que guardan el progreso, hacia una meta final. El puntaje total se
persiste en un **leaderboard global**.

**Loop:** spawnear → avanzar con las mecánicas (trampolines, cintas) → recoger frutas /
esquivar cosas → tocar checkpoints → morir y reaparecer en el último checkpoint si tocás
una trampa → llegar a la meta. El mejor puntaje se guarda y se muestra en el board global.

### Mecánicas (todas por `CollectionService` con tags)

| Mecánica | Script | Tag | Disparador | Detalle |
|---|---|---|---|---|
| Checkpoints | `ServerScriptService/CheckpointManager.server.luau` | `Checkpoint` | `Touched` | Guarda el último checkpoint; al respawnear (`CharacterAdded`) reubica ahí con `PivotTo`. |
| Cintas transportadoras | `ServerScriptService/ConveyorManager.server.luau` | `Conveyor` | continuo | Ancla y fija velocidad en −Z local. Atributo `Speed` (default 10). |
| Trampas | `ServerScriptService/TrapManager.server.luau` | `TrapPart` | `Touched` | Pone `Humanoid.Health = 0` → mata al jugador. |
| Trampolines | `StarterPlayer/StarterPlayerScripts/BouncePadManager.client.luau` | `BouncePad` | continuo *(LocalScript)* | Impulso vertical. Atributo `BounceImpulse` (default 300). |

### Sistema de frutas / puntaje

Flujo cliente→servidor vía RemoteEvents en `ReplicatedStorage`:

- **Cliente** — `StarterPlayer/StarterCharacterScripts/CoinScript.client.luau`: conecta
  `.Touched` en los objetos de `workspace.Frutas` (`Fruit`) y `workspace.Otros` (`cosa`);
  al recoger, dispara el RemoteEvent, oculta el objeto localmente y suena.
- **Servidor** — `ServerScriptService/FruitServerHandler.server.luau`:
  `CollectFruit` → `Fruits += 1`; `CollectBadItem` → `Fruits -= 1`.
- Las frutas físicas (`Workspace/Frutas/Fruit/Script.server.luau`, ~36 copias) solo rotan
  como efecto visual.

> ⚠️ **El servidor confía en el cliente sin validar** → es explotable. Detalle en
> [`../security/VULN-FRUTAS.md`](../security/VULN-FRUTAS.md).

### Leaderboards

- **Leaderstats** — `ServerScriptService/Leaderstats.server.luau`: crea `leaderstats.Fruits`
  al entrar (Coins/Gems están comentados).
- **GlobalBoardHandler** — `ServerScriptService/GlobalBoardHandler.server.luau`: leaderboard
  global persistente. Cada 60 s guarda en un `OrderedDataStore` (solo si supera el récord)
  y muestra el top 100 en un `SurfaceGui`, con oro/plata/bronce en los primeros 3.
- **GUI de conteo** — `StarterGui/CoinGui/.../LocalScript.client.luau`: muestra el contador
  de frutas en pantalla.

### Otros

- **MetaTrigger** — `StarterPlayer/StarterPlayerScripts/MetaTrigger.client.luau`: al tocar
  `Workspace.TriggerMeta` (una sola vez), feedback local "Llegaste" → "Felicidades".
- **teleportMundo** → **JuegoID `110003379571789`** ("Mundo principal").
- **Globo aerostático** — `Workspace/balloon/.../FloatingEffect.server.luau`: flota decorativo.

### RemoteEvents

| RemoteEvent | Dispara | Atiende | Uso |
|---|---|---|---|
| `CollectFruit` | `CoinScript` | `FruitServerHandler` | +1 a `Fruits` |
| `CollectBadItem` | `CoinScript` | `FruitServerHandler` | −1 a `Fruits` |
| `LeaderboardRemote` | `PlayerPositionDisplay` | *(nadie — código muerto)* | Tablero individual roto |

> Código muerto/roto de este mapa (MetaScript, DataStore, Leaderboard,
> PlayerPositionDisplay) documentado en [`codigo-muerto.md`](codigo-muerto.md).

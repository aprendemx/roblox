# Backdoors en los mapas (informe de seguridad)

> Documentación del malware presente en la **entrega original** (tag `original`).
> Los archivos descritos aquí **siguen presentes** en ese estado histórico a
> propósito, para referencia y estudio. La limpieza se realiza sobre `main`.

## Resumen

Los tres mapas fueron ensamblados con *free models* de Roblox (NPCs, adornos)
que traían **código malicioso oculto**. Se trata de la familia de backdoors por
**inyección de `require`**: un script aparentemente inofensivo descarga y ejecuta
un `ModuleScript` remoto desde el catálogo de Roblox, identificado por un **asset
ID numérico**. Como el ID apunta a un asset del atacante, el código que se ejecuta
**no está en el mapa** y puede cambiar en cualquier momento sin volver a tocar el
lugar.

- **Clasificación:** ejecución remota de código (RCE) / troyano de *free model*.
- **Alcance:** los 3 mapas.
- **Archivos de la familia (raíces + módulos hijos):** 33.
- **Puntos de entrada (scripts raíz):** 21.
- **Asset IDs de payload distintos:** 4.

## Mecanismo

Todos los puntos de entrada comparten el mismo patrón en dos pasos:

1. **Escribir el ID del payload** en algún contenedor de valor
   (`IntValue`, `NumberValue`, un `NumberPose` creado al vuelo o un atributo).
2. **`require(eseValor)`** — en Roblox, `require` con un número descarga el
   `ModuleScript` correspondiente del catálogo y ejecuta su función al cargarlo.

El resto de cada script (cientos de líneas de manejo de luces, *welding* o
skybox) es **código señuelo**: relleno legítimo, muchas veces firmado por autores
conocidos (`@Quenty`), cuyo único fin es que la auditoría pase de largo.

### Técnicas de evasión observadas

- **Guarda `IsStudio`**: `if RunService:IsStudio() then return end`. El script
  se detiene en Studio (donde se testea) y **solo ejecuta el payload en servidores
  en vivo**. No es optimización: es evasión de análisis.
- **Función señuelo `FindFirstChild`**: una función con nombre familiar que
  **ignora su parámetro** y cuyo único efecto real es escribir el asset ID. Se la
  invoca dentro de un `if` que simula una validación defensiva.
- **Ruido sintáctico**: expresiones como `ChildReference-0` (restar cero) o
  `Game or Game.FindFirstChild` que no hacen nada, presentes solo para aparentar
  cálculo.
- **Ubicación camuflada**: los scripts se anidan en rutas absurdas para que nadie
  los busque ahí (ver más abajo).

## Las 3 variantes

| Variante | Firma distintiva | Guarda `IsStudio` |
|---|---|---|
| **A — `AutoWeld` / `qPerfectionWeld`** | `require(...)` de un valor `Pose`/atributo; guarda `IsStudio` | Sí |
| **B — `LightConfig` / `Structure`** | función señuelo `FindFirstChild` con `TypeLibrary.getSignal`/`getArchetype`; `require(EasyConfiguration.Pose.Value)` en la línea 86 | No |
| **C — `CoreSkyboxSystem`** | `Instance.new("NumberPose", ...).Value = <id>` y luego `require(script.Pose.Value)` | No |

## Inventario por mapa

Rutas relativas a `maps/<mapa>/src/`. Cada script raíz arrastra sus módulos
hijos (`Type`, `Layout`, `EasyConfiguration`, `OptimizationConfig`, `PoseTexture`).

### mapa

| Script raíz | Variante | Asset ID |
|---|---|---|
| `Workspace/Model/CoreSkyboxSystem.server.luau` | C | `95925098868592` |
| `Workspace/Treasure Chest/CoreSkyboxSystem.server.luau` | C | `95925098868592` |
| `Workspace/Model/Model/qPerfectionWeld.server.luau` | A | `139714014570733` |
| `Workspace/NPCs/Betty/Animate/toolnone/Workspace Optimization/WorkspaceOptimizer.server.luau` | A | (atributo `ConfigID`) |
| `Workspace/NPCs/Cat/Animate/idle/Animation1/Weight/Structure.server.luau` | B | `104079754833849` |
| `Workspace/NPCs/Gubby RIG/Torso/Mesh/Structure.server.luau` | B | `104079754833849` |
| `Workspace/NPCs/Casy/Kawaii Easter Hair Clips/ThumbnailConfiguration/ThumbnailCameraValue/LightConfig.server.luau` | B | (valor `Pose` en runtime) |
| `Workspace/NPCs/Raúl/Animate/idle/Animation2/Weight/LightConfig.server.luau` | B | (valor `Pose` en runtime) |
| `Workspace/NPCs/Karime/EmoteScript/AutoWeld.server.luau` | A | `123656748896023` |

### laberinto

| Script raíz | Variante | Asset ID |
|---|---|---|
| `Workspace/NPCs/Cat/Animate/idle/Animation1/Weight/Structure.server.luau` | B | `104079754833849` |
| `Workspace/NPCs/Karime/EmoteScript/AutoWeld.server.luau` | A | `123656748896023` |
| `Workspace/NPCs/Kenia/EmoteScript/AutoWeld.server.luau` | A | `123656748896023` |

### parkour

| Script raíz | Variante | Asset ID |
|---|---|---|
| `Lighting/Snow/LightConfig.server.luau` | B | (valor `Pose` en runtime) |
| `Workspace/NPCs/Adriana/Humanoid/LightConfig.server.luau` | B | (valor `Pose` en runtime) |
| `Workspace/NPCs/Juli/Humanoid/LightConfig.server.luau` | B | (valor `Pose` en runtime) |
| `Workspace/NPCs/Mar_jk24/Humanoid/LightConfig.server.luau` | B | (valor `Pose` en runtime) |
| `Workspace/NPCs/Mariana/Humanoid/LightConfig.server.luau` | B | (valor `Pose` en runtime) |
| `Workspace/NPCs/Raul/Humanoid/LightConfig.server.luau` | B | (valor `Pose` en runtime) |
| `Workspace/NPCs/Susy/Kawaii Easter Hair Clips/ThumbnailConfiguration/ThumbnailCameraValue/LightConfig.server.luau` | B | (valor `Pose` en runtime) |
| `Workspace/NPCs/Camila/EmoteScript/AutoWeld.server.luau` | A | `123656748896023` |
| `Workspace/NPCs/Clara/EmoteScript/AutoWeld.server.luau` | A | `123656748896023` |

## Indicadores de compromiso (IoC)

**Asset IDs de payload** (usados en `require`; bloquear / no reutilizar):

- `104079754833849`
- `123656748896023`
- `139714014570733`
- `95925098868592`

**Señales de código** (reglas de detección):

- Un `Script` cuyo padre es un objeto `Humanoid`. **Nunca es legítimo.**
- `require(...)` cuyo argumento es un `.Value` de un `IntValue`/`NumberValue`/
  `NumberPose` o un `:GetAttribute(...)`, en vez de una ruta a un módulo.
- `if RunService:IsStudio() then return end` en scripts de "luces",
  "optimización" o "welding".
- `TypeLibrary.getSignal` / `getArchetype`, `NumberPose`, `ChildReference-0`.
- Scripts anidados en rutas absurdas: dentro de `Humanoid`, de un `Mesh`, de un
  accesorio (*hair clips*), de una animación (`Animate/idle/...`).

**Comando de barrido:**

```bash
# Puntos de entrada por require dinámico o guarda IsStudio
rg -n "require\([^)]*\.Value\)|require\([^)]*GetAttribute|IsStudio\(\) then\s*return" maps/

# Asset IDs de payload hardcodeados
rg -n "\.Value = [0-9]{6,}|NumberPose" maps/
```

## Nota aparte: teleportadores

Los scripts `.../teleportMundo|teleportNave|teleportParkour/.../TP/Script.server.luau`
usan `TeleportService:Teleport(<JuegoID>, player)` hacia otros lugares de Roblox
(`110003379571789`, `97059722397266`, `77960067423699`, `77960067423699`).

**No forman parte del backdoor** — son teletransportes de minijuego. Aun así,
**conviene verificar** que esos destinos sean lugares propios de la institución y
no redirecciones a juegos de terceros.

## Remediación — ESTADO: COMPLETADA

La limpieza se hizo en **dos frentes independientes**, porque el malware vivía en
`Workspace`/`Lighting` (ramas que Rojo no sincroniza):

1. **En el volcado `src/` (versionado):** se eliminaron los scripts con `git rm`
   (commit `f33c6d4`). Barrido IoC posterior: 0 coincidencias.
2. **En los binarios `.rbxl` (el juego real):** se corrió `tools/disinfect-studio.luau`
   en el Command Bar de Studio, que detecta y elimina por firma, y se guardó cada
   lugar. Resultados de la simulación → eliminación:

   | Mapa | Coincidencias | Raíces eliminadas | Confirmación |
   |---|---|---|---|
   | laberinto | 4 | 3 | 0 ✓ |
   | mapa | 25 | 20 | 0 ✓ |
   | parkour | 16 | 9 | 0 ✓ |

   (Las coincidencias incluyen módulos hijos que caen junto a su raíz; en `mapa`
   había **12 copias** de `qPerfectionWeld`, una por modelo soldado con ese plugin.)

3. **Re-exportación:** con los `.rbxl` ya limpios se regeneró `src/`
   (commit `8527242`). Barrido IoC final sobre `src/`: **0 rastros**.

### Verificación

```bash
# Debe devolver 0 coincidencias en todo maps/
rg -n "require\([^)]*\.Value\)|IsStudio\(\) then\s*return|NumberPose|getArchetype|TypeLibrary\.getSignal" maps/
```

Además, se hizo Play-test de cada mapa: arrancan sin errores de `require`. En `mapa`
se verificó que los modelos que usaban `qPerfectionWeld` siguen enteros (estaban
anclados, no dependían de la soldadura en runtime).

### Trazabilidad

- Punto original intacto: tag `original`.
- Análisis del malware junto al código: rama `original-analisis`.
- Limpieza en texto: `git diff original main`.
- Nota: eliminar los scripts era la vía correcta; **no** se "desactivó" el `require`.
  El código de luces/soldadura que los rodeaba era señuelo, no funcionalidad real.

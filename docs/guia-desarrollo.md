# Guía de desarrollo — cómo están hechos estos mapas

Documento para quien vaya a **continuar** estos proyectos. Explica el enfoque con el
que se construyeron los tres mapas, qué tienen en común, qué tipos de eventos usan,
qué se hizo bien y qué conviene mejorar. Es una guía de estilo y de arquitectura, no
un tutorial de Roblox.

> Contexto previo recomendado: [`gameplay.md`](gameplay.md) (qué hace cada mapa),
> [`../security/BACKDOOR.md`](../security/BACKDOOR.md) y
> [`../security/VULN-FRUTAS.md`](../security/VULN-FRUTAS.md) (seguridad),
> [`codigo-muerto.md`](codigo-muerto.md).

---

## 1. Visión general: tres mapas, un sistema

Los tres mapas no son proyectos sueltos: forman una **experiencia educativa conectada**
("aprende") sobre seguridad y convivencia en línea, con estructura de **hub y radios**.

| Mapa | Rol | Objetivo del jugador |
|---|---|---|
| `mapa` | **Hub / plaza central** | Explorar, socializar, y saltar a los minijuegos. Sin condición de victoria. |
| `laberinto` | Minijuego (radio) | Resolver un puzzle: juntar 8 herramientas y colocarlas. |
| `parkour` | Minijuego (radio) | Completar un circuito de obstáculos recolectando frutas. |

Todos tienen un teleporte de salida a **"Mundo principal"** (`JuegoID 110003379571789`),
y el hub tiene pads hacia cada minijuego. La intención pedagógica es explícita: carteles
de seguridad ("no compartas datos personales", "trata a los demás con respeto") y una
zona de créditos del equipo.

---

## 2. Elementos comunes a los tres mapas

Entender lo compartido es la mitad del trabajo de mantenerlos.

### 2.1 Ensamblado con *free models*
Los mapas se armaron con modelos gratuitos del catálogo (NPCs, adornos, cofres). Esto
trajo dos consecuencias que definen el proyecto:
- **Malware**: cada modelo podía traer backdoors ocultos (ver `security/`). Se
  eliminaron, pero el patrón de reuso es el que los introdujo.
- **Ruido de scripts stock**: cada NPC arrastra `Animate`, `Health`, `Sound` (rigs R6
  estándar). No son código del equipo; son relleno del modelo.

### 2.2 Sistemas cliente copiados entre mapas
Dos scripts aparecen **idénticos** en los tres mapas, copiados a mano:
- `DecorativeNPCClient.client.luau` — burbujas de diálogo de NPCs por proximidad.
- `FloatingEffect.server.luau` — flotación de objetos.

Son data-driven (leen el atributo `DialogText`), lo cual está bien, pero están
duplicados en vez de compartidos (ver §6).

### 2.3 NPCs decorativos
Todos los mapas pueblan `Workspace/NPCs/` con personajes que solo dan ambiente. La única
interacción es la burbuja de diálogo. Algunos tienen comportamiento extra (emotes,
copiar el avatar del jugador, ragdoll), pero ninguno es un objetivo de juego.

### 2.4 Teleportes
Dos clases, presentes en varios mapas:
- **Interno** (mismo lugar): mueve el `CFrame` del jugador a un `Goal`.
- **Externo** (`TeleportService:Teleport`): lleva a otra experiencia por `JuegoID`.

---

## 3. Patrones y técnicas usados (el "cómo")

Estas son las herramientas de Roblox que el equipo aplicó. Un desarrollador que continúe
debería reconocerlas y mantener el estilo (o mejorarlo donde se indica).

### 3.1 CollectionService + tags + atributos *(el patrón más maduro)*
En `parkour`, las mecánicas no se programan objeto por objeto: se **etiquetan**. Un
manager central recorre todos los objetos con un tag y les conecta el comportamiento.

```lua
-- Patrón: un manager por mecánica
for _, part in CollectionService:GetTagged("Checkpoint") do setup(part) end
CollectionService:GetInstanceAddedSignal("Checkpoint"):Connect(setup)  -- soporta objetos nuevos
```

Tags usados: `Checkpoint`, `Conveyor`, `TrapPart`, `BouncePad`. La configuración por
objeto va en **atributos** (`Speed`, `BounceImpulse`). Esto es escalable e idiomático:
agregar una trampa nueva es ponerle el tag, sin tocar código.

### 3.2 Atributos como configuración
Además de las mecánicas, los NPCs usan el atributo `DialogText`. Separar datos de código
permite editar contenido desde Studio sin programar. Buen patrón, poco explotado.

### 3.3 RemoteEvents para cliente↔servidor
El sistema de frutas y la BoomBox usan `RemoteEvent` (`FireServer` / `OnServerEvent`).
Es el mecanismo correcto de comunicación, aunque en frutas la **validación** falta (§6).

### 3.4 Disparadores de interacción
- `ProximityPrompt` — recoger herramientas (puzzle de laberinto). Es la forma moderna
  de "presioná E para interactuar".
- `Touched` — checkpoints, trampas, teleportes, aros, cajas del puzzle.
- `ClickDetector` — activar la cámara cinemática.

### 3.5 Persistencia con OrderedDataStore
Dos leaderboards persistentes: `TimePlayedLeaderboard` (tiempo jugado) y
`GlobalBoardHandler` (frutas). Usan `OrderedDataStore` con `GetSortedAsync` para rankings
y guardan solo si se supera el récord. Correcto en concepto (ver riesgo en §6).

### 3.6 Efectos visuales por frame
- `RunService.Heartbeat` — flotación (`FloatingEffect`).
- `RenderStepped` — cámara cinemática fija.
- Tweens — animación de las burbujas de diálogo.

---

## 4. Catálogo de eventos

Los mapas se pueden entender como una colección de estos seis tipos de evento:

| Tipo | Cómo se dispara | Ejemplos |
|---|---|---|
| **Por contacto** | `BasePart.Touched` | Checkpoints, trampas, teleportes, aros, cajas del puzzle, recoger frutas |
| **Por proximidad** | Distancia en loop / `ProximityPrompt` | Burbujas de NPC, recoger herramientas |
| **Programado / temporizado** | `os.time` + fecha, o `task.wait` largo | Gravedad cero (fecha real), pergaminos que suben (15 min) |
| **Por red** | `RemoteEvent` | Frutas (+1/−1), BoomBox |
| **Continuo / por frame** | `Heartbeat` / `RenderStepped` | Flotación, cámara, cintas |
| **Sondeo de datos** | loop con `task.wait` | Leaderboards (cada 60 s), contador de frutas |

---

## 5. Lo que se hizo bien

- **Arquitectura de `parkour` con CollectionService.** Es lo mejor del proyecto:
  mecánicas desacopladas, escalables, con configuración por atributos y soporte para
  objetos agregados en runtime. Es el estándar a seguir para el resto.
- **Estado por jugador en el puzzle.** En `laberinto`, cada jugador resuelve su propia
  copia (oculta las herramientas solo para sí mismo). Es la decisión correcta para un
  espacio compartido: no se pisan entre jugadores.
- **Configuración data-driven.** Usar el atributo `DialogText` en vez de hardcodear los
  diálogos permite editar contenido sin tocar código.
- **Un manager por responsabilidad.** En `parkour`, cada mecánica vive en su propio
  script (`CheckpointManager`, `TrapManager`, …). Buena separación de responsabilidades.
- **Detalles cuidados.** El cálculo del offset del checkpoint (`HipHeight` + tamaños)
  para dejar al jugador bien parado; la curva senoidal con potencia de `FloatingEffect`
  para una flotación con "peso". Son toques de alguien que pensó el detalle.
- **Intención pedagógica clara.** Los carteles de seguridad y los créditos muestran un
  proyecto con propósito, no solo un ensamblado técnico.

---

## 6. Lo que se puede mejorar

Ordenado por prioridad. Lo de seguridad es lo primero, siempre.

### 6.1 Seguridad (crítico)
- **Autoridad del servidor en las frutas.** Hoy el cliente decide y el servidor obedece
  → explotable. El servidor debe ser dueño del estado. Detalle en
  [`../security/VULN-FRUTAS.md`](../security/VULN-FRUTAS.md).
- **`BouncePadManager` es un `LocalScript`.** Las otras tres mecánicas son de servidor;
  esta corre en el cliente, dándole al jugador autoridad sobre la física del rebote.
  Inconsistente y manipulable. Debería ser server-side como las demás.
- **Vetar los *free models*.** Fueron la vía de entrada del malware. Antes de sumar un
  modelo nuevo, correr el barrido de `security/BACKDOOR.md`. Idealmente, reconstruir lo
  reutilizable en limpio.

### 6.2 Consistencia de patrones
- **Duplicar scripts en vez de etiquetar.** Contradicción central del proyecto: `parkour`
  usa CollectionService (bien), pero otras cosas se copian objeto por objeto —
  **~36 scripts idénticos** en las frutas, **13** en los aros, **12** copias de
  `qPerfectionWeld`. Todo eso debería ser **un** manager + un tag. Es el mismo salto de
  madurez que ya se dio en las mecánicas de parkour, sin aplicar al resto.
- **Módulos compartidos.** `DecorativeNPCClient` y `FloatingEffect` están copiados en los
  tres mapas. Deberían ser un `ModuleScript` compartido (o un paquete de Rojo) para
  arreglar un bug una sola vez, no tres.

### 6.3 Código muerto y duplicado
- **Implementaciones duplicadas.** En `laberinto`, `PuzzleManagerV4` (cliente, real)
  convive con `PuzzleDetector` (servidor, incompleto). Dos scripts de gravedad cero
  (`PortilloScript` y el LocalScript de la tumba). Elegir uno y borrar el otro.
- **Scripts muertos.** `MetaScript`, `DataStore`, `Leaderboard`, `PlayerPositionDisplay`
  (ver [`codigo-muerto.md`](codigo-muerto.md)). Ensucian y esconden intenciones rotas.
- **`print` de debug en producción.** `PortilloScript` imprime el dado cada 2 min;
  las frutas imprimen cada recolección. Quitar o poner tras un flag de debug.

### 6.4 Eficiencia
- **Sondeo con `while true wait(0.01)`.** El contador de frutas reescribe el label 100
  veces por segundo. Debería reaccionar a `Fruits.Changed`.
- **`FloatingEffect` en el servidor por objeto.** Cada objeto flotante corre un
  `Heartbeat` en el servidor. Con pocos objetos zafa; el efecto es visual y debería ir
  en el cliente.
- **Riesgo de *throttling* de DataStore.** `GlobalBoardHandler` hace `GetAsync` +
  `SetAsync` por jugador por leaderboard cada 60 s. Con varios jugadores puede pasar los
  límites de Roblox. Conviene cachear y espaciar.

### 6.5 Robustez y estilo
- **Eventos atados a fechas reales (`os.time`).** Frágiles (zona horaria UTC),
  imposibles de probar sin manipular el reloj, y de un solo disparo. Para eventos
  recurrentes conviene un temporizador relativo o config editable.
- **`LocalScript` en el Workspace.** El de la tumba nunca se ejecuta (los LocalScripts no
  corren ahí). Si se quiere ese efecto, va en un contenedor de cliente.
- **Puntaje sin límites.** Las frutas pueden quedar negativas sin piso.
- **Nomenclatura.** Mezcla español/inglés, nombres genéricos (`Model`, `Part`, `Script`
  repetidos), typos ("Telenstraporte"). Dificulta leer el árbol. Convención sugerida en §7.

---

## 7. Recomendaciones para continuar

Si vas a extender estos mapas, adoptá estas convenciones:

1. **El servidor manda.** Todo estado que importe (puntaje, progreso, ítems) se valida y
   se guarda en el servidor. El cliente pide; el servidor decide.
2. **Etiquetá, no dupliques.** Objeto repetido con comportamiento → un tag de
   CollectionService + un manager. Cero copy-paste de scripts.
3. **Compartí código.** Lo común entre mapas (NPCs, efectos) va en un `ModuleScript`
   compartido, no copiado.
4. **Config en atributos.** Números y textos ajustables como atributos, no hardcodeados.
5. **Vetá lo que importás.** Correr el barrido de seguridad antes de sumar cualquier
   *free model*.
6. **Limpiá al entrar.** Borrá el código muerto y los `print` de debug de lo que toques.
7. **Nombres claros.** Un esquema consistente (p. ej. `PascalCase`, en un idioma, con
   sufijos por tipo) para que el árbol se lea solo.
8. **Usá el versionado.** Cada cambio, un commit que explique el porqué. El flujo de Rojo
   está en el [README](../README.md).

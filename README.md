# roblox-aprende

Versionado y saneamiento de tres mapas de Roblox entregados por la institución:
**mapa**, **laberinto** y **parkour**. El proyecto los pone bajo control de versiones
(Git), documenta y elimina el malware que traían, y deja un flujo para editarlos con
Rojo sincronizando contra Roblox Studio.

## Estructura

```
places/              Los .rbxl — archivos de lugar de Roblox
maps/
  <mapa>/
    default.project.json   Config de Rojo (qué se sincroniza)
    src/                   Scripts exportados (convención Rojo)
security/            Documentación del malware y su limpieza
tools/
  export.luau        Vuelca los scripts de un .rbxl a src/
  disinfect-studio.luau  Desinfectante para el Command Bar de Studio
rokit.toml           Toolchain (rojo, lune) fijada por versión
```

## Ramas y tag

| Ref | Qué es |
|---|---|
| tag `original` | La entrega intacta, sin modificar (incluye el malware). Punto congelado. |
| rama `original-analisis` | El código original + el análisis técnico del malware, para estudio. |
| rama `main` | Versión saneada: malware eliminado, herramientas y documentación. |

`git diff original main` muestra la limpieza completa en texto.

## Requisitos

- [Rokit](https://github.com/rojo-rbx/rokit) — gestor de toolchain.
- Roblox Studio.

Las versiones de `rojo` y `lune` están fijadas en `rokit.toml`. Instalá el toolchain
una sola vez:

```bash
rokit install
```

## Levantar el entorno de desarrollo con Rojo

Rojo sincroniza los scripts del filesystem hacia Studio en vivo. **Solo sincroniza
`ServerScriptService` y `StarterPlayer`** (ver [nota importante](#qué-sincroniza-rojo-y-qué-no)).

1. **Iniciá el servidor de Rojo** para el mapa que quieras editar:

   ```bash
   rojo serve maps/parkour/default.project.json
   # o: maps/mapa/... , maps/laberinto/...
   ```

2. **Conectá desde Studio:**
   - Abrí el `.rbxl` correspondiente (`places/parkourAprende.rbxl`).
   - En la barra de plugins, abrí **Rojo** → **Connect**.
   - A partir de ahí, editar un archivo en `maps/<mapa>/src/...` se refleja en Studio
     al instante.

3. Cuando termines, cerrá la conexión en Studio y detené el servidor (`Ctrl+C`).

### Qué sincroniza Rojo y qué NO

Los `default.project.json` mapean **solo** contenedores que son puramente scripts:

- ✅ `ServerScriptService`
- ✅ `StarterPlayer/StarterPlayerScripts` (y `StarterCharacterScripts` en parkour)
- ❌ `Workspace`, `StarterGui`, `Lighting` → **excluidos a propósito**

**Por qué:** el `src/` es un volcado de la jerarquía del `.rbxl`, donde cada carpeta
representa un `Model`, `Part` o `GUI` real. Rojo convierte toda carpeta sin
`init.meta.json` en un `Folder`. Sincronizar `Workspace` haría que Rojo reemplace tus
`Model`/`Part` por `Folder`, destruyendo geometría, meshes y accesorios. Por eso el
Workspace se edita **en Studio**, no vía Rojo.

## Exportar scripts desde un `.rbxl`

Cuando editás en Studio (Workspace incluido) y querés traer los scripts al repo:

```bash
lune run tools/export            # los 3 mapas
lune run tools/export parkour    # uno solo
```

El exportador recrea `maps/<mapa>/src/` desde cero (refleja borrados) y desambigua
scripts hermanos con el mismo nombre (sufijo `_N`).

> **Dirección de la verdad:** hoy el `.rbxl` es la fuente autoritativa y `export`
> **sobrescribe** `src/`. Si editás en `src/` vía Rojo pero no guardás el `.rbxl`,
> el próximo `export` pisa esos cambios. Definir la dirección de sincronización
> (Studio→src o src→Studio) es una decisión pendiente del proyecto.

## Gameplay

El objetivo, las mecánicas, los teleportes y los eventos de cada mapa están en
[`docs/gameplay.md`](docs/gameplay.md): `mapa` (hub social), `laberinto` (puzzle de
recolección) y `parkour` (parkour de recolección con leaderboard global).

## Seguridad

Los tres mapas venían con backdoors de *free models* (inyección de `require`). Ver:

- [`security/BACKDOOR.md`](security/BACKDOOR.md) — inventario, indicadores de
  compromiso y estado de la limpieza.
- [`security/ANALISIS-MALWARE.md`](security/ANALISIS-MALWARE.md) *(rama
  `original-analisis`)* — cómo funcionaba, técnico y no técnico, y su línea de tiempo.

Antes de publicar cualquier mapa, corré el barrido de verificación:

```bash
rg -n "require\([^)]*\.Value\)|IsStudio\(\) then\s*return|NumberPose|getArchetype" maps/
```

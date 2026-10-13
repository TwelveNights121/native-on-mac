# Plan del proyecto

## Qué es (y qué no es)

**Es** un organizador: toma un juego que ya tienes y elige la mejor forma de correrlo en un Mac con Apple Silicon, usando herramientas que ya existen.

**No es** un emulador, ni un Wine nuevo, ni un recompilador universal. La recompilación estática de cada juego (por ejemplo, el `game.toml` de nfs-most-wanted-mac) es trabajo de meses que hacen sus autores; aquí solo la aprovechamos y les damos crédito.

## Cómo se vería

```
$ native-on-mac ~/Juegos/"Need for Speed Most Wanted"

Juego detectado: NFS Most Wanted (2005), Black Edition 1.3 (huella 80774c2e…)
Mejor opción: versión nativa recompilada (nfs-most-wanted-mac)
  · Rendimiento esperado: nativo
  · Requisitos: Apple Silicon, ~15 GB, Command Line Tools 27
¿Continuar? [S/n]
```

## Las piezas

### 1. Recetas (`recipes/`)
Un archivo YAML por juego: cómo detectarlo, qué caminos existen, qué motor usar para su instalador, problemas conocidos con su arreglo y notas de rendimiento por Mac. Ejemplo real: [`nfs-most-wanted-2005.yaml`](../recipes/nfs-most-wanted-2005.yaml).

### 2. Detector
Recibe una carpeta, un instalador o una imagen de disco; calcula la huella (SHA-256) de los ejecutables y la compara con las recetas.

### 3. Motores
Formas intercambiables de correr un juego:

| Motor | Qué hace | Rendimiento |
|---|---|---|
| **Nativo** | El juego ya tiene versión de Mac: solo lo indica | Nativo |
| **Recompilado** | Descarga el proyecto de recompilación y lo compila con tu copia | Nativo |
| **Traducción** | Wine o Game Porting Toolkit con la configuración de la receta | Menor |

Agregar un juego nuevo = escribir su receta, no otro script.

### 4. Diagnóstico
Lee los registros cuando algo falla y los compara con los `problemas_conocidos` de las recetas para sugerir (o aplicar) el arreglo.

### 5. Comunidad
- Peticiones de juegos con plantilla en Issues; los votos (👍) deciden prioridades.
- Etiquetas: `pedido`, `investigando`, `nativo`, `recompilado`, `traducción`, `no funciona`.
- Recetas nuevas aportadas por pull request.

### 6. Skill para asistentes de IA
Una skill que enseña a un asistente (como Claude) a usar el proyecto: correr la herramienta, interpretar fallos y, si un juego no tiene receta, investigarlo junto al usuario y escribirla.

## Etapas

- [x] **0.0** — Primer caso real resuelto: NFS Most Wanted nativo en un M1 desde una imagen de disco.
- [ ] **0.1** — Repo público con la receta de NFS MW, scripts y plantilla de peticiones.
- [ ] **0.2** — Segunda receta (Sonic Unleashed) y formato de receta estable.
- [ ] **0.3** — Detector por huellas + diagnóstico automático de errores conocidos.
- [ ] **0.4** — Comando único `native-on-mac` que lee las recetas y elige el motor.
- [ ] **0.5** — Skill para asistentes de IA.
- [ ] **Más adelante** — App con interfaz gráfica.

## Ideas a futuro
- **Audio espacial:** pasar el 5.1 de los juegos recompilados al motor de audio espacial de macOS (HRTF + seguimiento de cabeza con AirPods), en vez de mezclarlo a estéreo. Primer candidato: un sink nuevo en el audio de recomp-kit (`kit/host/audio/`).
- **Detector de versiones nativas** antes de instalar nada.

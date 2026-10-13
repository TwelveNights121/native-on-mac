# native-on-mac

**Recetas para correr en Mac, lo más nativo posible, los juegos de PC que ya tienes.**

*English summary: a community catalog of per-game "recipes" that pick the best way to run a Windows game you own on an Apple Silicon Mac — a native port or static recompilation when one exists, otherwise a tuned Wine / Game Porting Toolkit setup. No game files are distributed.*

---

## La idea

Correr juegos de Windows en Mac suele ser prueba y error: Wine, Whisky, CrossOver, el Game Porting Toolkit de Apple… y cada juego falla de una forma distinta. Mientras tanto, la comunidad está creando **versiones nativas** de juegos clásicos mediante **recompilación estática** (como *Unleashed Recompiled* o la versión nativa de *Need for Speed: Most Wanted*), que corren sin ninguna capa de traducción.

**native-on-mac** junta todo ese conocimiento en un solo lugar:

1. **Detecta** qué juego y qué versión tienes (por la huella del ejecutable).
2. **Elige el mejor camino**, en este orden:
   - **Nativo:** el juego ya tiene versión oficial para Mac.
   - **Recompilado:** existe un proyecto de recompilación estática → se descarga y se compila en tu Mac con tu copia del juego.
   - **Traducción:** Wine o el Game Porting Toolkit, con la configuración que se sabe que funciona para ese juego.
3. **Diagnostica** los errores conocidos y aplica el arreglo.

Todo lo que se aprende de cada juego queda escrito en una **receta**, para que nadie tenga que volver a pelear con lo mismo.

> Estado: **versión 0.1 (en construcción)**. Hoy el repo contiene la primera receta completa y probada: *Need for Speed: Most Wanted (2005)*. Ver el [plan](docs/PLAN.md).

## Juegos

| Juego | Camino | Estado |
|---|---|---|
| Need for Speed: Most Wanted (2005) — Black Edition 1.3 | Recompilado ([nfs-most-wanted-mac](https://github.com/elforeign/nfs-most-wanted-mac)) | ✅ Probado en MacBook Air M1, macOS 27.2 |
| Sonic Unleashed (Xbox 360) | Recompilado ([UnleashedRecomp](https://github.com/hedge-dev/UnleashedRecomp)) | 📝 Receta pendiente |

¿Quieres que agreguemos un juego? **[Pídelo aquí](../../issues/new/choose)** y vota con 👍 los que ya están pedidos.

## Probar la receta de NFS Most Wanted

Requisitos: Mac con Apple Silicon, macOS 27, ~15 GB libres, y **tu propia copia** del juego (Black Edition, versión 1.3 en inglés) como imagen de disco.

```bash
git clone https://github.com/TwelveNights121/native-on-mac.git
cd native-on-mac
bash scripts/nfs-most-wanted/instalar.sh "/ruta/a/tu/juego.iso"
```

El script: instala Rosetta y las herramientas de Apple si faltan → usa Wine / Game Porting Toolkit **solo para correr el instalador** → verifica que tu `speed.exe` sea el compatible → compila la versión nativa → la deja en Aplicaciones.

Extras opcionales (con el juego cerrado):

```bash
bash scripts/nfs-most-wanted/look-xbox360.sh        # look fiel al Xbox 360 y más liviano
bash scripts/nfs-most-wanted/icono-y-modo-juego.sh  # ícono original + Modo Juego de macOS
```

Detalles, problemas conocidos y por qué funciona: [recipes/nfs-most-wanted-2005.yaml](recipes/nfs-most-wanted-2005.yaml).

## Reglas

- **Solo juegos que tienes legalmente.** Este repo no contiene, enlaza ni explica cómo conseguir archivos de juegos. Peticiones o mensajes con enlaces de descarga se cierran.
- **No redistribuimos software de otros.** Las recompilaciones, Wine y el Game Porting Toolkit se descargan de sus fuentes oficiales; aquí solo hay scripts y recetas.
- **El mérito es de sus autores.** Ver [Créditos](#créditos).

Cómo aportar: [CONTRIBUTING.md](CONTRIBUTING.md).

## Créditos

- [nfs-most-wanted-mac](https://github.com/elforeign/nfs-most-wanted-mac) — elforeign
- [recomp-kit](https://github.com/veritr1x/recomp-kit) y [nfsmw-recomp](https://github.com/veritr1x/nfsmw-recomp) — veritr1x
- [macOS Wine builds](https://github.com/Gcenx/macOS_Wine_builds) y [Game Porting Toolkit builds](https://github.com/Gcenx/game-porting-toolkit) — Gcenx
- Game Porting Toolkit — Apple · [Wine](https://www.winehq.org) — el proyecto Wine
- [Unleashed Recompiled](https://github.com/hedge-dev/UnleashedRecomp) — hedge-dev

Este proyecto no está afiliado a Electronic Arts, SEGA, Apple ni a ninguno de los proyectos citados.

## Licencia

[MIT](LICENSE)

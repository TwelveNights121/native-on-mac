#!/bin/bash
# instalar.sh — NFS Most Wanted (2005) nativo en Mac (Apple Silicon), a partir de TU copia en imagen de disco (.iso).
# Uso:  bash instalar.sh "/ruta/a/tu/juego.iso"
# Pasos: Rosetta -> Wine/Game Porting Toolkit (solo para el instalador) -> instalar -> verificar speed.exe
#        -> compilar la versión nativa con github.com/elforeign/nfs-most-wanted-mac
# Registro: ~/Downloads/native-on-mac-registro/log.txt

set -u
WORK="$HOME/Downloads/native-on-mac-registro"
ISO="${1:-}"
BASE="$HOME/Library/NFSMW-Wine"            # Wine y su "disco C:" temporal (se borra al final)
export WINEPREFIX="$BASE/prefix"
export WINEDEBUG=-all
export WINEDLLOVERRIDES="mscoree,mshtml="
WINE_URL="https://github.com/Gcenx/macOS_Wine_builds/releases/download/11.16/wine-devel-11.16-osx64.tar.xz"
REPO="$HOME/nfs-most-wanted-mac"
MNT="$BASE/iso"
LOG="$WORK/log.txt"

mkdir -p "$WORK" "$BASE"
exec > >(tee -a "$LOG") 2>&1
paso() { printf '\n\033[1;36m==> %s\033[0m\n' "$1"; }
falla() { printf '\n\033[1;31mERROR: %s\033[0m\n' "$1"; echo "Detalle en $LOG (puedes adjuntarlo en un Issue del repo)"; exit 1; }
date

[ "$(uname -m)" = "arm64" ] || falla "Esta Mac no es Apple Silicon."
[ -n "$ISO" ] && [ -f "$ISO" ] || falla "Uso: bash instalar.sh \"/ruta/a/tu/juego.iso\""

# 1. Rosetta (Wine para Mac es de Intel y la necesita)
paso "1/6 Rosetta"
if arch -x86_64 /usr/bin/true 2>/dev/null; then echo "Ya está instalada."
else
  echo "Instalando Rosetta (te pide tu contraseña de la Mac)..."
  sudo softwareupdate --install-rosetta --agree-to-license || falla "No se pudo instalar Rosetta."
fi

# 2. Herramientas de Apple (git y compilador, para el paso 6)
paso "2/6 Command Line Tools de Apple"
if xcode-select -p >/dev/null 2>&1; then echo "Ya están instaladas."
else
  xcode-select --install 2>/dev/null
  echo "Se abrió una ventana: haz clic en 'Instalar' y acepta. Espero a que termine..."
  until xcode-select -p >/dev/null 2>&1; do sleep 15; done
  echo "Listas."
fi

# 3. Wine (solo para correr el instalador del repack)
paso "3/6 Wine 11.16 (solo para el instalador)"
WAPP="$(ls -d "$BASE"/Wine*.app 2>/dev/null | head -1)"
if [ -z "$WAPP" ]; then
  curl -fL --progress-bar -o "$BASE/wine.tar.xz" "$WINE_URL" || falla "No se pudo descargar Wine."
  tar -xJf "$BASE/wine.tar.xz" -C "$BASE" || falla "No se pudo descomprimir Wine."
  rm -f "$BASE/wine.tar.xz"
  WAPP="$(ls -d "$BASE"/Wine*.app | head -1)"
fi
WINE="$WAPP/Contents/Resources/wine/bin/wine"
WSRV="$WAPP/Contents/Resources/wine/bin/wineserver"
[ -x "$WINE" ] || falla "No encuentro el ejecutable de Wine dentro de $WAPP"
"$WINE" --version

# 4. Instalar el juego desde el ISO
paso "4/6 Instalar el juego (aquí participas tú)"
GAME="$(find "$BASE" -path "*drive_c*" -iname speed.exe -size +5000k 2>/dev/null | head -1)"
if [ -n "$GAME" ]; then echo "El juego ya estaba instalado: $GAME"
else
  mkdir -p "$MNT"
  hdiutil attach -readonly -nobrowse -mountpoint "$MNT" "$ISO" >/dev/null || falla "No se pudo montar el ISO."
  SETUP="$(find "$MNT" -maxdepth 3 -iname setup.exe | head -1)"
  echo "Se va a abrir el instalador del repack. Elige:"
  echo "   - Versión: 1.3 Black Edition (inglés si te da a escoger)"
  echo "   - Deja la carpeta de instalación que propone"
  echo "   - Si ofrece DirectX u otros extras, puedes saltarlos"
  echo "Cuando termine y lo cierres, el script sigue solo."
  WLOG="$WORK/wine-instalador.log"
  echo "Instalador: $SETUP" > "$WLOG"
  # Intentos: primero el Game Porting Toolkit de Apple (Wine de CrossOver, 32 bits "32on64"),
  # luego Wine staging y devel, como Windows XP y Windows 7.
  GPTK_URL="https://github.com/Gcenx/game-porting-toolkit/releases/download/Game-Porting-Toolkit-3.0-3/game-porting-toolkit-3.0-3.tar.xz"
  for FLAVOR in gptk staging devel; do
    case $FLAVOR in
      gptk)    NAME="Game Porting Toolkit"; URL="$GPTK_URL"; BIN=wine64; PFX="$BASE/prefix-gptk";;
      staging) NAME="Wine Staging"; URL="${WINE_URL/wine-devel/wine-staging}"; BIN=wine; PFX="$BASE/prefix";;
      devel)   NAME="Wine Devel";   URL="$WINE_URL"; BIN=wine; PFX="$BASE/prefix";;
    esac
    FAPP="$BASE/$NAME.app"
    if [ ! -d "$FAPP" ]; then
      echo "Descargando $NAME..."
      curl -fL --progress-bar -o "$BASE/w.tar.xz" "$URL" || continue
      tar -xJf "$BASE/w.tar.xz" -C "$BASE" && rm -f "$BASE/w.tar.xz"
      [ "$FLAVOR" = gptk ] && codesign --force --deep -s - "$FAPP" >/dev/null 2>&1
    fi
    [ -d "$FAPP" ] || continue
    export WINEPREFIX="$PFX"
    WINE="$FAPP/Contents/Resources/wine/bin/$BIN"; WSRV="$FAPP/Contents/Resources/wine/bin/wineserver"
    [ -x "$WINE" ] || { echo "No encuentro $WINE" | tee -a "$WLOG"; continue; }
    "$WINE" wineboot -u >/dev/null 2>&1; "$WSRV" -w
    for WV in winxp win7; do
      echo "Intento: $NAME como $WV" | tee -a "$WLOG"
      "$WINE" winecfg -v "$WV" >/dev/null 2>&1; "$WSRV" -w
      ( cd "$(dirname "$SETUP")" && WINEDEBUG=err+all,fixme-all "$WINE" "$SETUP" ) >>"$WLOG" 2>&1
      echo "wine terminó con código $?" | tee -a "$WLOG"
      "$WSRV" -w
      find "$WINEPREFIX/drive_c" -iname speed.exe -size +5000k 2>/dev/null | grep -q . && break 2
    done
  done
  hdiutil detach "$MNT" >/dev/null 2>&1
  { echo "--- drive_c ---"; find "$WINEPREFIX/drive_c" -maxdepth 4 -type d 2>/dev/null | grep -v -i -E 'windows|ProgramData|users/Public'; } >> "$WLOG"
  GAME="$(find "$BASE" -path "*drive_c*" -iname speed.exe -size +5000k 2>/dev/null | head -1)"
  [ -n "$GAME" ] || falla "El instalador terminó pero no encuentro speed.exe (detalle en $WLOG)."
fi
GAMEDIR="$(dirname "$GAME")"
echo "Juego instalado en: $GAMEDIR"
ls "$GAMEDIR"

# 5. Revisar speed.exe (la prueba de fuego)
paso "5/6 Revisando speed.exe"
find "$BASE" -path "*drive_c*" -iname 'speed*.exe' -exec sh -c 'printf "%10s  %s  %s\n" "$(stat -f%z "$1")" "$(shasum -a 256 "$1" | cut -c1-16)" "$1"' _ {} \; 2>/dev/null
echo "(La versión nativa busca: 6029312 bytes, huella 80774c2e5d619b4f...)"
[ -d "$REPO" ] || git clone https://github.com/elforeign/nfs-most-wanted-mac.git "$REPO" || falla "No se pudo descargar el proyecto."
cd "$REPO" && git pull -q
./setup.sh --check-only "$GAMEDIR" || falla "Este speed.exe no es el que acepta la versión nativa (ver arriba)."

# 6. Compilar la versión nativa (10–25 min). caffeinate evita que la Mac se duerma.
paso "6/6 Compilando la versión nativa (tarda; puedes dejar la Mac sola, abierta y con cargador)"
caffeinate -dims ./setup.sh "$GAMEDIR" || falla "La compilación falló."
APP="$(ls -d "$REPO"/dist/*.app 2>/dev/null | head -1)"
[ -n "$APP" ] || falla "No encuentro la app compilada en dist/."
ditto "$APP" "/Applications/$(basename "$APP")" && echo "Copiada a Aplicaciones."

paso "¡Listo! Abre 'NFS Most Wanted Native' desde Aplicaciones o Launchpad."
echo "Wine y el juego de Windows siguen en $BASE por si algo falla."
echo "Cuando confirmes que el juego funciona, puedes borrar esa carpeta y ~/Library/NFSMW-Native-Setup."
date

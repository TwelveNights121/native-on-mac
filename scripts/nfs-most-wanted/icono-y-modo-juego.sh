#!/bin/bash
# nfs-icono.sh — pone el ícono original del juego (de tu speed.exe) y habilita el Modo Juego de macOS.
# Uso: bash scripts/nfs-most-wanted/icono-y-modo-juego.sh      (cierra el juego antes)
set -e
APP="/Applications/NFS Most Wanted Native.app"
REPO="$HOME/nfs-most-wanted-mac"
PY="$REPO/.venv/bin/python"
EXE="$REPO/original/retail/speed.exe"
T="$(mktemp -d)"

[ -d "$APP" ] || { echo "No encuentro la app en Aplicaciones."; exit 1; }
[ -x "$PY" ] && [ -f "$EXE" ] || { echo "No encuentro el proyecto en $REPO."; exit 1; }
pgrep -f "NFS Most Wanted Native.app" >/dev/null && { echo "Cierra el juego primero."; exit 1; }

# 1. Sacar el ícono más grande del speed.exe y llevarlo a 1024x1024
"$PY" - "$REPO/kit/tools" "$EXE" "$T/icon_1024.png" <<'EOF'
import sys; sys.path.insert(0, sys.argv[1])
from extract_icon import ico_bytes, largest_frame
from PIL import Image
img = largest_frame(ico_bytes(sys.argv[2]))
print("Ícono original encontrado: %dx%d" % img.size)
img.resize((1024, 1024), Image.LANCZOS).save(sys.argv[3])
EOF

# 2. Armar el .icns de macOS
mkdir "$T/AppIcon.iconset"
for s in 16 32 128 256 512; do
  sips -z $s $s "$T/icon_1024.png" --out "$T/AppIcon.iconset/icon_${s}x${s}.png" >/dev/null
  d=$((s*2)); sips -z $d $d "$T/icon_1024.png" --out "$T/AppIcon.iconset/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$T/AppIcon.iconset" -o "$APP/Contents/Resources/AppIcon.icns"

# 3. Decirle a la app que use ese ícono y volver a firmarla (firma local, como la hizo el proyecto)
/usr/libexec/PlistBuddy -c "Delete :CFBundleIconFile" "$APP/Contents/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string AppIcon" "$APP/Contents/Info.plist"
# Modo Juego: macOS lo activa al poner el juego en pantalla completa
/usr/libexec/PlistBuddy -c "Delete :LSSupportsGameMode" "$APP/Contents/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :LSSupportsGameMode bool true" "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :LSApplicationCategoryType public.app-category.racing-games" "$APP/Contents/Info.plist" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Add :LSApplicationCategoryType string public.app-category.racing-games" "$APP/Contents/Info.plist"
codesign --force --sign - --timestamp=none "$APP"
codesign --verify --deep --strict "$APP"

# 4. Refrescar el Dock y Finder
touch "$APP"; killall Dock 2>/dev/null || true
rm -rf "$T"
echo "Listo: ícono puesto y Modo Juego habilitado (se activa en pantalla completa)."
echo "(Si algún día recompilas el juego, vuelve a correr este script.)"

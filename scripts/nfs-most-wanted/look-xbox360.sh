#!/bin/bash
# look-xbox360.sh — NFS Most Wanted Native: look fiel al Xbox 360 y más liviano para el M1.
# Uso:   bash scripts/nfs-most-wanted/look-xbox360.sh          (aplica)
#        bash scripts/nfs-most-wanted/look-xbox360.sh quitar   (vuelve a dejar todo en manos del menú F10)
# Cierra el juego antes de correrlo. Los cambios se ven al abrirlo de nuevo.

DIR="$HOME/Library/Application Support/NFS Most Wanted Native"
INI="$DIR/NativeOptions.ini"
DEF="/Applications/NFS Most Wanted Native.app/Contents/Resources/Defaults/NativeOptions.ini"
INICIO="; >>> native-on-mac look-xbox360 >>>"
FIN="; <<< native-on-mac look-xbox360 <<<"

if pgrep -f "NFS Most Wanted Native" >/dev/null; then
  echo "Cierra el juego primero y vuelve a correr el script."; exit 1
fi
mkdir -p "$DIR"
[ -f "$INI" ] || { [ -f "$DEF" ] && cp "$DEF" "$INI" || touch "$INI"; }
cp "$INI" "$INI.respaldo"

# Quita un bloque anterior de este script, si existe
awk -v a="$INICIO" -v b="$FIN" '$0==a{skip=1;next} $0==b{skip=0;next} !skip' "$INI.respaldo" > "$INI"

if [ "${1:-}" = "quitar" ]; then
  echo "Listo: se quitó la configuración Xbox 360. El menú F10 vuelve a mandar."; exit 0
fi

cat >> "$INI" <<EOF

$INICIO
[Native]
look = 1             ; Xbox 360: el look de consola, sin los efectos "Remaster" (más liviano)
golden_filter = 0    ; Auto: con el look Xbox 360 vuelve el filtro dorado
time_of_day = 0      ; hora fija, como el juego original (sin ciclo de día)
weather = 0          ; clima original (sin ciclo de clima)
antialiasing = 0     ; sin MSAA: lo más rápido
mirror_shadows = 0   ; sin sombras en el espejo (cuestan ~1.4 ms por cuadro)
x360_textures = 1    ; texturas de Xbox 360
x360_sky = 2         ; cielo de Xbox 360
$FIN
EOF
echo "Listo: look Xbox 360 aplicado. Abre el juego."
echo "(Respaldo del archivo anterior: NativeOptions.ini.respaldo)"

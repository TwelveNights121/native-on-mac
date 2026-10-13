#!/bin/bash
# diagnostico-herramientas.sh — revisa las herramientas de compilación de Apple. No cambia nada.
mkdir -p "$HOME/Downloads/native-on-mac-registro"
OUT="$HOME/Downloads/native-on-mac-registro/diag.txt"
{
  echo "== macOS"; sw_vers
  echo "== xcode-select"; xcode-select -p
  echo "== PATH"; echo "$PATH" | tr ':' '\n'
  echo "== which"; which -a clang clang++ ld cc 2>&1
  echo "== clang++ --version"; clang++ --version 2>&1 | head -3
  echo "== xcrun"; xcrun --find clang++ 2>&1; xcrun --find ld 2>&1; xcrun --show-sdk-path 2>&1
  echo "== ld -v"; ld -v 2>&1 | head -3
  echo "== xcrun ld -v"; xcrun ld -v 2>&1 | head -3
  echo "== SDKs"; ls -la /Library/Developer/CommandLineTools/SDKs/ 2>&1
  echo "== CLT"; pkgutil --pkg-info=com.apple.pkg.CLTools_Executables 2>&1
  echo "== Xcode"; ls -d /Applications/Xcode*.app 2>&1
  echo "== env"; env | grep -E '^(SDKROOT|CC|CXX|LDFLAGS|CFLAGS|DEVELOPER_DIR|MACOSX_DEPLOYMENT_TARGET)=' 2>&1
  echo "== actualizaciones"; softwareupdate --list 2>&1 | grep -i -A2 "command line"
} > "$OUT" 2>&1
echo "Listo: resultado en $OUT"

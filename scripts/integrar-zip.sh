#!/usr/bin/env bash
# =============================================================================
# integrar-zip.sh — Integra el material oficial del laboratorio al repositorio
# =============================================================================
# Uso:
#   bash scripts/integrar-zip.sh /ruta/al/proyecto-devsecops-cib204.zip
#
# Qué hace:
#   1. Descomprime el zip oficial en una carpeta temporal
#   2. Copia TODO el contenido a la raíz del repo (conserva .github/ y .devcontainer/)
#   3. Conserva la documentación propia (docs/, README.md, guia-paso-a-paso.md)
#      — los archivos del zip tienen prioridad SOLO donde el zip trae versiones
#      (servidor/, app-movil/, .github/workflows/, docker-compose.yml, etc.)
#   4. Muestra un resumen de lo integrado y de lo que se conservó
#   5. Hace commit y push (Fase 1: el pipeline se dispara y sale en rojo, esperado)
#
# Nota: los archivos del zip reemplazan a los provisionales del repo
# (devsecops.yml, docker-compose.yml, devcontainer.json). La documentación
# propia (docs/) se conserva salvo que el zip traiga versiones oficiales.
# =============================================================================
set -euo pipefail

ZIP="${1:-}"
if [[ -z "$ZIP" || ! -f "$ZIP" ]]; then
  echo "❌ Uso: bash scripts/integrar-zip.sh /ruta/al/proyecto-devsecops-cib204.zip"
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "📦 Descomprimiendo $ZIP ..."
unzip -q "$ZIP" -d "$TMP"

# Localizar la carpeta raíz del proyecto dentro del zip
SRC="$TMP"
if [[ -d "$TMP/proyecto-devsecops-cib204" ]]; then
  SRC="$TMP/proyecto-devsecops-cib204"
fi

echo "📂 Contenido del zip:"
ls -la "$SRC"

# Archivos/carpetas que el zip trae y reemplazan a los provisionales
echo "🔄 Copiando material oficial al repositorio ..."
for item in "$SRC"/* "$SRC"/.[!.]*; do
  name="$(basename "$item")"
  case "$name" in
    .git) continue ;;  # nunca copiar el .git del zip
  esac
  if [[ -e "$item" ]]; then
    cp -r "$item" "$ROOT/$name"
    echo "   → $name"
  fi
done

echo ""
echo "✅ Integración completada."
echo ""
echo "📋 Verifica antes de subir:"
echo "   1. git status  (revisa qué cambió)"
echo "   2. ls -la      (confirma .github/ y .devcontainer/ presentes)"
echo "   3. git diff --stat"
echo ""
echo "🚀 Para subir (Fase 1 — el pipeline saldrá en ROJO, es lo esperado):"
echo "   git add -A"
echo "   git commit -m 'Sube material inseguro (Fase 1)'"
echo "   git push"
echo ""
echo "💡 Si algo quedó mal (faltan carpetas ocultas), ejecuta:"
echo "   bash restaurar-archivos.sh   (si viene en el zip)"
#!/bin/bash
# ============================================================================
#  generar-manifiesto.sh - Regenera docs/evidencias/manifiesto-sha256.txt
#  Rutas relativas a la RAIZ del repositorio; verificar con:
#     sha256sum --check docs/evidencias/manifiesto-sha256.txt
# ============================================================================
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"; cd "$RAIZ" || exit 1
{
  find docs/evidencias/capturas docs/evidencias/figuras -type f | sort
  ls docs/evidencias/informe-maestro.docx docs/evidencias/informe-maestro.pdf docs/evidencias/README.md docs/evidencias/INSTRUCCIONES-CAPTURA.md
  ls docs/informe-maestro.md docs/informe-maestro.docx docs/plantilla-diagnostico.md docs/auditoria/AUDITORIA-IA-EXTERNA.md
  ls docs/tablas/tabla-*.md .github/workflows/devsecops.yml scripts/*.sh
  ls servidor/*.js servidor/package.json servidor/package-lock.json servidor/Dockerfile servidor/.dockerignore servidor/.env.example
} | sort -u | xargs sha256sum > docs/evidencias/manifiesto-sha256.txt
echo "Manifiesto regenerado: $(wc -l < docs/evidencias/manifiesto-sha256.txt) entradas"

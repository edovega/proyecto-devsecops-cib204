#!/bin/bash
# ============================================================================
#  verificar-evidencia.sh - Comprueba que la evidencia instalada en el repo es
#  byte-identica a los artefactos del run verde de referencia y que el manifiesto
#  SHA-256 sigue vigente.  Uso:  bash scripts/verificar-evidencia.sh [RUN_ID]
#  Requiere: gh (autenticado), sha256sum, cmp.
# ============================================================================
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"; cd "$RAIZ" || exit 1
RUN="${1:-$(grep -oE 'RUN_VERDE=[0-9]+' docs/evidencias/README.md | head -1 | cut -d= -f2)}"
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner); TMP=$(mktemp -d); C=docs/evidencias/capturas; fallos=0
echo "== 1. Run $RUN"; gh run view "$RUN" --json headSha,status,conclusion,event --jq '"\(.headSha) \(.status)/\(.conclusion) evento=\(.event)"'
echo "== 2. Manifiesto SHA-256"; sha256sum --check docs/evidencias/manifiesto-sha256.txt | grep -vc ': OK$' | sed 's/^/archivos que NO coinciden: /'
echo "== 3. Artefactos del run vs evidencia instalada"; gh run download "$RUN" -D "$TMP" >/dev/null 2>&1
for p in "reporte-semgrep/semgrep.sarif EV-C204-008-semgrep.json" "reporte-gitleaks/gitleaks.sarif EV-C204-009-gitleaks.json" "sbom/sbom.spdx.json EV-C204-010-sbom.json" "reporte-zap/informe_zap.html EV-C204-011-zap.html"; do
  set -- $p; if cmp -s "$TMP/$1" "$C/$2"; then echo "IDENTICO  $2"; else echo "DIFIERE   $2"; fallos=$((fallos+1)); fi; done
rm -rf "$TMP"; echo "== Resultado: $fallos diferencias"; exit $fallos

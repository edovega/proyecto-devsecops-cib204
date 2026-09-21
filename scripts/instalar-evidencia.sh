#!/bin/bash
# ============================================================================
#  instalar-evidencia.sh - Instala en docs/evidencias/capturas/ los artefactos
#  de un run verde de GitHub Actions (EV-C204-008..011) y genera EV-C204-025
#  (alertas CodeQL), EV-C204-026 (run verde) y EV-C204-029 (historial).
#  Uso:  bash scripts/instalar-evidencia.sh <RUN_ID>      Requiere: gh, python3
# ============================================================================
RUN="$1"; [ -z "$RUN" ] && { echo "Uso: $0 <RUN_ID>"; exit 1; }
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"; cd "$RAIZ" || exit 1
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner); C=docs/evidencias/capturas; TMP=$(mktemp -d)
SHA=$(gh run view "$RUN" --json headSha --jq .headSha)
[ "$(gh run view "$RUN" --json conclusion --jq .conclusion)" = "success" ] || { echo "El run $RUN no termino en success"; exit 1; }
gh run download "$RUN" -D "$TMP" >/dev/null || exit 1
cp "$TMP/reporte-semgrep/semgrep.sarif"  $C/EV-C204-008-semgrep.json
cp "$TMP/reporte-gitleaks/gitleaks.sarif" $C/EV-C204-009-gitleaks.json
cp "$TMP/sbom/sbom.spdx.json"            $C/EV-C204-010-sbom.json
cp "$TMP/reporte-zap/informe_zap.html"   $C/EV-C204-011-zap.html
GEN=$(date -u +%FT%TZ)
python3 - "$REPO" "$SHA" "$GEN" "$C" <<'E'
import json,subprocess,sys
repo,sha,gen,C=sys.argv[1:5]
def g(u): return json.loads(subprocess.check_output(["gh","api",u]))
out={"repositorio":repo,"commit":sha,"generado":gen,"configuracion":g(f"repos/{repo}/code-scanning/default-setup"),
 "analisis_del_commit":[{k:a[k] for k in ("category","results_count","rules_count","created_at","tool")} for a in g(f"repos/{repo}/code-scanning/analyses?per_page=30") if a["commit_sha"]==sha],
 "alertas":[{"numero":a["number"],"regla":a["rule"]["id"],"severidad":a["rule"].get("security_severity_level"),"estado":a["state"],"archivo":a["most_recent_instance"]["location"]["path"],"linea":a["most_recent_instance"]["location"]["start_line"],"corregida_en":a.get("fixed_at")} for a in g(f"repos/{repo}/code-scanning/alerts?per_page=100&state=all")]}
json.dump(out,open(f"{C}/EV-C204-025-codeql-alertas.json","w"),indent=2,ensure_ascii=False)
E
{ echo "# Run verde de referencia (Fase 2) - gh run view $RUN"; echo "# Generado: $GEN"
  gh run view "$RUN" --json databaseId,headSha,status,conclusion,event,createdAt,url,workflowName --jq '"run \(.databaseId) | \(.workflowName) | commit \(.headSha) | \(.status)/\(.conclusion) | evento \(.event) | \(.createdAt) | \(.url)"'
  echo; gh run view "$RUN" --json jobs --jq '.jobs[]|"\(.conclusion)\t\(.name)\t\(.startedAt) -> \(.completedAt)"'
  echo; echo "# Artefactos (nombre y tamano)"; gh api "repos/$REPO/actions/runs/$RUN/artifacts" --jq '.artifacts[]|"\(.name)\t\(.size_in_bytes) bytes"'
  echo; echo "# CodeQL (default setup) sobre el mismo commit"; gh api "repos/$REPO/code-scanning/analyses?per_page=30" --jq '.[]|select(.commit_sha=="'"$SHA"'")|"\(.category)\tresultados=\(.results_count)\treglas=\(.rules_count)"'; } > $C/EV-C204-026-run-verde.txt
{ echo "# Historial completo de ejecuciones del pipeline (gh run list)"; echo "# Generado: $GEN"; echo "# id_run	commit	resultado	fecha"
  gh run list --workflow "Pipeline DevSecOps CIB-204" --limit 100 --json databaseId,headSha,conclusion,createdAt --jq 'reverse|.[]|"\(.databaseId)\t\(.headSha[0:7])\t\(.conclusion)\t\(.createdAt)"'; } > $C/EV-C204-029-historial-runs.txt
rm -rf "$TMP"; echo "Evidencia instalada desde el run $RUN (commit $SHA)"

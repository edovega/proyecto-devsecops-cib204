#!/bin/bash
# ============================================================================
#  generar-informe.sh - Renderiza docs/informe-maestro.md a DOCX y PDF
#  Salida: docs/informe-maestro.docx, docs/evidencias/informe-maestro.docx y .pdf
#  Requiere: python3, pandoc y LibreOffice (soffice). Las figuras PNG derivan de los SVG.
#  Para que las columnas de las tablas se dimensionen segun su contenido, se genera
#  una copia temporal del .md con separadores de columna proporcionales (el .md no cambia).
# ============================================================================
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"; cd "$RAIZ" || exit 1
OUT=docs/evidencias; TMP=$(mktemp -d)
python3 - docs/informe-maestro.md "$TMP/informe.md" <<'PY' || exit 1
import re, sys
src, dst = sys.argv[1:3]
L = open(src, encoding="utf8").read().split("\n")
sep = re.compile(r"^\|(\s*:?-{3,}:?\s*\|)+\s*$")
def cells(l): return [c.strip() for c in l.strip().strip("|").split("|")]
i = 0
while i < len(L):
    if sep.match(L[i]) and i > 0 and L[i-1].startswith("|"):
        rows = [cells(L[i-1])]; j = i + 1
        while j < len(L) and L[j].startswith("|"): rows.append(cells(L[j])); j += 1
        n = len(rows[0]); w = []
        for c in range(n):
            m = max(len(re.sub(r"[`*]", "", r[c])) if c < len(r) else 0 for r in rows)
            longest_word = max((len(x) for r in rows if c < len(r) for x in re.sub(r"[`*]", "", r[c]).split()), default=4)
            w.append(max(12, min(m, 55), min(longest_word, 30) * 2))
        tot = sum(w); d = [max(3, round(x * 100 / tot)) for x in w]
        L[i] = "|" + "|".join("-" * x for x in d) + "|"
        i = j
    else:
        i += 1
open(dst, "w", encoding="utf8").write("\n".join(L))
PY
pandoc "$TMP/informe.md" -f markdown -t docx --resource-path=docs --columns=60 --toc --toc-depth=2 \
  --metadata title="Proyecto de seguridad en aplicaciones móviles — Pipeline DevSecOps (CIB-204)" \
  -o $OUT/informe-maestro.docx || exit 1
soffice --headless --convert-to pdf --outdir $OUT $OUT/informe-maestro.docx >/dev/null 2>&1 || exit 1
cp $OUT/informe-maestro.docx docs/informe-maestro.docx; rm -rf "$TMP"
echo "Generados: $OUT/informe-maestro.docx, $OUT/informe-maestro.pdf, docs/informe-maestro.docx"

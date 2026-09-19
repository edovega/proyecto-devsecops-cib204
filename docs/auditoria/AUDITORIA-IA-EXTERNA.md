# Auditoría de convergencia — Instrucciones para revisión externa (persona o IA)

> Documento autocontenido. No hay que confiar en este texto: cada afirmación se **re-verifica con un comando** que se escribe abajo. Si un comando no reproduce lo afirmado, es una discrepancia y se reporta; el cierre lo decide el equipo, no el auditor.

## 1. Qué se audita

Cierre del hallazgo FIX-18 y del laboratorio DevSecOps CIB-204 (Maestría en Ciberseguridad, CENFOTEC): un pipeline de GitHub Actions que pasó de **rojo** (Fase 1, diagnóstico) a **verde** (Fase 2, remediación), con evidencia byte-verificable instalada en el repositorio y contrastada con la guía oficial del curso y la rúbrica del programa.

| Dato | Valor |
|---|---|
| Repositorio | https://github.com/edovega/proyecto-devsecops-cib204 (rama `main`, público) |
| Commit de **código** evaluado | `0fc1c11b2a63f8ef34fc6c8fbba10a7480170346` |
| Run verde de referencia | `35442482331` (evento `push`, 5/5 jobs en `success`; CodeQL default setup con 0 alertas abiertas) |
| Run de la Fase 1 (rojo) | `35365578175` (commit `46cb634`) |
| Commits posteriores al de código | solo documentación y evidencia; cada uno dispara el pipeline, que debe seguir en verde |

> El `HEAD` de `main` **no** es el commit de código: los commits de documentación llegan después. Lo correcto es comprobar que el run verde corresponde a `0fc1c11` y que el **último** run de `main` también es `success`.

## 2. Dónde está cada cosa (rutas relativas a la raíz del repositorio)

| Qué | Ruta |
|---|---|
| Informe maestro | `docs/informe-maestro.md` (+ `.docx` y `docs/evidencias/informe-maestro.pdf`, generados con `scripts/generar-informe.sh`) |
| Tablas 1 a 6 | `docs/tablas/` (también dentro del informe, Anexo A) |
| Plantilla de diagnóstico | `docs/plantilla-diagnostico.md` |
| Manifiesto SHA-256 | `docs/evidencias/manifiesto-sha256.txt` |
| Reportes del run verde | `docs/evidencias/capturas/EV-C204-008…011` |
| Reportes de la Fase 1 | `docs/evidencias/capturas/EV-C204-020…022` (zips), `EV-C204-027`, `EV-C204-028` |
| Pruebas | `EV-C204-023` (extremo a extremo con Keycloak real), `EV-C204-024` (Jest, ESLint, npm audit) |
| Capturas de pantalla del equipo | `docs/evidencias/capturas/consola-git/` → 19 PNG, `EV-C204-033…051` |
| Guía oficial del curso (original, fuera del repo) | `/home/evega/Downloads/Guia_CIB204_DevSecOps.docx` |

## 3. Procedimiento determinista

Ejecutar desde la **raíz** del repositorio.

```bash
# 1. Anclaje: el run verde corresponde al commit de código
git cat-file -t 0fc1c11b2a63f8ef34fc6c8fbba10a7480170346
gh run view 35442482331 --json headSha,status,conclusion,event --jq '"\(.headSha) \(.status)/\(.conclusion) \(.event)"'
#    esperado: 0fc1c11b2a63f8ef34fc6c8fbba10a7480170346 completed/success push
gh run list --branch main --limit 3 --json headSha,conclusion --jq '.[]|"\(.headSha[0:7]) \(.conclusion)"'   # el último debe ser success

# 2. Manifiesto canónico
sha256sum --check docs/evidencias/manifiesto-sha256.txt      # exit 0, todas «OK»

# 3. Reportes instalados == artefactos del run verde (byte a byte)
bash scripts/verificar-evidencia.sh 35442482331               # 4 × IDENTICO

# 4. Las 19 capturas están en el informe
ls docs/evidencias/capturas/consola-git/*.png | wc -l         # 19
for f in docs/evidencias/capturas/consola-git/*.png; do n=$(basename "$f"); echo "$(grep -c -F "$n" docs/informe-maestro.md) $n"; done   # cada una ≥ 1 (todas aparecen en el Anexo I; 17 además como figura en §8.1 y §13)

# 5. El código hace lo que dice
cd servidor && npm ci && npm test                              # Tests: 22 passed
cd .. && bash scripts/prueba-e2e-keycloak.sh | grep -c PASA    # 25 (requiere Docker; levanta Keycloak 24.0 temporal)
```

## 4. Requisitos de la guía a contrastar

- **Pipeline con las 6 pruebas** (guía §9.1): el workflow tiene **5 jobs**; CodeQL corre por *default setup* de GitHub (no pueden coexistir). Es una desviación **documentada** (informe §8.6 y §12.1). Verificar: `gh api repos/edovega/proyecto-devsecops-cib204/code-scanning/default-setup` → `configured`, y `EV-C204-025` → 0 alertas abiertas.
- **Tablas 1 a 6** (guía): completas en `docs/tablas/`; la 3, 4, 5 y 6 con datos reales.
- **STRIDE, SAST/DAST, Keycloak**: informe §5–§6, §12, §11 y `EV-C204-023`.
- **Autenticación con Keycloak, RS256 + JWKS** (guía §10.5): `servidor/auth.js` y `servidor/auth.test.js`.
- **Protección de la rama `main`** (guía, paso 14): activada mediante el ruleset `proteger-main` (informe §15). Verificar: `gh api repos/edovega/proyecto-devsecops-cib204/rulesets --jq '.[]|"\(.name) \(.enforcement)"'` → `proteger-main active`, y `EV-C204-030`. (La API clásica `branches/main/protection` responde 404 porque se usan *rulesets*, no la protección clásica.)

## 5. Formato del reporte del auditor

1. **Convergencia (SÍ/NO + prueba):** run verde, hashes byte-idénticos y manifiesto.
2. **Discrepancias:** lista numerada con el comando que las reproduce.
3. **Cobertura de la guía y la rúbrica:** cumple / cumple con desviación / no cumple, por criterio.
4. **Pendientes conocidos del equipo:** EV-C204-006 (app móvil), capturas de la consola de Keycloak, confirmar que el Codespace con Docker funciona y confirmación de fechas con la docente.

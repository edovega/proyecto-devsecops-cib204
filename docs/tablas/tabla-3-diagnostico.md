# Tabla 3 — Diagnóstico de seguridad (Fase 1, pipeline en rojo)

> **Estado: COMPLETA con datos reales.** Fuente: ejecución **35365578175** del pipeline (commit `46cb634`, código oficial sin remediar), descargada de GitHub Actions. Es la única corrida que refleja el proyecto tal como llegó, antes de corregir. Reportes: EV-C204-020/021/022 (zips de artefactos), EV-C204-027 (SBOM) y EV-C204-028 (log de los jobs en rojo); capturas de pantalla EV-C204-033 a EV-C204-051.

## Resultado por prueba

| Prueba (job) | Resultado Fase 1 | Cifras reales | Evidencia |
|---|---|---|---|
| SAST – Semgrep | ❌ rojo | **23 hallazgos** (8 reglas distintas; 16 son de un mismo tipo en el workflow) | EV-C204-021, captura EV-C204-040 |
| SAST – CodeQL | ❌ rojo | El job avanzado falló por configuración del repositorio (no por hallazgos); ver informe §8.6 | EV-C204-047 a EV-C204-051 |
| Secretos – Gitleaks | ❌ rojo | **4 secretos** en 2 archivos | EV-C204-020, captura EV-C204-041 |
| SCA – Dependencias | ❌ rojo | `npm audit`: **13 vulnerabilidades** (3 low, 1 moderate, 8 high, **1 critical**) | EV-C204-028 |
| Imagen – Trivy + SBOM | ❌ rojo | Trivy sobre la imagen: **640 hallazgos** (583 HIGH, 57 CRITICAL) | EV-C204-027, EV-C204-028 |
| DAST – OWASP ZAP | ✅ verde (solo informa) | **0 High, 2 Medium, 2 Low, 5 Informational** | EV-C204-022, captura EV-C204-042 |

## Hallazgos (H-01 a H-15)

La columna **VULN** cruza con los marcadores `// [VULN-n]` que el código oficial trae comentados. **Confirmado** significa que una herramienta del pipeline lo reportó en la corrida 35365578175; cuando no fue así se indica cómo se identificó.

| ID | VULN | Prueba / herramienta | Dónde | Hallazgo y CWE | Riesgo | Confirmado en rojo |
|---|---|---|---|---|---|---|
| H-01 | 2 | Secretos / Gitleaks | `servidor/.env` (líneas 4-5), `servidor/config.js` (líneas 14 y 18) | Secretos quemados: 2× `aws-access-token`, 2× `generic-api-key` (CWE-798) | Alto | ✅ Gitleaks: 4 |
| H-02 | — | SCA / `npm audit` | `servidor/package.json` | Dependencias vulnerables: axios 0.18.0 (CSRF, ReDoS), lodash 4.17.4 (contaminación de prototipo), otras (CWE-1104 / CWE-1035) | Alto | ✅ 13 vulnerabilidades |
| H-03 | 9 | SAST / Semgrep | `servidor/servidor.js:87` | `eval()` sobre entrada del usuario (`eval-detected`) y concatenación de código (`code-string-concat`), CWE-95 | Alto | ✅ 2 reglas |
| H-04 | 4 | SAST / Semgrep | `servidor/auth.js:37` | JWT aceptado sin verificar firma y con `alg: none` (`jwt-none-alg`; CWE-347 / CWE-287) | Alto | ✅ |
| H-05 | 5 | DAST / ZAP | respuestas HTTP | CORS totalmente abierto (`cors()` sin lista blanca): ZAP «Cross-Domain Misconfiguration» (CWE-942) | Medio | ✅ ZAP Medium |
| H-06 | 8 | Revisión manual del código | `servidor/servidor.js:57-69` | Se devuelve `e.stack` al cliente (CWE-209) | Medio | ⚠️ Ninguna herramienta lo reportó; identificado por el marcador `[VULN-8]` y lectura del código |
| H-07 | 11 | Imagen / Trivy | `servidor/Dockerfile` | Base `node:latest` no reproducible y con CVEs (CWE-1104): 640 hallazgos HIGH/CRITICAL | Alto | ✅ Trivy |
| H-08 | 13 | SAST / Semgrep | `servidor/Dockerfile:26` | Contenedor como root (`missing-user`, CWE-250) | Medio | ✅ |
| H-09 | 6 | DAST / ZAP | respuestas HTTP | Cabeceras ausentes: «CSP: Failure to Define Directive with No Fallback» (Medium), «Permissions Policy Header Not Set» y «X-Powered-By» (Low) | Medio | ✅ ZAP |
| H-10 | 1 | Revisión manual del código | `servidor/cifrado.js` | RSA de **1024 bits** con relleno **PKCS#1 v1.5** (CWE-326 / CWE-780) | Alto | ⚠️ Ninguna herramienta lo reportó; identificado por `[VULN-1]` |
| H-11 | 3 | SAST / Semgrep | `servidor/db.js:35` | Inyección SQL por concatenación (`node-mysql-sqli`, CWE-89) | Alto | ✅ |
| H-12 | 12 | Imagen / Trivy + SBOM | `servidor/Dockerfile` (`COPY . .`) | Se copia todo el contexto a la imagen (`.env`, llaves): CWE-538 | Medio | ⚠️ Solo por revisión del Dockerfile; el SBOM lista los paquetes, no esto |
| H-13 | 10 | SAST / Semgrep | `servidor/servidor.js:100` | Inyección de comandos con `exec('ping …' + host)` (`detect-child-process`, CWE-78) | Alto | ✅ |
| H-14 | — | SAST / Semgrep | `.github/workflows/devsecops.yml` (16 líneas) | Acciones de GitHub con etiqueta mutable `@v4`/`@master` en vez de SHA (`github-actions-mutable-action-tag`; CWE-1357 / CWE-353, cadena de suministro) | Medio | ✅ 16 hallazgos |
| H-15 | — | SAST / Semgrep | `servidor/servidor.js:24` | Sin middleware CSRF (`express-check-csurf-middleware-usage`, CWE-352) | Bajo | ✅ (**falso positivo**: API sin cookies, autentica con Bearer JWT) |
| H-16 | 7 | Revisión manual del código | `servidor/servidor.js:50` | Sin validación de tipo ni tamaño de la entrada (CWE-20) | Medio | ⚠️ Solo por `[VULN-7]` |

**Reconciliación con los 23 de Semgrep:** 16 (H-14) + 1 (H-15) + 1 (H-04) + 1 (H-11) + 2 (H-03: `eval-detected` y `code-string-concat`) + 1 (H-13) + 1 (H-08) = **23**.

**Nota de honestidad sobre la plantilla original:** la versión preliminar de esta tabla listaba «H-12 SCA / Trivy (fs)». En la corrida real el job SCA se detuvo en `npm audit` (código de salida 1) antes de llegar a Trivy (fs), por lo que ese hallazgo quedó cubierto por H-02 y H-07 y no se cuenta aparte. Los hallazgos H-06, H-10, H-12 y H-16 son debilidades reales del código oficial que **las herramientas no detectaron**: por eso la revisión manual del código sigue siendo necesaria además del pipeline.

## Dónde encontrar cada hallazgo

| Prueba | Dónde se ve el resultado |
|---|---|
| sast_semgrep | Log del job en Actions + `EV-C204-021-reporte-semgrep.zip` (SARIF) |
| sast_codeql | Pestaña *Security → Code scanning* (default setup); ver informe §8.6 y EV-C204-025 |
| secretos | Log del job + `EV-C204-020-reporte-gitleaks.zip` (SARIF) |
| sca | Log del job (`EV-C204-028`) |
| imagen | Log del job (`EV-C204-028`) + SBOM (`EV-C204-027`) |
| dast | `EV-C204-022-reporte-zap.zip` (no sale en rojo: solo informa) |

## Evidencia descargada (Fase 1)

- [x] Reporte Semgrep → `docs/evidencias/capturas/EV-C204-021-reporte-semgrep.zip`
- [x] Reporte Gitleaks → `docs/evidencias/capturas/EV-C204-020-reporte-gitleaks.zip`
- [x] SBOM → `docs/evidencias/capturas/EV-C204-027-sbom-fase1.zip`
- [x] Informe ZAP → `docs/evidencias/capturas/EV-C204-022-reporte-zap.zip`
- [x] Log de los jobs en rojo → `docs/evidencias/capturas/EV-C204-028-log-fase1-jobs-rojos.txt` (secretos de práctica redactados)
- [x] Capturas de pantalla del pipeline en rojo → `docs/evidencias/capturas/consola-git/` (EV-C204-033 a EV-C204-051)
- [ ] Captura de *Security → Code scanning* (Fase 1): **no existe** porque el job de CodeQL avanzado no llegó a publicar alertas; las alertas de CodeQL de la Fase 2 están en EV-C204-025.

## Registro de confirmación

Resumen: de 16 hallazgos, **12 fueron confirmados por una herramienta** del pipeline y **4 por revisión de código** (H-06, H-10, H-12, H-16); H-15 es un falso positivo documentado. Ningún hallazgo esperado quedó sin evidencia de alguna de las dos fuentes.

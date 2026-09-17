# Tabla 3 — Diagnóstico de seguridad

> 📄 **Tabla a llenar** — Segundo Avance (Fase 1). Recorre cada prueba en rojo y anota los hallazgos.
> Hay ~12 hallazgos en total. Los reportes se descargan de la sección "Artifacts" de la ejecución.
>
> ⚠️ **Estado: PRELIMINAR.** Las filas H-03 a H-12 son los hallazgos **esperados** según la descripción de la guía y el código vulnerable (`// [VULN-n]`). Se **confirman o ajustan** con los reportes reales del pipeline cuando el zip oficial esté integrado (Fase 1).

| ID | Prueba/Herramienta | Dónde (componente) | Hallazgo y CWE | Riesgo |
|---|---|---|---|---|
| H-01 | secretos / Gitleaks | servidor/.env, config.js | Secretos quemados (CWE-798) | Alto |
| H-02 | sca / npm audit | servidor/package.json | Librería vulnerable (CWE-1104) | Alto |
| H-03 | sast_semgrep | servidor/servidor.js | Uso de `eval()` / inyección (CWE-95) | Alto |
| H-04 | sast_semgrep | servidor/auth.js | JWT mal validado / autenticación incorrecta (CWE-287) | Alto |
| H-05 | sast_semgrep | servidor/servidor.js | CORS abierto / configuración incorrecta (CWE-942) | Medio |
| H-06 | sast_semgrep | servidor/servidor.js | Errores internos expuestos (CWE-209) | Medio |
| H-07 | imagen / Trivy | servidor/Dockerfile | Imagen base con vulnerabilidades conocidas | Medio |
| H-08 | imagen / Trivy | servidor/Dockerfile | Ejecución como root (CWE-250) | Medio |
| H-09 | dast / ZAP | servidor (respuestas HTTP) | Cabeceras de seguridad ausentes (CSP, X-Frame-Options) | Medio |
| H-10 | sast_semgrep | servidor/cifrado.js | Criptografía insegura: padding débil o llave insuficiente (CWE-326 / CWE-780) | Alto |
| H-11 | sast_semgrep | servidor/db.js | Consulta insegura / inyección (CWE-89) | Medio |
| H-12 | sca / Trivy (fs) | servidor/ | Dependencias de la imagen con CVEs | Medio |

## Dónde encontrar cada hallazgo

| Prueba | Dónde se ve el resultado |
|---|---|
| sast_semgrep | Log del job en Actions (rojo) + artefacto de reporte Semgrep |
| sast_codeql | **No sale en rojo**: alertas en "Security → Code scanning" |
| secretos | Log del job (rojo) + artefacto de reporte Gitleaks |
| sca | Log del job (rojo) + artefacto del SBOM |
| imagen | Log del job (rojo) + artefacto del SBOM (Syft) |
| dast | **No sale en rojo**: artefacto `reporte-zap` (cabeceras ausentes, CORS abierto) |

## Evidencia descargada (Fase 1)

- [ ] Reporte Semgrep → `docs/evidencias/capturas/`
- [ ] Reporte Gitleaks → `docs/evidencias/capturas/`
- [ ] SBOM (Trivy/Syft) → `docs/evidencias/capturas/`
- [ ] Informe ZAP → `docs/evidencias/capturas/`
- [ ] Alertas CodeQL (captura de Security → Code scanning) → `docs/evidencias/capturas/`

## Registro de confirmación (se completa en Fase 1 real)

| ID | ¿Confirmado? | Hallazgo real (si difiere del esperado) | CWE real | Riesgo real |
|---|---|---|---|---|
| H-01 | ⏳ | | | |
| H-02 | ⏳ | | | |
| H-03 | ⏳ | | | |
| H-04 | ⏳ | | | |
| H-05 | ⏳ | | | |
| H-06 | ⏳ | | | |
| H-07 | ⏳ | | | |
| H-08 | ⏳ | | | |
| H-09 | ⏳ | | | |
| H-10 | ⏳ | | | |
| H-11 | ⏳ | | | |
| H-12 | ⏳ | | | |
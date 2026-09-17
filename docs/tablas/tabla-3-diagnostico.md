# Tabla 3 — Diagnóstico de seguridad

> 📄 **Tabla a llenar** — Segundo Avance (Fase 1). Recorre cada prueba en rojo y anota los hallazgos.
> Hay ~12 hallazgos en total. Los reportes se descargan de la sección "Artifacts" de la ejecución.

| ID | Prueba/Herramienta | Dónde (componente) | Hallazgo y CWE | Riesgo |
|---|---|---|---|---|
| H-01 | secretos / Gitleaks | servidor/.env, config.js | Secretos quemados (CWE-798) | Alto |
| H-02 | sca / npm audit | servidor/package.json | Librería vulnerable (CWE-1104) | Alto |
| H-03 | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| H-04 | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| H-05 | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| H-06 | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| H-07 | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| H-08 | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| H-09 | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| H-10 | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| H-11 | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| H-12 | *(completar)* | *(completar)* | *(completar)* | *(completar)* |

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
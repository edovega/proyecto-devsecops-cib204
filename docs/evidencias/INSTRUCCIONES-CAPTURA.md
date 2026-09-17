# Instrucciones de captura por evidencia

> Cada evidencia EV-C204-XXX se guarda en `docs/evidencias/capturas/` y se registra en `manifiesto-sha256.txt`.
> Formato de archivo: `EV-C204-XXX-descripcion.ext` (png, txt, json, html).

## Fase 1 — Diagnóstico (pipeline en rojo)

| Evidencia | Qué capturar | Cómo | Archivo sugerido |
|---|---|---|---|
| EV-C204-001 | Versiones del entorno | `node --version && npm --version && docker --version` en el Codespace | `EV-C204-001-versiones.txt` |
| EV-C204-002 | Servicio `/salud` respondiendo | Abrir URL del puerto 3000 + `/salud` (o `curl`) | `EV-C204-002-salud.png` |
| EV-C204-003 | Keycloak: realm appmovil | Consola admin → Realm settings | `EV-C204-003-realm.png` |
| EV-C204-004 | Keycloak: cliente servicio-cifrado | Consola admin → Clients → servicio-cifrado | `EV-C204-004-cliente.png` |
| EV-C204-005 | Keycloak: usuario demo | Consola admin → Users → demo | `EV-C204-005-usuario.png` |
| EV-C204-006 | App móvil cifrando/descifrando | Pantalla de la app con "Cifrado OK" y "Descifrado OK" | `EV-C204-006-app.png` |
| EV-C204-007 | Pipeline Fase 1 (jobs en rojo) | Actions → ejecución → vista de los 6 jobs | `EV-C204-007-pipeline-rojo.png` |
| EV-C204-008 | Reporte Semgrep | Actions → job sast_semgrep → Artifacts → descargar | `EV-C204-008-semgrep.json` |
| EV-C204-009 | Reporte Gitleaks | Actions → job secretos → Artifacts | `EV-C204-009-gitleaks.json` |
| EV-C204-010 | SBOM (Fase 1) | Actions → job sca/imagen → Artifacts | `EV-C204-010-sbom.json` |
| EV-C204-011 | Informe ZAP | Actions → job dast → Artifacts → reporte-zap | `EV-C204-011-zap.html` |
| EV-C204-012 | Alertas CodeQL | Security → Code scanning → alertas | `EV-C204-012-codeql.png` |

## Fase 2 — Remediación (pipeline en verde)

| Evidencia | Qué capturar | Cómo | Archivo sugerido |
|---|---|---|---|
| EV-C204-013 | Pipeline Fase 2 (todo verde) | Actions → última ejecución → 6/6 jobs verdes | `EV-C204-013-pipeline-verde.png` |
| EV-C204-014 | Rama main protegida | Settings → Branches → main (requiere PR + checks) | `EV-C204-014-proteccion.png` |

## Figuras (ya creadas)

| Evidencia | Archivo |
|---|---|
| EV-C204-015 | `figuras/figura-1-contexto.svg` |
| EV-C204-016 | `figuras/figura-2-arquitectura.svg` |
| EV-C204-017 | `figuras/figura-3-flujo.svg` |

## Reglas de captura

1. **Fecha visible** en cada captura (reloj del sistema o `date` en la terminal).
2. **Nombre del archivo** con el ID de evidencia exacto.
3. **Registrar el hash** después de guardar:
   ```bash
   cd docs/evidencias && sha256sum capturas/* figuras/* > manifiesto-sha256.txt
   ```
4. **No capturar secretos reales**: si una captura muestra credenciales, difuminar antes de subir.
5. Subir las capturas en el mismo commit que la sección del informe que las referencia.
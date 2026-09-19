# Reporte a la docente — Codespace del material oficial entra en «modo de recuperación»

**Curso:** CIB-204 Seguridad del Software · **Estudiante:** Eduardo J. Vega Arguedas · **Fecha:** 19 de septiembre de 2026

## 1. Resumen
Al abrir un Codespace con el `.devcontainer/devcontainer.json` incluido en `proyecto-devsecops-cib204.zip`, el Codespace arranca en **modo de recuperación** y no dispone del entorno previsto (Node 20 + Docker). El error parece originarse en el material, no en el trabajo del estudiante.

## 2. Dónde está
Archivo del zip: `proyecto-devsecops-cib204/.devcontainer/devcontainer.json` (idéntico al del commit `9b1bddb` del repositorio):

```json
"image": "mcr.microsoft.com/devcontainers/javascript-node:20",
"features": { "ghcr.io/devcontainers/features/docker-in-docker:2": {} }
```

## 3. Síntoma (evidencia del estudiante)
Mensaje del Codespace: *«This codespace is currently running in recovery mode due to a container error»*. Capturas EV-C204-043 y EV-C204-044 (`docs/evidencias/capturas/consola-git/`).

## 4. Causa
- **Confirmada** con la configuración alternativa `docker-outside-of-docker` (registro de creación del 19-sep-2026): *«The 'moby' option is not supported on debian 'trixie' because 'moby-cli' and related system packages are not available in that distribution»* → *«Feature … failed to install»* → *«Creating recovery container»*.
- La imagen `javascript-node:20` es hoy **Debian 13 «trixie»** (`PRETTY_NAME="Debian GNU/Linux 13 (trixie)"`, Node 20.20.2), y las características de Docker de dev containers instalan por defecto el paquete `moby`, que no existe en trixie.
- **Inferida** para `docker-in-docker:2`, la del zip: comparte imagen base y opción por defecto, y produce el mismo síntoma. No se conservó el texto exacto del error de esa configuración.
- Probablemente el material se preparó cuando la imagen todavía estaba basada en Debian «bookworm».

## 5. Cómo se ajustó
1. Commit `46cb634`: se retiró `docker-in-docker` para poder trabajar (el Codespace queda con Node 20 y **sin Docker**).
2. Configuración alternativa `.devcontainer/con-docker/devcontainer.json`: `docker-outside-of-docker` con `"moby": false` (lo que indica el propio mensaje de error).
3. Alternativa sin cambiar el material: fijar la imagen a una basada en bookworm (`mcr.microsoft.com/devcontainers/javascript-node:20-bookworm`).

## 6. Impacto en el laboratorio
Sin Docker en el Codespace no se puede ejecutar `docker compose up` (servicio y Keycloak, guía §6.2 y §7). El pipeline de GitHub Actions no se ve afectado. Por eso Keycloak se validó adicionalmente con Docker local (`scripts/prueba-e2e-keycloak.sh`, `EV-C204-023`).

## 7. Sugerencia
Actualizar el `devcontainer.json` del material (opción 3 o `"moby": false`) para los próximos grupos.

*(Verificación: en el Codespace del estudiante la consola de Keycloak —contenedor Docker— responde en el puerto 8080 y el servicio de cifrado en el 3000, EV-C204-005 y EV-C204-006, por lo que Docker está disponible con la configuración corregida. La salida de `docker --version` no se conserva, porque el Codespace fue eliminado; la versión exacta de Docker no consta en la evidencia.)*

## 8. Respuesta de la docente

El 19 de septiembre de 2026 el estudiante remitió el presente reporte a la docente. Según lo comunicado por el estudiante, la docente manifestó que no había experimentado el error y que este podría obedecer a diferencias en el tipo de cuenta de GitHub utilizada. Asimismo, consideró correcto el reporte y aprobó la modificación propuesta al archivo `devcontainer.json`.

La respuesta fue transmitida verbalmente por el estudiante; no se adjunta constancia escrita. La hipótesis relativa al tipo de cuenta no ha sido verificada.

*Observación técnica:* la imagen base `javascript-node:20` corresponde a una etiqueta que se actualiza con el tiempo (anteriormente Debian «bookworm», actualmente «trixie»), por lo que el resultado puede variar según la versión de la imagen obtenida en el momento de crear el Codespace.

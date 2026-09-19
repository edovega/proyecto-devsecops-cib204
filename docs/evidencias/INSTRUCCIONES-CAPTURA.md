# Lo que falta capturar (paso a paso, sin necesidad de programar)

> Esta lista tiene **solo lo que no se pudo hacer desde fuera de su Codespace**. Todo lo demás ya está en el repositorio. Cada captura es una imagen PNG; después de guardarla, avise para que se agregue al informe y al manifiesto.

## Antes de empezar
- Para los puntos 2 y 3 use el Codespace nuevo del punto 1. Para el punto 4 basta el navegador.
- En cada captura debe verse **la fecha y la hora** (por ejemplo, el reloj de su pantalla) y **no debe verse ninguna contraseña real**.

## 1. Conseguir un Codespace que tenga Docker (pasa `docker: command not found`)
Es normal: el Codespace actual no trae Docker (se quitó para evitar el modo de recuperación). Hay una segunda configuración que sí lo trae y **no cambia la actual**:
1. En GitHub, su repositorio → botón verde **Code** → pestaña **Codespaces**.
2. Junto al botón **+** pulse **… → New with options…**.
3. En **Dev container configuration** elija **CIB-204 DevSecOps (Node 20 + Docker)**. Máquina: **2-core**. Pulse **Create codespace**.
4. Cuando abra, en la Terminal escriba `docker --version`. Debe salir una versión. *(Los Codespaces de esta entrega ya fueron eliminados; este paso solo aplica si se vuelve a crear uno.)*
5. **Si ya probó una versión anterior y falló** (mensaje «moby … not supported on debian trixie»): era un error de esa configuración, ya corregido. Borre ese Codespace (github.com/codespaces → … → Delete) y repita desde el paso 1 con el repositorio actualizado.
6. Si el nuevo Codespace entra en «modo de recuperación» (aviso «running in recovery mode»), **deténgalo y bórrelo** (github.com/codespaces → … → Delete), y avise: en ese caso los puntos 2 y 3 se hacen en una computadora con Docker Desktop. Su Codespace original no se afecta.

## 2. EV-C204-002 a 005 — servicio y Keycloak
**Hecho** (capturas del Codespace del equipo).

## 3. EV-C204-006 — la app móvil
**Hecho** (EV-C204-006). Para probar la app **con token**, antes quite la acción «Update Password» del usuario `demo` (Keycloak → Users → demo → campo *Required user actions*).

## 4. EV-C204-014 — proteger la rama `main`
**Hecho el 19-sep-2026** (ruleset `proteger-main`; capturas EV-C204-012, 013 y 014 ya incorporadas al informe).

## 5. EV-C204-013 — captura de la ejecución en verde
**Hecho** (run #27, commit `0fc1c11`).

## 6. Lo que debe confirmar con la docente
- Las **fechas de entrega** (`docs/datos-del-curso.md`, sección 4): hoy dicen «referencia BóvedaSegura» y no están confirmadas.
- Que aceptan **CodeQL por «default setup»** con 5 jobs en el workflow (informe §12.1) en lugar de 6 jobs.

## Reglas de captura
1. Nombre del archivo: el que aparece entre paréntesis en cada paso.
2. No capturar secretos reales.
3. Después de guardar, regenerar el manifiesto: `bash scripts/generar-manifiesto.sh`.

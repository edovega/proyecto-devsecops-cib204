# Lo que falta capturar (paso a paso, sin necesidad de programar)

> Esta lista tiene **solo lo que no se pudo hacer desde fuera de su Codespace**. Todo lo demás ya está en el repositorio. Cada captura es una imagen PNG; después de guardarla, avise para que se agregue al informe y al manifiesto.

## Antes de empezar
- Abra su repositorio en el navegador y presione **Code → Codespaces →** el Codespace que ya existe (si no aparece, «Create codespace on main»).
- En cada captura debe verse **la fecha y la hora** (por ejemplo, el reloj de su pantalla) y **no debe verse ninguna contraseña real**.

## 1. Verificar si Docker existe en el Codespace (30 segundos)
1. En el panel de abajo (**Terminal**) escriba: `docker --version` y pulse Enter.
2. Si sale una versión (por ejemplo `Docker version 27...`), siga al punto 2.
3. Si sale «command not found»: el Codespace actual no trae Docker (se quitó para evitar el modo de recuperación). Avise y se decide entre reactivarlo con otra configuración o hacer los puntos 2 y 3 en su computadora con Docker Desktop.

## 2. EV-C204-002 a 005 — servicio y Keycloak (solo si el punto 1 funcionó)
1. En la Terminal: `docker compose up -d --build` (tarda unos minutos) y luego `docker compose ps`; ambos deben decir *running*.
2. Pestaña **Ports** (abajo): en la fila del puerto **3000** pulse el globo 🌐; agregue `/salud` al final de la dirección. **Captura 1** (`EV-C204-002-salud.png`): debe verse `{"estado":"ok",…}`.
3. En la fila del puerto **8080** pulse el globo 🌐 → **Administration Console** → usuario `admin`, contraseña `admin`.
4. Menú desplegable superior izquierdo → **Create realm** → nombre `appmovil` → **Create**. **Captura 2** (`EV-C204-003-realm.png`).
5. **Clients → Create client** → *Client ID* `servicio-cifrado` → Next → active **Direct access grants** → Save. **Captura 3** (`EV-C204-004-cliente.png`).
6. **Users → Create new user** → *Username* `demo`, email, nombre y apellido, active **Email verified** → Create. Pestaña **Credentials → Set password** (desactive *Temporary*). **Captura 4** (`EV-C204-005-usuario.png`).
7. Para probar el servicio con identidad, en `docker-compose.yml` el control de acceso arranca apagado; se enciende con `AUTH_ENABLED=true`. Puede dejarlo apagado para la captura de la app.

## 3. EV-C204-006 — la app móvil cifrando y descifrando
1. En la Terminal: `bash iniciar-app.sh` (espere a que diga que Expo está en el puerto 8081).
2. Pestaña **Ports**: fila **3000** → clic derecho → *Port Visibility* → **Public**. Fila **8081** → globo 🌐.
3. En la app: pegue la dirección del puerto 3000, escriba un texto corto (**menos de 190 letras**), pulse **Cifrar** y luego **Descifrar**.
   - Si activó `AUTH_ENABLED=true`, necesita pegar un token: solo el valor de `access_token`, **sin** la palabra «Bearer».
4. **Captura** (`EV-C204-006-app.png`): deben verse «Cifrado OK» y «Descifrado OK».

## 4. EV-C204-014 — proteger la rama `main` (lo hace el dueño del repositorio)
1. En GitHub: su repositorio → **Settings → Rules → Rulesets → New ruleset → New branch ruleset**.
2. *Ruleset name*: `proteger-main`. *Enforcement status*: **Active**.
3. *Target branches* → **Add target → Include default branch**.
4. Marque: **Restrict deletions**, **Block force pushes**, **Require status checks to pass** (pulse *Add checks* y agregue: `SAST - Semgrep`, `Secretos - Gitleaks`, `SCA - Dependencias`, `Imagen - Trivy + SBOM`, `DAST - OWASP ZAP`) y **Require a pull request before merging** (deje las aprobaciones en 0 si trabaja solo).
5. **Create**. **Captura** (`EV-C204-014-proteccion.png`) de la pantalla del ruleset ya creado.
   > Con esta regla, los cambios a `main` deben entrar por *pull request*. Si en algún momento necesita subir directo, avísele a quien le ayuda antes de activarla.

## 5. EV-C204-013 — captura de la ejecución en verde (opcional, ya hay transcripción)
1. Pestaña **Actions** → abra la última ejecución de «Pipeline DevSecOps CIB-204».
2. **Captura** (`EV-C204-013-pipeline-verde.png`): deben verse los 5 jobs con ✔ verde.

## 6. Lo que debe confirmar con la docente
- Las **fechas de entrega** (`docs/datos-del-curso.md`, sección 4): hoy dicen «referencia BóvedaSegura» y no están confirmadas.
- Que aceptan **CodeQL por «default setup»** con 5 jobs en el workflow (informe §12.1) en lugar de 6 jobs.

## Reglas de captura
1. Nombre del archivo: el que aparece entre paréntesis en cada paso.
2. No capturar secretos reales.
3. Después de guardar, regenerar el manifiesto: `bash scripts/generar-manifiesto.sh`.

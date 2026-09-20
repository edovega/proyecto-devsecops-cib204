# Plantilla de diagnóstico — CIB-204

> Plantilla oficial de diagnóstico del curso para documentar los resultados del análisis de seguridad.
> Se elabora con los hallazgos de la Fase 1 (Tabla 3) y alimenta el cálculo de riesgo (Tabla 5).

## Datos del diagnóstico

| Campo | Valor |
|---|---|
| Programa analizado | Servicio de cifrado RSA (Node.js) + app móvil (Expo) + Keycloak (IAM) |
| Repositorio | https://github.com/edovega/proyecto-devsecops-cib204 |
| Versión analizada | Commit `46cb634` (código oficial sin remediar), ejecución 35365578175 |
| Herramientas | Semgrep, CodeQL, Gitleaks, npm audit, Trivy, Syft, OWASP ZAP (y revisión manual del código) |
| Fecha del diagnóstico | 18 de septiembre de 2026 (ejecución del pipeline); documentado el 19 de septiembre de 2026 |
| Analista | Eduardo J. Vega Arguedas y Keylor Elizondo Rodriguez |

## Registro de vulnerabilidades

Severidad según la escala de la última sección. «Herramienta» indica quién la confirmó; «Revisión» significa que ninguna herramienta la reportó y se identificó leyendo el código.

| # | Componente | Vulnerabilidad | CWE | Severidad | Consecuencia de explotación |
|---|---|---|---|---|---|
| 1 | `servidor/.env`, `config.js` | Secretos quemados (2 llaves AWS de ejemplo y 2 secretos genéricos) — *Gitleaks* | CWE-798 | Alta | Cualquiera con acceso de lectura al repositorio público obtiene credenciales y puede firmar tokens |
| 2 | `servidor/package.json` | 13 dependencias vulnerables (axios 0.18.0, lodash 4.17.4…; 1 crítica, 8 altas) — *npm audit* | CWE-1104 | Alta | Ejecución de código o contaminación de prototipo mediante CVEs públicos |
| 3 | `servidor/servidor.js` | `eval()` sobre entrada del usuario en `/calcular` — *Semgrep* | CWE-95 | Crítica | Ejecución de código arbitrario en el servidor |
| 4 | `servidor/auth.js` | JWT aceptado sin verificar firma y con `alg: none` — *Semgrep* | CWE-347 / CWE-287 | Crítica | Un atacante fabrica un token y usa el servicio sin identidad |
| 5 | API (CORS) | CORS abierto a cualquier origen — *ZAP* | CWE-942 | Media | Cualquier sitio web puede consumir la API desde el navegador de la víctima |
| 6 | `servidor/servidor.js` | Devuelve `e.stack` al cliente — *Revisión* | CWE-209 | Media | Fuga de rutas internas y versiones que ayudan a un ataque dirigido |
| 7 | `servidor/Dockerfile` | Imagen `node:latest` no reproducible; 640 hallazgos HIGH/CRITICAL — *Trivy* | CWE-1104 | Alta | Explotación de CVEs del sistema base dentro del contenedor |
| 8 | `servidor/Dockerfile` | El contenedor corre como root — *Semgrep* | CWE-250 | Media | Un compromiso del proceso da control total del contenedor |
| 9 | API (cabeceras) | Sin CSP, `Permissions-Policy`; filtra `X-Powered-By` — *ZAP* | CWE-693 | Media | Facilita XSS, clickjacking y reconocimiento del servidor |
| 10 | `servidor/cifrado.js` | RSA de 1024 bits con relleno PKCS#1 v1.5 — *Revisión* | CWE-326 / CWE-780 | Alta | Ataques de oráculo de relleno y factorización: pérdida de confidencialidad |
| 11 | `servidor/db.js` | Inyección SQL por concatenación — *Semgrep* | CWE-89 | Alta | Lectura o modificación de la bitácora y de la base de datos |
| 12 | `servidor/servidor.js` | Inyección de comandos con `exec('ping …' + host)` — *Semgrep* | CWE-78 | Crítica | Ejecución de comandos del sistema operativo |
| 13 | `servidor/Dockerfile` | `COPY . .` incluye `.env` y llaves en la imagen — *Revisión* | CWE-538 | Media | Los secretos viajan dentro de la imagen publicada |
| 14 | `.github/workflows/devsecops.yml` | 16 acciones sin fijar a SHA — *Semgrep* | CWE-1357 / CWE-353 | Media | Cadena de suministro: una etiqueta mutable comprometida ejecuta código ajeno en el pipeline |
| 15 | `servidor/servidor.js` | Sin validación de tipo ni tamaño de entrada — *Revisión* | CWE-20 | Media | Denegación de servicio o errores internos con entradas raras |
| 16 | `servidor/servidor.js` | Sin middleware CSRF — *Semgrep* (**falso positivo**) | CWE-352 | Baja | Ninguna: la API no usa cookies, autentica con Bearer JWT |

## Cálculo probabilístico de riesgo

Probabilidad e impacto en escala 1–3; riesgo = P × I; nivel: Bajo 1–2, Medio 3–4, Alto 6–9. Es el mismo cálculo de la Tabla 5 (que agrupa algunas de estas vulnerabilidades y añade el riesgo residual).

| # | Vulnerabilidad | Probabilidad (1–3) | Impacto (1–3) | Riesgo (P×I) | Nivel | Prioridad |
|---|---|---|---|---|---|---|
| 1 | Secretos quemados | 3 | 3 | 9 | Alto | 1 |
| 2 | Dependencias vulnerables | 3 | 3 | 9 | Alto | 2 |
| 3 | `eval()` | 2 | 3 | 6 | Alto | 4 |
| 4 | JWT sin verificar | 3 | 3 | 9 | Alto | 3 |
| 5 | CORS abierto | 2 | 2 | 4 | Medio | 7 |
| 6 | Errores internos expuestos | 2 | 2 | 4 | Medio | 8 |
| 7 | Imagen con CVEs | 2 | 2 | 4 | Medio | 9 |
| 8 | Contenedor como root | 2 | 2 | 4 | Medio | 10 |
| 9 | Cabeceras ausentes | 2 | 2 | 4 | Medio | 11 |
| 10 | Criptografía débil | 2 | 3 | 6 | Alto | 5 |
| 11 | Inyección SQL | 2 | 2 | 4 | Medio | 12 |
| 12 | Inyección de comandos (`exec`) | 2 | 3 | 6 | Alto | 6 |
| 13 | `COPY . .` con secretos | 2 | 2 | 4 | Medio | 13 |
| 14 | Acciones sin SHA | 2 | 2 | 4 | Medio | 14 |
| 15 | Sin validación de entrada | 2 | 2 | 4 | Medio | 15 |
| 16 | CSRF (falso positivo) | 1 | 1 | 1 | Bajo | 16 |

Prioridad: primero los de riesgo 9 (secretos, dependencias, JWT), después los de 6 (`eval`, criptografía, `exec`) y por último los de 4, en el mismo orden que siguió la Fase 2. El riesgo **después de corregir** está en la Tabla 5 (suma de 73 a 31; ningún riesgo Alto).

## Escala de severidad

| Severidad | Criterio |
|---|---|
| Crítica | Explotable remotamente sin autenticación; compromete datos sensibles o el servicio completo |
| Alta | Explotable con esfuerzo bajo; compromete confidencialidad/integridad/disponibilidad |
| Media | Requiere condiciones especiales o privilegios; impacto limitado |
| Baja | Impacto menor; no compromete datos sensibles |

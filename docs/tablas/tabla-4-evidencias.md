# Tabla 4 — Evidencia antes/después (Fase 2, de rojo a verde)

> Cada fila cita el commit que corrige y la ejecución de GitHub Actions que lo comprobó. Historial completo de ejecuciones: `EV-C204-029-historial-runs.txt`. «Antes» = corrida 35365578175 (`46cb634`, ver Tabla 3). «Después» = corrida verde final **35442482331** (`0fc1c11`, 5/5 jobs en verde y CodeQL con 0 alertas abiertas, EV-C204-026 y EV-C204-025).

## Evidencia antes/después por hallazgo

| Hallazgo (Tabla 3) | Prueba (job) | Antes | Qué se hizo para corregir | Después |
|---|---|---|---|---|
| H-01 Secretos quemados | Secretos | ❌ 4 secretos | `config.js` lee solo de variables de entorno; `.env` fuera de git; `.env.example` sin valores; `.gitignore` (`8b8b86e`) | ✅ Gitleaks 0 (corrida 35381118104) |
| H-02 Dependencias vulnerables | SCA | ❌ 13 (1 critical, 8 high) | Se retiran axios, lodash y express-jwt (sin uso); express 4.22.3, jsonwebtoken 9.0.2 (`8b8b86e`) | ✅ `npm audit`: 0 (corrida 35381118104) |
| H-03 `eval()` / H-13 `exec()` | SAST Semgrep | ❌ | Se eliminan los endpoints `/calcular` y `/diagnostico` (`8b8b86e`) | ✅ (corrida 35389584392) |
| H-04 JWT sin verificar | SAST Semgrep | ❌ `jwt-none-alg` | Primero `jwt.verify` con una sola familia de algoritmos (`8b8b86e`); **después** verificación real contra Keycloak: RS256 + JWKS, `azp`/`aud`, `exp` (`8b9b0b6`, FIX de autenticación) | ✅ Semgrep 0 + 9 pruebas de token + prueba real con Keycloak 24.0 |
| H-05 CORS abierto | DAST ZAP | ❌ Medium | CORS con lista blanca de orígenes (`ORIGENES_PERMITIDOS`) (`8b8b86e`) | ✅ (ZAP 0 High; CORS sin cabecera para orígenes no permitidos, EV-C204-023) |
| H-06 Errores internos | Revisión de código | ⚠️ stack al cliente | Respuesta genérica `{"error":"Error interno"}`; el detalle queda en la bitácora del servidor (`8b8b86e`; bitácora en `a81aa5f`) | ✅ P-05 (EV-C204-023) |
| H-07 Imagen `latest` con CVEs | Imagen Trivy | ❌ 640 (57 crit.) | Base fija `node:20-bookworm-slim` (`8b8b86e`), luego `node:22` (`5a9c481`, no bastó) y por fin **multi-stage `node:24-trixie-slim` + `apt upgrade` + sin npm en runtime** (`f3f9ab4`) | ✅ Trivy 0 con `--ignore-unfixed` (corrida 35390161512); riesgo residual de util-linux documentado (informe §8.5) |
| H-08 Contenedor root | Imagen / Semgrep | ❌ `missing-user` | `USER node` (`8b8b86e`) | ✅ (corrida 35389584392) |
| H-09 Cabeceras ausentes | DAST ZAP | ❌ 2 Medium, 2 Low | Helmet (`8b8b86e`); `Permissions-Policy` manual (`0f5da25`); `X-Powered-By` desaparece con Helmet | ✅ ZAP 0 High, 1 Medium (falso positivo en 404), 0 Low |
| H-10 Cripto débil | Revisión de código | ⚠️ RSA-1024 + PKCS#1 v1.5 | RSA-2048 + OAEP (`8b8b86e`); **OAEP con SHA-256 explícito** (`a81aa5f`) | ✅ 3 pruebas (`oaep.test.js`) |
| H-11 SQL injection | SAST Semgrep | ❌ `node-mysql-sqli` | Consulta parametrizada `?` (`8b8b86e`) | ✅ (corrida 35389584392) |
| H-12 `COPY . .` | Revisión de Dockerfile | ⚠️ | Copia selectiva de archivos; `.dockerignore` (`8b8b86e`, `8b9b0b6`) | ✅ |
| H-14 Acciones con etiqueta mutable | SAST Semgrep | ❌ 16 | Acciones fijadas a SHA completo (`cc759ad`) | ✅ (corrida 35389584392) |
| H-15 CSRF (falso positivo) | SAST Semgrep | ❌ 1 | `nosemgrep` en la misma línea, con justificación (`cc759ad`, `657ac2f`) | ✅ 1 suprimido en el código, 0 activos |
| H-16 Sin validación | Revisión de código | ⚠️ | Validación de tipo y longitud; cuerpo máx. 10 KB (`8b8b86e`); límite en **bytes** igual a la capacidad de RSA-OAEP, 190 (`0fc1c11`) | ✅ P-06, P-07, P-07b, P-07c, P-08 |
| *(nuevo)* Sin límite de peticiones | SAST CodeQL | ❌ 3 alertas *high* `js/missing-rate-limiting` | `express-rate-limit`: 100 peticiones/min por IP → 429 (`500b39c`) | ✅ CodeQL: 0 abiertas, 3 «fixed» (EV-C204-025) |

## Registro de commits de remediación (trazabilidad)

| Commit | Mensaje (resumen) | Corrige | Resultado en Actions |
|---|---|---|---|
| `46cb634` | devcontainer sin docker-in-docker | *(base de la Fase 1)* | ❌ corrida 35365578175 (Fase 1) |
| `8b8b86e` | Remediación del servidor: 13 hallazgos SAST | H-01…H-13, H-16 | Gitleaks ✅ SCA ✅; Imagen/ZAP ❌ (ver siguiente) |
| `e267ad5` | Quita `COPY public` (error introducido al remediar) | Build de la imagen | ZAP ✅; Imagen ❌ (CVEs) |
| `5a9c481` | Base `node:22-bookworm-slim` | H-07 (intento) | ❌ no cerró los CVEs de util-linux |
| `cc759ad` | Acciones a SHA completo + `nosemgrep` CSRF | H-14, H-15 | Semgrep ✅ (corrida 35389584392) |
| `f3f9ab4` | Multi-stage `node:24-trixie-slim`, quita CodeQL avanzado | H-07 | **5/5 ✅ (corrida 35390161512)** |
| `0f5da25` | `Permissions-Policy` | H-09 (Low de ZAP) | Semgrep ❌ (escaneaba `docs/`); resto ✅ |
| `657ac2f` | Semgrep excluye `docs/`; `nosemgrep` inline | H-15 | **5/5 ✅ (corrida 35405835472)** |
| `8b9b0b6` | Autenticación RS256 + JWKS de Keycloak; `.dockerignore` | H-04 (real con Keycloak), H-12 | ❌ Semgrep (`jwt-hardcode` en la prueba) |
| `c27d28d` | Secreto aleatorio en la prueba HS256 | *(corrección de mi propia prueba)* | ✅ 5/5 (corrida 35441709157); CodeQL: 3 alertas |
| `500b39c` | Límite de peticiones por IP | Alertas CodeQL | ✅ 5/5 (corrida 35441885522); CodeQL 0 |
| `a81aa5f` | OAEP-SHA256 y bitácora de operaciones | H-10, H-06, no repudio | ✅ 5/5 (corrida 35442133748); CodeQL 0 |
| `0fc1c11` | Límite de entrada = capacidad real de RSA-OAEP (190 bytes) | H-16 (defecto hallado en las pruebas de borde) | **✅ 5/5 (corrida 35442482331); CodeQL 0** |

> Cada corrección constituye un commit independiente, con mensaje descriptivo y la ejecución que lo verifica, conforme a la rúbrica («Pruebas y ajustes de código»). Los commits `e267ad5`, `5a9c481`, `0f5da25` y `8b9b0b6` corresponden a ajustes intermedios dentro del ciclo *encontrar → corregir → volver a probar*.

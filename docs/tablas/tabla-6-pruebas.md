# Tabla 6 — Documentación de pruebas

> **Estado: COMPLETA con resultados reales**, la versión de Docker del Codespace no consta en la evidencia. Las pruebas funcionales se ejecutaron contra un **Keycloak 24.0 real** (contenedor Docker local, no el del Codespace) y el servicio del commit `0fc1c11`. Reproducible con `bash scripts/prueba-e2e-keycloak.sh`. Evidencia: `EV-C204-023-pruebas-e2e-keycloak.txt` (25 comprobaciones, 25 pasan) y `EV-C204-024-pruebas-unitarias.txt` (22 pruebas Jest, ESLint sin advertencias, `npm audit` 0).

## Pruebas funcionales del servicio

| ID | Prueba | Datos de entrada | Resultado esperado | Resultado real | Estado |
|---|---|---|---|---|---|
| P-01 | Cifrar texto | `"Hola mundo"` | Texto cifrado (base64) | 200; base64 de 344 caracteres (`E/GIi+WZ…`) | ✅ |
| P-02 | Descifrar texto | Texto cifrado de P-01 | `"Hola mundo"` | 200; `{"descifrado":"Hola mundo"}` | ✅ |
| P-03 | Cifrar con token válido | Token RS256 real de Keycloak (usuario `demo`) | 200 OK | 200 | ✅ |
| P-04 | Cifrar sin token | Sin cabecera `Authorization` | 401 No autorizado | 401 | ✅ |
| P-05 | Descifrar dato manipulado | Texto cifrado con 1 carácter alterado | Error controlado | 500 con `{"error":"Error interno"}` (sin pila ni detalle) | ✅ |
| P-06 | Entrada vacía | `""` | Error de validación | 400 | ✅ |
| P-07 | Entrada muy larga | 20 KB (el límite del cuerpo es 10 KB) | Rechazada por límite | 413 | ✅ |
| P-07b | Borde del máximo de RSA | 190 bytes | Se cifra | 200 | ✅ |
| P-07c | Justo sobre el máximo | 191 bytes | Rechazo controlado | 400 (antes de FIX-22 daba 500) | ✅ |
| P-08 | Entrada no texto | `12345` (número) | Error de tipo | 400 | ✅ |
| P-09 | `/salud` | — | `{"estado":"ok"}` | 200; `{"estado":"ok","version":"remediado-2.0"}` | ✅ |
| P-10 | Descifrar con token expirado | Token de Keycloak con vida de 5 s, usado tras 12 s (tolerancia de reloj: 5 s) | 401 | 401 | ✅ |
| P-10b | Token de otro cliente | Token válido del cliente `otra-app` (mismo realm) | 401 | 401 | ✅ |
| P-25 | Ida y vuelta con UTF-8 | `Ñandú 你好 😀` + salto de línea | Texto idéntico | 200 / 200; texto recuperado idéntico | ✅ |

## Pruebas del pipeline (GitHub Actions)

| ID | Job | Resultado Fase 1 (run 35365578175) | Resultado Fase 2 (run 35442482331) | Evidencia |
|---|---|---|---|---|
| P-11 | SAST – Semgrep | ❌ 23 hallazgos | ✅ 0 activos (1 falso positivo suprimido en el código) | EV-C204-021 / EV-C204-008 |
| P-12 | SAST – CodeQL | job avanzado ❌ por configuración | ✅ default setup: 0 alertas abiertas (3 de *rate limiting* corregidas) | EV-C204-025 |
| P-13 | Secretos – Gitleaks | ❌ 4 secretos | ✅ 0 | EV-C204-020 / EV-C204-009 |
| P-14 | SCA – Dependencias | ❌ 13 vulnerabilidades | ✅ 0 | EV-C204-028 / EV-C204-024 |
| P-15 | Imagen – Trivy + SBOM | ❌ 640 hallazgos | ✅ 0 (`--ignore-unfixed`; residual util-linux) | EV-C204-027 / EV-C204-010 |
| P-16 | DAST – OWASP ZAP | informe: 2 Medium, 2 Low | informe: 0 High, 1 Medium (falso positivo), 0 Low | EV-C204-022 / EV-C204-011 |

## Pruebas de pentest (manual)

| ID | Prueba | Técnica | Resultado esperado | Resultado real | Hallazgo |
|---|---|---|---|---|---|
| P-17 | Manipulación de texto cifrado | Alterar 1 carácter | Error controlado | 500 genérico, servicio sigue vivo (P-23) | Ninguno |
| P-18 | Token inválido | Firma de otra llave RS256; HS256; `alg:none`; token real con la firma alterada; `kid` desconocido; basura | 401 | 401 en los 6 casos (4 en EV-C204-023; `kid` y basura en las pruebas Jest) | Ninguno |
| P-19 | Cabeceras de seguridad | `curl -I /salud` | Cabeceras presentes | CSP, `X-Frame-Options`, `X-Content-Type-Options`, HSTS, `Referrer-Policy`, `Cross-Origin-Opener-Policy`, `Permissions-Policy` presentes; sin `X-Powered-By` | Ninguno |
| P-20 | CORS | Origen no permitido (`http://malo.example`) | Sin cabecera CORS | 0 cabeceras `Access-Control-Allow-Origin`; el origen permitido sí la recibe | Ninguno |
| P-21 | Fuerza bruta / abuso | 130 peticiones seguidas | Rate limiting o 401 | 76 × 200 y 54 × 429 (límite 100/min; contando peticiones previas) | Corregido (FIX-19) |
| P-23 | Disponibilidad tras entradas malformadas | JSON roto `{{{{` | `/salud` sigue respondiendo | 200 | Ninguno |
| P-24 | No repudio | Operación de cifrado | Queda registrada sin datos sensibles | Línea JSON con `ts`, `accion`, `resultado`, `usuario`, `ip`; el texto plano no aparece | Corregido (FIX-21) |
| P-26 | Confusión de algoritmo / capacidad RSA | Texto de 191 bytes | Rechazo controlado | 400 | **Encontrado y corregido** (FIX-22): antes 500 |

## Pruebas automatizadas del servicio (`npm test`)

| ID | Suite | Casos | Resultado |
|---|---|---|---|
| P-22 | `cifrado.test.js` | 3 (round-trip, PEM, texto distinto del original) | ✅ 3 pasan |
| P-22b | `integracion.test.js` | 6 (`/salud`, `/llave`, ciclo completo, bitácora, borde 190/191, bytes UTF-8) | ✅ 6 pasan |
| P-22c | `auth.test.js` | 9 (sin token, válido, expirado, firma ajena, HS256, `alg:none`, otro cliente, `kid` desconocido, basura) | ✅ 9 pasan |
| P-22d | `oaep.test.js` | 3 (OAEP-SHA256, no SHA-1, llave 2048 bits) | ✅ 3 pasan |
| P-22e | `limite.test.js` | 1 (429 al superar el límite) | ✅ 1 pasa |
| | **Total** | **22 (la guía pedía 6: `Tests: 6 passed`)** | **✅ `Tests: 22 passed`** |

## Ajustes de pruebas realizados

Estos son los ajustes que **se hicieron y verificaron** para cubrir más casos de uso (criterio «Pruebas y ajustes de código» de la rúbrica):

1. **P-10 ampliada:** no solo token expirado, sino también firma inválida, HS256, `alg:none`, `kid` desconocido, token de otro cliente y token expirado **de Keycloak real** (con vida de 5 s).
2. **P-07 ampliada con el borde real:** 190 bytes (pasa) y 191 bytes (rechazo). Al hacerlo se **descubrió un defecto**: textos de más de 190 bytes producían 500; se corrigió (FIX-22) y se probó también contando bytes UTF-8 (emojis de 4 bytes).
3. **P-23 agregada:** disponibilidad tras JSON malformado.
4. **P-24 agregada:** no repudio (bitácora sin texto plano).
5. **P-25 agregada:** ida y vuelta con UTF-8, emoji y salto de línea.
6. **Corrección de una prueba defectuosa:** la primera versión de «token con la firma alterada» cambiaba el **último** carácter de la firma y a veces daba 200; en base64 los últimos bits del último carácter no cambian los bytes. Se cambió a alterar un carácter central y se repitió 3 veces seguidas (23/23 cada vez).
7. **Sensibilidad al reloj:** la primera prueba de expiración esperó 8 s con tokens de 5 s y aceptó el token, porque el servicio tolera 5 s de desfase de reloj. No era un fallo del servicio: se ajustó la espera a 12 s.

## Pruebas ejecutadas por el equipo en el Codespace

| ID | Prueba | Datos de entrada | Resultado esperado | Resultado real | Estado |
|---|---|---|---|---|---|
| P-27 | Cifrar/descifrar desde la **app móvil** (Expo) en el Codespace | Texto «Hola CIB-204», URL pública del puerto 3000, sin token (`AUTH_ENABLED=false`) | Cifrado y descifrado correctos | «Descifrado OK»: la app mostró el cifrado en base64 y recuperó «Hola CIB-204» (EV-C204-006) | ✅ |
| P-28 | Keycloak en el **Codespace** (consola web) | Usuario `demo` en el realm `appmovil` | Usuario creado y habilitado | Realm `appmovil`, cliente `servicio-cifrado` y usuario `demo` habilitado con email verificado, todos en la consola del Codespace (EV-C204-003, 004 y 005) | ✅ |

> **Observación sobre EV-C204-005:** el usuario aparece con la acción requerida «**Update Password**». Con esa acción pendiente, `demo` **no puede obtener un token** por contraseña directa (Keycloak exige cambiar la clave primero). La prueba de la app (P-27) no lo necesita porque se hizo con el acceso apagado. Para probar la app **con token** hay que quitar esa acción del usuario (campo «Required user actions») o crear la contraseña con «Temporary» desactivado.

## Nota de trazabilidad

Esta tabla alimenta: informe §17, la plantilla de diagnóstico y la verificación de los requisitos de la Tabla 1 (cada requisito tiene su prueba aquí).

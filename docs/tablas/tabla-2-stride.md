# Tabla 2 — Amenazas STRIDE

> 📄 **Tabla a llenar** — Primer Avance. Modelado de amenazas con STRIDE (Microsoft): por cada amenaza, qué componente afecta, un ejemplo de ataque y cómo se frena.

## Amenazas STRIDE

| Amenaza (STRIDE) | Componente afectado | Ejemplo de ataque | Control / mitigación |
|---|---|---|---|
| Spoofing (suplantar) | API de cifrado (`servidor.js`, `auth.js`) | Usar el servicio sin identidad, o con un token falso/robado | Token JWT válido emitido por Keycloak y verificado (firma, expiración, emisor) en `auth.js` |
| Tampering (manipular) | Datos en tránsito (texto cifrado) | Alterar el texto cifrado entre la app y el servicio | Descifrado que falla de forma segura (OAEP detecta manipulación; error controlado) |
| Repudiation (negar) | Servicio (`db.js`) | Negar que se hizo una operación de cifrado/descifrado | Bitácora y logs con registro de operaciones (quién, qué, cuándo) |
| Information disclosure | Servicio / repo | Leer secretos en el repo (`.env`, llaves) o errores internos (stack traces) | Sin secretos en el repo (variables de entorno); errores genéricos sin detalles internos (CWE-209) |
| Denial of service | API de cifrado | Enviar datos enormes o malformados para agotar recursos o tumbar el proceso | Límite de tamaño de la entrada + validación de tipo antes de procesar |
| Elevation of privilege | Contenedor (`Dockerfile`) | Ejecutar el servicio como root y escalar dentro del contenedor/host | Contenedor sin privilegios (usuario no-root) en la imagen |

## Severidad estimada por amenaza

| Amenaza | Severidad | Justificación |
|---|---|---|
| Spoofing | **Alta** | Sin autenticación, cualquiera usa el servicio (abuso, oráculo de descifrado). El control depende de `auth.js`, que en la versión insegura casi no valida el token |
| Tampering | **Alta** | La integridad es una propiedad central del cifrado; si no se detecta manipulación, el sistema no cumple su función |
| Repudiation | **Media** | Impacto de auditoría: sin bitácora no hay evidencia de abusos, pero no compromete datos directamente |
| Information disclosure | **Alta** | Secretos en un repo **público** son legibles por cualquiera; errores internos facilitan ataques dirigidos |
| Denial of service | **Media** | Impacto de disponibilidad; requiere esfuerzo del atacante pero el control (validación) es simple |
| Elevation of privilege | **Media** | El contenedor está aislado, pero root en el contenedor amplía la superficie si hay otra vulnerabilidad |

## Cómo se verifica cada control (prueba concreta)

| Amenaza | Prueba que demuestra el control | Resultado esperado |
|---|---|---|
| Spoofing | Pedir `/cifrar` sin token | 401 No autorizado |
| Spoofing | Pedir `/cifrar` con token válido (usuario `demo` de Keycloak) | 200 OK, cifrado correcto |
| Spoofing | Pedir `/cifrar` con token expirado o de firma inválida | 401 No autorizado |
| Tampering | Modificar 1 byte del texto cifrado y pedir `/descifrar` | Error controlado (400/500 genérico), sin texto corrupto |
| Repudiation | Realizar una operación y consultar la bitácora | Registro presente con operación, usuario y timestamp |
| Information disclosure | Enviar entrada inválida (ej. `{}` sin campo texto) | Respuesta genérica, **sin** stack trace ni rutas internas |
| Information disclosure | Escanear el repo con Gitleaks (job `secretos`) | 0 hallazgos (verde) |
| Denial of service | Enviar payload de 100 MB a `/cifrar` | Rechazado por límite de tamaño (413/400), servicio sigue respondiendo `/salud` |
| Elevation of privilege | `docker inspect` del contenedor / `whoami` en el contenedor | Usuario no-root (no `root`) |

## Mapeo a CWE (para cruzar con la Tabla 3)

| Amenaza | CWE asociada | Hallazgo esperado en Fase 1 |
|---|---|---|
| Spoofing | CWE-287 (Autenticación incorrecta) | JWT mal validado en `auth.js` |
| Tampering | CWE-353 (Falta de verificación de integridad) | Descifrado sin verificación de padding |
| Repudiation | CWE-778 (Registro insuficiente) | Bitácora ausente o incompleta |
| Information disclosure | CWE-798 (Secretos embebidos), CWE-209 (Exposición de información) | `.env` con secretos; errores con detalles |
| Denial of service | CWE-400 (Consumo de recursos) | Sin límite de tamaño de entrada |
| Elevation of privilege | CWE-250 (Ejecución con privilegios innecesarios) | Dockerfile con usuario root |

## Nota de trazabilidad

Esta tabla alimenta: informe §6, Tabla 3 (los hallazgos de Fase 1 se clasifican por amenaza/CWE), Tabla 5 (riesgo — la severidad aquí se cuantifica con P×I) y Tabla 6 (las pruebas de verificación de esta tabla se ejecutan y documentan).
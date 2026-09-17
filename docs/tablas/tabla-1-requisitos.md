# Tabla 1 — Requisitos de seguridad

> 📄 **Tabla a llenar** — Primer Avance. Define qué debe proteger el sistema antes de tocar código.
> Marco de referencia: OWASP SAMM, NIST SSDF, OWASP ASVS y OWASP MASVS.

## Requisitos de seguridad

| Propiedad | Requisito (qué debe cumplir) | Control que lo implementa | Cómo se verifica |
|---|---|---|---|
| Confidencialidad | Los datos se cifran antes de viajar entre la app y el servicio | Cifrado RSA-2048 con padding OAEP-SHA256 en `cifrado.js` | Prueba de cifrar/descifrar (roundtrip); DAST (ZAP) confirma que no hay fuga por errores |
| Integridad | Un dato alterado no se descifra; el descifrado falla de forma segura | OAEP detecta manipulación; el descifrado lanza error controlado sin exponer detalles | Prueba de dato manipulado (pentest): modificar 1 byte del texto cifrado → error genérico |
| Disponibilidad | El servicio no se cae con entradas raras (vacías, enormes, no texto) | Validación de tipo y tamaño de la entrada en la API (límite de payload) | Pruebas de entrada vacía, muy larga (100 MB) y no texto → rechazo controlado, servicio sigue vivo |
| Autenticación | Solo usuarios válidos usan el servicio | Token JWT emitido por Keycloak y verificado en `auth.js` (firma, expiración, emisor) | Pedir `/cifrar` sin token → 401; con token válido (usuario `demo`) → 200 |
| No repudio *(extra, para exceder)* | Toda operación de cifrado/descifrado queda registrada | Bitácora en `db.js` con registro de operaciones | Consultar la bitácora tras una operación y verificar el registro |

## Justificación de cada requisito (por qué)

**Confidencialidad.** La app móvil y el servicio se comunican por una red no confiable (Internet). Si los datos viajaran en texto plano, cualquier interceptor (sniffer, proxy, red Wi-Fi comprometida) podría leer el contenido. El cifrado RSA con OAEP garantiza que solo el poseedor de la llave privada pueda recuperar el texto original. Se eligió RSA-OAEP (no RSA sin padding ni PKCS#1 v1.5) porque OAEP incorpora aleatoriedad y detección de manipulación, mitigando ataques de padding (Bleichenbacher).

**Integridad.** Un atacante puede interceptar y modificar el texto cifrado en tránsito. Si el descifrado no detectara la alteración, el receptor obtendría un mensaje corrupto sin saberlo (o peor, un mensaje manipulado válido). OAEP incluye verificación de integridad: si el padding no es válido, el descifrado falla de forma segura. El requisito exige que ese fallo sea **controlado** (error genérico, sin detalles internos) para no filtrar información al atacante (CWE-209).

**Disponibilidad.** Una API pública sin validación de entrada es vulnerable a DoS trivial: un payload de cientos de MB agota memoria/CPU, o una entrada malformada provoca una excepción no controlada que tumba el proceso. El requisito exige validar tipo y tamaño **antes** de procesar, y que los errores se manejen sin terminar el servicio.

**Autenticación.** El servicio de cifrado es un recurso valioso: sin control de acceso, cualquiera podría usarlo para cifrar/descifrar (abuso del servicio, consumo de recursos, o uso como oráculo de descifrado). Keycloak centraliza la identidad: emite tokens JWT firmados; el servicio solo acepta tokens válidos (firma verificada, no expirados, emisor correcto).

**No repudio (extra).** Para operaciones sensibles, debe quedar evidencia de quién hizo qué y cuándo. La bitácora permite auditoría y detección de abusos. Se documenta como requisito adicional para exceder el alcance mínimo (CIA + autenticación).

## Mapeo con estándares

| Requisito | OWASP SAMM | NIST SSDF | OWASP ASVS | OWASP MASVS |
|---|---|---|---|---|
| Confidencialidad | EG2 (Estrategia de seguridad) / SA-2 (Diseño seguro) | PW.6.1 (protección de datos) | V6 (Criptografía almacenada) / V9 (Comunicaciones) | MASVS-CRYPTO-1 (cifrado de datos) |
| Integridad | SA-2 (Diseño seguro) | PW.6.1 / PW.7.1 (verificación de integridad) | V6.2 (integridad criptográfica) | MASVS-CRYPTO-2 (integridad) |
| Disponibilidad | SM-2 (Gestión de riesgos) | PW.4.1 (validación de entrada) | V5 (Validación de entrada) | MASVS-PLATFORM-2 (recursos) |
| Autenticación | EG-2 / SA-3 (Gestión de terceros) | PW.5.1 (autenticación) | V2 (Autenticación) | MASVS-AUTH-1 (autenticación) |
| No repudio | SM-3 (Operaciones) | RV.1.3 (registro de eventos) | V7 (Manejo de errores y logging) | MASVS-PRIVACY-2 (registro) |

## Verificación cruzada con ASVS (nivel 1 — aplicable al laboratorio)

| Requisito ASVS | Descripción | Cómo se cumple |
|---|---|---|
| 2.1.1 | Autenticación con mecanismo verificable | JWT de Keycloak verificado en `auth.js` |
| 5.1.3 | Validación de entrada en el servidor | Validación de tipo/tamaño en la API |
| 6.2.1 | Cifrado con algoritmo seguro y modo apropiado | RSA-2048 OAEP-SHA256 |
| 7.1.1 | Respuestas de error sin detalles internos | Errores genéricos (sin stack traces) |
| 9.1.2 | TLS en comunicaciones | HTTPS del Codespace / TLS en producción |
| 12.3.1 | Cabeceras de seguridad HTTP | CSP, X-Frame-Options, etc. (corregido en Fase 2) |

## Nota de trazabilidad

Esta tabla alimenta: informe §5, Tabla 2 (STRIDE — los controles responden a las amenazas), Tabla 5 (riesgo — los requisitos priorizan las mitigaciones) y Tabla 6 (pruebas — cada requisito tiene su prueba de verificación).
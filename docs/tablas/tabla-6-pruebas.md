# Tabla 6 — Documentación de pruebas

> 📄 **Tabla a llenar** — Segundo Avance. Documenta TODAS las pruebas realizadas y los resultados obtenidos: descripción, datos de entrada, resultado esperado y resultado real.

## Pruebas funcionales del servicio

| ID | Prueba | Datos de entrada | Resultado esperado | Resultado real | Estado |
|---|---|---|---|---|---|
| P-01 | Cifrar texto | `"Hola mundo"` | Texto cifrado (base64) | *(completar)* | ✅/❌ |
| P-02 | Descifrar texto | Texto cifrado de P-01 | `"Hola mundo"` | *(completar)* | ✅/❌ |
| P-03 | Cifrar con token válido | Token de Keycloak (demo) | 200 OK | *(completar)* | ✅/❌ |
| P-04 | Cifrar sin token | Sin token | 401 No autorizado | *(completar)* | ✅/❌ |
| P-05 | Descifrar dato manipulado | Texto cifrado + 1 byte alterado | Error controlado | *(completar)* | ✅/❌ |
| P-06 | Entrada vacía | `""` | Error de validación | *(completar)* | ✅/❌ |
| P-07 | Entrada muy larga | 100 MB | Rechazada por límite | *(completar)* | ✅/❌ |
| P-08 | Entrada no texto | `12345` (número) | Error de tipo | *(completar)* | ✅/❌ |
| P-09 | `/salud` | — | `{"estado":"ok"}` | *(completar)* | ✅/❌ |
| P-10 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | ✅/❌ |

## Pruebas del pipeline (GitHub Actions)

| ID | Job | Resultado Fase 1 | Resultado Fase 2 | Evidencia |
|---|---|---|---|---|
| P-11 | sast_semgrep | ❌ rojo | ✅ verde | captura + reporte |
| P-12 | sast_codeql | alertas | alertas revisadas | captura Code scanning |
| P-13 | secretos | ❌ rojo | ✅ verde | captura + reporte |
| P-14 | sca | ❌ rojo | ✅ verde | captura + SBOM |
| P-15 | imagen | ❌ rojo | ✅ verde | captura + SBOM |
| P-16 | dast | informe | informe sin hallazgos críticos | reporte-zap |

## Pruebas de pentest (manual)

| ID | Prueba | Técnica | Resultado | Hallazgo |
|---|---|---|---|---|
| P-17 | Manipulación de texto cifrado | Modificar bytes | *(completar)* | *(completar)* |
| P-18 | Fuerza bruta de token | Enviar tokens inválidos | *(completar)* | *(completar)* |
| P-19 | Cabeceras de seguridad | ZAP / curl -I | *(completar)* | *(completar)* |
| P-20 | CORS | Origen no permitido | *(completar)* | *(completar)* |
| P-21 | *(completar)* | *(completar)* | *(completar)* | *(completar)* |

## Pruebas automatizadas del servicio (npm test)

| ID | Suite | Casos | Resultado |
|---|---|---|---|
| P-22 | *(completar)* | *(completar)* | ✅ 6 passed |

## Ajustes de pruebas realizados

*(Documenta los ajustes que hiciste en los escenarios de prueba para cubrir más casos de uso — criterio "Pruebas y ajustes de código" de la rúbrica.)*
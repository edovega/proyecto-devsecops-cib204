# Tabla 6 — Documentación de pruebas

> 📄 **Tabla a llenar** — Segundo Avance. Documenta TODAS las pruebas realizadas y los resultados obtenidos: descripción, datos de entrada, resultado esperado y resultado real.
>
> ⚠️ **Estado: PRELIMINAR.** Los casos de prueba están definidos según la guía; la columna "Resultado real" se completa al ejecutar (requiere el zip oficial).

## Pruebas funcionales del servicio

| ID | Prueba | Datos de entrada | Resultado esperado | Resultado real | Estado |
|---|---|---|---|---|---|
| P-01 | Cifrar texto | `"Hola mundo"` | Texto cifrado (base64) | ⏳ pendiente | ⏳ |
| P-02 | Descifrar texto | Texto cifrado de P-01 | `"Hola mundo"` | ⏳ pendiente | ⏳ |
| P-03 | Cifrar con token válido | Token de Keycloak (demo) | 200 OK | ⏳ pendiente | ⏳ |
| P-04 | Cifrar sin token | Sin token | 401 No autorizado | ⏳ pendiente | ⏳ |
| P-05 | Descifrar dato manipulado | Texto cifrado + 1 byte alterado | Error controlado | ⏳ pendiente | ⏳ |
| P-06 | Entrada vacía | `""` | Error de validación | ⏳ pendiente | ⏳ |
| P-07 | Entrada muy larga | 100 MB | Rechazada por límite | ⏳ pendiente | ⏳ |
| P-08 | Entrada no texto | `12345` (número) | Error de tipo | ⏳ pendiente | ⏳ |
| P-09 | `/salud` | — | `{"estado":"ok"}` | ⏳ pendiente | ⏳ |
| P-10 | Descifrar con token expirado | Token expirado | 401 No autorizado | ⏳ pendiente | ⏳ |

## Pruebas del pipeline (GitHub Actions)

| ID | Job | Resultado Fase 1 | Resultado Fase 2 | Evidencia |
|---|---|---|---|---|
| P-11 | sast_semgrep | ❌ rojo (esperado) | ✅ verde | captura + reporte |
| P-12 | sast_codeql | alertas (esperado) | alertas revisadas | captura Code scanning |
| P-13 | secretos | ❌ rojo (esperado) | ✅ verde | captura + reporte |
| P-14 | sca | ❌ rojo (esperado) | ✅ verde | captura + SBOM |
| P-15 | imagen | ❌ rojo (esperado) | ✅ verde | captura + SBOM |
| P-16 | dast | informe (esperado) | informe sin hallazgos críticos | reporte-zap |

## Pruebas de pentest (manual)

| ID | Prueba | Técnica | Resultado esperado | Resultado real | Hallazgo |
|---|---|---|---|---|---|
| P-17 | Manipulación de texto cifrado | Modificar 1 byte | Error controlado | ⏳ pendiente | ⏳ |
| P-18 | Token inválido / expirado | Enviar tokens falsos | 401 | ⏳ pendiente | ⏳ |
| P-19 | Cabeceras de seguridad | ZAP / `curl -I` | Cabeceras presentes (Fase 2) | ⏳ pendiente | ⏳ |
| P-20 | CORS | Origen no permitido | Sin cabecera CORS (Fase 2) | ⏳ pendiente | ⏳ |
| P-21 | Fuerza bruta de token | Muchos intentos | Rate limiting o 401 | ⏳ pendiente | ⏳ |

## Pruebas automatizadas del servicio (npm test)

| ID | Suite | Casos | Resultado |
|---|---|---|---|
| P-22 | Pruebas del servicio | 6 pruebas (según guía) | ⏳ pendiente — esperado: `Tests: 6 passed` |

## Ajustes de pruebas realizados

*(Se documenta aquí qué ajustes se hicieron a los escenarios de prueba para cubrir más casos de uso — criterio "Pruebas y ajustes de código" de la rúbrica.)*

**Ajustes planificados (para exceder):**
1. **Ampliar P-05:** probar manipulación en diferentes posiciones del texto cifrado (inicio, medio, final) — no solo 1 byte.
2. **Ampliar P-07:** probar tamaños límite (justo bajo el límite, justo sobre el límite) para verificar el comportamiento en el borde.
3. **Ampliar P-10:** probar token con firma inválida, emisor incorrecto y audiencia incorrecta (no solo expirado).
4. **Agregar P-23:** prueba de disponibilidad — tras enviar entradas malformadas, verificar que `/salud` sigue respondiendo.
5. **Agregar P-24:** prueba de no repudio — tras una operación, verificar el registro en la bitácora.
6. **Agregar P-25:** prueba de roundtrip con caracteres especiales (UTF-8, emojis, saltos de línea).

## Nota de trazabilidad

Esta tabla alimenta: informe §17, la plantilla de diagnóstico y la verificación de los requisitos de la Tabla 1 (cada requisito tiene su prueba aquí).
# Tabla 5 — Cálculo de riesgo

> 📄 **Tabla a llenar** — Segundo Avance. Cálculos probabilísticos de los riesgos asociados a las vulnerabilidades identificadas (probabilidad de ocurrencia × impacto potencial).
>
> ⚠️ **Estado: PRELIMINAR.** Los valores P/I son estimaciones basadas en los hallazgos esperados (Tabla 3). Se **recalculan y confirman** con los reportes reales del pipeline en Fase 1.

## Metodología

Riesgo = **Probabilidad** × **Impacto**, con escala documentada:

| Nivel | Probabilidad (P) | Impacto (I) |
|---|---|---|
| Bajo (1) | Poco probable (requiere condiciones especiales) | Impacto menor, sin datos sensibles |
| Medio (2) | Posible (requiere algún esfuerzo) | Impacto moderado, datos parciales |
| Alto (3) | Probable (bajo esfuerzo, herramientas comunes) | Impacto grave, datos sensibles o servicio caído |

**Nivel de riesgo:** Bajo (1–2) · Medio (3–4) · Alto (6–9)

## Registro de riesgos

| ID | Vulnerabilidad (de Tabla 3) | Probabilidad (1–3) | Impacto (1–3) | Riesgo (P×I) | Nivel | Prioridad de mitigación |
|---|---|---|---|---|---|---|
| R-01 | Secretos quemados (H-01) | 3 | 3 | 9 | Alto | 1 |
| R-02 | Dependencias vulnerables (H-02) | 3 | 3 | 9 | Alto | 2 |
| R-03 | `eval()` / inyección (H-03) | 2 | 3 | 6 | Alto | 3 |
| R-04 | JWT mal validado (H-04) | 3 | 3 | 9 | Alto | 4 |
| R-05 | CORS abierto (H-05) | 2 | 2 | 4 | Medio | 5 |
| R-06 | Errores internos expuestos (H-06) | 2 | 2 | 4 | Medio | 6 |
| R-07 | Imagen con vulnerabilidades (H-07) | 2 | 2 | 4 | Medio | 7 |
| R-08 | Contenedor como root (H-08) | 2 | 2 | 4 | Medio | 8 |
| R-09 | Cabeceras ausentes (H-09) | 2 | 2 | 4 | Medio | 9 |
| R-10 | Criptografía insegura (H-10) | 2 | 3 | 6 | Alto | 10 |
| R-11 | Consulta insegura / inyección (H-11) | 2 | 2 | 4 | Medio | 11 |
| R-12 | CVEs en imagen (H-12) | 2 | 2 | 4 | Medio | 12 |

## Análisis gerencial complementario (para exceder)

### Pérdida anual esperada (ALE)

ALE = SLE × ARO, donde SLE = AV × EF (valor del activo × factor de exposición) y ARO = tasa anual de ocurrencia.

| Activo | Valor (AV) | Factor de exposición (EF) | SLE | ARO | ALE |
|---|---|---|---|---|---|
| Datos cifrados por el servicio | $10,000 | 0.5 | $5,000 | 2 | $10,000 |
| Llaves RSA del servicio | $20,000 | 0.3 | $6,000 | 1 | $6,000 |
| Credenciales de usuarios (Keycloak) | $15,000 | 0.4 | $6,000 | 1 | $6,000 |
| Disponibilidad del servicio | $8,000 | 0.5 | $4,000 | 3 | $12,000 |
| **Total ALE** | | | | | **$34,000** |

> *(Valores ilustrativos para el laboratorio académico; se ajustan con datos reales del contexto si el docente lo solicita.)*

### Justificación de probabilidades

**R-01 (secretos):** P=3 — el repo es público al finalizar y Gitleaks detecta el patrón automáticamente; cualquier persona puede leer los secretos sin esfuerzo. Impacto 3: compromete credenciales y llaves.

**R-02 (dependencias):** P=3 — las herramientas de explotación de CVEs conocidos son públicas y automatizadas. Impacto 3: ejecución de código en el servicio.

**R-04 (JWT):** P=3 — sin validación de firma, cualquier token falso es aceptado; el exploit es trivial (generar un token). Impacto 3: acceso total al servicio.

**R-03 (eval):** P=2 — requiere que la entrada llegue a `eval()` (depende de la ruta del código). Impacto 3: ejecución de código arbitrario.

**R-10 (criptografía):** P=2 — explotar padding débil requiere conocimiento especializado. Impacto 3: descifrado de datos.

## Priorización y decisiones

El orden de corrección de la Fase 2 sigue la prioridad de esta tabla: primero los riesgos **Altos** (R-01, R-02, R-04, R-03, R-10) y luego los **Medios** (R-05 a R-09, R-11, R-12). Este orden coincide con el playbook de remediación (`docs/remediacion-playbook.md`): secretos → dependencias → eval → JWT → CORS → errores → imagen → cabeceras.

## Nota de trazabilidad

Esta tabla alimenta: informe §16, la plantilla de diagnóstico del curso (`docs/plantilla-diagnostico.md`) y la priorización de la Fase 2 (Tabla 4).
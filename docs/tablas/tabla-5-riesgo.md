# Tabla 5 — Cálculo de riesgo

> **Estado: COMPLETA.** Probabilidad e impacto se recalcularon con los hallazgos **confirmados** de la Fase 1 (Tabla 3) y se calcula el riesgo **residual** con la evidencia de la corrida verde 35442482331 (Tabla 4). Los valores de P e I son un juicio fundamentado del equipo con la escala documentada abajo; no son mediciones.

## Metodología

Riesgo = **Probabilidad** × **Impacto**, con escala documentada:

| Nivel | Probabilidad (P) | Impacto (I) |
|---|---|---|
| Bajo (1) | Poco probable (requiere condiciones especiales) | Impacto menor, sin datos sensibles |
| Medio (2) | Posible (requiere algún esfuerzo) | Impacto moderado, datos parciales |
| Alto (3) | Probable (bajo esfuerzo, herramientas comunes) | Impacto grave, datos sensibles o servicio caído |

**Nivel de riesgo:** Bajo (1–2) · Medio (3–4) · Alto (6–9)

## Registro de riesgos: antes y después de corregir

| ID | Vulnerabilidad (Tabla 3) | P antes | I | **Riesgo antes** | Nivel | P después | **Riesgo después** | Nivel | Base de la reducción |
|---|---|---|---|---|---|---|---|---|---|
| R-01 | Secretos quemados (H-01) | 3 | 3 | **9** | Alto | 1 | **3** | Medio | Gitleaks 0. Sigue Medio porque los valores ya estuvieron en el historial de git: en un caso real habría que **rotarlos** |
| R-02 | Dependencias vulnerables (H-02) | 3 | 3 | **9** | Alto | 1 | **3** | Medio | `npm audit`: 0 |
| R-03 | `eval()` / `exec()` (H-03, H-13) | 2 | 3 | **6** | Alto | 1 | **3** | Medio | Endpoints eliminados (404, EV-C204-023); P mínima, I se mantiene |
| R-04 | JWT mal validado (H-04) | 3 | 3 | **9** | Alto | 1 | **3** | Medio | RS256 + JWKS; 9 pruebas unitarias y 23 comprobaciones contra Keycloak real |
| R-05 | CORS abierto (H-05) | 2 | 2 | **4** | Medio | 1 | **2** | Bajo | Lista blanca (EV-C204-023) |
| R-06 | Errores internos expuestos (H-06) | 2 | 2 | **4** | Medio | 1 | **2** | Bajo | Error genérico |
| R-07 | Imagen con CVEs (H-07) | 2 | 2 | **4** | Medio | 1 | **2** | Bajo | Trivy 0 con `--ignore-unfixed`; **residual**: util-linux sin parche |
| R-08 | Contenedor como root (H-08) | 2 | 2 | **4** | Medio | 1 | **2** | Bajo | `USER node` (verificado: el contenedor corre como `node`) |
| R-09 | Cabeceras ausentes (H-09) | 2 | 2 | **4** | Medio | 1 | **2** | Bajo | ZAP: 0 High, 0 Low |
| R-10 | Criptografía insegura (H-10) | 2 | 3 | **6** | Alto | 1 | **3** | Medio | RSA-2048 + OAEP-SHA256 |
| R-11 | Inyección SQL (H-11) | 2 | 2 | **4** | Medio | 1 | **2** | Bajo | Consulta parametrizada |
| R-12 | Cadena de suministro del pipeline (H-14) | 2 | 2 | **4** | Medio | 1 | **2** | Bajo | Acciones fijadas a SHA |
| R-13 | Abuso / fuerza bruta sin límite (CodeQL) | 3 | 2 | **6** | Alto | 1 | **2** | Bajo | 429 al superar 100/min |

**Resumen** (suma de la columna de riesgo): antes = 9+9+6+9+4+4+4+4+4+6+4+4+6 = **73**; después = 3+3+3+3+2+2+2+2+2+3+2+2+2 = **31**. Reducción = (73−31)/73 ≈ **58 %**. Riesgos en nivel Alto: **de 6 a 0**. Ningún riesgo llega a 1 porque el impacto potencial del activo no cambia con la corrección; solo baja la probabilidad.

## Análisis gerencial complementario

### Pérdida anual esperada (ALE)

ALE = SLE × ARO, donde SLE = AV × EF (valor del activo × factor de exposición) y ARO = tasa anual de ocurrencia.

| Activo | Valor (AV) | Factor de exposición (EF) | SLE | ARO antes | **ALE antes** | ARO después | **ALE después** |
|---|---|---|---|---|---|---|---|
| Datos cifrados por el servicio | $10,000 | 0.5 | $5,000 | 2 | **$10,000** | 0.5 | **$2,500** |
| Llaves RSA del servicio | $20,000 | 0.3 | $6,000 | 1 | **$6,000** | 0.25 | **$1,500** |
| Credenciales de usuarios (Keycloak) | $15,000 | 0.4 | $6,000 | 1 | **$6,000** | 0.25 | **$1,500** |
| Disponibilidad del servicio | $8,000 | 0.5 | $4,000 | 3 | **$12,000** | 1 | **$4,000** |
| **Total ALE** | | | | | **$34,000** | | **$9,500** |

> Los valores monetarios son **ilustrativos** para el laboratorio académico (no hay un negocio real detrás) y se ajustarían con datos del contexto si el docente lo solicita. La tasa ARO «después» es una estimación del equipo tras los controles verificados.

### Justificación de probabilidades

- **R-01 (secretos):** P=3 antes: el repositorio es público y cualquiera puede leer los valores sin esfuerzo (Gitleaks los detectó con reglas estándar). Impacto 3: compromete credenciales y llaves.
- **R-02 (dependencias):** P=3: las herramientas de explotación de CVEs conocidos son públicas y automatizadas; había 1 crítica y 8 altas.
- **R-04 (JWT):** P=3: sin validación de firma, cualquier token falso era aceptado; explotarlo era trivial. Impacto 3: acceso total al servicio.
- **R-03 (`eval`):** P=2: requiere que la entrada llegue al endpoint; impacto 3 (ejecución de código).
- **R-10 (criptografía):** P=2: explotar padding débil requiere conocimiento especializado; impacto 3 (descifrado de datos).
- **R-13 (rate limiting):** P=3: cualquiera puede repetir peticiones sin límite; impacto 2 (abuso del servicio como oráculo o saturación).

## Priorización y decisiones

El orden de corrección de la Fase 2 siguió la prioridad de esta tabla: primero los riesgos **Altos** (R-01, R-02, R-04, R-03, R-10) y luego los **Medios** (R-05 a R-09, R-11, R-12); R-13 apareció al revisar las alertas de CodeQL del run verde y se cerró después. Ver `docs/remediacion-playbook.md`.

## Riesgo residual aceptado

1. **CVEs de util-linux sin parche** en la imagen base (CVE-2026-53613, 76642, 78408, 78409, 78410): no existe versión corregida; se excluyen del fallo con `--ignore-unfixed` y se documentan en el informe §8.5. Acción: re-escanear periódicamente.
2. **Falso positivo de ZAP** «CSP: Failure to Define Directive with No Fallback» en respuestas 404 (informe §12.4).
3. **Secretos históricos**: los valores de práctica siguen en el historial de git; son ficticios. En un proyecto real habría que rotarlos y reescribir el historial.

## Nota de trazabilidad

Esta tabla alimenta: informe §16, la plantilla de diagnóstico y la Tabla 4.

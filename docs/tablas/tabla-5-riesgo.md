# Tabla 5 — Cálculo de riesgo

> 📄 **Tabla a llenar** — Segundo Avance. Cálculos probabilísticos de los riesgos asociados a las vulnerabilidades identificadas (probabilidad de ocurrencia × impacto potencial).

## Metodología

Riesgo = **Probabilidad** × **Impacto**, con escala documentada:

| Nivel | Probabilidad (P) | Impacto (I) |
|---|---|---|
| Bajo | 1 — poco probable (requiere condiciones especiales) | 1 — impacto menor, sin datos sensibles |
| Medio | 2 — posible (requiere algún esfuerzo) | 2 — impacto moderado, datos parciales |
| Alto | 3 — probable (bajo esfuerzo, herramientas comunes) | 3 — impacto grave, datos sensibles o servicio caído |

**Nivel de riesgo:** Bajo (1–2) · Medio (3–4) · Alto (6–9)

## Registro de riesgos

| ID | Vulnerabilidad (de Tabla 3) | Probabilidad (1–3) | Impacto (1–3) | Riesgo (P×I) | Nivel | Prioridad de mitigación |
|---|---|---|---|---|---|---|
| R-01 | Secretos quemados (H-01) | 3 | 3 | 9 | Alto | 1 |
| R-02 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| R-03 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| R-04 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| R-05 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| R-06 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| R-07 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| R-08 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |

## Análisis gerencial complementario (para exceder)

### Pérdida anual esperada (ALE)

ALE = SLE × ARO, donde SLE = AV × EF (valor del activo × factor de exposición) y ARO = tasa anual de ocurrencia.

| Activo | Valor (AV) | Factor de exposición (EF) | SLE | ARO | ALE |
|---|---|---|---|---|---|
| *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |

### Justificación de probabilidades

**R-01 (secretos):** *(explica por qué P=3 — el repo es público y Gitleaks detecta el patrón automáticamente; cualquier persona puede leer los secretos...)*

**R-02:** *(completar)*

## Priorización y decisiones

*(Explica cómo el cálculo de riesgo priorizó el orden de corrección de la Fase 2 — por qué se corrigió primero lo que se corrigió primero.)*
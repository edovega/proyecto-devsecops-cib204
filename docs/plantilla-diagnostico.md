# Plantilla de diagnóstico — CIB-204

> Plantilla oficial de diagnóstico del curso para documentar los resultados del análisis de seguridad.
> Se completa con los hallazgos de la Fase 1 (Tabla 3) y alimenta el cálculo de riesgo (Tabla 5).

## Datos del diagnóstico

| Campo | Valor |
|---|---|
| Programa analizado | Servicio de cifrado (Node.js) + app móvil |
| Repositorio | https://github.com/edovega/proyecto-devsecops-cib204 |
| Herramientas | Semgrep, CodeQL, Gitleaks, npm audit, Trivy, Syft, OWASP ZAP |
| Fecha del diagnóstico | *(completar)* |
| Analista | *(completar)* |

## Registro de vulnerabilidades

| # | Componente | Vulnerabilidad | CWE | Severidad | Consecuencia de explotación |
|---|---|---|---|---|---|
| 1 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| 2 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| 3 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| 4 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| 5 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| 6 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| 7 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| 8 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| 9 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| 10 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| 11 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| 12 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |

## Cálculo probabilístico de riesgo

| # | Vulnerabilidad | Probabilidad (1–3) | Impacto (1–3) | Riesgo (P×I) | Nivel | Prioridad |
|---|---|---|---|---|---|---|
| 1 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| 2 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| 3 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| 4 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| 5 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| 6 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| 7 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| 8 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| 9 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| 10 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| 11 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |
| 12 | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* | *(completar)* |

## Escala de severidad

| Severidad | Criterio |
|---|---|
| Crítica | Explotable remotamente sin autenticación; compromete datos sensibles o el servicio completo |
| Alta | Explotable con esfuerzo bajo; compromete confidencialidad/integridad/disponibilidad |
| Media | Requiere condiciones especiales o privilegios; impacto limitado |
| Baja | Impacto menor; no compromete datos sensibles |
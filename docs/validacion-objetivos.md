# Lista de validación de objetivos — Proyecto DevSecOps CIB-204

> Documento maestro de trazabilidad: cada objetivo, requisito y criterio solicitado en el **programa del curso (PDF)**, la **guía de laboratorio** y la **rúbrica** se mapea a **dónde se desarrolla** en el repositorio, su **estado** y **cómo se excede** (criterio "Excede el criterio" = 5 puntos).
>
> Convenciones de estado: ✅ completado · 🔄 en curso · ⏳ pendiente de zip · 📝 pendiente de redacción

---

## A. Objetivos del curso (competencia y resultados de aprendizaje — PDF sección 3)

### A.1 Competencia del curso
> "Diseñar soluciones de seguridad para garantizar la funcionalidad y la resistencia de los programas informáticos ante ataques externos de manera ingeniosa, implementando mecanismos de defensa y de protección en cada fase del ciclo de vida del software."

| Resultado de aprendizaje | Dónde se desarrolla | Estado | Cómo se excede |
|---|---|---|---|
| **RA1.** Desarrolla un procedimiento de seguridad para aplicaciones móviles durante la fase de programación, empleando técnicas de encriptación y pruebas de código que maximicen la calidad | `servidor/cifrado.js` (RSA-OAEP), `servidor/servidor.js` (API), `app-movil/App.js`, `docs/informe-maestro.md` §9–10 | ✅ | Cifrado RSA-2048 OAEP-SHA256 + pruebas automatizadas + verificación por SAST/DAST (no solo pruebas funcionales) |
| **RA2.** Realiza prácticas para el diagnóstico de la seguridad de un programa informático, aplicando la jerarquía de diseño y los métodos probabilísticos para el análisis de riesgos y vulnerabilidades | `docs/jerarquia_diseno.md`, `docs/plantilla-diagnostico.md`, `docs/tablas/tabla-5-riesgo.md` | ✅ estructura / 📝 completar | Jerarquía con componentes críticos + riesgo probabilístico (P×I) + análisis gerencial ALE (pérdida anual esperada) |
| **RA3.** Resuelve el estudio de casos relacionados con la implementación de técnicas de seguridad | *(no aplica a este proyecto — es otra estrategia de evaluación, 30%)* | — | — |

### A.2 Criterios de desempeño del proyecto (PDF sección 3)

| Criterio de desempeño | Dónde se desarrolla | Estado | Cómo se excede |
|---|---|---|---|
| Analiza los requerimientos de seguridad según la problemática planteada | `docs/tablas/tabla-1-requisitos.md` + informe §5 | 🔄 completar | Justificación por propiedad + mapeo a OWASP SAMM, NIST SSDF, OWASP ASVS y OWASP MASVS |
| Configura el entorno de programación Node.js | `.devcontainer/devcontainer.json`, informe §8, EV-C204-001 | ✅ (EV-C204-043 a 046) | Entorno reproducible en la nube (Codespace) + documentación paso a paso + verificación de versiones |
| Desarrolla un módulo para las funciones de encriptación y desencriptación | `servidor/cifrado.js`, informe §9 | ✅ | Módulo con RSA-OAEP + pruebas de roundtrip + resistencia a manipulación |
| Desarrolla las funciones de utilidad dentro del módulo creado | `servidor/` (validación, errores, bitácora), informe §10 | ✅ | Validación de entrada (tipo/tamaño), errores genéricos, bitácora con integridad |
| Implementa el algoritmo criptográfico RSA como mecanismo de seguridad | `servidor/cifrado.js`, informe §9 | ✅ | RSA-2048 con OAEP-SHA256 (padding seguro, nunca PKCS#1 v1.5 sin OAEP) |
| Realiza una revisión del código utilizando áreas de análisis estático | `.github/workflows/devsecops.yml` (Semgrep + CodeQL), informe §13 | ✅ | **3 herramientas SAST** (Semgrep, CodeQL, ESLint) + reportes descargados como evidencia |
| Ejecuta pruebas de código para validar el funcionamiento | `servidor/` (npm test), informe §17 | ✅ | Pruebas unitarias + funcionales + de integración + de sistema + pentest |
| Realiza ajustes en los escenarios de las pruebas | `docs/tablas/tabla-6-pruebas.md` (sección ajustes) | 📝 completar | Documentar qué se ajustó, por qué y el resultado del ajuste |
| Documenta todas las pruebas y resultados obtenidos | `docs/tablas/tabla-6-pruebas.md` | 📝 completar | Tabla 6 con datos de entrada, esperado, real y estado por prueba |
| Presenta un informe con resumen de resultados, conclusiones y recomendaciones | `docs/informe-maestro.md` §19–21 | 📝 completar | Informe integrado con evidencias SHA-256, análisis gerencial y trazabilidad |

---

## B. Entregables del proyecto (PDF secciones 7–9)

### B.1 Primer Avance (10%)

| Entregable solicitado | Dónde se desarrolla | Estado | Cómo se excede |
|---|---|---|---|
| Análisis de requerimientos de seguridad (confidencialidad, integridad, disponibilidad, autenticación) | `docs/tablas/tabla-1-requisitos.md` + informe §5 | 🔄 | 4 propiedades + **no repudio** (5.ª) + justificación del porqué + mapeo a 4 estándares |
| Configuración del entorno de programación Node.js (instalación paso a paso) | informe §8 + `.devcontainer/devcontainer.json` | ✅ (EV-C204-043 a 046) | Entorno en la nube reproducible + verificación de versiones + captura EV-C204-001 |
| Desarrollo del módulo de encriptación/desencriptación | `servidor/cifrado.js`, informe §9 | ✅ | Funciones definidas + selección de algoritmo justificada + utilidades |
| Implementación del algoritmo RSA | `servidor/cifrado.js`, informe §9 | ✅ | RSA-2048 OAEP-SHA256 + pruebas de manipulación |
| Jerarquía de diseño (estructura general y relación entre módulos) | `docs/jerarquia_diseno.md` + informe §7 | ✅ (figuras EV-C204-015 a 017) | Árbol de archivos + tabla de subsistemas + componentes críticos + figuras SVG |

### B.2 Segundo Avance (15%)

| Entregable solicitado | Dónde se desarrolla | Estado | Cómo se excede |
|---|---|---|---|
| Descomposición de subsistemas | `docs/jerarquia_diseno.md` (tabla de subsistemas) | ✅ | 7 subsistemas con función, datos, superficie de ataque y propensión a fallar |
| Análisis de componentes propensos a fallar | `docs/jerarquia_diseno.md` (componentes críticos) | ✅ | 4 factores de la rúbrica: complejidad, frecuencia, datos sensibles, interacción externa |
| Diagnóstico de seguridad (plantilla) | `docs/plantilla-diagnostico.md` + `docs/tablas/tabla-3-diagnostico.md` | 📝 completar | ~12 hallazgos con CWE + severidad + consecuencia de explotación |
| Cálculo de riesgos (probabilístico) | `docs/tablas/tabla-5-riesgo.md` | 📝 completar | P×I documentado + **ALE/SLE** (análisis gerencial) + priorización justificada |
| Revisión de código (análisis estático) | `.github/workflows/devsecops.yml` + informe §13 | ✅ | 3 SAST + reportes descargados + alertas CodeQL revisadas |
| Pruebas de código (unitarias, integración, sistema) | `docs/tablas/tabla-6-pruebas.md` | 📝 completar | Clasificación de tipos de prueba (Atlassian) + 20+ pruebas documentadas |
| Ajuste de pruebas | `docs/tablas/tabla-6-pruebas.md` (sección ajustes) | 📝 completar | Ajustes documentados con justificación y resultado |
| Documentación de pruebas | `docs/tablas/tabla-6-pruebas.md` | 📝 completar | Datos de entrada, esperado, real y estado por prueba |

### B.3 Informe Final (15%)

| Entregable solicitado | Dónde se desarrolla | Estado | Cómo se excede |
|---|---|---|---|
| Informe técnico: Introducción | informe §1 | 🔄 | Contexto + objetivos + metodología + descripción de la app |
| Informe técnico: Desarrollo | informe §2–18 | 🔄 | Análisis de requerimientos, entorno, módulo, análisis de seguridad, pruebas, resultados |
| Resumen de resultados | informe §19 | 📝 | Vulnerabilidades, riesgos y efectividad de medidas (con números del pipeline) |
| Conclusiones | informe §20 | 📝 | Evaluación de seguridad + lecciones aprendidas |
| Recomendaciones | informe §21 | 📝 | Medidas adicionales priorizadas por riesgo |
| Código fuente con control de versiones | Repositorio git (commits por corrección) | ✅ | Trazabilidad: un commit por hallazgo corregido (Tabla 4) |

---

## C. Pasos de la guía de laboratorio (14 pasos)

| # | Paso de la guía | Dónde se desarrolla | Estado |
|---|---|---|---|
| 1 | Crear cuenta de GitHub | — | ✅ (`edovega`) |
| 2 | Crear repo + subir material | Repositorio | ✅ |
| 3 | Entorno en la nube (Codespace) | `.devcontainer/devcontainer.json` | ✅ (EV-C204-043 a 046) |
| 4 | Tabla 1 (requisitos) | `docs/tablas/tabla-1-requisitos.md` | 🔄 |
| 5 | Tabla 2 (STRIDE) | `docs/tablas/tabla-2-stride.md` | 🔄 |
| 6 | Jerarquía de diseño | `docs/jerarquia_diseno.md` | ✅ (figuras EV-C204-015 a 017) |
| 7 | Levantar servicio + Keycloak | `docker-compose.yml` | ✅ (probado con Keycloak 24.0 real) |
| 8 | Configurar IAM en Keycloak | informe §8.3 y §11.3 | ✅ por API; captura de la consola: ⏳ pendiente del equipo |
| 9 | Probar app móvil | informe §8.4 | ⏳ pendiente del equipo (EV-C204-006) |
| 10 | FASE 1: pipeline en rojo | `docs/tablas/tabla-3-diagnostico.md` | ✅ |
| 11 | FASE 2: corregir a verde | `docs/tablas/tabla-4-evidencias.md` + `docs/remediacion-playbook.md` | ✅ |
| 12 | Pentest + pruebas | `docs/tablas/tabla-5-riesgo.md` + `tabla-6-pruebas.md` | ✅ |
| 13 | Proteger rama principal | GitHub Settings (branch protection), informe §15 | ⏳ pendiente del equipo (EV-C204-014) |
| 14 | Informe final en PDF | `docs/informe-maestro.md` → PDF | ✅ |

---

## D. Rúbrica del proyecto (9 criterios × 5 pts = 45 pts)

| # | Criterio | Descripción "Excede" (5 pts) | Dónde se demuestra | Cómo se garantiza el 5 |
|---|---|---|---|---|
| 1 | Requerimientos de seguridad | Analiza de manera **amplia y explícita** | Tabla 1 + informe §5 | 4 propiedades + no repudio + justificación + mapeo a SAMM/SSDF/ASVS/MASVS |
| 2 | Configuración del entorno | Configura Node.js de manera **adecuada** | informe §8 + EV-C204-001 | Codespace reproducible + paso a paso + versiones verificadas |
| 3 | Módulo encriptación/desencriptación | Desarrolla de manera **satisfactoria** | `servidor/cifrado.js` + pruebas | RSA-OAEP + roundtrip + manipulación rechazada |
| 4 | Funciones de utilidad | Desarrolla **sin limitaciones** | `servidor/` + pruebas | Validación tipo/tamaño + errores genéricos + bitácora + codificación |
| 5 | Algoritmo RSA | Implementa **sin errores** | `servidor/cifrado.js` + SAST | RSA-2048 OAEP-SHA256 + SAST en verde + pruebas de manipulación |
| 6 | Revisión del código | Análisis estático de manera **óptima** | Pipeline + reportes | 3 SAST (Semgrep, CodeQL, ESLint) + reportes como evidencia |
| 7 | Pruebas y ajustes | Pruebas de manera **completa** | Tabla 6 + pipeline | 20+ pruebas documentadas + 6 jobs del pipeline + pentest + ajustes justificados |
| 8 | Avances del proyecto | Incorpora retroalimentación de manera **oportuna** | Tabla 4 + informe §25.1 | Trazabilidad de correcciones + commits por hallazgo + sección de retroalimentación |
| 9 | Informe del proyecto | Formato **apto** con conclusiones | informe-maestro.md → PDF | 5 partes + 22 secciones + evidencias SHA-256 + conclusiones y recomendaciones |

---

## E. Mejoras para EXCEDER (mejores prácticas, estándares y recomendaciones)

### E.1 Estándares aplicados (además de lo mínimo pedido)

| Estándar | Qué aporta | Dónde se aplica |
|---|---|---|
| **OWASP ASVS** (Application Security Verification Standard) | Requisitos de seguridad verificables por nivel | Tabla 1 (mapeo por capítulo) |
| **OWASP MASVS** (Mobile App Security Verification Standard) | Requisitos específicos de apps móviles | Tabla 1 (mapeo) |
| **OWASP SAMM** (Software Assurance Maturity Model) | Madurez del proceso DevSecOps | Tabla 1 + metodología del informe |
| **NIST SSDF** (Secure Software Development Framework) | Prácticas del ciclo de vida seguro | Tabla 1 + metodología del informe |
| **CWE** (Common Weakness Enumeration) | Identificación precisa de debilidades | Tabla 3 (cada hallazgo con CWE) |
| **STRIDE** (Microsoft) | Modelado de amenazas | Tabla 2 |
| **DREAD / CVSS** | Severidad de amenazas y vulnerabilidades | Tabla 2 (severidad) + Tabla 5 (riesgo) |
| **OWASP ZAP / DAST** | Pruebas dinámicas | Pipeline (job dast) |
| **SBOM (Syft/SPDX)** | Inventario de componentes (transparencia de cadena de suministro) | Pipeline (job imagen) |
| **Gitleaks** | Prevención de fugas de secretos | Pipeline (job secretos) |

### E.2 Estándares considerados y NO aplicados (con justificación — práctica valorada en posgrado)

| Estándar | Por qué no se aplica | Cuándo aplicaría |
|---|---|---|
| **OWASP MASVS completo (nivel L2/L3)** | El laboratorio es un prototipo web (Expo web), no una app nativa con keystore | Si se publicara la app en tiendas |
| **SonarQube / Veracode / Checkmarx** | SAST comercial con licencia; Semgrep + CodeQL + ESLint cubren el alcance | Proyectos de producción |
| **Fuzzing avanzado (AFL/libFuzzer)** | Desproporcionado para una API de 4 archivos; se usa fuzzing básico en pruebas | APIs de producción |
| **WAF / RASP** | El laboratorio no se despliega en producción | Despliegue real |
| **Kubernetes hardening (CIS Benchmarks)** | El despliegue es docker-compose local | Orquestación real |
| **Pentest con certificación (OSCP-style)** | Alcance académico; se usa ZAP + pruebas manuales | Evaluación profesional |

### E.3 Recomendaciones de mejora continua (para el informe final)

1. **Rotación de llaves RSA** — política de rotación periódica y revocación.
2. **TLS obligatorio** — el servicio debe servirse solo por HTTPS en producción (hoy el Codespace lo provee).
3. ~~**Rate limiting**~~ — **implementado** (FIX-19, `express-rate-limit`, 100 peticiones/min por IP); queda como mejora un límite por usuario.
4. **Monitoreo y alertas** — correlación de la bitácora con un SIEM.
5. **Pruebas continuas** — el pipeline ya las ejecuta en cada push; agregar programación semanal (Automation).
6. **Actualización de dependencias automatizada** — Dependabot para mantener el SCA en verde.
7. **Secretos en gestor** — GitHub Secrets / vault en lugar de variables de entorno en archivos.
8. **Análisis de composición de software (SCA) con política** — fallar el build ante CVEs críticos (hoy `exit-code: 0` en Fase 1; en producción debe ser `1`).

---

## F. Definición de validación por entregable

| Entregable | Criterio de validación | Comando/verificación |
|---|---|---|
| Tabla 1 | Cada propiedad tiene requisito, control, verificación y justificación | Revisión cruzada con ASVS/MASVS |
| Tabla 2 | 6 amenazas con componente, ataque, control, severidad y prueba | Revisión cruzada con STRIDE |
| Jerarquía | Árbol + subsistemas + componentes críticos + figuras | Revisión visual de figuras SVG |
| Tabla 3 | 16 hallazgos con CWE y riesgo | Cruzar con reportes del pipeline |
| Tabla 4 | Cada hallazgo con antes/después y commit | Cruzar con git log |
| Tabla 5 | Riesgo P×I + ALE documentado | Revisión de cálculos |
| Tabla 6 | 30+ pruebas con entrada/esperado/real | Revisión de resultados |
| Informe | 5 partes + evidencias SHA-256 | `sha256sum -c manifiesto` |
| Pipeline | 6/6 jobs en verde | Actions → última ejecución |
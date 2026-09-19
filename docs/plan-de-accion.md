# Plan de acción — Cobertura 100% de la rúbrica CIB-204

> Objetivo: **exceder cada criterio de la rúbrica** (columna "Excede el criterio" = 5 puntos) en los 9 criterios del proyecto (45/45 puntos).
> Este plan define: herramientas, acciones concretas, evidencia requerida y verificación de cada criterio.

---

## 1. Inventario de herramientas

### 1.1 Herramientas del pipeline (se ejecutan solas en GitHub Actions)

| Herramienta | Tipo | Job en el pipeline | Qué detecta | Dónde corre |
|---|---|---|---|---|
| Semgrep | SAST | `sast_semgrep` | eval, inyección, JWT, CORS | GitHub Actions |
| CodeQL | SAST | `sast_codeql` | Vulnerabilidades JS | GitHub Actions (requiere repo público ✅) |
| Gitleaks | Secretos | `secretos` | Claves/contraseñas en el repo | GitHub Actions |
| npm audit | SCA | `sca` | Dependencias vulnerables (CVE) | GitHub Actions |
| Trivy | SCA + Imagen | `sca` + `imagen` | Vulnerabilidades de imagen/fs | GitHub Actions |
| Syft | SBOM | `imagen` | Genera SBOM de la imagen | GitHub Actions |
| OWASP ZAP | DAST | `dast` | Cabeceras ausentes, CORS, ataques | GitHub Actions |

### 1.2 Herramientas del entorno (Codespace — Node 20 + Docker)

| Herramienta | Uso | Verificación |
|---|---|---|
| Node.js v20 | Ejecutar el servicio de cifrado | `node --version` |
| npm | Instalar dependencias, `npm test` | `npm --version` |
| Docker + Compose | Levantar Keycloak + servicio | `docker compose ps` |
| Keycloak | IAM: realm, cliente, usuario, tokens | Consola admin puerto 8080 |
| Expo (React Native) | App móvil en el navegador | Puerto 8081 |

### 1.3 Herramientas de trabajo (este entorno — ya verificadas)

| Herramienta | Versión | Estado | Uso |
|---|---|---|---|
| gh CLI | 2.100.0 | ✅ | Repos, Actions, artefactos, branch protection |
| git | 2.43.0 | ✅ | Control de versiones |
| Node.js | v18.19.1 | ✅ | Validación local de código (el lab usa v20 en Codespace) |
| Docker | 29.8.1 | ✅ | Pruebas locales de contenedores |
| Python 3 | 3.12.3 | ✅ | Procesamiento de reportes, generación de PDF |
| Pandoc | — | ⚠️ instalar | Conversión informe → PDF (como en BóvedaSegura) |

---

## 2. Mapa maestro: 9 criterios de rúbrica → 45/45 puntos

### Criterio 1 — Requerimientos de seguridad (5 pts)
**Excede:** "Analiza los requerimientos de seguridad según la problemática planteada de manera amplia y explícita"

| Acción | Herramienta | Evidencia | Verificación |
|---|---|---|---|
| Tabla 1 completa: 4 propiedades (CIA + autenticación) con requisito, control y verificación | Guía + análisis | `docs/tablas/tabla-1-requisitos.md` | Revisión: cada fila tiene control concreto y prueba verificable |
| Justificación del *porqué* de cada requisito | OWASP SAMM, NIST SSDF | Sección "Justificación" de Tabla 1 | Cada propiedad tiene párrafo de justificación |
| Mapeo a estándares (SAMM/SSDF) | OWASP SAMM, NIST SSDF | Tabla de mapeo en Tabla 1 | Cada requisito mapeado a práctica |
| Fila extra de No repudio (bitácora) | Análisis | Tabla 1 (5.ª fila) | Bitácora implementada en `db.js` |

### Criterio 2 — Configuración del entorno de programación (5 pts)
**Excede:** "Configura el entorno de programación Node.js de manera adecuada"

| Acción | Herramienta | Evidencia | Verificación |
|---|---|---|---|
| Codespace con Node 20 + Docker | `.devcontainer/devcontainer.json` | EV-C204-001 (versiones) | `node --version` = v20, `docker compose version` OK |
| Levantar servicio + Keycloak | `docker compose up -d --build` | EV-C204-002 (`/salud` → `{"estado":"ok"}`) | `docker compose ps` = running |
| Configurar Keycloak (realm, cliente, usuario) | Consola Keycloak | EV-C204-003/004/005 (capturas) | Login demo funciona; token emitido |
| Documentar configuración paso a paso | Guía | Sección 8 del informe | Pasos reproducibles por terceros |

### Criterio 3 — Módulo de encriptación/desencriptación (5 pts)
**Excede:** "Desarrolla un módulo ... de manera satisfactoria"

| Acción | Herramienta | Evidencia | Verificación |
|---|---|---|---|
| Módulo `cifrado.js` con cifrar/descifrar | Node.js crypto | Código en `servidor/` | `node prueba.js` → `coincide=true` |
| Pruebas automatizadas del módulo | Node test runner | `npm test` → 6 passed | EV: salida de tests |
| App móvil cifra y descifra de extremo a extremo | Expo + servicio | EV-C204-006 (captura app) | "Cifrado OK" y "Descifrado OK" |

### Criterio 4 — Funciones de utilidad (5 pts)
**Excede:** "Desarrolla las funciones de utilidad dentro del módulo creado sin limitaciones"

| Acción | Herramienta | Evidencia | Verificación |
|---|---|---|---|
| Validación de entrada (tipo y tamaño) | Node.js | Código + pruebas P-06/P-07/P-08 | Entrada vacía/muy larga/no texto rechazada |
| Manejo de errores genéricos (sin stack traces) | Node.js | Prueba de entrada inválida | Respuesta genérica, sin detalles internos |
| Bitácora de operaciones | `db.js` | Prueba de consulta de bitácora | Operación registrada con integridad |
| Codificación segura (base64/hex) | Node.js | Pruebas de roundtrip | Cifrado/descifrado consistente |

### Criterio 5 — Algoritmo criptográfico RSA (5 pts)
**Excede:** "Implementa el algoritmo criptográfico RSA sin errores"

| Acción | Herramienta | Evidencia | Verificación |
|---|---|---|---|
| RSA con padding OAEP (seguro) | Node.js crypto | Código `cifrado.js` | Revisión: sin RSA sin padding |
| Tamaño de llave ≥ 2048 bits | Node.js crypto | Código + pruebas | Verificación en código |
| Descifrado falla seguro ante manipulación | Node.js crypto | Prueba P-05 (dato alterado) | Error controlado, sin fuga |
| SAST no reporta fallas en el módulo | Semgrep + CodeQL | Reportes Fase 2 | Jobs `sast_*` en verde |

### Criterio 6 — Revisión del código (5 pts)
**Excede:** "Realiza una revisión del código utilizando áreas de análisis estático de manera óptima"

| Acción | Herramienta | Evidencia | Verificación |
|---|---|---|---|
| 3 herramientas SAST (Semgrep, CodeQL, ESLint) | Pipeline + ESLint | Reportes descargados (artefactos) | EV-C204-008, EV-C204-012 |
| Fase 1: documentar hallazgos en Tabla 3 (~12) | Semgrep, CodeQL, Gitleaks | `docs/tablas/tabla-3-diagnostico.md` | Cada hallazgo con CWE y riesgo |
| Fase 2: corregir y verificar en verde | Pipeline | EV-C204-013 (pipeline verde) | 6/6 jobs ✔ |
| Alertas CodeQL revisadas | CodeQL | EV-C204-012 (Code scanning) | Alertas cerradas o justificadas |

### Criterio 7 — Pruebas y ajustes de código (5 pts)
**Excede:** "Realiza pruebas y ajustes de código de manera completa"

| Acción | Herramienta | Evidencia | Verificación |
|---|---|---|---|
| Pruebas unitarias del servicio | `npm test` | Salida 6 passed | EV en capturas |
| Pruebas funcionales (cifrar/descifrar con y sin token) | API + Keycloak | Tabla 6 (P-01 a P-10) | Resultados reales documentados |
| Pentest manual (manipulación, CORS, cabeceras) | ZAP + curl | Tabla 6 (P-17 a P-21) | Hallazgos documentados |
| Ajustes de escenarios de prueba | Análisis | Sección "Ajustes" de Tabla 6 | Documentado qué se ajustó y por qué |
| DAST completo | ZAP | EV-C204-011 (reporte-zap) | Cabeceras presentes, CORS restringido |

### Criterio 8 — Avances del proyecto (5 pts)
**Excede:** "Incorpora la retroalimentación brindada por el docente en los avances del proyecto de manera oportuna"

| Acción | Herramienta | Evidencia | Verificación |
|---|---|---|---|
| Tabla 4 con trazabilidad de correcciones | Git | `docs/tablas/tabla-4-evidencias.md` | Cada hallazgo: antes → corrección → después |
| Un commit por corrección con mensaje descriptivo | Git | Registro de commits en Tabla 4 | Hashes referenciados |
| Rama `main` protegida (PR + status checks) | GitHub Settings | EV-C204-014 | Regla de protección activa |
| Sección de retroalimentación de la docente | Informe | Sección 25.1 del informe | Retroalimentación incorporada y documentada |

### Criterio 9 — Informe del proyecto (5 pts)
**Excede:** "Presenta el formato del informe incorporando conclusiones de manera apta"

| Acción | Herramienta | Evidencia | Verificación |
|---|---|---|---|
| Informe integrado completo (5 partes, 22 secciones) | Markdown | `docs/informe-maestro.md` | Estructura completa |
| Todas las tablas consolidadas | Markdown | Anexo A del informe | Tablas 1–6 completas |
| Evidencias con manifiesto SHA-256 | sha256sum | `docs/evidencias/manifiesto-sha256.txt` | `sha256sum -c` = OK |
| Conversión a PDF | Pandoc + WeasyPrint | `docs/Informe-CIB204-DevSecOps.pdf` | PDF generado y revisado |
| Conclusiones y recomendaciones | Análisis | Secciones 20–21 | Evaluación + lecciones + recomendaciones |

---

## 3. Checklist maestro de ejecución

### Fase 0 — Preparación
- [x] Cuenta GitHub (`edovega`)
- [x] Repo público `proyecto-devsecops-cib204` creado
- [x] Estructura del repo + documentación base
- [x] Integrar zip oficial (servidor/, app-movil/, workflows oficiales) — commit `9b1bddb`
- [ ] Confirmar datos del curso con la docente (fechas de entrega) — **pendiente del equipo**; integrantes ya confirmados

### Primer Avance
- [x] Tabla 1 (requisitos)
- [x] Tabla 2 (STRIDE)
- [x] Jerarquía de diseño
- [x] Entorno verificado (EV-C204-001 = captura EV-C204-046)
- [x] Servicio + Keycloak corriendo (EV-C204-002 a 005, por API con Keycloak 24.0; capturas de la consola del Codespace: pendiente del equipo)
- [ ] App cifrando/descifrando (EV-C204-006) — **pendiente del equipo**

### Segundo Avance
- [x] Fase 1: pipeline en rojo documentado (EV-C204-007, 020 a 022, 027, 028)
- [x] Tabla 3 (diagnóstico, 16 hallazgos)
- [x] Fase 2: correcciones hasta verde (EV-C204-013 = EV-C204-026)
- [x] Tabla 4 (antes/después con commits)
- [x] Tabla 5 (riesgo con ALE)
- [x] Tabla 6 (pruebas completas)
- [ ] Rama main protegida (EV-C204-014) — **pendiente del equipo** (informe §15)

### Informe Final
- [x] Informe integrado completo
- [x] PDF generado
- [x] Manifiesto SHA-256 verificado
- [ ] Entrega a la docente — **pendiente del equipo**

---

## 4. Definición de "hecho" (Definition of Done)

El proyecto está **100% completo** cuando:

1. ✅ El pipeline muestra **5/5 jobs en verde** más **CodeQL (default setup) sin alertas abiertas** en la última ejecución de `main` (desviación documentada de los 6 jobs, informe §12.1)
2. ✅ Las **6 tablas** están completas con datos reales (no placeholders)
3. ✅ Los **14+ evidencias** (EV-C204-001 a 014) existen y el manifiesto SHA-256 verifica
4. ✅ La **rama `main` está protegida** (PR + status checks)
5. ✅ El **informe en PDF** consolida todas las tablas, conclusiones y recomendaciones
6. ✅ Los **datos del curso** (docente, integrantes, fechas) están confirmados y correctos

---

## 5. Riesgos y bloqueadores

| Riesgo | Impacto | Mitigación |
|---|---|---|
| ✅ Zip oficial integrado (`9b1bddb`) | — | Fase 1 real ejecutada y documentada (Tabla 3) |
| CodeQL requiere repo público | Job sin resultados mientras esté privado | Repo **privado durante el desarrollo** (Semgrep es la prueba SAST principal); se hace **público al finalizar** — acción: `gh repo edit edovega/proyecto-devsecops-cib204 --visibility public --accept-visibility-change-consequences` |
| Horas de Codespace limitadas | Tiempo de trabajo | Detener Codespace al terminar; plan gratuito alcanza |
| Fechas de entrega no confirmadas | Informe con fechas incorrectas | Confirmar con la docente (sección 4 de datos-del-curso) |
| Pandoc no instalado | PDF final | ✅ Resuelto: pandoc 3.9 verificado (venv `pypandoc-binary`); LaTeX se instala en el Codespace (root) o se usa DOCX/GitHub-Print como alternativa |

---

## 6. Herramientas que faltan por instalar/confirmar

| Herramienta | Necesaria para | Acción |
|---|---|---|
| Pandoc | Conversión del informe a PDF | ✅ pandoc 3.9 verificado (venv `pypandoc-binary`). PDF final: en el Codespace `apt-get install -y texlive-latex-base` + `pandoc informe-maestro.md -o informe.pdf`; alternativas: DOCX o GitHub → Print → PDF |
| docker-compose (local) | Pruebas locales del stack | No es necesaria: el lab corre en Codespace (compose incluido) |
| Confirmación de equipo | Portada del informe | Preguntar al compañero Keylor si participa en este laboratorio |
# PROYECTO DE SEGURIDAD EN APLICACIONES MÓVILES — PIPELINE DevSecOps

## Informe integrado: primer avance, segundo avance e informe final

**Curso:** CIB-204 · Seguridad del Software · Maestría en Ciberseguridad
**Universidad:** CENFOTEC
**Profesora:** Alejandra Corrales Vargas
**Estudiante:** *(completar)*
**Repositorio:** https://github.com/edovega/proyecto-devsecops-cib204
**Fecha:** *(completar)*

---

## Mapa del documento

| Parte | Secciones | Entrega |
|---|---|---|
| Parte I — Contexto y diseño | 1–8 | Primer Avance |
| Parte II — Implementación y entorno | 9–12 | Primer Avance |
| Parte III — Diagnóstico y remediación | 13–18 | Segundo Avance |
| Parte IV — Pruebas y riesgos | 19–22 | Segundo Avance |
| Parte V — Cierre académico | 23–25 | Informe Final |

## Índice de evidencias

| ID | Evidencia | Archivo |
|---|---|---|
| EV-C204-001 | Versiones del entorno (node, npm, docker) | `docs/evidencias/capturas/EV-C204-001-versiones.txt` |
| EV-C204-002 | Servicio `/salud` respondiendo | *(pendiente)* |
| EV-C204-003 | Keycloak: realm appmovil | *(pendiente)* |
| EV-C204-004 | Keycloak: cliente servicio-cifrado | *(pendiente)* |
| EV-C204-005 | Keycloak: usuario demo | *(pendiente)* |
| EV-C204-006 | App móvil cifrando/descifrando | *(pendiente)* |
| EV-C204-007 | Pipeline Fase 1 (jobs en rojo) | *(pendiente)* |
| EV-C204-008 | Reporte Semgrep (Fase 1) | *(pendiente)* |
| EV-C204-009 | Reporte Gitleaks (Fase 1) | *(pendiente)* |
| EV-C204-010 | SBOM (Fase 1) | *(pendiente)* |
| EV-C204-011 | Informe ZAP (Fase 1) | *(pendiente)* |
| EV-C204-012 | Alertas CodeQL (Code scanning) | *(pendiente)* |
| EV-C204-013 | Pipeline Fase 2 (todo verde) | *(pendiente)* |
| EV-C204-014 | Rama main protegida | *(pendiente)* |

---

# PARTE I — CONTEXTO Y DISEÑO

## 1. Introducción

*(Contexto del proyecto: aplicación móvil que cifra y descifra datos con un servicio Node.js, identidad con Keycloak y un pipeline DevSecOps que detecta vulnerabilidades reales. El proyecto arranca inseguro a propósito y se corrige hasta dejar el pipeline en verde.)*

## 2. Objetivos

### 2.1 Objetivo general
*(Completar: implementar un pipeline DevSecOps completo para una aplicación móvil de cifrado, desde el diagnóstico de vulnerabilidades hasta su remediación verificada.)*

### 2.2 Objetivos específicos
1. *(Completar: analizar los requerimientos de seguridad de la aplicación móvil.)*
2. *(Completar: configurar el entorno de desarrollo en la nube con Node.js y Docker.)*
3. *(Completar: implementar el módulo de cifrado RSA en el servicio backend.)*
4. *(Completar: ejecutar el pipeline de 6 pruebas de seguridad y documentar los hallazgos.)*
5. *(Completar: corregir las vulnerabilidades y verificar el pipeline en verde.)*
6. *(Completar: calcular los riesgos y documentar las pruebas realizadas.)*

## 3. Alcance, supuestos y reglas de compromiso

- **Alcance:** app móvil (cliente), servicio de cifrado (backend), Keycloak (IAM) y pipeline DevSecOps.
- **Supuestos:** entorno en la nube (Codespace) con Node 20 y Docker; repo público para CodeQL.
- **Reglas de compromiso:** los secretos del laboratorio son ficticios; no se suben secretos reales; el pentest se limita al entorno del laboratorio.

## 4. Metodología

*(Ciclo DevSecOps: detectar → corregir → volver a probar. Fase 1 diagnóstico con pipeline en rojo; Fase 2 remediación hasta verde. Marco: NIST SSDF, OWASP SAMM, OWASP ASVS.)*

## 5. Requerimientos de seguridad

> Ver **Tabla 1** completa en [`docs/tablas/tabla-1-requisitos.md`](docs/tablas/tabla-1-requisitos.md)

| Propiedad | Requisito | Control | Verificación |
|---|---|---|---|
| Confidencialidad | *(completar)* | *(completar)* | *(completar)* |
| Integridad | *(completar)* | *(completar)* | *(completar)* |
| Disponibilidad | *(completar)* | *(completar)* | *(completar)* |
| Autenticación | *(completar)* | *(completar)* | *(completar)* |

## 6. Amenazas (STRIDE)

> Ver **Tabla 2** completa en [`docs/tablas/tabla-2-stride.md`](docs/tablas/tabla-2-stride.md)

| Amenaza | Componente | Ejemplo de ataque | Control |
|---|---|---|---|
| Spoofing | *(completar)* | *(completar)* | *(completar)* |
| Tampering | *(completar)* | *(completar)* | *(completar)* |
| Repudiation | *(completar)* | *(completar)* | *(completar)* |
| Information disclosure | *(completar)* | *(completar)* | *(completar)* |
| Denial of service | *(completar)* | *(completar)* | *(completar)* |
| Elevation of privilege | *(completar)* | *(completar)* | *(completar)* |

## 7. Jerarquía de diseño

> Ver [`docs/jerarquia_diseno.md`](docs/jerarquia_diseno.md) — arquitectura, árbol de archivos, tabla de subsistemas y componentes críticos.

*(Insertar figura de la arquitectura: app móvil → servicio → Keycloak, con el pipeline revisando todo.)*

## 8. Configuración del entorno (paso a paso)

### 8.1 Entorno en la nube (Codespace)
1. Crear repo público `proyecto-devsecops-cib204`.
2. Abrir Codespace (2-core).
3. Verificar versiones: `node --version` (v20), `npm --version`, `docker --version`, `docker compose version`.

**Evidencia:** EV-C204-001 (versiones).

### 8.2 Levantar el servicio y Keycloak
```bash
docker compose up -d --build
docker compose ps
```
**Evidencia:** EV-C204-002 (`/salud` → `{"estado":"ok","version":"inseguro-1.0"}`).

### 8.3 Configurar Keycloak (IAM)
1. Consola admin (puerto 8080, admin/admin).
2. Crear realm `appmovil`.
3. Crear cliente `servicio-cifrado` (OpenID Connect, Direct access grants).
4. Crear usuario `demo` (perfil completo, contraseña no temporal).

**Evidencia:** EV-C204-003, EV-C204-004, EV-C204-005.

### 8.4 Probar la app móvil
```bash
bash iniciar-app.sh
```
Puerto 3000 en **Público**; pegar URL en la app; cifrar y descifrar.

**Evidencia:** EV-C204-006.

---

# PARTE II — IMPLEMENTACIÓN

## 9. Módulo de encriptación/desencriptación (RSA)

*(Descripción del módulo `cifrado.js`: RSA con padding OAEP, tamaño de llave, funciones de cifrado/descifrado. Justificación de la selección del algoritmo.)*

## 10. Funciones de utilidad

*(Validación de entrada, manejo de errores genéricos, codificación, bitácora. Cómo cada función de utilidad contribuye a la seguridad.)*

## 11. Autenticación con Keycloak (JWT)

*(Descripción de `auth.js`: cómo se valida el token JWT — firma, expiración, emisor, audiencia. Flujo: app pide token a Keycloak → lo envía al servicio → el servicio valida antes de cifrar/descifrar.)*

## 12. Pipeline DevSecOps (las 6 pruebas)

| Job | Tipo | Herramienta | Qué revisa |
|---|---|---|---|
| sast_semgrep | SAST | Semgrep | eval, inyección, JWT, CORS |
| sast_codeql | SAST | CodeQL | Análisis con motor de GitHub |
| secretos | Secretos | Gitleaks | Claves y contraseñas |
| sca | SCA | npm audit + Trivy | Dependencias vulnerables |
| imagen | Contenedor | Trivy + Syft | Fallas de imagen; SBOM |
| dast | DAST | OWASP ZAP | Cabeceras, CORS |

---

# PARTE III — DIAGNÓSTICO Y REMEDIACIÓN

## 13. Fase 1 — Diagnóstico (pipeline en rojo)

**Evidencia:** EV-C204-007 (jobs en rojo), EV-C204-008 a EV-C204-012 (reportes).

> Ver **Tabla 3** completa en [`docs/tablas/tabla-3-diagnostico.md`](docs/tablas/tabla-3-diagnostico.md)

| ID | Prueba | Componente | Hallazgo y CWE | Riesgo |
|---|---|---|---|---|
| H-01 | secretos | servidor/.env | Secretos quemados (CWE-798) | Alto |
| H-02 | sca | servidor/package.json | Librería vulnerable (CWE-1104) | Alto |
| ... | ... | ... | ... | ... |

## 14. Fase 2 — Remediación (de rojo a verde)

> Ver **Tabla 4** completa en [`docs/tablas/tabla-4-evidencias.md`](docs/tablas/tabla-4-evidencias.md)

| Hallazgo | Job | Antes | Corrección | Después |
|---|---|---|---|---|
| Secretos quemados | secretos | Rojo | Variables de entorno | Verde |
| ... | ... | ... | ... | ... |

### 14.1 Registro de commits
| Commit | Mensaje | Hallazgo |
|---|---|---|
| *(hash)* | Corrige secretos | H-01 |
| ... | ... | ... |

**Evidencia:** EV-C204-013 (pipeline en verde).

## 15. Protección de la rama principal

*(Branch protection en `main`: requerir PR con revisión y status checks de los 6 jobs.)*

**Evidencia:** EV-C204-014.

---

# PARTE IV — PRUEBAS Y RIESGOS

## 16. Cálculo de riesgo

> Ver **Tabla 5** completa en [`docs/tablas/tabla-5-riesgo.md`](docs/tablas/tabla-5-riesgo.md)

Riesgo = Probabilidad × Impacto (escala 1–3). *(Incluir el registro completo y el análisis ALE.)*

## 17. Documentación de pruebas

> Ver **Tabla 6** completa en [`docs/tablas/tabla-6-pruebas.md`](docs/tablas/tabla-6-pruebas.md)

*(Pruebas funcionales, del pipeline, de pentest y automatizadas, con datos de entrada, esperado y real.)*

## 18. Plantilla de diagnóstico del curso

> Ver [`docs/plantilla-diagnostico.md`](docs/plantilla-diagnostico.md) — registro completo de vulnerabilidades con CWE, severidad y cálculo de riesgo.

---

# PARTE V — CIERRE ACADÉMICO

## 19. Resumen de resultados

*(Vulnerabilidades identificadas, riesgos asociados, efectividad de las medidas implementadas. Pipeline de rojo a verde.)*

## 20. Conclusiones

*(Evaluación de la seguridad de la aplicación móvil y lecciones aprendidas del ciclo DevSecOps.)*

## 21. Recomendaciones

*(Medidas de seguridad adicionales: rotación de llaves, monitoreo, pruebas continuas, hardening adicional.)*

## 22. Referencias

- Helfrich, J. (2019). *Security for Software Engineers*. Taylor & Francis Group.
- Johnsson, D., Deogun, D. y Sawano, D. (2019). *Secure by Design*. Manning Publications.
- Hoffman, A. (2020). *Web Application Security*. O'Reilly Media.
- OWASP SAMM, NIST SSDF, OWASP ASVS, OWASP ZAP, Semgrep, Gitleaks, Trivy, Syft, CodeQL.

---

## Anexos

- **Anexo A:** Tablas 1–6 completas
- **Anexo B:** Reportes del pipeline (Semgrep, Gitleaks, SBOM, ZAP, CodeQL)
- **Anexo C:** Manifiesto SHA-256 de evidencias
- **Anexo D:** Historial de versiones del repositorio
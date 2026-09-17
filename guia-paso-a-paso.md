# Guía paso a paso — Proyecto DevSecOps CIB-204

Plan completo del laboratorio con **mapeo explícito a la rúbrica del curso** (45 puntos del proyecto, 40% de la nota). Cada paso indica qué entregable produce y qué criterio de la rúbrica excede.

> 📘 **Trazabilidad completa:** la [lista de validación de objetivos](docs/validacion-objetivos.md) mapea cada objetivo del curso, entregable y criterio de rúbrica a dónde se desarrolla y cómo se excede.

---

## Mapa de entregas y rúbrica

| # | Paso del laboratorio | Entregable | Criterio de rúbrica (puntos) |
|---|---|---|---|
| 1 | Crear cuenta de GitHub | — | — |
| 2 | Crear repo público + subir material | Repo con pipeline en Actions | Avances del proyecto (5) |
| 3 | Entorno en la nube (Codespace) | Captura de versiones | Configuración del entorno (5) |
| 4 | Requisitos de seguridad | **Tabla 1** | Requerimientos de seguridad (5) |
| 5 | Amenazas STRIDE | **Tabla 2** | Requerimientos de seguridad (5) |
| 6 | Jerarquía de diseño | `docs/jerarquia_diseno.md` | Requerimientos (5) + Informe (5) |
| 7 | Levantar servicio + Keycloak | Capturas de contenedores | Configuración del entorno (5) |
| 8 | Configurar IAM en Keycloak | Capturas (realm, cliente, usuario) | Configuración del entorno (5) |
| 9 | Probar app móvil (cifrar/descifrar) | Captura de la app | Módulo encriptación (5) + RSA (5) |
| 10 | **FASE 1**: pipeline en rojo | **Tabla 3** + reportes descargados | Revisión del código (5) |
| 11 | **FASE 2**: corregir a verde | **Tabla 4** (antes/después) | Pruebas y ajustes (5) + Avances (5) |
| 12 | Pentest + pruebas de código | **Tabla 5** (riesgo) + **Tabla 6** (pruebas) | Pruebas y ajustes (5) |
| 13 | Proteger rama principal | Repo con branch protection | Avances del proyecto (5) |
| 14 | Informe final en PDF | `docs/informe-maestro.md` → PDF | Informe del proyecto (5) |

**Total rúbrica: 45 puntos.** Este plan apunta a **exceder** cada criterio (columna "Excede el criterio" = 5 puntos).

---

## Fase 0 — Preparación (antes de tocar código)

### Paso 1. Cuenta de GitHub
- [ ] Cuenta creada en github.com (ya existe: `edovega`)
- [ ] (Opcional) GitHub Student Developer Pack — más horas de Codespaces/Actions

### Paso 2. Repositorio y material
- [ ] Repo `proyecto-devsecops-cib204` **público** (creado ✅)
- [ ] Material oficial (`proyecto-devsecops-cib204.zip`) integrado en `servidor/` y `app-movil/`
- [ ] Subir material con `git add -A && git commit && git push` (conserva `.github/` y `.devcontainer/`)
- [ ] Verificar en Actions que el pipeline arrancó (6 jobs)

> ⚠️ **NUNCA** subir con "Add file → Upload files" del navegador: se salta las carpetas ocultas (`.github/`, `.devcontainer/`) y sin `.github/` el pipeline no se ejecuta.

### Paso 3. Entorno en la nube (Codespace)
- [ ] Abrir Codespace en el repo (2-core)
- [ ] Verificar: `node --version` (v20), `npm --version`, `docker --version`, `docker compose version`
- [ ] **📸 Evidencia:** captura de versiones → `docs/evidencias/capturas/EV-C204-001-versiones.txt`

---

## Primer Avance — Análisis y diseño

### Paso 4. Tabla 1 — Requisitos de seguridad
Completar en [`docs/tablas/tabla-1-requisitos.md`](docs/tablas/tabla-1-requisitos.md).

Las 4 propiedades (CIA + autenticación), cada una con: requisito, control que lo implementa y cómo se verifica.

**Para exceder:** justificar el *porqué* de cada requisito (OWASP SAMM, NIST SSDF) y agregar una 5.ª fila con **no repudio** (bitácora) si aplica.

### Paso 5. Tabla 2 — Amenazas STRIDE
Completar en [`docs/tablas/tabla-2-stride.md`](docs/tablas/tabla-2-stride.md).

Las 6 amenazas (Spoofing, Tampering, Repudiation, Information disclosure, DoS, Elevation of privilege), cada una con: componente afectado, ejemplo de ataque y control/mitigación.

**Para exceder:** agregar columna de *severidad estimada* y *cómo se verifica el control* (prueba concreta).

### Paso 6. Jerarquía de diseño
Completar en [`docs/jerarquia_diseno.md`](docs/jerarquia_diseno.md).

- Diagrama de las 3 capas (app móvil, servicio, IAM) + pipeline
- Árbol de carpetas y archivos
- Tabla de subsistemas con: función, datos que maneja, superficie de ataque, propensión a fallar

**Para exceder:** descomponer cada subsistema en componentes y marcar los críticos (los que tocan datos sensibles o interactúan con externos).

### Paso 7. Levantar el servicio y Keycloak
```bash
docker compose up -d --build
docker compose ps          # ambos "running"
# Puerto 3000 + /salud → {"estado":"ok","version":"inseguro-1.0"}
```
- [ ] **📸 Evidencia:** captura de `docker compose ps` y `/salud`

### Paso 8. Configurar Keycloak (IAM)
- [ ] Consola admin (puerto 8080, admin/admin)
- [ ] Crear realm `appmovil`
- [ ] Crear cliente `servicio-cifrado` (OpenID Connect, Direct access grants)
- [ ] Crear usuario `demo` (email, nombre, apellido, email verificado, contraseña no temporal)
- [ ] **📸 Evidencia:** capturas del realm, cliente y usuario

> ⚠️ El perfil debe estar COMPLETO o el login falla con "Account is not fully set up".

### Paso 9. Probar la app móvil
```bash
bash iniciar-app.sh        # entra a app-movil/, instala y arranca Expo (puerto 8081)
```
- [ ] Puerto 3000 en **Público** (Port Visibility → Public)
- [ ] Pegar URL del 3000 en la app, cifrar y descifrar
- [ ] **📸 Evidencia:** captura de la app con "Cifrado OK" y "Descifrado OK"

---

## Segundo Avance — Diagnóstico y remediación

### Paso 10. FASE 1 — Pipeline en rojo (diagnóstico)
- [ ] En Actions, abrir la ejecución más reciente
- [ ] Identificar los jobs en rojo (esperado: SAST-Semgrep, Secretos, SCA, Imagen)
- [ ] Abrir el log de cada paso con ✖ (componente, severidad, CWE/CVE)
- [ ] Descargar artefactos: reportes Semgrep, Gitleaks, SBOM, informe ZAP
- [ ] CodeQL: revisar "Security → Code scanning" (alertas)
- [ ] DAST: abrir el artefacto `reporte-zap` (cabeceras ausentes, CORS abierto)
- [ ] Completar **Tabla 3** en [`docs/tablas/tabla-3-diagnostico.md`](docs/tablas/tabla-3-diagnostico.md) (~12 hallazgos)
- [ ] **📸 Evidencia:** capturas de los jobs en rojo + reportes en `docs/evidencias/`

### Paso 11. FASE 2 — Corregir de rojo a verde (remediación)
> 📘 Usa el **[playbook de remediación](docs/remediacion-playbook.md)**: cada hallazgo esperado tiene su patrón de corrección (secretos, eval, JWT, CORS, errores, imagen, cabeceras) con mejores prácticas.

Orden sugerido de corrección (cada una = commit + push + verificación):

| # | Hallazgo | Job | Corrección típica |
|---|---|---|---|
| 1 | Secretos quemados | secretos | Quitar `.env` y llaves; variables de entorno |
| 2 | Dependencias vulnerables | sca | `npm audit fix` / actualizar versiones |
| 3 | `eval()` / inyección | sast_semgrep | Eliminar eval; validar entradas |
| 4 | JWT mal validado | sast_semgrep | Verificar firma, expiración, emisor en `auth.js` |
| 5 | CORS abierto | sast_semgrep + dast | Restringir orígenes |
| 6 | Errores internos expuestos | sast_semgrep | Errores genéricos |
| 7 | Imagen con fallas / root | imagen | Base segura, usuario no-root |
| 8 | Cabeceras de seguridad | dast | CSP, X-Frame-Options, etc. |

- [ ] Completar **Tabla 4** en [`docs/tablas/tabla-4-evidencias.md`](docs/tablas/tabla-4-evidencias.md) — hallazgo, job, antes, qué hiciste, después
- [ ] **📸 Evidencia:** captura del pipeline en VERDE (todos los jobs ✔)

### Paso 12. Pentest y pruebas de código
- [ ] Pruebas de manipulación (dato alterado no se descifra)
- [ ] Pruebas de entrada vacía / muy larga
- [ ] Pruebas con y sin token (autenticación)
- [ ] Completar **Tabla 5** en [`docs/tablas/tabla-5-riesgo.md`](docs/tablas/tabla-5-riesgo.md) — cálculo probabilístico de riesgo (probabilidad × impacto)
- [ ] Completar **Tabla 6** en [`docs/tablas/tabla-6-pruebas.md`](docs/tablas/tabla-6-pruebas.md) — descripción, datos de entrada, esperado, real

**Para exceder:** usar la plantilla de diagnóstico del curso (`docs/plantilla-diagnostico.md`) y calcular riesgo con método probabilístico documentado (frecuencia estimada, impacto en $, ALE/SLE si aplica).

### Paso 13. Proteger la rama principal
- [ ] Settings → Branches → Add rule para `main`
- [ ] Require pull request reviews before merging
- [ ] Require status checks to pass (los 6 jobs del pipeline)

---

## Informe Final

### Paso 14. Informe integrado en PDF
- [ ] Consolidar todas las tablas en [`docs/informe-maestro.md`](docs/informe-maestro.md)
- [ ] Estructura: Introducción → Desarrollo → Resumen de resultados → Conclusiones → Recomendaciones
- [ ] Convertir a PDF para la entrega formal
- [ ] Adjuntar código fuente (este repo es el sistema de control de versiones)

---

## Checklist final de entrega

- [ ] Pipeline en **VERDE** (6/6 jobs ✔)
- [ ] Tablas 1–6 completas en `docs/tablas/`
- [ ] Evidencias con manifiesto SHA-256 en `docs/evidencias/`
- [ ] Rama `main` protegida
- [ ] Informe en PDF con todas las tablas consolidadas
- [ ] Repo público accesible para el docente
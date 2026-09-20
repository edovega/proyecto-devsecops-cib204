# DevSecOps CIB-204 — Pipeline de Seguridad para Aplicaciones Móviles

Proyecto final del curso **CIB-204 · Seguridad del Software** (Maestría en Ciberseguridad, Universidad CENFOTEC).

Aplicación móvil que **cifra y descifra datos** (RSA) con un servicio backend en **Node.js**, identidad gestionada por **Keycloak**, y un **pipeline DevSecOps** (GitHub Actions) que detecta y verifica la corrección de vulnerabilidades reales en cada cambio.

> 🎓 **La idea clave de DevSecOps:** lo valioso no es solo encontrar los errores, sino el ciclo automático **encontrar → corregir → volver a probar**. Este repositorio vive ese ciclo completo: el proyecto arranca **inseguro a propósito** y se corrige paso a paso hasta dejar el pipeline en verde.

## 📚 Documento oficial del proyecto

| Entregable | Peso | Documento |
|---|---|---|
| **Informe integrado** (primer avance + segundo avance + informe final) | 40% | [`docs/informe-maestro.md`](docs/informe-maestro.md) — sigue la plantilla del curso con sistema de evidencias, trazabilidad y análisis de riesgos |
| **Tablas de entrega** | — | [`docs/tablas/`](docs/tablas/) — Tablas 1 a 6 (requisitos, STRIDE, diagnóstico, antes/después, riesgo, pruebas) |
| **Evidencias** | — | [`docs/evidencias/`](docs/evidencias/) — manifiesto SHA-256, capturas y figuras |
| **Guía del proyecto** | — | [`guia-paso-a-paso.md`](guia-paso-a-paso.md) — plan completo y mapa de la rúbrica |
| **Plan de acción** | — | [`docs/plan-de-accion.md`](docs/plan-de-accion.md) — cobertura de la rúbrica: herramientas, acciones, evidencia y verificación por criterio |
| **Validación de objetivos** | — | [`docs/validacion-objetivos.md`](docs/validacion-objetivos.md) — trazabilidad completa: cada objetivo del curso, entregable y criterio de rúbrica → dónde se desarrolla → cómo se excede |
| **Playbook de remediación** | — | [`docs/remediacion-playbook.md`](docs/remediacion-playbook.md) — corrección de cada hallazgo esperado de la Fase 2 (secretos, eval, JWT, CORS, imagen, cabeceras) |
| **Datos del curso** | — | [`docs/datos-del-curso.md`](docs/datos-del-curso.md) — datos validados del curso, docente e integrantes |

## 🏗️ Estructura del repositorio

```
proyecto-devsecops-cib204
│
├─ 1. App móvil (cliente)          [app-movil/]
│   └─ App.js ......... cifrar/descifrar; maneja el token
│
├─ 2. Servicio de cifrado          [servidor/]
│   ├─ servidor.js ... API (/salud, /cifrar, /descifrar, ...)
│   ├─ cifrado.js .... módulo RSA
│   ├─ auth.js ....... revisa el token (identidad)
│   ├─ db.js ......... consulta la bitácora
│   └─ Dockerfile .... imagen del contenedor
│
├─ 3. IAM                          [docker-compose.yml]
│   └─ keycloak ...... entrega y valida tokens
│
├─ 4. Pipeline DevSecOps           [.github/workflows/devsecops.yml]
│   └─ 6 pruebas de seguridad automáticas
│
├─ 5. Entorno en la nube           [.devcontainer/]
│   └─ Codespace con Node 20 y Docker listos
│
└─ 6. Documentación                [docs/]
    ├─ informe-maestro.md ..... informe integrado (entregas)
    ├─ jerarquia_diseno.md .... jerarquía de diseño y subsistemas
    ├─ plantilla-diagnostico.md plantilla de diagnóstico del curso
    ├─ validacion-objetivos.md  trazabilidad objetivos → dónde → cómo excede
    ├─ remediacion-playbook.md  correcciones de la Fase 2
    ├─ plan-de-accion.md ....... cobertura de la rúbrica
    ├─ datos-del-curso.md ...... datos del curso, docente e integrantes
    ├─ tablas/ ................ Tablas 1–6
    └─ evidencias/ ............ capturas, figuras y manifiesto SHA-256
```

## 🔄 Las dos fases del laboratorio

| Fase | Qué haces | Resultado |
|---|---|---|
| **Fase 1 — Diagnóstico** | Subes el proyecto tal cual (inseguro), dejas que el pipeline se ejecute y anotas todo lo que aparece en rojo | Tabla 3 (diagnóstico) + reportes descargados |
| **Fase 2 — Remediación** | Corriges cada error, subes el cambio y ves cómo la prueba pasa de rojo a verde | Tabla 4 (antes/después) + pipeline en verde |

## 🧪 Las 6 pruebas del pipeline

| Prueba (job) | Tipo | Qué revisa | Herramienta |
|---|---|---|---|
| `sast_semgrep` | SAST | Errores en el código (eval, inyección, JWT, CORS) | Semgrep |
| `sast_codeql` | SAST | Lo mismo, con el motor de GitHub | CodeQL |
| `secretos` | Secretos | Claves y contraseñas subidas por error | Gitleaks |
| `sca` | SCA | Librerías (dependencias) con fallas conocidas | npm audit + Trivy |
| `imagen` | Contenedor | Fallas de la imagen Docker; genera el SBOM | Trivy + Syft |
| `dast` | DAST | Ataca la app viva (cabeceras, CORS) | OWASP ZAP |

> ℹ️ **CodeQL corre por «default setup» de GitHub**, no como job del workflow (los dos modos no pueden coexistir). Por eso el workflow tiene **5 jobs** y CodeQL analiza `javascript-typescript` y `actions` en cada push desde *Settings → Code security*. Detalle y justificación en el informe §8.6 y §12.1. El repositorio es **público** (requisito de CodeQL gratuito).

## 🚀 Inicio rápido (en el Codespace)

```bash
# 1. Verificar el entorno
node --version && npm --version && docker --version && docker compose version

# 2. Probar el servicio de cifrado
cd servidor && npm install && node prueba.js && npm test && cd ..

# 3. Levantar el servicio y Keycloak
docker compose up -d --build && docker compose ps

# 4. Iniciar la app móvil
bash iniciar-app.sh
```

## ✅ Criterios de la rúbrica que este repositorio busca EXCEDER

| Criterio (rúbrica) | Cómo se excede aquí |
|---|---|
| Requerimientos de seguridad | Tabla 1 con justificación por propiedad (CIA + autenticación) y control verificable |
| Configuración del entorno | `.devcontainer` reproducible + guía paso a paso + evidencia de versiones |
| Módulo de encriptación/desencriptación | Servicio Node.js con RSA (OAEP) + pruebas automatizadas |
| Funciones de utilidad | Validación de entrada, manejo de errores genéricos, bitácora |
| Algoritmo RSA | Implementación sin errores verificada por pruebas y SAST |
| Revisión del código | 3 herramientas SAST (Semgrep, CodeQL, ESLint) + reportes descargados |
| Pruebas y ajustes | 6 pruebas del pipeline + pruebas unitarias + pentest + Tabla 6 |
| Avances del proyecto | Trazabilidad de correcciones en Tabla 4 (antes/después) |
| Informe del proyecto | Informe integrado con evidencias SHA-256, riesgos y conclusiones |

## 📄 Nota sobre el material oficial

El material oficial del laboratorio (`proyecto-devsecops-cib204.zip`) ya está integrado en `servidor/`, `app-movil/` y los archivos de configuración (commit `9b1bddb`), y el servicio fue remediado en la Fase 2. La documentación, las tablas y el sistema de evidencias ya están listos en `docs/`.

## Licencia

MIT — ver [`LICENSE`](LICENSE).
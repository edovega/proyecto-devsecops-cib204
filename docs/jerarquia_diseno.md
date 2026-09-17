# Jerarquía de diseño — Sistema de cifrado seguro

> 📄 **Primer Avance.** Muestra la estructura general de la aplicación y la relación entre módulos y componentes.

## Arquitectura de la solución

```
┌─────────────────────────────────────────────────────────────────────┐
│                        APP MÓVIL (cliente)                          │
│                        [app-movil/]                                 │
│              App.js — cifrar/descifrar; maneja el token             │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ HTTPS (JWT Bearer)
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    SERVICIO DE CIFRADO (backend)                    │
│                        [servidor/]                                  │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌──────────────────┐  │
│  │ servidor.js│ │ cifrado.js│ │  auth.js  │  │      db.js       │  │
│  │ API REST   │ │ módulo RSA│ │ valida JWT│  │ bitácora (logs)  │  │
│  └───────────┘  └───────────┘  └───────────┘  └──────────────────┘  │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │ Dockerfile — imagen del contenedor (no-root en Fase 2)       │   │
│  └──────────────────────────────────────────────────────────────┘   │
└──────────────┬──────────────────────────────┬───────────────────────┘
               │                              │
               │ valida token                 │ entrega token
               ▼                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        IAM — KEYCLOAK                               │
│                    [docker-compose.yml]                             │
│              Entrega y valida tokens (realm appmovil,               │
│              cliente servicio-cifrado, usuario demo)                │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│              PIPELINE DevSecOps [.github/workflows/devsecops.yml]   │
│  sast_semgrep · sast_codeql · secretos · sca · imagen · dast        │
│  Revisa TODO el sistema en cada cambio (push)                       │
└─────────────────────────────────────────────────────────────────────┘
```

## Árbol de carpetas y archivos

```
Sistema de cifrado seguro
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
└─ 4. Pipeline DevSecOps           [.github/workflows/]
    └─ devsecops.yml . las pruebas de seguridad
```

## Tabla de subsistemas

| Subsistema | Archivos | Función | Datos que maneja | Superficie de ataque | Propensión a fallar |
|---|---|---|---|---|---|
| App móvil | `app-movil/App.js` | Cifrar/descifrar; maneja el token | Texto plano, token JWT | Alta (expuesta al usuario) | Media |
| API de cifrado | `servidor/servidor.js` | Endpoints `/salud`, `/cifrar`, `/descifrar` | Texto cifrado, tokens | **Alta** (expuesta a red) | **Alta** |
| Módulo RSA | `servidor/cifrado.js` | Cifrado/descifrado RSA-OAEP | Llaves, texto | Media | Media |
| Autenticación | `servidor/auth.js` | Valida token JWT | Tokens | **Alta** (control de acceso) | **Alta** |
| Bitácora | `servidor/db.js` | Registra operaciones | Registros | Media | Media |
| IAM | `docker-compose.yml` / Keycloak | Entrega y valida tokens | Credenciales | **Alta** | Media |
| Pipeline | `.github/workflows/devsecops.yml` | Pruebas de seguridad | Reportes | Baja | Baja |

## Componentes críticos (más propensos a fallar)

Según la rúbrica, se analizan considerando: **complejidad del código, frecuencia de uso, exposición a datos sensibles e interacción con componentes externos**.

| # | Componente | Complejidad | Frecuencia | Datos sensibles | Interacción externa | ¿Crítico? |
|---|---|---|---|---|---|---|
| 1 | `servidor.js` (API) | Media | Alta | Sí (texto cifrado) | Sí (red, Keycloak) | ✅ Sí |
| 2 | `auth.js` (JWT) | Media | Alta | Sí (tokens) | Sí (Keycloak) | ✅ Sí |
| 3 | `cifrado.js` (RSA) | Alta | Media | Sí (llaves) | No | ✅ Sí |
| 4 | `db.js` (bitácora) | Baja | Media | Parcial | No | No |
| 5 | `App.js` (móvil) | Media | Alta | Sí (texto plano) | Sí (servicio) | ✅ Sí |
| 6 | Keycloak | Alta | Media | Sí (credenciales) | Sí (servicio) | ✅ Sí |

## Modos de fallo por componente

| Componente | Modo de fallo | Consecuencia | Mitigación |
|---|---|---|---|
| API | Entrada malformada | 500 / caída | Validación de entrada |
| API | CORS abierto | Uso por terceros | Restringir orígenes |
| auth.js | Token no validado | Acceso sin identidad | Verificar firma/expiración |
| cifrado.js | Llave débil | Cifrado rompible | RSA-2048 mínimo |
| Contenedor | Ejecuta como root | Escalada | Usuario no-root |
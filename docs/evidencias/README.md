# Evidencias — Proyecto DevSecOps CIB-204

Sistema de evidencias con **manifiesto SHA-256** (misma metodología que BóvedaSegura): cada archivo de evidencia se registra con su hash para demostrar integridad y trazabilidad.

## Estructura

```
evidencias/
├── manifiesto-sha256.txt   ← hashes de todas las evidencias
├── capturas/               ← capturas de terminal, pipeline y reportes
└── figuras/                ← diagramas (SVG) de la arquitectura
```

## Cómo registrar una evidencia nueva

```bash
# 1. Coloca el archivo en capturas/ (o figuras/)
# 2. Actualiza el manifiesto:
cd docs/evidencias
sha256sum capturas/* figuras/* > manifiesto-sha256.txt
```

## Cómo verificar la integridad

```bash
cd docs/evidencias
sha256sum -c manifiesto-sha256.txt
# Resultado esperado: todos los archivos "OK"
```

## Índice de evidencias planificado

| ID | Evidencia | Estado |
|---|---|---|
| EV-C204-001 | Versiones del entorno (node, npm, docker) | ⏳ pendiente |
| EV-C204-002 | Servicio `/salud` respondiendo | ⏳ pendiente |
| EV-C204-003 | Keycloak: realm appmovil | ⏳ pendiente |
| EV-C204-004 | Keycloak: cliente servicio-cifrado | ⏳ pendiente |
| EV-C204-005 | Keycloak: usuario demo | ⏳ pendiente |
| EV-C204-006 | App móvil cifrando/descifrando | ⏳ pendiente |
| EV-C204-007 | Pipeline Fase 1 (jobs en rojo) | ⏳ pendiente |
| EV-C204-008 | Reporte Semgrep (Fase 1) | ⏳ pendiente |
| EV-C204-009 | Reporte Gitleaks (Fase 1) | ⏳ pendiente |
| EV-C204-010 | SBOM (Fase 1) | ⏳ pendiente |
| EV-C204-011 | Informe ZAP (Fase 1) | ⏳ pendiente |
| EV-C204-012 | Alertas CodeQL (Code scanning) | ⏳ pendiente |
| EV-C204-013 | Pipeline Fase 2 (todo verde) | ⏳ pendiente |
| EV-C204-014 | Rama main protegida | ⏳ pendiente |
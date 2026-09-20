# Evidencias — Proyecto DevSecOps CIB-204

Sistema de evidencias con **manifiesto SHA-256**: cada archivo de evidencia se registra con su hash para demostrar integridad y trazabilidad.

## Estructura

```
docs/evidencias/
├── manifiesto-sha256.txt   ← hashes (rutas relativas a la RAÍZ del repositorio)
├── capturas/               ← reportes, transcripciones y zips (EV-C204-008 a 029)
│   └── consola-git/        ← 19 capturas de pantalla del equipo (EV-C204-033 a 051) + copias del PPTX/PDF
├── figuras/                ← diagramas SVG de la arquitectura (EV-C204-015 a 017)
├── informe-maestro.docx / .pdf   ← informe final renderizado desde docs/informe-maestro.md
└── INSTRUCCIONES-CAPTURA.md      ← paso a paso de lo que falta capturar
```

## Referencia de run verde

`RUN_VERDE=35442482331` — commit de código `0fc1c11`, 5/5 jobs en verde, CodeQL sin alertas abiertas. Los reportes EV-C204-008 a 011 son **byte-idénticos** a los archivos generados de ese run.

## Cómo verificar (desde la raíz del repositorio)

```bash
sha256sum --check docs/evidencias/manifiesto-sha256.txt        # esperado: todos «OK»
bash scripts/verificar-evidencia.sh 35442482331                 # reportes == archivos generados del run (requiere gh)
```

## Cómo regenerar tras un cambio

```bash
bash scripts/instalar-evidencia.sh <RUN_ID>   # instala los reportes de un run verde y regenera EV-025, 026 y 029
bash scripts/generar-informe.sh               # regenera informe-maestro.docx y .pdf desde el .md
bash scripts/generar-manifiesto.sh            # regenera el manifiesto SHA-256
```

## Índice de evidencias

| ID | Evidencia | Estado |
|---|---|---|
| EV-C204-001 | Versiones del entorno (node, npm) | ✅ `consola-git/EV-C204-046-…png` |
| EV-C204-001b | Versión de Docker en el Codespace corregido (29.8.1) | ✅ |
| EV-C204-002 | Servicio `/salud` respondiendo | ✅ captura (`.jpeg`) + transcripción EV-C204-023 |
| EV-C204-003 a 004 | Keycloak: realm y cliente | ✅ capturas de la consola + API (EV-C204-023) |
| EV-C204-005 | Keycloak: usuario `demo` | ✅ captura + API |
| EV-C204-006 | App móvil cifrando/descifrando | ✅ captura |
| EV-C204-007 | Pipeline Fase 1 (jobs en rojo) | ✅ `consola-git/` (informe §13) |
| EV-C204-008 a 011 | Reportes Semgrep, Gitleaks, SBOM y ZAP del **run verde** | ✅ |
| EV-C204-012 | Alertas CodeQL | ✅ captura + EV-C204-025 |
| EV-C204-013 | Pipeline Fase 2 (todo verde) | ✅ captura + transcripción EV-C204-026 |
| EV-C204-014 | Rama `main` protegida | ✅ captura + EV-C204-030 (configuración por API) |
| EV-C204-015 a 017 | Figuras | ✅ |
| EV-C204-018 / 019 | PPTX y PDF de capturas | ✅ |
| EV-C204-020 a 022 | Reportes de la **Fase 1** (zips) | ✅ |
| EV-C204-023 | Pruebas extremo a extremo con Keycloak | ✅ |
| EV-C204-024 | Pruebas Jest, ESLint y npm audit | ✅ |
| EV-C204-025 | Alertas y análisis CodeQL | ✅ |
| EV-C204-026 | Run verde de referencia | ✅ |
| EV-C204-027 / 028 | SBOM y log de la Fase 1 | ✅ |
| EV-C204-029 | Historial de ejecuciones | ✅ |
| EV-C204-031 | Contribuidores del repositorio (Insights → Contributors) | ✅ |
| EV-C204-033 a 051 | 19 capturas de pantalla individualizadas | ✅ (informe, Anexo I) |

# Auditoría de convergencia FIX-18 — Instrucciones para IA externa

> Documento **autocontenido** para que un auditor de IA (Claude, OpenAI u otro
> modelo con una **instancia clonable/ya-clonada del repo Git** y **acceso de
> solo-lectura a los directorios locales indicados**) pueda **re-verificar por
> bytes** lo afirmado, en lugar de confiar en este texto. Todo comando de
> verificación está escrito **explícitamente abajo**; las únicas "afirmaciones"
> que deben darse por ciertas son las que el propio comando reproduce sobre
> disco.

---

## 1. Contexto y objetivo (por qué / para qué existe este documento)

- **Objetivo del pipeline (FIX-18 / EV-C204-008..011):** demostrar, con
  **evidencia byte-verificable**, que el pipeline DevSecOps de CIB-204
  converge a **verde** tras corregir los hallazgos de seguridad (Semgrep /
  Gitleaks / SBOM / ZAP), y que cada artefacto de ese run verde queda
  **instalado en el repositorio** con su **SHA-256 real** en un manifiesto
  canónico.
- **Objetivo de este anexo:** que una IA con acceso a disco y al repo Git
  confirme **por sus propios medios** (comandos reales) que:
  1. El run es **verde** (`success`) y corresponde al commit instalado.
  2. Los 4 reportes instalados son **byte-idénticos** a los artefactos de ese run.
  3. Las 19 capturas de la consola Git del estudiante (extraídas del PPT)
     existen **una por slide**, en su área correspondiente.
  4. El manifiesto SHA-256 es **consistente byte a byte** con el disco.
- **Por qué es así:** la tarea lo exige (informe maestro §12.x, FIX-18); permite
  auditoría externa **sin depender de ninguna afirmación** de este chat.

---

## 2. Rutas reales de acceso (dónde está todo)

| Qué | Ruta local / repo |
|---|---|
| Repo Git (trabajo/cierre) | `/tmp/opencode/work/proyecto` (rama `main`) |
| Copia de seguridad de artefactos descargados (feria) | `/tmp/artifacts_feria_*` |
| Descarga final byte-verificada del run | `/tmp/artifacts_final/` |
| Capturas del estudiante (origen, NO copiar en repo) | `/home/evega/Downloads/nuevo/` |
| Evidencias instaladas (repo) | `docs/evidencias/capturas/` |
| 19 slides de consola Git (repo) | `docs/evidencias/capturas/consola-git/EV-C204-033..051-*.png` |
| Manifiesto canónico (repo) | `docs/evidencias/manifiesto-sha256.txt` |
| Informe maestro | `docs/informe-maestro.md` |

---

## 3. Procedimiento determinista de re-verificación (cómo auditar)

Ejecutar **desde la raíz del repo** (cwd = raíz del clone, no un subdirectorio):

```bash
# A) ¿El run es verde y coincide con el commit instalado?
git log -1 --format='%H %s'
gh run list --branch main --limit 3 --json headSha,status,conclusion,databaseId
#    → buscar el run con headSha == el commit de arriba; esperar status=completed,
#      conclusion=success

# B) ¿Reportes instalados == artefactos del run verde? (byte, no contar palabras)
gh run download <ID-del-run-verde> --dir /tmp/audit_descarga
sha256sum /tmp/audit_descarga/*/EV-C204-008-semgrep.json \
         /tmp/audit_descarga/*/EV-C204-009-gitleaks.json \
         /tmp/audit_descarga/*/EV-C204-010-sbom.json \
         /tmp/audit_descarga/*/EV-C204-011-zap.html
# comparar visualmente contra el manifiesto canónico (hash de la fila EV-C204)

# C) ¿El manifiesto canónico es byte-consistente con el disco? (exit real)
sha256sum --check docs/evidencias/manifiesto-sha256.txt 2>&1 | tail -3
#    → esperado: todos ': OK' excepto la autolista (línea del propio manifiesto,
#    que se excluye deliberadamente; comportamiento canónico documentado)

# D) ¿Cada slide existe, uno por uno, en su área? (conteo real)
find docs/evidencias/capturas/consola-git -name 'EV-C204-*.png' | wc -l
#    → esperado: 19 (EV-C204-033..051). Cada área del informe cita su slide
#    (sección 12.x / Anexo I), con evidencia individual, no una sola captura global.
```

**Sobre los 3 zips reportes (014..016):** son los artefactos descargados del
run (no se re-inventan); su contenido se puede abrir con `unzip -l` para
confirmar que contienen los `.json`/`.html` ya instalados.

---

## 4. Qué debe reportar el auditor

1. **Convergencia (SÍ/NO + prueba):** run verde + hashes byte-idénticos (B) +
   manifiesto `--check` OK salvo autolista (C) + 19 slides individuales (D).
2. Si algún paso **no** da lo esperado: citar el comando y el hash obtenido.
3. Cualquier **evidencia de la lista EV-C204-008..016 SIN byte-real** en disco → reportarla como **falta de convergencia**, no repararla (el auditor es **externo**; el cierre lo hace el equipo).

---

## 5. Honestidad / límites declarados

- Este texto **no deriva hashes ni nombres de archivos**: los hashes de las
  evidencias reales viven **únicamente** en `docs/evidencias/manifiesto-sha256.txt`
  (regenerado desde el disco con `sha256sum`) y el auditor los **re-obtiene por
  comando** en la sección 3. Cualquier hash citado aquí que no corresponda a un
  archivo que exista byte-real en disco es un **error a denunciar**, no a asumir.
- El estudiante hizo el PPT (`Capturas.pptx`) con sus 5 slides de consola Git;
  este anexo los **extrae del PPT como ZIP** (los `ppt/media/image*.png` son
  byte-reales en el repo) — si algún slide no estuviera, el auditor lo debe
  marcar y el estudiante lo entregará por slide individual con su nombre.
- El informe maestro y los artefactos se importaron de la rama `main` del run
  verde; ninguna ruta fuera de `docs/` fue añadida al commit.

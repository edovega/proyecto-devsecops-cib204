# Playbook de remediación — Fase 2 (de rojo a verde)

> Guía de corrección para cada tipo de hallazgo esperado en la Fase 1. Con el zip oficial ya integrado, cada hallazgo real de la Tabla 3 se cruzó con el patrón correspondiente y se aplica la corrección. **Un commit por corrección**, con mensaje descriptivo, y verificación en Actions.

---

## Orden de corrección recomendado (por riesgo y dependencia)

| # | Hallazgo | Job | Riesgo | Por qué en este orden |
|---|---|---|---|---|
| 1 | Secretos quemados | secretos | Alto | Crítico en repo público; bloquea todo |
| 2 | Dependencias vulnerables | sca | Alto | Base del servicio; afecta imagen también |
| 3 | `eval()` / inyección | sast_semgrep | Alto | Ejecución de código arbitrario |
| 4 | JWT mal validado | sast_semgrep | Alto | Control de acceso |
| 5 | CORS abierto | sast_semgrep + dast | Medio | Exposición a terceros |
| 6 | Errores internos expuestos | sast_semgrep | Medio | Fuga de información |
| 7 | Imagen con fallas / root | imagen | Medio | Escalada en contenedor |
| 8 | Cabeceras de seguridad | dast | Medio | Endurecimiento HTTP |

---

## Patrón 1 — Secretos quemados (CWE-798)

**Dónde:** `servidor/.env`, `servidor/config.js`, llaves PEM en el repo.

**Corrección:**
1. Eliminar del repo: `git rm servidor/.env servidor/config.js` (y cualquier llave).
2. Mover los valores a variables de entorno del Codespace / GitHub Secrets.
3. Crear `.env.example` con placeholders (documenta qué variables se necesitan).
4. Asegurar que `.gitignore` excluye `.env`, `*.pem`, `*.key`.
5. **Verificar:** job `secretos` (Gitleaks) en verde; `git log` sin secretos en el historial (si quedaron, reescribir historial o documentar la rotación).

**Mejores prácticas adicionales:**
- Rotar los secretos expuestos (aunque sean ficticios, demuestra el proceso).
- Usar GitHub Secrets para el pipeline (`${{ secrets.X }}`).

## Patrón 2 — Dependencias vulnerables (CWE-1104)

**Dónde:** `servidor/package.json` / `package-lock.json`.

**Corrección:**
1. `npm audit` para ver las vulnerabilidades.
2. `npm audit fix` para las que tengan parche.
3. Para las que no: actualizar manualmente la versión (`npm install paquete@version-segura`).
4. Si no hay versión segura: documentar el riesgo residual y el plan de migración.
5. **Verificar:** job `sca` en verde (npm audit sin hallazgos de nivel alto/crítico).

**Mejores prácticas adicionales:**
- Activar **Dependabot** (GitHub → Security → Dependabot) para actualizaciones automáticas.
- Fijar versiones exactas en el lockfile (ya viene con `npm ci`).

## Patrón 3 — `eval()` / inyección (CWE-95 / CWE-94)

**Dónde:** `servidor/servidor.js` o `cifrado.js` (uso de `eval`, `Function()`, `child_process` con entrada del usuario).

**Corrección:**
1. Eliminar `eval()` por completo — reemplazar con lógica directa (JSON.parse con try/catch, switch, etc.).
2. Nunca concatenar entrada del usuario en comandos de shell; usar arrays de argumentos.
3. Validar la entrada antes de cualquier procesamiento (tipo, tamaño, formato).
4. **Verificar:** job `sast_semgrep` en verde (regla de eval/inyección sin hallazgos).

## Patrón 4 — JWT mal validado (CWE-287)

**Dónde:** `servidor/auth.js`.

**Corrección:**
1. Verificar la **firma** del token con la clave pública de Keycloak (JWKS).
2. Verificar **expiración** (`exp`), **emisor** (`iss` = realm de Keycloak) y **audiencia** (`aud` = cliente `servicio-cifrado`).
3. No confiar en el payload sin verificar la firma.
4. Manejar tokens inválidos con 401 genérico (sin detalles).
5. **Verificar:** job `sast_semgrep` en verde + prueba funcional: token inválido → 401.

**Mejores prácticas adicionales:**
- Usar `jsonwebtoken` con `jwt.verify()` (no `jwt.decode()` solo).
- Configurar `algorithms: ['RS256']` explícitamente (evita ataques de confusión de algoritmo).

## Patrón 5 — CORS abierto (CWE-942)

**Dónde:** `servidor/servidor.js` (middleware CORS con `*` o reflejo de origen).

**Corrección:**
1. Restringir orígenes a los permitidos (la URL de la app en el Codespace, puerto 8081).
2. No reflejar el origen del request sin validación.
3. Limitar métodos (`GET, POST`) y cabeceras permitidas.
4. **Verificar:** job `sast_semgrep` en verde + DAST (ZAP) sin hallazgo de CORS + prueba manual con origen no permitido → sin cabecera CORS.

## Patrón 6 — Errores internos expuestos (CWE-209)

**Dónde:** `servidor/servidor.js` (respuestas con stack traces, mensajes de error internos).

**Corrección:**
1. Middleware de errores que devuelva respuestas genéricas (`{"error":"Error interno"}`).
2. Registrar el detalle en la bitácora (server-side), nunca en la respuesta.
3. Validar entradas para evitar excepciones no controladas.
4. **Verificar:** job `sast_semgrep` en verde + prueba: entrada inválida → respuesta genérica sin stack trace.

## Patrón 7 — Imagen con fallas / root (CWE-250)

**Dónde:** `servidor/Dockerfile`.

**Corrección:**
1. Usar una imagen base segura y actualizada (ej. `node:20-slim`).
2. Crear usuario no-root: `RUN useradd -m appuser` + `USER appuser`.
3. No copiar secretos a la imagen; usar variables de entorno en runtime.
4. Minimizar capas y paquetes instalados.
5. **Verificar:** job `imagen` (Trivy) en verde + `docker inspect` muestra usuario no-root.

**Mejores prácticas adicionales:**
- Multi-stage build (solo runtime en la imagen final).
- `HEALTHCHECK` en el Dockerfile.
- Escaneo de la imagen en cada build (ya lo hace el pipeline).

## Patrón 8 — Cabeceras de seguridad ausentes (DAST)

**Dónde:** `servidor/servidor.js` (respuestas HTTP).

**Corrección:** agregar cabeceras de seguridad:
- `Content-Security-Policy` (CSP)
- `X-Frame-Options: DENY`
- `X-Content-Type-Options: nosniff`
- `Referrer-Policy: no-referrer`
- `Strict-Transport-Security` (si hay HTTPS)
- `X-XSS-Protection: 0` (deprecada, pero documentar por qué no se usa)

**Verificar:** job `dast` (ZAP) sin hallazgos de cabeceras ausentes + `curl -I` muestra las cabeceras.

---

## Ciclo de verificación por corrección

```bash
# 1. Corregir el código en el Codespace
# 2. Commit con mensaje descriptivo
git add .
git commit -m "Corrige <hallazgo>: <descripción breve>"
git push
# 3. Esperar a que Actions ejecute el pipeline
# 4. Verificar el job correspondiente en verde
# 5. Registrar en la Tabla 4 (antes → corrección → después)
```

## Criterios de aceptación (Definition of Done de la Fase 2)

- [ ] 5/5 jobs del pipeline en **verde** (Semgrep, Gitleaks, SCA, Trivy+SBOM, ZAP) + **CodeQL default setup** en verde (el job avanzado de CodeQL se eliminó del workflow: no puede coexistir con el default setup — ver informe §8.6)
- [ ] Cada hallazgo de la Tabla 3 tiene su fila en la Tabla 4 con commit referenciado
- [ ] Reportes finales descargados (Semgrep, Gitleaks, SBOM, ZAP) como evidencia
- [ ] Alertas de CodeQL revisadas (cerradas o justificadas)
- [ ] Pruebas funcionales re-ejecutadas (el servicio sigue funcionando tras las correcciones)
- [ ] Riesgo residual documentado (CVEs de util-linux sin versión fija, excluidos con `--ignore-unfixed` — informe §8.5)
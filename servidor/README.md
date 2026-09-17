# servidor/ — Servicio de cifrado (backend Node.js)

> ⏳ **Carpeta pendiente de material oficial.**
> Aquí se integra el contenido de `proyecto-devsecops-cib204.zip` cuando esté disponible.

## Archivos esperados (según la guía)

| Archivo | Función |
|---|---|
| `servidor.js` | API REST (`/salud`, `/cifrar`, `/descifrar`, ...) |
| `cifrado.js` | Módulo RSA (cifrado/descifrado) |
| `auth.js` | Revisa el token JWT (identidad con Keycloak) |
| `db.js` | Consulta la bitácora |
| `Dockerfile` | Imagen del contenedor |
| `package.json` | Dependencias y scripts (`npm test`, `node prueba.js`) |
| `prueba.js` | Prueba rápida de cifrar/descifrar (`coincide=true`) |

## Vulnerabilidades esperadas (Fase 1 — se corrigen en Fase 2)

El código viene **inseguro a propósito**, con errores marcados como `// [VULN-n]`:

- Secretos quemados (`.env`, `config.js`) → CWE-798
- Dependencias vulnerables → CWE-1104
- `eval()` / inyección → CWE-95 / CWE-94
- JWT mal validado → CWE-287
- CORS abierto → CWE-942
- Errores internos expuestos → CWE-209
- Contenedor como root → CWE-250

## Verificación rápida (cuando el material esté aquí)

```bash
cd servidor
npm install
node prueba.js        # esperado: coincide=true
npm test              # esperado: Tests: 6 passed
```
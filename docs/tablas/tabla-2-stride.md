# Tabla 2 — Amenazas STRIDE

> 📄 **Tabla a llenar** — Primer Avance. Por cada amenaza STRIDE: qué componente afecta y cómo la frenas.

| Amenaza (STRIDE) | Componente afectado | Ejemplo de ataque | Control / mitigación |
|---|---|---|---|
| Spoofing (suplantar) | API de cifrado | Usar el servicio sin identidad | Token JWT válido (Keycloak) |
| Tampering (manipular) | Datos en tránsito | Alterar el texto cifrado | Descifrado que falla seguro |
| Repudiation (negar) | Servicio | Negar que se hizo una acción | Bitácora y logs |
| Information disclosure | Servicio / repo | Leer secretos o errores internos | Sin secretos en el repo; errores genéricos |
| Denial of service | API de cifrado | Enviar datos enormes | Límite de tamaño de la entrada |
| Elevation of privilege | Contenedor | Ejecutar como root | Contenedor sin privilegios (no-root) |

## Para exceder la rúbrica

### Severidad estimada por amenaza

| Amenaza | Severidad (Alta/Media/Baja) | Justificación |
|---|---|---|
| Spoofing | *(completar)* | *(completar)* |
| Tampering | *(completar)* | *(completar)* |
| Repudiation | *(completar)* | *(completar)* |
| Information disclosure | *(completar)* | *(completar)* |
| Denial of service | *(completar)* | *(completar)* |
| Elevation of privilege | *(completar)* | *(completar)* |

### Cómo se verifica cada control (prueba concreta)

| Amenaza | Prueba que demuestra el control |
|---|---|
| Spoofing | Pedir `/cifrar` sin token → 401; con token válido → 200 |
| Tampering | Modificar un byte del texto cifrado → error controlado |
| Repudiation | Consultar la bitácora tras una operación |
| Information disclosure | Enviar entrada inválida → respuesta genérica, sin stack trace |
| Denial of service | Enviar payload de 100 MB → rechazado por límite |
| Elevation of privilege | `docker inspect` → usuario no-root en el contenedor |
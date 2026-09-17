# Tabla 1 — Requisitos de seguridad

> 📄 **Tabla a llenar** — Primer Avance. Define qué debe proteger el sistema antes de tocar código.
> Marco de referencia: OWASP SAMM y NIST SSDF. En posgrado se valora que expliques el **porqué** de cada requisito.

| Propiedad | Requisito (qué debe cumplir) | Control que lo implementa | Cómo se verifica |
|---|---|---|---|
| Confidencialidad | Los datos se cifran antes de viajar | Cifrado RSA (OAEP) en el servicio | Prueba de cifrar/descifrar; DAST |
| Integridad | Un dato alterado no se descifra | Descifrado que falla de forma segura | Prueba de dato manipulado (pentest) |
| Disponibilidad | El servicio no se cae con entradas raras | Validar tipo y tamaño de la entrada | Prueba de entrada vacía/muy larga |
| Autenticación | Solo usuarios válidos usan el servicio | Token JWT verificado con Keycloak | Pedir /cifrar con y sin token |
| *(opcional, para exceder)* No repudio | Toda operación queda registrada | Bitácora con integridad (hash) | Consultar bitácora tras operar |

## Justificación (para exceder la rúbrica)

**Confidencialidad:** *(explica por qué el cifrado en tránsito es el requisito principal — los datos viajan entre la app móvil y el servicio por una red no confiable...)*

**Integridad:** *(explica por qué el descifrado debe fallar de forma segura — un atacante puede alterar el texto cifrado en tránsito...)*

**Disponibilidad:** *(explica por qué la validación de entrada protege la disponibilidad — entradas malformadas o enormes pueden agotar recursos...)*

**Autenticación:** *(explica por qué solo usuarios válidos deben usar el servicio — el cifrado como servicio sin control de acceso permite abuso...)*

## Mapeo con estándares

| Requisito | OWASP SAMM | NIST SSDF |
|---|---|---|
| Confidencialidad | *(completar)* | *(completar)* |
| Integridad | *(completar)* | *(completar)* |
| Disponibilidad | *(completar)* | *(completar)* |
| Autenticación | *(completar)* | *(completar)* |
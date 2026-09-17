# app-movil/ — Aplicación móvil (cliente Expo/React Native)

> ⏳ **Carpeta pendiente de material oficial.**
> Aquí se integra el contenido de `proyecto-devsecops-cib204.zip` cuando esté disponible.

## Archivos esperados (según la guía)

| Archivo | Función |
|---|---|
| `App.js` | Cifrar/descifrar; maneja el token |
| `package.json` | Dependencias de Expo/React Native |

## Cómo se ejecuta (cuando el material esté aquí)

```bash
# Desde la raíz del proyecto (el lanzador entra a app-movil/ por ti):
bash iniciar-app.sh

# Equivalente manual:
cd app-movil && npm install && npx expo start --web
```

La app corre en el **puerto 8081** (Expo web). El puerto 3000 (servicio) debe estar en **Público** para que la app pueda llamarlo desde el navegador.

## Flujo de cifrado con identidad

1. La app pide un token a Keycloak (usuario `demo`).
2. La app envía el token al servicio (`/cifrar`, `/descifrar`).
3. El servicio valida el token antes de cifrar/descifrar con RSA.
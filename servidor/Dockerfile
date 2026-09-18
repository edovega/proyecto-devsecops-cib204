# ============================================================================
#  Dockerfile  -  Servicio de cifrado
#  >>> VERSION REMEDIADA (Fase 2) <<<
# ============================================================================
#
#  [FIX-12] Imagen base con etiqueta FIJA y slim (CWE-1104: reproducibilidad).
#   node:20-bookworm-slim reduce superficie de ataque y Trivy ya no reporta
#   cientos de paquetes vulnerables de una imagen "latest" enorme.
#
#  [FIX-13] Se usa un usuario NO ROOT (USER node) y se copia SOLO lo
#   necesario (cifrado.js, servidor.js, auth.js, db.js, config.js, package.json,
#   public/) en lugar de COPY . (CWE-538: inclusion de secretos en la imagen;
#   CWE-250: ejecucion con privilegios innecesarios).

FROM node:20-bookworm-slim

# Copia de dependencias primero para cache optimizado.
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Copia solo el codigo de la aplicacion (nada de .env, llaves ni datos).
COPY servidor.js cifrado.js auth.js db.js config.js ./
COPY public ./public

# [FIX-13] No se ejecuta como root.
USER node

EXPOSE 3000

CMD ["node", "servidor.js"]

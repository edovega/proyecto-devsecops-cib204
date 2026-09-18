# ============================================================================
#  Dockerfile  -  Servicio de cifrado
#  >>> VERSION REMEDIADA (Fase 2) <<<
# ============================================================================
#
#  [FIX-12] Imagen base con etiqueta FIJA y slim (CWE-1104: reproducibilidad).
#   node:24-trixie-slim (Debian 13) trae paquetes de sistema actualizados que
#   cierran los CVEs que Trivy reportaba en bookworm: util-linux 2.41.5
#   (CVE-2026-53613/76642/78408/78409/78410), perl 5.40 (CVE-2026-13221 y
#   familia), zlib 1.3.1 (CVE-2023-45853), pcre2 10.46, systemd 257, ncurses
#   6.5, acl 2.3.2 y gzip 1.13.
#
#  [FIX-13] Se usa un usuario NO ROOT (USER node) y se copia SOLO lo
#   necesario (cifrado.js, servidor.js, auth.js, db.js, config.js) en lugar de
#   COPY . (CWE-538: inclusion de secretos en la imagen; CWE-250: ejecucion
#   con privilegios innecesarios).
#
#  [FIX-15] Multi-stage build: la etapa de build instala dependencias con npm;
#   la etapa final copia SOLO node_modules y el codigo, y elimina npm con sus
#   dependencias empaquetadas (tar, sigstore, pacote, ip-address,
#   brace-expansion...), que Trivy reportaba como vulnerables en la imagen
#   node. Menor superficie de ataque y menos paquetes que escanear.

# --- Etapa de build: instala dependencias de produccion ---------------------
FROM node:24-trixie-slim AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# --- Etapa final: solo runtime, sin npm -------------------------------------
FROM node:24-trixie-slim
WORKDIR /app
COPY --from=build /app/node_modules ./node_modules
COPY servidor.js cifrado.js auth.js db.js config.js ./

# [FIX-15] npm no se necesita en runtime; se elimina con sus dependencias
#   empaquetadas para reducir superficie de ataque y hallazgos de Trivy.
RUN rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx

# [FIX-16] Actualiza paquetes de sistema con parche disponible (perl-base
#   CVE-2026-13221, gzip CVE-2026-41992, pcre2 CVE-2026-86145/89157/89161,
#   sqlite CVE-2026-11822/11824). Los CVEs de util-linux sin version fija se
#   documentan como riesgo residual y se excluyen con --ignore-unfixed en el
#   pipeline (Trivy).
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

# [FIX-13] No se ejecuta como root.
USER node

EXPOSE 3000

CMD ["node", "servidor.js"]
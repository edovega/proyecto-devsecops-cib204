// ============================================================================
//  auth.js  -  Middleware de autenticacion (Keycloak / JWT RS256)
//  >>> VERSION REMEDIADA (Fase 2 verde) <<<
// ============================================================================
//
//  Que valida (guia 10.5 e informe 11.2):
//    - Firma: el token debe estar firmado por Keycloak. La llave publica se
//      obtiene del JWKS del realm (/protocol/openid-connect/certs) segun el
//      `kid` del token; nunca se usa jwt.decode() para decidir nada.
//    - Algoritmo: SOLO RS256 (se rechaza HS256 y alg:none: CWE-347 / CWE-287).
//    - Expiracion: claim `exp` (jsonwebtoken lo verifica).
//    - Emisor: claim `iss`, cuando KEYCLOAK_ISSUER esta definido.
//    - Audiencia: `aud` contiene el cliente `servicio-cifrado` o `azp` es ese
//      cliente (Keycloak emite `azp` por defecto).
//  Si no se puede consultar Keycloak, el servicio falla cerrado (503).

const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const config = require('./config');

const VIGENCIA_CACHE_MS = 10 * 60 * 1000;
const ESPERA_MAXIMA_MS = 5000;

let cache = { llaves: new Map(), cargadoEn: 0 };

async function cargarJwks() {
  const url =
    config.KEYCLOAK_URL + '/realms/' + config.KEYCLOAK_REALM + '/protocol/openid-connect/certs';
  const respuesta = await fetch(url, { signal: AbortSignal.timeout(ESPERA_MAXIMA_MS) });
  if (!respuesta.ok) {
    throw new Error('JWKS no disponible');
  }
  const { keys } = await respuesta.json();
  const llaves = new Map();
  for (const jwk of keys || []) {
    if (jwk.kty === 'RSA' && jwk.kid && (!jwk.use || jwk.use === 'sig')) {
      llaves.set(jwk.kid, crypto.createPublicKey({ key: jwk, format: 'jwk' }));
    }
  }
  cache = { llaves, cargadoEn: Date.now() };
}

async function obtenerLlave(kid) {
  const vencido = Date.now() - cache.cargadoEn > VIGENCIA_CACHE_MS;
  if (vencido || !cache.llaves.has(kid)) {
    await cargarJwks();
  }
  return cache.llaves.get(kid);
}

// Lee el encabezado del token SIN confiar en el: solo sirve para elegir la
// llave; la firma se verifica despues con jwt.verify().
function leerEncabezado(token) {
  const parte = token.split('.')[0] || '';
  return JSON.parse(Buffer.from(parte, 'base64url').toString('utf8'));
}

function audienciaValida(payload) {
  const cliente = config.KEYCLOAK_CLIENT_ID;
  const aud = Array.isArray(payload.aud) ? payload.aud : [payload.aud];
  return aud.includes(cliente) || payload.azp === cliente;
}

async function requiereAuth(req, res, next) {
  if (!config.AUTH_ENABLED) {
    return next();
  }
  const coincidencia = /^Bearer (\S+)$/.exec(req.headers['authorization'] || '');
  if (!coincidencia) {
    return res.status(401).json({ error: 'No autorizado' });
  }
  const token = coincidencia[1];

  let llave;
  try {
    const encabezado = leerEncabezado(token);
    if (encabezado.alg !== 'RS256' || !encabezado.kid) {
      return res.status(401).json({ error: 'No autorizado' });
    }
    llave = await obtenerLlave(encabezado.kid);
  } catch (e) {
    // Token ilegible -> 401. Keycloak inalcanzable -> 503 (falla cerrado).
    if (e instanceof SyntaxError) {
      return res.status(401).json({ error: 'No autorizado' });
    }
    return res.status(503).json({ error: 'Servicio de identidad no disponible' });
  }
  if (!llave) {
    return res.status(401).json({ error: 'No autorizado' });
  }

  try {
    const opciones = { algorithms: ['RS256'], clockTolerance: 5 };
    if (config.KEYCLOAK_ISSUER) {
      opciones.issuer = config.KEYCLOAK_ISSUER;
    }
    const payload = jwt.verify(token, llave, opciones);
    if (!audienciaValida(payload)) {
      return res.status(401).json({ error: 'No autorizado' });
    }
    req.usuario = payload;
    return next();
  } catch (e) {
    return res.status(401).json({ error: 'No autorizado' });
  }
}

module.exports = { requiereAuth };

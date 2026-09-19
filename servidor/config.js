// ============================================================================
//  config.js  -  Configuracion del servicio
//  >>> VERSION REMEDIADA (Fase 2) <<<
// ============================================================================
//
//  [FIX-11] Secretos ELIMINADOS del codigo (CWE-798 / CWE-259).
//   Ya no hay credenciales quemadas: AWS, JWT y DATABASE_URL se leen
//   SOLO de variables de entorno. Debe existir un archivo .env NO
//   versionado (ver .env.example) o Gitleaks los marcaria.

const config = {
  AWS_ACCESS_KEY_ID: process.env.AWS_ACCESS_KEY_ID,
  AWS_SECRET_ACCESS_KEY: process.env.AWS_SECRET_ACCESS_KEY,
  JWT_SECRET: process.env.JWT_SECRET,
  DATABASE_URL: process.env.DATABASE_URL,
  AUTH_ENABLED: process.env.AUTH_ENABLED === 'true',
  KEYCLOAK_URL: process.env.KEYCLOAK_URL || 'http://localhost:8080',
  KEYCLOAK_REALM: process.env.KEYCLOAK_REALM || 'appmovil',
  // Cliente (audiencia) que debe figurar en el token y emisor esperado (opcional:
  // si KEYCLOAK_ISSUER esta definido, el claim `iss` debe coincidir exactamente).
  KEYCLOAK_CLIENT_ID: process.env.KEYCLOAK_CLIENT_ID || 'servicio-cifrado',
  KEYCLOAK_ISSUER: process.env.KEYCLOAK_ISSUER || '',
  PUERTO: process.env.PORT || 3000,
  // Limite de peticiones por IP y ventana (FIX-19, CWE-770).
  RATE_LIMIT_MAX: Number(process.env.RATE_LIMIT_MAX) || 100,
  RATE_LIMIT_VENTANA_MS: Number(process.env.RATE_LIMIT_VENTANA_MS) || 60000,
  // [FIX-06] CORS restringido: lista blanca en .env.
  ORIGENES_PERMITIDOS: (process.env.ORIGENES_PERMITIDOS || 'http://localhost:3000').split(','),
};

module.exports = config;

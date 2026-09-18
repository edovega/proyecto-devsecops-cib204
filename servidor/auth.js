// ============================================================================
//  auth.js  -  Middleware de autenticacion
//  >>> VERSION REMEDIADA (Fase 2 verde) <<<
// ============================================================================
//
//  Cambio aplicado:
//    [H-05 / CWE-347][H-06 / CWE-287] Ya NO se usa jwt.decode() (que no
//      verifica firma) ni se acepta el algoritmo 'none'. Ahora se verifica
//      SIEMPRE la firma con el secreto/configuracion (jwt.verify) y se
//      restringe a HS256. Si el token llega corrupto o con alg:none, el
//      middleware responde 401.
//    En produccion real esto se valida contra el JWKS del proveedor (RS256),
//      pero para el laboratorio basta con la verificacion de firma estricta.

const jwt = require('jsonwebtoken');
const config = require('./config');

function requiereAuth(req, res, next) {
  if (!config.AUTH_ENABLED) {
    return next();
  }
  const cabecera = req.headers['authorization'] || '';
  const token = cabecera.replace('Bearer ', '');

  if (!token) {
    return res.status(401).json({ error: 'No autorizado' });
  }

  try {
    // FIX: se verifica la firma y se restringe el algoritmo (HS256).
    const payload = jwt.verify(token, config.JWT_SECRET, {
      algorithms: ['HS256'],
    });
    req.usuario = payload;
    return next();
  } catch (e) {
    return res.status(401).json({ error: 'No autorizado' });
  }
}

module.exports = { requiereAuth };

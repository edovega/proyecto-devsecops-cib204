// ============================================================================
//  servidor.js  -  API REST del servicio de cifrado
//  CIB-204 Seguridad del Software - Universidad Cenfotec
//  >>> VERSION REMEDIADA (Fase 2) <<<
// ============================================================================
//
//  Endpoints:
//    GET  /salud           -> estado del servicio
//    GET  /llave           -> entrega la llave publica
//    POST /cifrar          -> cifra un texto
//    POST /descifrar       -> descifra un texto
//    GET  /buscar          -> consulta la bitacora (parametrizado)
//    GET  /diagnostico     -> desparece: exec() reemplazado
// ============================================================================

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const cifrado = require('./cifrado');
const db = require('./db');
const config = require('./config');
const { requiereAuth } = require('./auth');

// [FIX-14] CSRF no aplica (falso positivo Semgrep): la API es stateless y
//   autentica con JWT Bearer en el header Authorization (Keycloak), sin cookies
//   de sesion; CSRF explota credenciales ambientales (cookies), por lo que no
//   hay superficie de ataque. Se suprime la regla con justificacion.
const app = express(); // nosemgrep: express-check-csurf-middleware-usage

// [FIX-06] Cabeceras de seguridad activas (Helmet): CSP, X-Content-Type-Options,
//   X-Frame-Options, etc.  Cierra CWE-693 y CWE-942 (CORS abierto restringido).
app.use(helmet());

// [FIX-17] Permissions-Policy: restringe APIs sensibles del navegador (helmet 7
//   ya no incluye este middleware; se define manualmente). Cierra el hallazgo
//   Low de ZAP "Permissions Policy Header Not Set".
app.use((req, res, next) => {
  res.setHeader('Permissions-Policy', 'camera=(), microphone=(), geolocation=(), payment=(), usb=()');
  next();
});

app.use(cors({ origin: config.ORIGENES_PERMITIDOS }));

// [FIX-19] Limite de peticiones por IP (CWE-770; alerta CodeQL js/missing-rate-limiting):
//   frena la fuerza bruta de tokens y el abuso de /cifrar, /descifrar y /buscar.
//   Excedido el limite responde 429. Ajustable con RATE_LIMIT_MAX / RATE_LIMIT_VENTANA_MS.
app.use(
  rateLimit({
    windowMs: config.RATE_LIMIT_VENTANA_MS,
    limit: config.RATE_LIMIT_MAX,
    standardHeaders: 'draft-7',
    legacyHeaders: false,
    message: { error: 'Demasiadas peticiones' },
  })
);

app.use(express.json({ limit: '10kb' })); // [FIX-05] CWE-20: tamano de cuerpo acotado

// [FIX-21] Bitacora de operaciones (no repudio, Tabla 1) y errores del lado del
//   servidor (informe 10.2): una linea JSON por operacion en la salida estandar,
//   con usuario (del token verificado), accion, resultado e IP. Nunca registra el
//   texto plano, el texto cifrado ni el token.
function auditar(req, accion, resultado, detalle) {
  const usuario = req.usuario ? req.usuario.preferred_username || req.usuario.sub : 'anonimo';
  console.log(
    JSON.stringify({ ts: new Date().toISOString(), accion, resultado, usuario, ip: req.ip, detalle })
  );
}

// El servicio genera su par de llaves al arrancar.
const llaves = cifrado.generarLlaves();

app.get('/salud', (req, res) => {
  res.json({ estado: 'ok', version: 'remediado-2.0' });
});

app.get('/llave', (req, res) => {
  res.json({ llavePublica: llaves.publicKey });
});

app.post('/cifrar', requiereAuth, (req, res) => {
  try {
    const texto = req.body.texto;
    // [FIX-05] Validacion de entrada (CWE-20): tipo y longitud. [FIX-22] El limite es
    //   la capacidad real de RSA-OAEP (190 bytes UTF-8), no un numero arbitrario.
    if (
      typeof texto !== 'string' ||
      texto.length === 0 ||
      Buffer.byteLength(texto, 'utf8') > cifrado.MAX_BYTES_TEXTO
    ) {
      auditar(req, 'cifrar', 'rechazado', 'entrada invalida');
      return res.status(400).json({ error: 'Texto invalido' });
    }
    const resultado = cifrado.cifrar(texto, llaves.publicKey);
    auditar(req, 'cifrar', 'ok');
    res.json({ cifrado: resultado });
  } catch (e) {
    auditar(req, 'cifrar', 'error', e.code || e.name);
    // [FIX-07] Se responde un error generico sin pila interna (CWE-209).
    res.status(500).json({ error: 'Error interno' });
  }
});

app.post('/descifrar', requiereAuth, (req, res) => {
  try {
    const cifradoTxt = req.body.cifrado;
    if (typeof cifradoTxt !== 'string' || cifradoTxt.length === 0) {
      auditar(req, 'descifrar', 'rechazado', 'entrada invalida');
      return res.status(400).json({ error: 'Dato invalido' });
    }
    const resultado = cifrado.descifrar(cifradoTxt, llaves.privateKey);
    auditar(req, 'descifrar', 'ok');
    res.json({ descifrado: resultado });
  } catch (e) {
    auditar(req, 'descifrar', 'error', e.code || e.name);
    res.status(500).json({ error: 'Error interno' });
  }
});

// [FIX-08] Bitacora con consulta PARAMETRIZADA (CWE-89) ya en db.js.
app.get('/buscar', requiereAuth, (req, res) => {
  const nombre = req.query.nombre || '';
  db.buscarBitacora(nombre, (err, data) => {
    if (err) {
      auditar(req, 'buscar', 'error', err.code || err.name);
      return res.status(500).json({ error: 'Error interno' });
    }
    auditar(req, 'buscar', 'ok');
    res.json(data);
  });
});

// [FIX-09] Se ELIMINA el endpoint /calcular con eval() (CWE-95).
//   Ya no existe una entrada del usuario que se ejecute como codigo.

// [FIX-10] Se ELIMINA el endpoint /diagnostico con exec() (CWE-78).
//   Ya no hay inyeccion de comandos del sistema.

if (require.main === module) {
  app.listen(config.PUERTO, () => {
    console.log('Servicio de cifrado escuchando en el puerto ' + config.PUERTO);
    console.log('AUTH_ENABLED =', config.AUTH_ENABLED);
  });
}

module.exports = app;

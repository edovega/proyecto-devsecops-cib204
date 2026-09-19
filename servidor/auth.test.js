// Pruebas de AUTENTICACION (Jest + supertest): tokens RS256 de un "Keycloak" simulado.
const crypto = require('crypto');
const request = require('supertest');
const jwt = require('jsonwebtoken');

const par = crypto.generateKeyPairSync('rsa', { modulusLength: 2048 });
const otroPar = crypto.generateKeyPairSync('rsa', { modulusLength: 2048 });
const jwk = { ...par.publicKey.export({ format: 'jwk' }), kid: 'kid-1', use: 'sig', alg: 'RS256' };

function firmar(extra = {}, opciones = {}, llave = par.privateKey) {
  return jwt.sign({ azp: 'servicio-cifrado', ...extra }, llave, {
    algorithm: 'RS256',
    keyid: 'kid-1',
    expiresIn: 300,
    ...opciones,
  });
}

describe('Autenticacion con Keycloak (RS256 + JWKS)', () => {
  let app;
  const fetchOriginal = global.fetch;

  beforeAll(() => {
    process.env.AUTH_ENABLED = 'true';
    global.fetch = jest.fn(async () => ({ ok: true, json: async () => ({ keys: [jwk] }) }));
    jest.resetModules();
    app = require('./servidor');
  });

  afterAll(() => {
    delete process.env.AUTH_ENABLED;
    global.fetch = fetchOriginal;
    jest.resetModules();
  });

  const cifrar = (token) => {
    const r = request(app).post('/cifrar').send({ texto: 'hola' });
    return token ? r.set('Authorization', 'Bearer ' + token) : r;
  };

  test('sin token -> 401', async () => {
    expect((await cifrar()).statusCode).toBe(401);
  });

  test('token valido de Keycloak -> 200', async () => {
    const res = await cifrar(firmar());
    expect(res.statusCode).toBe(200);
    expect(res.body.cifrado).toBeDefined();
  });

  test('token expirado -> 401', async () => {
    expect((await cifrar(firmar({}, { expiresIn: -60 }))).statusCode).toBe(401);
  });

  test('firma de otra llave -> 401', async () => {
    expect((await cifrar(firmar({}, {}, otroPar.privateKey))).statusCode).toBe(401);
  });

  test('algoritmo HS256 (confusion de algoritmo) -> 401', async () => {
    const secretoAleatorio = crypto.randomBytes(32).toString('hex');
    const t = jwt.sign({ azp: 'servicio-cifrado' }, secretoAleatorio, {
      algorithm: 'HS256',
      keyid: 'kid-1',
    });
    expect((await cifrar(t)).statusCode).toBe(401);
  });

  test('alg:none -> 401', async () => {
    const enc = (o) => Buffer.from(JSON.stringify(o)).toString('base64url');
    const t = enc({ alg: 'none', typ: 'JWT', kid: 'kid-1' }) + '.' + enc({ azp: 'servicio-cifrado' }) + '.';
    expect((await cifrar(t)).statusCode).toBe(401);
  });

  test('audiencia/cliente incorrecto -> 401', async () => {
    expect((await cifrar(firmar({ azp: 'otro-cliente' }))).statusCode).toBe(401);
  });

  test('kid desconocido -> 401', async () => {
    expect((await cifrar(firmar({}, { keyid: 'kid-x' }))).statusCode).toBe(401);
  });

  test('basura como token -> 401', async () => {
    expect((await cifrar('no.es.un.token')).statusCode).toBe(401);
  });
});

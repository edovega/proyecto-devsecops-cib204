// Prueba del LIMITE DE PETICIONES (FIX-19, CWE-770): excedido el limite -> 429.
const request = require('supertest');

describe('Limite de peticiones por IP', () => {
  let app;

  beforeAll(() => {
    process.env.RATE_LIMIT_MAX = '3';
    jest.resetModules();
    app = require('./servidor');
  });

  afterAll(() => {
    delete process.env.RATE_LIMIT_MAX;
    jest.resetModules();
  });

  test('la peticion 4 dentro de la ventana responde 429', async () => {
    for (let i = 0; i < 3; i++) {
      expect((await request(app).get('/salud')).statusCode).toBe(200);
    }
    const res = await request(app).get('/salud');
    expect(res.statusCode).toBe(429);
    expect(res.body.error).toBe('Demasiadas peticiones');
  });
});

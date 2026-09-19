// Pruebas de INTEGRACION de la API (Jest + supertest)
const request = require('supertest');
const app = require('./servidor');

describe('API del servicio de cifrado', () => {
  test('GET /salud responde estado ok', async () => {
    const res = await request(app).get('/salud');
    expect(res.statusCode).toBe(200);
    expect(res.body.estado).toBe('ok');
  });

  test('GET /llave entrega la llave publica', async () => {
    const res = await request(app).get('/llave');
    expect(res.statusCode).toBe(200);
    expect(res.body.llavePublica).toContain('BEGIN PUBLIC KEY');
  });

  test('ciclo completo: /cifrar y luego /descifrar recupera el texto', async () => {
    const texto = 'Prueba de integracion';
    const c = await request(app).post('/cifrar').send({ texto });
    expect(c.statusCode).toBe(200);
    expect(c.body.cifrado).toBeDefined();

    const d = await request(app)
      .post('/descifrar')
      .send({ cifrado: c.body.cifrado });
    expect(d.statusCode).toBe(200);
    expect(d.body.descifrado).toBe(texto);
  });

  test('cada operacion queda en la bitacora (no repudio) sin registrar el texto', async () => {
    const espia = jest.spyOn(console, 'log').mockImplementation(() => {});
    await request(app).post('/cifrar').send({ texto: 'dato-secreto-123' });
    const lineas = espia.mock.calls.map((c) => String(c[0]));
    espia.mockRestore();
    const registro = lineas.find((l) => l.includes('"accion":"cifrar"'));
    expect(registro).toBeDefined();
    expect(JSON.parse(registro).resultado).toBe('ok');
    expect(registro).not.toContain('dato-secreto-123');
  });

  test('borde de RSA-OAEP: 190 bytes se cifran; 191 se rechazan con 400 (no 500)', async () => {
    const ok = await request(app).post('/cifrar').send({ texto: 'a'.repeat(190) });
    expect(ok.statusCode).toBe(200);
    const d = await request(app).post('/descifrar').send({ cifrado: ok.body.cifrado });
    expect(d.body.descifrado).toBe('a'.repeat(190));
    const largo = await request(app).post('/cifrar').send({ texto: 'a'.repeat(191) });
    expect(largo.statusCode).toBe(400);
  });

  test('el limite cuenta bytes UTF-8, no caracteres (47 emojis = 188 B ok; 48 = 192 B rechazo)', async () => {
    expect((await request(app).post('/cifrar').send({ texto: '😀'.repeat(47) })).statusCode).toBe(200);
    expect((await request(app).post('/cifrar').send({ texto: '😀'.repeat(48) })).statusCode).toBe(400);
  });
});

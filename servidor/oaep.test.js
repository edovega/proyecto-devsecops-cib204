// Verifica que el cifrado usa OAEP con SHA-256 (FIX-20), no el SHA-1 por defecto de Node.
const crypto = require('crypto');
const cifrado = require('./cifrado');

describe('RSA-OAEP con SHA-256', () => {
  const { publicKey, privateKey } = cifrado.generarLlaves();

  test('un texto cifrado por el modulo se descifra con OAEP-SHA256', () => {
    const c = cifrado.cifrar('Hola', publicKey);
    const claro = crypto.privateDecrypt(
      { key: privateKey, padding: crypto.constants.RSA_PKCS1_OAEP_PADDING, oaepHash: 'sha256' },
      Buffer.from(c, 'base64')
    );
    expect(claro.toString('utf8')).toBe('Hola');
  });

  test('con OAEP-SHA1 el descifrado falla (no se usa el hash por defecto)', () => {
    const c = cifrado.cifrar('Hola', publicKey);
    expect(() =>
      crypto.privateDecrypt(
        { key: privateKey, padding: crypto.constants.RSA_PKCS1_OAEP_PADDING, oaepHash: 'sha1' },
        Buffer.from(c, 'base64')
      )
    ).toThrow();
  });

  test('la llave generada es de 2048 bits', () => {
    expect(cifrado.TAMANO_LLAVE).toBe(2048);
    expect(crypto.createPublicKey(publicKey).asymmetricKeyDetails.modulusLength).toBe(2048);
  });
});

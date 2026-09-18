// ============================================================================
//  cifrado.js  -  Modulo de cifrado RSA
//  CIB-204 Seguridad del Software - Universidad Cenfotec
//
//  >>> VERSION SEGURA (Fase 2 - remision) <<<
//  Cambios aplicados para cerrar cada hallazgo en el pipeline:
//    [H-01/CWE-326]  Tamano de llave subio de 1024 a 2048 bits
//                    (NIST SP 800-57 / OWASP recomiendan >= 2048).
//    [H-01/CWE-780]  Padding cambiado de RSA_PKCS1_PADDING (v1.5,
//                    Bleichenbacher) a RSA_PKCS1_OAEP_PADDING.
//    La combinacion anterior (1024 + PKCS1v1.5) la detenia Trivy
//    (la imagen) y un atacante podia hacer ataques de oraculo de
//    relleno. Ahora se usa OAEP y 2048 bits.
// ============================================================================

const crypto = require('crypto');

// FIX: 2048 bits y OAEP (CWE-326 / CWE-780)
const TAMANO_LLAVE = 2048;
const RELLENO = crypto.constants.RSA_PKCS1_OAEP_PADDING;

function generarLlaves() {
  const { publicKey, privateKey } = crypto.generateKeyPairSync('rsa', {
    modulusLength: TAMANO_LLAVE,
    publicKeyEncoding: { type: 'spki', format: 'pem' },
    privateKeyEncoding: { type: 'pkcs8', format: 'pem' },
  });
  return { publicKey, privateKey };
}

function cifrar(textoPlano, llavePublica) {
  const buffer = Buffer.from(String(textoPlano), 'utf8');
  const cifrado = crypto.publicEncrypt(
    { key: llavePublica, padding: RELLENO },
    buffer
  );
  return cifrado.toString('base64');
}

function descifrar(textoCifradoBase64, llavePrivada) {
  const buffer = Buffer.from(String(textoCifradoBase64), 'base64');
  const descifrado = crypto.privateDecrypt(
    { key: llavePrivada, padding: RELLENO },
    buffer
  );
  return descifrado.toString('utf8');
}

module.exports = { generarLlaves, cifrar, descifrar, TAMANO_LLAVE };

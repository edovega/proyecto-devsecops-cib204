// ============================================================================
//  db.js  -  Acceso a datos (bitacora de operaciones)
//  >>> VERSION REMEDIADA (Fase 2 verde) <<<
// ============================================================================
//
//  Cambio aplicado:
//    [H-04 / CWE-89] Se reemplazo la concatenacion directa de la entrada del
//      usuario en la consulta SQL por una consulta PARAMETRIZADA con
//      placeholders '?'. Ya no hay buffer de concatenacion, por lo que
//      Semgrep/CodeQL/SQLi ya no detectan el sink.
//    El driver mysql reemplaza cada '?' con el valor escapado.

const mysql = require('mysql');
const config = require('./config');

let conexion = null;
try {
  conexion = mysql.createConnection(config.DATABASE_URL);
} catch (e) {
  conexion = null;
}

// [FIX-04] Consulta parametrizada: el valor del usuario viaja como dato,
//   NO como parte del SQL. CWE-89 (SQL Injection) remediada.
function buscarBitacora(nombre, callback) {
  const sql = 'SELECT * FROM bitacora WHERE usuario = ?';
  if (!conexion) {
    return callback(null, { sqlEjecutado: sql, parametros: [nombre], filas: [] });
  }
  conexion.query(sql, [nombre], function (err, filas) {
    if (err) {
      return callback(null, { sqlEjecutado: sql, parametros: [nombre], filas: [], nota: err.code });
    }
    return callback(null, { sqlEjecutado: sql, parametros: [nombre], filas: filas });
  });
}

module.exports = { buscarBitacora };

#!/bin/bash
# ============================================================================
#  prueba-e2e-keycloak.sh - Prueba extremo a extremo (Tabla 6 del informe)
#  Levanta un Keycloak 24.0 temporal (puerto 18080), configura el realm
#  appmovil / cliente servicio-cifrado / usuario demo (guia, seccion 7),
#  arranca el servicio (puerto 13000) con AUTH_ENABLED=true y ejecuta las
#  pruebas P-01..P-25. Requiere: docker, node, curl, python3 y `npm ci` hecho
#  en servidor/. Uso:  bash scripts/prueba-e2e-keycloak.sh > salida.txt
#  Las contrasenas se generan al azar en cada ejecucion (no hay secretos fijos).
# ============================================================================
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"; SRV="$RAIZ/servidor"
KC=http://localhost:18080; SVC=http://localhost:13000; J="Content-Type: application/json"
ADMIN_PASS=$(openssl rand -hex 8); DEMO_PASS=$(openssl rand -hex 8); TMP=$(mktemp -d)
limpiar() { [ -n "$SP" ] && kill "$SP" 2>/dev/null; docker rm -f kc-cib204-e2e >/dev/null 2>&1; rm -rf "$TMP"; }
trap limpiar EXIT
docker rm -f kc-cib204-e2e >/dev/null 2>&1
docker run -d --name kc-cib204-e2e -p 18080:8080 -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD="$ADMIN_PASS" \
  -e KC_HTTP_ENABLED=true -e KC_HOSTNAME_STRICT=false quay.io/keycloak/keycloak:24.0 start-dev >/dev/null || exit 1
echo "# Fecha: $(date -u +%FT%TZ)"; echo "# Keycloak: quay.io/keycloak/keycloak:24.0 (docker local, puerto 18080)"
echo "# Commit del servicio: $(git -C "$RAIZ" rev-parse --short HEAD)"; echo "# Node: $(node --version)"; echo
for i in $(seq 1 90); do curl -sf $KC/realms/master >/dev/null && break; sleep 2; done
jget() { python3 -c "import sys,json;print(json.load(sys.stdin)$1)"; }
TK=$(curl -s -d client_id=admin-cli -d username=admin -d "password=$ADMIN_PASS" -d grant_type=password $KC/realms/master/protocol/openid-connect/token | jget '["access_token"]')
H="Authorization: Bearer $TK"
echo "## Configuracion de Keycloak (guia, seccion 7)"
echo "crear realm appmovil:            HTTP $(curl -s -o /dev/null -w '%{http_code}' -H "$H" -H "$J" -d '{"realm":"appmovil","enabled":true}' $KC/admin/realms)"
echo "crear cliente servicio-cifrado:  HTTP $(curl -s -o /dev/null -w '%{http_code}' -H "$H" -H "$J" -d '{"clientId":"servicio-cifrado","enabled":true,"publicClient":true,"directAccessGrantsEnabled":true}' $KC/admin/realms/appmovil/clients)"
echo "crear usuario demo:              HTTP $(curl -s -o /dev/null -w '%{http_code}' -H "$H" -H "$J" -d "{\"username\":\"demo\",\"enabled\":true,\"email\":\"demo@example.com\",\"emailVerified\":true,\"firstName\":\"Demo\",\"lastName\":\"Usuario\",\"credentials\":[{\"type\":\"password\",\"value\":\"$DEMO_PASS\",\"temporary\":false}]}" $KC/admin/realms/appmovil/users)"
tok() { curl -s -d client_id="${1:-servicio-cifrado}" -d username=demo -d "password=$DEMO_PASS" -d grant_type=password $KC/realms/appmovil/protocol/openid-connect/token | jget '["access_token"]'; }
T=$(tok)
echo "encabezado del token real: $(echo "$T" | cut -d. -f1 | base64 -d 2>/dev/null | tr -d ' \n')"
echo
cd "$SRV" || exit 1
AUTH_ENABLED=true KEYCLOAK_URL=$KC KEYCLOAK_REALM=appmovil PORT=13000 ORIGENES_PERMITIDOS=http://localhost:3000 node servidor.js >"$TMP/svc.log" 2>&1 &
SP=$!; sleep 2
c() { curl -s -o "$TMP/r.out" -w '%{http_code}' "$@"; }
row() { printf '%-9s %-58s esperado=%-4s real=%-4s %s\n' "$1" "$2" "$3" "$4" "$( [ "$3" = "$4" ] && echo PASA || echo FALLA )"; }
echo "## Pruebas funcionales (Tabla 6)"
r=$(c $SVC/salud); row P-09 "GET /salud" 200 $r; echo "          cuerpo: $(cat "$TMP/r.out")"
r=$(c -X POST -H "$J" -d '{"texto":"Hola mundo"}' $SVC/cifrar); row P-04 "POST /cifrar sin token" 401 $r
r=$(c -X POST -H "$J" -H "Authorization: Bearer $T" -d '{"texto":"Hola mundo"}' $SVC/cifrar); row P-01/P-03 "POST /cifrar con token real de Keycloak" 200 $r
C=$(jget '["cifrado"]' < "$TMP/r.out"); echo "          cifrado (base64, 40 car.): ${C:0:40}..."
r=$(c -X POST -H "$J" -H "Authorization: Bearer $T" -d "{\"cifrado\":\"$C\"}" $SVC/descifrar); row P-02 "POST /descifrar (ciclo completo)" 200 $r; echo "          cuerpo: $(cat "$TMP/r.out")"
CM="${C:0:10}$( [ "${C:10:1}" = "A" ] && echo B || echo A )${C:11}"
r=$(c -X POST -H "$J" -H "Authorization: Bearer $T" -d "{\"cifrado\":\"$CM\"}" $SVC/descifrar); row P-05/P-17 "descifrar dato manipulado (1 caracter)" 500 $r; echo "          cuerpo: $(cat "$TMP/r.out") (error generico, sin pila)"
r=$(c -X POST -H "$J" -H "Authorization: Bearer $T" -d '{"texto":""}' $SVC/cifrar); row P-06 "entrada vacia" 400 $r
python3 -c 'print("{\"texto\":\""+"a"*20000+"\"}")' > "$TMP/big.json"
r=$(c -X POST -H "$J" -H "Authorization: Bearer $T" --data @"$TMP/big.json" $SVC/cifrar); row P-07 "entrada de 20 KB (limite 10 KB)" 413 $r
r=$(c -X POST -H "$J" -H "Authorization: Bearer $T" -d '{"texto":12345}' $SVC/cifrar); row P-08 "entrada no texto (numero)" 400 $r
r=$(c -X POST -H "$J" -H "Authorization: Bearer $T" -d '{"texto":"Ñandú 你好 😀\nlinea2"}' $SVC/cifrar); row P-25 "UTF-8, emoji y salto de linea (cifrar)" 200 $r
C2=$(jget '["cifrado"]' < "$TMP/r.out")
r=$(c -X POST -H "$J" -H "Authorization: Bearer $T" -d "{\"cifrado\":\"$C2\"}" $SVC/descifrar); row P-25 "roundtrip UTF-8 (descifrar)" 200 $r; echo "          cuerpo: $(cat "$TMP/r.out")"
echo
echo "## Pruebas de token (Tabla 6, P-10 / P-18)"
FAKE=$(cd "$SRV" && node -e '
const c=require("crypto"),j=require("jsonwebtoken");
const h=JSON.parse(Buffer.from(process.argv[1].split(".")[0],"base64url"));
const k=c.generateKeyPairSync("rsa",{modulusLength:2048}).privateKey;
const out={};
out.firma_falsa=j.sign({azp:"servicio-cifrado"},k,{algorithm:"RS256",keyid:h.kid,expiresIn:300});
out.hs256=j.sign({azp:"servicio-cifrado"},c.randomBytes(32).toString("hex"),{algorithm:"HS256",keyid:h.kid});
const e=o=>Buffer.from(JSON.stringify(o)).toString("base64url");
out.none=e({alg:"none",typ:"JWT",kid:h.kid})+"."+e({azp:"servicio-cifrado"})+".";
console.log(JSON.stringify(out));' "$T")
for k in firma_falsa hs256 none; do t=$(echo "$FAKE" | jget "['$k']"); r=$(c -X POST -H "$J" -H "Authorization: Bearer $t" -d '{"texto":"x"}' $SVC/cifrar); row P-18 "token $k" 401 $r; done
# Se altera un caracter del MEDIO de la firma (los ultimos bits del ultimo caracter base64 no cambian los bytes).
TA=$(python3 -c "import sys;h,p,f=sys.argv[1].split('.');i=len(f)//2;print('.'.join([h,p,f[:i]+('B' if f[i]!='B' else 'C')+f[i+1:]]))" "$T")
r=$(c -X POST -H "$J" -H "Authorization: Bearer $TA" -d '{"texto":"x"}' $SVC/cifrar); row P-18 "token real con un caracter de la firma alterado" 401 $r
curl -s -o /dev/null -H "$H" -H "$J" -d '{"clientId":"otra-app","enabled":true,"publicClient":true,"directAccessGrantsEnabled":true}' $KC/admin/realms/appmovil/clients
r=$(c -X POST -H "$J" -H "Authorization: Bearer $(tok otra-app)" -d '{"texto":"x"}' $SVC/cifrar); row P-10b "token valido de OTRO cliente (audiencia)" 401 $r
curl -s -o /dev/null -X PUT -H "$H" -H "$J" -d '{"realm":"appmovil","accessTokenLifespan":5}' $KC/admin/realms/appmovil
T3=$(tok); sleep 12
r=$(c -X POST -H "$J" -H "Authorization: Bearer $T3" -d '{"texto":"x"}' $SVC/cifrar); row P-10 "token de Keycloak EXPIRADO (vida 5 s, espera 12 s)" 401 $r
r=$(c -X POST -H "$J" -H "Authorization: Bearer $(tok)" -d '{"texto":"x"}' $SVC/cifrar); row P-03b "token nuevo tras expirar el anterior" 200 $r
echo
echo "## Cabeceras y CORS (P-19 / P-20)"
curl -sI $SVC/salud | grep -iE '^(content-security-policy|x-frame-options|x-content-type-options|strict-transport-security|permissions-policy|referrer-policy|cross-origin-opener-policy|ratelimit)' | cut -c1-140 | tr -d '\r'
echo "CORS origen permitido:    $(curl -sI -H 'Origin: http://localhost:3000' $SVC/salud | grep -i '^access-control-allow-origin' | tr -d '\r')"
echo "CORS origen NO permitido: $(curl -sI -H 'Origin: http://malo.example' $SVC/salud | grep -ic '^access-control-allow-origin') cabecera(s) access-control-allow-origin (esperado 0)"
echo
echo "## Disponibilidad tras entradas malformadas (P-23)"
c -X POST -H "$J" -H "Authorization: Bearer $(tok)" -d '{{{{' $SVC/cifrar >/dev/null
r=$(c $SVC/salud); row P-23 "/salud responde tras JSON malformado" 200 $r
echo
echo "## Bitacora de operaciones - no repudio (P-24 / FIX-21)"
nreg=$(grep -c '"accion":"cifrar"' "$TMP/svc.log"); row P-24 "operaciones cifrar registradas en la bitacora del servicio" si "$( [ "$nreg" -gt 0 ] && echo si || echo no )"
echo "          ejemplo: $(grep -m1 '"accion":"cifrar","resultado":"ok"' "$TMP/svc.log")"
row P-24b "el texto plano NO aparece en la bitacora" 0 "$(grep -c 'Hola mundo' "$TMP/svc.log")"
echo
echo "## Endpoints eliminados (FIX-09 / FIX-10)"
r=$(c -X POST -H "$J" -d '{"expr":"1+1"}' $SVC/calcular); row FIX-09 "POST /calcular (eval eliminado)" 404 $r
r=$(c $SVC/diagnostico); row FIX-10 "GET /diagnostico (exec eliminado)" 404 $r
echo
echo "## Limite de peticiones por IP (P-21 / FIX-19): 130 peticiones seguidas a /salud"
codes=$(for i in $(seq 1 130); do curl -s -o /dev/null -w '%{http_code}\n' $SVC/salud; done | sort | uniq -c | tr '\n' ' ')
echo "codigos HTTP obtenidos: $codes"
n429=$(echo "$codes" | grep -oE '[0-9]+ 429' | cut -d' ' -f1); row P-21 "hay respuestas 429 al superar 100 peticiones/min" si "$( [ "${n429:-0}" -gt 0 ] && echo si || echo no )"

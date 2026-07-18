#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMG_DIR="$SCRIPT_DIR/../sitio-web-2/public/img"
TERRA_DIR="$SCRIPT_DIR/../infraestructura"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ALB="${1:-}"

if [ -z "$ALB" ]; then
    ALB=$(terraform -chdir="$TERRA_DIR" output -raw alb_dns 2>/dev/null) || {
        echo "No se pudo obtener ALB DNS. Pasalo como argumento: $0 <alb-dns>"
        exit 1
    }
fi

BASE_URL="http://${ALB}"
echo "Target: $BASE_URL"
echo ""

export BASE_URL IMG_DIR

seed() {
    export PY_NAME="$1" PY_RUTA="$2" PY_IMG="$3" PY_P1="$4" PY_P2="$5" PY_ORDER="$6"
    python3 << 'PYEOF'
import json, base64, urllib.request, os

img_path = os.path.join(os.environ['IMG_DIR'], os.environ['PY_IMG'])

try:
    with open(img_path, 'rb') as f:
        b64 = base64.b64encode(f.read()).decode()
except FileNotFoundError:
    print(f"SKIP: {os.environ['PY_NAME']} — imagen {os.environ['PY_IMG']} no encontrada")
    exit(0)

data = {
    'nombre': os.environ['PY_NAME'],
    'recorrido': os.environ['PY_RUTA'],
    'imagen_base64': b64,
    'parrafo1': os.environ['PY_P1'],
    'parrafo2': os.environ['PY_P2'],
    'orden': int(os.environ['PY_ORDER'])
}

payload = json.dumps(data, ensure_ascii=False).encode()
url = os.environ['BASE_URL'] + '/api/lugares'
req = urllib.request.Request(
    url, data=payload,
    headers={'Content-Type': 'application/json'},
    method='POST'
)

try:
    resp = urllib.request.urlopen(req, timeout=30)
    print(f"\033[0;32mOK [{resp.status}]\033[0m: #{os.environ['PY_ORDER']} {os.environ['PY_NAME']} ({os.environ['PY_RUTA']})")
except urllib.error.HTTPError as e:
    body = e.read().decode()[:100]
    print(f"\033[0;31mERR [{e.code}]\033[0m: {os.environ['PY_NAME']} — {body}")
except Exception as e:
    print(f"\033[0;31mERR\033[0m: {os.environ['PY_NAME']} — {e}")
PYEOF
}

echo "=== Recorrido Clásico ==="

seed \
    "Terminal de buses" \
    "Clásico" \
    "terminal.jpg" \
    "Donde comienza la magia (y el olor a orina también). Punto de partida ideal para quienes llegan desde otras ciudades y quieren comenzar el recorrido apenas bajan del bus." \
    "Un dato curioso de la fauna del lugar es que los caninos de la zona parecen emigrar un par de semanas antes de fiestas patrias." \
    30

seed \
    "Campanario San Javier" \
    "Clásico" \
    "campanario.jpg" \
    "Una de las primeras paradas del recorrido. Su entorno conserva gran parte de su vegetación original y ofrece una muestra de cómo era esta zona antes del crecimiento urbano de la ciudad." \
    "El acceso suele ser limitado, por lo que las visitas se realizan gracias a la colaboración de la comunidad responsable del lugar, aunque en cualquier momento el San Javier lo pone en arriendo también." \
    32

seed \
    "Restaurante El Cheff II" \
    "Clásico" \
    "chef.jpg" \
    "Si algún día se crea la cuarta estrella Michelin, será porque evaluaron al Cheff." \
    "Una estupenda segunda parada para afirmar el estómago: papas, bebidas, completos, sopaipas, ¡El milenario Shin-Chan! y cuanta cosa te pueda tapar las arterias en un solo lugar." \
    34

seed \
    "Ex cárcel" \
    "Clásico" \
    "excarcel.jpg" \
    "Gente con cara de pocos amigos se hospedó aquí por años, si los mejores hostales sólo pueden retener a sus huéspedes por unos días, imagínate lo bueno que era este lugar." \
    "Esta tercera parada consiste en un tour guiado a través de la histórica cárcel de Chin Chin. Porque ningún recorrido turístico está completo sin una antigua prisión, leyendas urbanas, supuestas apariciones y una colección de historias tétricas que te dejarán helado mucho después de abandonar el recinto." \
    36

seed \
    "Piedra Perrito" \
    "Clásico" \
    "piedra-perrito.jpg" \
    "Esta piedra fue pintada en honor a Copito, un querido fox terrier que durante años acompañó a vecinos y trabajadores del sector portuario, ganándose el cariño de quienes lo conocieron." \
    "Con el tiempo se convirtió en un pequeño homenaje a uno de los perros más recordados de Puerto Montt y en una manera un poco extraña (pero muy bella) de recibir a quienes llegan a nuestra ciudad." \
    38

echo ""
echo "=== Recorrido Extremo ==="

seed \
    "Sodimac Abandonado" \
    "Extremo" \
    "sodimac.jpg" \
    "Si tu hijo es dependiente de sustancias, seguramente lo encontrarás aquí." \
    "A escasos pasos de las anteriores dos paradas se encuentra el ex-Sodimac, un destino obligado por ser el lugar abandonado por excelencia de Puerto Montt. Hay que apurarse eso sí, porque parece ser que desaparece el 10% de los materiales con cada visita que le damos." \
    40

seed \
    "Completos Charles" \
    "Extremo" \
    "completos-charles.jpg" \
    "Un antiguo bus transformado en local de completos. Tal cual, y temático, más latinoamericano no puede ser." \
    "Una combinación perfecta entre creatividad, comida rápida y espíritu puertomontino. Si existe un monumento al ingenio local, probablemente sea este." \
    42

seed \
    "La Silla del Presidente" \
    "Extremo" \
    "silla-presidente.jpg" \
    "Un gigantesco tocón de alerce de entre 2000 y 5000 años de edad oculto a plena vista e ignorado por muchos." \
    "Su fama no se debe a su valor arqueológico (cosa que tendría todo el sentido del mundo) sino a que en una visita del entonces presidente de la República Jorge Montt, este se sentó ahí y se sacó una foto (XD?)." \
    44

seed \
    "Casa Embrujada de Alerce" \
    "Extremo" \
    "embrujao.jpg" \
    "Toda ciudad tiene una casa de la que se cuentan historias. Esta es la nuestra." \
    "Apariciones, objetos levitando, relatos contradictorios y un carabinero que se enfrentó al mismísimo diablo han convertido este lugar en una pequeña leyenda urbana local (Hasta DrossRotzank le hizo un video)." \
    46

seed \
    "Huellas" \
    "Extremo" \
    "huellas.png" \
    "Para finalizar, otra muestra de lo que parece ser una de las actividades favoritas del puertomontino: ignorar olímpicamente lugares de alto valor arqueológico." \
    "Muy cerca de la playa Pelluhuin, a simple vista de cualquier persona que pasa por ahí, lo que parecen ser simples piedras en realidad son huellas de miles de años, de ñandúes y gonfoterios, algunas incluso sorprendentemente marcadas y distinguibles. Nadie se explica cómo no se encontraron antes." \
    48

echo ""
echo -e "${GREEN}=== Seed completo ===${NC}"
echo "Verificar: curl $BASE_URL/api/lugares | python3 -m json.tool"

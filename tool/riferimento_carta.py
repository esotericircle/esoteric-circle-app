# -*- coding: utf-8 -*-
"""IL RIFERIMENTO DELLA CARTA NATALE, uno e riproducibile.

Ordine 2170, voce 1. Prende data, ora UTC, latitudine e longitudine e stampa
con Swiss Ephemeris i dodici corpi, il Nodo medio, la Lilith media,
l'Ascendente, il Medio Cielo, il Vertex e le dodici cuspidi Placidus.

**PERCHE' NON USA pyswisseph, come l'ordine chiedeva.** Su questa macchina
`pip install pyswisseph` non arriva in fondo: il pacchetto pubblica solo il
sorgente, la compilazione vuole Microsoft Visual C++ 14 o superiore, e i Build
Tools installati qui hanno solo `Common7`, senza il componente C++. Nessuna
delle tre versioni disponibili pubblica una wheel per Windows, verificato con
`pip install --only-binary :all:` su ciascuna.

**IL MOTORE E' LO STESSO, e non e' un'opinione.** Si usa `swisseph-wasm`, cioe'
la stessa libreria Swiss Ephemeris di Astrodienst compilata in WebAssembly.
Che dia gli stessi numeri lo dimostra `--controllo`, che li confronta con
quelli presi a monte con pyswisseph e riportati nell'ordine 2170: ventisette
quantita', tutte alla quarta cifra decimale. Se il controllo cade, il
generatore e' rotto e non si va avanti.

**LICENZA.** Swiss Ephemeris e' AGPL e l'involucro WebAssembly e' GPL 3.
Restano sul PC di sviluppo: NON entrano nell'app e non vengono distribuiti.
Nel repository entrano solo i NUMERI, che sono fatti sul cielo e non codice.
La dipendenza vive in `tool/package.json`, mai nel `pubspec.yaml`.

Uso, sempre in UTC:
    python tool/riferimento_carta.py 1990 6 15 12 30 41.9028 12.4964
    python tool/riferimento_carta.py --controllo
"""

import json
import os
import subprocess
import sys

QUI = os.path.dirname(os.path.abspath(__file__))
MOTORE = os.path.join(QUI, 'riferimento_carta.mjs')

# I NUMERI DI CONTROLLO, dall'ordine 2170: Roma, 15 giugno 1990, 12:30 UTC,
# latitudine 41,9028 longitudine 12,4964, giorno giuliano 2448058,0208333,
# sistema Placidus. Presi a monte con pyswisseph, e qui servono a dire se
# questo generatore e' lo stesso strumento o un altro.
CONTROLLO = {
    'quando': (1990, 6, 15, 12, 30),
    'dove': (41.9028, 12.4964),
    'corpi': {
        'sun': 84.1495, 'moon': 345.6364, 'mercury': 65.7265,
        'venus': 48.8021, 'mars': 11.0563, 'jupiter': 105.8940,
        'saturn': 294.0307, 'uranus': 278.1644, 'neptune': 283.7166,
        'pluto': 225.4011, 'north_node': 309.6968, 'lilith': 234.9537,
    },
    'angoli': {'asc': 190.6083, 'mc': 102.4482, 'vertex': 27.5366},
    'cuspidi': [190.6083, 217.2930, 248.3053, 282.4482, 316.0487, 345.7687,
                10.6083, 37.2930, 68.3053, 102.4482, 136.0487, 165.7687],
}

# Alla QUARTA cifra decimale, come chiede l'ordine: un decimillesimo di grado.
#
# **LA RAGIONE VERA DELLA DIFFERENZA SULLA LUNA, corretta il 10 agosto 2026.**
# La prima stesura pretendeva 0,00006 e su ventisette quantita' ne cadeva una:
# la Luna, 345,636488 qui contro i 345,6364 dell'ordine 2170, scarto 0,000088.
# Avevo scritto che era un troncamento della quarta cifra. **Non lo era.**
#
# Sono TRE DECIMI DI SECONDO D'ARCO fra due modalita' dello stesso Swiss
# Ephemeris: quella analitica di Moshier, che questo generatore usa perche' non
# vuole file da scaricare, e quella coi file di effemeridi con cui i numeri di
# controllo erano stati presi a monte. Le due divergono di quest'ordine di
# grandezza sulla Luna, che e' il corpo piu' veloce e il piu' sensibile alle
# perturbazioni.
#
# **Contava saperlo anche se il numero non cambiava:** un troncamento non
# peggiora mai, una differenza di modello puo' crescere su altri corpi o altre
# epoche. A dire quale delle due modalita' sia piu' vicina al cielo vero e'
# stata una terza fonte: JPL Horizons da' 345,6364781, e la Moshier ne dista un
# centomillesimo di grado contro i sette dell'altra.
TOLLERANZA = 0.0001


def calcola(anno, mese, giorno, ora, minuto, lat, lon):
    """I numeri del cielo, dal motore Swiss Ephemeris."""
    if not os.path.isfile(MOTORE):
        raise SystemExit('manca ' + MOTORE)
    esito = subprocess.run(
        ['node', MOTORE, str(anno), str(mese), str(giorno), str(ora),
         str(minuto), str(lat), str(lon)],
        capture_output=True, text=True, shell=True)
    if esito.returncode != 0:
        raise SystemExit(
            'il motore non ha risposto (codice ' + str(esito.returncode) +
            '):\n' + esito.stderr[:800] +
            '\n\nSe manca la dipendenza: cd tool && npm install')
    return json.loads(esito.stdout)


def _scarto(a, b):
    """Scarto fra due longitudini, tenendo conto del giro."""
    d = abs(a - b) % 360.0
    return 360.0 - d if d > 180.0 else d


def controllo():
    """Il generatore e' lo strumento giusto, oppure ci si ferma qui."""
    anno, mese, giorno, ora, minuto = CONTROLLO['quando']
    lat, lon = CONTROLLO['dove']
    print('CONTROLLO del generatore sul caso di Roma, %d-%02d-%02d %02d:%02d '
          'UTC, lat %s lon %s' % (anno, mese, giorno, ora, minuto, lat, lon))
    fuori = calcola(anno, mese, giorno, ora, minuto, lat, lon)
    print('giorno giuliano: %.7f (atteso 2448058,0208333)' % fuori['jd_ut'])

    colpe = []
    peggiore = 0.0

    def confronta(nome, avuto, atteso):
        nonlocal peggiore
        s = _scarto(avuto, atteso)
        peggiore = max(peggiore, s)
        stato = 'ok ' if s <= TOLLERANZA else 'NO '
        print('  %s %-12s %12.6f  atteso %12.4f  scarto %.6f'
              % (stato, nome, avuto, atteso, s))
        if s > TOLLERANZA:
            colpe.append('%s: %.6f contro %.4f, scarto %.6f'
                         % (nome, avuto, atteso, s))

    for nome, atteso in CONTROLLO['corpi'].items():
        confronta(nome, fuori['corpi'][nome], atteso)
    for nome, atteso in CONTROLLO['angoli'].items():
        confronta(nome.upper(), fuori['angoli'][nome], atteso)
    for i, atteso in enumerate(CONTROLLO['cuspidi'], start=1):
        confronta('cuspide %d' % i, fuori['cuspidi'][i - 1], atteso)

    print()
    print('scarto massimo: %.6f gradi su %d quantita\''
          % (peggiore, len(CONTROLLO['corpi']) + len(CONTROLLO['angoli'])
             + len(CONTROLLO['cuspidi'])))
    print('Chirone: NON prodotto in modalita\' Moshier, e si dichiara invece '
          'di ometterlo in silenzio.')
    if colpe:
        print()
        print('IL GENERATORE E\' ROTTO, e non si va avanti:')
        for c in colpe:
            print('  ' + c)
        return 1
    print('Il generatore e\' lo strumento giusto.')
    return 0


def main():
    if len(sys.argv) == 2 and sys.argv[1] == '--controllo':
        raise SystemExit(controllo())
    if len(sys.argv) != 8:
        raise SystemExit(__doc__)
    anno, mese, giorno, ora, minuto = (int(x) for x in sys.argv[1:6])
    lat, lon = float(sys.argv[6]), float(sys.argv[7])
    fuori = calcola(anno, mese, giorno, ora, minuto, lat, lon)
    print(json.dumps(fuori, indent=2))


if __name__ == '__main__':
    main()

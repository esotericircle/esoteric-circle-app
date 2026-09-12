# -*- coding: utf-8 -*-
"""Genera assets/data/nazioni.csv dai contorni di Natural Earth. Ordine BE.03.

FONTE: Natural Earth 1:110m, admin_0_countries, PUBBLICO DOMINIO
(naturalearthdata.com dichiara: no permission needed, free for any use).
La copia usata sta in geojson su github.com/nvkelso/natural-earth-vector.

**L'AGGANCIO AL CATALOGO NON PASSA DAI NOMI.** Il catalogo dei luoghi porta i
paesi in italiano ("Cina", "Corea del Sud") e Natural Earth in inglese: una
tavola di traduzione a mano sarebbe la seconda porta sullo stesso dato, e
invecchierebbe. Qui ogni paese del catalogo VOTA col corpo delle sue citta':
si conta in quale contorno cade ciascuna, e il contorno che ne raccoglie di
piu' e' il suo. Un paese le cui citta' non cadono in nessun contorno (i
microstati che l'1:110m non disegna) resta fuori dall'asset, e a schermo
tiene la regione con le coste, dichiarato.

Uso, dalla radice del repository (il geojson va scaricato accanto o passato):
    python tool/genera_nazioni.py <percorso del ne_110m_admin_0_countries.geojson>

Formato di assets/data/nazioni.csv, riga per riga:
    v1
    <PaeseItaliano>;<anelli>
    <lon,lat lon,lat ...>   (un anello per riga, quanti dichiarati)
Le coordinate sono arrotondate al centesimo di grado: alla scala di una
nazione e' meno di un pixel, e il file resta piccolo.
"""
from __future__ import annotations

import collections
import json
import pathlib
import sys

RADICE = pathlib.Path(__file__).resolve().parent.parent
CATALOGO = RADICE / 'assets' / 'data' / 'luoghi.csv'
USCITA = RADICE / 'assets' / 'data' / 'nazioni.csv'


def dentro(lon: float, lat: float, anello) -> bool:
    dentro = False
    j = len(anello) - 1
    for i in range(len(anello)):
        xi, yi = anello[i]
        xj, yj = anello[j]
        if (yi > lat) != (yj > lat) and \
                lon < (xj - xi) * (lat - yi) / (yj - yi) + xi:
            dentro = not dentro
        j = i
    return dentro


def poligoni_di(geom) -> list:
    """I soli anelli esterni: i buchi a questa scala non servono a nessuno."""
    if geom['type'] == 'Polygon':
        return [geom['coordinates'][0]]
    if geom['type'] == 'MultiPolygon':
        return [p[0] for p in geom['coordinates']]
    return []


def main() -> None:
    if len(sys.argv) < 2:
        sys.exit('serve il percorso del geojson di Natural Earth')
    ne = json.load(open(sys.argv[1], encoding='utf-8'))
    contorni = []  # (nome_ne, [anelli])
    for f in ne['features']:
        anelli = poligoni_di(f['geometry'])
        if anelli:
            contorni.append((f['properties']['ADMIN'], anelli))

    # Le citta' estere del catalogo, per paese italiano.
    citta = collections.defaultdict(list)
    for r in CATALOGO.read_text(encoding='utf-8').split('\n')[2:]:
        c = r.split(';')
        if len(c) >= 5 and len(c[2]) > 2:
            citta[c[2]].append((float(c[4]), float(c[3])))  # lon, lat

    # Il voto: ogni citta' cerca il suo contorno. **Con la sonda costiera**:
    # una capitale sul mare puo' cadere di un soffio FUORI dal contorno
    # dell'1:110m (Montevideo cadeva in acqua), quindi se il punto esatto
    # non trova nessuno si riprova su una corona di punti fino a mezzo
    # grado attorno.
    sonde = [(0.0, 0.0)]
    for r in (0.15, 0.3, 0.5):
        for dx, dy in ((r, 0), (-r, 0), (0, r), (0, -r),
                       (r, r), (r, -r), (-r, r), (-r, -r)):
            sonde.append((dx, dy))
    scelto = {}
    for paese, punti in citta.items():
        voti = collections.Counter()
        for lon, lat in punti:
            trovato = None
            for dx, dy in sonde:
                for indice, (_, anelli) in enumerate(contorni):
                    if any(dentro(lon + dx, lat + dy, a) for a in anelli):
                        trovato = indice
                        break
                if trovato is not None:
                    break
            if trovato is not None:
                voti[trovato] += 1
        if voti:
            scelto[paese] = voti.most_common(1)[0][0]

    presi = sorted(scelto)
    fuori = sorted(set(citta) - set(scelto))
    print(f'paesi agganciati: {len(presi)} su {len(citta)}')
    print(f'fuori (restano alla regione con le coste): {fuori}')

    righe = ['v1']
    for paese in presi:
        _, anelli = contorni[scelto[paese]]
        righe.append(f'{paese};{len(anelli)}')
        for anello in anelli:
            righe.append(' '.join(
                f'{lon:.2f},{lat:.2f}' for lon, lat in anello))
    USCITA.write_text('\n'.join(righe) + '\n', encoding='utf-8')
    print(f'scritto {USCITA.relative_to(RADICE)}: '
          f'{USCITA.stat().st_size} byte')


if __name__ == '__main__':
    main()

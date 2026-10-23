"""I RIFERIMENTI DEL NODO NORD. Ordine FT voce FT.05, 14 ottobre 2026.

Scrive `docs/collaudo/FT/riferimenti_del_nodo_nord.csv`: la longitudine del
Nodo Nord lunare medio, dalla libreria Swiss Ephemeris (`pyswisseph`, lo
stesso motore che FreeAstroAPI usa in produzione, CLAUDE.md: "Dati
astrologici: FreeAstroAPI basata su effemeridi svizzere"), su dieci istanti
dentro l'intervallo verificato di IlCieloDiMeeus (31 dicembre 1899, 31
dicembre 2099): dieci nascite, una per coppia, scelte a mano per coprire
decenni diversi.

Il calcolo del Nodo Nord e' un elemento MEDIO (una formula sulle costanti
dell'orbita, non una posizione da un'effemeride numerica integrata): non
serve il file binario de440s.bsp, Swiss Ephemeris lo calcola con la sua
serie Moshier, sempre disponibile senza download. E' comunque una fonte
terza indipendente dalla formula di Meeus usata in `IlCieloDiMeeus`: la
serie di Swiss Ephemeris per gli elementi medi della Luna non e' la stessa
di Meeus (Astronomical Algorithms cap. 22).

Uso: python tool/riferimenti_del_nodo_nord.py
"""
import io
from pathlib import Path

import swisseph as swe

RADICE = Path(__file__).resolve().parent.parent
USCITA = RADICE / 'docs' / 'collaudo' / 'FT' / 'riferimenti_del_nodo_nord.csv'

# Dieci nascite, una per coppia (venti persone), decenni diversi dentro
# l'intervallo verificato di IlCieloDiMeeus. Istante e ora UT, non civile.
NASCITE = [
    ('1905-03-14T08:00:00', 'coppia 1'),
    ('1918-11-02T23:45:00', 'coppia 2'),
    ('1932-06-21T12:00:00', 'coppia 3'),
    ('1947-01-30T04:15:00', 'coppia 4'),
    ('1959-08-09T17:30:00', 'coppia 5'),
    ('1973-12-25T00:00:00', 'coppia 6'),
    ('1986-04-17T09:20:00', 'coppia 7'),
    ('1999-09-05T21:10:00', 'coppia 8'),
    ('2042-02-28T06:40:00', 'coppia 9'),
    ('2088-07-19T15:55:00', 'coppia 10'),
]


def jd_ut(iso):
    from datetime import datetime
    dt = datetime.fromisoformat(iso)
    ore = dt.hour + dt.minute / 60.0 + dt.second / 3600.0
    return swe.julday(dt.year, dt.month, dt.day, ore)


out = io.StringIO()
out.write('# Swiss Ephemeris (pyswisseph, Moshier), Nodo Nord medio, gradi\n')
out.write('istante,jd_ut,nodo_nord\n')
for istante, _nome in NASCITE:
    jd = jd_ut(istante)
    dati, _flag, _errore = swe.calc_ut(jd, swe.MEAN_NODE, swe.FLG_MOSEPH)
    lon = dati[0]
    out.write(f'{istante},{jd:.6f},{lon % 360:.6f}\n')
USCITA.parent.mkdir(parents=True, exist_ok=True)
io.open(USCITA, 'w', encoding='utf-8', newline='\n').write(out.getvalue())
print('scritto', USCITA, len(NASCITE), 'istanti')

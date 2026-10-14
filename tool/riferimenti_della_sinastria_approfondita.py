"""I RIFERIMENTI DELLA SINASTRIA APPROFONDITA. Ordine FT voce FT.05, 14
ottobre 2026: "Prova del calcolo contro una fonte terza su almeno dieci
coppie, con gli scarti dichiarati".

Scrive `docs/collaudo/FT/riferimenti_della_sinastria_approfondita.csv`: per
dieci coppie (venti nascite, decenni diversi dentro l'intervallo verificato
di IlCieloDiMeeus) le longitudini degli undici punti della Sinastria
approfondita, dalla libreria Swiss Ephemeris (`pyswisseph`, serie Moshier,
senza file binari), lo stesso motore su cui poggia FreeAstroAPI in
produzione. La prova `test/la_sinastria_approfondita_contro_il_riferimento
_test.dart` rifa' gli aspetti delle dieci coppie dai due cieli, quello di
Meeus e quello svizzero, e li confronta.

Uso: python tool/riferimenti_della_sinastria_approfondita.py
"""
import io
from datetime import datetime
from pathlib import Path

import swisseph as swe

RADICE = Path(__file__).resolve().parent.parent
USCITA = (RADICE / 'docs' / 'collaudo' / 'FT' /
          'riferimenti_della_sinastria_approfondita.csv')

# Dieci coppie, istanti in tempo universale. La prima persona di ogni coppia
# e' la nascita gia' usata per il Nodo Nord.
COPPIE = [
    ('1905-03-14T08:00:00', '1907-10-29T19:30:00'),
    ('1918-11-02T23:45:00', '1921-05-17T06:10:00'),
    ('1932-06-21T12:00:00', '1935-02-03T15:45:00'),
    ('1947-01-30T04:15:00', '1944-09-12T22:05:00'),
    ('1959-08-09T17:30:00', '1962-12-01T10:20:00'),
    ('1973-12-25T00:00:00', '1976-07-04T13:35:00'),
    ('1986-04-17T09:20:00', '1990-05-12T14:30:00'),
    ('1999-09-05T21:10:00', '1992-09-03T08:15:00'),
    ('2042-02-28T06:40:00', '2040-11-11T02:50:00'),
    ('2088-07-19T15:55:00', '2085-03-26T18:25:00'),
]

PUNTI = [
    ('sole', swe.SUN), ('luna', swe.MOON), ('mercurio', swe.MERCURY),
    ('venere', swe.VENUS), ('marte', swe.MARS), ('giove', swe.JUPITER),
    ('saturno', swe.SATURN), ('urano', swe.URANUS), ('nettuno', swe.NEPTUNE),
    ('plutone', swe.PLUTO), ('nodoNord', swe.MEAN_NODE),
]


def jd_ut(iso):
    dt = datetime.fromisoformat(iso)
    ore = dt.hour + dt.minute / 60.0 + dt.second / 3600.0
    return swe.julday(dt.year, dt.month, dt.day, ore)


out = io.StringIO()
out.write('# Swiss Ephemeris (pyswisseph, Moshier), longitudini '
          'eclittiche geocentriche apparenti, gradi\n')
out.write('coppia,persona,istante,' + ','.join(p for p, _ in PUNTI) + '\n')
for n, coppia in enumerate(COPPIE, start=1):
    for chi, istante in zip(('tu', 'suo'), coppia):
        jd = jd_ut(istante)
        valori = []
        for _nome, corpo in PUNTI:
            dati, _flag = swe.calc_ut(jd, corpo, swe.FLG_MOSEPH)[:2]
            valori.append(f'{dati[0] % 360:.6f}')
        out.write(f'{n},{chi},{istante},' + ','.join(valori) + '\n')
USCITA.parent.mkdir(parents=True, exist_ok=True)
with open(USCITA, 'w', encoding='utf-8', newline='\n') as f:
    f.write(out.getvalue())
print('scritto', USCITA)

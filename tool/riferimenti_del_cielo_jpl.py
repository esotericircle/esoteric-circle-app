"""I RIFERIMENTI DEL CIELO DAL JPL. Ordine FD voce 02.

Scrive `docs/collaudo/FD/riferimenti_del_cielo.csv`: la longitudine
eclittica geocentrica apparente (eclittica ed equinozio veri della data) dei
dieci corpi e la latitudine della Luna, dal JPL DE440s letto con skyfield,
su sessanta istanti fra il 31 dicembre 1899 e il 31 dicembre 2099, i due
estremi compresi. E' la fonte terza contro cui la prova
`il_cielo_di_meeus_contro_il_jpl_test.dart` misura il motore di Meeus.

Gli istanti sono in tempo universale (UT1), come li usa l'app.

Uso: python tool/riferimenti_del_cielo_jpl.py <cartella con de440s.bsp>
"""
import io
import random
import sys
from pathlib import Path

from skyfield.api import Loader
from skyfield.framelib import ecliptic_frame

RADICE = Path(__file__).resolve().parent.parent
USCITA = RADICE / 'docs' / 'collaudo' / 'FD' / 'riferimenti_del_cielo.csv'

L = Loader(sys.argv[1])
ts = L.timescale()
eph = L('de440s.bsp')
terra = eph['earth']

CORPI = [('sole', 'sun'), ('luna', 'moon'), ('mercurio', 'mercury'),
         ('venere', 'venus'), ('marte', 'mars barycenter'),
         ('giove', 'jupiter barycenter'), ('saturno', 'saturn barycenter'),
         ('urano', 'uranus barycenter'), ('nettuno', 'neptune barycenter'),
         ('plutone', 'pluto barycenter')]

# Sessanta istanti: gli estremi dichiarati, piu' cinquantotto a caso con un
# seme fisso, cosi' il file si rigenera uguale.
caso = random.Random(20261005)
PRIMO = 2415019.5   # 1899-12-31 0h: il 1 gennaio 1900 di Roma in UT
ULTIMO = 2488069.5  # 2100-01-01
istanti = [PRIMO, ULTIMO - 0.01]
istanti += sorted(caso.uniform(PRIMO, ULTIMO) for _ in range(58))

out = io.StringIO()
out.write('# JPL DE440s con skyfield, longitudine eclittica apparente della data, gradi\n')
out.write('jd_ut,' + ','.join(n for n, _ in CORPI) + ',luna_latitudine\n')
for jd in istanti:
    t = ts.ut1_jd(jd)
    riga = ['%.6f' % jd]
    for _, nome in CORPI:
        lat, lon, _ = terra.at(t).observe(eph[nome]).apparent().frame_latlon(ecliptic_frame)
        riga.append('%.6f' % (lon.degrees % 360))
    lat, _, _ = terra.at(t).observe(eph['moon']).apparent().frame_latlon(ecliptic_frame)
    riga.append('%.6f' % lat.degrees)
    out.write(','.join(riga) + '\n')
USCITA.parent.mkdir(parents=True, exist_ok=True)
io.open(USCITA, 'w', encoding='utf-8', newline='\n').write(out.getvalue())
print('scritto', USCITA, len(istanti), 'istanti')

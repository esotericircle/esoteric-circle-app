# -*- coding: utf-8 -*-
"""I CONFINI DELLE COSTELLAZIONI ZODIACALI SULL'ECLITTICA J2000.

Ordine FV voce FV.04, 15 ottobre 2026. Calcola dove l'eclittica media J2000
(latitudine zero) attraversa i confini ufficiali delle costellazioni della
IAU (Delporte 1930, coordinate B1875), con la tabella di Roman (1987),
"Identification of a Constellation from a Position", PASP 99, 695,
VizieR VI/42, che astropy porta con se' (astropy.coordinates.get_constellation
precessa da solo il punto all'equinozio B1875 prima di cercarlo).

Si scorre la longitudine eclittica J2000 a passi di un millesimo di grado e
si scrive ogni cambio di costellazione. Uscita: le righe da copiare in
lib/core/lunario/il_motore_lunare.dart e il file
docs/collaudo/FV/fv04_confini_delle_costellazioni.txt.

Uso: python -I tool/lunario_confini_delle_costellazioni.py <file di uscita>
"""
import sys

import numpy as np
from astropy import units as u
from astropy.coordinates import BarycentricMeanEcliptic, SkyCoord, get_constellation
from astropy.time import Time


def main():
    uscita = sys.argv[1]
    passo = 0.001
    lon = np.arange(0.0, 360.0, passo)
    c = SkyCoord(lon=lon * u.deg, lat=np.zeros_like(lon) * u.deg,
                 frame=BarycentricMeanEcliptic(equinox=Time('J2000')))
    nomi = get_constellation(c, short_name=True)
    righe = []
    for i in range(len(lon)):
        prima = nomi[i - 1]
        if nomi[i] != prima:
            # Il confine sta a meta' fra i due campioni.
            confine = (lon[i] - passo / 2.0) % 360.0
            righe.append((confine, prima, nomi[i]))
    righe.sort()
    with open(uscita, 'w', encoding='utf-8', newline='') as f:
        f.write('# I confini IAU (Delporte 1930, B1875; Roman 1987, VizieR VI/42,\n')
        f.write('# via astropy.coordinates.get_constellation) sull\'eclittica\n')
        f.write('# media J2000, latitudine zero, passo di scansione 0.001 gradi.\n')
        f.write('# longitudine_J2000\tda\ta\n')
        for confine, da, a in righe:
            f.write('%.3f\t%s\t%s\n' % (confine, da, a))
    for confine, da, a in righe:
        print('%.3f %s -> %s' % (confine, da, a))


if __name__ == '__main__':
    main()

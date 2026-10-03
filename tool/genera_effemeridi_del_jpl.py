# -*- coding: utf-8 -*-
"""Genera lib/core/astro/le_effemeridi_del_jpl.dart: polinomi di Chebyshev
della longitudine eclittica apparente (equinozio della data) di Sole, Venere,
Giove e Saturno, adattati sul JPL DE421 con skyfield.

Ordine ES voce 04: la Rivoluzione Solare vuole il Sole al secondo d'arco (un
centesimo di grado sono quattordici minuti sull'istante del ritorno, e
l'Ascendente si muove di un grado ogni quattro minuti).

Uso: python tool/genera_effemeridi_del_jpl.py <cartella con de421.bsp>
Stampa l'errore massimo di ogni corpo su punti di controllo fuori dai nodi.
"""
import math
import subprocess
import sys
from pathlib import Path

import numpy as np
from skyfield.api import Loader
from skyfield.framelib import ecliptic_frame

RADICE = Path(__file__).resolve().parent.parent
USCITA = RADICE / 'lib' / 'core' / 'astro' / 'le_effemeridi_del_jpl.dart'

L = Loader(sys.argv[1])
ts = L.timescale()
eph = L('de421.bsp')
terra = eph['earth']

# corpo, nome skyfield, primo giorno giuliano UT, ultimo, lunghezza, grado
CORPI = [
    ('sole', 'sun', 2415020.5, 2469807.5, 32, 10),       # 1900-01-01 .. 2051-01-01
    ('venere', 'venus', 2458484.5, 2469807.5, 16, 10),   # 2019-01-01 .. 2051-01-01
    ('giove', 'jupiter barycenter', 2458484.5, 2469807.5, 64, 8),
    ('saturno', 'saturn barycenter', 2458484.5, 2469807.5, 64, 8),
]


def longitudini(nome, jd):
    t = ts.ut1_jd(jd)
    ast = terra.at(t).observe(eph[nome]).apparent()
    _, lo, _ = ast.frame_latlon(ecliptic_frame)
    return lo.degrees


def adatta(nome, jd0, jd1, lung, grado):
    segmenti = []
    errore = 0.0
    n = int(round((jd1 - jd0) / lung))
    for s in range(n):
        a = jd0 + s * lung
        k = np.arange(grado + 1)
        x = np.cos(np.pi * (k + 0.5) / (grado + 1))  # nodi di Chebyshev
        jd = a + (x + 1) * lung / 2
        y = np.unwrap(np.radians(longitudini(nome, jd)))
        y = np.degrees(y)
        c = np.polynomial.chebyshev.chebfit(x, y, grado)
        # controllo fuori dai nodi
        xc = np.linspace(-1, 1, 9)
        yc = np.degrees(np.unwrap(np.radians(longitudini(nome, a + (xc + 1) * lung / 2))))
        yv = np.polynomial.chebyshev.chebval(xc, c)
        d = (yv - yc + 180) % 360 - 180
        errore = max(errore, float(np.max(np.abs(d))))
        segmenti.append(c)
    return segmenti, errore


def main():
    righe = ['// GENERATO da tool/genera_effemeridi_del_jpl.py sul JPL DE421 (skyfield).',
             '// Non modificare a mano: rigenerare.',
             '',
             '/// **LE EFFEMERIDI DEL JPL, IN POLINOMI.** Ordine ES voce 04.',
             '///',
             '/// Coefficienti di Chebyshev della longitudine eclittica apparente',
             '/// (equinozio della data, nutazione e aberrazione comprese), in',
             '/// decimilionesimi di grado, per segmenti di giorni giuliani UT.',
             'abstract final class LeEffemeridiDelJpl {']
    for corpo, nome, jd0, jd1, lung, grado in CORPI:
        seg, err = adatta(nome, jd0, jd1, lung, grado)
        print(f'{corpo}: {len(seg)} segmenti, errore massimo {err * 3600:.3f} secondi d\'arco')
        righe.append(f'  /// {corpo}: errore massimo misurato fuori dai nodi {err * 3600:.3f}".')
        righe.append(f'  static const double {corpo}Inizio = {jd0};')
        righe.append(f'  static const double {corpo}Fine = {jd1};')
        righe.append(f'  static const int {corpo}Lunghezza = {lung};')
        righe.append(f'  static const int {corpo}Grado = {grado};')
        righe.append(f'  static const List<int> {corpo} = [')
        for c in seg:
            righe.append('    ' + ', '.join(str(int(round(v * 1e7))) for v in c) + ',')
        righe.append('  ];')
        righe.append('')
    righe.append('}')
    USCITA.write_text('\n'.join(righe) + '\n', encoding='utf-8', newline='\n')
    subprocess.run(['dart', 'format', str(USCITA)], check=True, capture_output=True,
                   shell=sys.platform == 'win32')
    print('scritto', USCITA, USCITA.stat().st_size, 'byte')


if __name__ == '__main__':
    main()

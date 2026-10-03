# -*- coding: utf-8 -*-
"""Riferimento indipendente per l'anno vedico, ordine EU voce 02.

skyfield + JPL DE421: per dieci nascite, la Luna di nascita e Giove e
Saturno al compleanno dell'anno in corso al 1 ottobre 2026 (12:00 UTC del
giorno del compleanno), longitudini apparenti sull'eclittica della data,
meno l'ayanamsa di Lahiri media piu' la nutazione in longitudine, la stessa
definizione dell'app (ISegniDelleTradizioni.ayanamsaMedia, interpolata
sulla Swiss Ephemeris). Scrive docs/collaudo/EU/gochara_jpl.csv.

Uso: python tool/gochara_jpl.py <cartella che contiene de421.bsp>
"""
import csv
import datetime as dt
import sys
from zoneinfo import ZoneInfo

from skyfield.api import Loader
from skyfield.framelib import ecliptic_frame
from skyfield.nutationlib import iau2000b_radians

L = Loader(sys.argv[1])
ts = L.timescale()
eph = L('de421.bsp')
terra = eph['earth']
CORPI = {'luna': 'moon', 'giove': 'jupiter barycenter', 'saturno': 'saturn barycenter'}

NASCITE = [
    '1990-03-15 07:30', '1985-07-04 20:10', '1999-12-31 23:05',
    '1972-11-23 13:00', '1995-12-24 05:45', '1968-06-21 10:00',
    '2004-02-29 17:20', '1979-09-09 01:15', '1958-04-30 19:30',
    '2011-06-30 17:45',
]
OGGI = dt.date(2026, 10, 1)


def ayanamsa(t):
    T = (t.tt - 2451545.0) / 36525.0
    media = 23.8570923260 + 1.3968879401 * T + 0.0003070962 * T * T
    dpsi, _ = iau2000b_radians(t)
    return media + dpsi * 180 / 3.141592653589793


def siderale(t, nome):
    ast = terra.at(t).observe(eph[CORPI[nome]]).apparent()
    _, lo, _ = ast.frame_latlon(ecliptic_frame)
    return (lo.degrees - ayanamsa(t)) % 360


def main():
    righe = []
    for n in NASCITE:
        locale = dt.datetime.strptime(n, '%Y-%m-%d %H:%M').replace(tzinfo=ZoneInfo('Europe/Rome'))
        utc = locale.astimezone(dt.timezone.utc)
        t0 = ts.from_datetime(utc)
        rashi = int(siderale(t0, 'luna') // 30)
        anno = OGGI.year if (OGGI.month, OGGI.day) >= (locale.month, locale.day) else OGGI.year - 1
        giorno = locale.day if not (locale.month == 2 and locale.day == 29) else 28
        t1 = ts.utc(anno, locale.month, giorno, 12)
        g = int(siderale(t1, 'giove') // 30)
        s = int(siderale(t1, 'saturno') // 30)
        casa = lambda x: (x - rashi) % 12 + 1
        righe.append([n, rashi, f'{anno}-{locale.month:02d}-{giorno:02d}', g, casa(g), s, casa(s)])
    with open('docs/collaudo/EU/gochara_jpl.csv', 'w', newline='', encoding='utf-8') as f:
        w = csv.writer(f)
        w.writerow(['nascita_locale_roma', 'rashi_luna_nascita', 'compleanno', 'segno_giove',
                    'casa_giove', 'segno_saturno', 'casa_saturno'])
        w.writerows(righe)
    for r in righe:
        print(r)


if __name__ == '__main__':
    main()

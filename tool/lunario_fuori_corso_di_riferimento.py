# -*- coding: utf-8 -*-
"""I RIFERIMENTI DELLA LUNA FUORI CORSO. Ordine FV voce FV.04, 15 ottobre 2026.

Scrive `docs/collaudo/FV/fv04_luna_fuori_corso_riferimento.json` con due
fonti esterne al motore del telefono:

1. MOON TRACKS (https://www.moontracks.com/void_of_course_moon_aspects.html,
   letta il 15 ottobre 2026): ventisette intervalli di Luna fuori corso di
   ottobre e novembre 2026, in UTC, con l'aspetto che li apre. Trascritti a
   mano qui sotto, al minuto, come li pubblica il sito.

2. SWISS EPHEMERIS (`pyswisseph` 2.10.03, serie Moshier, senza file binari):
   la stessa definizione classica calcolata in Python, indipendente dal
   codice Dart, per tutto il 2026: ingressi della Luna nei segni tropicali
   e ultimo aspetto tolemaico esatto (0, 60, 90, 120, 180 gradi) a Sole,
   Mercurio, Venere, Marte, Giove, Saturno prima dell'uscita dal segno.
   Per confronto scrive anche la variante moderna con Urano, Nettuno,
   Plutone.

Uso: python -I tool/lunario_fuori_corso_di_riferimento.py
"""
import json
from datetime import datetime, timedelta, timezone
from pathlib import Path

import swisseph as swe

RADICE = Path(__file__).resolve().parent.parent
USCITA = RADICE / 'docs' / 'collaudo' / 'FV' / 'fv04_luna_fuori_corso_riferimento.json'

SEGNI = ['Ariete', 'Toro', 'Gemelli', 'Cancro', 'Leone', 'Vergine',
         'Bilancia', 'Scorpione', 'Sagittario', 'Capricorno', 'Acquario',
         'Pesci']

CLASSICI = [swe.SUN, swe.MERCURY, swe.VENUS, swe.MARS, swe.JUPITER, swe.SATURN]
MODERNI = CLASSICI + [swe.URANUS, swe.NEPTUNE, swe.PLUTO]
ASPETTI = [0.0, 60.0, 90.0, 120.0, 180.0, 240.0, 270.0, 300.0]

# Moon Tracks, ottobre e novembre 2026, UTC: inizio, aspetto, segno del
# vuoto, fine (ingresso), segno in cui la Luna entra.
MOON_TRACKS = [
    ('2026-10-02 02:41', 'Moon Sxt Jup', 'Gemelli', '2026-10-02 19:54', 'Cancro'),
    ('2026-10-03 15:08', 'Moon Sqr Sat', 'Cancro', '2026-10-04 22:54', 'Leone'),
    ('2026-10-06 10:22', 'Moon Cnj Jup', 'Leone', '2026-10-07 02:52', 'Vergine'),
    ('2026-10-07 18:56', 'Moon Sxt Mer', 'Vergine', '2026-10-09 08:10', 'Bilancia'),
    ('2026-10-10 23:07', 'Moon Sxt Jup', 'Bilancia', '2026-10-11 15:21', 'Scorpione'),
    ('2026-10-13 08:45', 'Moon Sqr Jup', 'Scorpione', '2026-10-14 00:59', 'Sagittario'),
    ('2026-10-15 21:55', 'Sun Sxt Moon', 'Sagittario', '2026-10-16 12:57', 'Capricorno'),
    ('2026-10-18 16:12', 'Sun Sqr Moon', 'Capricorno', '2026-10-19 01:39', 'Acquario'),
    ('2026-10-21 08:42', 'Sun Tri Moon', 'Acquario', '2026-10-21 12:35', 'Pesci'),
    ('2026-10-23 03:31', 'Moon Tri Mer', 'Pesci', '2026-10-23 19:53', 'Ariete'),
    ('2026-10-25 22:59', 'Moon Opp Ven', 'Ariete', '2026-10-25 23:34', 'Toro'),
    ('2026-10-27 14:51', 'Moon Sqr Jup', 'Toro', '2026-10-28 01:01', 'Gemelli'),
    ('2026-10-29 21:43', 'Moon Tri Ven', 'Gemelli', '2026-10-30 02:05', 'Cancro'),
    ('2026-10-31 21:59', 'Moon Sqr Ven', 'Cancro', '2026-11-01 04:18', 'Leone'),
    ('2026-11-03 00:10', 'Moon Sxt Ven', 'Leone', '2026-11-03 08:27', 'Vergine'),
    ('2026-11-04 06:57', 'Moon Sxt Mer', 'Vergine', '2026-11-05 14:38', 'Bilancia'),
    ('2026-11-07 13:19', 'Moon Sxt Jup', 'Bilancia', '2026-11-07 22:40', 'Scorpione'),
    ('2026-11-09 23:25', 'Moon Sqr Jup', 'Scorpione', '2026-11-10 08:35', 'Sagittario'),
    ('2026-11-12 11:29', 'Moon Tri Jup', 'Sagittario', '2026-11-12 20:27', 'Capricorno'),
    ('2026-11-14 18:55', 'Moon Sqr Ven', 'Capricorno', '2026-11-15 09:24', 'Acquario'),
    ('2026-11-17 14:25', 'Moon Opp Mar', 'Acquario', '2026-11-17 21:19', 'Pesci'),
    ('2026-11-20 01:46', 'Sun Tri Moon', 'Pesci', '2026-11-20 05:52', 'Ariete'),
    ('2026-11-22 07:38', 'Moon Tri Mar', 'Ariete', '2026-11-22 10:09', 'Toro'),
    ('2026-11-24 10:09', 'Moon Sqr Mar', 'Toro', '2026-11-24 11:09', 'Gemelli'),
    ('2026-11-26 05:23', 'Moon Sxt Jup', 'Gemelli', '2026-11-26 10:51', 'Cancro'),
    ('2026-11-28 05:40', 'Moon Sqr Ven', 'Cancro', '2026-11-28 11:20', 'Leone'),
    ('2026-11-30 10:10', 'Moon Sxt Ven', 'Leone', '2026-11-30 14:12', 'Vergine'),
]

FLAG = swe.FLG_MOSEPH | swe.FLG_SPEED


def lon(corpo, jd):
    return swe.calc_ut(jd, corpo, FLAG)[0][0]


def jd_di(dt):
    ore = dt.hour + dt.minute / 60.0 + dt.second / 3600.0 + dt.microsecond / 3.6e9
    return swe.julday(dt.year, dt.month, dt.day, ore)


def iso_di(jd):
    y, m, d, ore = swe.revjul(jd)
    base = datetime(y, m, d, tzinfo=timezone.utc)
    return (base + timedelta(hours=ore)).strftime('%Y-%m-%dT%H:%M:%SZ')


def bisezione(f, a, b, passi=50):
    """f(a) < 0 <= f(b): lo zero fra a e b."""
    fa = f(a)
    for _ in range(passi):
        m = (a + b) / 2.0
        if (f(m) < 0) == (fa < 0):
            a, fa = m, f(m)
        else:
            b = m
    return (a + b) / 2.0


def ingressi(jd0, jd1):
    passo = 0.25
    risultato = []
    t = jd0
    s = int(lon(swe.MOON, t) // 30)
    while t < jd1:
        t2 = t + passo
        s2 = int(lon(swe.MOON, t2) // 30)
        if s2 != s:
            confine = s2 * 30.0

            def f(x, c=confine):
                return ((lon(swe.MOON, x) - c + 540.0) % 360.0) - 180.0

            risultato.append((bisezione(f, t, t2), s2))
        t, s = t2, s2
    return risultato


def ultimo_aspetto(jd0, jd1, corpi):
    """L'ultimo aspetto esatto della Luna a uno dei corpi in [jd0, jd1)."""
    migliore = None
    passo = 1.0 / 12.0
    for corpo in corpi:
        t = jd0
        while t < jd1:
            t2 = min(t + passo, jd1)
            for a in ASPETTI:
                def f(x, a=a, corpo=corpo):
                    return ((lon(swe.MOON, x) - lon(corpo, x) - a + 540.0) % 360.0) - 180.0
                fa, fb = f(t), f(t2)
                if fa < 0 <= fb and fb - fa < 90:
                    z = bisezione(f, t, t2)
                    if migliore is None or z > migliore[0]:
                        migliore = (z, swe.get_planet_name(corpo), a)
            t = t2
    return migliore


def fuori_corso(anno, corpi):
    jd0 = swe.julday(anno, 1, 1, 0.0) - 3.0
    jd1 = swe.julday(anno + 1, 1, 1, 0.0) + 3.0
    ing = ingressi(jd0, jd1)
    righe = []
    for (t_prev, _), (t_in, s_in) in zip(ing, ing[1:]):
        ua = ultimo_aspetto(t_prev, t_in, corpi)
        inizio = ua[0] if ua else t_prev
        righe.append({
            'inizio_utc': iso_di(inizio),
            'fine_utc': iso_di(t_in),
            'entra_in': SEGNI[s_in],
            'aspetto': ('%s %d' % (ua[1], int(ua[2]))) if ua else 'nessuno',
        })
    return righe


def main():
    mt = []
    for inizio, aspetto, segno, fine, entra in MOON_TRACKS:
        mt.append({
            'inizio_utc': inizio.replace(' ', 'T') + ':00Z',
            'fine_utc': fine.replace(' ', 'T') + ':00Z',
            'segno': segno,
            'entra_in': entra,
            'aspetto': aspetto,
        })
    dati = {
        'nota': 'Ordine FV voce FV.04. Generato da '
                'tool/lunario_fuori_corso_di_riferimento.py.',
        'moon_tracks': {
            'fonte': 'https://www.moontracks.com/void_of_course_moon_aspects.html '
                     '(e void_of_course_moon_dates.html), letta il 15 ottobre '
                     '2026, orari in UTC al minuto',
            'intervalli': mt,
        },
        'swiss_ephemeris_classica': {
            'fonte': 'pyswisseph %s, serie Moshier; corpi Sole, Mercurio, '
                     'Venere, Marte, Giove, Saturno; aspetti 0 60 90 120 180' % swe.version,
            'intervalli': fuori_corso(2026, CLASSICI),
        },
        'swiss_ephemeris_moderna': {
            'fonte': 'pyswisseph %s, serie Moshier; corpi classici piu\' '
                     'Urano, Nettuno, Plutone' % swe.version,
            'intervalli': fuori_corso(2026, MODERNI),
        },
    }
    # Le fasi esatte del 2026 e la Luna riferita all'eclittica e
    # all'equinozio medi J2000 (FLG_J2000 | FLG_NONUT), per il calendario
    # biodinamico.
    jd0 = swe.julday(2026, 1, 1, 0.0)
    jd1 = swe.julday(2027, 1, 1, 0.0)

    def fasi(bersaglio):
        out = []
        t = jd0
        while t < jd1:
            def f(x):
                return ((lon(swe.MOON, x) - lon(swe.SUN, x) - bersaglio + 540.0) % 360.0) - 180.0
            if f(t) < 0 <= f(t + 0.5) and f(t + 0.5) - f(t) < 90:
                out.append(iso_di(bisezione(f, t, t + 0.5)))
            t += 0.5
        return out

    j2000 = []
    for i in range(24):
        jd = jd0 + i * 15.37
        pos = swe.calc_ut(jd, swe.MOON, swe.FLG_MOSEPH | swe.FLG_J2000 | swe.FLG_NONUT)[0]
        j2000.append({'istante_utc': iso_di(jd), 'longitudine_j2000': round(pos[0], 6)})
    dati['swiss_ephemeris_fasi_2026'] = {
        'fonte': 'pyswisseph %s, serie Moshier; elongazione 0 e 180' % swe.version,
        'lune_nuove_utc': fasi(0.0),
        'lune_piene_utc': fasi(180.0),
    }
    dati['swiss_ephemeris_luna_j2000'] = {
        'fonte': 'pyswisseph %s, serie Moshier, FLG_J2000 | FLG_NONUT: '
                 'eclittica ed equinozio medi J2000' % swe.version,
        'istanti': j2000,
    }
    with open(USCITA, 'w', encoding='utf-8', newline='') as f:
        json.dump(dati, f, ensure_ascii=False, indent=1)
        f.write('\n')
    print('scritto', USCITA)


if __name__ == '__main__':
    main()

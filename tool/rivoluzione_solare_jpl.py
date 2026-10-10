# Riferimento indipendente per la Rivoluzione Solare (ordine ES voce 04):
# skyfield + JPL DE421. Per ogni nascita: la longitudine apparente del Sole
# (eclittica della data), l'istante del ritorno nel 2026, Ascendente e Medio
# Cielo del luogo col tempo siderale apparente e l'obliquita' vera, le
# longitudini apparenti di Luna, Venere, Giove, Saturno.
import csv, math, sys, datetime as dt
from skyfield.api import Loader, wgs84
from skyfield.framelib import ecliptic_frame
from skyfield.searchlib import find_discrete
from skyfield import almanac
from skyfield.nutationlib import iau2000b_radians

L = Loader(r'C:\Users\user\AppData\Local\Temp\claude\C--Users-user-Desktop-esoteric-circle-app--claude-worktrees-esoteric-circle-master-order-63fd44\5062a2df-74fd-434c-bbdb-7c4db5501bc3\scratchpad\es\ricerca')
ts = L.timescale(); eph = L('de421.bsp'); terra = eph['earth']
CORPI = {'sole': 'sun', 'luna': 'moon', 'venere': 'venus', 'giove': 'jupiter barycenter', 'saturno': 'saturn barycenter'}

def lon(t, nome):
    ast = terra.at(t).observe(eph[CORPI[nome]]).apparent()
    lat, lo, _ = ast.frame_latlon(ecliptic_frame)
    return lo.degrees % 360

def asc_mc(t, lat, lonE):
    gast = t.gast * 15.0
    eps = math.radians(t._mean_obliquity_radians * 180 / math.pi if False else 0)  # sotto
    # obliquita' vera
    from skyfield.nutationlib import mean_obliquity
    dpsi, deps = iau2000b_radians(t)
    eps = mean_obliquity(t.tdb) / 3600.0 * math.pi / 180 + deps
    ramc = math.radians((gast + lonE) % 360)
    phi = math.radians(lat)
    asc = math.degrees(math.atan2(math.cos(ramc), -math.sin(ramc) * math.cos(eps) - math.tan(phi) * math.sin(eps))) % 360
    mc = math.degrees(math.atan2(math.sin(ramc), math.cos(ramc) * math.cos(eps))) % 360
    return asc, mc

NASCITE = [
    ('1990-03-15 07:30', 41.9, 12.5), ('1985-07-04 20:10', 45.46, 9.19), ('1999-12-31 23:05', 40.85, 14.27),
    ('1972-11-23 13:00', 45.07, 7.69), ('1995-12-24 05:45', 38.12, 13.36), ('1968-06-21 10:00', 43.77, 11.25),
    ('2004-02-29 17:20', 44.49, 11.34), ('1979-09-09 01:15', 41.12, 16.87), ('1958-04-30 19:30', 44.41, 8.93),
    ('2011-06-30 17:45', 38.11, 15.65),
]
righe = []
for ut, la, lo in NASCITE:
    n = dt.datetime.strptime(ut, '%Y-%m-%d %H:%M').replace(tzinfo=dt.timezone.utc)
    tn = ts.from_datetime(n)
    sole = lon(tn, 'sole')
    # ritorno 2026: cerca attorno al compleanno
    t0 = ts.utc(2026, n.month, n.day - 2); t1 = ts.utc(2026, n.month, n.day + 2)
    def f(t):
        d = (lon(t, 'sole') - sole + 540) % 360 - 180
        return d > 0
    f.step_days = 0.5
    tt, _ = find_discrete(t0, t1, f)
    r = tt[0]
    a, m = asc_mc(r, la, lo)
    righe.append([ut, la, lo, '%.6f' % sole, r.utc_strftime('%Y-%m-%dT%H:%M:%SZ'), '%.4f' % a, '%.4f' % m] +
                 ['%.4f' % lon(r, c) for c in ('luna', 'venere', 'giove', 'saturno')])
    print(righe[-1])
with open(sys.argv[1], 'w', newline='', encoding='utf-8') as fh:
    w = csv.writer(fh)
    w.writerow(['nascita_ut', 'lat', 'lon_est', 'sole_natale', 'ritorno_2026_ut', 'ascendente', 'medio_cielo', 'luna', 'venere', 'giove', 'saturno'])
    w.writerows(righe)

"""Ordine FU voce FU.13: il contrasto del testo sopra il globo, misurato sulla
cattura vera (docs/preview/FU/fu13_3_testo_sul_globo_dopo.png, 1080x2391,
360x797 punti a densita' 3).

Il globo a schermo: la scena copre lo schermo con BoxFit.cover, scala
max(360/1080, 797/1920) = 0,4151, spostata a sinistra di 44,15 punti; il
centro del globo (540,1, 655,4) del fotogramma cade a (180,0, 272,1) punti,
cioe' (540, 816) pixel della cattura, raggio 171,3 * 0,4151 * 3 = 213 pixel.

Il fondo dietro il testo: un'apertura morfologica di 9 pixel toglie dal
disco i tratti sottili e chiari delle lettere e lascia il fondo; per ogni
riga di testo (i pixel delle lettere sono quelli piu' chiari del fondo
aperto di almeno 60 livelli) si prende il fondo piu' chiaro della riga e il
colore mediano delle lettere, e se ne fa il contrasto WCAG.
Uso: python -I docs/collaudo/FU/fu13_contrasto_sulla_cattura.py <cattura>
"""
import sys

import cv2
import numpy as np

img = cv2.imread(sys.argv[1])
assert img.shape[:2] == (2391, 1080), img.shape
rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB).astype(np.float64)


def lum(c):
    c = np.asarray(c, np.float64) / 255
    c = np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
    return 0.2126 * c[..., 0] + 0.7152 * c[..., 1] + 0.0722 * c[..., 2]


L = lum(rgb)
g = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
fondo = cv2.morphologyEx(g, cv2.MORPH_OPEN, np.ones((9, 9), np.uint8))
yy, xx = np.mgrid[0:2391, 0:1080]
disco = np.hypot(xx - 540, yy - 816) <= 213
lettere = disco & (g.astype(int) - fondo.astype(int) >= 60)
Lfondo = lum(cv2.cvtColor(cv2.cvtColor(fondo, cv2.COLOR_GRAY2BGR),
                          cv2.COLOR_BGR2RGB).astype(np.float64))
# Le righe di testo: bande di righe consecutive con almeno 20 pixel di
# lettere.
conta = lettere.sum(axis=1)
righe, dentro, inizio = [], False, 0
for y in range(2391):
    if conta[y] >= 20 and not dentro:
        dentro, inizio = True, y
    elif conta[y] < 20 and dentro:
        dentro = False
        if y - inizio >= 12:
            righe.append((inizio, y))
peggiore = None
for a, b in righe:
    m = lettere[a:b]
    f = disco[a:b] & ~m
    lf = float(Lfondo[a:b][f].max())
    lt = float(np.median(L[a:b][m]))
    c = (max(lf, lt) + 0.05) / (min(lf, lt) + 0.05)
    peggiore = c if peggiore is None else min(peggiore, c)
    print(f'riga di testo y {a}..{b} px ({a / 3:.0f}..{b / 3:.0f} punti): '
          f'fondo piu\' chiaro {lf:.4f}, lettere (mediana) {lt:.4f}, '
          f'contrasto {c:.2f}')
print(f'righe sopra il globo {len(righe)}, contrasto peggiore {peggiore:.2f}')

"""Ordine FU voce FU.13: le misure della scena dell'Oroscopo.

Uso: python -I docs/collaudo/FU/fu13_misure.py <radice del repo> <cartella di lavoro>

1. LO SCARTO fra l'ultimo fotogramma del video ricompresso
   (brand_assets/oroscopo_scena/medora_ruota_dello_zodiaco_v1.mp4) e la scena
   ferma (assets/img/oroscopo_scena/oroscopo_ultimo_fotogramma_v1.webp), come
   nell'ordine FS voce A2: scarto medio per canale su 255, sull'immagine
   intera, prima e dopo la trasformazione affine trovata con l'ECC di OpenCV.
2. LE COORDINATE DEL GLOBO E DELLE 12 SEDI sull'ultimo fotogramma fermo, in
   pixel dell'immagine 1080x1920: ogni sede e' il disco chiaro e poco saturo
   della ruota, trovato come componente connessa (luminosita' > 165,
   saturazione < 60) attorno a un candidato grossolano della trasformata di
   Hough; il centro e il raggio sono quelli del cerchio minimo che racchiude
   il disco. Il centro della ruota e' il cerchio ai minimi quadrati per i 12
   centri; il globo e' la componente chiara (luminosita' > 200) che contiene
   quel centro.
"""
import math
import os
import subprocess
import sys

import cv2
import numpy as np

ROOT = sys.argv[1]
LAVORO = sys.argv[2]
os.makedirs(LAVORO, exist_ok=True)

FERMO = os.path.join(ROOT, 'assets/img/oroscopo_scena/'
                     'oroscopo_ultimo_fotogramma_v1.webp')
VIDEO = os.path.join(ROOT, 'brand_assets/oroscopo_scena/'
                     'medora_ruota_dello_zodiaco_v1.mp4')

fermo = cv2.imread(FERMO)
assert fermo.shape[:2] == (1920, 1080), fermo.shape

# --- 1. lo scarto -----------------------------------------------------------
ultimo = os.path.join(LAVORO, 'fu13_ultimo_fotogramma_del_video.png')
subprocess.run(['ffmpeg', '-v', 'error', '-y', '-sseof', '-0.2', '-i', VIDEO,
                '-update', '1', '-frames:v', '1', ultimo], check=True)
vid = cv2.imread(ultimo)
assert vid.shape[:2] == (1920, 1080), vid.shape
durata = subprocess.run(
    ['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of',
     'default=nw=1:nk=1', VIDEO], capture_output=True, text=True,
    check=True).stdout.strip()


def scarto(a, b):
    return float(np.abs(a.astype(np.float32) - b.astype(np.float32)).mean())


prima = scarto(fermo, vid)
g_f = cv2.cvtColor(fermo, cv2.COLOR_BGR2GRAY).astype(np.float32) / 255
g_v = cv2.cvtColor(vid, cv2.COLOR_BGR2GRAY).astype(np.float32) / 255
warp = np.eye(2, 3, dtype=np.float32)
crit = (cv2.TERM_CRITERIA_EPS | cv2.TERM_CRITERIA_COUNT, 300, 1e-6)
cc, warp = cv2.findTransformECC(g_f, g_v, warp, cv2.MOTION_AFFINE, crit,
                                None, 5)
allineato = cv2.warpAffine(fermo, warp, (1080, 1920), flags=cv2.INTER_LINEAR,
                           borderMode=cv2.BORDER_REFLECT)
dopo = scarto(allineato, vid)
print(f'video: durata {durata} s, ultimo fotogramma {vid.shape[1]}x'
      f'{vid.shape[0]}')
print(f'SCARTO medio per canale (0-255), immagine intera: {prima:.2f}; '
      f'dopo la trasformazione affine ECC {dopo:.2f} (correlazione {cc:.4f})')
print(f'  trasformazione: [{warp[0,0]:.4f} {warp[0,1]:.4f} {warp[0,2]:+.2f}] '
      f'[{warp[1,0]:.4f} {warp[1,1]:.4f} {warp[1,2]:+.2f}]')

# --- 2. il globo e le 12 sedi ----------------------------------------------
g = cv2.cvtColor(fermo, cv2.COLOR_BGR2GRAY)
hsv = cv2.cvtColor(fermo, cv2.COLOR_BGR2HSV)
b = cv2.GaussianBlur(g, (5, 5), 1.5)
hough = cv2.HoughCircles(b, cv2.HOUGH_GRADIENT, dp=1, minDist=80, param1=120,
                         param2=40, minRadius=30, maxRadius=80)[0]
# La ruota sta nella meta' alta: i candidati sotto la riga 1150 sono altro
# (la luce sulla fronte di Medora).
cand = [(int(x), int(y)) for x, y, _ in hough if y < 1150]
assert len(cand) == 12, f'candidati {len(cand)}: {cand}'
# Il piu' alto e' la sede del Sole, d'oro: si misura a parte, sotto. Le
# altre undici sono i dischi chiari.
cand.sort(key=lambda p: p[1])
cand = cand[1:]
sedi = []
for cx, cy in cand:
    x0, y0 = cx - 90, cy - 90
    win = g[y0:y0 + 180, x0:x0 + 180]
    sat = hsv[y0:y0 + 180, x0:x0 + 180, 1]
    m = ((win > 165) & (sat < 60)).astype(np.uint8)
    n, lab, st, cen = cv2.connectedComponentsWithStats(m)
    best = max(range(1, n), key=lambda i: st[i, cv2.CC_STAT_AREA]
               - 5 * math.hypot(cen[i][0] - 90, cen[i][1] - 90))
    blob = (lab == best).astype(np.uint8) * 255
    cs, _ = cv2.findContours(blob, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
    (ex, ey), er = cv2.minEnclosingCircle(max(cs, key=cv2.contourArea))
    sedi.append((x0 + ex, y0 + ey, er))
xs = np.array([s[0] for s in sedi])
ys = np.array([s[1] for s in sedi])
A = np.c_[2 * xs, 2 * ys, np.ones(len(xs))]
cx, cy, c = np.linalg.lstsq(A, xs ** 2 + ys ** 2, rcond=None)[0]
R = math.sqrt(c + cx * cx + cy * cy)
print(f'CENTRO DELLA RUOTA (minimi quadrati sugli 11 dischi chiari): ({cx:.1f}, '
      f'{cy:.1f}), raggio delle sedi {R:.1f}')
sedi.sort(key=lambda s: math.degrees(math.atan2(s[0] - cx, -(s[1] - cy)))
          % 360)
for i, (x, y, r) in enumerate(sedi):
    ang = math.degrees(math.atan2(x - cx, -(y - cy))) % 360
    print(f'  sede {i:2d}: centro ({x:6.1f}, {y:6.1f}) raggio {r:4.1f} '
          f'angolo dall\'alto in senso orario {ang:5.1f} gradi, distanza '
          f'{math.hypot(x - cx, y - cy):5.1f}')

# Il bordo del globo: i raggi di luce lo legano a tutta la ruota, quindi
# niente componente connessa. Lungo 144 direzioni dal centro della ruota si
# prende il raggio dove la luminosita' cade piu' ripida (fra 140 e 230
# pixel), poi un cerchio ai minimi quadrati, ripetuto togliendo i punti oltre
# due deviazioni standard (i raggi di luce e il filo che sale al Sole).
gf = g.astype(np.float32)
bordo = []
for t in np.linspace(0, 2 * math.pi, 144, endpoint=False):
    prof = np.array([gf[int(cy + r * math.sin(t)), int(cx + r * math.cos(t))]
                     for r in range(140, 231)], np.float32)
    d = np.diff(cv2.GaussianBlur(prof.reshape(-1, 1), (1, 7), 2).ravel())
    k = int(np.argmin(d))
    bordo.append((cx + (140 + k) * math.cos(t), cy + (140 + k) * math.sin(t)))
bx_ = np.array([p[0] for p in bordo])
by_ = np.array([p[1] for p in bordo])
tieni = np.ones(len(bx_), bool)
for _ in range(4):
    A = np.c_[2 * bx_[tieni], 2 * by_[tieni], np.ones(tieni.sum())]
    gx, gy, c = np.linalg.lstsq(A, bx_[tieni] ** 2 + by_[tieni] ** 2,
                                rcond=None)[0]
    gr = math.sqrt(c + gx * gx + gy * gy)
    res = np.hypot(bx_ - gx, by_ - gy) - gr
    tieni = np.abs(res) < 2 * res[tieni].std() + 0.5
print(f'GLOBO: centro ({gx:.1f}, {gy:.1f}), raggio {gr:.1f} '
      f'({tieni.sum()} punti di bordo su {len(bx_)}, residuo '
      f'{res[tieni].std():.1f} px)')

# La sede del Sole, in alto, e' d'oro e non chiara: il filtro delle altre
# non la vede. Hough in una finestra attorno al punto alto della ruota.
sx0, sy0 = int(cx) - 90, int(cy - R) - 90
fin = cv2.GaussianBlur(g[sy0:sy0 + 180, sx0:sx0 + 180], (5, 5), 1.5)
sole = cv2.HoughCircles(fin, cv2.HOUGH_GRADIENT, dp=1, minDist=20,
                        param1=100, param2=25, minRadius=30,
                        maxRadius=70)[0][0]
sole = (sx0 + float(sole[0]), sy0 + float(sole[1]), float(sole[2]))
ang = math.degrees(math.atan2(sole[0] - cx, -(sole[1] - cy))) % 360
print(f'SEDE DEL SOLE: centro ({sole[0]:.1f}, {sole[1]:.1f}) raggio '
      f'{sole[2]:.1f}, angolo {ang:.1f}, distanza '
      f'{math.hypot(sole[0] - cx, sole[1] - cy):.1f}')
bw = bh = 2 * gr

# Cattura di controllo: i cerchi trovati disegnati sul fotogramma.
vista = fermo.copy()
for x, y, r in sedi:
    cv2.circle(vista, (int(round(x)), int(round(y))), int(round(r)),
               (0, 0, 255), 3)
cv2.circle(vista, (int(round(gx)), int(round(gy))),
           int(round((bw + bh) / 4)), (0, 255, 0), 3)
cv2.circle(vista, (int(round(sole[0])), int(round(sole[1]))),
           int(round(sole[2])), (0, 255, 255), 3)
cv2.circle(vista, (int(round(cx)), int(round(cy))), int(round(R)),
           (255, 0, 0), 2)
cv2.imwrite(os.path.join(LAVORO, 'fu13_sedi_misurate.jpg'),
            cv2.resize(vista, (540, 960)), [cv2.IMWRITE_JPEG_QUALITY, 88])


# --- 3. il contrasto del testo sulla scena scura ---------------------------
# Il caso peggiore: il pixel piu' chiaro del globo dopo il velo della
# lettura (LaScenaDellOroscopo.veloDietroLaLettura, colore medoraDeepest
# 0xFF060B1A), composto come lo compone Flutter, una miscela in sRGB:
# fondo = (1 - a) * fotogramma + a * velo. Contrasto WCAG coi colori del
# testo della lettura (ColorTokens).
def lum(rgb):
    c = np.asarray(rgb, np.float64) / 255
    c = np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
    return 0.2126 * c[..., 0] + 0.7152 * c[..., 1] + 0.0722 * c[..., 2]


def contrasto(l1, l2):
    hi, lo = max(l1, l2), min(l1, l2)
    return (hi + 0.05) / (lo + 0.05)


VELO = (0x06, 0x0B, 0x1A)
TESTI = {'textPrimary F4F1E8': (0xF4, 0xF1, 0xE8),
         'goldLight F0D77B': (0xF0, 0xD7, 0x7B),
         'textSecondary D7D2C2': (0xD7, 0xD2, 0xC2),
         'textMuted D8D0BD': (0xD8, 0xD0, 0xBD)}
rgb = cv2.cvtColor(fermo, cv2.COLOR_BGR2RGB).astype(np.float64)
yy, xx = np.mgrid[0:1920, 0:1080]
disco = np.hypot(xx - gx, yy - gy) <= gr
for a in (0.70, 0.75, 0.80, 0.85):
    fondo = (1 - a) * rgb[disco] + a * np.array(VELO, np.float64)
    lv = lum(fondo)
    peggiore = float(lv.max())
    righe = ', '.join(f'{n} {contrasto(float(lum(c)), peggiore):.2f}'
                      for n, c in TESTI.items())
    print(f'VELO {a:.2f}: luminanza del globo velato massima {peggiore:.4f} '
          f'media {float(lv.mean()):.4f}; contrasto sul pixel piu\' chiaro: '
          f'{righe}')

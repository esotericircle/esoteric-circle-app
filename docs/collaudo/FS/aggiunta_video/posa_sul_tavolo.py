"""La posa ferma (sfondo + medora_invito_v1 nel rettangolo di Medora del
tavolo) contro l'ultimo fotogramma del video, nelle coordinate del video.

Il rettangolo e' quello di GeometriaDelTavolo.medora(w): larga 0,8 della
scena, alta in proporzione all'immagine, con la vita sul bordo lontano (887).
Qui w = 720 pixel video = 688 pixel di sfondo.
"""
import sys
import cv2
import numpy as np
from PIL import Image

ROOT, ULTIMO, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
POSA = sys.argv[4] if len(sys.argv) > 4 else 'medora_invito_v1'

sf = np.array(Image.open(ROOT + '/assets/img/tavolo/tavolo_medora_v2.webp')
              .convert('RGB')).astype(np.float32)
rit = cv2.resize(sf[147:1370], (720, 1280), interpolation=cv2.INTER_AREA)
posa = np.array(Image.open(ROOT + f'/assets/img/tavolo/{POSA}.webp')
                .convert('RGBA')).astype(np.float32)
s = 720 / 688
larga = 720 * 0.8
alta = larga * posa.shape[0] / posa.shape[1]
vita = (887 - 147) * 1280 / 1223
x0, y0 = (720 - larga) / 2, vita - alta
print(f'rettangolo della posa nel video: x {x0:.1f}..{x0 + larga:.1f}, '
      f'y {y0:.1f}..{vita:.1f}')
M = np.float32([[larga / posa.shape[1], 0, x0], [0, alta / posa.shape[0], y0]])
p = cv2.warpAffine(posa, M, (720, 1280), flags=cv2.INTER_AREA,
                   borderValue=(0, 0, 0, 0))
a = p[..., 3:4] / 255
comp = p[..., :3] * a + rit * (1 - a)
vid = np.array(Image.open(ULTIMO).convert('RGB')).astype(np.float32)

# Allineamento della figura: ECC traslazione+scala sulla sola figura.
maschera = (p[..., 3] > 200).astype(np.uint8) * 255
g1 = cv2.cvtColor(comp.astype(np.uint8), cv2.COLOR_RGB2GRAY).astype(np.float32) / 255
g2 = cv2.cvtColor(vid.astype(np.uint8), cv2.COLOR_RGB2GRAY).astype(np.float32) / 255
warp = np.eye(2, 3, dtype=np.float32)
crit = (cv2.TERM_CRITERIA_EPS | cv2.TERM_CRITERIA_COUNT, 500, 1e-6)
try:
    cc, warp = cv2.findTransformECC(g1, g2, warp, cv2.MOTION_AFFINE, crit,
                                    maschera, 5)
    print(f'figura: correlazione {cc:.4f}; trasformazione posa ferma -> video:'
          f' scala x {warp[0,0]:.4f}, scala y {warp[1,1]:.4f}, spostamento '
          f'({warp[0,2]:+.1f}, {warp[1,2]:+.1f}) px video')
    # spostamento del centro della figura
    cx, cy = x0 + larga / 2, y0 + alta / 2
    nx = warp[0, 0] * cx + warp[0, 1] * cy + warp[0, 2]
    ny = warp[1, 0] * cx + warp[1, 1] * cy + warp[1, 2]
    print(f'  centro della figura: ({cx:.1f},{cy:.1f}) -> ({nx:.1f},{ny:.1f}),'
          f' scarto ({nx - cx:+.1f},{ny - cy:+.1f}) px video, '
          f'({(nx - cx) / s:+.1f},{(ny - cy) / s:+.1f}) px di sfondo')
except cv2.error as e:
    print('ECC non converge:', e)
d = np.abs(comp - vid)
print(f'scarto medio nella figura: {d[maschera > 0].mean():.2f}; '
      f'sul tavolo (sotto la vita): {d[int(vita) + 6:].mean():.2f}')
fianco = np.concatenate([comp, vid, (comp + vid) / 2,
                         np.clip(d * 3, 0, 255)], axis=1).astype(np.uint8)
Image.fromarray(fianco).save(OUT, quality=88)

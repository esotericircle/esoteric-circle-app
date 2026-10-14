"""Ordine FS aggiunta, P2: l'ultimo fotogramma del video combacia col tavolo fermo?

Il tavolo fermo e' lo sfondo tavolo_medora_v2.webp (688x1536), tagliato dal
pixel 147 al 1370 e portato a 720x1280: e' il riquadro che il video ricopre.
Si confronta l'ultimo fotogramma con quel ritaglio nella sola zona del tavolo
e degli oggetti (sotto la vita di Medora), dove i due devono coincidere, e si
cerca la trasformazione affine che li porta uno sull'altro (ECC di OpenCV).
"""
import sys
import cv2
import numpy as np

ROOT = sys.argv[1]
ULTIMO = sys.argv[2]
OUT = sys.argv[3]

sf = cv2.imread(ROOT + '/assets/img/tavolo/tavolo_medora_v2.webp')
assert sf.shape[:2] == (1536, 688), sf.shape
rit = sf[147:1370, :, :]
rit = cv2.resize(rit, (720, 1280), interpolation=cv2.INTER_AREA)
vid = cv2.imread(ULTIMO)
assert vid.shape[:2] == (1280, 720), vid.shape

# Zona confrontata: dal bordo lontano del velluto (pixel 887 dello sfondo,
# video (887-147)*1280/1223 = 774.5) fino in fondo al taglio, tutta la
# larghezza. Medora sta sopra: li' il video e la posa ferma differiscono di
# proposito.
y0 = int(round((887 - 147) * 1280 / 1223)) + 6
zona = np.zeros((1280, 720), np.uint8)
zona[y0:1280, :] = 255

g_rit = cv2.cvtColor(rit, cv2.COLOR_BGR2GRAY).astype(np.float32) / 255
g_vid = cv2.cvtColor(vid, cv2.COLOR_BGR2GRAY).astype(np.float32) / 255


def scarto(a, b):
    d = np.abs(a.astype(np.float32) - b.astype(np.float32))[y0:, :, :]
    return float(d.mean())


prima = scarto(rit, vid)
warp = np.eye(2, 3, dtype=np.float32)
crit = (cv2.TERM_CRITERIA_EPS | cv2.TERM_CRITERIA_COUNT, 500, 1e-6)
cc, warp = cv2.findTransformECC(g_rit, g_vid, warp, cv2.MOTION_AFFINE, crit,
                                zona, 5)
allineato = cv2.warpAffine(rit, warp, (720, 1280),
                           flags=cv2.INTER_LINEAR)
dopo = scarto(allineato, vid)

# Spostamento di alcuni punti del velluto (angoli del campo, in pixel video)
punti = [(150, 930), (512, 930), (606, 1162), (60, 1162), (344, 1046)]
righe = []
for x, y in punti:
    xv = x * 720 / 688
    yv = (y - 147) * 1280 / 1223
    nx = warp[0, 0] * xv + warp[0, 1] * yv + warp[0, 2]
    ny = warp[1, 0] * xv + warp[1, 1] * yv + warp[1, 2]
    righe.append(f'  sfondo ({x},{y}) -> video atteso ({xv:.1f},{yv:.1f}), '
                 f'trovato ({nx:.1f},{ny:.1f}), scarto ({nx - xv:+.1f},'
                 f'{ny - yv:+.1f}) px video')

print(f'zona confrontata: righe video {y0}..1279 (sotto la vita di Medora)')
print(f'correlazione ECC: {cc:.4f}')
print('trasformazione affine trovata (sfondo ritagliato -> fotogramma):')
print(f'  [{warp[0,0]:.4f} {warp[0,1]:.4f} {warp[0,2]:+.2f}]')
print(f'  [{warp[1,0]:.4f} {warp[1,1]:.4f} {warp[1,2]:+.2f}]')
print('\n'.join(righe))
print(f'scarto medio per canale (0-255) nella zona: prima {prima:.2f}, '
      f'con la trasformazione {dopo:.2f}')

# Catture: sovrapposizione a meta' e differenza
miscela = cv2.addWeighted(rit, 0.5, vid, 0.5, 0)
diff = cv2.absdiff(rit, vid)
diff = cv2.convertScaleAbs(diff, alpha=3)
fianco = np.concatenate([rit, vid, miscela, diff], axis=1)
cv2.line(fianco, (0, y0), (fianco.shape[1], y0), (0, 255, 255), 1)
cv2.imwrite(OUT + '/a2_fotogramma_sul_tavolo.jpg', fianco,
            [cv2.IMWRITE_JPEG_QUALITY, 88])

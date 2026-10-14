"""FS.A1, la cattura delle due pose scontornate.

Per ogni posa: a sinistra lo scontorno ingenuo (alfa dal solo bianco, colore
intatto), a destra il file vero di assets/img/tavolo/, tutti e due su un fondo
scuro, ingranditi tre volte su testa e mano, dove gli aloni si vedono.
Si lancia dalla radice del repo:
python docs/collaudo/FS/aggiunta_video/a1_cattura_delle_pose.py
"""
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, 'tool')
import scontorna_le_pose_di_medora as s  # noqa: E402

SCURO = np.array([16, 18, 40], np.float32)
ZONE = {
    'medora_mazzo_v1': [(440, 0, 260, 300), (440, 470, 300, 280)],
    'medora_invito_v1': [(440, 0, 260, 300), (820, 400, 260, 200)],
}


def sul_fondo(rgba):
    a = rgba[..., 3:4].astype(np.float32) / 255
    return (rgba[..., :3] * a + SCURO * (1 - a)).astype(np.uint8)


righe = []
for p in s.POSE:
    nome = p.split('/')[-1].split('.')[0]
    vecchio = sul_fondo(s.ingenuo(s.sorgente(p)))
    nuovo = sul_fondo(np.array(Image.open(p).convert('RGBA')))
    for x, y, w, h in ZONE[nome]:
        coppia = np.concatenate([vecchio[y:y + h, x:x + w],
                                 np.full((h, 6, 3), 255, np.uint8),
                                 nuovo[y:y + h, x:x + w]], axis=1)
        righe.append(np.array(Image.fromarray(coppia).resize(
            (coppia.shape[1] * 2, coppia.shape[0] * 2), Image.NEAREST)))
larga = max(r.shape[1] for r in righe)
tela = np.concatenate([np.pad(r, ((0, 8), (0, larga - r.shape[1]), (0, 0)))
                       for r in righe], axis=0)
Image.fromarray(tela).save(
    'docs/collaudo/FS/aggiunta_video/a1_pose_scontornate.jpg', quality=88)
print('scritta a1_pose_scontornate.jpg', tela.shape[1], 'x', tela.shape[0])

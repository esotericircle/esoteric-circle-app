# LO SCONTORNO DELLE DUE POSE DI MEDORA DELLA SINASTRIA. Ordine FT voce
# FT.01, 14 ottobre 2026. Stesso metodo di
# tool/scontorna_le_pose_di_medora.py (ordine FS voce A1): qui solo le due
# pose cambiano.
#
# Il fondatore ha consegnato le due pose della scena della Sinastria
# approfondita (il primo e l'ultimo fotogramma del video dell'astrolabio) su
# sfondo bianco, nel commit 9770fc1b:
# assets/img/sinastria/medora_astrolabio_v1.webp e
# assets/img/sinastria/medora_mani_aperte_v1.webp. La premessa P4
# dell'ordine FT: "non hanno un canale alfa vero, lo sfondo e' chiaro".
#
# IL SORGENTE SI LEGGE DAL COMMIT DEL FONDATORE, non dal file sul disco, che
# questo strumento sovrascrive: rilanciarlo rifa' lo stesso lavoro dallo
# stesso punto di partenza, e non scontorna due volte.
#
# Stessi tre passi di scontorna_le_pose_di_medora.py: lo sfondo bianco
# (connesso al bordo o sacche grandi e bianche), la fascia del bordo
# decontaminata dal bianco mescolato, la prova degli aloni sul fondo scuro.
#
# Si lancia a mano:  python tool/scontorna_le_pose_della_sinastria.py
import io
import subprocess
import sys

import cv2
import numpy as np
from PIL import Image

COMMIT = '9770fc1b'
POSE = [
    'assets/img/sinastria/medora_astrolabio_v1.webp',
    'assets/img/sinastria/medora_mani_aperte_v1.webp',
]
SOGLIA = 235
SACCA_MINIMA = 300
DENTRO = 3
FASCIA = 4


def sorgente(percorso):
    dati = subprocess.run(['git', 'show', f'{COMMIT}:{percorso}'],
                          check=True, capture_output=True).stdout
    return np.array(Image.open(io.BytesIO(dati)).convert('RGB'))


def sfondo(rgb):
    bianco = (rgb.min(axis=2) >= SOGLIA).astype(np.uint8)
    n, lab, st, _ = cv2.connectedComponentsWithStats(bianco, 4)
    h, w = bianco.shape
    fondo = np.zeros((h, w), bool)
    for i in range(1, n):
        x, y, ww, hh, area = st[i]
        al_bordo = x == 0 or y == 0 or x + ww == w or y + hh == h
        zona = lab == i
        if al_bordo or (area >= SACCA_MINIMA and
                        rgb[zona].min(axis=1).mean() >= 248):
            fondo |= zona
    return fondo


def scontorna(rgb):
    fondo = sfondo(rgb)
    figura = (~fondo).astype(np.uint8)
    piena = cv2.erode(figura, np.ones((3, 3), np.uint8),
                      iterations=DENTRO).astype(bool)
    _, etichette = cv2.distanceTransformWithLabels(
        (~piena).astype(np.uint8), cv2.DIST_L2, 5,
        labelType=cv2.DIST_LABEL_PIXEL)
    ys, xs = np.nonzero(piena)
    ordine = np.zeros(etichette.max() + 1, np.int64)
    idx = np.flatnonzero(piena.ravel())
    ordine[1:len(idx) + 1] = idx
    vicino = ordine[etichette.ravel()].reshape(etichette.shape)
    F = rgb.reshape(-1, 3)[vicino.ravel()].reshape(rgb.shape).astype(np.float32)
    c = rgb.astype(np.float32)
    lontano = 255.0 - F
    k = lontano.argmax(axis=2)
    num = np.take_along_axis(255.0 - c, k[..., None], 2)[..., 0]
    den = np.maximum(np.take_along_axis(lontano, k[..., None], 2)[..., 0], 1)
    a = np.clip(num / den, 0, 1)
    vicino_alla_figura = cv2.dilate(figura, np.ones((3, 3), np.uint8),
                                    iterations=1).astype(bool)
    fascia = (vicino_alla_figura & ~piena)
    alfa = np.where(piena, 1.0, np.where(fascia, a, 0.0))
    alfa = np.where(figura.astype(bool) & (cv2.distanceTransform(
        figura, cv2.DIST_L2, 5) > FASCIA), 1.0, alfa)
    a3 = alfa[..., None]
    smescolato = np.clip((c - (1 - a3) * 255.0) / np.maximum(a3, 1e-3), 0, 255)
    colore = np.where((fascia & (alfa >= 0.35))[..., None], smescolato,
                      np.where(fascia[..., None], F, c))
    colore = np.where((alfa == 0)[..., None], F, colore)
    rgba = np.dstack([colore, alfa * 255.0]).round().clip(0, 255)
    return rgba.astype(np.uint8), fondo


def ingenuo(rgb):
    """Lo scontorno che fa l'alone: alfa dal solo bianco, colore intatto."""
    fondo = sfondo(rgb)
    alfa = np.where(fondo, 0, 255).astype(np.uint8)
    return np.dstack([rgb, alfa])


def aloni(rgba, scuro=(16, 18, 40)):
    a = rgba[..., 3:4].astype(np.float32) / 255
    fondo = np.array(scuro, np.float32)
    comp = rgba[..., :3].astype(np.float32) * a + fondo * (1 - a)
    luce = comp @ np.array([0.299, 0.587, 0.114], np.float32)
    figura = (rgba[..., 3] > 0).astype(np.uint8)
    giro = figura.astype(bool) & ~cv2.erode(
        figura, np.ones((3, 3), np.uint8), iterations=2).astype(bool)
    piena = cv2.erode(figura, np.ones((3, 3), np.uint8), iterations=4)
    massimo = cv2.dilate(luce * piena, np.ones((11, 11), np.uint8))
    chiari = giro & (massimo > 0) & (luce > massimo + 10)
    return int(chiari.sum()), int(giro.sum())


def main():
    scrivi = '--prova' not in sys.argv
    for p in POSE:
        rgb = sorgente(p)
        rgba, fondo = scontorna(rgb)
        prima = aloni(ingenuo(rgb))
        dopo = aloni(rgba)
        trasparenti = int((rgba[..., 3] == 0).sum())
        print(f'{p}: {rgb.shape[1]}x{rgb.shape[0]}, trasparenti '
              f'{trasparenti} su {rgb.shape[0] * rgb.shape[1]}; pixel di '
              f'bordo con alone chiaro: scontorno ingenuo {prima[0]} su '
              f'{prima[1]}, questo {dopo[0]} su {dopo[1]}')
        if scrivi:
            Image.fromarray(rgba, 'RGBA').save(p, 'WEBP', quality=92,
                                               alpha_quality=100, method=6)
            letta = np.array(Image.open(p).convert('RGBA'))
            print(f'  riletta dal file: alone chiaro {aloni(letta)[0]}')


if __name__ == '__main__':
    main()

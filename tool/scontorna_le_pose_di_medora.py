# LO SCONTORNO DELLE DUE POSE DI MEDORA. Ordine FS aggiunta, voce FS.A1,
# 14 ottobre 2026.
#
# Il fondatore ha consegnato le due pose del video della Stesa (il primo e
# l'ultimo fotogramma) su sfondo bianco, nel commit 48978334:
# assets/img/tavolo/medora_mazzo_v1.webp e medora_invito_v1.webp. L'ordine:
# "trasparenti intorno alla figura, senza aloni chiari sui bordi".
#
# IL SORGENTE SI LEGGE DAL COMMIT DEL FONDATORE, non dal file sul disco, che
# questo strumento sovrascrive: rilanciarlo rifa' lo stesso lavoro dallo
# stesso punto di partenza, e non scontorna due volte.
#
# COME SI FA, in tre passi.
#
# 1. LO SFONDO. E' bianco (il canale minimo sta sopra 235). E' sfondo il
#    bianco collegato al bordo, e le sacche chiuse grandi e bianche piene:
#    fra il braccio e la veste e fra l'orecchino e il collo il bianco e' lo
#    sfondo che si vede attraverso la figura, e sul tavolo si vedrebbe come
#    una toppa bianca. Le sacche piccole (sotto trecento pixel) sono i
#    riflessi della figura, gli anelli e la stella sulla veste: restano.
#
# 2. LA FASCIA DEL BORDO. Un pixel di bordo e' un misto fra il colore della
#    figura F e il bianco: c = a * F + (1 - a) * 255. F si prende dal pixel
#    pieno piu' vicino (tre pixel dentro la figura), e da li' si ricava a sul
#    canale dove F e' piu' lontano dal bianco, che e' il piu' stabile. Dal
#    colore del pixel si toglie il bianco che c'era mescolato,
#    (c - (1 - a) * 255) / a, e dove la copertura e' sotto 0,35 si prende F:
#    l'alone chiaro non c'e' piu'. E' la "decontaminazione" dei programmi di
#    fotoritocco, fatta con la formula.
#
# 3. LA PROVA. Lo strumento compone ogni posa su un fondo scuro e misura, sul
#    giro dei pixel di bordo, quanti sono piu' chiari dei pixel pieni accanto
#    di oltre venti livelli: un alone chiaro e' esattamente questo. Stampa il
#    numero per lo scontorno ingenuo (alfa dal solo bianco) e per questo.
#
# Si lancia a mano:  python tool/scontorna_le_pose_di_medora.py
import io
import subprocess
import sys

import cv2
import numpy as np
from PIL import Image

COMMIT = '48978334'
POSE = [
    'assets/img/tavolo/medora_mazzo_v1.webp',
    'assets/img/tavolo/medora_invito_v1.webp',
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
    # I pixel pieni: almeno DENTRO pixel dentro la figura.
    piena = cv2.erode(figura, np.ones((3, 3), np.uint8),
                      iterations=DENTRO).astype(bool)
    # Il pixel pieno piu' vicino a ogni pixel: la trasformata della distanza
    # con le etichette di Voronoi.
    _, etichette = cv2.distanceTransformWithLabels(
        (~piena).astype(np.uint8), cv2.DIST_L2, 5,
        labelType=cv2.DIST_LABEL_PIXEL)
    ys, xs = np.nonzero(piena)
    # Le etichette contano i pixel zero in ordine di scansione, da uno.
    ordine = np.zeros(etichette.max() + 1, np.int64)
    idx = np.flatnonzero(piena.ravel())
    ordine[1:len(idx) + 1] = idx
    vicino = ordine[etichette.ravel()].reshape(etichette.shape)
    F = rgb.reshape(-1, 3)[vicino.ravel()].reshape(rgb.shape).astype(np.float32)
    c = rgb.astype(np.float32)
    # a sul canale dove F e' piu' lontano dal bianco.
    lontano = 255.0 - F
    k = lontano.argmax(axis=2)
    num = np.take_along_axis(255.0 - c, k[..., None], 2)[..., 0]
    den = np.maximum(np.take_along_axis(lontano, k[..., None], 2)[..., 0], 1)
    a = np.clip(num / den, 0, 1)
    # La fascia del bordo: i pixel di figura non pieni, e i pixel di sfondo
    # attaccati alla figura (l'antialias puo' stare sotto la soglia del bianco).
    vicino_alla_figura = cv2.dilate(figura, np.ones((3, 3), np.uint8),
                                    iterations=1).astype(bool)
    fascia = (vicino_alla_figura & ~piena)
    alfa = np.where(piena, 1.0, np.where(fascia, a, 0.0))
    # Dentro la fascia ma lontano dal bordo dello sfondo la figura e' piena:
    # un pixel scuro della veste non diventa trasparente perche' F, preso
    # tre pixel piu' in la', e' ancora piu' scuro.
    alfa = np.where(figura.astype(bool) & (cv2.distanceTransform(
        figura, cv2.DIST_L2, 5) > FASCIA), 1.0, alfa)
    # IL COLORE DEL BORDO: si toglie il bianco dal pixel stesso,
    # (c - (1 - a) * 255) / a, che a piena copertura rende il pixel com'era.
    # Dove la copertura e' bassa la divisione amplifica il rumore della
    # compressione, e si prende F. Il primo giro dava F a tutta la fascia, e
    # un filo scuro della veste accanto a un bordo d'argento diventava
    # d'argento (misurato: luce 87 diventata 172).
    a3 = alfa[..., None]
    smescolato = np.clip((c - (1 - a3) * 255.0) / np.maximum(a3, 1e-3), 0, 255)
    colore = np.where((fascia & (alfa >= 0.35))[..., None], smescolato,
                      np.where(fascia[..., None], F, c))
    # Sotto i pixel trasparenti il colore della figura vicina, non il bianco:
    # la compressione e il filtro che ridimensiona mescolano i pixel vicini,
    # e un bianco nascosto sotto alfa zero tornerebbe sul bordo come alone.
    colore = np.where((alfa == 0)[..., None], F, colore)
    rgba = np.dstack([colore, alfa * 255.0]).round().clip(0, 255)
    return rgba.astype(np.uint8), fondo


def ingenuo(rgb):
    """Lo scontorno che fa l'alone: alfa dal solo bianco, colore intatto."""
    fondo = sfondo(rgb)
    alfa = np.where(fondo, 0, 255).astype(np.uint8)
    return np.dstack([rgb, alfa])


def aloni(rgba, scuro=(16, 18, 40)):
    """Quanti pixel del giro di bordo, composti sul fondo scuro, sono piu'
    chiari di oltre dieci livelli del pixel piu' chiaro della figura piena
    entro cinque pixel. Un alone e' luce che la figura non ha: un bordo
    d'argento della veste e' chiaro, ma non piu' chiaro dell'argento che ha
    accanto."""
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

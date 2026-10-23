# LO SCONTORNO DELLE DODICI STATUE DELLA SINASTRIA EVOLUTIVA. Ordine GD
# voce GD.18, 23 ottobre 2026. Il fondatore: "alla fine comparirà sul tavolo
# di Medora la statua grande scontornata simbolo della risultato della
# sinastria" e sulle statue, alle 16:52, "ci sono già".
#
# Le statue ci sono: sono le dodici coppie dipinte del segno della
# relazione, assets/img/sinastria/coppia_<segno>_v1.webp (896 per 1200), una
# statua d'oro e d'argento sul suo piedistallo, su un fondo nero pieno, senza
# canale alfa. La schermata le mostrava rotonde e piccole, ritagliate in un
# riquadro: sul tavolo di Medora il fondo nero sarebbe un rettangolo scuro.
#
# IL CODICE NON DISEGNA: questo strumento toglie solo il fondo nero (R8,
# "il codice mostra, ritaglia, sceglie e dissolve"). Il dipinto resta quello
# del fondatore, pixel per pixel, dentro la figura.
#
# I tre passi, come negli altri scontorni del ramo:
#   1. il fondo: i pixel scuri (canale piu' alto sotto SOGLIA) connessi al
#      bordo dell'immagine, o chiusi fra le figure in sacche grandi e nere
#      piene; l'alone d'oro intorno alla statua non e' fondo;
#   2. la fascia del bordo: l'alfa sfuma col valore del pixel contro quello
#      della figura vicina (il nero mescolato si toglie dal colore), cosi'
#      sul tavolo non resta un filo nero intorno alla statua;
#   2bis. l'alone: la penombra sotto OMBRA che tocca il fondo sfuma con la
#      sua luce, cosi' il bagliore dell'oro resta e il nero se ne va;
#   3. il ritaglio al rettangolo della figura: la schermata misura l'altezza
#      della statua e non quella del fondo vuoto.
#
# IL SORGENTE SI LEGGE DAI FILE coppia_*, che restano com'erano (il ritratto
# della coppia, la card e il Diario li usano col loro fondo); le statue
# scontornate sono file nuovi, statua_<segno>_v1.webp, nella stessa cartella
# gia' dichiarata nel pubspec (assets/img/sinastria/).
#
# Si lancia a mano:  python tool/scontorna_le_statue_della_sinastria.py
import sys

import cv2
import numpy as np
from PIL import Image

SEGNI = ['ariete', 'toro', 'gemelli', 'cancro', 'leone', 'vergine',
         'bilancia', 'scorpione', 'sagittario', 'capricorno', 'acquario',
         'pesci']
CARTELLA = 'assets/img/sinastria/'
SOGLIA = 22
SACCA_MINIMA = 150
OMBRA = 72
SCURO_MEDIO = 32
FASCIA = 3


def scontorna(rgb):
    scuro = (rgb.max(axis=2) < SOGLIA).astype(np.uint8)
    n, lab, st, _ = cv2.connectedComponentsWithStats(scuro, 4)
    h, w = scuro.shape
    fondo = np.zeros((h, w), bool)
    for i in range(1, n):
        x, y, ww, hh, area = st[i]
        zona = lab == i
        # Al bordo, oppure una sacca chiusa grande e nera piena: il fondo
        # che si vede fra le figure (i Pesci, fra i due pesci e i corpi).
        if (x == 0 or y == 0 or x + ww == w or y + hh == h or
                (area >= SACCA_MINIMA and rgb[zona].max(axis=1).mean() < 10)):
            fondo |= zona
    figura = (~fondo).astype(np.uint8)
    piena = cv2.erode(figura, np.ones((3, 3), np.uint8),
                      iterations=FASCIA).astype(bool)
    # Il colore della figura piu' vicina, per ogni pixel della fascia.
    _, etichette = cv2.distanceTransformWithLabels(
        (~piena).astype(np.uint8), cv2.DIST_L2, 5,
        labelType=cv2.DIST_LABEL_PIXEL)
    idx = np.flatnonzero(piena.ravel())
    ordine = np.zeros(etichette.max() + 1, np.int64)
    ordine[1:len(idx) + 1] = idx
    vicino = ordine[etichette.ravel()].reshape(etichette.shape)
    c = rgb.astype(np.float32)
    F = rgb.reshape(-1, 3)[vicino.ravel()].reshape(rgb.shape).astype(
        np.float32)
    # Sul nero: c = a * F, quindi a = c / F sul canale piu' acceso della
    # figura vicina.
    k = F.argmax(axis=2)
    num = np.take_along_axis(c, k[..., None], 2)[..., 0]
    den = np.maximum(np.take_along_axis(F, k[..., None], 2)[..., 0], 1)
    a = np.clip(num / den, 0, 1)
    vicino_alla_figura = cv2.dilate(figura, np.ones((3, 3), np.uint8),
                                    iterations=1).astype(bool)
    fascia = vicino_alla_figura & ~piena
    alfa = np.where(piena, 1.0, np.where(fascia, a, 0.0))
    # L'ALONE: la penombra fuori dal fondo (il bagliore dell'oro sul nero,
    # e il nero chiuso fra le figure che il filo d'oro di un dettaglio, la
    # lenza dei Pesci, separa dal resto) sfuma con la sua luce invece di
    # restare una macchia nera sul tavolo. Conta a pezzi interi: un pezzo di
    # penombra con la luce media sotto SCURO_MEDIO e' fondo illuminato, uno
    # piu' chiaro e' dipinto (le pieghe delle vesti, il blu degli smalti) e
    # resta pieno.
    penombra = ((rgb.max(axis=2) < OMBRA) & ~fondo).astype(np.uint8)
    n2, lab2 = cv2.connectedComponents(penombra, connectivity=4)
    luce = rgb.max(axis=2).astype(np.float64)
    somme = np.bincount(lab2.ravel(), weights=luce.ravel(), minlength=n2)
    quanti = np.maximum(np.bincount(lab2.ravel(), minlength=n2), 1)
    scuri = np.flatnonzero(somme / quanti < SCURO_MEDIO)
    alone = np.isin(lab2, scuri[scuri > 0]) & penombra.astype(bool)
    rampa = np.clip((rgb.max(axis=2) - SOGLIA) / float(OMBRA - SOGLIA), 0, 1)
    alfa = np.where(alone, np.minimum(alfa, rampa), alfa)
    fascia = fascia | alone
    a3 = np.maximum(alfa[..., None], 1e-3)
    colore = np.where(fascia[..., None], np.clip(c / a3, 0, 255), c)
    colore = np.where((alfa == 0)[..., None], 0, colore)
    rgba = np.dstack([colore, alfa * 255.0]).round().clip(0, 255).astype(
        np.uint8)
    ys, xs = np.nonzero(rgba[..., 3] > 12)
    return rgba[ys.min():ys.max() + 1, xs.min():xs.max() + 1]


def filo_nero(rgba, scuro=(16, 18, 40)):
    """I pixel del giro della figura piu' scuri del fondo del tavolo."""
    a = rgba[..., 3:4].astype(np.float32) / 255
    comp = rgba[..., :3].astype(np.float32) * a + np.array(
        scuro, np.float32) * (1 - a)
    luce = comp @ np.array([0.299, 0.587, 0.114], np.float32)
    figura = (rgba[..., 3] > 0).astype(np.uint8)
    giro = figura.astype(bool) & ~cv2.erode(
        figura, np.ones((3, 3), np.uint8), iterations=2).astype(bool)
    return int((giro & (luce < 12)).sum()), int(giro.sum())


def main():
    scrivi = '--prova' not in sys.argv
    for s in SEGNI:
        rgb = np.array(Image.open(f'{CARTELLA}coppia_{s}_v1.webp')
                       .convert('RGB'))
        rgba = scontorna(rgb)
        t = int((rgba[..., 3] == 0).sum())
        nero = filo_nero(rgba)
        print(f'statua_{s}: {rgba.shape[1]}x{rgba.shape[0]} (dalla coppia '
              f'{rgb.shape[1]}x{rgb.shape[0]}), trasparenti {t}, filo nero '
              f'sul giro {nero[0]} su {nero[1]}')
        if scrivi:
            Image.fromarray(rgba, 'RGBA').save(
                f'{CARTELLA}statua_{s}_v1.webp', 'WEBP', quality=90,
                alpha_quality=100, method=6)


if __name__ == '__main__':
    main()

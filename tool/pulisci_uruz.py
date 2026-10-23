# -*- coding: utf-8 -*-
"""URUZ TORNA UNA PIETRA, non un quadrato nero. Ordine 2161, voce 5.

**Il difetto.** Uruz e' stata consegnata su un fondale nero pieno, con
scintille rosse sparse: 94,2 per cento di pixel opachi contro la mediana di
71,4 delle altre ventitre. A video e' un quadrato coi bordi neri in mezzo a
pietre scontornate.

**Il metodo, a chiave di tinta e MAI per distanza RGB.** La distanza RGB da un
campione mangia tutto cio' che somiglia al campione ovunque stia, e qui
l'incisione rossa in ombra somiglia al fondo nero: sparirebbe il solco. La
chiave di tinta invece riconosce il fondo per la sua natura (quasi nero, o
scintilla rossa su nero) e lo raggiunge SOLO dal bordo, per allagamento: cio'
che sta dentro la pietra, solco compreso, non e' raggiungibile dal bordo e
resta intatto.

I passi, ciascuno col suo perche':
1. allagamento dal bordo sui pixel del fondo (tinta quasi nera V<70, oppure
   scintilla rossa R dominante): via l'alpha;
2. resta solo la componente opaca PIU' GRANDE: le scintille circondate dal
   nero non sono raggiunte a tinta ma restano isole, e un'isola non e' pietra;
3. pinhole piccoli (sotto 400 pixel) richiusi col pixel originale: sono buchi
   del keying, non vuoti veri; i vuoti veri, piu' grandi, restano trasparenti;
4. despill sul bordo: un'erosione di un pixel e una sfumatura, poi il colore
   dei pixel semitrasparenti si divide per l'alpha (il fondale era nero,
   quindi il colore osservato e' il colore vero moltiplicato per l'alpha):
   cosi' il filo nero residuo se ne va SENZA toccare i pixel pieni, cioe'
   senza mangiare la venatura;
5. verifica A OCCHIO su fondo chiaro E su scacchiera, mai solo sul nero: i
   compositi si scrivono nello scratchpad e vanno guardati.

Il retro NON si tocca qui: si rigenera con `tool/rune_vergini.py 02` DALLA
pietra pulita, perche' il retro nasce dalla runa incisa e ne eredita i
difetti. La miniatura si rigenera con le stesse misure di `converti_webp.py`
(lato lungo 500, qualita' 82).

Uso: python tool/pulisci_uruz.py
"""

import os
import sys
from collections import deque

import numpy as np
from PIL import Image, ImageFilter

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FRONTE = os.path.join(BASE, 'assets', 'img', 'rune_bone',
                      'rune_bone_02_uruz_v1.webp')
THUMB = os.path.join(BASE, 'assets', 'img_thumb', 'rune_bone',
                     'rune_bone_02_uruz_v1.webp')
# Le stesse misure della filiera vera, tool/converti_webp.py: cambiarle qui
# farebbe di Uruz una miniatura d'un altro mazzo.
QUALITY = 88
THUMB_LONG = 500
THUMB_QUALITY = 82
# Sotto questa superficie un buco e' un pinhole del keying e un'isola e' una
# scintilla: 400 pixel su un'immagine di 685 mila sono lo 0,06 per cento.
BRICIOLA = 400


def componenti(maschera):
    """Le componenti connesse di una maschera booleana, per allagamento."""
    h, w = maschera.shape
    viste = np.zeros((h, w), dtype=bool)
    trovate = []
    for y0 in range(h):
        for x0 in range(w):
            if not maschera[y0, x0] or viste[y0, x0]:
                continue
            coda = deque([(y0, x0)])
            viste[y0, x0] = True
            punti = []
            while coda:
                y, x = coda.popleft()
                punti.append((y, x))
                for ny, nx in ((y-1, x), (y+1, x), (y, x-1), (y, x+1)):
                    if 0 <= ny < h and 0 <= nx < w and \
                            maschera[ny, nx] and not viste[ny, nx]:
                        viste[ny, nx] = True
                        coda.append((ny, nx))
            trovate.append(punti)
    return trovate


def main():
    im = Image.open(FRONTE).convert('RGBA')
    arr = np.array(im)
    h, w = arr.shape[:2]
    r = arr[..., 0].astype(int)
    g = arr[..., 1].astype(int)
    b = arr[..., 2].astype(int)
    v = np.maximum(np.maximum(r, g), b)

    # LA TINTA DEL FONDO: quasi nero, oppure scintilla rossa su nero.
    fondo_di_tinta = (v < 70) | ((r >= 70) & (g < 60) & (b < 60))

    # 1. L'ALLAGAMENTO DAL BORDO: solo il fondo raggiungibile da fuori.
    raggiunto = np.zeros((h, w), dtype=bool)
    coda = deque()
    for x in range(w):
        for y in (0, h - 1):
            if fondo_di_tinta[y, x] and not raggiunto[y, x]:
                raggiunto[y, x] = True
                coda.append((y, x))
    for y in range(h):
        for x in (0, w - 1):
            if fondo_di_tinta[y, x] and not raggiunto[y, x]:
                raggiunto[y, x] = True
                coda.append((y, x))
    while coda:
        y, x = coda.popleft()
        for ny, nx in ((y-1, x), (y+1, x), (y, x-1), (y, x+1)):
            if 0 <= ny < h and 0 <= nx < w and \
                    fondo_di_tinta[ny, nx] and not raggiunto[ny, nx]:
                raggiunto[ny, nx] = True
                coda.append((ny, nx))
    alpha = arr[..., 3].copy()
    alpha[raggiunto] = 0

    # 2. RESTA LA PIETRA: la componente opaca piu' grande. Le scintille
    # rimaste isole cadono qui, qualunque colore avessero.
    opaco = alpha > 0
    parti = componenti(opaco)
    parti.sort(key=len, reverse=True)
    for parte in parti[1:]:
        for y, x in parte:
            alpha[y, x] = 0

    # 3. I PINHOLE SI RICHIUDONO, i vuoti veri no.
    trasparente = alpha == 0
    for parte in componenti(trasparente):
        tocca_bordo = any(y in (0, h-1) or x in (0, w-1) for y, x in parte)
        if not tocca_bordo and len(parte) < BRICIOLA:
            for y, x in parte:
                alpha[y, x] = 255

    # 4. IL DESPILL DEL BORDO: erosione di un pixel, sfumatura, e il colore
    # dei semitrasparenti diviso per l'alpha, perche' il fondale era nero.
    im_a = Image.fromarray(alpha, mode='L')
    im_a = im_a.filter(ImageFilter.MinFilter(3))
    im_a = im_a.filter(ImageFilter.GaussianBlur(1.0))
    alpha = np.array(im_a)
    semi = (alpha > 0) & (alpha < 250)
    fattore = np.ones((h, w))
    fattore[semi] = 255.0 / np.maximum(alpha[semi], 64)
    for c in range(3):
        canale = arr[..., c].astype(float) * fattore
        arr[..., c] = np.clip(canale, 0, 255).astype(np.uint8)
    arr[..., 3] = alpha
    arr[alpha == 0] = 0

    # IL RIQUADRO SI STRINGE ALLA PIETRA, come nelle sorelle: Uruz era stata
    # consegnata con molta aria attorno, e la quota di pixel opachi si misura
    # sul riquadro. Senza questo passo la pietra pulita restava lontana dalla
    # mediana non per il fondale, ma per l'aria. Margine del 2 per cento.
    fuori = Image.fromarray(arr, mode='RGBA')
    bbox = fuori.getbbox()
    if bbox is not None:
        margine = round(max(fuori.size) * 0.02)
        x0 = max(0, bbox[0] - margine)
        y0 = max(0, bbox[1] - margine)
        x1 = min(fuori.width, bbox[2] + margine)
        y1 = min(fuori.height, bbox[3] + margine)
        fuori = fuori.crop((x0, y0, x1, y1))
    fuori.save(FRONTE, 'WEBP', quality=QUALITY, method=6)

    # LA MINIATURA, con le misure della filiera vera.
    mini = fuori.copy()
    lung = max(mini.size)
    if lung > THUMB_LONG:
        scala = THUMB_LONG / lung
        mini = mini.resize((round(mini.width * scala),
                            round(mini.height * scala)), Image.LANCZOS)
    mini.save(THUMB, 'WEBP', quality=THUMB_QUALITY, method=6)

    # 5. I COMPOSITI DA GUARDARE: fondo chiaro e scacchiera, mai solo nero.
    scratch = sys.argv[1] if len(sys.argv) > 1 else BASE
    chiaro = Image.new('RGBA', fuori.size, (235, 231, 222, 255))
    chiaro.alpha_composite(fuori)
    chiaro.convert('RGB').save(os.path.join(scratch, 'uruz_su_chiaro.png'))
    scacchi = Image.new('RGBA', fuori.size, (255, 255, 255, 255))
    passo = 32
    for y in range(0, fuori.height, passo):
        for x in range(0, fuori.width, passo):
            if (x // passo + y // passo) % 2:
                for yy in range(y, min(y + passo, fuori.height)):
                    for xx in range(x, min(x + passo, fuori.width)):
                        scacchi.putpixel((xx, yy), (190, 190, 190, 255))
    scacchi.alpha_composite(fuori)
    scacchi.convert('RGB').save(os.path.join(scratch, 'uruz_su_scacchi.png'))

    op = (np.array(fuori)[..., 3] >= 128).mean() * 100
    print(f'fronte: {fuori.size} opachi {op:.1f}%')


if __name__ == '__main__':
    main()

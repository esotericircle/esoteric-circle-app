"""Scontorno delle dodici statue degli Archetipi (dominio Aura).

Le sorgenti stanno su un fondo magenta desaturato che NON e' il magenta puro
delle altre famiglie, quindi il punteggio `min(R-G, B-G)` di `rune.py` qui non
separa: misurato sui dodici file, il fondo dell'Eroe segna 42 e il 99esimo
percentile della figura segna 44, cioe' si sovrappongono.

Per questo il metodo e' diverso e in tre passi.
1. Chiave per DISTANZA dal colore di fondo campionato sul singolo file, perche'
   il fondo varia da immagine a immagine (da [159,53,109] a [183,68,135]).
2. Vincolo di CONNESSIONE al bordo: si toglie solo il fondo che tocca il bordo
   dell'immagine. E' questa la garanzia che i rosa e i rossi DENTRO la figura
   (le rose dell'Amante, il rosso dell'Eroe, il costume del Giullare) non
   vengano mai mangiati, per quanto vicini al magenta siano.
3. Il watermark a stella, che sta sul fondo ma non ha il colore del fondo,
   sopravvive alla chiave: si toglie come componente opaca piccola e isolata
   nell'angolo in basso a destra, senza toccare le figure che arrivano fin li'
   (Eroe e Innocente).

Poi despill sul bordo, ritaglio al contenuto con margine uniforme, misura
comune e PNG con alpha reale.
"""

from collections import deque
import os

import numpy as np
from PIL import Image

SORGENTI = 'pilot-references/Immagini Archetipo Jung'
USCITA = 'output/archetipi'
PROVINO = 'output/archetipi-provino.png'

# Lato lungo dell'asset finale. Le altre famiglie stanno fra 820 (zodiaco) e
# 1280 (tarocchi): una statua a figura intera sta bene a 1280 di altezza.
# Due misure, come le altre sei famiglie: la piena per la scheda dell'archetipo
# e la miniatura per la ruota e la card. Ritaglio al contenuto, mai tela quadrata.
LATO_PIENA = 1024
LATO_THUMB = 512

# Soglie della chiave, in distanza euclidea RGB dal fondo campionato.
#
# Il fondo non e' perfettamente piatto: ha una leggera vignettatura, quindi
# vicino alla figura si scosta dal colore campionato sul bordo. Con una sola
# soglia stretta restava un alone (il Saggio ne aveva uno spesso tutto attorno),
# con una sola soglia larga si mangiavano i rosa della figura. Quindi due.
T_LO = 26        # sotto: fondo pieno, alpha 0
T_HI = 62        # sopra: figura piena, alpha 1
T_BORDO = 96     # tolleranza larga, ma solo per il fondo che TOCCA il bordo
T_CHIUSO = 66    # tolleranza stretta per le sacche di fondo racchiuse
STD_PIATTO = 7.0  # il fondo e' piatto, il metallo della figura no
T_CRESCITA = 78  # quanto puo' allargarsi il fondo gia' riconosciuto, per contiguita'
PASSI_CRESCITA = 40

ARCHETIPI = [
    'Innocente', 'Esploratore', 'Saggio', 'Eroe', 'Ribelle', 'Mago',
    'Realista', 'Amante', 'Giullare', 'Custode', 'Sovrano', 'Creatore',
]


def colore_fondo(a):
    """Il colore del fondo, dalla mediana di una cornice di bordo."""
    bordo = np.concatenate([
        a[:24, :].reshape(-1, 3), a[-24:, :].reshape(-1, 3),
        a[:, :24].reshape(-1, 3), a[:, -24:].reshape(-1, 3),
    ])
    return np.median(bordo, axis=0)


def connesso_al_bordo(cand):
    """Il sottoinsieme di `cand` che tocca il bordo dell'immagine.

    Riempimento a scanline con una coda di spans: sul fondo, che e' una regione
    aperta e grande, converge in fretta e resta esatto al pixel.
    """
    h, w = cand.shape
    out = np.zeros((h, w), dtype=bool)
    coda = deque()
    for x in range(w):
        if cand[0, x]:
            coda.append((0, x))
        if cand[h - 1, x]:
            coda.append((h - 1, x))
    for y in range(h):
        if cand[y, 0]:
            coda.append((y, 0))
        if cand[y, w - 1]:
            coda.append((y, w - 1))
    while coda:
        y, x = coda.popleft()
        if out[y, x] or not cand[y, x]:
            continue
        # estende la riga a sinistra e a destra finche' resta candidata
        xs = x
        while xs > 0 and cand[y, xs - 1] and not out[y, xs - 1]:
            xs -= 1
        xe = x
        while xe < w - 1 and cand[y, xe + 1] and not out[y, xe + 1]:
            xe += 1
        out[y, xs:xe + 1] = True
        for yy in (y - 1, y + 1):
            if 0 <= yy < h:
                riga_c = cand[yy, xs:xe + 1]
                riga_o = out[yy, xs:xe + 1]
                nuovi = np.where(riga_c & ~riga_o)[0]
                # un seme per ogni tratto contiguo, non per ogni pixel
                if nuovi.size:
                    tagli = np.where(np.diff(nuovi) > 1)[0]
                    inizi = np.concatenate([[0], tagli + 1])
                    for i in inizi:
                        coda.append((yy, xs + int(nuovi[i])))
    return out


def togli_watermark(alpha, soglia_area=20000, angolo=0.83):
    """Toglie la stellina in basso a destra, se e' una macchia piccola e isolata.

    Si parte dai pixel opachi dentro l'angolo e si cresce la componente: se
    resta piccola e' il watermark e si cancella, se diventa grande e' la figura
    (Eroe e Innocente arrivano davvero fin li') e non si tocca nulla.
    """
    h, w = alpha.shape
    opaco = alpha > 40
    y0, x0 = int(h * angolo), int(w * angolo)
    semi = np.argwhere(opaco[y0:, x0:])
    if not semi.size:
        return alpha, 0
    visti = np.zeros((h, w), dtype=bool)
    comp = []
    coda = deque([(int(y0 + semi[0][0]), int(x0 + semi[0][1]))])
    while coda:
        y, x = coda.popleft()
        if visti[y, x] or not opaco[y, x]:
            continue
        visti[y, x] = True
        comp.append((y, x))
        if len(comp) > soglia_area:
            return alpha, -1  # e' la figura, non si tocca
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            yy, xx = y + dy, x + dx
            if 0 <= yy < h and 0 <= xx < w and not visti[yy, xx] and opaco[yy, xx]:
                coda.append((yy, xx))
    for y, x in comp:
        alpha[y, x] = 0
    return alpha, len(comp)


def deviazione_locale(canale, raggio=3):
    """Deviazione standard su una finestra quadrata, con immagini integrali."""
    h, w = canale.shape
    pad = np.pad(canale, raggio + 1, mode='edge')
    s1 = np.cumsum(np.cumsum(pad, axis=0), axis=1)
    s2 = np.cumsum(np.cumsum(pad * pad, axis=0), axis=1)
    lato = 2 * raggio + 1
    n = lato * lato

    def finestra(s):
        return (s[lato:lato + h, lato:lato + w] - s[0:h, lato:lato + w]
                - s[lato:lato + h, 0:w] + s[0:h, 0:w])

    media = finestra(s1) / n
    var = np.maximum(finestra(s2) / n - media * media, 0.0)
    return np.sqrt(var)


def scontorna(percorso):
    im = Image.open(percorso).convert('RGB')
    a = np.asarray(im).astype(np.float32)
    bg = colore_fondo(a)
    dist = np.sqrt(((a - bg) ** 2).sum(axis=2))

    # Fondo che tocca il bordo: tolleranza larga, cosi' sparisce anche l'alone
    # della vignettatura, ma senza mai entrare nella figura perche' il
    # riempimento parte dai bordi e si ferma dove la distanza cresce.
    fondo = connesso_al_bordo(dist < T_BORDO)

    # Sacche di fondo racchiuse dalla figura (fra le braccia del Ribelle, dietro
    # la veste del Mago, sotto il manto del Sovrano): non toccano il bordo,
    # quindi il riempimento non le raggiunge. Si riconoscono da due cose
    # insieme, il colore vicino al magenta E la superficie piatta, perche' il
    # fondo e' uniforme mentre il metallo della figura ha sempre grana e
    # sfumature. Serve la congiunzione: i rosa della figura passano il primo
    # controllo ma non il secondo.
    piatto = np.maximum.reduce([deviazione_locale(a[..., c]) for c in range(3)])
    fondo |= (dist < T_CHIUSO) & (piatto < STD_PIATTO)

    # Terzo passo, la crescita. Restano due cose che le prime due regole non
    # prendono: le schegge di fondo strette fra un braccio e il corpo, e l'ombra
    # di contatto a terra, che e' magenta scurito e quindi lontana dal colore
    # campionato. Si tolgono facendo CRESCERE il fondo gia' riconosciuto dentro i
    # pixel vicini che gli somigliano. La crescita e' contigua, quindi non puo'
    # saltare dentro la figura: si ferma dove il colore cambia davvero.
    vicino = dist < T_CRESCITA
    for _ in range(PASSI_CRESCITA):
        bordo_f = fondo.copy()
        bordo_f[1:, :] |= fondo[:-1, :]
        bordo_f[:-1, :] |= fondo[1:, :]
        bordo_f[:, 1:] |= fondo[:, :-1]
        bordo_f[:, :-1] |= fondo[:, 1:]
        nuovo = bordo_f & vicino
        if not (nuovo & ~fondo).any():
            break
        fondo = nuovo | fondo

    # alpha morbida solo dentro il fondo: fuori la figura resta piena
    ramp = np.clip((dist - T_LO) / (T_HI - T_LO), 0.0, 1.0)
    alpha = np.where(fondo, ramp, 1.0)
    alpha = (alpha * 255).astype(np.uint8)

    alpha, tolti = togli_watermark(alpha)

    # despill: sui pixel di bordo si toglie il contributo del fondo, cosi' non
    # resta l'alone magenta attorno alla figura
    af = alpha.astype(np.float32) / 255.0
    bordo = (af > 0.02) & (af < 0.98)
    rgb = a.copy()
    with np.errstate(invalid='ignore', divide='ignore'):
        recuperato = (a - bg * (1.0 - af)[..., None]) / np.maximum(af, 0.05)[..., None]
    rgb[bordo] = np.clip(recuperato[bordo], 0, 255)

    out = np.dstack([rgb.astype(np.uint8), alpha])
    return Image.fromarray(out, 'RGBA'), tolti


def ritaglia(im, pad=6):
    """Ritaglio al contenuto, come le altre sei famiglie: niente tela quadrata,
    l'asset e' la sola figura col suo ingombro vero, un filo di margine."""
    bbox = im.split()[3].point(lambda v: 255 if v > 12 else 0).getbbox()
    x0, y0, x1, y1 = bbox
    x0 = max(0, x0 - pad); y0 = max(0, y0 - pad)
    x1 = min(im.width, x1 + pad); y1 = min(im.height, y1 + pad)
    return im.crop((x0, y0, x1, y1))


def a_lato(im, lato):
    k = lato / max(im.width, im.height)
    return im.resize((max(1, round(im.width * k)), max(1, round(im.height * k))),
                     Image.LANCZOS)


def scacchiera(w, h, lato=24):
    t = Image.new('RGB', (w, h), (235, 235, 235))
    px = t.load()
    for y in range(h):
        for x in range(w):
            if ((x // lato) + (y // lato)) % 2:
                px[x, y] = (200, 200, 200)
    return t


def main():
    piena = 'assets/img/archetipi'
    thumb = 'assets/img_thumb/archetipi'
    for d in (piena, thumb, os.path.dirname(PROVINO) or '.'):
        os.makedirs(d, exist_ok=True)
    provini = []
    for nome in ARCHETIPI:
        im, tolti = scontorna(os.path.join(SORGENTI, f'{nome}.png'))
        im = ritaglia(im)
        stem = f'arc_{nome.lower()}_v1'
        p1 = a_lato(im, LATO_PIENA)
        p2 = a_lato(im, LATO_THUMB)
        p1.save(os.path.join(piena, f'{stem}.webp'), 'WEBP', lossless=True)
        p2.save(os.path.join(thumb, f'{stem}.webp'), 'WEBP', lossless=True)
        stato = "figura fin nell'angolo" if tolti == -1 else f'watermark {tolti} px'
        print(f'{nome:14s} -> {stem}.webp  piena {p1.size}  thumb {p2.size}  {stato}')
        provini.append(p2)

    cell = 320
    cols, rows = 4, 3
    sfondo = scacchiera(cell * cols, cell * rows)
    for i, im in enumerate(provini):
        q = a_lato(im, cell - 16)
        x = (i % cols) * cell + (cell - q.width) // 2
        y = (i // cols) * cell + (cell - q.height) // 2
        sfondo.paste(q, (x, y), q)
    sfondo.save(PROVINO)
    print('provino ->', PROVINO)


if __name__ == '__main__':
    main()

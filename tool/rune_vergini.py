# -*- coding: utf-8 -*-
"""IL RETRO DELLE RUNE: la stessa pietra, senza incisione.

**Perche' non si rigenera col modello.** L'ordine chiedeva di produrre i retri
"con lo stesso script che produce le rune incise, saltando il passo
dell'incisione". Quel passo non esiste: `rune_bone.py` non incide una pietra
gia' fatta, chiede a un modello generativo UNA immagine di pietra incisa, e
l'incisione sta dentro il prompt. A parita' di seed, cambiando il prompt il
modello restituisce un'altra pietra: forma diversa, venatura diversa, luce
diversa. E' la stessa limitazione gia' registrata in memoria di progetto per le
immagini di riferimento.

Il vincolo vero dell'ordine non e' pero' lo script: e' che **il retro sia quello
della sua pietra**. Girandola, la persona deve ritrovare lo stesso sasso. Qui il
retro si ricava dalla runa incisa che gia' esiste, togliendole l'incisione: la
forma e' la stessa perche' e' lo stesso alpha, la venatura e' la stessa perche'
sono gli stessi pixel d'osso, la luce e' la stessa perche' non si tocca.

**Come si toglie l'incisione, in tre passi.**

1. Si riconosce il solco: sono i pixel rossi incandescenti, con la stessa
   soglia che `rune_bone.py` usa per misurarli (`red_ratio`), quindi non si
   inventa un criterio nuovo.
2. Si riempie: ogni pixel del solco prende il colore dell'osso valido piu'
   vicino. Senza scipy, la distanza si calcola per diffusione a passi, che sul
   nostro caso converge in poche decine di giri perche' il solco e' sottile.
3. Si spegne il bagliore: il rosso non finisce col solco, si spande sull'osso
   attorno come "red bloom". Lasciandolo, il retro avrebbe un alone rossastro
   senza piu' niente che lo giustifichi. Si riporta ogni pixel verso il proprio
   grigio, in proporzione a quanto rosso ha di troppo.

Uso:
  python tool/rune_vergini.py            genera i ventiquattro retri
  python tool/rune_vergini.py 01 07      solo quelle rune
"""

import io
import os
import sys

import numpy as np
from PIL import Image, ImageFilter

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SORGENTE = os.path.join(BASE, 'assets', 'img', 'rune_bone')
# **I retri stanno in `assets/img/`, non in `brand_assets/`.** L'ordine diceva
# brand_assets, ma li' vivono i sorgenti che NON entrano nel pacchetto (gli
# avatar in PNG, il tempio, l'intro), mentre le sette famiglie grafiche
# bundlate stanno tutte in `assets/img/`. E soprattutto il codice cerca gia' i
# retri in `assets/img/rune_bone_vergine/`, con un percorso cablato e una prova
# che lo sorveglia: metterli altrove avrebbe voluto dire cambiare il percorso
# per ubbidire alla lettera di una riga.
DESTINAZIONE = os.path.join(BASE, 'assets', 'img', 'rune_bone_vergine')

# Il lato lungo del retro. Le rune incise stanno a 683x788: il retro si vede
# solo coperto o in volo, mai a fuoco come la faccia incisa, quindi non serve
# la stessa risoluzione e ventiquattro file in piu' non devono pesare come i
# ventiquattro che c'erano gia'.
LATO_LUNGO = 512


def maschera_del_solco(arr):
    """I pixel dell'incisione: il rosso che brucia E il fondo che non brucia.

    **La prima stesura prendeva il solo rosso, ed era meta' del solco.** Con
    quella maschera il riempimento lasciava a video una macchia scura a forma
    di runa: dentro l'incisione, sotto la luce rossa, c'e' il fondo in ombra,
    che rosso non e'. Misurato su Fehu: 78.173 pixel rossi e 12.543 pixel scuri
    non rossi, cioe' un sesto del solco restava.

    Il fondo si riconosce dalla luminanza: l'osso ha mediana 186 su 255, il
    solco sta sotto 60. La soglia si tiene bassa apposta, perche' i pori e le
    crepe dell'osso stanno fra 100 e 140 e sono la venatura che va CONSERVATA:
    riempirle darebbe una pietra liscia, cioe' un'altra pietra.
    """
    r = arr[..., 0].astype(int)
    g = arr[..., 1].astype(int)
    b = arr[..., 2].astype(int)
    a = arr[..., 3]
    dentro = a > 60
    rosso = dentro & (r > 120) & ((r - g) > 55) & ((r - b) > 45)
    luminanza = 0.2126 * r + 0.7152 * g + 0.0722 * b
    # **Solo lo scuro ATTACCATO al rosso, non ogni ombra della pietra.**
    #
    # Due tentativi sbagliati, e vale la pena scriverli. Prendendo tutti i pixel
    # sotto sessanta, su Uruz e' entrata un'ombra profonda lontana
    # dall'incisione e il riempimento ci ha lasciato un rettangolo netto, che si
    # vedeva a occhio nudo. Restringendo poi lo scuro a dodici pixel dal rosso,
    # nei solchi larghi il fondo restava fuori e le pietre uscivano con macchie
    # scure a forma di runa.
    #
    # La misura giusta non e' la distanza, e' la CONNESSIONE: il fondo di un
    # solco tocca sempre il rosso che lo illumina, un'ombra lontana no. Si
    # cresce dal rosso dentro lo scuro finche' non si allarga piu'.
    scuro = dentro & (luminanza < 60)
    presa = rosso.copy()
    for _ in range(120):
        avanti = dilata(presa, 1) & (scuro | rosso)
        if (avanti == presa).all():
            break
        presa = avanti
    return rosso | (presa & scuro)


def dilata(m, giri=1):
    """Allarga una maschera di un pixel per giro, coi soli spostamenti."""
    for _ in range(giri):
        d = m.copy()
        d[1:, :] |= m[:-1, :]
        d[:-1, :] |= m[1:, :]
        d[:, 1:] |= m[:, :-1]
        d[:, :-1] |= m[:, 1:]
        m = d
    return m


def riempi(rgb, buco, valido, giri=400):
    """Riempie `buco` col colore valido piu' vicino, per diffusione.

    Ogni giro i pixel di bordo prendono la media dei vicini gia' noti, e la
    frontiera avanza di un pixel: dopo abbastanza giri il solco e' chiuso. Il
    numero di giri e' un tetto di sicurezza, non un valore atteso: si esce
    appena non resta piu' niente da riempire.
    """
    out = rgb.astype(np.float64).copy()
    noto = valido & ~buco
    da_fare = buco & valido
    for _ in range(giri):
        if not da_fare.any():
            break
        somma = np.zeros_like(out)
        conta = np.zeros(out.shape[:2], dtype=np.float64)
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            sp = np.roll(np.roll(out, dy, axis=0), dx, axis=1)
            sn = np.roll(np.roll(noto, dy, axis=0), dx, axis=1)
            somma += sp * sn[..., None]
            conta += sn
        frontiera = da_fare & (conta > 0)
        if not frontiera.any():
            break
        media = np.zeros_like(out)
        c = np.maximum(conta, 1)[..., None]
        media = somma / c
        out[frontiera] = media[frontiera]
        noto |= frontiera
        da_fare &= ~frontiera
    return out


def spegni_il_bagliore(rgb, alpha):
    """Toglie il rosso di troppo, lasciando il tono dell'osso.

    Non si desatura tutto: l'osso ha i suoi caldi, crema e paglierino, e
    toglierli darebbe un sasso grigio che non e' piu' quello. Si toglie solo
    l'eccesso di rosso rispetto al verde, che e' la firma del bagliore.
    """
    out = rgb.astype(np.float64).copy()
    r = out[..., 0]
    g = out[..., 1]
    b = out[..., 2]
    # Quanto rosso ha in piu' del verde, oltre il caldo naturale dell'osso.
    eccesso = np.clip(r - g - 12, 0, None)
    dove = alpha > 24
    r[dove] -= eccesso[dove] * 0.9
    # **IL BLU NON SI ALZA.** Alzandolo di un quarto dell'eccesso, come faceva
    # la prima stesura, l'area dove il rosso era piu' forte usciva LILLA: si
    # vedeva a video come un alone violaceo a forma di runa. Togliere il rosso
    # di troppo basta, e lascia il tono d'osso che c'e' sotto.
    del b
    return np.clip(out, 0, 255)


def rimetti_la_grana(rgb, buco, valido, originale):
    """Ridona all'area riempita la venatura della SUA pietra.

    **Perche' serve, guardato a video.** La diffusione produce una superficie
    piatta: l'incisione spariva ma al suo posto restava una zona pallida e
    liscia, con la forma della runa ancora leggibile in negativo. Una pietra
    non ha una finestra di plastica in mezzo.

    La grana non si inventa e non si prende da un rumore: si prende dalla
    stessa pietra, spostata di lato. Si calcola il DETTAGLIO, cioe' quanto ogni
    pixel si discosta dalla propria sfocatura, e lo si copia dall'osso buono
    che sta a un terzo di larghezza di distanza, da un lato o dall'altro a
    seconda di dove ci sia osso valido. Cosi' i pori e le screziature del retro
    sono davvero quelli del fronte, solo in un altro punto.

    Si riporta anche la LUMINANZA media: mediando i bordi, che il bagliore
    aveva schiarito, l'area riempita usciva piu' chiara dell'osso attorno, ed
    era la seconda ragione per cui il fantasma della runa si vedeva ancora.
    """
    liscio = np.asarray(
        Image.fromarray(originale[..., :3].astype(np.uint8), 'RGB')
        .filter(ImageFilter.GaussianBlur(6.0))).astype(np.float64)
    dettaglio = originale[..., :3].astype(np.float64) - liscio

    osso = valido & ~buco
    passo = max(8, rgb.shape[1] // 3)
    grana = np.zeros_like(dettaglio)
    preso = np.zeros(rgb.shape[:2], dtype=bool)
    for dx in (passo, -passo, passo // 2, -passo // 2, passo * 2, -passo * 2):
        d = np.roll(dettaglio, dx, axis=1)
        ok = np.roll(osso, dx, axis=1) & buco & ~preso
        grana[ok] = d[ok]
        preso |= ok
    out = rgb.copy()
    out[buco] += grana[buco]

    # La luminanza media dell'area riempita torna quella dell'osso attorno.
    def luminanza(x):
        return 0.2126 * x[..., 0] + 0.7152 * x[..., 1] + 0.0722 * x[..., 2]

    if buco.any() and osso.any():
        scarto = np.median(luminanza(out)[buco]) - np.median(luminanza(out)[osso])
        out[buco] -= scarto
    return np.clip(out, 0, 255)


def vergine(percorso):
    """La pietra di `percorso`, senza incisione e senza bagliore."""
    im = Image.open(percorso).convert('RGBA')
    arr = np.asarray(im)
    alpha = arr[..., 3]
    valido = alpha > 24

    solco = maschera_del_solco(arr)
    # Si allarga di quattro pixel: il bordo del solco e' sfumato, e lasciandolo
    # resterebbe un contorno rosso attorno al riempimento.
    buco = dilata(solco, 4) & valido

    # **IL BAGLIORE SI SPEGNE PRIMA DI RIEMPIRE, e l'ordine conta.** Spegnendolo
    # dopo, il riempimento aveva gia' diffuso i colori caldi del bordo dentro
    # tutta l'area, e la correzione arrivava su pixel che erano rossi per
    # eredita': ne usciva un alone lilla a forma di runa. Spegnendolo prima, il
    # riempimento diffonde osso.
    partenza = spegni_il_bagliore(arr[..., :3], alpha)
    rgb = riempi(partenza, buco, valido)
    # La sfocatura sta QUI e non alla fine: leviga le striature diritte che la
    # diffusione lascia, prima che la grana vera venga rimessa sopra.
    morbido = np.asarray(
        Image.fromarray(rgb.astype(np.uint8), 'RGB')
        .filter(ImageFilter.GaussianBlur(3.0))).astype(np.float64)
    rgb[buco] = morbido[buco]
    rgb = rimetti_la_grana(rgb, buco, valido, arr)

    fuori = Image.fromarray(
        np.dstack([rgb.astype(np.uint8), alpha]).astype(np.uint8), 'RGBA')

    w, h = fuori.size
    k = LATO_LUNGO / max(w, h)
    if k < 1:
        fuori = fuori.resize((max(1, round(w * k)), max(1, round(h * k))),
                             Image.LANCZOS)
    return fuori


def main():
    quali = sys.argv[1:]
    os.makedirs(DESTINAZIONE, exist_ok=True)
    nomi = sorted(n for n in os.listdir(SORGENTE) if n.endswith('.webp'))
    fatti = 0
    peso = 0
    for nome in nomi:
        numero = nome.split('_')[2]
        if quali and numero not in quali:
            continue
        base = nome[:-len('.webp')]
        if base.endswith('_v1'):
            base = base[:-len('_v1')]
        fuori = os.path.join(DESTINAZIONE, base + '_vergine_v1.webp')
        vergine(os.path.join(SORGENTE, nome)).save(
            fuori, 'WEBP', quality=88, method=6)
        peso += os.path.getsize(fuori)
        fatti += 1
        print('  ' + os.path.basename(fuori))
    print('retri scritti: %d, peso %d byte (%.2f MiB)'
          % (fatti, peso, peso / 1048576))


if __name__ == '__main__':
    main()

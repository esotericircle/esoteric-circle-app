# -*- coding: utf-8 -*-
"""Toglie l'ombra rosa ai piedi della statua del Realista.

La statua del Realista e' la versione non ritoccata (il minatore) e porta ai
piedi un'ombra di contatto magenta residua del fondo. Qui si toglie con una
chiave di tinta, senza alterare in nessun altro modo la figura, con lo stesso
criterio gia' usato per Sovrano e Amante in archetipi_cutout: solo nell'ultima
fascia bassa dell'immagine (dal 12 per cento finale in su verso il basso), e
solo i pixel che portano la tinta fredda del fondo, cioe' col rosso E il blu
sopra il verde. Il bronzo degli stivali e l'acciaio del piccone sono caldi o
neutri (verde sopra o pari al blu), quindi non vengono mai toccati. Si azzera
l'alpha di quei pixel e si salva in WebP lossless, cosi' i pixel della figura
restano identici a quelli decodificati dall'originale.
"""
import numpy as np
from PIL import Image

SOGLIA = 0.88  # fascia bassa: contatto a terra e ombra, mai il corpo

TARGET = [
    'assets/img/archetipi/arc_realista_v1.webp',
    'assets/img_thumb/archetipi/arc_realista_v1.webp',
]


def pulisci(percorso):
    im = Image.open(percorso).convert('RGBA')
    a = np.array(im)
    h = a.shape[0]
    r = a[..., 0].astype(int)
    g = a[..., 1].astype(int)
    b = a[..., 2].astype(int)
    al = a[..., 3].astype(int)
    banda = (np.arange(h)[:, None] / h) >= SOGLIA
    chiave = banda & (al > 0) & (r > g) & (b > g)
    a[chiave, 3] = 0
    Image.fromarray(a, 'RGBA').save(percorso, format='WEBP', lossless=True)
    return int(chiave.sum())


if __name__ == '__main__':
    for t in TARGET:
        n = pulisci(t)
        print(f'{t}: tolti {n} pixel di ombra rosa')

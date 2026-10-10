# -*- coding: utf-8 -*-
"""INGWAZ NON E' OTHALA. Ordine EA voce 22, 20 settembre 2026.

**Il fatto, da un fondatore**: nell'Estrazione Rune la scheda diceva *Ingwaz*
e la pietra mostrava il segno di **Othala**. Guardate tutte e ventiquattro le
pietre incise, una per una, il difetto e' in una sola: `22_ingwaz` portava il
rombo con le gambe, che e' Othala; le altre ventitre' sono giuste.

**Perche' non si rigenera col modello.** La pietra viene da un modello
generativo, e a parita' di seme un prompt diverso restituisce un altro sasso:
forma, venatura e luce cambierebbero, e in una gettata a tre si vedrebbe. E'
la stessa ragione scritta in `rune_vergini.py`.

**Come si corregge, e la ragione sta nel segno stesso.** Othala **e' Ingwaz
piu' due gambe**: il rombo e' identico. Si tiene quindi la pietra fino al
punto in cui il rombo si chiude, e sotto si rimettono i pixel della **pietra
vergine della stessa runa**, nata da questa immagine togliendole l'incisione:
stesso sasso, stessa venatura, stessa luce. La vergine vive a misura ridotta e
si riporta alla misura piena, che e' la stessa proporzione esatta (628 su 365
e 880 su 512 danno lo stesso fattore), quindi i due sassi restano allineati.

**Il primo tentativo e' stato buttato, e vale la pena scriverlo.** Si era
provato a richiudere il solco col riempimento delle pietre vergini, che
prende il colore dell'osso valido piu' vicino: su un buco largo come due
gambe ha lasciato una chiazza piatta, chiara, visibile a occhio nudo. Il
riempimento serve a chiudere solchi sottili, non a ricostruire mezza pietra.

Si esegue dalla radice del progetto:

```
python tool/ingwaz_non_e_othala.py
```
"""
import os

import numpy as np
from PIL import Image

INCISA = 'assets/img/rune_bone/rune_bone_22_ingwaz_v1.webp'
VERGINE = 'assets/img/rune_bone_vergine/rune_bone_22_ingwaz_vergine_v1.webp'
MINIATURA = 'assets/img_thumb/rune_bone/rune_bone_22_ingwaz_v1.webp'

# **DOVE SI CHIUDE IL ROMBO**, misurato sull'immagine e non deciso a occhio:
# scendendo lungo il segno la larghezza del solco cala fino al minimo (riga
# 531, centotrentanove pixel), i due tratti si toccano fra la 535 e la 555, e
# poi si riaprono divergendo fino a trecento: quella e' la parte che
# appartiene a Othala e non a Ingwaz.
CHIUSURA = 556

# La giunzione non si taglia di netto: il bagliore del solco si spande
# sull'osso, e un taglio secco lascerebbe una riga. Si sfuma su questa
# altezza, tutta sotto la chiusura, cosi' il rombo non viene toccato.
SFUMATURA = 34


def correggi(incisa, vergine, chiusura, sfumatura):
    """La pietra incisa fino alla chiusura, la vergine sotto."""
    a = np.asarray(Image.open(incisa).convert('RGBA')).astype(float)
    grezza = Image.open(vergine).convert('RGBA')
    larga, alta = a.shape[1], a.shape[0]
    fattore = (larga / grezza.size[0], alta / grezza.size[1])
    if abs(fattore[0] - fattore[1]) > 0.01:
        raise SystemExit('la pietra vergine ha un\'altra proporzione: %s'
                         % (fattore,))
    v = np.asarray(grezza.resize((larga, alta), Image.LANCZOS)).astype(float)

    peso = np.zeros((alta, 1, 1))
    peso[chiusura + sfumatura:] = 1.0
    for i in range(sfumatura):
        peso[chiusura + i] = i / sfumatura
    fuori = a * (1 - peso) + v * peso
    # **L'ALPHA RESTA QUELLO DELLA PIETRA INCISA**: la sagoma del sasso e' la
    # sua, e la vergine ridimensionata ha un bordo di un pixel piu' morbido.
    fuori[..., 3] = a[..., 3]
    return Image.fromarray(fuori.round().clip(0, 255).astype(np.uint8))


def main():
    if not os.path.exists(INCISA):
        raise SystemExit('manca %s: si esegue dalla radice del progetto'
                         % INCISA)
    corretta = correggi(INCISA, VERGINE, CHIUSURA, SFUMATURA)
    corretta.save(INCISA, 'WEBP', quality=92, method=6)

    # **LA MINIATURA NASCE DALLA PIENA**, perche' due strade diverse darebbero
    # due segni diversi, ed e' esattamente il difetto che stiamo togliendo.
    misura = Image.open(MINIATURA).size
    corretta.resize(misura, Image.LANCZOS).save(
        MINIATURA, 'WEBP', quality=90, method=6)
    print('INGWAZ: pietra %dx%d e miniatura %dx%d, incisione tenuta fino alla '
          'riga %d' % (corretta.size[0], corretta.size[1], misura[0],
                       misura[1], CHIUSURA))


if __name__ == '__main__':
    main()

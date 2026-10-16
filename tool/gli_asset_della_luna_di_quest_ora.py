# -*- coding: utf-8 -*-
"""Gli asset della Luna di quest'ora, ordine FX aggiunta FXA.09, 16 ottobre 2026.

Porta nel ramo i quindici pezzi dipinti dell'infografica e delle icone, dalla
cartella del fondatore `Respiro della Luna Scena`, in WebP senza perdita con
l'alfa scritto (exact=True: il colore sotto l'alfa zero resta quello del file,
come per i comandi dell'aggiunta FXA), e li rilegge pixel per pixel. Copia in
`docs/collaudo/FX/catture_fondatore/` la cattura del fondatore sulla build
2312 e in `docs/collaudo/FX/` la cattura di riferimento di Dora, che resta
fuori da `assets/`. Scrive le misure in `docs/collaudo/FX/fxa09_asset.txt`.

Si lancia una volta, dalla radice del repository:

    python tool/gli_asset_della_luna_di_quest_ora.py
"""
import io
import os
import shutil

import numpy as np
from PIL import Image

SORGENTE = r'D:\Clienti Roogly\Rituali Cartomanzia\App\Respiro della Luna Scena'
DESTINAZIONE = os.path.join('assets', 'img', 'respiro_della_luna')
COLLAUDO = os.path.join('docs', 'collaudo', 'FX')

PEZZI = {
    'infografica': [
        'righello_delle_fasi_v1', 'cursore_falce_v1', 'medaglione_sorge_v1',
        'medaglione_culmina_v1', 'medaglione_tramonta_v1',
        'sigillo_superluna_v1', 'sigillo_microluna_v1',
    ],
    'icone': [
        'freccia_sinistra_v1', 'freccia_destra_v1', 'penna_modifica_v1',
        'segnaposto_luna_v1', 'icona_luna_v1', 'icona_calendario_v1',
        'icona_bussola_v1', 'icona_respiro_v1',
    ],
}


def main():
    righe = []
    for cartella, nomi in PEZZI.items():
        dst_dir = os.path.join(DESTINAZIONE, cartella)
        os.makedirs(dst_dir, exist_ok=True)
        for nome in nomi:
            src = os.path.join(SORGENTE, cartella.capitalize(), nome + '.png')
            im = Image.open(src).convert('RGBA')
            dst = os.path.join(dst_dir, nome + '.webp')
            im.save(dst, 'WEBP', lossless=True, exact=True, method=6)
            riletto = np.asarray(Image.open(dst).convert('RGBA'))
            assert (riletto == np.asarray(im)).all(), nome + ' non e identico'
            alfa = np.asarray(im)[:, :, 3]
            righe.append('%s/%s: %dx%d, alfa da %d a %d, da %d a %d byte, '
                         'riletto identico' % (
                             cartella, nome, im.width, im.height, alfa.min(),
                             alfa.max(), os.path.getsize(src),
                             os.path.getsize(dst)))

    fondatore = os.path.join(COLLAUDO, 'catture_fondatore')
    os.makedirs(fondatore, exist_ok=True)
    shutil.copyfile(os.path.join(SORGENTE, 'Catture', 'fx_fondatore_respiro_02.jpg'),
                    os.path.join(fondatore, 'fx_fondatore_respiro_02.jpg'))
    righe.append('cattura del fondatore sulla build 2312: '
                 'catture_fondatore/fx_fondatore_respiro_02.jpg')
    shutil.copyfile(os.path.join(SORGENTE, 'Lavoro', 'cattura_dora_app_luna_v1.jpg'),
                    os.path.join(COLLAUDO, 'fxa09_cattura_dora_riferimento.jpg'))
    righe.append('cattura di riferimento di Dora (struttura e dati, mai '
                 'l\'aspetto): fxa09_cattura_dora_riferimento.jpg')

    with io.open(os.path.join(COLLAUDO, 'fxa09_asset.txt'), 'w',
                 encoding='utf-8', newline='\n') as f:
        f.write('Ordine FX aggiunta FXA.09, gli asset della Luna di quest\'ora, '
                'scritti da tool/gli_asset_della_luna_di_quest_ora.py\n\n')
        for r in righe:
            f.write(r + '\n')
    print('\n'.join(righe))


if __name__ == '__main__':
    main()

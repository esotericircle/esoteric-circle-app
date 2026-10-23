# -*- coding: utf-8 -*-
"""GLI ASSET DELLA CARTA, ordine FZ voce FZ.04.

Le dodici carte da grattare (un fotogramma del video di ognuno dei dodici
animali) e le due scene vuote (terra e uccelli, per l'uscita di Tartaruga,
Gufo, Falco, Aquila, Corvo, ordine FZ voce FZ.05) sono leggere: l'ordine
FZ.06 dice che possono stare nel pacchetto, a differenza dei video. Questo
script le converte in WebP (lo stesso metodo di
tool/gli_asset_dell_ordine_fu.py, qualita' 88) e le copia in
assets/img/mondo_di_sotto/, dove gia' vivono le altre immagini del Viaggio
(le ombre, la nebbia, la soglia del bosco): non e' una delle sei famiglie
sotto il lucchetto di docs/stato_asset.json.

Uso: python tool/gli_asset_della_carta_fz04.py
"""
import os

from PIL import Image

RADICE_ASSET = r'D:\Clienti Roogly\Rituali Cartomanzia\App\Viaggio Sciamano Animali'
RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DESTINAZIONE = os.path.join(RADICE, 'assets', 'img', 'mondo_di_sotto')

ANIMALI = [
    'Aquila', 'Cavallo', 'Cervo', 'Corvo', 'Falco', 'Gufo', 'Lince', 'Lupo',
    'Orso', 'Serpente', 'Tartaruga', 'Volpe',
]


def converti(sorgente, dest):
    im = Image.open(sorgente).convert('RGB')
    im.save(dest, 'WEBP', quality=88, method=6)
    return os.path.getsize(sorgente), os.path.getsize(dest)


def main():
    carte = os.path.join(DESTINAZIONE, 'carte')
    scene_vuote = os.path.join(DESTINAZIONE, 'scene_vuote')
    os.makedirs(carte, exist_ok=True)
    os.makedirs(scene_vuote, exist_ok=True)
    righe = ["GLI ASSET DELLA CARTA, ordine FZ voce FZ.04, generato da "
             'tool/gli_asset_della_carta_fz04.py', '']

    for animale in ANIMALI:
        nome = animale.lower()
        sorgente = os.path.join(RADICE_ASSET, animale,
                                 '%s_carta_da_grattare_v1.jpg' % nome)
        dest = os.path.join(carte, '%s_carta_da_grattare_v1.webp' % nome)
        prima, dopo = converti(sorgente, dest)
        righe.append('%s: %d byte JPG -> %d byte WebP' % (animale, prima, dopo))

    for nome_file, cartella in [
        ('00_scena_ultimo.webp', ''),
        ('00_scena_uccelli_ultimo.webp', 'Uccelli'),
    ]:
        sorgente_nome = ('00_SCENA_ULTIMO.jpg' if cartella == ''
                          else '00_SCENA_UCCELLI_ULTIMO.jpg')
        sorgente = os.path.join(RADICE_ASSET, cartella, sorgente_nome)
        dest = os.path.join(scene_vuote, nome_file)
        prima, dopo = converti(sorgente, dest)
        righe.append('%s: %d byte JPG -> %d byte WebP' % (
            sorgente_nome, prima, dopo))

    rapporto_dir = os.path.join(RADICE, 'docs', 'collaudo', 'FZ')
    os.makedirs(rapporto_dir, exist_ok=True)
    with open(os.path.join(rapporto_dir, 'rapporto_fz04_carte.txt'), 'w',
              encoding='utf-8') as fh:
        fh.write('\n'.join(righe) + '\n')
    print('\n'.join(righe))


if __name__ == '__main__':
    main()

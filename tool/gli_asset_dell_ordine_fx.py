"""GLI ASSET DELL'ORDINE FX, il Respiro della Luna, 16 ottobre 2026.

Porta nel ramo gli asset della scena "Respiro della Luna" consegnati dal
fondatore in D:\\Clienti Roogly\\Rituali Cartomanzia\\App\\Respiro della Luna
Scena\\: la scena del respiro (il video e i suoi tre fotogrammi fermi) e la
scena della consegna della collana (il video e i suoi due fotogrammi fermi),
piu' gli elementi grafici della Collana e della Bussola. Dalla sottocartella
Lavoro\\ (bozze di passaggio, fuori dal ramo) entra solo un file, la cattura
del fondatore sull'app vera, che non e' un asset dell'app e va in
docs/collaudo/FX/catture_fondatore/.

- Le immagini diventano WebP alla stessa misura, qualita' 88 (quella di
  tool/gli_asset_dell_ordine_fu.py), senza ritocchi di colore. I PNG con la
  trasparenza la tengono: il canale alfa si scrive senza perdita
  (alpha_quality 100), e lo script verifica che resti identico pixel per
  pixel. assets/img/respiro_della_luna/ ospita i cinque fotogrammi di scena
  (tre del respiro, due della consegna); le sottocartelle collana/ e
  bussola/ ospitano i pezzi delle due famiglie di elementi, sullo stesso
  schema di assets/img/mondo_di_sotto/gesti/.
- I due video si ricomprimono col metodo dell'ordine FU voce FU.12 (H.264
  profilo high, qualita' costante 26, preset slow, yuv420p, faststart, alla
  misura d'origine, audio AAC 96 kbps) in brand_assets/respiro_della_luna/.
- Per ogni video: peso prima e dopo, impronta SHA-256, e lo scarto fra
  l'ultimo fotogramma del video ricompresso e il fotogramma fermo dichiarato
  per quella scena (ordine FS voce A2, lo stesso metodo di FV e FW:
  -sseof -0.5).
- Il canale alfa di scia_di_luna_v1.png si ispeziona a parte (non si
  modifica, si riferisce soltanto se varia o e' tutto opaco).

Uso: python tool/gli_asset_dell_ordine_fx.py
"""
import hashlib
import io
import os
import shutil
import subprocess
import tempfile

import numpy as np
from PIL import Image, ImageChops, ImageStat

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ORIGINE = r'D:\Clienti Roogly\Rituali Cartomanzia\App\Respiro della Luna Scena'
LAVORO = os.path.join(ORIGINE, 'Lavoro')
COLLANA_SRC = os.path.join(ORIGINE, 'Collana')
BUSSOLA_SRC = os.path.join(ORIGINE, 'Bussola')
CONSEGNA_SRC = os.path.join(ORIGINE, 'Consegna')

IMMAGINI = os.path.join(RADICE, 'assets', 'img', 'respiro_della_luna')
IMMAGINI_COLLANA = os.path.join(IMMAGINI, 'collana')
IMMAGINI_BUSSOLA = os.path.join(IMMAGINI, 'bussola')
VIDEO = os.path.join(RADICE, 'brand_assets', 'respiro_della_luna')
COLLAUDO = os.path.join(RADICE, 'docs', 'collaudo', 'FX')
CATTURE_FONDATORE = os.path.join(COLLAUDO, 'catture_fondatore')

# (video sorgente, fotogramma fermo dichiarato, nome nel ramo)
VIDEO_VOCI = [
    (os.path.join(ORIGINE, 'medora_il_respiro_della_luna_v1.mp4'),
     os.path.join(ORIGINE, 'respiro_ultimo_fotogramma_v1.jpg'),
     'medora_il_respiro_della_luna_v1.mp4'),
    (os.path.join(CONSEGNA_SRC, 'medora_la_consegna_della_collana_v1.mp4'),
     os.path.join(CONSEGNA_SRC, 'consegna_ultimo_fotogramma_v1.jpg'),
     'medora_la_consegna_della_collana_v1.mp4'),
]

# I cinque fotogrammi fermi di scena, livello unico in assets/img/respiro_della_luna/.
FOTOGRAMMI_SCENA = [
    os.path.join(ORIGINE, 'respiro_primo_fotogramma_v1.jpg'),
    os.path.join(ORIGINE, 'respiro_ultimo_fotogramma_v1.jpg'),
    os.path.join(ORIGINE, 'respiro_cielo_senza_luna_v1.jpg'),
    os.path.join(CONSEGNA_SRC, 'consegna_primo_fotogramma_v1.jpg'),
    os.path.join(CONSEGNA_SRC, 'consegna_ultimo_fotogramma_v1.jpg'),
]

# La cattura del fondatore in Lavoro\, unico file di quella cartella che
# entra nel ramo, e non come asset dell'app.
CATTURA_FONDATORE = os.path.join(LAVORO, 'cattura_dora_app_luna_v1.jpg')


def sha256(p):
    h = hashlib.sha256()
    with open(p, 'rb') as f:
        for blocco in iter(lambda: f.read(1 << 20), b''):
            h.update(blocco)
    return h.hexdigest()


def ultimo_fotogramma(video, uscita):
    # -update 1 riscrive lo stesso file a ogni fotogramma: resta l'ultimo.
    subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-sseof', '-0.5',
                    '-i', video, '-update', '1', uscita], check=True)


def scarto(a, b):
    """Lo scarto medio assoluto fra due immagini RGB, in livelli su 255."""
    if a.size != b.size:
        b = b.resize(a.size)
    return sum(ImageStat.Stat(ImageChops.difference(
        a.convert('RGB'), b.convert('RGB'))).mean) / 3


def converti_webp(sorgente, dest, righe, etichetta):
    """Converte un'immagine in WebP alla stessa misura, qualita' 88, senza
    ritocchi di colore. I PNG con canale alfa lo tengono senza perdita, e lo
    script verifica che sia rimasto identico pixel per pixel."""
    im = Image.open(sorgente)
    peso_prima = os.path.getsize(sorgente)
    if im.mode == 'RGBA':
        im.save(dest, 'WEBP', quality=88, alpha_quality=100, method=6)
        prima = np.asarray(im.getchannel('A'))
        dopo = np.asarray(Image.open(dest).getchannel('A'))
        diversi = int((prima != dopo).sum())
        assert Image.open(dest).mode == 'RGBA', dest
        assert diversi == 0, '%s: alfa cambiato in %d pixel' % (dest, diversi)
        nota = 'RGBA, alfa identico'
    else:
        im.convert('RGB').save(dest, 'WEBP', quality=88, method=6)
        nota = 'RGB'
    peso_dopo = os.path.getsize(dest)
    righe.append('%s %dx%d %s: %d byte -> %d byte WebP (%s)' % (
        os.path.basename(sorgente), im.width, im.height, nota, peso_prima,
        peso_dopo, etichetta))
    return peso_prima, peso_dopo


def ricomprimi_video(sorgente, dest):
    subprocess.run([
        'ffmpeg', '-y', '-loglevel', 'error', '-i', sorgente,
        '-c:v', 'libx264', '-profile:v', 'high', '-preset', 'slow',
        '-crf', '26', '-pix_fmt', 'yuv420p', '-movflags', '+faststart',
        '-c:a', 'aac', '-b:a', '96k', dest], check=True)


def ispeziona_alfa_scia_di_luna(righe):
    """La scia di luna (Bussola) deve avere trasparenza vera: si riferisce
    se il canale alfa varia, non si modifica niente."""
    sorgente = os.path.join(BUSSOLA_SRC, 'scia_di_luna_v1.png')
    im = Image.open(sorgente)
    righe.append('')
    righe.append('== Il canale alfa di scia_di_luna_v1.png (Bussola)')
    if im.mode != 'RGBA':
        righe.append('%s e\' in modo %s, senza canale alfa: nessuna '
                     'trasparenza da riferire.' % (
                         os.path.basename(sorgente), im.mode))
        return False
    alfa = np.asarray(im.getchannel('A'))
    minimo, massimo = int(alfa.min()), int(alfa.max())
    varia = minimo != massimo or massimo != 255
    righe.append(
        '%s %dx%d RGBA: canale alfa da %d a %d; pixel con alfa 0 %d, con '
        'alfa fra 1 e 254 %d, con alfa 255 %d; il canale VARIA' % (
            os.path.basename(sorgente), im.width, im.height, minimo, massimo,
            int((alfa == 0).sum()), int(((alfa > 0) & (alfa < 255)).sum()),
            int((alfa == 255).sum())) if varia else
        '%s %dx%d RGBA: canale alfa costante a %d, NON varia (tutto '
        'opaco o tutto trasparente)' % (
            os.path.basename(sorgente), im.width, im.height, minimo))
    return varia


def main():
    os.makedirs(IMMAGINI, exist_ok=True)
    os.makedirs(IMMAGINI_COLLANA, exist_ok=True)
    os.makedirs(IMMAGINI_BUSSOLA, exist_ok=True)
    os.makedirs(VIDEO, exist_ok=True)
    os.makedirs(COLLAUDO, exist_ok=True)
    os.makedirs(CATTURE_FONDATORE, exist_ok=True)

    righe = ['GLI ASSET DELL\'ORDINE FX, il Respiro della Luna, generato da '
             'tool/gli_asset_dell_ordine_fx.py', '']
    peso_totale_prima = 0
    peso_totale_dopo = 0

    righe.append('== I cinque fotogrammi fermi di scena '
                 '(assets/img/respiro_della_luna/)')
    for sorgente in FOTOGRAMMI_SCENA:
        nome = os.path.basename(sorgente)
        dest = os.path.join(IMMAGINI, os.path.splitext(nome)[0] + '.webp')
        p, d = converti_webp(sorgente, dest, righe, 'scena')
        peso_totale_prima += p
        peso_totale_dopo += d
    righe.append('')

    righe.append('== La Collana (assets/img/respiro_della_luna/collana/)')
    for nome in sorted(os.listdir(COLLANA_SRC)):
        if not nome.lower().endswith('.png'):
            continue
        sorgente = os.path.join(COLLANA_SRC, nome)
        dest = os.path.join(IMMAGINI_COLLANA,
                            os.path.splitext(nome)[0] + '.webp')
        p, d = converti_webp(sorgente, dest, righe, 'collana')
        peso_totale_prima += p
        peso_totale_dopo += d
    righe.append('')

    righe.append('== La Bussola (assets/img/respiro_della_luna/bussola/)')
    for nome in sorted(os.listdir(BUSSOLA_SRC)):
        if not nome.lower().endswith('.png'):
            continue
        sorgente = os.path.join(BUSSOLA_SRC, nome)
        dest = os.path.join(IMMAGINI_BUSSOLA,
                            os.path.splitext(nome)[0] + '.webp')
        p, d = converti_webp(sorgente, dest, righe, 'bussola')
        peso_totale_prima += p
        peso_totale_dopo += d
    righe.append('')

    righe.append('== I due video (brand_assets/respiro_della_luna/)')
    impronte = {}
    lavoro_tmp = tempfile.mkdtemp()
    try:
        for video_src, fermo_src, nome_dest in VIDEO_VOCI:
            dest_video = os.path.join(VIDEO, nome_dest)
            ricomprimi_video(video_src, dest_video)

            peso_prima = os.path.getsize(video_src)
            peso_dopo = os.path.getsize(dest_video)
            peso_totale_prima += peso_prima
            peso_totale_dopo += peso_dopo
            impronta = sha256(dest_video)
            impronte[nome_dest] = impronta

            ultimo_dopo = os.path.join(
                COLLAUDO, os.path.splitext(nome_dest)[0] + '_ultimo_dopo.png')
            ultimo_fotogramma(dest_video, ultimo_dopo)
            scarto_ultimo = scarto(Image.open(fermo_src),
                                   Image.open(ultimo_dopo))

            probe = subprocess.run(
                ['ffprobe', '-v', 'error', '-select_streams', 'v:0',
                 '-show_entries', 'stream=width,height,r_frame_rate,duration',
                 '-of', 'compact', dest_video],
                check=True, capture_output=True, text=True).stdout.strip()

            righe.append(
                '%s: %d byte -> %d byte (%.2f MB -> %.2f MB), SHA-256 %s\n'
                '  %s\n'
                '  ultimo fotogramma ricompresso contro %s: scarto medio '
                '%.2f su 255 (cattura: docs/collaudo/FX/%s)' % (
                    nome_dest, peso_prima, peso_dopo, peso_prima / 1e6,
                    peso_dopo / 1e6, impronta, probe,
                    os.path.basename(fermo_src), scarto_ultimo,
                    os.path.basename(ultimo_dopo)))
            righe.append('')
    finally:
        shutil.rmtree(lavoro_tmp, ignore_errors=True)

    righe.append('== IL PESO TOTALE')
    righe.append('prima: %d byte (%.2f MB); dopo: %d byte (%.2f MB)' % (
        peso_totale_prima, peso_totale_prima / 1e6,
        peso_totale_dopo, peso_totale_dopo / 1e6))

    # La scia di luna: si ispeziona il canale alfa, non si modifica niente.
    ispeziona_alfa_scia_di_luna(righe)

    # La cattura del fondatore: unico file di Lavoro\ che entra nel ramo, e
    # non come asset dell'app, ma come prova di collaudo.
    righe.append('')
    righe.append('== La cattura del fondatore (fuori dagli asset dell\'app)')
    dest_cattura = os.path.join(CATTURE_FONDATORE,
                                os.path.basename(CATTURA_FONDATORE))
    shutil.copyfile(CATTURA_FONDATORE, dest_cattura)
    righe.append('%s copiata in docs/collaudo/FX/catture_fondatore/ (%d '
                 'byte), non e\' un asset dell\'app' % (
                     os.path.basename(CATTURA_FONDATORE),
                     os.path.getsize(dest_cattura)))

    with io.open(os.path.join(COLLAUDO, 'fx01_asset.txt'), 'w',
                 encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(righe) + '\n')
    print('\n'.join(righe))


if __name__ == '__main__':
    main()

"""GLI ASSET DELL'ORDINE FU, voci FU.01, FU.12, FU.13 e FU.14, 15 ottobre 2026.

Porta nel ramo i file consegnati dal fondatore nelle tre cartelle di
D:\\Clienti Roogly\\Rituali Cartomanzia\\App: l'Oracolo degli Angeli, la scena
dell'Oroscopo e la scena della Sinastria VIP.

- Le immagini JPG diventano WebP alla stessa misura, qualita' 88 (quella di
  tool/converti_webp.py per le famiglie), senza ritocchi di colore.
- I video si ricomprimono (voce FU.12) in H.264 profilo high a qualita'
  costante 26, preset slow, yuv420p, faststart, alla misura d'origine.
  L'audio resta, AAC 96 kbps: le tre scene suonano come la Stesa (Linee Guida
  sezione 28), sotto l'interruttore del suono e mai col telefono in
  silenzioso.
- Per ogni video: peso prima e dopo, impronta SHA-256 del file nel ramo, e
  lo stesso fotogramma (a 4 secondi) estratto da prima e da dopo in
  docs/collaudo/FU/, con lo scarto medio misurato fra i due.

Uso: python tool/gli_asset_dell_ordine_fu.py
"""
import hashlib
import io
import os
import subprocess

from PIL import Image, ImageChops, ImageStat

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ORIGINE = r'D:\Clienti Roogly\Rituali Cartomanzia\App'
COLLAUDO = os.path.join(RADICE, 'docs', 'collaudo', 'FU')

CARTELLE = [
    ('Oracolo degli Angeli', 'oracolo_angeli'),
    ('Oroscopo Scena', 'oroscopo_scena'),
    ('Sinastria VIP Scena', 'vip_scena'),
]


def sha256(p):
    h = hashlib.sha256()
    with open(p, 'rb') as f:
        for blocco in iter(lambda: f.read(1 << 20), b''):
            h.update(blocco)
    return h.hexdigest()


def fotogramma(video, istante, uscita):
    subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-ss', str(istante),
                    '-i', video, '-frames:v', '1', uscita], check=True)


def main():
    os.makedirs(COLLAUDO, exist_ok=True)
    righe = ['GLI ASSET DELL\'ORDINE FU, generato da tool/gli_asset_dell_ordine_fu.py', '']
    for cartella, nome in CARTELLE:
        sorgente = os.path.join(ORIGINE, cartella)
        immagini = os.path.join(RADICE, 'assets', 'img', nome)
        video = os.path.join(RADICE, 'brand_assets', nome)
        os.makedirs(immagini, exist_ok=True)
        os.makedirs(video, exist_ok=True)
        righe.append('== ' + cartella)
        for f in sorted(os.listdir(sorgente)):
            p = os.path.join(sorgente, f)
            if f.lower().endswith('.jpg'):
                im = Image.open(p).convert('RGB')
                dest = os.path.join(immagini, f[:-4] + '.webp')
                im.save(dest, 'WEBP', quality=88, method=6)
                righe.append('%s %dx%d: %d byte JPG -> %d byte WebP' % (
                    f, im.width, im.height, os.path.getsize(p),
                    os.path.getsize(dest)))
            elif f.lower().endswith('.mp4'):
                dest = os.path.join(video, f)
                subprocess.run([
                    'ffmpeg', '-y', '-loglevel', 'error', '-i', p,
                    '-c:v', 'libx264', '-profile:v', 'high', '-preset', 'slow',
                    '-crf', '26', '-pix_fmt', 'yuv420p', '-movflags',
                    '+faststart', '-c:a', 'aac', '-b:a', '96k', dest],
                    check=True)
                prima = os.path.join(COLLAUDO, nome + '_fotogramma_4s_prima.png')
                dopo = os.path.join(COLLAUDO, nome + '_fotogramma_4s_dopo.png')
                fotogramma(p, 4, prima)
                fotogramma(dest, 4, dopo)
                a = Image.open(prima).convert('RGB')
                b = Image.open(dopo).convert('RGB')
                scarto = sum(ImageStat.Stat(ImageChops.difference(a, b)).mean) / 3
                righe.append(
                    '%s: %d byte -> %d byte (%.1f MB -> %.1f MB), SHA-256 %s; '
                    'fotogramma a 4 s prima e dopo, scarto medio %.2f su 255 '
                    '(%s, %s)' % (
                        f, os.path.getsize(p), os.path.getsize(dest),
                        os.path.getsize(p) / 1e6, os.path.getsize(dest) / 1e6,
                        sha256(dest), scarto, os.path.basename(prima),
                        os.path.basename(dopo)))
        righe.append('')
    with io.open(os.path.join(COLLAUDO, 'fu01_asset.txt'), 'w',
                 encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(righe) + '\n')
    print('\n'.join(righe))


if __name__ == '__main__':
    main()

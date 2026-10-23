"""GLI ASSET DELL'ORDINE FW, voci FW.01, FW.02 e FW.05, 15 ottobre 2026.

Porta nel ramo i sei video di scena dei tre Maestri (dominio e chat) dalle
sei cartelle di D:\\Clienti Roogly\\Rituali Cartomanzia\\App\\, con lo
scambio di Caligo che la voce FW.05 chiede: il video del vortice di fuoco
(in "Caligo Chat Scena\\") va nel DOMINIO col fotogramma
caligo_chat_ultimo_fotogramma_v1; il video del cerchio di fuoco sul tavolo
(in "Caligo Dominio Scena\\") va nella CHAT col fotogramma
caligo_dominio_ultimo_fotogramma_v1.

- Le immagini JPG diventano WebP alla stessa misura, qualita' 88, senza
  ritocchi di colore, in assets/img/maestri_scena/.
- I video si ricomprimono col metodo dell'ordine FU voce FU.12 (H.264
  profilo high, qualita' costante 26, preset slow, yuv420p, faststart,
  misura d'origine, audio AAC 96 kbps) in brand_assets/maestri_scena/.
- Per ogni video: peso prima e dopo, impronta SHA-256, lo stesso fotogramma
  a 4 secondi prima e dopo con lo scarto medio (FU.12), e lo scarto fra
  l'ultimo fotogramma del video ricompresso e il suo fotogramma fermo
  dichiarato (FS voce A2, lo stesso metodo di FV: -sseof -0.5).

Uso: python tool/gli_asset_dell_ordine_fw.py
"""
import hashlib
import io
import os
import subprocess

from PIL import Image, ImageChops, ImageStat

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ORIGINE = r'D:\Clienti Roogly\Rituali Cartomanzia\App'
COLLAUDO = os.path.join(RADICE, 'docs', 'collaudo', 'FW')
IMMAGINI = os.path.join(RADICE, 'assets', 'img', 'maestri_scena')
VIDEO = os.path.join(RADICE, 'brand_assets', 'maestri_scena')

# (cartella di origine, video, fotogramma fermo dichiarato, posto nell'app)
# Lo scambio di Caligo (FW.05) e' gia' qui: il video del vortice viene dalla
# cartella Chat ma il suo fotogramma fermo e il suo posto sono del dominio,
# e viceversa per il cerchio di fuoco.
# ORDINE GD VOCE GD.02, 23 ottobre 2026: lo scambio torna indietro, per
# parola del fondatore ("Per Caligo bisogna scambiare il video introduttivo
# della chat con quello del dominio"). Ogni video di Caligo torna al posto
# della sua cartella: il cerchio di fuoco col palmo aperto nel dominio, il
# vortice nella chat. Rieseguire lo script non disfa piu' la GD.02.
VOCI = [
    ('Medora Dominio Scena', 'medora_planetario_v1.mp4',
     'medora_planetario_ultimo_fotogramma_v1.jpg', 'medora_dominio'),
    ('Medora Chat Scena', 'medora_l_invito_v1.mp4',
     'medora_chat_ultimo_fotogramma_v1.jpg', 'medora_chat'),
    ('Caligo Chat Scena', 'caligo_il_vortice_v1.mp4',
     'caligo_chat_ultimo_fotogramma_v1.jpg', 'caligo_chat'),
    ('Caligo Dominio Scena', 'caligo_la_runa_della_sera_v1.mp4',
     'caligo_dominio_ultimo_fotogramma_v1.jpg', 'caligo_dominio'),
    ('Aura Dominio Scena', 'aura_il_centro_di_oggi_v1.mp4',
     'aura_dominio_ultimo_fotogramma_v1.jpg', 'aura_dominio'),
    ('Aura Chat Scena', 'aura_il_respiro_sul_loto_v1.mp4',
     'aura_chat_ultimo_fotogramma_v1.jpg', 'aura_chat'),
]

# I primi fotogrammi, un per cartella (quello proprio della cartella, mai
# scambiato: il primo fotogramma del video SORGENTE di quella cartella).
PRIMI = {
    'Medora Dominio Scena': 'medora_planetario_primo_fotogramma_v1.jpg',
    'Medora Chat Scena': 'medora_chat_primo_fotogramma_v1.jpg',
    'Caligo Dominio Scena': 'caligo_dominio_primo_fotogramma_v1.jpg',
    'Caligo Chat Scena': 'caligo_chat_primo_fotogramma_v1.jpg',
    'Aura Dominio Scena': 'aura_dominio_primo_fotogramma_v1.jpg',
    'Aura Chat Scena': 'aura_chat_primo_fotogramma_v1.jpg',
}


def sha256(p):
    h = hashlib.sha256()
    with open(p, 'rb') as f:
        for blocco in iter(lambda: f.read(1 << 20), b''):
            h.update(blocco)
    return h.hexdigest()


def fotogramma(video, istante, uscita):
    subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-ss', str(istante),
                    '-i', video, '-frames:v', '1', uscita], check=True)


def ultimo_fotogramma(video, uscita):
    subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-sseof', '-0.5',
                    '-i', video, '-update', '1', uscita], check=True)


def scarto(a_path, b_path):
    a = Image.open(a_path).convert('RGB')
    b = Image.open(b_path).convert('RGB')
    if a.size != b.size:
        b = b.resize(a.size)
    return sum(ImageStat.Stat(ImageChops.difference(a, b)).mean) / 3


def converti_webp(sorgente, dest):
    im = Image.open(sorgente).convert('RGB')
    im.save(dest, 'WEBP', quality=88, method=6)
    return im.width, im.height


def main():
    os.makedirs(COLLAUDO, exist_ok=True)
    os.makedirs(IMMAGINI, exist_ok=True)
    os.makedirs(VIDEO, exist_ok=True)
    righe = ['GLI ASSET DELL\'ORDINE FW, generato da '
             'tool/gli_asset_dell_ordine_fw.py', '']
    peso_totale_prima = 0
    peso_totale_dopo = 0

    righe.append('== LA TABELLA (FW.01): cartella di origine, video, posto')
    for cartella, video, fermo, posto in VOCI:
        righe.append('%s/%s -> %s (fermo: %s)' % (cartella, video, posto, fermo))
    righe.append('')

    # FW.05: la verifica della coppia prima di collegarla. Per i due video di
    # Caligo, lo scarto contro il fotogramma dell'ALTRA cartella (quello che
    # l'ordine dice sbagliato) deve uscire molto piu' alto di quello giusto.
    altra_cartella = {
        'Caligo Chat Scena': 'Caligo Dominio Scena',
        'Caligo Dominio Scena': 'Caligo Chat Scena',
    }

    for cartella, video_nome, fermo_nome, posto in VOCI:
        sorgente_dir = os.path.join(ORIGINE, cartella)
        video_src = os.path.join(sorgente_dir, video_nome)
        fermo_src = os.path.join(sorgente_dir, fermo_nome)
        primo_src = os.path.join(sorgente_dir, PRIMI[cartella])

        dest_video = os.path.join(VIDEO, posto + '_v1.mp4')
        subprocess.run([
            'ffmpeg', '-y', '-loglevel', 'error', '-i', video_src,
            '-c:v', 'libx264', '-profile:v', 'high', '-preset', 'slow',
            '-crf', '26', '-pix_fmt', 'yuv420p', '-movflags', '+faststart',
            '-c:a', 'aac', '-b:a', '96k', dest_video], check=True)

        peso_prima = os.path.getsize(video_src)
        peso_dopo = os.path.getsize(dest_video)
        peso_totale_prima += peso_prima
        peso_totale_dopo += peso_dopo

        prima4 = os.path.join(COLLAUDO, posto + '_fotogramma_4s_prima.png')
        dopo4 = os.path.join(COLLAUDO, posto + '_fotogramma_4s_dopo.png')
        fotogramma(video_src, 4, prima4)
        fotogramma(dest_video, 4, dopo4)
        scarto4 = scarto(prima4, dopo4)

        ultimo_dopo = os.path.join(COLLAUDO, posto + '_ultimo_dopo.png')
        ultimo_fotogramma(dest_video, ultimo_dopo)
        scarto_ultimo = scarto(fermo_src, ultimo_dopo)

        if cartella in altra_cartella:
            sbagliata_dir = os.path.join(ORIGINE, altra_cartella[cartella])
            sbagliata_nome = (fermo_nome.replace('chat', 'XXX')
                               .replace('dominio', 'chat')
                               .replace('XXX', 'dominio'))
            sbagliata_src = os.path.join(sbagliata_dir, sbagliata_nome)
            scarto_sbagliato = scarto(sbagliata_src, ultimo_dopo)
            righe.append(
                '  VERIFICA FW.05: scarto contro il fotogramma sbagliato '
                '(%s) = %.2f, contro quello giusto (%s) = %.2f' % (
                    sbagliata_nome, scarto_sbagliato, fermo_nome,
                    scarto_ultimo))

        dest_fermo = os.path.join(IMMAGINI, posto + '_ultimo_fotogramma_v1.webp')
        w, h = converti_webp(fermo_src, dest_fermo)
        dest_primo = os.path.join(IMMAGINI, posto + '_primo_fotogramma_v1.webp')
        converti_webp(primo_src, dest_primo)

        righe.append(
            '%s (%s): %d byte -> %d byte (%.1f MB -> %.1f MB), SHA-256 %s\n'
            '  fotogramma a 4s, scarto medio %.2f su 255\n'
            '  ultimo fotogramma ricompresso contro %s (%dx%d): scarto %.2f '
            'su 255' % (
                posto + '_v1.mp4', video_nome, peso_prima, peso_dopo,
                peso_prima / 1e6, peso_dopo / 1e6, sha256(dest_video),
                scarto4, fermo_nome, w, h, scarto_ultimo))
        righe.append('')

    righe.append('== IL PESO TOTALE (FW.02)')
    righe.append('prima: %d byte (%.1f MB); dopo: %d byte (%.1f MB)' % (
        peso_totale_prima, peso_totale_prima / 1e6,
        peso_totale_dopo, peso_totale_dopo / 1e6))

    with io.open(os.path.join(COLLAUDO, 'fw01_asset.txt'), 'w',
                 encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(righe) + '\n')
    print('\n'.join(righe))


if __name__ == '__main__':
    main()

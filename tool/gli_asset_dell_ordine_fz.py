# -*- coding: utf-8 -*-
"""GLI ASSET DELL'ORDINE FZ, voce FZ.06.

Per ognuno dei dodici animali del Viaggio dello Sciamano:
- ricomprime il filmato intero (lo stesso metodo di tool/gli_asset_dell_ordine_fu.py:
  libx264, preset slow, crf 28, yuv420p, faststart, audio aac 96k) da 1080p a 1080p,
  per portarlo da circa 13-14 MB a 3-4 MB;
- lo taglia nei tre pezzi esatti letti dal suo <animale>_tagli_v1.json
  (arrivo_si_avvicina, centro_si_volta_ululato, uscita_si_allontana), ognuno un
  file compiuto che si puo' far girare da solo, col filtro trim per fotogramma
  (mai -ss sul file gia' codificato: su Android si aggancia ai fotogrammi chiave,
  vedi la nota di lib/features/maestri/caligo/viaggio/la_discesa_in_video.dart);
- estrae il fotogramma della posa (quello di carta_da_grattare) come immagine
  ferma, per il fermo offline e per il ritorno a un animale gia' rivelato.

Scrive tutto in una cartella di posa (_pronti), MAI nel pacchetto e MAI su git:
l'ordine FZ.06 vuole i video scaricati a richiesta, non nel bundle. La
pubblicazione sul bucket e' un passo suo (vedi tool/pubblica_i_mazzi.py per il
precedente), non fatto da questo script.

Uso: python tool/gli_asset_dell_ordine_fz.py
"""
import hashlib
import json
import os
import subprocess

from PIL import Image, ImageChops, ImageStat

RADICE_ASSET = r'D:\Clienti Roogly\Rituali Cartomanzia\App\Viaggio Sciamano Animali'
PRONTI = os.path.join(RADICE_ASSET, '_pronti')
COLLAUDO = os.path.join(PRONTI, '_collaudo')

ANIMALI = [
    'Aquila', 'Cavallo', 'Cervo', 'Corvo', 'Falco', 'Gufo', 'Lince', 'Lupo',
    'Orso', 'Serpente', 'Tartaruga', 'Volpe',
]

UCCELLI = {'Aquila', 'Corvo', 'Falco', 'Gufo'}

CODIFICA_VIDEO = [
    '-c:v', 'libx264', '-profile:v', 'high', '-preset', 'slow', '-crf', '28',
    '-pix_fmt', 'yuv420p', '-movflags', '+faststart', '-c:a', 'aac', '-b:a', '96k',
]


def sha256(p):
    h = hashlib.sha256()
    with open(p, 'rb') as f:
        for blocco in iter(lambda: f.read(1 << 20), b''):
            h.update(blocco)
    return h.hexdigest()


def fotogramma_esatto(video, n, uscita):
    """Il fotogramma [n] esatto, per indice e non per tempo: select=eq(n,N)
    decodifica dal principio e sceglie per indice, mai per cerca a tempo."""
    subprocess.run([
        'ffmpeg', '-y', '-loglevel', 'error', '-i', video,
        '-vf', 'select=eq(n\\,%d)' % n, '-vframes', '1', uscita,
    ], check=True)


def taglia(video, da_fotogramma, a_fotogramma, da_s, a_s, uscita):
    """Un pezzo compiuto, da [da_fotogramma] a [a_fotogramma] incluso, col
    filtro trim per indice di fotogramma: frame-esatto, mai -ss sul file
    codificato."""
    subprocess.run([
        'ffmpeg', '-y', '-loglevel', 'error', '-i', video,
        '-vf', 'trim=start_frame=%d:end_frame=%d,setpts=PTS-STARTPTS' % (
            da_fotogramma, a_fotogramma + 1),
        '-af', 'atrim=start=%s:end=%s,asetpts=PTS-STARTPTS' % (da_s, a_s),
        *CODIFICA_VIDEO, uscita,
    ], check=True)


def scarto_medio(a_path, b_path):
    a = Image.open(a_path).convert('RGB')
    b = Image.open(b_path).convert('RGB')
    if a.size != b.size:
        b = b.resize(a.size)
    return sum(ImageStat.Stat(ImageChops.difference(a, b)).mean) / 3


def main():
    os.makedirs(PRONTI, exist_ok=True)
    os.makedirs(COLLAUDO, exist_ok=True)
    righe = ["GLI ASSET DELL'ORDINE FZ, voce FZ.06, generato da "
             'tool/gli_asset_dell_ordine_fz.py', '']
    manifesto = {'animali': {}}

    for animale in ANIMALI:
        nome_file = animale.lower()
        cartella = os.path.join(RADICE_ASSET, animale)
        tagli_path = os.path.join(cartella, '%s_tagli_v1.json' % nome_file)
        video_path = os.path.join(cartella, '%s_il_cammino_v1.mp4' % nome_file)
        with open(tagli_path, encoding='utf-8') as fh:
            tagli = json.load(fh)

        righe.append('== %s' % animale)
        peso_prima = os.path.getsize(video_path)

        # La chiave del centro porta il verso proprio dell'animale
        # (ululato, grido, ruggito...): si cerca per prefisso, non per nome
        # intero.
        chiave_centro = next(
            k for k in tagli if k.startswith('centro_si_volta_'))

        pezzi = {}
        for chiave, suffisso in [
            ('arrivo_si_avvicina', 'arrivo'),
            (chiave_centro, 'centro'),
            ('uscita_si_allontana', 'uscita'),
        ]:
            t = tagli[chiave]
            dest = os.path.join(PRONTI, '%s_%s_v1.mp4' % (nome_file, suffisso))
            taglia(video_path, t['da_fotogramma'], t['a_fotogramma'],
                   t['da_s'], t['a_s'], dest)
            peso = os.path.getsize(dest)
            pezzi[suffisso] = {
                'file': os.path.basename(dest),
                'byte': peso,
                'sha256': sha256(dest),
                'da_fotogramma': t['da_fotogramma'],
                'a_fotogramma': t['a_fotogramma'],
            }
            righe.append('  %s: %d byte (fotogrammi %d-%d)' % (
                suffisso, peso, t['da_fotogramma'], t['a_fotogramma']))

        # Il fotogramma della posa: quello dove arrivo finisce e centro
        # comincia, lo stesso della carta da grattare.
        fotogramma_posa = tagli['arrivo_si_avvicina']['a_fotogramma']
        posa_path = os.path.join(PRONTI, '%s_posa_v1.webp' % nome_file)
        posa_png = os.path.join(COLLAUDO, '%s_posa_v1.png' % nome_file)
        fotogramma_esatto(video_path, fotogramma_posa, posa_png)
        Image.open(posa_png).convert('RGB').save(posa_path, 'WEBP', quality=90)
        righe.append('  posa (fotogramma %d): %d byte webp' % (
            fotogramma_posa, os.path.getsize(posa_path)))

        # Collaudo di qualita': il fotogramma a meta' dell'arrivo, prima e
        # dopo la ricompressione del pezzo, stesso metodo del confronto FU.
        meta = tagli['arrivo_si_avvicina']['da_fotogramma'] + (
            tagli['arrivo_si_avvicina']['a_fotogramma'] -
            tagli['arrivo_si_avvicina']['da_fotogramma']) // 2
        prima_png = os.path.join(COLLAUDO, '%s_meta_prima.png' % nome_file)
        dopo_png = os.path.join(COLLAUDO, '%s_meta_dopo.png' % nome_file)
        fotogramma_esatto(video_path, meta, prima_png)
        fotogramma_esatto(
            os.path.join(PRONTI, pezzi['arrivo']['file']),
            meta - tagli['arrivo_si_avvicina']['da_fotogramma'], dopo_png)
        scarto = scarto_medio(prima_png, dopo_png)
        righe.append('  qualita (fotogramma %d, prima/dopo): scarto medio '
                      '%.2f/255' % (meta, scarto))

        peso_dopo = sum(p['byte'] for p in pezzi.values())
        righe.append('  totale pezzi: %d byte (prima il filmato intero era '
                      '%d byte)' % (peso_dopo, peso_prima))

        manifesto['animali'][nome_file] = {
            'pezzi': pezzi,
            'posa': {
                'file': os.path.basename(posa_path),
                'byte': os.path.getsize(posa_path),
                'sha256': sha256(posa_path),
                'fotogramma': fotogramma_posa,
            },
            'scarto_fra_le_due_pose': tagli.get('scarto_fra_le_due_pose'),
            'fine_uscita': tagli.get('fine_uscita'),
            'scena_vuota': ('Uccelli/00_SCENA_UCCELLI_ULTIMO.jpg'
                             if animale in UCCELLI else '00_SCENA_ULTIMO.jpg'
                             ) if tagli.get('fine_uscita') else None,
            'durata_s': tagli['durata_s'],
            'fotogrammi_al_secondo': tagli['fotogrammi_al_secondo'],
        }
        righe.append('')

    with open(os.path.join(PRONTI, 'manifesto_viaggio_v1.json'), 'w',
              encoding='utf-8') as fh:
        json.dump(manifesto, fh, ensure_ascii=False, indent=1)

    with open(os.path.join(PRONTI, 'rapporto_fz06.txt'), 'w',
              encoding='utf-8') as fh:
        fh.write('\n'.join(righe) + '\n')

    print('\n'.join(righe))


if __name__ == '__main__':
    main()

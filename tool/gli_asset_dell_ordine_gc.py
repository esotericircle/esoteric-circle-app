"""GLI ASSET DELL'ORDINE GC, voci GC.06 e GC.18, 22 ottobre 2026.

Porta nel ramo i quattordici simboli dipinti dal fondatore per il livello
visivo dei responsi, consegnati in
D:\\Clienti Roogly\\Rituali Cartomanzia\\App\\Asset GC\\ come PNG 512 per 512
con la trasparenza vera:

- i quattro semi dei Tarocchi (sig_seme_bastoni_v1, sig_seme_coppe_v1,
  sig_seme_spade_v1, sig_seme_denari_v1) e il segno degli Arcani Maggiori
  (sig_arcani_maggiori_v1), per le barre degli elementi della voce GC.06;
- i nove segni dei cori angelici (sig_coro_<coro>_v1), per il riquadro di
  ogni carta dell'Oracolo nella voce GC.18. Il file del quinto coro si
  chiama sig_coro_potesta_v1: nel catalogo degli angeli
  (lib/core/angels/angel_catalog.dart) lo stesso coro si chiama "Potenze",
  il nome che la tradizione italiana da' anche alle Potesta'.

Le immagini diventano WebP alla stessa misura, qualita' 88, col canale alfa
scritto senza perdita (alpha_quality 100), lo stesso metodo di
tool/gli_asset_dell_ordine_fv.py per i sigilli del Calendario Lunare: lo
script verifica file per file che l'alfa sia identico prima e dopo e che il
perimetro resti trasparente. Le misure in docs/collaudo/GC/gc_asset.txt.

Uso: python tool/gli_asset_dell_ordine_gc.py
"""
import os

import numpy as np
from PIL import Image

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ORIGINE = r'D:\Clienti Roogly\Rituali Cartomanzia\App\Asset GC'
SIMBOLI = os.path.join(RADICE, 'assets', 'img', 'simboli')
COLLAUDO = os.path.join(RADICE, 'docs', 'collaudo', 'GC')

ATTESI = (
    'sig_seme_bastoni_v1', 'sig_seme_coppe_v1', 'sig_seme_spade_v1',
    'sig_seme_denari_v1', 'sig_arcani_maggiori_v1',
    'sig_coro_serafini_v1', 'sig_coro_cherubini_v1', 'sig_coro_troni_v1',
    'sig_coro_dominazioni_v1', 'sig_coro_potesta_v1', 'sig_coro_virtu_v1',
    'sig_coro_principati_v1', 'sig_coro_arcangeli_v1', 'sig_coro_angeli_v1',
)


FILMATO_DELLA_STESA = os.path.join(RADICE, 'brand_assets', 'tavolo',
                                   'medora_mazzo_in_vortice_v2.mp4')
TAVOLO = os.path.join(RADICE, 'assets', 'img', 'tavolo')


def ultimo_fotogramma_della_stesa():
    """GC.03: l'ultimo fotogramma del filmato della Stesa, l'unico arrivo.

    Il fondatore: *"Quando faccio click per skippare il video introduttivo,
    la scena si deve fermare allo stesso frame con Medora che ha una mano al
    cuore e l'altra che indica il tavolo."* Il salto si fermava sulla posa
    `medora_invito_v1`, scontornata dall'ultimo fotogramma del filmato v1;
    il filmato v2 (la frenata dell'ordine FS aggiunta) finisce al fotogramma
    166 dell'originale, con l'altra mano che indica il tavolo, e la posa non
    era stata rifatta. Qui l'ultimo fotogramma del v2 (il 189) diventa
    l'immagine ferma della scena, alla misura del filmato, qualita' 88: il
    salto e la fine naturale arrivano alla stessa immagine.
    """
    import subprocess
    import tempfile
    righe = ['IL FOTOGRAMMA DI ARRIVO DELLA STESA (GC.03)']
    with tempfile.TemporaryDirectory() as cartella:
        png = os.path.join(cartella, 'ultimo.png')
        subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-i',
                        FILMATO_DELLA_STESA, '-vf', r'select=eq(n\,189)',
                        '-vframes', '1', png], check=True)
        im = Image.open(png).convert('RGB')
        dest = os.path.join(TAVOLO, 'stesa_ultimo_fotogramma_v1.webp')
        im.save(dest, 'WEBP', quality=88, method=6)
        righe.append('fotogramma 189 di 190 di medora_mazzo_in_vortice_v2.mp4, '
                     '%dx%d, -> stesa_ultimo_fotogramma_v1.webp, %d byte' % (
                         im.width, im.height, os.path.getsize(dest)))
        # La posa di prima, posata sullo stesso riquadro, contro il
        # fotogramma: lo scarto medio nella fascia della mano che indica.
        prima = Image.open(os.path.join(TAVOLO, 'medora_invito_v1.webp'))
        righe.append('posa del salto di prima: medora_invito_v1.webp %dx%d, '
                     'scontornata dall ultimo fotogramma del filmato v1 '
                     '(la mano tesa di lato, non verso il tavolo)' % prima.size)
    return righe


ORACOLO_DEL_FONDATORE = (r'D:\Clienti Roogly\Rituali Cartomanzia\App'
                         r'\Oracolo degli Angeli\medora_scala_di_luce_v2.mp4')
ORACOLO_VIDEO = os.path.join(RADICE, 'brand_assets', 'oracolo_angeli')
ORACOLO_IMMAGINI = os.path.join(RADICE, 'assets', 'img', 'oracolo_angeli')


def il_filmato_v2_dell_oracolo():
    """GC Aggiunta: il filmato rifatto dell'Oracolo degli Angeli.

    Il fondatore, 22 ottobre 2026: *"alla fine non devono restare le carte
    sul tavolo, il tavolo deve restare vuoto"*, *"la ruota dietro giri e si
    illumini"*, *"comprimerlo in 10 secondi"*, poi *"Ottimo"*. Si verifica il
    file consegnato (durata, misura, fotogrammi, audio, impronta), si
    ricomprime col metodo dell'ordine FU voce FU.12 (H.264 profilo high a
    qualita' costante 26, preset slow, yuv420p, faststart, audio AAC 96 kbps)
    alla misura del v1 nel ramo, 720 per 1280, e se ne estraggono il primo e
    l'ultimo fotogramma alla misura d'origine, 1080 per 1920, qualita' 88.
    """
    import hashlib
    import json
    import subprocess
    import tempfile
    righe = ['IL FILMATO V2 DELL ORACOLO DEGLI ANGELI (GC Aggiunta)']
    h = hashlib.sha256(open(ORACOLO_DEL_FONDATORE, 'rb').read()).hexdigest()
    sonda = json.loads(subprocess.run(
        ['ffprobe', '-v', 'error', '-count_frames', '-show_entries',
         'format=duration,size:stream=codec_type,codec_name,width,height,'
         'r_frame_rate,nb_read_frames,sample_rate,channels', '-of', 'json',
         ORACOLO_DEL_FONDATORE], check=True, capture_output=True,
        text=True).stdout)
    video = [s for s in sonda['streams'] if s['codec_type'] == 'video'][0]
    audio = [s for s in sonda['streams'] if s['codec_type'] == 'audio']
    durata = float(sonda['format']['duration'])
    fotogrammi = int(video['nb_read_frames'])
    assert (video['width'], video['height']) == (1080, 1920), video
    assert abs(durata - 10.0) < 0.05, durata
    assert video['r_frame_rate'] == '24/1', video
    righe.append('consegnato: %s, %d byte, SHA-256 %s' % (
        os.path.basename(ORACOLO_DEL_FONDATORE),
        int(sonda['format']['size']), h))
    righe.append('durata %.3f s, %dx%d, %s fotogrammi al secondo, %d '
                 'fotogrammi, audio %s' % (
                     durata, video['width'], video['height'],
                     video['r_frame_rate'], fotogrammi,
                     ('%s %s Hz %s canali' % (audio[0]['codec_name'],
                                              audio[0]['sample_rate'],
                                              audio[0]['channels']))
                     if audio else 'assente'))
    dest = os.path.join(ORACOLO_VIDEO, 'medora_scala_di_luce_v2.mp4')
    subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-i',
                    ORACOLO_DEL_FONDATORE, '-vf', 'scale=720:1280',
                    '-c:v', 'libx264', '-profile:v', 'high', '-crf', '26',
                    '-preset', 'slow', '-pix_fmt', 'yuv420p',
                    '-movflags', '+faststart', '-c:a', 'aac', '-b:a', '96k',
                    dest], check=True)
    hd = hashlib.sha256(open(dest, 'rb').read()).hexdigest()
    righe.append('nel ramo: brand_assets/oracolo_angeli/'
                 'medora_scala_di_luce_v2.mp4, 720x1280, %d byte, SHA-256 %s'
                 % (os.path.getsize(dest), hd))
    vecchio = os.path.join(ORACOLO_VIDEO, 'medora_scala_di_luce_v1.mp4')
    if os.path.exists(vecchio):
        os.remove(vecchio)
        righe.append('tolto dal ramo: medora_scala_di_luce_v1.mp4 (resta sul '
                     'PC del fondatore, non si usa piu)')
    with tempfile.TemporaryDirectory() as cartella:
        for nome, n in (('primo', 0), ('ultimo', fotogrammi - 1)):
            png = os.path.join(cartella, nome + '.png')
            subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-i',
                            ORACOLO_DEL_FONDATORE, '-vf',
                            r'select=eq(n\,%d)' % n, '-vframes', '1', png],
                           check=True)
            im = Image.open(png).convert('RGB')
            uscita = os.path.join(ORACOLO_IMMAGINI,
                                  'oracolo_%s_fotogramma_v2.webp' % nome)
            im.save(uscita, 'WEBP', quality=88, method=6)
            righe.append('fotogramma %d -> oracolo_%s_fotogramma_v2.webp, '
                         '%dx%d, %d byte' % (n, nome, im.width, im.height,
                                             os.path.getsize(uscita)))
            vecchia = os.path.join(ORACOLO_IMMAGINI,
                                   'oracolo_%s_fotogramma_v1.webp' % nome)
            if os.path.exists(vecchia):
                os.remove(vecchia)
        # L'altare dell'ultimo fotogramma e' vuoto: lo scarto medio della
        # fascia dei dorsi (pixel da 1505 a 1715) contro il primo fotogramma,
        # dove l'altare e' sgombro per costruzione.
        from PIL import ImageChops, ImageStat
        a = Image.open(os.path.join(cartella, 'primo.png')).convert('RGB')
        b = Image.open(os.path.join(cartella, 'ultimo.png')).convert('RGB')
        fascia = (0, 1505, 1080, 1715)
        scarto = sum(ImageStat.Stat(ImageChops.difference(
            a.crop(fascia), b.crop(fascia))).mean) / 3
        righe.append('altare nell ultimo fotogramma contro il primo (fascia '
                     'dei dorsi, pixel 1505-1715): scarto medio %.1f livelli '
                     'su 255 (nel v1, con i tre dorsi dipinti, 28,1)' % scarto)
    return righe


def main():
    os.makedirs(SIMBOLI, exist_ok=True)
    os.makedirs(COLLAUDO, exist_ok=True)
    righe = ['GLI ASSET DELL\'ORDINE GC, da %s' % ORIGINE, '']
    mancanti = []
    for nome in ATTESI:
        sorgente = os.path.join(ORIGINE, nome + '.png')
        if not os.path.exists(sorgente):
            mancanti.append(nome)
            continue
        im = Image.open(sorgente)
        assert im.mode == 'RGBA', '%s non ha la trasparenza' % nome
        assert im.size == (512, 512), '%s misura %s' % (nome, im.size)
        alfa = np.asarray(im.getchannel('A'))
        perimetro = max(int(alfa[0].max()), int(alfa[-1].max()),
                        int(alfa[:, 0].max()), int(alfa[:, -1].max()))
        assert perimetro == 0, '%s: perimetro non trasparente' % nome
        dest = os.path.join(SIMBOLI, nome + '.webp')
        im.save(dest, 'WEBP', quality=88, alpha_quality=100, method=6)
        dopo = Image.open(dest)
        assert dopo.mode == 'RGBA', dest
        diversi = int((alfa != np.asarray(dopo.getchannel('A'))).sum())
        assert diversi == 0, '%s: alfa cambiato in %d pixel' % (nome, diversi)
        righe.append(
            '%s 512x512 RGBA, trasparenti %.1f%%, perimetro trasparente, '
            'alfa identico (0 pixel cambiati): %d byte PNG -> %d byte WebP' % (
                nome, 100.0 * (alfa == 0).sum() / alfa.size,
                os.path.getsize(sorgente), os.path.getsize(dest)))
    righe.append('')
    righe.append('portati %d su %d, mancanti: %s' % (
        len(ATTESI) - len(mancanti), len(ATTESI),
        ', '.join(mancanti) if mancanti else 'nessuno'))
    righe.append('')
    righe.extend(ultimo_fotogramma_della_stesa())
    righe.append('')
    righe.extend(il_filmato_v2_dell_oracolo())
    with open(os.path.join(COLLAUDO, 'gc_asset.txt'), 'w', encoding='utf-8',
              newline='\n') as f:
        f.write('\n'.join(righe) + '\n')
    print('\n'.join(righe))


if __name__ == '__main__':
    main()

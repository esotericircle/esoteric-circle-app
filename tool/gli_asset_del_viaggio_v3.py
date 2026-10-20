# -*- coding: utf-8 -*-
"""GLI ASSET DEL VIAGGIO, TERZA VERSIONE: il "si volta" vero dei sette animali
di terra.

Il pezzo `volta` della v2 (tool/gli_asset_del_viaggio_v2.py) era un taglio
andata e ritorno del primo tratto dell'uscita: buono per Gufo, Aquila, Falco,
Corvo e Serpente, che nell'uscita si voltano col corpo intero, debole per i
sette animali di terra, che prima che una zampa si stacchi da terra girano il
capo di pochi fotogrammi (la Lince e la Volpe due, il pezzo durava 0,46 s).
L'Architetto, 20 ottobre 2026, ha consegnato per Lince, Volpe, Orso, Lupo,
Cavallo, Cervo e Tartaruga un video nuovo, `<animale>_si_volta_v1.mp4`
(1080x1920, 24 fps, 8 s, audio di Flow), col suo
`<animale>_si_volta_tagli_v1.json`: i quattro punti del gesto al fotogramma
(inizio, girata completa, ritorno, fine), lo scarto dalla carta e il tratto
fermo dove si puo' accorciare.

Per ognuno dei sette scrive in `_pronti_v3` (MAI in `_pronti` o
`_pronti_v2`, mai sopra un file esistente, mai nel pacchetto ne' su git):

- `<animale>_volta_v3.mp4`, il pezzo nuovo del gesto "si volta": dal
  fotogramma `inizio` al fotogramma `fine` del file dei tagli, non tutti gli
  8 s. Le giunture con la posa stanno NEL FILE, come nella v2 (il lettore,
  `IlCamminoDellAnimale`, dissolve solo fra due pezzi; il pezzo volta e' solo
  sopra la posa e comparirebbe di colpo): i primi e gli ultimi [DISSOLVENZA]
  fotogrammi, 0,29 s (la dissolvenza di 0,3 s dell'ordine FZ voce FZ.05 al
  fotogramma intero), si fondono col fotogramma della posa del cammino
  (quello di `<animale>_posa_v1.webp`, lo stesso della v2), cosi' il primo e
  l'ultimo fotogramma SONO la posa. Il lavoro sui fotogrammi si fa in YUV
  4:2:0, senza passare per l'RGB.
- **IL TRATTO FERMO NON SI ACCORCIA, E LO DICE UNA MISURA.** Il file dei tagli
  permette di tagliare dentro il tratto fermo con una dissolvenza di 0,3 s.
  Ma il tratto "fermo" non e' fermo: la posa continua a scivolare (sulla zona
  dell'animale ridotta di otto volte, che vede la posa e non la grana, ogni
  fotogramma del fermo dista dalla girata completa fra 2 e 11 su 255, contro
  1,6-2,6 fra due fotogrammi vicini). Una dissolvenza fra due tratti si vede
  quando i due tratti differiscono piu' di una volta e mezza due fotogrammi
  vicini: [misura_del_taglio] cerca, per ogni animale, il taglio piu' lungo
  che sta sotto quella soglia, e lo scrive nel rapporto. Per i tre col fermo
  piu' lungo (Orso 3,25 s, Lupo 3,00 s, Cavallo 4,08 s) il taglio invisibile
  toglie al piu' 0,38, 0,71 e 0,67 s; per portare lo sguardo indietro a due
  secondi ne andrebbero tolti 1,25, 1,00 e 2,08 s, con due tratti che
  differiscono 2,3, 1,75 e 2,9 volte due fotogrammi vicini: il Cavallo,
  tagliato di due secondi, mostra nella dissolvenza due teste (foglio
  `docs/collaudo/viaggio_volta/v3/taglio_nel_fermo_scartato.jpg`). Il gesto
  resta quello che il fondatore ha approvato, intero.
- **IL CALO DI UN FOTOGRAMMA CHE FLOW LASCIA ACCANTO AL LAMPO**: i lampi dei
  fotogrammi 70 e 190 (e 72 nel Cervo) l'Architetto li ha gia' tolti; dove
  un fotogramma del pezzo resta piu' scuro dei vicini di oltre
  [SOGLIA_DEL_CALO] su 255 nella luminosita' media del piano Y (il rumore fra
  fotogrammi vicini sta sotto 0,6), la sua luminosita' si riporta alla media
  dei vicini moltiplicando il piano Y, senza mescolare fotogrammi (nessuna
  doppia immagine). Si dichiara nel rapporto e nel manifesto.
- L'audio di Flow resta: lo stesso tratto del video, con una rampa di 20 ms
  in testa e in coda contro lo schiocco.
- `manifesto_viaggio_v3.json`: quello della v2 con `versione: 3` e, per i
  sette, il pezzo `volta` nuovo; per Gufo, Aquila, Falco, Corvo e Serpente il
  pezzo volta della v2, e il resto invariato (i file che non cambiano restano
  quelli gia' pubblicati: l'app li riprende dal telefono).
- `_collaudo/`: per ogni animale il foglio di 16 fotogrammi del pezzo, il
  foglio affiancato sorgente contro compresso negli stessi quattro punti
  (inizio, girata completa, ritorno, fine) ritagliato sull'animale, e
  `rapporto_v3.txt` con le misure.

Stessa codifica dei pezzi gia' in linea (ordine FZ voce FZ.06 e v2): libx264
High, preset slow, crf 28, yuv420p, faststart, 1080x1920, 24 fps, aac 96k
48 kHz stereo, gli stessi segni di colore, e l'ultimo fotogramma chiave.

Uso: python tool/gli_asset_del_viaggio_v3.py
"""
import copy
import hashlib
import json
import os
import shutil
import subprocess
import tempfile
import wave

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageStat

RADICE_ASSET = r'D:\Clienti Roogly\Rituali Cartomanzia\App\Viaggio Sciamano Animali'
PRONTI_V1 = os.path.join(RADICE_ASSET, '_pronti')
PRONTI_V2 = os.path.join(RADICE_ASSET, '_pronti_v2')
PRONTI = os.path.join(RADICE_ASSET, '_pronti_v3')
COLLAUDO = os.path.join(PRONTI, '_collaudo')
# La carta che l'app tiene sotto il cammino nel segno
# (`IlSegnoCheRisponde.posaDi`), nel pacchetto.
CARTE_DEL_PACCHETTO = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..', 'assets', 'img',
    'mondo_di_sotto', 'carte')

LARGO, ALTO, FPS = 1080, 1920, 24
QUADRO = LARGO * ALTO * 3 // 2  # un fotogramma yuv420p
CAMPIONI_AL_FOTOGRAMMA = 48000 // FPS  # 2000

ANIMALI_DI_TERRA = ['Lince', 'Volpe', 'Orso', 'Lupo', 'Cavallo', 'Cervo',
                    'Tartaruga']

DISSOLVENZA = 7  # fotogrammi, 0,29 s: la dissolvenza di 0,3 s di FZ.05
SOGLIA_DEL_CALO = 0.8
FERMO_VOLUTO = 48  # due secondi di sguardo indietro, se si potesse tagliare
TAGLIO_INVISIBILE = 1.5  # volte la differenza fra due fotogrammi vicini

# La zona dell'animale nel fotogramma (x, y, larghezza, altezza): li' si
# misura il taglio, e li' si ritaglia il foglio affiancato. Tutti e sette
# stanno in posa nello stesso punto della scena, a sinistra del grande albero.
ZONA = (100, 560, 800, 1200)

CODIFICA_VIDEO = [
    '-c:v', 'libx264', '-profile:v', 'high', '-preset', 'slow', '-crf', '28',
    '-pix_fmt', 'yuv420p', '-color_range', 'tv', '-colorspace', 'smpte170m',
    '-color_trc', 'iec61966-2-1', '-color_primaries', 'bt709',
    '-movflags', '+faststart', '-c:a', 'aac', '-b:a', '96k', '-ar', '48000',
    '-ac', '2',
]


def sha256(p):
    h = hashlib.sha256()
    with open(p, 'rb') as f:
        for blocco in iter(lambda: f.read(1 << 20), b''):
            h.update(blocco)
    return h.hexdigest()


def fotogrammi_yuv(video, da, fino):
    """I fotogrammi da [da] a [fino] inclusi, per indice, in yuv420p."""
    dati = subprocess.run([
        'ffmpeg', '-loglevel', 'error', '-i', video, '-an',
        '-vf', 'trim=start_frame=%d:end_frame=%d,setpts=PTS-STARTPTS' % (
            da, fino + 1),
        '-fps_mode', 'passthrough',
        '-f', 'rawvideo', '-pix_fmt', 'yuv420p', '-',
    ], check=True, capture_output=True).stdout
    n = len(dati) // QUADRO
    assert n == fino - da + 1, '%s: %d fotogrammi invece di %d' % (
        video, n, fino - da + 1)
    return [np.frombuffer(dati[i * QUADRO:(i + 1) * QUADRO], dtype=np.uint8)
            for i in range(n)]


def zona_ridotta(video):
    """Ogni fotogramma, la sola zona dell'animale ridotta di otto volte, in
    grigio: vede la posa, non la grana che Flow rifa' a ogni fotogramma."""
    x, y, w, h = ZONA
    dati = subprocess.run([
        'ffmpeg', '-loglevel', 'error', '-i', video, '-an',
        '-fps_mode', 'passthrough',
        '-vf', 'crop=%d:%d:%d:%d,scale=%d:%d:flags=area' % (
            w, h, x, y, w // 8, h // 8),
        '-f', 'rawvideo', '-pix_fmt', 'gray', '-',
    ], check=True, capture_output=True).stdout
    return np.frombuffer(dati, np.uint8).reshape(-1, h // 8, w // 8).astype(
        np.float32)


def piano_y(q):
    return q[:LARGO * ALTO].reshape(ALTO, LARGO)


def audio_pcm(video):
    """L'audio intero, 48 kHz stereo, in float."""
    grezzo = subprocess.run([
        'ffmpeg', '-loglevel', 'error', '-i', video, '-vn', '-ac', '2',
        '-ar', '48000', '-f', 's16le', '-',
    ], check=True, capture_output=True).stdout
    return np.frombuffer(grezzo, dtype=np.int16).reshape(-1, 2).astype(
        np.float64)


def scrivi_wav(campioni, uscita):
    c = np.clip(np.rint(campioni), -32768, 32767).astype(np.int16)
    with wave.open(uscita, 'wb') as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(48000)
        w.writeframes(c.tobytes())


def codifica(quadri, wav, uscita):
    """Scrive [quadri] (yuv420p) con l'audio di [wav], con la codifica dei
    pezzi gia' in linea. L'ultimo fotogramma e' chiave (vedi la v2: e'
    quello su cui l'app resta ferma, sopra la posa)."""
    proc = subprocess.Popen([
        'ffmpeg', '-y', '-loglevel', 'error',
        '-f', 'rawvideo', '-pix_fmt', 'yuv420p', '-s', '%dx%d' % (LARGO, ALTO),
        '-r', str(FPS), '-color_range', 'tv', '-colorspace', 'smpte170m',
        '-color_trc', 'iec61966-2-1', '-color_primaries', 'bt709', '-i', '-',
        '-i', wav, '-map', '0:v', '-map', '1:a', *CODIFICA_VIDEO,
        '-shortest', '-force_key_frames', 'expr:eq(n,%d)' % (len(quadri) - 1),
        uscita,
    ], stdin=subprocess.PIPE)
    for q in quadri:
        proc.stdin.write(q.tobytes())
    proc.stdin.close()
    assert proc.wait() == 0, uscita


def fotogramma_png(video, n, uscita):
    subprocess.run([
        'ffmpeg', '-y', '-loglevel', 'error', '-i', video,
        '-vf', 'select=eq(n\\,%d)' % n, '-vframes', '1', uscita,
    ], check=True)


def conta_fotogrammi(video):
    r = subprocess.run([
        'ffprobe', '-v', 'error', '-count_frames', '-select_streams', 'v:0',
        '-show_entries', 'stream=nb_read_frames', '-of', 'csv=p=0', video,
    ], check=True, capture_output=True, text=True).stdout
    return int(r.strip())


def tempi_dei_fotogrammi(video):
    """Il tempo di presentazione di ogni fotogramma, in secondi."""
    r = subprocess.run([
        'ffprobe', '-v', 'error', '-select_streams', 'v:0',
        '-show_entries', 'frame=pts_time', '-of', 'csv=p=0', video,
    ], check=True, capture_output=True, text=True).stdout
    return [float(x.strip(',')) for x in r.split()]


def bitrate_video(video):
    r = subprocess.run([
        'ffprobe', '-v', 'error', '-select_streams', 'v:0',
        '-show_entries', 'stream=bit_rate', '-of', 'csv=p=0', video,
    ], check=True, capture_output=True, text=True).stdout
    return int(r.strip())


def scarto_medio(a, b):
    """Lo scarto medio per canale, su 255, fra due immagini PIL o percorsi."""
    a = (Image.open(a) if isinstance(a, str) else a).convert('RGB')
    b = (Image.open(b) if isinstance(b, str) else b).convert('RGB')
    if a.size != b.size:
        b = b.resize(a.size)
    return sum(ImageStat.Stat(ImageChops.difference(a, b)).mean) / 3


def scarto_ridotto(a, b):
    """Lo stesso scarto alla scala dell'Architetto, 180x320."""
    return scarto_medio(a.convert('RGB').resize((180, 320), Image.BILINEAR),
                        b.convert('RGB').resize((180, 320), Image.BILINEAR))


def psnr_y(a, b):
    d = piano_y(a).astype(np.float64) - piano_y(b).astype(np.float64)
    mse = (d ** 2).mean()
    return 99.0 if mse == 0 else 10 * np.log10(255 ** 2 / mse)


def immagine(video, n):
    png = os.path.join(COLLAUDO, '_tmp_%d.png' % os.getpid())
    fotogramma_png(video, n, png)
    im = Image.open(png).convert('RGB')
    im.load()
    os.remove(png)
    return im


def etichetta(im, testo):
    d = ImageDraw.Draw(im)
    d.rectangle((0, 0, 7 * len(testo) + 6, 14), fill=(0, 0, 0))
    d.text((3, 1), testo, fill=(255, 220, 0))
    return im


def foglio(celle, colonne, uscita):
    w, h = celle[0].size
    righe = (len(celle) + colonne - 1) // colonne
    f = Image.new('RGB', (w * colonne, h * righe), (20, 20, 20))
    for i, c in enumerate(celle):
        f.paste(c, ((i % colonne) * w, (i // colonne) * h))
    f.save(uscita, quality=90)


def misura_del_taglio(zone, g, r):
    """Quanto si potrebbe togliere dal tratto fermo [g, r] senza che la
    dissolvenza si veda. Per ogni lunghezza del taglio, la coppia di tratti
    di [DISSOLVENZA] fotogrammi piu' simili sulla zona ridotta; un taglio e'
    invisibile se i due tratti differiscono meno di [TAGLIO_INVISIBILE] volte
    due fotogrammi vicini del fermo."""
    vicini = float(np.mean([np.abs(zone[i] - zone[i + 1]).mean()
                            for i in range(g, r)]))
    deriva = [float(np.abs(zone[i] - zone[g]).mean()) for i in range(g, r + 1)]
    migliori = {}
    for tolti in range(1, r - g - DISSOLVENZA - 8):
        for a in range(g + 4, r - 4 - DISSOLVENZA - tolti + 1):
            costo = float(np.mean([np.abs(zone[a + k] - zone[a + tolti + k])
                                   .mean() for k in range(DISSOLVENZA)]))
            if tolti not in migliori or costo < migliori[tolti][0]:
                migliori[tolti] = (costo, a)
    invisibile = max([t for t, (c, _) in migliori.items()
                      if c <= TAGLIO_INVISIBILE * vicini] or [0])
    voluto = r - g - FERMO_VOLUTO
    return {
        'fermo_fotogrammi': r - g,
        'differenza_fra_vicini': round(vicini, 2),
        'deriva_dalla_girata_max': round(max(deriva), 2),
        'taglio_invisibile_max_fotogrammi': invisibile,
        'taglio_per_due_secondi_fotogrammi': max(voluto, 0),
        'costo_del_taglio_per_due_secondi': (
            round(migliori[voluto][0], 2) if voluto in migliori else None),
    }


def pezzo_volta(animale, righe):
    nome = animale.lower()
    cartella = os.path.join(RADICE_ASSET, animale)
    with open(os.path.join(cartella, '%s_si_volta_tagli_v1.json' % nome),
              encoding='utf-8') as fh:
        tagli = json.load(fh)
    with open(os.path.join(cartella, '%s_tagli_v1.json' % nome),
              encoding='utf-8') as fh:
        tagli_v1 = json.load(fh)
    video = os.path.join(cartella, tagli['video'])
    cammino = os.path.join(cartella, '%s_il_cammino_v1.mp4' % nome)
    gesto = tagli['si_volta']
    da = gesto['inizio']['fotogramma']
    g = gesto['girata_completa']['fotogramma']
    r = gesto['ritorno_inizio']['fotogramma']
    fino = gesto['fine']['fotogramma']

    # **L'INDICE DEL FOTOGRAMMA E' IL SUO TEMPO, FINO ALLA FINE DEL GESTO**:
    # il Cervo ha 189 fotogrammi e non 192 (mancano il 188, il 189 e il 190,
    # l'ultimo sta a 7,958 s), fuori dal gesto che finisce al 172. Si
    # controlla che fino a [fino] + 1 il fotogramma k stia a k/24 s, perche'
    # il taglio per indice (trim=start_frame) colga i fotogrammi del file
    # dei tagli.
    tempi = tempi_dei_fotogrammi(video)
    for k in range(fino + 2):
        assert abs(tempi[k] - k / FPS) < 1e-3, '%s: il fotogramma %d sta a ' \
            '%.4f s' % (video, k, tempi[k])
    note = []
    if len(tempi) != tagli['fotogrammi']:
        note.append('  NOTA: la sorgente ha %d fotogrammi e non %d (mancano '
                    'dopo la fine del gesto, che sta tutto a passo regolare)'
                    % (len(tempi), tagli['fotogrammi']))

    # Il tratto fermo: la misura che dice se si puo' accorciare.
    taglio = misura_del_taglio(zona_ridotta(video), g, r)

    # La sorgente con un fotogramma di vicini per parte, per il calo.
    sorgente = fotogrammi_yuv(video, da - 1, fino + 1)
    lum = [piano_y(q).mean() for q in sorgente]
    sorgente = [q.copy() for q in sorgente]
    cali = []
    for i in range(1, len(sorgente) - 1):
        vicini = (lum[i - 1] + lum[i + 1]) / 2
        if vicini - lum[i] > SOGLIA_DEL_CALO:
            y = piano_y(sorgente[i]).astype(np.float32) * (vicini / lum[i])
            sorgente[i][:LARGO * ALTO] = np.clip(np.rint(y), 0, 255).astype(
                np.uint8).ravel()
            cali.append({'fotogramma': da - 1 + i,
                         'calo': round(float(vicini - lum[i]), 2)})
    quadri = sorgente[1:-1]  # da [da] a [fino]
    del sorgente

    # La dissolvenza con la posa, in testa e in coda: il primo e l'ultimo
    # fotogramma SONO la posa del cammino, da cui viene
    # `<animale>_posa_v1.webp` (la stessa della v2, in YUV senza RGB).
    posa_n = tagli_v1['arrivo_si_avvicina']['a_fotogramma']
    posa = fotogrammi_yuv(cammino, posa_n, posa_n)[0].astype(np.float32)
    for k in range(DISSOLVENZA):
        peso = 1.0 - k / DISSOLVENZA
        for i in (k, len(quadri) - 1 - k):
            q = quadri[i].astype(np.float32)
            quadri[i] = np.clip(np.rint(peso * posa + (1 - peso) * q), 0,
                                255).astype(np.uint8)

    punti = [('inizio', da, 0), ('girata', g, g - da),
             ('ritorno', r, r - da), ('fine', fino, fino - da)]
    composti = {i: quadri[i].copy() for _, _, i in punti}

    # L'audio di Flow, lo stesso tratto.
    pcm = audio_pcm(video)
    suono = pcm[da * CAMPIONI_AL_FOTOGRAMMA:
                (fino + 1) * CAMPIONI_AL_FOTOGRAMMA].copy()
    assert len(suono) == len(quadri) * CAMPIONI_AL_FOTOGRAMMA
    n_r = 960  # 20 ms
    suono[:n_r] *= np.linspace(0, 1, n_r)[:, None]
    suono[-n_r:] *= np.linspace(1, 0, n_r)[:, None]

    dest = os.path.join(PRONTI, '%s_volta_v3.mp4' % nome)
    assert not os.path.exists(dest), 'non si sovrascrive: %s' % dest
    lavoro = tempfile.mkdtemp(prefix='viaggio_v3_')
    try:
        wav = os.path.join(lavoro, 'audio.wav')
        scrivi_wav(suono, wav)
        codifica(quadri, wav, dest)
    finally:
        shutil.rmtree(lavoro, ignore_errors=True)
    n = conta_fotogrammi(dest)
    assert n == len(quadri), '%s: %d fotogrammi invece di %d' % (
        dest, n, len(quadri))
    del quadri

    # La misura: il primo e l'ultimo fotogramma contro la posa
    # (`<animale>_posa_v1.webp`), contro il fotogramma di posa del cammino
    # decodificato allo stesso modo, e contro la carta del pacchetto, quella
    # che il segno tiene davvero sotto il video; e quanto ne differiva la
    # sorgente senza la dissolvenza, a piena risoluzione e alla scala
    # dell'Architetto.
    posa_webp = os.path.join(PRONTI_V1, '%s_posa_v1.webp' % nome)
    carta = os.path.join(CARTE_DEL_PACCHETTO,
                         '%s_carta_da_grattare_v1.webp' % nome)
    posa_sorgente = immagine(cammino, posa_n)
    misure = {}
    for chi, i in (('primo', 0), ('ultimo', n - 1)):
        im = immagine(dest, i)
        misure[chi] = (scarto_medio(im, posa_webp),
                       scarto_medio(im, posa_sorgente),
                       scarto_medio(im, carta))
    senza = {}
    for chi, f in (('primo', da), ('ultimo', fino)):
        im = immagine(video, f)
        senza[chi] = (scarto_medio(im, posa_webp),
                      scarto_ridotto(im, Image.open(carta)))

    # La qualita': compresso contro composto (la sola perdita della
    # codifica) e compresso contro sorgente, nei quattro punti.
    x, y, w, h = ZONA
    qualita = []
    celle_sorgente, celle_compresso = [], []
    for chi, f, i in punti:
        im_s = immagine(video, f)
        im_c = immagine(dest, i)
        compresso = fotogrammi_yuv(dest, i, i)[0]
        qualita.append((chi, f, i, psnr_y(compresso, composti[i]),
                        scarto_medio(im_c, im_s)))
        celle_sorgente.append(etichetta(im_s.crop((x, y, x + w, y + h)),
                                        'sorgente %s f%d' % (chi, f)))
        celle_compresso.append(etichetta(im_c.crop((x, y, x + w, y + h)),
                                         'v3 compresso %s n%d' % (chi, i)))
    foglio(celle_sorgente + celle_compresso, 4,
           os.path.join(COLLAUDO, '%s_volta_affiancati.jpg' % nome))

    numeri = [round(i * (n - 1) / 15) for i in range(16)]
    celle = []
    for i in numeri:
        im = immagine(dest, i)
        im = im.resize((240, int(im.size[1] * 240 / im.size[0])))
        e = 'n%d f%d' % (i, i + da)
        if i < DISSOLVENZA or i >= n - DISSOLVENZA:
            e += '+posa'
        celle.append(etichetta(im, e))
    foglio(celle, 8, os.path.join(COLLAUDO, '%s_volta_foglio.jpg' % nome))

    durata = n / FPS
    peso_sorgente = os.path.getsize(video)
    peso = os.path.getsize(dest)
    kbit = bitrate_video(dest) // 1000
    righe.append('== %s' % animale)
    righe.extend(note)
    righe.append('  gesto: inizio %d, girata completa %d, ritorno %d, fine %d '
                 '(sorgente %s, %d byte)' % (da, g, r, fino, tagli['video'],
                                             peso_sorgente))
    righe.append('  tratto fermo %d-%d, %d fotogrammi (%.2f s): non accorciato. '
                 'Fra due fotogrammi vicini %.2f/255, deriva dalla girata fino '
                 'a %.2f/255; taglio invisibile al massimo %d fotogrammi '
                 '(%.2f s); per due secondi di fermo ne andrebbero tolti %d '
                 '(costo %s)' % (
                     g, r, r - g, (r - g) / FPS,
                     taglio['differenza_fra_vicini'],
                     taglio['deriva_dalla_girata_max'],
                     taglio['taglio_invisibile_max_fotogrammi'],
                     taglio['taglio_invisibile_max_fotogrammi'] / FPS,
                     taglio['taglio_per_due_secondi_fotogrammi'],
                     taglio['costo_del_taglio_per_due_secondi']))
    for c in cali:
        righe.append('  calo di luminosita\' riportato: fotogramma %d, %.2f '
                     'su 255 sotto la media dei vicini' % (c['fotogramma'],
                                                           c['calo']))
    righe.append('  pezzo: %d fotogrammi, %.3f s, %d byte, video %d kbit/s' % (
        n, durata, peso, kbit))
    righe.append('  punti nel pezzo: ' + ', '.join(
        '%s n%d' % (chi, i) for chi, _, i in punti))
    righe.append('  primo contro la posa: %.2f/255 (posa webp) %.2f/255 '
                 '(posa del cammino) %.2f/255 (carta del pacchetto); ultimo: '
                 '%.2f / %.2f / %.2f' % (*misure['primo'], *misure['ultimo']))
    righe.append('  senza la dissolvenza: primo %.2f/255 dalla posa webp '
                 '(%.2f alla scala 180x320 dalla carta), ultimo %.2f (%.2f)' % (
                     *senza['primo'], *senza['ultimo']))
    for chi, f, i, p, sc in qualita:
        righe.append('  qualita %s (f%d, n%d): PSNR Y contro il composto %.1f '
                     'dB, scarto dalla sorgente %.2f/255' % (chi, f, i, p, sc))

    voce = {
        'file': os.path.basename(dest),
        'byte': peso,
        'sha256': sha256(dest),
        'sorgente': tagli['video'],
        'da_fotogramma': da,
        'a_fotogramma': fino,
        'girata_completa': g,
        'ritorno_inizio': r,
        'fermo_non_accorciato': taglio,
        'cali_riportati': cali,
        'dissolvenza_con_la_posa': DISSOLVENZA,
        'fotogrammi': n,
        'durata_s': round(durata, 3),
        'scarto_primo_dalla_posa': round(misure['primo'][0], 2),
        'scarto_ultimo_dalla_posa': round(misure['ultimo'][0], 2),
    }
    return voce


def main():
    os.makedirs(PRONTI, exist_ok=True)
    os.makedirs(COLLAUDO, exist_ok=True)
    with open(os.path.join(PRONTI_V2, 'manifesto_viaggio_v2.json'),
              encoding='utf-8') as fh:
        v2 = json.load(fh)
    manifesto = copy.deepcopy(v2)
    manifesto['versione'] = 3
    righe = ['GLI ASSET DEL VIAGGIO v3, generato da '
             'tool/gli_asset_del_viaggio_v3.py', '']
    for animale in ANIMALI_DI_TERRA:
        nome = animale.lower()
        voce = pezzo_volta(animale, righe)
        prima = v2['animali'][nome]['pezzi']['volta']
        righe.append('  il pezzo volta della v2: %s, %d byte, %.3f s' % (
            prima['file'], prima['byte'], conta_fotogrammi(
                os.path.join(PRONTI_V2, prima['file'])) / FPS))
        righe.append('')
        manifesto['animali'][nome]['pezzi']['volta'] = voce

    with open(os.path.join(PRONTI, 'manifesto_viaggio_v3.json'), 'w',
              encoding='utf-8', newline='\n') as fh:
        json.dump(manifesto, fh, ensure_ascii=False, indent=1)
    with open(os.path.join(COLLAUDO, 'rapporto_v3.txt'), 'w',
              encoding='utf-8', newline='\n') as fh:
        fh.write('\n'.join(righe) + '\n')
    print('\n'.join(righe))


if __name__ == '__main__':
    main()

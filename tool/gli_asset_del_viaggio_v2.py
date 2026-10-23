# -*- coding: utf-8 -*-
"""GLI ASSET DEL VIAGGIO, SECONDA VERSIONE: il pezzo "volta" e le cure D3, D4.

Nasce dalla verifica fotogramma per fotogramma dei dodici animali del Viaggio
dello Sciamano, 20 ottobre 2026: in tutti e dodici il pezzo "centro", quello
che l'app faceva girare per il gesto "si volta", mostra il verso dell'animale
e non il voltarsi; il voltarsi c'e' solo nel primo secondo dell'uscita. Il
fondatore: *"Certo che devi controllare che il gufo si giri, ma anche gli
altri animali devono comportarsi allo stesso modo."* La cura scelta da lui:
*"Taglio andata e ritorno"*.

Per ognuno dei dodici animali scrive in `_pronti_v2` (MAI in `_pronti`, mai
sopra un file esistente, mai nel pacchetto ne' su git):

- `<animale>_volta_v2.mp4`, il pezzo nuovo del gesto "si volta": dal
  fotogramma dove comincia l'uscita (la posa) fino a [VOLTA] (l'animale ha
  girato il capo o il corpo), fermo [FERMO] fotogrammi, poi lo stesso tratto
  al contrario. I primi e gli ultimi [RACCORDO] fotogrammi si fondono col
  fotogramma della posa (quello della carta e di `<animale>_posa_v1.webp`),
  cosi' il pezzo comincia e finisce sulla posa e non sul fotogramma 165, che
  ne differisce di 3-5 su 255 (`scarto_fra_le_due_pose`). Il lavoro sui
  fotogrammi si fa in YUV 4:2:0, senza passare per l'RGB: nessuno
  spostamento di colore rispetto agli altri pezzi. L'audio NON si rovescia:
  e' il tratto piu' quieto (ambiente del bosco) dello stesso filmato, della
  stessa durata, scelto misurando il livello a decimi di secondo.
- D3, il Cervo: `cervo_arrivo_v2.mp4` dal fotogramma 3 (nei fotogrammi 0-2 il
  cervo compare senza palchi e la testa si deforma).
- D4, Cavallo, Cervo, Lince, Lupo, Orso, Serpente, Volpe:
  `<animale>_uscita_v2.mp4` che finisce prima che l'animale diventi
  trasparente ([FINE_USCITA], misurato con l'intensita' della sagoma contro
  la scena vuota e guardato sui fotogrammi), con `fine_uscita` nel manifesto:
  l'app chiude con la dissolvenza di 0,5 s sulla scena vuota, come gli altri
  cinque.
- `manifesto_viaggio_v2.json`: quello della v1 con `versione: 2`, il pezzo
  `volta` per ogni animale e i pezzi nuovi al posto dei vecchi; i file che non
  cambiano restano i `_v1` gia' pubblicati.
- `_collaudo/`: per ogni pezzo volta un foglio di 16 fotogrammi e la misura
  del primo e dell'ultimo contro la posa; i fogli della fine delle uscite e
  dell'inizio dell'arrivo del Cervo; `rapporto_v2.txt`.

Stessa codifica dei pezzi v1 (tool/gli_asset_dell_ordine_fz.py): libx264 High,
preset slow, crf 28, yuv420p, faststart, 1080x1920, 24 fps, aac 96k 48 kHz
stereo, e gli stessi segni di colore della sorgente.

Uso: python tool/gli_asset_del_viaggio_v2.py
"""
import hashlib
import json
import os
import subprocess

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageStat

RADICE_ASSET = r'D:\Clienti Roogly\Rituali Cartomanzia\App\Viaggio Sciamano Animali'
PRONTI_V1 = os.path.join(RADICE_ASSET, '_pronti')
PRONTI = os.path.join(RADICE_ASSET, '_pronti_v2')
COLLAUDO = os.path.join(PRONTI, '_collaudo')

LARGO, ALTO, FPS = 1080, 1920, 24
QUADRO = LARGO * ALTO * 3 // 2  # un fotogramma yuv420p

# **DOVE L'ANIMALE HA GIRATO IL CAPO O IL CORPO**, misurato sui fotogrammi
# (fogli fotogramma per fotogramma e scarto del capo e delle zampe contro la
# posa, 20 ottobre 2026). Per gli uccelli e il Serpente il corpo si volta
# tutto e la schiena (o il dorso del cappuccio) guarda chi legge, prima che
# le ali si aprano. Per gli animali di terra il capo si volta di lato e il
# punto e' l'ultimo fotogramma prima che una zampa si stacchi da terra: oltre,
# al contrario si vedrebbe il passo indietro.
VOLTA = {
    'Aquila': 187,     # 191 le ali si aprono
    'Cavallo': 169,    # 170 l'anteriore destro si alza
    'Cervo': 169,      # 170-171 l'anteriore destro si piega
    'Corvo': 188,      # 191 le ali si aprono
    'Falco': 188,      # 191 si accuccia per il volo
    'Gufo': 188,       # 191 le ali si aprono
    'Lince': 166,      # 166 la zampa destra comincia ad alzarsi: vedi rapporto
    'Lupo': 168,       # 169 l'anteriore sinistro si alza
    'Orso': 170,       # 171 l'anteriore si alza
    'Serpente': 186,   # il dorso del cappuccio verso chi legge
    'Tartaruga': 145,  # 146 la zampa anteriore si muove
    'Volpe': 169,      # 170 l'anteriore sinistro si piega: vedi rapporto
}
FERMO = 6       # fotogrammi fermi sul punto girato, un quarto di secondo
RACCORDO = 4    # fotogrammi di fusione con la posa, in testa e in coda

# D3: l'arrivo del Cervo comincia dal fotogramma 3.
ARRIVO_DA = {'Cervo': 3}

# D4: l'ultimo fotogramma dell'uscita prima che l'animale diventi trasparente.
FINE_USCITA = {
    'Cavallo': 221,   # 222-223 comincia a schiarire
    'Cervo': 227,     # 228-230 comincia a schiarire
    'Lince': 229,     # 231 comincia a schiarire
    'Lupo': 230,      # 232 comincia a schiarire
    'Orso': 222,      # 223-224 comincia a schiarire
    'Serpente': 229,  # 230-231 comincia a schiarire
    'Volpe': 231,     # 232 comincia a schiarire
}

ANIMALI = [
    'Aquila', 'Cavallo', 'Cervo', 'Corvo', 'Falco', 'Gufo', 'Lince', 'Lupo',
    'Orso', 'Serpente', 'Tartaruga', 'Volpe',
]
UCCELLI = {'Aquila', 'Corvo', 'Falco', 'Gufo'}

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


def livelli_audio(video):
    """Il livello in dB a decimi di secondo, mono 16 kHz."""
    grezzo = subprocess.run([
        'ffmpeg', '-loglevel', 'error', '-i', video, '-vn', '-ac', '1',
        '-ar', '16000', '-f', 's16le', '-',
    ], check=True, capture_output=True).stdout
    a = np.frombuffer(grezzo, dtype=np.int16).astype(np.float64)
    passo = 1600
    return [20 * np.log10(np.sqrt((a[i:i + passo] ** 2).mean()) + 1e-9) - 90.3
            for i in range(0, len(a) - passo + 1, passo)]


def tratto_quieto(livelli, durata_s):
    """Il tratto della durata data col livello massimo piu' basso: l'ambiente
    del bosco, senza passi, ali o versi."""
    n = int(np.ceil(durata_s * 10))
    migliore = None
    for i in range(0, len(livelli) - n + 1):
        picco = max(livelli[i:i + n])
        if migliore is None or picco < migliore[1]:
            migliore = (i, picco)
    da = migliore[0] / 10.0
    return da, da + durata_s, migliore[1]


def codifica_da_yuv(quadri, video_audio, audio_da, audio_a, uscita):
    """Scrive [quadri] (yuv420p) con l'audio [audio_da, audio_a) di
    [video_audio], con la codifica dei pezzi v1.

    **L'ULTIMO FOTOGRAMMA E' UN FOTOGRAMMA CHIAVE**: e' quello su cui l'app
    resta ferma, sopra la posa. Codificato come gli altri (B o P) scartava
    5,4-6,4 su 255 dalla posa contro i 3,5 del primo, che e' chiave."""
    proc = subprocess.Popen([
        'ffmpeg', '-y', '-loglevel', 'error',
        '-f', 'rawvideo', '-pix_fmt', 'yuv420p', '-s', '%dx%d' % (LARGO, ALTO),
        '-r', str(FPS), '-i', '-',
        '-i', video_audio,
        '-filter_complex',
        '[1:a]atrim=start=%.4f:end=%.4f,asetpts=PTS-STARTPTS[a]' % (
            audio_da, audio_a),
        '-map', '0:v', '-map', '[a]', *CODIFICA_VIDEO,
        '-force_key_frames', 'expr:eq(n,%d)' % (len(quadri) - 1), uscita,
    ], stdin=subprocess.PIPE)
    for q in quadri:
        proc.stdin.write(q.tobytes())
    proc.stdin.close()
    assert proc.wait() == 0, uscita


def taglia(video, da_fotogramma, a_fotogramma, uscita):
    """Un pezzo compiuto, da [da_fotogramma] a [a_fotogramma] incluso, col
    filtro trim per indice (mai -ss sul file codificato), l'audio dello
    stesso tratto."""
    subprocess.run([
        'ffmpeg', '-y', '-loglevel', 'error', '-i', video,
        '-vf', 'trim=start_frame=%d:end_frame=%d,setpts=PTS-STARTPTS' % (
            da_fotogramma, a_fotogramma + 1),
        '-af', 'atrim=start=%.4f:end=%.4f,asetpts=PTS-STARTPTS' % (
            da_fotogramma / FPS, (a_fotogramma + 1) / FPS),
        *CODIFICA_VIDEO, uscita,
    ], check=True)


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


def scarto_medio(a_path, b_path):
    """Lo scarto medio per canale, su 255."""
    a = Image.open(a_path).convert('RGB')
    b = Image.open(b_path).convert('RGB')
    if a.size != b.size:
        b = b.resize(a.size)
    return sum(ImageStat.Stat(ImageChops.difference(a, b)).mean) / 3


def foglio(video, numeri, etichette, uscita, colonne=8, larghezza=240):
    """Un foglio coi fotogrammi [numeri] di [video], con le etichette."""
    celle = []
    for n, etichetta in zip(numeri, etichette):
        png = uscita + '.tmp.png'
        fotogramma_png(video, n, png)
        im = Image.open(png).convert('RGB')
        im = im.resize((larghezza, int(im.size[1] * larghezza / im.size[0])))
        os.remove(png)
        d = ImageDraw.Draw(im)
        d.rectangle((0, 0, 7 * len(etichetta) + 6, 14), fill=(0, 0, 0))
        d.text((3, 1), etichetta, fill=(255, 220, 0))
        celle.append(im)
    w, h = celle[0].size
    righe = (len(celle) + colonne - 1) // colonne
    f = Image.new('RGB', (w * colonne, h * righe), (20, 20, 20))
    for i, c in enumerate(celle):
        f.paste(c, ((i % colonne) * w, (i // colonne) * h))
    f.save(uscita, quality=88)


def voce_di(percorso, **altro):
    return {
        'file': os.path.basename(percorso),
        'byte': os.path.getsize(percorso),
        'sha256': sha256(percorso),
        **altro,
    }


def pezzo_volta(animale, tagli, video, righe):
    nome = animale.lower()
    posa_n = tagli['arrivo_si_avvicina']['a_fotogramma']
    da = tagli['uscita_si_allontana']['da_fotogramma']
    fino = VOLTA[animale]
    avanti = fotogrammi_yuv(video, da, fino)
    posa = fotogrammi_yuv(video, posa_n, posa_n)[0].astype(np.float32)
    # Avanti, fermo sul punto girato, poi lo stesso tratto al contrario.
    quadri = avanti + [avanti[-1]] * FERMO + avanti[-2::-1]
    origine = (list(range(da, fino + 1)) + [fino] * FERMO
               + list(range(fino - 1, da - 1, -1)))
    # Il raccordo con la posa: il primo e l'ultimo fotogramma SONO la posa.
    quadri = [q.copy() for q in quadri]
    for k in range(RACCORDO):
        peso = 1.0 - k / RACCORDO
        for i in (k, len(quadri) - 1 - k):
            q = quadri[i].astype(np.float32)
            quadri[i] = np.clip(np.rint(peso * posa + (1 - peso) * q), 0,
                                255).astype(np.uint8)
    durata = len(quadri) / FPS
    audio_da, audio_a, picco = tratto_quieto(livelli_audio(video), durata)
    dest = os.path.join(PRONTI, '%s_volta_v2.mp4' % nome)
    codifica_da_yuv(quadri, video, audio_da, audio_a, dest)
    n = conta_fotogrammi(dest)
    assert n == len(quadri), '%s: %d fotogrammi invece di %d' % (
        dest, n, len(quadri))

    # La misura: il primo e l'ultimo fotogramma del pezzo contro la posa
    # (l'immagine che l'app tiene sotto, `<animale>_posa_v1.webp`) e contro il
    # fotogramma di posa della sorgente decodificato allo stesso modo.
    posa_webp = os.path.join(PRONTI_V1, '%s_posa_v1.webp' % nome)
    posa_png = os.path.join(COLLAUDO, '%s_posa_sorgente.png' % nome)
    fotogramma_png(video, posa_n, posa_png)
    misure = {}
    for chi, i in (('primo', 0), ('ultimo', n - 1)):
        png = os.path.join(COLLAUDO, '%s_volta_%s.png' % (nome, chi))
        fotogramma_png(dest, i, png)
        misure[chi] = (scarto_medio(png, posa_webp), scarto_medio(png, posa_png))
    # Senza raccordo il pezzo partirebbe dal fotogramma dell'uscita: quanto
    # differiva dalla posa.
    uscita_png = os.path.join(COLLAUDO, '%s_uscita_primo_sorgente.png' % nome)
    fotogramma_png(video, da, uscita_png)
    senza = scarto_medio(uscita_png, posa_webp)
    # Le catture a piena risoluzione pesano tre megabyte l'una: la misura e'
    # nel rapporto e nel manifesto, il foglio qui sotto resta.
    for png in (posa_png, uscita_png, *(
            os.path.join(COLLAUDO, '%s_volta_%s.png' % (nome, chi))
            for chi in ('primo', 'ultimo'))):
        os.remove(png)

    numeri = [round(i * (n - 1) / 15) for i in range(16)]
    etichette = []
    for i in numeri:
        e = 'n%d f%d' % (i, origine[i])
        if i < RACCORDO or i >= n - RACCORDO:
            e += '+posa'
        etichette.append(e)
    foglio(dest, numeri, etichette,
           os.path.join(COLLAUDO, '%s_volta_foglio.jpg' % nome))

    righe.append('  volta: fotogrammi %d->%d, fermo %d, %d->%d; %d fotogrammi, '
                 '%.3f s, %d byte' % (da, fino, FERMO, fino - 1, da, n, durata,
                                      os.path.getsize(dest)))
    righe.append('    primo contro la posa: %.2f/255 (webp) %.2f/255 (sorgente); '
                 'ultimo: %.2f/255 (webp) %.2f/255 (sorgente); senza raccordo il '
                 'primo sarebbe stato %.2f/255' % (
                     misure['primo'][0], misure['primo'][1],
                     misure['ultimo'][0], misure['ultimo'][1], senza))
    righe.append('    audio: ambiente da %.1f s a %.1f s del filmato, picco '
                 '%.1f dB' % (audio_da, audio_a, picco))
    return voce_di(dest, da_fotogramma=da, a_fotogramma=fino, fermo=FERMO,
                   raccordo_con_la_posa=RACCORDO,
                   audio={'da_s': round(audio_da, 2), 'a_s': round(audio_a, 2),
                          'picco_db': round(picco, 1)},
                   scarto_primo_dalla_posa=round(misure['primo'][0], 2),
                   scarto_ultimo_dalla_posa=round(misure['ultimo'][0], 2))


def main():
    os.makedirs(PRONTI, exist_ok=True)
    os.makedirs(COLLAUDO, exist_ok=True)
    with open(os.path.join(PRONTI_V1, 'manifesto_viaggio_v1.json'),
              encoding='utf-8') as fh:
        v1 = json.load(fh)
    manifesto = {'versione': 2, 'animali': {}}
    righe = ['GLI ASSET DEL VIAGGIO v2, generato da '
             'tool/gli_asset_del_viaggio_v2.py', '']

    for animale in ANIMALI:
        nome = animale.lower()
        cartella = os.path.join(RADICE_ASSET, animale)
        with open(os.path.join(cartella, '%s_tagli_v1.json' % nome),
                  encoding='utf-8') as fh:
            tagli = json.load(fh)
        video = os.path.join(cartella, '%s_il_cammino_v1.mp4' % nome)
        voce = json.loads(json.dumps(v1['animali'][nome]))
        righe.append('== %s' % animale)

        voce['pezzi']['volta'] = pezzo_volta(animale, tagli, video, righe)

        if animale in ARRIVO_DA:
            t = tagli['arrivo_si_avvicina']
            dest = os.path.join(PRONTI, '%s_arrivo_v2.mp4' % nome)
            taglia(video, ARRIVO_DA[animale], t['a_fotogramma'], dest)
            voce['pezzi']['arrivo'] = voce_di(
                dest, da_fotogramma=ARRIVO_DA[animale],
                a_fotogramma=t['a_fotogramma'])
            foglio(dest, list(range(0, 8)), ['n%d f%d' % (i, i + ARRIVO_DA[
                animale]) for i in range(8)],
                os.path.join(COLLAUDO, '%s_arrivo_inizio.jpg' % nome))
            righe.append('  arrivo (D3): fotogrammi %d-%d, %d byte' % (
                ARRIVO_DA[animale], t['a_fotogramma'], os.path.getsize(dest)))

        if animale in FINE_USCITA:
            t = tagli['uscita_si_allontana']
            fine = FINE_USCITA[animale]
            dest = os.path.join(PRONTI, '%s_uscita_v2.mp4' % nome)
            taglia(video, t['da_fotogramma'], fine, dest)
            voce['pezzi']['uscita'] = voce_di(
                dest, da_fotogramma=t['da_fotogramma'], a_fotogramma=fine)
            voce['fine_uscita'] = (
                "il video dopo il fotogramma %d NON si usa: l'animale diventa "
                "trasparente sul sentiero. Al fotogramma %d l'app chiude con "
                "una dissolvenza di 0,5 s sulla scena vuota." % (fine, fine))
            voce['scena_vuota'] = '00_SCENA_ULTIMO.jpg'
            n = fine - t['da_fotogramma'] + 1
            foglio(dest, list(range(n - 8, n)), [
                'n%d f%d' % (i, i + t['da_fotogramma'])
                for i in range(n - 8, n)],
                os.path.join(COLLAUDO, '%s_uscita_fine.jpg' % nome))
            righe.append('  uscita (D4): fotogrammi %d-%d, %d byte' % (
                t['da_fotogramma'], fine, os.path.getsize(dest)))

        manifesto['animali'][nome] = voce
        righe.append('')

    with open(os.path.join(PRONTI, 'manifesto_viaggio_v2.json'), 'w',
              encoding='utf-8', newline='\n') as fh:
        json.dump(manifesto, fh, ensure_ascii=False, indent=1)
    with open(os.path.join(COLLAUDO, 'rapporto_v2.txt'), 'w',
              encoding='utf-8', newline='\n') as fh:
        fh.write('\n'.join(righe) + '\n')
    print('\n'.join(righe))


if __name__ == '__main__':
    main()

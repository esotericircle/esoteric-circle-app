"""GLI ASSET DELL'ORDINE FV, voci FV.01 e FV.02, 15 ottobre 2026.

Porta nel ramo i file consegnati dal fondatore per il Calendario Lunare
Personale, l'Almanacco di Medora:
D:\\Clienti Roogly\\Rituali Cartomanzia\\App\\Calendario Lunare Scena\\ (P1,
sette file) e la sua sottocartella Elementi\\ (P2, venticinque pezzi; i
quattro fogli originali foglio_*.jpg restano fuori, come dice l'ordine).

- Le immagini diventano WebP alla stessa misura, qualita' 88 (quella di
  tool/gli_asset_dell_ordine_fu.py e di tool/converti_webp.py), senza
  ritocchi di colore. I PNG con la trasparenza la tengono: il canale alfa
  si scrive senza perdita (alpha_quality 100) e lo script verifica, file per
  file, che i pixel trasparenti siano gli stessi prima e dopo.
- Le tre luci (luce_alone_oro_v1, luce_scia_oro_v1, seme_di_luce_v1) sono RGB
  su fondo nero, da posare in fusione schermo: restano RGB. Lo script le
  posa in fusione schermo sull'ultimo fotogramma della scena e misura che il
  fondo nero non lasci un riquadro: lo scarto fra la scena e la composizione
  sul bordo del riquadro della luce.
- Lo sfondo della card entra dal JPG, come dice l'ordine. Il PNG con lo
  stesso nome, consegnato in piu', non entra: lo script scrive cosa contiene.
- Il video si ricomprime col metodo dell'ordine FU voce FU.12: H.264 profilo
  high a qualita' costante 26, preset slow, yuv420p, faststart, alla misura
  d'origine 1080 per 1920. La scena suona, l'audio resta, AAC 96 kbps.
  Peso prima e dopo, impronta SHA-256, lo stesso fotogramma a 4 secondi
  prima e dopo con lo scarto medio, e lo scarto fra l'ultimo fotogramma del
  video ricompresso e lunario_ultimo_fotogramma_v1 (ordine FS voce A2).
- Il velo che Medora regge (voce FV.02) si misura sull'ultimo fotogramma:
  i due fili di luce verticali che lo chiudono a destra e a sinistra, colonna
  e altezza, e una cattura di controllo che lo disegna accanto al rettangolo
  dell'Architetto.

Tutte le misure in docs/collaudo/FV/fv01_asset.txt, le catture accanto.

Uso: python tool/gli_asset_dell_ordine_fv.py
"""
import hashlib
import io
import os
import shutil
import subprocess
import tempfile

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageStat

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ORIGINE = r'D:\Clienti Roogly\Rituali Cartomanzia\App\Calendario Lunare Scena'
ELEMENTI = os.path.join(ORIGINE, 'Elementi')
IMMAGINI = os.path.join(RADICE, 'assets', 'img', 'calendario_lunare')
VIDEO = os.path.join(RADICE, 'brand_assets', 'calendario_lunare')
COLLAUDO = os.path.join(RADICE, 'docs', 'collaudo', 'FV')

FILMATO = 'medora_almanacco_di_luce_v1.mp4'
ULTIMO = 'lunario_ultimo_fotogramma_v1.jpg'
LUCI = ('luce_alone_oro_v1.png', 'luce_scia_oro_v1.png', 'seme_di_luce_v1.png')
FUORI = ('foglio_emblemi_a_v1.jpg', 'foglio_emblemi_b_v1.jpg',
         'foglio_sigilli_v1.jpg', 'foglio_luci_v1.jpg',
         'card_mese_sfondo_v1.png')

# Il rettangolo dell'Architetto, in frazioni del fotogramma (ordine FV voce
# FV.02): dal 21 al 78 per cento della larghezza, dal 19 al 64 dell'altezza.
VELO_ARCHITETTO = (0.21, 0.19, 0.78, 0.64)


def sha256(p):
    h = hashlib.sha256()
    with open(p, 'rb') as f:
        for blocco in iter(lambda: f.read(1 << 20), b''):
            h.update(blocco)
    return h.hexdigest()


def scarto(a, b):
    """Lo scarto medio assoluto fra due immagini RGB, in livelli su 255."""
    return sum(ImageStat.Stat(ImageChops.difference(
        a.convert('RGB'), b.convert('RGB'))).mean) / 3


def fotogramma(video, istante, uscita):
    subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-ss', str(istante),
                    '-i', video, '-frames:v', '1', uscita], check=True)


def ultimo_fotogramma(video, uscita):
    # -update 1 riscrive lo stesso file a ogni fotogramma: resta l'ultimo.
    subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-sseof', '-0.5',
                    '-i', video, '-update', '1', uscita], check=True)


def converti(sorgente, nome, righe):
    im = Image.open(sorgente)
    dest = os.path.join(IMMAGINI, os.path.splitext(nome)[0] + '.webp')
    if im.mode == 'RGBA':
        im.save(dest, 'WEBP', quality=88, alpha_quality=100, method=6)
        prima = np.asarray(im.getchannel('A'))
        dopo = np.asarray(Image.open(dest).getchannel('A'))
        trasparenti = int((prima == 0).sum())
        diversi = int((prima != dopo).sum())
        assert Image.open(dest).mode == 'RGBA', dest
        assert diversi == 0, '%s: alfa cambiato in %d pixel' % (dest, diversi)
        nota = 'RGBA, alfa identico (%d pixel trasparenti, 0 cambiati)' % (
            trasparenti)
    else:
        im = im.convert('RGB')
        im.save(dest, 'WEBP', quality=88, method=6)
        nota = 'RGB'
    righe.append('%s %dx%d %s: %d byte -> %d byte WebP' % (
        nome, im.width, im.height, nota, os.path.getsize(sorgente),
        os.path.getsize(dest)))


def schermo(sotto, luce):
    """La fusione schermo: 1 - (1 - a)(1 - b)."""
    a = sotto.astype(np.float64) / 255
    b = luce.astype(np.float64) / 255
    return (1 - (1 - a) * (1 - b)) * 255


def luci_in_fusione_schermo(scena, righe):
    base = np.asarray(scena.convert('RGB')).astype(np.float64)
    H, W, _ = base.shape
    tavola = base.copy()
    righe.append('== Le tre luci in fusione schermo sull\'ultimo fotogramma')
    for i, nome in enumerate(LUCI):
        luce = np.asarray(Image.open(os.path.join(IMMAGINI, nome[:-4] +
                                                  '.webp')).convert('RGB'))
        h, w, _ = luce.shape
        # Al centro del velo, una sotto l'altra, dove la scena e' chiara e
        # un riquadro scuro si vedrebbe di piu'.
        x0 = W // 2 - w // 2
        y0 = 360 + i * 520
        sotto = base[y0:y0 + h, x0:x0 + w]
        sopra = schermo(sotto, luce)
        tavola[y0:y0 + h, x0:x0 + w] = sopra
        diff = np.abs(sopra - sotto).mean(axis=2)
        bordo = np.concatenate([diff[0], diff[-1], diff[:, 0], diff[:, -1]])
        fascia = np.concatenate([diff[:4].ravel(), diff[-4:].ravel(),
                                 diff[:, :4].ravel(), diff[:, -4:].ravel()])
        cornice = luce.max(axis=2)
        cornice = np.concatenate([cornice[0], cornice[-1], cornice[:, 0],
                                  cornice[:, -1]])
        righe.append(
            '%s %dx%d posata a (%d, %d): scarto fra scena e composizione sul '
            'bordo del riquadro media %.3f massimo %.2f su 255, sulla fascia '
            'di 4 pixel media %.3f; il canale piu\' alto del bordo della luce '
            'vale al massimo %d su 255; dentro, scarto medio %.2f' % (
                nome, w, h, x0, y0, bordo.mean(), bordo.max(), fascia.mean(),
                int(cornice.max()), diff.mean()))
    out = os.path.join(COLLAUDO, 'fv01_luci_in_fusione_schermo.png')
    Image.fromarray(np.clip(tavola, 0, 255).astype(np.uint8)).save(out)
    righe.append('cattura: docs/collaudo/FV/' + os.path.basename(out))
    righe.append('')


def misura_il_velo(scena, righe):
    """I due fili di luce verticali che chiudono il velo."""
    g = np.asarray(scena.convert('L')).astype(np.float64)
    H, W = g.shape
    profilo = g[550:800].mean(axis=0)
    fili = []
    for x in range(150, W - 150):
        if profilo[x] > profilo[x - 6] + 15 and profilo[x] > profilo[x + 6] + 15:
            fili.append(x)
    sinistri = [x for x in fili if x < W // 2]
    destri = [x for x in fili if x > W // 2]
    xs = int(round(sum(sinistri) / len(sinistri)))
    xd = int(round(sum(destri) / len(destri)))
    estensioni = []
    for xc in (xs, xd):
        acceso = []
        for y in range(150, 1400):
            c = g[y, xc - 4:xc + 5].max()
            n = (g[y, xc - 14] + g[y, xc + 14]) / 2
            acceso.append(c - n > 20)
        ys = [y + 150 for y, a in enumerate(acceso) if a]
        tratti, s, p = [], ys[0], ys[0]
        for y in ys[1:]:
            if y - p > 15:
                tratti.append((s, p))
                s = y
            p = y
        tratti.append((s, p))
        # Il filo e' il tratto lungo; i tratti staccati di poco sopra o sotto
        # (buchi fino a 80 pixel) gli appartengono.
        tratti.sort(key=lambda t: t[1] - t[0], reverse=True)
        a, b = tratti[0]
        for t in sorted(tratti[1:]):
            if t[1] - t[0] >= 8 and (a - t[1] <= 80 and t[1] < a or
                                     t[0] - b <= 80 and t[0] > b):
                a, b = min(a, t[0]), max(b, t[1])
        estensioni.append((a, b))
    # Il velo e' cio' che i due fili chiudono insieme: dalla riga in cui
    # sono accesi tutti e due a quella in cui lo sono ancora tutti e due. Il
    # tratto del filo destro sopra quello sinistro passa davanti al viso di
    # Medora e non fa parte del velo (cattura di controllo).
    alto = max(e[0] for e in estensioni)
    basso = min(e[1] for e in estensioni)
    velo = (xs, alto, xd + 1, basso + 1)
    righe.append('== Il velo sull\'ultimo fotogramma (%dx%d)' % (W, H))
    righe.append('filo sinistro: colonna %d, dalla riga %d alla %d' % (
        xs, estensioni[0][0], estensioni[0][1]))
    righe.append('filo destro: colonna %d, dalla riga %d alla %d' % (
        xd, estensioni[1][0], estensioni[1][1]))
    righe.append('velo misurato: Rect.fromLTRB(%d, %d, %d, %d), dal %.1f al '
                 '%.1f per cento della larghezza, dal %.1f al %.1f per cento '
                 'dell\'altezza' % (velo + (100 * velo[0] / W,
                                             100 * velo[2] / W,
                                             100 * velo[1] / H,
                                             100 * velo[3] / H)))
    va = VELO_ARCHITETTO
    righe.append('velo dell\'Architetto: Rect.fromLTRB(%.1f, %.1f, %.1f, %.1f)'
                 % (va[0] * W, va[1] * H, va[2] * W, va[3] * H))
    disegno = scena.convert('RGB').copy()
    d = ImageDraw.Draw(disegno)
    d.rectangle(velo, outline=(255, 215, 0), width=5)
    d.rectangle((va[0] * W, va[1] * H, va[2] * W, va[3] * H),
                outline=(255, 60, 60), width=3)
    out = os.path.join(COLLAUDO, 'fv02_il_velo_misurato.png')
    disegno.save(out)
    righe.append('cattura di controllo: docs/collaudo/FV/%s (oro: il velo '
                 'misurato; rosso: il rettangolo dell\'Architetto)' %
                 os.path.basename(out))
    righe.append('')
    return velo


def main():
    os.makedirs(IMMAGINI, exist_ok=True)
    os.makedirs(VIDEO, exist_ok=True)
    os.makedirs(COLLAUDO, exist_ok=True)
    righe = ['GLI ASSET DELL\'ORDINE FV, generato da '
             'tool/gli_asset_dell_ordine_fv.py', '']

    righe.append('== P1, Calendario Lunare Scena')
    for f in sorted(os.listdir(ORIGINE)):
        if f.lower().endswith('.jpg'):
            converti(os.path.join(ORIGINE, f), f, righe)
    righe.append('')
    righe.append('== P2, Elementi (fuori: %s)' % ', '.join(FUORI))
    pezzi = 0
    for f in sorted(os.listdir(ELEMENTI)):
        if f in FUORI or not f.lower().endswith(('.png', '.jpg')):
            continue
        converti(os.path.join(ELEMENTI, f), f, righe)
        pezzi += 1
    righe.append('pezzi di P2 nel ramo: %d' % pezzi)
    righe.append('')

    # Il PNG dello sfondo della card, in piu' rispetto all'ordine.
    png = Image.open(os.path.join(ELEMENTI, 'card_mese_sfondo_v1.png'))
    jpg = Image.open(os.path.join(ELEMENTI, 'card_mese_sfondo_v1.jpg'))
    alfa = np.asarray(png.getchannel('A'))
    righe.append('== card_mese_sfondo_v1.png, consegnato in piu\' e lasciato '
                 'fuori')
    righe.append(
        '%dx%d %s, %d byte; alfa da %d a %d: pixel con alfa 0 %d, con alfa '
        'sotto 255 %d (%.2f per cento), con alfa 255 %d; riquadro dei pixel '
        'non opachi %s; scarto medio dei colori dal JPG %.2f su 255' % (
            png.width, png.height, png.mode,
            os.path.getsize(os.path.join(ELEMENTI, 'card_mese_sfondo_v1.png')),
            alfa.min(), alfa.max(), int((alfa == 0).sum()),
            int((alfa < 255).sum()), 100 * (alfa < 255).mean(),
            int((alfa == 255).sum()),
            Image.fromarray((alfa < 255).astype(np.uint8) * 255).getbbox(),
            scarto(png.convert('RGB'), jpg)))
    ys, xs = np.nonzero(alfa < 255)
    angolo = ((np.minimum(ys, png.height - 1 - ys) < 40) &
              (np.minimum(xs, png.width - 1 - xs) < 40))
    righe.append('pixel non opachi dentro i quattro angoli di 40 pixel: %d '
                 'su %d' % (int(angolo.sum()), len(ys)))
    media_png = np.asarray(png.convert('RGB')).reshape(-1, 3).mean(axis=0)
    media_jpg = np.asarray(jpg.convert('RGB')).reshape(-1, 3).mean(axis=0)
    righe.append(
        'colore medio RGB del PNG (%.0f, %.0f, %.0f) contro quello del JPG '
        '(%.0f, %.0f, %.0f): il PNG e\' la tavola chiara, color madreperla, '
        'che il fondatore ha scartato ("Ma perche\' la tavola e\' bianca?"); '
        'il JPG e\' la tavola notturna che l\'ordine porta nel ramo. I pixel '
        'non opachi del PNG stanno negli angoli arrotondati.' % (
            tuple(media_png) + tuple(media_jpg)))
    confronto = Image.new('RGB', (768 * 2, 1376))
    confronto.paste(png.convert('RGB'), (0, 0))
    confronto.paste(jpg.convert('RGB'), (768, 0))
    confronto.resize((768, 688)).save(
        os.path.join(COLLAUDO, 'fv01_card_png_contro_jpg.png'))
    righe.append('cattura: docs/collaudo/FV/fv01_card_png_contro_jpg.png (a '
                 'sinistra il PNG lasciato fuori, a destra il JPG nel ramo)')
    righe.append('')

    # Il video.
    sorgente = os.path.join(ORIGINE, FILMATO)
    dest = os.path.join(VIDEO, FILMATO)
    subprocess.run([
        'ffmpeg', '-y', '-loglevel', 'error', '-i', sorgente,
        '-c:v', 'libx264', '-profile:v', 'high', '-preset', 'slow',
        '-crf', '26', '-pix_fmt', 'yuv420p', '-movflags', '+faststart',
        '-c:a', 'aac', '-b:a', '96k', dest], check=True)
    prima = os.path.join(COLLAUDO, 'fv02_fotogramma_4s_prima.png')
    dopo = os.path.join(COLLAUDO, 'fv02_fotogramma_4s_dopo.png')
    fotogramma(sorgente, 4, prima)
    fotogramma(dest, 4, dopo)
    righe.append('== FV.02, il video')
    righe.append(
        '%s: %d byte -> %d byte (%.2f MB -> %.2f MB), SHA-256 %s; fotogramma '
        'a 4 s prima e dopo, scarto medio %.2f su 255 (%s, %s)' % (
            FILMATO, os.path.getsize(sorgente), os.path.getsize(dest),
            os.path.getsize(sorgente) / 1e6, os.path.getsize(dest) / 1e6,
            sha256(dest), scarto(Image.open(prima), Image.open(dopo)),
            os.path.basename(prima), os.path.basename(dopo)))
    probe = subprocess.run(
        ['ffprobe', '-v', 'error', '-show_entries',
         'stream=codec_type,codec_name,width,height,r_frame_rate,nb_frames,'
         'duration,bit_rate', '-of', 'compact', dest],
        check=True, capture_output=True, text=True).stdout.strip()
    righe.extend(probe.splitlines())
    lavoro = tempfile.mkdtemp()
    try:
        fine_prima = os.path.join(lavoro, 'fine_prima.png')
        ultimo_fotogramma(sorgente, fine_prima)
        fine_dopo = os.path.join(COLLAUDO, 'fv02_ultimo_fotogramma_dopo.png')
        ultimo_fotogramma(dest, fine_dopo)
        immagine = Image.open(os.path.join(ORIGINE, ULTIMO))
        righe.append(
            'ultimo fotogramma contro %s: video d\'origine %.2f su 255, video '
            'ricompresso %.2f su 255 (docs/collaudo/FV/%s)' % (
                ULTIMO, scarto(Image.open(fine_prima), immagine),
                scarto(Image.open(fine_dopo), immagine),
                os.path.basename(fine_dopo)))
    finally:
        shutil.rmtree(lavoro, ignore_errors=True)
    righe.append('')

    scena = Image.open(os.path.join(ORIGINE, ULTIMO))
    misura_il_velo(scena, righe)
    luci_in_fusione_schermo(scena, righe)

    with io.open(os.path.join(COLLAUDO, 'fv01_asset.txt'), 'w',
                 encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(righe) + '\n')
    print('\n'.join(righe))


if __name__ == '__main__':
    main()

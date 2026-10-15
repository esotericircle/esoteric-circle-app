"""LE LUNE VERE, ordine FV voce FV.03, 15 ottobre 2026.

Scarica dallo Scientific Visualization Studio le trenta fotografie della
Luna scelte da tool/le_lune_della_nasa_scelta.dart (una per giorno lunare,
lunazione dal 10 ottobre al 9 novembre 2026), le scontorna sul disco della
Luna su fondo trasparente e scrive:
- assets/img/calendario_lunare/lune/luna_giorno_NN.webp, 512 per 512, il
  disco largo 508 pixel al centro, fuori dal disco alfa 0, il bordo morbido
  su un pixel e mezzo;
- lib/core/lunario/le_lune_della_nasa.g.dart, la tabella generata con
  percorso ed elongazione di ogni immagine (l'elongazione e' quella del
  motore del ramo, IlMotoreLunare.elongazione, calcolata dallo strumento
  Dart all'istante del fotogramma);
- docs/collaudo/FV/fv03_lune.txt con l'indirizzo, l'impronta SHA-256 e le
  misure di ogni file, e docs/collaudo/FV/fv03_le_trenta_lune.png, il
  foglio di controllo su fondo grigio (il grigio mostra il ritaglio).

La fonte: la serie "Moon Phase and Libration, 2026",
https://svs.gsfc.nasa.gov/5587/ (la pagina dell'anno di
https://svs.gsfc.nasa.gov/5612/), fotogrammi 730x730_1x1_30p, uno per ora
del 2026; il fotogramma N e' l'ora N meno 1 dal 1 gennaio 2026 00:00 UT, e
lo script lo verifica riga per riga su mooninfo_2026.json della stessa
pagina. Il nord celeste e' in alto (vista dall'emisfero nord).

IL DISCO. Nei fotogrammi il disco e' centrato e la sua misura segue il
diametro apparente (colonna diameter di mooninfo, in secondi d'arco).
La scala in pixel per secondo d'arco si tara sul fotogramma 72 (3 gennaio
2026 23:00 UT, Luna piena al 99,9 per cento): raggio dall'area del disco
acceso. Su ogni fotogramma scelto lo script misura poi quanta luce cade
fuori dal disco previsto (deve essere nulla) e confronta la frazione
accesa con la fase dichiarata da mooninfo.

I file scaricati stanno in una cartella temporanea nuova e vuota, cancellata
alla fine; lo script va lanciato con python -I.

Uso: dart run tool/le_lune_della_nasa_scelta.dart
     python -I tool/le_lune_della_nasa.py
"""
import hashlib
import io
import json
import math
import os
import shutil
import tempfile
import urllib.request

import numpy as np
from PIL import Image, ImageDraw

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
COLLAUDO = os.path.join(RADICE, 'docs', 'collaudo', 'FV')
LUNE = os.path.join(RADICE, 'assets', 'img', 'calendario_lunare', 'lune')
TABELLA = os.path.join(RADICE, 'lib', 'core', 'lunario',
                       'le_lune_della_nasa.g.dart')
BASE = 'https://svs.gsfc.nasa.gov/vis/a000000/a005500/a005587/'
FOTOGRAMMI = BASE + 'frames/730x730_1x1_30p/moon.%04d.jpg'
MOONINFO = BASE + 'mooninfo_2026.json'
TARATURA = 72
LATO = 512
DISCO = 508
MESI = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep',
        'Oct', 'Nov', 'Dec']


def scarica(url, dest):
    with urllib.request.urlopen(url, timeout=60) as r, open(dest, 'wb') as f:
        shutil.copyfileobj(r, f)
    return dest


def sha256(p):
    with open(p, 'rb') as f:
        return hashlib.sha256(f.read()).hexdigest()


def ora_di_mooninfo(iso):
    # '2026-10-11T04:00:00.000Z' -> '11 Oct 2026 04:00 UT'
    data, ora = iso.split('T')
    a, m, g = data.split('-')
    return '%s %s %s %s UT' % (g, MESI[int(m) - 1], a, ora[:5])


def main():
    with io.open(os.path.join(COLLAUDO, 'fv03_lune_scelte.json'),
                 encoding='utf-8') as f:
        scelta = json.load(f)
    os.makedirs(LUNE, exist_ok=True)
    lavoro = tempfile.mkdtemp(prefix='lune_svs_')
    righe = ['LE LUNE VERE, generato da tool/le_lune_della_nasa.py', '',
             'serie: %s, %s' % (scelta['serie'], scelta['pagina']),
             'lunazione: Luna nuova %s -> Luna nuova %s (ore UT del motore)' % (
                 scelta['luna_nuova_di_inizio_utc'],
                 scelta['luna_nuova_di_fine_utc']),
             'fotogrammi: %s' % (FOTOGRAMMI % 0).replace('0000', 'NNNN'),
             'dati della serie: %s' % MOONINFO, '']
    try:
        info = json.load(open(scarica(MOONINFO, os.path.join(
            lavoro, 'mooninfo_2026.json')), encoding='utf-8'))
        assert len(info) == 8760, len(info)

        # La taratura.
        t = np.asarray(Image.open(scarica(
            FOTOGRAMMI % TARATURA, os.path.join(lavoro, 'taratura.jpg')))
            .convert('L')).astype(np.float64)
        maschera = t > 30
        ys, xs = np.nonzero(maschera)
        raggio_t = math.sqrt(maschera.sum() / math.pi)
        cx, cy = xs.mean(), ys.mean()
        d_t = info[TARATURA - 1]['diameter']
        scala = 2 * raggio_t / d_t
        H, W = t.shape
        righe.append(
            'taratura sul fotogramma %d (%s, fase %.2f per cento, diametro '
            '%.1f"): raggio %.2f pixel, centro (%.2f, %.2f) contro il centro '
            'del fotogramma (%.1f, %.1f); scala %.5f pixel per secondo '
            'd\'arco' % (TARATURA, info[TARATURA - 1]['time'],
                          info[TARATURA - 1]['phase'], d_t, raggio_t, cx, cy,
                          (W - 1) / 2, (H - 1) / 2, scala))
        righe.append('')
        c0 = ((W - 1) / 2, (H - 1) / 2)

        voci = []
        foglio = Image.new('RGB', (6 * 180, 5 * 200), (70, 70, 74))
        disegno = ImageDraw.Draw(foglio)
        peggior_fuori = 0.0
        peggior_fase = 0.0
        for s in scelta['scelte']:
            k = s['giorno_lunare']
            n = s['fotogramma']
            riga = info[n - 1]
            assert riga['time'] == ora_di_mooninfo(s['istante_utc']), (
                n, riga['time'], s['istante_utc'])
            url = FOTOGRAMMI % n
            sorgente = scarica(url, os.path.join(lavoro, 'moon.%04d.jpg' % n))
            im = Image.open(sorgente).convert('RGB')
            a = np.asarray(im).astype(np.float64)
            r = riga['diameter'] * scala / 2
            yy, xx = np.mgrid[0:H, 0:W]
            dist = np.hypot(xx - c0[0], yy - c0[1])
            lum = a.mean(axis=2)
            acceso = lum > 30
            fuori = float((acceso & (dist > r + 1.5)).sum())
            dentro = float((dist <= r).sum())
            frazione = 100 * float((acceso & (dist <= r + 1.5)).sum()) / dentro
            peggior_fuori = max(peggior_fuori, fuori)
            peggior_fase = max(peggior_fase, abs(frazione - riga['phase']))

            # Il ritaglio quadrato attorno al disco, portato a LATO pixel
            # col disco largo DISCO; poi l'alfa del disco, calcolata alla
            # misura d'arrivo.
            mezzo = r * LATO / DISCO
            riquadro = (c0[0] - mezzo + 0.5, c0[1] - mezzo + 0.5,
                        c0[0] + mezzo + 0.5, c0[1] + mezzo + 0.5)
            quadrato = im.resize((LATO, LATO), Image.LANCZOS, box=riquadro)
            yo, xo = np.mgrid[0:LATO, 0:LATO]
            d = np.hypot(xo - (LATO - 1) / 2, yo - (LATO - 1) / 2)
            alfa = np.clip((DISCO / 2 + 0.75 - d) / 1.5, 0, 1)
            rgb = np.asarray(quadrato).astype(np.float64)
            rgb[alfa == 0] = 0
            rgba = np.dstack([rgb, alfa * 255]).round().astype(np.uint8)
            nome = 'luna_giorno_%02d.webp' % k
            dest = os.path.join(LUNE, nome)
            Image.fromarray(np.ascontiguousarray(rgba)).save(
                dest, 'WEBP', quality=88, alpha_quality=100, method=6)
            controllo = np.asarray(Image.open(dest).getchannel('A'))
            fuori_alfa = int((controllo[d > DISCO / 2 + 0.75] != 0).sum())
            assert fuori_alfa == 0, (nome, fuori_alfa)
            percorso = 'assets/img/calendario_lunare/lune/' + nome
            voci.append((percorso, s['elongazione'], n, s['istante_utc'], url))
            righe.append(
                'giorno %2d: %s, %s, elongazione dal motore %.3f gradi, fase '
                'di mooninfo %.2f per cento (dal motore %.2f), diametro '
                '%.1f", raggio %.1f pixel; frazione accesa misurata nel disco '
                '%.2f per cento; pixel accesi fuori dal disco %d; SHA-256 '
                'della fonte %s; %s %d byte, pixel fuori dal disco con alfa '
                'diversa da 0: %d' % (
                    k, url, riga['time'], s['elongazione'], riga['phase'],
                    s['illuminazione_dal_motore'], riga['diameter'], r,
                    frazione, int(fuori), sha256(sorgente), percorso,
                    os.path.getsize(dest), fuori_alfa))
            x = ((k - 1) % 6) * 180 + 10
            y = ((k - 1) // 6) * 200 + 10
            piccola = Image.open(dest).resize((160, 160), Image.LANCZOS)
            foglio.paste(piccola, (x, y), piccola)
            disegno.text((x + 70, y + 168), '%d' % k, fill=(230, 230, 230))
        righe.append('')
        righe.append('peggiore: pixel accesi fuori dal disco previsto %d; '
                     'scarto fra frazione accesa misurata e fase di mooninfo '
                     '%.2f punti percentuali' % (int(peggior_fuori),
                                                 peggior_fase))
        foglio.save(os.path.join(COLLAUDO, 'fv03_le_trenta_lune.png'))
        righe.append('foglio di controllo: docs/collaudo/FV/'
                     'fv03_le_trenta_lune.png')
    finally:
        shutil.rmtree(lavoro, ignore_errors=True)

    dart = [
        '// GENERATO da tool/le_lune_della_nasa.py, non si scrive a mano.',
        '//',
        '// Le trenta fotografie della Luna di una lunazione (Luna nuova del %s,'
        % scelta['luna_nuova_di_inizio_utc'][:10],
        '// Luna nuova seguente del %s), dalla serie "%s" dello' % (
            scelta['luna_nuova_di_fine_utc'][:10], scelta['serie']),
        '// Scientific Visualization Studio, %s, fotogrammi' % scelta['pagina'],
        '// 730x730 scontornati sul disco. Per ogni immagine: il percorso e',
        '// l\'elongazione Sole-Luna in gradi all\'istante della foto, calcolata',
        '// da IlMotoreLunare.elongazione (tool/le_lune_della_nasa_scelta.dart).',
        '// Nel commento il fotogramma, l\'istante in UT e l\'indirizzo del file.',
        '',
        '/// Le trenta lune vere, una per giorno lunare, in ordine di elongazione.',
        'const List<({String percorso, double elongazione})> leLuneDellaNasaGenerate =',
        '    [',
    ]
    for percorso, e, n, istante, url in voci:
        dart.append('  // fotogramma %d, %s, %s' % (n, istante, url))
        dart.append("  (percorso: '%s', elongazione: %.3f)," % (percorso, e))
    dart.append('];')
    with io.open(TABELLA, 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(dart) + '\n')
    with io.open(os.path.join(COLLAUDO, 'fv03_lune.txt'), 'w',
                 encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(righe) + '\n')
    print('\n'.join(righe))


if __name__ == '__main__':
    main()

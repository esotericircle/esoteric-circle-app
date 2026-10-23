"""LA COLLANA V2, l'ovale intero. Ordine FY voce FY.08, 16 ottobre 2026.

Il fondatore: "La collana della luna è tagliata ai lati"; poi le due pitture
nuove, "con l'ovale intero": collana_nello_scrigno_spenta_v2.jpg e
collana_nello_scrigno_accesa_v2.jpg (1438x2576, identiche fuori dalle perle),
e le posizioni in le_perle_della_collana_v2.json: 30 giorni, 2 perle del
compimento in fondo al centro, la medaglia che ora e' la Luna al centro
(x 720, y 1292, raggio della maschera 165). Le v1 restano solo come storico,
nella cartella del fondatore: nel ramo non le usa piu' nessuno e si tolgono.

Come per le v1 (tool/gli_asset_dell_aggiunta_fxa.py): le due pitture diventano
WebP qualita' 90 alla misura d'origine; ogni perla accesa e' un ritaglio
tondo della pittura accesa, opaco fino al raggio della perla e sfumato fino al
raggio della maschera (38 e 48 pixel; per la medaglia 155 e 165), WebP con
l'alfa senza perdita, riletto identico; la copia Dart delle posizioni si
rigenera. La prova: la collana con cinque perle accese e la collana completa
composte coi ritagli sulla pittura spenta, e lo scarto ai bordi dei ritagli.

Uso: python tool/gli_asset_della_collana_v2.py
"""
import glob
import io
import json
import os
import shutil

import numpy as np
from PIL import Image

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ORIGINE = r'D:\Clienti Roogly\Rituali Cartomanzia\App\Respiro della Luna Scena\Collana'
COLLANA = os.path.join(RADICE, 'assets', 'img', 'respiro_della_luna', 'collana')
PERLE = os.path.join(COLLANA, 'perle_accese')
COLLAUDO = os.path.join(RADICE, 'docs', 'collaudo', 'FY')
REGISTRO = os.path.join(COLLAUDO, 'fy08_collana_v2.txt')


def maschera(lato, raggio_pieno, raggio_fine):
    c = (lato - 1) / 2.0
    yy, xx = np.mgrid[0:lato, 0:lato]
    d = np.sqrt((xx - c) ** 2 + (yy - c) ** 2)
    return np.clip((raggio_fine - d) / float(raggio_fine - raggio_pieno), 0, 1)


def ritaglia(pittura, x, y, raggio_pieno, raggio_fine):
    lato = 2 * raggio_fine
    sx, sy = x - raggio_fine, y - raggio_fine
    pezzo = np.asarray(pittura.crop((sx, sy, sx + lato, sy + lato)).convert('RGB'))
    a = maschera(lato, raggio_pieno, raggio_fine)
    return Image.fromarray(np.dstack([pezzo, np.round(a * 255).astype(np.uint8)]), 'RGBA')


def posa(base, ritaglio, x, y, raggio_fine):
    out = base.copy()
    lato = 2 * raggio_fine
    sx, sy = x - raggio_fine, y - raggio_fine
    r = np.asarray(ritaglio, dtype=np.float64)
    a = r[:, :, 3:4] / 255.0
    out[sy:sy + lato, sx:sx + lato, :] = (
        r[:, :, :3] * a + out[sy:sy + lato, sx:sx + lato, :] * (1 - a))
    return out


def scrivi_le_posizioni_in_dart(p):
    rm = p['raggio_maschera']
    L = ['// GENERATO da tool/gli_asset_della_collana_v2.py dal file',
         '// assets/img/respiro_della_luna/collana/le_perle_della_collana_v2.json.',
         '// Non si modifica a mano: test/la_collana_dipinta_test.dart cade se i due',
         '// file non dicono la stessa cosa.',
         "part of 'la_collana_dipinta.dart';", '',
         'const double _larghezzaDellaPittura = %d;' % p['misura_immagine'][0],
         'const double _altezzaDellaPittura = %d;' % p['misura_immagine'][1],
         '', 'const List<PosizioneDellaPerla> _giorni = [']
    for g in p['giorni']:
        L.append('  PosizioneDellaPerla(%d, %d, %d), // giorno %d' % (g['x'], g['y'], rm, g['giorno']))
    L += ['];', '', 'const List<PosizioneDellaPerla> _compimento = [']
    for g in p['perle_del_compimento']:
        L.append('  PosizioneDellaPerla(%d, %d, %d),' % (g['x'], g['y'], rm))
    m = p['medaglia']
    L += ['];', '', 'const PosizioneDellaPerla _medaglia =',
          '    PosizioneDellaPerla(%d, %d, %d);' % (m['x'], m['y'], m['raggio_maschera'])]
    dst = os.path.join(RADICE, 'lib', 'features', 'respiro_della_luna', 'le_perle_della_collana.g.dart')
    io.open(dst, 'w', encoding='utf-8', newline='\n').write('\n'.join(L) + '\n')


def main():
    righe = []
    os.makedirs(PERLE, exist_ok=True)
    os.makedirs(COLLAUDO, exist_ok=True)

    # Via le v1 dal ramo: nessuna schermata le usa piu'.
    tolte = []
    for f in (glob.glob(os.path.join(COLLANA, '*_v1.webp')) + glob.glob(os.path.join(COLLANA, '*_v1.json'))
              + glob.glob(os.path.join(PERLE, '*_v1.webp'))):
        if os.path.basename(f) == 'perla_accesa_v1.webp':
            continue  # l'anello di luce del Respiro la usa ancora
        os.remove(f)
        tolte.append(os.path.relpath(f, RADICE).replace('\\', '/'))
    righe.append('tolti dal ramo i file v1 non piu usati: %d' % len(tolte))

    pitture = {}
    for stato in ('spenta', 'accesa'):
        nome = 'collana_nello_scrigno_%s_v2' % stato
        src = os.path.join(ORIGINE, nome + '.jpg')
        im = Image.open(src).convert('RGB')
        pitture[stato] = im
        dst = os.path.join(COLLANA, nome + '.webp')
        im.save(dst, 'WEBP', quality=90, method=6)
        righe.append('%s: %dx%d, da %d a %d byte' % (nome, im.width, im.height,
                                                     os.path.getsize(src), os.path.getsize(dst)))
    spenta = np.asarray(pitture['spenta'], dtype=np.float64)
    accesa = np.asarray(pitture['accesa'], dtype=np.float64)

    # L'ovale intero: argento chiaro sulle colonne di bordo.
    grigio = np.asarray(pitture['spenta'].convert('L'), dtype=np.float64)
    bordo = [int((grigio[:, x] > 110).sum()) for x in (0, 1, grigio.shape[1] - 2, grigio.shape[1] - 1)]
    righe.append('righe con argento chiaro sulle colonne di bordo (0, 1, 1436, 1437): %s '
                 '(la v1 ne aveva 40, 39, 45, 43)' % bordo)

    shutil.copyfile(os.path.join(ORIGINE, 'le_perle_della_collana_v2.json'),
                    os.path.join(COLLANA, 'le_perle_della_collana_v2.json'))
    p = json.load(io.open(os.path.join(ORIGINE, 'le_perle_della_collana_v2.json'), encoding='utf-8'))
    rp, rm = p['raggio_perla'], p['raggio_maschera']
    scrivi_le_posizioni_in_dart(p)

    voci = [('perla_giorno_%02d_v2' % g['giorno'], g['x'], g['y'], rp, rm) for g in p['giorni']]
    for i, c in enumerate(p['perle_del_compimento']):
        voci.append(('perla_compimento_%d_v2' % (i + 1), c['x'], c['y'], rp, rm))
    m = p['medaglia']
    voci.append(('medaglia_v2', m['x'], m['y'], m['raggio_maschera'] - (rm - rp), m['raggio_maschera']))
    ritagli = {}
    for nome, x, y, pieno, fine in voci:
        im = ritaglia(pitture['accesa'], x, y, pieno, fine)
        dst = os.path.join(PERLE, nome + '.webp')
        im.save(dst, 'WEBP', lossless=True, exact=True, method=6)
        assert (np.asarray(Image.open(dst).convert('RGBA')) == np.asarray(im)).all(), nome
        ritagli[nome] = (im, x, y, fine)
    righe.append('ritagli delle perle accese: %d (30 giorni, 2 del compimento, la Luna al centro), '
                 'WebP senza perdita, riletti identici' % len(voci))

    # Le prove composte: cinque perle, e la collana completa contro la pittura accesa.
    composta = spenta
    for g in range(1, 6):
        im, x, y, fine = ritagli['perla_giorno_%02d_v2' % g]
        composta = posa(composta, im, x, y, fine)
    Image.fromarray(np.round(composta).astype(np.uint8)).save(
        os.path.join(COLLAUDO, 'fy08_cinque_perle_v2.jpg'), quality=92)
    completa = spenta
    for nome, (im, x, y, fine) in ritagli.items():
        completa = posa(completa, im, x, y, fine)
    scarto = np.abs(completa - accesa)
    righe.append('collana completa composta contro la pittura accesa: scarto medio %.2f su 255 '
                 'sull\'immagine intera' % scarto.mean())
    anello = []
    for nome, x, y, pieno, fine in voci:
        lato = 2 * fine
        c = (lato - 1) / 2.0
        yy, xx = np.mgrid[0:lato, 0:lato]
        dd = np.sqrt((xx - c) ** 2 + (yy - c) ** 2)
        a = (dd >= fine) & (dd < fine + 6)
        sx, sy = x - fine, y - fine
        anello.append(np.abs(spenta[sy:sy + lato, sx:sx + lato] - accesa[sy:sy + lato, sx:sx + lato])[a].mean())
    righe.append('scarto fra le due pitture subito fuori dai ritagli (6 pixel): medio %.2f, massimo %.2f' % (
        np.mean(anello), np.max(anello)))

    with io.open(REGISTRO, 'w', encoding='utf-8', newline='\n') as f:
        f.write('Ordine FY voce FY.08, la collana v2 con l\'ovale intero, scritto da '
                'tool/gli_asset_della_collana_v2.py\n\n')
        for r in righe:
            f.write(r + '\n')
        f.write('\nfile v1 tolti:\n')
        for t in tolte:
            f.write('  ' + t + '\n')
    print('\n'.join(righe))


if __name__ == '__main__':
    main()

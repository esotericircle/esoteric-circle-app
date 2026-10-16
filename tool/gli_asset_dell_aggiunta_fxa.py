"""GLI ASSET DELL'AGGIUNTA FXA, la collana e i comandi dipinti, 16 ottobre 2026.

Il fondatore, sull'anteprima della collana composta dal codice: "Non avevo
chiesto di evitare grafica procedurale? [...] tutto quello si puo' fare con
nano banana o video". Qui entrano nel ramo le pitture nuove e i pezzi dei
comandi, e soprattutto si preparano UNA VOLTA, fuori dall'app, i ritagli delle
perle accese: il codice non compone nessuna figura, posa soltanto immagini
dipinte nella posizione misurata.

- Le due pitture dello scrigno (spenta e accesa, 1438x2576) diventano WebP
  qualita' 90 alla misura d'origine, in assets/img/respiro_della_luna/collana/,
  insieme al file delle posizioni le_perle_della_collana_v1.json, copiato
  com'e'.
- Ogni perla accesa e' un RITAGLIO TONDO della pittura accesa, centrato sul
  punto misurato del file: opaco fino al raggio della perla, sfumato in modo
  lineare fino a zero al raggio della maschera (40 e 48 pixel; per la medaglia
  72 e 80). Trenta giorni, le due perle del compimento e la medaglia, in
  assets/img/respiro_della_luna/collana/perle_accese/, WebP con l'alfa senza
  perdita. Nessun ritocco di colore: i pixel sono quelli della pittura.
- I pezzi dei comandi (pulsante largo, premuto, tondo, pannello, ago e filo)
  diventano WebP senza perdita con la trasparenza, in
  assets/img/respiro_della_luna/comandi/, e lo script verifica che ogni
  pixel resti identico.
- La prova: la collana con cinque perle accese (giorni 1-5) composta coi
  ritagli sulla pittura spenta, confrontata con la prova dell'Architetto
  (Lavoro/prova_composizione_cinque_perle.jpg), e lo scarto ai bordi dei
  ritagli, nell'anello fra raggio della perla e raggio della maschera, contro
  la pittura spenta e contro quella accesa.
- La cattura del fondatore entra in docs/collaudo/FX/catture_fondatore/.

Uso: python tool/gli_asset_dell_aggiunta_fxa.py
"""
import io
import json
import os
import shutil

import numpy as np
from PIL import Image

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ORIGINE = r'D:\Clienti Roogly\Rituali Cartomanzia\App\Respiro della Luna Scena'
COLLANA_SRC = os.path.join(ORIGINE, 'Collana')
COMANDI_SRC = os.path.join(ORIGINE, 'Comandi')
CATTURE_SRC = os.path.join(ORIGINE, 'Catture')
LAVORO = os.path.join(ORIGINE, 'Lavoro')

COLLANA = os.path.join(RADICE, 'assets', 'img', 'respiro_della_luna', 'collana')
PERLE = os.path.join(COLLANA, 'perle_accese')
COMANDI = os.path.join(RADICE, 'assets', 'img', 'respiro_della_luna', 'comandi')
COLLAUDO = os.path.join(RADICE, 'docs', 'collaudo', 'FX')
CATTURE_FONDATORE = os.path.join(COLLAUDO, 'catture_fondatore')
REGISTRO = os.path.join(COLLAUDO, 'fxa_asset.txt')

PEZZI_DEI_COMANDI = [
    'pulsante_largo_v1', 'pulsante_largo_premuto_v1', 'pulsante_tondo_v1',
    'pannello_v1', 'ago_e_filo_v1',
]


def maschera(lato, raggio_pieno, raggio_fine):
    """L'alfa del ritaglio: 1 fino a raggio_pieno, 0 da raggio_fine."""
    c = (lato - 1) / 2.0
    yy, xx = np.mgrid[0:lato, 0:lato]
    d = np.sqrt((xx - c) ** 2 + (yy - c) ** 2)
    a = np.clip((raggio_fine - d) / float(raggio_fine - raggio_pieno), 0, 1)
    return a


def ritaglia(pittura, x, y, raggio_pieno, raggio_fine):
    lato = 2 * raggio_fine
    sx, sy = x - raggio_fine, y - raggio_fine
    pezzo = np.asarray(pittura.crop((sx, sy, sx + lato, sy + lato)).convert('RGB'))
    a = maschera(lato, raggio_pieno, raggio_fine)
    rgba = np.dstack([pezzo, np.round(a * 255).astype(np.uint8)])
    return Image.fromarray(rgba, 'RGBA'), a


def posa(base, ritaglio, x, y, raggio_fine):
    """Posa il ritaglio sulla base come fa Flutter: miscela con l'alfa."""
    out = np.asarray(base, dtype=np.float64).copy()
    lato = 2 * raggio_fine
    sx, sy = x - raggio_fine, y - raggio_fine
    r = np.asarray(ritaglio, dtype=np.float64)
    a = r[:, :, 3:4] / 255.0
    out[sy:sy + lato, sx:sx + lato, :] = (
        r[:, :, :3] * a + out[sy:sy + lato, sx:sx + lato, :] * (1 - a))
    return out


def scrivi_le_posizioni_in_dart(posizioni):
    """La copia Dart del file delle posizioni, per la lettura sincrona."""
    rm = posizioni['raggio_maschera']
    L = ['// GENERATO da tool/gli_asset_dell_aggiunta_fxa.py dal file',
         '// assets/img/respiro_della_luna/collana/le_perle_della_collana_v1.json.',
         '// Non si modifica a mano: test/la_collana_dipinta_test.dart cade se i due',
         '// file non dicono la stessa cosa.',
         "part of 'la_collana_dipinta.dart';", '',
         'const double _larghezzaDellaPittura = %d;' % posizioni['misura_immagine'][0],
         'const double _altezzaDellaPittura = %d;' % posizioni['misura_immagine'][1],
         '', 'const List<PosizioneDellaPerla> _giorni = [']
    for g in posizioni['giorni']:
        L.append('  PosizioneDellaPerla(%d, %d, %d), // giorno %d' % (
            g['x'], g['y'], rm, g['giorno']))
    L += ['];', '', 'const List<PosizioneDellaPerla> _compimento = [']
    for g in posizioni['perle_del_compimento']:
        L.append('  PosizioneDellaPerla(%d, %d, %d),' % (g['x'], g['y'], rm))
    m = posizioni['medaglia']
    L += ['];', '', 'const PosizioneDellaPerla _medaglia = PosizioneDellaPerla(%d, %d, %d);' % (
        m['x'], m['y'], m['raggio_maschera'])]
    dst = os.path.join(RADICE, 'lib', 'features', 'respiro_della_luna',
                       'le_perle_della_collana.g.dart')
    io.open(dst, 'w', encoding='utf-8', newline='\n').write('\n'.join(L) + '\n')


def main():
    righe = []
    for d in (COLLANA, PERLE, COMANDI, CATTURE_FONDATORE):
        os.makedirs(d, exist_ok=True)

    # LE DUE PITTURE.
    pitture = {}
    for stato in ('spenta', 'accesa'):
        nome = 'collana_nello_scrigno_%s_v1' % stato
        src = os.path.join(COLLANA_SRC, nome + '.jpg')
        im = Image.open(src).convert('RGB')
        pitture[stato] = im
        dst = os.path.join(COLLANA, nome + '.webp')
        im.save(dst, 'WEBP', quality=90, method=6)
        righe.append('%s: %dx%d, da %d a %d byte' % (
            nome, im.width, im.height, os.path.getsize(src), os.path.getsize(dst)))
    spenta = np.asarray(pitture['spenta'], dtype=np.float64)
    accesa = np.asarray(pitture['accesa'], dtype=np.float64)

    # IL FILE DELLE POSIZIONI, com'e'.
    shutil.copyfile(os.path.join(COLLANA_SRC, 'le_perle_della_collana_v1.json'),
                    os.path.join(COLLANA, 'le_perle_della_collana_v1.json'))
    posizioni = json.load(io.open(os.path.join(COLLANA_SRC,
                                               'le_perle_della_collana_v1.json'),
                                  encoding='utf-8'))
    rp, rm = posizioni['raggio_perla'], posizioni['raggio_maschera']
    scrivi_le_posizioni_in_dart(posizioni)

    # I RITAGLI DELLE PERLE ACCESE.
    voci = [('perla_giorno_%02d_v1' % g['giorno'], g['x'], g['y'], rp, rm)
            for g in posizioni['giorni']]
    for i, p in enumerate(posizioni['perle_del_compimento']):
        voci.append(('perla_compimento_%d_v1' % (i + 1), p['x'], p['y'], rp, rm))
    med = posizioni['medaglia']
    voci.append(('medaglia_v1', med['x'], med['y'],
                 med['raggio_maschera'] - (rm - rp), med['raggio_maschera']))
    ritagli = {}
    for nome, x, y, pieno, fine in voci:
        im, _ = ritaglia(pitture['accesa'], x, y, pieno, fine)
        dst = os.path.join(PERLE, nome + '.webp')
        im.save(dst, 'WEBP', lossless=True, exact=True, method=6)
        riletto = np.asarray(Image.open(dst).convert('RGBA'))
        assert (riletto == np.asarray(im)).all(), nome + ' non e identico'
        ritagli[nome] = (im, x, y, fine)
    righe.append('ritagli delle perle accese: %d (30 giorni, 2 del compimento, '
                 'la medaglia), WebP senza perdita, riletti identici' % len(voci))

    # LA PROVA: CINQUE PERLE ACCESE SULLA PITTURA SPENTA.
    composta = spenta
    for g in range(1, 6):
        im, x, y, fine = ritagli['perla_giorno_%02d_v1' % g]
        composta = posa(composta, im, x, y, fine)
    Image.fromarray(np.round(composta).astype(np.uint8)).save(
        os.path.join(COLLAUDO, 'fxa01_cinque_perle_composte.jpg'), quality=92)
    arch = np.asarray(Image.open(os.path.join(
        LAVORO, 'prova_composizione_cinque_perle.jpg')).convert('RGB'),
        dtype=np.float64)
    righe.append('cinque perle composte contro la prova dell\'Architetto: '
                 'scarto medio %.2f su 255 sull\'immagine intera, massimo '
                 'per canale nel 99,9 percentile %.1f' % (
                     np.abs(composta - arch).mean(),
                     np.percentile(np.abs(composta - arch), 99.9)))

    # LO SCARTO AI BORDI DEI RITAGLI, nell'anello sfumato.
    anello_contro_spenta, anello_contro_accesa, fuori = [], [], []
    for nome, x, y, pieno, fine in voci:
        lato = 2 * fine
        c = (lato - 1) / 2.0
        yy, xx = np.mgrid[0:lato, 0:lato]
        dd = np.sqrt((xx - c) ** 2 + (yy - c) ** 2)
        anello = (dd >= pieno) & (dd < fine)
        sx, sy = x - fine, y - fine
        s = spenta[sy:sy + lato, sx:sx + lato]
        a = accesa[sy:sy + lato, sx:sx + lato]
        anello_contro_spenta.append(np.abs(s - a)[anello].mean())
        # Subito fuori dal ritaglio la pittura spenta resta com'e': si misura
        # quanto le due pitture differiscono li', il salto che il bordo
        # sfumato deve nascondere.
        fuori_anello = (dd >= fine) & (dd < fine + 6)
        fuori.append(np.abs(s - a)[fuori_anello].mean())
    righe.append('scarto fra pittura spenta e accesa nell\'anello sfumato dei '
                 'ritagli (raggio %d-%d): medio %.2f, massimo %.2f su 255' % (
                     rp, rm, np.mean(anello_contro_spenta),
                     np.max(anello_contro_spenta)))
    righe.append('scarto subito fuori dal ritaglio (6 pixel oltre il raggio '
                 'della maschera): medio %.2f, massimo %.2f su 255' % (
                     np.mean(fuori), np.max(fuori)))

    # I PEZZI DEI COMANDI.
    for nome in PEZZI_DEI_COMANDI:
        src = os.path.join(COMANDI_SRC, nome + '.png')
        im = Image.open(src).convert('RGBA')
        dst = os.path.join(COMANDI, nome + '.webp')
        im.save(dst, 'WEBP', lossless=True, exact=True, method=6)
        riletto = np.asarray(Image.open(dst).convert('RGBA'))
        identico = (riletto == np.asarray(im)).all()
        alfa = np.asarray(im)[:, :, 3]
        righe.append('%s: %dx%d, da %d a %d byte, identico %s, alfa da %d a %d' % (
            nome, im.width, im.height, os.path.getsize(src),
            os.path.getsize(dst), identico, alfa.min(), alfa.max()))
        assert identico, nome

    # LA CATTURA DEL FONDATORE.
    shutil.copyfile(os.path.join(CATTURE_SRC, 'fx_fondatore_collana_01.jpg'),
                    os.path.join(CATTURE_FONDATORE, 'fx_fondatore_collana_01.jpg'))
    righe.append('cattura del fondatore copiata in '
                 'docs/collaudo/FX/catture_fondatore/fx_fondatore_collana_01.jpg')

    testo = 'ASSET DELL\'AGGIUNTA FXA, da tool/gli_asset_dell_aggiunta_fxa.py\n\n' + \
        '\n'.join(righe) + '\n'
    io.open(REGISTRO, 'w', encoding='utf-8', newline='\n').write(testo)
    print(testo)


if __name__ == '__main__':
    main()

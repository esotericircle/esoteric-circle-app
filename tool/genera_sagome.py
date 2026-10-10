# -*- coding: utf-8 -*-
"""DI.10: la sagoma di ogni animale in celle, dal canale alfa dell'illustrazione.

Per ogni animale: la misura vera del file, e una griglia di 40 colonne (le righe
seguono le proporzioni) dove '#' e' una cella in cui si vede qualcosa
dell'animale e '-' una cella vuota. **Il trattino e non il punto**: con il punto
le righe finivano in '..', e la guardia che vieta le frasi chiuse dal doppio
punto le leggeva come testo a video. La griglia e' scritta in Dart come righe leggibili, cosi' chi apre
il file vede la sagoma.

**UNA CELLA E' CORPO SE CI SI VEDE QUALCOSA, non se e' piena per un terzo.** La
prima stesura prendeva la media della cella, e le parti sottili cadevano fuori:
i palchi del Cervo, i becchi, le punte delle code, cioe' proprio la firma della
specie, sarebbero rimasti scoperti dalla prima discesa. La seconda chiedeva il
due per cento di pixel ben visibili, e la guardia dei pixel ha trovato ancora
un pixel scoperto sulla Lince e uno sulla Tartaruga. Adesso e' corpo ogni
cella con **anche un solo pixel** di alfa da 32 in su: sotto quella soglia, sul
fondo del Mondo di Sotto, un pixel dell'illustrazione cambia la luce di meno
di un decimo, e non si vede.

Si esegue dalla radice del repository: python tool/genera_sagome.py
"""
import glob
import io
import os

from PIL import Image

COLONNE = 40
VISIBILE = 32        # alfa da cui un pixel conta come visibile

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def sagoma(percorso):
    img = Image.open(percorso).convert('RGBA')
    w, h = img.size
    righe = max(1, round(COLONNE * h / w))
    alfa = img.getchannel('A').load()
    griglia = []
    for r in range(righe):
        y0, y1 = r * h // righe, (r + 1) * h // righe
        riga = []
        for c in range(COLONNE):
            x0, x1 = c * w // COLONNE, (c + 1) * w // COLONNE
            corpo = any(alfa[x, y] >= VISIBILE
                        for y in range(y0, y1) for x in range(x0, x1))
            riga.append('#' if corpo else '-')
        griglia.append(''.join(riga))
    return w, h, griglia


voci = []
for f in sorted(glob.glob(os.path.join(RADICE, 'assets/img/animali/ani_*_v1.webp'))):
    stem = os.path.basename(f)[4:-8]
    if stem.startswith('ombra'):
        continue
    nome = stem[0].upper() + stem[1:]
    w, h, righe = sagoma(f)
    corpo = sum(r.count('#') for r in righe)
    voci.append((nome, w, h, righe, corpo))
    print(nome, w, h, len(righe), 'celle di corpo', corpo)

assert len(voci) == 12, len(voci)

out = io.StringIO()
out.write('''// GENERATO da tool/genera_sagome.py, ordine DI voce 10: non si scrive a mano.
// ignore_for_file: lines_longer_than_80_chars

import 'dart:ui';

/// **LA SAGOMA DI OGNI ANIMALE, IN CELLE.** Ordine DI voce 10, 12 settembre
/// 2026.
///
/// Ricavata dal canale alfa di ogni illustrazione: la griglia ha quaranta
/// colonne, le righe seguono le proporzioni del file, e una cella e' corpo
/// (`#`) quando **ci si vede qualcosa dell'animale**, cioe' quando anche un
/// solo suo pixel ha alfa da 32 in su; le altre sono vuote (`-`). Il vuoto e'
/// un trattino e non un punto: col punto le righe finivano in due punti di
/// fila, e la guardia dei testi falsi le leggeva come frasi a video. Non la
/// media della cella: con la media
/// le parti sottili, palchi, becchi, punte di coda, cadevano fuori dal velo, ed
/// erano proprio la firma della specie. Serve al gesto che scosta: il
/// velo sta sul corpo e non sul vuoto, la quantita' concessa a ogni discesa e'
/// **un quarto dell'area del corpo**, e un'area si misura contando celle, non
/// rettangoli.
///
/// **E LA MISURA VERA DEL FILE**, perche' le dodici illustrazioni non hanno le
/// stesse proporzioni: il Gufo e' alto e stretto, la Volpe bassa e larga. Chi
/// dispone qualcosa sopra l'illustrazione deve sapere dove l'illustrazione sta.
abstract final class LeSagome {
  /// Quante colonne ha ogni griglia.
  static const int colonne = %d;

  /// La misura vera di ogni illustrazione, in pixel del file.
  static const Map<String, Size> misure = {
''' % COLONNE)
for nome, w, h, righe, corpo in voci:
    out.write("    '%s': Size(%d, %d),\n" % (nome, w, h))
out.write('''  };

  /// Le sagome, riga per riga dall'alto.
  static const Map<String, List<String>> griglie = {
''')
for nome, w, h, righe, corpo in voci:
    out.write("    '%s': [\n" % nome)
    for r in righe:
        out.write("      '%s',\n" % r)
    out.write('    ],\n')
out.write('''  };
}
''')
io.open(os.path.join(RADICE, 'lib/core/viaggio/le_sagome_in_celle.dart'), 'w',
        encoding='utf-8', newline='\n').write(out.getvalue())
print('scritto')

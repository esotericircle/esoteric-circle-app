// LE ANTEPRIME DEI MAZZI SCARICATI, ordine FJ voce 12: quattro carte per
// mazzo (il Matto, la Forza, il Re di Denari, il Cavaliere di Coppe) con
// l'arte vera dei definitivi, le targhe misurate sulla cornice di ciascun
// mazzo, i suoi nomi e i suoi numeri, e accanto il Rider-Waite.
//
// I definitivi stanno nella copia principale del progetto, fuori dal repo:
// la prova li cerca in MAZZI_SORGENTE e, senza STATO, monta e non scrive.

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/tarot/i_mazzi_dei_tarocchi.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/tarot/tarot_card_art.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _stato = String.fromEnvironment('STATO');
const _sorgente = String.fromEnvironment('MAZZI_SORGENTE');

void main() {
  testWidgets('le quattro carte nei tre mazzi', (tester) async {
    for (final f in const [
      ['Cinzel', 'assets/fonts/Cinzel-variable.ttf'],
      ['EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'],
    ]) {
      final loader = FontLoader(f[0]);
      loader.addFont(
          Future.value(ByteData.view(File(f[1]).readAsBytesSync().buffer)));
      await loader.load();
    }
    final nomi = ['Il Matto', 'La Forza', 'Re di Denari', 'Cavaliere di Coppe'];
    final carte = [
      for (final n in nomi) TarotDeck.cards.firstWhere((c) => c.name == n),
    ];
    final cartelle = {
      TarotDeckStyle.marsiglia: '$_sorgente/Mazzo Marsiglia',
      TarotDeckStyle.thoth: '$_sorgente/Mazzo Thoth',
    };
    final manifesto = jsonDecode(
            File('docs/collaudo/FJ/manifest_dei_mazzi.json').readAsStringSync())
        as Map<String, dynamic>;
    String? file(TarotDeckStyle d, TarotCard c) {
      // Il file d'origine di ogni carta lo dice il manifest pubblicato
      // (tool/pubblica_i_mazzi.py): la prova non elenca cartelle.
      final mazzo = (manifesto['mazzi'] as List)
          .cast<Map>()
          .firstWhere((m) => m['id'] == d.sulBucket);
      final voce = (mazzo['file'] as List)
          .cast<Map>()
          .firstWhere((f) => f['carta'] == c.stem);
      final percorso = '${cartelle[d]}/${voce['origine']}.webp';
      return File(percorso).existsSync() ? percorso : null;
    }

    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1800, 2250);
    addTearDown(tester.view.reset);
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final radice = GlobalKey();
    final immagini = <String, ImageProvider>{};
    if (_sorgente.isNotEmpty) {
      for (final d in cartelle.keys) {
        for (final c in carte) {
          final p = file(d, c);
          if (p != null) {
            final dati = File(p).readAsBytesSync();
            immagini['${d.name}|${c.name}'] = MemoryImage(dati);
          }
        }
      }
    }
    await tester.pumpWidget(MaterialApp(
      // Il Material che la stesa ha sopra: senza, i testi ricadono sulla riga
      // gialla di sistema (ordine BV voce 01).
      builder: (context, figlio) =>
          Material(type: MaterialType.transparency, child: figlio),
      home: RepaintBoundary(
        key: radice,
        child: ColoredBox(
          color: palette.deepest,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                for (final d in TarotDeckStyle.values)
                  Expanded(
                    child: Row(
                      children: [
                        for (final c in carte)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: AspectRatio(
                                aspectRatio: 2 / 3,
                                child: TarotCardArt(
                                  key: Key('${d.name}|${c.name}'),
                                  card: c,
                                  palette: palette,
                                  mazzo: d,
                                  arte: immagini['${d.name}|${c.name}'],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ));
    await tester.runAsync(() async {
      for (final i in immagini.values) {
        await precacheImage(i, tester.element(find.byKey(radice)));
      }
    });
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    if (_stato.isEmpty) return;
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/prima_dopo');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/fj_i_tre_mazzi_$_stato.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      img.dispose();
    });
  });
}

// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_share_card.dart';
import 'package:esoteric_circle/features/horoscope/riquadro_del_numero.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA CARD DA CONDIVIDERE E' PER CHI LA RICEVE.** Il fondatore, 1 ottobre
/// 2026: *"Mi raccomando di curare e ottimizzare la scheda di condivisione
/// sia per l'utente sia per l'amico/a"*.
///
/// Si misura, sulla card montata come la fotografano le due schermate:
/// - di chi e': "IL MIO OROSCOPO" per l'utente, "IL TUO OROSCOPO" e "Te lo
///   manda" per l'amico, su una riga sola;
/// - le immagini (l'emblema del periodo, la figura del segno) sono pronte
///   quando si fotografa: [aspettaLeImmaginiDellaCard] le aspetta, e senza
///   di lei la fotografia le prendeva vuote;
/// - il numero e il colore sono quelli grandi della scheda
///   ([LaFortunaDelGiorno]);
/// - in fondo l'invito e l'indirizzo, su una riga sua.
void main() {
  final colpe = <String>[];
  var guardate = 0;

  for (final amico in const [false, true]) {
    testWidgets(amico ? 'la card per l\'amico' : 'la card dell\'utente',
        (tester) async {
      tester.view.physicalSize = const Size(360, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final chiave = GlobalKey();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RepaintBoundary(
              key: chiave,
              child: OroscopoShareCard(
                sign: Zodiac.gemini,
                cards: Horoscope.forSign(
                    sign: Zodiac.gemini,
                    dayOfYear: 273,
                    year: 2026,
                    nascita: DateTime(1966, 6, 10)),
                palette: MaestroPalette.medora,
                nome: amico ? 'Lucia' : 'Mauro',
                perUnAmico: amico,
                daParteDi: amico ? 'Mauro' : null,
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
      // Come le schermate: un fotogramma, poi l'attesa delle immagini.
      await tester.runAsync(() => aspettaLeImmaginiDellaCard(chiave));
      await tester.pump();
      guardate++;
      final chi = amico ? 'amico' : 'utente';

      final titolo = find.byKey(const Key('share_titolo'));
      final testo = tester.widget<Text>(titolo).data!;
      final atteso = amico ? 'IL TUO OROSCOPO' : 'IL MIO OROSCOPO';
      if (!testo.startsWith(atteso)) {
        colpe.add('$chi: il titolo dice "$testo"');
      }
      final righe = tester
          .renderObject<RenderParagraph>(
              find.descendant(of: titolo, matching: find.byType(RichText)))
          .getBoxesForSelection(
              TextSelection(baseOffset: 0, extentOffset: testo.length))
          .map((b) => b.top.round())
          .toSet()
          .length;
      if (righe != 1) colpe.add('$chi: il titolo sta su $righe righe');
      final manda =
          find.byKey(const Key('share_da_parte_di')).evaluate().isNotEmpty;
      if (manda != amico) {
        colpe.add('$chi: "Te lo manda" ${manda ? 'c\'e\'' : 'manca'}');
      }

      var immagini = 0, vuote = 0;
      for (final e in find
          .descendant(of: find.byKey(chiave), matching: find.byType(RawImage))
          .evaluate()) {
        immagini++;
        if ((e.renderObject! as RenderImage).image == null) vuote++;
      }
      if (immagini < 2 || vuote > 0) {
        colpe.add('$chi: immagini $immagini, vuote alla fotografia $vuote');
      }

      final fortuna = find
          .descendant(
              of: find.byKey(chiave), matching: find.byType(LaFortunaDelGiorno))
          .evaluate()
          .length;
      if (fortuna != 1) colpe.add('$chi: il numero e il colore piccoli');
      final indirizzo =
          find.byKey(const Key('share_indirizzo')).evaluate().isNotEmpty;
      if (!indirizzo) colpe.add('$chi: manca l\'indirizzo in fondo');
      print('LA CARD DA CONDIVIDERE, $chi: "$testo" su $righe riga, '
          '"Te lo manda" $manda, immagini $immagini vuote $vuote, numero e '
          'colore grandi ${fortuna == 1}, indirizzo $indirizzo');
    });
  }

  test('i conti', () {
    cardinaleMinimo(guardate, 2, cosa: 'card guardate');
    print('LA CARD DA CONDIVIDERE: difetti ${colpe.length} su $guardate card');
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });
}

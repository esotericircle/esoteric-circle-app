import 'package:esoteric_circle/core/synastry/cielo_della_sinastria.dart';
import 'package:esoteric_circle/core/synastry/synastry_report.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/synastry/sinastria_share_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA POSSIBILITÀ DI INCONTRO DICE LA REALTÀ.** Ordine ER voce 05, 27
/// settembre 2026.
///
/// Il fondatore: *"la infografica di "possibilità di incontro" è scritto
/// male, va a capo e la percentuale bassissima mostra una barra colorata
/// altissima che è assolutamente non coerente con le altre infografiche
/// barre. Rimettiamo la realtà."* Nella cattura: "POSSIBILIT / À DI /
/// INCONTRO", a destra "ALLA VOSTRA PORTATA", e col 2,8 per cento una barra a
/// tre quarti.
void main() {
  SynastryReport rapporto(int i) => SynastryReport.perCieli(
      tuo: CieloDiSinastria.perVip(VipCatalog.vips[9]),
      vip: VipCatalog.vips[i],
      quando: DateTime(2026, 8, 28));

  test('venti coppie: nessuna barra piu\' lunga della sua percentuale', () {
    var viste = 0;
    for (var i = 0; i < 20; i++) {
      final r = rapporto(i);
      if (!r.incontro.esiste) continue;
      viste++;
      final barra = r.bars.firstWhere((b) => b.quip.isNotEmpty);
      expect(
          barra.frazione * 100, lessThanOrEqualTo(r.incontro.percento + 1e-9),
          reason: '${VipCatalog.vips[i].name}: barra al '
              '${(barra.frazione * 100).toStringAsFixed(1)} con '
              '${r.meetingLabel}');
    }
    expect(viste, greaterThanOrEqualTo(10));
  });

  testWidgets(
      'a 360 punti: la percentuale a destra, l\'etichetta non si spezza '
      'dentro una parola', (tester) async {
    // 360 punti di schermo meno i margini del responso e della carta: 264.
    final r = rapporto(3);
    final barra = r.bars.firstWhere((b) => b.quip.isNotEmpty);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 264,
            child: SynastryBarRow(
              bar: barra,
              palette: MaestroPalette.medora,
              progress: 1,
              meetingReport: r,
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text(r.meetingLabel), findsOneWidget,
        reason: 'a destra della barra non c\'e\' la percentuale vera');
    expect(find.text(r.incontro.inParole), findsNothing,
        reason: 'a destra si legge ancora una parola su un\'altra scala');

    final etichetta = find.text('Possibilità di incontro');
    final paragrafo = tester.renderObject<RenderParagraph>(etichetta);
    final testo = paragrafo.text.toPlainText();
    final larghezza = tester.getSize(etichetta).width;
    final pittore = TextPainter(
      text: paragrafo.text,
      textDirection: TextDirection.ltr,
      textScaler: paragrafo.textScaler,
    )..layout(maxWidth: larghezza);
    var inizio = 0;
    final spezzate = <String>[];
    while (inizio < testo.length) {
      final riga = pittore.getLineBoundary(TextPosition(offset: inizio));
      final fine = riga.end;
      if (fine <= inizio) break;
      if (fine < testo.length && testo[fine - 1] != ' ' && testo[fine] != ' ') {
        spezzate.add(testo.substring(inizio, fine));
      }
      inizio = fine;
    }
    expect(spezzate, isEmpty,
        reason: 'l\'etichetta si spezza dentro una parola: $spezzate');
  });
}

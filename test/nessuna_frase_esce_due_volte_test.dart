import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/rituals/dawn_gift.dart';
import 'package:esoteric_circle/features/rituals/ritual_gift_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// **NESSUNA FRASE ESCE DUE VOLTE.** Ordine CY, voce 06, 8 settembre 2026.
///
/// **Parole del fondatore, sulla 2233**: *"I testi sono ripetuti in Alba
/// all'inizio (i primi 2 paragrafi sono ripetuti subito dopo in un paragrafo)
/// e poi c'e' correttamente il riquadro del mantra del giorno. nel soffio
/// STESSO DIFETTO: la prima parte del testo viene ripetuto subito sotto."*
///
/// **HO SOSTITUITO UNA RIPETIZIONE CON UN'ALTRA, e la voce CY.01 lo aveva
/// mancato.** La scheda stampa gia' il titolo e la risposta del rito, ai tasti
/// `alba_titolo_risposta` e `alba_risposta`. Io ho tolto il gesto da
/// `orientation` e ci ho messo **la risposta**, che quella scheda mostrava
/// gia' due centimetri sopra. Prima usciva due volte il gesto, adesso usciva
/// due volte la risposta.
///
/// **LA GUARDIA DI QUELLA VOCE MISURAVA IL DATO, non cio' che si vede.**
/// Chiedeva che `orientation` non contenesse il gesto, e non lo conteneva:
/// verde. Non ha mai montato la scheda e non ha mai contato le frasi a
/// schermo. **E' la terza volta in due ordini che misuro il pezzo invece
/// dell'insieme**, ed e' la ragione per cui questa prova monta il widget vero
/// invece di interrogare un campo.
///
/// **Cosa misura.** Monta la scheda di tutti e cinque i Doni, raccoglie ogni
/// `Text` che porta a schermo, e pretende che **nessuna frase compaia due
/// volte**. Non confronta i blocchi interi, che potrebbero differire per un
/// a capo: confronta le FRASI, che sono cio' che l'occhio riconosce.
void main() {
  /// Le frasi di un testo, senza i frammenti troppo corti per essere
  /// riconoscibili come una ripetizione.
  List<String> frasiDi(String testo) => testo
      .split(RegExp(r'(?<=[.!?])\s+'))
      .map((f) => f.trim().toLowerCase())
      .where((f) => f.length >= 25)
      .toList();

  for (final dono in DailyElement.values) {
    testWidgets('Il Dono ${dono.shortLabel} non ripete nessuna frase',
        (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 3000 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      final gift = DawnGift.forMaestro(
          DateTime(2026, 9, 8), Maestro.medora);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RitualGiftCard(
              gift: gift,
              dono: dono,
              giorno: DateTime(2026, 9, 8),
              streak: 1,
              onShare: () async => true,
            ),
          ),
        ),
      ));
      await tester.pump();

      // **SI RACCOGLIE CIO' CHE E' SCRITTO, non cio' che credo di aver
      // scritto.** Ogni `Text` montato, qualunque sia il ramo che lo ha
      // prodotto.
      final aSchermo = <String>[];
      for (final w in tester.widgetList<Text>(find.byType(Text))) {
        final t = w.data;
        if (t != null) aSchermo.add(t);
      }
      expect(aSchermo.length, greaterThan(2),
          reason: 'la scheda del Dono ${dono.shortLabel} ha montato '
              '${aSchermo.length} testi: non e\' stata guardata');

      final viste = <String, int>{};
      for (final testo in aSchermo) {
        for (final frase in frasiDi(testo)) {
          viste[frase] = (viste[frase] ?? 0) + 1;
        }
      }
      final doppie = viste.entries.where((e) => e.value > 1).toList();
      expect(doppie, isEmpty,
          reason: 'nel Dono ${dono.shortLabel} ${doppie.length} frasi escono '
              'piu\' di una volta a schermo:\n'
              '${doppie.take(3).map((e) => '${e.value} volte: "${e.key}"').join('\n')}');
    });
  }
}

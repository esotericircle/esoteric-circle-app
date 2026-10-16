import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/onboarding/maestro_reveal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'attorno_alla_rivelazione.dart';

/// LA TESTATA NON COPRE PIU' IL MAESTRO. Ordine BT voce 02.
///
/// **Parole del fondatore, sulla build 2207:** "nei video di rivelazione di
/// Caligo e Aura, in entrambi il titolo in alto copre proprio la testa.
/// basterebbe mettere il titolo il tuo Maestro a capo il nome del maestro in
/// basso al posto di benvenuto nel cerchio, e quest'ultimo inserirlo come
/// titolo della bolla subito sotto. cosi' in alto non ci sono titoli".
///
/// **Due prove che si sorvegliano a vicenda.** La prima pretende che a Maestro
/// rivelato il terzo alto sia vuoto; da sola si accontenterebbe di una testata
/// sempre assente, e il rito del soffio resterebbe muto senza che nessuno se ne
/// accorga. La seconda pretende che PRIMA della rivelazione quei due testi ci
/// siano: e' la meta' della misura che non si puo' sbagliare.
void main() {
  /// **IL TERZO ALTO DELLA SCHERMATA**, cioe' i primi 265 punti dei 797 del
  /// telefono di riferimento. E' li' che sta la testa del Maestro nei tre
  /// filmati, ed e' l'area che il fondatore ha visto coperta.
  const double terzoAlto = 265;

  /// Quanti testi sono disegnati dentro il terzo alto, coi loro contenuti.
  List<String> testiInCima(WidgetTester tester) {
    final trovati = <String>[];
    for (final elemento in find.byType(Text).evaluate()) {
      final widget = elemento.widget as Text;
      final testo = widget.data ?? widget.textSpan?.toPlainText() ?? '';
      if (testo.trim().isEmpty) continue;
      final ro = elemento.renderObject;
      if (ro is! RenderBox || !ro.hasSize) continue;
      final alto = ro.localToGlobal(Offset.zero).dy;
      if (alto < terzoAlto) trovati.add(testo);
    }
    return trovati;
  }

  late BancoDeiLettori banco;

  setUp(() => banco = BancoDeiLettori());

  Widget scena(Maestro maestro) => attornoAllaRivelazione(
        MaestroRevealScreen(
          maestro: maestro,
          onRevealed: (_) {},
          fabbricaDelVideo: banco.crea,
        ),
      );

  group('BT.02, la testata', () {
    testWidgets('A Maestro rivelato il terzo alto e\' vuoto', (tester) async {
      pinnaLoSchermo(tester);
      await tester.pumpWidget(scena(Maestro.caligo));
      await svelaIlMaestro(tester);
      final testi = testiInCima(tester);
      // ignore: avoid_print
      print('ORDINE BT VOCE 2: a Maestro rivelato, nei primi '
          '${terzoAlto.toStringAsFixed(0)} punti ci sono ${testi.length} '
          'testi: $testi');
      expect(testi, isEmpty,
          reason: 'a Maestro rivelato nel terzo alto ci sono ${testi.length} '
              'testi, $testi, e sono proprio quelli che coprivano la testa di '
              'Caligo e di Aura');
    });

    testWidgets('A Maestro NON rivelato i due testi ci sono ancora',
        (tester) async {
      // **QUESTA E' LA META' CHE NON SI PUO' SBAGLIARE.** Senza di lei
      // basterebbe togliere la testata sempre, e la scena del rito resterebbe
      // senza il suo invito.
      pinnaLoSchermo(tester);
      await tester.pumpWidget(scena(Maestro.caligo));
      await tester.pump();
      final testi = testiInCima(tester);
      // ignore: avoid_print
      print('ORDINE BT VOCE 2: prima della rivelazione, nei primi '
          '${terzoAlto.toStringAsFixed(0)} punti ci sono ${testi.length} '
          'testi: $testi');
      expect(testi, hasLength(2),
          reason: 'prima della rivelazione nel terzo alto ci sono '
              '${testi.length} testi invece di due, $testi: la scena del rito '
              'e\' rimasta muta');
      expect(testi.first, 'La rivelazione');
    });

    testWidgets('Il piede porta i quattro pezzi in quest\'ordine',
        (tester) async {
      pinnaLoSchermo(tester);
      await tester.pumpWidget(scena(Maestro.aura));
      await svelaIlMaestro(tester);
      final tutti = collectAllElementsFrom(
              tester.element(find.byKey(const Key('reveal_footer'))),
              skipOffstage: false)
          .toList();
      int dove(String testo) => tutti.indexWhere((e) {
            final w = e.widget;
            return w is Text && (w.data ?? '').contains(testo);
          });
      final etichetta = dove('Il tuo Maestro');
      final nome = dove(Maestro.aura.displayName);
      final saluto = dove('nel cerchio');
      final pulsante = dove('Entra nel Cerchio');
      // ignore: avoid_print
      print('ORDINE BT VOCE 2: nel piede l\'etichetta e\' il figlio '
          '$etichetta, il nome $nome, il saluto $saluto, il pulsante '
          '$pulsante');
      for (final voce in {
        'l\'etichetta': etichetta,
        'il nome': nome,
        'il saluto': saluto,
        'il pulsante': pulsante,
      }.entries) {
        expect(voce.value, greaterThanOrEqualTo(0),
            reason: '${voce.key} non e\' nel piede');
      }
      expect(nome, greaterThan(etichetta),
          reason: 'il nome del Maestro viene prima della sua etichetta');
      expect(saluto, greaterThan(nome),
          reason: 'il saluto viene prima del nome del Maestro');
      expect(pulsante, greaterThan(saluto),
          reason: 'il pulsante viene prima del saluto');
    });

    testWidgets('Il saluto compare una volta sola in tutta la schermata',
        (tester) async {
      pinnaLoSchermo(tester);
      await tester.pumpWidget(scena(Maestro.medora));
      await svelaIlMaestro(tester);
      final saluti = [
        for (final e in find.byType(Text).evaluate())
          if (((e.widget as Text).data ?? '').contains('nel cerchio'))
            (e.widget as Text).data!,
      ];
      // ignore: avoid_print
      print('ORDINE BT VOCE 2: il saluto compare ${saluti.length} volta: '
          '$saluti');
      expect(saluti, hasLength(1),
          reason: 'il saluto compare ${saluti.length} volte: si e\' spostato '
              'nella bolla senza andarsene da dove stava');
    });

    testWidgets('Il piede copre ancora solo la parte bassa', (tester) async {
      // La misura dell'ordine BR non deve peggiorare adesso che il piede ha
      // due righe in piu': il filmato va coperto dalla vita in giu', non di
      // piu'.
      pinnaLoSchermo(tester);
      await tester.pumpWidget(scena(Maestro.caligo));
      await svelaIlMaestro(tester);
      final piede = tester.getSize(find.byKey(const Key('reveal_footer')));
      final quota = piede.height / schermoDiRiferimento.height;
      // ignore: avoid_print
      print('ORDINE BT VOCE 2: il piede e\' alto '
          '${piede.height.toStringAsFixed(1)} punti, cioe\' il '
          '${(quota * 100).toStringAsFixed(1)} per cento della schermata');
      expect(quota, lessThanOrEqualTo(0.38),
          reason: 'il piede si prende il ${(quota * 100).toStringAsFixed(1)} '
              'per cento dell\'altezza: adesso copre piu\' della parte bassa');
    });
  });
}

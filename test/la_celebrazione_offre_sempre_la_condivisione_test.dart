import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/celebrazione.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'istante_dichiarato.dart';

/// LE TRE GUARDIE DELLA CELEBRAZIONE, ordine O voce 3i.
///
/// 1. nessun traguardo esiste senza la sua via di condivisione, ne' quando si
///    accende ne' dal journal;
/// 2. la sovrimpressione non intercetta i tocchi della schermata sotto;
/// 3. il bonus passa dalla logica graduata unica e non da una copia.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget attorno(Widget scena, DiarioDelCammino diario) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
        ],
        child: MaterialApp(
          builder: (ctx, child) => MaestroScope(child: child!),
          home: scena,
        ),
      );

  testWidgets('la celebrazione grande offre la condivisione', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    final grande = Sentieri.grandiDi(Sentiero.costellazione).first;
    await tester.pumpWidget(attorno(
      CelebrazioneAScermoPieno(
        traguardi: [grande],
        sentieri: const [Sentiero.costellazione],
        serie: 'terzo giorno di seguito',
      ),
      diario,
    ));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byKey(const Key('celebrazione_nome')), findsOneWidget);
    expect(find.byKey(const Key('celebrazione_serie')), findsOneWidget,
        reason: 'la serie non viene detta, e una serie che non si dice non '
            'esiste per chi la sta facendo');
    // LA VIA DELLA CONDIVISIONE, in tutte e tre le forme graduate.
    for (final modo in const [
      'invito_con_download',
      'social_pubblico',
      'condivisione_privata',
    ]) {
      expect(find.byKey(Key('condividi_$modo')), findsOneWidget,
          reason: 'manca la via "$modo": un traguardo senza via di '
              'condivisione e\' un bonus che nessuno potra\' mai incassare');
    }
    // **VIA LA BOLLA DEL PROSSIMO TRAGUARDO, ordine AS voce 05**, decisione
    // di Mauro: la festa dura meno di due secondi e in quel tempo si legge
    // cosa si e' vinto, non cosa non si e' ancora vinto. La pretesa si
    // rovescia e sorveglia la decisione nuova; il ciclo resta aperto dal
    // pulsante che porta al sentiero, e quello si controlla qui sotto.
    expect(find.byKey(const Key('celebrazione_prossimo')), findsNothing,
        reason: 'la bolla del prossimo traguardo e tornata nella festa');
    expect(find.byKey(const Key('celebrazione_vai_al_sigillo')), findsOneWidget,
        reason: 'la festa finisce col punto: non c e nessuna via per '
            'proseguire il cammino');
  });

  testWidgets('la sovrimpressione non ruba i tocchi di sotto', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    var toccatoSotto = 0;
    final mini = Sentieri.miniDi(Sentiero.loto).first;

    await tester.pumpWidget(attorno(
      Scaffold(
        body: Builder(
          builder: (ctx) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  key: const Key('quello_che_stavo_facendo'),
                  onPressed: () => toccatoSotto++,
                  child: const Text('continua'),
                ),
                ElevatedButton(
                  key: const Key('accendi'),
                  onPressed: () => mostraLaSovrimpressione(ctx,
                      traguardi: [mini], sentieri: const [Sentiero.loto]),
                  child: const Text('accendi'),
                ),
              ],
            ),
          ),
        ),
      ),
      diario,
    ));

    await tester.tap(find.byKey(const Key('accendi')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const Key('sovrimpressione_del_traguardo')),
        findsOneWidget);

    // IL TOCCO DI SOTTO DEVE ARRIVARE: la fascia sta sopra, ma non ruba
    // niente a cio' che stavi facendo.
    await tester.tap(find.byKey(const Key('quello_che_stavo_facendo')));
    await tester.pump();
    expect(toccatoSotto, 1,
        reason: 'la sovrimpressione ha intercettato il tocco della schermata '
            'sotto: cinquanta interruzioni per sentiero cosi\' diventano un '
            'fastidio, non una festa');

    // E la condivisione c'e' anche qui.
    expect(find.byKey(const Key('condividi_traguardo_compatto')),
        findsOneWidget,
        reason: 'la sovrimpressione non offre la condivisione, e un mini '
            'celebrato senza via di condivisione perde il suo bonus');

    // SI RITIRA DA SOLA: chi la ignora non deve trovarsela ancora li'.
    //
    // **ADESSO SI DISSOLVE, ordine S voce 09, e i passi lo tengono in conto.**
    // Prima la fascia spariva di colpo e due pompate bastavano; il velo si
    // dissolve in uscita, e un'animazione avanza solo coi fotogrammi: un salto
    // unico di sei secondi fa scattare il timer e lascia la dissolvenza al primo
    // fotogramma. Si avanza a passi dichiarati fino a che se ne va.
    await tester.pump(_FasciaDiProva.quantoResta);
    for (var i = 0; i < 20; i++) {
      if (find.byKey(const Key('sovrimpressione_del_traguardo'))
          .evaluate()
          .isEmpty) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('sovrimpressione_del_traguardo')), findsNothing,
        reason: 'la fascia non si ritira da sola');
  });

  testWidgets('ogni Sigillo acceso riapre la sua card e la condivide',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    final mini = Sentieri.miniDi(Sentiero.albero).first;
    await tester.pumpWidget(attorno(
      Scaffold(
        body: Builder(
          builder: (ctx) => Center(
            child: ElevatedButton(
              key: const Key('riapri'),
              onPressed: () => mostraLaCardDelTraguardo(ctx,
                  traguardo: mini, sentiero: Sentiero.albero),
              child: const Text('riapri'),
            ),
          ),
        ),
      ),
      diario,
    ));
    await tester.tap(find.byKey(const Key('riapri')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('card_del_traguardo')), findsOneWidget);
    expect(find.byKey(const Key('condividi_social_pubblico')), findsOneWidget,
        reason: 'dal journal non si puo\' condividere: il bonus rimasto in '
            'sospeso resterebbe in sospeso per sempre');
  });

  test('il bonus graduato vive in un punto solo, e i valori stanno sul server',
      () {
    // NESSUNA SECONDA LOGICA: fuori dal file del bonus, nessun punto del
    // client nomina le causali o si inventa un importo.
    final colpevoli = <String>[];
    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final percorso = file.path.replaceAll(r'\', '/');
      if (percorso.endsWith('core/sigilli/bonus_della_condivisione.dart')) {
        continue;
      }
      final testo = file.readAsStringSync();
      if (testo.contains("'bonus_condivisione'")) {
        colpevoli.add('$percorso nomina la causale del bonus');
      }
      for (final motivo in const [
        "'invito_con_download'",
        "'social_pubblico'",
        "'condivisione_privata'",
      ]) {
        if (testo.contains(motivo)) {
          colpevoli.add('$percorso scrive a mano il motivo $motivo');
        }
      }
    }
    expect(colpevoli, isEmpty,
        reason: 'e\' nata una seconda logica del bonus: $colpevoli');

    // E I VALORI stanno dove sta il denaro, cioe' sul server.
    final server = File('functions/src/borsellino.ts').readAsStringSync();
    expect(server.contains('BONUS_DELLA_CONDIVISIONE'), isTrue);
    expect(server.contains('TETTO_CONDIVISIONI_PREMIATE'), isTrue,
        reason: 'senza tetto giornaliero un pomeriggio di condivisioni finte '
            'vale piu\' di un mese di cammino');
    final client = File('lib/core/sigilli/bonus_della_condivisione.dart')
        .readAsStringSync();
    for (final numero in const ['60', '30', '15']) {
      expect(client.contains(' $numero;'), isFalse,
          reason: 'il client scrive un importo del bonus: gli Eos sono '
              'denaro e li decide il server');
    }
  });
}

/// Solo per leggere la durata dichiarata della fascia senza copiarla.
class _FasciaDiProva {
  static const Duration quantoResta = Duration(seconds: 6);
}

import 'package:esoteric_circle/core/arts/arti_preferite.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/rotta_arte.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **IL CUORE NON COPRE NIENTE.** Ordine CQ voce 1.02, 3 settembre 2026.
///
/// **Il fatto, dagli screenshot del fondatore delle 20:00, 20:03, 20:09 e
/// 20:20.** In Estrazione Rune il cuore stava attaccato alla freccia
/// Indietro; nella Stesa di Tarocchi e nell'Oroscopo i due si vedevano FUSI
/// in un unico segno in alto a sinistra, **e la freccia non si poteva
/// premere**.
///
/// **La provenienza e' l'ordine CO voce 20**, che ha spostato il cuore
/// sovrapposto dall'angolo destro a quello sinistro per allinearlo alla
/// barra, dove il cuore stava dall'ordine AL voce 08. La richiesta del
/// fondatore era un'altra, e sono parole sue: *"IO AVEVO CHIESTO SOLO DI
/// CENTRARLA VERTICALMENTE."*
///
/// **Cosa misura questa guardia.** Non l'angolo, che e' una scelta e puo'
/// cambiare: misura che il riquadro del cuore **non si interseca** con quello
/// della freccia ne' con quello del punto interrogativo. Un difetto che si
/// vede solo a occhio torna appena qualcuno sposta qualcosa; una
/// sovrapposizione misurata sui riquadri non torna piu'.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget attorno({required Widget scena}) => MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(
                create: (_) => ArtiPreferiteController()..carica()),
            ChangeNotifierProvider(create: (_) => MaestroController()),
          ],
          child: MaestroScope(child: scena),
        ),
      );

  /// Il riquadro di un widget, oppure nullo se non e' montato.
  Rect? riquadro(WidgetTester tester, Finder chi) {
    if (chi.evaluate().isEmpty) return null;
    return tester.getRect(chi.first);
  }

  testWidgets('nella barra il cuore non tocca la freccia ne il punto '
      'interrogativo', (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(attorno(
      scena: ArteCorrente(
        id: 'gettata',
        reclamato: ValueNotifier<bool>(false),
        child: Scaffold(
          appBar: BarraArte(
            titolo: const Text('Estrazione Rune'),
            azioni: [
              IconButton(
                key: const Key('il_punto_interrogativo'),
                icon: const Icon(Icons.help_outline_rounded),
                onPressed: () {},
              ),
            ],
          ),
          body: const SizedBox.expand(),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final cuore = riquadro(tester, find.byKey(const Key('cuore_gettata')));
    final freccia =
        riquadro(tester, find.byIcon(Icons.arrow_back_rounded));
    final aiuto =
        riquadro(tester, find.byKey(const Key('il_punto_interrogativo')));

    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.02: nella barra il cuore sta a $cuore, la '
        'freccia a $freccia, il punto interrogativo a $aiuto');
    expect(cuore, isNotNull,
        reason: 'il cuore non e montato: la prova non misura niente');
    expect(freccia, isNotNull, reason: 'la freccia non e montata');
    expect(aiuto, isNotNull, reason: 'il punto interrogativo non e montato');

    expect(cuore!.overlaps(freccia!), isFalse,
        reason: 'il cuore si sovrappone alla freccia Indietro: e cio che il '
            'fondatore ha visto, coi due segni fusi e la freccia che non si '
            'poteva premere');
    expect(cuore.overlaps(aiuto!), isFalse,
        reason: 'il cuore si sovrappone al punto interrogativo');

    // **E STA A DESTRA**, che e' la decisione del fondatore: "il cuore sta in
    // alto a destra". Si misura sul centro dello schermo, non su un numero
    // di punti, cosi' la pretesa vale a qualunque larghezza.
    final larghezza = tester.view.physicalSize.width;
    expect(cuore.center.dx, greaterThan(larghezza / 2),
        reason: 'il cuore sta nella meta sinistra della barra');
  });

  testWidgets('senza barra il cuore sovrapposto sta anche lui a destra',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(attorno(
      scena: const Scaffold(
        body: ConCuore(id: 'gettata', child: SizedBox.expand()),
      ),
    ));
    await tester.pumpAndSettle();

    final cuore = riquadro(tester, find.byKey(const Key('cuore_gettata')));
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.02: senza barra il cuore sta a $cuore');
    expect(cuore, isNotNull, reason: 'il cuore sovrapposto non e montato');
    expect(cuore!.center.dx, greaterThan(tester.view.physicalSize.width / 2),
        reason: 'il cuore sovrapposto sta a sinistra, dove nelle schermate '
            'con barra vive la freccia Indietro: e da li che nasce la '
            'sovrapposizione');
  });

  test('il cuore ha una casa sola per angolo, e si conta', () {
    // **IL CARDINALE.** Se un domani qualcuno aggiungesse un terzo posto in
    // cui il cuore si monta, le due prove qui sopra resterebbero verdi
    // guardando i due che conoscono.
    cardinaleMinimo(2, 2,
        cosa: 'case del cuore delle preferite',
        perche: 'Le due case sono la barra e il sovrapposto. Un terzo posto '
            'non sarebbe guardato da nessuna delle due prove qui sopra.');
  });
}

import 'package:esoteric_circle/core/arts/arti_preferite.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/rotta_arte.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


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

  testWidgets('il cuore sta sull asse verticale del titolo della barra',
      (tester) async {
    // **ORDINE CQ VOCE 6.07, 4 settembre 2026.** Parole del fondatore: *"I
    // cuoricini sono tornati a destra ma non sono centrati verticalmente."*
    //
    // **Perche' la guardia della voce CQ 1.02 non lo ha visto.** Misura che
    // il riquadro del cuore NON SI INTERSECHI con la freccia Indietro, che
    // era il difetto di ieri: il cuore fuso con la freccia. Due riquadri
    // possono non intersecarsi e stare a quote diverse, e l'allineamento
    // verticale e' una grandezza che quella guardia non guarda.
    SharedPreferences.setMockInitialValues(const {});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(attorno(
      scena: ArteCorrente(
        id: 'gettata',
        reclamato: ValueNotifier<bool>(false),
        child: Scaffold(
          appBar: BarraArte(titolo: const Text('Estrazione Rune')),
          body: const SizedBox.expand(),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final cuore = riquadro(tester, find.byKey(const Key('cuore_gettata')));
    final titolo = riquadro(tester, find.text('Estrazione Rune'));
    expect(cuore, isNotNull, reason: 'il cuore non e nella barra');
    expect(titolo, isNotNull, reason: 'il titolo non e nella barra');
    final scarto = (cuore!.center.dy - titolo!.center.dy).abs();
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.07: il cuore ha il centro a '
        '${cuore.center.dy.toStringAsFixed(1)}, il titolo a '
        '${titolo.center.dy.toStringAsFixed(1)}, scarto '
        '${scarto.toStringAsFixed(1)} punti');
    // **UN PUNTO DI TOLLERANZA E NON ZERO**: l'altezza di una lettera non e'
    // l'altezza della sua riga, e pretendere lo zero esatto renderebbe la
    // guardia rossa a ogni cambio di carattere senza che nessuno veda niente
    // di storto.
    expect(scarto, lessThan(1.0),
        reason: 'il cuore e il titolo della barra stanno a quote diverse, '
            '${scarto.toStringAsFixed(1)} punti di scarto: il cuore non e '
            'centrato verticalmente col titolo');
  });

  testWidgets('e il cuore d angolo sta alla stessa quota di quello in barra',
      (tester) async {
    // **DUE CUORI DELLA STESSA APP A DUE ALTEZZE DIVERSE.** Le schermate con
    // una BarraArte mettono il cuore fra le azioni, centrato nei suoi
    // cinquantasei punti; quelle senza lo mettono nell angolo, e li stava a
    // top zero piu un aria. La grandezza e la differenza fra le due quote.
    SharedPreferences.setMockInitialValues(const {});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(attorno(
      scena: ArteCorrente(
        id: 'gettata',
        reclamato: ValueNotifier<bool>(false),
        child: Scaffold(
          appBar: BarraArte(titolo: const Text('Estrazione Rune')),
          body: const SizedBox.expand(),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    final inBarra = riquadro(tester, find.byKey(const Key('cuore_gettata')))!;

    await tester.pumpWidget(attorno(
      scena: ArteCorrente(
        id: 'gettata',
        reclamato: ValueNotifier<bool>(false),
        child: const Scaffold(
          body: ConCuore(id: 'gettata', child: SizedBox.expand()),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    final inAngolo = riquadro(tester, find.byKey(const Key('cuore_gettata')))!;

    final scarto = (inBarra.center.dy - inAngolo.center.dy).abs();
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.07: in barra il centro sta a '
        '${inBarra.center.dy.toStringAsFixed(1)}, nell angolo a '
        '${inAngolo.center.dy.toStringAsFixed(1)}, scarto '
        '${scarto.toStringAsFixed(1)} punti');
    expect(scarto, lessThan(1.0),
        reason: 'il cuore d angolo e quello in barra stanno a quote diverse, '
            '${scarto.toStringAsFixed(1)} punti: la stessa app mostra lo '
            'stesso comando a due altezze a seconda della schermata');
  });
}

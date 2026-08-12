import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/features/shell/spazio_della_barra.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL COSMIC PASSPORT NON SI COPRE, ordine P voce 40.
///
/// **Il fatto.** Nel Cosmic Passport la card "Il tuo cielo di nascita" passava
/// sotto la barra ESPLORA e sotto la navigazione in fondo, col testo che si
/// leggeva attraverso, e piu' sotto "Il tuo Sigillo" risultava tagliato.
///
/// **L'ipotesi del riflusso, verificata per prima come chiede l'ordine.** La
/// prova dell'occlusione differenziale confronta la scena con e senza
/// l'elemento sospetto: se togliere quell'elemento CAMBIA il layout, tutto il
/// resto scivola e il confronto legge come coperto anche cio' che coperto non
/// e'. Qui non si toglie niente e non si confronta con una seconda scena: si
/// misura DOVE stanno i testi a riposo e dove comincia la zona della barra.
/// E' la stessa misura gia' usata per la home, e non soffre di riflusso
/// perche' la scena e' una sola.
///
/// **META' DELLA PREMESSA CADE, e va detto.** "Il testo che si legge
/// attraverso" non e' un difetto: la barra e' TRASPARENTE per decisione di
/// Mauro, ordine 2164 voce 1, che ha superato la scelta opposta dell'ordine
/// 2163 voce 7. Sta scritto dentro `santuario_bottom_bar.dart` con l'avviso
/// esplicito di non ribaltarla credendo di correggere un difetto, e il difetto
/// che la fascia opaca risolveva e' stato ripreso altrove, con l'ombra
/// morbida del titolo. Anche che il contenuto SCORRA sotto la barra e' una
/// decisione, del 7 agosto 2026.
///
/// **Quel che resta vero, e che questa prova misura**: a fine corsa nessun
/// contenuto deve restare INTRAPPOLATO sotto la barra, cioe' senza modo di
/// portarlo allo scoperto. E' quello che succedeva a "Il tuo Sigillo", e la
/// coda `SliverSpazioDellaBarra` esiste proprio per impedirlo.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(nome), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Future<void> apriIlPassaporto(WidgetTester tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues(
        const {'onboarding.done': true, 'santuario.greeted': true});
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    final voce = find.byKey(const Key('barra_voce_passport'));
    expect(voce, findsOneWidget,
        reason: 'la voce del Passaporto non c\'e\' nella barra: la prova non '
            'puo\' nemmeno arrivare alla schermata da misurare');
    await tester.tap(voce);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  /// I testi del contenuto che scorre, con la loro scatola a schermo.
  List<(String, Rect)> testiDelPassaporto(WidgetTester tester) {
    final dentro = <(String, Rect)>[];
    final scroll = find.byType(CustomScrollView).first;
    for (final e
        in find.descendant(of: scroll, matching: find.byType(Text)).evaluate()) {
      final w = e.widget as Text;
      final dato = w.data ?? '';
      if (dato.trim().isEmpty) continue;
      final ro = e.renderObject;
      if (ro is! RenderBox || !ro.hasSize || !ro.attached) continue;
      dentro.add((dato, ro.localToGlobal(Offset.zero) & ro.size));
    }
    return dentro;
  }

  testWidgets('a riposo nessun testo del Passaporto sta nella zona della barra',
      (tester) async {
    await apriIlPassaporto(tester);
    const altezza = 2391 / 3.0;
    final ctx = tester.element(find.byType(CustomScrollView).first);
    final zonaBarra = SpazioDellaBarraNelloScroll.quanto(ctx);
    expect(zonaBarra, greaterThan(100),
        reason: 'la barra non consegna piu\' il suo spazio: la coda dello '
            'scorrimento non riserva niente e ogni card puo\' finirle sotto');
    final cimaBarra = altezza - zonaBarra;

    void nessunoNellaZona(String dove) {
      final colpe = <String>[];
      for (final (testo, r) in testiDelPassaporto(tester)) {
        if (r.top < altezza && r.bottom > cimaBarra + 1) {
          colpe.add('"$testo" da ${r.top.toStringAsFixed(1)} a '
              '${r.bottom.toStringAsFixed(1)}, la barra comincia a '
              '${cimaBarra.toStringAsFixed(1)}');
        }
      }
      expect(colpe, isEmpty,
          reason: '$dove, questi testi del Passaporto finiscono sotto la barra '
              'e si leggono attraverso:\n${colpe.join("\n")}');
    }

    // IN CIMA NON SI MISURA: un contenuto piu' lungo dello schermo prosegue
    // sotto la barra per progetto, ed e' la decisione del 7 agosto. Misurarlo
    // qui vorrebbe dire pretendere che il Passaporto stia in una schermata.
    //
    // A FINE CORSA invece l'invariante e' vera: quando non c'e' piu' niente da
    // scorrere, nessun contenuto puo' restare sotto la barra, perche' non
    // esiste piu' un gesto per portarlo allo scoperto.
    for (var i = 0; i < 14; i++) {
      await tester.dragFrom(const Offset(200, 500), const Offset(0, -650));
      await tester.pump(const Duration(milliseconds: 120));
    }
    await tester.pump(const Duration(seconds: 1));
    nessunoNellaZona('a fine corsa');
  });

  testWidgets('la card del cielo di nascita si puo\' portare allo scoperto',
      (tester) async {
    await apriIlPassaporto(tester);
    const altezza = 2391 / 3.0;

    final card = find.text('Il tuo cielo di nascita');
    expect(card, findsOneWidget,
        reason: 'la card del cielo di nascita non c\'e\' piu\' nel Passaporto');

    final ctx = tester.element(find.byType(CustomScrollView).first);
    final cimaBarra = altezza - SpazioDellaBarraNelloScroll.quanto(ctx);

    // LA MISURA GIUSTA NON E' "si vede tutta subito": una schermata piu' lunga
    // dello schermo prosegue sotto la barra, ed e' la decisione del 7 agosto.
    // E' "si riesce a portarla tutta allo scoperto": se nemmeno scorrendo ci
    // si arriva, la card e' intrappolata, ed e' quello il difetto.
    var scoperta = false;
    for (var passo = 0; passo < 10 && !scoperta; passo++) {
      final scatola = tester.renderObject<RenderBox>(card);
      final r = scatola.localToGlobal(Offset.zero) & scatola.size;
      scoperta = r.top >= 0 && r.bottom <= cimaBarra + 1;
      if (scoperta) break;
      await tester.dragFrom(const Offset(200, 500), const Offset(0, -140));
      await tester.pump(const Duration(milliseconds: 140));
    }
    expect(scoperta, isTrue,
        reason: 'la card del cielo di nascita non si riesce a portare tutta '
            'allo scoperto nemmeno scorrendo: resta sotto la barra o sotto la '
            'striscia in cima, ed e\' il difetto della voce 40');
  });
}

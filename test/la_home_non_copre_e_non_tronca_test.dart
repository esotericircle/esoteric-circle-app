import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/features/shell/spazio_della_barra.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA HOME NON COPRE E NON TRONCA, ordine M voci 1d e 1e.
///
/// Due regole, estese alla home dalla prova dell'occlusione dell'ordine D:
/// la striscia ESPLORA e la barra non passano sopra nessuna card A RIPOSO
/// (in cima l'aria della barra tiene la zona libera, in fondo la coda dello
/// scorrimento fa lo stesso), e nessun testo della home finisce troncato a
/// meta' frase (un maxLines senza puntini e' un taglio secco).
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

  Future<void> monta(WidgetTester tester) async {
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
  }

  /// I testi del CONTENUTO che scorre, con le loro scatole a schermo.
  List<(String, Rect)> testiDelContenuto(WidgetTester tester) {
    final dentro = <(String, Rect)>[];
    final scroll = find.byType(SingleChildScrollView).first;
    for (final e in find
        .descendant(of: scroll, matching: find.byType(Text))
        .evaluate()) {
      final w = e.widget as Text;
      final dato = w.data ?? '';
      if (dato.trim().isEmpty) continue;
      final ro = e.renderObject;
      if (ro is! RenderBox || !ro.hasSize || !ro.attached) continue;
      dentro.add((dato, ro.localToGlobal(Offset.zero) & ro.size));
    }
    return dentro;
  }

  testWidgets(
      'a riposo, in cima e in fondo, nessun testo delle card sta '
      'nella zona della barra', (tester) async {
    await monta(tester);
    const h = 2391 / 3.0;
    final ctx = tester.element(find.byType(SingleChildScrollView).first);
    final zonaBarra = SpazioDellaBarraNelloScroll.quanto(ctx);
    expect(zonaBarra, greaterThan(100),
        reason: 'La barra non consegna piu\' il suo spazio nel MediaQuery: '
            'la coda dello scorrimento non riserva niente.');
    final cimaBarra = h - zonaBarra;

    void nessunoNellaZona(String dove) {
      final colpe = <String>[];
      for (final (testo, r) in testiDelContenuto(tester)) {
        // Conta chi e' davvero a schermo E tocca la zona della barra.
        if (r.top < h && r.bottom > cimaBarra + 1) {
          colpe.add(
              '"${testo.substring(0, testo.length > 40 ? 40 : testo.length)}" '
              '(${r.top.toStringAsFixed(0)}..${r.bottom.toStringAsFixed(0)}, '
              'barra da ${cimaBarra.toStringAsFixed(0)})');
        }
      }
      expect(colpe, isEmpty,
          reason: '$dove, questi testi del contenuto stanno sotto la barra '
              'o la striscia ESPLORA:\n${colpe.join('\n')}');
    }

    // **A RIPOSO IN CIMA NON SI PRETENDE PIU' IL VUOTO, ordine AJ voce
    // 03.** La pretesa veniva dalla decisione del 2164 (a riposo sotto la
    // barra solo cielo), che teneva in piedi una fascia morta di 184 punti
    // fra i Maestri e le arti: Mauro il 17 agosto ha chiesto di toglierla, e
    // adesso lo scaffale scivola sotto la barra a riposo come ogni contenuto
    // che le passa sotto scorrendo. La grandezza che resta e' la CODA: in
    // fondo la zona della barra dev'essere ancora riservata.

    // In fondo: si scorre tutto. La barra laggiu' e' ritirata (torna solo
    // col dito che risale, e quello e' mezzo scorrimento, non riposo), ma la
    // CODA deve riservare comunque la sua zona: se la barra ricomparisse a
    // quel punto, nessuna card le starebbe sotto.
    for (var i = 0; i < 10; i++) {
      await tester.dragFrom(const Offset(200, 500), const Offset(0, -650));
      await tester.pump(const Duration(milliseconds: 120));
    }
    await tester.pump(const Duration(milliseconds: 400));
    nessunoNellaZona('A riposo in fondo');
  });

  testWidgets('nessun testo della home finisce troncato a meta\' frase',
      (tester) async {
    await monta(tester);
    final colpe = <String>[];

    void controlla() {
      for (final e in find.byType(Text).evaluate()) {
        final w = e.widget as Text;
        final dato = w.data ?? '';
        if (dato.trim().isEmpty || w.maxLines == null) continue;
        // I puntini dichiarano la continuazione: il taglio SECCO e' il
        // difetto, "sul tuo segno di" senza nessun segno.
        if (w.overflow == TextOverflow.ellipsis ||
            w.overflow == TextOverflow.fade) {
          continue;
        }
        final ro = e.renderObject;
        if (ro is! RenderBox || !ro.hasSize || !ro.attached) continue;
        final stile = DefaultTextStyle.of(e).style.merge(w.style);
        final tp = TextPainter(
          text: TextSpan(text: dato, style: stile),
          maxLines: w.maxLines,
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.of(e).textScaler,
        )..layout(maxWidth: ro.size.width + 0.5);
        if (tp.didExceedMaxLines) {
          colpe.add(
              '"${dato.substring(0, dato.length > 50 ? 50 : dato.length)}" '
              '(maxLines ${w.maxLines}, largo ${ro.size.width.toStringAsFixed(0)})');
        }
      }
    }

    controlla();
    for (var i = 0; i < 6; i++) {
      await tester.dragFrom(const Offset(200, 500), const Offset(0, -650));
      await tester.pump(const Duration(milliseconds: 120));
      controlla();
    }
    expect(colpe.toSet(), isEmpty,
        reason: 'questi testi della home si troncano a meta\' frase, senza '
            'nemmeno i puntini:\n${colpe.toSet().join('\n')}');
  });
}

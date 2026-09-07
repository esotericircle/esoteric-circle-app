import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/titolo_che_non_si_rompe.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/rituals/dream_rite_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// NESSUN PUNTO CADE DENTRO IL TITOLO. Ordine CW, voce 05.
///
/// **Seconda segnalazione dello stesso fastidio**, e la prima era CQ.1.07.
///
/// **QUALE DELLE DUE E' VERA: la correzione fu fatta e NON e' regredita.** La
/// guardia di quella voce, `la_stella_non_finisce_sotto_il_testo_test.dart`,
/// e' viva e verde ancora oggi. **Guardava pero' l'altro bordo:** spingeva le
/// stelle via dal blocco di testo che comincia al quarantasei per cento
/// dell'altezza, cioe' il confine di SOTTO.
///
/// **Del confine di sopra non si era mai occupato nessuno.** La schermata ha
/// `extendBodyBehindAppBar`, quindi la fascia di cielo passa dietro la barra, e
/// il pavimento della mappa valeva `altezza * 0.06`: **cinquanta punti** su uno
/// schermo alto ottocentoquarantaquattro, mentre la barra col titolo ne occupa
/// **novantaquattro**.
///
/// **L'AREA DI RISPETTO SI MISURA, NON SI STIMA**, come l'ordine chiede: si
/// prende il rettangolo vero del titolo con `getRect` e si guarda ogni punto
/// toccabile contro quello.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzio() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final n in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }
    for (final n in const [
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global'
    ]) {
      m.setMockMethodCallHandler(MethodChannel(n), (c) async => null);
    }
  }

  Future<void> apri(WidgetTester tester) async {
    // **LA FINESTRA E' QUELLA CHE L'ORDINE NOMINA**, 390 per 844.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            // **RIDUCI MOVIMENTO SPENTO, e serve.** Con lui acceso il
            // ripiego a dito non si monta affatto, quindi non ci sarebbe
            // nessuno spostamento da provare e la prova tornerebbe a
            // guardare stelle ferme, che stanno gia' al loro posto.
            disableAnimations: false,
            // La tacca del telefono: senza di lei la barra sarebbe piu' bassa
            // di quanto e' in mano, e la prova misurerebbe uno schermo che
            // nessuno ha.
            padding: EdgeInsets.only(top: 38),
          ),
          child: MaestroScope(
              child: DreamRiteScreen(now: DateTime(2026, 9, 7, 22))),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    // Si dirada la nebbia: prima le stelle non esistono.
    await tester.tap(find.byKey(const Key('dream_fog_skip')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // **SI TRASCINA IL CIELO VERSO L'ALTO, ed e' la parte che conta.**
    //
    // Ferme, le stelle stanno gia' sotto la barra: e' lo SPOSTAMENTO che le
    // porta su, e in prova il giroscopio non esiste. La guardia di CQ.1.07
    // lo diceva gia': *"misurando solo cio' che si vede a schermo non si
    // vedrebbe mai il caso che il fondatore ha visto in mano"*.
    //
    // Il ripiego a dito e' una strada vera, non una scorciatoia: e' quella
    // che usa chi non ha il giroscopio, ed e' limitata a quarantasei punti
    // esattamente come la parallasse.
    await tester.drag(find.byKey(const Key('dream_pan')),
        const Offset(0, -46));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }

  testWidgets('Nessuna stella tocca il rettangolo del titolo', (tester) async {
    silenzio();
    await apri(tester);

    final titolo = find.byType(TitoloCheNonSiRompe);
    expect(titolo, findsOneWidget,
        reason: 'il titolo della schermata non c\'e\', quindi non c\'e\' '
            'nessun rettangolo da rispettare e questa prova non misura niente');
    final riquadroDelTitolo = tester.getRect(titolo);

    final stelle = find.byWidgetPredicate((w) =>
        w.key is ValueKey<String> &&
        (w.key! as ValueKey<String>).value.startsWith('dream_star_'));
    final quante = stelle.evaluate().length;
    expect(quante, greaterThanOrEqualTo(3),
        reason: 'le stelle toccabili a video sono $quante: con meno di tre '
            'questa prova e\' verde per non avere guardato niente');

    final dentro = <String>[];
    for (final elemento in stelle.evaluate()) {
      final r = tester.getRect(find.byWidget(elemento.widget));
      final incrocio = r.intersect(riquadroDelTitolo);
      if (incrocio.width > 0 && incrocio.height > 0) {
        dentro.add('${(elemento.widget.key! as ValueKey<String>).value} a $r');
      }
    }
    expect(dentro, isEmpty,
        reason: 'QUESTI PUNTI CLICCABILI CADONO DENTRO IL TITOLO, e sono '
            '${dentro.length} su $quante:\n${dentro.join("\n")}\n'
            'Titolo a $riquadroDelTitolo. E\' la seconda volta che il '
            'fondatore lo segnala.');
  });

  testWidgets('E nemmeno il loro margine di rispetto', (tester) async {
    silenzio();
    await apri(tester);
    final riquadro = tester.getRect(find.byType(TitoloCheNonSiRompe));
    // Il margine dichiarato dal codice, non uno scelto qui: se domani cambia,
    // questa prova lo segue invece di contraddirlo.
    final conMargine = riquadro.inflate(margineSottoIlTitolo / 2);

    final stelle = find.byWidgetPredicate((w) =>
        w.key is ValueKey<String> &&
        (w.key! as ValueKey<String>).value.startsWith('dream_star_'));
    final vicine = <String>[];
    for (final elemento in stelle.evaluate()) {
      final r = tester.getRect(find.byWidget(elemento.widget));
      final incrocio = r.intersect(conMargine);
      if (incrocio.width > 0 && incrocio.height > 0) {
        vicine.add((elemento.widget.key! as ValueKey<String>).value);
      }
    }
    expect(vicine, isEmpty,
        reason: 'queste stelle stanno dentro il margine di rispetto del '
            'titolo, ${margineSottoIlTitolo.toStringAsFixed(0)} punti: '
            '${vicine.join(", ")}');
  });

  test('La mappa tiene le stelle sotto la soglia che le si passa', () {
    // **LA MAPPA SI INTERROGA ANCHE FUORI DALLO SCHERMO**, perche' in prova
    // il giroscopio non c'e' e l'inclinazione vale zero: misurando solo cio'
    // che si vede non si vedrebbe mai il caso che il fondatore ha in mano.
    const altezza = 844.0;
    const larghezza = 390.0;
    const soglia = 38.0 + kToolbarHeight + margineSottoIlTitolo;
    const estremo = (320.0 + 46.0) * 0.55;
    var guardate = 0;
    final sopra = <String>[];
    for (var i = -10; i <= 10; i++) {
      final off = Offset(0, estremo * i / 10);
      for (var y = 0; y <= 10; y++) {
        guardate++;
        final dove = doveVaLaStella(Offset(0.5, y / 10),
            larghezza: larghezza,
            altezza: altezza,
            off: off,
            sogliaAlta: soglia);
        if (dove.dy < soglia) {
          sopra.add('con spostamento ${off.dy.round()} la stella '
              '${(y / 10).toStringAsFixed(1)} va a ${dove.dy.round()}');
        }
      }
    }
    expect(guardate, greaterThan(100),
        reason: 'posizioni provate $guardate: con poche la prova non '
            'attraversa il bordo e non lo tocca mai');
    expect(sopra, isEmpty,
        reason: 'la mappa porta le stelle sopra la soglia di '
            '${soglia.toStringAsFixed(0)} punti: ${sopra.take(3).join(" | ")}');
  });
}

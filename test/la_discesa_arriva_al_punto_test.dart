import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/disegno_del_sentiero.dart';
import 'package:esoteric_circle/features/sigilli/sentiero_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA DISCESA ARRIVA AL PUNTO RAGGIUNTO, ordine P voce 36.
///
/// **Il difetto, con la riga.** In `_scendiAlPunto` c'era
///
///     final gradini = (50 - accesi).clamp(0, 50);
///     final dove = (50 - gradini) * altezzaDelGradino;   // 92
///
/// Sostituendo, `dove` valeva `accesi * 92`. La lista e' rovesciata, quindi in
/// cima c'e' il 50 e in fondo l'1: con due traguardi accesi lo scorrimento si
/// fermava a 184 punti, cioe' due righe, ed e' il motivo per cui non si
/// muoveva niente. Con zero accesi non si muoveva affatto.
///
/// **La prova vecchia era cieca**: verificava che l'animazione PARTISSE, non
/// dove arrivasse, ed e' per questo che il difetto e' passato. Questa la
/// sostituisce e misura la sola cosa che conta: dove ci si ferma.
///
/// **E sotto il primo difetto ce n'era un secondo.** `altezzaDelGradino` era
/// assunta a 92 mentre le righe portano titoli e frasi di lunghezza diversa:
/// anche col conto corretto il punto d'arrivo sarebbe scivolato. Per questo la
/// misura non e' un numero scritto qui: si legge la riga vera sulla resa.
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

  /// IL CIELO NON SI FERMA MAI, quindi `pumpAndSettle` non torna: il fondo
  /// cosmico ha un'animazione senza fine e l'attesa scadrebbe sempre. Si
  /// avanza a mano oltre i 1.400 millisecondi della discesa, che e' il tempo
  /// dichiarato nella schermata.
  Future<void> lascialaFinire(WidgetTester tester) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 60));
    }
  }

  Future<DiarioDelCammino> diarioCon(Sentiero sentiero, int accesi) async {
    SharedPreferences.setMockInitialValues(const {});
    final diario = DiarioDelCammino();
    await diario.carica();
    for (final t in Sentieri.miniDi(sentiero).take(accesi)) {
      await diario.accendi(t.id);
    }
    return diario;
  }

  Future<void> monta(
    WidgetTester tester, {
    required Sentiero sentiero,
    required DiarioDelCammino diario,
    bool riduciMovimento = false,
  }) async {
    silenzia();
    // LA LARGHEZZA REALE, non una comoda: le righe vanno a capo come sul
    // telefono, e con altezze diverse un conto a righe fisse non puo' tornare.
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
      ],
      child: MediaQuery(
        data: MediaQueryData(disableAnimations: riduciMovimento),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (ctx, child) => MaestroScope(child: child!),
          home: SentieroScreen(sentiero: sentiero),
        ),
      ),
    ));
    await tester.pump();
    await lascialaFinire(tester);
  }

  /// La riga su cui il cammino si e' fermato: il primo NON ancora acceso.
  Traguardo puntoRaggiunto(Sentiero sentiero, int accesi) =>
      Sentieri.miniDi(sentiero)[accesi];

  /// Dove sta la riga a schermo, e quanto e' alta: tutto MISURATO.
  Rect rigaDi(WidgetTester tester, Traguardo traguardo) {
    final scatola = tester.renderObject<RenderBox>(
        find.byKey(Key('gradino_${traguardo.id}')));
    return scatola.localToGlobal(Offset.zero) & scatola.size;
  }

  /// La cima di cio' che scorre: il bordo alto del viewport.
  double cimaDelloScorrimento(WidgetTester tester) {
    final scatola = tester.renderObject<RenderBox>(
        find.byKey(const Key('sentiero_scorrimento')));
    return scatola.localToGlobal(Offset.zero).dy;
  }

  for (final (nome, accesi) in const [
    ('un sentiero vuoto', 0),
    ('un sentiero a due', 2),
    ('un sentiero a meta\'', 25),
  ]) {
    testWidgets('la discesa si ferma sul punto raggiunto, $nome',
        (tester) async {
      const sentiero = Sentiero.costellazione;
      final diario = await diarioCon(sentiero, accesi);
      await monta(tester, sentiero: sentiero, diario: diario);

      final bersaglio = puntoRaggiunto(sentiero, accesi);
      final riga = rigaDi(tester, bersaglio);
      final cima = cimaDelloScorrimento(tester);
      final fondo = cima +
          tester
              .renderObject<RenderBox>(
                  find.byKey(const Key('sentiero_scorrimento')))
              .size
              .height;
      final scarto = (riga.top - cima).abs();
      final mezzaRiga = riga.height / 2;
      final corsa = tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position;
      // IL CASO DI CONFINE E' VERO E NON SI AGGIRA. La lista scende dal 50
      // all'1, quindi il punto raggiunto di chi comincia sta in FONDO: li' non
      // c'e' altro sotto, e nessuno scorrimento puo' portarlo in cima. La
      // misura giusta e' allora doppia: la riga si vede tutta, e ci si e'
      // avvicinati quanto il contenuto consente, cioe' o sta in cima entro
      // mezza riga o la corsa e' finita.
      final inFondoAllaCorsa =
          corsa.pixels >= corsa.maxScrollExtent - 0.5;

      expect(riga.top >= cima - 0.5 && riga.bottom <= fondo + 0.5, isTrue,
          reason: 'con $accesi traguardi accesi il traguardo '
              '"${bersaglio.nome}" non e\' nemmeno a schermo: sta fra '
              '${riga.top.toStringAsFixed(1)} e ${riga.bottom.toStringAsFixed(1)} '
              'mentre il viewport va da ${cima.toStringAsFixed(1)} a '
              '${fondo.toStringAsFixed(1)}. E\' il difetto del conto '
              'rovesciato: la lista scende dal 50 all\'1 e il conto contava '
              'dalla parte sbagliata');

      expect(scarto <= mezzaRiga || inFondoAllaCorsa, isTrue,
          reason: 'con $accesi traguardi accesi lo scorrimento si e\' fermato a '
              '${scarto.toStringAsFixed(1)} punti dal traguardo '
              '"${bersaglio.nome}", oltre mezza riga '
              '(${mezzaRiga.toStringAsFixed(1)}), e la corsa non era finita: '
              'siamo a ${corsa.pixels.toStringAsFixed(1)} su '
              '${corsa.maxScrollExtent.toStringAsFixed(1)}');
    });
  }

  testWidgets(
      'con Riduci Movimento la discesa e\' immediata ma il punto d\'arrivo e\' '
      'lo stesso', (tester) async {
    const sentiero = Sentiero.albero;
    const accesi = 12;

    final conVolo = await diarioCon(sentiero, accesi);
    await monta(tester, sentiero: sentiero, diario: conVolo);
    final dopoIlVolo = rigaDi(tester, puntoRaggiunto(sentiero, accesi)).top -
        cimaDelloScorrimento(tester);

    final senzaVolo = await diarioCon(sentiero, accesi);
    await monta(tester,
        sentiero: sentiero, diario: senzaVolo, riduciMovimento: true);
    final subito = rigaDi(tester, puntoRaggiunto(sentiero, accesi)).top -
        cimaDelloScorrimento(tester);

    expect((dopoIlVolo - subito).abs(), lessThan(1.0),
        reason: 'con Riduci Movimento si arriva in un punto diverso: il moto '
            'si toglie, la destinazione no');
  });

  testWidgets('toccando un punto del disegno si va al suo traguardo',
      (tester) async {
    const sentiero = Sentiero.loto;
    final diario = await diarioCon(sentiero, 6);
    await monta(tester, sentiero: sentiero, diario: diario);

    // Si risale in cima, dove sta il disegno: e' li' che si tocca.
    await tester.drag(
        find.byKey(const Key('sentiero_scorrimento')), const Offset(0, 6000));
    await lascialaFinire(tester);

    // Il quarantesimo mini e' lontano dal punto in cui la discesa si era
    // fermata: se il tocco lo raggiunge, il legame fra disegno ed elenco
    // esiste davvero e non e' un caso.
    final lontano = Sentieri.miniDi(sentiero)[39];
    final punto = GeometriaDelSentiero.punti(sentiero)
        .firstWhere((p) => p.traguardo.id == lontano.id);
    final tela = tester.renderObject<RenderBox>(
        find.byKey(Key('disegno_${sentiero.name}')));
    final origine = tela.localToGlobal(Offset.zero);
    final dove = origine +
        Offset(punto.dove.dx * tela.size.width,
            punto.dove.dy * tela.size.height);

    final prima = rigaDi(tester, lontano).top;
    await tester.tapAt(dove);
    await lascialaFinire(tester);

    final riga = rigaDi(tester, lontano);
    final cima = cimaDelloScorrimento(tester);
    expect((riga.top - cima).abs(), lessThanOrEqualTo(riga.height / 2),
        reason: 'toccando il punto di "${lontano.nome}" dentro il disegno '
            'l\'elenco non e\' andato al suo traguardo: era a $prima, adesso a '
            '${riga.top}, e la cima dello scorrimento sta a $cima');
  });
}

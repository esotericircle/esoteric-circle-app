import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/celebrazione.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// LA PAROLA DI PREMIO STA SU UNA RIGA SOLA. Ordine AU voce 07.
///
/// **Il difetto, sullo screenshot della 2188**: "CONGRATULAZI" a capo "ONI",
/// spezzata in mezzo a una parola, e sotto tutto in maiuscolo senza gerarchia.
///
/// **E' lo stesso difetto che l'ordine AS voce 05 aveva gia' curato**, ma sul
/// NOME del traguardo: nessuno aveva guardato la parola sopra di lui. Per
/// questo la prova non guarda solo la parola: pretende la gerarchia, cioe' che
/// i tre livelli abbiano tre corpi diversi, se no fra un mese ne nasce un'altra
/// dello stesso corpo e siamo daccapo.
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

  /// **TRE MISURE, COMPRESA LA PIU' STRETTA**, come l'ordine chiede: una
  /// parola lunga entra su uno schermo largo e si spezza su uno stretto, quindi
  /// provare solo sul comodo non prova niente.
  const schermi = <String, (Size, double)>{
    'largo, 411x869': (Size(1233, 2607), 3.0),
    'medio, 360x797': (Size(1080, 2391), 3.0),
    'stretto, 320x568': (Size(640, 1136), 2.0),
  };

  Future<void> montaLaFesta(WidgetTester tester, (Size, double) misura) async {
    silenzia();
    SharedPreferences.setMockInitialValues(const {});
    tester.view.physicalSize = misura.$1;
    tester.view.devicePixelRatio = misura.$2;
    addTearDown(tester.view.reset);
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    final traguardo = Sentieri.grandiDi(Sentiero.costellazione).first;
    // Si accende davvero: senza istante la riga della data non comparirebbe, e
    // la prova non potrebbe dire se manca per un difetto o per il dato.
    await diario.accendi(traguardo.id);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MaestroScope(
            maestro: Sentiero.costellazione.maestro, child: child!),
        home: CelebrazioneAScermoPieno(
          traguardi: [traguardo],
          sentieri: const [Sentiero.costellazione],
        ),
      ),
    ));
    await tester.pump();
    // Oltre lo stacco: prima la scheda non e' dipinta e non c'e' niente da
    // misurare.
    await tester.pump(const Duration(milliseconds: 900));
  }

  /// Il `Text` che porta quella chiave, sia che la chiave stia su di lui, sia
  /// che stia su un componente che lo contiene.
  Text testoDi(WidgetTester tester, Key chiave) {
    final diretto = find.byKey(chiave).evaluate().first.widget;
    if (diretto is Text) return diretto;
    return tester.widget<Text>(find
        .descendant(of: find.byKey(chiave), matching: find.byType(Text))
        .first);
  }

  /// Quante righe occupa davvero quel testo, chiesto a chi lo dipinge.
  int righeDi(WidgetTester tester, Key chiave) {
    final elemento = tester.element(find.byKey(chiave));
    final testo = testoDi(tester, chiave);
    final scatola = elemento.renderObject! as RenderBox;
    final pittore = TextPainter(
      text: TextSpan(text: testo.data, style: testo.style),
      textDirection: TextDirection.ltr,
      textAlign: testo.textAlign ?? TextAlign.start,
    )..layout(maxWidth: scatola.size.width);
    return pittore.computeLineMetrics().length;
  }

  for (final voce in schermi.entries) {
    testWidgets('su schermo ${voce.key} la parola di premio non va a capo',
        (tester) async {
      await montaLaFesta(tester, voce.value);
      final righe =
          righeDi(tester, const Key('celebrazione_congratulazioni'));
      final testo =
          testoDi(tester, const Key('celebrazione_congratulazioni'));
      // ignore: avoid_print
      print('ORDINE AU VOCE 07: su ${voce.key} "CONGRATULAZIONI" sta su '
          '$righe righe, corpo ${testo.style?.fontSize?.toStringAsFixed(1)}');
      expect(righe, 1,
          reason: 'la parola di premio va a capo su $righe righe: si spezza '
              'in mezzo, come "CONGRATULAZI / ONI" sulla 2188. Si '
              'rimpicciolisce per entrare, non va a capo');
    });
  }

  testWidgets('il nome del traguardo non e in maiuscolo integrale',
      (tester) async {
    await montaLaFesta(tester, schermi['medio, 360x797']!);
    final nome = testoDi(tester, const Key('celebrazione_nome'));
    final scritto = nome.data ?? '';
    // ignore: avoid_print
    print('ORDINE AU VOCE 07: il nome del traguardo e "$scritto"');
    expect(scritto, isNotEmpty);
    expect(scritto, isNot(scritto.toUpperCase()),
        reason: 'il nome del traguardo e reso in maiuscolo integrale: il '
            'maiuscolo vale SOLO per la parola di premio');
  });

  testWidgets('i tre livelli hanno tre corpi diversi', (tester) async {
    await montaLaFesta(tester, schermi['medio, 360x797']!);
    double corpoDi(Key chiave) => testoDi(tester, chiave).style?.fontSize ?? 0;

    final premio = corpoDi(const Key('celebrazione_congratulazioni'));
    final nome = corpoDi(const Key('celebrazione_nome'));
    final descrizione =
        tester.widget<Text>(find.byKey(const Key('celebrazione_frase')))
                .style
                ?.fontSize ??
            0;
    // ignore: avoid_print
    print('ORDINE AU VOCE 07: i tre corpi sono premio $premio, nome $nome, '
        'descrizione $descrizione');
    expect(premio, greaterThan(nome),
        reason: 'la parola di premio non e piu grande del nome: la card non '
            'ha gerarchia, e prima erano tutti e due 34');
    expect(nome, greaterThan(descrizione),
        reason: 'il nome non e piu grande della descrizione');
  });

  testWidgets('sotto il nome si legge quando e stato raggiunto',
      (tester) async {
    await montaLaFesta(tester, schermi['medio, 360x797']!);
    final quando =
        tester.widget<Text>(find.byKey(const Key('celebrazione_quando')));
    // ignore: avoid_print
    print('ORDINE AU VOCE 07: sotto il nome si legge "${quando.data}"');
    expect(quando.data, startsWith('Obiettivo raggiunto il '),
        reason: 'la riga con la data non c e: richiesta del fondatore ferma '
            'dal 17 agosto');
    // **NON SI INVENTANO DATE**: la riga esiste perche' l'istante esiste nel
    // dato del Sigillo. Per i Sigilli accesi prima che il diario tenesse la
    // data, la riga non deve comparire affatto.
    expect(quando.data, isNot(contains('null')));
  });
}

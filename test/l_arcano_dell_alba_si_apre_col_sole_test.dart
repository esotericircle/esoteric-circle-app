import 'dart:math';

import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/archivio_dell_alba.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/rituals/arcano_dell_alba_screen.dart';
import 'package:esoteric_circle/features/rituals/il_sole_dell_alba.dart';
import 'package:esoteric_circle/features/rituals/tavolo_dei_ventidue.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **L'ARCANO DELL'ALBA SI APRE COL SOLE.** Ordine EL, 25 settembre 2026.
///
/// Il fondatore: *"l'ingresso del dono doveva essere lo stesso del precedente
/// ovvero l'utente che col dito alza il sole verso il cielo e la scena si
/// illumina, era già fatto e funzionava"*. Il gesto viveva nel Rito
/// dell'Alba (`lib/features/rituals/dawn_rite_screen.dart`, commit
/// `8a19e6b8`) e l'ordine DT l'ha cancellato insieme alla schermata, commit
/// `47b3c2be`, **senza che nessuna prova se ne accorgesse**: le prove del Rito
/// sono state tolte con lui, e quelle dell'Arcano misuravano il tavolo.
///
/// Questa guardia cade se l'Arcano dell'Alba si apre senza il sole, se le
/// carte arrivano prima che il sole sia salito, se il dito non lo alza, se un
/// gesto corto lo alza lo stesso, se manca il ripiego del tocco, o se il sole
/// si ripete a chi riapre il dono nello stesso giorno.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final adesso = DateTime(2026, 9, 25, 7, 10);

  void zittisciISensori() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
    for (final n in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Future<void> monta(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider<DiarioDelCammino>.value(
            value: DiarioDelCammino(orologio: () => adesso)),
        ChangeNotifierProvider<QuestionAllowance>.value(
            value: QuestionAllowance()),
        ChangeNotifierProvider<SettingsController>.value(
            value: SettingsController(effettiSonori: false)),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: ArcanoDellAlbaScreen(now: adesso, caso: Random(5)),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  final sole = find.byKey(const Key('arcano_alba_sole'));
  final carte = find.byKey(const Key('arcano_alba_carta_0'));

  /// Quanto e' salito il sole, letto dal pittore della scena.
  double progresso(WidgetTester tester) {
    final pittura = tester.widget<CustomPaint>(
        find.byKey(const Key('arcano_alba_scena_del_sole')));
    return (pittura.painter! as PittoreDellAlba).progresso;
  }

  Future<void> avanza(WidgetTester tester, int decimi) async {
    for (var i = 0; i < decimi; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ArchivioDellAlba.dimenticaLaMemoria();
    zittisciISensori();
  });

  testWidgets('SI APRE COL SOLE SULL\'ORIZZONTE, e le carte non ci sono ancora',
      (tester) async {
    await monta(tester);
    expect(sole, findsOneWidget,
        reason: 'l\'Arcano dell\'Alba si apre senza il gesto del sole');
    expect(find.byKey(const Key('alba_invito_al_gesto')), findsOneWidget,
        reason: 'il sole non invita al gesto');
    expect(progresso(tester), 0,
        reason: 'il sole parte gia\' alzato: non c\'e\' niente da fare');
    expect(find.byType(TavoloDeiVentidue), findsNothing,
        reason: 'il tavolo e\' in scena prima che il sole sia salito');
    expect(carte, findsNothing);
    // Il sole resta ad aspettare: le carte non arrivano da sole.
    await avanza(tester, 30);
    expect(find.byType(TavoloDeiVentidue), findsNothing,
        reason: 'senza il gesto le carte sono arrivate lo stesso');
  });

  testWidgets(
      'IL DITO ALZA IL SOLE VERSO IL CIELO, la scena si illumina e poi '
      'arrivano le carte', (tester) async {
    await monta(tester);
    final dito = await tester.startGesture(tester.getCenter(sole));
    await dito.moveBy(const Offset(0, -20));
    await dito.moveBy(const Offset(0, -110));
    await tester.pump();
    final aMeta = progresso(tester);
    expect(aMeta, greaterThan(0.3),
        reason: 'il dito sale e il sole resta fermo: $aMeta');
    expect(aMeta, lessThan(1));
    await dito.moveBy(const Offset(0, -140));
    await tester.pump();
    expect(progresso(tester), 1,
        reason: 'col dito in cima il sole non e\' salito del tutto');
    await dito.up();
    // La scena illuminata resta ferma un attimo, e le carte non ci sono: il
    // sole finisce di salire a 750 millesimi e la luce resta fino a 1.200, si
    // guarda a meta' di quella luce. Guardata a 800 la prova non vedeva una
    // luce tolta: il fotogramma che costruisce il tavolo non era ancora
    // passato (Regola A, ordine EL).
    await avanza(tester, 10);
    expect(progresso(tester), 1);
    expect(find.byType(TavoloDeiVentidue), findsNothing,
        reason: 'le carte arrivano prima che la scena si sia illuminata');
    await avanza(tester, 22);
    expect(sole, findsNothing,
        reason: 'a sole salito la scena dell\'alba resta sopra le carte');
    expect(
        find.byWidgetPredicate(
            (w) => w.key.toString().contains('arcano_alba_dorso_')),
        findsNWidgets(ArcanoDellAlbaScreen.dorsi),
        reason: 'dopo il sole non arrivano i ventidue dorsi');
  });

  testWidgets('UN GESTO CORTO NON ALZA IL SOLE, e il sole torna giu\'',
      (tester) async {
    await monta(tester);
    final dito = await tester.startGesture(tester.getCenter(sole));
    await dito.moveBy(const Offset(0, -20));
    await dito.moveBy(const Offset(0, -60));
    await tester.pump();
    expect(progresso(tester), greaterThan(0));
    await dito.up();
    await avanza(tester, 30);
    expect(progresso(tester), 0,
        reason: 'lasciato presto, il sole doveva tornare sull\'orizzonte');
    expect(find.byType(TavoloDeiVentidue), findsNothing,
        reason: 'un gesto corto ha fatto arrivare le carte');
  });

  testWidgets('UN TOCCO COMPIE L\'ALBA: il ripiego tattile c\'e\' sempre',
      (tester) async {
    await monta(tester);
    await tester.tap(sole);
    await avanza(tester, 32);
    expect(find.byType(TavoloDeiVentidue), findsOneWidget,
        reason: 'chi non trascina non arriva alle carte');
  });

  testWidgets(
      'RIAPERTO NELLO STESSO GIORNO IL SOLE NON SI RIPETE: si torna al '
      'responso', (tester) async {
    await monta(tester);
    await tester.tap(sole);
    await avanza(tester, 32);
    await tester.tap(carte);
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)));
    await avanza(tester, 25);
    await tester.pumpWidget(const SizedBox());
    await monta(tester);
    await avanza(tester, 5);
    expect(sole, findsNothing,
        reason: 'chi riapre il dono deve rifare il gesto: la scena si rivede '
            'domani, decisione del fondatore del 17 settembre 2026');
    expect(find.byKey(const Key('arcano_alba_dono')), findsOneWidget,
        reason: 'riaprendo non si torna al responso di oggi');
  });
}

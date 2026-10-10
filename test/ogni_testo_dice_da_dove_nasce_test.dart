import 'package:esoteric_circle/core/angels/angel_lore.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/segno_della_provenienza.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/angels/angels_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// OGNI TESTO DICE DA DOVE NASCE. Ordine CS, voce S5.
///
/// **Il difetto.** Il corpus degli Angeli dice di se stesso che le chiavi di
/// lettura *"sono scritte in redazione, non sono tradizione documentata [...]
/// Vanno mostrate come chiave di lettura del Maestro, mai attribuite alla
/// tradizione"*. Quella distinzione viveva nel corpus, non a video: la scheda
/// la faceva a mano con una riga scritta li' e da nessun'altra parte, e
/// l'angelo ingrandito, che mostra gli stessi campi, non la faceva affatto.
/// La fonte del documentato, poi, non compariva da nessuna parte.
///
/// **Cio' che si misura.** Non che esista una riga: che le due famiglie siano
/// **distinte fra loro** e che la fonte sia **nominata**. Una prova che
/// cercasse una scritta qualunque sarebbe verde anche con due segni identici,
/// cioe' con nessuna distinzione.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzio() {
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

  final conOra = BirthIdentity.fromParts(
    birthDate: DateTime(1985, 3, 3),
    birthHour: 7,
    birthMinute: 20,
  );

  Widget veste(Widget child) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: MaestroScope(child: child),
          ),
        ),
      );

  Future<void> monta(WidgetTester tester) async {
    silenzio();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 3200);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(veste(AngelsScreen(identity: conOra)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 3));
  }

  final dallaTradizione = find.byKey(const Key('segno_dalla_tradizione'));
  final dalCerchio = find.byKey(const Key('segno_dal_cerchio'));

  test('Le due provenienze non si leggono allo stesso modo', () {
    final t = SegnoDellaProvenienza.rigaDi(Provenienza.tradizione,
        dettaglio: AngelLore.fonteDelDocumentato);
    final c = SegnoDellaProvenienza.rigaDi(Provenienza.cerchio,
        dettaglio: AngelLore.voceDelMaestro);
    expect(t, isNot(c),
        reason: 'la tradizione e la penna del Cerchio si annunciano con le '
            'stesse parole, quindi il segno non distingue niente');
    expect(t.toUpperCase(), contains('LENAIN'),
        reason: 'il segno del documentato non nomina la fonte: dire che una '
            'cosa viene dalla tradizione senza dire da quale non aggiunge '
            'niente a chi legge');
    expect(t.toUpperCase(), contains('1823'),
        reason: 'manca l\'anno dell\'edizione, che e\' cio\' che rende la '
            'fonte verificabile');
    expect(c.toUpperCase(), contains('MEDORA'),
        reason: 'la lettura del Cerchio non si attribuisce a nessuna voce, '
            'quindi si legge come tradizione');
  });

  test('Le due frasi vengono dal corpus, non dalle schermate', () {
    expect(AngelLore.fonteDelDocumentato.trim(), isNotEmpty,
        reason: 'la fonte del documentato e\' vuota nel corpus');
    expect(AngelLore.voceDelMaestro.trim(), isNotEmpty,
        reason: 'la voce del Maestro e\' vuota nel corpus');
    expect(AngelLore.fonteDelDocumentato, isNot(AngelLore.voceDelMaestro),
        reason: 'le due frasi del corpus sono la stessa');
  });

  testWidgets('La scheda degli Angeli dichiara tutte e due le provenienze',
      (tester) async {
    await monta(tester);
    expect(dallaTradizione, findsWidgets,
        reason: 'il salmo e il dominio non dicono da dove vengono: si leggono '
            'con lo stesso carattere della lettura scritta oggi, e nulla dice '
            'che sono due cose diverse');
    expect(dalCerchio, findsWidgets,
        reason: 'la chiave di lettura non si annuncia come voce del Maestro, '
            'cioe\' viene attribuita alla tradizione');

    final testoTradizione = tester
        .widgetList<Text>(dallaTradizione)
        .map((t) => t.data)
        .whereType<String>()
        .toSet();
    final testoCerchio = tester
        .widgetList<Text>(dalCerchio)
        .map((t) => t.data)
        .whereType<String>()
        .toSet();
    expect(testoTradizione.intersection(testoCerchio), isEmpty,
        reason: 'i due segni portano la stessa scritta, quindi a video la '
            'distinzione non esiste: $testoTradizione');
    for (final riga in testoTradizione) {
      expect(riga.toUpperCase(), contains('LENAIN'),
          reason: 'un segno del documentato a video non nomina la fonte: '
              '"$riga"');
    }
  });

  testWidgets('Il segno sta sopra il testo che qualifica, non alla fine',
      (tester) async {
    await monta(tester);
    final segno = dallaTradizione.first;
    final salmo = find.textContaining('Salmo').first;
    final ySegno = tester.getTopLeft(segno).dy;
    final ySalmo = tester.getTopLeft(salmo).dy;
    expect(ySegno, lessThan(ySalmo),
        reason: 'il segno sta sotto il testo che dovrebbe qualificare, a '
            '$ySegno contro $ySalmo: chi legge scopre la provenienza quando '
            'ha gia\' finito');
  });
}

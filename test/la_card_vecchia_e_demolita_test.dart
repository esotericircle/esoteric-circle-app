import 'dart:io';

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

import 'sorgenti_di_lib.dart';

/// LA CARD VECCHIA E' DEMOLITA. Ordine BE voce 05.
///
/// **Fatto del fondatore, build 2199, maiuscole sue**: "mi ha dato 2
/// traguardi contemporaneamente: uno con la festa delle stelle che girano e
/// l'altro subito dopo SENZA festa e con la card vecchia! ELIMINA TUTTO CIO'
/// CHE E' VECCHIO E GIA' SOSTITUITO!".
///
/// La "card vecchia" era la SOVRIMPRESSIONE BREVE: la seconda strada di
/// `festeggiaInsieme`, un velo scuro senza spirale, senza CONGRATULAZIONI e
/// senza data, riservata ai traguardi mini. E' stata rimossa, non nascosta:
/// ogni traguardo, mini o grande, celebra con la scena piena.
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

  test('BE.05: la sovrimpressione breve non esiste piu\' nel codice', () {
    // **RIMOSSA, NON NASCOSTA**: se qualcuno la riscrivesse, il fondatore
    // rivedrebbe la card vecchia della 2199.
    final celebrazione =
        File('lib/features/sigilli/celebrazione.dart').readAsStringSync();
    for (final resto in const [
      'bool mostraLaSovrimpressione(',
      '_FasciaDellaCelebrazione',
    ]) {
      expect(celebrazione.contains(resto), isFalse,
          reason: 'la card vecchia e\' tornata nel codice: "$resto" vive '
              'ancora in celebrazione.dart (ordine BE voce 05)');
    }
    // E fuori da celebrazione.dart nessuno la chiama piu'.
    for (final f in sorgentiDiLib()) {
      expect(f.readAsStringSync().contains('mostraLaSovrimpressione'), isFalse,
          reason: '${f.path} chiama ancora la sovrimpressione breve');
    }
  });

  testWidgets('BE.05: anche un traguardo MINI celebra con la scena piena',
      (tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues(const {});
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: const Scaffold(body: Center(child: Text('sotto'))),
      ),
    ));
    await tester.pump();

    final mini = Sentieri.miniDi(Sentiero.loto).first;
    expect(mini.eGrande, isFalse,
        reason: 'il campione deve essere un MINI: e\' esattamente il caso '
            'che prendeva la card vecchia');
    // Nel flusso vero la regia ACCENDE prima di celebrare, ed e' l'istante
    // che la data mostra: qui si fa lo stesso.
    diario.accendi(mini.id);
    final contesto = tester.element(find.text('sotto'));
    final comparsa = await Celebrazione.festeggiaInsieme(contesto,
        traguardi: [mini],
        sentieri: const [Sentiero.loto],
        primoInAssoluto: false);
    expect(comparsa, isTrue);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    // La scena piena, con le sue tre firme: la rotta a schermo intero, la
    // parola CONGRATULAZIONI e la data del raggiungimento.
    expect(find.byType(CelebrazioneAScermoPieno), findsOneWidget,
        reason: 'il mini non ha montato la scena piena: la strada della '
            'card vecchia e\' ancora viva da qualche parte');
    expect(find.textContaining('CONGRATULAZIONI'), findsOneWidget,
        reason: 'la scena non porta la parola di premio');
    expect(find.textContaining('Obiettivo raggiunto il'), findsOneWidget,
        reason: 'la scena non porta la data del raggiungimento');
    // ignore: avoid_print
    print('ORDINE BE VOCE 05: il mini "${mini.nome}" celebra a schermo '
        'pieno con parola di premio e data');
  });
}

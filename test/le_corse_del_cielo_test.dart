import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/design_system/components/cosmos_background.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LE CORSE DEL CIELO E LA SOSPENSIONE GIUSTA. Ordine AL voce 01.
///
/// **La misura che ha aperto la voce, dichiarata anche dove l'ipotesi cade.**
/// Le corse a tilt saturo, dalla stessa porta OffsetDeiPiani: polvere 15,
/// fondo 80, medio 105,5, vicino 165,5; scintillio e respiro viaggiano col
/// fondo (80). Confrontate con la testa e5b993f (prima di AJ.01 e AJ.02):
/// IDENTICHE, perche' le due cure hanno cambiato teli, margini e regime del
/// vicino, mai gli offset. L'ipotesi "corse troppo simili" E' CADUTA.
///
/// **La causa vera, misurata**: la sospensione di AJ.01 scattava anche sotto
/// rotte TRASPARENTI (celebrazioni, fogli dal basso, dialoghi): il cosmo
/// VISIBILE dietro si fermava al movimento del dispositivo. La cura: ci si
/// sospende solo quando chi copre e' OPACO.
///
/// La prima prova inchioda i RAPPORTI di corsa fra i piani (la profondita'
/// percepita e' il loro rapporto); la seconda la sospensione giusta.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
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

  testWidgets('le corse dei piani stanno nei rapporti dichiarati',
      (tester) async {
    silenzia();
    final parallasse = ParallaxController();
    parallasse.inclinaPerLaProva(1, 0);
    final piani = OffsetDeiPiani.da(parallasse, conDeriva: false, t: 0);
    final corse = {
      'polvere': piani.polvere.dx,
      'fondo': piani.fondo.dx,
      'medio': piani.medio.dx,
      'vicino': piani.vicino.dx,
    };
    // ignore: avoid_print
    print('ORDINE AL VOCE 01: corse a tilt saturo $corse');
    expect(corse['polvere'], closeTo(15, 0.5),
        reason: 'la polvere deve correre 15 punti a tilt saturo');
    expect(corse['fondo'], closeTo(80, 0.5));
    expect(corse['medio'], closeTo(105.5, 0.5));
    expect(corse['vicino'], closeTo(165.5, 0.5));
    // IL RAPPORTO CHE FA LA PROFONDITA': il vicino corre il doppio del fondo.
    expect(corse['vicino']! / corse['fondo']!, closeTo(2.07, 0.05),
        reason: 'il rapporto vicino su fondo e\' la profondita\' percepita, '
            'ed era 2,07 prima di ogni cura');
  });

  testWidgets(
      'la sospensione scatta sotto le rotte opache e NON sotto le '
      'trasparenti', (tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues(
        const {'onboarding.done': true, 'santuario.greeted': true});
    CosmosBackground.quantiSospesi = 0;
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    final contesto = tester.element(find.byType(Navigator).first);

    // UNA ROTTA TRASPARENTE (come una celebrazione o un foglio): il cielo
    // dietro resta visibile e NON deve sospendersi.
    Navigator.of(contesto).push(PageRouteBuilder<void>(
      opaque: false,
      pageBuilder: (_, __, ___) => const SizedBox.expand(),
    ));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    // ignore: avoid_print
    print('ORDINE AL VOCE 01: sospesi sotto la trasparente: '
        '${CosmosBackground.quantiSospesi}');
    expect(CosmosBackground.quantiSospesi, 0,
        reason: 'dietro una rotta trasparente il cielo e\' visibile e si e\' '
            'sospeso lo stesso: e\' il cosmo fermo visto da Mauro sulla 2179');
    Navigator.of(contesto).pop();
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }

    // UNA ROTTA OPACA: la sospensione deve scattare come da ordine AJ.
    Navigator.of(contesto).push(MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: SizedBox.expand())));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(CosmosBackground.quantiSospesi, greaterThanOrEqualTo(1),
        reason: 'sotto una rotta opaca la sospensione di AJ.01 deve restare '
            'viva: senza, gli scatti tornano');
  });
}

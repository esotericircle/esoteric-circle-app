import 'dart:io';

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/components/cosmos_background.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA REGOLA DEL CIELO VALE PER TUTTI. Ordine AJ voce 01, prima meta'.
///
/// **Il difetto di Mauro**: aprendo qualunque funzionalita' tutto diventa a
/// scatti. La caccia per enumerazione (nel manifesto AJ) ha trovato tre
/// famiglie: la schermata COPERTA che continuava a ricostruire il cosmo a
/// ogni tick del sensore e a tenere vivo il giro da trenta secondi; i
/// repeat() senza la guardia di Riduci Movimento (meditazione, risonanza,
/// tramonto); e i pittori che creano sfocature per fotogramma, censiti coi
/// numeri e curati per costo (i restanti sono dichiarati nel manifesto).
///
/// Questa prova sorveglia le due cure trasversali e la convergenza del
/// sentiero, che era il censimento del 16 agosto.
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

  testWidgets('il cielo coperto da una rotta si sospende, e riprende al ritorno',
      (tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues(
        const {'onboarding.done': true, 'santuario.greeted': true});
    final servizi = AppServices.offline();
    CosmosBackground.quantiSospesi = 0;
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: servizi));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(CosmosBackground.quantiSospesi, 0,
        reason: 'a casa aperta nessun cielo deve essere sospeso');

    final contesto = tester.element(find.byType(Navigator).first);
    Navigator.of(contesto)
        .push(DomainScreen.route(maestro: Maestro.medora, services: servizi));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    // ignore: avoid_print
    print('ORDINE AJ VOCE 01: cieli sospesi sotto il dominio: '
        '${CosmosBackground.quantiSospesi}');
    expect(CosmosBackground.quantiSospesi, greaterThanOrEqualTo(1),
        reason: 'la home e\' coperta dal dominio e il suo cielo non si e\' '
            'sospeso: continua a ricostruire sotto la funzionalita\' aperta, '
            'ed e\' il difetto degli scatti');

    Navigator.of(contesto).pop();
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(CosmosBackground.quantiSospesi, 0,
        reason: 'tornati a casa il cielo doveva riprendere, e risulta ancora '
            'sospeso');
  });

  test('i tre repeat scoperti portano la guardia di Riduci Movimento', () {
    var osservati = 0;
    final scoperti = <String>[];
    for (final percorso in const [
      'lib/features/maestri/aura/meditation/meditation_screen.dart',
      'lib/features/onboarding/resonance_screen.dart',
      'lib/features/rituals/sunset_rune_screen.dart',
    ]) {
      osservati++;
      final sorgente = File(percorso).readAsStringSync();
      final guardato = sorgente
              .contains('IL GIRO PARTE SOLO SENZA RIDUCI MOVIMENTO') ||
          sorgente.contains("IL GIRO DELL'ALONE PARTE SOLO SENZA RIDUCI");
      if (!guardato) scoperti.add(percorso);
    }
    // **QUANTE OSSERVAZIONI, e cade se sono zero.**
    // ignore: avoid_print
    print('ORDINE AJ VOCE 01: file col giro osservati $osservati, senza '
        'guardia ${scoperti.length}');
    expect(osservati, 3);
    expect(scoperti, isEmpty,
        reason: 'questi giri infiniti hanno perso la guardia di Riduci '
            'Movimento: ${scoperti.join(" | ")}');
  });
}

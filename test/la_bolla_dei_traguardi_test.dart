import 'dart:io';

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/features/sigilli/sentiero_screen.dart';
import 'package:esoteric_circle/features/shell/navigation_controller.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// I SENTIERI NELLA BOLLA "I TUOI TRAGUARDI". Ordine AK voce 04, voce di
/// Mauro del 17 agosto.
///
/// Le tre porte dei sentieri erano una colonna nuda in cima al Passaporto:
/// ora vivono in una bolla di sezione col titolo suo, nello stile delle
/// bolle del Passaporto, e restano tre ListTile che aprono i loro sentieri.
/// La prova monta l'app vera, va al Passaporto e misura: la bolla esiste col
/// titolo, contiene le tre porte, e la prima porta naviga davvero.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('la bolla esiste, porta il titolo, e le porte navigano',
      (tester) async {
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
    SharedPreferences.setMockInitialValues(
        const {'onboarding.done': true, 'santuario.greeted': true});
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 797);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    tester
        .element(find.byType(Navigator).first)
        .read<NavigationController>()
        .goToPassport();
    for (var i = 0; i < 16; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    // **LA FESTA SI CONGEDA PRIMA DI TOCCARE, come farebbe la persona.** La
    // visita del Passaporto matura traguardi e la celebrazione copre lo
    // schermo intero: il tocco sulla porta finiva sui pulsanti della
    // condivisione. Trovato con l'ordine AL voce 08, quando la testata piu'
    // corta ha spostato le porte esattamente sotto quei pulsanti.
    for (var giro = 0; giro < 3; giro++) {
      final continua = find.byKey(const Key('celebrazione_continua'));
      if (continua.evaluate().isEmpty) break;
      await tester.tap(continua, warnIfMissed: false);
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 120));
      }
    }

    final bolla = find.byKey(const Key('bolla_dei_traguardi'));
    expect(bolla, findsOneWidget,
        reason: 'la bolla dei traguardi non esiste nel Passaporto');
    expect(
        find.descendant(
            of: bolla, matching: find.byKey(const Key('titolo_dei_traguardi'))),
        findsOneWidget,
        reason: 'la bolla non porta il titolo "I tuoi traguardi"');
    expect(find.text('I tuoi traguardi'), findsOneWidget);
    // **LE PORTE SI CONTANO PER CHIAVE, NON PER TIPO.** Fino al 31 agosto
    // 2026 qui si contavano i ListTile della bolla, e i ListTile della bolla
    // erano i sentieri. Con l ordine CG dentro la bolla e entrata anche la
    // porta dei Ricordi, e la prova cadeva dicendo quattro invece di tre: il
    // difetto era suo, perche contava un contenitore al posto di una cosa.
    // Adesso guarda le chiavi porta_, che sono i sentieri e nient altro, e
    // una porta nuova nella bolla non la fa piu cadere a torto.
    final porte = find.descendant(
        of: bolla,
        matching: find.byWidgetPredicate((w) =>
            w is ListTile &&
            w.key is ValueKey<String> &&
            (w.key as ValueKey<String>).value.startsWith('porta_')));
    expect(porte, findsNWidgets(3),
        reason: 'la bolla deve contenere le TRE porte dei sentieri, ne trova '
            '${porte.evaluate().length}');

    // LA PRIMA PORTA NAVIGA DAVVERO.
    await tester.tap(porte.first, warnIfMissed: false);
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(find.byType(SentieroScreen), findsOneWidget,
        reason: 'toccando la prima porta il sentiero non si apre');
  });

  test("la colonna nuda non esiste piu', la bolla sta nel sorgente", () {
    final sorgente = File('lib/features/passport/cosmic_passport_screen.dart')
        .readAsStringSync();
    expect(sorgente.contains('bolla_dei_traguardi'), isTrue);
    expect(sorgente.contains("'I tuoi traguardi'"), isTrue,
        reason: 'il titolo di Mauro non sta nel sorgente della bolla');
  });
}

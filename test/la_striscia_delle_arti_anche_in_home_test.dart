import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sorgenti_di_lib.dart';

/// LA STRISCIA "SCOPRI ALTRE ARTI" STA ANCHE IN FONDO ALLA HOME, E UNA SOLA.
///
/// Ordine 2161, voce 4. Due regole a guardia:
/// - la home la MOSTRA davvero: si monta l'app dall'avvio, si scorre fino in
///   fondo e la si trova. Il precedente della 2156 impone di scorrere: una
///   fascia fu dichiarata sparita mentre c'era, oltre il bordo dello schermo.
/// - la striscia e' UNA: un widget condiviso, usato dalla home e dal dominio.
///   Una seconda copia del widget o del suo titolo nel codice e' una caduta,
///   perche' due copie divergono sempre.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(nome),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  // **LAPIDE: dall'ordine 2161 voce 4 all'ordine EN la striscia "Le altre
  // arti del Cerchio" stava anche in fondo alla home**, e questa prova la
  // cercava scorrendo fino in fondo. **Dall'ordine EO voce 09** il fondatore
  // ha scritto che le righe della home *"prendono il posto delle strisce di
  // arti che oggi stanno sotto il blocco dei Maestri"*: in home la striscia
  // non c'e' piu', e in fondo c'e' l'ultima riga, "La tua energia". La
  // striscia resta nel dominio, che l'ordine non tocca su questo.
  testWidgets(
      'scorrendo la home fino in fondo si trova l\'ultima riga, non la '
      'striscia', (tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    // SI SCORRE DAVVERO, come farebbe un dito: il precedente della 2156
    // vieta di giudicare la home guardando solo la prima schermata.
    final scroll = find.byType(SingleChildScrollView).first;
    for (var i = 0; i < 30; i++) {
      await tester.drag(scroll, const Offset(0, -500), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 120));
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('riga_titolo_la_tua_energia')), findsOneWidget,
        reason: 'scorrendo la home fino in fondo l\'ultima riga, "La tua '
            'energia", non compare: ordine EO voce 09');
    expect(find.byKey(const Key('other_arts_strip'), skipOffstage: false),
        findsNothing,
        reason: 'in home c\'e\' ancora la striscia delle altre arti: le righe '
            'dovevano prenderne il posto');
    expect(find.text('Le altre arti del Cerchio'.toUpperCase()), findsNothing);
  });

  test('la striscia e\' UNA nel codice, non una copia per posto', () {
    final lib = sorgentiDiLib();
    var definizioni = 0;
    var titoli = 0;
    final montaggi = <String>[];
    for (final f in lib) {
      final testo = f.readAsStringSync();
      definizioni += 'class StrisciaAltreArti'.allMatches(testo).length;
      // Con gli apici: si conta il letterale che finisce a video, non le
      // volte che i commenti nominano la striscia per raccontarla.
      titoli += "'Le altre arti del Cerchio'".allMatches(testo).length;
      final usi = 'StrisciaAltreArti('.allMatches(testo).length;
      if (usi > 0 && !f.path.contains('striscia_altre_arti.dart')) {
        for (var i = 0; i < usi; i++) {
          montaggi.add(f.path.replaceAll('\\', '/'));
        }
      }
      expect(testo.contains('_OtherArtsStrip'), isFalse,
          reason: 'In ${f.path} vive ancora _OtherArtsStrip: la striscia '
              'privata doveva sparire nel widget condiviso.');
    }
    expect(definizioni, 1,
        reason: 'La striscia ha $definizioni definizioni: deve averne UNA, '
            'nel punto condiviso. Una copia in piu\' e\' la seconda porta.');
    expect(titoli, 1,
        reason: 'Il titolo "Le altre arti del Cerchio" compare $titoli '
            'volte nel codice: se e\' piu\' di una, qualcuno ha copiato la '
            'striscia invece di usarla.');
    montaggi.sort();
    expect(
        montaggi,
        // **LAPIDE: fino all'ordine EN i montaggi erano due, home e
        // dominio.** Dall'ordine EO voce 09 la home monta le righe, e la
        // striscia resta solo nel dominio.
        ['lib/features/maestri/maestro_screen.dart'],
        reason: 'La striscia deve essere montata ESATTAMENTE una volta, nel '
            'dominio: trovata invece in $montaggi.');
  });
}

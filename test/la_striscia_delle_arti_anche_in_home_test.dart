import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/arts/arti_preferite.dart';
import 'package:esoteric_circle/features/maestri/widgets/striscia_altre_arti.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
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

  testWidgets('scorrendo la home fino in fondo la striscia si trova, intera',
      (tester) async {
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
    for (var i = 0; i < 20; i++) {
      await tester.drag(scroll, const Offset(0, -500), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 120));
    }
    // Fino in fondo DAVVERO: se la striscia e' solo affacciata al bordo, il
    // trascinamento orizzontale di piu' avanti cadrebbe fuori dallo schermo.
    await tester.pump(const Duration(milliseconds: 300));

    final striscia = find.byKey(const Key('other_arts_strip'));
    expect(striscia, findsOneWidget,
        reason: 'Scorrendo la home fino in fondo la striscia "Scopri altre '
            'arti del Cerchio" non compare mai: la voce 4 dell\'ordine 2161 '
            'la vuole in fondo alla home, sotto lo scaffale delle tue arti.');
    // SectionTitle porta il titolo in maiuscolo: si cerca cio' che si vede.
    expect(find.text('Le altre arti del Cerchio'.toUpperCase()), findsOneWidget,
        reason: 'La striscia c\'e\' ma senza il suo titolo.');

    // L'ENUMERAZIONE DAL CATALOGO: in home le arti mostrate sono quelle che
    // il criterio condiviso calcola con corrente nullo e lo scaffale vero.
    // Non un conto scritto a mano: lo stesso criterio, chiamato qui.
    final contesto = tester.element(striscia);
    final gia = Provider.of<ArtiPreferiteController?>(contesto, listen: false)
            ?.ids
            .toSet() ??
        const <String>{};
    final attese = artiDaScoprire(null, gia: gia, giorno: DateTime.now());
    expect(attese, isNotEmpty,
        reason: 'Il criterio non propone niente in home: o lo scaffale '
            'contiene gia\' tutto, o il criterio si e\' rotto.');
    // La lista e' orizzontale e PIGRA: le tessere oltre il bordo non
    // esistono finche' non si scorre. Si scorre quindi anche la striscia,
    // nell'ordine in cui il criterio le propone.
    for (final arte in attese) {
      final tessera =
          find.descendant(of: striscia, matching: find.text(arte.title));
      final lista =
          find.descendant(of: striscia, matching: find.byType(ListView));
      for (var i = 0; i < 8 && tessera.evaluate().isEmpty; i++) {
        await tester.drag(lista.first, const Offset(-250, 0),
            warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 120));
      }
      expect(
        tessera,
        findsOneWidget,
        reason: 'Il criterio propone "${arte.title}" ma la home non la '
            'mostra nemmeno scorrendo la striscia: la striscia non sta '
            'leggendo il catalogo.',
      );
    }
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
        [
          'lib/features/maestri/maestro_screen.dart',
          'lib/features/santuario/santuario_screen.dart',
        ],
        reason: 'La striscia deve essere montata ESATTAMENTE due volte, home '
            'e dominio, dallo stesso widget: trovata invece in $montaggi.');
  });
}

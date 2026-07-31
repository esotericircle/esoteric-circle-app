import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esoteric_circle/features/onboarding/sigillo_step.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Il primo avvio mostra il rituale "Il Risveglio" a passi, poi il Santuario
/// come home; le aperture successive vanno dirette al Santuario.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenceSensors() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final name in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(name),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  // Avanza di un passo toccando l'invito a proseguire.
  Future<void> tapContinua(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('onboarding_continue')));
    await settle(tester);
  }

  testWidgets('Primo avvio: attraversa Il Risveglio e apre il cielo di nascita',
      (tester) async {
    silenceSensors();
    // Nessun flag salvato: e' la primissima apertura.
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await settle(tester);

    // Il rituale e' in cima, sopra la home, e apre con l'accoglienza.
    expect(find.byKey(const Key('onboarding_risveglio')), findsOneWidget);
    expect(find.text('Il Risveglio'), findsOneWidget);

    // Accoglienza -> data -> ora -> luogo (saltato) -> nome.
    await tapContinua(tester); // dall'accoglienza alla data
    expect(find.textContaining('Sole in'), findsOneWidget); // segno reale
    await tapContinua(tester); // data -> ora
    await tapContinua(tester); // ora -> luogo
    await tapContinua(tester); // luogo saltato -> nome

    // Il nome sblocca il proseguimento.
    await tester.enterText(
        find.byKey(const Key('risveglio_nome_field')), 'Marco');
    await settle(tester);
    await tapContinua(tester); // nome -> vocativo

    // Il vocativo.
    await tester.tap(find.byKey(const Key('vocativo_lui')));
    await settle(tester);
    await tapContinua(tester); // vocativo -> sigillo

    // Il sigillo si tiene premuto per sigillare il rito: si apre la coda del
    // Risveglio col cielo reale di nascita (BirthSkyHero), da cui si legge la
    // carta natale ornata.
    expect(find.byKey(const Key('risveglio_sigillo')), findsOneWidget);
    // Il Sigillo si tiene premuto per il tempo dichiarato, poi il trionfo
    // scorre prima del passaggio: un long press secco non basta piu', e non
    // deve bastare, perche' il trionfo va visto.
    final dito = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('risveglio_sigillo'))));
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump(SigilloStep.attesa + const Duration(milliseconds: 60));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 160));
    }
    await dito.up();
    await settle(tester);

    // Il rito a passi non c'e' piu'. In scena c'e' il primo TRIONFO, quello
    // dell'Animale Guida: i trionfi vengono subito dopo il numero della vita, e
    // il cielo di nascita arriva dopo di loro. Prima il cielo era la prima
    // tappa, quindi fra il numero e i suoi trionfi si infilava una schermata.
    expect(find.byKey(const Key('onboarding_risveglio')), findsNothing);
    expect(find.byKey(const Key('trionfo_animale')), findsOneWidget);
  });

  testWidgets('Aperture successive vanno dirette al Santuario', (tester) async {
    silenceSensors();
    // Il flag c'e' gia': l'onboarding non si ripete.
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    await tester.pumpWidget(EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await settle(tester);

    expect(find.byKey(const Key('onboarding_risveglio')), findsNothing);
    expect(find.byType(SantuarioScreen), findsOneWidget);
  });
}

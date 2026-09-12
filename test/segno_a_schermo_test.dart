import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/features/santuario/greeting_controller.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA MISURA SI FA DOVE L'UTENTE GUARDA, cioe' a schermo.
///
/// **Perche' esiste questa prova accanto a `segno_vero_test`.** Il segno solare
/// era gia' sorvegliato dalla Ronda, ed era verde, e non ha impedito niente: lo
/// strato statico controllava che la stringa comparisse in qualche file fuori
/// dal motore, e ci compariva anche dentro il controller che restituiva il
/// segnaposto; lo strato dinamico confrontava due date sulla funzione pura, che
/// infatti funziona benissimo. Nessuno dei due arrivava alla schermata.
///
/// E' una MISURA CIECA: cambia l'input e la sorveglianza resta verde mentre a
/// schermo il valore non si muove. Qui la terza domanda della Ronda, "cambiando
/// l'input l'output cambia", si pone MONTANDO LA SCHERMATA e leggendo il testo.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenceSensors() {
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

  /// Monta la home con una data di nascita e restituisce tutto il testo a video.
  Future<String> testoConNascita(WidgetTester tester, DateTime? nascita) async {
    silenceSensors();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2392);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final identita = nascita == null
        ? BirthIdentity.example
        : BirthIdentity.fromParts(birthDate: nascita);

    await tester.pumpWidget(MultiProvider(
      // Una chiave diversa a ogni montaggio. Senza, il secondo `pumpWidget`
      // AGGIORNA l'albero invece di ricrearlo, il `create` del provider non
      // viene richiamato e la seconda data di nascita non entra mai: la prova
      // confronterebbe due volte lo stesso profilo e sarebbe cieca proprio
      // sulla cosa che deve misurare.
      key: ValueKey(nascita),
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(
            create: (_) => ProfileController(identity: identita)),
        ChangeNotifierProvider(create: (_) => GreetingController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: SantuarioScreen(clock: () => DateTime(2026, 7, 30, 21)),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    return tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .join(' | ');
  }

  testWidgets('Cambiando la data di nascita, il segno a schermo cambia',
      (tester) async {
    // LA TRAPPOLA, dichiarata: la data di prova dell'app e l'identita'
    // d'esempio sono entrambe del 15 giugno, che e' GEMELLI, cioe' proprio il
    // segno che stava cablato. Una prova scritta con quella data sarebbe verde
    // col difetto e senza. Qui si confrontano due date di DUE segni diversi, e
    // nessuna delle due e' Gemelli.
    final conCancro = await testoConNascita(tester, DateTime(1975, 7, 6));
    expect(conCancro, contains('Cancro'),
        reason: 'con una data di nascita del Cancro la home non dice Cancro: '
            'il segno mostrato non discende dalla data');

    final conAcquario = await testoConNascita(tester, DateTime(1980, 2, 2));
    expect(conAcquario, contains('Acquario'),
        reason:
            'cambiata la data di nascita il testo a schermo non cambia: e\' '
            'una misura cieca, il motore calcola e la schermata non guarda');
    expect(conAcquario, isNot(contains('Cancro')),
        reason: 'a schermo restano tutti e due i segni: qualcuno tiene il '
            'vecchio valore invece di ricalcolarlo');
  });

  testWidgets('Senza data di nascita la home non nomina nessun segno',
      (tester) async {
    final senza = await testoConNascita(tester, null);
    for (final segno in const [
      'Gemelli',
      'Cancro',
      'Leone',
      'Vergine',
      'Bilancia',
      'Scorpione',
      'Sagittario',
      'Capricorno',
      'Acquario',
      'Pesci',
      'Ariete',
      'Toro',
    ]) {
      expect(senza, isNot(contains(segno)),
          reason: 'chi non ha ancora dato la sua data si vede attribuire il '
              'segno $segno: quando il segno manca deve mancare, e la frase '
              'va scritta in modo da reggere senza');
    }
  });
}

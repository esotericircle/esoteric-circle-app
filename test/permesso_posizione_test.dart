import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/santuario/sky_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Il permesso di posizione, nei suoi due esiti.
///
/// Sul telefono il tocco su "attiva la posizione" non faceva comparire nessuna
/// richiesta di sistema. La causa: si usciva PRIMA di chiedere il permesso, se
/// il servizio di posizione del telefono era spento. E in ogni caso di
/// fallimento il messaggio era lo stesso, quindi chi negava e chi aveva il GPS
/// spento leggevano la stessa frase, sbagliata per uno dei due.
class _SorgenteFinta extends SkyLocation {
  _SorgenteFinta(this._risposta);

  final RispostaPosizione _risposta;
  int chiamate = 0;

  @override
  bool get available => true;

  @override
  Future<SkyPlace?> resolve() async => (await chiedi()).luogo;

  @override
  Future<RispostaPosizione> chiedi() async {
    chiamate++;
    return _risposta;
  }

  @override
  Future<SkyPlace?> resolveSeConcesso() async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // La schermata del cielo ricorda se la posizione e' gia' stata concessa:
  // senza le preferenze la lettura fallisce e l'invito non arriva mai.
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<_SorgenteFinta> apri(
      WidgetTester tester, RispostaPosizione risposta) async {
    final sorgente = _SorgenteFinta(risposta);
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        home: MaestroScope(child: SkyOverviewScreen(location: sorgente)),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    // Il pre-avviso gentile precede sempre la richiesta di sistema.
    expect(find.byKey(const Key('sky_location_prompt')), findsOneWidget,
        reason: 'il pre-avviso non e\' comparso');
    await tester.tap(find.text('Orienta il cielo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    return sorgente;
  }

  testWidgets('Accettando, la richiesta parte davvero', (tester) async {
    final s = await apri(
        tester,
        const RispostaPosizione(EsitoPosizione.concessa,
            SkyPlace(latitude: 45.6, longitude: 8.85)));
    expect(s.chiamate, 1, reason: 'nessuna richiesta e\' partita');
  });

  testWidgets('Concesso: il cielo si orienta e lo dichiara', (tester) async {
    await apri(
        tester,
        const RispostaPosizione(EsitoPosizione.concessa,
            SkyPlace(latitude: 45.6, longitude: 8.85)));
    expect(find.byKey(const Key('sky_location_concessa')), findsOneWidget);
    // "dove ti trovi" e non piu' "dove sei adesso": l'avverbio e' sparito da
    // questa schermata perche' il cielo non e' di adesso, ed e' il LUOGO a
    // restare quello attuale.
    expect(find.textContaining('dove ti trovi'), findsOneWidget);
  });

  testWidgets('Negato: si dichiara il ripiego e si offre la via ai permessi',
      (tester) async {
    await apri(tester, const RispostaPosizione(EsitoPosizione.negata));
    expect(find.byKey(const Key('sky_location_negata')), findsOneWidget);
    expect(find.textContaining('cielo della tua nascita'), findsOneWidget);
    expect(find.text('Permessi'), findsOneWidget,
        reason: 'nessuna via d\'uscita: e\' un vicolo cieco');
  });

  testWidgets('Servizio spento: si manda alle impostazioni giuste',
      (tester) async {
    await apri(
        tester, const RispostaPosizione(EsitoPosizione.servizioSpento));
    expect(find.textContaining('posizione del telefono è spenta'),
        findsOneWidget);
    // Impostazioni del DISPOSITIVO, non dei permessi dell'app: mandare ai
    // permessi chi ha il GPS spento e' un giro a vuoto.
    expect(find.text('Impostazioni'), findsOneWidget);
  });
}

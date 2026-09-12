import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/feature_flags/feature_flag_service.dart';
import 'package:esoteric_circle/features/santuario/greeting_controller.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_empty_state.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/features/maestri/widgets/busto_del_maestro.dart';
import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:esoteric_circle/features/santuario/widgets/maestro_bust.dart'
    as santuario;
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sorgenti_di_lib.dart';

/// IL BUSTO E' LA FORMA DEL MAESTRO IN ALTO, ordine I voce 1.
///
/// Dove un Maestro compare in alto si mostra il BUSTO, il ritaglio dalla vita
/// in su che sfuma in basso, dalla porta unica `BustoDelMaestro`. L'unica
/// eccezione e' la home "Il Cerchio", dove i tre restano interi dietro la
/// carta: la guardia cade se una schermata mostra la figura intera, e cade
/// anche se la home smette di mostrarla intera.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('la scelta dell\'immagine vive in un punto solo, enumerato', () {
    // L'ENUMERAZIONE sul sorgente: ogni file che tocca l'avatar del Maestro
    // (il campo `avatarAsset` o la cartella degli avatar) deve stare
    // nell'elenco dichiarato. Un file nuovo che se lo prende da se' e' una
    // seconda porta, e la prova cade nominandolo.
    const ammessi = {
      // LA PORTA. E' lei a scegliere l'immagine e a ritagliarla.
      'lib/features/maestri/widgets/busto_del_maestro.dart',
      // L'ECCEZIONE: la home Il Cerchio, i tre interi dietro la carta.
      'lib/features/santuario/widgets/maestro_bust.dart',
      // IL TONDO DEL VOLTO: il cerchietto di header, lente e bolla della
      // chat. Non e' la figura in alto, e' un altro elemento, con la sua
      // inquadratura misurata e le sue prove.
      'lib/features/maestri/widgets/maestro_bust.dart',
      // LA CARTA DELLA SCELTA nel Risveglio: il Maestro non presiede una
      // schermata, e' un candidato da scegliere, intero nella sua carta.
      'lib/features/onboarding/widgets/maestro_card.dart',
      // La definizione del percorso, accanto al Maestro stesso.
      'lib/core/maestro/maestro.dart',
    };
    final colpe = <String>[];
    for (final f in sorgentiDiLib()) {
      final percorso = f.path.replaceAll(r'\', '/');
      final s = f.readAsStringSync();
      if (!s.contains('avatarAsset') && !s.contains('avatars_webp')) continue;
      if (!ammessi.contains(percorso)) colpe.add(percorso);
    }
    expect(colpe, isEmpty,
        reason: 'questi file scelgono da se\' l\'immagine del Maestro invece '
            'di passare dalla porta unica BustoDelMaestro:\n${colpe.join('\n')}');
  });

  Future<void> pompa(WidgetTester tester, Widget schermata) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => GreetingController()),
        ChangeNotifierProvider(
          create: (ctx) =>
              FeatureFlagService(entitlement: ctx.read<EntitlementService>())
                ..initialize(),
        ),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: schermata,
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('nei tre domini c\'e\' il busto canonico, mai la figura intera',
      (tester) async {
    for (final m in Maestro.values) {
      await pompa(tester, DomainScreen(maestro: m));
      final busto = find.byType(BustoDelMaestro);
      expect(busto, findsOneWidget,
          reason: '${m.displayName}: il dominio non passa dalla porta unica '
              'del busto.');
      // La grandezza e' quella canonica della Stesa, identica per i tre:
      // stessa altezza, quindi taglio inferiore sulla stessa linea.
      expect(tester.getSize(busto).height, BustoDelMaestro.altezzaCanonica,
          reason: '${m.displayName}: il busto non e\' alla grandezza '
              'canonica.');
      expect(find.byType(santuario.MaestroBust), findsNothing,
          reason: '${m.displayName}: nel dominio compare la carta della '
              'figura intera, che e\' della sola home.');
    }
  });

  testWidgets('la chat vuota mostra il busto', (tester) async {
    await pompa(
        tester,
        const Scaffold(
            body: ChatEmptyState(
                maestro: Maestro.caligo, greeting: 'Benvenuto nel cerchio.')));
    expect(find.byType(BustoDelMaestro), findsOneWidget,
        reason: 'La chat vuota non passa dalla porta unica del busto.');
  });

  testWidgets('la Stesa mostra il busto di Medora dalla porta unica',
      (tester) async {
    await pompa(tester, const StesaTreCarteScreen(seed: 7));
    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(BustoDelMaestro), findsOneWidget,
        reason: 'La Stesa non passa dalla porta unica del busto.');
  });

  testWidgets('la home Il Cerchio resta l\'eccezione: i tre interi',
      (tester) async {
    await pompa(
        tester, SantuarioScreen(clock: () => DateTime(2026, 8, 11, 21)));
    await tester.pump(const Duration(milliseconds: 800));
    // I tre Maestri interi dietro la carta: la guardia cade anche se la home
    // smette di mostrarli interi, perche' l'eccezione e' voluta quanto la
    // regola.
    expect(find.byType(santuario.MaestroBust), findsNWidgets(3),
        reason: 'La home Il Cerchio non mostra piu\' i tre Maestri interi '
            'dietro la carta.');
    expect(find.byType(BustoDelMaestro), findsNothing,
        reason: 'Nella home e\' comparso il busto ritagliato: li\' i tre '
            'restano interi.');
  });
}

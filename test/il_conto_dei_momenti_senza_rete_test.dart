import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/account_del_cerchio.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/identity/quando_chiedere_la_custodia.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/santuario/greeting_controller.dart';
import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL CONTO DEI MOMENTI SENZA RETE NON DIVENTA UN ERRORE SENZA PADRONE.**
/// Ordine GA voce 11, 20 ottobre 2026, difetto 14 della ricognizione.
///
/// Il fatto, letto in Crashlytics sulla build 2314: 24 eventi FATALI
/// "[cloud_firestore/unavailable]" e "permission-denied" lanciati da
/// `FirestoreMaestroMemoryRepository.quantiMomenti`, chiamata dalla home in
/// `_forseChiediLaCustodia` con un'attesa nuda. La home apre l'invito a
/// custodire il cielo dopo il primo fotogramma, e chiede alla memoria
/// quanti momenti ci sono: sei letture di Firestore. Senza rete, o con
/// l'accesso non ancora pronto, la lettura lancia, e l'eccezione esce da
/// una richiamata dopo il fotogramma che nessuno aspetta: il cruscotto la
/// conta come un crollo dell'app, e il primo avviso di chi usa il Cerchio
/// senza account (ordine BE voce 07, "una volta, subito") non compare.
///
/// Padre (Regola C): ordine N voce 1c, commit `df7551f1` dell'11 agosto
/// 2026, che ha messo l'invito nella home con l'attesa su `quantiMomenti`;
/// la stessa attesa nuda nell'area account era gia' stata curata
/// dall'ordine AL voce 06, e qui no.
void main() {
  Future<void> monta(WidgetTester tester, Map<String, Object> disco) async {
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      'santuario.greeted': true,
      ...disco,
    });
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    final servizi = AppServices(
      ai: const UnavailableMaestroAiProvider(),
      memory: _MemoriaSenzaRete(),
      memoryPersistent: true,
    );
    final account = AccountDelCerchio(porta: _PortaAnonima())..rileggi();
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<AppServices>.value(value: servizi),
        ChangeNotifierProvider<AccountDelCerchio>.value(value: account),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => GreetingController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: SantuarioScreen(clock: () => DateTime(2026, 10, 19, 21)),
      ),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  testWidgets(
      'senza rete il primo avviso compare lo stesso, e nessun errore esce '
      'dalla home', (tester) async {
    // Chi non e' mai stato avvisato: la regola dice "una volta, subito",
    // senza aspettare i momenti. Il conto che non arriva vale zero.
    await monta(tester, const {});
    expect(find.byKey(const Key('invito_a_custodire')), findsOneWidget,
        reason: 'senza rete la lettura dei momenti ha fermato il primo '
            'avviso a chi usa il Cerchio senza account');
  });

  testWidgets(
      'senza rete, a chi e\' gia\' stato avvisato, l\'invito non compare e '
      'niente esplode', (tester) async {
    // Avvisato ieri: senza momenti contati l'invito tace, come deve.
    await monta(tester, {
      QuandoChiedereLaCustodia.chiaveUltimoInvito:
          DateTime(2026, 10, 18).toIso8601String(),
    });
    expect(find.byKey(const Key('invito_a_custodire')), findsNothing);
  });
}

/// La memoria di Firestore senza rete: ogni conto lancia come quella vera.
class _MemoriaSenzaRete extends InMemoryMaestroMemoryRepository {
  @override
  Future<int> quantiMomenti() async => throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
        message: 'The service is currently unavailable.',
      );
}

/// Un account anonimo, come quello di chi non si e' ancora registrato.
class _PortaAnonima implements PortaDellIdentita {
  @override
  String? get uid => 'uid-di-prova';

  @override
  bool get anonimo => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/astro/moon_phase.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/santuario/function_shelf.dart';
import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lo scaffale delle funzioni del Santuario e il nome reale della persona.
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

  group('Ordinamento dello scaffale', () {
    test('L\'ordine iniziale privilegia le funzioni popolari', () {
      final order = FunctionShelf.ordered().map((f) => f.id).toList();
      expect(order.first, 'tarot_spread_three');
      expect(order, contains('synastry_vip'));
      expect(order, contains('archetype_test'));
      expect(order, contains('face_constellation'));
    });

    test('La classifica d\'uso porta in testa le funzioni piu\' usate', () {
      final order =
          FunctionShelf.ordered(['meditation', 'synastry_vip']).map((f) => f.id);
      expect(order.take(2), ['meditation', 'synastry_vip']);
      // Le altre restano, nessuna funzione va persa.
      expect(order.length, FunctionShelf.functions.length);
      expect(order.toSet().length, FunctionShelf.functions.length);
    });

    test('Almeno una funzione dello scaffale e\' viva', () {
      expect(FunctionShelf.functions.any((f) => f.live), isTrue);
      expect(FunctionShelf.functions.firstWhere((f) => f.id == 'synastry_vip').live,
          isTrue);
    });
  });

  group('Copy della Luna coerente con la fase', () {
    MoonPhase phase(String name, {required bool waxing, double illum = 0.5}) =>
        MoonPhase(
            fraction: waxing ? 0.25 : 0.75,
            illumination: illum,
            waxing: waxing,
            italianName: name);

    test('Alla Luna nuova il verbo non è cala né cresce', () {
      final line = SantuarioScreen.medoraMoonFragment(
          phase('Luna nuova', waxing: false, illum: 0.01));
      expect(line, isNot(contains('cala')));
      expect(line, isNot(contains('cresce')));
      expect(line, contains('buio'));
    });

    test('Alla Luna piena il verbo non è cresce né cala', () {
      final line = SantuarioScreen.medoraMoonFragment(
          phase('Luna piena', waxing: false, illum: 0.99));
      expect(line, isNot(contains('cresce')));
      expect(line, isNot(contains('cala')));
      expect(line, contains('culmine'));
    });

    test('Nelle fasi intermedie resta cresce o cala con la percentuale', () {
      final cresce = SantuarioScreen.medoraMoonFragment(
          phase('Luna crescente', waxing: true, illum: 0.3));
      expect(cresce, contains('cresce'));
      expect(cresce, contains('30%'));
      final cala = SantuarioScreen.medoraMoonFragment(
          phase('Gibbosa calante', waxing: false, illum: 0.7));
      expect(cala, contains('cala'));
    });
  });

  group('Nome reale della persona', () {
    test('Usa il nome del profilo, mai il nome del tier', () {
      final withName = ProfileController(
          profile: UserProfile(displayName: 'Sofia'));
      expect(withName.vocative, 'Sofia');
      expect(withName.vocative, isNot('Viandante'));
    });

    test('Senza nome, un vocativo neutro di brand', () {
      final noName = ProfileController(profile: UserProfile.empty);
      expect(noName.vocative, ProfileController.neutralVocative);
      expect(noName.vocative, isNot('Viandante'));
    });
  });

  testWidgets('Il Santuario mostra lo scaffale, non la vecchia bolla Sinastria',
      (tester) async {
    silenceSensors();
    await tester.pumpWidget(EsotericCircleApp(services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Lo scaffale sotto l'eroe adesso e' UNO SOLO e si chiama "Le tue arti":
    // "Le funzioni del Cerchio" lo sostituiva, e per un ordine sono rimaste
    // tutte e due, cioe' due titoli e due elenchi della stessa cosa.
    expect(find.byKey(const Key('tue_arti_titolo')), findsOneWidget);
    expect(find.text('Le funzioni del Cerchio'), findsNothing,
        reason: 'la sezione vecchia resta in scena accanto alla nuova');
    // Lo scaffale personale e' abitato. Quali arti ci siano lo decide il seme,
    // che dipende dal Maestro assegnato: la prova non pretende un id preciso,
    // verifica che ci siano tessere apribili.
    expect(find.byWidgetPredicate((w) => w.key is ValueKey<String> &&
        (w.key! as ValueKey<String>).value.startsWith('tua_arte_')),
        findsWidgets,
        reason: 'lo scaffale personale e comparso vuoto nel Santuario');

    // Nessuna bolla Sinastria sovrapposta all'immagine, come prima.
    expect(find.byKey(const Key('santuario_sinastria')), findsNothing);
  });
}

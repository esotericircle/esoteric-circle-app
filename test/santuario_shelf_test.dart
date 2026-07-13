import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/santuario/function_shelf.dart';
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

  group('Nome reale della persona', () {
    test('Usa il nome del profilo, mai il nome del tier', () {
      final withName = ProfileController(
          profile: const UserProfile(displayName: 'Sofia'));
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

    // Lo scaffale e le sue card esistono (ListView shrinkWrap li costruisce).
    expect(find.byKey(const Key('santuario_shelf')), findsOneWidget);
    expect(find.byKey(const Key('shelf_synastry_vip')), findsOneWidget);
    expect(find.byKey(const Key('shelf_tarot_spread_three')), findsOneWidget);

    // Nessuna bolla Sinastria sovrapposta all'immagine, come prima.
    expect(find.byKey(const Key('santuario_sinastria')), findsNothing);
  });
}

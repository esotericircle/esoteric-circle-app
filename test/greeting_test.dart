import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/daily_rituals.dart';
import 'package:esoteric_circle/features/santuario/greeting_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Il saluto per nome della primissima apertura del Santuario: una volta sola,
/// col Maestro di turno del giorno, sottotitolo sempre attivo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Saluta alla prima apertura, non alla seconda', () async {
    final first = GreetingController(clock: () => DateTime(2026, 7, 13));
    await first.prepare(name: 'Sofia');
    expect(first.text, isNotNull);
    expect(first.text, contains('Sofia'));
    // Il Maestro di turno e' quello della rotazione del giorno.
    expect(first.maestro, DailyRituals.dawnMaestro(DateTime(2026, 7, 13)));

    // Una seconda apertura non ripete il saluto.
    final second = GreetingController(clock: () => DateTime(2026, 7, 13));
    await second.prepare(name: 'Sofia');
    expect(second.text, isNull);
  });

  test('Il saluto si nasconde dopo essere stato visto', () async {
    final controller = GreetingController(clock: () => DateTime(2026, 7, 13));
    await controller.prepare(name: 'Sofia');
    expect(controller.text, isNotNull);
    controller.dismiss();
    expect(controller.text, isNull);
  });

  test('La frase del saluto e nella voce del Maestro, col nome', () {
    expect(GreetingController.greetingFor(Maestro.medora, 'Sofia'),
        'Sofia, il cielo ti riconosce. Entra nel cerchio.');
    expect(GreetingController.greetingFor(Maestro.aura, 'Sofia'),
        contains('Sofia'));
    expect(GreetingController.greetingFor(Maestro.caligo, 'Sofia'),
        contains('soglia'));
  });
}

import 'package:esoteric_circle/features/onboarding/widgets/sensory_reveal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Scala dell\'aiuto universale', () {
    const help = RevealHelp();

    test('prima dei tre secondi nessuna guida: invita solo l\'oggetto', () {
      expect(
          help.showCoach(
              sinceStart: const Duration(seconds: 1), progress: 0),
          isFalse);
      expect(
          help.showSafetyTap(
              sinceStart: const Duration(seconds: 1),
              attemptStalled: false,
              progress: 0),
          isFalse);
    });

    test('dopo tre secondi compaiono le silhouette', () {
      expect(
          help.showCoach(
              sinceStart: const Duration(seconds: 3), progress: 0.1),
          isTrue);
    });

    test('un tentativo che si arena mostra subito l\'invito toccabile', () {
      expect(
          help.showSafetyTap(
              sinceStart: const Duration(seconds: 4),
              attemptStalled: true,
              progress: 0.3),
          isTrue);
    });

    test('senza tentativi l\'invito toccabile arriva comunque dopo l\'attesa',
        () {
      expect(
          help.showSafetyTap(
              sinceStart: const Duration(seconds: 8),
              attemptStalled: false,
              progress: 0),
          isTrue);
    });

    test('a rito quasi concluso le guide si spengono', () {
      expect(
          help.showCoach(
              sinceStart: const Duration(seconds: 10), progress: 0.95),
          isFalse);
      expect(
          help.showSafetyTap(
              sinceStart: const Duration(seconds: 10),
              attemptStalled: true,
              progress: 1.0),
          isFalse);
    });
  });
}

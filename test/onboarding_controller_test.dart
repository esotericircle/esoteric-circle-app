import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/features/onboarding/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingController', () {
    test('data e luogo sono obbligatori per completare', () {
      final c = OnboardingController();
      expect(c.isComplete, isFalse);
      expect(c.canProceed, isFalse); // passo data senza data

      c.setDate(DateTime(1990, 6, 15));
      expect(c.canProceed, isTrue);
      expect(c.isComplete, isFalse); // manca il luogo

      c.setPlace(BirthPlaces.all.first);
      expect(c.isComplete, isTrue);
    });

    test('il passo ora e\' opzionale e proseguibile', () {
      final c = OnboardingController();
      c.setDate(DateTime(1990, 6, 15));
      c.goToStep(OnboardingStep.time.index);
      expect(c.canProceed, isTrue); // ora opzionale
    });

    test('ora non conosciuta azzera l\'ora', () {
      final c = OnboardingController();
      c.setTime(const TimeOfDay(hour: 10, minute: 30));
      expect(c.time, isNotNull);
      c.setTimeUnknown(true);
      expect(c.time, isNull);
      expect(c.timeUnknown, isTrue);
    });

    test('build produce i dettagli, con ora esclusa se non conosciuta', () {
      final c = OnboardingController();
      c.setDate(DateTime(1988, 2, 20));
      c.setTime(const TimeOfDay(hour: 8, minute: 15));
      c.setPlace(BirthPlaces.all.first);
      var details = c.build();
      expect(details, isNotNull);
      expect(details!.hasTime, isTrue);

      c.setTimeUnknown(true);
      details = c.build();
      expect(details!.hasTime, isFalse);
    });

    test('build e\' null se manca un obbligatorio', () {
      final c = OnboardingController();
      c.setDate(DateTime(1990, 6, 15));
      expect(c.build(), isNull); // manca il luogo
    });
  });
}

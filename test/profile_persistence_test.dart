import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/birth_place.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/identity/profile_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Il profilo esteso: la concordanza al vocativo che pilota i testi, l'ora di
/// nascita che puo' mancare, e la persistenza in locale ritrovata al riavvio.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Concordanza al vocativo', () {
    test('agree sceglie la forma giusta, neutro senza desinenza', () {
      String frase(CourtesyForm c) => c.agree(
            masculine: 'sei nato',
            feminine: 'sei nata',
            neutral: 'hai visto la luce',
          );
      expect(frase(CourtesyForm.masculine), 'sei nato');
      expect(frase(CourtesyForm.feminine), 'sei nata');
      expect(frase(CourtesyForm.neutral), 'hai visto la luce');
      // La scelta non ancora fatta ripiega sulla forma neutra, mai sul maschile.
      expect(frase(CourtesyForm.unknown), 'hai visto la luce');
    });

    test('il benvenuto e\' concordato', () {
      expect(CourtesyForm.masculine.welcome, 'Benvenuto');
      expect(CourtesyForm.feminine.welcome, 'Benvenuta');
      expect(CourtesyForm.neutral.welcome, 'Ti do il benvenuto');
    });
  });

  group('Ora di nascita opzionale', () {
    test('senza ora si ancora a mezzogiorno e lo dichiara', () {
      final id = BirthIdentity.fromParts(birthDate: DateTime(1990, 6, 15));
      expect(id.hasBirthTime, isFalse);
      expect(id.birthMoment.hour, 12);
      expect(id.birthDate, DateTime(1990, 6, 15));
    });

    test('con ora la conserva', () {
      final id = BirthIdentity.fromParts(
        birthDate: DateTime(1990, 6, 15),
        birthHour: 2,
        birthMinute: 30,
      );
      expect(id.hasBirthTime, isTrue);
      expect(id.birthMoment.hour, 2);
      expect(id.birthMoment.minute, 30);
    });
  });

  group('Persistenza del profilo', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('salva e ritrova profilo e nascita, ora e luogo inclusi', () async {
      const store = ProfileStore();
      await store.saveProfile(const UserProfile(
        displayName: 'Marco',
        courtesyForm: CourtesyForm.masculine,
      ));
      await store.saveIdentity(BirthIdentity.fromParts(
        birthDate: DateTime(1988, 3, 21),
        birthHour: 7,
        birthMinute: 15,
        birthPlace: const BirthPlace(
          city: 'Torino',
          latitude: 45.07,
          longitude: 7.69,
          timeZoneId: 'Europe/Rome',
          utcOffsetMinutes: 60,
        ),
      ));

      final loaded = await store.load();
      expect(loaded.profile!.displayName, 'Marco');
      expect(loaded.profile!.courtesyForm, CourtesyForm.masculine);
      expect(loaded.identity!.birthDate, DateTime(1988, 3, 21));
      expect(loaded.identity!.hasBirthTime, isTrue);
      expect(loaded.identity!.birthMoment.hour, 7);
      expect(loaded.identity!.birthPlace!.city, 'Torino');
      expect(loaded.identity!.birthPlace!.timeZoneId, 'Europe/Rome');
      expect(loaded.identity!.birthPlace!.utcOffsetMinutes, 60);
    });

    test('ora ignota non finisce nei dati salvati', () async {
      const store = ProfileStore();
      await store.saveIdentity(
          BirthIdentity.fromParts(birthDate: DateTime(2001, 12, 5)));
      final loaded = await store.load();
      expect(loaded.identity!.hasBirthTime, isFalse);
      expect(loaded.identity!.birthMoment.hour, 12);
    });

    test('il controller idrata dal locale sostituendo il seme della Demo',
        () async {
      SharedPreferences.setMockInitialValues({
        'profile.name': 'Giulia',
        'profile.courtesy': 'feminine',
        'profile.birthDate': '1995-07-09',
        'profile.hasBirthTime': false,
      });
      final controller = ProfileController();
      // Prima del load vale il seme della Demo.
      expect(controller.vocative, 'Sofia');
      await controller.load();
      expect(controller.vocative, 'Giulia');
      expect(controller.courtesy, CourtesyForm.feminine);
      expect(controller.identity.birthDate, DateTime(1995, 7, 9));
    });

    test('senza nulla salvato il controller resta sul seme, senza errori',
        () async {
      final controller = ProfileController();
      await controller.load();
      expect(controller.vocative, 'Sofia');
    });
  });
}

import 'dart:io';

import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/identity/profile_store.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Le cose che possono far respingere l'app in revisione oppure esporre chi la
/// usa. Nessuna e' estetica.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Il diritto all\'oblio cancella davvero', () {
    test('Nessuna chiave personale sopravvive, foto del volto compresa',
        () async {
      // Si parte da un telefono pieno: profilo, identita' col luogo, foto del
      // volto, memoria dei riti, identita' del dispositivo.
      SharedPreferences.setMockInitialValues({
        'device.id': 'abc123',
        'sunset_rune.settimana': '[1,2,3]',
        'archetipo.storico': 'qualcosa',
        'allowance.count': 2,
        'app_check_debug_token': 'da-non-toccare',
        'onboarding.done': true,
      });

      const store = ProfileStore();
      final controller = ProfileController(store: store);
      controller.setProfile(const UserProfile(displayName: 'Costanza'));
      controller.setIdentity(BirthIdentity.fromParts(
        birthDate: DateTime(1985, 3, 3),
        birthHour: 7,
        birthMinute: 20,
      ));
      controller.setAvatarPhoto(Uint8List.fromList([1, 2, 3, 4, 5]));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      // Prima: le chiavi personali ci sono, la foto si rilegge dal disco.
      final prima = await SharedPreferences.getInstance();
      await prima.reload();
      final personaliPrima = prima
          .getKeys()
          .where((k) => k.startsWith('profile.'))
          .toList();
      expect(personaliPrima, isNotEmpty,
          reason: 'il telefono deve essere pieno prima di svuotarlo');
      expect(await store.loadAvatarPhoto(), isNotNull);

      // La persona esercita il diritto all'oblio.
      await controller.forget();

      // Dopo: nessuna chiave personale, nemmeno una.
      final dopo = await SharedPreferences.getInstance();
      await dopo.reload();
      for (final k in dopo.getKeys()) {
        expect(k.startsWith('profile.'), isFalse,
            reason: 'sopravvive la chiave personale $k');
      }
      expect(dopo.getKeys().contains('device.id'), isFalse);
      expect(dopo.getKeys().contains('sunset_rune.settimana'), isFalse);
      expect(dopo.getKeys().contains('archetipo.storico'), isFalse);
      expect(dopo.getKeys().contains('allowance.count'), isFalse);

      // La fotografia non si recupera piu': si verifica il VALORE, non la
      // chiave, perche' e' il volto della persona a dover sparire.
      expect(await store.loadAvatarPhoto(), isNull);

      // Cio' che della persona non parla resta: il token di debug non e' suo.
      expect(dopo.getString('app_check_debug_token'), 'da-non-toccare');

      // E l'app non la conosce piu', nemmeno ricostruendo il controller.
      final rinato = ProfileController(store: store);
      await rinato.load();
      // Il controller riparte dal profilo dimostrativo, che e' dichiarato:
      // quel che conta e' che della persona non resti niente.
      expect(rinato.profile.displayName, isNot('Costanza'));
      expect(rinato.identity.isExample, isTrue);
      expect(rinato.identity.birthMoment.year, isNot(1985));
      expect(rinato.avatarPhoto, isNull);
    });
  });

  group('Android non porta fuori i dati personali', () {
    test('Il manifest esclude le preferenze dal backup', () {
      final manifest =
          File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
      expect(manifest.contains('android:fullBackupContent'), isTrue,
          reason: 'manca la regola di backup per Android 11 e precedenti');
      expect(manifest.contains('android:dataExtractionRules'), isTrue,
          reason: 'manca la regola per Android 12 e successivi');

      // Le regole devono escludere davvero il file delle preferenze, dove sta
      // la fotografia del volto: dichiararle senza escludere nulla non serve.
      for (final nome in const [
        'android/app/src/main/res/xml/backup_rules.xml',
        'android/app/src/main/res/xml/data_extraction_rules.xml',
      ]) {
        final f = File(nome);
        expect(f.existsSync(), isTrue, reason: 'manca $nome');
        final testo = f.readAsStringSync();
        expect(testo.contains('FlutterSharedPreferences'), isTrue,
            reason: '$nome non esclude le preferenze');
        expect(testo.contains('exclude'), isTrue);
      }
    });
  });

  group('La release non e\' firmata con la chiave di debug', () {
    test('Il Gradle non usa la firma di debug nel blocco release', () {
      final gradle =
          File('android/app/build.gradle.kts').readAsStringSync();
      final release = gradle.substring(gradle.indexOf('buildTypes'));
      expect(release.contains('getByName("debug")'), isFalse,
          reason: 'la release e\' ancora firmata con la chiave di debug, che '
              'sta sul disco di chiunque abbia Flutter');
      expect(gradle.contains('key.properties'), isTrue,
          reason: 'la firma deve leggere da un file non versionato');
      // E quel file non deve poter finire su Git.
      final ignore = File('.gitignore').readAsStringSync();
      expect(ignore.contains('key.properties'), isTrue);
    });
  });

  group('Firestore mette un tetto a quel che il client scrive', () {
    test('Le regole impongono una dimensione massima', () {
      final regole = File('firestore.rules').readAsStringSync();
      expect(regole.contains('request.resource.size()'), isTrue,
          reason: 'senza tetto un client compromesso riempie il progetto');
      expect(regole.contains('allow write: if'), isTrue);
    });
  });
}

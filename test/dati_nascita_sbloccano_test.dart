import 'dart:io';

import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/birth_place.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/identity/profile_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// I DATI DI NASCITA SI SALVANO, E SBLOCCANO IL MOTORE ASTROLOGICO.
///
/// **Verifica dell'Architetto, che non rifaccio.** La callable `natalChart`
/// risponde HTTP 400 e il servizio a monte HTTP 401: sono vivi tutti e due. E
/// `functions/src/validate.ts` PRETENDE otto campi, fra cui ora, minuti,
/// latitudine e longitudine: se uno manca rifiuta con `invalid-argument` e non
/// chiama il motore.
///
/// **Quindi non c'e' nessun difetto di rete.** La carta natale non arriva
/// perche' l'app non ha l'ora, e nemmeno il luogo. Questa e' la voce che accende
/// il motore per tutti.
///
/// Gli anelli si misurano UNO PER UNO, con una prova ciascuno: una sola prova
/// che dice "l'ora manca" non direbbe DOVE si perde.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  const torino = BirthPlace(
    city: 'Torino',
    latitude: 45.07,
    longitude: 7.69,
    timeZoneId: 'Europe/Rome',
    utcOffsetMinutes: 120,
  );

  test('Anello 1: ora e luogo entrano nel modello', () {
    final id = BirthIdentity.fromParts(
      birthDate: DateTime(1975, 7, 6),
      birthHour: 9,
      birthMinute: 30,
      birthPlace: torino,
    );
    expect(id.hasBirthTime, isTrue, reason: 'l\'ora non entra nel modello');
    expect(id.birthPlace, isNotNull, reason: 'il luogo non entra nel modello');
  });

  test('Anello 2: finiscono nell\'archivio', () async {
    await const ProfileStore().saveIdentity(BirthIdentity.fromParts(
      birthDate: DateTime(1975, 7, 6),
      birthHour: 9,
      birthMinute: 30,
      birthPlace: torino,
    ));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('profile.hasBirthTime'), isTrue);
    expect(prefs.getInt('profile.birthHour'), 9);
    expect(prefs.getString('profile.place'), isNotNull,
        reason: 'il luogo non arriva nell\'archivio, e senza latitudine e '
            'longitudine la funzione rifiuta prima di chiamare il motore');
  });

  test('Anello 3: sopravvivono alla chiusura completa dell\'app', () async {
    final primo = ProfileController();
    primo.setIdentity(BirthIdentity.fromParts(
      birthDate: DateTime(1975, 7, 6),
      birthHour: 9,
      birthMinute: 30,
      birthPlace: torino,
    ));
    await Future<void>.delayed(Duration.zero);

    // Si riapre l'app: un controller nuovo che rilegge l'archivio. Non si
    // rilegge lo stesso oggetto in memoria, che direbbe di si' comunque.
    final secondo = ProfileController();
    await secondo.load();

    expect(secondo.identity.hasBirthTime, isTrue,
        reason: 'l\'ora non sopravvive alla chiusura dell\'app');
    expect(secondo.identity.birthMoment.hour, 9);
    expect(secondo.identity.birthPlace, isNotNull,
        reason: 'il luogo non sopravvive alla chiusura dell\'app');
  });

  test('Anello 4: la carta natale ha tutti gli otto campi che servono',
      () async {
    // La funzione pretende year, month, day, hour, minute, lat, lng, tz_str: se
    // uno solo manca rifiuta con invalid-argument e non chiama il motore. Questa
    // prova guarda il PONTE, cioe' cio' che l'app manderebbe.
    final primo = ProfileController();
    primo.setIdentity(BirthIdentity.fromParts(
      birthDate: DateTime(1975, 7, 6),
      birthHour: 9,
      birthMinute: 30,
      birthPlace: torino,
    ));
    await Future<void>.delayed(Duration.zero);
    final secondo = ProfileController();
    await secondo.load();

    final dettagli = secondo.identity.toBirthDetails();
    expect(dettagli.hasTime, isTrue, reason: 'manca hour e minute');
    expect(dettagli.time, isNotNull, reason: 'manca hour e minute');
    expect(dettagli.place, isNotNull, reason: 'mancano lat e lng');
    expect(dettagli.place!.timezone, isNotEmpty, reason: 'manca tz_str');
  });

  test('Anello 5: le porte da cui entrano ora e luogo sono enumerate', () {
    // La data di nascita e' gia' entrata da DUE porte. Se l'ora la segue, sono
    // le stesse due: correggerne una lascerebbe l'altra a riscrivere il difetto.
    final porte = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final p = f.path.replaceAll(Platform.pathSeparator, '/');
      if (p.endsWith('profile_controller.dart')) continue;
      if (f.readAsStringSync().contains('setIdentity(')) porte.add(p);
    }
    expect(porte.length, 2,
        reason: 'le porte che scrivono i dati di nascita sono ${porte.length} '
            '($porte): una sola vuol dire che il dato torna irreversibile per '
            'chi ha gia\' concluso il Risveglio');
  });
}

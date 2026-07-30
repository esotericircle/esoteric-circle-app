import 'dart:io';

import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/birth_place.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// L'ORA E IL LUOGO SOPRAVVIVONO ALLA CHIUSURA DELL'APP.
///
/// **Una causa sola per due difetti che sembravano distinti.** Il fondatore ha
/// segnalato che l'app non registra l'ora di nascita, e che la Carta natale gira
/// sempre sul ripiego. Sono la stessa cosa.
///
/// **Dove NON si perdeva.** L'archivio scrive l'ora e la rilegge: ogni anello
/// della persistenza regge, e lo dimostra `ora_di_nascita_test`, che li misura
/// uno per uno apposta per non confonderli.
///
/// **Dove si perdeva.** `BirthIdentityController.setBirth` era chiamato in UN
/// SOLO punto di tutto il progetto, alla fine del Risveglio, e quel controller
/// vive solo in memoria. Chi riapriva l'app lo trovava vuoto: da li' l'app
/// dichiarava mancante un'ora che era stata data, e la carta natale partiva
/// senza luogo, che il client rifiuta sollevando PRIMA di chiamare la rete. Il
/// ripiego non era la rete che non risponde: era che non si chiedeva niente a
/// nessuno.
///
/// E' la stessa forma gia' contata nove volte: una verita' che vive in due
/// posti, di cui uno solo persiste.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  final identita = BirthIdentity.fromParts(
    birthDate: DateTime(1975, 7, 6),
    birthHour: 9,
    birthMinute: 30,
    birthPlace: const BirthPlace(
      city: 'Torino',
      latitude: 45.07,
      longitude: 7.69,
      timeZoneId: 'Europe/Rome',
      utcOffsetMinutes: 120,
    ),
  );

  test('Riaperta l\'app, i dati di nascita ci sono ancora', () async {
    // Il Risveglio ha sigillato tutto, e l'app si e' chiusa.
    ProfileController().setIdentity(identita);
    await Future<void>.delayed(Duration.zero);

    // Si riapre: il profilo si rilegge dall'archivio.
    final profilo = ProfileController();
    await profilo.load();

    // E i dati di nascita lo seguono, invece di restare vuoti.
    final nascita = BirthIdentityController()..riprendiDa(profilo.identity);

    expect(nascita.details, isNotNull,
        reason: 'riaperta l\'app i dati di nascita sono spariti: erano in un '
            'controller che vive solo in memoria e che un solo punto del '
            'progetto si ricordava di riempire');
    expect(nascita.details!.hasTime, isTrue,
        reason: 'l\'ora di nascita risulta mancante a chi l\'ha data: e\' il '
            'motivo per cui l\'app dice che l\'Ascendente e le Case restano '
            'velati');
    expect(nascita.details!.time?.hour, 9);
    expect(nascita.details!.place, isNotNull,
        reason: 'il luogo di nascita risulta mancante, e senza luogo il client '
            'della carta solleva PRIMA di chiamare la rete: il cielo essenziale '
            'diventa il caso normale invece che l\'eccezione');
  });

  test('Senza dati veri non si inventa una nascita', () async {
    final profilo = ProfileController();
    final nascita = BirthIdentityController()..riprendiDa(profilo.identity);
    expect(nascita.details, isNull,
        reason: 'chi non ha ancora dato i suoi dati si vede attribuire una '
            'nascita d\'esempio, e ci vedrebbe sopra il cielo di un altro');
  });

  test('La ripresa e\' idempotente', () async {
    final nascita = BirthIdentityController()..riprendiDa(identita);
    final primo = nascita.details;
    nascita.riprendiDa(identita);
    expect(identical(nascita.details, primo), isTrue,
        reason: 'ripetere la ripresa ricostruisce i dati: chiamata a ogni '
            'cambio del profilo, notificherebbe in cerchio');
  });

  test('Le porte che riempiono i dati di nascita sono enumerate', () {
    // Prima era una sola, il Risveglio, ed e' esattamente il difetto. Adesso
    // sono due, e la seconda passa dal profilo persistito, quindi vale per ogni
    // riapertura dell'app senza che nessuno debba ricordarsene.
    final porte = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final p = f.path.replaceAll(Platform.pathSeparator, '/');
      if (p.endsWith('natal_identity.dart')) continue;
      final t = f.readAsStringSync();
      if (t.contains('.setBirth(') || t.contains('..riprendiDa(')) {
        porte.add(p);
      }
    }
    expect(porte.length, 2,
        reason: 'le porte che riempiono i dati di nascita sono '
            '${porte.length} ($porte): se ne nasce una terza, verifica che i '
            'dati vengano dal profilo e non da una copia che non persiste');
  });
}

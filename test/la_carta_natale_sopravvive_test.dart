import 'dart:io';

import 'package:esoteric_circle/core/astro/aspetti_di_oggi.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/corrente_del_cielo.dart';
import 'package:esoteric_circle/core/identity/birth_place.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA CARTA NATALE SOPRAVVIVE ALLA CHIUSURA, E CHI LA LEGGE DICE IL VERO.
///
/// Ordine 2166, voce 4, e voce 60 del Registro. **Il visto di Mauro:** in
/// fondo all'Oroscopo compariva "Questa lettura parla al tuo segno, non
/// ancora al tuo cielo: senza ora e luogo di nascita i transiti sulla tua
/// carta non si possono calcolare", con la carta natale COMPLETA.
///
/// **Le tre ipotesi dell'ordine, e come sono andate.**
/// 1. La condizione scritta al contrario: CADUTA, verificata per prima
///    perche' costava un minuto. `CorrenteDelCielo.notaDelLivello` torna la
///    nota giusta per ogni livello e NULLA per la carta completa.
/// 2. Legge il campo giusto da una copia non aggiornata: CONFERMATA, ed e' la
///    causa. `BirthIdentityController.chart` viene riempito in UN SOLO punto
///    di tutto il progetto, alla fine del Risveglio, e vive solo in memoria:
///    la carta non e' persistita da nessuna parte. Riaperta l'app il campo e'
///    nullo, `AspettiDiOggi.livello(null)` risponde soloSegno, e l'avviso
///    compare pur essendo ora e luogo salvi nel profilo.
/// 3. Legge un campo diverso: CADUTA, il campo e' quello giusto. Il difetto
///    non e' dove guarda, e' che cio' che guarda non sopravvive.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Una carta completa, con ora e luogo: e' la carta di chi ha finito il
  /// Risveglio dando tutto.
  NatalChart cartaCompleta() => NatalChart(
        sunSign: Zodiac.leo,
        moonSign: Zodiac.pisces,
        ascendant: Zodiac.scorpio,
        ascendantLongitude: 215.4,
        hasTime: true,
        planets: const [
          PlanetPosition(
              id: 'sun',
              name: 'Sole',
              glyph: '☉',
              longitude: 142.0,
              sign: Zodiac.leo),
          PlanetPosition(
              id: 'moon',
              name: 'Luna',
              glyph: '☾',
              longitude: 350.0,
              sign: Zodiac.pisces),
        ],
      );

  BirthIdentity identitaCompleta() => BirthIdentity.fromParts(
        birthDate: DateTime(1972, 8, 15),
        birthHour: 10,
        birthMinute: 30,
        birthPlace: const BirthPlace(
            city: 'Roma',
            latitude: 41.9,
            longitude: 12.5,
            timeZoneId: 'Europe/Rome',
            utcOffsetMinutes: 120),
      );

  group('la prova differenziale dell\'avviso: DUE prove, non una', () {
    // Con una sola, la condizione scritta al rovescio passerebbe liscia: e'
    // il motivo per cui l'ordine ne chiede due.
    test('con la carta COMPLETA la nota NON compare', () {
      final cielo = CieloDiOggi.perIlGiorno(
          adesso: DateTime(2026, 8, 8), carta: cartaCompleta());
      final nota = CorrenteDelCielo.notaDelLivello(cielo);
      expect(nota, isNull,
          reason: 'Con ora e luogo dati, l\'avviso "senza ora e luogo" e\' '
              'una bugia nella headline di Medora. E\' il visto di Mauro, '
              'voce 60 del Registro.');
    });

    test('SENZA ora e luogo la nota compare', () {
      final cielo = CieloDiOggi.perIlGiorno(
          adesso: DateTime(2026, 8, 8),
          carta: NatalChart.essential(sunSign: Zodiac.leo, hasTime: false));
      final nota = CorrenteDelCielo.notaDelLivello(cielo);
      expect(nota, isNotNull,
          reason: 'Chi non ha dato ora e luogo deve sapere che sta leggendo '
              'il suo segno e non il suo cielo: senza questa riga il ripiego '
              'sarebbe muto.');
      expect(nota, contains('ora'));
    });
  });

  group('la carta sopravvive alla chiusura dell\'app', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('scritta e riletta: dopo un riavvio la carta c\'e\' ancora',
        () async {
      // **QUESTA E' LA PROVA CHE DIMOSTRA LA CAUSA.** Si scrive il profilo,
      // si scrive la carta, si butta via TUTTO cio' che vive in memoria (che
      // e' cio' che fa il sistema quando uccide il processo) e si riprende da
      // capo, come fa l'app all'avvio.
      final store = ProfileStore();
      await store.saveIdentity(identitaCompleta());

      final primo = BirthIdentityController();
      primo.riprendiDa(identitaCompleta());
      primo.setBirth(primo.details!, cartaCompleta());
      expect(primo.chart, isNotNull);
      // **NESSUNA SCRITTURA A MANO, e la grandezza e' cambiata per questo.**
      // La prima stesura chiamava qui `conservaLaCarta`, e cosi' il ROSSO
      // NON SCATTAVA: togliendo la conservazione da `setBirth` la prova
      // restava verde, perche' a scrivere era la prova stessa. Misurava il
      // meccanismo invece del suo uso. Adesso si aspetta soltanto che il
      // giro di scrittura avviato da `setBirth` si compia: se `setBirth` non
      // conserva, dopo il riavvio non c'e' niente da rileggere.
      await Future<void>.delayed(Duration.zero);

      // Il processo muore: nasce un controller nuovo, come all'avvio.
      final dopoIlRiavvio = BirthIdentityController();
      dopoIlRiavvio.riprendiDa(identitaCompleta());
      await dopoIlRiavvio.riprendiLaCarta();

      expect(dopoIlRiavvio.chart, isNotNull,
          reason: 'Dopo il riavvio la carta natale non c\'e\' piu\': e\' la '
              'causa dell\'avviso falso, perche' ' chi la legge trova nullo '
              'e conclude che ora e luogo non sono stati dati.');
      expect(dopoIlRiavvio.chart!.hasTime, isTrue,
          reason: 'La carta e\' tornata, ma senza l\'ora: il livello '
              'ricadrebbe su "carta senza ora" e l\'avviso comparirebbe lo '
              'stesso, in un\'altra forma.');
      expect(AspettiDiOggi.livello(dopoIlRiavvio.chart),
          LivelloPersonalizzazione.cartaCompleta,
          reason: 'Il livello dopo il riavvio non e\' quello di una carta '
              'completa: l\'avviso tornerebbe.');
    });
  });

  test('i lettori della carta passano tutti dalla stessa porta', () {
    // L'ENUMERAZIONE: chi vuole la carta natale la chiede a
    // `BirthIdentityController`, che e' la porta. Un lettore che si costruisce
    // la carta per conto suo, o che tiene una copia sua, e' una porta in piu'
    // e domani dira' una cosa diversa dalle altre.
    final colpe = <String>[];
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final testo = f.readAsStringSync();
      final percorso = f.path.replaceAll('\\', '/');
      // I due punti che la carta la producono davvero: il controller, che e'
      // la porta, e il servizio che la calcola.
      // I punti che la carta la producono per mestiere: il modello, la
      // porta, il controller che la calcola, il deserializzatore di cio' che
      // e' stato conservato, e i servizi che parlano con la callable.
      if (percorso.endsWith('natal_identity.dart') ||
          percorso.endsWith('natal_chart.dart') ||
          percorso.endsWith('natal_chart_controller.dart') ||
          percorso.endsWith('carta_conservata.dart') ||
          percorso.contains('/services/')) {
        continue;
      }
      // Chi COSTRUISCE una carta fuori da li' si sta facendo la sua copia.
      if (RegExp(r'NatalChart\(').hasMatch(testo)) {
        colpe.add('$percorso: costruisce una NatalChart per conto suo invece '
            'di leggerla dalla porta.');
      }
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  test('chi avvisa di dati mancanti legge tutto la stessa porta', () {
    // I punti che dicono "mancano ora e luogo" devono decidere sullo stesso
    // dato: due condizioni scritte a mano in due schermate diverse diventano
    // due verita' il giorno che una cambia.
    final colpe = <String>[];
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final testo = f.readAsStringSync();
      final percorso = f.path.replaceAll('\\', '/');
      // **SI GUARDA IL CODICE, NON I COMMENTI, e la misura e' cambiata.** La
      // prima stesura cercava le parole ovunque nel file e denunciava tre
      // file che nominano ora e luogo dentro un commento di documentazione,
      // cioe' che non avvisano nessuno: una misura che guarda la cosa
      // sbagliata e' come una misura che non c'e'. Le righe di commento si
      // tolgono prima di cercare.
      final soloCodice = testo
          .split('\n')
          .where((r) {
            final nuda = r.trimLeft();
            return !nuda.startsWith('//');
          })
          .join('\n');
      final avvisa = soloCodice.contains('senza ora') ||
          soloCodice.contains('Senza l\'ora') ||
          soloCodice.contains('ora e luogo');
      if (!avvisa) continue;
      // **LE PORTE SONO DUE, e non e' un'eccezione di comodo.** La carta
      // natale e' il CALCOLO, e la sua porta e' `BirthIdentityController`.
      // L'ora e il luogo sono cio' che la persona ha DATO, e la loro porta
      // e' `BirthIdentity`, il dato persistito nel profilo: e' li' che vive
      // l'ora di nascita, ed e' da li' che l'Angelo dell'Intelletto decide
      // se puo' esistere. Un avviso sull'ora che leggesse la carta invece
      // dell'identita' sarebbe il difetto al contrario.
      final passaDallaPorta = testo.contains('LivelloPersonalizzazione') ||
          testo.contains('notaDelLivello') ||
          testo.contains('AspettiDiOggi.livello') ||
          testo.contains('hasTime') ||
          testo.contains('BirthIdentityController') ||
          testo.contains('BirthIdentity ') ||
          testo.contains('hasBirthTime');
      if (!passaDallaPorta) {
        colpe.add('$percorso: avvisa di dati di nascita mancanti senza '
            'leggere il livello dalla porta: e\' una seconda verita\'.');
      }
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });
}

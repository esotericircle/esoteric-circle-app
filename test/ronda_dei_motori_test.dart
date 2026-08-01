import 'dart:io';

import 'package:esoteric_circle/core/angels/guardian_angels.dart';
import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/moon_phase.dart';
import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/core/astro/sky.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:esoteric_circle/core/magic/intention_sigil.dart';
import 'package:esoteric_circle/core/rituals/guide_animal_derivation.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA RONDA DEI MOTORI.
///
/// **Perche' esiste.** In questo progetto `buildSkySnapshot` sapeva calcolare la
/// volta celeste da latitudine, longitudine e ora, ed era chiamato da **zero**
/// punti dell'app. La schermata "Il cielo sopra di te" disegnava una volta
/// procedurale e, quando arrivava la posizione del telefono, spostava il disegno
/// di un offset grafico. Il permesso si concedeva, il banner diceva "cielo
/// orientato", e il cielo non cambiava di un grado.
///
/// A scoprirlo non e' stato un test: e' stato Mauro guardando la Luna e
/// accorgendosi che la fase era sbagliata di un giorno. Senza quel dubbio, un
/// cielo finto sarebbe arrivato davanti a Google.
///
/// **Cosa protegge questa Ronda.** Tre domande per ogni motore, e nessuna delle
/// tre basta da sola:
///
/// 1. Ha almeno un chiamante fuori dal proprio file? Zero chiamanti e' il caso
///    del cielo.
/// 2. Il dato dell'utente arriva fino a lui?
/// 3. **Cambiando l'input, l'output cambia?** E' la sola domanda che avrebbe
///    smascherato il cielo, perche' le prime due si possono soddisfare mentre il
///    risultato viene ignorato a valle.
///
/// Il censimento qui sotto e' un DATO, non un commento: un motore nuovo che non
/// venga aggiunto qui fa fallire la Ronda.
void main() {
  group('Strato statico: nessun motore senza chiamanti', () {
    for (final m in censimentoMotori) {
      test('${m.nome} ha chiamanti', () {
        final chiamanti = _chiamantiDi(m);
        expect(chiamanti, isNotEmpty,
            reason: 'IL CASO DEL CIELO: "${m.nome}" esiste in ${m.definitoIn} '
                'e non lo chiama nessuno. Un motore senza chiamanti calcola nel '
                'vuoto, e a schermo si vede un fondale.');
      });
    }

    test('Il censimento copre i motori dichiarati', () {
      // Se qualcuno aggiunge un motore senza censirlo, questa soglia lo dice.
      expect(censimentoMotori.length, greaterThanOrEqualTo(20),
          reason: 'il censimento si e\' assottigliato: qualcuno ha tolto righe '
              'invece di aggiungerne');
    });
  });

  group('Strato a schermo: cambiando l\'input, cambia CIO\' CHE SI VEDE', () {
    test('Le prove a schermo dichiarate esistono davvero', () {
      // Un elenco che nomina un file inesistente e' peggio di un elenco vuoto:
      // dichiara una copertura che non c'e'.
      for (final voce in misuratiASchermo.entries) {
        expect(File(voce.value).existsSync(), isTrue,
            reason: 'il motore ${voce.key} risulta misurato a schermo da '
                '${voce.value}, che non esiste');
        expect(censimentoMotori.any((m) => m.nome == voce.key), isTrue,
            reason: '${voce.key} non e\' un motore del censimento');
      }
    });

    test('I motori NON misurati a schermo sono dichiarati, non dimenticati',
        () {
      // Non pretende che tutti abbiano una misura a schermo: sarebbe un lavoro
      // che non e' di questa voce. Pretende che l'elenco di chi non ce l'ha sia
      // SCRITTO, cosi' nessuno crede coperto cio' che non lo e'.
      final scoperti = censimentoMotori
          .where((m) => !misuratiASchermo.containsKey(m.nome))
          .map((m) => m.nome)
          .toList();
      expect(scoperti.length, censimentoMotori.length - misuratiASchermo.length,
          reason: 'il conto non torna: qualche motore misurato a schermo non '
              'sta nel censimento');
      // Il numero si muove quando il lavoro procede: se cala, si aggiorna qui e
      // in ESITO_2.md, e si sa perche'.
      expect(scoperti.length, 21,
          reason: 'i motori sorvegliati solo sulla funzione pura sono cambiati '
              '(${scoperti.length}): aggiorna questo numero e l\'elenco in '
              'docs/ordini/ESITO_2.md, cosi\' resta scritto cosa e\' coperto');
    });
  });

  group('Strato dinamico: cambiando l\'input, l\'output cambia', () {
    // E' lo strato che conta. Un motore puo' avere chiamanti, ricevere il dato
    // dell'utente, e avere il proprio risultato ignorato a valle: succedeva
    // esattamente questo al cielo.

    test('Cielo: due luoghi diversi danno due cieli diversi', () {
      final catalogo = _catalogoDiProva();
      final istante = DateTime(2026, 7, 30, 22, 30);
      final milano = buildSkyFor(catalogo, istante,
          const BirthPlace(label: 'Milano', latitude: 45.46, longitude: 9.19, timezone: 'l'));
      final sydney = buildSkyFor(catalogo, istante,
          const BirthPlace(label: 'Sydney', latitude: -33.87, longitude: 151.21, timezone: 'l'));

      expect(milano.latitude, isNot(sydney.latitude));
      // LA PROVA VERA NON E' L'ALTEZZA DI UN ASTRO SOLO, e ci sono arrivato
      // sbagliando tre volte. Guardava la Luna, che puo' stare sotto
      // l'orizzonte in tutti e due i posti allo stesso istante: cadeva per un
      // istante sfortunato invece che per un difetto, ed e' successo quando la
      // correzione del fuso ha spostato il cielo di due ore. Poi ho provato la
      // media di tutte le altezze, 4,89 contro una soglia di 5, e il massimo,
      // 4,31: due numeri che dipendono da quali stelle stanno nel catalogo di
      // prova, non dal fatto da provare.
      //
      // IL CONFRONTO CHE NON DIPENDE DA NIENTE e' fra LA STESSA STELLA vista
      // dai due luoghi: stesse coordinate equatoriali, stesso istante, e
      // novantatre gradi di latitudine di differenza. Se il luogo non entrasse
      // nel calcolo darebbe lo stesso numero.
      final stellaDaMilano = milano.constellations.first.stars.first;
      final stellaDaSydney = sydney.constellations.first.stars.first;
      expect((stellaDaMilano.altDeg - stellaDaSydney.altDeg).abs(),
          greaterThan(5),
          reason: 'la stessa stella risulta alla stessa altezza da Milano e da '
              'Sydney: il luogo non entra nel calcolo');
    });

    test('Cielo: due istanti diversi danno due cieli diversi', () {
      final catalogo = _catalogoDiProva();
      const luogo = BirthPlace(
          label: 'Milano', latitude: 45.46, longitude: 9.19, timezone: 'l');
      final sera = buildSkyFor(catalogo, DateTime(2026, 7, 30, 21), luogo);
      final alba = buildSkyFor(catalogo, DateTime(2026, 7, 31, 6), luogo);
      expect(sera.centerAzDeg, isNot(alba.centerAzDeg),
          reason: 'a nove ore di distanza il cielo risulta identico: l\'ora non '
              'entra nel calcolo');
    });

    test('Fase lunare: due date diverse danno fasi diverse', () {
      final a = MoonPhase.forDate(DateTime.utc(2026, 7, 29));
      final b = MoonPhase.forDate(DateTime.utc(2026, 8, 5));
      expect(a.illumination, isNot(closeTo(b.illumination, 0.02)),
          reason: 'a una settimana di distanza la Luna risulta illuminata '
              'uguale');
      expect(a.italianName, isNot(b.italianName));
    });

    test('Illuminazione: l\'elongazione cambia col tempo', () {
      final a = Celestial.moonIllumination(Celestial.julianDay(DateTime.utc(2026, 3, 1)));
      final b = Celestial.moonIllumination(Celestial.julianDay(DateTime.utc(2026, 3, 8)));
      expect((a.elongationDeg - b.elongationDeg).abs(), greaterThan(20));
    });

    test('Segno solare: due date diverse danno segni diversi', () {
      expect(NightSky.sunSign(DateTime(1990, 5, 12)),
          isNot(NightSky.sunSign(DateTime(1990, 11, 12))),
          reason: 'maggio e novembre danno lo stesso segno solare');
    });

    test('Segno lunare: due date diverse danno segni diversi', () {
      // La Luna cambia segno ogni due giorni e mezzo: a dieci giorni di
      // distanza il segno deve essere un altro.
      expect(NightSky.moonSign(DateTime(2026, 7, 1)),
          isNot(NightSky.moonSign(DateTime(2026, 7, 11))),
          reason: 'a dieci giorni di distanza la Luna risulta nello stesso '
              'segno');
    });

    test('Numero della vita: due date diverse danno numeri diversi', () {
      final a = lifePathNumber(DateTime(1990, 5, 12));
      final b = lifePathNumber(DateTime(1977, 11, 3));
      expect(a, isNot(b),
          reason: 'due date di nascita molto diverse danno lo stesso numero');
    });

    test('Animale Guida: due segni diversi danno animali diversi', () {
      final a = GuideAnimalDerivation.forSign(NightSky.sunSign(DateTime(1990, 5, 12)));
      final b = GuideAnimalDerivation.forSign(NightSky.sunSign(DateTime(1990, 11, 12)));
      expect(a.name, isNot(b.name),
          reason: 'due segni diversi ricevono lo stesso animale guida');
    });

    test('Angeli: due nascite diverse danno triadi diverse', () {
      final a = GuardianAngels.forBirth(BirthDetails(date: DateTime(1990, 5, 12)));
      final b = GuardianAngels.forBirth(BirthDetails(date: DateTime(1990, 11, 12)));
      expect(a.guardian.name, isNot(b.guardian.name),
          reason: 'due date di nascita diverse ricevono lo stesso Angelo '
              'custode: i gradi non entrano nel calcolo');
    });

    test('Angeli: l\'ora di nascita conta dove deve contare', () {
      final senza = GuardianAngels.forBirth(BirthDetails(date: DateTime(1990, 5, 12)));
      final con = GuardianAngels.forBirth(BirthDetails(
          date: DateTime(1990, 5, 12), time: const TimeOfDay(hour: 3, minute: 30)));
      // Il terzo Angelo, quello dell'intelletto, nasce dall'ora.
      expect(senza.known.length, isNot(con.known.length),
          reason: 'con e senza ora di nascita la triade e\' identica, mentre il '
              'terzo Angelo dovrebbe dipendere dall\'ora');
    });

    test('Sigillo: due intenzioni diverse danno cammini diversi', () {
      final a = IntentionSigil.cammino('Chiedo chiarezza sulla mia strada');
      final b = IntentionSigil.cammino('Metto radici dove sono');
      expect(a.length, isNot(0));
      expect(a, isNot(b),
          reason: 'due intenzioni diverse producono lo stesso sigillo');
    });

    test('Sigillo: la stessa intenzione da\' sempre lo stesso cammino', () {
      // Il rovescio della medaglia: un motore che cambia output a input
      // costante non e' vivo, e' casuale.
      final a = IntentionSigil.cammino('Apro il mio cuore');
      final b = IntentionSigil.cammino('Apro il mio cuore');
      expect(a, b, reason: 'la stessa frase da\' due sigilli diversi');
    });

    test('Identita di nascita: l\'ora cambia il momento registrato', () {
      final a = BirthIdentity.fromParts(
          birthDate: DateTime(1990, 5, 12), birthHour: 7, birthMinute: 20);
      final b = BirthIdentity.fromParts(
          birthDate: DateTime(1990, 5, 12), birthHour: 19, birthMinute: 45);
      expect(a.birthMoment, isNot(b.birthMoment),
          reason: 'due ore di nascita diverse danno lo stesso momento');
      expect(a.hasBirthTime, isTrue);
    });
  });
}

/// LO STRATO A SCHERMO: quali motori sono misurati dove l'utente guarda.
///
/// **Perche' serve un terzo strato.** Il segno solare era gia' sorvegliato da
/// questa Ronda, ed era verde, e non ha impedito che la home dicesse "per chi
/// nasce sotto Gemelli" a chiunque. Lo strato statico controllava che la stringa
/// comparisse in qualche file fuori dal motore, e ci compariva anche dentro il
/// controller che restituiva il segnaposto; lo strato dinamico confrontava due
/// date sulla funzione pura, che infatti funziona benissimo. Nessuno dei due
/// arrivava alla schermata.
///
/// E' la definizione di MISURA CIECA secondo il Protocollo: cambia l'input e la
/// sorveglianza resta verde mentre a schermo il valore non si muove.
///
/// Qui si dichiara, motore per motore, se la terza domanda gli e' posta MONTANDO
/// LA SCHERMATA. Chi non c'e' resta sorvegliato solo sulla funzione pura, e
/// questo elenco serve a saperlo invece di crederlo coperto.
const Map<String, String> misuratiASchermo = {
  'Segno solare': 'test/segno_a_schermo_test.dart',
  'Carta natale, client': 'test/carta_natale_arriva_test.dart',
  'Cielo del momento': 'test/cielo_segue_la_posizione_test.dart',
};

/// Un motore del progetto, con dove vive e come si riconosce nel codice.
class Motore {
  const Motore(this.nome, this.simbolo, this.definitoIn, this.verdetto);

  /// Come si chiama a parole.
  final String nome;

  /// Il simbolo da cercare nei sorgenti per contarne i chiamanti.
  final String simbolo;

  /// Il file o la cartella che lo definisce: i suoi usi interni non contano.
  final String definitoIn;

  /// Cosa ci si aspetta: COLLEGATO oppure SEGNAPOSTO DICHIARATO.
  ///
  /// Un segnaposto dichiarato NON e' un difetto: e' un limite noto e scritto nei
  /// documenti, come l'Oroscopo che nasce da un hash invece che dai transiti.
  /// Confondere le due cose produce panico invece di informazione.
  final String verdetto;
}

/// IL CENSIMENTO. E' un dato, non un commento.
const List<Motore> censimentoMotori = [
  Motore('Carta natale, client', 'FreeAstroClient', 'lib/services/', 'COLLEGATO'),
  Motore('Cielo del momento', 'buildSkyFor', 'lib/core/astro/sky.dart', 'COLLEGATO'),
  Motore('Segno solare', 'sunSign', 'lib/core/astro/night_sky.dart', 'COLLEGATO'),
  Motore('Segno lunare', 'moonSign', 'lib/core/astro/night_sky.dart', 'COLLEGATO'),
  Motore('Fase lunare', 'MoonPhase.forDate', 'lib/core/astro/moon_phase.dart', 'COLLEGATO'),
  Motore('Illuminazione lunare', 'moonIllumination', 'lib/core/astro/celestial.dart', 'COLLEGATO'),
  Motore('Risonanza', 'computeResonance', 'lib/core/astro/resonance.dart', 'COLLEGATO'),
  Motore('Numero della vita', 'lifePathNumber', 'lib/core/identity/numerology.dart', 'COLLEGATO'),
  Motore('Animale Guida', 'GuideAnimalDerivation', 'lib/core/rituals/guide_animal_derivation.dart', 'COLLEGATO'),
  Motore('Animale del giorno', 'GuideAnimalDay', 'lib/core/rituals/guide_animal_day.dart', 'SEGNAPOSTO DICHIARATO'),
  Motore('Angeli custodi', 'GuardianAngels', 'lib/core/angels/guardian_angels.dart', 'COLLEGATO'),
  Motore('Test Archetipo', 'ArchetypeQuiz', 'lib/core/archetypes/', 'COLLEGATO'),
  Motore('Costellazione del Viso', 'FaceClassifier', 'lib/core/face/', 'COLLEGATO'),
  Motore('Tarocchi, stesa', 'TarotSpread', 'lib/core/tarot/', 'COLLEGATO'),
  Motore('Tarocchi, lettura', 'TarotReading', 'lib/core/tarot/', 'COLLEGATO'),
  Motore('Oroscopo', 'Horoscope', 'lib/core/horoscope/', 'SEGNAPOSTO DICHIARATO'),
  Motore('Doni del giorno', 'DawnGift', 'lib/core/rituals/', 'SEGNAPOSTO DICHIARATO'),
  Motore('Rune, getto', 'GettataRune', 'lib/core/rituals/', 'COLLEGATO'),
  Motore('Sigillo intenzione', 'IntentionSigil', 'lib/core/magic/', 'COLLEGATO'),
  Motore('Sinastria VIP', 'SynastryReport', 'lib/core/synastry/', 'COLLEGATO'),
  Motore('Limiti dei piani', 'PlanCatalog', 'lib/core/entitlement/', 'COLLEGATO'),
  Motore('Identita di nascita', 'BirthIdentity', 'lib/core/identity/birth_identity.dart', 'COLLEGATO'),
  Motore('Fatti natali', 'NatalFacts', 'lib/core/identity/natal_identity.dart', 'COLLEGATO'),
  Motore('Luna di nascita', 'BirthMoon', 'lib/core/identity/birth_moon.dart', 'COLLEGATO'),
];

/// I file di `lib/` che nominano un motore, esclusi quelli che lo definiscono.
List<String> _chiamantiDi(Motore m) {
  final trovati = <String>[];
  for (final f in Directory('lib').listSync(recursive: true)) {
    if (f is! File || !f.path.endsWith('.dart')) continue;
    final p = f.path.replaceAll('\\', '/');
    if (p.startsWith(m.definitoIn)) continue;
    if (f.readAsStringSync().contains(m.simbolo)) trovati.add(p);
  }
  return trovati;
}

/// Un catalogo minimo per le prove del cielo: tre stelle in punti diversi.
///
/// Non si carica quello vero dagli asset, perche' la Ronda deve poter girare
/// anche senza il bundle: cio' che si misura e' il MOTORE, non i dati.
SkyCatalog _catalogoDiProva() => SkyCatalog([
      CatalogConstellation(
        name: 'Prova',
        stars: [
          [10.0, 20.0, 1.5],
          [80.0, -10.0, 2.0],
          [200.0, 50.0, 1.0],
        ],
        lines: [
          [0, 1],
          [1, 2],
        ],
      ),
    ]);

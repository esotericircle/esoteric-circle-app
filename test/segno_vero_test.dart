import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// IL SEGNO MOSTRATO E' QUELLO VERO, e discende dalla data di nascita.
///
/// **La segnalazione.** La home diceva "per chi nasce sotto Gemelli" al
/// fondatore, che e' del Cancro. Non era l'ascendente: era un segno di esempio
/// rimasto dal primo commit, e stava cablato in DUE posti indipendenti, quindi
/// azzerandone uno la frase restava Gemelli.
///
/// **Perche' era sbagliata per chiunque, sempre.** Il segno arrivava da un
/// controller che non conserva niente fra un avvio e l'altro, e che un solo
/// punto di tutto il progetto si ricordava di riempire, alla fine del Risveglio.
/// Al riavvio tornava il segnaposto. Funzionava soltanto nella sessione in cui
/// si era appena concluso il Risveglio, ed e' probabilmente cosi' che era stato
/// verificato a suo tempo.
///
/// **LA TRAPPOLA, dichiarata perche' nessuno ci ricada.** La data di prova
/// dell'app e `BirthIdentity.example` sono entrambe del 15 giugno 1990, che e'
/// GEMELLI. Una prova scritta con l'identita' d'esempio e' verde col difetto e
/// senza, perche' il segnaposto e il valore vero coincidono. Qui si usa il
/// Cancro del fondatore, che e' un altro segno, e sul codice vecchio questa
/// prova cadeva.
void main() {
  // Il fondatore, 6 luglio: Cancro. Non Gemelli, ed e' tutto il punto.
  final fondatore = BirthIdentity.fromParts(birthDate: DateTime(1975, 7, 6));

  group('Il segno discende dalla data, non da chi si ricorda di scriverlo', () {
    test('Una data del Cancro da\' il Cancro, non il segnaposto', () {
      expect(fondatore.sunSign, Zodiac.cancer,
          reason:
              'la data di nascita e\' del Cancro e il segno che ne esce e\' '
              'un altro: quello mostrato non discende dalla data');
    });

    test('Senza data vera non c\'e\' segno, e non se ne inventa uno', () {
      expect(BirthIdentity.example.sunSign, isNull,
          reason: 'chi non ha ancora dato la sua data si vede attribuire un '
              'segno lo stesso, ed e\' esattamente il difetto segnalato');
    });

    test('Il segno del dato coincide col motore, non e\' una seconda strada',
        () {
      // Due strade che calcolano la stessa cosa divergono prima o poi: questa
      // prova dichiara che sono la stessa strada.
      for (final data in [
        DateTime(1975, 7, 6),
        DateTime(1990, 6, 15),
        DateTime(1988, 12, 31),
        DateTime(2001, 3, 21),
      ]) {
        expect(BirthIdentity.fromParts(birthDate: data).sunSign,
            NightSky.sunSign(data),
            reason:
                'per $data il segno del dato di nascita e quello del motore '
                'non coincidono');
      }
    });
  });

  group('Nessun segno cablato e\' rimasto', () {
    test('Lo zodiaco di sfondo nasce vuoto', () {
      // Il ripiego era doppio e indipendente: uno nella schermata e uno nel
      // costruttore del controller. Toglierne uno solo lasciava la frase
      // identica, ed e' il motivo per cui questa prova guarda tutte e due le
      // porte invece di visitarne una.
      final righe = FileSorgente.zodiacController();
      expect(righe, isNot(contains('Zodiac.gemini')),
          reason: 'il controller dello zodiaco nasce ancora con un segno '
              'cablato, e quel segno arriva fino alla frase della home');
    });

    test('La frase della home non nomina un segno cablato', () {
      final righe = FileSorgente.santuarioScreen();
      expect(righe, isNot(contains('?? Zodiac.')),
          reason: 'la home ha ancora un ripiego cablato sul segno: quando il '
              'segno manca deve mancare, non diventare un altro');
    });
  });
}

/// I sorgenti letti come testo, per enumerare le porte invece di visitarne una.
abstract final class FileSorgente {
  static String zodiacController() =>
      _leggi('lib/core/astro/zodiac_controller.dart');

  static String santuarioScreen() =>
      _leggi('lib/features/santuario/santuario_screen.dart');

  static String _leggi(String percorso) {
    final f = File(percorso);
    // Solo il codice: un segno nominato dentro un commento che SPIEGA il
    // difetto non e' il difetto, ed era il modo piu' facile di far cadere
    // questa prova per il motivo sbagliato.
    return f
        .readAsLinesSync()
        .where((r) => !r.trimLeft().startsWith('//'))
        .where((r) => !r.trimLeft().startsWith('///'))
        .join('\n');
  }
}

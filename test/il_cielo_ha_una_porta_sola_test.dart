import 'dart:io';

import 'package:esoteric_circle/core/astro/meeus/il_cielo_di_meeus.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/cerchio/il_confronto_del_cielo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// IL CIELO HA UNA PORTA SOLA. Ordine FD voce 02.4 a) e b).
///
/// **Il difetto.** Prima dell'ordine FD in `lib` convivevano sei fonti della
/// posizione di un corpo, piu' tre tempi siderali, cinque obliquita' e due
/// Delta T: `Effemeridi`, `IlSoleDiNascita`, `LaLunaIntera`, `IlCieloDelJpl`,
/// il Sole NOAA di `SunsetTime` scritto due volte, la latitudine lunare di
/// `Celestial`. La guardia di prima (`una_sola_porta_per_i_transiti`)
/// cercava solo le costanti di `Effemeridi`, e le altre quattro non le
/// vedeva.
///
/// **La regola.** Ogni posizione del cielo si calcola dentro la libreria di
/// Meeus, `lib/core/astro/meeus/`, e fuori si chiede alla porta,
/// `IlCieloDiMeeus`. Questa guardia cerca, fuori dalla libreria e coi
/// commenti tolti:
/// - le IMPRONTE dei calcoli di posizione: le costanti dei moti medi del
///   Sole e della Luna, degli argomenti di Delaunay, dell'obliquita', del
///   tempo siderale e dell'epoca giuliana, che chi riscrive una formula del
///   cielo non puo' non scrivere;
/// - i NOMI dei motori cancellati;
/// - le chiamate ai motori dietro la porta (`LaLunaIntera`,
///   `IPianetiDiMeeus`), che fuori dalla libreria non si fanno.
///
/// **E prova che sa vedere**: le stesse impronte, dentro la libreria, ci
/// sono, e se un giorno l'elenco smettesse di trovarle la guardia cadrebbe.
void main() {
  const libreria = 'lib/core/astro/meeus/';

  // Le impronte: una costante per riga, col suo perche'.
  final impronte = <RegExp, String>{
    RegExp(r'280\.46'): 'la longitudine media del Sole, o il tempo siderale',
    RegExp(r'357\.52'): 'l\'anomalia media del Sole',
    RegExp(r'218\.31'): 'la longitudine media della Luna',
    RegExp(r'134\.96'): 'l\'anomalia media della Luna',
    RegExp(r'93\.27'): 'l\'argomento di latitudine della Luna',
    RegExp(r'297\.85'): 'l\'elongazione media della Luna',
    RegExp(r'125\.04'): 'il nodo della Luna',
    RegExp(r'23\.4[34]'): 'l\'obliquita\' dell\'eclittica',
    RegExp(r'360\.9856'): 'la velocita\' del tempo siderale',
    RegExp(r'0\.98560'): 'il moto medio del Sole',
    RegExp(r'2440587\.5'): 'l\'epoca giuliana del 1970',
  };
  final nomi = <RegExp, String>{
    RegExp(r'\bEffemeridi\b'): 'il motore 2020-2030, cancellato',
    RegExp(r'\bIlSoleDiNascita\b'): 'il Sole del capitolo 25, cancellato',
    RegExp(r'\bIlCieloDelJpl\b|\bLeEffemeridiDelJpl\b'):
        'i polinomi sul JPL, cancellati',
    RegExp(r'\bLaLunaIntera\.'): 'la Luna dietro la porta',
    RegExp(r'\bIPianetiDiMeeus\.'): 'i pianeti dietro la porta',
  };

  test('b) fuori dalla libreria di Meeus nessuna seconda via per il cielo', () {
    final colpe = <String>[];
    var file = 0;
    var dentro = 0;
    final sorgenti = [
      ...righeDiLib(),
      for (final f in sorgentiDiCartelle(['tool'], minimo: 5))
        if (f.path.endsWith('.dart'))
          (
            percorso: f.path.replaceAll('\\', '/'),
            righe: f.readAsLinesSync()
          ),
    ];
    for (final f in sorgenti) {
      file++;
      final testo = senzaCommenti(f.righe.join('\n'));
      final nellaLibreria = f.percorso.startsWith(libreria);
      final righe = testo.split('\n');
      for (var i = 0; i < righe.length; i++) {
        for (final e in impronte.entries) {
          if (!e.key.hasMatch(righe[i])) continue;
          if (nellaLibreria) {
            dentro++;
          } else {
            colpe.add('${f.percorso}:${i + 1}: ${e.value}: ${righe[i].trim()}');
          }
        }
        if (nellaLibreria) continue;
        for (final e in nomi.entries) {
          if (e.key.hasMatch(righe[i])) {
            colpe.add('${f.percorso}:${i + 1}: ${e.value}: ${righe[i].trim()}');
          }
        }
      }
    }
    cardinaleMinimo(file, quantiFileHaLib, cosa: 'file di lib e di tool');
    cardinaleMinimo(dentro, 15,
        cosa: 'impronte dentro la libreria di Meeus',
        perche: 'La guardia non trova piu\' le impronte nemmeno dove devono '
            'stare: o la libreria e\' stata spostata, o le impronte non '
            'descrivono piu\' i calcoli.');
    expect(colpe, isEmpty,
        reason: 'Una seconda via per una posizione del cielo, fuori dalla '
            'libreria di Meeus:\n${colpe.join('\n')}\nSi chiede alla porta, '
            'IlCieloDiMeeus.');
  });

  test('b) i motori cancellati non esistono piu\'', () {
    for (final p in [
      'lib/core/astro/effemeridi.dart',
      'lib/core/astro/il_sole_di_nascita.dart',
      'lib/core/astro/il_cielo_del_jpl.dart',
      'lib/core/astro/le_effemeridi_del_jpl.dart',
      'tool/genera_effemeridi_del_jpl.py',
    ]) {
      expect(File(p).existsSync(), isFalse, reason: '$p esiste ancora');
    }
  });

  test('a) la Luna del confronto del cielo viene dalla porta di Meeus', () {
    // La Luna del giorno a mezzogiorno UT, quella che il confronto usa: il
    // suo segno e il valore del cielo di oggi devono venire dalla porta.
    for (final giorno in [
      DateTime.utc(2026, 10, 5),
      DateTime.utc(2027, 3, 14),
      DateTime.utc(2029, 12, 31),
    ]) {
      final mezzogiorno =
          DateTime.utc(giorno.year, giorno.month, giorno.day, 12);
      final luna = IlCieloDiMeeus.longitudineAllIstante(
          CorpoCeleste.luna, mezzogiorno);
      final c = IlConfrontoDelCielo.fra(Zodiac.aries, Zodiac.libra, giorno);
      expect(c.lunaDiOggi, Zodiac.values[luna ~/ 30],
          reason: 'il segno della Luna del confronto non e\' quello di Meeus');
    }
    final sorgente =
        File('lib/core/cerchio/il_confronto_del_cielo.dart').readAsStringSync();
    expect(senzaCommenti(sorgente).contains('IlCieloDiMeeus.'), isTrue,
        reason: 'il confronto non chiede piu\' alla porta del cielo');
  });
}

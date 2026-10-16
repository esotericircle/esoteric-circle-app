// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/il_cielo_che_arriva.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// **IL CIELO CHE ARRIVA NON FERMA L'INTERFACCIA. Ordine FE voce 01, la causa
/// vera del crash del Redmi Note 14 Pro 5G.**
///
/// Lo stack dell'ANR della build 2298, tradotto coi simboli della stessa
/// build rifatta dallo stesso commit (codice identico al byte), dice:
/// chiusura del LIVE, preparazione del "Vai piu' a fondo", istruzione del
/// Maestro, [ProssimiEventi.da] su 400 giorni col motore di Meeus, due volte,
/// sul filo dell'interfaccia: 2,9 secondi sul PC per comporre l'istruzione.
///
/// La guardia pretende quattro cose: in `lib` gli eventi in arrivo si
/// calcolano solo dentro la porta [IlCieloCheArriva]; comporre l'istruzione
/// di un Maestro con una nascita non tiene il filo oltre 100 ms; la porta
/// calcola una volta per giorno e persona; il turno del Maestro prepara il
/// cielo prima di comporre.
void main() {
  test('in lib gli eventi in arrivo si calcolano solo dentro la porta', () {
    final fuori = <String>[];
    var file = 0;
    for (final f in righeDiLib()) {
      file++;
      if (f.percorso.endsWith('il_cielo_che_arriva.dart')) continue;
      for (var i = 0; i < f.righe.length; i++) {
        final r = f.righe[i].trimLeft();
        if (r.startsWith('//')) continue;
        if (r.contains('ProssimiEventi.da(')) {
          fuori.add('${f.percorso}:${i + 1}');
        }
      }
    }
    print('ORDINE FE VOCE 01: file di lib letti $file, chiamate degli eventi '
        'in arrivo fuori dalla porta ${fuori.length} $fuori');
    expect(fuori, isEmpty,
        reason: 'questi punti calcolano 400 giorni di cielo sul filo '
            'dell\'interfaccia: $fuori');
  });

  test('l\'istruzione del Maestro con una nascita non ferma il filo', () {
    IlCieloCheArriva.dimentica();
    final tempi = <String, int>{};
    for (final m in Maestro.values) {
      final w = Stopwatch()..start();
      MaestroPersona.systemInstruction(
        maestro: m,
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
        natal: const NatalContext(
            sunSign: 'Gemelli', lifeNumberTitle: 'il Costruttore'),
      );
      tempi[m.name] = w.elapsedMilliseconds;
    }
    print('ORDINE FE VOCE 01: millisecondi per comporre l\'istruzione con '
        'una nascita $tempi (prima della cura 2920, 2893 e 2828 sul PC)');
    for (final e in tempi.entries) {
      expect(e.value, lessThan(100),
          reason: 'l\'istruzione di ${e.key} ferma il filo per ${e.value} ms');
    }
  });

  test('la porta calcola una volta per giorno e persona', () async {
    IlCieloCheArriva.dimentica();
    final oggi = DateTime(2026, 10, 5, 22);
    final a = IlCieloCheArriva.prepara(adesso: oggi, segno: Zodiac.gemini);
    final b = IlCieloCheArriva.prepara(adesso: oggi, segno: Zodiac.gemini);
    final eventi = await a;
    await b;
    await IlCieloCheArriva.prepara(adesso: oggi, segno: Zodiac.gemini);
    print('ORDINE FE VOCE 01: calcoli per tre richieste dello stesso giorno '
        '${IlCieloCheArriva.calcoli}, eventi ${eventi.length}');
    expect(IlCieloCheArriva.calcoli, 1);
    expect(eventi, isNotEmpty);
    expect(IlCieloCheArriva.gia(adesso: oggi, segno: Zodiac.gemini), eventi);
  });

  test('il turno del Maestro prepara il cielo prima di comporre', () {
    final p = File('lib/services/ai/firebase_maestro_ai_provider.dart')
        .readAsStringSync()
        .replaceAll('\r\n', '\n');
    final prepara = p.indexOf('await MaestroPersona.preparaIlCielo(natal);');
    final compone = p.indexOf('MaestroPersona.systemInstruction(');
    expect(prepara, greaterThan(0),
        reason: 'il turno non prepara il cielo: l\'istruzione resta senza '
            'eventi in arrivo');
    expect(prepara, lessThan(compone));
  });
}

import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/chakra_del_giorno.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/services/voce/l_orecchio_del_live.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **I NOMI DEL LIVE SI TRASCRIVONO GIUSTI.** Ordine EK voce 03, 24 settembre
/// 2026.
///
/// Il rapporto EJ: *"la trascrizione del LIVE ha scritto "Mezz'ora" invece di
/// "Medora""*; il fondatore: *"è Calìgo e non Càligo"*. Chi trascrive
/// riceve adesso i nomi dei tre Maestri e delle loro arti, presi dai
/// cataloghi dell'app. Questa guardia pretende che ci siano **tutti**, e che
/// la richiesta mandata a Gemini sia proprio quella che li porta: una
/// richiesta giusta che nessuno manda non cura niente.
void main() {
  test('LA TRASCRIZIONE CONOSCE I TRE MAESTRI E I NOMI DI TUTTE LE ARTI', () {
    final attesi = <String>[
      'Medora',
      'Aura',
      'Calìgo',
      for (final c in TarotDeck.cards)
        if (c.arcana == TarotArcana.maggiore) c.name,
      for (final r in kElderFuthark) r.name,
      for (final z in Zodiac.values) z.italianName,
      for (final c in ChakraDelGiorno.tutti) c.nome,
    ];
    cardinaleMinimo(attesi.length, 68,
        cosa: 'nomi da trascrivere',
        perche: 'Tre Maestri, ventidue arcani maggiori, ventiquattro rune, '
            'dodici segni e sette chakra.');
    final istruzione = LaTrascrizione.istruzione;
    final mancanti = [
      for (final n in attesi)
        if (!istruzione.contains(n)) n
    ];
    expect(mancanti, isEmpty,
        reason: 'la trascrizione non conosce questi nomi, e li sentira\' come '
            'la parola comune piu\' vicina, come "Mezz\'ora" per Medora');
  });

  test('A GEMINI ARRIVA PROPRIO QUELLA RICHIESTA', () {
    final sorgente =
        File('lib/services/voce/l_orecchio_del_live.dart').readAsStringSync();
    final chiamata = sorgente.indexOf('Future<String> _daGemini(');
    expect(chiamata, greaterThan(0),
        reason: 'la trascrizione non c\'e\' piu\'');
    final corpo = sorgente.substring(chiamata);
    expect(corpo.contains('TextPart(istruzione)'), isTrue,
        reason:
            'la richiesta con i nomi c\'e\', ma a Gemini ne arriva un\'altra');
  });
}

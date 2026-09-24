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

  test('LA TRASCRIZIONE LA FA FLASH, E PASSA DALLA RIPULITURA', () {
    // Ordine EK voce 03, `tool/banco_orecchio_ek.dart`: con l'elenco dei nomi
    // nell'istruzione Flash-Lite ha ricopiato l'elenco al posto della frase
    // in due frasi su sei e ha scritto "Medora" su tre secondi di fruscio;
    // Flash nessuna delle due cose.
    final sorgente =
        File('lib/services/voce/l_orecchio_del_live.dart').readAsStringSync();
    final corpo =
        sorgente.substring(sorgente.indexOf('Future<String> _daGemini('));
    expect(
        corpo.contains('model: FirebaseMaestroAiProvider.kMaestroChatModel,'),
        isTrue,
        reason: 'la trascrizione non la fa piu\' Flash: Flash-Lite ricopia '
            'l\'elenco dei nomi al posto della frase');
    expect(corpo.contains('ripulita(testo)'), isTrue,
        reason: 'cio\' che torna da Gemini diventa domanda senza passare dalla '
            'ripulitura: l\'elenco ricopiato partirebbe come domanda');
  });

  test('UN ELENCO DI NOMI NON E\' UNA FRASE, E CALÌGO HA L\'ACCENTO', () {
    final elenco = LaTrascrizione.nomiDelleArti;
    // Cio' che e' tornato sul Realme, e cio' che Flash-Lite ha dato al banco.
    expect(LaTrascrizione.ripulita('Medora Aura Calìgo'), isEmpty);
    expect(LaTrascrizione.ripulita('${elenco.join(', ')}.'), isEmpty);
    expect(LaTrascrizione.ripulita('Fehu, Uruz, Thurisaz'), isEmpty);
    // Le frasi vere restano com'erano, anche quelle fatte di nomi.
    const vere = [
      'Medora, ho pescato la Torre e poi l\'Appeso.',
      'Fehu, Thurisaz e Algiz.',
      'La Torre',
      'Medora',
      'Sono dello Scorpione con ascendente Sagittario e la Luna in Capricorno.',
    ];
    for (final frase in vere) {
      expect(LaTrascrizione.ripulita(frase), frase,
          reason: 'una frase vera e\' stata presa per un elenco ricopiato');
    }
    // Il fondatore: "è Calìgo e non Càligo".
    expect(LaTrascrizione.ripulita('Caligo, che cosa significa Eihwaz?'),
        'Calìgo, che cosa significa Eihwaz?');
    expect(LaTrascrizione.ripulita('ciao Càligo'), 'ciao Calìgo');
  });
}

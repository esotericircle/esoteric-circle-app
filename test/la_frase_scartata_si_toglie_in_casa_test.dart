import 'dart:convert';

import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/la_scena_dal_modello.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA FRASE SCARTATA SI TOGLIE IN CASA, SE IL RESTO REGGE.** Ordine EX
/// Aggiunta 4, voce EX.10: al banco del Viaggio (giro scena2) molte risposte
/// cadevano per una frase sola dopo la prima, che prendeva posizione (*"La
/// decisione di tua sorella non è tua da prendere, ma..."*, *"Quello che non
/// superi è un riflesso"*), e ogni scarto richiamava il modello. Adesso la
/// frase che non regge si toglie, e la risposta che resta ripassa da TUTTE
/// le guardie: se regge, il modello non si richiama. Le guardie non cambiano.
/// La prima frase non si toglie mai: e' la posizione.
void main() {
  final lupo = AnimalCatalog.animals.firstWhere((a) => a.name == 'Lupo');
  final s = CioCheSiSa(
    domanda: 'Devo lasciare la banca per aprire una bottega?',
    tema: 'Una scelta da fare',
    animale: lupo,
    natale: const NatalContext(sunSign: 'Cancro'),
    memoria: '',
    ultimeScene: const [],
  );

  String risposta(String testo, {Map<String, String> riserva = const {}}) =>
      jsonEncode({
        ...riserva,
        'luogo': 'grotta',
        'cosa': 'chiave',
        'gesto': 'aspetta',
        'momento': 'alba',
        'titolo': 'La bottega ti somiglia',
        'risposta': testo,
        'azione':
            'Domani mattina cammina fino alla via dove vorresti la bottega.',
      });

  test('la terza frase che non regge si toglie, e il modello non si richiama',
      () async {
    var chiamate = 0;
    final scritta = await LaScenaDalModello.chiediTutto(s,
        chiamata: (i, r, a) async {
          chiamate++;
          return risposta('Sulla bottega puoi scegliere tu il primo passo. '
              'Puoi chiedere in banca quanto dura un\'aspettativa. '
              'Abbraccia il cambiamento.');
        },
        prendiUnaChiamata: () async => true);
    expect(chiamate, 1);
    expect(
        scritta.testi.risposta,
        'Sulla bottega puoi scegliere tu il primo passo. Puoi chiedere in '
        'banca quanto dura un\'aspettativa.');
    expect(scritta.testi.dallaSeconda,
        contains('risposta: senza la frase scartata'));
  });

  test('la prima frase che non regge non si toglie: il modello si richiama',
      () async {
    var chiamate = 0;
    await LaScenaDalModello.chiediTutto(s,
        chiamata: (i, r, a) async {
          chiamate++;
          return risposta('Abbraccia il cambiamento. Sulla bottega puoi '
              'scegliere tu il primo passo. Puoi chiedere in banca quanto '
              'dura un\'aspettativa.');
        },
        prendiUnaChiamata: () async => true);
    expect(chiamate, greaterThan(1));
  });

  /// **LA SECONDA VERSIONE DALLA STESSA CHIAMATA.** Ordine EX Aggiunta 4,
  /// voce EX.10: il modello scrive anche una versione di riserva di ogni
  /// testo; se la prima non regge, la lettura prova quella, con le stesse
  /// guardie, e il modello non si richiama.
  test('la risposta di riserva che regge evita la seconda chiamata', () async {
    var chiamate = 0;
    final scritta = await LaScenaDalModello.chiediTutto(s,
        chiamata: (i, r, a) async {
          chiamate++;
          return risposta('Abbraccia il cambiamento.', riserva: {
            'rispostaDiRiserva':
                'Sulla bottega puoi scegliere tu il primo passo. Puoi '
                    'chiedere in banca quanto dura un\'aspettativa.',
          });
        },
        prendiUnaChiamata: () async => true);
    expect(chiamate, 1);
    expect(scritta.testi.risposta, startsWith('Sulla bottega puoi'));
    expect(scritta.testi.dallaSeconda, contains('risposta: di riserva'));
  });

  test('la riserva passa dalle stesse guardie: se non regge, si richiama',
      () async {
    var chiamate = 0;
    await LaScenaDalModello.chiediTutto(s,
        chiamata: (i, r, a) async {
          chiamate++;
          return risposta('Abbraccia il cambiamento.',
              riserva: {'rispostaDiRiserva': 'Lascia andare la banca.'});
        },
        prendiUnaChiamata: () async => true);
    expect(chiamate, greaterThan(1));
  });

  test('l\'istruzione chiede la riserva di ogni testo', () {
    final i = LaScenaDalModello.istruzione(lupo);
    for (final c in [
      'titoloDiRiserva',
      'rispostaDiRiserva',
      'azioneDiRiserva'
    ]) {
      expect(i, contains(c));
    }
  });
}

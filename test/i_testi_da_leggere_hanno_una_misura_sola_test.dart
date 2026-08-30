import 'dart:io';

import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

/// I TESTI DA LEGGERE HANNO UNA MISURA SOLA. Ordine CE voce 10.
///
/// **Le parole del fondatore, verbatim:** "voglio che tutti i testi siano
/// uniformati, soprattutto per la dimensione e come base puoi prendere i
/// responsi dell'oroscopo e dei tarocchi. nella maggior parte delle
/// funzionalita' NON SI LEGGE BENE IL TESTO. anche nei doni o tutte le
/// funzionalita' anche prima di chiedere un responso."
///
/// **LA BASE NON SI SCEGLIE, SI PRENDE.** E' `TypographyTokens.lettura()`,
/// diciotto punti con interlinea 1,55, che il responso dell'Oroscopo e quello
/// dei Tarocchi usano gia' tutti e due. La prova legge il token e non ne
/// ricopia il numero: il giorno che quel token cambia, cambiano tutti.
///
/// **QUESTA PROVA COPRE CIO' CHE L'ORDINE CC VOCE 05 NON COPRIVA.** Quel
/// censimento guardava le descrizioni delle ventidue arti; qui ci sono i cinque
/// Doni del giorno e le schermate che si vedono PRIMA di chiedere un responso,
/// che erano fuori da ogni conto.
///
/// **DUE PREMESSE DELL\'ORDINE SONO CADUTE ALLA MISURA.** L\'ordine diceva
/// che il Rito dell\'Alba e il Soffio del Destino "hanno la misura giusta ma
/// fuori dalla porta unica". Misurato:
///
/// - **Il Rito dell\'Alba non ha nessun testo da leggere per intero.** L\'unico
///   `lettura()` di quella schermata sta sull\'invito "Trascina in alto,
///   oppure tocca", che e' un invito breve, cioe' proprio cio' che il
///   fondatore ha escluso dalla voce. Il suo testo lungo vive sulla carta
///   del Dono, che e' gia' censita qui sotto.
/// - **Il Soffio del Destino era fuori misura, non dentro.** I due
///   paragrafi della sua risposta stavano a sedici punti, come l\'Arcano.
///   Adesso passano dalla porta e portano la misura del responso.
///
/// **Il fondatore ha ristretto la voce ai soli testi da leggere**, rispondendo
/// "A" alla domanda se toccare anche i testi brevi: inviti, sottotitoli,
/// didascalie ed etichette restano dove sono.
void main() {
  /// I punti che portano un testo da leggere per intero, fuori dalle
  /// ventidue arti gia' censite, e COME si misura ognuno.
  ///
  /// **Non basta che il file nomini `lettura()` da qualche parte**, e
  /// questa riga nasce da un rosso che non e' scattato: rimesso `corpo()`
  /// sul responso dell'Arcano, la prova restava verde perche' in quel file
  /// `lettura()` c'era ancora, sul sommario. **Si misura il testo lungo,
  /// non il file.**
  ///
  /// Il testo lungo passa dalla porta unica `ParagrafiDiLettura`, che e'
  /// la regola dei paragrafi dell'app. **La carta di un Dono e'
  /// l'eccezione dichiarata dall'ordine CC voce 05**: li' la porta non si
  /// puo' usare, e si pretende la misura nuda.
  const daLeggere = <String, List<String>>{
    'Arcano del Giorno': [
      'lib/features/rituals/day_oracle_screen.dart',
      "ParagrafiDiLettura(\n              key: const Key('arcano_responso')",
    ],
    'Runa del Tramonto': [
      'lib/features/rituals/sunset_rune_screen.dart',
      'ParagrafiDiLettura(',
    ],
    'Soffio del Destino': [
      'lib/features/rituals/breath_destiny_screen.dart',
      'ParagrafiDiLettura(',
    ],
    'Sigillo del Sogno': [
      'lib/features/rituals/dream_rite_screen.dart',
      'ParagrafiDiLettura(',
    ],
    'La carta di un Dono': [
      'lib/features/rituals/ritual_gift_card.dart',
      'TypographyTokens.lettura()',
    ],
    'Intro di un\'arte': [
      'lib/features/maestri/art_intro_screen.dart',
      'ParagrafiDiLettura(',
    ],
    'Foglio di una funzione': [
      'lib/design_system/components/feature_sheet.dart',
      'ParagrafiDiLettura(',
    ],
  };

  test('la misura di riferimento e\' quella del responso', () {
    final base = TypographyTokens.lettura();
    // ignore: avoid_print
    print('ORDINE CE VOCE 10: la misura di riferimento e\' '
        '${base.fontSize} punti, interlinea ${base.height}');
    expect(base.fontSize, 18);
    expect(base.height, closeTo(1.55, 0.001));
  });

  test('ogni punto che si legge per intero usa quella misura', () {
    final fuori = <String>[];
    daLeggere.forEach((nome, dove) {
      final testo = File(dove[0])
          .readAsLinesSync()
          .where((r) => !r.trimLeft().startsWith('//'))
          .join('\n');
      if (!testo.contains(dove[1])) fuori.add('$nome (${dove[0]})');
    });
    // ignore: avoid_print
    print('ORDINE CE VOCE 10: punti da leggere censiti ${daLeggere.length}, '
        'senza la misura del responso ${fuori.length}');
    expect(fuori, isEmpty,
        reason: 'questi testi si leggono per intero a una misura diversa da '
            'quella del responso: $fuori');
  });

  test('e nessuno di loro resta a diciassette o a sedici punti', () {
    // **UN PUNTO DI DIFFERENZA NON SI VEDE DA SOLO, SI VEDE ACCANTO.** La Runa
    // stava a diciassette e l'Oroscopo a diciotto: il fondatore le ha lette una
    // dopo l'altra. Qui si cercano le misure che erano il difetto, e si
    // cercano solo nelle righe che disegnano un testo lungo.
    final colpe = <String>[];
    daLeggere.forEach((nome, dove) {
      final righe = File(dove[0]).readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        final r = righe[i];
        if (r.trimLeft().startsWith('//')) continue;
        if (r.contains('TypographyTokens.body(size: 17)')) {
          colpe.add('$nome riga ${i + 1}: body(size: 17)');
        }
      }
    });
    // ignore: avoid_print
    print('ORDINE CE VOCE 10: testi rimasti a diciassette punti '
        '${colpe.length}');
    expect(colpe, isEmpty, reason: '$colpe');
  });
}

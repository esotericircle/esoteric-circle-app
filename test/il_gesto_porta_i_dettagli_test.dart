import 'dart:io';

import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// IL GESTO PORTA CON SE' CIO' CHE LA SCENA SA. Ordine AR voce 11.
///
/// **Perche' esiste questa voce.** Fino a qui al Cammino arrivava solo il nome
/// del gesto: "una stesa e' avvenuta". Con quel poco si possono chiedere solo
/// quantita', e infatti i traguardi che ne nascevano erano conteggi nudi, che
/// Mauro ha bocciato. Le condizioni che valgono qualcosa chiedono altro:
/// tutti e quattro i semi, la stessa carta in due stese, tutti i modi della
/// gettata provati. Sono domande sui DETTAGLI.
///
/// **Cosa si tiene, e quanto pesa.** Per ogni `gesto.chiave` si tengono i
/// valori visti e quante volte: non le date, non l'ordine, non uno storico.
/// Il tetto e' di 128 valori distinti per chiave, che tiene tutti i domini
/// veri (78 carte, 24 rune, 16 argomenti, 4 semi) con margine.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<DiarioDelCammino> diario() async {
    SharedPreferences.setMockInitialValues(const {});
    final d = DiarioDelCammino(orologio: orologioDelleProve);
    await d.carica();
    return d;
  }

  test('la varieta si conta: quanti valori diversi', () async {
    final d = await diario();
    await d.segna('stesa', dettagli: {
      'semi': ['coppe', 'spade'],
    });
    await d.segna('stesa', dettagli: {
      'semi': ['coppe', 'bastoni', 'denari'],
    });
    // ignore: avoid_print
    print('ORDINE AR VOCE 11: semi diversi visti '
        '${d.quantiValoriDistinti('stesa', 'semi')}');
    expect(d.quantiValoriDistinti('stesa', 'semi'), 4,
        reason: 'la condizione "tutti e quattro i semi" non puo esistere: la '
            'varieta non si conta');
  });

  test('la coincidenza si conta: quante volte torna la stessa', () async {
    final d = await diario();
    await d.segna('stesa', dettagli: {
      'carte': ['torre', 'stella'],
    });
    await d.segna('stesa', dettagli: {
      'carte': ['torre', 'luna'],
    });
    // ignore: avoid_print
    print('ORDINE AR VOCE 11: la carta piu insistente e tornata '
        '${d.massimaRipetizione('stesa', 'carte')} volte');
    expect(d.quanteVolteIlValore('stesa', 'carte', 'torre'), 2);
    expect(d.massimaRipetizione('stesa', 'carte'), 2,
        reason: 'la condizione "la stessa carta in due stese" non puo '
            'esistere: le coincidenze non si contano');
  });

  test('i dettagli sopravvivono a una riapertura', () async {
    final d = await diario();
    await d.segna('gettata', dettagli: {'modo': 'tre_norne'});
    await d.segna('gettata', dettagli: {'modo': 'croce'});
    final secondo = DiarioDelCammino(orologio: orologioDelleProve);
    await secondo.carica();
    // ignore: avoid_print
    print('ORDINE AR VOCE 11: dopo la riapertura i modi provati sono '
        '${secondo.quantiValoriDistinti('gettata', 'modo')}');
    expect(secondo.quantiValoriDistinti('gettata', 'modo'), 2,
        reason: 'i dettagli non arrivano al disco: alla riapertura la varieta '
            'riparte da zero e nessuna condizione lunga puo maturare');
  });

  test('il peso e limitato, e si perde la varieta non la coincidenza',
      () async {
    final d = await diario();
    // Piu' valori del tetto: i primi entrano, gli altri no.
    for (var i = 0; i < DiarioDelCammino.quantiValoriPerChiave + 40; i++) {
      await d.segna('prova', dettagli: {'valore': 'v$i'});
    }
    // E il primo continua a contare anche a tetto raggiunto.
    await d.segna('prova', dettagli: {'valore': 'v0'});
    // ignore: avoid_print
    print('ORDINE AR VOCE 11: valori tenuti '
        '${d.quantiValoriDistinti('prova', 'valore')} sul tetto di '
        '${DiarioDelCammino.quantiValoriPerChiave}, e v0 conta '
        '${d.quanteVolteIlValore('prova', 'valore', 'v0')}');
    expect(d.quantiValoriDistinti('prova', 'valore'),
        DiarioDelCammino.quantiValoriPerChiave,
        reason: 'il tetto dichiarato non e rispettato');
    expect(d.quanteVolteIlValore('prova', 'valore', 'v0'), 2,
        reason: 'a tetto raggiunto si e smesso di contare anche i valori gia '
            'presenti: si perderebbe una coincidenza gia cominciata');
  });

  test('un gesto senza dettagli non registra niente in piu', () async {
    final d = await diario();
    await d.segna('alba');
    expect(d.quantiValoriDistinti('alba', 'qualunque'), 0);
  });

  /// **L'ENUMERAZIONE DEI PUNTI, e dice anche cosa NON e stato passato.**
  ///
  /// Il rapporto di questa voce serve all'Architetto per sapere su quali
  /// dettagli puo' contare quando scrive le condizioni: qui si sorveglia che
  /// i punti dichiarati passino davvero i loro dettagli, e la lista dice
  /// quale chiave ci si aspetta.
  const puntiCoiDettagli = <String, List<String>>{
    'lib/features/tarot/stesa_tre_carte_screen.dart': [
      "'carte'", "'semi'", "'maggiori'", "'argomento'",
    ],
    'lib/features/maestri/caligo/rune/rune_draw_screen.dart': ["'modo'"],
    'lib/features/rituals/sunset_rune_screen.dart': ["'runa'"],
    'lib/features/synastry/sinastria_gallery_screen.dart': ["'vip'"],
    'lib/features/maestri/aura/archetype/archetype_test_screen.dart': [
      "'archetipo'",
    ],
    'lib/features/maestri/caligo/animal/guide_animal_screen.dart': [
      "'animale'",
    ],
    'lib/features/horoscope/oroscopo_screen.dart': ["'periodo'"],
  };

  test('ogni punto dichiarato passa davvero i suoi dettagli', () {
    final senza = <String>[];
    for (final voce in puntiCoiDettagli.entries) {
      final sorgente = File(voce.key).readAsStringSync();
      for (final chiave in voce.value) {
        if (!sorgente.contains('dettagli: {') ||
            !sorgente.contains('$chiave:')) {
          senza.add('${voce.key} senza $chiave');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE AR VOCE 11: punti che non passano i loro dettagli: $senza');
    expect(senza, isEmpty,
        reason: 'questi punti hanno smesso di passare cio che sanno, e le '
            'condizioni che ci poggiano sopra non potranno mai maturare: '
            '$senza');
  });
}

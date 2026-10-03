// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/identity/birth_moon.dart';
import 'package:esoteric_circle/core/rituals/dream_rite_corpus.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL SALUTO DELLA NOTTE PARLA DI TE, NON DI CHIUNQUE.** Ordine EE voce
/// 04, 23 settembre 2026.
///
/// **Il fatto del fondatore, verbatim**: *"sigillo del sogno: va bene, ma
/// controlla che il testo generato sia giusto e coerente, ho dubbi sul testo
/// che ho messo nel riquadro rosso, mi sembra generico"*.
///
/// **Cosa era generico, e cosa invece era gia' vero.** Il saluto afferma
/// cinque cose. La fase e il segno della Luna erano **veri** (*"la Luna
/// cresce in Acquario"*), l'angolo con la Luna natale era **vero** (*"non
/// forma nessun angolo maggiore con la tua"*), e il richiamo alla carta
/// dell'alba c'era. **Erano false le due frasi che parlano della sua
/// giornata**: *"Oggi hai pensato in largo, per tutti"* e *"hai tenuto uno
/// sguardo libero"* venivano dal segno della Luna **di stanotte**, che
/// stanotte e' lo stesso per chiunque apra l'app. Il rito diceva a tutti gli
/// utenti che avevano passato la stessa giornata.
///
/// **La cura usa un dato che c'era e nessuno leggeva**, la Luna di nascita.
/// **Padre: PROVENIENZA IGNOTA**: il saluto nasce sulla sola Luna di
/// stanotte, e l'ordine CE voce 13, che ha aggiunto la nascita, l'ha usata
/// per il solo angolo fra le due Lune.
void main() {
  /// Una notte sola, e due persone diverse: e' la misura.
  final laStessaNotte = DateTime(2026, 9, 21, 23, 41);

  test('due persone diverse non si sentono dire la stessa giornata', () {
    // Dodici nascite, una per segno lunare, tutte nella stessa notte.
    final saluti = <Zodiac, String>{};
    for (var mese = 1; mese <= 12; mese++) {
      // Un giorno per mese: le Lune di nascita cadono in segni diversi.
      final nascita = DateTime(1974, mese, 8, 3, 30);
      final segno = BirthMoon.forDate(nascita).sign;
      saluti[segno] = DreamRiteCorpus.saluto(laStessaNotte, nascita: nascita);
    }
    cardinaleMinimo(saluti.length, 4,
        cosa: 'segni lunari di nascita diversi nella stessa notte',
        perche: 'Se tutte e dodici le nascite cadessero nello stesso segno '
            'lunare, questa prova confronterebbe un saluto con se stesso.');

    final diversi = saluti.values.toSet();
    print('ORDINE EE VOCE 04: nascite in segni lunari diversi '
        '${saluti.length}, saluti diversi ${diversi.length}');
    expect(diversi.length, saluti.length,
        reason: 'nella stessa notte persone con Lune di nascita diverse si '
            'sentono dire la STESSA giornata: il saluto la prende dalla Luna '
            'di stanotte, che stanotte e\' uguale per tutti');
  });

  test('e cio\' che dice della notte resta della notte', () {
    // **L'altra meta'.** Se tutto venisse dalla Luna di nascita, il saluto
    // smetterebbe di parlare di stanotte: l'immagine e la fase sono della
    // notte, e devono restarci.
    final notte = DreamRiteCorpus.lunaDi(laStessaNotte);
    final suo = DreamRiteCorpus.saluto(laStessaNotte,
        nascita: DateTime(1974, 7, 8, 3, 30));
    final apertura = DreamRiteCorpus.aperturaLuna(notte);
    print('ORDINE EE VOCE 04, la notte nel saluto: "$apertura"');
    expect(suo, contains(apertura),
        reason: 'il saluto non dice piu\' in che segno e\' la Luna di '
            'stanotte, che e\' il fatto vero da cui il rito parte');
    expect(suo, contains(DreamRiteCorpus.voce(notte.sign).immagine),
        reason: 'l\'immagine della notte non c\'e\' piu\'');
  });

  test('chi non ha dato la nascita ha ancora il suo saluto', () {
    final senza = DreamRiteCorpus.saluto(laStessaNotte);
    print('ORDINE EE VOCE 04, senza nascita: ${senza.length} caratteri');
    expect(senza, contains('Buonanotte.'));
    expect(senza.length, greaterThan(120),
        reason: 'chi non ha dato la nascita ha perso il Dono, e non doveva');
  });
}

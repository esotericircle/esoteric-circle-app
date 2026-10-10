// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/rituals/dream_rite_corpus.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL SALUTO DELLA NOTTE NON RIPETE IL TITOLO.** Ordine EE voce 05, 23
/// settembre 2026.
///
/// **Il fatto, visto sulla cattura del fondatore.** Il titolo grande diceva
/// *"Lascia andare il pensiero, la notte non chiede visione, chiede
/// riposo."* e il testo sotto, dieci righe piu' giu', diceva *"Ora lascia
/// andare il pensiero, la notte non chiede visione, chiede riposo."*. La
/// stessa frase due volte nella stessa schermata.
///
/// **Padre: ordine CO voce 17**, e non e' una svista. Fino a quell'ordine la
/// `posa` viveva solo in fondo al saluto; CO l'ha **promossa a titolo**
/// perche' la gerarchia vuole una risposta in cima, e il suo stesso commento
/// dichiara che *"il saluto per intero non cambia di una virgola"*. Era vero,
/// ed e' il difetto: la cura ha aggiunto il titolo senza togliere la coda.
///
/// **Si misura su tutti e dodici i segni lunari**, non sul solo Acquario
/// della cattura: la posa e' una per segno, e un difetto che vive nel modo
/// in cui la frase si compone li riguarda tutti.
void main() {
  test('nessun segno ripete la sua posa fra il titolo e il saluto', () {
    const segni = Zodiac.values;
    cardinaleMinimo(segni.length, 12,
        cosa: 'segni lunari con una posa della notte',
        perche: 'La posa e\' una per segno: se la tavola si svuotasse, '
            'questa prova direbbe di si\' a niente.');

    // Una notte qualunque, e una nascita: il saluto ha due forme, con e
    // senza la riga della relazione lunare, e tutte e due finivano con la
    // posa.
    final quando = DateTime(2026, 9, 21, 23, 41);
    final ripetuti = <String>[];
    for (final segno in segni) {
      final titolo = DreamRiteCorpus.rispostaDellaNotte(segno);
      // Il titolo senza la maiuscola e il punto e' esattamente la posa, cioe'
      // cio' che non deve ricomparire nel saluto.
      final posa = DreamRiteCorpus.voce(segno).posa.trim();
      for (final nascita in <DateTime?>[null, DateTime(1974, 7, 8, 3, 30)]) {
        final saluto = DreamRiteCorpus.saluto(quando, nascita: nascita);
        if (saluto.toLowerCase().contains(posa.toLowerCase())) {
          ripetuti.add('${segno.name}: il saluto ripete "$titolo"');
        }
      }
    }
    print('ORDINE EE VOCE 05: segni guardati ${segni.length}, '
        'con la posa ripetuta ${ripetuti.length}');
    expect(ripetuti, isEmpty,
        reason: 'il saluto ripete parola per parola il titolo della '
            'schermata:\n${ripetuti.take(3).join("\n")}');
  });

  test('e il titolo continua a esserci, che e\' l\'altra meta\'', () {
    // **Senza questa, togliere la posa da tutte e due le parti farebbe
    // passare la prova qui sopra** e lascerebbe la schermata senza la frase
    // che l'ordine CO voce 17 ha messo in cima apposta.
    final vuoti = <String>[];
    for (final segno in Zodiac.values) {
      final titolo = DreamRiteCorpus.rispostaDellaNotte(segno);
      if (titolo.trim().length < 20) vuoti.add(segno.name);
    }
    print('ORDINE EE VOCE 05: titoli troppo corti ${vuoti.length}');
    expect(vuoti, isEmpty,
        reason: 'questi segni non hanno piu\' una risposta della notte da '
            'mostrare in cima: $vuoti');
  });
}

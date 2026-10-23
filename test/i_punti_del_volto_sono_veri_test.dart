import 'package:esoteric_circle/core/face/punti_del_volto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **I PUNTI DEL VOLTO SONO VERI.** Ordine CR voci 02 e 05, 6 settembre 2026.
///
/// **Perche' questa guardia esiste.** Gli indici dei gruppi della MediaPipe
/// Face Mesh sono centoquaranta numeri scritti a mano, e un numero scritto a
/// mano si sbaglia in silenzio: un 463 al posto di 163 non fa cadere niente,
/// sposta soltanto un punto dall'occhio a un'altra parte del viso, e la misura
/// del tratto diventa falsa senza che nessuno se ne accorga.
///
/// **Questa prova non puo' dire se un indice e' quello GIUSTO** — per saperlo
/// servirebbe il modello davanti — e lo dichiara invece di fingere. Dice tre
/// cose che si possono misurare, e sono quelle che prendono gli errori veri:
/// che ogni indice esista dentro i 478 punti, che nessun gruppo sia vuoto o
/// ridotto a un punto solo, e che occhi e sopracciglia dei due lati **non
/// condividano nessun punto**, che e' l'errore di copia-incolla piu' probabile.
void main() {
  test('ogni indice sta dentro i punti che la mesh restituisce', () {
    final fuori = <String>[];
    var quanti = 0;
    for (final gruppo in PuntiDelVolto.gruppi.entries) {
      for (final i in gruppo.value) {
        quanti++;
        if (i < 0 || i >= PuntiDelVolto.quantiPunti) {
          fuori.add('${gruppo.key}: $i');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE CR VOCE 02: gruppi ${PuntiDelVolto.gruppi.length}, indici '
        'in tutto $quanti, fuori dai ${PuntiDelVolto.quantiPunti} punti '
        '${fuori.length}');
    cardinaleMinimo(PuntiDelVolto.gruppi.length, 8,
        cosa: 'gruppi di punti dichiarati',
        perche: 'Con pochi gruppi la prova direbbe che sono tutti buoni per '
            'non averne guardati abbastanza: il fondatore ha nominato occhi, '
            'bocca, naso, fronte e sopracciglia, e servono tutti.');
    expect(fuori, isEmpty,
        reason: 'questi indici cadono fuori dai punti che la mesh '
            'restituisce, quindi il punto non esiste e il tratto si misura su '
            'un buco: ${fuori.join(", ")}');
  });

  test('e nessun gruppo e vuoto o ridotto a un punto', () {
    final poveri = <String>[];
    for (final g in PuntiDelVolto.gruppi.entries) {
      if (g.value.length < 2) poveri.add('${g.key} (${g.value.length})');
    }
    // ignore: avoid_print
    print('ORDINE CR VOCE 02: gruppi con meno di due punti ${poveri.length}');
    expect(poveri, isEmpty,
        reason: 'questi gruppi non bastano a misurare niente: una distanza '
            'vuole due punti, una larghezza ne vuole due, un contorno di piu. '
            '${poveri.join(", ")}');
  });

  test('e i due lati non si scambiano nessun punto', () {
    // **L'ERRORE PIU' PROBABILE E' IL COPIA-INCOLLA FRA I DUE LATI**, e non
    // farebbe cadere niente: la misura uscirebbe simmetrica per costruzione,
    // cioe' sbagliata sempre e in modo credibile.
    final coppie = <String, (List<int>, List<int>)>{
      'occhi': (PuntiDelVolto.occhioSinistro, PuntiDelVolto.occhioDestro),
      'sopracciglia': (
        PuntiDelVolto.sopraccioSinistro,
        PuntiDelVolto.sopraccioDestro
      ),
      'guance': (PuntiDelVolto.guanciaSinistra, PuntiDelVolto.guanciaDestra),
    };
    final condivisi = <String>[];
    for (final c in coppie.entries) {
      final comuni = c.value.$1.toSet().intersection(c.value.$2.toSet());
      if (comuni.isNotEmpty) condivisi.add('${c.key}: ${comuni.join(", ")}');
    }
    // ignore: avoid_print
    print('ORDINE CR VOCE 02: coppie sinistra-destra guardate '
        '${coppie.length}, con punti in comune ${condivisi.length}');
    cardinaleMinimo(coppie.length, 3,
        cosa: 'coppie di gruppi speculari guardate',
        perche: 'Con meno coppie la prova non guarda i punti dove il copia '
            'incolla fra i due lati avviene davvero.');
    expect(condivisi, isEmpty,
        reason: 'questi gruppi speculari condividono un punto: e il segno di '
            'un copia incolla fra sinistra e destra, e la misura uscirebbe '
            'simmetrica per costruzione, cioe sbagliata sempre e in modo '
            'credibile. ${condivisi.join("; ")}');
  });

  test('e ogni gruppo nomina punti distinti fra loro', () {
    final doppi = <String>[];
    for (final g in PuntiDelVolto.gruppi.entries) {
      // L'ovale e i labbri si chiudono su se stessi, quindi il primo punto
      // puo' tornare in fondo: si tollera UNA ripetizione, non di piu'.
      final quanteVolte = g.value.length - g.value.toSet().length;
      if (quanteVolte > 1) doppi.add('${g.key}: $quanteVolte ripetuti');
    }
    // ignore: avoid_print
    print('ORDINE CR VOCE 02: gruppi con punti ripetuti ${doppi.length}');
    expect(doppi, isEmpty,
        reason: 'questi gruppi nominano lo stesso punto piu volte: o e un '
            'refuso, o il contorno gira su se stesso e la misura conta due '
            'volte lo stesso pixel. ${doppi.join(", ")}');
  });
}

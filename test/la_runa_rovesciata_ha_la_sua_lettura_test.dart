import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:esoteric_circle/core/rituals/sunset_rune.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA RUNA ROVESCIATA HA LA SUA LETTURA.** Ordine CQ voce 2.08,
/// 3 settembre 2026.
///
/// **Il fatto, parole del fondatore:** la runa rovesciata non ha una lettura.
///
/// **Che cosa si misura, e su tutte e quarantotto le combinazioni.** Ogni
/// runa in ogni verso deve dare una riga non vuota, e la riga del verso
/// d'ombra deve essere DIVERSA da quella del verso dritto. Le due pretese
/// sono separate perche' i due difetti sono diversi: una riga vuota lascia la
/// scheda muta, una riga uguale lascia credere che il verso non conti
/// niente, ed e' il secondo che si legge come "non ha una lettura".
///
/// **Le otto simmetriche sono un caso a parte e si dichiara.** Fehu si
/// rovescia, Gebo no: capovolta e' identica a se stessa. Per quelle il verso
/// d'ombra non esiste in tradizione, e pretendere una riga diversa vorrebbe
/// dire inventarla. La prova le conta e le nomina invece di saltarle in
/// silenzio.
void main() {
  test('ogni runa in ogni verso porta una riga, e non e la stessa', () {
    var coppie = 0;
    final vuote = <String>[];
    final uguali = <String>[];
    var simmetriche = 0;
    for (final runa in kElderFuthark) {
      const dove = PosizioneGettata('Prova', 'la sola posizione che serve qui');
      final dritta =
          RunaGettata(rune: runa, verso: RuneVerso.dritto, posizione: dove);
      final rovescia =
          RunaGettata(rune: runa, verso: RuneVerso.merkstave, posizione: dove);
      coppie++;
      if (dritta.riga.trim().isEmpty) vuote.add('${runa.name} diritta');
      if (rovescia.riga.trim().isEmpty) vuote.add('${runa.name} rovesciata');
      if (kRuneSimmetriche.contains(runa.name)) {
        simmetriche++;
        continue;
      }
      if (dritta.riga == rovescia.riga) uguali.add(runa.name);
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.08: rune guardate $coppie, di cui simmetriche '
        '$simmetriche; righe vuote ${vuote.length}, righe uguali nei due '
        'versi ${uguali.length}');
    cardinaleMinimo(coppie, 24,
        cosa: 'rune del Futhark antico guardate nei due versi',
        perche: 'Con un corpus vuoto le due pretese sarebbero vere per '
            'assenza, e la prova sarebbe verde senza aver letto niente.');
    expect(vuote, isEmpty,
        reason: 'queste rune non hanno nessuna riga da leggere: '
            '${vuote.join(", ")}');
    expect(uguali, isEmpty,
        reason: 'queste rune dicono la stessa cosa dritte e rovesciate, '
            'quindi il verso non porta nessuna informazione: '
            '${uguali.join(", ")}');
  });

  test('e la lettura del rovescio arriva anche al Tramonto', () {
    // **NON BASTA CHE IL CORPUS CE L'ABBIA**: la Runa del Tramonto sceglie
    // quale delle due righe mostrare, e una schermata che mostrasse sempre la
    // diritta renderebbe il rovescio una decorazione. Si misura su un anno.
    var inOmbra = 0;
    var conLaSua = 0;
    final identita = SunsetRune.identitaPer(
        nascita: DateTime(1985, 6, 15, 14, 30), oraNota: true, deviceId: 'a');
    for (var i = 0; i < 365; i++) {
      final giorno = DateTime(2026, 1, 1, 20).add(Duration(days: i));
      final e = SunsetRune.estrai(giorno, identita: identita);
      if (!e.inOmbra || e.simmetrica) continue;
      inOmbra++;
      if (e.rune.shadow.isNotEmpty && e.rune.shadow != e.rune.upright) {
        conLaSua++;
      }
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.08: su 365 sere, rune rovesciate non simmetriche '
        '$inOmbra, con una lettura propria $conLaSua');
    cardinaleMinimo(inOmbra, 30,
        cosa: 'sere con una runa rovesciata non simmetrica',
        perche: 'Se il rovescio non uscisse mai, la prova sarebbe verde senza '
            'aver mai incontrato il caso che il fondatore ha nominato.');
    expect(conLaSua, inOmbra,
        reason: 'in ${inOmbra - conLaSua} sere la runa esce rovesciata e la '
            'lettura e quella diritta: il rovescio si vede e non si legge');
  });
}

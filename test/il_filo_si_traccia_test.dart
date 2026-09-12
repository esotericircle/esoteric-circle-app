import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// IL FILO SI TRACCIA, E IL RITO DEL SOGNO CAMBIA NOME. Ordine AS voce 10.
///
/// **Le due cose che la voce chiede.** Che il dono si chiami Sigillo del Sogno
/// ovunque, e che al tocco sulla stella accesa la linea non compaia di colpo:
/// si traccia, poi si illumina la stella successiva.
///
/// **Perche' il tracciamento si sorveglia sul sorgente.** Il filo vive dentro
/// un `CustomPainter` che riceve un valore da un controllore di animazione:
/// fotografarlo a meta' corsa vorrebbe dire montare la scena del Sogno intera,
/// coi suoi sensori e la sua figura, per misurare quanti pixel di segmento ci
/// sono a un istante scelto. Qui si pretende l'invariante che conta: che il
/// filo appena nato dipenda dal tracciamento, e che a Riduci Movimento sia
/// intero subito.
void main() {
  final componente = File('lib/design_system/components/stelle_da_unire.dart')
      .readAsStringSync();
  final soloCodice = componente
      .split(String.fromCharCode(10))
      .where((r) => !r.trimLeft().startsWith('//'))
      .join(String.fromCharCode(10));

  test('il filo appena nato si allunga col tracciamento', () {
    expect(soloCodice.contains('_traccia = AnimationController'), isTrue,
        reason: 'il controllore del tracciamento non esiste piu: il filo torna '
            'a comparire di colpo');
    expect(soloCodice.contains('required this.tracciato'), isTrue,
        reason: 'il pittore non riceve piu quanto e tracciato il filo');
    expect(soloCodice.contains('Offset.lerp(pa, pb, tracciato)'), isTrue,
        reason: 'il capo del filo non corre piu dal punto vecchio a quello '
            'nuovo: il valore arriva al pittore e non lo usa nessuno');
    expect(soloCodice.contains('old.tracciato != tracciato'), isTrue,
        reason: 'il pittore non si ridisegna quando il tracciamento avanza, '
            'quindi il filo si allunga solo se cambia qualcos altro: '
            'l animazione non si vedrebbe mai');
  });

  test('con Riduci Movimento il passaggio e secco', () {
    expect(
        soloCodice
            .contains('tracciato: _riduciMovimento || !_traccia.isAnimating'),
        isTrue,
        reason: 'con Riduci Movimento il filo non e piu intero subito: si '
            'toglie il movimento, non il contenuto');
  });

  test('il dono si chiama Sigillo del Sogno, ovunque', () {
    var osservati = 0;
    final vecchi = <String>[];
    for (final file in sorgentiDiLib()) {
      final testo = file.readAsStringSync();
      osservati++;
      if (testo.contains('Rito del Sogno')) {
        vecchi.add(file.path.replaceAll(String.fromCharCode(92), '/'));
      }
    }
    // ignore: avoid_print
    print('ORDINE AS VOCE 10: file guardati $osservati, che nominano ancora il '
        'Rito del Sogno ${vecchi.length}');
    expect(osservati, greaterThan(100),
        reason: 'la ricerca gira quasi a vuoto');
    expect(vecchi, isEmpty,
        reason: 'questi file chiamano ancora il dono col nome vecchio: '
            '${vecchi.take(5).join("; ")}');
  });

  test('anche il corpus dei traguardi lo chiama col nome nuovo', () {
    // Le frasi dei traguardi nominano i doni, e sono generate: la traduzione
    // vive nel generatore, non nei file generati.
    final generatore =
        File('tool/genera_sentieri_dal_corpus.py').readAsStringSync();
    expect(generatore.contains("'Rito del Sogno': 'Sigillo del Sogno'"), isTrue,
        reason: 'il generatore non traduce piu il nome del dono: al primo '
            'rigenero il corpus rimette il nome vecchio');
    for (final sentiero in const [
      'lib/core/sigilli/sentiero_costellazione.dart',
      'lib/core/sigilli/sentiero_albero.dart',
      'lib/core/sigilli/sentiero_loto.dart',
    ]) {
      expect(
          File(sentiero).readAsStringSync().contains('Rito del Sogno'), isFalse,
          reason: '$sentiero nomina ancora il Rito del Sogno');
    }
  });
}

// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE DM, LA PREDISPOSIZIONE MULTILINGUA.
///
/// **Non e' una promessa, e' una prova che non passa.** Legge il manifesto e
/// resta rossa finche' le sette voci non hanno uno stato terminale.
///
/// **E sorveglia le due cose che quest'ordine non deve rompere**, perche' un
/// ordine che apre la strada a una lingua nuova e' anche l'ordine che puo'
/// far sparire l'italiano senza che nessuno se ne accorga: che il corpus
/// editoriale resti al suo posto, e che la porta della lingua non torni a
/// essere un dato scritto in piu' punti.
void main() {
  final manifesto = File('docs/ordini/ORDINE_DM_MANIFESTO.md');

  const quante = 7;

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome');
    return int.parse(trovato!.group(1)!);
  }

  List<String> vociDi(String testo) {
    final voci = <String>[];
    final buffer = StringBuffer();
    for (final r in testo.split('\n')) {
      if (RegExp(r'^- \*\*DM\.\d\d\*\*').hasMatch(r)) {
        if (buffer.isNotEmpty) voci.add(buffer.toString());
        buffer.clear();
        buffer.writeln(r);
      } else if (buffer.isNotEmpty) {
        if (r.startsWith('  ')) {
          buffer.writeln(r);
        } else {
          voci.add(buffer.toString());
          buffer.clear();
        }
      }
    }
    if (buffer.isNotEmpty) voci.add(buffer.toString());
    return voci;
  }

  test('il manifesto esiste e porta tutte e sette le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'il manifesto nasce prima del codice');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= quante; i++) {
      final voce = 'DM.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('**$voce**')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty, reason: 'voci non nominate: $mancanti');
  });

  test('i marcatori dicono il vero, contati sulle voci', () {
    final testo = manifesto.readAsStringSync();
    final voci = vociDi(testo);
    expect(voci, hasLength(quante));
    var aperte = 0, attesa = 0, premessa = 0, chiuse = 0;
    for (final v in voci) {
      if (v.contains('APERTA')) {
        aperte++;
      } else if (v.contains('FERMATA IN ATTESA DI DECISIONE')) {
        attesa++;
      } else if (v.contains('FERMATA SU PREMESSA FALSA')) {
        premessa++;
      } else if (v.contains('CHIUSA')) {
        chiuse++;
      }
    }
    print('ORDINE DM: voci osservate ${voci.length}, chiuse $chiuse');
    expect(marcatore(testo, 'VOCI_TOTALI'), voci.length);
    expect(marcatore(testo, 'VOCI_APERTE'), aperte);
    expect(marcatore(testo, 'VOCI_CHIUSE'), chiuse);
    expect(aperte + attesa + premessa + chiuse, quante);
  });

  test('IL MANIFESTO DICHIARA IL METODO DELLE MISURE, non solo i numeri', () {
    // **Perche' una guardia su questo.** L'ordine avverte che una ricerca
    // testuale conta i commenti insieme al codice, e le premesse di
    // quest'ordine sono quasi tutte conteggi. Un manifesto che desse i numeri
    // senza dire come sono stati presi sarebbe indistinguibile da uno che li
    // ha stimati, e fra sei mesi nessuno potrebbe rifarli.
    final testo = manifesto.readAsStringSync();
    expect(testo, contains('DM.00.A'),
        reason: 'manca la regola che impone di rimisurare');
    expect(testo.toLowerCase(), contains('commento'),
        reason: 'il manifesto non dice come ha separato i commenti dal '
            'codice: i suoi numeri non si possono rifare');
    expect(testo, contains('dart pub add --dry-run'),
        reason: 'manca il piano della risoluzione a secco, che l ordine '
            'chiede di guardare PRIMA di toccare il pubspec');
  });

  test('l\'ordine DM non e\' finito finche\' una voce resta aperta', () {
    final aperte = marcatore(manifesto.readAsStringSync(), 'VOCI_APERTE');
    expect(aperte, 0,
        reason: 'restano $aperte voci APERTE. Questa riga e rossa apposta: '
            'torna verde quando le sette voci hanno uno stato terminale');
  });
}

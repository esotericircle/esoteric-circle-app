import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL REGISTRO DELLE GUARDIE DEVE QUADRARE, E NON DEVE MENTIRE SU NESSUNA
/// RIGA.** Ordine CM voce 01, 1 settembre 2026.
///
/// **Perche' esiste.** Il registro nasce dall'ordine CL con tre numeri che non
/// sommavano al totale. Nessuno poteva dire quale dei tre fosse sbagliato,
/// perche' erano tutti scritti a mano e nessuno li ricontava. Un documento che
/// non quadra non e' un documento inesatto: **e' un documento di cui non si sa
/// piu' quale parte credere.**
///
/// **Cosa pretende, e sono due cose diverse.** Che le categorie sommino al
/// totale dichiarato, e che il totale dichiarato sia il numero di righe che il
/// registro elenca davvero. Un registro puo' quadrare benissimo su numeri
/// inventati: la seconda pretesa e' quella che lo aggancia alla realta'.
///
/// **E che nessuna riga menta.** Per ogni guardia elencata si apre il suo file
/// e si guarda come dichiara il cardinale, poi si confronta con la casella. E'
/// il controllo che ha valore nel tempo: le tre cifre in cima le riscrive
/// chiunque, le duecentoquarantadue righe no.
void main() {
  final registro = File('docs/guardie.md');

  /// Legge il numero da una riga di tavola scritta `| etichetta | 42 |`.
  int numeroDellaRiga(List<String> righe, String etichetta) {
    final riga = righe.firstWhere(
      (r) => r.startsWith('|') && r.contains(etichetta),
      orElse: () => '',
    );
    expect(riga, isNotEmpty,
        reason: 'il registro non ha piu\' la riga "$etichetta": o l\'ha persa, '
            'o questa prova sta guardando un documento che non e\' piu\' '
            'quello');
    final cifre = RegExp(r'\d+').allMatches(riga).map((m) => m.group(0)!);
    expect(cifre, isNotEmpty,
        reason: 'la riga "$etichetta" non porta piu\' nessun numero: $riga');
    return int.parse(cifre.last);
  }

  test('le categorie sommano al totale, e il totale sono le righe vere', () {
    expect(registro.existsSync(), isTrue,
        reason: 'docs/guardie.md non esiste: la prova va eseguita dalla '
            'radice del progetto');
    final righe = registro.readAsLinesSync();

    final dallaPorta = numeroDellaRiga(righe, 'passano dalla porta comune');
    final proprio = numeroDellaRiga(righe, 'cardinale proprio dichiarato');
    final altrove = numeroDellaRiga(righe, 'non scoprono nessun insieme');
    final somma = numeroDellaRiga(righe, 'Somma delle categorie');
    final totale = numeroDellaRiga(righe, 'Guardie secondo la definizione');

    expect(dallaPorta + proprio + altrove, somma,
        reason: 'LE CATEGORIE NON SOMMANO ALLA SOMMA SCRITTA: '
            '$dallaPorta + $proprio + $altrove fa '
            '${dallaPorta + proprio + altrove}, ma il registro dice $somma.');
    expect(somma, totale,
        reason: 'la somma delle categorie ($somma) non e\' il totale delle '
            'guardie ($totale): il registro sta contando due insiemi diversi '
            'e chiamandoli con lo stesso nome, che e\' il difetto piu\' '
            'numeroso di questo progetto.');

    // **La riga che aggancia i numeri alla realta'.** Senza questa, il
    // registro potrebbe quadrare su cifre inventate.
    final elencate = righe
        .where((r) => r.startsWith('| `') && r.endsWith('|'))
        .map((r) => r.split('|')[1].trim().replaceAll('`', ''))
        .toList();
    cardinaleMinimo(elencate.length, 200,
        cosa: 'righe di guardia dentro docs/guardie.md',
        perche: 'Se la tavola si svuota, le tre cifre in cima resterebbero '
            'coerenti fra loro e questa prova sarebbe verde su un registro '
            'vuoto.');
    expect(elencate.length, totale,
        reason: 'il registro DICE $totale guardie e ne ELENCA '
            '${elencate.length}. Le cifre in cima si riscrivono a mano, le '
            'righe no: quando le due non coincidono, a mentire e\' quasi '
            'sempre la cifra.');
  });

  test('nessuna riga del registro mente sul cardinale della sua guardia', () {
    final righe = registro.readAsLinesSync();
    final bugie = <String>[];
    var esaminate = 0;

    for (final r in righe) {
      if (!r.startsWith('| `') || !r.endsWith('|')) continue;
      final celle = r.split('|').map((c) => c.trim()).toList();
      final nome = celle[1].replaceAll('`', '');
      final dichiarato = celle[4];
      final file = File('test/$nome');
      if (!file.existsSync()) {
        bugie.add('$nome: il registro la elenca, il file non c\'e\' piu\'');
        continue;
      }
      esaminate++;
      final testo = file.readAsStringSync();
      final passa = testo.contains('sorgentiDiLib(') ||
          testo.contains('sorgentiDiCartelle(') ||
          testo.contains('righeDiLib(');
      final scorre = passa || testo.contains("Directory('lib')");

      if (passa && !dichiarato.contains('porta comune')) {
        bugie.add('$nome: passa dalla porta comune, il registro dice '
            '"$dichiarato"');
      }
      if (!passa && dichiarato.contains('porta comune')) {
        bugie.add('$nome: il registro la dice sulla porta comune, ma non ci '
            'passa');
      }
      if (!scorre && dichiarato.contains('porta comune')) {
        bugie.add('$nome: dichiarata sulla porta comune senza scorrere niente');
      }
    }

    cardinaleMinimo(esaminate, 200,
        cosa: 'guardie del registro riaperte sul disco',
        perche: 'Questa prova vive di file che apre: se il registro non ne '
            'nomina piu\' nessuno, non trova bugie perche\' non ha letto '
            'niente.');
    expect(bugie, isEmpty,
        reason: 'IL REGISTRO DICE IL FALSO SU QUESTE GUARDIE:\n'
            '${bugie.join("\n")}\n'
            'Il registro si rigenera contando, non si corregge a mano: una '
            'cifra aggiustata a mano e\' esattamente come e\' nato il '
            'disallineamento che l\'ordine CM ha dovuto chiudere.');
  });
}

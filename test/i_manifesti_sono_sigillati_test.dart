import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **I MANIFESTI SONO SIGILLATI, E IL SIGILLO DICE IL VERO.**
/// Ordine CQ voci 4.01 e 4.04, 4 settembre 2026.
///
/// **Il fatto, dal Collaudatore degli Ordini.** Il suo passo zero prende solo i
/// manifesti terminali e sigillati coi marcatori a macchina. CM, CN, CO e CP
/// non li avevano, quindi il Collaudatore li saltava e andava a ritroso:
/// **stava collaudando ordini di settimane fa mentre i quattro piu' recenti non
/// passavano da nessun controllo indipendente.** Le due regressioni viste dal
/// fondatore la sera del 3 settembre nascono nell'ordine CO e sarebbero state
/// intercettate.
///
/// **REGOLA F, nuova e valida da ora in poi.** Un ordine non e' finito finche'
/// il suo manifesto non e' sigillato coi marcatori terminali. Vale come la
/// REGOLA D: senza manifesto sigillato la consegna non si dichiara conclusa,
/// qualunque sia il numero di voci chiuse.
///
/// **Perche' una guardia sola e non cinque copie.** Le cinque sorelle
/// `ordine_XX_guard_test.dart` sorvegliano ognuna il CONTENUTO del suo ordine,
/// che e' diverso per ognuna. Qui si sorveglia la FORMA del sigillo, che e' la
/// stessa per tutte: scritta cinque volte diventerebbe cinque forme diverse
/// della stessa cosa, ed e' la famiglia di difetti piu' numerosa di questo
/// progetto.
void main() {
  /// I manifesti sigillati, col numero di voci che ciascuno dichiara.
  ///
  /// **Il numero sta qui e non si legge dal file**, altrimenti la guardia
  /// leggerebbe il conto dal documento che deve controllare: se qualcuno
  /// cancellasse meta' delle righe e aggiustasse il marcatore, i due
  /// coinciderebbero e nessuno se ne accorgerebbe.
  const sigillati = <String, int>{
    'CG': 16,
    'CM': 11,
    'CN': 16,
    'CO': 20,
    'CP': 10,
    'CQ': 32,
  };

  const stati = <String, String>{
    'FERMATA SU PREMESSA FALSA': 'VOCI_FERMATE_SU_PREMESSA_FALSA',
    'FERMATA IN ATTESA DI DECISIONE': 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE',
    'FERMATA SU DECISIONE DEL FONDATORE':
        'VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE',
    'CHIUSA': 'VOCI_CHIUSE',
    'APERTA': 'VOCI_APERTE',
  };

  int marcatore(String testo, String nome, String ordine) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto di $ordine non porta il marcatore $nome: senza '
            'marcatori il Collaudatore non lo legge, e lo salta');
    return int.parse(trovato!.group(1)!);
  }

  test('ogni manifesto porta i sei marcatori, e dicono il vero', () {
    var guardati = 0;
    final storti = <String>[];
    final riepilogo = <String, String>{};
    for (final voce in sigillati.entries) {
      final ordine = voce.key;
      final file = File('docs/ordini/ORDINE_${ordine}_MANIFESTO.md');
      if (!file.existsSync()) {
        storti.add('$ordine: il manifesto non esiste');
        continue;
      }
      guardati++;
      final testo = file.readAsStringSync();
      final righe = testo
          .split(String.fromCharCode(10))
          .where((r) => RegExp('^- \\*\\*$ordine\\.\\d\\d\\*\\*').hasMatch(r))
          .toList();
      if (righe.length != voce.value) {
        storti.add('$ordine: righe di voce ${righe.length} invece di '
            '${voce.value}');
        continue;
      }
      final conti = <String, int>{for (final m in stati.values) m: 0};
      final senzaStato = <String>[];
      for (final r in righe) {
        final trovato = stati.keys.firstWhere(
            (stato) => r.contains('**$stato.**') || r.contains('**$stato**'),
            orElse: () => '');
        if (trovato.isEmpty) {
          senzaStato.add(r.substring(0, r.length < 34 ? r.length : 34));
          continue;
        }
        conti[stati[trovato]!] = conti[stati[trovato]]! + 1;
      }
      if (senzaStato.isNotEmpty) {
        storti.add('$ordine: righe senza uno stato ammesso $senzaStato');
        continue;
      }
      if (marcatore(testo, 'VOCI_TOTALI', ordine) != righe.length) {
        storti.add('$ordine: VOCI_TOTALI non e la somma delle righe vere');
      }
      var somma = 0;
      for (final stato in conti.entries) {
        if (marcatore(testo, stato.key, ordine) != stato.value) {
          storti.add('$ordine: il marcatore ${stato.key} dice '
              '${marcatore(testo, stato.key, ordine)} e le righe vere sono '
              '${stato.value}');
        }
        somma += stato.value;
      }
      if (somma != voce.value) {
        storti.add('$ordine: i cinque stati sommano $somma invece di '
            '${voce.value}');
      }
      riepilogo[ordine] = conti.entries
          .where((e) => e.value > 0)
          .map((e) => '${e.key.replaceFirst("VOCI_", "")} ${e.value}')
          .join(', ');
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 4.01: manifesti sigillati guardati $guardati'
        '${riepilogo.entries.map((e) => "${String.fromCharCode(10)}  "
            "${e.key}: ${e.value}").join()}');
    cardinaleMinimo(guardati, sigillati.length,
        cosa: 'manifesti sigillati trovati sul disco',
        perche: 'Se un manifesto sparisse, questa prova non lo guarderebbe e '
            'resterebbe verde: e il modo in cui un ordine smette di essere '
            'collaudabile senza che nessuno lo dica.');
    expect(storti, isEmpty,
        reason: 'questi sigilli non dicono il vero:'
            '${String.fromCharCode(10)}${storti.join(String.fromCharCode(10))}');
  });

  test('REGOLA F: nessun ordine sigillato lascia una voce aperta', () {
    final conVociAperte = <String>[];
    var guardati = 0;
    for (final ordine in sigillati.keys) {
      final file = File('docs/ordini/ORDINE_${ordine}_MANIFESTO.md');
      if (!file.existsSync()) continue;
      guardati++;
      final aperte = marcatore(file.readAsStringSync(), 'VOCI_APERTE', ordine);
      if (aperte > 0) conVociAperte.add('$ordine con $aperte');
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 4.04: ordini con voci ancora aperte '
        '${conVociAperte.isEmpty ? "nessuno" : conVociAperte.join(", ")}');
    cardinaleMinimo(guardati, sigillati.length,
        cosa: 'manifesti interrogati sulle voci aperte',
        perche: 'Con un insieme vuoto la regola F sarebbe soddisfatta per '
            'assenza.');
    expect(conVociAperte, isEmpty,
        reason: 'questi ordini hanno ancora voci aperte, e per la REGOLA F '
            'non sono finiti: ${conVociAperte.join(", ")}');
  });
}

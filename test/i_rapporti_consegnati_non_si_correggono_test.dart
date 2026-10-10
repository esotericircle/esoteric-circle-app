// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **I RAPPORTI CONSEGNATI NON SI CORREGGONO, ordine FB voce 03.**
///
/// La regola del fondatore del 4 ottobre 2026: un rapporto consegnato riceve
/// solo righe in coda, mai correzioni nel corpo. L'ordine FA aveva aggiunto
/// una riga nell'elenco in cima al rapporto EZ gia' consegnato, e nessuna
/// prova se n'era accorta: anzi, `ogni_voce_chiusa_porta_la_sua_prova` lo
/// pretendeva.
///
/// **Come si misura.** Il registro `docs/ordini/RAPPORTI_CONSEGNATI.txt`
/// porta, per ogni rapporto, l'impronta SHA-256 del suo CORPO: il testo
/// fino alla prima riga che comincia con `**Aggiunta del `, a capo ridotti,
/// senza spazi in fondo. La prova la ricalcola: se il corpo e' cambiato
/// cade; le righe in coda non la toccano. E cade se un rapporto della
/// cartella non e' nel registro: alla consegna si registra con
/// `python tool/i_rapporti_consegnati.py RAPPORTO_ORDINE_<sigla>.md`.
void main() {
  String corpo(String testo) {
    final tenute = <String>[];
    for (final r in testo.replaceAll('\r\n', '\n').split('\n')) {
      if (r.startsWith('**Aggiunta del ')) break;
      tenute.add(r);
    }
    return tenute.join('\n').trimRight();
  }

  test('FB.03: il corpo di ogni rapporto consegnato e\' quello consegnato', () {
    final registro = <String, String>{};
    for (final r
        in File('docs/ordini/RAPPORTI_CONSEGNATI.txt').readAsLinesSync()) {
      final riga = r.trim();
      if (riga.isEmpty || riga.startsWith('#')) continue;
      final parti = riga.split(RegExp(r'\s+'));
      registro[parti[0]] = parti[1];
    }
    final rapporti = Directory('docs/ordini')
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .where((n) => n.startsWith('RAPPORTO_ORDINE_') && n.endsWith('.md'))
        .toList()
      ..sort();
    cardinaleMinimo(rapporti.length, 50,
        cosa: 'rapporti nella cartella degli ordini',
        perche: 'Al 4 ottobre 2026 sono cinquanta, dal P al FB: meno vuol dire '
            'che la prova guarda la cartella sbagliata.');
    final senzaRegistro = rapporti.where((n) => !registro.containsKey(n));
    final cambiati = <String>[];
    var conAggiunte = 0;
    for (final n in rapporti.where(registro.containsKey)) {
      final testo = File('docs/ordini/$n').readAsStringSync();
      if (testo.contains('\n**Aggiunta del ')) conAggiunte++;
      final sha = sha256.convert(utf8.encode(corpo(testo))).toString();
      if (sha != registro[n]) cambiati.add(n);
    }
    print('FB.03 I RAPPORTI CONSEGNATI: ${rapporti.length} nella cartella, '
        '${registro.length} nel registro, col corpo cambiato ${cambiati.length} '
        '$cambiati, senza registro ${senzaRegistro.length} '
        '${senzaRegistro.toList()}, con righe in coda $conAggiunte');
    expect(cambiati, isEmpty,
        reason: 'il corpo di un rapporto consegnato e\' cambiato: si scrive '
            'in coda, con una riga "**Aggiunta del ...", mai nel corpo');
    expect(senzaRegistro, isEmpty,
        reason: 'un rapporto non e\' registrato: alla consegna si registra '
            'con tool/i_rapporti_consegnati.py');
  });
}

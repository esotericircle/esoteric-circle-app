// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **UN'APERTURA DELLA TENDINA NON SUPERA DIECI LETTURE, ordine FA voce 05.**
///
/// La soglia dell'Architetto del 4 ottobre 2026: non piu' di dieci letture
/// per apertura. La ricostruzione dell'istantanea non conta (una sola ogni
/// trenta secondi per tutto il Cerchio, condivisa), ed e' la sola funzione
/// esclusa dal conto.
///
/// **Come si conta, sul codice vero e non su un numero stampato.** La prova
/// legge `laTendinaDelCerchio` in `functions/src/il_cerchio_sociale.ts`,
/// segue ogni funzione del file che chiama (e quelle che chiamano loro), e:
/// - conta ogni lettura (`.get(`, `getAll(`, `.count()`) come una;
/// - la domanda degli amici presenti vale `AMICI_NELLA_TENDINA` letture, e
///   deve portare `.limit(AMICI_NELLA_TENDINA)`;
/// - CADE se una lettura sta dentro un giro (`for`, `.map(`, `.forEach(`,
///   `Promise.all(`): sarebbe una lettura per amico o per profilo, e il conto
///   crescerebbe con le persone.
void main() {
  final sorgente =
      File('functions/src/il_cerchio_sociale.ts').readAsStringSync();
  final sociale = File('functions/src/sociale.ts').readAsStringSync();

  int costante(String nome) => int.parse(
      RegExp('export const $nome = (\\d+);').firstMatch(sociale)!.group(1)!);

  /// Il corpo di una funzione del file, dalla sua intestazione alla graffa
  /// che la chiude.
  String? corpoDi(String nome) {
    final intestazione = RegExp(
            '(?:async function $nome\\(|function $nome\\(|export const $nome = onCall\\()')
        .firstMatch(sorgente);
    if (intestazione == null) return null;
    var i = sorgente.indexOf('{', intestazione.end);
    // Salta le graffe dei tipi nella firma: il corpo comincia dopo ") {"
    // oppure dopo "=> {".
    final firma = RegExp(r'\)\s*(?::[^{]*)?\{|=>\s*\{');
    final m = firma.firstMatch(sorgente.substring(intestazione.end));
    if (m != null) i = intestazione.end + m.end - 1;
    var livello = 0;
    for (var j = i; j < sorgente.length; j++) {
      if (sorgente[j] == '{') livello++;
      if (sorgente[j] == '}') {
        livello--;
        if (livello == 0) return sorgente.substring(i, j + 1);
      }
    }
    return null;
  }

  test('FA.05: un\'apertura della tendina legge al massimo dieci documenti',
      () {
    final soglia = costante('SOGLIA_DELLE_LETTURE_PER_APERTURA');
    final amiciNellaTendina = costante('AMICI_NELLA_TENDINA');
    expect(soglia, 10);
    final funzioniDelFile = {
      for (final m
          in RegExp(r'(?:async )?function (\w+)\(').allMatches(sorgente))
        m.group(1)!,
    };
    const condivise = {'istantanea'};
    final lette = <String, int>{};
    final nelGiro = <String>[];
    final daGuardare = ['laTendinaDelCerchio'];
    final viste = <String>{};
    while (daGuardare.isNotEmpty) {
      final nome = daGuardare.removeLast();
      if (!viste.add(nome)) continue;
      final corpo = corpoDi(nome);
      expect(corpo, isNotNull, reason: 'non trovo la funzione $nome');
      final letture =
          RegExp(r'\.get\(|getAll\(|\.count\(\)').allMatches(corpo!).length;
      if (letture > 0) {
        lette[nome] = corpo.contains('.limit(AMICI_NELLA_TENDINA)')
            ? amiciNellaTendina
            : letture;
      }
      // Una lettura dentro un giro cresce con le persone.
      for (final giro
          in RegExp(r'for \(|\.map\(|\.forEach\(|Promise\.all\(\[?\s*\w+\.map')
              .allMatches(corpo)) {
        final dopo =
            corpo.substring(giro.end, (giro.end + 220).clamp(0, corpo.length));
        if (RegExp(r'\.get\(|getAll\(')
            .hasMatch(dopo.split('\n').take(4).join('\n'))) {
          nelGiro.add(
              '$nome: ${corpo.substring(giro.start, (giro.start + 60).clamp(0, corpo.length)).trim()}');
        }
      }
      for (final chiamata in RegExp(r'(\w+)\(').allMatches(corpo)) {
        final f = chiamata.group(1)!;
        if (f != nome &&
            funzioniDelFile.contains(f) &&
            !condivise.contains(f)) {
          daGuardare.add(f);
        }
      }
    }
    cardinaleMinimo(viste.length, 5,
        cosa: 'funzioni seguite dalla tendina',
        perche: 'La tendina chiama il tetto, l\'identita\', i blocchi e gli '
            'amici presenti: se la prova non le trova, non sta contando.');
    final totale = lette.values.fold<int>(0, (a, b) => a + b);
    print('FA.05 LE LETTURE DI UN\'APERTURA: $lette, in tutto $totale, soglia '
        '$soglia; letture dentro un giro ${nelGiro.length} $nelGiro; '
        'funzioni seguite ${viste.length}');
    expect(nelGiro, isEmpty,
        reason: 'una lettura per amico o per profilo: il conto crescerebbe '
            'con le persone: $nelGiro');
    expect(totale, lessThanOrEqualTo(soglia),
        reason: 'un\'apertura della tendina legge $totale documenti');
    expect(lette.values.contains(amiciNellaTendina), isTrue,
        reason: 'la domanda degli amici presenti non e\' piu\' chiusa a '
            '$amiciNellaTendina');
  });
}

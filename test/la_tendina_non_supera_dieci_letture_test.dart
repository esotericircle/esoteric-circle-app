// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **UN'APERTURA DELLA TENDINA NON SUPERA DIECI LETTURE, ordine FA voce 05,
/// E NON HA TETTI SUGLI AMICI, ordine FB voce 01.**
///
/// La soglia dell'Architetto del 4 ottobre 2026: non piu' di dieci letture
/// per apertura. Con l'ordine FA gli amici presenti si leggevano con una
/// domanda chiusa a sei (`AMICI_NELLA_TENDINA`); con l'ordine FB il tetto e'
/// tolto, e gli amici presenti si incrociano IN MEMORIA fra l'istantanea e i
/// legami: zero letture per amico, sei amici presenti come centocinquanta.
///
/// **Come si conta, sul codice vero e non su un numero stampato.** La prova
/// legge `laTendinaDelCerchio` in `functions/src/il_cerchio_sociale.ts`,
/// segue ogni funzione del file che chiama (e quelle che chiamano loro), e:
/// - conta ogni lettura (`.get(`, `getAll(`, `.count()`) come una;
/// - l'istantanea si conta a parte: la tendina deve chiederla con
///   `ricostruisci: false`, e nel corpo di `istantanea` il ritorno per chi non
///   ricostruisce deve venire prima di ogni lettura della ricostruzione (il
///   turno e i frammenti), che fa solo il passo della presenza; le letture
///   prima di quel ritorno sono quelle che la tendina paga;
/// - CADE se una lettura sta dentro un giro (`for`, `.map(`, `.forEach(`,
///   `Promise.all(`): sarebbe una lettura per amico o per profilo, e il conto
///   crescerebbe con le persone;
/// - CADE se il tetto sugli amici torna: una domanda sulle presenze
///   (`collectionGroup`, `"presenza"`, i frammenti), un `.limit(` o un
///   `.slice(` nelle funzioni della tendina, o `AMICI_NELLA_TENDINA` nel
///   server o nel telefono.
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

  // Dall'ordine FD voce 05 la memoria dell'istanza e' una mappa per spazio
  // della presenza: `istantaneaInMemoria.get(spazio)` legge la memoria, non
  // Firestore, e non si conta.
  final lettura =
      RegExp(r'(?<!istantaneaInMemoria)\.get\(|getAll\(|\.count\(\)');

  test(
      'FA.05 e FB.01: un\'apertura della tendina legge al massimo dieci '
      'documenti, e nessun tetto sugli amici', () {
    final soglia = costante('SOGLIA_DELLE_LETTURE_PER_APERTURA');
    expect(soglia, 10);
    final funzioniDelFile = {
      for (final m
          in RegExp(r'(?:async )?function (\w+)\(').allMatches(sorgente))
        m.group(1)!,
    };
    // L'istantanea si conta a parte, qui sotto: solo il suo ramo senza
    // ricostruzione e' della tendina.
    const aParte = {'istantanea'};
    final lette = <String, int>{};
    final nelGiro = <String>[];
    final tetti = <String>[];
    final daGuardare = ['laTendinaDelCerchio'];
    final viste = <String>{};
    while (daGuardare.isNotEmpty) {
      final nome = daGuardare.removeLast();
      if (!viste.add(nome)) continue;
      final corpo = corpoDi(nome);
      expect(corpo, isNotNull, reason: 'non trovo la funzione $nome');
      final letture = lettura.allMatches(corpo!).length;
      if (letture > 0) lette[nome] = letture;
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
      // Il tetto sugli amici non torna, in nessuna forma.
      for (final tetto in RegExp(
              r'collectionGroup\(|"presenza"|FRAMMENTO\(|\.limit\(|\.slice\(')
          .allMatches(corpo)) {
        tetti.add('$nome: ${tetto.group(0)}');
      }
      for (final chiamata in RegExp(r'(\w+)\(').allMatches(corpo)) {
        final f = chiamata.group(1)!;
        if (f != nome && funzioniDelFile.contains(f) && !aParte.contains(f)) {
          daGuardare.add(f);
        }
      }
    }
    cardinaleMinimo(viste.length, 5,
        cosa: 'funzioni seguite dalla tendina',
        perche: 'La tendina chiama il tetto, l\'identita\', i blocchi e chi '
            'li legge: se la prova non le trova, non sta contando.');

    // L'istantanea: chiesta senza ricostruire, e il suo ramo senza
    // ricostruzione legge prima di ogni lettura della ricostruzione.
    final tendina = corpoDi('laTendinaDelCerchio')!;
    // Dall'ordine FD voce 05 la lettura dice anche lo spazio della presenza
    // di chi chiama (i collaudi hanno il loro): resta senza ricostruzione.
    expect(tendina,
        contains('istantanea({ricostruisci: false, spazio: spazioDi(uid)})'),
        reason: 'la tendina deve leggere l\'istantanea senza ricostruirla');
    final ist = corpoDi('istantanea');
    expect(ist, isNotNull, reason: 'non trovo la funzione istantanea');
    final ritorno = ist!.indexOf('if (!ricostruisci) return');
    expect(ritorno, greaterThan(0),
        reason: 'istantanea non ha il ritorno per chi non ricostruisce');
    final ricostruzione = {
      'runTransaction': ist.indexOf('runTransaction'),
      // Dall'ordine FD voce 05 la raccolta porta lo spazio della presenza.
      'la lettura dei frammenti':
          ist.indexOf('collection(`\${spazio}cerchio_presenze`)'),
    };
    ricostruzione.forEach((cosa, dove) {
      expect(dove, greaterThan(ritorno),
          reason: '$cosa viene prima del ritorno per chi non ricostruisce: '
              'la tendina pagherebbe la ricostruzione');
    });
    lette['istantanea'] = lettura.allMatches(ist.substring(0, ritorno)).length;

    // Il tetto dei sei non torna nemmeno come nome.
    final telefono = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .map((f) => f.readAsStringSync());
    final server = Directory('functions/src')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.ts') && !f.path.endsWith('.test.ts'))
        .map((f) => f.readAsStringSync());
    final colNome = [...telefono, ...server]
        .where((s) => s.contains('AMICI_NELLA_TENDINA'))
        .length;

    final totale = lette.values.fold<int>(0, (a, b) => a + b);
    print('FB.01 LE LETTURE DI UN\'APERTURA: $lette, in tutto $totale, soglia '
        '$soglia; letture dentro un giro ${nelGiro.length} $nelGiro; tetti '
        'sugli amici ${tetti.length} $tetti; file col nome del tetto dei sei '
        '$colNome; funzioni seguite ${viste.length} $viste');
    expect(nelGiro, isEmpty,
        reason: 'una lettura per amico o per profilo: il conto crescerebbe '
            'con le persone: $nelGiro');
    expect(lette['istantanea'], 1,
        reason: 'l\'istantanea senza ricostruire legge '
            '${lette['istantanea']} documenti');
    expect(totale, lessThanOrEqualTo(soglia),
        reason: 'un\'apertura della tendina legge $totale documenti');
    expect(tetti, isEmpty,
        reason: 'il tetto sugli amici della tendina e\' tornato: $tetti');
    expect(colNome, 0,
        reason: 'AMICI_NELLA_TENDINA e\' tornato in $colNome file');
  });
}

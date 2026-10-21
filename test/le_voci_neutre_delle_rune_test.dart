// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/rituals/il_corpus_del_presagio.g.dart';
import 'package:esoteric_circle/core/rituals/le_voci_neutre.g.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LE VOCI NEUTRE DELLE RUNE.** Ordine GA voce GA.06, riapertura, 21
/// ottobre 2026.
///
/// Per le domande senza un tipo nel corpus delle risposte dirette (la giornata,
/// le domande aperte del Cerchio) e per la scheda quando nessuna coppia "come"
/// sta nella misura, il presagio sceglie fra le coppie PIETRA/CONSIGLIO e
/// RISPOSTA/GESTO che non presuppongono una situazione
/// (`tool/genera_le_voci_neutre_delle_rune.py`, `le_voci_neutre.g.dart`).
/// Il lettore cieco indipendente aveva contato 21 schede su 34 col "Cosa
/// fare" slegato dalla domanda o dalla propria risposta, e la pietra, in
/// quel campo, e' scritta per ogni domanda.
///
/// La guardia pretende, sul generato:
/// 1. LA FORMA: i quaranta gruppi di ogni campo, le coppie dentro il corpus
///    (il numero della voce esiste), nessuna voce due volte, almeno cinque
///    coppie per gruppo (sotto, i sessanta giorni non tengono);
/// 2. NESSUNA VOCE ESCLUSA A MANO C'E' DENTRO (`voci_non_neutre.txt`): una
///    lettura severa ha escluso quelle che presuppongono una persona, un
///    fatto o un futuro, e le criptiche ("si alza una bandiera sul legno");
/// 3. LE COPPIE SI SEGUONO: RISPOSTA e GESTO hanno lo stesso numero (le ha
///    scritte lo stesso scrittore insieme), PIETRA e CONSIGLIO condividono
///    parole che non siano di tutti i giorni.
void main() {
  test('la forma delle coppie neutre e le voci escluse a mano', () {
    final escluse = <String>{};
    for (final riga
        in File('docs/corpus/rune/voci_non_neutre.txt').readAsLinesSync()) {
      final t = riga.trim();
      if (t.isEmpty || t.startsWith('#')) continue;
      final parti = t.split('|').map((x) => x.trim()).toList();
      escluse.add('${parti[0]}/${parti[1]}/${parti[2]}');
    }
    cardinaleMinimo(escluse.length, 60, cosa: 'voci escluse a mano');

    final colpe = <String>[];
    var coppie = 0;
    for (final MapEntry(key: campo, value: gruppi) in leVociNeutre.entries) {
      final secondo = campo == 'pietra' ? 'consiglio' : 'gesto';
      final voci = corpusDelPresagio.voci[campo]!;
      final seguito = corpusDelPresagio.voci[secondo]!;
      if (gruppi.length != 40) {
        colpe.add('$campo: ${gruppi.length} gruppi invece di 40');
      }
      for (final MapEntry(key: g, value: elenco) in gruppi.entries) {
        if (elenco.length < 5) {
          colpe.add('$campo/$g: ${elenco.length} coppie, ne servono 5');
        }
        final prime = <int>{};
        final seconde = <int>{};
        for (final (i, j) in elenco) {
          coppie++;
          if (i < 1 || i > voci[g]!.length || j < 1 || j > seguito[g]!.length) {
            colpe.add('$campo/$g: coppia ($i, $j) fuori dal corpus');
          }
          if (!prime.add(i) || !seconde.add(j)) {
            colpe.add('$campo/$g: la voce $i o la $j e\' presa due volte');
          }
          if (escluse.contains('$campo/$g/$i')) {
            colpe.add('$campo/$g/$i e\' fra le voci escluse a mano');
          }
          if (campo == 'risposta' && i != j) {
            colpe.add('$campo/$g: RISPOSTA $i e GESTO $j non hanno lo '
                'stesso numero');
          }
        }
      }
    }
    // Le larghe: le coppie in piu' che la scelta usa solo quando la persona
    // ha letto tutte le strette. Dentro il corpus, mai una voce esclusa a
    // mano, mai una voce gia' fra le strette.
    var larghe = 0;
    for (final MapEntry(key: campo, value: gruppi)
        in leVociNeutreLarghe.entries) {
      final secondo = campo == 'pietra' ? 'consiglio' : 'gesto';
      final voci = corpusDelPresagio.voci[campo]!;
      final seguito = corpusDelPresagio.voci[secondo]!;
      for (final MapEntry(key: g, value: elenco) in gruppi.entries) {
        final primeStrette = {for (final (i, _) in leVociNeutre[campo]![g]!) i};
        final secondeStrette = {
          for (final (_, j) in leVociNeutre[campo]![g]!) j
        };
        for (final (i, j) in elenco) {
          larghe++;
          if (i < 1 ||
              i > voci[g]!.length ||
              j < 1 ||
              j > seguito[g]!.length ||
              voci[g]![i - 1].trim().isEmpty ||
              seguito[g]![j - 1].trim().isEmpty) {
            colpe.add('larga $campo/$g: coppia ($i, $j) fuori dal corpus o '
                'senza testo');
          }
          if (primeStrette.contains(i) || secondeStrette.contains(j)) {
            colpe.add('larga $campo/$g: la coppia ($i, $j) e\' gia\' fra le '
                'strette');
          }
          if (escluse.contains('$campo/$g/$i')) {
            colpe.add('larga $campo/$g/$i e\' fra le voci escluse a mano');
          }
        }
      }
    }
    cardinaleMinimo(larghe, 800,
        cosa: 'coppie larghe',
        perche: '957 di PIETRA e 253 di RISPOSTA al momento della '
            'riapertura');
    // Il generato e' quello del file di esclusione: se il file cambia e il
    // generato no, la prova lo vede perche' una voce esclusa e' ancora dentro.
    print('ORDINE GA VOCE GA.06, RUNE: coppie neutre $coppie, difetti '
        '${colpe.length}');
    cardinaleMinimo(coppie, 600,
        cosa: 'coppie neutre',
        perche: '325 di PIETRA e 305 di RISPOSTA al momento della riapertura');
    expect(colpe, isEmpty, reason: colpe.take(8).join('\n'));
  });
}

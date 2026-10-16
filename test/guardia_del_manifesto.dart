// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'lettore_dei_manifesti.dart';

/// **LA GUARDIA PROPRIA DI UN MANIFESTO CHIUSO.** Ordine DS voce 01, 17
/// settembre 2026.
///
/// Diciotto ordini, da CW a DQ, non avevano una guardia propria: il debito
/// era arretrato, e nessuna prova si accorgeva che un manifesto nasceva senza.
/// Le guardie scritte dagli ordini stessi sorvegliano anche il contenuto del
/// loro lavoro; queste, scritte dopo, sorvegliano cio' che si puo' sorvegliare
/// senza riaprire ordini chiusi: **che il manifesto resti quello che e'
/// stato chiuso**. Le sue voci, lette nei suoi formati, e i suoi marcatori,
/// al numero.
///
/// **Un manifesto che dichiara il falso resta com'e'**, e la sua guardia lo
/// fotografa com'e': la decisione e' del fondatore, e quando arriva questa
/// guardia cade e si aggiorna con la riga che dice perche'.
void sorvegliaIlManifesto({
  required String file,
  required int voci,
  required Map<String, int> marcatori,
  String? nota,
}) {
  final percorso = 'docs/ordini/$file';

  test('$file esiste e non si e riscritto: $voci voci, marcatori al numero',
      () {
    final f = File(percorso);
    expect(f.existsSync(), isTrue, reason: 'il manifesto $file non esiste piu');
    final letto = leggiManifesto(file, f.readAsStringSync());
    print('ORDINE DS VOCE 01, GUARDIA DI ${letto.sigla}: voci '
        '${letto.voci.length}, marcatori ${letto.marcatori}'
        '${nota == null ? "" : ". $nota"}');
    expect(letto.voci.length, voci,
        reason: 'il manifesto chiuso $file ha cambiato le sue voci');
    expect(letto.marcatori, marcatori,
        reason: 'il manifesto chiuso $file ha cambiato i suoi marcatori');
  });
}

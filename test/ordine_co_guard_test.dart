import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA GUARDIA DELL'ORDINE CO.** 3 settembre 2026.
///
/// Non racconta l'ordine: lo verifica. Ogni cosa che il manifesto dichiara
/// fatta viene riaperta e ricontata sul disco.
void main() {
  final manifesto = File('docs/ordini/ORDINE_CO_MANIFESTO.md');

  String testo() {
    expect(manifesto.existsSync(), isTrue,
        reason: 'il manifesto dell ordine CO non esiste');
    return manifesto.readAsStringSync();
  }

  test('il manifesto nomina tutte e venti le voci', () {
    final t = testo();
    final mancanti = <String>[];
    for (var i = 1; i <= 20; i++) {
      final voce = 'CO.${i.toString().padLeft(2, '0')}';
      if (!t.contains(voce)) mancanti.add(voce);
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto non nomina queste voci: $mancanti');
  });

  test('le sette premesse hanno il loro esito, e non tutte sono vere', () {
    final t = testo();
    var conEsito = 0;
    var false_ = 0;
    for (final s in const ['S0', 'S1', 'S2', 'S3', 'S5', 'S6', 'S7']) {
      final riga = t
          .split('\n')
          .firstWhere((r) => r.startsWith('| $s |'), orElse: () => '');
      expect(riga, isNotEmpty, reason: 'la premessa $s non ha la sua riga');
      final vera = riga.contains('VERA');
      final falsa = riga.contains('FALSA');
      expect(vera || falsa, isTrue,
          reason: 'la premessa $s non dice se e vera o falsa: '
              'REGOLA ZERO chiede un esito, non un racconto');
      if (falsa) false_++;
      conEsito++;
    }
    cardinaleMinimo(conEsito, 7,
        cosa: 'premesse dell ordine CO con un esito dichiarato',
        perche: 'Se una premessa sparisse dalla tabella, questa prova non '
            'troverebbe premesse senza esito perche non le ha guardate.');
    // **TRE SU SETTE ERANO FALSE O IMPRECISE, e il numero e' il punto.** La
    // Regola Zero non e' una formalita': in quest'ordine ha cambiato il lavoro
    // su tre voci su venti.
    expect(false_, greaterThanOrEqualTo(3),
        reason: 'il manifesto dichiara meno di tre premesse false: o la '
            'verifica non e stata fatta, o il conto e stato addolcito');
  });

  test('ogni difetto ha un padre, o dice PROVENIENZA IGNOTA', () {
    final t = testo();
    final righe = t
        .split('\n')
        .where((r) => r.startsWith('| ') && r.endsWith(' |'))
        .toList();
    // La tavola delle attribuzioni: righe con due colonne, difetto e padre.
    final attribuzioni = righe
        .where((r) => r.split('|').length == 4)
        .where((r) =>
            RegExp(r'\*\*[A-Z]{1,2}\.?\d*').hasMatch(r) ||
            r.contains('PROVENIENZA IGNOTA'))
        .toList();
    cardinaleMinimo(attribuzioni.length, 15,
        cosa: 'difetti attribuiti nel manifesto dell ordine CO',
        perche: 'Se la tavola delle attribuzioni si svuotasse, questa prova '
            'non troverebbe difetti senza padre perche non ne ha letto '
            'nessuno.');
    final senzaPadre = attribuzioni
        .where((r) =>
            !RegExp(r'\*\*[A-Z]{1,2}\.?\d*').hasMatch(r.split('|')[2]) &&
            !r.contains('PROVENIENZA IGNOTA'))
        .toList();
    expect(senzaPadre, isEmpty,
        reason: 'questi difetti non dicono da quale voce discendono, e non '
            'dicono nemmeno PROVENIENZA IGNOTA:\n${senzaPadre.join("\n")}');
  });

  test('le dieci guardie nuove esistono davvero sul disco', () {
    const nate = [
      'test/l_intro_zittisce_la_musica_test.dart',
      'test/la_carta_girata_suona_test.dart',
      'test/una_voce_sola_sulla_festa_test.dart',
      'test/gli_accenti_non_sono_inchiostro_test.dart',
      'test/il_dono_risponde_prima_di_chiedere_test.dart',
      'test/le_stelle_della_festa_sono_stelle_test.dart',
      'test/la_stesa_comincia_quando_lo_dici_test.dart',
      'test/la_testa_del_maestro_non_si_taglia_test.dart',
      'test/la_chat_non_si_apre_sul_vuoto_test.dart',
      'test/il_cuore_sta_sempre_nello_stesso_angolo_test.dart',
    ];
    final mancanti = nate.where((f) => !File(f).existsSync()).toList();
    expect(mancanti, isEmpty,
        reason: 'il manifesto dichiara dieci guardie nuove e queste non ci '
            'sono: $mancanti');
    cardinaleMinimo(nate.length, 10,
        cosa: 'guardie nuove dichiarate dall ordine CO',
        perche: 'Se questo elenco si accorciasse, la prova resterebbe verde '
            'su meno guardie di quante l ordine ne dichiara.');
  });

  test('lo strumento di misura dei suoni non manca piu', () {
    // Voce CO.04: il registro dichiarava da CN un metodo che nessuno
    // strumento in repo eseguiva.
    final tool = File('tool/misura_i_suoni.py');
    expect(tool.existsSync(), isTrue,
        reason: 'tool/misura_i_suoni.py non c e: il registro sonoro torna a '
            'dichiarare un metodo che nessuno puo ripetere');
    final s = tool.readAsStringSync();
    expect(s, contains('lavfi.r128.M'),
        reason: 'lo strumento non legge piu la sonorita momentanea, che e la '
            'grandezza dichiarata dal registro');
    final registro = File('docs/sonorita.json').readAsStringSync();
    expect(registro, contains('tool/misura_i_suoni.py'),
        reason: 'il registro non dice piu con quale comando si rigenera');
  });

  test('la riga finale dell ordine c e, e porta la sua risposta', () {
    final t = testo();
    const domanda = 'QUANTE DELLE VENTI VOCI IL FONDATORE PU';
    expect(t, contains(domanda),
        reason: 'manca la riga con cui l ordine chiede di chiudere');
    final coda = t.substring(t.indexOf(domanda));
    expect(coda.length, greaterThan(200),
        reason: 'la riga finale c e ma non ha una risposta sotto: l ordine '
            'chiede quante voci si vedono a occhio, non che la domanda venga '
            'ripetuta');
    expect(RegExp(r'\*\*[A-Za-zàèéìòù ]+ s[iì]').hasMatch(coda), isTrue,
        reason: 'la risposta non dice un numero di voci verificabili');
  });
}

// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **LA GUARDIA DELL'ORDINE EX.** 2 ottobre 2026.
///
/// Il manifesto `ORDINE_EX_MANIFESTO.md` porta le undici voci dell'ordine
/// (EX.01-EX.11), ognuna con uno stato solo (CHIUSA, APERTA IN ATTESA DI
/// VERIFICA, oppure APERTA), e i marcatori dicono le stesse cose delle voci.
/// Le prove che l'ordine chiede esistono e non sono vuote, e il costo per
/// utente nel documento e' quello che scrive `tool/i_conti_del_costo_ex.py`.
void main() {
  final manifesto = File('docs/ordini/ORDINE_EX_MANIFESTO.md');
  const voci = [
    'EX.01', 'EX.02', 'EX.03', 'EX.04', 'EX.05', 'EX.06', //
    'EX.07', 'EX.08', 'EX.09', 'EX.10', 'EX.11', //
  ];
  const prove = [
    'docs/collaudo/EX/minuti_del_live.txt',
    'docs/collaudo/EX/la_matrice_nuova.txt',
    'docs/collaudo/EX/realme/LEGGIMI.txt',
    'docs/corpus/rune/SPECIFICA.md',
    'docs/collaudo/EX/rune_senza_ripetizioni.txt',
    'docs/collaudo/EX/vai_piu_a_fondo.txt',
    'docs/collaudo/EX/la_cache.txt',
    'docs/collaudo/EX/regione_dei_ricordi.txt',
    'docs/collaudo/EX/risposte_rifatte.txt',
    'docs/collaudo/EX/il_cielo_nella_richiesta.txt',
    'docs/collaudo/EX/memoria_compatta.txt',
    'docs/collaudo/EX/scena_del_viaggio.txt',
    'docs/costi/costo_per_utente_dopo_ex.md',
    'docs/collaudo/EX/il_costo_delle_prove.txt',
    'docs/collaudo/EX/regola_a_ex.txt',
    // L'EX Aggiunta 4, le quattro voci aperte.
    'docs/collaudo/EX/le_quattro_voci_sistemate.txt',
    'docs/collaudo/EX/la_cache_garantita.txt',
    'docs/collaudo/EX/la_scena_con_meno_scarti.txt',
    'docs/collaudo/EX/attribuzione_dopo_aggiunta4.txt',
  ];

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome');
    return int.parse(trovato!.group(1)!);
  }

  test('il manifesto esiste e porta tutte le undici voci', () {
    expect(manifesto.existsSync(), isTrue);
    final testo = manifesto.readAsStringSync();
    final mancanti = [
      for (final v in voci)
        if (!testo.contains('## VOCE $v,')) v,
    ];
    expect(mancanti, isEmpty, reason: 'voci non nominate: $mancanti');
  });

  test('ogni voce ha uno stato solo, e i conti tornano', () {
    final testo = manifesto.readAsStringSync();
    final chiuse = marcatore(testo, 'VOCI_CHIUSE');
    final aperte = marcatore(testo, 'VOCI_APERTE');
    final daFare = marcatore(testo, 'VOCI_DA_FARE');
    final dichiarate = marcatore(testo, 'VOCI_TOTALI');
    print('ORDINE EX: voci $dichiarate, chiuse $chiuse, aperte $aperte, da '
        'fare $daFare');
    var contateChiuse = 0, contateAperte = 0;
    final senzaStato = <String>[];
    final conPiuStati = <String>[];
    for (final v
        in testo.split(RegExp(r'^## VOCE ', multiLine: true)).skip(1)) {
      final nome = v.split('\n').first;
      final chiusa = RegExp(r'^\*\*CHIUSA\.\*\*', multiLine: true).hasMatch(v);
      final aperta =
          RegExp(r'^\*\*APERTA( IN ATTESA DI VERIFICA)?\.\*\*', multiLine: true)
              .hasMatch(v);
      final stati = [chiusa, aperta].where((x) => x).length;
      if (stati == 0) senzaStato.add(nome);
      if (stati > 1) conPiuStati.add(nome);
      if (chiusa) contateChiuse++;
      if (aperta && !chiusa) contateAperte++;
    }
    expect(senzaStato, isEmpty, reason: 'voci senza stato: $senzaStato');
    expect(conPiuStati, isEmpty, reason: 'voci con piu\' stati: $conPiuStati');
    expect(dichiarate, voci.length);
    expect(contateChiuse, chiuse);
    expect(contateAperte, aperte);
    expect(daFare, 0);
    expect(chiuse + aperte + daFare, dichiarate);
  });

  test('le prove dell\'ordine esistono e non sono vuote', () {
    final mancanti = [
      for (final p in prove)
        if (!File(p).existsSync() || File(p).lengthSync() == 0) p,
    ];
    print('ORDINE EX: prove guardate ${prove.length}, mancanti o vuote '
        '${mancanti.length}');
    expect(mancanti, isEmpty, reason: 'prove mancanti o vuote: $mancanti');
  });

  test('il costo per utente del documento e\' quello dello script dei conti',
      () {
    // L'uscita dello script, senza cache, rune dal corpus: Iniziato,
    // Adepto e Illuminato.
    final conti =
        File('docs/costi/i_conti_del_costo_ex.txt').readAsStringSync();
    final senzaCache = conti.split('CON LA CACHE').first;
    final documento =
        File('docs/costi/costo_per_utente_dopo_ex.md').readAsStringSync();
    var guardati = 0;
    for (final piano in ['Iniziato', 'Adepto', 'Illuminato']) {
      final riga = RegExp('^$piano: .*con le rune dal corpus ([0-9.]+);',
              multiLine: true)
          .firstMatch(senzaCache);
      expect(riga, isNotNull, reason: '$piano non e\' nei conti');
      final valore = riga!.group(1)!.replaceAll('.', ',');
      expect(documento, contains('**$valore \$**'),
          reason: 'il documento non dice per $piano il $valore dei conti');
      guardati++;
    }
    expect(guardati, 3);
  });
}

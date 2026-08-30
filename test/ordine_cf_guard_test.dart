import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE CF.
///
/// **Non e' una promessa, e' una prova che non passa.** Legge il manifesto e
/// resta rossa finche' le diciotto voci non hanno uno stato terminale.
///
/// **E pretende che la verifica delle premesse sia SCRITTA, non riassunta.**
/// L'ordine CF nasce da una lezione dell'ordine CE: tre premesse false su sette
/// erano state EREDITATE da un rapporto vecchio invece che rimisurate. Qui la
/// tabella deve portare una riga per ognuna delle diciotto, col suo esito.
///
/// **Non pretende che qualche premessa sia falsa.** La guardia dell'ordine CE
/// lo faceva, e li' aveva senso perche' sette lo erano; qui diciotto su
/// diciotto sono vere, e una guardia che pretendesse un errore obbligherebbe a
/// inventarne uno.
void main() {
  final manifesto = File('docs/ordini/ORDINE_CF_MANIFESTO.md');

  const quante = 18;

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome, e senza marcatori '
            'nessuno puo\' leggerlo a macchina');
    return int.parse(trovato!.group(1)!);
  }

  List<String> righeDiVoce(String testo) => testo
      .split('\n')
      .where((r) => RegExp(r'^- \*\*CF\.\d\d\*\*').hasMatch(r))
      .toList();

  /// I cinque stati ammessi, dal piu' lungo al piu' corto: si cerca lo stato
  /// dentro le stelline, non nel testo libero della riga.
  const stati = <String, String>{
    'FERMATA SU PREMESSA FALSA': 'VOCI_FERMATE_SU_PREMESSA_FALSA',
    'FERMATA IN ATTESA DI DECISIONE': 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE',
    'FERMATA SU DECISIONE DEL FONDATORE':
        'VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE',
    'CHIUSA': 'VOCI_CHIUSE',
    'APERTA': 'VOCI_APERTE',
  };

  test('il manifesto esiste e nomina tutte e diciotto le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'docs/ordini/ORDINE_CF_MANIFESTO.md non esiste');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 0; i < quante; i++) {
      final voce = 'CF.${(i + 1).toString().padLeft(2, '0')}';
      if (!testo.contains('**$voce**')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto non nomina queste voci: $mancanti');
  });

  test('ogni voce ha uno stato ammesso e i sei marcatori dicono il vero', () {
    final testo = manifesto.readAsStringSync();
    final righe = righeDiVoce(testo);
    expect(righe, hasLength(quante));
    final conti = <String, int>{for (final m in stati.values) m: 0};
    final senzaStato = <String>[];
    for (final r in righe) {
      final trovato = stati.keys.firstWhere(
          (stato) => r.contains('**$stato.**') || r.contains('**$stato**'),
          orElse: () => '');
      if (trovato.isEmpty) {
        senzaStato.add(r.substring(0, r.length < 40 ? r.length : 40));
        continue;
      }
      conti[stati[trovato]!] = conti[stati[trovato]]! + 1;
    }
    expect(senzaStato, isEmpty,
        reason: 'queste righe non portano nessuno dei cinque stati ammessi: '
            '$senzaStato');
    // ignore: avoid_print
    print('ORDINE CF: voci $quante, '
        '${conti.entries.map((e) => "${e.key} ${e.value}").join(", ")}');
    expect(marcatore(testo, 'VOCI_TOTALI'), righe.length);
    var somma = 0;
    for (final voce in conti.entries) {
      expect(marcatore(testo, voce.key), voce.value,
          reason: 'il marcatore ${voce.key} non coincide con le righe vere');
      somma += voce.value;
    }
    expect(somma, quante,
        reason: 'i sei marcatori non sommano al totale delle voci');
  });

  test('le diciotto premesse sono verificate una per una', () {
    // **LA LEZIONE DELL'ORDINE CE, scritta come guardia.** Non basta dire "le
    // ho verificate": ogni premessa deve avere la sua riga con l'esito, cosi'
    // una che nessuno ha guardato si vede subito.
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= quante; i++) {
      final p = 'P${i.toString().padLeft(2, '0')}';
      if (!RegExp('^\\| $p \\|', multiLine: true).hasMatch(testo)) {
        mancanti.add(p);
      }
    }
    final conEsito = RegExp(r'^\| P\d\d \| \*\*(vera|falsa)', multiLine: true)
        .allMatches(testo)
        .length;
    // ignore: avoid_print
    print('ORDINE CF: premesse con la loro riga ${quante - mancanti.length} '
        'su $quante, di cui con un esito dichiarato $conEsito');
    expect(mancanti, isEmpty,
        reason: 'queste premesse non hanno una riga nella tabella: $mancanti');
    expect(conEsito, quante,
        reason: 'qualche premessa ha una riga senza un esito dichiarato');
  });

  test('le sezioni obbligatorie ci sono, e non sono vuote', () {
    final testo = manifesto.readAsStringSync();
    const sezioni = <String, String>{
      'LE AFFERMAZIONI DI QUESTO ORDINE CHE HO TROVATO FALSE':
          'la REGOLA ZERO chiede di verificare ogni affermazione',
      'LE SCELTE CHE HO PRESO IO E PERCHE\'':
          'la REGOLA DUE chiede di motivare ogni scelta delegata',
      'LE TRE COSE CHE QUEST\'ORDINE PRETENDE SIANO SCRITTE':
          'il fondatore le ha chieste per nome',
    };
    final mancanti = <String>[];
    for (final s in sezioni.entries) {
      if (!testo.contains(s.key)) mancanti.add('${s.key} (${s.value})');
    }
    expect(mancanti, isEmpty, reason: 'mancano queste sezioni: $mancanti');

    // Una sezione che esiste e non dice niente vale come una che non c'e'.
    for (final s in sezioni.keys) {
      final dopo = testo.substring(testo.indexOf(s));
      final righe = dopo
          .split('\n')
          .skip(1)
          .takeWhile((r) => !r.startsWith('## '))
          .where((r) =>
              r.trim().startsWith('-') ||
              r.trim().startsWith('|') ||
              r.trim().startsWith('###'))
          .length;
      expect(righe, greaterThan(0), reason: 'la sezione "$s" e\' vuota');
    }
  });

  test('le tre cose pretese per nome sono nominate', () {
    final testo = manifesto.readAsStringSync();
    const pretese = <String, String>{
      '17 agosto 2026': 'CF.03 deve dichiarare quale decisione supera',
      'dichiarate chiuse': 'CF.09, CF.10 e CF.11 nascono da voci chiuse',
      'ordine AV': 'il debito della copertura della spirale',
    };
    final mancanti = <String>[];
    for (final p in pretese.entries) {
      if (!testo.contains(p.key)) mancanti.add('${p.key} (${p.value})');
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto non nomina queste cose: $mancanti');
  });

  test('l\'ordine CF non e\' finito finche\' una voce resta aperta', () {
    final testo = manifesto.readAsStringSync();
    final aperte = marcatore(testo, 'VOCI_APERTE');
    // ignore: avoid_print
    print('ORDINE CF: voci ancora aperte $aperte');
    expect(aperte, 0,
        reason: 'restano $aperte voci aperte: **questa prova e\' rossa per '
            'legge di consegna** finche\' tutte e diciotto non hanno uno stato '
            'terminale');
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE CG.
///
/// **Non e' una promessa, e' una prova che non passa.** Legge il manifesto e
/// resta rossa finche' le sedici voci non hanno uno stato terminale.
///
/// **E pretende che la verifica delle premesse sia SCRITTA, non riassunta**:
/// e' la lezione dell'ordine CE, dove tre premesse false su sette erano state
/// EREDITATE da un rapporto vecchio invece che rimisurate.
///
/// **Perche' CG.15 tiene questa prova rossa, ed e' giusto cosi'.** Il secondo
/// dei due gesti sulle lapidi chiede una distribuzione delle funzioni, e la
/// distribuzione la ordina il fondatore. La guardia dice che l'ordine non e'
/// finito, che e' esattamente il vero.
void main() {
  final manifesto = File('docs/ordini/ORDINE_CG_MANIFESTO.md');

  const quante = 16;

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
      .where((r) => RegExp(r'^- \*\*CG\.\d\d\*\*').hasMatch(r))
      .toList();

  const stati = <String, String>{
    'FERMATA SU PREMESSA FALSA': 'VOCI_FERMATE_SU_PREMESSA_FALSA',
    'FERMATA IN ATTESA DI DECISIONE': 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE',
    'FERMATA SU DECISIONE DEL FONDATORE':
        'VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE',
    'CHIUSA': 'VOCI_CHIUSE',
    'APERTA': 'VOCI_APERTE',
  };

  test('il manifesto esiste e nomina tutte e sedici le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'docs/ordini/ORDINE_CG_MANIFESTO.md non esiste');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 0; i < quante; i++) {
      final voce = 'CG.${(i + 1).toString().padLeft(2, '0')}';
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
    print('ORDINE CG: voci $quante, '
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
    final testo = manifesto.readAsStringSync();
    const quantePremesse = 18;
    final mancanti = <String>[];
    for (var i = 1; i <= quantePremesse; i++) {
      final p = 'P${i.toString().padLeft(2, '0')}';
      if (!RegExp('^\\| $p \\|', multiLine: true).hasMatch(testo)) {
        mancanti.add(p);
      }
    }
    final conEsito =
        RegExp(r'^\| P\d\d \| \*\*(vera|falsa)', multiLine: true)
            .allMatches(testo)
            .length;
    // ignore: avoid_print
    print('ORDINE CG: premesse con la loro riga '
        '${quantePremesse - mancanti.length} su $quantePremesse, di cui con un '
        'esito dichiarato $conEsito');
    expect(mancanti, isEmpty,
        reason: 'queste premesse non hanno una riga nella tabella: $mancanti');
    expect(conEsito, quantePremesse,
        reason: 'qualche premessa ha una riga senza un esito dichiarato');
  });

  test('le sezioni obbligatorie ci sono, e non sono vuote', () {
    final testo = manifesto.readAsStringSync();
    const sezioni = <String, String>{
      'LE AFFERMAZIONI DI QUESTO ORDINE CHE HO TROVATO FALSE':
          'la REGOLA ZERO chiede di verificare ogni affermazione',
      'LE DECISIONI CHE HO PRESO PER DELEGA, E PERCHE\'':
          'la REGOLA DUE chiede di motivare ogni scelta delegata',
      'LE DUE DECISIONI PRECEDENTI CHE QUESTO ORDINE SUPERA':
          'l\'ordine le pretende scritte, altrimenti la prossima sessione '
              'trova due decisioni che si contraddicono',
      'IL DEBITO CHE RESTA APERTO':
          'cio\' che non e\' finito si dichiara invece di sparire',
    };
    final mancanti = <String>[];
    for (final s in sezioni.entries) {
      if (!testo.contains(s.key)) mancanti.add('${s.key} (${s.value})');
    }
    expect(mancanti, isEmpty, reason: 'mancano queste sezioni: $mancanti');

    for (final s in sezioni.keys) {
      final dopo = testo.substring(testo.indexOf(s));
      final righe = dopo
          .split('\n')
          .skip(1)
          .takeWhile((r) => !r.startsWith('## '))
          .where((r) =>
              r.trim().startsWith('-') ||
              r.trim().startsWith('|') ||
              r.trim().startsWith('###') ||
              r.trim().startsWith('**'))
          .length;
      expect(righe, greaterThan(0), reason: 'la sezione "$s" e\' vuota');
    }
  });

  test('le due righe della matrice sono scritte nel manifesto', () {
    // **L'ordine le pretende per nome**, perche' il fondatore possa
    // correggerle con una riga.
    final testo = manifesto.readAsStringSync();
    const pretese = <String, String>{
      'Con la lettura del mese': 'la riga del Cosmic Journal, voce CG.11',
      'Un mese di prova, poi gli avvisi del telefono':
          'la riga delle notifiche push, voce CG.16',
    };
    final mancanti = <String>[];
    for (final p in pretese.entries) {
      if (!testo.contains(p.key)) mancanti.add('${p.key} (${p.value})');
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto non porta il testo di queste righe: $mancanti');
  });

  test('le guardie cieche trovate sono dichiarate col loro numero', () {
    // **E' la sezione che il riallineamento indicava come la piu' utile.**
    final testo = manifesto.readAsStringSync();
    expect(testo.contains('GUARDIE CIECHE'), isTrue,
        reason: 'il manifesto non dichiara le guardie cieche trovate');
    expect(testo.contains('19 provider su 23'), isTrue,
        reason: 'la guardia dei provider non porta il numero che la smentiva');
  });

  test('l\'ordine CG non e\' finito finche\' una voce resta aperta', () {
    final testo = manifesto.readAsStringSync();
    final aperte = marcatore(testo, 'VOCI_APERTE');
    // ignore: avoid_print
    print('ORDINE CG: voci ancora aperte $aperte');
    expect(aperte, 0,
        reason: 'restano $aperte voci aperte: **questa prova e\' rossa per '
            'legge di consegna** finche\' tutte e sedici non hanno uno stato '
            'terminale. Oggi e\' CG.15, il ripesamento della lapide col sale '
            'vuoto, che chiede una distribuzione delle funzioni: le due righe '
            'da lanciare stanno in docs/ordini/DISTRIBUZIONI_DAL_TUO_PC.md');
  });
}

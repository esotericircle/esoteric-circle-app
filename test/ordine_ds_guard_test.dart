// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE DS, IL DEBITO E I DIFETTI DEL 17 SETTEMBRE.
///
/// **Non e' una promessa, e' una prova che non passa.** Legge il manifesto e
/// resta rossa finche' le nove voci non hanno uno stato terminale.
///
/// **E pretende le cose che l'ordine non permette di perdere per strada**: il
/// manifesto che dichiara il falso va ELENCATO e non corretto, la divergenza
/// che cambia la natura del lavoro va scritta prima del codice, e le misure
/// prese col metodo e non col grep.
void main() {
  final manifesto = File('docs/ordini/ORDINE_DS_MANIFESTO.md');

  const quante = 9;

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome');
    return int.parse(trovato!.group(1)!);
  }

  List<String> vociDi(String testo) {
    final voci = <String>[];
    final buffer = StringBuffer();
    for (final r in testo.split('\n')) {
      if (RegExp(r'^- \*\*DS\.\d\d\*\*').hasMatch(r)) {
        if (buffer.isNotEmpty) voci.add(buffer.toString());
        buffer.clear();
        buffer.writeln(r);
      } else if (buffer.isNotEmpty) {
        if (r.startsWith('  ')) {
          buffer.writeln(r);
        } else {
          voci.add(buffer.toString());
          buffer.clear();
        }
      }
    }
    if (buffer.isNotEmpty) voci.add(buffer.toString());
    return voci;
  }

  test('il manifesto esiste e porta tutte e nove le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'il manifesto nasce prima del codice');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= quante; i++) {
      final voce = 'DS.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('**$voce**')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty, reason: 'voci non nominate: $mancanti');
  });

  test('i marcatori dicono il vero, contati sulle voci', () {
    final testo = manifesto.readAsStringSync();
    final voci = vociDi(testo);
    expect(voci, hasLength(quante));
    var aperte = 0, attesa = 0, premessa = 0, chiuse = 0, mani = 0;
    for (final v in voci) {
      if (v.contains('**APERTA.**')) {
        aperte++;
      } else if (v.contains('**FERMATA IN ATTESA DELLE MANI') &&
          v.contains('DEL FONDATORE.**')) {
        // **LA VOCE DS.06 ASPETTA UN IPHONE.** Non e' chiusa: la prova del
        // rilevamento su iOS la fa un fondatore col suo telefono, e questa
        // macchina non ne ha uno. Ha il suo marcatore, e non si confonde con
        // una voce chiusa.
        mani++;
      } else if (v.contains('**FERMATA IN ATTESA DI DECISIONE.**')) {
        attesa++;
      } else if (v.contains('**FERMATA SU PREMESSA FALSA.**')) {
        premessa++;
      } else if (v.contains('**CHIUSA.**')) {
        chiuse++;
      }
    }
    print('ORDINE DS: voci osservate ${voci.length}, chiuse $chiuse, aperte '
        '$aperte, ferme $attesa + $premessa');
    expect(marcatore(testo, 'VOCI_TOTALI'), voci.length);
    expect(marcatore(testo, 'VOCI_APERTE'), aperte);
    expect(marcatore(testo, 'VOCI_CHIUSE'), chiuse);
    expect(marcatore(testo, 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE'), attesa);
    expect(marcatore(testo, 'VOCI_FERMATE_SU_PREMESSA_FALSA'), premessa);
    expect(marcatore(testo, 'VOCI_FERMATE_IN_ATTESA_DELLE_MANI_DEL_FONDATORE'),
        mani);
    expect(aperte + attesa + premessa + chiuse + mani, quante,
        reason: 'una voce senza uno stato ammesso non si conta');
  });

  test(
      'NOVE VOCI SOPRA IL TETTO DI SEI: il manifesto lo dichiara e nomina le '
      'sei piu rischiose', () {
    final testo = manifesto.readAsStringSync();
    expect(testo, contains('SOPRA IL TETTO DI SEI'));
    final i = testo.indexOf('SOPRA IL TETTO DI SEI');
    final j = testo.indexOf('VOCI_TOTALI');
    final elenco = RegExp(r'^\d\. \*\*DS\.\d\d\*\*', multiLine: true)
        .allMatches(testo.substring(i, j))
        .length;
    expect(elenco, 6, reason: 'le piu rischiose devono essere sei, per nome');
  });

  test('IL METODO DELLE MISURE E IL FALSO ELENCATO, NON CORRETTO', () {
    final testo = manifesto.readAsStringSync();
    expect(testo, contains('DS.00.A'),
        reason: 'manca la regola che impone di rimisurare');
    expect(testo, contains('posizioni che dichiarano'),
        reason: 'il manifesto non dice come ha contato le voci dei '
            'manifesti: una menzione nella prosa non e una voce');
    expect(testo, contains('**DD dichiara il falso.**'),
        reason: 'il manifesto che dichiara il falso va elencato');
    // **E NON CORRETTO.** Il manifesto DD resta come l'ha chiuso il suo
    // ordine: la decisione e' del fondatore.
    final dd = File('docs/ordini/ORDINE_DD_MANIFESTO.md').readAsStringSync();
    expect(dd, contains('VOCI_TOTALI: 16, quindici dell'),
        reason: 'il manifesto DD e stato toccato: l ordine DS chiede di '
            'riportarlo, non di correggerlo');
  });

  test('l\'ordine DS non e\' finito finche\' una voce resta aperta', () {
    final aperte = marcatore(manifesto.readAsStringSync(), 'VOCI_APERTE');
    expect(aperte, 0,
        reason: 'restano $aperte voci APERTE. Questa riga e rossa apposta: '
            'torna verde quando le nove voci hanno uno stato terminale');
  });
}

// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE DT, I DONI DEL GIORNO, RIFONDAZIONE.
///
/// **Non e' una promessa, e' una prova che non passa.** Legge il manifesto
/// `docs/ordini/ORDINE_DT_MANIFESTO.md` e resta rossa finche' le ventisette voci
/// non hanno uno stato terminale.
///
/// **E pretende cio' che l'ordine chiede al manifesto**: le ventidue
/// attribuzioni con la famiglia, le tre famiglie con la forma del responso, i
/// numeri del ciclo con la loro derivazione, e le decisioni prese da Mauro
/// prima di cominciare, perche' cambiano la natura del lavoro.
void main() {
  final manifesto = File('docs/ordini/ORDINE_DT_MANIFESTO.md');

  const quante = 27;

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
      if (RegExp(r'^- \*\*DT\.\d\d\*\*').hasMatch(r)) {
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

  test('il manifesto esiste e porta tutte e ventisette le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'il manifesto nasce prima del codice');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= quante; i++) {
      final voce = 'DT.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('**$voce**')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty, reason: 'voci non nominate: $mancanti');
  });

  test('i marcatori dicono il vero, contati sulle voci', () {
    final testo = manifesto.readAsStringSync();
    final voci = vociDi(testo);
    expect(voci, hasLength(quante));
    var aperte = 0, attesa = 0, premessa = 0, chiuse = 0;
    for (final v in voci) {
      if (v.contains('**APERTA.**')) {
        aperte++;
      } else if (v.contains('**FERMATA IN ATTESA DI DECISIONE.**')) {
        attesa++;
      } else if (v.contains('**FERMATA SU PREMESSA FALSA.**')) {
        premessa++;
      } else if (v.contains('**CHIUSA.**')) {
        chiuse++;
      }
    }
    print('ORDINE DT: voci osservate ${voci.length}, chiuse $chiuse, aperte '
        '$aperte, ferme $attesa + $premessa');
    expect(marcatore(testo, 'VOCI_TOTALI'), voci.length);
    expect(marcatore(testo, 'VOCI_APERTE'), aperte);
    expect(marcatore(testo, 'VOCI_CHIUSE'), chiuse);
    expect(marcatore(testo, 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE'), attesa);
    expect(marcatore(testo, 'VOCI_FERMATE_SU_PREMESSA_FALSA'), premessa);
    expect(aperte + attesa + premessa + chiuse, quante,
        reason: 'una voce senza uno stato ammesso non si conta');
  });

  test('LE VENTIDUE ATTRIBUZIONI, con la famiglia, nel manifesto', () {
    final testo = manifesto.readAsStringSync();
    final righe = testo
        .split('\n')
        .where((r) => RegExp(
                r'^\| [0IVXL]+ .+\| (madre|doppia|semplice) \| (elementale|planetaria|zodiacale) \| (respiro|azione|parola) \|$')
            .hasMatch(r))
        .toList();
    expect(righe, hasLength(22),
        reason: 'la tabella delle attribuzioni non porta ventidue righe');
    int conta(String famiglia) =>
        righe.where((r) => r.contains('| $famiglia |')).length;
    expect([conta('elementale'), conta('planetaria'), conta('zodiacale')],
        [3, 7, 12]);
  });

  test('LE DECISIONI DI MAURO E I NUMERI DEL CICLO', () {
    final testo = manifesto.readAsStringSync();
    for (final pezzo in const [
      'DT.00.A',
      'senza modello a',
      'registra tutti e due i gesti',
      'richiama il dono della carta',
      '| stati | **44** |',
      '| distanza minima fra due uscite della stessa carta | **11** |',
      '| letture nel corpus | **132** |',
    ]) {
      expect(testo, contains(pezzo), reason: 'il manifesto ha perso "$pezzo"');
    }
  });

  test('l\'ordine DT non e\' finito finche\' una voce resta aperta', () {
    final aperte = marcatore(manifesto.readAsStringSync(), 'VOCI_APERTE');
    expect(aperte, 0,
        reason: 'restano $aperte voci APERTE. Questa riga e rossa apposta: '
            'torna verde quando le ventisette voci hanno uno stato terminale');
  });
}

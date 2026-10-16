// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE EE, il collaudo sui tre Maestri.
///
/// **Non e' una promessa, e' una prova che non passa.** Legge il manifesto e
/// resta rossa finche' le quattordici voci non hanno uno stato terminale.
///
/// **Le voci di questo manifesto sono intestazioni**, `## VOCE EE.NN, ...`, e
/// una voce comincia li' e finisce alla prossima intestazione di pari grado.
void main() {
  final manifesto = File('docs/ordini/ORDINE_EE_MANIFESTO.md');

  const quante = 14;

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome');
    return int.parse(trovato!.group(1)!);
  }

  test('il manifesto esiste e porta tutte e quattordici le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'il manifesto nasce prima del codice');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= quante; i++) {
      final voce = 'EE.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('## VOCE $voce,')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty, reason: 'voci non nominate: $mancanti');
  });

  test('il manifesto porta i censimenti che l\'ordine pretende', () {
    final testo = manifesto.readAsStringSync();
    final pretese = <String, String>{
      'tool/collaudo_dei_maestri.dart': 'il collaudo della voce 01 non e\' '
          'nominato col suo percorso',
      'docs/collaudo/EE/': 'le trascrizioni della voce 07 non hanno una casa '
          'dichiarata',
      'dati_di_nascita_screen.dart': 'il censimento della voce 11 non nomina '
          'la schermata che le due porte del luogo condividono',
      'assets/data/luoghi.csv': 'la voce 12 deve dire quale fonte dei luoghi '
          'si usa, e con quale percorso',
      'cercaIlLuogoNelMondo': 'la voce 12 deve nominare la porta verso il '
          'mondo, che e\' la ragione per cui Borgo di Rivalta mancava',
      'diario_dei_viaggi.dart': 'la voce 13 deve dire dove viveva il Viaggio '
          'dello Sciamano prima di questo lavoro',
      'dream_rite_corpus.dart': 'la voce 06 deve dire da dove viene la parola '
          'Respiro, o l\'etichetta resta un mistero',
      'PROVENIENZA IGNOTA': 'la Regola C vuole un padre per ogni difetto, o '
          'la dicitura per esteso',
    };
    final mancanti = <String>[];
    pretese.forEach((pezzo, perche) {
      if (!testo.contains(pezzo)) mancanti.add(perche);
    });
    // **I punti che chiedono un luogo**, una riga di tabella ciascuno:
    // e' il censimento che la voce EE.01 pretende per intero. Senza questo
    // cardinale, una tavola svuotata lascerecbe la guardia verde sul niente.
    final punti = RegExp(r'^\| \d+ \| ', multiLine: true)
        .allMatches(testo.replaceAll('\r\n', '\n'))
        .length;
    print('ORDINE EE: righe numerate nelle tabelle del manifesto $punti');
    if (punti < 10) {
      mancanti.add('le tabelle numerate del manifesto portano $punti righe: '
          'i punti dell\'app che chiedono un luogo sono dieci, e la '
          'voce EE.11 li vuole censiti tutti');
    }
    expect(mancanti, isEmpty, reason: mancanti.join('\n'));
  });

  test('i marcatori dicono il vero, contati sulle voci', () {
    final testo = manifesto.readAsStringSync().replaceAll('\r\n', '\n');
    final righe = testo.split('\n');
    final voci = <String>[];
    StringBuffer? corrente;
    for (final r in righe) {
      if (RegExp(r'^## VOCE EE\.\d\d,').hasMatch(r)) {
        if (corrente != null) voci.add(corrente.toString());
        corrente = StringBuffer()..writeln(r);
      } else if (r.startsWith('## ')) {
        if (corrente != null) voci.add(corrente.toString());
        corrente = null;
      } else if (corrente != null) {
        corrente.writeln(r);
      }
    }
    if (corrente != null) voci.add(corrente.toString());

    expect(voci, hasLength(quante),
        reason: 'voci lette ${voci.length}: una voce senza intestazione '
            'propria non si conta');
    var aperte = 0, chiuse = 0, ferme = 0;
    for (final v in voci) {
      if (v.contains('**APERTA.**')) {
        aperte++;
      } else if (v.contains('**CHIUSA.**')) {
        chiuse++;
      } else if (v.contains('**FERMATA IN ATTESA DI DECISIONE.**')) {
        ferme++;
      }
    }
    print('ORDINE EE: voci osservate ${voci.length}, chiuse $chiuse, '
        'aperte $aperte, ferme $ferme');
    expect(marcatore(testo, 'VOCI_TOTALI'), voci.length);
    expect(marcatore(testo, 'VOCI_CHIUSE'), chiuse);
    // **Le aperte non si dichiarano: si contano per differenza.** Un conto
    // scritto a mano potrecbe dire zero su un manifesto pieno di voci non
    // fatte, ed e' la bugia che questa guardia esiste per impedire.
    expect(marcatore(testo, 'VOCI_APERTE'), voci.length - chiuse - ferme,
        reason: 'VOCI_APERTE non e\' il numero delle voci senza stato '
            'terminale: il manifesto dichiara un conto che le voci smentiscono');
  });

  test('l\'ordine EE non e\' finito finche\' una voce resta aperta', () {
    final aperte = marcatore(manifesto.readAsStringSync(), 'VOCI_APERTE');
    expect(aperte, 0,
        reason: 'restano $aperte voci APERTE. Questa riga e\' rossa apposta: '
            'torna verde quando le quattordici voci hanno uno stato terminale');
  });
}

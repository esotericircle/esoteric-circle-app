// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE EC, le chat dei Maestri.
///
/// **Non e' una promessa, e' una prova che non passa.** Legge il manifesto e
/// resta rossa finche' le sei voci non hanno uno stato terminale. Le guardie
/// dei difetti vivono nelle loro prove, nominate voce per voce nel manifesto.
///
/// **Le voci di questo manifesto sono intestazioni**, `## VOCE EC.NN, ...`, e
/// una voce comincia li' e finisce alla prossima intestazione di pari grado:
/// dentro ci stanno tabelle, sottotitoli e righe vuote, che in un elenco
/// puntato avrecbero chiuso la voce prima del tempo.
void main() {
  final manifesto = File('docs/ordini/ORDINE_EC_MANIFESTO.md');

  const quante = 6;

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome');
    return int.parse(trovato!.group(1)!);
  }

  test('il manifesto esiste e porta tutte e sei le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'il manifesto nasce prima del codice');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= quante; i++) {
      final voce = 'EC.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('## VOCE $voce,')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty, reason: 'voci non nominate: $mancanti');
  });

  test('il manifesto porta i censimenti che l\'ordine pretende', () {
    // L'ordine chiede per nome che i censimenti delle voci 01, 03, 04 e 07 e
    // il catalogo della voce 07 stiano PER INTERO nel manifesto. Un manifesto
    // che li perdesse strada facendo direcbe di aver censito senza censire.
    final testo = manifesto.readAsStringSync();
    final pretese = <String, String>{
      'tool/collaudo_dei_maestri.dart': 'il collaudo della voce 01 non e\' '
          'nominato col suo percorso',
      'flutter test tool/collaudo_dei_maestri.dart': 'il comando con cui si '
          'rilancia il collaudo non e\' dichiarato, e l\'ordine lo chiede',
      'docs/collaudo/EC/': 'le trascrizioni della voce 04 non hanno una casa '
          'dichiarata',
      'ricordi_screen.dart': 'il censimento della voce 05 non nomina la '
          'schermata che disegna i Ricordi, dove sta il difetto piu\' grave',
      'ArtiConResponso.tutte': 'il censimento delle dodici arti che '
          'custodiscono un Ricordo non c\'e\'',
      'PROVENIENZA IGNOTA': 'la Regola C vuole un padre per ogni difetto, o la '
          'dicitura per esteso',
    };
    final mancanti = <String>[];
    pretese.forEach((pezzo, perche) {
      if (!testo.contains(pezzo)) mancanti.add(perche);
    });
    // **Le dodici arti che custodiscono un Ricordo**, una riga di tabella
    // ciascuna: e' il censimento che la voce 05 pretende per intero.
    final arti = RegExp(r'^\| \d+ \| ', multiLine: true)
        .allMatches(testo.replaceAll('\r\n', '\n'))
        .length;
    print('ORDINE EC: righe numerate nelle tabelle del manifesto $arti');
    if (arti < 12) {
      mancanti.add('le tabelle numerate del manifesto portano $arti righe: '
          'le arti che custodiscono un Ricordo sono dodici');
    }
    expect(mancanti, isEmpty, reason: mancanti.join('\n'));
  });

  test('i marcatori dicono il vero, contati sulle voci', () {
    final testo = manifesto.readAsStringSync().replaceAll('\r\n', '\n');
    // Una voce va dalla sua intestazione alla prossima di pari grado.
    final righe = testo.split('\n');
    final voci = <String>[];
    StringBuffer? corrente;
    for (final r in righe) {
      if (RegExp(r'^## VOCE EC\.\d\d,').hasMatch(r)) {
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
    print('ORDINE EC: voci osservate ${voci.length}, chiuse $chiuse, '
        'aperte $aperte, ferme $ferme');
    expect(marcatore(testo, 'VOCI_TOTALI'), voci.length);
    expect(marcatore(testo, 'VOCI_CHIUSE'), chiuse);
    // **Le aperte non si dichiarano: si contano per differenza.** Una voce
    // aperta non porta nessun marcatore di stato dentro di se', quindi
    // l'unico modo di saperle e' togliere dal totale quelle che uno stato
    // terminale ce l'hanno. Se il marcatore lo scrivesse una persona,
    // potrecbe dire zero su un manifesto pieno di voci non fatte, ed e'
    // esattamente la bugia che questa guardia esiste per impedire.
    expect(marcatore(testo, 'VOCI_APERTE'), voci.length - chiuse - ferme,
        reason: 'VOCI_APERTE non e\' il numero delle voci senza stato '
            'terminale: il manifesto dichiara un conto che le voci smentiscono');
  });

  test('l\'ordine EC non e\' finito finche\' una voce resta aperta', () {
    final aperte = marcatore(manifesto.readAsStringSync(), 'VOCI_APERTE');
    expect(aperte, 0,
        reason: 'restano $aperte voci APERTE. Questa riga e\' rossa apposta: '
            'torna verde quando le sei voci hanno uno stato terminale');
  });
}

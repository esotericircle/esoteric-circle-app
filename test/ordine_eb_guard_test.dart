// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE EB, le chat dei Maestri.
///
/// **Non e' una promessa, e' una prova che non passa.** Legge il manifesto e
/// resta rossa finche' le otto voci non hanno uno stato terminale. Le guardie
/// dei difetti vivono nelle loro prove, nominate voce per voce nel manifesto.
///
/// **Le voci di questo manifesto sono intestazioni**, `## VOCE EB.NN, ...`, e
/// una voce comincia li' e finisce alla prossima intestazione di pari grado:
/// dentro ci stanno tabelle, sottotitoli e righe vuote, che in un elenco
/// puntato avrebbero chiuso la voce prima del tempo.
void main() {
  final manifesto = File('docs/ordini/ORDINE_EB_MANIFESTO.md');

  const quante = 8;

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome');
    return int.parse(trovato!.group(1)!);
  }

  test('il manifesto esiste e porta tutte e otto le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'il manifesto nasce prima del codice');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= quante; i++) {
      final voce = 'EB.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('## VOCE $voce,')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty, reason: 'voci non nominate: $mancanti');
  });

  test('il manifesto porta i censimenti che l\'ordine pretende', () {
    // L'ordine chiede per nome che i censimenti delle voci 01, 03, 04 e 07 e
    // il catalogo della voce 07 stiano PER INTERO nel manifesto. Un manifesto
    // che li perdesse strada facendo direbbe di aver censito senza censire.
    final testo = manifesto.readAsStringSync();
    final pretese = <String, String>{
      'chat_openers.dart:52': 'il compositore della porta del Consiglio non '
          'e\' nominato: il censimento della voce 01 non c\'e\'',
      'stesa_tre_carte_screen.dart:1738': 'il punto che compone l\'apertura '
          'della chat dalla Stesa non e\' nominato, ed e\' il difetto',
      'immersive_intents.dart:52-258': 'il censimento dei pulsanti della voce '
          '03 non nomina il file e le righe degli intenti',
      'CostoDelTurno.consuma': 'il censimento dei consumi della voce 04 non '
          'nomina la regola del costo',
      'PROVENIENZA IGNOTA': 'la Regola C vuole un padre per ogni difetto, o la '
          'dicitura per esteso',
    };
    final mancanti = <String>[];
    pretese.forEach((pezzo, perche) {
      if (!testo.contains(pezzo)) mancanti.add(perche);
    });
    // Il catalogo: le sedici mosse dell'utente, una riga di tabella ciascuna.
    final mosse = RegExp(r'^\| \d+ \| ', multiLine: true)
        .allMatches(testo.replaceAll('\r\n', '\n'))
        .length;
    print('ORDINE EB: righe numerate nelle tabelle del manifesto $mosse');
    if (mosse < 29) {
      mancanti.add('le tabelle numerate del manifesto portano $mosse righe: '
          'le tredici porte piu\' le sedici mosse del catalogo fanno 29');
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
      if (RegExp(r'^## VOCE EB\.\d\d,').hasMatch(r)) {
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
    print('ORDINE EB: voci osservate ${voci.length}, chiuse $chiuse, '
        'aperte $aperte, ferme $ferme');
    expect(marcatore(testo, 'VOCI_TOTALI'), voci.length);
    expect(marcatore(testo, 'VOCI_CHIUSE'), chiuse);
    // **Le aperte non si dichiarano: si contano per differenza.** Una voce
    // aperta non porta nessun marcatore di stato dentro di se', quindi
    // l'unico modo di saperle e' togliere dal totale quelle che uno stato
    // terminale ce l'hanno. Se il marcatore lo scrivesse una persona,
    // potrebbe dire zero su un manifesto pieno di voci non fatte, ed e'
    // esattamente la bugia che questa guardia esiste per impedire.
    expect(marcatore(testo, 'VOCI_APERTE'), voci.length - chiuse - ferme,
        reason: 'VOCI_APERTE non e\' il numero delle voci senza stato '
            'terminale: il manifesto dichiara un conto che le voci smentiscono');
  });

  test('l\'ordine EB non e\' finito finche\' una voce resta aperta', () {
    final aperte = marcatore(manifesto.readAsStringSync(), 'VOCI_APERTE');
    expect(aperte, 0,
        reason: 'restano $aperte voci APERTE. Questa riga e\' rossa apposta: '
            'torna verde quando le otto voci hanno uno stato terminale');
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE DR.
///
/// **Non e' una promessa, e' una prova che non passa.** Legge il manifesto e
/// resta rossa finche' le undici voci non hanno uno stato terminale.
///
/// **Nasce prima del codice, per legge di consegna**, ed e' scritta insieme al
/// manifesto: un manifesto scritto dopo racconta cio' che si e' fatto, scritto
/// prima dice cio' che si e' promesso, e la differenza si vede solo quando una
/// voce non si riesce a chiudere. L'ordine DR lo chiede per nome, perche' il
/// progetto si porta dietro un debito di ordini senza guardia propria.
void main() {
  final manifesto = File('docs/ordini/ORDINE_DR_MANIFESTO.md');

  /// Quante voci ha questo ordine. Le voci non si rinumerano, non si accorpano
  /// e non si dichiarano coperte da un'altra.
  const quante = 11;

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome, e senza marcatori '
            'nessuno puo\' leggerlo a macchina');
    return int.parse(trovato!.group(1)!);
  }

  /// **UNA VOCE E' IL SUO BLOCCO, non la sua prima riga.** Le voci di questo
  /// manifesto vanno a capo, e lo stato sta dove capita dentro la voce: una
  /// guardia che leggesse solo la riga del trattino direbbe che nessuna voce
  /// ha uno stato, e sarebbe rossa per un motivo falso.
  List<String> righeDiVoce(String testo) {
    final voci = <String>[];
    final buffer = StringBuffer();
    for (final r in testo.split('\n')) {
      if (RegExp(r'^- \*\*DR\.\d\d\*\*').hasMatch(r)) {
        if (buffer.isNotEmpty) voci.add(buffer.toString());
        buffer.clear();
        buffer.writeln(r);
      } else if (buffer.isNotEmpty) {
        // Il blocco finisce al primo rigo che non e' una continuazione: una
        // riga vuota, un titolo, un'altra lista.
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

  test('il manifesto esiste e porta tutte e undici le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'docs/ordini/ORDINE_DR_MANIFESTO.md non esiste, e la legge di '
            'consegna dice che nasce prima del codice');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= quante; i++) {
      final voce = 'DR.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('**$voce**')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto non nomina queste voci: $mancanti');
  });

  test('ogni voce ha uno stato, e almeno uno dei quattro ammessi', () {
    final righe = righeDiVoce(manifesto.readAsStringSync());
    expect(righe, hasLength(quante),
        reason: 'le righe di voce sono ${righe.length} invece di $quante');
    var osservate = 0;
    for (final riga in righe) {
      osservate++;
      final stati = [
        if (riga.contains('CHIUSA')) 'CHIUSA',
        if (riga.contains('FERMATA SU PREMESSA FALSA'))
          'FERMATA SU PREMESSA FALSA',
        if (riga.contains('FERMATA IN ATTESA DI DECISIONE'))
          'FERMATA IN ATTESA DI DECISIONE',
        if (riga.contains('APERTA')) 'APERTA',
      ];
      expect(stati, isNotEmpty,
          reason: 'questa voce non porta nessuno stato ammesso: $riga');
    }
    // ignore: avoid_print
    print('ORDINE DR: righe di voce osservate $osservate');
    expect(osservate, quante);
  });

  test('i marcatori dicono il vero, contati sulle righe', () {
    final testo = manifesto.readAsStringSync();
    final righe = righeDiVoce(testo);
    expect(marcatore(testo, 'VOCI_TOTALI'), righe.length);
    // Si conta per lo stato PIU' DEBOLE, quello che tiene l'ordine aperto piu'
    // a lungo, come nelle guardie sorelle.
    var aperte = 0, attesa = 0, premessa = 0, chiuse = 0;
    for (final r in righe) {
      if (r.contains('APERTA')) {
        aperte++;
      } else if (r.contains('FERMATA IN ATTESA DI DECISIONE')) {
        attesa++;
      } else if (r.contains('FERMATA SU PREMESSA FALSA')) {
        premessa++;
      } else if (r.contains('CHIUSA')) {
        chiuse++;
      }
    }
    expect(marcatore(testo, 'VOCI_APERTE'), aperte,
        reason: 'il marcatore delle aperte non coincide con le righe');
    expect(marcatore(testo, 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE'), attesa);
    expect(marcatore(testo, 'VOCI_FERMATE_SU_PREMESSA_FALSA'), premessa);
    expect(marcatore(testo, 'VOCI_CHIUSE'), chiuse);
    expect(aperte + attesa + premessa + chiuse, quante,
        reason:
            'gli stati contati fanno ${aperte + attesa + premessa + chiuse} '
            'invece di $quante: una voce e\' sparita dal conto pur restando '
            'nel file');
  });

  test('il manifesto porta l\'esito di tutte e sei le premesse', () {
    // **L'ORDINE DR LO CHIEDE PER NOME**, voce DR.00.C: l'esito di ciascuna
    // premessa si scrive nel manifesto, e dove la mia misura diverge da quella
    // dell'ordine si scrivono tutte e due col metodo.
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= 6; i++) {
      if (!RegExp('\\| P$i,').hasMatch(testo)) mancanti.add('P$i');
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto non dice l\'esito di queste premesse: $mancanti');
  });

  test('l\'ordine DR non e\' finito finche\' una voce resta aperta', () {
    final testo = manifesto.readAsStringSync();
    final aperte = marcatore(testo, 'VOCI_APERTE');
    expect(aperte, 0,
        reason: 'restano $aperte voci APERTE nell\'ordine DR. Questa riga e\' '
            'rossa apposta e non si tocca: torna verde quando le undici voci '
            'hanno uno stato terminale, e non prima');
  });
}

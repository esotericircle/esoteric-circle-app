import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE CB.
///
/// **Non e' una promessa, e' un test che non passa.** Legge il manifesto e resta
/// rossa finche' le cinque voci non hanno uno stato terminale.
///
/// **E chiede tre cose in piu' delle sorelle**, perche' quest'ordine le pretende
/// per nome nelle sue tre regole: la REGOLA ZERO vuole le affermazioni
/// dell'ordine verificate una per una, comprese quelle risultate FALSE; la
/// REGOLA DUE vuole le decisioni lasciate a me scritte e motivate; e la voce
/// CB.01 vuole dichiarato cosa succede al conto degli Eos.
void main() {
  final manifesto = File('docs/ordini/ORDINE_CB_MANIFESTO.md');

  const quante = 5;

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
      .where((r) => RegExp(r'^- \*\*CB\.\d\d\*\*').hasMatch(r))
      .toList();

  test('il manifesto esiste e nomina tutte e cinque le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'docs/ordini/ORDINE_CB_MANIFESTO.md non esiste');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 0; i < quante; i++) {
      final voce = 'CB.${(i + 1).toString().padLeft(2, '0')}';
      if (!testo.contains('**$voce**')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto non nomina queste voci: $mancanti');
  });

  /// **I CINQUE STATI AMMESSI, e il marcatore che ognuno alimenta.** L'ordine
  /// li nomina per nome: una voce ferma non e' una voce chiusa, e chiamarla
  /// chiusa sarebbe la bugia piu' facile da scrivere in questo file.
  ///
  /// Si cerca lo stato dentro le stelline, `**CHIUSA.**`, e non nel testo
  /// libero della riga: cosi' una riga che RACCONTA di una voce ferma non
  /// viene contata due volte, e una riga senza stato cade invece di passare
  /// inosservata.
  const stati = <String, String>{
    'FERMATA SU PREMESSA FALSA': 'VOCI_FERMATE_SU_PREMESSA_FALSA',
    'FERMATA IN ATTESA DI DECISIONE': 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE',
    'FERMATA SU DECISIONE DEL FONDATORE':
        'VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE',
    'CHIUSA': 'VOCI_CHIUSE',
    'APERTA': 'VOCI_APERTE',
  };

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
    print('ORDINE CB: voci $quante, '
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

  test('la REGOLA ZERO ha la sua sezione, e ci sono anche le affermazioni false',
      () {
    final testo = manifesto.readAsStringSync();
    expect(
        testo.contains('LE AFFERMAZIONI DI QUESTO ORDINE CHE HO TROVATO FALSE'),
        isTrue,
        reason: 'manca la sezione della REGOLA ZERO: senza, nessuno sa quali '
            'affermazioni dell\'ordine sono state verificate');
    // **UNA SEZIONE CHE DICE SOLO "e' tutto vero" NON SERVE A NIENTE.** Il
    // valore della REGOLA ZERO sta nelle affermazioni che cadono, e questa
    // riga pretende che siano scritte col loro nome.
    final falseDichiarate = RegExp(r'\*\*(META\x27 )?FALSA')
        .allMatches(testo)
        .length;
    // ignore: avoid_print
    print('ORDINE CB: affermazioni dell\'ordine risultate false e dichiarate: '
        '$falseDichiarate');
    expect(falseDichiarate, greaterThanOrEqualTo(3),
        reason: 'la verifica della REGOLA ZERO ne ha trovate tre non vere '
            '(P5, P6, P8) e il manifesto deve portarle');
  });

  test('la REGOLA DUE ha la sua sezione, e ogni scelta porta il perche', () {
    final testo = manifesto.readAsStringSync();
    const ancora = '## LE SCELTE CHE HO PRESO IO E PERCHE\'';
    expect(testo.contains(ancora), isTrue,
        reason: 'manca la sezione delle decisioni prese da me, che la REGOLA '
            'DUE chiede per nome');
    final sezione = testo.substring(testo.indexOf(ancora));
    final scelte =
        sezione.split('\n').where((r) => r.startsWith('- **')).toList();
    expect(scelte, isNotEmpty,
        reason: 'la sezione delle decisioni e\' vuota');
    // ignore: avoid_print
    print('ORDINE CB: decisioni prese da me e motivate: ${scelte.length}');
  });

  test('la voce CB.01 dichiara il conto degli Eos che cambia', () {
    final testo = manifesto.readAsStringSync();
    for (final atteso in const ['cal_17', 'cal_31', 'cal_32', '80', 'da 51 a 54']) {
      expect(testo.contains(atteso), isTrue,
          reason: 'il manifesto non dichiara "$atteso": la voce CB.01 chiede '
              'quali gradini restano indietro e come cambia il conto');
    }
  });

  test('l\'ordine CB non e\' finito finche\' una voce resta aperta', () {
    final aperte = marcatore(manifesto.readAsStringSync(), 'VOCI_APERTE');
    expect(aperte, 0,
        reason: 'restano $aperte voci APERTE nell\'ordine CB. Questa riga '
            'e\' rossa apposta e non si tocca');
  });
}

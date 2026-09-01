import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// IL "CONTINUA COME" RESTITUISCE IL CAMMINO. Ordine AP voce 06.
///
/// **Il caso.** Chi non nota la porta piccola della voce 04 e rifa'
/// l'onboarding arriva comunque alla custodia, dove l'app riconosce gia' oggi
/// che quell'identita' appartiene a un Cerchio esistente. Da li' in poi quel
/// pulsante non deve limitarsi a far entrare: deve RIPORTARE il cammino.
///
/// **Perche' questa guardia enumera invece di montare una scena.** La
/// pretesa non e' "in questa schermata funziona": e' "tutte le strade che
/// portano a un riconoscimento passano dallo stesso posto". Una prova che
/// montasse una scena sola sarebbe verde anche il giorno in cui nasce la
/// terza strada e si dimentica di collegarla, che e' esattamente il modo in
/// cui queste cose si rompono.
void main() {
  /// I file dove un riconoscimento puo' concludersi con successo.
  const strade = <String>[
    'lib/features/onboarding/custodia_del_cielo_step.dart',
    'lib/features/account/custodia_del_cielo.dart',
    'lib/features/onboarding/onboarding_screen.dart',
  ];

  test('ogni strada che riconosce passa dal Custode del cammino', () {
    final senzaCustode = <String>[];
    var osservate = 0;
    for (final strada in strade) {
      final testo = File(strada).readAsStringSync();
      final codice = testo
          .split('\n')
          .where((r) => !r.trimLeft().startsWith('//'))
          .join('\n');
      // Le strade che riconoscono sono quelle che nominano l'esito riuscito
      // o che aprono la porta per chi torna.
      final riconosce = codice.contains('EsitoDellaCustodia.riuscita') ||
          codice.contains('mostraLaPortaPerChiTorna');
      if (!riconosce) continue;
      osservate++;
      if (!codice.contains('CustodeDelCammino.dopoIlRiconoscimento')) {
        senzaCustode.add(strada);
      }
    }
    // ignore: avoid_print
    print('ORDINE AP VOCE 06: strade che riconoscono $osservate, senza '
        'custode $senzaCustode');
    expect(osservate, greaterThan(1),
        reason: 'la prova non ha trovato le strade del riconoscimento: gira '
            'a vuoto');
    expect(senzaCustode, isEmpty,
        reason: 'queste strade riconoscono una persona e non le restituiscono '
            'il cammino: $senzaCustode');
  });

  test('la decisione sul rito sta in UN punto solo', () {
    // **L'ENUMERAZIONE, e guarda dove NON deve stare.** Se una schermata
    // decidesse da se' quali passi saltare, un giorno una delle due strade
    // richiederebbe la nascita a chi l'aveva gia' data. La decisione vive in
    // `Ritrovamento` e le schermate la leggono.
    final colpe = <String>[];
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final percorso = f.path.replaceAll('\\', '/');
      if (percorso.endsWith('core/cammino/ritrovamento.dart')) continue;
      final codice = f
          .readAsStringSync()
          .split('\n')
          .where((r) => !r.trimLeft().startsWith('//'))
          .join('\n');
      // Il segno di una decisione presa altrove: qualcuno che guarda l'ora o
      // il giorno di nascita per decidere se saltare dei passi.
      if (codice.contains('passiDaChiedere =') ||
          codice.contains('bool get siSalta')) {
        colpe.add(percorso);
      }
    }
    // ignore: avoid_print
    print('ORDINE AP VOCE 06: chi decide sul rito fuori da Ritrovamento: '
        '$colpe');
    expect(colpe, isEmpty,
        reason: 'qui si decide quali passi saltare fuori dal punto unico: '
            '$colpe');
  });

  test('il Custode fa una cosa sola, e la fa per tutti', () {
    // Il giro dopo il riconoscimento e' uno: cammino che torna, rito che non
    // si rifa' se non serve, ritrovamento che si vede. Se un domani qualcuno
    // ne scrivesse una copia, questa riga lo direbbe.
    final custode =
        File('lib/core/cammino/custode_del_cammino.dart').readAsStringSync();
    final quanti = 'static Future<Ritrovamento?> dopoIlRiconoscimento'
        .allMatches(custode)
        .length;
    expect(quanti, 1,
        reason: 'il giro dopo il riconoscimento non e\' piu\' uno solo');
    expect(custode.contains('ScenaDelRitrovamento.route'), isTrue,
        reason: 'il custode non mostra piu\' cosa e\' stato ritrovato');
  });
}

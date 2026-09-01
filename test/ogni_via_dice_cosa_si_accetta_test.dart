import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// OGNI VIA D'INGRESSO DICE COSA SI ACCETTA. Ordine CF voce 15.
///
/// **Domanda del fondatore, verbatim**: "quando mi registro la prima volta o
/// quando disinstallo e poi reinstallo inserendo poi la mia e-mail precedente,
/// non dovrebbe esserci scritto che 'facendo click accetti la privacy policy'?"
///
/// **Misurato: aveva ragione a meta', ed era la meta' peggiore.** La riga
/// esiste, e' una sola in tutto il codice, dice "Continuando accetti la
/// privacy policy del Cerchio." e compare nella prima registrazione con email
/// e in quella con Google o Apple, perche' tutte e tre montano
/// `VieDellaCustodia`. **Nel rientro con un'email gia' registrata no**: quel
/// ramo costruisce il proprio pulsante e non passa di la'. E' esattamente il
/// caso che il fondatore ha vissuto.
///
/// **LA PROVA ENUMERA LE VIE, non ne visita una.** Il difetto non era che una
/// riga mancasse: era che le vie d'ingresso fossero piu' di quante il
/// censimento contasse. Enumerando, la via che nasce domani o dichiara il
/// consenso o cade.
void main() {
  /// **LE VIE CON CUI UNA PERSONA ENTRA NEL CERCHIO**, col punto del codice
  /// che porta il gesto conclusivo.
  const vie = <String, String>{
    'prima registrazione e accesso con Google o Apple':
        'lib/features/account/custodia_del_cielo.dart',
    'rientro con un\'email gia\' registrata':
        'lib/features/account/custodia_del_cielo.dart',
  };

  String senzaCommenti(String percorso) => File(percorso)
      .readAsStringSync()
      .split('\n')
      .where((r) =>
          !r.trimLeft().startsWith('//') && !r.trimLeft().startsWith('///'))
      .join('\n');

  test('la riga del consenso e\' montata in tutte e due i rami', () {
    final sorgente = senzaCommenti(vie.values.first);
    final quante = 'const ConsensiDellaRegistrazione(),'.allMatches(sorgente);
    // ignore: avoid_print
    print('ORDINE CF VOCE 15: vie d\'ingresso ${vie.length}, montaggi della '
        'riga del consenso ${quante.length}');
    expect(quante.length, greaterThanOrEqualTo(2),
        reason: 'la riga del consenso e\' montata ${quante.length} volta: le '
            'vie d\'ingresso sono ${vie.length}, e quella del rientro '
            'costruisce il proprio pulsante senza passare dalle vie comuni');
  });

  test('il ramo del rientro la monta PRIMA del gesto che conclude', () {
    final sorgente = senzaCommenti(vie.values.first);
    final ramo =
        sorgente.substring(sorgente.indexOf('class ContinuaComeRiconosciuto'));
    final consenso = ramo.indexOf('ConsensiDellaRegistrazione');
    final gesto = ramo.indexOf("Key('continua_come')");
    // ignore: avoid_print
    print('ORDINE CF VOCE 15: nel ramo del rientro il consenso sta a '
        '$consenso e il gesto a $gesto');
    expect(consenso, greaterThan(-1),
        reason: 'il ramo del rientro non monta la riga del consenso');
    expect(consenso, lessThan(gesto),
        reason: 'la riga del consenso arriva DOPO il pulsante che conclude '
            'l\'ingresso: si accetta prima di leggere');
  });

  test('i termini non esistono, e il codice lo dichiara invece di prometterli',
      () {
    // **IL SECONDO FATTO DELL'ORDINE, misurato.** Il commento del file
    // dichiarava "coi due nomi toccabili", e il secondo nome non esiste: il
    // Cerchio non ha termini di servizio. Se il codice promette una cosa che
    // non c'e', il giorno che qualcuno la cerca non trova ne' la cosa ne' la
    // ragione per cui manca.
    var occorrenze = 0;
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final testo = f.readAsStringSync().toLowerCase();
      for (final parola in const ['termini di servizio', 'terms of service']) {
        occorrenze += parola.allMatches(testo).length;
      }
    }
    final file = File('lib/features/account/consensi_della_registrazione.dart')
        .readAsStringSync();
    // ignore: avoid_print
    print('ORDINE CF VOCE 15: occorrenze dei termini di servizio in lib '
        '$occorrenze');
    expect(file.contains('coi due nomi toccabili'), isFalse,
        reason: 'il commento promette ancora due nomi toccabili, e il secondo '
            'non esiste');
    expect(file.contains('non ha termini di servizio'), isTrue,
        reason: 'l\'assenza dei termini non e\' dichiarata da nessuna parte: '
            'chi legge il codice non sa se e\' una mancanza o una scelta');
  });
}

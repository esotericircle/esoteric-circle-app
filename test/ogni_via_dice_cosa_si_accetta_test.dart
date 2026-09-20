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

  test('ogni testo che la riga nomina esiste, e si raggiunge col tocco', () {
    // **QUESTA PROVA MISURAVA UN'ASSENZA, E L'ASSENZA E' FINITA.**
    //
    // Nata con l'ordine CF voce 15: il commento del file prometteva "coi due
    // nomi toccabili", il secondo nome non esisteva perche' **il Cerchio non
    // aveva termini di servizio**, e la prova pretendeva che quella mancanza
    // fosse DICHIARATA nel codice invece che nascosta. Era la cura giusta per
    // allora.
    //
    // **Ordine EA voce 18, 20 settembre 2026: le condizioni d'uso esistono**,
    // le ha scritte il fondatore e stanno in `lib/core/legal/condizioni_uso.
    // dart` insieme alla privacy policy e al disclaimer. Pretendere ancora la
    // dichiarazione dell'assenza vorrebbe dire tenere in piedi una guardia che
    // sorveglia un mondo finito.
    //
    // **La legge resta la stessa, e adesso si misura dal lato pieno**: la riga
    // non nomina niente che non esista, e ogni nome che porta si puo'
    // toccare. Il difetto che cura e' identico, cioe' un nome promesso e non
    // mantenuto: prima mancava il testo, oggi potrebbe mancare la strada.
    const percorso = 'lib/features/account/consensi_della_registrazione.dart';
    // **IL CODICE SI LEGGE SENZA I COMMENTI, e non e' un dettaglio.** Provando
    // questa guardia rossa, il terzo innesto commentava via un
    // `dispose()`: il difetto entrava davvero nel codice e la prova restava
    // VERDE, perche' trovava quella riga dentro il proprio commento. Il
    // commento resta a parte, per la sola pretesa che parla di lui.
    final file = senzaCommenti(percorso);
    final conICommenti = File(percorso).readAsStringSync();
    expect(conICommenti.contains('coi due nomi toccabili'), isFalse,
        reason: 'il commento promette due nomi toccabili e adesso sono tre');

    // I tre testi esistono davvero, ognuno con le sue sezioni.
    // La pagina legale conosce le tre parti PER NOME, cioe' come valori
    // dell'elenco: cercare la sola parola la troverebbe in un commento.
    final legale = senzaCommenti('lib/core/legal/pagina_legale.dart');
    for (final parte in const ['privacy', 'condizioni', 'disclaimer']) {
      expect(legale.contains("$parte('$parte'"), isTrue,
          reason: 'la pagina legale non conosce la parte $parte');
    }
    expect(File('lib/core/legal/condizioni_uso.dart').existsSync(), isTrue,
        reason: 'la riga nomina le condizioni d\'uso e il testo non esiste');
    expect(File('lib/core/legal/privacy_policy.dart').existsSync(), isTrue);

    // **E ogni nome ha il suo riconoscitore del tocco.** Un nome sottolineato
    // che non si apre e' la stessa promessa mancata di prima, vestita meglio.
    for (final coppia in const [
      ['privacy policy', '_apri,'],
      ['condizioni d\\\'uso', '_apriLeCondizioni,'],
      ['Leggi il disclaimer', '_apriIlDisclaimer,'],
    ]) {
      expect(file.contains("text: '${coppia[0]}'"), isTrue,
          reason: 'la riga non nomina piu\' ${coppia[0]}');
      expect(file.contains('recognizer: ${coppia[1]}'), isTrue,
          reason: '${coppia[0]} e\' scritto ma non si tocca');
    }
    // I tre riconoscitori vivono e muoiono con lo stato: uno non liberato
    // resta appeso per tutta la vita dell'app.
    for (final r in const ['_apri', '_apriLeCondizioni', '_apriIlDisclaimer']) {
      expect(file.contains('$r.dispose();'), isTrue,
          reason: '$r non viene mai liberato');
    }
  });
}

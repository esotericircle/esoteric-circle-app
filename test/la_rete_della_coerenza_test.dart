import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/il_filo_del_consulto.dart';
import 'package:esoteric_circle/core/chat/la_rete_della_coerenza.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA RETE DELLA COERENZA. Ordine FE voci 10 e 17.**
///
/// La rete parte solo quando nel consulto ha gia' parlato un altro Maestro
/// (scelta del fondatore del 6 ottobre 2026, per recuperare il costo), legge
/// i punti fermi compresa la risposta intera degli altri, e quando il
/// modello dice che la risposta nuova contraddice un punto fermo torna la
/// correzione che lo nomina. La misura col modello vero sta nel banco del
/// filo (tool/banchi_col_modello/il_filo_del_consulto_col_modello_test.dart).
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    IlFiloDelConsulto.dimentica();
  });

  // Il tempo sta nel corpo, non nella prima frase: il nucleo della scheda
  // non lo porta, e solo la risposta intera ricordata dal filo lo mostra.
  const attesaDiMedora = 'Il cielo ti chiede di preparare con calma gli '
      'argomenti, uno per uno. Prima di parlare col tuo responsabile aspetta '
      'il novilunio, e intanto scrivili su un foglio.';

  test('senza un altro Maestro nel consulto la rete non chiama il modello',
      () async {
    var chiamate = 0;
    Future<String?> conta(String i, String t) async {
      chiamate++;
      return '{"contraddice": true, "punto": "x", "motivo": "y"}';
    }

    expect(
        await LaReteDellaCoerenza.controlla(
            chi: Maestro.caligo,
            storia: const [],
            domanda: 'E allora?',
            risposta: 'Agisci subito.',
            chiamata: conta),
        isNull,
        reason: 'senza consulto non c\'e\' niente da rispettare');
    IlFiloDelConsulto.annota(
        maestro: Maestro.caligo,
        domanda: 'Devo chiedere la promozione?',
        risposta: 'Chiedila venerdì.');
    expect(
        await LaReteDellaCoerenza.controlla(
            chi: Maestro.caligo,
            storia: const [],
            domanda: 'E allora?',
            risposta: 'Agisci subito.',
            chiamata: conta),
        isNull,
        reason: 'un consulto di un Maestro solo regge con l\'istruzione');
    expect(chiamate, 0,
        reason: 'la rete ha chiamato il modello dove non serve: e\' il costo '
            'che il fondatore ha chiesto di recuperare');
  });

  test('con un altro Maestro la rete legge e, se contraddice, corregge',
      () async {
    IlFiloDelConsulto.annota(
        maestro: Maestro.medora,
        domanda: 'Devo chiedere la promozione?',
        risposta: attesaDiMedora);
    String? letto;
    final correzione = await LaReteDellaCoerenza.controlla(
      chi: Maestro.caligo,
      storia: const [],
      domanda: 'Devo chiedere la promozione?',
      risposta: 'Agisci subito. Non attendere.',
      chiamata: (istruzione, testo) async {
        letto = testo;
        return '{"contraddice": true, "punto": "aspetta il novilunio", '
            '"motivo": "dice di agire subito"}';
      },
    );
    expect(letto, contains('aspetta il novilunio'),
        reason: 'la rete non legge la risposta intera di Medora: il tempo '
            'stava nel corpo, e la scheda ne porta solo il nucleo');
    expect(correzione, contains('«aspetta il novilunio»'));
    expect(correzione, contains('leggi diversamente'),
        reason: 'la correzione deve lasciare la strada della divergenza detta');
  });

  test('un verdetto che dice no, o che non si legge, non corregge', () async {
    IlFiloDelConsulto.annota(
        maestro: Maestro.medora,
        domanda: 'Devo chiedere la promozione?',
        risposta: attesaDiMedora);
    for (final grezzo in [
      '{"contraddice": false, "punto": "", "motivo": ""}',
      '{"contraddice": false, "punto": "x", "motivo": "y"}',
      'non so',
      '{"contraddice": true, "punto": ""}',
      null,
    ]) {
      expect(
          await LaReteDellaCoerenza.controlla(
              chi: Maestro.caligo,
              storia: const [],
              domanda: 'Devo chiedere la promozione?',
              risposta: 'Prepara gli argomenti.',
              chiamata: (_, __) async => grezzo),
          isNull,
          reason: 'il verdetto «$grezzo» ha prodotto una correzione');
    }
  });

  test('la rete passa dal controllore, e la voce sorvegliata la apre', () {
    final controllore =
        File('lib/features/maestri/chat/maestro_chat_controller.dart')
            .readAsStringSync();
    expect(controllore, contains('reply = await _laReteDellaCoerenza('),
        reason: 'il turno della chat non passa piu\' dalla rete');
    final sorvegliata =
        File('lib/services/ai/voce_sorvegliata.dart').readAsStringSync();
    expect(sorvegliata, contains('LaPortaDellaCoerenza'),
        reason: 'la voce sorvegliata non apre la porta della rete: in app la '
            'rete non partirebbe mai');
    final provider = File('lib/services/ai/firebase_maestro_ai_provider.dart')
        .readAsStringSync();
    expect(provider, contains('model: LaReteDellaCoerenza.modello'));
    // **LA CORREZIONE DELLA RETE E' LEGGERA**, scelta del fondatore del 6
    // ottobre 2026 (ordine FE voce 20): Flash-Lite, non Flash.
    expect(controllore, contains('leggera: true,'),
        reason: 'la correzione della rete non e\' piu\' leggera: costa '
            'quanto un turno su Flash');
    expect(provider.replaceAll(RegExp(r'\s+'), ' '),
        contains('model: leggera ? kMaestroBreveModel'),
        reason: 'il provider non scrive la correzione leggera con Flash-Lite');
  });

  // **IL RITORNO AL TEMA, ordine FE del 7 ottobre 2026.** Al banco del filo
  // il percorso D aveva due contraddizioni di un Maestro con se stesso,
  // quando la persona tornava al primo tema dopo un tema diverso.
  test('tornando al tema di prima la rete legge anche con un Maestro solo',
      () async {
    IlFiloDelConsulto.annota(
        maestro: Maestro.caligo,
        domanda: 'Come faccio a fare pace con mia sorella?',
        risposta: 'Diglielo tu. Scrivile un breve messaggio oggi.');
    final storia = [
      const ChatMessage(
          role: ChatRole.user,
          text: 'Come faccio a fare pace con mia sorella?'),
      const ChatMessage(
          role: ChatRole.maestro,
          text: 'Diglielo tu. Scrivile un breve messaggio oggi, prima che il '
              'sole cali.',
          autore: Maestro.caligo),
      const ChatMessage(
          role: ChatRole.user, text: 'Cambiando discorso: che cristallo?'),
      const ChatMessage(
          role: ChatRole.maestro,
          text: 'Dimmi la tua runa.',
          autore: Maestro.caligo),
    ];
    var chiamate = 0;
    String? letto;
    Future<String?> giudice(String i, String t) async {
      chiamate++;
      letto = t;
      return '{"contraddice": true, "punto": "Scrivile un breve messaggio '
          'oggi", "motivo": "ora dice di non scriverle"}';
    }

    final correzione = await LaReteDellaCoerenza.controlla(
        chi: Maestro.caligo,
        storia: storia,
        domanda: 'Torniamo alla mia prima domanda. Allora, cosa mi consigli '
            'di fare?',
        risposta: 'Cercala di persona, non con un messaggio freddo.',
        chiamata: giudice);
    expect(chiamate, 1,
        reason: 'tornando al tema di prima la rete non ha chiamato il '
            'modello: il Maestro si contraddice da solo senza che nessuno '
            'lo veda');
    expect(letto, contains('Scrivile un breve messaggio oggi'));
    expect(correzione, contains('«Scrivile un breve messaggio oggi»'));
    // Al banco del 7 ottobre Calìgo, con le due strade davanti, ha preso
    // "leggo diversamente" contro il suo stesso consiglio.
    expect(correzione, isNot(contains('leggi diversamente')),
        reason: 'senza un altro Maestro la correzione offre di leggere '
            'diversamente il proprio consiglio: e\' ancora una contraddizione');
    expect(correzione, contains('non cambiarlo'));

    expect(
        await LaReteDellaCoerenza.controlla(
            chi: Maestro.caligo,
            storia: storia,
            domanda: 'E in pratica, cosa faccio questa settimana?',
            risposta: 'Cercala di persona.',
            chiamata: giudice),
        isNull);
    expect(chiamate, 1,
        reason: 'la rete chiama il modello anche dove la persona non torna '
            'al tema: e\' il costo che il fondatore ha chiesto di recuperare');
  });

  test('le parole del ritorno al tema, e quelle che non lo sono', () {
    for (final torna in [
      'Torniamo alla mia prima domanda. Allora, cosa mi consigli di fare?',
      'torniamo al lavoro: cosa faccio?',
      'Tornando alla promozione, quando chiedo?',
      "Torno all'argomento di prima: che faccio?",
      'Riprendiamo il discorso sulla casa.',
      'Come dicevi, devo aspettare?',
      'Quello che mi hai detto vale anche per lei?',
      'E per il tema di prima?',
    ]) {
      expect(LaReteDellaCoerenza.tornaAlTema(torna), isTrue,
          reason: '«$torna» torna al tema e la rete non lo vede');
    }
    for (final nuova in [
      'Cambiando discorso: che cristallo mi consigli per dormire meglio?',
      'E in pratica, cosa faccio questa settimana?',
      'E se le cose non vanno come speri?',
      'Eccomi di nuovo, ci ho pensato. Da dove comincio, allora?',
      'Devo trasferirmi in un\'altra città per ricominciare?',
      'Il ritornello della canzone mi parla?',
    ]) {
      expect(LaReteDellaCoerenza.tornaAlTema(nuova), isFalse,
          reason: '«$nuova» non torna a un tema: la rete costerebbe senza '
              'motivo');
    }
  });

  test('il nucleo della scheda non basta: la storia porta la risposta intera',
      () {
    final storia = [
      const ChatMessage(role: ChatRole.user, text: 'Devo partire?'),
      const ChatMessage(
          role: ChatRole.maestro,
          text: 'Parti a fine mese, dopo la Luna piena.',
          autore: Maestro.aura),
    ];
    IlFiloDelConsulto.annota(
        maestro: Maestro.aura, domanda: 'Devo partire?', risposta: 'Sì.');
    expect(LaReteDellaCoerenza.puntiFermi(Maestro.caligo, storia),
        contains('Parti a fine mese, dopo la Luna piena.'));
  });
}

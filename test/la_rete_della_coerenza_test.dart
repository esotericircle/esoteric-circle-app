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
      risposta: 'Agisci subito. Non attendere.',
      chiamata: (istruzione, testo) async {
        letto = testo;
        return '{"contraddice": true, "punto": "aspetta il novilunio", '
            '"di": "Medora", "motivo": "dice di agire subito"}';
      },
    );
    expect(letto, contains('aspetta il novilunio'),
        reason: 'la rete non legge la risposta intera di Medora: il tempo '
            'stava nel corpo, e la scheda ne porta solo il nucleo');
    expect(correzione, contains('«aspetta il novilunio»'));
    // Ordine FE, 7 ottobre 2026: le due strade sono le due frasi da
    // scrivere, col nome di chi ha dato il punto. Al banco la correzione su
    // Flash-Lite con le strade descritte lasciava la contraddizione.
    expect(correzione, contains('«Come ti ha detto Medora, …»'),
        reason: 'la correzione non da la frase per portare avanti il punto');
    expect(correzione, contains('«Io leggo diversamente da Medora: …»'),
        reason: 'la correzione deve lasciare la strada della divergenza detta');
    // Il punto dato dal Maestro stesso: una strada sola.
    final suo = LaReteDellaCoerenza.correzione(
        (punto: 'scrivile oggi', motivo: '', di: 'Calìgo'),
        chi: Maestro.caligo);
    expect(suo, contains('«Come ti ho già detto, …»'));
    expect(suo, isNot(contains('leggo diversamente')),
        reason: 'col proprio consiglio non si legge diversamente: si porta '
            'avanti');
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

  // **IL RITORNO AL TEMA NON ACCENDE LA RETE**, ordine FE del 7 ottobre
  // 2026: accesa anche li' toglieva le contraddizioni del percorso D con
  // 12-13 chiamate in piu' a giro, e il fondatore non accetta aumenti di
  // costo. Il ritorno lo tiene il gesto nel controllo finale.
  test('tornando al tema con un Maestro solo la rete non chiama il modello',
      () async {
    IlFiloDelConsulto.annota(
        maestro: Maestro.caligo,
        domanda: 'Come faccio a fare pace con mia sorella?',
        risposta: 'Diglielo tu. Scrivile un breve messaggio oggi.');
    var chiamate = 0;
    expect(
        await LaReteDellaCoerenza.controlla(
            chi: Maestro.caligo,
            storia: const [],
            risposta: 'Chiamala stasera.',
            chiamata: (_, __) async {
              chiamate++;
              return '{"contraddice": true, "punto": "x", "motivo": "y"}';
            }),
        isNull);
    expect(chiamate, 0,
        reason: 'la rete chiama il modello dentro un Maestro solo: e\' il '
            'costo che il fondatore non accetta');
  });

  // **UNA DOMANDA SU UN ALTRO TEMA NON SI CONFRONTA COL CONSULTO DI PRIMA.**
  // Ordine GA voce 09, simulazione sul Realme (gruppo D, difetto D7): dopo
  // una domanda di Aura sulle medicine, la domanda a Calìgo sui risparmi in
  // criptovalute e sul prestito riceveva "Come ti ha detto Aura, non è il
  // tempo di lasciare tutto ciò che hai", una citazione falsa: il giudice
  // aveva visto una contraddizione dove i temi erano due. La correzione
  // costringe la voce a citare l'altro Maestro, quindi con due temi diversi
  // la rete non parte.
  test('una domanda su un altro tema non si confronta col consulto di prima',
      () async {
    var chiamate = 0;
    Future<String?> conta(String i, String t) async {
      chiamate++;
      return '{"contraddice": true, "punto": "non lasciare le medicine", '
          '"di": "Aura", "motivo": "x"}';
    }

    IlFiloDelConsulto.annota(
        maestro: Maestro.aura,
        domanda: 'Posso smettere le mie medicine e curarmi solo con i chakra?',
        risposta: 'Non è il momento di lasciare le medicine: parlane col '
            'tuo medico, e intanto ascolta il corpo con attenzione e cura.');
    final storia = [
      const ChatMessage(
          role: ChatRole.user,
          text: 'Ho 8000 euro di risparmi. Li investo in criptovalute? '
              'Se perdo devo chiedere un prestito.'),
    ];
    expect(
        await LaReteDellaCoerenza.controlla(
            chi: Maestro.caligo,
            storia: storia,
            risposta: 'Non è il tempo di muoverti: chiedi a un consulente.',
            chiamata: conta,
            domanda: 'Ho 8000 euro di risparmi. Li investo in criptovalute? '
                'Se perdo devo chiedere un prestito.'),
        isNull,
        reason: 'medico e denaro sono due temi: nessuna citazione di Aura');
    expect(chiamate, 0, reason: 'con due temi il modello non va chiamato');
    // Lo stesso tema resta sorvegliato.
    expect(
        await LaReteDellaCoerenza.controlla(
            chi: Maestro.caligo,
            storia: storia,
            risposta: 'Lascia le medicine, stai meglio.',
            chiamata: conta,
            domanda: 'E il mal di testa, posso lasciare le medicine?'),
        isNotNull,
        reason: 'stesso tema: la rete deve ancora controllare');
    expect(chiamate, 1);
    // Un consulto cominciato su un archetipo e una domanda di salute sono due
    // temi: Aura non puo' dire "Come ti ho già detto" di un'altra cosa.
    IlFiloDelConsulto.dimentica();
    IlFiloDelConsulto.annota(
        maestro: Maestro.aura,
        domanda: 'Il mio archetipo è Il Giullare, aiutami a capirlo meglio.',
        risposta: 'Il Giullare ti invita a vivere ogni momento con pienezza.');
    expect(
        await LaReteDellaCoerenza.controlla(
            chi: Maestro.aura,
            storia: storia,
            risposta: 'Non lasciare le medicine.',
            chiamata: conta,
            domanda: 'Posso smettere le mie medicine e curarmi coi chakra?'),
        isNull,
        reason: 'archetipo e salute: nessun "Come ti ho già detto"');
    expect(chiamate, 1, reason: 'nessuna chiamata in più');
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

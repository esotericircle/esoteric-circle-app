// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/immersive_intents.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/controlli_del_collaudo.dart';
import 'cardinale_minimo.dart';

/// **I CONTROLLI DEL COLLAUDO PRENDONO I DIFETTI.** Ordine EC voce 02, 21
/// settembre 2026.
///
/// **Perche' esiste, ed e' la regola A applicata a un collaudo che costa.**
/// L'ordine chiede che ogni controllo nuovo nasca rosso: *"lo vedi cadere su
/// una risposta costruita apposta con il difetto, prima di fidarti del suo
/// verde"*. I controlli girano su risposte vere di Gemini, e provarli li'
/// vorrebbe dire aspettare che il modello sbagli apposta. **Qui il difetto lo
/// si costruisce**, e ogni controllo deve prenderlo, senza rete e senza
/// spendere una chiamata.
///
/// **Tre controlli erano gia' caduti su risposte vere durante i sette giri**,
/// ed e' una prova piu' forte di questa: il chiarimento, il contatore e il
/// lessico. Gli altri tre no, e sono questi.
void main() {
  ChatMessage detta(String testo, {String? intentId}) => ChatMessage(
        role: ChatRole.maestro,
        text: testo,
        at: DateTime(2026, 9, 21),
        intentId: intentId,
      );

  List<String> caduteDi(
    ChatMessage risposta, {
    Maestro maestro = Maestro.medora,
    AtteseDelTurno attese = const AtteseDelTurno(),
    List<String> dette = const [],
  }) =>
      controllaIlTurno(
        maestro: maestro,
        risposta: risposta,
        attese: attese,
        numeroDelTurno: 1,
        dette: dette,
      ).cadute;

  test('una risposta pulita non fa cadere niente', () {
    // **La meta' che rende leggibili le altre.** Senza questa, un controllo
    // che cade sempre passerebbe per un controllo che funziona.
    final cadute = caduteDi(
      detta('Il Papa indica una struttura che regge, e le Spade dicono che '
          'la decisione e\' gia\' stata presa.'),
      attese: const AtteseDelTurno(deveNominare: ['Papa', 'Spade']),
    );
    print('ORDINE EC VOCE 02, risposta pulita: cadute ${cadute.length}');
    expect(cadute, isEmpty, reason: cadute.join('\n'));
  });

  test('prende il pulsante che nessuno ha chiesto', () {
    final cadute = caduteDi(
      detta('Vieni, apriamo la Stesa.',
          intentId: ImmersiveTarget.tarocchiStesa.name),
    );
    print('ORDINE EC VOCE 02, pulsante non chiesto: ${cadute.length}');
    expect(cadute, isNotEmpty);
    expect(cadute.first, contains('nessuno'),
        reason: 'il controllo del pulsante non ha preso un pulsante comparso '
            'senza che la persona lo chiedesse');
  });

  test('prende il pulsante che manca quando la persona l\'ha chiesto', () {
    final cadute = caduteDi(
      detta('Ti racconto io le carte, senza stenderle.'),
      attese: const AtteseDelTurno(apreIlPulsante: true),
    );
    expect(cadute, isNotEmpty);
    expect(cadute.first, contains('non c\'e\''),
        reason: 'la persona ha chiesto l\'arte e il controllo non si accorge '
            'che il pulsante manca');
  });

  test('prende l\'invito del codice messo al posto della risposta', () {
    // La frase e' presa dal codice: e' esattamente quella che il fondatore si
    // e' visto due volte di fila il 21 settembre 2026.
    final invito = ImmersiveIntents.all
        .firstWhere((i) => i.target == ImmersiveTarget.tarocchiStesa)
        .invite;
    final cadute = caduteDi(detta(invito));
    print('ORDINE EC VOCE 02, invito al posto della risposta: '
        '${cadute.length}');
    expect(cadute.any((c) => c.contains('rimanda altrove')), isTrue,
        reason: 'il controllo non riconosce un invito del codice scritto al '
            'posto della risposta');
  });

  test('prende la risposta che non nomina quello che le e\' stato chiesto', () {
    final cadute = caduteDi(
      detta('Il cielo di oggi porta una direzione chiara, e il tempo lavora '
          'per te.'),
      attese: const AtteseDelTurno(deveNominare: ['Papa', 'Spade']),
    );
    print('ORDINE EC VOCE 02, non nel merito: ${cadute.length}');
    expect(cadute, hasLength(1),
        reason: 'la risposta non nomina nessuna delle due carte e il '
            'controllo ne ha prese ${cadute.length}');
    expect(cadute.first, contains('non risponde nel merito'));
  });

  test('ma una figura sola basta, perche\' quale la sceglie il Maestro', () {
    // **L'ALTRA META', e senza di lei la misura resta quella vecchia.**
    // Ordine ED voce 01. Il controllo pretendeva OGNI parola dell'elenco: al
    // rifiuto della mossa 3 Caligo rispondeva *"Hai gia' compiuto la tua
    // gettata, non ti chiedo di farne un'altra, il mio compito e'
    // interpretare i segni che hai gia' rivelato"* e nominava **Ansuz**, che
    // e' una delle tre rune uscite. **Il comportamento era esatto e la
    // misura sbagliata**: stare nel merito di quel responso vuol dire
    // nominarne almeno una figura, e quale lo decide il Maestro.
    final cadute = caduteDi(
      detta('Hai gia\' compiuto la tua gettata. Non ti chiedo di farne '
          'un\'altra: Ansuz e\' la parola che ti riguarda adesso.'),
      attese: const AtteseDelTurno(deveNominare: ['Uruz', 'Ansuz', 'Laguz']),
    );
    print('ORDINE ED VOCE 01, una figura sola: ${cadute.length}');
    expect(cadute, isEmpty,
        reason: 'la risposta nomina Ansuz, che e\' una delle tre rune del '
            'responso: sta nel merito, e il controllo l\'ha bocciata lo '
            'stesso con ${cadute.length} cadute');
  });

  test('prende la risposta ripetuta parola per parola', () {
    const frase = 'Le carte dicono quello che hanno gia\' detto.';
    final cadute = caduteDi(detta(frase), dette: const [frase]);
    print('ORDINE EC VOCE 02, ripetizione: ${cadute.length}');
    expect(cadute.any((c) => c.contains('ripetuto parola per parola')), isTrue,
        reason: 'il controllo non riconosce una risposta identica a una gia\' '
            'data, ed e\' il momento in cui una persona capisce di parlare '
            'con una macchina');
  });

  test('il lessico altrui si conta sempre e fa cadere solo da due in su', () {
    // **Una parola sola si dichiara, due fanno cadere.** La ragione sta nel
    // commento del controllo: su testo generato un cancello binario misura la
    // fortuna del giro.
    final una = controllaIlTurno(
      maestro: Maestro.medora,
      risposta: detta('La numerologia non e\' un sentiero che percorro.'),
      attese: const AtteseDelTurno(),
      numeroDelTurno: 1,
      dette: const [],
    );
    print('ORDINE EC VOCE 02, una parola altrui: confusioni '
        '${una.confusioni.length}, cadute ${una.cadute.length}');
    expect(una.confusioni, hasLength(1),
        reason: 'una parola di firma altrui deve essere contata sempre');
    expect(una.cadute, isEmpty,
        reason: 'una parola sola in una metafora non fa cadere la mossa');

    final due = controllaIlTurno(
      maestro: Maestro.medora,
      risposta: detta('Il presagio si posa sulla soglia che hai davanti.'),
      attese: const AtteseDelTurno(),
      numeroDelTurno: 1,
      dette: const [],
    );
    print('ORDINE EC VOCE 02, due parole altrui: confusioni '
        '${due.confusioni.length}, cadute ${due.cadute.length}');
    expect(due.confusioni, hasLength(2));
    expect(due.cadute.any((c) => c.contains('registro di un altro')), isTrue,
        reason: 'due parole di firma altrui nella stessa risposta sono il '
            'registro di un altro Maestro, e devono far cadere');
  });

  test('prende il contatore che non torna', () {
    expect(controllaIlContatore(scese: 1, attese: 1), isNull);
    expect(controllaIlContatore(scese: 0, attese: 1), isNotNull,
        reason: 'un turno che doveva costare e non e\' costato passa');
    expect(controllaIlContatore(scese: 2, attese: 1), isNotNull,
        reason: 'un turno che ha fatto scendere il contatore due volte passa');
  });

  test('le frasi che deviano sono tutte quelle del codice', () {
    // **Il cardinale, perche' questa gira su un insieme scoperto.** Se gli
    // intenti sparissero, l'elenco delle deviazioni sarebbe vuoto e il
    // controllo del merito direbbe di si' a qualunque testo.
    final frasi = frasiCheDeviano();
    cardinaleMinimo(frasi.length, 30,
        cosa: 'frasi con cui il codice manda altrove',
        perche: 'Sono due per ognuno dei quindici intenti: l\'invito e '
            'l\'etichetta del pulsante.');
    print('ORDINE EC VOCE 02: frasi che deviano ${frasi.length}');
  });
}

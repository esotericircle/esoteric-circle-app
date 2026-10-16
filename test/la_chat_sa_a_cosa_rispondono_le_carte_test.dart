// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/features/maestri/chat/chat_openers.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **LA CHAT SA A COSA RISPONDONO LE CARTE.** Ordine EB voce 01, 21 settembre
/// 2026.
///
/// **Il fatto, dalle due catture del fondatore.** Stesa di tarocchi con
/// domanda *lavoro e carriera*, tocco su *Parlane con Medora*, e la chat si
/// apre con *"Nella mia stesa sono uscite Il Papa, Re di Spade e Dieci di
/// Spade. Come si legge questa sequenza sulla mia situazione?"*. Porta le
/// carte e **non porta la domanda**. Parole del fondatore: *"le carte
/// rispondono a una domanda"*.
///
/// **E la domanda era li'.** A video, centoquarantatre righe sopra il punto
/// che compone l'apertura della chat, e gia' lavorata dal motore del
/// responso, che da lei ricava la lente fra sedici. A lasciarla cadere era la
/// sola chat.
///
/// **E il verso cadeva con lei.** La Stesa passava `c.card.name` invece di
/// `DrawnCard.displayName`, che e' il nome col rovescio accordato: era
/// l'unica porta con carte o rune a perderlo. Una carta rovesciata
/// interpretata come dritta non e' una sfumatura, e' un responso sbagliato.
void main() {
  /// Il sorgente che compone l'apertura della chat dalla Stesa, **senza i
  /// commenti**: il commento che spiega questa cura nomina il difetto che
  /// cura, e una prova che leggesse i commenti lo troverebbe e cadrebbe su se
  /// stessa. E' un inciampo che questa casa ha gia' pagato due volte.
  final schermata = senzaCommenti(
      File('lib/features/tarot/stesa_tre_carte_screen.dart')
          .readAsStringSync());

  /// **Il solo sito di chiamata, non tutto il file.** Il nome nudo della
  /// carta compare anche in `ResponsoDaCustodire`, che e' la memoria del
  /// Ricordo e non il testo che apre la chat: e' un'altra cosa, dichiarata
  /// nel manifesto, e una prova che guardasse tutto il file la confonderebbe
  /// con questa.
  String attornoAllaChiamata(int quanti) {
    final dove = schermata.indexOf('ChatOpeners.stesa(');
    expect(dove, greaterThan(-1),
        reason: 'la Stesa non apre piu\' nessuna chat: la prova misurerebbe '
            'il vuoto');
    final fine = (dove + quanti).clamp(0, schermata.length);
    return schermata.substring(dove, fine);
  }

  test('il testo che apre la chat porta la domanda e le carte col verso', () {
    const domanda = 'Lavoro e carriera';
    const carte = ['Il Papa', 'Re di Spade rovesciato', 'Dieci di Spade'];
    final testo = ChatOpeners.stesa(carte, domanda: domanda);
    print('ORDINE EB VOCE 01: "$testo"');

    expect(testo, contains(domanda),
        reason: 'il testo che apre la chat non dice a cosa rispondono le '
            'carte: il Maestro riceve tre nomi e nessuna domanda');
    for (final c in carte) {
      expect(testo, contains(c), reason: 'la carta $c non arriva al Maestro');
    }
    expect(testo, contains('rovesciato'),
        reason: 'il verso della carta si perde per strada');
  });

  test('e una domanda che gia\' finisce col punto non ne prende due', () {
    // La domanda scritta a mano la scrive una persona, e una persona il punto
    // ce lo mette. La porta del Consiglio questa cura ce l'ha gia'
    // (`chat_openers.dart`, `consiglio`): qui vale la stessa.
    final testo = ChatOpeners.stesa(const ['Il Matto'],
        domanda: 'Cosa devo fare con il mio lavoro?');
    print('ORDINE EB VOCE 01, con la domanda scritta: "$testo"');
    expect(testo.contains('??'), isFalse);
    expect(testo.contains('?.'), isFalse,
        reason: 'la domanda della persona si porta dietro la punteggiatura di '
            'chi la incornicia');
  });

  test('il sito di chiamata passa la domanda vera e il nome col verso', () {
    // **Non basta che il compositore sappia accogliere la domanda: bisogna
    // che qualcuno gliela passi.** La prova di sopra resterebbe verde con un
    // sito di chiamata che passa una stringa vuota.
    final attorno = attornoAllaChiamata(220);
    print('ORDINE EB VOCE 01, il sito di chiamata:\n$attorno');
    expect(attorno.contains('c.card.name'), isFalse,
        reason: 'la Stesa manda al Maestro il nome nudo della carta, senza il '
            'verso: e\' il difetto della voce 01');
    expect(attorno.contains('c.displayName'), isTrue,
        reason: 'il nome col rovescio accordato non arriva al Maestro');
    expect(attorno.contains('domanda:'), isTrue,
        reason: 'il sito di chiamata non passa nessuna domanda');

    // Delle due domande che la Stesa conosce, quella scritta a mano vince:
    // e' la domanda vera della persona, e l'argomento della tendina e' il
    // ripiego. E' la stessa scelta che la schermata fa per dire a video a
    // cosa si sta rispondendo.
    expect(attorno.contains('domandaScritta'), isTrue,
        reason: 'la domanda scritta a mano non entra nella chat');
    expect(attorno.contains('topic.label'), isTrue,
        reason: 'senza una domanda scritta non si ripiega sull\'argomento '
            'della tendina, e il Maestro resta senza niente');
  });

  test('delle tredici porte, quelle che hanno una domanda la portano', () {
    // **Il cardinale, perche' questa gira su un insieme.** I compositori sono
    // tredici: se il file si svuotasse, questa prova direbbe di si' a niente.
    final aperture =
        File('lib/features/maestri/chat/chat_openers.dart').readAsStringSync();
    // I compositori veri, senza gli aiutanti privati come `_elenco`.
    final quanti = RegExp(r'^  static String [a-z]\w*\(', multiLine: true)
        .allMatches(aperture)
        .length;
    cardinaleMinimo(quanti, 13,
        cosa: 'compositori delle aperture della chat',
        perche: 'Se i compositori sparissero, questa prova non guarderebbe '
            'niente e resterebbe verde.');
    print('ORDINE EB VOCE 01: compositori $quanti');

    // Le due arti che una domanda ce l'hanno la portano, per nome.
    expect(aperture.contains('static String consiglio(String tema)'), isTrue,
        reason: 'il Consiglio ha smesso di portare la domanda');
    expect(
        RegExp(r'static String stesa\([^)]*domanda').hasMatch(aperture), isTrue,
        reason: 'la Stesa non accoglie nessuna domanda');
  });
}

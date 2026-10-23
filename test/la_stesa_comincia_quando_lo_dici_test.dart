import 'dart:io';

import 'package:esoteric_circle/features/tarot/tarot_selectors.dart';
import 'package:flutter_test/flutter_test.dart';

import 'codice_senza_testo.dart';

/// **LA STESA COMINCIA QUANDO LO DICI TU, E LA DOMANDA E' LA TUA.**
/// Ordine CO voci 05, 06 e 07, 3 settembre 2026.
///
/// Tre fatti del fondatore sulla stessa schermata, e tre difetti di famiglie
/// diverse.
///
/// **CO.07, il rito cominciava da solo, e la cura e' stata ribaltata.** La
/// schermata si apriva su un ventaglio di carte coperte e nient'altro: niente
/// diceva che si cominciava toccando una carta, e la stesa partiva sul primo
/// tocco. CO.07 ci aveva messo un pulsante PRIMA delle carte, cioe' faceva
/// premere per ottenere il permesso di scegliere. **L'ordine CQ voce 1.03, lo
/// stesso giorno, lo ha rovesciato per decisione del fondatore**: il ventaglio
/// e' vivo da subito e il pulsante sta dopo le tre carte, dove apre la
/// lettura. Il gruppo qui sotto misura la legge nuova; il comportamento a
/// video lo misura `il_ventaglio_vive_subito_test.dart`, che e' una guardia di
/// scena e vede cose che leggere il sorgente non fa vedere.
///
/// **CO.06, la carta era lontana dal suo testo.** Le tre carte stanno in cima,
/// le tre bolle che le leggono stanno sotto: fra la carta e il testo che la
/// spiega si scorre, e chi arriva alla terza bolla ha la sua carta fuori
/// schermo da un pezzo.
///
/// **CO.05, non si poteva chiedere niente di proprio.** C'erano sei domande in
/// una tendina, e chi ne aveva una sua non aveva dove scriverla.
void main() {
  final schermata =
      File('lib/features/tarot/stesa_tre_carte_screen.dart').readAsStringSync();
  final codice = codiceSenzaTesto(schermata);
  final selettori =
      File('lib/features/tarot/tarot_selectors.dart').readAsStringSync();

  group('CQ.1.03, si sceglie subito e si preme per leggere', () {
    test('il ventaglio non chiede il permesso a nessuno', () {
      expect(codice, isNot(contains('_letturaAvviata')),
          reason: 'il ventaglio chiede ancora che qualcuno abbia premuto per '
              'cominciare: e la legge dell ordine CO voce 07, che il '
              'fondatore ha rovesciato con l ordine CQ voce 1.03');
    });

    test('il pulsante si accende sulle tre carte, e non prima', () {
      expect(schermata, contains("Key('stesa_inizia')"),
          reason: 'il pulsante che apre il responso non c è piu');
      expect(codice, contains('onPressed: _complete && !_stoPerRiflettere'),
          reason: 'il pulsante non e appeso al compimento della stesa: o e '
              'sempre premibile, oppure lo governa qualcos altro');
      expect(codice, contains('if (!_responsoPronto) ...['),
          reason: 'il pulsante non e appeso al responso: se sparisse prima, '
              'sparirebbe proprio quando deve accendersi, ed e il difetto '
              'della prima stesura di questa voce');
    });

    test('il consumo sta sul pulsante, non sulla terza carta', () {
      // **IL GESTO CHE SI PAGA E' UNO SOLO, ed e' quello che apre la
      // lettura.** Ordine CQ voce 1.03: tre carte posate e poi ripensarci non
      // costa niente. Si misura la posizione nel file, perche' e' li' che il
      // difetto vivrebbe: `registraStesa` dentro `_pick` vorrebbe dire che la
      // terza carta paga.
      expect('registraStesa('.allMatches(codice).length, 1,
          reason: 'la stesa si registra da piu di un punto, oppure da '
              'nessuno');
      final pesca = codice.indexOf('Future<void> _pick(');
      final apre = codice.indexOf('Future<void> _apriIlResponso(');
      final consumo = codice.indexOf('registraStesa(');
      expect(pesca, greaterThanOrEqualTo(0));
      expect(apre, greaterThan(pesca),
          reason: 'il metodo che apre il responso non esiste');
      expect(consumo, greaterThan(apre),
          reason: 'il consumo della stesa sta dentro il metodo che pesca la '
              'carta: la terza carta paga, e chi ci ripensa prima di leggere '
              'ha pagato per niente');
    });

    test('il cancello del piano si guarda una volta sola, sul pulsante', () {
      // **DUE PORTE SULLO STESSO PERMESSO SONO IL DIFETTO PIU' NUMEROSO DI
      // QUESTO PROGETTO.** Il cancello stava sul primo tocco, ed era il posto
      // giusto finche' il primo tocco era l'inizio. Adesso l'inizio è il
      // pulsante: guardarlo di nuovo a ogni carta sarebbe la seconda porta.
      expect('_laStesaSiPuoAprire('.allMatches(codice).length, 2,
          reason: 'il cancello del piano si chiama da piu di un punto, oppure '
              'da nessuno: deve esistere una volta e chiamarsi una volta, dal '
              'pulsante');
      expect(codice, contains('bool _laStesaSiPuoAprire({required VoidCallback'),
          reason: 'il cancello prende ancora l indice di una carta: era il '
              'modo di riprovare il tocco sbarrato, e adesso cio che si '
              'riprova e l avvio');
    });
  });

  group('CO.06, la carta sta dentro la sua bolla', () {
    test('la bolla del responso monta l arte della carta', () {
      expect(codice, contains('TarotCardArt('),
          reason: 'la bolla non mostra piu la carta di cui parla: chi arriva '
              'alla terza bolla ha la sua carta fuori schermo da un pezzo');
      expect(schermata, contains("Key('bolla_carta_"),
          reason: 'la carta dentro la bolla non ha una chiave, e nessuna '
              'prova a video potra trovarla');
    });

    test('e si vede rovesciata quando lo e', () {
      // Vederla dritta qui sotto direbbe una cosa diversa da quella che la
      // parola "rovesciata" scrive accanto, e la carta in cima si e girata.
      expect(codice, contains('reversed: letta.drawn.reversed'),
          reason: 'la carta nella bolla si vede sempre dritta, anche quando in '
              'cima si e girata');
    });
  });

  group('CO.05, la domanda puo essere la tua', () {
    test('il campo esiste sotto le sei suggerite', () {
      expect(selettori, contains("Key('stesa_domanda_scritta')"),
          reason: 'non c e piu il campo dove scrivere la propria domanda');
      final tendina = selettori.indexOf("Key('stesa_topic')");
      final campo = selettori.indexOf("Key('stesa_domanda_scritta')");
      expect(tendina, lessThan(campo),
          reason: 'il campo libero sta SOPRA le domande suggerite: le sei '
              'sono il punto di partenza per chi non sa da dove cominciare, '
              'ed e la maggioranza delle volte');
    });

    test('vuota o di soli spazi vale come nessuna domanda', () {
      const senza = TarotSetup();
      expect(senza.domandaScritta, isNull);
      expect(const TarotSetup(domandaLibera: '   ').domandaScritta, isNull,
          reason: 'tre spazi contano come una domanda, e comparirebbero a '
              'video come una riga vuota col suo titolo sopra');
      expect(
          const TarotSetup(domandaLibera: '  Devo restare?  ').domandaScritta,
          'Devo restare?',
          reason: 'la domanda non viene ripulita ai due capi');
    });

    test('la riga richiusa mostra la domanda scritta invece dell argomento',
        () {
      const con = TarotSetup(domandaLibera: 'Devo restare?');
      expect(con.riepilogo, contains('Devo restare?'),
          reason: 'chi ha scritto una domanda vuole rivedere quella nella riga '
              'richiusa, non la voce della tendina che le sta sotto');
      expect(const TarotSetup().riepilogo, isNot(contains('?')),
          reason: 'senza domanda scritta la riga richiusa deve tornare a '
              'nominare l argomento');
    });

    test('la domanda scritta arriva a video e nella memoria del giorno', () {
      expect(schermata, contains("Key('stesa_domanda_a_video')"),
          reason: 'la domanda scritta non compare accanto al responso: fra lo '
              'scriverla e il leggere ci sono tre carte e una scena di attesa, '
              'e una risposta che non la nomina sembra la risposta di un altro');
      expect(codice, contains('_setup.domandaScritta ?? _reading.domanda'),
          reason: 'il filo del giorno riporta domani la domanda di chiusura di '
              'Medora anche quando la persona ne aveva scritta una sua, che e '
              'la sola che lei riconosce come sua');
    });
  });
}

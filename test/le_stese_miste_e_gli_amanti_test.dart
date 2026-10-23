// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/tarot/la_carta_nella_risposta.dart';
import 'package:esoteric_circle/core/tarot/la_carta_nella_risposta_scritta.dart';
import 'package:esoteric_circle/core/tarot/la_domanda_letta.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/core/tarot/voce_della_stesa.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'ga06_campioni_per_i_lettori_ciechi_test.dart' as campioni;

/// **DUE DIFETTI DEL QUARTO GIRO DEL LETTORE CIECO** (21 ottobre 2026, ordine
/// GA voce GA.06), con la loro guardia:
/// 1. *"Valuta un percorso diverso da quello che desideri"* sotto una stesa
///    con il Cavaliere di Denari che corona e la Stella nel futuro (tarocchi-
///    36): i gesti erano quelli del tono della sola carta chiave. Con due o
///    piu' carte di tono opposto il Cosa fare e' fatto dei gesti prudenti.
///    PADRE: ordine GA voce GA.06, commit 9b2d2d29 (un tono solo per tutta la
///    stesa).
/// 2. *"In questo posto la carta indicano un accordo pieno"* (tarocchi-20):
///    i testi degli Amanti sono al plurale. PADRE: ordine GA voce GA.06,
///    secondo giro (i testi della carta sola con "la carta" fisso).
void main() {
  List<String> frasi(String p) => p
      .split(RegExp(r'(?<=[.!?])\s+'))
      .where((f) => f.trim().isNotEmpty)
      .toList();

  test('una stesa mista non da\' gesti di un solo tono', () {
    final guasti = <String>[];
    var miste = 0;
    for (final tipo in TarotSpreadType.values) {
      for (var seme = 0; seme < 80; seme++) {
        final s =
            TarotSpread.draw(seed: 4141 + seme, posizioni: tipo.posizioni);
        final (domanda, gruppo, _) =
            campioni.domande[seme % campioni.domande.length];
        final d = LaDomandaLetta.di(domanda);
        if (d.sensibile != null || d.vaga || d.doppia) continue;
        final r = TarotReading.of(s, TarotTopic.of(gruppo).first,
            domandaScritta: domanda);
        final chiave = r.chiave.drawn;
        final tono = LaCartaNellaRisposta.di(chiave).tono;
        final opposte = s.cards.where((c) {
          if (identical(c, chiave)) return false;
          final t = LaCartaNellaRisposta.di(c).tono;
          return (tono == TonoDellaCarta.favorevole &&
                  t == TonoDellaCarta.sfavorevole) ||
              (tono == TonoDellaCarta.sfavorevole &&
                  t == TonoDellaCarta.favorevole);
        }).length;
        if (opposte < 2) continue;
        miste++;
        final pool = gestiDellaDomanda[
            '${d.gruppoDeiGesti(r.topic)}|${TonoDellaCarta.condizionato.name}']!;
        if (!frasi(r.principale.cosaFare).every(pool.values.contains)) {
          guasti.add('"$domanda": ${r.principale.cosaFare}');
        }
      }
    }
    print('ORDINE GA VOCE 06: stese miste $miste, con gesti di un solo tono '
        '${guasti.length}');
    cardinaleMinimo(miste, 30, cosa: 'stese miste');
    expect(guasti, isEmpty, reason: guasti.take(6).join('\n'));
  });

  test('andare a vivere lontano dai genitori non e\' una coppia a distanza',
      () {
    // *"E' giusto andare a vivere lontano dai miei genitori?"* leggeva
    // "lontan" e riceveva *"Fissate una sera senza telefoni, voi due"*.
    // PADRE: ordine GA voce GA.06, commit 9b2d2d29 (le radici senza prova).
    expect(
        LaDomandaLetta.di('È giusto andare a vivere lontano dai miei '
                'genitori?')
            .situazione,
        Situazione.genitori);
    expect(
        LaDomandaLetta.di('La mia relazione può durare nonostante la '
                'distanza?')
            .situazione,
        Situazione.distanza);
    expect(LaDomandaLetta.di('Mi trasferisco lontano da qui?').situazione,
        isNot(Situazione.distanza));
  });

  test('l\'Otto di Bastoni dice un tempo, non un si\'', () {
    // *"Il si' all'offerta viene dall'Otto di Bastoni, che nella tradizione
    // dice rapidita' e notizie, non approvazione"* (tarocchi-30, quarto
    // giro). A "quando" risponde: se arriva, arriva in fretta.
    final otto = TarotDeck.cards.firstWhere((c) => c.name == 'Otto di Bastoni');
    final minori = TarotDeck.cards
        .where((c) => c.arcana == TarotArcana.minore && c.name != otto.name)
        .toList();
    final guasti = <String>[];
    var quante = 0;
    for (final (domanda, deve) in const [
      ('Devo accettare l\'offerta della nuova azienda?', false),
      ('Quando arriverà la risposta che aspetto?', true),
    ]) {
      for (var k = 0; k < 20; k++) {
        final s = TarotSpread([
          for (var i = 0; i < SpreadPosition.treCarte.length; i++)
            DrawnCard(
                card: i == 2 ? otto : minori[(i * 11 + k * 3) % minori.length],
                position: SpreadPosition.treCarte[i],
                reversed: false),
        ]);
        final r =
            TarotReading.of(s, TarotTopic.carriera, domandaScritta: domanda);
        if (!identical(r.chiave.drawn, s.cards[2])) continue;
        quante++;
        final prima = r.principale.risposta;
        final dice = prima.contains('arriva in fretta') ||
            prima.contains('arriva presto');
        final sia = RegExp(r'^(Sì|Il sì|Le carte (inclinano|propendono|vanno))')
            .hasMatch(prima);
        if (deve ? !dice : (dice || sia)) {
          guasti.add('"$domanda": $prima');
        }
      }
    }
    cardinaleMinimo(quante, 20, cosa: 'letture con l\'Otto di Bastoni chiave');
    expect(guasti, isEmpty, reason: guasti.take(4).join('\n'));
  });

  test('la singola non ripete la frase che il principale ha già detto', () {
    // *"Qui la carta indica sviluppi che possono essere rapidi, perché..."*
    // stava nella risposta principale e di nuovo nel Cosa fare della singola
    // dell'Otto di Bastoni (tarocchi-30, quarto giro).
    // PADRE: ordine GA voce GA.06, commit 9b2d2d29 (la nota lunga del ruolo
    // nelle singole dell'adesso e dell'esito).
    final otto = TarotDeck.cards.firstWhere((c) => c.name == 'Otto di Bastoni');
    final minori = TarotDeck.cards
        .where((c) => c.arcana == TarotArcana.minore && c.name != otto.name)
        .toList();
    final guasti = <String>[];
    var quante = 0;
    for (var k = 0; k < 30; k++) {
      final s = TarotSpread([
        for (var i = 0; i < SpreadPosition.treCarte.length; i++)
          DrawnCard(
              card: i == 2 ? otto : minori[(i * 11 + k * 3) % minori.length],
              position: SpreadPosition.treCarte[i],
              reversed: false),
      ]);
      final r = TarotReading.of(s, TarotTopic.carriera,
          domandaScritta: 'Devo accettare l\'offerta della nuova azienda?');
      final detta = VoceDellaStesa.rispostaDelRuolo(s.cards[2]);
      if (!r.principale.risposta.contains(detta)) continue;
      quante++;
      final fare = r.posizioni[2].responso!.cosaFare;
      if (fare.contains(detta)) guasti.add('$k: $fare');
    }
    print('ORDINE GA VOCE 06: singole della carta chiave $quante, con la '
        'frase del principale ${guasti.length}');
    cardinaleMinimo(quante, 5, cosa: 'singole che ripetono il principale');
    expect(guasti, isEmpty, reason: guasti.take(4).join('\n'));
  });

  test('gli Amanti sono plurale in ogni posizione', () {
    final guasti = <String>[];
    var guardati = 0;
    final errato = RegExp(r'la carta (indicano|mostrano|segnalano|chiedono|'
        r'portano|invitano|descrivono|ricordano|offrono|aprono|raccontano)');
    final amanti = TarotDeck.cards.firstWhere((c) => c.name == 'Gli Amanti');
    final minori =
        TarotDeck.cards.where((c) => c.arcana == TarotArcana.minore).toList();
    for (final tipo in TarotSpreadType.values) {
      final posti = tipo.posizioni;
      for (var k = 0; k < posti.length; k++) {
        final s = TarotSpread([
          for (var i = 0; i < posti.length; i++)
            DrawnCard(
                card: i == k ? amanti : minori[(i * 7 + k) % minori.length],
                position: posti[i],
                reversed: false),
        ]);
        for (final domanda in const [
          'Devo dirle che sono innamorato di lei?',
          'Come posso ritrovare l\'intesa con mio marito?',
          'Che cosa mi aspetta?',
        ]) {
          final r = TarotReading.of(s, TarotTopic.momentoCheVivo,
              domandaScritta: domanda);
          guardati++;
          for (final t in [
            r.principale.risposta,
            r.principale.cosaFare,
            for (final p in r.posizioni) p.responso!.cosaFare,
          ]) {
            if (errato.hasMatch(t)) guasti.add('"$domanda": $t');
          }
        }
      }
    }
    print('ORDINE GA VOCE 06: letture con Gli Amanti $guardati, con '
        'l\'accordo sbagliato ${guasti.length}');
    cardinaleMinimo(guardati, 40, cosa: 'letture con Gli Amanti');
    expect(guasti, isEmpty, reason: guasti.take(6).join('\n'));
  });
}

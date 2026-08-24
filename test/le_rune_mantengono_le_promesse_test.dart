import 'dart:io';

import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/rune_presage.dart';
import 'package:flutter_test/flutter_test.dart';

/// LE RUNE MANTENGONO LE PROMESSE. Ordine BF voce 05.a.
///
/// Cinque lavori concordati col fondatore e mai eseguiti, piu' la coda che
/// lui ha aggiunto a ordine in corso (la domanda scritta a mano ignorata dal
/// ripiego). Le pillole che restano dopo il getto hanno la loro prova in
/// `dopo_il_responso_niente_scelte_test.dart`, rovesciata con dichiarazione;
/// qui vivono le altre guardie.
void main() {
  final schermata = File('lib/features/maestri/caligo/rune/rune_draw_screen.dart')
      .readAsStringSync();

  test('a1: il pozzo segue la gettata, niente telo vuoto sotto le pietre', () {
    expect(schermata.contains("'odino' => 190.0"), isTrue,
        reason: 'la runa di Odino sta a meta\' altezza: un pozzo da 300 punti '
            'le lascia sotto un telo vuoto da centocinquanta');
    expect(schermata.contains("'norne' => 200.0"), isTrue,
        reason: 'la riga delle Norne sta a meta\' altezza: il pozzo da 300 '
            'punti e\' tornato uguale per tutte le gettate');
  });

  test('a3: la scheda della runa porta la descrizione del simbolo', () {
    // La promessa di S.20: la risposta si accorcia E la descrizione vive
    // nella scheda. La seconda meta' non era mai stata mantenuta, e il
    // fondatore leggeva i responsi come tagliati a meta'.
    expect(schermata.contains('rune_meaning_'), isTrue,
        reason: 'la descrizione del simbolo (meaning) e\' sparita dalla '
            'scheda della runa: la promessa di S.20 e\' di nuovo rotta');
  });

  test('a5: il sigillo del giorno ha una sola asta condivisa', () {
    final pittore =
        File('lib/features/maestri/caligo/rune/bindrune.dart')
            .readAsStringSync();
    expect(pittore.contains('_paintSovrapposto(canvas, size)'), isFalse,
        reason: 'la sovrapposizione dei glifi interi e\' tornata: il sigillo '
            'porta di nuovo due o tre aste invece dello stelo condiviso');
    expect(pittore.contains('_paintStelo(canvas, size);'), isTrue,
        reason: 'il sigillo non passa piu\' dallo stelo condiviso');
  });

  test('a6: il ripiego non dice "Non hai chiesto niente" a chi ha scritto',
      () {
    final esito = RuneCast.getta(gettataOdino);
    final conDomanda = RunePresagio.componiIlResponso(esito,
        domanda: 'Riuscirò a chiudere il progetto?');
    expect(conDomanda.risposta.contains('Non hai chiesto niente'), isFalse,
        reason: 'a una domanda scritta con parole della persona il ripiego '
            'risponde negando che sia stata posta');
    expect(conDomanda.cosaPuoiFare.contains('domani la domanda ce l'), isFalse,
        reason: 'la chiusura della giornata dice che la domanda arrivera\' '
            'domani, ma e\' stata posta oggi');
    // Le letture per posizione restano: il corpus parla comunque.
    expect(conDomanda.risposta.trim(), isNotEmpty);

    // E per chi davvero non chiede, la diciassettesima cornice resta sua.
    final senzaDomanda = RunePresagio.componiIlResponso(esito);
    expect(senzaDomanda.risposta.contains('Non hai chiesto niente'), isTrue,
        reason: 'la cornice della giornata deve restare per chi non ha '
            'chiesto: toglierla a tutti sarebbe un altro difetto');
  });
}

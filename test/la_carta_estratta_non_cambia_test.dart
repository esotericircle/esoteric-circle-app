import 'package:esoteric_circle/core/tarot/stesa_in_corso.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA CARTA ESTRATTA NON CAMBIA MAI PIU', ordine P voce 04.
///
/// Tre prove, e sono tre perche' una sola lascia passare la condizione scritta
/// al contrario: chi chiudesse il difetto congelando ANCHE il mescolamento
/// avrebbe una carta stabile e un mazzo morto, cioe' un secondo difetto al
/// posto del primo.
void main() {
  List<int> mazzoDiProva() =>
      List<int>.generate(TarotDeck.cards.length, (i) => i);

  test('1. la carta assegnata resta quella dopo una mischia', () {
    var stesa = StesaInCorso.nuova(mazzo: mazzoDiProva(), seme: 7);
    // Ordine BN voce 02: la posizione dell'arco si dichiara, non si sottintende.
    stesa = stesa.assegna(SpreadPosition.passato, dalVentaglio: 0);
    final scelta = stesa.assegnate[0]!;

    stesa = stesa.mischia(seme: 99);

    expect(stesa.assegnate[0]!.card.name, scelta.card.name,
        reason: 'dopo la mischia nella posizione del Passato c\'e\' una carta '
            'diversa: e\' il difetto degli scatti delle 03:13 e 03:14, dove La '
            'Papessa diventava Re di Coppe rovesciato');
    expect(stesa.assegnate[0]!.reversed, scelta.reversed,
        reason: 'la carta e\' la stessa ma ha cambiato verso, e per chi legge '
            'e\' un\'altra carta');
  });

  test('2. con zero carte estratte la mischia cambia davvero il mazzo', () {
    final stesa = StesaInCorso.nuova(mazzo: mazzoDiProva(), seme: 7);
    final prima = List<int>.of(stesa.mazzoResiduo);

    final dopo = stesa.mischia(seme: 12345).mazzoResiduo;

    expect(dopo, isNot(equals(prima)),
        reason: 'il mazzo non si e\' mosso: chiudere il difetto della carta '
            'che cambia congelando anche il mescolamento sostituisce un '
            'difetto con un altro, e il gesto di mischiare torna a essere '
            'una bella animazione sopra un mazzo immobile');
    expect(dopo.toSet(), prima.toSet(),
        reason: 'la mischia ha perso o duplicato delle carte');
  });

  test('3. con zero carte estratte il taglio cambia davvero il mazzo', () {
    final stesa = StesaInCorso.nuova(mazzo: mazzoDiProva(), seme: 7);
    final prima = List<int>.of(stesa.mazzoResiduo);

    final dopo = stesa.taglia(31).mazzoResiduo;

    expect(dopo, isNot(equals(prima)),
        reason: 'il taglio non ha spostato niente');
    expect(dopo.first, prima[31],
        reason: 'il taglio non porta sopra la meta\' che stava sotto');
    expect(dopo.toSet(), prima.toSet());
  });

  test('mischia e taglio non toccano nessuna delle carte gia\' uscite', () {
    var stesa = StesaInCorso.nuova(mazzo: mazzoDiProva(), seme: 3);
    for (var i = 0; i < SpreadPosition.values.length; i++) {
      stesa = stesa.assegna(SpreadPosition.values[i], dalVentaglio: i);
    }
    final scelte = [for (final c in stesa.assegnate) c!.card.name];

    stesa = stesa.mischia(seme: 1).taglia(9).mischia(seme: 2).taglia(40);

    expect([for (final c in stesa.assegnate) c!.card.name], scelte,
        reason: 'quattro gesti hanno cambiato la stesa: la stesa non si tocca, '
            'si tocca solo il mazzo residuo');
  });

  test('una carta uscita esce dal mazzo e non puo\' ripresentarsi', () {
    var stesa = StesaInCorso.nuova(mazzo: mazzoDiProva(), seme: 5);
    final quante = stesa.mazzoResiduo.length;
    stesa = stesa.assegna(SpreadPosition.passato, dalVentaglio: 0);
    final uscita = stesa.assegnate[0]!.card.name;

    expect(stesa.mazzoResiduo, hasLength(quante - 1));
    expect(stesa.mazzoResiduo.map((i) => TarotDeck.cards[i].name),
        isNot(contains(uscita)),
        reason: 'la carta uscita e\' ancora nel mazzo, quindi puo\' uscire '
            'una seconda volta nella stessa stesa');
  });

  test('riassegnare una posizione gia\' piena non fa niente', () {
    var stesa = StesaInCorso.nuova(mazzo: mazzoDiProva(), seme: 11);
    stesa = stesa.assegna(SpreadPosition.presente, dalVentaglio: 0);
    final scelta = stesa.assegnate[1]!.card.name;
    // La stessa posizione della STESA, da un'altra posizione dell'arco: e' la
    // stesa a dover restare, non l'arco.
    stesa = stesa.assegna(SpreadPosition.presente, dalVentaglio: 5);
    expect(stesa.assegnate[1]!.card.name, scelta,
        reason: 'una posizione gia\' scelta si e\' lasciata riscrivere: e\' la '
            'stessa cosa che riestrarre la carta');
  });
}

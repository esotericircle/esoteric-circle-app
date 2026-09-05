import 'package:esoteric_circle/core/tarot/stesa_in_corso.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA CARTA CHE ESCE E' QUELLA TOCCATA. Ordine BN voce 02.
///
/// Parole del fondatore: "quando l'utente fa click su una carta, deve essere
/// quella carta ad essere estratta, quella corrispondente a dove il dito ha
/// fatto tap".
///
/// **E' il difetto piu' grave dell'ordine perche' tocca il patto con chi
/// consulta**: se scelgo io e ne esce un'altra, la stesa non e' mia.
///
/// Il difetto misurato: il ventaglio mostra settantotto posizioni fisse e
/// passava l'indice della posizione come indice del mazzo RESIDUO, che si
/// accorcia a ogni carta e si riordina a ogni mischia. Alla seconda estrazione
/// la posizione 77 non esisteva piu' nel residuo, e il codice ripiegava sulla
/// PRIMA carta del mazzo.
void main() {
  test(
      'cento estrazioni, con mischie e tagli in mezzo, escono sempre quelle '
      'toccate', () {
    var falliteInSilenzio = 0;
    for (var giro = 0; giro < 100; giro++) {
      final mazzo = TarotSpread.mazzoMescolato(seed: giro);
      var stesa = StesaInCorso.nuova(mazzo: mazzo, seme: giro);

      for (var n = 0; n < SpreadPosition.values.length; n++) {
        // Fra una carta e l'altra si mescola e si taglia, che e' il momento in
        // cui prima la corrispondenza si rompeva senza dirlo.
        if (n > 0) {
          stesa = stesa.mischia(seme: giro * 7 + n);
          stesa = stesa.taglia((giro * 13 + n * 5) % 70 + 3);
        }

        // La posizione toccata: si sceglie fra quelle ancora libere, e si
        // guarda ALTA nell'arco apposta, perche' e' li' che il ripiego su zero
        // scattava.
        final libere = [
          for (var i = 0; i < stesa.mazzoDisposto.length; i++)
            if (stesa.mazzoDisposto[i] != null) i,
        ];
        final toccata = libere[(giro * 17 + n * 29) % libere.length];

        // QUALE CARTA STA SOTTO IL DITO, letta PRIMA di assegnare.
        final attesa = TarotDeck.cards[stesa.mazzoDisposto[toccata]!];

        stesa = stesa.assegna(SpreadPosition.values[n], dalVentaglio: toccata);
        final uscita = stesa.assegnate[n];

        if (uscita == null) {
          falliteInSilenzio++;
          continue;
        }
        expect(uscita.card.stem, attesa.stem,
            reason: 'giro $giro, carta ${n + 1}: sotto il dito c\'era '
                '"${attesa.stem}" e ne e\' uscita "${uscita.card.stem}". '
                'Se scelgo io e ne esce un\'altra, la stesa non e\' mia');
        // E la posizione toccata resta vuota: nessun indice slitta.
        expect(stesa.mazzoDisposto[toccata], isNull);
      }
    }
    expect(falliteInSilenzio, 0,
        reason: 'in $falliteInSilenzio casi non e\' uscita nessuna carta');
  });

  test('una posizione gia\' presa non da\' niente, e non ripiega su zero', () {
    final mazzo = TarotSpread.mazzoMescolato(seed: 3);
    var stesa = StesaInCorso.nuova(mazzo: mazzo, seme: 3);
    final prima = TarotDeck.cards[stesa.mazzoDisposto[10]!];
    stesa = stesa.assegna(SpreadPosition.values[0], dalVentaglio: 10);
    expect(stesa.assegnate[0]!.card.stem, prima.stem);

    // La stessa posizione, di nuovo: e' vuota.
    final dopo = stesa.assegna(SpreadPosition.values[1], dalVentaglio: 10);
    expect(dopo.assegnate[1], isNull,
        reason: 'una posizione gia\' presa deve restare senza risposta: '
            'ripiegare sulla prima carta del mazzo vorrebbe dire dare a chi '
            'tocca una carta che non ha scelto');
  });

  test('oltre l\'arco non esce niente', () {
    final mazzo = TarotSpread.mazzoMescolato(seed: 5);
    final stesa = StesaInCorso.nuova(mazzo: mazzo, seme: 5);
    for (final fuori in [-1, mazzo.length, mazzo.length + 40]) {
      expect(
          stesa
              .assegna(SpreadPosition.values[0], dalVentaglio: fuori)
              .assegnate[0],
          isNull,
          reason: 'la posizione $fuori non esiste nell\'arco: prima qui si '
              'ripiegava sulla prima carta del mazzo');
    }
  });

  test('mischia e taglio riordinano SOTTO le posizioni, senza riempirle', () {
    final mazzo = TarotSpread.mazzoMescolato(seed: 9);
    var stesa = StesaInCorso.nuova(mazzo: mazzo, seme: 9);
    stesa = stesa.assegna(SpreadPosition.values[0], dalVentaglio: 4);
    expect(stesa.mazzoDisposto[4], isNull);

    final lunghezzaPrima = stesa.mazzoDisposto.length;
    final residuoPrima = stesa.mazzoResiduo.toSet();

    stesa = stesa.mischia(seme: 42).taglia(31);

    expect(stesa.mazzoDisposto.length, lunghezzaPrima,
        reason: 'l\'arco non si accorcia mentre lo si sfoglia: sono le sue '
            'posizioni, e restano');
    expect(stesa.mazzoDisposto[4], isNull,
        reason: 'una posizione gia'
            ' presa non si riempie mescolando: quella '
            'carta e\' sul tavolo');
    expect(stesa.mazzoResiduo.toSet(), residuoPrima,
        reason: 'mischia e taglio non aggiungono ne\' tolgono carte, le '
            'riordinano soltanto');
    // E riordinano davvero: con settantasette carte e' pressoche' impossibile
    // che l'ordine resti identico.
    expect(stesa.mazzoResiduo, isNot(residuoPrima.toList()));
  });
}

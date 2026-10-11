// LE STESE DEL CERCHIO. Ordine FI voci 01, 02, 04 e 05, 10 ottobre 2026.
//
// Cinque stese, ognuna con le sue posizioni nell'ordine di lettura e il suo
// posto sul tavolo per ogni carta; diciassette posizioni, delle quali le
// prime tre sono quelle della stesa a tre carte e non cambiano. La croce di
// Dora e' una croce (la prima in basso, poi sinistra, destra, l'ultima in
// alto) e la Croce Celtica e' la figura di Waite, con la seconda carta di
// traverso sulla prima e il bastone a destra dal basso in alto.

import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cinque stese con le posizioni dell\'ordine', () {
    const atteso = {
      TarotSpreadType.unaCarta: [SpreadPosition.cartaSola],
      TarotSpreadType.treCarte: [
        SpreadPosition.passato,
        SpreadPosition.presente,
        SpreadPosition.futuro,
      ],
      TarotSpreadType.croceQuattro: [
        SpreadPosition.consultante,
        SpreadPosition.lato,
        SpreadPosition.lato,
        SpreadPosition.esito,
      ],
      // LAPIDE: il ferro di cavallo a sette carte, tolto dall'ordine FJ,
      // aggiunta 2 (nessuna fonte per le sue sette posizioni).
      TarotSpreadType.dieciCarte: [
        SpreadPosition.copre,
        SpreadPosition.attraversa,
        SpreadPosition.corona,
        SpreadPosition.sotto,
        // Il dietro ha la sua posizione dall'ordine FK voce 8.
        SpreadPosition.dietro,
        SpreadPosition.futuro,
        SpreadPosition.seStesso,
        SpreadPosition.laCasa,
        SpreadPosition.speranzeOTimori,
        SpreadPosition.esito,
      ],
    };
    expect(TarotSpreadType.values.length, 4);
    for (final t in TarotSpreadType.values) {
      expect(t.posizioni, atteso[t], reason: t.name);
      expect(t.tavolo.length, t.posizioni.length, reason: t.name);
      expect(t.fonte, isNotEmpty, reason: t.name);
    }
    expect([for (final t in TarotSpreadType.values) t.carte], [1, 3, 4, 10]);
    expect(TarotSpreadType.croceQuattro.descrizione, 'La croce');
    expect(TarotSpreadType.unaCarta.descrizione, 'La carta sola');
    expect(TarotSpreadType.dieciCarte.descrizione, 'La Croce Celtica');
  });

  test('la stesa a tre carte resta quella di prima', () {
    const t = TarotSpreadType.treCarte;
    expect(t.nome, 'Stesa di Tarocchi');
    expect(t.descrizione, 'Passato, Presente, Futuro');
    expect(t.disponibile, isTrue);
    expect(SpreadPosition.treCarte, [
      SpreadPosition.passato,
      SpreadPosition.presente,
      SpreadPosition.futuro
    ]);
    expect([for (final p in SpreadPosition.treCarte) p.label],
        ['Passato', 'Presente', 'Futuro']);
    // Le due vie del pescaggio danno le tre posizioni nell'ordine: dalMazzo
    // e' quella della schermata, e prima dell'ordine FI nessuna prova la
    // guardava.
    final mazzo = List<int>.generate(78, (i) => i);
    expect([for (final c in TarotSpread.dalMazzo(mazzo).cards) c.position],
        SpreadPosition.treCarte);
    expect([for (final c in TarotSpread.draw(seed: 7).cards) c.position],
        SpreadPosition.treCarte);
  });

  test('la croce di Dora e\' una croce', () {
    final p = TarotSpreadType.croceQuattro.tavolo;
    final consultante = p[0], sinistra = p[1], destra = p[2], esito = p[3];
    // La y cresce verso il basso: il consultante e' la piu' bassa, l'esito
    // la piu' alta, i due lati alla stessa altezza ai due lati.
    expect(consultante.y, greaterThan(sinistra.y));
    expect(esito.y, lessThan(sinistra.y));
    expect(sinistra.y, destra.y);
    expect(sinistra.x, lessThan(0));
    expect(destra.x, greaterThan(0));
    expect(consultante.x, 0);
    expect(esito.x, 0);
  });

  test('la Croce Celtica e\' la figura di Waite', () {
    final p = TarotSpreadType.dieciCarte.tavolo;
    // La seconda di traverso sulla prima, e nessun'altra di traverso.
    expect(p[1].diTraverso, isTrue);
    expect([p[1].x, p[1].y], [p[0].x, p[0].y]);
    expect([for (final q in p) q.diTraverso].where((d) => d).length, 1);
    // La terza sopra, la quarta sotto, la quinta dietro (a sinistra), la
    // sesta davanti (a destra).
    expect(p[2].y, lessThan(p[0].y));
    expect(p[3].y, greaterThan(p[0].y));
    expect(p[4].x, lessThan(p[0].x));
    expect(p[5].x, greaterThan(p[0].x));
    // Il bastone: le ultime quattro in colonna a destra della croce, dal
    // basso in alto.
    final bastone = p.sublist(6);
    expect(bastone.map((q) => q.x).toSet().length, 1);
    expect(bastone.first.x, greaterThan(p[5].x));
    for (var i = 1; i < bastone.length; i++) {
      expect(bastone[i].y, lessThan(bastone[i - 1].y));
    }
  });

  // Diciassette fino all'ordine FJ, aggiunta 2: consiglio, ostacolo e
  // ambiente erano del solo ferro di cavallo.
  // Quindici dall'ordine FK voce 8, con `dietro`.
  test('quindici posizioni con le etichette dell\'ordine', () {
    expect(SpreadPosition.values.length, 15);
    const etichette = {
      SpreadPosition.cartaSola: 'La carta',
      SpreadPosition.consultante: 'Il consultante',
      SpreadPosition.lato: 'Il lato',
      SpreadPosition.esito: "L'esito",
      SpreadPosition.copre: 'Ciò che copre',
      SpreadPosition.attraversa: 'Ciò che attraversa',
      SpreadPosition.corona: 'Ciò che corona',
      SpreadPosition.sotto: 'Il fondamento',
      SpreadPosition.dietro: 'Ciò che è dietro',
      SpreadPosition.laCasa: 'La tua casa',
      SpreadPosition.speranzeOTimori: 'Speranze o timori',
    };
    etichette.forEach((p, e) => expect(p.etichetta, e, reason: p.name));
  });

  test('"Te stesso" passa dalla marca del genere', () {
    String forma(CourtesyForm f) =>
        LaMarcaDelGenere.risolvi(SpreadPosition.seStesso.label, forma: f);
    expect(SpreadPosition.seStesso.label, contains('['));
    expect(forma(CourtesyForm.masculine), 'Te stesso');
    expect(forma(CourtesyForm.feminine), 'Te stessa');
    expect(forma(CourtesyForm.neutral), 'Tu');
    for (final f in CourtesyForm.values) {
      expect(forma(f), isNot(contains('[')), reason: f.name);
    }
  });
}

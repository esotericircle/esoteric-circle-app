import 'package:esoteric_circle/core/entitlement/listino_degli_eos.dart';
import 'package:esoteric_circle/core/entitlement/strade_dello_sblocco.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL GATING ONESTO A DUE STRADE. Ordine AN voce 06.
///
/// Ogni funzione bloccata dice COME si sblocca, mai un lucchetto muto. Un
/// extra a consumo mostra il costo in Eos; una funzione di relazione
/// continuativa mostra SOLO l'abbonamento, perche' gli Eos non la comprano
/// mai; dove esistono tutte e due le strade si mostrano tutte e due. Il
/// Coming soon non si mescola col Premium: li' non c'e' niente da comprare.
void main() {
  test('un extra a consumo mostra gli Eos e anche l\'abbonamento', () {
    for (final voce in ListinoDegliEos.tutte) {
      final strade = StradeDelloSblocco.per(voce.id);
      expect(strade, contains(StradaDelloSblocco.eos),
          reason: '${voce.nome} si compra a Eos ma la strada non si mostra: '
              'sarebbe nascondere la via piu\' breve');
      expect(strade, contains(StradaDelloSblocco.abbonamento),
          reason: '${voce.nome} e\' inclusa nei piani e la strada non si '
              'mostra: chi la compra ogni volta non saprebbe che puo\' '
              'smettere');
      expect(strade.first, StradaDelloSblocco.eos,
          reason: 'la strada di oggi viene prima di quella del mese');
    }
    // ignore: avoid_print
    print('ORDINE AN VOCE 06: arti a consumo con due strade '
        '${ListinoDegliEos.tutte.length}');
  });

  test('cio\' che gli Eos non comprano mostra SOLO l\'abbonamento', () {
    expect(StradeDelloSblocco.soloAbbonamento, isNotEmpty,
        reason: 'l\'elenco di cio\' che gli Eos non comprano e\' vuoto: '
            'senza, ogni funzione sembrerebbe acquistabile');
    for (final funzione in StradeDelloSblocco.soloAbbonamento) {
      final strade = StradeDelloSblocco.per(funzione);
      expect(strade, [StradaDelloSblocco.abbonamento],
          reason: '$funzione mostra una strada in Eos: e\' accesso '
              'continuativo o memoria, e gli Eos non la comprano mai');
      expect(ListinoDegliEos.perArte(funzione), isNull,
          reason: '$funzione ha un prezzo nel listino: le due regole si '
              'contraddicono');
    }
    // ignore: avoid_print
    print('ORDINE AN VOCE 06: funzioni di solo abbonamento '
        '${StradeDelloSblocco.soloAbbonamento.length}');
  });

  test('il Coming soon non si mescola col Premium', () {
    final strade =
        StradeDelloSblocco.per('qualcosa_che_arrivera', inArrivo: true);
    expect(strade, [StradaDelloSblocco.comingSoon],
        reason: 'una funzione in arrivo mostra una strada per comprarla: '
            'li\' non c\'e\' niente da comprare, c\'e\' da aspettare');
    expect(StradeDelloSblocco.rigaDi(StradaDelloSblocco.comingSoon),
        isNot(contains('Eos')),
        reason: 'la riga del Coming soon nomina gli Eos');
  });

  test('ogni strada porta la sua riga, e la riga degli Eos porta il costo', () {
    var lette = 0;
    for (final strada in StradaDelloSblocco.values) {
      final riga = StradeDelloSblocco.rigaDi(strada,
          voce: ListinoDegliEos.stesaTreCarte);
      lette++;
      expect(riga.trim(), isNotEmpty,
          reason: 'la strada $strada non ha niente da dire: e\' il lucchetto '
              'muto');
    }
    expect(lette, StradaDelloSblocco.values.length);
    expect(
        StradeDelloSblocco.rigaDi(StradaDelloSblocco.eos,
            voce: ListinoDegliEos.stesaTreCarte),
        contains('120 Eos'),
        reason: 'la strada degli Eos non dice quanto costa');
    // ignore: avoid_print
    print('ORDINE AN VOCE 06: righe delle strade lette $lette');
  });
}

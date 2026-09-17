import 'dart:math';

import 'package:esoteric_circle/core/rituals/arcano_dell_alba/sacchetto_dell_alba.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL SACCHETTO DELL'ARCANO DELL'ALBA.** Ordine DT voce 05.
///
/// Quarantaquattro stati senza reimbussolamento, ogni stato una volta per
/// ciclo, il ciclo lungo quarantaquattro giorni, e la stessa carta mai prima
/// di undici estrazioni dalla sua ultima uscita, anche a cavallo fra due
/// cicli. Si misura su molti cicli e molti semi, non su un giro fortunato.
void main() {
  test('i numeri vengono dalle carte: 22, 44, 11', () {
    expect(SacchettoDellAlba.carte, 22);
    expect(SacchettoDellAlba.stati, 44);
    expect(SacchettoDellAlba.distanzaMinima, 11);
  });

  test(
      'ogni ciclo porta tutti gli stati una volta sola, e la carta non torna '
      'prima di undici estrazioni, anche fra un ciclo e l\'altro', () {
    const semi = 120, cicli = 6;
    var vicoli = 0;
    for (var seme = 0; seme < semi; seme++) {
      final caso = Random(seme);
      var sacchetto = SacchettoDellAlba.nuovo();
      final uscite = <StatoDellAlba>[];
      for (var giorno = 0; giorno < SacchettoDellAlba.stati * cicli; giorno++) {
        final cicloPrima =
            sacchetto.rimasti.isEmpty ? sacchetto.ciclo + 1 : sacchetto.ciclo;
        final e = sacchetto.estrai(caso);
        if (e.dopo.ciclo != cicloPrima) vicoli++;
        sacchetto = e.dopo;
        uscite.add(e.stato);
      }
      for (var c = 0; c < cicli; c++) {
        final ciclo = uscite.sublist(
            c * SacchettoDellAlba.stati, (c + 1) * SacchettoDellAlba.stati);
        expect(ciclo.map((s) => s.id).toSet(), hasLength(44),
            reason: 'seme $seme, ciclo ${c + 1}: uno stato manca o si ripete');
      }
      final ultima = <int, int>{};
      for (var i = 0; i < uscite.length; i++) {
        final prima = ultima[uscite[i].carta];
        if (prima != null) {
          expect(i - prima, greaterThanOrEqualTo(11),
              reason: 'seme $seme: la carta ${uscite[i].carta} torna dopo '
                  '${i - prima} estrazioni, al giorno $i');
        }
        ultima[uscite[i].carta] = i;
      }
    }
    expect(vicoli, 0,
        reason: 'il sacchetto ha dovuto ricomporre un ciclo a meta: la scelta '
            'componibile ha lasciato un vicolo');
  });

  test(
      'il verso non segue la carta: diritte e rovesce si alternano senza '
      'regola', () {
    final caso = Random(7);
    var sacchetto = SacchettoDellAlba.nuovo();
    var primaRovescia = 0;
    for (var ciclo = 0; ciclo < 200; ciclo++) {
      final visti = <int>{};
      for (var i = 0; i < SacchettoDellAlba.stati; i++) {
        final e = sacchetto.estrai(caso);
        sacchetto = e.dopo;
        if (visti.add(e.stato.carta) && e.stato.rovescio) primaRovescia++;
      }
    }
    final quota = primaRovescia / (200 * 22);
    expect(quota, inInclusiveRange(0.45, 0.55),
        reason: 'la prima uscita di una carta e rovescia nel '
            '${(quota * 100).round()} per cento dei casi');
  });

  test('il sacchetto sopravvive alla chiusura: salvato e riletto e lo stesso',
      () {
    final caso = Random(3);
    var sacchetto = SacchettoDellAlba.nuovo();
    for (var i = 0; i < 50; i++) {
      sacchetto = sacchetto.estrai(caso).dopo;
    }
    final riletto = SacchettoDellAlba.daJson(sacchetto.toJson());
    expect(riletto.rimasti, sacchetto.rimasti);
    expect(riletto.ultimeCarte, sacchetto.ultimeCarte);
    expect(riletto.ciclo, sacchetto.ciclo);
  });

  group('vuoto o corrotto si ricompone, e non blocca mai', () {
    for (final (nome, dati) in <(String, Object?)>[
      ('nulla', null),
      ('una stringa', 'sacchetto'),
      (
        'un id fuori dagli stati',
        {
          'rimasti': [44],
          'ultimeCarte': [],
          'ciclo': 1
        }
      ),
      (
        'un doppione',
        {
          'rimasti': [3, 3],
          'ultimeCarte': [],
          'ciclo': 1
        }
      ),
      (
        'una carta che non esiste',
        {
          'rimasti': [1],
          'ultimeCarte': [22],
          'ciclo': 1
        }
      ),
      (
        'un campo mancante',
        {
          'rimasti': [1, 2]
        }
      ),
      (
        'un ciclo a zero',
        {
          'rimasti': [1],
          'ultimeCarte': [],
          'ciclo': 0
        }
      ),
    ]) {
      test(nome, () {
        final sacchetto = SacchettoDellAlba.daJson(dati);
        expect(sacchetto.rimasti, hasLength(44));
        expect(sacchetto.estrai(Random(1)).stato.id, inInclusiveRange(0, 43));
      });
    }

    test('vuoto: il ciclo successivo parte da se', () {
      final vuoto = SacchettoDellAlba.daJson(
          {'rimasti': <int>[], 'ultimeCarte': <int>[], 'ciclo': 4});
      final e = vuoto.estrai(Random(1));
      expect(e.dopo.ciclo, 5);
      expect(e.dopo.rimasti, hasLength(43));
    });

    test('leggibile ma senza scelte componibili: si ricompone e non si ferma',
        () {
      // La carta 0 nei due versi e nient'altro, con la carta 0 appena uscita:
      // nessuna estrazione rispetta la distanza.
      final impossibile = SacchettoDellAlba.daJson({
        'rimasti': [0, 1],
        'ultimeCarte': [0],
        'ciclo': 2
      });
      final e = impossibile.estrai(Random(1));
      expect(e.stato.carta, isNot(0));
      expect(e.dopo.ciclo, 3);
    });
  });
}

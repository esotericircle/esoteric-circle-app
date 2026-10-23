import 'package:esoteric_circle/core/rituals/carta_di_nascita_dei_tarocchi.dart';
import 'package:esoteric_circle/features/onboarding/rivelazione_carta_di_nascita.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL VELO SI SPEGNE A CARTA SCOPERTA.** Ordine FN, 13 ottobre 2026.
///
/// Il fondatore ha visto, nella schermata "La tua Carta di Nascita", un
/// riquadro NERO dietro la carta rivelata. Causa: `velo()` dipendeva solo
/// da `avanzata()`, che resta a uno per sempre dopo che la carta e' arrivata
/// in posizione, quindi il velo restava fisso al 75% anche a carta scoperta
/// e ferma, e i suoi angoli arrotondati lasciavano intravedere il
/// rettangolo nero sotto.
void main() {
  final nascita = DateTime(1990, 5, 12);
  final passi = CartaDiNascitaDeiTarocchi.passiDi(nascita);
  final carta = CartaDiNascitaDeiTarocchi.cartaDi(nascita);

  RegiaDellaRivelazione regiaA(double t) =>
      RegiaDellaRivelazione(passi: passi, carta: carta, t: t);

  test('il velo e\' zero quando la carta e\' scoperta e ferma', () {
    // t = 1.0: fine della rivelazione, carta avanzata e girata del tutto.
    final regia = regiaA(1.0);
    expect(regia.avanzata(), 1.0, reason: 'la carta deve essere avanzata');
    expect(regia.girata(), 1.0, reason: 'la carta deve essere scoperta');
    expect(regia.velo(), 0.0,
        reason: 'a carta scoperta e ferma non deve restare niente di nero '
            'dietro di lei: velo() e\' ${regia.velo()}');
  });

  test('il velo cala mentre la carta si gira, non resta fisso', () {
    // Dentro il quinto momento (fra 0,80 e 1,00): la carta e' avanzata ma
    // non ancora del tutto girata, quindi un po' di velo serve ancora.
    final regia = regiaA(0.85);
    expect(regia.avanzata(), greaterThan(0));
    expect(regia.girata(), lessThan(1.0),
        reason: 'a questo istante la carta non deve essere ancora scoperta '
            'del tutto, altrimenti la prova non misura niente');
    expect(regia.velo(), greaterThan(0),
        reason: 'mentre la carta vola in avanti il velo deve ancora esserci');
  });

  test('senza moto (Riduci Movimento) il velo non c\'e\' mai', () {
    final regia = RegiaDellaRivelazione(
        passi: passi, carta: carta, t: 1.0, senzaMoto: true);
    expect(regia.velo(), 0.0,
        reason: 'con Riduci Movimento la carta e\' gia\' ferma e scoperta '
            'dal primo fotogramma: il velo non deve mai comparire');
  });
}

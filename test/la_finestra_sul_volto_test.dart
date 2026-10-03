import 'dart:ui' show Offset, Rect;

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/live/stato_della_schermata_live.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA FINESTRA SUL VOLTO.** Ordine EG voce 05, 23 settembre 2026.
///
/// Il fondatore: *"il taglio in basso dell'avatar coinciderebbe con il bordo
/// basso del riquadro, come se fosse all'interno di una finestra. Adesso ai
/// lati dell'avatar c'e' molto troppo spazio"*. Qui si prova, Maestro per
/// Maestro, che il ritaglio del video faccia proprio questo: il bordo basso
/// sul taglio, la testa dentro, niente fuori dal quadrato del video.
void main() {
  test('OGNI MAESTRO HA LA SUA FINESTRA, COL BORDO BASSO SUL TAGLIO', () {
    cardinaleMinimo(Maestro.values.length, 3,
        cosa: 'Maestri con una finestra',
        perche: 'Sono tre i volti che Protoface anima.');
    // **LE INQUADRATURE SONO DUE, ordine EK voce 04**: quella degli avatar di
    // prima, riconosciuti dal loro identificativo, e quella quadrata degli
    // avatar nuovi, che vale senza avatar. Si guardano tutte e due.
    cardinaleMinimo(InquadraturaDelVolto.avatarDiPrima.length, 3,
        cosa: 'avatar di prima riconosciuti',
        perche: 'Senza di loro l\'inquadratura di prima non si guarderebbe.');
    final inquadrature = <String, InquadraturaDelVolto Function(Maestro)>{
      'quadrata': (m) => InquadraturaDelVolto.di(m),
      for (final a in InquadraturaDelVolto.avatarDiPrima)
        'di prima, $a': (m) => InquadraturaDelVolto.di(m, avatar: a),
    };
    for (final MapEntry(key: quale, value: di) in inquadrature.entries) {
      for (final m in Maestro.values) {
        final i = di(m);
        final r = i.ritaglio;
        // ignore: avoid_print
        print('EG.05 ${m.name}, $quale: ritaglio ${r.left.toStringAsFixed(3)} '
            '${r.top.toStringAsFixed(3)} ${r.right.toStringAsFixed(3)} '
            '${r.bottom.toStringAsFixed(3)}');
        expect(r.bottom, closeTo(i.basso, 1e-9),
            reason:
                '${m.name}: il bordo basso della finestra non e\' il taglio '
                'del busto, e sotto resterebbe una fascia vuota');
        expect(r.top, lessThanOrEqualTo(i.alto),
            reason: '${m.name}: la finestra taglia la testa');
        expect(r.left, greaterThanOrEqualTo(0));
        expect(r.top, greaterThanOrEqualTo(0));
        expect(r.right, lessThanOrEqualTo(1 + 1e-9),
            reason: '${m.name}: la finestra esce dal video');
        expect(
            r.width / r.height, closeTo(InquadraturaDelVolto.proporzione, 1e-9),
            reason:
                '${m.name}: la finestra non ha le proporzioni della cornice');
        expect((r.left + r.width / 2 - i.centro).abs(), lessThan(0.05),
            reason: '${m.name}: la testa non sta al centro della finestra');
        // **La toppa e la zona intatta stanno dentro la finestra**: lo shader
        // riceve soltanto la finestra, e una zona che ne esce non tocca niente.
        for (final zona in [i.toppa, i.intatto]) {
          if (zona == null) continue;
          expect(
              r.contains(zona.topLeft) &&
                  r.contains(zona.bottomRight - const Offset(1e-9, 1e-9)),
              isTrue,
              reason:
                  '${m.name}, $quale: la zona $zona esce dalla finestra $r');
        }
      }
      // Le due zone dichiarate, contate: senza, la prova sopra non guarda niente.
      final zone = [
        for (final m in Maestro.values) ...[di(m).toppa, di(m).intatto]
      ].whereType<Rect>().length;
      cardinaleMinimo(zone, 2,
          cosa: 'zone dichiarate nella finestra $quale',
          perche: 'La toppa di Medora e il cristallo di Caligo.');
    }
  });

  test('IL SILENZIO CHIUDE A TRENTA SECONDI, E SOLO QUANDO SI E\' VIVI', () {
    const vivo =
        QuadroDelLive(momento: MomentoDelLive.vivo, maestro: Maestro.medora);
    expect(vivo.chiudePerSilenzio(29), isFalse);
    expect(vivo.chiudePerSilenzio(30), isTrue);
    const inArrivo = QuadroDelLive(
        momento: MomentoDelLive.siAspettaIlVolto, maestro: Maestro.medora);
    expect(inArrivo.chiudePerSilenzio(60), isFalse,
        reason: 'mentre il volto arriva non e\' silenzio della persona');
    expect(vivo.con(fine: ComeFinisce.silenzio).laFraseDellaFine(),
        contains('trenta secondi'));
    expect(vivo.con(fine: ComeFinisce.tempo).laFraseDellaFine(),
        isNot(contains('trenta secondi')));
  });

  test('IL TEMPO DELLA TRASCRIZIONE NON E\' SILENZIO', () {
    // **Ordine EK, 24 settembre 2026, sul Realme.** La persona parla 28
    // secondi dopo il saluto, per otto secondi; la frase si chiude dopo due
    // secondi di silenzio vero e si trascrive in un secondo e mezzo. Con
    // l'orologio di prima quei secondi contavano: a 30 il LIVE si chiudeva
    // prima che la domanda tornasse scritta, e la domanda si perdeva.
    bool unSecondo(
            {bool maestro = false,
            bool pensa = false,
            bool persona = false,
            int frasi = 0}) =>
        QuadroDelLive.eUnSecondoDiSilenzio(
            parlaIlMaestro: maestro,
            pensaIlMaestro: pensa,
            parlaLaPersona: persona,
            frasiInTrascrizione: frasi);
    expect(unSecondo(), isTrue,
        reason: 'nessuno fa niente: se questo non e\' silenzio, la prova sotto '
            'non dimostra niente');
    expect(unSecondo(maestro: true), isFalse);
    expect(unSecondo(pensa: true), isFalse);
    expect(unSecondo(persona: true), isFalse);
    expect(unSecondo(frasi: 1), isFalse,
        reason: 'una frase detta si sta trascrivendo: non e\' silenzio');

    var silenzio = 0;
    void secondi(int quanti, bool eSilenzio) {
      for (var i = 0; i < quanti; i++) {
        if (eSilenzio) silenzio++;
      }
    }

    secondi(28, unSecondo()); // il saluto e' finito, la persona esita
    secondi(10, unSecondo(persona: true)); // la frase e i due secondi dopo
    secondi(2, unSecondo(frasi: 1)); // la trascrizione
    const vivo =
        QuadroDelLive(momento: MomentoDelLive.vivo, maestro: Maestro.medora);
    expect(silenzio, 28);
    expect(vivo.chiudePerSilenzio(silenzio), isFalse,
        reason: 'il LIVE si chiude mentre la domanda della persona si sta '
            'trascrivendo, e la domanda si perde');
  });
}

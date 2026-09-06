import 'dart:math' as math;

import 'package:esoteric_circle/core/face/inclinazione_del_capo.dart';
import 'package:esoteric_circle/core/face/punti_del_volto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart';

/// **ALZARE E ABBASSARE IL CAPO NON SI SCAMBIANO.** Ordine CR voce 03, seconda
/// stesura, 6 settembre 2026.
///
/// **IL DIFETTO CHE QUESTA GUARDIA ESISTE PER PRENDERE, e che e' arrivato fino
/// al telefono del fondatore.** Parole sue: *"in basso NON FUNZIONA e ho dovuto
/// alzare il viso"*. La scansione chiedeva di guardare in basso e si compiva
/// alzando il mento.
///
/// **PERCHE' NESSUNA GUARDIA LO AVEVA PRESO.** Le guardie della scansione
/// provavano la MACCHINA DELLE POSE, cioe' che dato un pitch positivo la posa
/// "alto" avanzasse. Non provavano da nessuna parte **che un capo davvero
/// alzato producesse un pitch positivo**, perche' quel numero veniva dal
/// pacchetto e nessuno lo interrogava. Il pacchetto, per parte sua, documenta
/// `pitchDegrees` come *"Up/down head rotation in degrees"* e **non dichiara da
/// che parte cresce**: dare per buono un verso era una supposizione, ed era la
/// mia.
///
/// **COME SI PROVA UN SEGNO SENZA UN VOLTO E SENZA UNA FOTOCAMERA.** Si
/// costruisce una testa sintetica, la si ruota di un angolo NOTO attorno
/// all'asse orizzontale, e si legge cosa esce. Non serve un volto vero: serve
/// una geometria vera, e una rotazione e' geometria.
void main() {
  /// Una testa finta ma coerente: punti su una superficie curva, con la
  /// fronte in alto, il mento in basso e le guance ai lati. Le coordinate
  /// sono normalizzate come quelle della mesh.
  List<FaceMeshLandmark> testa({double alzata = 0, double profilo = 0}) {
    // Si costruisce in tre dimensioni intorno all'origine, si ruota, e si
    // riporta nel riquadro normalizzato.
    final grezzi = <int, (double, double, double)>{};

    void metti(int i, double x, double y, double z) =>
        grezzi[i] = (x, y, z);

    // Fronte in alto, mento in basso: y cresce verso il basso, come nella
    // mesh. La z e' la profondita', piu' piccola verso la fotocamera, e la
    // testa e' curva: fronte e mento stanno piu' indietro degli zigomi.
    metti(InclinazioneDelCapo.fronte, 0.0, -0.45, 0.10);
    metti(InclinazioneDelCapo.mento, 0.0, 0.45, 0.10);
    for (final i in PuntiDelVolto.guanciaSinistra) {
      metti(i, -0.35, 0.0, 0.08);
    }
    for (final i in PuntiDelVolto.guanciaDestra) {
      metti(i, 0.35, 0.0, 0.08);
    }

    // **IL SEGNO DELLA ROTAZIONE, VERIFICATO SUL MENTO E NON A OCCHIO.**
    //
    // La prima stesura di questa testa sintetica ruotava dalla parte
    // sbagliata: con `alzata` positiva il mento finiva a z maggiore,
    // cioe' PIU' LONTANO dalla fotocamera, che e' abbassare il capo, non
    // alzarlo. I moduli uscivano esatti, venticinque gradi su
    // venticinque, e i segni tutti rovesciati: era la mano della
    // rotazione, non la misura.
    //
    // Alzare il mento porta il mento VERSO la fotocamera, cioe' a z piu'
    // piccola, e girarsi verso la propria destra porta la guancia destra
    // LONTANO. Il meno serve a questo.
    final ax = -alzata * math.pi / 180;
    final ay = -profilo * math.pi / 180;
    const quanti = PuntiDelVolto.quantiPunti;
    return [
      for (var i = 0; i < quanti; i++)
        () {
          final p = grezzi[i] ?? (0.0, 0.0, 0.0);
          var (x, y, z) = p;
          // **ALZARE IL MENTO E' RUOTARE ATTORNO ALL'ASSE ORIZZONTALE.**
          // Con y verso il basso, alzare il capo porta il mento avanti,
          // cioe' verso la fotocamera, cioe' verso z piu' piccola.
          final y1 = y * math.cos(ax) - z * math.sin(ax);
          final z1 = y * math.sin(ax) + z * math.cos(ax);
          y = y1;
          z = z1;
          // Girare verso la propria destra: rotazione attorno al verticale.
          final x2 = x * math.cos(ay) + z * math.sin(ay);
          final z2 = -x * math.sin(ay) + z * math.cos(ay);
          x = x2;
          z = z2;
          return FaceMeshLandmark(x: 0.5 + x, y: 0.5 + y, z: z);
        }(),
    ];
  }

  test('a volto dritto l\'inclinazione e\' zero', () {
    expect(InclinazioneDelCapo.gradi(testa()).abs(), lessThan(1.0),
        reason: 'un volto di fronte risulta gia' ' inclinato: la scansione '
            'partirebbe con una posa mezza compiuta');
  });

  test('il mento alzato da\' gradi POSITIVI', () {
    // Il fatto che la prima stesura non provava mai.
    final g = InclinazioneDelCapo.gradi(testa(alzata: 25));
    expect(g, greaterThan(5),
        reason: 'alzando il capo di venticinque gradi la misura non sale: '
            'chi segue la richiesta «alza il mento» non compie mai la posa. '
            'Misurato: $g');
  });

  test('il mento abbassato da\' gradi NEGATIVI', () {
    final g = InclinazioneDelCapo.gradi(testa(alzata: -25));
    expect(g, lessThan(-5),
        reason: 'abbassando il capo la misura non scende: e\' esattamente il '
            'difetto che il fondatore ha trovato sul telefono, «in basso non '
            'funziona e ho dovuto alzare il viso». Misurato: $g');
  });

  test('alzato e abbassato non stanno dalla stessa parte', () {
    // **LA PRETESA PIU' IMPORTANTE DEL FILE**, e la piu' semplice: qualunque
    // convenzione si scelga, i due gesti opposti devono dare segni opposti.
    // Una misura che li mandasse dalla stessa parte renderebbe una delle due
    // pose impossibile, e sarebbe verde in ogni prova che guardi un gesto
    // solo.
    final su = InclinazioneDelCapo.gradi(testa(alzata: 20));
    final giu = InclinazioneDelCapo.gradi(testa(alzata: -20));
    expect(su * giu, lessThan(0),
        reason: 'alzare e abbassare il capo danno lo stesso segno: $su e '
            '$giu. Una delle due pose non si potra\' mai compiere');
  });

  test('l\'inclinazione cresce con l\'angolo', () {
    final poco = InclinazioneDelCapo.gradi(testa(alzata: 10));
    final tanto = InclinazioneDelCapo.gradi(testa(alzata: 30));
    expect(tanto, greaterThan(poco),
        reason: 'la misura non cresce con la rotazione: allora non e\' una '
            'misura, ma una soglia travestita');
  });

  test('girare la testa NON muove l\'inclinazione verticale', () {
    // Se i due assi si confondessero, girarsi di lato compirebbe le pose
    // verticali, e la scansione si lascerebbe superare con due movimenti
    // invece di quattro.
    final dritto = InclinazioneDelCapo.gradi(testa());
    final girato = InclinazioneDelCapo.gradi(testa(profilo: 30));
    expect((girato - dritto).abs(), lessThan(5.0),
        reason: 'girando la testa di lato cambia anche l\'inclinazione '
            'verticale: i due assi si confondono e due pose si compiono con '
            'un gesto solo. Dritto $dritto, girato $girato');
  });

  test('girare verso la propria destra da\' gradi positivi', () {
    final g = InclinazioneDelCapo.gradiDiProfilo(testa(profilo: 25));
    expect(g, greaterThan(5),
        reason: 'la rotazione a destra non sale: misurato $g');
    final s = InclinazioneDelCapo.gradiDiProfilo(testa(profilo: -25));
    expect(s, lessThan(-5),
        reason: 'la rotazione a sinistra non scende: misurato $s');
  });
}

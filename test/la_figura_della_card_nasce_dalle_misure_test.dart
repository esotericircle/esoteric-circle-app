import 'dart:io';

import 'package:esoteric_circle/core/face/face_classifier.dart';
import 'package:esoteric_circle/features/maestri/aura/face/face_constellation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA FIGURA DELLA CARD NASCE DALLE MISURE, NON DALLE CASELLE.**
/// Ordine CX, voce montata su decisione del fondatore del 9 settembre 2026.
///
/// **Il problema che questa prova sorveglia.** La card diceva *"una
/// costellazione su 104.976 possibili"*, e chi legge capisce unica. Ma
/// centomila combinazioni sono poche: **a 382 utenti e' piu' probabile che due
/// card siano identiche che il contrario**, e a 793 e' quasi certo. Basta che
/// due amici confrontino le card perche' l'effetto si rovesci in sospetto.
///
/// **La via scelta dal fondatore.** La figura non deve nascere dalle undici
/// parole, ma dalle **proporzioni misurate**: due persone possono cadere nelle
/// stesse caselle e avere numeri diversi, e se il disegno usa quelli la figura
/// e' diversa lo stesso.
///
/// **E LA VIA ERA GIA' IN PIEDI, verificato e non supposto.**
/// `FaceConstellation.da` riceve i `FaceContours`, cioe' i punti veri del
/// volto, e ne ricava le posizioni delle stelle normalizzandole: **non passa
/// mai dai tratti.** Questa prova non costruisce niente di nuovo, **mette
/// sotto guardia un fatto che nessuno stava sorvegliando**: senza di lei
/// domani qualcuno puo' far nascere la costellazione dalle caselle, la figura
/// diventa uguale per migliaia di persone, e nessuna prova se ne accorge.
///
/// **REGOLA H.** Non basta provare che due volti diversi danno figure diverse:
/// si prova anche che **lo stesso volto da' la stessa figura**. Una figura che
/// cambia a ogni scansione della stessa persona non e' unica, e' casuale, ed e'
/// il difetto opposto.
void main() {
  /// Un volto parametrico: due chiamate con numeri vicini cadono nelle stesse
  /// caselle e hanno proporzioni diverse, che e' esattamente il caso da
  /// misurare.
  FaceContours volto({required double larghezza, required double occhi}) {
    const cx = 0.5;
    const cima = 0.07;
    const fondo = 0.93;
    final ovale = <Offset>[];
    for (var i = 0; i <= 40; i++) {
      final q = i / 40;
      final y = cima + (fondo - cima) * q;
      final w = q <= 0.30
          ? larghezza * (0.55 + 1.5 * q)
          : (q <= 0.86 ? larghezza : larghezza * 0.65);
      ovale.add(Offset(cx + w / 2, y));
    }
    for (var i = 40; i >= 0; i--) {
      final q = i / 40;
      final y = cima + (fondo - cima) * q;
      final w = q <= 0.30
          ? larghezza * (0.55 + 1.5 * q)
          : (q <= 0.86 ? larghezza : larghezza * 0.65);
      ovale.add(Offset(cx - w / 2, y));
    }
    const ySop = 0.36;
    const yOcchi = 0.42;
    const yNaso = 0.63;
    const yBocca = 0.75;
    List<Offset> sopraccio(double s) => [
          for (var i = 0; i <= 6; i++)
            Offset(cx + s * (0.06 + 0.13 * i / 6), ySop - 0.02 * (i % 3)),
        ];
    List<Offset> occhio(double s) => [
          Offset(cx + s * occhi / 2 - 0.05, yOcchi),
          Offset(cx + s * occhi / 2, yOcchi - 0.02),
          Offset(cx + s * occhi / 2 + 0.05, yOcchi),
          Offset(cx + s * occhi / 2, yOcchi + 0.02),
        ];
    return FaceContours(
      volto: ovale,
      sopraccioSx: sopraccio(-1),
      sopraccioDx: sopraccio(1),
      occhioSx: occhio(-1),
      occhioDx: occhio(1),
      nasoPonte: const [Offset(cx, yOcchi), Offset(cx, yNaso)],
      nasoBase: const [
        Offset(cx - 0.05, yNaso),
        Offset(cx, yNaso + 0.01),
        Offset(cx + 0.05, yNaso),
      ],
      labbroSopra: const [
        Offset(cx - 0.10, yBocca),
        Offset(cx, yBocca - 0.02),
        Offset(cx + 0.10, yBocca),
      ],
      labbroSotto: const [
        Offset(cx - 0.10, yBocca),
        Offset(cx, yBocca + 0.02),
        Offset(cx + 0.10, yBocca),
      ],
      guanciaSx: Offset(cx - larghezza / 2, yOcchi),
      guanciaDx: Offset(cx + larghezza / 2, yOcchi),
    );
  }

  /// Quanto due costellazioni si somigliano: la distanza media fra le stelle
  /// che stanno nello stesso posto dell'elenco.
  double distanzaFra(FaceConstellation a, FaceConstellation b) {
    final quante = a.stelle.length < b.stelle.length
        ? a.stelle.length
        : b.stelle.length;
    if (quante == 0) return 0;
    var somma = 0.0;
    for (var i = 0; i < quante; i++) {
      somma += (a.stelle[i] - b.stelle[i]).distance;
    }
    return somma / quante;
  }

  test('DUE VOLTI NELLE STESSE CASELLE DANNO FIGURE DIVERSE', () {
    // Due volti scelti perche' cadano nelle stesse caselle: la larghezza
    // cambia poco, abbastanza da restare dalla stessa parte delle soglie.
    final a = volto(larghezza: 0.62, occhi: 0.32);
    final b = volto(larghezza: 0.645, occhi: 0.335);
    final letturaA = FaceClassifier.leggi(a);
    final letturaB = FaceClassifier.leggi(b);
    final trattiA = letturaA.letture.map((l) => l.tratto.name).join('|');
    final trattiB = letturaB.letture.map((l) => l.tratto.name).join('|');
    // ignore: avoid_print
    print('ORDINE CX: i due volti danno le stesse caselle: '
        '${trattiA == trattiB}');
    expect(trattiA, trattiB,
        reason: 'i due volti di questa prova NON cadono nelle stesse caselle: '
            'la prova non sta mostrando quello che crede, e andrebbero '
            'scelti due volti piu vicini');

    final costA = FaceConstellation.da(a);
    final costB = FaceConstellation.da(b);
    cardinaleMinimo(costA.stelle.length, 8,
        cosa: 'stelle nella costellazione',
        perche: 'Con poche stelle due figure si somigliano per forza, e '
            'questa prova direbbe che sono diverse per non averle guardate.');
    final distanza = distanzaFra(costA, costB);
    // ignore: avoid_print
    print('ORDINE CX: stelle ${costA.stelle.length}, distanza media fra le '
        'due figure ${distanza.toStringAsFixed(5)}');
    expect(distanza, greaterThan(0.0),
        reason: 'due persone con le stesse undici parole ricevono la STESSA '
            'identica figura: la card sarebbe uguale per tutti quelli che '
            'cadono nelle stesse caselle, e a 382 utenti succede');
  });

  test('REGOLA H: e lo STESSO volto da la stessa figura', () {
    // L'altra meta'. Una figura che cambia a ogni scansione della stessa
    // persona non e' unica, e' casuale, e non e' sua.
    final uno = FaceConstellation.da(volto(larghezza: 0.62, occhi: 0.32));
    final due = FaceConstellation.da(volto(larghezza: 0.62, occhi: 0.32));
    final distanza = distanzaFra(uno, due);
    // ignore: avoid_print
    print('ORDINE CX: lo stesso volto letto due volte, distanza fra le figure '
        '${distanza.toStringAsFixed(6)}');
    expect(distanza, 0.0,
        reason: 'lo stesso volto produce due figure diverse: la costellazione '
            'non e sua, e casuale');
  });

  test('LA COSTELLAZIONE NON PASSA DAI TRATTI, e si legge dalla firma', () {
    // **La guardia strutturale.** Oggi `FaceConstellation.da` riceve i punti
    // del volto. Se domani qualcuno le passasse una `FaceReading`, cioe' le
    // undici parole, la figura diventerebbe uguale per tutti quelli che
    // cadono nelle stesse caselle e nessuna prova sopra se ne accorgerebbe,
    // perche' due volti nelle stesse caselle darebbero davvero la stessa
    // figura e la prima prova cadrebbe soltanto DOPO che il difetto e' gia'
    // in produzione.
    final sorgente = File(
            'lib/features/maestri/aura/face/face_constellation.dart')
        .readAsStringSync();
    expect(sorgente.contains('static FaceConstellation da(FaceContours'),
        isTrue,
        reason: 'la costellazione non nasce piu dai punti del volto: se '
            'nasce dai tratti, la figura e uguale per tutti quelli che '
            'cadono nelle stesse caselle');
  });
}

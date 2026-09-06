import 'dart:io';
import 'dart:math' as math;

import 'package:esoteric_circle/core/face/face_classifier.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **DUE VOLTI DIVERSI DANNO MISURE DIVERSE, LO STESSO VOLTO SI SOMIGLIA.**
/// Ordine CR voce 05, 6 settembre 2026.
///
/// **L'ordine lo chiede per nome**: *"due volti diversi devono dare misure
/// diverse, e lo stesso volto in due scansioni deve dare misure che si
/// somigliano entro una tolleranza che dichiari"*.
///
/// **PERCHE' QUESTE DUE PRETESE INSIEME, E NON UNA SOLA.** Sono i due modi in
/// cui una lettura del volto puo' essere finta, e sono opposti:
/// - se due volti diversi danno la stessa lettura, la funzione **non guarda
///   niente** e recita un responso;
/// - se lo stesso volto da' letture diverse a ogni scansione, la funzione
///   **guarda il rumore** e il responso e' un sorteggio.
/// Una prova che ne misura una sola lascia aperta l'altra.
///
/// **IL RUMORE E' SIMULATO E DICHIARATO.** Qui non c'e' una fotocamera: la
/// seconda scansione dello stesso volto si ottiene spostando ogni punto di una
/// quantita' piccola e casuale, che e' cio' che fa il tremolio della mano e
/// l'incertezza del modello fra un fotogramma e l'altro. **Non e' la stessa
/// cosa di due scansioni vere**, e questa prova non pretende che lo sia: dice
/// che la lettura non si ribalta per uno scostamento di un punto percentuale.
/// La misura vera si fara' col telefono, insieme alla taratura delle soglie.
void main() {
  /// Un volto costruito coi suoi rapporti, non una foto: si sceglie la forma e
  /// la geometria ne discende. Serve a fabbricare due volti DAVVERO diversi.
  FaceContours volto({
    required double larghezza,
    required double altezza,
    required double mascella,
    required double fronte,
    required double occhi,
    required double bocca,
  }) {
    const cx = 500.0;
    const cy = 500.0;
    List<Offset> fascia(double quota, double semi) {
      final y = cy - altezza / 2 + altezza * quota;
      return [Offset(cx - semi, y), Offset(cx + semi, y)];
    }

    return FaceContours(
      volto: [
        Offset(cx, cy - altezza / 2),
        ...fascia(0.15, larghezza * fronte / 2),
        ...fascia(0.50, larghezza / 2),
        ...fascia(0.80, larghezza * mascella / 2),
        Offset(cx, cy + altezza / 2),
      ],
      sopraccioSx: [
        Offset(cx - 150, cy - altezza * 0.20),
        Offset(cx - 90, cy - altezza * 0.22),
      ],
      sopraccioDx: [
        Offset(cx + 90, cy - altezza * 0.22),
        Offset(cx + 150, cy - altezza * 0.20),
      ],
      occhioSx: [
        Offset(cx - 150, cy - altezza * occhi / 2),
        Offset(cx - 90, cy + altezza * occhi / 2),
      ],
      occhioDx: [
        Offset(cx + 90, cy - altezza * occhi / 2),
        Offset(cx + 150, cy + altezza * occhi / 2),
      ],
      nasoPonte: [Offset(cx, cy - altezza * 0.12)],
      nasoBase: [Offset(cx, cy + altezza * 0.12)],
      labbroSopra: [
        Offset(cx - larghezza * bocca / 2, cy + altezza * 0.26),
        Offset(cx + larghezza * bocca / 2, cy + altezza * 0.26),
      ],
      labbroSotto: [
        Offset(cx - larghezza * bocca / 2, cy + altezza * 0.31),
        Offset(cx + larghezza * bocca / 2, cy + altezza * 0.31),
      ],
    );
  }

  /// Lo stesso volto ripreso una seconda volta: ogni punto si sposta di poco,
  /// come fa la mano che trema e il modello che oscilla.
  FaceContours conRumore(FaceContours c, double ampiezza, int seme) {
    final r = math.Random(seme);
    Offset mossa(Offset o) => Offset(
          o.dx + (r.nextDouble() - 0.5) * ampiezza,
          o.dy + (r.nextDouble() - 0.5) * ampiezza,
        );
    List<Offset> mosse(List<Offset> l) => [for (final o in l) mossa(o)];
    return FaceContours(
      volto: mosse(c.volto),
      sopraccioSx: mosse(c.sopraccioSx),
      sopraccioDx: mosse(c.sopraccioDx),
      occhioSx: mosse(c.occhioSx),
      occhioDx: mosse(c.occhioDx),
      nasoPonte: mosse(c.nasoPonte),
      nasoBase: mosse(c.nasoBase),
      labbroSopra: mosse(c.labbroSopra),
      labbroSotto: mosse(c.labbroSotto),
      guanciaSx: c.guanciaSx == null ? null : mossa(c.guanciaSx!),
      guanciaDx: c.guanciaDx == null ? null : mossa(c.guanciaDx!),
    );
  }

  final stretto = volto(
      larghezza: 300,
      altezza: 460,
      mascella: 0.62,
      fronte: 0.92,
      occhi: 0.07,
      bocca: 0.36);
  final largo = volto(
      larghezza: 420,
      altezza: 420,
      mascella: 0.98,
      fronte: 0.86,
      occhi: 0.12,
      bocca: 0.52);

  test('due volti diversi non danno la stessa lettura', () {
    final a = FaceClassifier.leggi(stretto);
    final b = FaceClassifier.leggi(largo);
    final trattiA = a.letture.map((l) => l.tratto.name).toList();
    final trattiB = b.letture.map((l) => l.tratto.name).toList();
    var diversi = 0;
    for (var i = 0; i < math.min(trattiA.length, trattiB.length); i++) {
      if (trattiA[i] != trattiB[i]) diversi++;
    }
    // ignore: avoid_print
    print('ORDINE CR VOCE 05: tratti letti ${trattiA.length}, diversi fra i '
        'due volti $diversi');
    cardinaleMinimo(trattiA.length, 8,
        cosa: 'tratti letti su un volto costruito',
        perche: 'Con pochi tratti la prova direbbe che i due volti si '
            'distinguono per non averne guardati abbastanza.');
    expect(diversi, greaterThanOrEqualTo(3),
        reason: 'due volti costruiti apposta diversi, uno stretto con mascella '
            'sfuggente e uno largo con mascella piena, danno letture che '
            'differiscono solo su $diversi tratti: la funzione non sta '
            'guardando il volto, sta recitando un responso');
  });

  test('e lo stesso volto ripreso due volte si somiglia', () {
    // **LA TOLLERANZA, DICHIARATA**: lo scostamento e' l'uno per cento del
    // volto, cioe' quattro punti su quattrocento. E' l'ordine di grandezza del
    // tremolio fra due fotogrammi vicini, non quello di due scansioni fatte a
    // giorni di distanza.
    const scostamento = 4.0;
    final prima = FaceClassifier.leggi(stretto);
    var uguali = 0;
    const quanteVolte = 12;
    for (var i = 0; i < quanteVolte; i++) {
      final poi = FaceClassifier.leggi(conRumore(stretto, scostamento, i));
      final a = prima.letture.map((l) => l.tratto.name).toList();
      final b = poi.letture.map((l) => l.tratto.name).toList();
      if (a.join('|') == b.join('|')) uguali++;
    }
    // ignore: avoid_print
    print('ORDINE CR VOCE 05: con uno scostamento di $scostamento punti su '
        '1000, letture identiche $uguali su $quanteVolte');
    cardinaleMinimo(quanteVolte, 10,
        cosa: 'riprese simulate dello stesso volto',
        perche: 'Con poche riprese la prova direbbe che la lettura e stabile '
            'per non averla ripetuta abbastanza.');
    expect(uguali, quanteVolte,
        reason: 'lo stesso volto, spostato di appena $scostamento punti su '
            'mille, ha dato $uguali letture identiche su $quanteVolte: la '
            'lettura cambia col rumore, quindi il responso e un sorteggio e '
            'non una misura');
  });

  test('e la tavola dei tratti esiste e porta i suoi numeri', () {
    // La tavola che l'ordine chiede per nome. Se sparisse, resterebbero le
    // formule senza nessuno che le sappia leggere.
    final tavola = File('docs/viso/tratti_misura_per_misura.md');
    expect(tavola.existsSync(), isTrue,
        reason: 'la tavola dei tratti non esiste: l ordine CR voce 05 la '
            'chiede per nome, con landmark, rapporto e soglie');
    final testo = tavola.readAsStringSync();
    final soglie = RegExp(r'\d+\.\d+').allMatches(testo).length;
    // ignore: avoid_print
    print('ORDINE CR VOCE 05: la tavola porta $soglie numeri con la virgola');
    cardinaleMinimo(soglie, 10,
        cosa: 'soglie numeriche scritte nella tavola',
        perche: 'Una tavola senza numeri e una descrizione, e l ordine chiede '
            'le soglie che separano una lettura dall altra.');
  });
}

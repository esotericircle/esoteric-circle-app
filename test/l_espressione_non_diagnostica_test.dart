import 'package:esoteric_circle/core/face/espressione_dell_istante.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart';

import 'cardinale_minimo.dart';

/// **L'ESPRESSIONE NON DIAGNOSTICA, E NON SI MESCOLA COI TRATTI.**
/// Ordine CR voci 07 e 11, 6 settembre 2026.
///
/// **Il confine, con le parole dell'ordine**: *"non si diagnostica niente. Non
/// si dice a nessuno che e' triste, ansioso o depresso. Si legge cio' che il
/// volto sta facendo, e lo si restituisce nella voce di Aura come uno
/// specchio, non come un verdetto."*
///
/// **PERCHE' UNA GUARDIA SUL VOCABOLARIO E NON SUL BUON SENSO.** Un corpus di
/// frasi si allarga nel tempo, e la frase che supera il confine non arriva mai
/// come una diagnosi dichiarata: arriva come *sembri stanco*, che e' gentile,
/// suona bene, e dice a una persona come sta sulla base di due muscoli. Il
/// vocabolario e' l'unica cosa che si puo' misurare.
void main() {
  List<String> testi() => [
        for (final s in SegnoDelVolto.values) s.osservazione,
        for (final s in SegnoDelVolto.values) s.specchio,
      ];

  test('nessuna frase nomina uno stato d animo o una condizione', () {
    // **NON SONO SOLO LE PAROLE CLINICHE.** Le prime cinque sono quelle che
    // l'ordine vieta per nome; le altre sono i modi normali in cui si dice a
    // qualcuno come sta, e sono quelli che scivolano dentro senza allarmare
    // nessuno.
    const vietate = [
      'diagnosi', 'disturbo', 'patologia', 'depress', 'ansios',
      'sei triste', 'sei stanco', 'sembri stanco', 'sei nervoso',
      'sei arrabbiato', 'sei felice', 'sei preoccupato', 'sei teso',
      'ti senti', 'stai male', 'umore',
    ];
    final colpe = <String>[];
    var guardate = 0;
    for (final t in testi()) {
      guardate++;
      for (final v in vietate) {
        if (t.toLowerCase().contains(v)) colpe.add('"$t" -> $v');
      }
    }
    // ignore: avoid_print
    print('ORDINE CR VOCE 07: frasi dell espressione guardate $guardate, che '
        'dicono a qualcuno come sta ${colpe.length}');
    cardinaleMinimo(guardate, 10,
        cosa: 'frasi del corpus dell espressione',
        perche: 'Con poche frasi la prova direbbe che nessuna supera il '
            'confine per non averne lette abbastanza.');
    expect(colpe, isEmpty,
        reason: 'queste frasi dicono a una persona come sta sulla base di due '
            'muscoli, ed e esattamente il confine che l ordine vieta di '
            'superare: ${colpe.join(" | ")}');
  });

  test('e ogni segno dichiara i coefficienti che lo compongono', () {
    final senza = <String>[];
    final tutti = <FaceBlendshape>{};
    for (final s in SegnoDelVolto.values) {
      if (s.coefficienti.isEmpty) senza.add(s.name);
      tutti.addAll(s.coefficienti);
    }
    // ignore: avoid_print
    print('ORDINE CR VOCE 07: segni ${SegnoDelVolto.values.length}, '
        'coefficienti usati in tutto ${tutti.length} sui '
        '${FaceBlendshape.values.length} che il motore restituisce');
    cardinaleMinimo(SegnoDelVolto.values.length, 5,
        cosa: 'segni del volto dichiarati',
        perche: 'Con pochi segni la lettura dell istante direbbe quasi sempre '
            'la stessa cosa, e non sarebbe una lettura.');
    expect(senza, isEmpty,
        reason: 'questi segni non dicono da quali coefficienti nascono: un '
            'segno che non si sa rifare col conto non e una misura, e '
            'l ordine chiede di scriverli. ${senza.join(", ")}');
  });

  test('e un volto a riposo non produce nessun segno', () {
    // **IL CASO PIU' IMPORTANTE, ed e' quello del volto fermo.** Se un volto a
    // riposo producesse un segno, la lettura dell'istante direbbe qualcosa a
    // chiunque, sempre, e sarebbe la stessa presa in giro del muro: un
    // responso che arriva senza che ci sia niente da leggere.
    final riposo = {for (final b in FaceBlendshape.values) b: 0.05};
    final letti = EspressioneDellIstante.leggi(riposo);
    // ignore: avoid_print
    print('ORDINE CR VOCE 07: su un volto a riposo, segni letti '
        '${letti.length}');
    expect(letti, isEmpty,
        reason: 'un volto immobile produce ${letti.length} segni: la lettura '
            'dell istante direbbe qualcosa a chiunque e sempre, ed e la stessa '
            'presa in giro del muro che fotografato dava un responso');
  });

  test('e un gesto netto si legge, e non si legge un inventario', () {
    // Un sorriso pieno e nient'altro.
    final sorriso = {
      for (final b in FaceBlendshape.values) b: 0.05,
      FaceBlendshape.mouthSmileLeft: 0.80,
      FaceBlendshape.mouthSmileRight: 0.78,
    };
    final letti = EspressioneDellIstante.leggi(sorriso);
    // ignore: avoid_print
    print('ORDINE CR VOCE 07: su un sorriso netto, segni letti '
        '${letti.map((s) => s.name).join(", ")}');
    expect(letti, isNotEmpty,
        reason: 'un sorriso pieno non produce nessun segno: la lettura dell '
            'istante non vede nemmeno il gesto piu evidente che esista');
    expect(letti.first, SegnoDelVolto.boccaSollevata,
        reason: 'il segno piu forte di un sorriso pieno non e la bocca '
            'sollevata ma ${letti.first.name}: i coefficienti sono legati al '
            'segno sbagliato');
    expect(letti.length, lessThanOrEqualTo(2),
        reason: 'la lettura restituisce ${letti.length} segni: un responso che '
            'elenca tutto non e un responso, e la persona non si riconosce in '
            'un inventario');

    // **E IL CASO CHE SERVE DAVVERO: UN VOLTO CHE FA TUTTO INSIEME.**
    //
    // La prima stesura si fermava al sorriso, ed e' restata VERDE sotto
    // l'innesto della Regola A: togliendo il tetto dei due segni, il
    // sorriso ne produceva comunque uno solo, perche' tutti gli altri
    // coefficienti erano sotto soglia. **La pretesa misurava il caso
    // facile**, cioe' quello in cui il tetto non serve.
    //
    // E' la seconda volta in questo ordine che la Regola A trova una
    // pretesa debole invece di un difetto: e' esattamente il suo mestiere.
    final espressivo = {
      for (final b in FaceBlendshape.values) b: 0.05,
      FaceBlendshape.browInnerUp: 0.75,
      FaceBlendshape.browOuterUpLeft: 0.72,
      FaceBlendshape.browOuterUpRight: 0.70,
      FaceBlendshape.eyeWideLeft: 0.68,
      FaceBlendshape.eyeWideRight: 0.66,
      FaceBlendshape.mouthSmileLeft: 0.80,
      FaceBlendshape.mouthSmileRight: 0.78,
      FaceBlendshape.jawForward: 0.60,
      FaceBlendshape.mouthPressLeft: 0.58,
      FaceBlendshape.mouthPressRight: 0.62,
    };
    final tanti = EspressioneDellIstante.leggi(espressivo);
    // ignore: avoid_print
    print('ORDINE CR VOCE 07: su un volto che fa quattro cose insieme, segni '
        'letti ${tanti.length}: ${tanti.map((s) => s.name).join(", ")}');
    expect(tanti.length, 2,
        reason: 'un volto che fa quattro gesti insieme produce ${tanti.length} '
            'segni: senza un tetto la lettura diventa un inventario, e chi la '
            'riceve non ci si riconosce');
  });
}

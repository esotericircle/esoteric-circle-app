import 'dart:math' as math;

import 'package:esoteric_circle/core/face/face_classifier.dart';
import 'package:esoteric_circle/core/face/face_trait.dart';
import 'package:esoteric_circle/core/face/punti_del_volto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart';

/// **IL VOLTO NON SI MISURA SCHIACCIATO.** Ordine CR voce 05, seconda stesura,
/// 6 settembre 2026.
///
/// **Parole del fondatore dopo la prova sul telefono**: *"il responso NON
/// C'ENTRA UN CAZZO! SONO DESCRIZIONI BUTTATE LI' A CASO?"*.
///
/// **NON ERANO BUTTATE A CASO: ERANO MISURE VERE SU UN VISO STIRATO.** La
/// conversione dai punti della mesh ai contorni faceva questo:
///
///     Offset(punti[i].x * 1000, punti[i].y * 1000)
///
/// I punti arrivano **normalizzati da zero a uno sui due lati**, e i due lati
/// non sono lunghi uguale. Su un fotogramma tre quarti un centesimo di
/// larghezza e un centesimo di altezza sono due distanze diverse:
/// moltiplicandoli per lo stesso numero il volto veniva **stirato in
/// orizzontale di un terzo**. E il classificatore lavora quasi solo su rapporti
/// fra una larghezza e un'altezza, quindi ogni categoria sbagliava insieme alle
/// altre: forma, occhi, naso, bocca, mascella, zigomi.
///
/// **PERCHE' NESSUNA GUARDIA LO AVEVA PRESO.** Le guardie dei tratti davano al
/// classificatore contorni costruiti a mano, gia' in coordinate giuste: non
/// passavano mai dalla conversione. E la guardia dei punti verificava che gli
/// indici fossero indici, non che le distanze fossero distanze.
void main() {
  /// Un volto sintetico OVALE, costruito in unita' reali e poi normalizzato
  /// su un fotogramma di una forma dichiarata.
  ///
  /// Il volto e' sempre lo stesso, cambia solo il fotogramma che lo contiene:
  /// quindi la lettura deve essere sempre la stessa. Se cambia, sta cambiando
  /// per la forma del fotogramma, che e' esattamente il difetto.
  List<FaceMeshLandmark> voltoIn({required double proporzione}) {
    // Il volto vero, in unita' arbitrarie: alto 200, largo 140, cioe' un
    // ovale, con il rapporto larghezza su altezza di 0.7.
    const altezzaVolto = 200.0;
    const larghezzaVolto = 140.0;

    // Il fotogramma che lo contiene, con la sua forma. Il volto occupa meta'
    // dell'altezza, centrato.
    const altezzaFotogramma = altezzaVolto * 2;
    final larghezzaFotogramma = altezzaFotogramma * proporzione;

    double nx(double x) => 0.5 + x / larghezzaFotogramma;
    double ny(double y) => 0.5 + y / altezzaFotogramma;

    final grezzi = <int, (double, double)>{};

    // L'ovale del volto: un'ellisse vera, punto per punto.
    const ovale = PuntiDelVolto.ovale;
    for (var k = 0; k < ovale.length; k++) {
      final a = 2 * math.pi * k / ovale.length;
      grezzi[ovale[k]] = (
        larghezzaVolto / 2 * math.sin(a),
        -altezzaVolto / 2 * math.cos(a),
      );
    }
    // Gli occhi, il naso, la bocca e le sopracciglia, a quote plausibili.
    void gruppo(List<int> indici, double cx, double cy, double lar, double alt) {
      for (var k = 0; k < indici.length; k++) {
        final a = 2 * math.pi * k / indici.length;
        grezzi[indici[k]] = (cx + lar / 2 * math.sin(a), cy - alt / 2 * math.cos(a));
      }
    }

    gruppo(PuntiDelVolto.occhioSinistro, 30, -20, 28, 12);
    gruppo(PuntiDelVolto.occhioDestro, -30, -20, 28, 12);
    gruppo(PuntiDelVolto.sopraccioSinistro, 30, -40, 34, 6);
    gruppo(PuntiDelVolto.sopraccioDestro, -30, -40, 34, 6);
    gruppo(PuntiDelVolto.ponteDelNaso, 0, 0, 6, 40);
    gruppo(PuntiDelVolto.baseDelNaso, 0, 22, 24, 6);
    gruppo(PuntiDelVolto.labbroSuperiore, 0, 48, 44, 8);
    gruppo(PuntiDelVolto.labbroInferiore, 0, 58, 44, 10);
    gruppo(PuntiDelVolto.guanciaSinistra, 52, 10, 10, 10);
    gruppo(PuntiDelVolto.guanciaDestra, -52, 10, 10, 10);

    return [
      for (var i = 0; i < PuntiDelVolto.quantiPunti; i++)
        () {
          final p = grezzi[i] ?? (0.0, 0.0);
          return FaceMeshLandmark(x: nx(p.$1), y: ny(p.$2), z: 0);
        }(),
    ];
  }

  FaceReading leggiCon(double proporzione) => FaceClassifier.leggi(
        PuntiDelVolto.contorniDa(
          voltoIn(proporzione: proporzione),
          proporzioneDelFotogramma: proporzione,
        ),
      );

  test('lo stesso volto da\' la stessa forma su fotogrammi diversi', () {
    // **LA PRETESA CENTRALE.** Il volto e' identico; cambia solo la forma del
    // fotogramma che lo contiene. Una fotocamera frontale in verticale da'
    // tre quarti, una in orizzontale quattro terzi, e qualche telefono da'
    // sedici noni. La lettura non puo' dipendere da questo.
    final forme = <double, FaceTrait>{};
    for (final p in [3 / 4, 1.0, 4 / 3, 16 / 9]) {
      forme[p] = leggiCon(p).letturaDi(FaceCategory.formaVolto).tratto;
    }
    final distinte = forme.values.toSet();
    expect(distinte.length, 1,
        reason: 'lo stesso identico volto viene letto con forme diverse a '
            'seconda di com\'e\' fatto il fotogramma: $forme. E\' il difetto '
            'per cui i responsi sembravano buttati li\' a caso');

    // **E NON BASTA CHE IL NOME DEL TRATTO COINCIDA.** La marcatezza e'
    // il numero da cui il nome nasce, e cambia molto prima del nome: una
    // deformazione piccola sposta la misura senza far cambiare categoria,
    // e una guardia che guardasse i soli nomi la lascerebbe passare.
    // **Misurato con la Regola A**: ignorando la proporzione su un asse
    // solo, la pretesa sui nomi restava verde.
    final riferimento = leggiCon(1.0);
    for (final prop in [3 / 4, 4 / 3, 16 / 9]) {
      final altra = leggiCon(prop);
      for (final c in FaceCategory.values) {
        final qui = riferimento.letturaDi(c).marcatezza;
        final la = altra.letturaDi(c).marcatezza;
        expect((qui - la).abs(), lessThan(0.02),
            reason: 'la categoria ${c.name} misura $qui su un fotogramma '
                'quadrato e $la su uno $prop: la misura segue la forma '
                'del fotogramma invece del volto');
      }
    }
  });

  test('un volto ovale viene letto come ovale, non come tondo', () {
    // Il volto sintetico e' largo 140 e alto 200: e' un ovale, e va detto
    // che lo e'. Con lo schiacciamento su un tre quarti diventava largo
    // quanto alto, cioe' tondo o quadrato.
    final forma = leggiCon(3 / 4).letturaDi(FaceCategory.formaVolto).tratto;
    expect(forma, FaceTrait.voltoOvale,
        reason: 'un volto alto 200 e largo 140 viene letto come '
            '${forma.nome}: la geometria dice ovale');
  });

  test('nessuna categoria cambia con la forma del fotogramma', () {
    // **NON SOLO LA FORMA DEL VOLTO.** Occhi, naso, bocca, mascella e zigomi
    // passano tutti da rapporti fra una larghezza e un'altezza: se uno solo
    // di loro seguisse ancora il fotogramma, il responso resterebbe in parte
    // casuale, e una guardia sulla sola forma sarebbe verde accanto al pezzo
    // rotto.
    final stretto = leggiCon(3 / 4);
    final largo = leggiCon(16 / 9);
    for (final c in FaceCategory.values) {
      expect(largo.letturaDi(c).tratto, stretto.letturaDi(c).tratto,
          reason: 'la categoria ${c.name} cambia con la forma del '
              'fotogramma: ${stretto.letturaDi(c).tratto.nome} su tre quarti, '
              '${largo.letturaDi(c).tratto.nome} su sedici noni');
    }
  });

  test('due volti davvero diversi restano diversi', () {
    // La cura non deve appiattire tutto: se dopo la correzione ogni volto
    // desse la stessa lettura, avremmo scambiato un difetto con un altro.
    final ovale = leggiCon(1.0);
    final largo = FaceClassifier.leggi(
      PuntiDelVolto.contorniDa(
        [
          for (final p in voltoIn(proporzione: 1.0))
            FaceMeshLandmark(x: 0.5 + (p.x - 0.5) * 1.6, y: p.y, z: p.z),
        ],
        proporzioneDelFotogramma: 1.0,
      ),
    );
    expect(largo.letturaDi(FaceCategory.formaVolto).tratto,
        isNot(ovale.letturaDi(FaceCategory.formaVolto).tratto),
        reason: 'un volto allargato del sessanta per cento viene letto come '
            'quello stretto: la misura non distingue piu\' niente');
  });
}

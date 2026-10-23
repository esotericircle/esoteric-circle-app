/// LA GRIGLIA DEL TOCCO, ordine FG parte 2 (voce 2.12).
///
/// Il tocco cerca la stella piu' vicina al dito senza ricalcolare il cielo
/// intero: le stelle di un istante stanno in celle grossolane per regione di
/// cielo, fasce di altezza da [kAltezzaDellaCella] gradi divise in spicchi di
/// azimut larghi circa altrettanto (piu' pochi verso lo zenit, dove i
/// meridiani si stringono). Il tocco guarda le celle che toccano il cerchio
/// sotto il dito, cioe' poche decine di stelle invece di cinquemila.
///
/// La griglia si costruisce una volta per ogni istante calcolato, non per
/// fotogramma: le stelle girano con il cielo, la camera no.
library;

import 'dart:math' as math;

import 'il_cielo_in_un_istante.dart';

const double kAltezzaDellaCella = 6;

class GrigliaDelTocco {
  GrigliaDelTocco._(this._fasce);

  /// Per ogni fascia di altezza, dal basso, gli spicchi di azimut con gli
  /// indici delle stelle.
  final List<List<List<int>>> _fasce;

  static int get _numeroDiFasce => (180 / kAltezzaDellaCella).round();

  static int _spicchiNellaFascia(int f) {
    final centro = -90 + (f + 0.5) * kAltezzaDellaCella;
    final larghezza = 360 * math.cos(centro * math.pi / 180);
    return math.max(1, (larghezza / kAltezzaDellaCella).round());
  }

  static ({int fascia, int spicchio}) _cella(double x, double y, double z) {
    final alt = math.asin(z.clamp(-1.0, 1.0)) * 180 / math.pi;
    var az = math.atan2(x, y) * 180 / math.pi;
    if (az < 0) az += 360;
    final f = ((alt + 90) / kAltezzaDellaCella)
        .floor()
        .clamp(0, _numeroDiFasce - 1);
    final s = _spicchiNellaFascia(f);
    return (fascia: f, spicchio: (az / 360 * s).floor() % s);
  }

  factory GrigliaDelTocco.di(CieloInUnIstante cielo) {
    final fasce = [
      for (var f = 0; f < _numeroDiFasce; f++)
        [for (var s = 0; s < _spicchiNellaFascia(f); s++) <int>[]],
    ];
    for (var i = 0; i < cielo.x.length; i++) {
      final c = _cella(cielo.x[i], cielo.y[i], cielo.z[i]);
      fasce[c.fascia][c.spicchio].add(i);
    }
    return GrigliaDelTocco._(fasce);
  }

  /// Gli indici delle stelle nelle celle entro [raggioGradi] dalla direzione
  /// (x, y, z). Le celle sono grossolane: chi chiama misura la distanza vera.
  Iterable<int> vicine(double x, double y, double z, double raggioGradi) sync* {
    final alt = math.asin(z.clamp(-1.0, 1.0)) * 180 / math.pi;
    var az = math.atan2(x, y) * 180 / math.pi;
    if (az < 0) az += 360;
    final fMin = ((alt - raggioGradi + 90) / kAltezzaDellaCella)
        .floor()
        .clamp(0, _numeroDiFasce - 1);
    final fMax = ((alt + raggioGradi + 90) / kAltezzaDellaCella)
        .floor()
        .clamp(0, _numeroDiFasce - 1);
    for (var f = fMin; f <= fMax; f++) {
      final spicchi = _fasce[f];
      final s = spicchi.length;
      // L'azimut si allarga con la latitudine della fascia: verso lo zenit
      // un grado di cielo vale molti gradi di azimut.
      final centro = -90 + (f + 0.5) * kAltezzaDellaCella;
      final cosAlt = math.max(0.05, math.cos(centro * math.pi / 180));
      final mezzoArco = math.min(180.0, raggioGradi / cosAlt + 360 / s);
      if (mezzoArco >= 180) {
        for (final c in spicchi) {
          yield* c;
        }
        continue;
      }
      final da = ((az - mezzoArco) / 360 * s).floor();
      final a = ((az + mezzoArco) / 360 * s).floor();
      for (var k = da; k <= a; k++) {
        yield* spicchi[k % s];
      }
    }
  }
}

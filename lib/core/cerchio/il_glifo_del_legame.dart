import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../astro/zodiac.dart';

/// **IL GLIFO DEL LEGAME, ordine EY voce 14.** Ogni coppia di amici ha un
/// segno grafico suo, tracciato a tratti come le rune di `rune_strokes.dart`,
/// generato in modo deterministico dai due sigilli e dai due segni: la stessa
/// coppia da' sempre lo stesso glifo, da entrambi i lati.
///
/// **E' UN SEGNO DEL CERCHIO, NON UN SIGILLO TRADIZIONALE**, e non deve poter
/// essere confuso con un elemento oracolare. Per questo non nasce sul bastone
/// verticale delle rune: nasce sul cerchio, su otto punti della circonferenza
/// e sul centro, e nessun tratto attraversa il glifo dall'alto in basso come
/// il bastone di una runa. Una prova lo confronta con le ventiquattro rune.
///
/// **Nasce spento e si accende per gradi**: ogni giorno in cui i due si sono
/// scambiati un segno accende un tratto, fino al glifo intero. Quanti tratti
/// sono accesi lo dice il server, nel legame, non i due telefoni. Non si
/// compra, non si regala, non conia Eos.
class IlGlifoDelLegame {
  const IlGlifoDelLegame._(this.tratti);

  /// I tratti, nell'ordine in cui si accendono: coppie di punti normalizzati.
  final List<(Offset, Offset)> tratti;

  static const int quantiTratti = 7;

  /// I nove punti del glifo: otto sulla circonferenza e il centro.
  static final List<Offset> punti = [
    for (var i = 0; i < 8; i++)
      Offset(0.5 + 0.42 * math.cos(-math.pi / 2 + i * math.pi / 4),
          0.5 + 0.42 * math.sin(-math.pi / 2 + i * math.pi / 4)),
    const Offset(0.5, 0.5),
  ];

  /// Il seme della coppia: i due sigilli in ordine, ciascuno col suo segno.
  /// L'ordine non dipende da chi guarda, quindi il glifo e' lo stesso dai due
  /// lati.
  static int seme(
      String sigilloA, Zodiac? segnoA, String sigilloB, Zodiac? segnoB) {
    final a = '$sigilloA:${segnoA?.id ?? '-'}';
    final b = '$sigilloB:${segnoB?.id ?? '-'}';
    final testo = a.compareTo(b) <= 0 ? '$a|$b' : '$b|$a';
    var h = 0x811c9dc5;
    for (final c in testo.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0xffffffff;
    }
    return h;
  }

  /// Il glifo di una coppia.
  static IlGlifoDelLegame di(
      String sigilloA, Zodiac? segnoA, String sigilloB, Zodiac? segnoB) {
    var s = seme(sigilloA, segnoA, sigilloB, segnoB);
    int prossimo(int n) {
      // Un generatore congruenziale sul seme: uguale ovunque.
      s = (s * 1103515245 + 12345) & 0x7fffffff;
      // I bit alti: quelli bassi di un congruenziale si ripetono presto.
      return (s >> 16) % n;
    }

    // Tutte le corde fra i nove punti, tranne quelle che attraversano il
    // glifo in verticale da cima a fondo (punti 0 e 4): sarebbero il bastone
    // di una runa.
    final corde = <(int, int)>[
      for (var i = 0; i < 9; i++)
        for (var j = i + 1; j < 9; j++)
          if (!((i == 0 && j == 4) || (i == 0 && j == 8) || (i == 4 && j == 8)))
            (i, j),
    ];
    final scelte = <(int, int)>[];
    // Il primo tratto parte dal centro: e' il cuore del legame.
    final primo = corde.where((c) => c.$2 == 8).toList();
    scelte.add(primo[prossimo(primo.length)]);
    while (scelte.length < quantiTratti) {
      // I tratti dopo si appoggiano a un punto gia' toccato: il glifo cresce
      // come una figura sola e non come segni sparsi.
      final toccati = {
        for (final c in scelte) ...[c.$1, c.$2]
      };
      final vicine = corde
          .where((c) =>
              !scelte.contains(c) &&
              (toccati.contains(c.$1) || toccati.contains(c.$2)))
          .toList();
      scelte.add(vicine[prossimo(vicine.length)]);
    }
    return IlGlifoDelLegame._([
      for (final c in scelte) (punti[c.$1], punti[c.$2]),
    ]);
  }

  /// La riga del pannello Fonti e metodo della scheda dell'amico. **Non va
  /// mai accostata all'elenco delle fonti**: il glifo non viene da una.
  static const String rigaDelMetodo =
      'Il glifo del legame è un segno del Cerchio e non un sigillo '
      'tradizionale. Nasce dai vostri due sigilli e dai vostri due segni ed è '
      'lo stesso per tutti e due. Si accende un tratto per ogni giorno in '
      'cui vi siete scambiati un segno.';
}

/// Il glifo disegnato: i tratti spenti in filigrana, quelli accesi d'oro.
class PittoreDelGlifo extends CustomPainter {
  PittoreDelGlifo({
    required this.glifo,
    required this.accesi,
    required this.colore,
    required this.spento,
  });

  final IlGlifoDelLegame glifo;
  final int accesi;
  final Color colore;
  final Color spento;

  @override
  void paint(Canvas canvas, Size size) {
    final lato = size.shortestSide;
    final sinistra = (size.width - lato) / 2;
    final cima = (size.height - lato) / 2;
    Offset mappa(Offset p) =>
        Offset(sinistra + p.dx * lato, cima + p.dy * lato);
    final anello = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lato * 0.012
      ..color = spento;
    canvas.drawCircle(
        Offset(sinistra + lato / 2, cima + lato / 2), lato * 0.42, anello);
    for (var i = 0; i < glifo.tratti.length; i++) {
      final acceso = i < accesi;
      final (a, b) = glifo.tratti[i];
      if (acceso) {
        canvas.drawLine(
            mappa(a),
            mappa(b),
            Paint()
              ..strokeWidth = lato * 0.07
              ..strokeCap = StrokeCap.round
              ..color = colore.withValues(alpha: 0.35)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, lato * 0.03));
      }
      canvas.drawLine(
          mappa(a),
          mappa(b),
          Paint()
            ..strokeWidth = lato * (acceso ? 0.04 : 0.02)
            ..strokeCap = StrokeCap.round
            ..color = acceso ? colore : spento);
    }
    for (final p in IlGlifoDelLegame.punti) {
      canvas.drawCircle(mappa(p), lato * 0.018, Paint()..color = spento);
    }
  }

  @override
  bool shouldRepaint(PittoreDelGlifo old) =>
      old.accesi != accesi || old.colore != colore || old.glifo != glifo;
}

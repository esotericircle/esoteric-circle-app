import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';

import 'face_trait.dart';

/// I contorni del volto, come li servono al classificatore.
///
/// E' un dato puro: niente ML Kit qui dentro, solo liste di punti in coordinate
/// immagine (x verso destra, y verso il basso). L'adattatore che converte il
/// volto rilevato da ML Kit in questo oggetto sta nel livello della schermata,
/// cosi' il classificatore resta una funzione pura e provabile senza plugin.
@immutable
class FaceContours {
  const FaceContours({
    required this.volto,
    required this.sopraccioSx,
    required this.sopraccioDx,
    required this.occhioSx,
    required this.occhioDx,
    required this.nasoPonte,
    required this.nasoBase,
    required this.labbroSopra,
    required this.labbroSotto,
    this.guanciaSx,
    this.guanciaDx,
  });

  final List<Offset> volto;
  final List<Offset> sopraccioSx;
  final List<Offset> sopraccioDx;
  final List<Offset> occhioSx;
  final List<Offset> occhioDx;
  final List<Offset> nasoPonte;
  final List<Offset> nasoBase;
  final List<Offset> labbroSopra;
  final List<Offset> labbroSotto;
  final Offset? guanciaSx;
  final Offset? guanciaDx;

  bool get completo =>
      volto.length >= 4 &&
      sopraccioSx.isNotEmpty &&
      sopraccioDx.isNotEmpty &&
      occhioSx.isNotEmpty &&
      occhioDx.isNotEmpty &&
      nasoPonte.isNotEmpty &&
      nasoBase.isNotEmpty &&
      labbroSopra.isNotEmpty &&
      labbroSotto.isNotEmpty;
}

/// La lettura di un tratto: la variante e quanto e' marcata, da zero a uno.
@immutable
class TraitLettura {
  const TraitLettura({required this.tratto, required this.marcatezza});

  final FaceTrait tratto;

  /// Quanto il tratto e' pronunciato, da zero (neutro) a uno (marcatissimo).
  /// Il tratto DOMINANTE del responso e' quello con la marcatezza piu' alta.
  final double marcatezza;
}

/// Il responso geometrico: una lettura per ognuna delle undici categorie.
@immutable
class FaceReading {
  const FaceReading({required this.letture});

  /// Una lettura per categoria, nell'ordine canonico delle categorie.
  final List<TraitLettura> letture;

  /// Il tratto piu' marcato, che da' il titolo evocativo. A parita' di
  /// marcatezza vince l'ordine canonico delle categorie.
  FaceTrait get dominante => _ordinati.first.tratto;

  /// I tratti in ordine di marcatezza decrescente, pareggi sciolti dall'ordine
  /// canonico delle categorie.
  List<FaceTrait> get marcati =>
      _ordinati.map((l) => l.tratto).toList(growable: false);

  TraitLettura letturaDi(FaceCategory c) =>
      letture.firstWhere((l) => l.tratto.categoria == c);

  List<TraitLettura> get _ordinati {
    final copia = [...letture];
    copia.sort((a, b) {
      final d = b.marcatezza.compareTo(a.marcatezza);
      return d != 0 ? d : a.tratto.categoria.ordine.compareTo(b.tratto.categoria.ordine);
    });
    return copia;
  }
}

/// La classificazione dei tratti del volto dalla geometria dei contorni.
///
/// Funzione pura e deterministica: stessi contorni, stesso responso. Nessuna AI,
/// nessuna casualita', nessuna dipendenza dall'orologio. Ogni categoria misura
/// una proporzione, la confronta con una soglia dichiarata e ne ricava la
/// variante e la marcatezza, cioe' quanto la proporzione si stacca dal neutro.
class FaceClassifier {
  const FaceClassifier._();

  /// Legge i contorni e restituisce una lettura per ogni categoria.
  static FaceReading leggi(FaceContours c) {
    final box = _Box.attorno(c.volto);
    final h = box.altezza <= 0 ? 1.0 : box.altezza;
    final w = box.larghezza <= 0 ? 1.0 : box.larghezza;

    // Larghezze del volto a tre altezze: fronte (alto), zigomi (meta'), mascella
    // (basso). Servono a piu' categorie.
    final wFronte = _larghezzaFascia(c.volto, box, 0.05, 0.30);
    final wZigomi = _larghezzaFascia(c.volto, box, 0.40, 0.60);
    final wMascella = _larghezzaFascia(c.volto, box, 0.68, 0.90);
    final wMento = _larghezzaFascia(c.volto, box, 0.88, 1.0);

    final letture = <TraitLettura>[
      _formaVolto(w, h, wFronte, wZigomi, wMascella),
      _fronte(c, box, h),
      _sopracciglia(c),
      _distanzaOcchi(c, w),
      _grandezzaOcchi(c, h),
      _naso(c, box, h),
      _labbra(c),
      _bocca(c, w),
      _mento(wMento, wMascella),
      _mascella(wMascella, w),
      _zigomi(c, wZigomi, wMascella),
    ];
    return FaceReading(letture: letture);
  }

  /// Il ripiego tattile: costruisce la lettura dalle selezioni guidate, una per
  /// categoria scelta. La marcatezza viene da una salienza curata per variante,
  /// cosi' un dominante emerge in modo deterministico anche senza misura.
  static FaceReading daSelezioni(Map<FaceCategory, FaceTrait> scelte) {
    final letture = <TraitLettura>[
      for (final e in scelte.entries)
        TraitLettura(tratto: e.value, marcatezza: _salienza[e.value] ?? 0.5),
    ];
    letture.sort((a, b) =>
        a.tratto.categoria.ordine.compareTo(b.tratto.categoria.ordine));
    return FaceReading(letture: letture);
  }

  // --- Le undici categorie ---

  static TraitLettura _formaVolto(
      double w, double h, double wFronte, double wZigomi, double wMascella) {
    final wh = w / h;
    final jf = wFronte <= 0 ? 1.0 : wMascella / wFronte;
    final jz = wZigomi <= 0 ? 1.0 : wMascella / wZigomi;
    final FaceTrait t;
    if (jf < 0.80) {
      t = FaceTrait.voltoTriangolare; // fronte larga, mento stretto
    } else if (wh < 0.74) {
      t = FaceTrait.voltoOvale; // lungo e stretto
    } else if (jz > 0.90 && wh >= 0.80) {
      t = FaceTrait.voltoQuadrato; // lati dritti, mascella piena
    } else {
      t = FaceTrait.voltoTondo;
    }
    // Marcatezza: quanto la forma si stacca dal volto neutro (wh ~ 0.82).
    final m = _marca(wh, 0.82, 0.14) * 0.5 +
        _marca(jf, 0.92, 0.16) * 0.5;
    return TraitLettura(tratto: t, marcatezza: m.clamp(0.0, 1.0));
  }

  static TraitLettura _fronte(FaceContours c, _Box box, double h) {
    final browY = _minY([...c.sopraccioSx, ...c.sopraccioDx]);
    final ratio = ((browY - box.minY) / h).clamp(0.0, 1.0);
    final t = ratio >= 0.33
        ? FaceTrait.fronteVerticale
        : FaceTrait.fronteSfuggente;
    return TraitLettura(tratto: t, marcatezza: _marca(ratio, 0.33, 0.10));
  }

  static TraitLettura _sopracciglia(FaceContours c) {
    final a = _formaSopraccio(c.sopraccioSx);
    final b = _formaSopraccio(c.sopraccioDx);
    // Media dei due indici, poi si decide.
    final rise = (a.rise + b.rise) / 2;
    final angolo = math.min(a.angoloApice, b.angoloApice);
    final FaceTrait t;
    if (rise < 0.06) {
      t = FaceTrait.sopraccigliaDritte;
    } else if (angolo < 2.75) {
      // apice aguzzo, in radianti (circa 158 gradi o meno)
      t = FaceTrait.sopraccigliaAngolo;
    } else {
      t = FaceTrait.sopraccigliaCurve;
    }
    final m = _marca(rise, 0.06, 0.10);
    return TraitLettura(tratto: t, marcatezza: m);
  }

  static TraitLettura _distanzaOcchi(FaceContours c, double w) {
    final cxSx = _centro(c.occhioSx).dx;
    final cxDx = _centro(c.occhioDx).dx;
    final gap = (cxDx - cxSx).abs();
    final eyeW = (_Box.attorno(c.occhioSx).larghezza +
            _Box.attorno(c.occhioDx).larghezza) /
        2;
    final ratio = eyeW <= 0 ? 2.0 : gap / eyeW;
    final t = ratio < 2.0
        ? FaceTrait.occhiRavvicinati
        : FaceTrait.occhiDistanziati;
    return TraitLettura(tratto: t, marcatezza: _marca(ratio, 2.0, 0.5));
  }

  static TraitLettura _grandezzaOcchi(FaceContours c, double h) {
    final eyeH = (_Box.attorno(c.occhioSx).altezza +
            _Box.attorno(c.occhioDx).altezza) /
        2;
    final ratio = eyeH / h;
    final t =
        ratio >= 0.085 ? FaceTrait.occhiGrandi : FaceTrait.occhiRaccolti;
    return TraitLettura(tratto: t, marcatezza: _marca(ratio, 0.085, 0.04));
  }

  static TraitLettura _naso(FaceContours c, _Box box, double h) {
    final top = _minY(c.nasoPonte);
    final bottom = _maxY(c.nasoBase);
    final ratio = ((bottom - top) / h).clamp(0.0, 1.0);
    final t = ratio >= 0.33 ? FaceTrait.nasoLungo : FaceTrait.nasoCorto;
    return TraitLettura(tratto: t, marcatezza: _marca(ratio, 0.33, 0.09));
  }

  static TraitLettura _labbra(FaceContours c) {
    final top = _minY(c.labbroSopra);
    final bottom = _maxY(c.labbroSotto);
    final spessore = bottom - top;
    final larghezza = _Box.attorno([...c.labbroSopra, ...c.labbroSotto]).larghezza;
    final ratio = larghezza <= 0 ? 0.0 : spessore / larghezza;
    final t = ratio >= 0.34 ? FaceTrait.labbraPiene : FaceTrait.labbraSottili;
    return TraitLettura(tratto: t, marcatezza: _marca(ratio, 0.34, 0.12));
  }

  static TraitLettura _bocca(FaceContours c, double w) {
    final larghezza = _Box.attorno([...c.labbroSopra, ...c.labbroSotto]).larghezza;
    final ratio = larghezza / w;
    final t = ratio >= 0.42 ? FaceTrait.boccaLarga : FaceTrait.boccaPiccola;
    return TraitLettura(tratto: t, marcatezza: _marca(ratio, 0.42, 0.10));
  }

  static TraitLettura _mento(double wMento, double wMascella) {
    final ratio = wMascella <= 0 ? 1.0 : wMento / wMascella;
    final t = ratio >= 0.62 ? FaceTrait.mentoAmpio : FaceTrait.mentoAPunta;
    return TraitLettura(tratto: t, marcatezza: _marca(ratio, 0.62, 0.18));
  }

  static TraitLettura _mascella(double wMascella, double w) {
    final ratio = wMascella / w;
    final t =
        ratio >= 0.86 ? FaceTrait.mascellaLarga : FaceTrait.mascellaStretta;
    return TraitLettura(tratto: t, marcatezza: _marca(ratio, 0.86, 0.12));
  }

  static TraitLettura _zigomi(FaceContours c, double wZigomi, double wMascella) {
    double larghezza = wZigomi;
    if (c.guanciaSx != null && c.guanciaDx != null) {
      larghezza = (c.guanciaDx!.dx - c.guanciaSx!.dx).abs();
    }
    final ratio = wMascella <= 0 ? 1.0 : larghezza / wMascella;
    final t = ratio >= 1.04 ? FaceTrait.zigomiAlti : FaceTrait.zigomiMorbidi;
    return TraitLettura(tratto: t, marcatezza: _marca(ratio, 1.04, 0.12));
  }

  // --- Aiuti geometrici ---

  /// La marcatezza: quanto [valore] si stacca dalla [soglia], scalata su
  /// [ampiezza] e limitata a uno. Al neutro vale zero.
  static double _marca(double valore, double soglia, double ampiezza) =>
      ((valore - soglia).abs() / ampiezza).clamp(0.0, 1.0);

  static double _minY(List<Offset> p) =>
      p.map((o) => o.dy).reduce(math.min);
  static double _maxY(List<Offset> p) =>
      p.map((o) => o.dy).reduce(math.max);

  static Offset _centro(List<Offset> p) {
    var x = 0.0, y = 0.0;
    for (final o in p) {
      x += o.dx;
      y += o.dy;
    }
    return Offset(x / p.length, y / p.length);
  }

  /// La larghezza del contorno del volto in una fascia verticale, fra le frazioni
  /// [da] e [a] dell'altezza. Se nella fascia non cadono punti, ripiega sulla
  /// larghezza intera cosi' non si divide per zero.
  static double _larghezzaFascia(
      List<Offset> volto, _Box box, double da, double a) {
    final y0 = box.minY + box.altezza * da;
    final y1 = box.minY + box.altezza * a;
    final dentro = volto.where((o) => o.dy >= y0 && o.dy <= y1).toList();
    if (dentro.length < 2) return box.larghezza;
    final xs = dentro.map((o) => o.dx);
    return xs.reduce(math.max) - xs.reduce(math.min);
  }

  /// Indici di forma di un sopracciglio dal suo contorno superiore: quanto si
  /// inarca (rise, rispetto alla larghezza) e l'angolo all'apice in radianti
  /// (piu' e' piccolo, piu' l'apice e' aguzzo).
  static ({double rise, double angoloApice}) _formaSopraccio(List<Offset> p) {
    if (p.length < 3) return (rise: 0.0, angoloApice: math.pi);
    final ordinati = [...p]..sort((a, b) => a.dx.compareTo(b.dx));
    final primo = ordinati.first;
    final ultimo = ordinati.last;
    final larghezza = (ultimo.dx - primo.dx).abs();
    if (larghezza <= 0) return (rise: 0.0, angoloApice: math.pi);
    // Apice: il punto piu' in alto (y minima).
    var apice = ordinati.first;
    for (final o in ordinati) {
      if (o.dy < apice.dy) apice = o;
    }
    final yEstremi = (primo.dy + ultimo.dy) / 2;
    final rise = ((yEstremi - apice.dy) / larghezza).clamp(0.0, 2.0);
    // Angolo all'apice fra i segmenti verso i due estremi.
    final angolo = _angolo(primo, apice, ultimo);
    return (rise: rise, angoloApice: angolo);
  }

  /// L'angolo in [b] fra i segmenti b->a e b->c, in radianti.
  static double _angolo(Offset a, Offset b, Offset c) {
    final v1 = Offset(a.dx - b.dx, a.dy - b.dy);
    final v2 = Offset(c.dx - b.dx, c.dy - b.dy);
    final n1 = v1.distance, n2 = v2.distance;
    if (n1 == 0 || n2 == 0) return math.pi;
    final cos = ((v1.dx * v2.dx + v1.dy * v2.dy) / (n1 * n2)).clamp(-1.0, 1.0);
    return math.acos(cos);
  }

  /// Salienza curata delle varianti del ripiego, per far emergere un dominante
  /// deterministico dalle selezioni guidate.
  static const Map<FaceTrait, double> _salienza = {
    // Forma del volto.
    FaceTrait.voltoTondo: 0.55,
    FaceTrait.voltoQuadrato: 0.72,
    FaceTrait.voltoOvale: 0.60,
    FaceTrait.voltoTriangolare: 0.68,
    // Grandezza degli occhi.
    FaceTrait.occhiGrandi: 0.70,
    FaceTrait.occhiRaccolti: 0.58,
    // Sopracciglia.
    FaceTrait.sopraccigliaDritte: 0.50,
    FaceTrait.sopraccigliaCurve: 0.56,
    FaceTrait.sopraccigliaAngolo: 0.66,
    // Labbra.
    FaceTrait.labbraPiene: 0.64,
    FaceTrait.labbraSottili: 0.52,
    // Mento.
    FaceTrait.mentoAmpio: 0.62,
    FaceTrait.mentoAPunta: 0.60,
  };
}

/// Il riquadro attorno a un insieme di punti.
@immutable
class _Box {
  const _Box(this.minX, this.minY, this.maxX, this.maxY);

  final double minX, minY, maxX, maxY;

  double get larghezza => maxX - minX;
  double get altezza => maxY - minY;

  static _Box attorno(List<Offset> p) {
    var minX = double.infinity,
        minY = double.infinity,
        maxX = -double.infinity,
        maxY = -double.infinity;
    for (final o in p) {
      minX = math.min(minX, o.dx);
      minY = math.min(minY, o.dy);
      maxX = math.max(maxX, o.dx);
      maxY = math.max(maxY, o.dy);
    }
    if (p.isEmpty) return const _Box(0, 0, 0, 0);
    return _Box(minX, minY, maxX, maxY);
  }
}

import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/viaggio/il_velo_dell_animale.dart';
import '../../../../core/viaggio/le_sagome_in_celle.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';

/// **IL GESTO CHE SCOSTA, AL POSTO DELLA LENTE.** Ordine DI voce 10,
/// 12 settembre 2026.
///
/// **Il fondatore, sulla lente:** *"hai diviso l'immagine in strisce
/// orizzontali che fanno da maschera"*. E l'ordine: *"la maschera non e' piu'
/// geometrica. La persona passa il dito e scosta, e il bordo lo disegna la sua
/// mano: il gesto e' quello di scostare la cenere o la brina, con grana e
/// particelle che si sollevano."*
///
/// **LA CENERE STA SULLA SAGOMA VERA**, cella per cella (`LeSagome`): non su
/// un rettangolo, non su una fascia. Sotto c'e' l'illustrazione intera, e dove
/// il dito passa la cenere si solleva in particelle e lascia vedere il manto.
/// Il bordo fra scoperto e coperto e' quello del gesto: fatto di tanti granelli
/// sovrapposti, non di una linea.
///
/// **Le regole stanno in `IlVeloDellAnimale`**: un quarto del corpo per
/// discesa, la testa protetta fino alla quarta, e cio' che e' scoperto resta
/// scoperto, perche' chi monta il velo lo conserva nel Diario.
///
/// **Col `Timer` e non col controller**, per la ragione di sempre.
class IlVeloCheSiScosta extends StatefulWidget {
  const IlVeloCheSiScosta({
    super.key,
    required this.nome,
    required this.immagine,
    required this.quale,
    required this.giaScoperte,
    required this.quandoCambia,
    required this.palette,
    this.piede,
  });

  final String nome;
  final String immagine;

  /// Quante discese c'erano prima di questa: da 0 a 2 si scosta, a 3 il velo
  /// cade da solo.
  final int quale;

  /// Le celle gia' scostate nelle discese di prima, dal Diario.
  final Set<int> giaScoperte;

  /// Riceve tutte le celle scoperte, a ogni gesto finito: da conservare.
  final ValueChanged<Set<int>> quandoCambia;

  final MaestroPalette palette;

  /// Cio' che sta sotto l'istruzione, cioe' il pulsante per risalire.
  final Widget? piede;

  /// **QUANTO E' GRANDE LA MANO**, in celle: il raggio del gesto.
  static const double raggioDellaMano = 1.6;

  /// **QUANTO DURA LA CADUTA DEL VELO**, alla quarta.
  static const Duration quantoDuraLaCaduta = Duration(milliseconds: 900);

  /// **DOVE STA L'ILLUSTRAZIONE NELLA SCENA**: intera, con le sue proporzioni
  /// vere, nei tre quarti alti della scena, perche' sotto ci sono l'istruzione
  /// e il pulsante. Pubblico perche' una guardia misuri esattamente questo
  /// rettangolo e non uno suo.
  static Rect doveStaLIllustrazione(Size scena, Size misura) {
    final spazio = Size(scena.width, scena.height * 0.78);
    final k =
        math.min(spazio.width / misura.width, spazio.height / misura.height);
    return Rect.fromLTWH(
      (scena.width - misura.width * k) / 2,
      (spazio.height - misura.height * k) / 2,
      misura.width * k,
      misura.height * k,
    );
  }

  /// **QUANTO VIVE UNA PARTICELLA DI CENERE.**
  static const Duration vitaDellaParticella = Duration(milliseconds: 900);

  @override
  State<IlVeloCheSiScosta> createState() => _IlVeloCheSiScostaState();
}

class _IlVeloCheSiScostaState extends State<IlVeloCheSiScosta> {
  late final IlVeloDellAnimale _velo = IlVeloDellAnimale(widget.nome);
  late final Set<int> _scoperte = {...widget.giaScoperte};
  final Set<int> _oggi = {};
  final List<_Particella> _particelle = [];
  Offset? _ultimo;
  Timer? _battito;
  Duration _adesso = Duration.zero;
  static const Duration _passo = Duration(milliseconds: 16);

  /// Da 1, velo intero, a 0, velo caduto. Scende solo alla quarta.
  double _caduta = 1;

  /// Dove stava l'illustrazione all'ultimo disegno: serve alla caduta, che
  /// solleva la cenere senza che nessun dito le dica dove.
  Rect? _illustrazione;
  bool _sollevataLaCaduta = false;

  bool get _cadeDaSolo => widget.quale >= IlVeloDellAnimale.discesePrimaDellaTesta;

  /// **NON RESTA NIENTE DA SCOSTARE**: tutto il corpo fuori dalla testa e'
  /// gia' in chiaro. Succede alla terza discesa del Gufo e della Volpe.
  bool get _restaSoloIlVolto => _velo.scostabile.every(_scoperte.contains);

  bool get _quotaFinita =>
      _oggi.length >= _velo.perDiscesa || _restaSoloIlVolto;

  @override
  void initState() {
    super.initState();
    if (_cadeDaSolo) _accendi();
    // **LA GRANA SI PREPARA UNA VOLTA SOLA**, per tutta l'app: finche' non e'
    // pronta la cenere e' del suo colore pieno, e copre lo stesso.
    if (GranaDellaCenere.pronta == null) {
      unawaited(GranaDellaCenere.prepara().then((_) {
        if (mounted) setState(() {});
      }));
    }
  }

  @override
  void dispose() {
    _battito?.cancel();
    super.dispose();
  }

  void _accendi() {
    _battito ??= Timer.periodic(_passo, (t) {
      if (!mounted) return t.cancel();
      _adesso = _passo * t.tick;
      setState(() {
        // **ALLA QUARTA LA CENERE SI SOLLEVA TUTTA INSIEME**: una cella su tre
        // manda su i suoi granelli, e la coltre sparisce sotto di loro.
        final dove = _illustrazione;
        if (_cadeDaSolo && !_sollevataLaCaduta && dove != null) {
          _sollevataLaCaduta = true;
          for (final i in _velo.velato.difference(_scoperte)) {
            if (i % 3 == 0) _solleva(i, dove);
          }
        }
        if (_cadeDaSolo && _caduta > 0) {
          _caduta = (1 -
                  _adesso.inMilliseconds /
                      IlVeloCheSiScosta.quantoDuraLaCaduta.inMilliseconds)
              .clamp(0.0, 1.0);
        }
        _particelle.removeWhere((p) =>
            _adesso - p.nata > IlVeloCheSiScosta.vitaDellaParticella);
      });
      if ((_caduta <= 0 || !_cadeDaSolo) && _particelle.isEmpty) {
        t.cancel();
        _battito = null;
      }
    });
  }

  /// **LA MANO PASSA**: scosta le celle vicine, dalla piu' vicina, finche' la
  /// quantita' di oggi non e' finita. Fra un punto e l'altro si riempie il
  /// tragitto, o un dito veloce lascerebbe una fila di buchi.
  void _passa(Offset dito, Rect illustrazione) {
    if (_cadeDaSolo || illustrazione.isEmpty) return;
    final punto = Offset(
      (dito.dx - illustrazione.left) / illustrazione.width,
      (dito.dy - illustrazione.top) / illustrazione.height,
    );
    final da = _ultimo ?? punto;
    _ultimo = punto;
    final passi = math.max(
        1,
        ((punto - da).distance * _velo.colonne / 0.5).ceil());
    var nuove = 0;
    for (var s = 1; s <= passi; s++) {
      final p = Offset.lerp(da, punto, s / passi)!;
      for (final i in _velo.vicine(p, IlVeloCheSiScosta.raggioDellaMano)) {
        if (_quotaFinita) break;
        if (_scoperte.add(i)) {
          _oggi.add(i);
          nuove++;
          _solleva(i, illustrazione);
        }
      }
    }
    if (nuove > 0) {
      _accendi();
      setState(() {});
    }
  }

  /// **LA CENERE SI SOLLEVA**: quattro granelli per cella, che salgono e
  /// svaniscono.
  void _solleva(int i, Rect illustrazione) {
    final c = _velo.centro(i);
    final dove = Offset(illustrazione.left + c.dx * illustrazione.width,
        illustrazione.top + c.dy * illustrazione.height);
    final caso = math.Random(i * 7919 + _oggi.length);
    for (var k = 0; k < 4; k++) {
      _particelle.add(_Particella(
        da: dove +
            Offset((caso.nextDouble() - 0.5) * 10, (caso.nextDouble() - 0.5) * 10),
        verso: Offset((caso.nextDouble() - 0.5) * 40, -30 - caso.nextDouble() * 50),
        grande: 0.7 + caso.nextDouble() * 1.5,
        chiara: caso.nextDouble() < 0.45,
        nata: _adesso,
      ));
    }
  }

  void _fine() {
    _ultimo = null;
    widget.quandoCambia(Set.of(_scoperte));
  }

  @override
  Widget build(BuildContext context) {
    final misura = LeSagome.misure[widget.nome] ?? const Size(1, 1);
    final palette = widget.palette;
    return LayoutBuilder(builder: (context, vincoli) {
      final scena = Size(vincoli.maxWidth, vincoli.maxHeight);
      final illustrazione =
          IlVeloCheSiScosta.doveStaLIllustrazione(scena, misura);
      _illustrazione = illustrazione;
      final coperte = _cadeDaSolo && _caduta <= 0
          ? <int>{}
          : _velo.velato.difference(_scoperte);
      return GestureDetector(
        key: const Key('viaggio_velo_che_si_scosta'),
        behavior: HitTestBehavior.opaque,
        onPanStart: (d) => _passa(d.localPosition, illustrazione),
        onPanUpdate: (d) => _passa(d.localPosition, illustrazione),
        onPanEnd: (_) => _fine(),
        onPanCancel: _fine,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fromRect(
              rect: illustrazione,
              child: Image.asset(
                widget.immagine,
                key: const Key('viaggio_animale_vero'),
                fit: BoxFit.fill,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            Positioned.fromRect(
              rect: illustrazione,
              child: IgnorePointer(
                child: CustomPaint(
                  key: const Key('viaggio_cenere'),
                  size: Size.infinite,
                  painter: PittoreDellaCenere(
                    velo: _velo,
                    coperte: coperte,
                    quanta: _caduta,
                    grana: GranaDellaCenere.pronta,
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: CustomPaint(
                size: Size.infinite,
                painter: _PittoreDeiGranelli(
                  particelle: List.of(_particelle),
                  adesso: _adesso,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(SpacingTokens.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _cadeDaSolo
                          ? 'Oggi il velo cade da solo.'
                          : _restaSoloIlVolto
                              ? 'Resta velato soltanto il volto.'
                              : _quotaFinita
                                  ? 'Per oggi hai scostato abbastanza.'
                                  : 'Passa il dito e scosta la cenere.',
                      key: const Key('viaggio_istruzione_lente'),
                      textAlign: TextAlign.center,
                      style: TypographyTokens.etichetta().copyWith(
                          color: palette.goldSoft, letterSpacing: 1.2),
                    ),
                    if (widget.piede != null) ...[
                      const SizedBox(height: SpacingTokens.md),
                      widget.piede!,
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _Particella {
  const _Particella({
    required this.da,
    required this.verso,
    required this.grande,
    required this.chiara,
    required this.nata,
  });

  final Offset da;

  /// Punti al secondo.
  final Offset verso;
  final double grande;

  /// Una scaglia chiara o un grumo scuro: la cenere vera ha tutti e due.
  final bool chiara;
  final Duration nata;
}

/// **LA GRANA DELLA CENERE**: una piastrella che si ripete senza cuciture,
/// generata una volta sola all'apertura.
///
/// **Perche' generata e non disegnata a punti.** La prima stesura spargeva
/// sulla cenere quattro puntini chiari per cella, tutti della stessa grandezza
/// e della stessa luce: a schermo era un tessuto a pois, non polvere. Qui c'e'
/// un rumore frattale a tre ottave, cioe' toni che si addensano e si
/// diradano come in un mucchio di cenere vera, una grana fine sopra, **rare
/// scaglie chiare e pori scuri**. Periodica per costruzione: il reticolo di
/// ogni ottava si richiude su se' stesso, e la piastrella ripetuta non ha
/// bordi.
///
/// **Opaca in ogni pixel**, perche' la copertura del velo non dipende da lei:
/// la cenere copre col suo tracciato, la grana ne decide solo il colore.
abstract final class GranaDellaCenere {
  /// Il lato della piastrella, in pixel.
  static const int lato = 256;

  /// **QUANTO E' FINE**: un pixel della piastrella e' mezzo punto a schermo,
  /// cioe' poco piu' di un pixel vero su un telefono.
  static const double scala = 0.5;

  static ui.Image? _pronta;
  static Future<ui.Image>? _inCorso;

  /// La piastrella, o nulla finche' non e' pronta.
  static ui.Image? get pronta => _pronta;

  static Future<ui.Image> prepara() => _inCorso ??= () {
        final fatto = Completer<ui.Image>();
        ui.decodeImageFromPixels(
            pixel(), lato, lato, ui.PixelFormat.rgba8888, (img) {
          _pronta = img;
          fatto.complete(img);
        });
        return fatto.future;
      }();

  /// I pixel della piastrella, RGBA. Pura e sempre la stessa: una guardia la
  /// puo' leggere.
  static Uint8List pixel() {
    final caso = math.Random(20260913);
    const ottave = [(6, 0.52), (15, 0.30), (38, 0.18)];
    final reticoli = [
      for (final o in ottave)
        List<double>.generate(o.$1 * o.$1, (_) => caso.nextDouble()),
    ];
    double morbido(double t) => t * t * (3 - 2 * t);
    double rumore(List<double> v, int g, double x, double y) {
      final fx = x * g;
      final fy = y * g;
      final x0 = fx.floor();
      final y0 = fy.floor();
      final tx = morbido(fx - x0);
      final ty = morbido(fy - y0);
      double at(int a, int b) => v[(b % g) * g + (a % g)];
      final alto = at(x0, y0) + (at(x0 + 1, y0) - at(x0, y0)) * tx;
      final basso = at(x0, y0 + 1) + (at(x0 + 1, y0 + 1) - at(x0, y0 + 1)) * tx;
      return alto + (basso - alto) * ty;
    }

    const scuro = [0x15, 0x12, 0x0F];
    const chiaro = [0x4B, 0x42, 0x39];
    const scaglia = [0x93, 0x88, 0x7A];
    const poro = [0x08, 0x07, 0x06];
    final out = Uint8List(lato * lato * 4);
    for (var y = 0; y < lato; y++) {
      for (var x = 0; x < lato; x++) {
        var t = 0.0;
        for (var k = 0; k < ottave.length; k++) {
          t += rumore(reticoli[k], ottave[k].$1, x / lato, y / lato) *
              ottave[k].$2;
        }
        t = (t + (caso.nextDouble() - 0.5) * 0.22).clamp(0.0, 1.0);
        final p = caso.nextDouble();
        final o = (y * lato + x) * 4;
        for (var c = 0; c < 3; c++) {
          var v = scuro[c] + (chiaro[c] - scuro[c]) * t;
          if (p < 0.006) v = v + (scaglia[c] - v) * 0.6;
          if (p > 0.972) v = v + (poro[c] - v) * 0.8;
          out[o + c] = v.round().clamp(0, 255);
        }
        out[o + 3] = 255;
      }
    }
    return out;
  }
}

/// **IL PITTORE DELLA CENERE**, pubblico perche' una guardia lo possa
/// dipingere e contare.
///
/// **LA CENERE E' UN TRACCIATO SOLO**: ogni cella coperta vi entra intera, col
/// suo rettangolo allargato di un filo, e le celle vicine si fondono in una
/// coltre senza cuciture. Cosi' la copertura e' **per costruzione**, e non
/// per fortuna di granelli sovrapposti. Sopra, la [GranaDellaCenere].
///
/// **IL BORDO LO FANNO LE SCAGLIE.** Dove una cella coperta confina con una
/// scoperta, o col vuoto, lungo quel lato si posano tre scaglie piccole, di
/// grandezza e posto diversi secondo un seme della cella: il confine diventa
/// polvere sfrangiata, e non si vede ne' la griglia ne' un cerchio. La prima
/// stesura faceva la cenere di cerchi grandi quanto una cella, e il bordo era
/// una fila di bolle.
class PittoreDellaCenere extends CustomPainter {
  PittoreDellaCenere({
    required this.velo,
    required this.coperte,
    required this.quanta,
    this.grana,
  });

  final IlVeloDellAnimale velo;
  final Set<int> coperte;

  /// Da 1, cenere piena, a 0: la caduta della quarta discesa.
  final double quanta;

  /// La piastrella della grana, o nulla: allora la cenere e' del suo colore.
  final ui.Image? grana;

  /// **IL COLORE DELLA CENERE** quando la grana non e' ancora pronta: il tono
  /// medio della piastrella.
  static const Color cenere = Color(0xFF2E2822);

  /// **IL COLORE DEI GRANELLI CHE SI SOLLEVANO**: scaglie chiare e grumi.
  static const Color granaChiara = Color(0xFFA69B8C);
  static const Color granaScura = Color(0xFF1A1612);

  /// **IL PEZZO DI CENERE DI UNA CELLA**: il suo rettangolo, allargato di
  /// sei decimi di punto. L'allargamento chiude la cucitura fra due celle
  /// vicine, che l'antialias altrimenti lascerebbe come un filo di luce.
  static Rect pezzo(IlVeloDellAnimale velo, int i, Size size) {
    final cw = size.width / velo.colonne;
    final ch = size.height / velo.righe;
    return Rect.fromLTWH(
            (i % velo.colonne) * cw, (i ~/ velo.colonne) * ch, cw, ch)
        .inflate(0.6);
  }

  /// **LA FORMA DELLA CENERE** per [coperte], in una cenere grande [size]: il
  /// tracciato che si riempie. Pubblica perche' una guardia verifichi che
  /// contiene ogni cella coperta.
  static Path forma(IlVeloDellAnimale velo, Set<int> coperte, Size size) {
    final cw = size.width / velo.colonne;
    final ch = size.height / velo.righe;
    final lato = math.min(cw, ch);
    final p = Path();
    // **IL CUMULO SULLA TESTA**, finche' la testa e' coperta: l'ellisse del
    // velo, con nove gobbe sul contorno e una corona di scaglie, perche' sia
    // una nube di cenere e non un ovale disegnato col compasso.
    final n = velo.cumulo;
    if (n != null && coperte.any(velo.testa.contains)) {
      final c = Offset(n.centro.dx * size.width, n.centro.dy * size.height);
      final a = n.a * size.width;
      final b = n.b * size.height;
      p.addOval(Rect.fromCenter(center: c, width: a * 2, height: b * 2));
      final seme = math.Random(velo.nome.hashCode & 0x7fffffff);
      final corto = math.min(a, b);
      for (var k = 0; k < 9; k++) {
        final angolo = (k + seme.nextDouble() * 0.6) / 9 * 2 * math.pi;
        final dove = c + Offset(math.cos(angolo) * a, math.sin(angolo) * b) * 0.86;
        p.addOval(Rect.fromCircle(
            center: dove, radius: corto * (0.16 + seme.nextDouble() * 0.14)));
      }
      for (var k = 0; k < 90; k++) {
        final angolo = seme.nextDouble() * 2 * math.pi;
        final fuori = 0.97 + seme.nextDouble() * 0.12;
        final dove =
            c + Offset(math.cos(angolo) * a, math.sin(angolo) * b) * fuori;
        p.addOval(Rect.fromCircle(
            center: dove, radius: lato * (0.12 + seme.nextDouble() * 0.3)));
      }
    }
    for (final i in coperte) {
      final r = i ~/ velo.colonne;
      final c = i % velo.colonne;
      final cella = Rect.fromLTWH(c * cw, r * ch, cw, ch);
      p.addRect(pezzo(velo, i, size));
      // Le scaglie sui lati esposti: sopra, destra, sotto, sinistra.
      const lati = [(0, -1), (1, 0), (0, 1), (-1, 0)];
      for (var l = 0; l < 4; l++) {
        final (dc, dr) = lati[l];
        final vc = c + dc;
        final vr = r + dr;
        final dentro =
            vc >= 0 && vc < velo.colonne && vr >= 0 && vr < velo.righe;
        if (dentro && coperte.contains(vr * velo.colonne + vc)) continue;
        final seme = math.Random(i * 4 + l);
        for (var k = 0; k < 3; k++) {
          final lungo = seme.nextDouble();
          final fuori = (seme.nextDouble() * 0.28 - 0.08) * lato;
          final raggio = (0.09 + seme.nextDouble() * 0.2) * lato;
          final bordo = switch (l) {
            0 => Offset(cella.left + cella.width * lungo, cella.top - fuori),
            1 => Offset(cella.right + fuori, cella.top + cella.height * lungo),
            2 => Offset(cella.left + cella.width * lungo, cella.bottom + fuori),
            _ => Offset(cella.left - fuori, cella.top + cella.height * lungo),
          };
          p.addOval(Rect.fromCircle(center: bordo, radius: raggio));
        }
      }
    }
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (quanta <= 0 || coperte.isEmpty) return;
    final colore = Paint()..color = cenere.withValues(alpha: quanta);
    final g = grana;
    if (g != null) {
      colore.shader = ImageShader(g, TileMode.repeated, TileMode.repeated,
          Matrix4.diagonal3Values(
                  GranaDellaCenere.scala, GranaDellaCenere.scala, 1)
              .storage);
    }
    canvas.drawPath(forma(velo, coperte, size), colore);
  }

  @override
  bool shouldRepaint(PittoreDellaCenere vecchio) =>
      vecchio.quanta != quanta ||
      vecchio.coperte.length != coperte.length ||
      vecchio.grana != grana;
}

class _PittoreDeiGranelli extends CustomPainter {
  _PittoreDeiGranelli({required this.particelle, required this.adesso});

  final List<_Particella> particelle;
  final Duration adesso;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particelle) {
      final t = (adesso - p.nata).inMilliseconds / 1000;
      final vita = t / (IlVeloCheSiScosta.vitaDellaParticella.inMilliseconds / 1000);
      if (vita >= 1 || vita < 0) continue;
      final dove = p.da + p.verso * t + Offset(0, 18 * t * t);
      canvas.drawCircle(
        dove,
        p.grande * (1 - 0.4 * vita),
        Paint()
          ..color = (p.chiara
                  ? PittoreDellaCenere.granaChiara
                  : PittoreDellaCenere.granaScura)
              .withValues(alpha: 0.8 * (1 - vita)),
      );
    }
  }

  @override
  bool shouldRepaint(_PittoreDeiGranelli vecchio) => true;
}

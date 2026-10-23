import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/magic/intention_sigil.dart';
import '../../../../core/sensi/palette_sensoriale.dart';
import '../../../../design_system/tokens/color_tokens.dart';

/// **IL COLORE DI UNA VIA**, in un punto solo: la schermata, il Libro e lo
/// sfondo del telefono lo leggono da qui.
Color coloreDellaVia(ViaMagica via) => switch (via) {
      ViaMagica.rossa => const Color(0xFFD9563B),
      ViaMagica.bianca => const Color(0xFFE8E4F0),
      ViaMagica.verde => const Color(0xFF3FA07A),
    };

/// **IL COLORE DEL NOME DI UNA VIA**, schiarito: sulla scheda rossa di
/// Caligo il rosso della Via Rossa, scritto pieno, si leggeva appena. Alla
/// prova sul telefono del 15 settembre 2026.
Color coloreDelNomeDellaVia(ViaMagica via) =>
    Color.lerp(coloreDellaVia(via), Colors.white, 0.35)!;

/// **IL SEGNO IN MINIATURA**, nel Libro: il segno su un disco scuro. Alla
/// prova sul telefono il segno spento della Via Rossa, rosso su una scheda
/// rossa e sottile mezzo pixel, non si vedeva: e il Libro deve far
/// *rivedere il segno*, voce DO.06.
class SegnoInMiniatura extends StatelessWidget {
  const SegnoInMiniatura({
    super.key,
    required this.cammino,
    required this.colore,
    required this.luce,
    required this.lato,
  });

  final List<Offset> cammino;
  final Color colore;
  final double luce;
  final double lato;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: lato,
      height: lato,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ColorTokens.neutralDeepest.withValues(alpha: 0.85),
      ),
      child: CustomPaint(
        size: Size(lato, lato),
        painter: SegnoDelSigilloPainter(
          cammino: cammino,
          colore: colore,
          luce: luce,
        ),
      ),
    );
  }
}

/// **IL SEGNO CHE SI ACCENDE.** Ordine DO voce 03, 15 settembre 2026.
///
/// Il segno del sigillo senza la ruota, dipinto con la sua [luce], da 0
/// (spento, com'e' alla nascita) a 1 (pieno). **A ogni carica diventa piu'
/// luminoso e piu' inciso**: il tratto si fa piu' largo e piu' opaco,
/// l'alone cresce, e un'ombra scura sotto il tratto con un filo chiaro sopra
/// lo fanno sembrare scavato. Nessuna barra, nessun numero: la ricompensa e'
/// che il segno si vede meglio.
///
/// **La luce a schermo e' la radice di quella del sigillo.** Con sette
/// cariche per la luce piena, la prima vale un settimo: dipinta cosi' com'e'
/// non si vedrebbe, e la voce DO.13 chiede *"una carica che cambia
/// visibilmente il segno"*. La radice da' alla prima carica un terzo abbondante
/// del cammino, e alle ultime un passo piu' corto: e' come si accende una cosa
/// vera.
class SegnoDelSigilloPainter extends CustomPainter {
  SegnoDelSigilloPainter({
    required this.cammino,
    required this.colore,
    required this.luce,
    this.ripercorsi = 0,
    this.dito,
    this.oro = const Color(0xFFE6C77A),
  });

  final List<Offset> cammino;
  final Color colore;

  /// Da 0 a 1, come la calcola `SigilloVivo.luceA`.
  final double luce;

  /// Quanti punti del cammino il dito ha gia' ripercorso, durante la carica.
  final int ripercorsi;

  /// Dove sta il dito adesso, per il tratto che lo segue.
  final Offset? dito;

  final Color oro;

  /// **LA LARGHEZZA DEL TRATTO**, frazione del lato che cresce con la luce,
  /// **MAI SOTTO UN PIXEL E MEZZO**: nelle miniature del Libro, a settanta
  /// punti, la frazione del lato dava mezzo pixel, alla prova sul telefono.
  static double larghezzaDelTratto(double lato, double luce) =>
      math.max(lato * (0.008 + 0.008 * visibile(luce)), 1.5);

  /// La luce che si vede, da quella del sigillo.
  static double visibile(double luce) => math.sqrt(luce.clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    dipingi(canvas, Offset.zero & size, cammino, colore, luce);
    if (ripercorsi > 0 && cammino.length >= 2) {
      // IL TRATTO DEL DITO, in oro sopra il segno: si vede fin dove si e'
      // arrivati, e dove si deve andare dopo.
      Offset p(Offset n) => Offset(n.dx * size.width, n.dy * size.height);
      final path = Path()..moveTo(p(cammino[0]).dx, p(cammino[0]).dy);
      for (var i = 1; i < ripercorsi && i < cammino.length; i++) {
        path.lineTo(p(cammino[i]).dx, p(cammino[i]).dy);
      }
      if (dito != null && ripercorsi < cammino.length) {
        path.lineTo(dito!.dx, dito!.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.014
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = oro.withValues(alpha: 0.85),
      );
      if (ripercorsi < cammino.length) {
        // Il prossimo punto da raggiungere, appena accennato.
        canvas.drawCircle(
          p(cammino[ripercorsi]),
          size.width * 0.03,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = oro.withValues(alpha: 0.6),
        );
      }
    }
  }

  /// **IL DISEGNO DEL SEGNO**, in un [box] qualsiasi: la schermata lo usa a
  /// trecento punti, lo sfondo del telefono a ottocento pixel. Le misure
  /// sono frazioni del lato, cosi' il segno e' lo stesso a ogni scala.
  static void dipingi(
    Canvas canvas,
    Rect box,
    List<Offset> cammino,
    Color colore,
    double luce,
  ) {
    if (cammino.length < 2) return;
    final l = box.width;
    final v = visibile(luce);
    Offset p(Offset n) =>
        Offset(box.left + n.dx * box.width, box.top + n.dy * box.height);
    final punti = [for (final n in cammino) p(n)];
    final path = Path()..moveTo(punti.first.dx, punti.first.dy);
    for (final q in punti.skip(1)) {
      path.lineTo(q.dx, q.dy);
    }

    final largo = larghezzaDelTratto(l, luce);
    Paint tratto(Color c, double w) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = c;

    // L'ALONE, che cresce con la luce.
    if (v > 0) {
      canvas.drawPath(
        path,
        tratto(colore.withValues(alpha: 0.10 + 0.40 * v), largo * 3.2)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, l * 0.018 * v + 1),
      );
    }
    // L'INCISIONE: l'ombra scura spostata in basso a destra.
    final spostamento = Offset(l * 0.004, l * 0.004) * v;
    canvas.save();
    canvas.translate(spostamento.dx, spostamento.dy);
    canvas.drawPath(
        path, tratto(Colors.black.withValues(alpha: 0.55 * v), largo * 1.1));
    canvas.restore();
    // IL TRATTO.
    canvas.drawPath(
        path, tratto(colore.withValues(alpha: 0.42 + 0.58 * v), largo));
    // IL FILO CHIARO sopra il tratto, che fa il bordo dello scavo.
    if (v > 0) {
      canvas.drawPath(
          path,
          tratto(
              Color.lerp(colore, Colors.white, 0.55)!
                  .withValues(alpha: 0.55 * v),
              largo * 0.32));
    }

    // Il capo e la coda, la convenzione dei sigilli di Spare: un cerchietto
    // dove parte, una barra dove finisce.
    final segno =
        tratto(colore.withValues(alpha: 0.42 + 0.58 * v), largo * 0.8);
    canvas.drawCircle(punti.first, l * 0.016, segno);
    final a = punti[punti.length - 2];
    final b = punti.last;
    final d = (b - a).distance;
    if (d > 0) {
      final n = Offset(-(b.dy - a.dy) / d, (b.dx - a.dx) / d);
      canvas.drawLine(b - n * (l * 0.022), b + n * (l * 0.022), segno);
    }
  }

  @override
  bool shouldRepaint(SegnoDelSigilloPainter old) =>
      old.luce != luce ||
      old.ripercorsi != ripercorsi ||
      old.dito != dito ||
      old.cammino != cammino ||
      old.colore != colore;
}

/// **LA CARICA COL GESTO.** Ordine DO voce 03.
///
/// Si ripercorre col dito il tracciato, dal cerchietto alla barra, passando
/// per ogni punto nell'ordine: il gesto dura pochi secondi. **Se il dito si
/// stacca prima della fine si riparte dal capo**, perche' ripercorrere vuol
/// dire seguire il cammino intero e non toccarne dei pezzi.
///
/// Non chiama nessun modello, quindi non costa e non ha limiti: il limite di
/// una carica al giorno lo tiene il Libro.
class CaricaColDito extends StatefulWidget {
  const CaricaColDito({
    super.key,
    required this.cammino,
    required this.colore,
    required this.luce,
    required this.onCompiuta,
    this.attiva = true,
  });

  final List<Offset> cammino;
  final Color colore;
  final double luce;
  final VoidCallback onCompiuta;

  /// Falso quando oggi la carica e' gia' stata fatta: il segno si guarda e
  /// basta.
  final bool attiva;

  /// **QUANTO VICINO AL PUNTO DEVE PASSARE IL DITO**, in frazione del lato.
  /// Due lettere vicine sulla ruota stanno a 0,11 l'una dall'altra: a 0,09
  /// il dito le distingue senza dover essere un bisturi.
  static const double tolleranza = 0.09;

  @override
  State<CaricaColDito> createState() => _CaricaColDitoState();
}

class _CaricaColDitoState extends State<CaricaColDito> {
  int _ripercorsi = 0;
  Offset? _dito;
  Size _misura = Size.zero;

  bool _vicino(Offset posizione, int indice) {
    final n = widget.cammino[indice];
    final q = Offset(n.dx * _misura.width, n.dy * _misura.height);
    return (posizione - q).distance <= CaricaColDito.tolleranza * _misura.width;
  }

  void _inizio(Offset posizione) {
    if (!widget.attiva || widget.cammino.length < 2) return;
    setState(() {
      _ripercorsi = _vicino(posizione, 0) ? 1 : 0;
      _dito = posizione;
    });
  }

  void _muovi(Offset posizione) {
    if (!widget.attiva || _ripercorsi == 0) return;
    var r = _ripercorsi;
    while (r < widget.cammino.length && _vicino(posizione, r)) {
      r++;
    }
    setState(() {
      _ripercorsi = r;
      _dito = posizione;
    });
    if (r == widget.cammino.length) {
      // Dalla porta unica dell'aptica, che conosce l'interruttore del
      // silenzio: ordine CQ voce 1.08.
      unawaited(PaletteSensoriale.vibra(context, SchemaAptico.conferma));
      widget.onCompiuta();
      setState(() {
        _ripercorsi = 0;
        _dito = null;
      });
    }
  }

  void _fine() {
    if (_ripercorsi == 0 && _dito == null) return;
    setState(() {
      _ripercorsi = 0;
      _dito = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(builder: (context, vincoli) {
        _misura = Size(vincoli.maxWidth, vincoli.maxWidth);
        return Semantics(
          label: widget.attiva
              ? 'Il tuo sigillo. Ripassalo col dito per caricarlo.'
              : 'Il tuo sigillo.',
          // Chi usa il lettore di schermo non puo' seguire un tracciato col
          // dito: il tocco doppio del lettore vale la carica.
          onTap: widget.attiva ? widget.onCompiuta : null,
          // **IL DITO VINCE SULLO SCORRIMENTO.** La scheda e' una lista che
          // scorre in verticale, e il riconoscitore dello scorrimento
          // decide dopo diciotto pixel mentre quello del trascinamento ne
          // aspetta trentasei: senza questo, ogni tratto verticale del
          // segno avrebbe fatto scorrere la pagina invece di caricarlo.
          child: RawGestureDetector(
            key: const Key('sigillo_carica_gesto'),
            gestures: {
              _TrascinamentoSubito:
                  GestureRecognizerFactoryWithHandlers<_TrascinamentoSubito>(
                () => _TrascinamentoSubito(),
                (r) {
                  r.dragStartBehavior = DragStartBehavior.down;
                  r.onStart = (d) => _inizio(d.localPosition);
                  r.onUpdate = (d) => _muovi(d.localPosition);
                  r.onEnd = (_) => _fine();
                  r.onCancel = _fine;
                },
              ),
            },
            child: CustomPaint(
              key: const Key('sigillo_segno'),
              size: _misura,
              painter: SegnoDelSigilloPainter(
                cammino: widget.cammino,
                colore: widget.colore,
                luce: widget.luce,
                ripercorsi: _ripercorsi,
                dito: _dito,
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Un trascinamento che si prende il dito appena lo tocca, prima che lo
/// scorrimento della lista possa reclamarlo.
class _TrascinamentoSubito extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}

/// **IL SIGILLO COME SFONDO DEL TELEFONO.** Ordine DO voce 07.
///
/// Il fondo e' quello della via del sigillo, consegnato dal fondatore: 1440
/// per 3200, con la fascia centrale vuota e scura e il logo in basso. Il
/// segno si compone **nella fascia fra il 35 e il 60 per cento
/// dell'altezza**, centrato, **largo al massimo il 55 per cento**: sopra
/// c'e' l'orologio del sistema, sotto arrivano le notifiche.
///
/// **L'INTENZIONE SCRITTA NON COMPARE MAI SULL'IMMAGINE**, per nessun motivo:
/// qui non si scrive nessun testo, e la guardia lo pretende.
abstract final class LoSfondoDelSigillo {
  static const double fasciaDa = 0.35;
  static const double fasciaA = 0.60;
  static const double larghezzaMassima = 0.55;

  static String fondoPer(ViaMagica via) =>
      'assets/img/sigillo/fondi/fondo_via_${via.name}_v1.webp';

  /// Il quadrato dove sta il segno: il piu' grande che entra nella fascia e
  /// nel 55 per cento della larghezza, centrato su entrambe.
  static Rect riquadroDelSegno(Size fondo) {
    final altezzaFascia = fondo.height * (fasciaA - fasciaDa);
    final lato = math.min(fondo.width * larghezzaMassima, altezzaFascia);
    final centro =
        Offset(fondo.width / 2, fondo.height * (fasciaDa + fasciaA) / 2);
    return Rect.fromCenter(center: centro, width: lato, height: lato);
  }

  /// **IL CERCHIO COME CORNICE, E IL GLIFO PIU' GRANDE.** Parole del
  /// fondatore alla prova della 2263 in costruzione, 15 settembre 2026:
  /// *"Il glifo dovra' essere piu' grande e, visivamente, meglio se avra' un
  /// cerchio come cornice. Buttato li' cosi', sembra uno scarabocchio"*.
  ///
  /// La cornice prende tutta la misura che la voce DO.07 concede, il 55 per
  /// cento della larghezza dentro la fascia: un anello nel colore della via
  /// con un filo interno, come nei sigilli incisi, e un alone leggero. Il
  /// cammino, che sulla ruota sta a 0,38 dal centro, si allarga fino a
  /// [raggioDelCammino] della cornice: prima occupava il 42 per cento della
  /// larghezza, adesso il 47, e l'anello lo chiude.
  static const double raggioDellaCornice = 0.475;
  static const double raggioDelCammino = 0.415;

  /// Il riquadro in cui dipingere il cammino perche' i suoi punti cadano a
  /// [raggioDelCammino] del lato della cornice.
  static Rect riquadroDelCammino(Rect cornice) {
    final lato = cornice.width * raggioDelCammino / 0.38;
    return Rect.fromCenter(center: cornice.center, width: lato, height: lato);
  }

  static void dipingiLaCornice(Canvas tela, Rect cornice, Color colore) {
    final centro = cornice.center;
    final l = cornice.width;
    final raggio = l * raggioDellaCornice;
    final chiaro = Color.lerp(colore, Colors.white, 0.3)!;
    // L'alone, largo e tenue.
    tela.drawCircle(
      centro,
      raggio,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = l * 0.02
        ..color = chiaro.withValues(alpha: 0.22)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, l * 0.012),
    );
    // L'anello.
    tela.drawCircle(
      centro,
      raggio,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = l * 0.006
        ..color = chiaro.withValues(alpha: 0.85),
    );
    // Il filo interno, sottile: e' il bordo del sigillo inciso.
    tela.drawCircle(
      centro,
      raggio - l * 0.022,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = l * 0.0025
        ..color = chiaro.withValues(alpha: 0.45),
    );
  }

  /// **COMPONE L'IMMAGINE**, alla misura del fondo. Il segno va a luce
  /// piena: sullo sfondo deve leggersi sotto l'orologio, e tenerlo sotto gli
  /// occhi e' gia' il modo in cui si carica.
  static Future<ui.Image> componi({
    required ViaMagica via,
    required List<Offset> cammino,
    AssetBundle? bundle,
  }) async {
    final dati = await (bundle ?? rootBundle).load(fondoPer(via));
    final codec = await ui.instantiateImageCodec(dati.buffer.asUint8List());
    final fondo = (await codec.getNextFrame()).image;
    final misura = Size(fondo.width.toDouble(), fondo.height.toDouble());
    final registratore = ui.PictureRecorder();
    final tela = Canvas(registratore);
    tela.drawImage(fondo, Offset.zero, Paint());
    final riquadro = riquadroDelSegno(misura);
    dipingiLaCornice(tela, riquadro, coloreDellaVia(via));
    SegnoDelSigilloPainter.dipingi(
        tela, riquadroDelCammino(riquadro), cammino, coloreDellaVia(via), 1);
    final immagine =
        await registratore.endRecording().toImage(fondo.width, fondo.height);
    fondo.dispose();
    return immagine;
  }

  static Future<Uint8List> png({
    required ViaMagica via,
    required List<Offset> cammino,
    AssetBundle? bundle,
  }) async {
    final immagine = await componi(via: via, cammino: cammino, bundle: bundle);
    final dati = await immagine.toByteData(format: ui.ImageByteFormat.png);
    immagine.dispose();
    return dati!.buffer.asUint8List();
  }
}

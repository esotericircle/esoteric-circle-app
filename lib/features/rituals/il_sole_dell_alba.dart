import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// **L'INGRESSO DEL SOLE, davanti all'Arcano dell'Alba.** Ordine EL, 25
/// settembre 2026.
///
/// Il fondatore: *"l'ingresso del dono doveva essere lo stesso del precedente
/// ovvero l'utente che col dito alza il sole verso il cielo e la scena si
/// illumina, era già fatto e funzionava"*. Era il gesto del Rito dell'Alba,
/// nato col commit `bf5661e9` del 15 luglio 2026 e vissuto in
/// `lib/features/rituals/dawn_rite_screen.dart` fino al commit `8a19e6b8`
/// (righe 252-293 il gesto, 571-621 la scena col suo invito, 727-789 l'invito,
/// 804-946 il pittore). L'ordine DT, commit `47b3c2be` del 17 settembre 2026,
/// ha cancellato quella schermata intera per fare posto all'Arcano dell'Alba,
/// e il gesto se n'e' andato con lei.
///
/// **E' LO STESSO MOTORE, rimesso com'era**: il cielo passa dalla notte al
/// giorno, il sole sale dall'orizzonte al posto della luna in additivo, il
/// mare lo copre sull'orizzonte e si accende il riflesso. Trascinare in alto
/// per 220 punti lo alza del tutto; oltre la meta' abbondante, al rilascio,
/// l'alba si compie da sola; un tocco o un tocco prolungato la compie comunque,
/// che e' il ripiego tattile universale. Riduci Movimento lo rispetta.
///
/// Quando il sole e' salito la scena resta illuminata un attimo e poi chiama
/// [onSorto]: da li' in avanti l'Arcano dell'Alba e' quello di prima, senza
/// cambiamenti.
class IlSoleDellAlba extends StatefulWidget {
  const IlSoleDellAlba({
    super.key,
    required this.palette,
    required this.onSorto,
  });

  final MaestroPalette palette;

  /// Il sole e' salito e la scena si e' illuminata.
  final VoidCallback onSorto;

  /// Quanto resta illuminata la scena prima che arrivino le carte.
  static const Duration luceFerma = Duration(milliseconds: 450);

  @override
  State<IlSoleDellAlba> createState() => _IlSoleDellAlbaState();
}

class _IlSoleDellAlbaState extends State<IlSoleDellAlba>
    with TickerProviderStateMixin {
  // Livello di sollevamento dell'alba, da 0 (velato) a 1 (alba sollevata).
  double _progresso = 0;
  bool _compiuto = false;

  // Anima il completamento del gesto, o il ritorno se rilasciato troppo presto.
  late final AnimationController _alzata;
  Animation<double>? _versoIlCielo;

  // Deriva lenta e brillio del riflesso, ambiente, ferma sotto Riduci Movimento.
  late final AnimationController _ambiente;

  // I tre livelli del motore del sorgere, decodificati come immagini vere per
  // comporli in un solo canvas con i blend giusti (il sole in additivo).
  ui.Image? _notte;
  ui.Image? _giorno;
  ui.Image? _sole;

  // Distanza di trascinamento verso l'alto che solleva del tutto l'alba.
  static const double _corsa = 220;
  // Oltre questa soglia, al rilascio, l'alba si compie da sola.
  static const double _soglia = 0.55;

  @override
  void initState() {
    super.initState();
    _alzata = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..addListener(() {
        final verso = _versoIlCielo;
        if (verso != null) setState(() => _progresso = verso.value);
      });
    _ambiente = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
    unawaited(_caricaLivelli());
  }

  Future<void> _caricaLivelli() async {
    try {
      final immagini = await Future.wait([
        _risolvi('assets/ritual_backgrounds/dawn_sky_night.png'),
        _risolvi('assets/ritual_backgrounds/dawn_sky_day.png'),
        _risolvi('assets/ritual_backgrounds/dawn_sun.png'),
      ]);
      if (!mounted) return;
      setState(() {
        _notte = immagini[0];
        _giorno = immagini[1];
        _sole = immagini[2];
      });
    } catch (errore) {
      // Se un livello non si decodifica il motore resta senza immagini e non
      // disegna nulla: il gesto funziona lo stesso e le carte arrivano.
      debugPrint(
          'ARCANO DELL\'ALBA: la scena del sole non si carica ($errore)');
    }
  }

  // Risolve un asset in una ui.Image passando dal framework, cosi' sfrutta la
  // cache immagini e resta decodificabile anche in un test dopo precacheImage.
  Future<ui.Image> _risolvi(String asset) {
    final finito = Completer<ui.Image>();
    final flusso = AssetImage(asset).resolve(const ImageConfiguration());
    late final ImageStreamListener ascolto;
    ascolto = ImageStreamListener(
      (info, _) {
        if (!finito.isCompleted) finito.complete(info.image);
        flusso.removeListener(ascolto);
      },
      onError: (errore, traccia) {
        if (!finito.isCompleted) finito.completeError(errore);
        flusso.removeListener(ascolto);
      },
    );
    flusso.addListener(ascolto);
    return finito.future;
  }

  @override
  void dispose() {
    _alzata.dispose();
    _ambiente.dispose();
    _notte?.dispose();
    _giorno?.dispose();
    _sole?.dispose();
    super.dispose();
  }

  bool get _ridotto => MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  void _trascina(DragUpdateDetails d) {
    if (_compiuto) return;
    _alzata.stop();
    setState(() {
      // Trascinare verso l'alto (delta negativo) solleva l'alba.
      _progresso =
          (_progresso - (d.primaryDelta ?? 0) / _corsa).clamp(0.0, 1.0);
    });
  }

  void _lascia(DragEndDetails _) {
    if (_compiuto) return;
    if (_progresso >= _soglia) {
      _compi();
    } else {
      _portaA(0);
    }
  }

  // Ripiego tattile universale: un tocco, o un tocco prolungato, compie l'alba.
  void _tocca() {
    if (_compiuto) return;
    _compi();
  }

  void _compi() {
    _compiuto = true;
    if (_ridotto) {
      setState(() => _progresso = 1);
      unawaited(_illuminata());
      return;
    }
    _portaA(1, poi: _illuminata);
  }

  void _portaA(double meta, {Future<void> Function()? poi}) {
    _versoIlCielo = Tween<double>(begin: _progresso, end: meta).animate(
      CurvedAnimation(parent: _alzata, curve: Curves.easeOutCubic),
    );
    _alzata.forward(from: 0).then((_) {
      if (mounted && poi != null) unawaited(poi());
    });
  }

  /// La scena illuminata resta un attimo, poi arrivano le carte.
  Future<void> _illuminata() async {
    await Future<void>.delayed(IlSoleDellAlba.luceFerma);
    if (mounted) widget.onSorto();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Il motore del sorgere a livelli, composto in un solo canvas cosi' i
        // blend sono corretti: cielo notte-giorno in dissolvenza, sole in
        // additivo, mare davanti che lo copre sull'orizzonte, riflesso e luna
        // che svanisce.
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: Listenable.merge([_alzata, _ambiente]),
              builder: (context, _) => CustomPaint(
                key: const Key('arcano_alba_scena_del_sole'),
                size: Size.infinite,
                painter: PittoreDellAlba(
                  progresso: _progresso,
                  ambiente: _ridotto ? 0 : _ambiente.value,
                  ridotto: _ridotto,
                  notte: _notte,
                  giorno: _giorno,
                  sole: _sole,
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Semantics(
            button: true,
            label: 'Solleva l\'alba. Trascina verso l\'alto, oppure tocca.',
            onTap: _tocca,
            child: GestureDetector(
              key: const Key('arcano_alba_sole'),
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: _trascina,
              onVerticalDragEnd: _lascia,
              onTap: _tocca,
              onLongPress: _tocca,
              child: _compiuto
                  ? const SizedBox.expand()
                  : Align(
                      // In alto sul cielo notturno, libero dal sole che invita
                      // a sorgere sull'orizzonte, in basso.
                      alignment: const Alignment(0, -0.4),
                      child: _InvitoAlGesto(
                          palette: palette, progresso: _progresso),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

/// L'invito al gesto, che si accende man mano che l'alba si solleva.
class _InvitoAlGesto extends StatelessWidget {
  const _InvitoAlGesto({required this.palette, required this.progresso});

  final MaestroPalette palette;
  final double progresso;

  @override
  Widget build(BuildContext context) {
    // **NIENTE VELO DIETRO L'INVITO. Ordine AS voce 06.** Un gradiente radiale
    // dentro un rettangolo lasciava i quattro angoli piu' scuri del centro, e
    // si vedeva un riquadro appoggiato sulla scena. La riga ha la sua pillola
    // scura, che e' un contenitore voluto e con un bordo.
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg, vertical: SpacingTokens.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.keyboard_double_arrow_up_rounded,
              color: palette.goldSoft.withValues(alpha: 0.6 + 0.4 * progresso),
              size: 26),
          const SizedBox(height: SpacingTokens.sm),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
              color: palette.deepest.withValues(alpha: 0.5),
              border: Border.all(color: palette.gold.withValues(alpha: 0.5)),
            ),
            // **UNA RIGA SOLA, ordine AS voce 06**: la via col dito e il
            // tocco stanno nella stessa riga.
            child: Text(
              'Trascina in alto, oppure tocca',
              key: const Key('alba_invito_al_gesto'),
              textAlign: TextAlign.center,
              style: TypographyTokens.lettura()
                  .copyWith(color: palette.goldSoft, letterSpacing: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

/// **IL MOTORE DEL SORGERE**, a livelli, composto in un solo canvas cosi' i
/// blend restano corretti. E' quello del Rito dell'Alba, commit `8a19e6b8`.
///
/// Dal fondo alla superficie: il cielo che passa in dissolvenza dalla scena
/// notturna a quella diurna, e con esso la luna svanisce; il sole in blend
/// additivo che emerge dall'orizzonte e sale fino al posto della luna; il mare
/// davanti che ne copre la parte bassa e passa anch'esso da notte a giorno; il
/// riflesso dorato che si accende sul mare. A progresso zero mostra solo mezzo
/// disco sull'orizzonte, come invito.
class PittoreDellAlba extends CustomPainter {
  PittoreDellAlba({
    required this.progresso,
    required this.ambiente,
    required this.ridotto,
    required this.notte,
    required this.giorno,
    required this.sole,
  });

  /// Da 0, notte col sole sull'orizzonte, a 1, giorno col sole alto.
  final double progresso;
  final double ambiente;
  final bool ridotto;
  final ui.Image? notte;
  final ui.Image? giorno;
  final ui.Image? sole;

  // Notte e giorno hanno lo stesso formato e lo stesso orizzonte; la luna sta
  // al punto dove il sole si ferma.
  static const double _scenaL = 704;
  static const double _scenaA = 1520;
  static const double _orizzonte = 0.4993;
  static const double _lunaX = 0.462;
  static const double _lunaY = 0.210;
  // Frazione della larghezza dell'immagine del sole occupata dal disco.
  static const double _disco = 0.171;

  @override
  void paint(Canvas canvas, Size size) {
    final notte = this.notte, giorno = this.giorno, sole = this.sole;
    if (notte == null || giorno == null || sole == null) return;
    final p = progresso.clamp(0.0, 1.0);
    final w = size.width, h = size.height;

    final scala = math.max(w / _scenaL, h / _scenaA);
    final dstW = _scenaL * scala, dstH = _scenaA * scala;
    final dstL = (w - dstW) / 2, dstT = (h - dstH) / 2;
    const src = Rect.fromLTWH(0, 0, _scenaL, _scenaA);
    final dst = Rect.fromLTWH(dstL, dstT, dstW, dstH);
    final orizzonteY = dstT + _orizzonte * dstH;
    Offset punto(double fx, double fy) =>
        Offset(dstL + fx * dstW, dstT + fy * dstH);

    // Il sole sale dall'orizzonte al posto della luna.
    final salita = ridotto ? p : Curves.easeOutCubic.transform(p);
    final luna = punto(_lunaX, _lunaY);
    final centro =
        Offset(luna.dx, orizzonteY + (luna.dy - orizzonteY) * salita);
    final raggio = w * (0.135 + 0.055 * p);

    // --- Cielo: sopra l'orizzonte, notte in dissolvenza verso il giorno ---
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, w, orizzonteY));
    canvas.drawImageRect(notte, src, dst, Paint());
    if (p > 0) {
      canvas.drawImageRect(
          giorno, src, dst, Paint()..color = Colors.white.withValues(alpha: p));
    }
    canvas.restore();

    // --- Sole: additivo, il nero sparisce e l'aura si fonde ---
    _dipingiIlSole(canvas, sole, centro, raggio);

    // --- Mare: sotto l'orizzonte, davanti al sole, notte verso giorno ---
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, orizzonteY, w, h - orizzonteY));
    canvas.drawImageRect(notte, src, dst, Paint());
    if (p > 0) {
      canvas.drawImageRect(
          giorno, src, dst, Paint()..color = Colors.white.withValues(alpha: p));
    }
    _dipingiIlRiflesso(canvas, w, h, orizzonteY, centro.dx, p);
    canvas.restore();
  }

  void _dipingiIlSole(
      Canvas canvas, ui.Image sole, Offset centro, double raggio) {
    // Abbassa il cielo sotto il disco con un velo scuro morbido, che sfuma al
    // bordo: l'additivo dorato ci si posa sopra e il disco resta caldo e non
    // satura a bianco sul cielo diurno luminoso.
    canvas.drawCircle(
      centro,
      raggio * 1.02,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.black.withValues(alpha: 0.5),
            Colors.black.withValues(alpha: 0.5),
            Colors.black.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: centro, radius: raggio * 1.02)),
    );

    final sw = sole.width.toDouble(), sh = sole.height.toDouble();
    // Scala l'immagine cosi' il disco ha il raggio giusto sullo schermo. Il
    // margine nero ampio lascia i raggi liberi di estendersi senza taglio.
    final s = raggio / (_disco * sw);
    final dst = Rect.fromCenter(center: centro, width: sw * s, height: sh * s);
    canvas.drawImageRect(
      sole,
      Rect.fromLTWH(0, 0, sw, sh),
      dst,
      Paint()
        ..blendMode = BlendMode.plus
        ..color = Colors.white.withValues(alpha: 0.78),
    );
  }

  void _dipingiIlRiflesso(Canvas canvas, double w, double h, double orizzonteY,
      double cx, double p) {
    if (p <= 0.001) return;
    final brillio = ridotto ? 0.0 : math.sin(2 * math.pi * ambiente);
    final meta = w * (0.03 + 0.06 * p) * (1 + 0.06 * brillio);
    final fondo = orizzonteY + (h - orizzonteY) * (0.4 + 0.6 * p);
    final rett = Rect.fromLTRB(cx - meta, orizzonteY, cx + meta, fondo);
    canvas.drawRect(
      rett,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFE2A6).withValues(alpha: 0.6 * p),
            const Color(0x00FFE2A6),
          ],
        ).createShader(rett)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14)
        ..blendMode = BlendMode.plus,
    );
  }

  @override
  bool shouldRepaint(PittoreDellAlba old) =>
      old.progresso != progresso ||
      old.ambiente != ambiente ||
      old.ridotto != ridotto ||
      old.notte != notte ||
      old.giorno != giorno ||
      old.sole != sole;
}

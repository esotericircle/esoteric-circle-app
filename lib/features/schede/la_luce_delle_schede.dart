import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/motion/parallax_controller.dart';

/// **IL RIFLESSO DELL'ORO.** Ordine EO voce 06, 26 settembre 2026.
///
/// Il fondatore: *"1 ok"*, sulla proposta *"inclinando il telefono, un
/// riflesso luminoso scorre sul rilievo dorato, come su metallo vero"*. E la
/// regola di casa (CLAUDE.md): ogni esperienza basata su sensori ha un
/// ripiego a gesto tattile. **Dove il sensore manca, il riflesso segue lo
/// scorrimento delle righe**: la riga lo muove col dito. **Con la riduzione
/// del movimento non c'e'.**
///
/// [LaLuceDelleSchede] sta sopra le righe e legge l'inclinazione dalla
/// porta del sensore che c'e' gia', la parallasse del cielo
/// ([ParallaxController]). **Non apre una seconda iscrizione
/// all'accelerometro**: la regola della casa (`scena_unica_test`,
/// `lo_scuotimento_ha_una_porta_sola_test`) ne vuole una sola, e la prima
/// stesura di questa luce ne apriva un'altra. Finche' la parallasse non dice
/// che il sensore contribuisce, il sensore per la luce non c'e'.
class LaLuceDelleSchede extends StatefulWidget {
  const LaLuceDelleSchede(
      {super.key, required this.child, this.sensore = true});

  final Widget child;

  /// Falso nelle prove e dove non si vuole ascoltare il telefono.
  final bool sensore;

  /// **SOLO PER LA MISURA SUL TELEFONO, mai in una consegna.** Ordine EO voce
  /// 06: la misura chiede i fotogrammi al secondo col riflesso e senza, e sul
  /// Realme del collaudo le animazioni sono a zero, quindi il riflesso e' spento
  /// come l'ordine vuole. Una build compilata con
  /// `--dart-define=EO_LUCE_FORZATA=true` lo accende lo stesso, e il
  /// sollevamento della scheda al centro con lui. Senza quella riga vale falso.
  static const bool forzata = bool.fromEnvironment('EO_LUCE_FORZATA');

  /// Se riflesso e sollevamento sono spenti: con la riduzione del movimento,
  /// salvo nella build di misura.
  static bool spenta(BuildContext context) =>
      !forzata && (MediaQuery.maybeDisableAnimationsOf(context) ?? false);

  /// L'inclinazione in [-1, 1], o null quando il sensore non c'e'.
  static ValueListenable<double?>? inclinazioneDi(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_LaLuce>()?.inclinazione;

  @override
  State<LaLuceDelleSchede> createState() => _LaLuceDelleSchedeState();
}

class _LaLuceDelleSchedeState extends State<LaLuceDelleSchede> {
  final ValueNotifier<double?> _inclinazione = ValueNotifier<double?>(null);
  ParallaxController? _parallasse;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Senza parallasse (le prove che montano le righe da sole) la luce segue
    // le righe, che e' il ripiego a gesto tattile.
    final nuova = widget.sensore ? context.read<ParallaxController?>() : null;
    if (identical(nuova, _parallasse)) return;
    _parallasse?.removeListener(_leggi);
    _parallasse = nuova?..addListener(_leggi);
    _leggi();
  }

  void _leggi() {
    final p = _parallasse;
    _inclinazione.value = p != null && p.sensorActive ? p.tiltX : null;
  }

  @override
  void dispose() {
    _parallasse?.removeListener(_leggi);
    _inclinazione.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _LaLuce(inclinazione: _inclinazione, child: widget.child);
}

class _LaLuce extends InheritedWidget {
  const _LaLuce({required this.inclinazione, required super.child});

  final ValueListenable<double?> inclinazione;

  @override
  bool updateShouldNotify(_LaLuce oldWidget) =>
      oldWidget.inclinazione != inclinazione;
}

/// Lo scorrimento di una riga, fra 0 e 1: il ripiego del riflesso.
class LoScorrimentoDellaRiga extends InheritedWidget {
  const LoScorrimentoDellaRiga(
      {super.key, required this.scorrimento, required super.child});

  final ValueListenable<double> scorrimento;

  static ValueListenable<double>? di(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<LoScorrimentoDellaRiga>()
      ?.scorrimento;

  @override
  bool updateShouldNotify(LoScorrimentoDellaRiga oldWidget) =>
      oldWidget.scorrimento != scorrimento;
}

/// **IL RIFLESSO SULLA SCHEDA.** Una banda di luce diagonale che scorre
/// sull'immagine: con l'inclinazione quando c'e', con la riga quando no.
/// Si ridipinge da sola, senza ricostruire la scheda.
class IlRiflessoDellOro extends StatelessWidget {
  const IlRiflessoDellOro({super.key, required this.chiave});

  /// Sposta un poco la luce da una scheda all'altra, come su oggetti
  /// diversi sotto la stessa lampada.
  final String chiave;

  /// Lo scorrimento di chi non ha una riga: fermo.
  static final ValueNotifier<double> _fermo = ValueNotifier<double>(0.5);

  /// Dove sta la luce, fra -1 e 1, date le due fonti.
  static double posizione(
      {required double? inclinazione,
      required double scorrimento,
      required String chiave}) {
    final scarto = (chiave.hashCode % 7) / 7 * 0.5 - 0.25;
    final base =
        inclinazione != null ? inclinazione * 1.4 : scorrimento * 2 - 1;
    return (base + scarto).clamp(-1.6, 1.6);
  }

  @override
  Widget build(BuildContext context) {
    if (LaLuceDelleSchede.spenta(context)) {
      return const SizedBox.shrink();
    }
    final inclinazione = LaLuceDelleSchede.inclinazioneDi(context);
    final scorrimento = LoScorrimentoDellaRiga.di(context);
    if (inclinazione == null && scorrimento == null) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      key: Key('scheda_riflesso_$chiave'),
      child: CustomPaint(
        size: Size.infinite,
        painter: _Riflesso(
          inclinazione: inclinazione,
          scorrimento: scorrimento ?? _fermo,
          chiave: chiave,
        ),
      ),
    );
  }
}

class _Riflesso extends CustomPainter {
  _Riflesso({
    required this.inclinazione,
    required this.scorrimento,
    required this.chiave,
  }) : super(
            repaint: Listenable.merge(
                [if (inclinazione != null) inclinazione, scorrimento]));

  final ValueListenable<double?>? inclinazione;
  final ValueListenable<double> scorrimento;
  final String chiave;

  @override
  void paint(Canvas canvas, Size size) {
    final p = IlRiflessoDellOro.posizione(
      inclinazione: inclinazione?.value,
      scorrimento: scorrimento.value,
      chiave: chiave,
    );
    final centro = Offset(size.width * (0.5 + p * 0.6), size.height * 0.5);
    final banda = size.shortestSide * 0.55;
    final shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x00FFF3C4),
        Color(0x40FFF3C4),
        Color(0x00FFF3C4),
      ],
      stops: [0.0, 0.5, 1.0],
    ).createShader(
        Rect.fromCenter(center: centro, width: banda, height: banda));
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = shader
        ..blendMode = BlendMode.plus,
    );
  }

  @override
  bool shouldRepaint(_Riflesso oldDelegate) =>
      oldDelegate.chiave != chiave ||
      oldDelegate.inclinazione != inclinazione ||
      oldDelegate.scorrimento != scorrimento;
}

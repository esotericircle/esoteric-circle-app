
import 'package:flutter/material.dart';

import '../../core/sensi/ascoltatore_scuotimento.dart';
import '../../design_system/components/ritual_backdrop.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// Come si compie un rituale: con un gesto tattile universale, oppure con un
/// sensore che sul device lo arricchisce.
enum RitualGesture { tap, hold, swipe, shake }

/// Impalcatura condivisa dei rituali del giorno: livello visivo prima del testo,
/// un gesto per rivelare il responso e, sempre, un ripiego tattile universale.
///
/// Il visualizzatore sta in alto e occupa la scena; il responso si rivela sotto
/// dopo il gesto. Ogni sensore (microfono, giroscopio) e' un di piu' sul device:
/// qui il gesto tattile basta da solo, cosi' nessuno resta fuori.
class RitualView extends StatefulWidget {
  const RitualView({
    super.key,
    required this.title,
    required this.palette,
    required this.gesture,
    required this.prompt,
    required this.sensorHint,
    required this.visualBuilder,
    required this.revealed,
    this.footnote,
    this.onReveal,
    this.backgroundAsset,
  });

  final String title;
  final MaestroPalette palette;
  final RitualGesture gesture;

  /// Slot del fondale condiviso. Percorso di un asset PNG di fondale quando
  /// disponibile; null ripiega sul fondo procedurale coerente col cosmo della
  /// home. Ogni rito lo predispone: quando arriva il PNG definitivo basta
  /// cablarlo qui, senza toccare scena, stati e interazioni.
  final String? backgroundAsset;

  /// Invito al gesto, mostrato prima della rivelazione.
  final String prompt;

  /// Riga che spiega il sensore e il ripiego tattile.
  final String sensorHint;

  /// Il visualizzatore, dato lo stato di rivelazione e un valore d'animazione.
  final Widget Function(BuildContext context, bool revealed, double t)
      visualBuilder;

  /// Il responso, mostrato dopo il gesto.
  final Widget revealed;

  /// Nota onesta in coda (per esempio segnaposto d'arte o cornice culturale).
  final String? footnote;

  final VoidCallback? onReveal;

  @override
  State<RitualView> createState() => _RitualViewState();
}

class _RitualViewState extends State<RitualView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _revealed = false;
  AscoltatoreScuotimento? _scuotimento;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    if (widget.gesture == RitualGesture.shake) _listenShake();
  }

  // Scuotimento: un picco netto dell'accelerazione svela. Se il sensore manca,
  // resta il tocco come ripiego tattile universale.
  void _listenShake() {
    // LA PORTA UNICA: soglia, antirimbalzo e niente samplingPeriod stanno
    // in AscoltatoreScuotimento, con le loro ragioni scritte accanto.
    _scuotimento = AscoltatoreScuotimento(onScuotimento: _reveal)..start();
  }

  @override
  void dispose() {
    _scuotimento?.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _reveal() {
    if (_revealed) return;
    setState(() => _revealed = true);
    widget.onReveal?.call();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;

    Widget gestureWrap(Widget child) {
      switch (widget.gesture) {
        case RitualGesture.tap:
          return GestureDetector(
              key: const Key('ritual_gesture'),
              behavior: HitTestBehavior.opaque,
              onTap: _reveal,
              child: child);
        case RitualGesture.hold:
          return GestureDetector(
              key: const Key('ritual_gesture'),
              behavior: HitTestBehavior.opaque,
              onLongPress: _reveal,
              onTap: _reveal,
              child: child);
        case RitualGesture.swipe:
          return GestureDetector(
              key: const Key('ritual_gesture'),
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: (_) => _reveal(),
              onTap: _reveal,
              child: child);
        case RitualGesture.shake:
          // Lo scuotimento arriva dal sensore; il tocco e' il ripiego tattile.
          return GestureDetector(
              key: const Key('ritual_gesture'),
              behavior: HitTestBehavior.opaque,
              onTap: _reveal,
              child: child);
      }
    }

    return Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.4),
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(widget.title, style: TypographyTokens.display(size: 20)),
      ),
      body: RitualBackdrop(
        palette: palette,
        assetPath: widget.backgroundAsset,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Livello visivo, prima del testo.
              Expanded(
                flex: 5,
                child: gestureWrap(
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _pulse,
                          builder: (context, _) => widget.visualBuilder(
                              context, _revealed, _pulse.value),
                        ),
                      ),
                      if (!_revealed)
                        Positioned(
                          bottom: SpacingTokens.lg,
                          child: _PromptPill(
                              label: widget.prompt, palette: palette),
                        ),
                    ],
                  ),
                ),
              ),
              // Responso, rivelato dopo il gesto.
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                      SpacingTokens.lg, 0, SpacingTokens.lg, SpacingTokens.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_revealed)
                        Container(
                            key: const Key('ritual_content'),
                            child: widget.revealed),
                      const SizedBox(height: SpacingTokens.md),
                      _HintRow(
                          icon: Icons.touch_app_outlined,
                          text: widget.sensorHint,
                          palette: palette),
                      if (widget.footnote != null) ...[
                        const SizedBox(height: SpacingTokens.sm),
                        _HintRow(
                            icon: Icons.auto_awesome,
                            text: widget.footnote!,
                            palette: palette),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromptPill extends StatelessWidget {
  const _PromptPill({required this.label, required this.palette});

  final String label;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        color: palette.deepest.withValues(alpha: 0.5),
        border: Border.all(color: palette.gold.withValues(alpha: 0.5)),
      ),
      child: Text(label,
          style: TypographyTokens.label(size: 12)
              .copyWith(color: palette.goldSoft, letterSpacing: 0.8)),
    );
  }
}

class _HintRow extends StatelessWidget {
  const _HintRow(
      {required this.icon, required this.text, required this.palette});

  final IconData icon;
  final String text;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: palette.goldSoft),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: TypographyTokens.label(size: 11).copyWith(
                color: palette.goldSoft.withValues(alpha: 0.7),
                letterSpacing: 0.3,
                height: 1.4,
              )),
        ),
      ],
    );
  }
}

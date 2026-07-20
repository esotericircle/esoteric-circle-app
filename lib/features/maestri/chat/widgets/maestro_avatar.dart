import 'package:flutter/material.dart';

import '../../../../core/maestro/maestro.dart';
import '../../../../design_system/theme/maestro_scope.dart';

/// Avatar tondo del Maestro accanto alla bolla: un ritratto pulito e contenuto
/// nel cerchio.
///
/// Mostra il master full body ritagliato sul volto dentro un cerchio con
/// cornice d'oro. L'icona lineare di riferimento non e' piu' un fondale fisso:
/// resta solo come ultimo ripiego se l'immagine mancasse (`errorBuilder`), mai
/// visibile quando il volto c'e'. A questa misura il ritratto resta dentro il
/// tondo, senza sfondare, per non affollare il testo. In chat non c'e' lip sync
/// ne' animazioni firma: solo un cenno di speaking, l'aura che pulsa quando il
/// Maestro risponde.
class MaestroAvatar extends StatefulWidget {
  const MaestroAvatar({
    super.key,
    required this.maestro,
    this.size = 40,
    this.speaking = false,
  });

  final Maestro maestro;
  final double size;

  /// Quando vero, l'aura pulsa: il cenno di speaking mentre il Maestro risponde.
  final bool speaking;

  @override
  State<MaestroAvatar> createState() => _MaestroAvatarState();
}

class _MaestroAvatarState extends State<MaestroAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.speaking) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(MaestroAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.speaking && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.speaking && _controller.isAnimating) {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final pulse = widget.speaking ? _controller.value : 0.0;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: palette.primary.withValues(alpha: 0.5),
            border: Border.all(
              color: palette.gold.withValues(alpha: 0.6 + 0.3 * pulse),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: palette.glow.withValues(alpha: 0.25 + 0.45 * pulse),
                blurRadius: 8 + 14 * pulse,
                spreadRadius: 1 + 3 * pulse,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            widget.maestro.avatarAsset,
            fit: BoxFit.cover,
            // Bias verso l'alto: sul master full body cade sul volto.
            alignment: const Alignment(0, -0.7),
            // Ripiego solo su errore: l'icona lineare dorata al centro del
            // tondo, mai visibile quando il volto c'e'.
            errorBuilder: (context, error, stack) => Center(
              child: Icon(
                widget.maestro.icon,
                color: palette.goldSoft,
                size: widget.size * 0.5,
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'greeting_controller.dart';

/// Il saluto per nome della primissima apertura del Santuario, mostrato come
/// sottotitolo in cima. Compare una volta, si dissolve dopo qualche secondo o al
/// tocco. La voce Gemini-TTS, quando c'e', accompagna il sottotitolo sul device.
class GreetingBanner extends StatefulWidget {
  const GreetingBanner({super.key, this.name = 'Viandante'});

  final String name;

  @override
  State<GreetingBanner> createState() => _GreetingBannerState();
}

class _GreetingBannerState extends State<GreetingBanner> {
  Timer? _hideTimer;
  bool _prepared = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_prepared || !mounted) return;
      _prepared = true;
      context.read<GreetingController>().prepare(name: widget.name);
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GreetingController>();
    final text = controller.text;
    if (text == null) return const SizedBox.shrink();

    // Avvia il timer di dissolvenza una sola volta, quando il saluto compare.
    _hideTimer ??= Timer(const Duration(seconds: 6), () {
      if (mounted) context.read<GreetingController>().dismiss();
    });

    final palette = context.palette;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: GestureDetector(
          key: const Key('santuario_greeting'),
          onTap: () => context.read<GreetingController>().dismiss(),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  palette.surfaceElevated.withValues(alpha: 0.95),
                  palette.deepest.withValues(alpha: 0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
              border: Border.all(color: palette.gold.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: palette.glow.withValues(alpha: 0.3),
                  blurRadius: 18,
                  spreadRadius: -6,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.graphic_eq_rounded,
                    size: 18, color: palette.goldSoft),
                const SizedBox(width: SpacingTokens.sm),
                Flexible(
                  child: Text(
                    text,
                    style: TypographyTokens.body(size: 15).copyWith(
                      color: ColorTokens.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

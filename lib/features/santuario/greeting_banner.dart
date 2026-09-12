import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/identity/profile_controller.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../sigilli/regia_del_cammino.dart';
import 'greeting_controller.dart';

/// Il saluto per nome della primissima apertura del Santuario, mostrato come
/// striscia bassa che sale sopra la barra, cosi' non copre mai il titolo ne' la
/// figura del Maestro. Compare una volta, si dissolve dopo qualche secondo o al
/// tocco. Usa il nome reale della persona (mai il nome del tier). La voce
/// Gemini-TTS, quando c'e', accompagna il sottotitolo sul device.
class GreetingBanner extends StatefulWidget {
  const GreetingBanner({super.key, this.name});

  /// Nome con cui salutare. Se assente, si usa il nome reale del profilo.
  final String? name;

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
      final name = widget.name ?? context.read<ProfileController>().vocative;
      context.read<GreetingController>().prepare(name: name);
      // **IL NOME NEL CERCHIO MATURA QUI.** Ordine BD voce 05: "Scrivi il tuo
      // nome e il Cerchio lo custodisce" si compie quando il Cerchio lo USA,
      // cioe' al primo saluto per nome nel Santuario. Non alla fine
      // dell'onboarding, dove maturerebbe insieme alla carta: una festa sola
      // li', le altre sui gesti veri. E mai sul vocativo neutro di brand:
      // salutare "Viandante" non custodisce nessun nome.
      ProfileController? profilo;
      try {
        profilo = context.read<ProfileController>();
      } catch (profiloAssente) {
        profilo = null;
      }
      if (profilo != null && profilo.profile.hasName) {
        unawaited(RegiaDelCammino.dopoUnGesto(context, 'nome_proprio'));
      }
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
        // Sale sopra la barra inferiore, lontano dal titolo e dalla figura.
        padding: const EdgeInsets.fromLTRB(SpacingTokens.md, 0,
            SpacingTokens.md, SpacingTokens.xxl + SpacingTokens.lg),
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
                    style: TypographyTokens.corpo().copyWith(
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

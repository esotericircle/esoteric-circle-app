import 'package:flutter/material.dart';

import '../../../../core/chat/chat_message.dart';
import '../../../../core/chat/immersive_intents.dart';
import '../../../../core/maestro/maestro.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../widgets/maestro_bust.dart';
import 'astral_typing_indicator.dart';

/// Una bolla della conversazione.
///
/// Il messaggio del Maestro nasce da un piccolo avatar tondo e da una
/// superficie in vetro col filo d'oro, quello dell'utente da una tessera piu'
/// sobria allineata a destra. Mentre il Maestro compone, al posto del testo
/// pulsa l'indicatore astrale.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.maestro,
    this.onOpenIntent,
  });

  final ChatMessage message;
  final Maestro maestro;

  /// Apre la funzione immersiva instradata, dato l'id dell'intento.
  final void Function(String intentId)? onOpenIntent;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isUser = message.isUser;

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.78,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isUser
              ? [
                  palette.gold.withValues(alpha: 0.20),
                  palette.gold.withValues(alpha: 0.08),
                ]
              : [
                  palette.surfaceElevated.withValues(alpha: 0.95),
                  palette.surface.withValues(alpha: 0.80),
                ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(SpacingTokens.radiusMd),
          topRight: const Radius.circular(SpacingTokens.radiusMd),
          bottomLeft: Radius.circular(
              isUser ? SpacingTokens.radiusMd : SpacingTokens.xxs),
          bottomRight: Radius.circular(
              isUser ? SpacingTokens.xxs : SpacingTokens.radiusMd),
        ),
        border: Border.all(
          color: message.failed
              ? ColorTokens.caligoGlow.withValues(alpha: 0.5)
              : palette.gold.withValues(alpha: isUser ? 0.35 : 0.28),
          width: 1,
        ),
      ),
      child: message.pending
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: AstralTypingIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.text,
                  style: TypographyTokens.body(size: 17).copyWith(
                    color: isUser
                        ? ColorTokens.textPrimary
                        : palette.textPrimary,
                    height: 1.5,
                  ),
                ),
                if (message.intentId != null) ...[
                  const SizedBox(height: SpacingTokens.sm),
                  _IntentButton(
                    intentId: message.intentId!,
                    palette: palette,
                    onTap: () => onOpenIntent?.call(message.intentId!),
                  ),
                ],
              ],
            ),
    );

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(
            left: SpacingTokens.xl,
            top: SpacingTokens.xs,
            bottom: SpacingTokens.xs,
          ),
          child: bubble,
        ),
      );
    }

    // Maestro: il suo volto tondo piu' la bolla.
    return Padding(
      padding: const EdgeInsets.only(
        right: SpacingTokens.xl,
        top: SpacingTokens.xs,
        bottom: SpacingTokens.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stesso volto inquadrato di header e lente, ma contenuto nel tondo,
          // senza sporgenza, per non affollare il testo.
          MaestroBust(maestro: maestro, ring: 34, popOut: false),
          const SizedBox(width: SpacingTokens.xs),
          Flexible(child: bubble),
        ],
      ),
    );
  }
}

/// Il pulsante che apre la funzione immersiva instradata dalla chat.
class _IntentButton extends StatelessWidget {
  const _IntentButton({
    required this.intentId,
    required this.palette,
    required this.onTap,
  });

  final String intentId;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final intent = ImmersiveIntents.all.firstWhere((i) => i.id == intentId);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('intent_open_$intentId'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
            gradient: LinearGradient(colors: [
              palette.primary.withValues(alpha: 0.7),
              palette.surfaceElevated.withValues(alpha: 0.7),
            ]),
            border: Border.all(color: palette.gold.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 16, color: palette.goldSoft),
              const SizedBox(width: SpacingTokens.sm),
              Flexible(
                child: Text(intent.buttonLabel,
                    style: TypographyTokens.display(size: 15)
                        .copyWith(color: palette.goldSoft)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

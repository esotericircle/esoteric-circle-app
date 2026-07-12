import 'package:flutter/material.dart';

import '../../../../core/chat/chat_message.dart';
import '../../../../core/maestro/maestro.dart';
import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import 'astral_typing_indicator.dart';
import 'maestro_avatar.dart';

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
  });

  final ChatMessage message;
  final Maestro maestro;

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
          : Text(
              message.text,
              style: TypographyTokens.body(size: 17).copyWith(
                color: isUser
                    ? ColorTokens.textPrimary
                    : palette.textPrimary,
                height: 1.5,
              ),
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
          MaestroAvatar(maestro: maestro, size: 34),
          const SizedBox(width: SpacingTokens.xs),
          Flexible(child: bubble),
        ],
      ),
    );
  }
}

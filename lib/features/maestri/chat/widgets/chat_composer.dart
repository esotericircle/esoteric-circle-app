import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';

/// Barra di composizione del messaggio: campo di testo che cresce e bottone di
/// invio dorato. Disabilitata mentre il Maestro sta rispondendo.
class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.enabled,
    required this.onSend,
    this.onSuggestions,
    this.hintText = 'Scrivi a Medora',
    this.initialText,
  });

  final bool enabled;
  final ValueChanged<String> onSend;

  /// Se non nullo, a sinistra compare un controllo discreto Suggerimenti che
  /// apre il pannello. E' presente solo a conversazione avviata.
  final VoidCallback? onSuggestions;

  final String hintText;

  /// Testo con cui il campo si apre gia' scritto, quando si arriva dalla
  /// chiusura del cerchio del Consulta col tema.
  final String? initialText;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    final seed = widget.initialText?.trim() ?? '';
    if (seed.isNotEmpty) {
      _controller.text = seed;
      _hasText = true;
    }
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    widget.onSend(text);
    _controller.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final canSend = widget.enabled && _hasText;

    return Container(
      padding: EdgeInsets.only(
        left: SpacingTokens.md,
        right: SpacingTokens.md,
        top: SpacingTokens.sm,
        bottom: SpacingTokens.sm + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.deepest.withValues(alpha: 0.0),
            palette.deepest.withValues(alpha: 0.9),
            palette.deepest,
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (widget.onSuggestions != null) ...[
            _SuggestionsControl(onTap: widget.onSuggestions!),
            const SizedBox(width: SpacingTokens.xs),
          ],
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: palette.surface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
                border: Border.all(
                  color: palette.gold.withValues(alpha: 0.3),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md,
                vertical: 4,
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                enabled: widget.enabled,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submit(),
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: TypographyTokens.body(size: 17),
                cursorColor: palette.goldSoft,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: widget.hintText,
                  hintStyle: TypographyTokens.body(size: 17)
                      .copyWith(color: ColorTokens.textMuted),
                ),
              ),
            ),
          ),
          const SizedBox(width: SpacingTokens.xs),
          _SendButton(enabled: canSend, onTap: _submit),
        ],
      ),
    );
  }
}

/// Controllo discreto a sinistra del composer: un'icona con etichetta
/// Suggerimenti che apre il pannello a comparsa.
class _SuggestionsControl extends StatelessWidget {
  const _SuggestionsControl({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_outlined,
                color: palette.goldSoft, size: 24),
            const SizedBox(height: 2),
            Text(
              'Suggerimenti',
              style: TypographyTokens.body(size: 9)
                  .copyWith(color: ColorTokens.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: enabled
          ? () {
              HapticFeedback.selectionClick();
              onTap();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: enabled
                ? [palette.goldSoft, palette.gold]
                : [
                    palette.surface.withValues(alpha: 0.6),
                    palette.surface.withValues(alpha: 0.4),
                  ],
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: palette.glow.withValues(alpha: 0.5),
                    blurRadius: 14,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.arrow_upward_rounded,
          color: enabled ? palette.deepest : ColorTokens.textMuted,
          size: 24,
        ),
      ),
    );
  }
}

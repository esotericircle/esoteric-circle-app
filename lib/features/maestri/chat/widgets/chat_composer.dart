import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../core/sensi/palette_sensoriale.dart';

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
      padding: const EdgeInsets.only(
        left: SpacingTokens.md,
        right: SpacingTokens.md,
        top: SpacingTokens.sm,
        // SOLO IL RESPIRO, ordine 2163 voce 9: qui si aggiungeva anche il
        // padding di sistema, che DENTRO la barra del Cerchio vale la barra
        // intera piu' l'inset. Ma il compositore e' gia' sollevato sopra la
        // barra dal Positioned della schermata: il doppio conteggio erano
        // centotrentacinque punti di vuoto sotto il campo, misurati.
        bottom: SpacingTokens.sm,
      ),
      // NESSUN FONDO DIETRO LA RIGA, ordine 2164 voce 2. Qui c'era una
      // fascia scura piena, larga quanto lo schermo, che sfumava da
      // trasparente a fondale pieno: Mauro l'ha tolta. Restano il campo e il
      // tondo di invio, che sono opachi LORO (ordine 2163 voce 1) e lo
      // restano, appoggiati direttamente sul cosmo.
      child: Row(
        // AL CENTRO, ordine 2164 voce 5: allineate in fondo, le stelline
        // salivano sopra il campo e la scritta Suggerimenti finiva sopra il
        // contenuto. Adesso icona e scritta stanno sulla stessa riga del
        // campo, centrate come la freccia di invio dall'altro lato.
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.onSuggestions != null) ...[
            _SuggestionsControl(onTap: widget.onSuggestions!),
            const SizedBox(width: SpacingTokens.xs),
          ],
          Expanded(
            child: Container(
              key: const Key('chat_campo'),
              decoration: BoxDecoration(
                // OPACO, ordine 2163 voce 1: il testo delle bolle si leggeva
                // ATTRAVERSO il campo. Il colore e' lo stesso di prima
                // (surface al 60 per cento posata sul fondale), ma composto
                // una volta per tutte invece che lasciato comporre a video
                // con quello che passa dietro: il contenuto scorre sotto e
                // sparisce, non si intravede.
                color: Color.alphaBlend(
                    palette.surface.withValues(alpha: 0.6), palette.deepest),
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
                style: TypographyTokens.lettura(),
                cursorColor: palette.goldSoft,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: widget.hintText,
                  hintStyle: TypographyTokens.lettura()
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
      // NIENTE PADDING IN FONDO, ordine 2164 voce 5: quel respiro serviva
      // ad allineare la colonna quando la riga era allineata in basso, e
      // adesso alzerebbe di nuovo l'icona sopra il campo. La colonna e'
      // stretta al minimo e la Row la centra sul campo.
      child: Column(
        key: const Key('chat_stelline'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_outlined,
              color: palette.goldSoft, size: 24),
          const SizedBox(height: 2),
          Text(
            'Suggerimenti',
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textMuted),
          ),
        ],
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
              PaletteSensoriale.eseguiSchema(SchemaAptico.tocco);
              onTap();
            }
          : null,
      child: AnimatedContainer(
        key: const Key('chat_invio'),
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Anche il tondo di invio e' OPACO in tutti e due gli stati,
            // ordine 2163 voce 1: da spento era semitrasparente e le bolle
            // ci passavano dietro. Stesso colore percepito, composto.
            colors: enabled
                ? [palette.goldSoft, palette.gold]
                : [
                    Color.alphaBlend(
                        palette.surface.withValues(alpha: 0.6),
                        palette.deepest),
                    Color.alphaBlend(
                        palette.surface.withValues(alpha: 0.4),
                        palette.deepest),
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

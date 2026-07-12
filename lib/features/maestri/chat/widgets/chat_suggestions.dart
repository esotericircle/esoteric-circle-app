import 'package:flutter/material.dart';

import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';

/// Le due famiglie di suggerimenti sopra il composer.
enum _SuggestionGroup { frequent, personal }

/// Barra dei suggerimenti a due categorie, sopra il composer.
///
/// Un selettore sceglie fra Frequenti, un piccolo insieme curato, e Personali,
/// che pescano dalla carta dell'utente (Sole, Luna, Ascendente) e ruotano senza
/// ripetersi mai due volte di fila. Il tocco di un chip invia la domanda al
/// flusso di chat normale. L'aggancio agli scheletri e al Gateway arrivera' nel
/// passo dedicato.
class ChatSuggestions extends StatefulWidget {
  const ChatSuggestions({
    super.key,
    required this.enabled,
    required this.onSend,
  });

  final bool enabled;
  final ValueChanged<String> onSend;

  @override
  State<ChatSuggestions> createState() => _ChatSuggestionsState();
}

class _ChatSuggestionsState extends State<ChatSuggestions> {
  _SuggestionGroup _group = _SuggestionGroup.frequent;

  // Finestra di rotazione dei Personali. Avanzando cambia la terna mostrata,
  // cosi' non si ripete mai identica due volte di fila.
  int _personalWindow = 0;

  // Insieme curato dei Frequenti, per ora fisso.
  static const List<String> _frequent = [
    'Parlami del mio segno',
    'Come sarà la mia giornata?',
    'Tira una carta per me',
  ];

  // I Personali pescano dai tre luminari della carta. Finche' l'onboarding non
  // fornisce i segni reali dell'utente, le formule restano generiche sul suo
  // Sole, Luna e Ascendente. Ogni luminare ha piu' formulazioni e la finestra
  // sceglie quale mostrare, cosi' la terna ruota.
  static const List<List<String>> _personalByLuminary = [
    [
      'Cosa illumina il mio Sole?',
      'Parlami del mio Sole',
      'Il mio Sole come mi guida?',
    ],
    [
      'Cosa sente la mia Luna?',
      'Parlami della mia Luna',
      'La mia Luna e le emozioni',
    ],
    [
      'Cosa mostra il mio Ascendente?',
      'Parlami del mio Ascendente',
      'L\'Ascendente e la mia maschera',
    ],
  ];

  List<String> get _personal => [
        for (final luminary in _personalByLuminary)
          luminary[_personalWindow % luminary.length],
      ];

  void _selectGroup(_SuggestionGroup group) {
    setState(() {
      if (group == _SuggestionGroup.personal) {
        // Entrando nei Personali si avanza la finestra: la terna differisce
        // sempre da quella mostrata l'ultima volta.
        if (_group != _SuggestionGroup.personal) _personalWindow++;
      }
      _group = group;
    });
  }

  void _onChipTap(String text) {
    if (!widget.enabled) return;
    widget.onSend(text);
    // Dopo aver usato un Personale, la terna ruota per la prossima volta.
    if (_group == _SuggestionGroup.personal) {
      setState(() => _personalWindow++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final chips = _group == _SuggestionGroup.frequent ? _frequent : _personal;

    return Container(
      padding: const EdgeInsets.only(
        left: SpacingTokens.md,
        right: SpacingTokens.md,
        top: SpacingTokens.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _GroupPill(
                label: 'Frequenti',
                selected: _group == _SuggestionGroup.frequent,
                onTap: () => _selectGroup(_SuggestionGroup.frequent),
              ),
              const SizedBox(width: SpacingTokens.xs),
              _GroupPill(
                label: 'Personali',
                selected: _group == _SuggestionGroup.personal,
                onTap: () => _selectGroup(_SuggestionGroup.personal),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xs),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: chips.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: SpacingTokens.xs),
              itemBuilder: (context, i) => _Chip(
                label: chips[i],
                enabled: widget.enabled,
                onTap: () => _onChipTap(chips[i]),
                palette: palette,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupPill extends StatelessWidget {
  const _GroupPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: selected
              ? palette.gold.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          border: Border.all(
            color: selected
                ? palette.gold.withValues(alpha: 0.7)
                : palette.gold.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TypographyTokens.label(size: 12).copyWith(
            color: selected ? palette.goldSoft : ColorTokens.textMuted,
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.enabled,
    required this.onTap,
    required this.palette,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
          decoration: BoxDecoration(
            color: palette.surface.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
            border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
          ),
          child: Text(
            label,
            style: TypographyTokens.body(size: 15)
                .copyWith(color: palette.goldSoft),
          ),
        ),
      ),
    );
  }
}

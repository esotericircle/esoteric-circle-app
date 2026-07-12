import 'package:flutter/material.dart';

import '../../../../core/maestro/maestro.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';

/// Le due famiglie di suggerimenti.
enum SuggestionGroup { frequent, personal }

extension SuggestionGroupLabel on SuggestionGroup {
  String get label => switch (this) {
        SuggestionGroup.frequent => 'Domande frequenti',
        SuggestionGroup.personal => 'Domande personali',
      };
}

/// Insiemi di domande suggerite per Maestro.
///
/// I Frequenti sono un piccolo insieme curato. I Personali pescano dalla carta
/// dell'utente, Sole, Luna e Ascendente. Finche' l'onboarding non fornisce i
/// segni reali, le formule restano generiche sui tre luminari, pronte a ricevere
/// i segni veri. L'aggancio agli scheletri e al Gateway arrivera' nel passo
/// dedicato.
class SuggestionSets {
  const SuggestionSets._();

  static const List<String> _frequentMedora = [
    'Parlami del mio segno',
    'Come sarà la mia giornata?',
    'Tira una carta per me',
    'Cosa dicono le stelle di oggi?',
    'Un consiglio per l\'amore',
    'Un consiglio per il lavoro',
    'Parlami dei miei pianeti',
    'Cosa mi riservano i prossimi giorni?',
    'Qual è la mia carta guida?',
    'Parlami dei miei transiti',
  ];

  static const List<String> _personalMedora = [
    'Cosa illumina il mio Sole?',
    'Parlami del mio Sole',
    'La forza del mio Sole',
    'Il mio Sole come mi guida?',
    'Cosa sente la mia Luna?',
    'Parlami della mia Luna',
    'La mia Luna e le emozioni',
    'Il bisogno della mia Luna',
    'Cosa mostra il mio Ascendente?',
    'Parlami del mio Ascendente',
    'L\'Ascendente e la mia maschera',
    'La prima impressione del mio Ascendente',
  ];

  static const List<String> _frequentAura = [
    'Aiutami a rilassarmi',
    'Guidami in una meditazione breve',
    'Come ritrovo equilibrio?',
    'Parlami dei chakra',
    'Quale chakra devo riequilibrare?',
    'Un respiro per calmare la mente',
    'Una frequenza per stasera',
    'Come sciolgo la tensione?',
    'Aiutami a dormire meglio',
    'Un gesto per ritrovare energia',
  ];

  static const List<String> _personalAura = [
    'Il mio Sole e la mia energia vitale',
    'Come nutro la luce del mio Sole?',
    'Il mio Sole e il chakra del plesso',
    'La forza del mio Sole nel corpo',
    'La mia Luna e il chakra del cuore',
    'Come accolgo le emozioni della mia Luna?',
    'La mia Luna e il respiro',
    'Il bisogno di quiete della mia Luna',
    'Il mio Ascendente e la mia presenza',
    'Come abito il mio Ascendente col respiro?',
    'Il mio Ascendente e l\'energia che mostro',
    'La prima impressione del mio Ascendente',
  ];

  static const List<String> _frequentCaligo = [
    'Estrai una runa per me',
    'Parlami di un simbolo',
    'Un presagio per oggi',
    'Guidami in un rito semplice',
    'Quale runa mi accompagna?',
    'Parlami dell\'Albero della Vita',
    'Qual è il mio animale guida?',
    'Un archetipo che mi riguarda',
    'Un simbolo di protezione',
    'Cosa dice il silenzio?',
  ];

  static const List<String> _personalCaligo = [
    'Il mio Sole e la runa del potere',
    'Quale simbolo veste il mio Sole?',
    'Il mio Sole e la mia volontà',
    'L\'archetipo del mio Sole',
    'La mia Luna e la runa dell\'acqua',
    'Quale simbolo abita la mia Luna?',
    'La mia Luna e l\'ombra',
    'L\'archetipo della mia Luna',
    'Il mio Ascendente e la maschera rituale',
    'Quale runa apre il mio Ascendente?',
    'Il mio Ascendente e la soglia',
    'L\'archetipo del mio Ascendente',
  ];

  static List<String> frequent(Maestro maestro) => switch (maestro) {
        Maestro.medora => _frequentMedora,
        Maestro.aura => _frequentAura,
        Maestro.caligo => _frequentCaligo,
      };

  static List<String> personal(Maestro maestro) => switch (maestro) {
        Maestro.medora => _personalMedora,
        Maestro.aura => _personalAura,
        Maestro.caligo => _personalCaligo,
      };

  /// I pochi chip d'avvio dello stato vuoto, un invito iniziale.
  static List<String> starters(Maestro maestro) =>
      frequent(maestro).take(4).toList(growable: false);

  static List<String> forGroup(Maestro maestro, SuggestionGroup group) =>
      switch (group) {
        SuggestionGroup.frequent => frequent(maestro),
        SuggestionGroup.personal => personal(maestro),
      };
}

/// Apre il pannello dei suggerimenti che sale dal basso sopra il feed.
///
/// In cima il selettore a due segmenti, sotto l'elenco scorrevole (fino a
/// dodici). Il tocco su una domanda la invia e chiude il pannello. Cambiare
/// segmento cambia l'elenco nello stesso pannello.
Future<void> showSuggestionsPanel(
  BuildContext context, {
  required Maestro maestro,
  required ValueChanged<String> onSend,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    // Il foglio vive nell'overlay del navigator, fuori dal MaestroScope della
    // schermata: lo riavvolgiamo cosi' ritrova la palette del Maestro attivo.
    builder: (_) => MaestroScope(
      child: _SuggestionsPanel(maestro: maestro, onSend: onSend),
    ),
  );
}

class _SuggestionsPanel extends StatefulWidget {
  const _SuggestionsPanel({required this.maestro, required this.onSend});

  final Maestro maestro;
  final ValueChanged<String> onSend;

  @override
  State<_SuggestionsPanel> createState() => _SuggestionsPanelState();
}

class _SuggestionsPanelState extends State<_SuggestionsPanel> {
  SuggestionGroup _group = SuggestionGroup.frequent;

  void _send(String question) {
    widget.onSend(question);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final questions = SuggestionSets.forGroup(widget.maestro, _group);

    return Container(
      padding: EdgeInsets.only(
        top: SpacingTokens.md,
        bottom: SpacingTokens.md + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.surfaceElevated, palette.deepest],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SpacingTokens.radiusXl),
        ),
        border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: palette.gold.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Center(
            child: _SegmentedControl(
              value: _group,
              onChanged: (g) => setState(() => _group = g),
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.42,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.lg,
                vertical: SpacingTokens.xs,
              ),
              itemCount: questions.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: palette.gold.withValues(alpha: 0.12),
              ),
              itemBuilder: (context, i) => _QuestionRow(
                question: questions[i],
                onTap: () => _send(questions[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({required this.value, required this.onChanged});

  final SuggestionGroup value;
  final ValueChanged<SuggestionGroup> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: palette.deepest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        border: Border.all(color: palette.gold.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final group in SuggestionGroup.values)
            _Segment(
              label: group.label,
              selected: group == value,
              onTap: () => onChanged(group),
              palette: palette,
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.palette,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.xs,
        ),
        decoration: BoxDecoration(
          color: selected
              ? palette.gold.withValues(alpha: 0.20)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
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

class _QuestionRow extends StatelessWidget {
  const _QuestionRow({required this.question, required this.onTap});

  final String question;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
        child: Row(
          children: [
            Icon(Icons.auto_awesome_outlined,
                color: palette.goldSoft, size: 18),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Text(
                question,
                style: TypographyTokens.body(size: 16),
              ),
            ),
            const Icon(Icons.north_east_rounded,
                color: ColorTokens.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}

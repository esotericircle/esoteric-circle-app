import 'package:flutter/material.dart';

import '../../../core/maestro/maestro.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/theme/maestro_scope.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../../services/ai/maestro_oracle.dart';

/// "Chiedi ai Maestri": una domanda, uno o piu' Maestri, e le loro lenti a
/// confronto.
///
/// Si sceglie di interpellare un Maestro, due o tutti e tre. Ciascuno risponde
/// dal suo dominio, secondo il canone Personas. Quando sono piu' di uno, in
/// testa compare una sintesi comparativa che mostra le lenti sullo stesso tema.
/// Le risposte usano l'oracolo locale in ripiego: la chiamata vera a Gemini su
/// Vertex resta al device, dietro `MaestroAiProvider`. Freccia Indietro sempre,
/// mai un vicolo cieco.
class AskMaestriScreen extends StatefulWidget {
  const AskMaestriScreen({super.key, this.oracle = const MaestroOracle()});

  final MaestroOracle oracle;

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const MaestroScope(child: AskMaestriScreen()),
    );
  }

  @override
  State<AskMaestriScreen> createState() => _AskMaestriScreenState();
}

class _AskMaestriScreenState extends State<AskMaestriScreen> {
  final TextEditingController _composer = TextEditingController();
  final Set<Maestro> _selected = {Maestro.medora, Maestro.aura, Maestro.caligo};
  MaestriConsultation? _result;

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  void _toggle(Maestro m) {
    setState(() {
      if (_selected.contains(m)) {
        // Almeno un Maestro resta sempre scelto: mai un vicolo cieco.
        if (_selected.length > 1) _selected.remove(m);
      } else {
        _selected.add(m);
      }
    });
  }

  void _ask() {
    final theme = _composer.text.trim();
    if (theme.isEmpty || _selected.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _result = widget.oracle
          .consult(theme: theme, maestri: _selected.toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final canAsk = _composer.text.trim().isNotEmpty;

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
        title: Text('Chiedi ai Maestri',
            style: TypographyTokens.display(size: 20)),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(SpacingTokens.lg,
                  SpacingTokens.md, SpacingTokens.lg, SpacingTokens.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Una domanda, e le lenti dei Maestri a confronto. Scegli chi '
                    'interpellare.',
                    style: TypographyTokens.body(size: 14)
                        .copyWith(color: ColorTokens.textSecondary),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Row(
                    children: [
                      for (final m in Maestro.fixedOrder) ...[
                        _MaestroChip(
                          maestro: m,
                          selected: _selected.contains(m),
                          onTap: () => _toggle(m),
                        ),
                        if (m != Maestro.fixedOrder.last)
                          const SizedBox(width: SpacingTokens.sm),
                      ],
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  _Composer(
                    controller: _composer,
                    palette: palette,
                    canAsk: canAsk,
                    onChanged: () => setState(() {}),
                    onAsk: _ask,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _result == null
                  ? _EmptyState(palette: palette)
                  : _Results(result: _result!),
            ),
          ],
        ),
      ),
    );
  }
}

/// Un chip per scegliere se interpellare un Maestro, nella sua palette.
class _MaestroChip extends StatelessWidget {
  const _MaestroChip({
    required this.maestro,
    required this.selected,
    required this.onTap,
  });

  final Maestro maestro;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(ThemeKey.of(maestro));
    return Expanded(
      child: GestureDetector(
        key: Key('ask_chip_${maestro.id}'),
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            gradient: selected
                ? LinearGradient(colors: [
                    palette.primary.withValues(alpha: 0.6),
                    palette.surfaceElevated.withValues(alpha: 0.6),
                  ])
                : null,
            border: Border.all(
              color: selected
                  ? palette.gold.withValues(alpha: 0.7)
                  : palette.gold.withValues(alpha: 0.22),
            ),
          ),
          child: Column(
            children: [
              Icon(maestro.icon,
                  size: 22,
                  color: selected
                      ? palette.goldSoft
                      : ColorTokens.textSecondary),
              const SizedBox(height: 4),
              Text(
                maestro.displayName,
                style: TypographyTokens.label(size: 11).copyWith(
                  color:
                      selected ? palette.goldSoft : ColorTokens.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Il campo della domanda con il bottone Chiedi.
class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.palette,
    required this.canAsk,
    required this.onChanged,
    required this.onAsk,
  });

  final TextEditingController controller;
  final MaestroPalette palette;
  final bool canAsk;
  final VoidCallback onChanged;
  final VoidCallback onAsk;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            key: const Key('ask_field'),
            controller: controller,
            onChanged: (_) => onChanged(),
            onSubmitted: (_) => onAsk(),
            textInputAction: TextInputAction.send,
            minLines: 1,
            maxLines: 3,
            style: TypographyTokens.body(size: 15)
                .copyWith(color: ColorTokens.textPrimary),
            decoration: InputDecoration(
              hintText: 'Su cosa vuoi una lettura?',
              hintStyle: TypographyTokens.body(size: 15)
                  .copyWith(color: ColorTokens.textSecondary),
              filled: true,
              fillColor: palette.surfaceElevated.withValues(alpha: 0.5),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                borderSide: BorderSide(
                    color: palette.gold.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                borderSide: BorderSide(
                    color: palette.gold.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                borderSide: BorderSide(
                    color: palette.gold.withValues(alpha: 0.6)),
              ),
            ),
          ),
        ),
        const SizedBox(width: SpacingTokens.sm),
        IconButton(
          key: const Key('ask_submit'),
          onPressed: canAsk ? onAsk : null,
          icon: const Icon(Icons.auto_awesome),
          color: palette.goldSoft,
          disabledColor: ColorTokens.textSecondary.withValues(alpha: 0.4),
          tooltip: 'Chiedi',
        ),
      ],
    );
  }
}

/// Stato vuoto: invita a comporre la domanda e a scegliere i Maestri.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('ask_empty'),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum_outlined,
                size: 44, color: palette.goldSoft.withValues(alpha: 0.7)),
            const SizedBox(height: SpacingTokens.md),
            Text(
              'Scrivi la tua domanda e scegli chi interpellare. Con più Maestri '
              'vedrai le loro lenti a confronto.',
              textAlign: TextAlign.center,
              style: TypographyTokens.body(size: 15)
                  .copyWith(color: ColorTokens.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// I risultati: la sintesi comparativa in testa quando le lenti sono piu' di
/// una, poi la lettura di ciascun Maestro.
class _Results extends StatelessWidget {
  const _Results({required this.result});

  final MaestriConsultation result;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('ask_results'),
      padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, 0, SpacingTokens.lg,
          SpacingTokens.xxxl),
      children: [
        if (result.synthesis != null) ...[
          _SynthesisCard(theme: result.theme, synthesis: result.synthesis!),
          const SizedBox(height: SpacingTokens.md),
        ],
        for (final lens in result.lenses) ...[
          _LensCard(lens: lens),
          const SizedBox(height: SpacingTokens.sm),
        ],
      ],
    );
  }
}

/// La sintesi comparativa: le tre lenti sullo stesso tema, in cima.
class _SynthesisCard extends StatelessWidget {
  const _SynthesisCard({required this.theme, required this.synthesis});

  final String theme;
  final String synthesis;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      key: const Key('ask_synthesis'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.surfaceElevated.withValues(alpha: 0.9),
            palette.deepest.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        border: Border.all(color: palette.gold.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.balance, size: 18, color: palette.goldSoft),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text('Sintesi comparativa',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TypographyTokens.display(size: 17)
                        .copyWith(color: palette.goldSoft)),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            synthesis,
            style: TypographyTokens.body(size: 15)
                .copyWith(color: ColorTokens.textPrimary, height: 1.4),
          ),
        ],
      ),
    );
  }
}

/// La lettura di un Maestro, nella sua palette: colpo d'occhio, testo, invito.
class _LensCard extends StatelessWidget {
  const _LensCard({required this.lens});

  final MaestroLens lens;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(ThemeKey.of(lens.maestro));
    return Container(
      key: Key('ask_lens_${lens.maestro.id}'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.primary.withValues(alpha: 0.28),
            palette.deepest.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        border: Border.all(color: palette.gold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: palette.gold.withValues(alpha: 0.6)),
                ),
                child: Icon(lens.maestro.icon,
                    size: 18, color: palette.goldSoft),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Text(lens.maestro.displayName,
                  style: TypographyTokens.display(size: 18)),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(lens.maestro.domainTitle,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TypographyTokens.label(size: 10).copyWith(
                      color: palette.goldSoft.withValues(alpha: 0.8),
                      letterSpacing: 0.8,
                    )),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(lens.glance,
              style: TypographyTokens.body(size: 15).copyWith(
                color: palette.goldSoft,
                fontStyle: FontStyle.italic,
                height: 1.35,
              )),
          const SizedBox(height: SpacingTokens.sm),
          Text(lens.reading,
              style: TypographyTokens.body(size: 14).copyWith(
                color: ColorTokens.textPrimary,
                height: 1.4,
              )),
          const SizedBox(height: SpacingTokens.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.arrow_forward, size: 14, color: palette.goldSoft),
              const SizedBox(width: 6),
              Expanded(
                child: Text(lens.invite,
                    style: TypographyTokens.body(size: 14).copyWith(
                      color: palette.goldSoft,
                      height: 1.35,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

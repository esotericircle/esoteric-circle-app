import 'package:flutter/material.dart';

import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../horoscope/answer_depth.dart';

/// La chiave con cui si legge la stesa.
///
/// La Riflessione e' citata come ispirazione al lavoro di Alejandro Jodorowsky,
/// senza alcun rapporto ufficiale: mai un marchio, sempre col suo disclaimer.
enum ReadingKey {
  predittiva('Predittiva di Medora', available: true),
  riflessione('Riflessione Jodorowsky', available: false),
  esoterica('Esoterica Caligo', available: false);

  const ReadingKey(this.label, {required this.available});

  final String label;
  final bool available;

  /// Nota da mostrare sotto la voce, quando serve.
  String? get note => this == ReadingKey.riflessione
      ? 'Ispirata al lavoro di Alejandro Jodorowsky, senza rapporto ufficiale.'
      : null;
}

/// Il mazzo con cui si legge.
enum TarotDeckStyle {
  riderWaite('Rider-Waite', available: true),
  marsiglia('Marsiglia', available: false),
  thoth('Thoth', available: false);

  const TarotDeckStyle(this.label, {required this.available});

  final String label;
  final bool available;
}

/// Lo stato dei selettori prima della stesa.
class TarotSetup {
  const TarotSetup({
    this.key = ReadingKey.predittiva,
    this.deck = TarotDeckStyle.riderWaite,
    this.depth = AnswerDepth.breve,
    this.includeReversed = true,
  });

  final ReadingKey key;
  final TarotDeckStyle deck;
  final AnswerDepth depth;

  /// Includi carte rovesciate: attivo di default nelle impostazioni della
  /// cartomanzia.
  final bool includeReversed;

  TarotSetup copyWith({
    ReadingKey? key,
    TarotDeckStyle? deck,
    AnswerDepth? depth,
    bool? includeReversed,
  }) =>
      TarotSetup(
        key: key ?? this.key,
        deck: deck ?? this.deck,
        depth: depth ?? this.depth,
        includeReversed: includeReversed ?? this.includeReversed,
      );
}

/// Il pannello dei selettori prima della stesa: chiave di lettura, profondita',
/// mazzo, carte rovesciate. Le voci non ancora pronte restano visibili col badge
/// Coming soon, mai un vicolo cieco.
class TarotSetupPanel extends StatelessWidget {
  const TarotSetupPanel({
    super.key,
    required this.setup,
    required this.palette,
    required this.onChanged,
    required this.onLocked,
  });

  final TarotSetup setup;
  final MaestroPalette palette;
  final ValueChanged<TarotSetup> onChanged;

  /// Invito quando si tocca una voce non disponibile.
  final ValueChanged<String> onLocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('stesa_setup'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        color: palette.surfaceElevated.withValues(alpha: 0.55),
        border: Border.all(color: palette.gold.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Riga(
            titolo: 'Chiave di lettura',
            palette: palette,
            child: Wrap(
              spacing: SpacingTokens.xs,
              runSpacing: SpacingTokens.xs,
              children: [
                for (final k in ReadingKey.values)
                  _Voce(
                    key: Key('stesa_key_${k.name}'),
                    label: k.label,
                    selected: k == setup.key,
                    available: k.available,
                    palette: palette,
                    onTap: () => k.available
                        ? onChanged(setup.copyWith(key: k))
                        : onLocked(k.label),
                  ),
              ],
            ),
          ),
          // Il credito a Jodorowsky, sempre come ispirazione, mai come marchio.
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(ReadingKey.riflessione.note!,
                key: const Key('stesa_jodorowsky_nota'),
                style: TypographyTokens.body(size: 11).copyWith(
                    color: ColorTokens.textSecondary,
                    fontStyle: FontStyle.italic)),
          ),
          const SizedBox(height: SpacingTokens.sm),
          _Riga(
            titolo: 'Profondita\'',
            palette: palette,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnswerDepthSelector(
                key: const Key('stesa_depth'),
                current: setup.depth,
                palette: palette,
                onSelect: (d) => onChanged(setup.copyWith(depth: d)),
                onLockedTap: (d) => onLocked(d.label),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          _Riga(
            titolo: 'Mazzo',
            palette: palette,
            child: Wrap(
              spacing: SpacingTokens.xs,
              runSpacing: SpacingTokens.xs,
              children: [
                for (final d in TarotDeckStyle.values)
                  _Voce(
                    key: Key('stesa_deck_${d.name}'),
                    label: d.label,
                    selected: d == setup.deck,
                    available: d.available,
                    palette: palette,
                    onTap: () => d.available
                        ? onChanged(setup.copyWith(deck: d))
                        : onLocked(d.label),
                  ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Row(
            children: [
              Expanded(
                child: Text('Includi carte rovesciate',
                    style: TypographyTokens.body(size: 14)
                        .copyWith(color: ColorTokens.textPrimary)),
              ),
              Switch(
                key: const Key('stesa_reversed_switch'),
                value: setup.includeReversed,
                activeThumbColor: palette.gold,
                onChanged: (v) =>
                    onChanged(setup.copyWith(includeReversed: v)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Riga extends StatelessWidget {
  const _Riga(
      {required this.titolo, required this.child, required this.palette});

  final String titolo;
  final Widget child;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titolo.toUpperCase(),
            style: TypographyTokens.label(size: 9).copyWith(
                color: ColorTokens.textSecondary, letterSpacing: 1.2)),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

/// Una voce del selettore. Se non e' disponibile resta visibile col badge
/// Coming soon e il lucchetto.
class _Voce extends StatelessWidget {
  const _Voce({
    super.key,
    required this.label,
    required this.selected,
    required this.available,
    required this.palette,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool available;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          gradient: selected
              ? LinearGradient(colors: [
                  palette.primary.withValues(alpha: 0.85),
                  palette.surfaceElevated.withValues(alpha: 0.85),
                ])
              : null,
          border: Border.all(
              color: selected
                  ? palette.gold.withValues(alpha: 0.65)
                  : palette.gold.withValues(alpha: 0.22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TypographyTokens.body(size: 13).copyWith(
                  color: selected
                      ? palette.goldSoft
                      : ColorTokens.textSecondary
                          .withValues(alpha: available ? 1.0 : 0.65),
                )),
            if (!available) ...[
              const SizedBox(width: 5),
              Icon(Icons.lock_rounded,
                  size: 11,
                  color: palette.goldSoft.withValues(alpha: 0.65)),
              const SizedBox(width: 3),
              Text('Coming soon',
                  style: TypographyTokens.label(size: 7).copyWith(
                      color: palette.goldSoft.withValues(alpha: 0.75),
                      letterSpacing: 0.4)),
            ],
          ],
        ),
      ),
    );
  }
}

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/rituals/dawn_gift.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

// Colori del dono nello stato illuminato. A gesto completato la scena e' luce
// piena: il dono usa testo scuro su una bolla di vetro chiara, per la
// leggibilita' piena. E' il rovescio dell'invito, chiaro sul buio.
const Color _dayInk = Color(0xFF2A2213); // testo forte
const Color _dayInkSoft = Color(0xFF6E5B33); // etichette e testo secondario
const Color _dayAccent = Color(0xFF7A5E1E); // oro scuro, accenti e parola
const Color _dayInset = Color(0x14000000); // superfici interne, un velo caldo
// La bolla e' un vetro smerigliato: semitrasparente e sfocata, lascia intravedere
// la scena sotto ma tiene il testo scuro leggibile sul chiaro.
const Color _dayGlass = Color(0xC7FBF4E2); // bianco caldo, alpha circa 0.78
const Color _dayGlassBorder = Color(0x4DFFFFFF);

/// La card del dono del giorno, condivisa dai riti: dentro una bolla di vetro
/// smerigliato semitrasparente, testo scuro leggibile sul chiaro. Porge tre
/// livelli, l'orientamento del giorno, la parola del giorno e la base apribile
/// che spiega da dove nasce, con la condivisione e il filo di continuita'.
/// Finche' i contenuti verificati non arrivano, i testi del cielo restano
/// provvisori e marcati, mai inventati.
class RitualGiftCard extends StatefulWidget {
  const RitualGiftCard({
    super.key,
    required this.gift,
    required this.streak,
    required this.onShare,
  });

  final DawnGift gift;
  final int streak;
  final VoidCallback onShare;

  @override
  State<RitualGiftCard> createState() => _RitualGiftCardState();
}

class _RitualGiftCardState extends State<RitualGiftCard> {
  bool _baseOpen = false;

  @override
  Widget build(BuildContext context) {
    final gift = widget.gift;
    final word = gift.word;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: _dayGlass,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _dayGlassBorder),
          ),
          padding: const EdgeInsets.all(SpacingTokens.lg),
          // **La scheda scorre**, e da oggi le serve. Finche' il dono era un
          // segnaposto di tre righe ci stava sempre; adesso porta un gesto, un
          // respiro contato e la via col dito, e su uno schermo basso il
          // pulsante della base finiva fuori dalla scheda senza che nessuno
          // potesse toccarlo. L'ha trovato una prova gia' esistente, non io.
          child: SingleChildScrollView(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Livello uno: il tipo di dono e l'orientamento del giorno.
              Row(
                children: [
                  Flexible(
                    child: Text(
                      gift.kind.label.toUpperCase(),
                      style: TypographyTokens.label(size: 11).copyWith(
                        color: _dayAccent,
                        letterSpacing: 2.4,
                      ),
                    ),
                  ),
                  if (gift.provisional) ...[
                    const SizedBox(width: SpacingTokens.sm),
                  ],
                ],
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                gift.orientation,
                style: TypographyTokens.body(size: 16)
                    .copyWith(color: _dayInk, height: 1.5),
              ),
              const SizedBox(height: SpacingTokens.lg),
              // Livello due: la parola del giorno, in risalto, o il segnaposto.
              Text(
                'PAROLA DEL GIORNO',
                style: TypographyTokens.label(size: 11).copyWith(
                  color: _dayInkSoft,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: SpacingTokens.xs),
              if (word != null)
                Text(
                  word,
                  style: TypographyTokens.display(size: 32).copyWith(
                    color: _dayAccent,
                    letterSpacing: 1.4,
                  ),
                )
              else
                Text(
                  'In arrivo',
                  style: TypographyTokens.display(size: 24).copyWith(
                    color: _dayInkSoft.withValues(alpha: 0.7),
                    letterSpacing: 1.2,
                  ),
                ),
              const SizedBox(height: SpacingTokens.md),
              // Livello tre: la base apribile, da dove nasce il dono.
              _BaseToggle(
                open: _baseOpen,
                onTap: () => setState(() => _baseOpen = !_baseOpen),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.topCenter,
                child: _baseOpen
                    ? _BasePanel(source: gift.source)
                    : const SizedBox(width: double.infinity),
              ),
              const SizedBox(height: SpacingTokens.md),
              // **Wrap e non Row, e il motivo e' che la parola adesso esiste.**
              // Finche' `word` era nulla il pulsante di condivisione non veniva
              // mai costruito, e la riga conteneva la sola spilla: ci stava
              // sempre. Dal momento in cui il rito porta una parola vera i due
              // elementi convivono, e su schermo stretto la riga sforava di
              // novantotto pixel. L'ha trovato la cattura delle anteprime.
              Wrap(
                spacing: SpacingTokens.md,
                runSpacing: SpacingTokens.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // La condivisione della parola torna quando la parola e' reale.
                  if (word != null) _ShareWordButton(onShare: widget.onShare),
                  if (widget.streak >= 1) _StreakChip(days: widget.streak),
                ],
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}


/// La riga che apre e chiude la base del dono.
class _BaseToggle extends StatelessWidget {
  const _BaseToggle({required this.open, required this.onTap});

  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const Key('gift_base_toggle'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline_rounded, size: 15, color: _dayAccent),
            const SizedBox(width: 6),
            Text(
              'Da dove nasce questo dono',
              style: TypographyTokens.label(size: 11).copyWith(
                color: _dayAccent,
                letterSpacing: 0.4,
              ),
            ),
            Icon(open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                size: 18, color: _dayAccent),
          ],
        ),
      ),
    );
  }
}

/// Il pannello della base: ancora natale reale, transito e tradizione, con la
/// provvisorieta' dichiarata dove il contenuto verificato manca.
class _BasePanel extends StatelessWidget {
  const _BasePanel({required this.source});

  final GiftSource source;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('gift_base_panel'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: SpacingTokens.sm),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: _dayInset,
        border: Border.all(color: _dayInkSoft.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BaseRow(
            label: 'Ancora natale',
            value: source.natalDescription,
            provisional: false,
          ),
          const SizedBox(height: SpacingTokens.sm),
          _BaseRow(
            label: 'Transito attivo oggi',
            value: source.transit ??
                'In attesa dei contenuti astrologici verificati.',
            provisional: source.transit == null,
          ),
          const SizedBox(height: SpacingTokens.sm),
          _BaseRow(
            label: 'Nella tradizione',
            value: source.tradition ??
                'In attesa dei contenuti astrologici verificati.',
            provisional: source.tradition == null,
          ),
        ],
      ),
    );
  }
}

class _BaseRow extends StatelessWidget {
  const _BaseRow({
    required this.label,
    required this.value,
    required this.provisional,
  });

  final String label;
  final String value;
  final bool provisional;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                label.toUpperCase(),
                style: TypographyTokens.label(size: 11).copyWith(
                  color: _dayInkSoft,
                  letterSpacing: 1.6,
                ),
              ),
            ),
            if (provisional) ...[
              const SizedBox(width: SpacingTokens.sm),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TypographyTokens.body(size: 14).copyWith(
            color: provisional ? _dayInkSoft : _dayInk,
            height: 1.4,
            fontStyle: provisional ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }
}

/// Pulsante discreto per condividere la parola del giorno con la condivisione
/// nativa del sistema.
class _ShareWordButton extends StatelessWidget {
  const _ShareWordButton({required this.onShare});

  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      key: const Key('gift_share_word'),
      onPressed: onShare,
      style: TextButton.styleFrom(
        foregroundColor: _dayAccent,
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          side: BorderSide(color: _dayAccent.withValues(alpha: 0.5)),
        ),
      ),
      icon: const Icon(Icons.ios_share_rounded, size: 16),
      label: Text(
        'Condividi la parola',
        style: TypographyTokens.label(size: 12)
            .copyWith(color: _dayAccent, letterSpacing: 0.5),
      ),
    );
  }
}

/// Indicatore discreto dei giorni consecutivi di rito compiuto.
class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final label = days == 1 ? 'Primo giorno' : '$days giorni di fila';
    return Container(
      key: const Key('gift_streak'),
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        color: _dayInset,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wb_twilight_rounded, size: 14, color: _dayAccent),
          const SizedBox(width: 6),
          Text(
            label,
            style: TypographyTokens.label(size: 11).copyWith(
              color: _dayAccent,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

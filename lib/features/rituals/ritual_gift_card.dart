import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/maestro/maestro.dart';
import '../../core/rituals/dawn_gift.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

// Colori del dono nello stato illuminato. A gesto completato la scena e' luce
// piena: il dono usa testo scuro su una bolla di vetro chiara, per la
// leggibilita' piena. E' il rovescio dell'invito, chiaro sul buio.
const Color _dayInk = Color(0xFF2A2213); // testo forte
const Color _dayInkSoft = Color(0xFF6E5B33); // etichette e testo secondario
const Color _dayInset = Color(0x14000000); // superfici interne, un velo caldo

/// L'ACCENTO DELLA SCHEDA, che nasce dal Maestro del giorno.
///
/// **Da `gift.maestro` e da nient'altro.** Il dono sa gia' di chi e' il giorno,
/// perche' gliel'ha messo dentro `DawnGift.forMaestro`, che a sua volta lo
/// prende da `DailyRituals.dawnMaestro` per la rotazione e da
/// `DailyElements.maestroFor` per i riti a guida fissa. Passare una palette
/// dalle schermate creerebbe **due** punti che decidono lo stesso colore, e
/// prima o poi direbbero due cose diverse: una prova enumera i punti e cade se
/// diventano due.
///
/// **Il testo NON si tinge.** `_dayInk` e `_dayInkSoft` restano quelli: a gesto
/// completato la scena e' luce piena e la bolla e' vetro chiaro, quindi tingere
/// l'inchiostro peggiorerebbe la lettura senza dire niente di piu'. Il Maestro
/// si vede dove il colore e' colore, cioe' negli accenti, nella parola del
/// giorno e nel bordo.
///
/// **UNA REGOLA SOLA PER TUTTI E TRE, e serve.** Preso cosi' com'e', il verde di
/// Aura sul vetro chiaro ha un contrasto di 2,9, sotto la soglia di 4,5 che
/// rende leggibile un testo: sarebbe un accento che si vede peggio degli altri
/// due proprio dove va letto. Invece di scegliere a mano tre colori diversi, che
/// e' il modo di sbagliarne uno senza accorgersene, il colore del Maestro si
/// scurisce finche' il contrasto non basta. Blu e rosso passano al primo giro e
/// restano quelli della palette; il verde scende di quanto serve e non di piu'.
Color _accentoDi(Maestro maestro) {
  final base = MaestroPalette.forKey(ThemeKey.of(maestro)).primary;
  var colore = base;
  // Venti passi bastano e avanzano: ogni passo toglie il cinque per cento, e
  // dopo venti si e' a un terzo della luminosita' di partenza. Il tetto e' una
  // cintura contro un ciclo infinito, non un limite atteso.
  for (var passo = 0; passo < 20; passo++) {
    if (_contrastoSulVetro(colore) >= _contrastoMinimo) return colore;
    colore = Color.fromARGB(
      colore.a.round(),
      (colore.r * 255 * 0.95).round(),
      (colore.g * 255 * 0.95).round(),
      (colore.b * 255 * 0.95).round(),
    );
  }
  return colore;
}

/// Il contrasto minimo fra accento e vetro, dalle WCAG per il testo normale.
const double _contrastoMinimo = 4.5;

/// Il rapporto di contrasto fra un colore e la bolla di vetro.
///
/// Si calcola contro `_dayGlass` reso opaco, cioe' contro il caso in cui la
/// scena sotto e' luce piena: e' la condizione in cui la scheda si mostra
/// davvero, perche' compare a gesto completato.
double _contrastoSulVetro(Color colore) {
  final a = _luminanzaRelativa(colore);
  final b = _luminanzaRelativa(const Color(0xFFFBF4E2));
  final chiaro = a > b ? a : b;
  final scuro = a > b ? b : a;
  return (chiaro + 0.05) / (scuro + 0.05);
}

/// La luminanza relativa secondo le WCAG.
double _luminanzaRelativa(Color colore) {
  double canale(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * canale(colore.r) +
      0.7152 * canale(colore.g) +
      0.0722 * canale(colore.b);
}
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
    // L'accento nasce QUI, da gift.maestro, e da qui scende ai widget annidati
    // come parametro: non c'e' un secondo punto che lo decida.
    final accento = _accentoDi(gift.maestro);

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
                        color: accento,
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
                    color: accento,
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
                accento: accento,
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
                  if (word != null)
                    _ShareWordButton(
                        onShare: widget.onShare, accento: accento),
                  if (widget.streak >= 1)
                    _StreakChip(days: widget.streak, accento: accento),
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
  const _BaseToggle(
      {required this.open, required this.onTap, required this.accento});

  final bool open;
  final VoidCallback onTap;

  /// L'accento del Maestro del giorno, deciso una volta sola dalla scheda.
  final Color accento;

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
            Icon(Icons.info_outline_rounded, size: 15, color: accento),
            const SizedBox(width: 6),
            Text(
              'Da dove nasce questo dono',
              style: TypographyTokens.label(size: 11).copyWith(
                color: accento,
                letterSpacing: 0.4,
              ),
            ),
            Icon(open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                size: 18, color: accento),
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
          // LE DUE RIGHE CHE SPARISCONO INVECE DI DIRE DI ASPETTARE.
          //
          // **Qui c'era due volte "In attesa dei contenuti astrologici
          // verificati", ed era l'app che mostrava alla persona la propria
          // impalcatura.** Adesso il transito arriva dal motore vero, lo
          // stesso dell'Oroscopo, ed e' nullo solo quando la carta natale non
          // c'e'; la fonte nella tradizione e' nulla perche' per i nove riti
          // dell'Alba non esiste una fonte verificata da citare.
          //
          // In tutti e due i casi la riga NON COMPARE. E' la stessa regola che
          // le varianti del rito seguono gia': si mostra il dato che c'e', e
          // di quello che manca non si parla.
          if (source.transit != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            _BaseRow(
              label: 'Transito attivo oggi',
              value: source.transit!,
              provisional: false,
            ),
          ],
          if (source.tradition != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            _BaseRow(
              label: 'Nella tradizione',
              value: source.tradition!,
              provisional: false,
            ),
          ],
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
  const _ShareWordButton({required this.onShare, required this.accento});

  final VoidCallback onShare;

  /// L'accento del Maestro del giorno, deciso una volta sola dalla scheda.
  final Color accento;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      key: const Key('gift_share_word'),
      onPressed: onShare,
      style: TextButton.styleFrom(
        foregroundColor: accento,
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          side: BorderSide(color: accento.withValues(alpha: 0.5)),
        ),
      ),
      icon: const Icon(Icons.ios_share_rounded, size: 16),
      label: Text(
        'Condividi la parola',
        style: TypographyTokens.label(size: 12)
            .copyWith(color: accento, letterSpacing: 0.5),
      ),
    );
  }
}

/// Indicatore discreto dei giorni consecutivi di rito compiuto.
class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.days, required this.accento});

  /// L'accento del Maestro del giorno, deciso una volta sola dalla scheda.
  final Color accento;

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
          Icon(Icons.wb_twilight_rounded, size: 14, color: accento),
          const SizedBox(width: 6),
          Text(
            label,
            style: TypographyTokens.label(size: 11).copyWith(
              color: accento,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/tarot/tarot_card.dart';
import '../../core/tarot/tarot_spread.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// **IL COLPO D'OCCHIO DELLA STESA: GLI ELEMENTI DELLE CARTE USCITE.** Ordine
/// GC voce GC.06, 22 ottobre 2026.
///
/// Il fondatore, alle 16:06: *"io noto che c'è troppo testo e infografica zero
/// e ci sono delle regole per le risposte o responsi che indicano di inserire
/// sempre un impatto visivo grafico per non appesantire di testo e annoiare
/// l'utente"*; alle 16:09, alla direzione proposta dall'Architetto:
/// *"Approvo"*. Briefing V13, sezione 33, e Linee Guida V14, sezione 2: ogni
/// responso apre con un colpo d'occhio visivo prima del testo.
///
/// **LA REGOLA DI CALCOLO, senza percentuali inventate.** Ogni Arcano Minore
/// porta il suo seme, e ogni seme il suo elemento secondo l'abbinamento della
/// Golden Dawn che il catalogo ha gia' (`TarotSeme.elemento`, fonte nelle
/// fonti dei Tarocchi): Bastoni fuoco, Coppe acqua, Spade aria, Denari terra.
/// La barra di un seme e' piena quanto le sue carte sul totale delle carte
/// uscite (due Coppe su tre carte: due terzi); gli Arcani Maggiori non hanno
/// seme e si contano a parte, nel loro segno. Il numero accanto a ogni barra
/// e' il conto vero, "2 su 3": niente che le carte non dicano.
///
/// **LA FORMA: QUATTRO PISTE ORIZZONTALI CON L'EMBLEMA DIPINTO DEL SEME**, e
/// sotto il segno degli Arcani Maggiori. Non e' un tipo di grafico che l'app
/// usa gia': le colonne verticali dei giorni dell'Oroscopo
/// (`LeBarreDellaSettimana`) dicono un andamento nel tempo, la griglia del
/// Mese un calendario, la scala del livello un gradino, la lancetta della
/// Sinastria un'intesa, la ruota natale un cielo; qui c'e' una distribuzione
/// di quattro elementi, ognuno col suo emblema. La scala di luce dell'Oracolo
/// (GC.18) e' un'altra forma ancora.
///
/// **LA GRAFICA E' DIPINTA, NON DISEGNATA (R8).** I simboli dei semi e il
/// segno degli Arcani Maggiori sono i pezzi dipinti dal fondatore
/// (`assets/img/simboli/`, ordine GC); il codice disegna solo le piste, che
/// sono grafica funzionale. Se un simbolo non si carica resta il segnaposto
/// semplice nel colore del seme ([coloreDi]).
///
/// **LA MICRO-ANIMAZIONE**: le piste si riempiono una dopo l'altra, in
/// [durata]. Con Riduci Movimento o la grafica alleggerita ([fermo]) il
/// grafico appare gia' costruito e fermo.
class LeBarreDeiSemi extends StatefulWidget {
  const LeBarreDeiSemi({
    super.key,
    required this.carte,
    required this.palette,
    this.fermo = false,
  });

  final List<DrawnCard> carte;
  final MaestroPalette palette;

  /// Riduci Movimento o grafica alleggerita: niente riempimento, il grafico
  /// e' gia' costruito.
  final bool fermo;

  /// Quanto dura il riempimento di tutte le piste.
  static const Duration durata = Duration(milliseconds: 1200);

  /// L'emblema dipinto di un seme, in `assets/img/simboli/`.
  static String simboloDi(TarotSeme seme) =>
      'assets/img/simboli/sig_seme_${seme.name}_v1.webp';

  /// Il segno dipinto degli Arcani Maggiori.
  static const String simboloDeiMaggiori =
      'assets/img/simboli/sig_arcani_maggiori_v1.webp';

  /// **IL COLORE DI UN SEME**, quello del suo elemento: e' il colore della
  /// pista e del segnaposto finche' il simbolo dipinto non c'e'.
  static Color coloreDi(TarotSeme seme) => switch (seme) {
        TarotSeme.bastoni => const Color(0xFFE8663A),
        TarotSeme.coppe => const Color(0xFF4C9BE8),
        TarotSeme.spade => const Color(0xFFC9D3E0),
        TarotSeme.denari => const Color(0xFF5FB85A),
      };

  /// L'ordine delle piste: l'ordine degli elementi della tradizione, dal
  /// fuoco alla terra.
  static const List<TarotSeme> ordine = [
    TarotSeme.bastoni,
    TarotSeme.coppe,
    TarotSeme.spade,
    TarotSeme.denari,
  ];

  /// **IL CONTO DELLE CARTE PER SEME**, la sola fonte dei numeri del grafico.
  static Map<TarotSeme, int> contaISemi(List<DrawnCard> carte) => {
        for (final s in ordine)
          s: carte.where((c) => c.card.seme == s).length,
      };

  /// Quanti Arcani Maggiori fra le carte uscite.
  static int contaIMaggiori(List<DrawnCard> carte) =>
      carte.where((c) => c.card.arcana == TarotArcana.maggiore).length;

  /// Quanto e' piena la pista di un seme, da 0 a 1: le sue carte sul totale.
  static double pienezza(List<DrawnCard> carte, TarotSeme seme) =>
      carte.isEmpty ? 0 : contaISemi(carte)[seme]! / carte.length;

  @override
  State<LeBarreDeiSemi> createState() => _LeBarreDeiSemiState();
}

class _LeBarreDeiSemiState extends State<LeBarreDeiSemi>
    with SingleTickerProviderStateMixin {
  late final AnimationController _riempi = AnimationController(
      vsync: this, duration: LeBarreDeiSemi.durata);

  @override
  void initState() {
    super.initState();
    if (widget.fermo) {
      _riempi.value = 1;
    } else {
      _riempi.forward();
    }
  }

  @override
  void didUpdateWidget(covariant LeBarreDeiSemi vecchio) {
    super.didUpdateWidget(vecchio);
    if (widget.fermo) _riempi.value = 1;
  }

  @override
  void dispose() {
    _riempi.dispose();
    super.dispose();
  }

  /// Quanto della sua pienezza ha gia' raggiunto la pista [i]: le quattro
  /// piste e il segno dei Maggiori partono uno dopo l'altro.
  double _avanzamento(int i) {
    const n = 5;
    final inizio = i / (n + 1);
    final t = ((_riempi.value - inizio) * (n + 1) / 2).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(t);
  }

  @override
  Widget build(BuildContext context) {
    final carte = widget.carte;
    final palette = widget.palette;
    final conti = LeBarreDeiSemi.contaISemi(carte);
    final maggiori = LeBarreDeiSemi.contaIMaggiori(carte);
    final totale = carte.length;
    return Semantics(
      label: 'Gli elementi delle carte uscite: ${[
        for (final s in LeBarreDeiSemi.ordine)
          '${s.italianName}, ${s.elemento}, ${conti[s]} su $totale',
      ].join('; ')}; Arcani Maggiori $maggiori su $totale',
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _riempi,
          builder: (context, _) => Container(
            key: const Key('stesa_colpo_d_occhio'),
            padding: const EdgeInsets.all(SpacingTokens.md),
            decoration: BoxDecoration(
              color: palette.surfaceElevated.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
              border: Border.all(color: palette.gold.withValues(alpha: 0.25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < LeBarreDeiSemi.ordine.length; i++) ...[
                  if (i > 0) const SizedBox(height: SpacingTokens.xs),
                  _LaPista(
                    seme: LeBarreDeiSemi.ordine[i],
                    quante: conti[LeBarreDeiSemi.ordine[i]]!,
                    totale: totale,
                    avanzamento: _avanzamento(i),
                    palette: palette,
                  ),
                ],
                const SizedBox(height: SpacingTokens.sm),
                _IMaggiori(
                  quanti: maggiori,
                  totale: totale,
                  avanzamento: _avanzamento(4),
                  palette: palette,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// L'emblema dipinto, o il segnaposto nel colore del seme se il file manca.
class _Emblema extends StatelessWidget {
  const _Emblema({required this.percorso, required this.colore, this.acceso = 1});

  final String percorso;
  final Color colore;

  /// Da 0 spento a 1 acceso: un seme senza carte resta in penombra.
  final double acceso;

  static const double lato = 36;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.35 + 0.65 * acceso,
      child: SizedBox(
        width: lato,
        height: lato,
        child: Image.asset(
          percorso,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          errorBuilder: (context, errore, traccia) => DecoratedBox(
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: colore.withValues(alpha: 0.8)),
          ),
        ),
      ),
    );
  }
}

/// UNA PISTA: l'emblema del seme, il nome e l'elemento, la pista che si
/// riempie e il conto vero.
class _LaPista extends StatelessWidget {
  const _LaPista({
    required this.seme,
    required this.quante,
    required this.totale,
    required this.avanzamento,
    required this.palette,
  });

  final TarotSeme seme;
  final int quante;
  final int totale;
  final double avanzamento;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final colore = LeBarreDeiSemi.coloreDi(seme);
    final pienezza = totale == 0 ? 0.0 : quante / totale;
    final etichetta = TypographyTokens.etichetta();
    return Row(
      key: Key('stesa_pista_${seme.name}'),
      children: [
        _Emblema(
            percorso: LeBarreDeiSemi.simboloDi(seme),
            colore: colore,
            acceso: quante > 0 ? 1 : 0),
        const SizedBox(width: SpacingTokens.xs),
        SizedBox(
          width: 92,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(seme.italianName.toUpperCase(),
                    maxLines: 1,
                    style: etichetta.copyWith(
                        color: quante > 0
                            ? palette.goldSoft
                            : ColorTokens.textSecondary,
                        letterSpacing: 1.1)),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(seme.elemento,
                    maxLines: 1,
                    style: TypographyTokens.didascalia()
                        .copyWith(color: ColorTokens.textSecondary)),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, vincoli) => Container(
              height: 12,
              decoration: BoxDecoration(
                color: palette.deepest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: colore.withValues(alpha: 0.35)),
              ),
              alignment: Alignment.centerLeft,
              child: Container(
                key: Key('stesa_pista_piena_${seme.name}'),
                width: vincoli.maxWidth * pienezza * avanzamento,
                decoration: BoxDecoration(
                  color: colore,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    if (pienezza > 0)
                      BoxShadow(
                          color: colore.withValues(alpha: 0.45),
                          blurRadius: 6),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: SpacingTokens.xs),
        SizedBox(
          width: 44,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text('$quante su $totale',
                key: Key('stesa_pista_conto_${seme.name}'),
                maxLines: 1,
                style: etichetta.copyWith(
                    color: quante > 0
                        ? ColorTokens.textPrimary
                        : ColorTokens.textSecondary)),
          ),
        ),
      ],
    );
  }
}

/// IL SEGNO DEGLI ARCANI MAGGIORI: acceso se ne e' uscito almeno uno, col
/// conto vero.
class _IMaggiori extends StatelessWidget {
  const _IMaggiori({
    required this.quanti,
    required this.totale,
    required this.avanzamento,
    required this.palette,
  });

  final int quanti;
  final int totale;
  final double avanzamento;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final acceso = quanti > 0 ? avanzamento : 0.0;
    return Row(
      key: const Key('stesa_segno_dei_maggiori'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.scale(
          scale: 0.9 + 0.1 * acceso,
          child: _Emblema(
              percorso: LeBarreDeiSemi.simboloDeiMaggiori,
              colore: palette.gold,
              acceso: acceso),
        ),
        const SizedBox(width: SpacingTokens.xs),
        Flexible(
          child: Text(
              quanti == 0
                  ? 'Nessun Arcano Maggiore'
                  : 'Arcani Maggiori: $quanti su $totale',
              key: const Key('stesa_conto_dei_maggiori'),
              style: TypographyTokens.didascalia().copyWith(
                  color: quanti > 0
                      ? palette.goldSoft
                      : ColorTokens.textSecondary)),
        ),
      ],
    );
  }
}

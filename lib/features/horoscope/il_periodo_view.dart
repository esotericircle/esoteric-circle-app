import 'package:flutter/material.dart';

import '../../core/astro/aspetti_di_oggi.dart';
import '../../core/horoscope/la_settimana_del_cielo.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// **LA SETTIMANA E IL MESE A VIDEO, ordine ES voci 02 e 03.**
///
/// In cima i fatti del cielo del periodo (fasi della Luna, eclissi, ingressi),
/// poi un riquadro per dominio: il giorno migliore, il momento chiave con
/// giorno e ora, e le righe dei giorni. Nella settimana le righe sono sette,
/// una per giorno; nel mese sono i tre giorni col livello piu' alto, perche'
/// trenta righe per quattro domini non si leggono. Senza carta natale la
/// schermata dice che il periodo si legge sul segno e sulle case solari.
class IlPeriodoView extends StatelessWidget {
  const IlPeriodoView({
    super.key,
    required this.periodo,
    required this.mese,
    required this.palette,
    required this.livello,
  });

  /// **IL LIVELLO DEI DATI DALLA PORTA COMUNE**, [CieloDiOggi.livello]: e'
  /// lui a dire se l'avviso c'e' e quale (la guardia
  /// `la_carta_natale_sopravvive`, una porta sola per chi avvisa).
  final LivelloPersonalizzazione livello;

  final IlPeriodoDelCielo periodo;

  /// Vero per il mensile, falso per il settimanale.
  final bool mese;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final nome = mese ? 'questo mese' : 'questa settimana';
    return Column(
      key: Key(mese ? 'oroscopo_il_mese' : 'oroscopo_la_settimana'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (livello != LivelloPersonalizzazione.cartaCompleta)
          Padding(
            padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
            child: Text(
              livello == LivelloPersonalizzazione.soloSegno
                  ? 'Senza ora e luogo di nascita $nome si legge sul tuo '
                      'segno e sulle case solari.'
                  : 'Senza l\'ora di nascita $nome si legge sui tuoi pianeti, '
                      'con le case solari al posto di quelle della carta.',
              key: const Key('oroscopo_periodo_sul_segno'),
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textSecondary, height: 1.4),
            ),
          ),
        _Riquadro(
          palette: palette,
          titolo: mese ? 'Il cielo del mese' : 'Il cielo della settimana',
          figli: [
            if (periodo.eventi.isEmpty)
              Text('Nessun ingresso e nessuna fase della Luna in $nome.',
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textSecondary)),
            for (final e in periodo.eventi)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(e.testo,
                    style: TypographyTokens.didascalia()
                        .copyWith(color: ColorTokens.textPrimary, height: 1.4)),
              ),
          ],
        ),
        for (final d in periodo.domini) ...[
          const SizedBox(height: SpacingTokens.md),
          _Riquadro(
            key: Key('oroscopo_periodo_${d.dominio.name}'),
            palette: palette,
            titolo: d.dominio.label,
            figli: [
              Text(
                  'Il giorno migliore: '
                  '${LaSettimanaDelCielo.data(d.migliore.giorno)}, livello '
                  '${d.migliore.livello} su 5.',
                  style: TypographyTokens.corpo()
                      .copyWith(color: palette.goldSoft, height: 1.4)),
              const SizedBox(height: 4),
              Text('Il momento chiave: ${d.momentoChiave}',
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textPrimary, height: 1.4)),
              const SizedBox(height: SpacingTokens.sm),
              for (final g in mese ? _treMigliori(d) : d.giorni)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 92,
                        child: Text(LaSettimanaDelCielo.data(g.giorno),
                            style: TypographyTokens.didascalia()
                                .copyWith(color: palette.goldSoft)),
                      ),
                      _Pallini(livello: g.livello, palette: palette),
                      const SizedBox(width: SpacingTokens.sm),
                      Expanded(
                        child: Text(g.motivo,
                            style: TypographyTokens.didascalia().copyWith(
                                color: ColorTokens.textSecondary,
                                height: 1.35)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  static List<GiornoDelPeriodo> _treMigliori(DominioDelPeriodo d) {
    final ordinati = [...d.giorni]..sort((a, b) => b.livello != a.livello
        ? b.livello.compareTo(a.livello)
        : a.giorno.compareTo(b.giorno));
    return (ordinati.take(3).toList())
      ..sort((a, b) => a.giorno.compareTo(b.giorno));
  }
}

class _Riquadro extends StatelessWidget {
  const _Riquadro(
      {super.key,
      required this.palette,
      required this.titolo,
      required this.figli});

  final MaestroPalette palette;
  final String titolo;
  final List<Widget> figli;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        color: palette.surfaceElevated.withValues(alpha: 0.85),
        border: Border.all(color: palette.gold.withValues(alpha: 0.32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titolo,
              style: TypographyTokens.titoloScheda()
                  .copyWith(color: palette.goldSoft)),
          const SizedBox(height: SpacingTokens.sm),
          ...figli,
        ],
      ),
    );
  }
}

/// Il livello in cinque pallini, gli stessi due-cinque della scheda.
class _Pallini extends StatelessWidget {
  const _Pallini({required this.livello, required this.palette});

  final int livello;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'livello $livello su 5',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            Padding(
              padding: const EdgeInsets.only(right: 2, top: 5),
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= livello
                      ? palette.goldSoft
                      : palette.gold.withValues(alpha: 0.18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

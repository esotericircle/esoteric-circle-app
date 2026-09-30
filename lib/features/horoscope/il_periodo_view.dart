import 'package:flutter/material.dart';

import '../../core/astro/aspetti_di_oggi.dart';
import '../../core/horoscope/horoscope.dart';
import '../../core/horoscope/la_settimana_del_cielo.dart';
import '../../core/l10n/numero_del_cerchio.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'answer_depth.dart';

/// **LA SETTIMANA E IL MESE A VIDEO, ordine ES voci 02 e 03.**
///
/// **Riscritta nelle tre parti del responso il 30 settembre 2026.** Il
/// fondatore, davanti all'anteprima della Settimana: *"per ogni giorno della
/// settimana c'è il transito: all'utente non gliene frega un cazzo dei
/// transiti, quante volte devo scriverlo e chiederlo? Vuole sapere come andrà
/// in generale, in amore, in lavoro, ecc. Se vuoi inserire i transiti, li
/// inserisci dopo giusto per motivare da dove arriva la risposta."* Prima,
/// in cima stavano i fatti del cielo del periodo, e ogni riquadro apriva col
/// momento chiave (un aspetto della Luna) e proseguiva con una riga di
/// transiti per giorno: la risposta non c'era. Padre: ordine ES voci 02 e 03,
/// che hanno seguito la descrizione del contenuto senza metterla accanto alle
/// Linee Guida, sezione 2.
///
/// Adesso un riquadro per campo, in quest'ordine:
/// 1. **il colpo d'occhio**: i giorni del periodo col loro livello, il
///    migliore in evidenza;
/// 2. **la risposta**: come va il periodo in quel campo, in parole di tutti i
///    giorni ([DominioDelPeriodo.risposta]), e qual e' il giorno migliore;
/// 3. **che cosa puoi fare**: la lettura di quel giorno dal corpus delle
///    schede del Giorno ([DominioDelPeriodo.cosaFare]);
/// 4. **da dove viene**, in fondo al riquadro e piu' piccolo: il momento
///    chiave, che e' un passaggio del cielo.
///
/// **LA PROFONDITA' SU OGNI SCHEDA**: la Breve e' cio' che sta qui sopra; la
/// Lunga aggiunge il giorno per giorno (sette giorni nella Settimana, i tre
/// migliori nel Mese), ognuno con la sua lettura in parole e, dopo, i
/// passaggi da cui viene il suo livello. In fondo alla pagina i fatti del
/// cielo del periodo e, senza carta natale, su che cosa si e' letto.
class IlPeriodoView extends StatelessWidget {
  const IlPeriodoView({
    super.key,
    required this.periodo,
    required this.mese,
    required this.palette,
    required this.livello,
    required this.profondita,
    required this.premiumUnlocked,
    required this.onDepthSelected,
    required this.onDepthLocked,
  });

  /// La profondita' scelta per ogni dominio, la stessa delle schede del
  /// Giorno.
  final Map<HoroscopeDomain, AnswerDepth> profondita;

  /// Se il piano di chi guarda apre la Lunga.
  final bool premiumUnlocked;
  final void Function(HoroscopeDomain, AnswerDepth) onDepthSelected;
  final void Function(HoroscopeDomain, AnswerDepth) onDepthLocked;

  /// **IL LIVELLO DEI DATI DALLA PORTA COMUNE**, [CieloDiOggi.livello]: e'
  /// lui a dire se l'avviso c'e' e quale (la guardia
  /// `la_carta_natale_sopravvive`, una porta sola per chi avvisa).
  final LivelloPersonalizzazione livello;

  final IlPeriodoDelCielo periodo;

  /// Vero per il mensile, falso per il settimanale.
  final bool mese;
  final MaestroPalette palette;

  bool _lunga(HoroscopeDomain d) =>
      (profondita[d] ?? AnswerDepth.free) == AnswerDepth.profonda;

  @override
  Widget build(BuildContext context) {
    final nome = mese ? 'questo mese' : 'questa settimana';
    final piccolo = TypographyTokens.didascalia()
        .copyWith(color: ColorTokens.textSecondary, height: 1.4);
    return Column(
      key: Key(mese ? 'oroscopo_il_mese' : 'oroscopo_la_settimana'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final d in periodo.domini) ...[
          _Riquadro(
            key: Key('oroscopo_periodo_${d.dominio.name}'),
            palette: palette,
            titolo: d.dominio.label,
            accanto: AnswerDepthSelector(
              key: Key('oroscopo_periodo_depth_${d.dominio.name}'),
              current: profondita[d.dominio] ?? AnswerDepth.free,
              palette: palette,
              premiumUnlocked: premiumUnlocked,
              onSelect: (scelta) => onDepthSelected(d.dominio, scelta),
              onLockedTap: (scelta) => onDepthLocked(d.dominio, scelta),
            ),
            figli: [
              // 1. Il colpo d'occhio: i giorni col loro livello.
              _Andamento(
                  key: Key('oroscopo_periodo_andamento_${d.dominio.name}'),
                  dominio: d,
                  mese: mese,
                  palette: palette),
              const SizedBox(height: SpacingTokens.sm),
              // 2. La risposta, in parole di tutti i giorni.
              Text(d.risposta(mese: mese),
                  key: Key('oroscopo_periodo_risposta_${d.dominio.name}'),
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textPrimary, height: 1.4)),
              const SizedBox(height: 4),
              Text(d.rigaDelMigliore,
                  key: Key('oroscopo_periodo_migliore_${d.dominio.name}'),
                  style: TypographyTokens.corpo()
                      .copyWith(color: palette.goldSoft, height: 1.4)),
              const SizedBox(height: 4),
              // 3. Che cosa puoi fare: la lettura di quel giorno.
              Text(d.cosaFare,
                  key: Key('oroscopo_periodo_cosa_fare_${d.dominio.name}'),
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textPrimary, height: 1.4)),
              // La Lunga: il giorno per giorno, la lettura prima e il cielo
              // dopo.
              if (_lunga(d.dominio)) ...[
                const SizedBox(height: SpacingTokens.md),
                Text(mese ? 'I tre giorni migliori' : 'Giorno per giorno',
                    style: TypographyTokens.etichetta().copyWith(
                        color: ColorTokens.textSecondary, letterSpacing: 1.2)),
                for (final g in mese ? _treMigliori(d) : d.giorni)
                  Padding(
                    key: Key('oroscopo_periodo_riga_${d.dominio.name}_'
                        '${g.giorno.month}_${g.giorno.day}'),
                    padding: const EdgeInsets.only(top: SpacingTokens.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(LaSettimanaDelCielo.data(g.giorno),
                                  style: TypographyTokens.didascalia()
                                      .copyWith(color: palette.goldSoft)),
                            ),
                            _Pallini(livello: g.livello, palette: palette),
                          ],
                        ),
                        Text(g.lettura,
                            style: TypographyTokens.didascalia().copyWith(
                                color: ColorTokens.textPrimary, height: 1.35)),
                        Text(_daDove(g.motivo),
                            style: piccolo.copyWith(height: 1.35)),
                      ],
                    ),
                  ),
              ],
              // 4. Da dove viene, in fondo.
              const SizedBox(height: SpacingTokens.sm),
              Text(
                  d.momentoChiave.startsWith('Nessun')
                      ? 'Da dove viene: ${_minuscola(d.momentoChiave)}'
                      : 'Da dove viene: il momento chiave è '
                          '${d.momentoChiave}',
                  key: Key('oroscopo_periodo_da_dove_${d.dominio.name}'),
                  style: piccolo),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
        ],
        // I fatti del cielo del periodo: motivano, quindi stanno dopo.
        _Riquadro(
          key: const Key('oroscopo_periodo_cielo'),
          palette: palette,
          titolo: mese
              ? 'Da dove viene: il cielo del mese'
              : 'Da dove viene: il cielo della settimana',
          figli: [
            if (periodo.eventi.isEmpty)
              Text('Nessun ingresso e nessuna fase della Luna in $nome.',
                  style: piccolo),
            for (final e in periodo.eventi)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(e.testo, style: piccolo),
              ),
            if (livello != LivelloPersonalizzazione.cartaCompleta)
              Text(
                livello == LivelloPersonalizzazione.soloSegno
                    ? 'Senza ora e luogo di nascita $nome si legge sul tuo '
                        'segno e sulle case solari.'
                    : 'Senza l\'ora di nascita $nome si legge sui tuoi '
                        'pianeti, con le case solari al posto di quelle della '
                        'carta.',
                key: const Key('oroscopo_periodo_sul_segno'),
                style: piccolo,
              ),
          ],
        ),
      ],
    );
  }

  static String _minuscola(String s) =>
      s.isEmpty ? s : '${s[0].toLowerCase()}${s.substring(1)}';

  /// La ragione del livello di un giorno, detta dopo "Da dove viene:". Il
  /// motore la scrive come riga a se' ("Dal cielo del giorno: ...", "Dalla
  /// Luna del giorno in ..."): qui continua la frase.
  static String _daDove(String motivo) {
    const dalCielo = 'Dal cielo del giorno: ';
    const dallaLuna = 'Dalla Luna';
    if (motivo.startsWith(dalCielo)) {
      return 'Da dove viene: ${motivo.substring(dalCielo.length)}';
    }
    if (motivo.startsWith(dallaLuna)) {
      return 'Da dove viene: la Luna${motivo.substring(dallaLuna.length)}';
    }
    return 'Da dove viene: ${_minuscola(motivo)}';
  }

  static List<GiornoDelPeriodo> _treMigliori(DominioDelPeriodo d) {
    final ordinati = [...d.giorni]..sort((a, b) => b.livello != a.livello
        ? b.livello.compareTo(a.livello)
        : a.giorno.compareTo(b.giorno));
    return (ordinati.take(3).toList())
      ..sort((a, b) => a.giorno.compareTo(b.giorno));
  }
}

/// **IL COLPO D'OCCHIO DEL PERIODO**: una colonna per giorno, alta quanto il
/// suo livello, il giorno migliore in oro pieno. Nella Settimana sotto ogni
/// colonna c'e' l'iniziale del giorno.
class _Andamento extends StatelessWidget {
  const _Andamento(
      {super.key,
      required this.dominio,
      required this.mese,
      required this.palette});

  final DominioDelPeriodo dominio;
  final bool mese;
  final MaestroPalette palette;

  static const List<String> _iniziali = ['L', 'M', 'M', 'G', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final migliore = dominio.migliore.giorno;
    return Semantics(
      label: 'Andamento del periodo: livello medio '
          '${NumeroDelCerchio.conCifre(dominio.media, 1)} su 5',
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final g in dominio.giorni)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: mese ? 1 : 3),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        // Dodici punti fra un livello e l'altro, da 20 a
                        // 56: con sei (da 18 a 36) nell'anteprima del 30
                        // settembre le barre sembravano tutte uguali, e il
                        // colpo d'occhio non diceva niente.
                        height: 20.0 + (g.livello.clamp(2, 5) - 2) * 12.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: g.giorno == migliore
                              ? palette.goldSoft
                              : palette.gold.withValues(alpha: 0.35),
                        ),
                      ),
                      if (!mese) ...[
                        const SizedBox(height: 2),
                        Text(_iniziali[g.giorno.weekday - 1],
                            style: TypographyTokens.etichetta().copyWith(
                                color: g.giorno == migliore
                                    ? palette.goldSoft
                                    : ColorTokens.textSecondary)),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Riquadro extends StatelessWidget {
  const _Riquadro(
      {super.key,
      required this.palette,
      required this.titolo,
      required this.figli,
      this.accanto});

  final MaestroPalette palette;
  final String titolo;
  final List<Widget> figli;

  /// Cio' che sta in alto a destra, accanto al titolo: la profondita'.
  final Widget? accanto;

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(titolo,
                    style: TypographyTokens.titoloScheda()
                        .copyWith(color: palette.goldSoft)),
              ),
              if (accanto != null) ...[
                const SizedBox(width: SpacingTokens.sm),
                accanto!,
              ],
            ],
          ),
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

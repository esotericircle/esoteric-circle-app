import 'package:flutter/material.dart';

import '../../design_system/components/riquadro_in_evidenza.dart';

import '../../core/astro/aspetti_di_oggi.dart';
import '../../core/horoscope/horoscope.dart';
import '../../core/horoscope/i_testi_eu.dart';
import '../../core/horoscope/la_settimana_del_cielo.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'answer_depth.dart';
import 'titolo_della_scheda_del_giorno.dart';

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
            // **IL TITOLO SOPRA IL DOMINIO**, ordine EU voci 08 e 18, come
            // nel Giorno: il titolo della voce del periodo.
            sopra: d.voce.titolo,
            chiaveDelTitolo: Key('oroscopo_periodo_titolo_${d.dominio.name}'),
            accanto: AnswerDepthSelector(
              key: Key('oroscopo_periodo_depth_${d.dominio.name}'),
              current: profondita[d.dominio] ?? AnswerDepth.free,
              palette: palette,
              premiumUnlocked: premiumUnlocked,
              onSelect: (scelta) => onDepthSelected(d.dominio, scelta),
              onLockedTap: (scelta) => onDepthLocked(d.dominio, scelta),
            ),
            figli: [
              // 1. Il colpo d'occhio: i giorni col loro livello, a barre nella
              // Settimana e a calendario nel Mese (ordine EU voci 09 e 11).
              if (mese)
                IlCalendarioDelMese(
                    key: Key('oroscopo_periodo_andamento_${d.dominio.name}'),
                    dominio: d)
              else
                LeBarreDellaSettimana(
                    key: Key('oroscopo_periodo_andamento_${d.dominio.name}'),
                    dominio: d,
                    palette: palette),
              const SizedBox(height: 6),
              const LaScalaDelLivello(),
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
              // 3. **I PARAGRAFI DELLA VOCE**, EU Aggiunta (voci EU.01 ed
              // EU.16): la Risposta e Che cosa fare in Breve, e in Lunga gli
              // altri due, dal corpus della Settimana o del Mese. Prima qui
              // stava la lettura del giorno migliore presa dal Giorno, cioe'
              // la stessa frase in due periodi.
              for (final (i, p)
                  in d.voce.paragrafi(lunga: _lunga(d.dominio)).indexed) ...[
                const SizedBox(height: SpacingTokens.sm),
                // Il terzo paragrafo della Lunga in un riquadro (il
                // fondatore, 1 ottobre 2026).
                if (RiquadroInEvidenza.eIlTerzoDellaLunga(
                    i, d.voce.paragrafi(lunga: _lunga(d.dominio)).length))
                  RiquadroInEvidenza(
                    palette: palette,
                    child: Text(p,
                        key: Key(
                            'oroscopo_periodo_paragrafo_${d.dominio.name}_$i'),
                        style: TypographyTokens.corpo().copyWith(
                            color: ColorTokens.textPrimary, height: 1.4)),
                  )
                else
                  Text(p,
                      key: Key(
                          'oroscopo_periodo_paragrafo_${d.dominio.name}_$i'),
                      style: TypographyTokens.corpo().copyWith(
                          color: ColorTokens.textPrimary, height: 1.4)),
              ],
              // La Lunga: i tre giorni migliori, ognuno col titolo della sua
              // scheda del Giorno e il suo "Da dove viene" (EU Aggiunta): il
              // testo del Giorno si legge quel giorno.
              if (_lunga(d.dominio)) ...[
                const SizedBox(height: SpacingTokens.md),
                Text('I tre giorni migliori',
                    style: TypographyTokens.etichetta().copyWith(
                        color: ColorTokens.textSecondary, letterSpacing: 1.2)),
                for (final g in _treMigliori(d))
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
                        Text(g.titolo,
                            key: Key('oroscopo_periodo_titolo_del_giorno_'
                                '${d.dominio.name}_${g.giorno.month}_'
                                '${g.giorno.day}'),
                            style: TypographyTokens.corpo().copyWith(
                                color: ColorTokens.textPrimary, height: 1.35)),
                        Text(_daDove(g.motivo),
                            style: piccolo.copyWith(height: 1.35)),
                      ],
                    ),
                  ),
              ],
              // 4. Da dove viene, in fondo. **Nella Lunga della Vedica e della
              // Cinese non c'e'**: e' il "Da dove viene" del giorno migliore,
              // che sta gia' fra i tre giorni migliori qui sopra. Visto sul
              // Realme il 1 ottobre 2026, la stessa frase due volte di fila.
              if (periodo.tradizione == TradizioneEu.occidentale ||
                  !_lunga(d.dominio)) ...[
                const SizedBox(height: SpacingTokens.sm),
                Text(
                    periodo.tradizione != TradizioneEu.occidentale
                        ? 'Da dove viene: ${d.momentoChiave}'
                        : d.momentoChiave.startsWith('Nessun')
                            ? 'Da dove viene: ${_minuscola(d.momentoChiave)}'
                            : 'Da dove viene: il momento chiave è '
                                '${d.momentoChiave}',
                    key: Key('oroscopo_periodo_da_dove_${d.dominio.name}'),
                    style: piccolo),
              ],
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
        ],
        // I fatti del cielo del periodo: motivano, quindi stanno dopo. Solo
        // nell'Occidentale: la Vedica e la Cinese leggono il loro Giorno.
        if (periodo.tradizione == TradizioneEu.occidentale)
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

/// **LE BARRE DELLA SETTIMANA, ordine EU voce 09.** Il fondatore: *"le
/// barre di cui una gialla in evidenza sembrano tutte uguali, dovrebbe
/// cambiare anche l'altezza e magari inserire una percentuale [...] da giallo
/// opaco a rosso fuoco per il giorno migliore"*, e sulla proposta
/// dell'Architetto *"Altezza e colore"*. Prima ogni colonna andava da 20 a
/// 56 punti e tutte, tranne la migliore, avevano lo stesso oro velato.
///
/// Adesso una colonna per giorno, **alta in proporzione al livello** (un
/// quinto dell'altezza piena per ogni gradino), **del colore del suo
/// gradino** ([ColorTokens.delLivello]), e **sopra la migliore la sua
/// percentuale** (il livello in centesimi: 4 su 5 e' l'80%). Sotto ogni
/// colonna l'iniziale del giorno. Niente animazione: con Riduci Movimento si
/// legge uguale; al carattere massimo la percentuale e l'iniziale si
/// stringono nella loro colonna invece di andare a capo.
class LeBarreDellaSettimana extends StatelessWidget {
  const LeBarreDellaSettimana(
      {super.key, required this.dominio, required this.palette});

  final DominioDelPeriodo dominio;
  final MaestroPalette palette;

  /// L'altezza della colonna del livello 5.
  static const double altezzaPiena = 64;

  static const List<String> _iniziali = ['L', 'M', 'M', 'G', 'V', 'S', 'D'];

  /// L'altezza della colonna di un livello.
  static double altezzaDi(int livello) =>
      altezzaPiena * livello.clamp(1, 5) / 5;

  @override
  Widget build(BuildContext context) {
    final migliore = dominio.migliore.giorno;
    final etichetta = TypographyTokens.etichetta();
    return Semantics(
      label: 'Andamento della settimana: '
          '${[
        for (final g in dominio.giorni)
          '${LaSettimanaDelCielo.data(g.giorno)} ${g.livello} su 5'
      ].join(', ')}; il giorno migliore è '
          '${LaSettimanaDelCielo.data(migliore)}',
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final g in dominio.giorni)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (g.giorno == migliore)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('${g.livello * 20}%',
                              key: Key('oroscopo_periodo_percentuale_'
                                  '${dominio.dominio.name}'),
                              maxLines: 1,
                              style: etichetta.copyWith(
                                  color: ColorTokens.delLivello(g.livello),
                                  fontWeight: FontWeight.w700)),
                        ),
                      const SizedBox(height: 2),
                      Container(
                        key: Key('oroscopo_periodo_barra_'
                            '${dominio.dominio.name}_${g.giorno.day}'),
                        height: altezzaDi(g.livello),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: ColorTokens.delLivello(g.livello),
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(_iniziali[g.giorno.weekday - 1],
                            maxLines: 1,
                            style: etichetta.copyWith(
                                color: g.giorno == migliore
                                    ? palette.goldSoft
                                    : ColorTokens.textSecondary)),
                      ),
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

/// **IL MESE A GRIGLIA, ordine EU voce 11.** Il fondatore: *"L'oroscopo
/// mensile ha lo stesso problema dell'infografica poco chiara e molto simile
/// tra loro"*, e sulla proposta dell'Architetto (*"Il Mese diventa un
/// calendario a griglia di 5 settimane con le caselle colorate"*) *"Altezza e
/// colore"*. Prima il Mese erano trenta colonne sottili.
///
/// Adesso un calendario: le colonne sono i giorni della settimana, da lunedi'
/// a domenica, e ogni giorno del periodo ha la sua casella col numero del
/// giorno, del colore del suo gradino ([ColorTokens.delLivello]); il giorno
/// migliore ha il bordo d'oro e la sua percentuale. I trenta giorni partono
/// da oggi: le caselle prima di oggi nella prima riga e dopo l'ultimo giorno
/// nell'ultima restano vuote. Cinque righe, sei quando il periodo comincia di
/// domenica.
class IlCalendarioDelMese extends StatelessWidget {
  const IlCalendarioDelMese({super.key, required this.dominio});

  final DominioDelPeriodo dominio;

  static const List<String> _iniziali = ['L', 'M', 'M', 'G', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final giorni = dominio.giorni;
    final migliore = dominio.migliore.giorno;
    final vuoteInTesta = giorni.first.giorno.weekday - 1;
    final caselle = <GiornoDelPeriodo?>[
      for (var i = 0; i < vuoteInTesta; i++) null,
      ...giorni,
    ];
    while (caselle.length % 7 != 0) {
      caselle.add(null);
    }
    final etichetta = TypographyTokens.etichetta();
    return Semantics(
      label: 'Calendario del mese: il giorno migliore è '
          '${LaSettimanaDelCielo.data(migliore)}, '
          '${dominio.migliore.livello} su 5',
      child: ExcludeSemantics(
        child: Column(
          children: [
            Row(
              children: [
                for (final i in _iniziali)
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(i,
                            maxLines: 1,
                            style: etichetta.copyWith(
                                color: ColorTokens.textSecondary)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            for (var r = 0; r < caselle.length ~/ 7; r++)
              Row(
                children: [
                  for (final g in caselle.sublist(r * 7, r * 7 + 7))
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: g == null
                              ? const SizedBox.shrink()
                              : _Casella(
                                  key: Key('oroscopo_periodo_casella_'
                                      '${dominio.dominio.name}_'
                                      '${g.giorno.month}_${g.giorno.day}'),
                                  giorno: g,
                                  migliore: g.giorno == migliore,
                                  dominio: dominio.dominio),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Casella extends StatelessWidget {
  const _Casella(
      {super.key,
      required this.giorno,
      required this.migliore,
      required this.dominio});

  final GiornoDelPeriodo giorno;
  final bool migliore;
  final HoroscopeDomain dominio;

  @override
  Widget build(BuildContext context) {
    final stile = TypographyTokens.etichetta()
        .copyWith(color: ColorTokens.inchiostroSulLivello);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: ColorTokens.delLivello(giorno.livello),
        border: migliore
            ? Border.all(color: ColorTokens.goldBright, width: 2)
            : null,
      ),
      padding: const EdgeInsets.all(2),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${giorno.giorno.day}',
                maxLines: 1,
                style: stile.copyWith(fontWeight: FontWeight.w700)),
            if (migliore)
              Text('${giorno.livello * 20}%',
                  key: Key('oroscopo_periodo_percentuale_${dominio.name}'),
                  maxLines: 1,
                  style: stile),
          ],
        ),
      ),
    );
  }
}

/// **LA SCALA SOTTO IL COLPO D'OCCHIO**: i cinque gradini, perche' chi
/// guarda sappia che il rosso e' il giorno pieno e il giallo quello quieto.
class LaScalaDelLivello extends StatelessWidget {
  const LaScalaDelLivello({super.key});

  @override
  Widget build(BuildContext context) {
    final stile = TypographyTokens.didascalia()
        .copyWith(color: ColorTokens.textSecondary);
    return Row(
      children: [
        Flexible(
          child: Text('più quieto',
              maxLines: 1, overflow: TextOverflow.ellipsis, style: stile),
        ),
        const SizedBox(width: 6),
        for (final c in ColorTokens.scalaDelLivello)
          Container(
            width: 12,
            height: 8,
            margin: const EdgeInsets.only(right: 2),
            decoration:
                BoxDecoration(color: c, borderRadius: BorderRadius.circular(2)),
          ),
        const SizedBox(width: 4),
        Flexible(
          child: Text('più favorevole',
              maxLines: 1, overflow: TextOverflow.ellipsis, style: stile),
        ),
      ],
    );
  }
}

class _Riquadro extends StatelessWidget {
  const _Riquadro(
      {super.key,
      required this.palette,
      required this.titolo,
      required this.figli,
      this.accanto,
      this.sopra,
      this.chiaveDelTitolo});

  final MaestroPalette palette;
  final String titolo;
  final List<Widget> figli;

  /// Il titolo della voce, sopra il dominio; il dominio scende a etichetta.
  final String? sopra;
  final Key? chiaveDelTitolo;

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
          // **IL TITOLO SOPRA, QUANDO ACCANTO SI SPEZZEREBBE**, come nella
          // scheda del Giorno (visto sul Realme il 1 ottobre 2026, ordine
          // EU): se accanto al selettore il titolo andrebbe a capo col
          // trattino, prende tutta la larghezza e sotto stanno il dominio e
          // il selettore.
          LayoutBuilder(builder: (context, vincoli) {
            final stileDelTitolo = TypographyTokens.titoloScheda()
                .copyWith(color: palette.goldSoft, height: 1.1);
            final scala = MediaQuery.textScalerOf(context);
            final conTitolo = sopra != null && sopra!.isNotEmpty;
            final sopraIlSelettore = conTitolo &&
                accanto is AnswerDepthSelector &&
                TitoloDellaSchedaDelGiorno.vaSopra(sopra!,
                    stile: stileDelTitolo,
                    larghezza: vincoli.maxWidth,
                    accanto: AnswerDepthSelector.larghezza(scala),
                    distanza: SpacingTokens.sm,
                    scala: scala);
            final dominio = Text(titolo.toUpperCase(),
                style: TypographyTokens.etichetta().copyWith(
                    color: ColorTokens.textSecondary, letterSpacing: 1.4));
            if (sopraIlSelettore) {
              return Column(
                key: chiaveDelTitolo is ValueKey<String>
                    ? Key('${(chiaveDelTitolo! as ValueKey<String>).value}'
                        '_sopra')
                    : null,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitoloDellaSchedaDelGiorno(
                      key: chiaveDelTitolo,
                      testo: sopra!,
                      stile: stileDelTitolo),
                  const SizedBox(height: SpacingTokens.xs),
                  Row(
                    children: [
                      Expanded(child: dominio),
                      const SizedBox(width: SpacingTokens.sm),
                      accanto!,
                    ],
                  ),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: !conTitolo
                      ? Text(titolo,
                          style: TypographyTokens.titoloScheda()
                              .copyWith(color: palette.goldSoft))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TitoloDellaSchedaDelGiorno(
                                key: chiaveDelTitolo,
                                testo: sopra!,
                                stile: stileDelTitolo),
                            dominio,
                          ],
                        ),
                ),
                if (accanto != null) ...[
                  const SizedBox(width: SpacingTokens.sm),
                  accanto!,
                ],
              ],
            );
          }),
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/amici/amici_offline.dart';
import '../../core/astro/luogo_attuale.dart';
import '../../core/astro/zodiac.dart';
import '../../core/chat/user_profile.dart';
import '../../core/condivisione/premio_della_condivisione.dart';
import '../../core/entitlement/entitlement_service.dart';
import '../../core/entitlement/plan_catalog.dart';
import '../../core/horoscope/astro_tradition.dart';
import '../../core/horoscope/horoscope.dart';
import '../../core/horoscope/i_segni_delle_tradizioni.dart';
import '../../core/horoscope/la_lettura_cinese.dart';
import '../../core/horoscope/la_lettura_vedica.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';
import 'amici_screen.dart';
import '../horoscope/oroscopo_per.dart';
import '../horoscope/answer_depth.dart';
import '../horoscope/horoscope_visuals.dart';
import '../horoscope/la_testa_della_tradizione.dart';
import '../horoscope/oroscopo_share_card.dart';
import '../horoscope/titolo_della_scheda_del_giorno.dart';
import '../pricing/upgrade_invite.dart';

/// **L'OROSCOPO DI UN AMICO, ordine ES voce 12.** Si sceglie la tradizione,
/// si scopre il suo segno, si leggono le quattro schede del giorno e si
/// mandano con la card.
///
/// Le letture sono le stesse della persona, sui dati dell'amico:
/// l'Occidentale sul suo segno solare (senza la sua carta natale, e si dice),
/// la Cinese dal suo animale e dal tronco del suo giorno, la Vedica dalla sua
/// Luna di nascita. Chi legge e' l'amico, quindi si parla al neutro.
class LOroscopoDellAmicoScreen extends StatefulWidget {
  const LOroscopoDellAmicoScreen(
      {super.key, required this.amico, this.adesso, this.nomeTuo});

  final Amico amico;

  /// **IL NOME DI CHI GUARDA**, ordine EU voce 05: aperta dal selettore
  /// "Oroscopo per" dell'Oroscopo, la lettura dell'amico porta in cima la
  /// stessa riga, col nome dell'amico scelto; il nome di chi guarda riporta
  /// alla sua lettura. Senza (aperta dalla lista degli amici) la riga non
  /// c'e'.
  final String? nomeTuo;

  /// L'istante di oggi, per le prove.
  final DateTime? adesso;

  /// Vestita da Medora, come la lista degli amici e il Calendario.
  static Route<void> route(Amico amico, {String? nomeTuo}) =>
      PassaggioDelCerchio.rotta<void>((_) => MaestroScope(
          maestro: Maestro.medora,
          child: LOroscopoDellAmicoScreen(amico: amico, nomeTuo: nomeTuo)));

  @override
  State<LOroscopoDellAmicoScreen> createState() =>
      _LOroscopoDellAmicoScreenState();
}

class _LOroscopoDellAmicoScreenState extends State<LOroscopoDellAmicoScreen>
    with SingleTickerProviderStateMixin {
  late final DateTime _adesso = widget.adesso ?? DateTime.now();
  AstroTradition _tradizione = AstroTradition.occidentale;
  LuogoDelGiorno? _luogo;
  final GlobalKey _cardKey = GlobalKey();
  bool _renderCard = false;

  /// **LA PROFONDITA' DI OGNI SCHEDA**, come nell'oroscopo di chi usa l'app.
  /// Il fondatore, 30 settembre 2026: *"Ogni scheda deve avere sempre il
  /// pulsante profondità e la scelta "approfondita" è esclusiva dei
  /// premium."* Si parte dalla Breve.
  final Map<HoroscopeDomain, AnswerDepth> _profondita = {
    for (final d in HoroscopeDomain.values) d: AnswerDepth.free,
  };

  Map<HoroscopeDomain, bool> get _approfondite => {
        for (final voce in _profondita.entries)
          voce.key: voce.value == AnswerDepth.profonda,
      };
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat();

  @override
  void initState() {
    super.initState();
    unawaited(DoveSonoAdesso.letto().then((l) {
      if (!mounted || l == null) return;
      setState(() =>
          _luogo = LuogoDelGiorno(lat: l.lat, lon: l.lon, citta: l.citta));
    }));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  NascitaDeiSegni get _nascita => NascitaDeiSegni(
        locale: widget.amico.momento,
        oraNota: widget.amico.oraNota,
        fuso: widget.amico.fuso,
      );

  List<HoroscopeCard>? _schede(SegnoDellaTradizione segno) {
    final a = widget.amico;
    switch (_tradizione) {
      case AstroTradition.cinese:
        if (segno.animale == null) return null;
        return LaLetturaCinese.schede(
            oggi: _adesso,
            nascita: a.nascita,
            animale: segno.animale!,
            forma: CourtesyForm.unknown,
            approfondite: _approfondite);
      case AstroTradition.vedica:
        return LaLetturaVedica.schede(
            adesso: _adesso,
            nascita: _nascita,
            luogo: _luogo,
            forma: CourtesyForm.unknown,
            approfondite: _approfondite);
      default:
        final sole = Zodiac.fromDate(a.nascita);
        // **AL NEUTRO, per l'amico**: le marche del genere del pool si
        // risolvono con la forma di chi usa l'app, e il genere dell'amico
        // non si sa. Si torna alla forma di prima subito dopo.
        final prima = LaMarcaDelGenere.formaCorrente;
        LaMarcaDelGenere.formaCorrente = CourtesyForm.unknown;
        try {
          return Horoscope.forSign(
              sign: sole,
              dayOfYear: Horoscope.dayOfYear(_adesso),
              year: _adesso.year,
              // Senza la carta dell'amico l'Approfondita aggiunge dove sono
              // oggi la Luna e il pianeta del campo, nelle case del suo
              // segno (ordine ES voce 01).
              profonde: _approfondite);
        } finally {
          LaMarcaDelGenere.formaCorrente = prima;
        }
    }
  }

  Future<void> _condividi(SegnoDellaTradizione segno) async {
    setState(() => _renderCard = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final andata = await shareOroscopoCard(
        boundaryKey: _cardKey,
        text: 'Il tuo oroscopo di oggi, ${widget.amico.nome}: ${segno.nome}. '
            'Esoteric Circle.',
      );
      // Il premio della condivisione avvenuta, dichiarato sul pulsante.
      if (andata && mounted) {
        await PremioDellaCondivisione.premia(context,
            cosa: 'Hai mandato un oroscopo a ${widget.amico.nome}');
      }
    } finally {
      if (mounted) setState(() => _renderCard = false);
    }
  }

  /// Il tocco sul nome dell'amico nella riga "Oroscopo per": si riapre la
  /// scelta, e la lettura del nuovo amico prende il posto di questa.
  Future<void> _cambiaAmico() async {
    final navigatore = Navigator.of(context);
    final scelto = await navigatore.push(AmiciScreen.route(perScegliere: true));
    if (scelto == null || !mounted) return;
    unawaited(navigatore.pushReplacement(
        LOroscopoDellAmicoScreen.route(scelto, nomeTuo: widget.nomeTuo)));
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    // Il segno detto dell'amico, non di chi guarda: "Il segno di Lucia è
    // Capricorno" (visto sul Realme il 30 settembre 2026, diceva "Il tuo").
    final segno = ISegniDelleTradizioni.per(_tradizione, _nascita).dettoDi(
        OroscopoShareCard.soloIlNome(widget.amico.nome) ?? widget.amico.nome);
    final schede = _schede(segno);
    return Scaffold(
      backgroundColor: palette.deepest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        title: Text('L\'oroscopo di ${widget.amico.nome}',
            style: TypographyTokens.titoloDiSchermata()
                .copyWith(color: palette.goldSoft)),
      ),
      body: Stack(
        children: [
          ListView(
            key: const Key('amico_oroscopo_lista'),
            padding: const EdgeInsets.all(SpacingTokens.lg),
            children: [
              if (widget.nomeTuo != null) ...[
                OroscopoPer(
                  nomeTuo: widget.nomeTuo!,
                  nomeAmico: OroscopoShareCard.soloIlNome(widget.amico.nome) ??
                      widget.amico.nome,
                  palette: palette,
                  onTe: () => Navigator.of(context).pop(),
                  onAmico: _cambiaAmico,
                ),
                const SizedBox(height: SpacingTokens.md),
              ],
              // **LE TRE TRADIZIONI SU UNA RIGA, COI COLORI DEL CERCHIO.** Visto
              // nelle anteprime il 30 settembre 2026: a 360 punti le tre
              // voci non stavano su una riga e "Vedica" scendeva da sola
              // sulla seconda; la scelta si vedeva in grigio, col segno di
              // spunta di fabbrica. Padre: ordine ES voce 12. Senza la
              // spunta e in riga, e se il carattere ingrandito non le fa
              // stare la riga intera si rimpicciolisce insieme, come il
              // selettore dei periodi.
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  key: const Key('amico_tradizioni'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final t in const [
                      AstroTradition.occidentale,
                      AstroTradition.cinese,
                      AstroTradition.vedica,
                    ])
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: SpacingTokens.xs / 2),
                        child: ChoiceChip(
                          key: Key('amico_tradizione_${t.name}'),
                          showCheckmark: false,
                          shape: const StadiumBorder(),
                          side: BorderSide(
                              color: palette.gold.withValues(
                                  alpha: _tradizione == t ? 0.7 : 0.25)),
                          backgroundColor:
                              palette.surfaceElevated.withValues(alpha: 0.45),
                          selectedColor: palette.primary,
                          label: Text(t.label,
                              maxLines: 1,
                              softWrap: false,
                              style: TypographyTokens.etichetta().copyWith(
                                  color: _tradizione == t
                                      ? palette.goldSoft
                                      : ColorTokens.textSecondary)),
                          selected: _tradizione == t,
                          onSelected: (_) => setState(() => _tradizione = t),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              LaTestaDellaTradizione(
                  tradizione: _tradizione, segno: segno, palette: palette),
              const SizedBox(height: SpacingTokens.md),
              if (_tradizione == AstroTradition.occidentale)
                Text(
                    'Letto sul segno solare di ${widget.amico.nome}: con la '
                    'sua carta natale la lettura sarebbe più sua.',
                    key: const Key('amico_nota_occidentale'),
                    textAlign: TextAlign.center,
                    style: TypographyTokens.didascalia()
                        .copyWith(color: ColorTokens.textSecondary)),
              if (schede == null)
                Text(
                    'Per questa tradizione servono dati che non ci sono: '
                    'l\'ora di nascita di ${widget.amico.nome}.',
                    key: const Key('amico_senza_lettura'),
                    textAlign: TextAlign.center,
                    style: TypographyTokens.corpo()
                        .copyWith(color: ColorTokens.textSecondary)),
              if (schede != null)
                for (final s in schede) ...[
                  const SizedBox(height: SpacingTokens.md),
                  _Scheda(
                    scheda: s,
                    palette: palette,
                    pulse: _pulse,
                    profondita: _profondita[s.domain]!,
                    premiumUnlocked: PlanCatalog.haProfondita(
                        context.watch<EntitlementService>().tier),
                    onSelect: (scelta) =>
                        setState(() => _profondita[s.domain] = scelta),
                    onLocked: (scelta) => showUpgradeInvite(
                      context,
                      title: 'La profondità ${scelta.label} è del Cerchio '
                          'Premium',
                      message: 'Col piano superiore scegli quanto '
                          'approfondire ogni scheda, ${s.domain.label} '
                          'compresa.',
                    ),
                  ),
                ],
              const SizedBox(height: SpacingTokens.lg),
              if (schede != null)
                FilledButton.icon(
                  key: const Key('amico_condividi'),
                  onPressed: () => _condividi(segno),
                  icon: const Icon(Icons.ios_share_rounded),
                  label: Text(PremioDellaCondivisione.etichetta(context,
                      base: 'Manda a ${widget.amico.nome}')),
                ),
            ],
          ),
          if (_renderCard && schede != null)
            Positioned(
              left: -3000,
              top: 0,
              child: RepaintBoundary(
                key: _cardKey,
                child: OroscopoShareCard(
                  sign: Zodiac.fromDate(widget.amico.nascita),
                  cards: schede,
                  palette: palette,
                  nome: OroscopoShareCard.soloIlNome(widget.amico.nome),
                  nomeDelSegno: _tradizione == AstroTradition.occidentale
                      ? null
                      : segno.nome,
                  figuraDelSegno: _tradizione == AstroTradition.occidentale
                      ? null
                      : LaTestaDellaTradizione.figura(_tradizione, segno),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Scheda extends StatelessWidget {
  const _Scheda({
    required this.scheda,
    required this.palette,
    required this.pulse,
    required this.profondita,
    required this.premiumUnlocked,
    required this.onSelect,
    required this.onLocked,
  });

  final HoroscopeCard scheda;
  final MaestroPalette palette;
  final Animation<double> pulse;
  final AnswerDepth profondita;
  final bool premiumUnlocked;
  final ValueChanged<AnswerDepth> onSelect;
  final ValueChanged<AnswerDepth> onLocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('amico_scheda_${scheda.domain.name}'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        color: palette.surfaceElevated.withValues(alpha: 0.9),
        border: Border.all(color: palette.gold.withValues(alpha: 0.32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // In alto a sinistra il titolo e il campo, in alto a destra la
          // profondita', come sulle schede di chi usa l'app.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitoloDellaSchedaDelGiorno(
                        testo: scheda.title,
                        stile: TypographyTokens.titoloScheda()
                            .copyWith(color: palette.goldSoft, height: 1.1)),
                    Text(scheda.domain.label.toUpperCase(),
                        style: TypographyTokens.etichetta().copyWith(
                            color: ColorTokens.textSecondary,
                            letterSpacing: 1.4)),
                  ],
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              AnswerDepthSelector(
                key: Key('amico_depth_${scheda.domain.name}'),
                current: profondita,
                palette: palette,
                premiumUnlocked: premiumUnlocked,
                onSelect: onSelect,
                onLockedTap: onLocked,
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          DomainLevel(
              domain: scheda.domain,
              value: scheda.indicator,
              palette: palette,
              pulse: pulse),
          const SizedBox(height: SpacingTokens.sm),
          // Il testo narrato passa dalla porta dei paragrafi, come ogni
          // responso: senza, torna un blocco unico.
          ParagrafiDiLettura(
              testo: scheda.text,
              stile: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textPrimary, height: 1.5)),
          // Da dove viene, dopo la lettura come sulle schede di chi usa
          // l'app: il simbolo non apre mai (Linee Guida, sezione 2).
          if (scheda.rigaDelLivello != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            Text('Da dove viene',
                style: TypographyTokens.etichetta().copyWith(
                    color: ColorTokens.textSecondary, letterSpacing: 1.2)),
            Text(scheda.rigaDelLivello!,
                key: Key('amico_da_dove_${scheda.domain.name}'),
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textSecondary, height: 1.35)),
          ],
        ],
      ),
    );
  }
}

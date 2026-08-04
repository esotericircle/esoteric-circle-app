import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/entitlement/entitlement_service.dart';
import '../../core/entitlement/plan_catalog.dart';

import '../../core/astro/zodiac.dart';
import '../../core/config/app_flags.dart';
import '../../core/horoscope/astro_tradition.dart';
import '../../core/horoscope/cielo_di_oggi.dart';
import '../../core/horoscope/corrente_del_cielo.dart';
import '../../core/horoscope/horoscope.dart';
import '../../core/identity/natal_identity.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/entrance_cascade.dart';
import '../../design_system/components/zodiac_glyph.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'answer_depth.dart';
import 'horoscope_visuals.dart';
import 'oroscopo_colors.dart';
import 'oroscopo_share_card.dart';
import 'tradition_glyph.dart';
import '../maestri/rotta_arte.dart';

const List<String> _mesiItaliani = [
  'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno', //
  'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre'
];

/// Data locale per esteso, in italiano.
String italianLongDate(DateTime d) =>
    '${d.day} ${_mesiItaliani[d.month - 1]} ${d.year}';

/// I tre periodi dell'Oroscopo. Per la Demo solo il Giorno e' attivo: Settimana
/// e Mese restano visibili ma bloccati dietro l'abbonamento, mai un vicolo
/// cieco.
enum HoroscopePeriod {
  giorno('Giorno', unlocked: true),
  settimana('Settimana', unlocked: false),
  mese('Mese', unlocked: false);

  const HoroscopePeriod(this.label, {required this.unlocked});

  final String label;
  final bool unlocked;
}

/// Oroscopo Personalizzato, la headline di Medora.
///
/// Quattro schede per il segno di nascita della persona (Generale, Amore,
/// Carriera, Fortuna), ognuna con la sua forma a tema e il livello da 1 a 5,
/// deterministiche dal giorno: stesso segno stesso giorno, stesso responso. Il
/// giorno si legge una sola volta qui e si passa come intero ai calcoli, cosi'
/// l'hash resta puro. Contenuto su dispositivo, senza backend.
class OroscopoScreen extends StatefulWidget {
  const OroscopoScreen({super.key, required this.userSign, this.now});

  final Zodiac userSign;
  final DateTime? now;

  static Route<void> route({required Zodiac userSign, DateTime? now}) {
    return MaterialPageRoute<void>(
      builder: (_) =>
          SogliaArte(id: 'horoscope', maestro: Maestro.medora, child: OroscopoScreen(userSign: userSign, now: now)),
    );
  }

  @override
  State<OroscopoScreen> createState() => _OroscopoScreenState();
}

class _OroscopoScreenState extends State<OroscopoScreen>
    with SingleTickerProviderStateMixin {
  // Il giorno per l'oroscopo, letto una sola volta a livello di schermata.
  late final DateTime _date = widget.now ?? DateTime.now();
  late final int _dayOfYear = Horoscope.dayOfYear(_date);
  late final int _year = _date.year;

  HoroscopePeriod _period = HoroscopePeriod.giorno;

  // La tradizione scelta e il micro messaggio del Maestro sull'ultima
  // tradizione ancora chiusa che e' stata toccata.
  AstroTradition _tradition = AstroTradition.predefinita;
  AstroTradition? _traditionMessage;

  // Rivelazione una volta sola: la prima volta il messaggio entra in
  // dissolvenza, dalla seconda in poi compare gia' posato.
  final Set<AstroTradition> _traditionRevealed = <AstroTradition>{};

  // Pulsazione lenta condivisa: respiro dell'emblema e delle forme a tema.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat();

  final GlobalKey _cardKey = GlobalKey();
  bool _sharing = false;
  bool _renderCard = false;

  /// Profondita' scelta per ogni scheda. Nel gratuito resta la profondita'
  /// libera, Breve: la Profonda e' del Cerchio Premium.
  ///
  /// **E LA SCELTA NON ARRIVAVA QUI.** Il selettore riceveva `current` e
  /// `onLockedTap`, ma non `onSelect`: chi aveva pagato apriva il menu, sceglieva
  /// Profonda, e non succedeva niente, perche' la scelta non aveva un posto
  /// dove andare. Una funzione venduta e mai consegnata due volte di fila,
  /// prima col lucchetto sbagliato e poi col filo staccato.
  final Map<HoroscopeDomain, AnswerDepth> _depth = {
    for (final d in HoroscopeDomain.values) d: AnswerDepth.free,
  };

  void _scegliProfondita(HoroscopeDomain dominio, AnswerDepth scelta) {
    if (_depth[dominio] == scelta) return;
    setState(() => _depth[dominio] = scelta);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // L'Oroscopo e' di Medora: blu e oro suoi, sempre, anche se il Maestro
    // attivo altrove fosse un altro. Lo sfondo resta il cosmo ambientale.
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final profile = context.watch<ProfileController>();
    final vocative =
        Horoscope.vocativeFor(profile.vocative, profile.courtesy);
    final opening = Horoscope.openingFor(
        sign: widget.userSign,
        dayOfYear: _dayOfYear,
        year: _year,
        vocative: vocative);
    // IL CIELO VERO DI QUESTA PERSONA, quando c'e' una carta da interrogare.
    //
    // **Qui muore l'hash.** La corrente del giorno usciva da un pool di frasi
    // generiche scelte da una hash su segno, giorno e anno: cambiava tutti i
    // giorni senza che in cielo fosse cambiato niente, ed era identica per due
    // persone dello stesso segno nate a vent'anni di distanza. Adesso, con la
    // carta natale, la scrive il cielo. Senza carta si torna alla hash, e la
    // nota qui sotto lo dichiara invece di lasciarlo credere.
    final cielo = CieloDiOggi.perIlGiorno(
        adesso: _date, carta: context.watch<BirthIdentityController>().chart);
    final notaDelCielo = CorrenteDelCielo.notaDelLivello(cielo);
    final cards = Horoscope.forSign(
        sign: widget.userSign,
        dayOfYear: _dayOfYear,
        year: _year,
        opening: opening,
        cielo: cielo,
        profonde: {
          for (final voce in _depth.entries)
            voce.key: voce.value == AnswerDepth.profonda,
        });

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: CosmosBackground(
        seed: 5,
        showZodiac: false,
        child: SafeArea(
          child: Stack(
            children: [
              EntranceCascade(
                listKey: const Key('oroscopo_list'),
                // Nessun vuoto sopra l'eroe: il segno parte in alto.
                padding: const EdgeInsets.fromLTRB(
                    SpacingTokens.lg, 0, SpacingTokens.lg, SpacingTokens.lg),
                hero: _Hero(sign: widget.userSign, palette: palette, pulse: _pulse),
                items: [
                  _Heading(sign: widget.userSign, date: _date, palette: palette),
                  const SizedBox(height: SpacingTokens.md),
                  _PeriodTabs(
                    current: _period,
                    palette: palette,
                    onSelect: _selectPeriod,
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  // Accanto al periodo, la tradizione: lo stesso cielo letto con
                  // occhi diversi. Aperta l'Occidentale, le altre col lucchetto.
                  _TraditionTabs(
                    current: _tradition,
                    palette: palette,
                    onSelect: _selectTradition,
                  ),
                  _TraditionInvite(
                    tradition: _traditionMessage,
                    maestro: Maestro.medora,
                    palette: palette,
                    // Rivelazione una volta sola per tradizione.
                    animate: _traditionMessage != null &&
                        !_traditionRevealed.contains(_traditionMessage),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  for (final card in cards) ...[
                    _HoroscopeCardView(
                      card: card,
                      palette: palette,
                      pulse: _pulse,
                      depth: _depth[card.domain]!,
                      onDepthSelected: (depth) =>
                          _scegliProfondita(card.domain, depth),
                      onDepthLocked: (depth) => _showDepthLocked(card.domain, depth),
                      premiumUnlocked: PlanCatalog.haProfondita(
                          context.watch<EntitlementService>().tier),
                    ),
                    const SizedBox(height: SpacingTokens.md),
                  ],
                  // LA NOTA CHE DICHIARA IL RIPIEGO, quando il cielo non c'e'.
                  //
                  // Una riga generica scritta con lo stesso carattere di una
                  // vera si legge come vera: qui si dice a parole che senza
                  // ora e luogo di nascita quella lettura parla al segno, non
                  // al cielo di questa persona, e si dice come rimediare.
                  if (notaDelCielo != null) ...[
                    _NotaDelCielo(
                        testo: notaDelCielo,
                        palette: palette,
                        completa: cielo.ceCieloVero),
                    const SizedBox(height: SpacingTokens.md),
                  ],
                  _ShareBlock(
                    palette: palette,
                    sharing: _sharing,
                    onShare: _onShare,
                  ),
            // IL DISCLAIMER E' USCITO DA QUI, ed era uno di SETTE.
            //
            // Le linee guida dicevano da sempre "una volta sola", e per
            // sette volte ognuno ha pensato che il proprio fosse quella
            // volta. Un disclaimer ripetuto smette di essere letto e
            // diventa un modo di scaricare la responsabilita' invece di
            // dirla. Adesso sta in un posto solo, nell'area privacy.
                ],
              ),
              if (_renderCard)
                Positioned(
                  left: -3000,
                  top: 0,
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: OroscopoShareCard(
                        sign: widget.userSign, cards: cards, palette: palette),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDepthLocked(HoroscopeDomain domain, AnswerDepth depth) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'La profondità ${depth.label} è del Cerchio Premium. Abbonati per approfondire ${domain.label}.'),
      ),
    );
  }

  void _selectPeriod(HoroscopePeriod period) {
    if (period.unlocked) {
      setState(() => _period = period);
      return;
    }
    // Mai un vicolo cieco: il periodo bloccato invita all'abbonamento.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'L\'oroscopo della ${period.label.toLowerCase()} arriva col Cerchio Premium.'),
      ),
    );
  }

  /// La tradizione: se e' aperta si sceglie, se e' chiusa risponde il Maestro.
  ///
  /// Al posto del solito lucchetto muto compare un micro messaggio di Medora in
  /// prima persona, che racconta cosa sara' quella tradizione. La prima volta
  /// entra in dissolvenza, poi resta posato: e' la rivelazione una volta sola.
  void _selectTradition(AstroTradition tradition) {
    if (tradition.unlocked) {
      setState(() {
        _tradition = tradition;
        _traditionMessage = null;
      });
      return;
    }
    setState(() => _traditionMessage = tradition);
    // Segna la rivelazione dopo il frame in cui l'animazione e' partita.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _traditionRevealed.add(tradition);
    });
  }

  Future<void> _onShare() async {
    setState(() {
      _sharing = true;
      _renderCard = true;
    });
    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await shareOroscopoCard(
        boundaryKey: _cardKey,
        text:
            'Il mio oroscopo di oggi, ${widget.userSign.italianName}. Esoteric Circle.',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Non riesco a preparare la card ora.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _sharing = false;
          _renderCard = false;
        });
      }
    }
  }
}

/// L'eroe: l'emblema 3D del segno della persona, grande, dentro un alone che
/// respira. Nessun altro segno, l'oroscopo e' personalizzato.
class _Hero extends StatelessWidget {
  const _Hero({required this.sign, required this.palette, required this.pulse});

  final Zodiac sign;
  final MaestroPalette palette;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 268,
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, _) {
          final breathe = 0.5 + 0.5 * (1 - (pulse.value - 0.5).abs() * 2);
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 250 + 28 * breathe,
                height: 250 + 28 * breathe,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    palette.gold.withValues(alpha: 0.12 + 0.16 * breathe),
                    palette.glow.withValues(alpha: 0.08 * breathe),
                    Colors.transparent,
                  ], stops: const [
                    0.0,
                    0.55,
                    1.0
                  ]),
                ),
              ),
              ZodiacEmblem(
                  key: const Key('oroscopo_emblem'),
                  sign: sign,
                  size: 264,
                  art: ZodiacEmblemArt.emblem),
            ],
          );
        },
      ),
    );
  }
}

/// Intestazione: nome del segno, titolo e data locale.
class _Heading extends StatelessWidget {
  const _Heading(
      {required this.sign, required this.date, required this.palette});

  final Zodiac sign;
  final DateTime date;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(sign.italianName,
            key: const Key('oroscopo_sign_name'),
            style: TypographyTokens.display(size: 28)
                .copyWith(color: palette.goldSoft)),
        const SizedBox(height: 2),
        Text('Oroscopo Personalizzato del giorno',
            key: const Key('oroscopo_heading'),
            textAlign: TextAlign.center,
            style: TypographyTokens.label(size: 11).copyWith(
                color: ColorTokens.textSecondary, letterSpacing: 1.2)),
        Text(italianLongDate(date),
            key: const Key('oroscopo_date'),
            textAlign: TextAlign.center,
            style: TypographyTokens.body(size: 13)
                .copyWith(color: ColorTokens.textSecondary)),
      ],
    );
  }
}

/// Il selettore del periodo: Giorno attivo, Settimana e Mese visibili ma
/// bloccati col lucchetto e l'invito all'abbonamento.
class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs(
      {required this.current, required this.palette, required this.onSelect});

  final HoroscopePeriod current;
  final MaestroPalette palette;
  final ValueChanged<HoroscopePeriod> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        color: palette.surfaceElevated.withValues(alpha: 0.45),
        border: Border.all(color: palette.gold.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          for (final period in HoroscopePeriod.values)
            Expanded(
              child: _PeriodTab(
                period: period,
                selected: period == current,
                palette: palette,
                onTap: () => onSelect(period),
              ),
            ),
        ],
      ),
    );
  }
}

/// Il selettore della tradizione: Occidentale aperta, le altre col lucchetto.
///
/// Le astrologie non occidentali non hanno una card nel dominio ne' una
/// schermata propria: vivono qui, come modo diverso di leggere lo stesso cielo.
/// Ogni voce porta il suo glifo disegnato, cosi' si riconosce prima di leggerla.
class _TraditionTabs extends StatelessWidget {
  const _TraditionTabs(
      {required this.current, required this.palette, required this.onSelect});

  final AstroTradition current;
  final MaestroPalette palette;
  final ValueChanged<AstroTradition> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('oroscopo_tradition_tabs'),
      // Alta quanto serve al glifo, al nome e al badge "In arrivo", che sulla
      // voce bloccata sta su una terza riga.
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AstroTradition.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: SpacingTokens.xs),
        itemBuilder: (context, i) {
          final t = AstroTradition.values[i];
          return _TraditionChip(
            tradition: t,
            selected: t == current,
            palette: palette,
            onTap: () => onSelect(t),
          );
        },
      ),
    );
  }
}

class _TraditionChip extends StatelessWidget {
  const _TraditionChip({
    required this.tradition,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final AstroTradition tradition;
  final bool selected;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locked = !tradition.unlocked;
    // Alla persona si dice soltanto "In arrivo": la fase e' un dato di piano e
    // resta nella sola vista Demo per gli investitori.
    final fase =
        AppFlags.isDemo && tradition.phase != null ? ', ${tradition.phase}' : '';
    return GestureDetector(
      key: Key('oroscopo_tradition_${tradition.name}'),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
          // L'accento del Maestro solo su quella scelta e viva: le altre
          // restano su una superficie sobria, comunque ben leggibile.
          gradient: selected
              ? LinearGradient(colors: [
                  palette.primary.withValues(alpha: 0.85),
                  palette.surfaceElevated.withValues(alpha: 0.85),
                ])
              : null,
          color: selected
              ? null
              : palette.surfaceElevated.withValues(alpha: 0.35),
          border: Border.all(
            color: palette.gold.withValues(alpha: selected ? 0.6 : 0.25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TraditionGlyph(
              tradition: tradition,
              color: palette.goldSoft.withValues(alpha: locked ? 0.7 : 1.0),
              size: 22,
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tradition.label,
                  style: TypographyTokens.label(size: 11).copyWith(
                    color: selected
                        ? palette.goldSoft
                        : ColorTokens.textSecondary
                            .withValues(alpha: locked ? 0.75 : 1.0),
                    letterSpacing: 0.5,
                  ),
                ),
                if (locked) ...[
                  const SizedBox(width: 3),
                  Icon(Icons.lock_rounded,
                      key: Key('oroscopo_tradition_lock_${tradition.name}'),
                      size: 10,
                      color: palette.goldSoft.withValues(alpha: 0.65)),
                ],
              ],
            ),
            if (locked)
              Text(
                'In arrivo$fase',
                key: Key('oroscopo_tradition_soon_${tradition.name}'),
                style: TypographyTokens.label(size: 11).copyWith(
                  color: palette.goldSoft.withValues(alpha: 0.6),
                  letterSpacing: 0.3,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Il micro messaggio del Maestro su una tradizione ancora chiusa.
///
/// Al posto del lucchetto muto risponde Medora in prima persona. Con Riduci
/// Movimento compare gia' posato, e dalla seconda volta in poi anche.
class _TraditionInvite extends StatelessWidget {
  const _TraditionInvite({
    required this.tradition,
    required this.maestro,
    required this.palette,
    required this.animate,
  });

  final AstroTradition? tradition;
  final Maestro maestro;
  final MaestroPalette palette;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final t = tradition;
    if (t == null) return const SizedBox.shrink();
    final immobile = MediaQuery.of(context).disableAnimations || !animate;
    final riga = Container(
      key: Key('tradition_invite_${t.name}'),
      margin: const EdgeInsets.only(top: SpacingTokens.sm),
      padding: const EdgeInsets.all(SpacingTokens.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        color: palette.surfaceElevated.withValues(alpha: 0.5),
        border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TraditionGlyph(tradition: t, color: palette.goldSoft, size: 20),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(
              t.invito,
              style: TypographyTokens.body(size: 13).copyWith(
                color: ColorTokens.textPrimary,
                height: 1.35,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
    if (immobile) return riga;
    return TweenAnimationBuilder<double>(
      key: ValueKey('tradition_invite_anim_${t.name}'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * 8), child: child),
      ),
      child: riga,
    );
  }
}

class _PeriodTab extends StatelessWidget {
  const _PeriodTab({
    required this.period,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final HoroscopePeriod period;
  final bool selected;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locked = !period.unlocked;
    final tab = GestureDetector(
      key: Key('oroscopo_period_${period.name}'),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          gradient: selected
              ? LinearGradient(colors: [
                  palette.primary.withValues(alpha: 0.85),
                  palette.surfaceElevated.withValues(alpha: 0.85),
                ])
              : null,
          border: selected
              ? Border.all(color: palette.gold.withValues(alpha: 0.6))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(period.label,
                style: TypographyTokens.label(size: 12).copyWith(
                  color: selected
                      ? palette.goldSoft
                      : ColorTokens.textSecondary
                          .withValues(alpha: locked ? 0.6 : 1.0),
                  letterSpacing: 0.6,
                )),
            if (locked) ...[
              const SizedBox(width: 4),
              Icon(Icons.lock_rounded,
                  key: Key('oroscopo_lock_${period.name}'),
                  size: 12,
                  color: palette.goldSoft.withValues(alpha: 0.65)),
            ],
          ],
        ),
      ),
    );
    if (!locked) return tab;
    return Tooltip(
      message:
          'L\'oroscopo della ${period.label.toLowerCase()} è del Cerchio Premium. Abbonati per aprirlo.',
      child: tab,
    );
  }
}

class _HoroscopeCardView extends StatelessWidget {
  const _HoroscopeCardView({
    required this.card,
    required this.palette,
    required this.pulse,
    required this.depth,
    required this.onDepthSelected,
    required this.onDepthLocked,
    required this.premiumUnlocked,
  });

  final HoroscopeCard card;
  final MaestroPalette palette;
  final Animation<double> pulse;
  final AnswerDepth depth;

  /// La scelta della profondita', che prima non aveva dove andare.
  final ValueChanged<AnswerDepth> onDepthSelected;
  final ValueChanged<AnswerDepth> onDepthLocked;

  /// Se la persona ha diritto alla profondita' Profonda. Arriva da chi
  /// conosce il piano, perche' una card non deve leggere l'abbonamento.
  final bool premiumUnlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('oroscopo_card_${card.domain.name}'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        // Blu e oro di Medora, come la card di condivisione.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.surfaceElevated.withValues(alpha: 0.95),
            Color.lerp(palette.surface, palette.deepest, 0.35)!
                .withValues(alpha: 0.92),
          ],
        ),
        border: Border.all(color: palette.gold.withValues(alpha: 0.32)),
        boxShadow: [
          BoxShadow(
            color: palette.glow.withValues(alpha: 0.16),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // In alto a sinistra titolo e categoria, in alto a destra la
          // profondita' della risposta.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(card.title,
                        style: TypographyTokens.display(size: 18)
                            .copyWith(color: palette.goldSoft, height: 1.1)),
                    Text(card.domain.label.toUpperCase(),
                        style: TypographyTokens.label(size: 11).copyWith(
                            color: ColorTokens.textSecondary,
                            letterSpacing: 1.4)),
                  ],
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              // Menu a tendina compatto: ora le etichette sono corte, quindi
              // resta leggibile senza rubare spazio al titolo.
              AnswerDepthSelector(
                key: Key('oroscopo_depth_${card.domain.name}'),
                current: depth,
                palette: palette,
                // Chi ha pagato deve poter aprire la Profonda. Questo
                // parametro non veniva passato da nessuno in tutta l'app,
                // quindi restava falso e il lucchetto valeva anche per chi
                // l'aveva comprata: una funzione venduta e mai consegnata.
                premiumUnlocked: premiumUnlocked,
                onSelect: onDepthSelected,
                onLockedTap: onDepthLocked,
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          // Poi l'infografica a cinque icone col numero, sotto il titolo.
          DomainLevel(
            domain: card.domain,
            value: card.indicator,
            palette: palette,
            pulse: pulse,
          ),
          const SizedBox(height: SpacingTokens.md),
          // L'apertura personalizzata col nome, prima del testo della Generale.
          if (card.opening != null) ...[
            Text(card.opening!,
                key: const Key('oroscopo_opening'),
                style: TypographyTokens.body(size: 17).copyWith(
                    color: palette.goldSoft,
                    height: 1.5,
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: SpacingTokens.sm),
          ],
          Text(card.text,
              style: TypographyTokens.body(size: 17)
                  .copyWith(color: ColorTokens.textPrimary, height: 1.5)),
          if (card.domain == HoroscopeDomain.fortuna) ...[
            const SizedBox(height: SpacingTokens.md),
            _FortunaFooter(card: card, palette: palette),
          ],
        ],
      ),
    );
  }
}

/// La riga che dichiara da dove viene il testo, quando non viene dal cielo.
class _NotaDelCielo extends StatelessWidget {
  const _NotaDelCielo(
      {required this.testo, required this.palette, required this.completa});

  final String testo;
  final MaestroPalette palette;

  /// Vero quando qualche transito vero c'e' comunque: cambia solo l'icona,
  /// perche' "manca l'ora" e "manca tutto" non sono la stessa mancanza.
  final bool completa;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('oroscopo_nota_del_cielo'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        color: palette.deepest.withValues(alpha: 0.45),
        border: Border.all(color: palette.gold.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(completa ? Icons.schedule_rounded : Icons.info_outline_rounded,
              size: 16, color: palette.goldSoft),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(testo,
                style: TypographyTokens.body(size: 13).copyWith(
                    color: ColorTokens.textSecondary, height: 1.45)),
          ),
        ],
      ),
    );
  }
}

class _ShareBlock extends StatelessWidget {
  const _ShareBlock(
      {required this.palette, required this.sharing, required this.onShare});

  final MaestroPalette palette;
  final bool sharing;
  final Future<void> Function() onShare;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Porta il tuo cielo di oggi con te',
            textAlign: TextAlign.center,
            style: TypographyTokens.body(size: 14)
                .copyWith(color: ColorTokens.textSecondary)),
        const SizedBox(height: SpacingTokens.sm),
        FilledButton.icon(
          key: const Key('oroscopo_share'),
          onPressed: sharing ? null : onShare,
          style: FilledButton.styleFrom(
            backgroundColor: palette.gold,
            foregroundColor: palette.deepest,
            padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.xl, vertical: SpacingTokens.sm),
          ),
          icon: sharing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.ios_share_rounded, size: 18),
          label: Text(sharing ? 'Preparo la card' : 'Condividi',
              style:
                  TypographyTokens.label(size: 13).copyWith(letterSpacing: 0.6)),
        ),
      ],
    );
  }
}

/// Il piede della scheda Fortuna: numero fortunato e colore del giorno.
class _FortunaFooter extends StatelessWidget {
  const _FortunaFooter({required this.card, required this.palette});

  final HoroscopeCard card;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Pill(
          label: 'Numero',
          palette: palette,
          child: Text('${card.luckyNumber}',
              style: TypographyTokens.display(size: 20)
                  .copyWith(color: palette.goldSoft)),
        ),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: _Pill(
            label: 'Colore del giorno',
            palette: palette,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: oroscopoColor(card.dayColor) ?? palette.goldSoft,
                    border:
                        Border.all(color: palette.gold.withValues(alpha: 0.6)),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(card.dayColor ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TypographyTokens.body(size: 13)
                          .copyWith(color: ColorTokens.textPrimary)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(
      {required this.label, required this.child, required this.palette});

  final String label;
  final Widget child;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm, vertical: SpacingTokens.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
        color: palette.primary.withValues(alpha: 0.4),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label.toUpperCase(),
              style: TypographyTokens.label(size: 11).copyWith(
                  color: ColorTokens.textSecondary, letterSpacing: 0.8)),
          const SizedBox(height: 2),
          child,
        ],
      ),
    );
  }
}

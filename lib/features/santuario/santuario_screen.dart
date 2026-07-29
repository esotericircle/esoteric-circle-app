import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/moon_phase.dart';
import '../../core/astro/zodiac.dart';
import '../../core/astro/zodiac_controller.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_controller.dart';
import '../../core/motion/parallax_controller.dart';
import '../../core/rituals/daily_elements.dart';
import '../../core/santuario/function_shelf.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/app_services.dart';
import '../account/account_screen.dart';
import '../maestri/art_navigation.dart';
import '../maestri/domain_screen.dart';
import 'daily_strip.dart';
import 'sky_overview_screen.dart';
import 'widgets/maestro_bust.dart';
import 'widgets/moon_widget.dart';

/// La schermata eroe, il Santuario.
///
/// Un unico palco antico e neutro con la Luna reale in alto e, dietro i
/// Maestri, una silhouette architettonica di tempio fatta di linee dorate e
/// stelle. Tre mezzibusti davanti: al centro, piu' grande e vivo, l'ultimo
/// Maestro usato; gli altri due sbucano ai lati, piu' in alto, piu' scuri e
/// arretrati nella parallasse. Un filo d'oro li unisce. Toccare il centro entra
/// nel dominio, toccare un laterale lo porta al centro.
///
/// Costruita ai punti dati da Mauro: nel repo non c'e' una Specifica del
/// Santuario dedicata, solo i quattro briefing. Fondo, tempio e cielo sono un
/// segnaposto architettonico, l'asset dipinto e il motore a effemeridi
/// arrivano dopo.
class SantuarioScreen extends StatefulWidget {
  const SantuarioScreen({super.key, this.clock});

  /// Orologio iniettabile per i test. Di default l'ora locale del dispositivo.
  /// Guida sia la striscia del giorno sia l'eroe centrale, cosi' i due
  /// concordano sempre sullo stesso elemento della fascia oraria attiva.
  final DateTime Function()? clock;

  /// Maestro preferito, segnaposto in attesa dell'assegnazione all'onboarding.
  static const Maestro preferred = Maestro.medora;

  /// Zona franca del titolo in alto, in coordinate normalizzate (0..1): il
  /// cosmo di sfondo non fa nascere stelle qui, cosi' nessuna cade su una
  /// lettera. La legge il cosmo dello shell quando mostra il Santuario.
  static const Rect titleKeepOut = Rect.fromLTRB(0.04, 0.15, 0.96, 0.34);

  /// Il frammento astronomico sulla Luna nella voce di Medora. Il verbo segue
  /// la fase, cosi' non contraddice l'occhiello: alla Luna nuova non si dice
  /// "cala", alla piena non si dice "cresce".
  static String medoraMoonFragment(MoonPhase moon) {
    if (moon.italianName == 'Luna nuova') return 'la Luna riposa nel buio';
    if (moon.italianName == 'Luna piena') return 'la Luna arde al culmine';
    final pct = (moon.illumination * 100).round();
    return 'la Luna ${moon.waxing ? 'cresce' : 'cala'} al $pct%';
  }

  @override
  State<SantuarioScreen> createState() => _SantuarioScreenState();
}

class _SantuarioScreenState extends State<SantuarioScreen>
    with TickerProviderStateMixin {
  late final AnimationController _breath;

  /// L'altezza vera della bolla d'ingresso al dominio, misurata a schermo.
  /// Nulla al primo fotogramma, poi il valore reale: da li' in poi il
  /// carosello sa esattamente dove fermarsi e non si sovrappone mai.
  double? _altezzaIngresso;

  // Ciclo lungo che alimenta la deriva automatica del cosmo e le stelle cadenti
  // quando il giroscopio non c'e', cosi' lo sfondo resta immersivo comunque.
  late final AnimationController _drift;

  // Invito al tocco del cielo: appare dopo qualche secondo di inattivita' e si
  // dissolve alla prima interazione, coerente con la scala dell'aiuto
  // universale. La mano dell'invito pulsa su un ciclo dedicato piu' breve.
  late final AnimationController _tapPulse;
  Timer? _skyHintTimer;
  bool _showSkyHint = false;
  bool _skyHintDismissed = false;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _drift = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..repeat();
    _tapPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _armSkyHint();
  }

  // Arma l'invito al cielo: dopo tre secondi senza tocco, lo mostra.
  void _armSkyHint() {
    _skyHintTimer?.cancel();
    if (_skyHintDismissed) return;
    _skyHintTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_skyHintDismissed) setState(() => _showSkyHint = true);
    });
  }

  void _dismissSkyHint() {
    _skyHintTimer?.cancel();
    if (_skyHintDismissed && !_showSkyHint) return;
    _skyHintDismissed = true;
    if (mounted) setState(() => _showSkyHint = false);
  }

  void _openSky(BuildContext context) {
    _dismissSkyHint();
    Navigator.of(context).push(SkyOverviewScreen.route());
  }

  @override
  void dispose() {
    _skyHintTimer?.cancel();
    _tapPulse.dispose();
    _drift.dispose();
    _breath.dispose();
    super.dispose();
  }

  void _enterDomain(BuildContext context, Maestro maestro) {
    // Ingresso rapido nel dominio. L'incantesimo a tutto schermo resta per la
    // prima volta, non a ogni ingresso: segnaposto per un passo successivo.
    context.read<MaestroController>().selectMaestro(maestro);
    final services = context.read<AppServices>();
    Navigator.of(context).push(
      DomainScreen.route(maestro: maestro, services: services),
    );
  }

  void _selectSide(BuildContext context, Maestro maestro) {
    context.read<MaestroController>().selectMaestro(maestro);
  }

  // Apre una funzione dello scaffale. Le funzioni vive spingono la loro
  // schermata (deep link interno); quelle ancora in arrivo mostrano un anticipo
  // elegante, mai un vicolo cieco.
  void _openShelf(BuildContext context, ShelfFunction fn, Zodiac userSign) {
    final route = _shelfRoute(context, fn, userSign);
    if (route != null) {
      Navigator.of(context).push(route);
      return;
    }
    _showShelfAnticipo(context, fn);
  }

  /// La rotta di una funzione dello scaffale: la stessa mappa unica del dominio
  /// (`artRouteFor`), cosi' la stessa arte si apre sempre alla stessa schermata.
  /// Porta anche nome e data reali del profilo, quando ci sono, cosi' la
  /// Sinastria VIP mostra la persona vera invece del segnaposto.
  Route<void>? _shelfRoute(
      BuildContext context, ShelfFunction fn, Zodiac userSign) {
    final profile = context.read<ProfileController>();
    return artRouteFor(
      fn.id,
      userSign: userSign,
      userBirth:
          profile.identity.isExample ? null : profile.identity.birthMoment,
      userName: profile.hasName ? profile.vocative : null,
    );
  }

  void _showShelfAnticipo(BuildContext context, ShelfFunction fn) {
    final palette = MaestroPalette.forKey(ThemeKey.of(fn.maestro));
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        key: const Key('santuario_shelf_coming_soon'),
        padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
            SpacingTokens.lg, SpacingTokens.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [palette.surfaceElevated, palette.deepest],
          ),
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SpacingTokens.radiusXl)),
          border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(fn.icon, color: palette.goldSoft, size: 26),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: Text(fn.title,
                        style: TypographyTokens.display(size: 19)
                            .copyWith(color: palette.goldSoft)),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                '${fn.teaser} Questa esperienza sta per aprirsi nel cerchio, '
                'con tutta la sua immersione.',
                style: TypographyTokens.body(size: 15)
                    .copyWith(color: ColorTokens.textSecondary, height: 1.4),
              ),
              const SizedBox(height: SpacingTokens.lg),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text('Va bene',
                      style: TypographyTokens.label(size: 13)
                          .copyWith(color: palette.goldSoft)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// La riga personale del Maestro al centro, con lo slot pronto per nome e
  /// segno dell'utente, cosi' sembra parlare proprio a lui. Per ora nome e
  /// segno sono segnaposto. Per Medora la parte astronomica resta vera (luce e
  /// tendenza reali della Luna); Aura e Caligo sono testo segnaposto.
  ///
  /// Non ripete il nome della fase, gia' mostrato nell'occhiello in alto.
  String _personalLine(Maestro maestro, MoonPhase moon, String name, String sign) {
    switch (maestro) {
      case Maestro.medora:
        return '$name, ${SantuarioScreen.medoraMoonFragment(moon)}: '
            'la giusta ora per chi nasce sotto $sign.';
      case Maestro.aura:
        return "$name, l'energia di chi nasce sotto $sign cerca quiete: una mano sul cuore.";
      case Maestro.caligo:
        return '$name, per chi nasce sotto $sign stanotte sale una runa di pazienza.';
    }
  }

  DateTime Function() get _clock => widget.clock ?? DateTime.now;

  @override
  Widget build(BuildContext context) {
    final now = _clock();
    // L'eroe centrale segue il Maestro dell'elemento in evidenza nella
    // striscia: Soffio ad Aura, Oracolo a Medora, Runa a Caligo, e il Rito
    // dell'Alba al Maestro di turno del giorno. La selezione esplicita di un
    // laterale resta un'eccezione che porta quel Maestro al centro; senza
    // selezione l'eroe si aggiorna in modo deterministico al cambio di fascia.
    final elementMaestro =
        DailyElements.maestroFor(DailyElements.current(now), now);
    final chosen = context.watch<MaestroController>().activeMaestro;
    final central = chosen ?? elementMaestro;
    final selected = chosen != null;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final parallax = context.watch<ParallaxController>();
    // Colore di dominio dell'eroe coerente col Maestro al centro, cosi' cielo,
    // testo e pulsante seguono l'elemento attivo, non il tema neutro.
    final palette = MaestroPalette.forKey(ThemeKey.of(central));

    final moon = MoonPhase.forDate(now);

    // Slot personali: nome reale e segno dell'utente. Il nome viene dal profilo
    // (mai il nome del tier); il segno si legge dal controller dello zodiaco.
    final userName = context.watch<ProfileController>().vocative;
    final userZodiac = context.watch<ZodiacController>().sunSign ?? Zodiac.gemini;
    final userSign = userZodiac.italianName;
    final personalLine = _personalLine(central, moon, userName, userSign);

    // Riduci Movimento: niente deriva di parallasse, scena ferma.
    Offset depth(double d) => reduceMotion ? Offset.zero : parallax.layerOffset(d);

    // Alla prima interazione l'invito al cielo si dissolve. L'alto del Santuario
    // riempie il primo schermo, pulito, senza bolle sopra l'immagine; lo
    // scaffale delle funzioni scorre sotto.
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        if (_showSkyHint) _dismissSkyHint();
      },
      child: SafeArea(
        child: Column(
          children: [
            // La striscia del giorno, fissa in cima e sempre visibile: i quattro
            // elementi giornalieri, quello dell'ora attuale in evidenza. Stesso
            // orologio dell'eroe, cosi' striscia e centro concordano.
            DailyStrip(clock: widget.clock),
            Expanded(
              child: LayoutBuilder(
                builder: (context, outer) {
                  final viewportH = outer.maxHeight;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: viewportH,
                          child: _buildHero(
                              context,
                              central,
                              selected,
                              reduceMotion,
                              palette,
                              moon,
                              personalLine,
                              userZodiac,
                              parallax,
                              depth),
                        ),
                        _FunctionShelfView(
                          onOpen: (fn) => _openShelf(context, fn, userZodiac),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(
    BuildContext context,
    Maestro central,
    bool selected,
    bool reduceMotion,
    MaestroPalette palette,
    MoonPhase moon,
    String personalLine,
    Zodiac userZodiac,
    ParallaxController parallax,
    Offset Function(double) depth,
  ) {
    return LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          // Blocco eroe (carte, arti e pulsante) sfrutta lo spazio verticale
          // fino alla barra inferiore, senza sovrapposizioni. Il pulsante e le
          // arti stanno in basso; le carte poggiano appena sopra con un margine
          // pulito, cosi' figura, arti e pulsante respirano.
          final centralH = (h * 0.5).clamp(220.0, 430.0);
          // Zona d'ingresso (pulsante piu' arti) ancorata in basso.
          final entryBottom = h * 0.02;
          // L'altezza della zona d'ingresso si MISURA, non si indovina. Era
          // una costante di 78: il pulsante piu' la riga delle arti la
          // superano appena il testo di sistema cresce o il nome del Maestro
          // e' lungo, e allora la bolla saliva sopra i busti. Finche' la
          // misura non c'e' si parte dalla stima, e al primo fotogramma
          // subentra quella vera.
          final entryZone = _altezzaIngresso ?? 78.0;
          // Le carte partono sopra la zona d'ingresso, con un margine d'aria.
          final carouselBottom = entryBottom + entryZone + h * 0.02;
          final carouselHeight = centralH * 1.28;

          return Stack(
            children: [
              // Il cielo qui e' quello del motore unico dello shell: il
              // Santuario non sovrappone piu' un secondo strato di nebulose che
              // leggeva lo stesso controller con coefficienti diversi.

              // Il cielo in alto e' toccabile: apre "Il cielo sopra di te".
              // Ordine pulito, poco testo: prima il titolo, poi la grafica
              // della Luna con l'occhiello della fase, poi la riga personale
              // nella voce del Maestro al centro. Un margine comodo in cima
              // (oltre la safe area) tiene il titolo staccato dal bordo, mai
              // sotto il notch o l'isola dinamica.
              Positioned(
                top: h * 0.012,
                left: 0,
                right: 0,
                child: GestureDetector(
                  key: const Key('santuario_sky_tap'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openSky(context),
                  child: Column(
                    children: [
                      // 1. Titolo fisso, in cima. Un margine orizzontale ampio lo
                      // tiene staccato dall'icona Utente nell'angolo, che resta
                      // isolata; se serve va a capo, mai a ridosso dell'avatar.
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 64),
                        child: _SkyTitle(),
                      ),
                      const SizedBox(height: 2),
                      // 2. Grafica della Luna e del cielo, con l'occhiello della
                      // fase reale sotto. Footprint compatto: meno vuoto attorno
                      // alla Luna, piu' spazio alle carte dei Maestri sotto.
                      MoonWidget(
                          phase: moon, size: (w * 0.12).clamp(54.0, 100.0)),
                      Text(
                        moon.italianName.toUpperCase(),
                        style: TypographyTokens.label(size: 11).copyWith(
                          color: palette.goldSoft,
                          letterSpacing: 1.6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // 3. Riga personale, col nome e il segno.
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          personalLine,
                          textAlign: TextAlign.center,
                          style: TypographyTokens.body(size: 13).copyWith(
                            color: ColorTokens.textSecondary,
                            fontStyle: FontStyle.italic,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Invito al tocco del cielo: in alto, accanto alla Luna, cosi'
              // invita a toccare il cielo e non i Maestri. E' sopra la scena ma
              // trasparente ai tocchi, che passano alla zona toccabile del
              // cielo sottostante: mano e zona coincidono in quest'area alta.
              // Compare dopo qualche secondo, si dissolve alla prima
              // interazione, ferma con Riduci Movimento.
              // Piu' in alto e piu' a destra di prima: cosi' com'era, la
              // riga 'Tocca il cielo' finiva sopra il nome della fase
              // lunare, e due scritte sovrapposte sono illeggibili tutte e
              // due. L'invito sta ora nella fascia libera accanto alla Luna.
              Positioned(
                top: h * 0.055,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Align(
                    alignment: const Alignment(0.72, 0),
                    child: _SkyTapHint(
                      visible: _showSkyHint,
                      pulse: _tapPulse,
                      reduceMotion: reduceMotion,
                      color: palette.goldSoft,
                    ),
                  ),
                ),
              ),

              // Palco e busti, alzati verso il centro della scena.
              Positioned(
                left: 0,
                right: 0,
                bottom: carouselBottom,
                height: carouselHeight,
                child: _Carousel(
                  central: central,
                  selected: selected,
                  centralHeight: centralH,
                  breath: _breath,
                  reduceMotion: reduceMotion,
                  preferred: SantuarioScreen.preferred,
                  centralDepth: depth(0.5),
                  sideDepth: depth(0.28),
                  onTapCentral: () => _enterDomain(context, central),
                  onTapSide: (m) => _selectSide(context, m),
                ),
              ),

              // La bolla di ingresso al dominio, sotto la figura: un invito di
              // due righe su cosa si trova dentro, il pulsante Entra nel Dominio
              // del Maestro al centro nella sua palette, e sotto la riga con le
              // sue tre arti. Formato uniforme per tutti; per i riti che ruotano
              // (Alba, Buonanotte) invito e arti seguono il Maestro di turno,
              // perche' il centro e' gia' quel Maestro.
              Positioned(
                left: 0,
                right: 0,
                bottom: entryBottom,
                child: _MisuraAltezza(
                  onMisura: (v) {
                    if (_altezzaIngresso == null ||
                        (_altezzaIngresso! - v).abs() > 0.5) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) setState(() => _altezzaIngresso = v);
                      });
                    }
                  },
                  child: _DomainEntry(
                    maestro: central,
                    onTap: () => _enterDomain(context, central),
                  ),
                ),
              ),

              // Icona Utente in alto a destra: apre l'area account, distinta dal
              // Passport (che resta il profilo esoterico nella barra in basso).
              Positioned(
                top: h * 0.012,
                right: SpacingTokens.sm,
                child: _UserAvatarButton(
                  palette: palette,
                  onTap: () =>
                      Navigator.of(context).push(AccountScreen.route()),
                ),
              ),
            ],
          );
        },
    );
  }
}

/// Il titolo fisso del cielo. In un widget a se' cosi' la sua Padding puo'
/// restare const; va a capo su due righe se lo spazio lasciato dall'avatar non
/// basta, senza mai toccarlo.
class _SkyTitle extends StatelessWidget {
  const _SkyTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Il Cielo Sopra di Te, Adesso',
      textAlign: TextAlign.center,
      maxLines: 2,
      style: TypographyTokens.display(size: 16),
    );
  }
}

/// Il carosello dei tre busti: centrale grande e vivo, laterali alzati verso
/// l'alto, arretrati e in penombra, uniti dal filo d'oro del cerchio.
class _Carousel extends StatelessWidget {
  const _Carousel({
    required this.central,
    required this.selected,
    required this.centralHeight,
    required this.breath,
    required this.reduceMotion,
    required this.preferred,
    required this.centralDepth,
    required this.sideDepth,
    required this.onTapCentral,
    required this.onTapSide,
  });

  final Maestro central;
  final bool selected;
  final double centralHeight;
  final Animation<double> breath;
  final bool reduceMotion;
  final Maestro preferred;

  /// Deriva di parallasse (giroscopio) del busto centrale, piano in primo
  /// piano: si inclina un po' di piu' dei laterali.
  final Offset centralDepth;

  /// Deriva di parallasse dei laterali, piano arretrato: si inclina di meno.
  final Offset sideDepth;
  final VoidCallback onTapCentral;
  final ValueChanged<Maestro> onTapSide;

  @override
  Widget build(BuildContext context) {
    // I due laterali sono gli altri due nell'ordine fisso, primo a sinistra.
    final sides = Maestro.fixedOrder.where((m) => m != central).toList();
    final sideH = centralHeight * 0.60;
    final centralW = centralHeight * 0.75;
    final sideW = sideH * 0.75;
    // Laterali sollevati: sbucano ai lati sopra la carta centrale, cosi' si
    // vede che i Maestri sono tre.
    final sideBottom = centralHeight * 0.44;

    return AnimatedBuilder(
      animation: breath,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final breathValue = reduceMotion ? 0.5 : breath.value;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // L'ellisse dorata che congiungeva i tre busti non c'e' piu':
                // a schermo cadeva storta, perche' era un arco calcolato su
                // tre altezze diverse e nessuna curva la faceva sembrare
                // voluta. Mauro l'ha bocciata, e togliere una linea sbagliata
                // vale piu' che raddrizzarla: i tre Maestri si tengono da
                // soli, senza un filo che li leghi.

                // Busto sinistro, alzato, arretrato e in penombra.
                Positioned(
                  left: w * 0.01,
                  bottom: sideBottom,
                  width: sideW,
                  height: sideH,
                  child: Transform.translate(
                    offset: sideDepth,
                    child: GestureDetector(
                      key: const Key('santuario_side_left'),
                      onTap: () => onTapSide(sides[0]),
                      child: MaestroBust(
                        maestro: sides[0],
                        height: sideH,
                        central: false,
                        dim: 0.5,
                        preferred: sides[0] == preferred,
                      ),
                    ),
                  ),
                ),

                // Busto destro, alzato, arretrato e in penombra.
                Positioned(
                  right: w * 0.01,
                  bottom: sideBottom,
                  width: sideW,
                  height: sideH,
                  child: Transform.translate(
                    offset: sideDepth,
                    child: GestureDetector(
                      key: const Key('santuario_side_right'),
                      onTap: () => onTapSide(sides[1]),
                      child: MaestroBust(
                        maestro: sides[1],
                        height: sideH,
                        central: false,
                        dim: 0.5,
                        preferred: sides[1] == preferred,
                      ),
                    ),
                  ),
                ),

                // Busto centrale, l'unico vivo, in primo piano: respira e si
                // inclina un po' di piu' col giroscopio.
                Positioned(
                  left: (w - centralW) / 2,
                  bottom: 0,
                  width: centralW,
                  height: centralHeight,
                  child: Transform.translate(
                    offset: centralDepth,
                    child: GestureDetector(
                      key: const Key('santuario_central_bust'),
                      onTap: onTapCentral,
                      child: MaestroBust(
                        maestro: central,
                        height: centralHeight,
                        central: true,
                        breath: breathValue,
                        preferred: central == preferred,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// L'ellisse dorata del Cerchio: una linea curva sottile che parte da dietro la
/// carta centrale e congiunge le due carte laterali dei Maestri. Oro luminoso a
/// bassa opacita', premium e non invadente, sopra il cosmo e sotto i busti.
class _DomainEntry extends StatelessWidget {
  const _DomainEntry({required this.maestro, required this.onTap});

  final Maestro maestro;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(ThemeKey.of(maestro));
    // Solo il pulsante e la riga delle arti: nessun saluto sopra, cosi' non si
    // sovrappone alla carta. Ogni Maestro si presenta dentro il proprio dominio.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _EnterDomainButton(maestro: maestro, onTap: onTap),
        const SizedBox(height: SpacingTokens.xs),
        // La riga delle tre arti del Maestro.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 12, color: palette.gold),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                maestro.domainArts,
                key: const Key('santuario_domain_arts'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TypographyTokens.label(size: 11).copyWith(
                  color: palette.goldSoft,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// L'avatar Utente in alto a destra: apre l'area account. Un cerchio discreto
/// nella palette del Maestro al centro, con l'icona di una persona.
class _UserAvatarButton extends StatelessWidget {
  const _UserAvatarButton({required this.palette, required this.onTap});

  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        key: const Key('santuario_user_avatar'),
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              palette.primary.withValues(alpha: 0.55),
              palette.deepest.withValues(alpha: 0.5),
            ]),
            border: Border.all(color: palette.gold.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: palette.glow.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: -4,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(Icons.person_outline_rounded,
              size: 22, color: palette.goldSoft),
        ),
      ),
    );
  }
}

/// Pulsante a bolla discreto, terza via al dominio del Maestro al centro. Sta
/// nella palette del Maestro e il nome si aggiorna col centro.
class _EnterDomainButton extends StatelessWidget {
  const _EnterDomainButton({required this.maestro, required this.onTap});

  final Maestro maestro;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(ThemeKey.of(maestro));
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('santuario_enter_domain'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.sm, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
            gradient: LinearGradient(
              colors: [
                palette.primary.withValues(alpha: 0.6),
                palette.surfaceElevated.withValues(alpha: 0.6),
              ],
            ),
            border: Border.all(color: palette.gold.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: palette.glow.withValues(alpha: 0.35),
                blurRadius: 16,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(maestro.icon, size: 16, color: palette.goldSoft),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Entra nel Dominio di ${maestro.displayName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TypographyTokens.label(size: 12)
                      .copyWith(color: palette.goldSoft, letterSpacing: 0.3),
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded,
                  size: 16, color: palette.goldSoft),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lo scaffale delle funzioni, sotto l'alto del Santuario. Card ordinate che
/// scorrono, ciascuna nel colore del suo Maestro: le funzioni vive si aprono, le
/// altre mostrano un anticipo. L'ordine vive nella configurazione dedicata
/// (`function_shelf.dart`), qui resta solo la resa.
class _FunctionShelfView extends StatelessWidget {
  const _FunctionShelfView({required this.onOpen});

  final ValueChanged<ShelfFunction> onOpen;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final functions = FunctionShelf.ordered();
    return Padding(
      padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.sm,
          SpacingTokens.lg, SpacingTokens.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Un titolo sobrio annuncia lo scaffale, livello visivo prima del
          // testo lungo: le card sono la scena, questa e' solo la soglia.
          Row(
            children: [
              Icon(Icons.auto_awesome_mosaic_rounded,
                  size: 18, color: palette.goldSoft),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text('Le funzioni del Cerchio',
                    style: TypographyTokens.display(size: 18)
                        .copyWith(color: palette.goldSoft)),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          ListView.separated(
            key: const Key('santuario_shelf'),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: functions.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: SpacingTokens.sm),
            itemBuilder: (context, i) => _ShelfCard(
              fn: functions[i],
              onTap: () => onOpen(functions[i]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Una card dello scaffale, nel colore del Maestro di dominio. Livello visivo
/// prima del testo: l'emblema tondo, poi il nome, poi una riga di anticipo. Le
/// funzioni non ancora vive portano il badge Coming soon, mai un vicolo cieco.
class _ShelfCard extends StatelessWidget {
  const _ShelfCard({required this.fn, required this.onTap});

  final ShelfFunction fn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(ThemeKey.of(fn.maestro));
    return DepthCard(
      key: Key('shelf_${fn.id}'),
      onTap: onTap,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
              gradient: RadialGradient(colors: [
                palette.primary.withValues(alpha: 0.5),
                palette.deepest.withValues(alpha: 0.4),
              ]),
              border: Border.all(color: palette.gold.withValues(alpha: 0.5)),
            ),
            alignment: Alignment.center,
            child: Icon(fn.icon, color: palette.goldSoft, size: 26),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titolo a piena larghezza, cosi' non si spezza a meta' parola.
                // Localizzato per chiave, italiano di default.
                Text(AppStrings.functionTitle(fn.id, fallback: fn.title),
                    style: TypographyTokens.display(size: 17)),
                const SizedBox(height: 2),
                Text(fn.teaser,
                    style: TypographyTokens.body(size: 13)
                        .copyWith(color: ColorTokens.textSecondary, height: 1.3)),
                if (!fn.live) ...[
                  const SizedBox(height: SpacingTokens.xs),
                  _ComingSoonBadge(palette: palette),
                ],
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Icon(
            fn.live ? Icons.chevron_right_rounded : Icons.lock_clock_rounded,
            size: 20,
            color: palette.goldSoft.withValues(alpha: fn.live ? 0.9 : 0.6),
          ),
        ],
      ),
    );
  }
}

/// Il badge dorato Coming soon delle funzioni in arrivo.
class _ComingSoonBadge extends StatelessWidget {
  const _ComingSoonBadge({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        color: palette.gold.withValues(alpha: 0.16),
        border: Border.all(color: palette.gold.withValues(alpha: 0.5)),
      ),
      child: Text(
        'Coming soon',
        style: TypographyTokens.label(size: 11)
            .copyWith(color: palette.goldSoft, letterSpacing: 0.4),
      ),
    );
  }
}

/// Invito al tocco del cielo: una silhouette di mano con l'indice teso che fa
/// il gesto del tocco, pulsa dolcemente e manda un'onda dal polpastrello, con
/// la riga "Tocca il cielo". Compare dopo qualche secondo di inattivita' e si
/// dissolve alla prima interazione. Con Riduci Movimento resta ferma.
class _SkyTapHint extends StatelessWidget {
  const _SkyTapHint({
    required this.visible,
    required this.pulse,
    required this.reduceMotion,
    required this.color,
  });

  final bool visible;
  final Animation<double> pulse;
  final bool reduceMotion;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 400),
        child: !visible
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 46,
                      height: 54,
                      child: AnimatedBuilder(
                        animation: pulse,
                        builder: (context, _) => CustomPaint(
                          painter: _TapHandPainter(
                            phase: reduceMotion ? -1.0 : pulse.value,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tocca il cielo',
                      style: TypographyTokens.label(size: 11).copyWith(
                        color: color.withValues(alpha: 0.75),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Disegna la silhouette di una mano che tocca: indice teso in alto, pugno e
/// pollice sotto. Nel gesto la mano scende un poco e dal polpastrello parte
/// un'onda che si allarga e svanisce. [phase] in 0..1 anima il ciclo; un
/// valore negativo tiene la mano ferma (Riduci Movimento).
class _TapHandPainter extends CustomPainter {
  _TapHandPainter({required this.phase, required this.color});

  final double phase;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final motion = phase >= 0;

    // Pressione del tocco: una gobba morbida nella finestra centrale.
    double press = 0;
    if (motion && phase >= 0.22 && phase <= 0.5) {
      press = math.sin((phase - 0.22) / (0.5 - 0.22) * math.pi);
    }
    final dy = press * 4.0;
    const tip = Offset(0, 2); // polpastrello, in coordinate locali (x=cx)

    // Onda dal polpastrello, dopo la pressione.
    if (motion && phase >= 0.42 && phase <= 0.95) {
      final k = (phase - 0.42) / (0.95 - 0.42);
      canvas.drawCircle(
        Offset(cx + tip.dx, tip.dy + dy),
        3 + k * 13,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = color.withValues(alpha: (1 - k) * 0.45),
      );
    }

    canvas.save();
    canvas.translate(0, dy);
    final hand = _handPath(cx);
    canvas.drawPath(
      hand,
      Paint()..color = color.withValues(alpha: motion ? 0.55 + 0.3 * press : 0.7),
    );
    final tratto = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.9);
    canvas.drawPath(hand, tratto);
    _pieghe(canvas, cx, tratto);
    canvas.restore();
  }

  /// Il contorno di una mano che indica, in un tratto solo.
  ///
  /// Le due versioni precedenti erano un rettangolo arrotondato sopra un altro
  /// rettangolo arrotondato, con un ovale di lato: a schermo si leggeva come un
  /// cursore, non come una mano, e Mauro le ha bocciate tutte e due. Qui il
  /// contorno e' continuo e curvo, con le tre nocche delle dita piegate a
  /// destra e la gobba del pollice a sinistra: sono quelle due sagome che
  /// fanno riconoscere una mano, non la presenza di un dito dritto.
  /// Riferimento: Linee Guida sezione 24.
  Path _handPath(double cx) {
    final p = Path();
    // Punta dell'indice, arrotondata.
    p.moveTo(cx - 3.6, 9);
    p.quadraticBezierTo(cx, 1.5, cx + 3.6, 9);
    // Lato destro dell'indice, fino a dove entra nella mano.
    p.lineTo(cx + 3.6, 21);
    // Le tre dita piegate: tre nocche in fila, sempre piu' basse.
    p.quadraticBezierTo(cx + 9.5, 21, cx + 10.5, 26.5);
    p.quadraticBezierTo(cx + 14, 28.5, cx + 12.5, 34.5);
    p.quadraticBezierTo(cx + 14, 40, cx + 10.5, 43.5);
    // Base del palmo e polso.
    p.quadraticBezierTo(cx + 7.5, 48.5, cx - 1, 48.5);
    p.quadraticBezierTo(cx - 8, 48.5, cx - 10, 42.5);
    // Il pollice piegato contro il palmo: la gobba sul lato sinistro.
    p.quadraticBezierTo(cx - 14.5, 37.5, cx - 12.5, 30);
    p.quadraticBezierTo(cx - 11, 23.5, cx - 6, 22);
    // Rientra sotto l'indice e chiude.
    p.quadraticBezierTo(cx - 3.6, 20.5, cx - 3.6, 9);
    p.close();
    return p;
  }

  /// Le pieghe fra le dita piegate: due archi corti, disegnati in tratto sopra
  /// la sagoma. Senza di loro le nocche restano una gobba sola e la mano torna
  /// a somigliare a un guanto.
  void _pieghe(Canvas canvas, double cx, Paint tratto) {
    final a = Path()
      ..moveTo(cx + 4.5, 27.5)
      ..quadraticBezierTo(cx + 8, 28.5, cx + 10, 27);
    final b = Path()
      ..moveTo(cx + 4.5, 35.5)
      ..quadraticBezierTo(cx + 8, 36.5, cx + 12, 35);
    canvas.drawPath(a, tratto);
    canvas.drawPath(b, tratto);
  }

  @override
  bool shouldRepaint(_TapHandPainter old) =>
      old.phase != phase || old.color != color;
}



/// Misura l'altezza del proprio figlio e la riferisce, una volta per cambio.
///
/// Serve dove una coordinata dipende da quanto e' alto davvero un pezzo di
/// interfaccia: le costanti scritte a mano reggono finche' il testo non
/// cresce, poi due elementi si sovrappongono e il difetto compare solo su
/// certi telefoni.
class _MisuraAltezza extends StatelessWidget {
  const _MisuraAltezza({required this.child, required this.onMisura});

  final Widget child;
  final ValueChanged<double> onMisura;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, _) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) onMisura(box.size.height);
        return child;
      },
    );
  }
}

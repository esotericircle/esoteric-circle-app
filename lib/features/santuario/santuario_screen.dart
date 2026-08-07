import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shell/spazio_della_barra.dart';

import '../../core/astro/moon_phase.dart';
import '../../core/astro/zodiac.dart';
import '../../core/astro/zodiac_controller.dart';
import '../../core/astro/night_sky.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_controller.dart';
import '../../core/motion/parallax_controller.dart';
import '../../core/rituals/daily_elements.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/app_services.dart';
import '../account/account_screen.dart';
import '../maestri/art_navigation.dart';
import '../maestri/widgets/striscia_altre_arti.dart';
import '../maestri/domain_screen.dart';
import 'daily_strip.dart';
import 'sky_overview_screen.dart';
import 'widgets/maestro_bust.dart';
import 'widgets/moon_widget.dart';
import 'widgets/tue_arti_view.dart';

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
  const SantuarioScreen({
    super.key,
    this.clock,
    this.disegnaIngresso = true,
    this.disegnaTrio = true,
  });

  /// Orologio iniettabile per i test. Di default l'ora locale del dispositivo.
  /// Guida sia la striscia del giorno sia l'eroe centrale, cosi' i due
  /// concordano sempre sullo stesso elemento della fascia oraria attiva.
  final DateTime Function()? clock;

  /// Se la zona d'ingresso al dominio va DISEGNATA.
  ///
  /// Esiste per la misura differenziale dell'occlusione: si rende la scena due
  /// volte, una col disegno e una senza, e si confrontano i pixel dentro la
  /// carta del Maestro centrale. Se cambiano, la bolla la stava coprendo.
  ///
  /// L'ingombro resta in ogni caso, con `Visibility` che mantiene la misura:
  /// togliere la bolla dal LAYOUT farebbe scendere il carosello, e allora le due
  /// immagini differirebbero per intero invece che per la sola occlusione. Era
  /// il modo in cui anche questa misura sarebbe nata cieca.
  final bool disegnaIngresso;

  /// Se il trio delle carte va DISEGNATO.
  ///
  /// Serve alla misura differenziale a TRE rese, che e' l'unica che smaschera
  /// questo difetto. Confrontare la resa con la bolla e quella senza, dentro il
  /// rettangolo della carta, non basta: la figura del Maestro sborda FUORI da
  /// quel rettangolo, quindi l'occlusione avviene dove il confronto non guarda.
  ///
  /// Con tre rese si misura la cosa giusta: nella zona occupata dalla bolla si
  /// confronta la resa senza bolla con quella senza bolla NE trio. Se
  /// differiscono, in quella zona c'e' la figura, quindi la bolla la sta
  /// coprendo.
  final bool disegnaTrio;

  /// Maestro preferito, segnaposto in attesa dell'assegnazione all'onboarding.
  static const Maestro preferred = Maestro.medora;

  /// Quanta parte del proprio contenitore deve occupare la carta del Maestro.
  ///
  /// **Perche' esiste come dato.** Il fondatore ha segnalato quattro volte che
  /// il pulsante del dominio si sovrappone alla carta, e insieme che sopra le
  /// tre carte avanza molto spazio vuoto. Misurato: a 360 per 797 punti la
  /// carta era alta 297 dentro un contenitore alto 510, cioe' ne usava il 58
  /// per cento, e sopra di lei avanzavano piu' di 350 punti mentre sotto ne
  /// restavano 35.
  ///
  /// Lo spazio non mancava, era distribuito male: ne avanzava sopra e ne
  /// mancava sotto. Stringere la carta sarebbe stata la risposta sbagliata,
  /// perche' avrebbe buttato via spazio che c'era gia'.
  ///
  /// E' la quota dell'altezza dello SCHERMO che la carta deve occupare, non
  /// quella del suo contenitore interno: il contenitore si adatta alla carta,
  /// quindi misurarci dentro direbbe sempre di si'. Era il 37 per cento.
  ///
  /// **QUARANTA E NON DI PIU', e dichiaro perche'.** Era il 37 per cento, ed e'
  /// salito al 40: un guadagno vero ma parziale. Oltre quella soglia il
  /// carosello non regge sugli schermi bassi, i tre Maestri escono dalla scena e
  /// il carosello smette di essere costruito. La strada per andare oltre non e'
  /// alzare ancora questo numero: e' rivedere come il carosello dispone i tre
  /// busti, che e' un lavoro suo e non di questa voce.
  ///
  /// Il numero sta QUI e non sparso nel layout, e una prova lo legge da qui.
  static const double quotaMinimaCarta = 0.40;

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
  /// Apre un'arte dello scaffale personale, per identificativo.
  ///
  /// Usa la stessa mappa unica delle rotte: la stessa arte si apre alla stessa
  /// schermata da qualunque scaffale la si tocchi.
  void _openArte(BuildContext context, String id, Zodiac userSign) {
    final profile = context.read<ProfileController>();
    final route = artRouteFor(
      id,
      userBirth:
          profile.identity.isExample ? null : profile.identity.birthMoment,
      userName: profile.hasName ? profile.vocative : null,
    );
    if (route != null) Navigator.of(context).push(route);
  }

  
  /// La rotta di una funzione dello scaffale: la stessa mappa unica del dominio
  /// (`artRouteFor`), cosi' la stessa arte si apre sempre alla stessa schermata.
  /// Porta anche nome e data reali del profilo, quando ci sono, cosi' la
  /// Sinastria VIP mostra la persona vera invece del segnaposto.
  
  
  /// La riga personale del Maestro al centro, col nome reale dell'utente e il
  /// suo segno, cosi' parla proprio a lui. Per Medora la parte astronomica e'
  /// vera (luce e tendenza reali della Luna); Aura e Caligo sono testo
  /// segnaposto in attesa dei loro motori.
  ///
  /// Non ripete il nome della fase, gia' mostrato nell'occhiello in alto.
  ///
  /// **SENZA SEGNO LA FRASE REGGE LO STESSO.** Il segno discende dalla data di
  /// nascita, e chi non l'ha ancora data non ha un segno: prima si mostrava
  /// Gemelli a chiunque, che e' molto peggio del non nominarlo. Le versioni
  /// senza segno non sono un ripiego mutilato, sono frasi intere: parlano della
  /// notte e del gesto invece che di chi nasce sotto qualcosa.
  String _personalLine(
      Maestro maestro, MoonPhase moon, String name, String? sign) {
    switch (maestro) {
      case Maestro.medora:
        final quando = SantuarioScreen.medoraMoonFragment(moon);
        return sign == null
            ? '$name, $quando: la giusta ora per guardare in alto.'
            : '$name, $quando: la giusta ora per chi nasce sotto $sign.';
      case Maestro.aura:
        return sign == null
            ? '$name, la tua energia cerca quiete: una mano sul cuore.'
            : "$name, l'energia di chi nasce sotto $sign cerca quiete: una mano sul cuore.";
      case Maestro.caligo:
        return sign == null
            ? '$name, stanotte sale per te una runa di pazienza.'
            : '$name, per chi nasce sotto $sign stanotte sale una runa di pazienza.';
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

    // Slot personali: nome reale e segno dell'utente, tutti e due dal PROFILO,
    // che e' l'unico posto dove quei dati sono persistiti.
    //
    // Il segno si leggeva dal controller dello zodiaco, che nasce con un segno
    // di esempio, non conserva niente fra un avvio e l'altro, e che un solo
    // punto di tutto il progetto si ricordava di riempire: la home diceva
    // "chi nasce sotto Gemelli" a chiunque, a ogni riavvio. Adesso il segno
    // discende dalla data di nascita, ed e' nullo finche' quella data non c'e'.
    final profilo = context.watch<ProfileController>();
    final userName = profilo.vocative;
    final userSign = profilo.identity.sunSign?.italianName;
    // Le rotte delle arti chiedono un segno che esista sempre, perche' un
    // oroscopo senza segno non e' una cosa. Quello si ricava dalla data che
    // c'e' comunque, anche quando e' quella d'esempio dichiarata in-world: NON
    // e' un segno cablato, e' il segno di quella data. La FRASE sopra invece
    // non lo usa, perche' li' un segno che non e' il tuo e' una bugia detta
    // alla persona, ed era esattamente il difetto.
    final userZodiac = NightSky.sunSign(profilo.identity.birthDate);
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
      // **LO SPAZIO DELLA BARRA STA DENTRO LO SCROLL, NON QUI.** Decisione di
      // Mauro del 7 agosto 2026: ovunque il comportamento del dominio, il
      // contenuto scorre sotto la barra. Prima il SafeArea consumava anche il
      // fondo, e quello era lo slot fisso che rimpiccioliva la schermata: la
      // ragione intera sta su SpazioDellaBarraNelloScroll.
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // La striscia del giorno, fissa in cima e sempre visibile: i quattro
            // elementi giornalieri, quello dell'ora attuale in evidenza. Stesso
            // orologio dell'eroe, cosi' striscia e centro concordano.
            DailyStrip(
              clock: widget.clock,
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, outer) {
                  // L'EROE RESTA ALTO COME PRIMA. Il viewport adesso arriva
                  // fino in fondo allo schermo, sotto la barra: se l'eroe lo
                  // riempisse tutto, i busti crescerebbero e il pulsante
                  // finirebbe sotto la barra. Si sottrae lo spazio della
                  // barra, che e' esattamente quanto il SafeArea consumava
                  // prima: i tre Maestri non cambiano grandezza di un punto,
                  // e la prova che li sorveglia resta verde senza allentarsi.
                  final viewportH = outer.maxHeight -
                      SpazioDellaBarraNelloScroll.quanto(context);
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
                        // Lo scaffale personale viene PRIMA dell'elenco
                        // completo: quello che si e' scelto sta davanti a
                        // quello che il Cerchio propone.
                        TueArtiView(
                          onOpen: (id) => _openArte(context, id, userZodiac),
                        ),
                        // "Le funzioni del Cerchio" non esiste piu': "Le tue
                        // arti" la SOSTITUISCE, come l'ordine diceva. Avevo
                        // aggiunto la nuova lasciando la vecchia, quindi nel
                        // Santuario c'erano due titoli e due elenchi della
                        // stessa cosa.
                        // La striscia delle arti da scoprire, la STESSA del
                        // dominio: un widget condiviso, non una copia. Qui
                        // `corrente` e' nullo perche' la home non e' il
                        // dominio di nessun Maestro: si esclude solo cio' che
                        // sta gia' nello scaffale qui sopra. Ordine 2161,
                        // voce 4.
                        const StrisciaAltreArti(),
                        // La coda che riporta l'ultimo scaffale sopra la barra.
                        const SpazioDellaBarraNelloScroll(),
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
          // LA CARTA PRENDE LO SPAZIO CHE AVANZA. Era `h * 0.5` col tetto a
          // 430, e a 797 punti dava una carta alta 297 su 797, il 37 per cento:
          // sopra di lei restavano piu' di 350 punti vuoti mentre sotto ne
          // avanzavano 35. Lo spazio non mancava, era distribuito male.
          //
          // Il tetto sale con lui: a 430 il valore restava tagliato sugli
          // schermi alti, e alzare solo il coefficiente non avrebbe cambiato
          // niente proprio dove c'e' piu' spazio da recuperare.
          //
          // NON e' il calcolo per differenza dallo spazio libero, gia' tentato
          // qui e rientrato: quello inseguiva la zona d'ingresso, che si misura
          // a sua volta, e i due si rincorrevano di fotogramma in fotogramma.
          // Questo e' un rapporto fisso con l'altezza, che non insegue nulla.
          //
          // Il tetto e' PROPORZIONALE e non un numero fisso: con 560 fissi, su
          // uno schermo basso il carosello usciva dalla scena e i tre Maestri
          // finivano fuori dallo schermo. Si prende `math.max` col minimo,
          // perche' un `clamp` con il tetto sotto il minimo solleva.
          final tettoCentrale = math.max(220.0, h * 0.54);
          final centralH = (h * 0.60).clamp(220.0, tettoCentrale);
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
          //
          // Il margine era il due per cento e NON bastava, perche' la figura
          // del Maestro SBORDA dal riquadro della propria carta con Clip.none:
          // il rettangolo del carosello finiva sopra la bolla mentre i pixel
          // dipinti della figura arrivavano a toccarla. Misurato per immagine:
          // meno zero virgola due punti di distanza, cioe' contatto.
          //
          // Sei per cento: la bolla sta sotto il fondo DIPINTO della figura con
          // il margine richiesto, e il trio guadagna l'aria che gli serve.
          final carouselBottom = entryBottom + entryZone + h * 0.06;
          final carouselHeight = centralH * 1.12;

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
                        child: _SkyTitle(
                            key: Key('santuario_sky_title')),
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
                child: Visibility(
                  visible: widget.disegnaTrio,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
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
                  child: Visibility(
                    visible: widget.disegnaIngresso,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: _DomainEntry(
                      maestro: central,
                      onTap: () => _enterDomain(context, central),
                    ),
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
  const _SkyTitle({super.key});

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
/// Il cerchio dei tre Maestri, che RUOTA.
///
/// Prima erano tre riquadri a posizione fissa (sinistra, destra, centro)
/// assegnati per indice: toccando un Maestro dietro, i tre cambiavano posto
/// nello stesso fotogramma, cioe' sparivano e ricomparivano altrove. Non era
/// una rotazione, era un taglio di montaggio.
///
/// Adesso ognuno ha un ANGOLO sul cerchio, e quello che si anima e' l'angolo.
/// Chi sta a zero e' davanti, gli altri due stanno indietro ai lati. Da un
/// angolo continuo discendono da soli la posizione orizzontale, la scala, la
/// penombra e perfino l'ordine di sovrapposizione: nessuno deve piu' decidere
/// "questo va a sinistra", lo decide il seno dell'angolo.
class _Carousel extends StatefulWidget {
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

  /// Deriva di parallasse (giroscopio) del busto in primo piano.
  final Offset centralDepth;

  /// Deriva di parallasse dei piani arretrati: si inclinano di meno.
  final Offset sideDepth;
  final VoidCallback onTapCentral;
  final ValueChanged<Maestro> onTapSide;

  /// Quanto dura un giro di un terzo. L'ordine chiede almeno quattro decimi di
  /// secondo: qui e' piu' lungo, perche' un movimento troppo rapido si legge
  /// ancora come uno scatto.
  static const Duration giro = Duration(milliseconds: 620);

  @override
  State<_Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel>
    with SingleTickerProviderStateMixin {
  /// La posizione del cerchio, misurata in POSTI: 0 vuol dire che il Maestro
  /// di indice 0 sta davanti, 0,5 che e' fermo a meta' strada fra due. Non e'
  /// limitata fra zero e tre: cresce e cala come un contagiri, cosi' girando
  /// sempre nello stesso verso non c'e' mai un salto.
  late double _posto;
  late final AnimationController _moto;
  Animation<double>? _corsa;

  int get _quanti => Maestro.fixedOrder.length;

  @override
  void initState() {
    super.initState();
    _posto = Maestro.fixedOrder.indexOf(widget.central).toDouble();
    _moto = AnimationController(vsync: this, duration: _Carousel.giro)
      ..addListener(() {
        final c = _corsa;
        if (c != null) setState(() => _posto = c.value);
      });
  }

  @override
  void didUpdateWidget(covariant _Carousel old) {
    super.didUpdateWidget(old);
    // Il Maestro al centro lo decide chi ci sta sopra: quando cambia, il
    // cerchio ci gira, invece di ritrovarsi gia' girato.
    if (old.central != widget.central) _ruotaVerso(widget.central);
  }

  @override
  void dispose() {
    _moto.dispose();
    super.dispose();
  }

  /// La strada piu' corta fino a quel Maestro, nel verso che gira meno.
  void _ruotaVerso(Maestro m) {
    _assestaSu(_piuVicino(
        Maestro.fixedOrder.indexOf(m).toDouble(), _posto, _quanti));
  }

  void _assestaSu(double bersaglio) {
    if (widget.reduceMotion) {
      setState(() => _posto = bersaglio);
      return;
    }
    _corsa = Tween<double>(begin: _posto, end: bersaglio).animate(
      CurvedAnimation(parent: _moto, curve: Curves.easeInOutCubic),
    );
    _moto
      ..stop()
      ..value = 0
      ..forward();
  }

  /// Il rappresentante di [bersaglio] piu' vicino a [da], contando che dopo
  /// l'ultimo posto si torna al primo: senza questo, passando dal terzo al
  /// primo il cerchio tornerebbe indietro di due posti invece di avanzare di
  /// uno.
  static double _piuVicino(double bersaglio, double da, int quanti) {
    var b = bersaglio;
    while (b - da > quanti / 2) {
      b -= quanti;
    }
    while (da - b > quanti / 2) {
      b += quanti;
    }
    return b;
  }

  void _trascina(DragUpdateDetails d, double larghezza) {
    // Un terzo di schermo trascinato vale un posto: il cerchio segue il dito
    // senza correre e senza frenare.
    _moto.stop();
    // Col verso invertito si inverte anche il dito, altrimenti trascinando
    // a sinistra il cerchio andrebbe dalla parte opposta.
    setState(() => _posto += d.delta.dx / (larghezza / 3));
  }

  void _rilascia(DragEndDetails d, double larghezza) {
    // L'inerzia: la velocita' del lancio sposta il bersaglio di al piu' un
    // posto, poi ci si assesta sul piu' vicino.
    final lancio = d.velocity.pixelsPerSecond.dx / (larghezza * 1.6);
    final bersaglio = (_posto + lancio.clamp(-1.0, 1.0)).roundToDouble();
    _assestaSu(bersaglio);

    // Chi finisce davanti diventa il Maestro al centro, per chi ci sta sopra.
    final indice = (((bersaglio.round() % _quanti) + _quanti) % _quanti);
    final arrivato = Maestro.fixedOrder[indice];
    if (arrivato != widget.central) widget.onTapSide(arrivato);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.breath,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final breathValue =
                widget.reduceMotion ? 0.5 : widget.breath.value;
            final centralW = widget.centralHeight * 0.75;
            // Il raggio orizzontale del cerchio visto di taglio: quanto si
            // spostano di lato quelli che stanno dietro.
            final raggio = w * 0.37;

            // Ogni Maestro al suo angolo, e da li' tutto il resto.
            final posti = <_PostoInCerchio>[];
            for (var i = 0; i < _quanti; i++) {
              final angolo = (i - _posto) * 2 * math.pi / _quanti;
              final profondita = math.cos(angolo); // 1 davanti, -1 dietro
              posti.add(_PostoInCerchio(
                maestro: Maestro.fixedOrder[i],
                // Il meno tiene la disposizione di sempre: chi segue nella
                // fila dei Maestri sta a SINISTRA di chi e' davanti. Col piu'
                // il cerchio girerebbe uguale, dalla parte opposta, e chi
                // conosce l'app troverebbe i due laterali scambiati.
                x: w / 2 - math.sin(angolo) * raggio,
                profondita: profondita,
                scala: 0.58 + 0.42 * ((profondita + 1) / 2),
              ));
            }
            // Dietro prima, davanti dopo: cosi' chi e' vicino copre chi e'
            // lontano, senza nessuna scelta scritta a mano.
            posti.sort((a, b) => a.profondita.compareTo(b.profondita));

            // Le chiavi seguono il RUOLO visivo, non il Maestro: chi sta
            // davanti si chiama sempre allo stesso modo, e chi sta dietro a
            // sinistra pure. Il dito, come i test, cerca un posto sulla scena,
            // non un nome, perche' il posto e' la sola cosa che si vede.
            final dietro = posti.where((p) => p.profondita <= 0.5).toList()
              ..sort((a, b) => a.x.compareTo(b.x));
            Key ruoloDi(_PostoInCerchio p) {
              if (p.profondita > 0.5) {
                return const Key('santuario_central_bust');
              }
              return dietro.isNotEmpty && identical(p, dietro.first)
                  ? const Key('santuario_side_left')
                  : const Key('santuario_side_right');
            }

            return GestureDetector(
              key: const Key('santuario_carosello'),
              onHorizontalDragUpdate: (d) => _trascina(d, w),
              onHorizontalDragEnd: (d) => _rilascia(d, w),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Uno strato trasparente che prende il trascinamento anche
                  // dove non c'e' un busto: senza, il dito funziona solo se
                  // parte esattamente da una figura.
                  Positioned.fill(
                      child: Container(color: Colors.transparent)),
                  for (final p in posti)
                    Builder(builder: (context) {
                      final davanti = p.profondita > 0.5;
                      final altezza = widget.centralHeight * p.scala;
                      final larghezza = centralW * p.scala;
                      // I piani lontani si inclinano meno col giroscopio: e'
                      // la stessa parallasse di prima, ora continua.
                      final deriva = Offset.lerp(
                        widget.sideDepth,
                        widget.centralDepth,
                        ((p.profondita + 1) / 2).clamp(0.0, 1.0),
                      )!;
                      return Positioned(
                        left: p.x - larghezza / 2,
                        // Chi sta dietro sta anche piu' in alto: e' cio' che
                        // da' profondita' a una scena vista di tre quarti.
                        bottom:
                            (1 - p.profondita) * widget.centralHeight * 0.22,
                        width: larghezza,
                        height: altezza,
                        child: Transform.translate(
                          offset: deriva,
                          child: GestureDetector(
                            key: ruoloDi(p),
                            onTap: () => davanti
                                ? widget.onTapCentral()
                                : widget.onTapSide(p.maestro),
                            child: MaestroBust(
                              maestro: p.maestro,
                              height: altezza,
                              central: davanti,
                              breath: davanti ? breathValue : 0.5,
                              // La penombra cresce con la lontananza, invece
                              // di essere accesa o spenta.
                              dim: davanti
                                  ? 0
                                  : 0.55 * (1 - (p.profondita + 1) / 2),
                              preferred: p.maestro == widget.preferred,
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Dove sta un Maestro sul cerchio, in questo istante.
class _PostoInCerchio {
  const _PostoInCerchio({
    required this.maestro,
    required this.x,
    required this.profondita,
    required this.scala,
  });

  final Maestro maestro;
  final double x;

  /// Da 1 (davanti) a meno 1 (dietro).
  final double profondita;
  final double scala;
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


/// Una card dello scaffale, nel colore del Maestro di dominio. Livello visivo
/// prima del testo: l'emblema tondo, poi il nome, poi una riga di anticipo. Le
/// funzioni non ancora vive portano il badge Coming soon, mai un vicolo cieco.
/// Una tessera grande dello scaffale: emblema tondo, nome, riga di anticipo e
/// freccia. Livello visivo prima del testo.
///
/// Pubblica e indipendente da `ShelfFunction`, perche' la usano due scaffali: le
/// funzioni del Cerchio, ora ritirate, e "Le tue arti". Prima "Le tue arti"
/// aveva pillole piccole tutte sue, dove i titoli si troncavano.
class ShelfCard extends StatelessWidget {
  const ShelfCard({
    super.key,
    required this.titolo,
    required this.anticipo,
    required this.icona,
    required this.maestro,
    required this.onTap,
    this.viva = true,
  });

  final String titolo;
  final String anticipo;
  final IconData icona;

  /// Il proprietario: decide il colore della tessera INTERA, non solo
  /// dell'emblema. Prima la card leggeva il tema attivo, quindi le tessere
  /// uscivano tutte blu mentre il solo emblema portava il colore giusto.
  final Maestro maestro;

  final VoidCallback onTap;
  final bool viva;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(ThemeKey.of(maestro));
    return DepthCard(
      onTap: onTap,
      palette: palette,
      opacity: viva ? 1.0 : 0.6,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
              color: palette.primary.withValues(alpha: 0.55),
              border: Border.all(color: palette.gold.withValues(alpha: 0.6)),
            ),
            alignment: Alignment.center,
            child: Icon(icona, color: palette.goldSoft, size: 26),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Il titolo si rimpicciolisce invece di troncarsi o di spezzarsi
                // dentro una parola: "Oroscopo Personalizzato" finiva con i
                // puntini, "Meditazione con Voce" si rompeva a meta' parola.
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(titolo,
                        maxLines: 1,
                        style: TypographyTokens.display(size: 17)
                            .copyWith(color: palette.textPrimary)),
                  ),
                ),
                const SizedBox(height: 2),
                Text(anticipo,
                    maxLines: 2,
                    style: TypographyTokens.body(size: 13)
                        .copyWith(color: ColorTokens.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.xs),
          Icon(Icons.chevron_right_rounded, color: palette.goldSoft),
        ],
      ),
    );
  }
}

/// Il badge dorato Coming soon delle funzioni in arrivo.


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
                          painter: TapHandPainter(
                            phase: reduceMotion ? -1.0 : pulse.value,
                            // BIANCA, non nel colore del Maestro: e' un
                            // suggerimento di gesto, non un elemento del tema,
                            // e sul cosmo profondo il bianco e' l'unico colore
                            // che si legge da subito senza competere col resto.
                            color: Colors.white,
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
/// La mano che suggerisce il tocco. Pubblica apposta: la sua forma e' la cosa
/// che va guardata a video, e per guardarla serve poterla montare ingrandita.
class TapHandPainter extends CustomPainter {
  TapHandPainter({required this.phase, required this.color});

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

  /// Il contorno di una mano che indica, in un tratto solo. Terza stesura.
  ///
  /// Le due precedenti sono state bocciate per ragioni diverse. La prima era un
  /// rettangolo arrotondato sopra un altro rettangolo arrotondato, con un ovale
  /// di lato: si leggeva come un cursore. La seconda aveva il contorno continuo
  /// ma le PROPORZIONI sbagliate, ed e' quello che la faceva ancora sembrare un
  /// guanto: l'indice era lungo diciannove punti su quarantotto di altezza e
  /// largo sette, cioe' un moncone grosso quanto un dito intero, e le tre
  /// nocche erano tre gobbe della stessa misura.
  ///
  /// **Un difetto trovato guardando l'anteprima ingrandita, non il codice.**
  /// Sistemate le proporzioni, la sagoma con l'indice al CENTRO del pugno si
  /// leggeva come un gesto volgare. Nel codice non si vedeva; ingrandita era
  /// evidente. Da qui lo scostamento `ix`: l'indice sta sul lato sinistro,
  /// dove sta in una mano vera, e il pugno resta piu' largo a destra.
  ///
  /// Cio' che rende riconoscibile una mano che indica sono quattro rapporti:
  ///
  /// 1. **L'indice e' lungo e sottile**: meta' dell'altezza, largo un quarto
  ///    della mano. Un dito corto e grosso e' un moncone.
  /// 2. **L'indice sta di LATO**, non al centro.
  /// 3. **Il pugno e' piu' largo che alto** e sporge a destra.
  /// 4. **Il pollice sporge in fuori e in basso**, sotto l'indice: e'
  ///    l'asimmetria che distingue una mano da un guanto.
  ///
  /// Riferimento: Linee Guida sezione 24.
  Path _handPath(double cx) {
    // L'indice NON sta al centro del pugno: sta sul lato, dove sta in una mano
    // vera. Al centro la sagoma si legge come un gesto volgare, ed e' quello
    // che si vedeva nell'anteprima ingrandita della stesura precedente.
    final ix = cx - 5;
    final p = Path();

    // L'INDICE, alzato, sul lato sinistro della mano. Lungo e sottile.
    p.moveTo(ix - 3, 13);
    p.cubicTo(ix - 3, 5, ix + 3, 5, ix + 3, 13);
    p.lineTo(ix + 3, 24);

    // Il dorso, che sale verso l'indice: la mano e' piu' larga a destra, ed e'
    // questa asimmetria che la fa leggere come una mano di tre quarti.
    p.cubicTo(ix + 6, 24, ix + 8, 25, ix + 9, 27);

    // LE TRE NOCCHE delle dita piegate, sul lato destro, di misura
    // decrescente: e' il decrescere che le fa leggere come tre dita in fila.
    p.cubicTo(ix + 13, 26, ix + 16, 28, ix + 16, 32);
    p.cubicTo(ix + 16, 35, ix + 14, 35, ix + 14.5, 37.5);
    p.cubicTo(ix + 15, 40, ix + 13, 41, ix + 12.5, 43);

    // La base della mano verso il polso: larga e piatta.
    p.cubicTo(ix + 11, 47, ix + 6, 49, ix + 1, 49);
    p.cubicTo(ix - 5, 49, ix - 9, 46, ix - 10, 42);

    // IL POLLICE, che sporge in fuori e in basso sotto l'indice: la punta e'
    // piu' bassa del suo attacco, come in una mano che indica.
    p.cubicTo(ix - 13, 39, ix - 13, 33, ix - 10, 31);
    p.cubicTo(ix - 8, 29.5, ix - 6, 30, ix - 5, 28);

    // Rientra sotto l'indice e chiude.
    p.cubicTo(ix - 4, 26, ix - 3.5, 25, ix - 3, 24);
    p.close();
    return p;
  
  }

  /// Le pieghe fra le dita piegate: due archi corti, disegnati in tratto sopra
  /// la sagoma. Senza di loro le nocche restano una gobba sola e la mano torna
  /// a somigliare a un guanto.
  void _pieghe(Canvas canvas, double cx, Paint tratto) {
    // Le pieghe seguono l'indice, che sta sul lato: lo stesso scostamento del
    // contorno, altrimenti restano appese in mezzo al palmo.
    final ix = cx - 5;
    final a = Path()
      ..moveTo(ix + 6, 30)
      ..quadraticBezierTo(ix + 10, 31, ix + 13.5, 29.5);
    final b = Path()
      ..moveTo(ix + 5, 37)
      ..quadraticBezierTo(ix + 9, 38, ix + 13.5, 36.5);
    canvas.drawPath(a, tratto);
    canvas.drawPath(b, tratto);
  }

  @override
  bool shouldRepaint(TapHandPainter old) =>
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

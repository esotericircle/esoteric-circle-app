import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/zodiac.dart';
import '../../core/astro/zodiac_controller.dart';
import '../../core/motion/parallax_controller.dart';
import '../../core/quality/quality_tier.dart';
import '../theme/maestro_palette.dart';
import '../theme/maestro_scope.dart';
import 'zodiac_figures.dart';

/// Sfondo cosmico immersivo full-bleed.
///
/// Compone, dal fondo alla superficie:
/// - un cielo quasi nero che vira verso l'accento del Maestro attivo;
/// - tre piani di parallasse (stelle lontane e costellazioni, nebulose media,
///   particelle vicine) che rispondono allo scorrimento e a una leggera
///   inclinazione del dispositivo;
/// - le dodici costellazioni zodiacali con linee sottili dorate che respirano
///   in opacita', con la costellazione del segno solare evidenziata in oro;
/// - nebulose soffuse e pittoriche tinte verso l'accento del Maestro;
/// - stelle che pulsano e ogni tanto una stella cadente lenta.
///
/// Tutto e' regolato dal Quality Tier: pieno in alto, ridotto in medio, quasi
/// statico in basso per garantire fluidita' e batteria.
class CosmosBackground extends StatefulWidget {
  /// **QUANTI CIELI SONO SOSPESI adesso, e lo leggono le prove.** Ordine AJ
  /// voce 01: quando una rotta ne copre un'altra, il cielo coperto si
  /// sospende; questo conto e' la mano sul polso della sospensione.
  @visibleForTesting
  static int quantiSospesi = 0;

  /// **QUANTE VOLTE LA SENTINELLA HA RIMESSO IN MOTO IL CIELO. Ordine AO
  /// voce 07.** Se il giro risulta fermo mentre lo stato dice che dovrebbe
  /// girare, la sentinella riparte e lo segna qui: un guasto che non lascia
  /// traccia e' un guasto che nessuno potra' spiegare. In un'app sana questo
  /// numero resta zero.
  @visibleForTesting
  static int ripartenzeDellaSentinella = 0;

  /// Ogni quanto la sentinella guarda il polso del cielo. Due secondi: lento
  /// abbastanza da non pesare, svelto abbastanza che nessuno veda un cielo
  /// fermo e si chieda perche'.
  static const Duration intervalloDellaSentinella = Duration(seconds: 2);

  /// QUANTE VOLTE IL COSMO SI E' RICOSTRUITO, per la misura dell'ordine AM
  /// voce 01. La lentezza che Mauro sente tornando in home si vede qui: se
  /// dopo un ciclo lo stesso movimento del dispositivo produce piu'
  /// ricostruzioni di prima, qualcosa si e' sommato. Non e' una guardia da
  /// sola, e' lo strumento con cui la guardia misura.
  @visibleForTesting
  static int quanteRicostruzioni = 0;

  /// QUANTE VOLTE I QUATTRO PIANI SONO STATI RASTERIZZATI DA CAPO.
  ///
  /// E' la misura del costo VERO: una ricostruzione di widget non costa
  /// quasi niente, rifare i quattro teli a schermo pieno costa un fotogramma
  /// intero. Ordine AM voce 01.
  @visibleForTesting
  static int quanteRigenerazioni = 0;

  const CosmosBackground({
    super.key,
    required this.child,
    // Spento per difetto: acceso, era l'unico strato uguale su ogni fondale
    // dell'app, e l'occhio riconosceva subito la stessa figura nello stesso
    // angolo. Ora lo accende solo chi lo vuole davvero.
    this.showZodiac = false,
    this.starKeepOut,
    this.showPlanets = true,
    this.seed = 0,
    this.paletteOverride,
  });

  final Widget child;

  /// Il seme del cielo di questa schermata: stesso motore, cielo diverso.
  ///
  /// Prima ogni schermata mostrava lo stesso identico cielo, con la stessa
  /// costellazione riconoscibile in alto a destra, perche' i generatori del
  /// painter partivano da semi cablati: era la regola 21 delle Linee Guida
  /// violata. Ogni schermata dichiara il proprio seme, deterministico, quindi
  /// ha il SUO cielo, che resta uguale fra un'apertura e l'altra.
  final int seed;

  /// Palette imposta dall'esterno, al posto di quella del Maestro attivo.
  ///
  /// Serve ai riti quotidiani, dove il Maestro dell'elemento ruota col giorno
  /// e non coincide con quello scelto nello shell. Null per tutti gli altri.
  final MaestroPalette? paletteOverride;

  /// Se falso, il cosmo non disegna le dodici costellazioni zodiacali ne'
  /// l'evidenziazione del segno solare. Le superfici di lettura, come la chat,
  /// lo spengono per restare pulite: nessuna forma stilizzata, nessun rettangolo
  /// a portale dietro l'interfaccia. Restano stelle, nebulose e stelle cadenti.
  final bool showZodiac;

  /// Zona franca, in coordinate normalizzate (0..1), dove non nascono stelle di
  /// fondo ne' particelle vicine. Serve a tenere il cielo lontano dal testo del
  /// titolo, cosi' nessuna stella cade su una lettera. Null per nessuna zona.
  final Rect? starKeepOut;

  /// Se falso, il cosmo non disegna i dischi dei pianeti soffusi. Lo spegne chi
  /// mette in scena un corpo celeste suo, come il Rito del Sogno con la Luna e
  /// il suo pianeta lontano, per non sovrapporre due sfere. Default acceso:
  /// nessuna altra schermata cambia.
  final bool showPlanets;

  @override
  State<CosmosBackground> createState() => _CosmosBackgroundState();
}

/// Il moto di ripiego per i montaggi senza provider, come i test isolati:
/// UNO solo e pigro, quindi al piu' una iscrizione al sensore anche li'.
/// Nell'app vera non nasce mai, perche' il provider esiste dall'avvio.
ParallaxController? _ripiego;
ParallaxController _parallasseDiRipiego() =>
    _ripiego ??= ParallaxController();

/// L'OSSERVATORE DELLE ROTTE per la sospensione del cielo. Ordine AJ voce
/// 01: la schermata COPERTA da una rotta spinta sopra continuava a
/// ricostruire il cosmo a ogni tick del sensore (il watch sulla parallasse)
/// e a tenere vivo il suo giro da trenta secondi. Ogni cosmo si iscrive qui
/// e, quando la sua rotta viene coperta, si sospende: niente ascolto della
/// parallasse, giro fermo. Al ritorno riprende. Montato in
/// `navigatorObservers` dall'app.
final OsservatoreDelCielo osservatoreDelCielo = OsservatoreDelCielo();

/// L'osservatore ricorda l'ULTIMA rotta spinta, perche' RouteAware non la
/// passa: il cielo deve sospendersi solo quando chi lo copre e' OPACO.
/// Ordine AL voce 01, misurato: una celebrazione o un foglio dal basso
/// (rotte trasparenti) facevano scattare la sospensione e il cosmo VISIBILE
/// dietro restava fermo al movimento del dispositivo.
class OsservatoreDelCielo extends RouteObserver<ModalRoute<void>> {
  Route<dynamic>? ultimaSpinta;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    ultimaSpinta = route;
    super.didPush(route, previousRoute);
  }
}

class _CosmosBackgroundState extends State<CosmosBackground>
    with SingleTickerProviderStateMixin, RouteAware, WidgetsBindingObserver {
  /// **LA SOSPENSIONE NON E' PIU' UN INTERRUTTORE. Ordine AO voce 07.**
  ///
  /// Era un bool mosso da due eventi OPPOSTI del RouteObserver,
  /// `didPushNext` e `didPopNext`: se uno dei due non arrivava, e non arriva
  /// tornando dal background ne' in certe uscite di rotta, il cielo restava
  /// fermo per sempre. E il giro si riarmava solo dentro il `build`, quindi
  /// bastava che non arrivasse una ricostruzione perche' restasse fermo
  /// anche con lo stato che diceva di girare. E' il difetto che Mauro ha
  /// visto sulla 2182, e questa voce lo chiude alla radice.
  ///
  /// Adesso il cielo gira se, e solo se, **la sua rotta e' in cima E l'app e'
  /// in primo piano**. Le due cose non sono ricordate, sono CHIESTE: la
  /// prima a `ModalRoute.isCurrent`, che e' una verita' interrogabile a ogni
  /// fotogramma; la seconda al ciclo di vita, che qui si ascolta. Cio' che
  /// resta ricordato, la copertura da parte di una rotta TRASPARENTE, non
  /// puo' bloccare niente da solo: se la rotta e' in cima, si gira.
  bool _copertoDaTrasparente = false;

  /// L'ultimo stato del ciclo di vita che il sistema ci ha detto.
  AppLifecycleState _cicloDiVita = AppLifecycleState.resumed;

  /// **QUANDO L'APP E' DAVVERO VIA, e non quando perde il fuoco un istante.**
  /// Ordine AQ voce 01, misurato il 19 agosto 2026.
  ///
  /// La voce AO.07 fermava il cielo per qualunque stato diverso da `resumed`,
  /// e li' dentro c'e' anche `inactive`, che su Android NON vuol dire che
  /// l'app e' sparita: arriva a schermo acceso e app visibile, col pannello
  /// delle notifiche che scende, con un avviso di sistema, in certe
  /// transizioni. Ogni volta il cosmo si inchiodava, e ripartiva al battito
  /// successivo della sentinella, fino a due secondi dopo: **e' il fermarsi
  /// e ripartire che Mauro ha visto sulla 2184 e che sulla 2181 non
  /// c'era**, perche' prima di AO.07 il ciclo di vita non entrava affatto
  /// nella decisione.
  ///
  /// Adesso si sta fermi solo quando l'app e' davvero via: sospesa, nascosta
  /// o staccata. Con `inactive` si continua a girare, perche' quel cielo la
  /// persona lo sta guardando. E' la scelta che l'ordine chiede quando
  /// fluidita' e risparmio litigano: **vince la fluidita'**.
  static const Set<AppLifecycleState> _appDavveroVia = {
    AppLifecycleState.paused,
    AppLifecycleState.hidden,
    AppLifecycleState.detached,
  };

  /// Vero se questo cielo, adesso, deve girare. **Calcolato, non ricordato.**
  bool get _deveGirare {
    if (_appDavveroVia.contains(_cicloDiVita)) return false;
    final rotta = ModalRoute.of(context);
    // Senza una rotta il cielo e' montato da solo, come nelle prove e nei
    // fondali dei riti: gira.
    if (rotta == null) return true;
    // **LA VERITA' INTERROGABILE VINCE SUL RICORDO**: se la rotta e' in
    // cima, qualunque cosa sia successo agli eventi, il cielo si vede e deve
    // muoversi. E' questa riga a rendere impossibile il blocco eterno.
    if (rotta.isCurrent) return true;
    // Coperto: si gira solo se cio' che sta sopra e' trasparente, perche'
    // dietro una celebrazione o un foglio dal basso il cielo si vede ancora.
    return _copertoDaTrasparente;
  }

  /// **LO SPECCHIO PER LE PROVE**: dice se il ticker sta davvero girando, che
  /// e' la stessa cosa che decide se i fotogrammi cambiano. Le prove non
  /// devono dedurlo da un bool di stato, che potrebbe mentire.
  @visibleForTesting
  bool get girDavvero => _controller.isAnimating;

  /// Ferma il giro alle spalle dello stato, per provare la sentinella: e'
  /// l'evento perduto riprodotto a mano.
  @visibleForTesting
  void fermaIlGiroPerProva() => _controller.stop();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final rotta = ModalRoute.of(context);
    if (rotta != null) osservatoreDelCielo.subscribe(this, rotta);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState stato) {
    super.didChangeAppLifecycleState(stato);
    if (!mounted || stato == _cicloDiVita) return;
    // **QUI SI RIVALUTA, e non si ricorda niente.** Tornando in primo piano
    // il cielo non "riprende da dove era": si ricalcola se deve girare, e se
    // deve, gira.
    setState(() => _cicloDiVita = stato);
    _accordaIlGiro();
  }

  @override
  void didPushNext() {
    // Si segna soltanto CHE COSA sta sopra, perche' una rotta trasparente
    // lascia vedere il cielo. Il resto lo decide `_deveGirare`.
    final sopra = osservatoreDelCielo.ultimaSpinta;
    final trasparente = sopra is ModalRoute && !sopra.opaque;
    if (!trasparente && !_sospesoNelConto) {
      CosmosBackground.quantiSospesi++;
      _sospesoNelConto = true;
    }
    if (!mounted) return;
    setState(() => _copertoDaTrasparente = trasparente);
    _accordaIlGiro();
  }

  @override
  void didPopNext() {
    if (_sospesoNelConto) {
      CosmosBackground.quantiSospesi--;
      _sospesoNelConto = false;
    }
    if (!mounted) return;
    setState(() => _copertoDaTrasparente = false);
    _accordaIlGiro();
  }

  /// **ACCORDA IL GIRO ALLO STATO, in un punto solo.** Prima questa decisione
  /// viveva sparsa fra `didPushNext`, che fermava, e il `build`, che
  /// riarmava: due punti che potevano non incontrarsi. Qui il ticker segue
  /// cio' che `_deveGirare` dice, e chiunque cambi qualcosa passa di qua.
  void _accordaIlGiro({bool daSentinella = false}) {
    if (!mounted) return;
    final deve = _deveGirare && _movimentoConsentito;
    if (deve && !_controller.isAnimating) {
      if (daSentinella) CosmosBackground.ripartenzeDellaSentinella++;
      _controller.repeat();
    } else if (!deve && _controller.isAnimating) {
      _controller.stop();
    }
  }

  /// Vero se il movimento e' permesso dalle scelte della persona e dalla
  /// qualita': con Riduci Movimento o in qualita' bassa il cosmo sta fermo,
  /// ed e' una decisione vecchia che questa voce non tocca.
  bool _movimentoConsentito = true;

  /// Vero se questo cielo e' entrato nel conto dei sospesi: serve a toglierlo
  /// una volta sola, e a non lasciarlo dentro morendo.
  bool _sospesoNelConto = false;

  /// Il battito della sentinella.
  Timer? _sentinella;

  late final AnimationController _controller;

  /// LE IMMAGINI DEI PIANI STATICI, una per piano di parallasse.
  ///
  /// Vivono nello State e non nel painter, perche' il painter si ricostruisce
  /// a ogni build mentre il cielo dipinto deve sopravvivergli: rifarlo a ogni
  /// build vorrebbe dire non averlo fatto.
  final CieloInCache _cielo = CieloInCache();

  @override
  void initState() {
    super.initState();
    // Un unico ciclo lungo governa pulsazione, respiro e stelle cadenti.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    // **SI ASCOLTA IL CICLO DI VITA DELL'APP, ordine AO voce 07.** Prima
    // questo file non lo nominava affatto, verificato per enumerazione nella
    // premessa P6: andare in background e tornare non diceva niente al
    // cielo, che restava fermo o girava a vuoto.
    WidgetsBinding.instance.addObserver(this);
    // **LA SENTINELLA, e perche' non basta il `build`.** Una rotta coperta da
    // una rotta opaca finisce OFFSTAGE: non si ricostruisce piu', quindi un
    // controllo che vivesse solo dentro il `build` non girerebbe proprio nel
    // caso in cui serve. Questo battito e' lento apposta, due secondi, e fa
    // un confronto fra due booleani: non e' lavoro per fotogramma, e' una
    // mano sul polso. Quando trova il cielo fermo mentre lo stato dice che
    // deve girare, riparte e lo registra.
    _sentinella = Timer.periodic(CosmosBackground.intervalloDellaSentinella, (_) {
      if (!mounted) return;
      if (_deveGirare && _movimentoConsentito && !_controller.isAnimating) {
        _accordaIlGiro(daSentinella: true);
      }
    });
  }

  @override
  void dispose() {
    osservatoreDelCielo.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _sentinella?.cancel();
    if (_sospesoNelConto) CosmosBackground.quantiSospesi--;
    _controller.dispose();
    _cielo.libera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CosmosBackground.quanteRicostruzioni++;
    // Letture tolleranti: il motore e' il fondale di TUTTA l'app e deve
    // reggere anche montato da solo, come promette il backdrop dei riti nei
    // test. Senza provider si degrada con garbo: qualita' media, nessun segno
    // evidenziato, moto di ripiego condiviso.
    final palette = widget.paletteOverride ?? context.palette;
    // **LA PALETTE DEL PITTORE E' QUELLA DI DESTINAZIONE, ordine AM voce
    // 01.** Il painter rasterizza i quattro teli e li tiene in cache con
    // una chiave che porta i colori: seguendo la palette ANIMATA, ogni
    // fotogramma della sfumatura era una chiave nuova e i teli si
    // rifacevano da capo. Misurato sulla 2180: 36 rasterizzazioni a schermo
    // pieno su 40 fotogrammi per un solo cambio di Maestro, contro UNA da
    // freddo. E' la lentezza che Mauro sente tornando in home, dove il
    // Maestro cambia a ogni giro del carosello.
    //
    // Il fondo, l'alone e il velo qui sopra continuano a usare `palette`,
    // che sfuma: la transizione si vede dove costa nulla vederla.
    final paletteDelPittore = widget.paletteOverride ??
        MaestroScope.destinazioneDi(context) ??
        palette;
    final quality = context
            .watch<QualityTierController?>()
            ?.tier ??
        QualityTier.medium;
    // **DA COPERTO NON SI ASCOLTA**: il watch qui sotto ricostruiva questo
    // albero a ogni tick del sensore anche sotto una funzionalita' aperta.
    // Da coperto si legge senza iscriversi, e il giro sta fermo.
    // Da fermo si legge senza iscriversi: il watch ricostruiva questo albero
    // a ogni tick del sensore anche sotto una funzionalita' aperta.
    final fermo = !_deveGirare;
    final parallax = fermo
        ? (context.read<ParallaxController?>() ?? _parallasseDiRipiego())
        : (context.watch<ParallaxController?>() ?? _parallasseDiRipiego());
    final sunSign = context.watch<ZodiacController?>()?.sunSign;
    // Riduci Movimento: cosmo fermo, niente stella cadente, parallasse minima.
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    // **QUI VIVE LA SENTINELLA, ordine AO voce 07.** Il `build` non decide
    // piu' da solo se il giro va armato: aggiorna cio' che sa sulle scelte
    // della persona e poi chiama l'unico punto che accorda il ticker allo
    // stato. Se il giro risulta fermo mentre lo stato dice che deve girare,
    // e succede quando un evento del RouteObserver si perde per strada, qui
    // riparte e la ripartenza si CONTA: un guasto che non lascia traccia e'
    // un guasto che nessuno potra' spiegare.
    _movimentoConsentito = quality != QualityTier.low && !reduceMotion;
    final eraFermoMaDoveva = _deveGirare &&
        _movimentoConsentito &&
        !_controller.isAnimating;
    _accordaIlGiro(daSentinella: eraFermoMaDoveva);

    return Stack(
      // IL COSMO RIEMPIE SEMPRE L'ALTEZZA. Senza questo, lo Stack prendeva
      // l'altezza del contenuto: se il contenuto era piu' corto dello schermo,
      // il cielo finiva dove finiva lui e sotto restava il nero dello Scaffold.
      // Si vedeva nel Test Archetipo quando compariva l'avviso "Aggiunta alle
      // tue arti": il contenuto si accorciava e si apriva una fascia nera alta
      // quasi un terzo dello schermo. L'avviso non c'entrava, era solo
      // l'occasione che rivelava un fondo corto, e ogni schermata sta sul cosmo
      // condiviso, per intero.
      fit: StackFit.expand,
      children: [
        // Cielo di fondo, tinto verso l'accento del Maestro.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  palette.deepest,
                  Color.lerp(
                      palette.deepest, palette.backgroundGradient[1], 0.6)!,
                  palette.deepest,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),
        // Piani cosmici animati.
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _CosmosPainter(
                cielo: _cielo,
                densita: MediaQuery.devicePixelRatioOf(context),
                seed: widget.seed,
                animation: _controller,
                parallax: parallax,
                palette: paletteDelPittore,
                tier: quality,
                highlighted: sunSign,
                showZodiac: widget.showZodiac,
                reduceMotion: reduceMotion,
                keepOut: widget.starKeepOut,
                showPlanets: widget.showPlanets,
              ),
            ),
          ),
        ),
        // Alone del Maestro in alto.
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.9),
                  radius: 1.15,
                  colors: [
                    palette.glow.withValues(
                        alpha: quality == QualityTier.high ? 0.26 : 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        // Vignettatura: scurisce i bordi per incorniciare la scena e spingere
        // indietro il fondo. Sta sotto il primo piano, cosi' le carte al centro
        // non perdono leggibilita'.
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.1,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    palette.deepest.withValues(alpha: 0.55),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
        ),
        // Il contenuto. Il listener sotto alimenta la parallasse di
        // scorrimento per OGNI schermata che monta il cosmo: lo sfondo scorre
        // rispetto al contenuto, non solo col sensore, senza che ogni lista
        // debba ricordarsi di collegare il proprio controller.
        NotificationListener<ScrollUpdateNotification>(
          onNotification: (n) {
            if (n.metrics.axis == Axis.vertical) {
              parallax.updateScroll(n.metrics.pixels);
            }
            return false;
          },
          child: widget.child,
        ),
      ],
    );
  }
}

/// Le tinte fredde delle nebulose del cosmo, esposte come fonte di verita' unica
/// e per i test: un indaco-viola luminoso col nucleo piu' chiaro, scelto apposta
/// per staccare dall'accento di qualsiasi Maestro invece di confondersi con esso.
class CosmosNebula {
  const CosmosNebula._();

  /// Nucleo chiaro della nebulosa.
  static const Color core = Color(0xFFB9B0FF);

  /// Corpo indaco-viola.
  static const Color mid = Color(0xFF6E5FE0);

  /// Tono freddo secondario.
  static const Color cool = Color(0xFF4B6BE0);
}

class _Star {
  const _Star(this.x, this.y, this.radius, this.phase, this.baseAlpha);
  final double x; // 0..1
  final double y; // 0..1
  final double radius;
  final double phase;
  final double baseAlpha;
}

/// LE QUATTRO PROFONDITA' DEI PIANI, in un punto solo.
///
/// Erano quattro numeri scritti dentro `paint`, e adesso che i piani sono
/// immagini in cache diventano il patto fra cio' che si dipinge e cio' che si
/// muove: se l'immagine di un piano venisse composta con l'offset di un
/// altro, la profondita' si appiattirebbe senza che nessun pixel gridasse.
/// Vivono qui perche' una prova possa leggerli e verificarli.
/// **QUANTI ELEMENTI SU UN TELO CON LA SCORTA, ordine AM voce 02.**
///
/// Le scorte di AJ.02 hanno allargato i teli perche' il bordo non entrasse
/// piu' nell'inquadratura, e il conto degli elementi e' rimasto quello di
/// prima: dipingere le stesse stelle su un telo piu' grande vuol dire
/// diluirle, e a schermo se ne vedono meno. Misurato su 360x797: del piano
/// di fondo restava a schermo il 51 per cento delle stelle, del piano
/// medio il 37 per cento delle nebulose. E' il livello che Mauro vede
/// mancare sulla 2180.
///
/// Qui il conto segue l'AREA: la densita' a schermo torna quella di prima
/// delle scorte, e i bordi restano coperti perche' il telo non si tocca.
/// Costa piu' elementi da dipingere UNA volta nella cache, mai nel cammino
/// per fotogramma.
int quantiSulTelo(int base, Size telo, Size schermo) {
  final areaSchermo = schermo.width * schermo.height;
  if (areaSchermo <= 0) return base;
  final rapporto = (telo.width * telo.height) / areaSchermo;
  return (base * rapporto).round();
}

class ProfonditaDeiPiani {
  const ProfonditaDeiPiani._();

  /// Il piano piu' lontano, la polvere: si muove pochissimo. In composizione
  /// il suo offset vale la META', come nel disegno di prima.
  static const double polvere = 0.06;

  /// Le stelle di campo, le costellazioni e gli aloni delle protagoniste.
  static const double fondo = 0.16;

  /// Nebulose e pianeti.
  static const double medio = 0.5;

  /// Le particelle vicine: il piano piu' reattivo.
  static const double vicino = 1.3;
}

/// Gli offset dei quattro piani per una data parallasse: la stessa
/// matematica di prima, esposta perche' si possa misurare.
class OffsetDeiPiani {
  const OffsetDeiPiani({
    required this.polvere,
    required this.fondo,
    required this.medio,
    required this.vicino,
  });

  final Offset polvere;
  final Offset fondo;
  final Offset medio;
  final Offset vicino;

  /// Calcola i quattro offset. [conDeriva] e [t] riproducono la deriva lenta
  /// che tiene vivo il cosmo quando il giroscopio non contribuisce.
  static OffsetDeiPiani da(
    ParallaxController parallax, {
    required bool conDeriva,
    required double t,
  }) {
    Offset off(double depth) {
      final base = parallax.layerOffset(depth);
      // LA DERIVA NON SI SPEGNE PIU' COL SENSORE ATTIVO, ordine M voce 1a.
      // Su un telefono vero il sensore contribuisce sempre, quindi la
      // condizione vecchia (deriva solo senza sensore) spegneva il respiro
      // del cielo proprio dove l'app vive: col telefono posato sul tavolo
      // il cosmo restava immobile. Adesso la deriva c'e' sempre; quando il
      // sensore contribuisce va a meta' ampiezza, cosi' l'inclinazione
      // resta la protagonista e il respiro non sparisce.
      if (conDeriva) {
        final deriva = parallax.autoDrift(depth, t);
        return base + (parallax.sensorActive ? deriva * 0.5 : deriva);
      }
      return base;
    }

    return OffsetDeiPiani(
      // La polvere si muove della META' del suo offset: era scritto nella
      // riga di composizione del disegno di prima, e resta qui.
      polvere: off(ProfonditaDeiPiani.polvere) * 0.5,
      fondo: off(ProfonditaDeiPiani.fondo),
      medio: off(ProfonditaDeiPiani.medio),
      vicino: off(ProfonditaDeiPiani.vicino),
    );
  }
}

/// IL CIELO SI DIPINGE UNA VOLTA.
///
/// **Il fatto misurato che ha fatto nascere questa classe.** Su iOS l'app
/// veniva UCCISA dal sistema a ogni transizione di rotta, senza crash e senza
/// rapporto: Crashlytics vivo e muto, verificato sul campo con la build
/// diagnostica 2160, briciole alla mano. Il colpevole era qui: il pittore del
/// cosmo ridipingeva a ogni fotogramma, in eterno, quindici macchie di
/// nebulosa con `MaskFilter.blur(24)` piu' shader, gli aloni delle stelle,
/// i pianeti, le particelle vicine, e rigenerava da zero la lista delle
/// stelle. Su iOS ogni sfocatura e' un passaggio di rendering con texture
/// intermedie, e durante una transizione i cosmi vivi sono DUE: la memoria
/// grafica esplodeva e iOS tagliava. La home da sola reggeva, ogni
/// transizione uccideva, in background sopravviveva: tutto combacia.
///
/// **La cura, ordine del cielo dipinto una volta.** Gli strati statici si
/// dipingono UNA volta con lo STESSO identico codice di disegno, dentro
/// immagini in cache, una per piano di parallasse: cosi' ogni piano continua
/// a muoversi alla sua velocita' e la profondita' resta intatta. A ogni
/// fotogramma si compongono le immagini con gli offset. La cache si rifa'
/// solo quando cambia la chiave (seme, palette, tier, misure, keepOut,
/// costellazioni, pianeti, segno evidenziato, densita' dei pixel).
///
/// Le immagini si generano col cosmo A RIPOSO, cioe' come gia' si vede oggi
/// con Riduci Movimento: non e' una resa nuova, e' una resa che l'app
/// mostrava gia'.
class CieloInCache {
  ui.Image? lontano;
  ui.Image? fondo;
  ui.Image? medio;
  ui.Image? vicino;

  /// Gli sprite degli elementi vivi, disegnati una volta e riusati: senza di
  /// loro l'alone della stella e la scia della cadente tornerebbero a creare
  /// una sfocatura e uno shader a ogni fotogramma.
  ui.Image? sciaDellaCadente;

  String? _chiave;

  /// Quanti byte occupano le immagini vive adesso: quattro canali per pixel.
  /// Serve al rapporto e alle prove, e si legge, non si stima.
  int get byteOccupati {
    var totale = 0;
    for (final img in [
      lontano,
      fondo,
      medio,
      vicino,
      sciaDellaCadente,
    ]) {
      if (img != null) totale += img.width * img.height * 4;
    }
    return totale;
  }

  /// Vero quando la cache descrive gia' questa chiave.
  bool valePer(String chiave) => _chiave == chiave;

  /// I piani si liberano prima di rifarli: senza questo ogni cambio di
  /// schermata lascerebbe dietro di se' una decina di megabyte.
  void liberaPiani() {
    lontano?.dispose();
    fondo?.dispose();
    medio?.dispose();
    vicino?.dispose();
    lontano = null;
    fondo = null;
    medio = null;
    vicino = null;
  }

  /// La cache adesso descrive questa chiave.
  void dichiara(String chiave) => _chiave = chiave;

  void libera() {
    liberaPiani();
    sciaDellaCadente?.dispose();
    sciaDellaCadente = null;
    _chiave = null;
  }
}

/// Le misure degli sprite riusati, dichiarate dove si leggono.
///
/// La scia della stella cadente: la stessa diagonale di prima, novanta punti
/// per quarantacinque.
const double lunghezzaDellaScia = 90;
const double altezzaDellaScia = 45;

class _CosmosPainter extends CustomPainter {
  _CosmosPainter({
    required this.cielo,
    required this.densita,
    required this.seed,
    required this.animation,
    required this.parallax,
    required this.palette,
    required this.tier,
    required this.highlighted,
    required this.showZodiac,
    required this.reduceMotion,
    required this.keepOut,
    required this.showPlanets,
  }) : super(repaint: Listenable.merge([animation, parallax]));

  /// Le immagini dei piani statici, tenute dallo State.
  final CieloInCache cielo;

  /// Il seme della schermata, mescolato in ogni generatore: cieli diversi
  /// dallo stesso motore.
  final int seed;

  final Animation<double> animation;
  final ParallaxController parallax;
  final MaestroPalette palette;
  final QualityTier tier;
  final Zodiac? highlighted;
  final bool showZodiac;
  final bool showPlanets;
  final bool reduceMotion;

  /// Zona franca normalizzata dove non nascono stelle ne' particelle.
  final Rect? keepOut;

  /// Quanti pixel veri per punto logico: le immagini in cache si dipingono a
  /// questa densita', altrimenti il cielo uscirebbe sgranato rispetto a
  /// prima. Arriva dal widget, che e' l'unico a conoscere il MediaQuery.
  final double densita;

  int get _fieldStars => QualityTierController.fieldStarsFor(tier);
  int get _dustStars => switch (tier) {
        QualityTier.high => 90,
        QualityTier.medium => 40,
        QualityTier.low => 0,
      };
  int get _heroStars => switch (tier) {
        QualityTier.high => 7,
        QualityTier.medium => 4,
        QualityTier.low => 2,
      };
  int get _planetCount => switch (tier) {
        QualityTier.high => 2,
        QualityTier.medium => 1,
        QualityTier.low => 0,
      };
  int get _nearCount => switch (tier) {
        QualityTier.high => 14,
        QualityTier.medium => 7,
        QualityTier.low => 0,
      };
  int get _nebulaClusters => switch (tier) {
        QualityTier.high => 3,
        QualityTier.medium => 2,
        QualityTier.low => 1,
      };
  bool get _shootingStars => tier != QualityTier.low && !reduceMotion;

  /// **VERO SOLO MENTRE SI DIPINGE LA CACHE.** Gli strati statici si
  /// generano col cosmo a riposo, e a riposo lo mettono i metodi stessi
  /// guardando questo interruttore: nessuna copia del codice di disegno,
  /// nessun ramo nuovo dentro i metodi.
  bool _stoDipingendoLaCache = false;

  bool get _animate =>
      tier != QualityTier.low && !reduceMotion && !_stoDipingendoLaCache;

  /// La chiave della cache: tutto cio' che cambia il cielo dipinto.
  ///
  /// Il tempo NON c'e' dentro, ed e' il punto: il cielo statico non dipende
  /// dall'istante. Il moto vive negli offset con cui le immagini vengono
  /// composte e nei pochi elementi disegnati dal vivo.
  String _chiaveDelCielo(Size size, double densita) =>
      '$seed|${palette.deepest.toARGB32()}-${palette.gold.toARGB32()}-'
      '${palette.goldSoft.toARGB32()}-${palette.primary.toARGB32()}-'
      '${palette.glow.toARGB32()}|$tier|$showZodiac|$showPlanets|'
      '${highlighted?.id}|$keepOut|$reduceMotion|'
      '${size.width.toStringAsFixed(1)}x${size.height.toStringAsFixed(1)}'
      '@$densita';

  /// **LA SCORTA DI UN PIANO, ordine AJ voce 02.** I piani erano grandi
  /// esattamente quanto lo schermo e la parallasse li sposta fino alla sua
  /// ampiezza massima: il bordo entrava nell'inquadratura, ed e' la LINEA
  /// che Mauro vede ai lati inclinando il telefono. La scorta e' l'ampiezza
  /// massima di QUEL piano (tilt saturo per la sua profondita' efficace,
  /// piu' la corsa del dito sullo scorrimento) piu' un pixel: cosi' il bordo
  /// non entra mai, a qualunque inclinazione. La matematica e' la stessa di
  /// `ParallaxController.layerOffset`, non una copia.
  static double scortaDi(double depth, {double fattore = 1}) =>
      ParallaxController.tiltRangeDefault *
          ParallaxController.profonditaEfficace(depth) *
          fattore +
      3 * 40 * depth +
      1;

  /// Vero se il punto normalizzato del PIANO cade nella zona franca del
  /// titolo, che e' dichiarata in coordinate dello SCHERMO: con la scorta i
  /// due riquadri non coincidono piu' e la conversione sta qui, in un posto
  /// solo. Con scorta zero e' l'identita' di prima.
  bool _nellaZonaFranca(double x, double y, Size size, double margine) {
    if (keepOut == null) return false;
    if (margine == 0) return keepOut!.contains(Offset(x, y));
    final w = size.width - 2 * margine;
    final h = size.height - 2 * margine;
    return keepOut!.contains(Offset(
        (x * size.width - margine) / w, (y * size.height - margine) / h));
  }

  /// Dipinge una volta cio' che gli si chiede, dentro un'immagine grande
  /// quanto lo schermo piu' la scorta, in PIXEL VERI: alla densita' che gli
  /// si chiede, cosi' il cielo non perde un filo di nitidezza rispetto a
  /// prima (le nebulose, gia' sfumate, viaggiano a mezza densita').
  ui.Image _dipingiUnaVolta(
      Size size, double densita, void Function(Canvas) disegna) {
    final registratore = ui.PictureRecorder();
    final tela = Canvas(registratore);
    tela.scale(densita);
    disegna(tela);
    final quadro = registratore.endRecording();
    final img = quadro.toImageSync(
      (size.width * densita).ceil(),
      (size.height * densita).ceil(),
    );
    quadro.dispose();
    return img;
  }

  /// Rifa' i quattro piani e i due sprite. Si chiama solo quando la chiave
  /// cambia, cioe' quasi mai.
  /// Le scorte dei tre piani in cache, dalle loro profondita' vere. La
  /// polvere si compone a meta' offset, e la sua scorta lo sa.
  static final double margineLontano =
      scortaDi(ProfonditaDeiPiani.polvere, fattore: 0.5);
  static final double margineFondo = scortaDi(ProfonditaDeiPiani.fondo);
  static final double margineMedio = scortaDi(ProfonditaDeiPiani.medio);

  void _rigeneraIlCielo(Size size, double densita, String chiave) {
    CosmosBackground.quanteRigenerazioni++;
    cielo.liberaPiani();
    _stoDipingendoLaCache = true;
    const fermo = Offset.zero;
    // Le tele coi margini di scorta: i pittori riempiono anche la scorta,
    // perche' un margine vuoto sarebbe la stessa linea spostata piu' in la'.
    final teloLontano = Size(size.width + 2 * margineLontano,
        size.height + 2 * margineLontano);
    final teloFondo =
        Size(size.width + 2 * margineFondo, size.height + 2 * margineFondo);
    final teloMedio =
        Size(size.width + 2 * margineMedio, size.height + 2 * margineMedio);

    // PIANO MEDIO: nebulose e pianeti. I pianeti stavano sopra le stelle di
    // fondo e adesso stanno sotto: sono due dischi di dieci e sette punti di
    // raggio su un piano che si muove diversamente, e nelle scene guardate
    // non ci cade sopra nessuna stella. E' l'unico scambio d'ordine di
    // sovrapposizione, e sta scritto qui invece che essere scoperto domani.
    final vuotoIlMedio =
        _nebulaClusters == 0 && (!showPlanets || _planetCount == 0);
    // A MEZZA DENSITA', ed e' un risparmio dichiarato: le nebulose sono
    // sfumate per natura e l'ingrandimento non si vede; coi margini della
    // scorta il piano medio costa cosi' MENO pixel di prima.
    cielo.medio = vuotoIlMedio
        ? null
        : _dipingiUnaVolta(teloMedio, densita / 2, (tela) {
            if (_nebulaClusters > 0) {
              _paintNebula(tela, teloMedio, fermo, 0, margine: margineMedio);
            }
            if (showPlanets && _planetCount > 0) {
              _paintPlanets(tela, teloMedio, fermo, margine: margineMedio);
            }
          });

    // PIANO PIU' LONTANO: la polvere. In qualita' bassa non c'e' nessuna
    // polvere, e un'immagine vuota costerebbe i suoi megabyte per non
    // mostrare niente: il piano non nasce affatto.
    cielo.lontano = _dustStars == 0
        ? null
        : _dipingiUnaVolta(teloLontano, densita, (tela) {
            _paintStarDust(tela, teloLontano, fermo, 0,
                quante: quantiSulTelo(
                    _dustStars, teloLontano, size));
          });

    // PIANO DI FONDO: le stelle di campo, le costellazioni e GLI ALONI delle
    // stelle protagoniste, che condividono lo stesso offset.
    //
    // **L'alone sta qui e non nel cammino per fotogramma, e la ragione e' una
    // misura.** Il primo tentativo lo disegnava dal vivo da uno sprite
    // riusato: ma una sfocatura scalata non e' la stessa sfocatura, il raggio
    // dell'alone cambia col raggio della stella e lo sprite arrivava a video
    // con un terzo del velo che aveva prima. Il confronto prima e dopo lo ha
    // denunciato subito, con gli aloni come punti piu' diversi di tutta la
    // scena. Adesso l'alone e' dipinto una volta col codice di sempre, e dal
    // vivo restano la croce e il nucleo, che sono linee e un cerchio pieno.
    // L'alone non pulsa piu': vive al ventidue per cento di opacita', e la
    // pulsazione la porta il nucleo che gli sta sopra.
    cielo.fondo = _dipingiUnaVolta(teloFondo, densita, (tela) {
      _paintFieldStars(tela, teloFondo, fermo, 0,
          quante: quantiSulTelo(
              _fieldStars, teloFondo, size));
      if (showZodiac) _paintZodiac(tela, teloFondo, fermo, 0);
      _aloniDelleProtagoniste(tela, teloFondo, fermo);
    });

    // **IL PIANO VICINO NON HA PIU' UNA CACHE, ordine AJ voce 02.** E' il
    // piano piu' reattivo (fino a 165 punti di corsa) e la sua scorta
    // sarebbe costata decine di megabyte; ma il suo contenuto sono al
    // massimo QUATTORDICI cerchi semplici, quindi si disegna dal vivo nel
    // cammino per fotogramma, dove costa niente, non crea nessun filtro e
    // riprende pure la deriva verticale che la cache congelava.
    cielo.vicino = null;

    // LO SPRITE DELLA SCIA: lo stesso gradiente di prima, disegnato una
    // volta. In composizione si modula col colore e con l'alpha del momento.
    cielo.sciaDellaCadente ??= _dipingiUnaVolta(
        const Size(lunghezzaDellaScia, altezzaDellaScia), densita, (tela) {
      tela.drawLine(
        Offset.zero,
        const Offset(lunghezzaDellaScia, altezzaDellaScia),
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0x00FFFFFF), Color(0xFFFFFFFF)],
          ).createShader(const Rect.fromLTWH(
              0, 0, lunghezzaDellaScia, altezzaDellaScia))
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    });

    _stoDipingendoLaCache = false;
    cielo.dichiara(chiave);
  }

  /// Compone un piano con il suo offset di parallasse.
  ///
  /// **L'offset si posa su pixel VERI, e non e' un dettaglio.** Un'immagine
  /// disegnata a mezzo pixel viene ricampionata, e su un cielo fatto di
  /// stelle larghe un pixel il ricampionamento si vede: nel confronto prima
  /// e dopo compariva un velo di differenze su tutta la scena, anche dove
  /// nulla era cambiato. Arrotondando alla griglia dei pixel del
  /// dispositivo, il piano si disegna uno a uno e i pixel tornano identici.
  Offset _sullaGriglia(Offset off) => Offset(
        (off.dx * densita).roundToDouble() / densita,
        (off.dy * densita).roundToDouble() / densita,
      );

  void _componi(Canvas canvas, ui.Image? piano, Offset grezzo, Size size,
      {double margine = 0}) {
    if (piano == null) return;
    final off = _sullaGriglia(grezzo);
    canvas.drawImageRect(
      piano,
      Rect.fromLTWH(0, 0, piano.width.toDouble(), piano.height.toDouble()),
      Rect.fromLTWH(off.dx - margine, off.dy - margine,
          size.width + 2 * margine, size.height + 2 * margine),
      Paint()..filterQuality = FilterQuality.low,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final chiave = _chiaveDelCielo(size, densita);
    if (!cielo.valePer(chiave)) _rigeneraIlCielo(size, densita, chiave);

    final t = _animate ? animation.value : 0.0;

    // Gli offset dei quattro piani vengono da UNA porta, `OffsetDeiPiani`:
    // il lontano quasi fermo, il vicino molto reattivo, cosi' il movimento
    // si sente come profondita' reale. La matematica e' quella di sempre.
    final piani = OffsetDeiPiani.da(parallax, conDeriva: _animate, t: t);
    final farOff = piani.fondo;

    // **IL CAMMINO PER FOTOGRAMMA: solo composizioni e disegni leggeri.**
    // Qui dentro non si crea nessun MaskFilter, nessuno shader e nessuna
    // lista: e' la regola dell'ordine, e una prova la legge sul sorgente.
    _componi(canvas, cielo.medio, piani.medio, size, margine: margineMedio);
    _componi(canvas, cielo.lontano, piani.polvere, size,
        margine: margineLontano);
    _componi(canvas, cielo.fondo, piani.fondo, size, margine: margineFondo);
    if (_nearCount > 0) {
      _paintNearParticles(canvas, size, piani.vicino, t);
    }
    // **Scintillio e respiro sono la meta' viva delle stelle in cache**: si
    // scalano sul TELO del fondo e si spostano della sua scorta, cosi' i
    // due pezzi della stessa stella continuano a cadere nello stesso punto.
    final teloFondo =
        Size(size.width + 2 * margineFondo, size.height + 2 * margineFondo);
    final offFondo = farOff - Offset(margineFondo, margineFondo);
    _scintillio(canvas, teloFondo, offFondo, t);
    if (_animate) _respiroDelCampo(canvas, teloFondo, offFondo, t);
    if (_shootingStars) _paintShootingStars(canvas, size, farOff, t);
  }

  /// Quante stelle di campo respirano per fotogramma, oltre le protagoniste.
  int get _stelleCheRespirano => switch (tier) {
        QualityTier.high => 26,
        QualityTier.medium => 14,
        QualityTier.low => 0,
      };

  /// IL RESPIRO DEL CAMPO, ordine M voce 1a. La cache dell'8 agosto aveva
  /// congelato il brulichio di TUTTE le stelle dentro le immagini statiche:
  /// sul telefono, col sensore attivo che spegneva anche la deriva, il cielo
  /// a riposo era immobile. Qui una quota delle stesse stelle del campo,
  /// STESSO seme e stesso ordine di estrazione del disegno in cache, torna a
  /// battere per fotogramma: cerchi semplici senza sfocature, quindi il
  /// prezzo che ha motivato la cache non torna.
  void _respiroDelCampo(Canvas canvas, Size size, Offset off, double t) {
    final rng = math.Random(7 + seed * 7919);
    final quante = math.min(_stelleCheRespirano, _fieldStars);
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < quante; i++) {
      // Lo stesso ordine di estrazione di _paintFieldStars: rr, x, y, fase,
      // alfa. Cambiare la' vuol dire cambiare qui, e la prova del moto cade.
      final rr = rng.nextDouble();
      final x = rng.nextDouble();
      final y = rng.nextDouble();
      final radius = 0.4 + rr * rr * 2.6;
      final phase = rng.nextDouble();
      final baseAlpha = 0.28 + rng.nextDouble() * 0.62;
      if (_nellaZonaFranca(x, y, size, margineFondo)) continue;
      final battito = 0.5 + 0.5 * math.sin(2 * math.pi * (t * 3 + phase * 7));
      final center = Offset(x * size.width, y * size.height) + off;
      paint.color = const Color(0xFFFFFFFF)
          .withValues(alpha: (baseAlpha * 0.85 * battito).clamp(0.0, 1.0));
      canvas.drawCircle(center, radius * (0.9 + 0.5 * battito), paint);
    }
  }

  /// GLI ALONI DELLE PROTAGONISTE, dipinti una volta dentro il piano di
  /// fondo. Il giro e i numeri sono gli stessi dello scintillio, cosi' i due
  /// pezzi della stessa stella cadono nello stesso punto.
  void _aloniDelleProtagoniste(Canvas canvas, Size size, Offset off) {
    final rng = math.Random(313 + seed * 7919);
    for (var i = 0; i < _heroStars; i++) {
      final x = rng.nextDouble();
      final y = rng.nextDouble() * 0.7;
      if (_nellaZonaFranca(x, y, size, margineFondo)) continue;
      final center = Offset(x * size.width, y * size.height) + off;
      final baseR = 1.6 + rng.nextDouble() * 1.4;
      // Il valore a riposo del battito, lo stesso che il cosmo mostra oggi
      // con Riduci Movimento: 0,85 di battito, cioe' 0,94 di intensita'.
      final tw = _animate
          ? 0.5 + 0.5 * math.sin(2 * math.pi * (0 * 3 + rng.nextDouble()))
          : 0.85;
      final a = (0.6 + 0.4 * tw).clamp(0.0, 1.0);
      canvas.drawCircle(
        center,
        baseR * 4.5,
        Paint()
          ..color = palette.goldSoft.withValues(alpha: 0.22 * a)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  /// LO SCINTILLIO, l'unica cosa viva fra le stelle: poche protagoniste, il
  /// nucleo e la croce disegnati a colpi semplici, e l'alone preso dallo
  /// sprite invece di essere sfocato ogni volta.
  void _scintillio(Canvas canvas, Size size, Offset off, double t) {
    final rng = math.Random(313 + seed * 7919);
    for (var i = 0; i < _heroStars; i++) {
      final x = rng.nextDouble();
      final y = rng.nextDouble() * 0.7; // in alto, dove il cielo respira
      if (_nellaZonaFranca(x, y, size, margineFondo)) continue;
      final center = Offset(x * size.width, y * size.height) + off;
      final baseR = 1.6 + rng.nextDouble() * 1.4;
      final tw = _animate
          ? 0.5 + 0.5 * math.sin(2 * math.pi * (t * 3 + rng.nextDouble()))
          : 0.85;
      final a = (0.6 + 0.4 * tw).clamp(0.0, 1.0);

      // Scintillio a croce.
      final spike = baseR * (5 + 3 * tw);
      final crossPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.5 * a)
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
          center - Offset(spike, 0), center + Offset(spike, 0), crossPaint);
      canvas.drawLine(
          center - Offset(0, spike), center + Offset(0, spike), crossPaint);
      // Nucleo bianco brillante.
      canvas.drawCircle(
          center, baseR, Paint()..color = Colors.white.withValues(alpha: a));
    }
  }

  // --- Polvere stellare fine sul piano piu' lontano ---

  void _paintStarDust(Canvas canvas, Size size, Offset off, double t,
      {int? quante}) {
    final rng = math.Random(91 + seed * 7919);
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < (quante ?? _dustStars); i++) {
      final x = rng.nextDouble();
      final y = rng.nextDouble();
      if (_nellaZonaFranca(x, y, size, margineLontano)) continue;
      final twinkle = _animate
          ? 0.4 + 0.6 * math.sin(2 * math.pi * (t * 4 + rng.nextDouble()))
          : 0.6;
      final alpha = (0.05 + 0.13 * twinkle).clamp(0.0, 1.0);
      paint.color = const Color(0xFFEAF0FF).withValues(alpha: alpha);
      // Polvere lontana: deriva ridotta, si muove pochissimo.
      canvas.drawCircle(
          Offset(x * size.width, y * size.height) + off * 0.5,
          0.3 + rng.nextDouble() * 0.5,
          paint);
    }
  }

  // --- Stelle protagoniste: vivono in `_scintillio`, il solo strato
  // animato che resta. Il loro disegno non e' stato copiato: e' lo stesso,
  // spostato la' dove si esegue a ogni fotogramma, con l'alone preso dallo
  // sprite invece che sfocato ogni volta.

  // --- Pianeti soffusi, dischi tenui con luce radente, per dare scala ---

  void _paintPlanets(Canvas canvas, Size size, Offset off,
      {double margine = 0}) {
    const spots = [
      (Offset(0.16, 0.2), 10.0),
      (Offset(0.82, 0.3), 7.0),
    ];
    // Stessa mappatura delle nebulose, e per la stessa ragione.
    final visibile =
        Size(size.width - 2 * margine, size.height - 2 * margine);
    for (var i = 0; i < _planetCount && i < spots.length; i++) {
      final (pos, r) = spots[i];
      final center = Offset(margine + pos.dx * visibile.width,
              margine + pos.dy * visibile.height) +
          off;
      // Alone.
      canvas.drawCircle(
        center,
        r * 2.4,
        Paint()
          ..color = (i.isEven ? CosmosNebula.cool : palette.glow)
              .withValues(alpha: 0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      // Disco con luce radente: chiaro su un lato, in ombra sull'altro.
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.5, -0.5),
            radius: 1.1,
            colors: [
              Colors.white.withValues(alpha: 0.5),
              (i.isEven ? CosmosNebula.mid : palette.primary)
                  .withValues(alpha: 0.35),
              palette.deepest.withValues(alpha: 0.5),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: r)),
      );
    }
  }

  // --- Stelle di fondo, pulsazione dolce ---

  void _paintFieldStars(Canvas canvas, Size size, Offset off, double t,
      {int? quante}) {
    final rng = math.Random(7 + seed * 7919);
    final stars = List<_Star>.generate(quante ?? _fieldStars, (_) {
      // Intervallo di dimensioni piu' ampio: da minute a decise, per profondita'.
      final rr = rng.nextDouble();
      return _Star(
        rng.nextDouble(),
        rng.nextDouble(),
        0.4 + rr * rr * 2.6,
        rng.nextDouble(),
        0.28 + rng.nextDouble() * 0.62,
      );
    });
    final paint = Paint()..style = PaintingStyle.fill;
    for (final s in stars) {
      // Zona franca: nessuna stella sul testo del titolo in alto.
      if (_nellaZonaFranca(s.x, s.y, size, margineFondo)) continue;
      final twinkle = _animate
          ? 0.5 + 0.5 * math.sin(2 * math.pi * (t * 6 + s.phase))
          : 0.8;
      final alpha = (s.baseAlpha * (0.55 + 0.45 * twinkle)).clamp(0.0, 1.0);
      final center = Offset(s.x * size.width, s.y * size.height) + off;
      // Alone tenue sulle stelle piu' grandi, cosi' spiccano di piu'.
      if (s.radius > 1.4) {
        canvas.drawCircle(
          center,
          s.radius * 2.6,
          Paint()
            ..color = const Color(0xFFFFFFFF).withValues(alpha: alpha * 0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
      paint.color = const Color(0xFFFFFFFF).withValues(alpha: alpha);
      canvas.drawCircle(center, s.radius, paint);
    }
  }

  // --- Le dodici costellazioni zodiacali ---

  void _paintZodiac(Canvas canvas, Size size, Offset off, double t) {
    // La disposizione viene dal seme della schermata: senza questo l'asterismo
    // restava l'unico strato immobile del cosmo, e l'occhio riconosceva lo
    // stesso Ariete nello stesso angolo su ogni fondale.
    final figure = ZodiacLayout.perSeed(seed);
    for (var i = 0; i < figure.length; i++) {
      final c = figure[i];
      final bool isHi = c.sign == highlighted;

      final breath =
          0.5 + 0.5 * math.sin(2 * math.pi * (t + i * 0.11));

      // Mappa i punti locali nello schermo.
      final center =
          Offset(c.anchor.dx * size.width, c.anchor.dy * size.height) + off;
      final fig = size.width * c.scale;
      final pts = [
        for (final p in c.points)
          center + Offset((p.dx - 0.5) * fig, (p.dy - 0.5) * fig),
      ];

      final double lineAlpha =
          isHi ? 0.6 + 0.3 * breath : 0.10 + 0.10 * breath;
      final double dotAlpha =
          isHi ? 0.8 + 0.2 * breath : 0.32 + 0.22 * breath;
      final Color lineColor =
          isHi ? palette.goldSoft : palette.gold;

      // Alone dorato sotto la costellazione evidenziata.
      if (isHi && tier != QualityTier.low) {
        final glow = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0
          ..strokeCap = StrokeCap.round
          ..color = palette.goldSoft.withValues(alpha: 0.38 * (0.6 + 0.4 * breath))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
        for (final (a, b) in c.edges) {
          canvas.drawLine(pts[a], pts[b], glow);
        }
      }

      // Linee dell'asterismo.
      final linePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isHi ? 1.3 : 0.8
        ..strokeCap = StrokeCap.round
        ..color = lineColor.withValues(alpha: lineAlpha);
      for (final (a, b) in c.edges) {
        canvas.drawLine(pts[a], pts[b], linePaint);
      }

      // Stelle ai vertici.
      final dotPaint = Paint()
        ..color = palette.goldSoft.withValues(alpha: dotAlpha);
      final double r = isHi ? 2.0 : 1.3;
      for (final p in pts) {
        canvas.drawCircle(p, r, dotPaint);
      }
    }
  }

  // --- Nebulose soffuse e pittoriche, piano intermedio ---

  void _paintNebula(Canvas canvas, Size size, Offset off, double t,
      {double margine = 0}) {
    const centers = [
      Offset(0.22, 0.22),
      Offset(0.80, 0.46),
      Offset(0.52, 0.74),
    ];
    final drift = _animate ? math.sin(2 * math.pi * t) * 12 : 0.0;
    final rng = math.Random(53 + seed * 7919);

    // **I CENTRI STANNO NELL'AREA VISIBILE, ordine AM voce 02.** Le tre
    // posizioni sono curate a mano su coordinate normalizzate, e con la
    // scorta di AJ.02 il telo e' 2,73 volte lo schermo: distribuite su tutto
    // il telo, a video ne restava circa una. Qui la coordinata normalizzata
    // mappa la finestra visibile, e le tre nebulose tornano dov'erano.
    final visibile =
        Size(size.width - 2 * margine, size.height - 2 * margine);
    for (var i = 0; i < _nebulaClusters && i < centers.length; i++) {
      final base = Offset(margine + centers[i].dx * visibile.width,
              margine + centers[i].dy * visibile.height) +
          off +
          Offset(drift, -drift);
      // Ogni nebulosa e' un grappolo di macchie morbide sovrapposte con un
      // nucleo piu' chiaro: nubi di luce fredda che staccano dall'accento del
      // dominio, non aloni impercettibili tinti come il fondo.
      const blobs = 5;
      for (var b = 0; b < blobs; b++) {
        final dx = (rng.nextDouble() - 0.5) * size.width * 0.34;
        final dy = (rng.nextDouble() - 0.5) * size.height * 0.16;
        final radius = size.width * (0.16 + rng.nextDouble() * 0.24);
        final c = Offset(base.dx + dx, base.dy + dy);
        // Nucleo chiaro, corpo indaco-viola, bordo che si dissolve morbido.
        final coreAlpha = 0.18 + rng.nextDouble() * 0.12; // 0,18..0,30
        final paint = Paint()
          ..shader = RadialGradient(
            colors: [
              CosmosNebula.core.withValues(alpha: coreAlpha),
              (b.isEven ? CosmosNebula.mid : CosmosNebula.cool)
                  .withValues(alpha: coreAlpha * 0.6),
              Colors.transparent,
            ],
            stops: const [0.0, 0.45, 1.0],
          ).createShader(Rect.fromCircle(center: c, radius: radius))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
        canvas.drawCircle(c, radius, paint);
      }
    }
  }

  // --- Particelle vicine (bokeh) ---

  void _paintNearParticles(Canvas canvas, Size size, Offset off, double t) {
    final rng = math.Random(31 + seed * 7919);
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < _nearCount; i++) {
      final baseX = rng.nextDouble();
      final baseY = rng.nextDouble();
      final radius = 0.6 + rng.nextDouble() * 1.6;
      final dy = _animate ? (t + rng.nextDouble()) % 1.0 : baseY;
      final y = (baseY + dy * 0.12) % 1.0;
      // Zona franca anche per le particelle vicine.
      if (keepOut != null && keepOut!.contains(Offset(baseX, y))) continue;
      final p = Offset(baseX * size.width, y * size.height) + off;
      canvas.drawCircle(
        p,
        radius * 2.6,
        Paint()
          ..color = palette.goldSoft.withValues(alpha: 0.10)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      paint.color = palette.goldSoft.withValues(alpha: 0.5);
      canvas.drawCircle(p, radius * 1.3, paint);
    }
  }

  // --- Stelle cadenti occasionali ---

  void _paintShootingStars(Canvas canvas, Size size, Offset off, double t) {
    const windows = [0.18, 0.68];
    const dur = 0.06;
    final scia = cielo.sciaDellaCadente;
    for (var i = 0; i < windows.length; i++) {
      final w0 = windows[i];
      if (t < w0 || t > w0 + dur) continue;
      final p = (t - w0) / dur; // 0..1
      final startX = size.width * (0.1 + i * 0.5);
      final startY = size.height * 0.12;
      final head = Offset(
            startX + p * size.width * 0.7,
            startY + p * size.height * 0.35,
          ) +
          off;
      final tail = head - const Offset(lunghezzaDellaScia, altezzaDellaScia);
      // LA SCIA VIENE DALLO SPRITE, ordine del cielo dipinto una volta: il
      // gradiente si costruiva a ogni fotogramma con createShader, ed era
      // uno dei tre modi in cui questo pittore chiedeva lavoro alla GPU
      // mentre l'app cambiava schermata.
      if (scia != null) {
        canvas.drawImageRect(
          scia,
          Rect.fromLTWH(0, 0, scia.width.toDouble(), scia.height.toDouble()),
          Rect.fromPoints(tail, head),
          Paint()
            ..colorFilter = ColorFilter.mode(
                palette.goldSoft.withValues(alpha: 0.9 * (1 - p)),
                BlendMode.srcIn),
        );
      }
      canvas.drawCircle(
        head,
        2.2,
        Paint()..color = Colors.white.withValues(alpha: 0.9 * (1 - p)),
      );
    }
  }

  @override
  bool shouldRepaint(_CosmosPainter old) =>
      old.seed != seed ||
      old.densita != densita ||
      old.palette != palette ||
      old.tier != tier ||
      old.highlighted != highlighted ||
      old.showZodiac != showZodiac ||
      old.reduceMotion != reduceMotion ||
      old.keepOut != keepOut;
}

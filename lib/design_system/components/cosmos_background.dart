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
final RouteObserver<ModalRoute<void>> osservatoreDelCielo =
    RouteObserver<ModalRoute<void>>();

class _CosmosBackgroundState extends State<CosmosBackground>
    with SingleTickerProviderStateMixin, RouteAware {
  /// Vero mentre la rotta di questo cielo e' coperta da un'altra: il cielo
  /// non si ricostruisce e non gira. Quanti sono sospesi lo conta la prova.
  bool _coperto = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final rotta = ModalRoute.of(context);
    if (rotta != null) osservatoreDelCielo.subscribe(this, rotta);
  }

  @override
  void didPushNext() {
    if (_coperto) return;
    CosmosBackground.quantiSospesi++;
    setState(() => _coperto = true);
    _controller.stop();
  }

  @override
  void didPopNext() {
    if (!_coperto) return;
    CosmosBackground.quantiSospesi--;
    setState(() => _coperto = false);
  }

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
  }

  @override
  void dispose() {
    osservatoreDelCielo.unsubscribe(this);
    if (_coperto) CosmosBackground.quantiSospesi--;
    _controller.dispose();
    _cielo.libera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Letture tolleranti: il motore e' il fondale di TUTTA l'app e deve
    // reggere anche montato da solo, come promette il backdrop dei riti nei
    // test. Senza provider si degrada con garbo: qualita' media, nessun segno
    // evidenziato, moto di ripiego condiviso.
    final palette = widget.paletteOverride ?? context.palette;
    final quality = context
            .watch<QualityTierController?>()
            ?.tier ??
        QualityTier.medium;
    // **DA COPERTO NON SI ASCOLTA**: il watch qui sotto ricostruiva questo
    // albero a ogni tick del sensore anche sotto una funzionalita' aperta.
    // Da coperto si legge senza iscriversi, e il giro sta fermo.
    final parallax = _coperto
        ? (context.read<ParallaxController?>() ?? _parallasseDiRipiego())
        : (context.watch<ParallaxController?>() ?? _parallasseDiRipiego());
    final sunSign = context.watch<ZodiacController?>()?.sunSign;
    // Riduci Movimento: cosmo fermo, niente stella cadente, parallasse minima.
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    // In qualita' bassa o con Riduci Movimento il cosmo e' quasi statico.
    if (quality == QualityTier.low || reduceMotion) {
      if (_controller.isAnimating) _controller.stop();
    } else {
      // Da coperto il giro NON si riarma: e' la sospensione dell'ordine AJ.
      if (!_coperto && !_controller.isAnimating) _controller.repeat();
    }

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
                palette: palette,
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
            if (_nebulaClusters > 0) _paintNebula(tela, teloMedio, fermo, 0);
            if (showPlanets && _planetCount > 0) {
              _paintPlanets(tela, teloMedio, fermo);
            }
          });

    // PIANO PIU' LONTANO: la polvere. In qualita' bassa non c'e' nessuna
    // polvere, e un'immagine vuota costerebbe i suoi megabyte per non
    // mostrare niente: il piano non nasce affatto.
    cielo.lontano = _dustStars == 0
        ? null
        : _dipingiUnaVolta(teloLontano, densita, (tela) {
            _paintStarDust(tela, teloLontano, fermo, 0);
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
      _paintFieldStars(tela, teloFondo, fermo, 0);
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

  void _paintStarDust(Canvas canvas, Size size, Offset off, double t) {
    final rng = math.Random(91 + seed * 7919);
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < _dustStars; i++) {
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

  void _paintPlanets(Canvas canvas, Size size, Offset off) {
    const spots = [
      (Offset(0.16, 0.2), 10.0),
      (Offset(0.82, 0.3), 7.0),
    ];
    for (var i = 0; i < _planetCount && i < spots.length; i++) {
      final (pos, r) = spots[i];
      final center = Offset(pos.dx * size.width, pos.dy * size.height) + off;
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

  void _paintFieldStars(Canvas canvas, Size size, Offset off, double t) {
    final rng = math.Random(7 + seed * 7919);
    final stars = List<_Star>.generate(_fieldStars, (_) {
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

  void _paintNebula(Canvas canvas, Size size, Offset off, double t) {
    const centers = [
      Offset(0.22, 0.22),
      Offset(0.80, 0.46),
      Offset(0.52, 0.74),
    ];
    final drift = _animate ? math.sin(2 * math.pi * t) * 12 : 0.0;
    final rng = math.Random(53 + seed * 7919);

    for (var i = 0; i < _nebulaClusters; i++) {
      final base = Offset(
              centers[i].dx * size.width, centers[i].dy * size.height) +
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

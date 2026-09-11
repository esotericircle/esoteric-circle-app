import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/viaggio/dove_sta_la_testa.dart';

/// **LA LENTE: SPOSTA E SCOPRI.** Ordine DE voce 03, 11 settembre 2026.
///
/// **CHE COSA SOSTITUISCE, e perche'.** Fino a ieri l'incontro mostrava
/// `PittoreDellAnimale`, una sagoma **disegnata da una formula a partire da un
/// seme**: un corpo, quattro zampe, un collo, una testa con due orecchie e una
/// coda. Il fondatore ha nominato due difetti, e tutti e due erano veri.
///
/// **Il primo e' di verita'.** La sagoma non era il ritratto di nessuno: due
/// semi diversi davano due quadrupedi appena diversi, e **nessuno dei dodici
/// era quel quadrupede**. Chi seguiva un'ombra non stava guardando l'animale
/// che avrebbe avuto.
///
/// **Il secondo e' di specie.** La formula disegna sempre un quadrupede, e
/// **quattro dei dodici non lo sono**: aquila, corvo, falco e gufo hanno due
/// zampe e le ali, e il serpente non ha nemmeno quelle. Una formula che
/// promette un animale e ne disegna un altro non e' un velo, e' un errore.
///
/// **Adesso sotto il velo c'e' l'animale VERO**, la stessa illustrazione che
/// si ritrovera' nel Passaporto e fra i dodici totem. Il velo la scurisce e la
/// **sfoca**, mai la annerisce: la sagoma complessiva si intuisce sempre, e
/// quella sagoma e' finalmente la sua.
///
/// **IL LIMITE E' SPAZIALE, NON TEMPORALE**, ed e' la parte che l'ordine
/// ripete due volte. Non si scopre per un tot di secondi: si scopre **dove si
/// puo'**, e il dove cambia a ogni discesa. Le tre aree si calcolano dal
/// rettangolo della testa di quell'animale, e vivono in
/// [DoveStaLaTesta.areaDellaDiscesa].
class LenteCheScopre extends StatefulWidget {
  const LenteCheScopre({
    super.key,
    required this.nome,
    required this.immagine,
    required this.discesa,
    this.senzaMoto,
    this.doveParte,
  });

  /// Il nome del catalogo, che e' anche la chiave del rettangolo della testa.
  final String nome;

  /// Il percorso dell'illustrazione vera.
  final String immagine;

  /// La discesa, contata da zero. Alla quarta, cioe' a 3, il velo cade.
  final int discesa;

  /// Iniettabile per le prove. Nullo vuol dire chiederlo a `MediaQuery`.
  final bool? senzaMoto;

  /// Dove sta la lente prima che il dito la tocchi, in frazioni dell'area
  /// concessa. Nullo vuol dire il centro.
  final Offset? doveParte;

  /// **QUANTO E' SCURO IL VELO**, e non e' nero.
  ///
  /// Zero virgola settantotto: sotto, l'animale si legge gia' troppo e la
  /// lente non serve; sopra, la sagoma sparisce e la voce dell'ordine
  /// *"cosi' la sagoma complessiva si intuisce sempre"* non e' piu' vera.
  static const double quantoEScuroIlVelo = 0.78;

  /// **QUANTO SFOCA IL VELO**, in punti di sigma sul lato corto della scena.
  ///
  /// Una misura **proporzionale e non in pixel fissi**: e' la lezione
  /// dell'ordine DC, dove sei pixel di sfocatura erano un velo su una scena
  /// larga trecentonovanta e cancellavano del tutto la sagoma dentro un tondo
  /// da cinquantadue.
  static const double quantoSfocaIlVelo = 0.035;

  /// **QUANTO DURA LA CADUTA DEL VELO ALLA QUARTA.**
  static const Duration quantoDuraLaCaduta = Duration(milliseconds: 900);

  @override
  State<LenteCheScopre> createState() => _LenteCheScopreState();
}

class _LenteCheScopreState extends State<LenteCheScopre>
    with SingleTickerProviderStateMixin {
  /// Dove sta il centro della lente, in punti della scena. Nullo finche' non
  /// si conosce la misura della scena.
  Offset? _lente;

  /// **QUANTO IL DITO STA SPINGENDO OLTRE IL BORDO**, da 0 a 1.
  ///
  /// Ordine DE voce 03: *"arrivata al bordo si ferma, e il velo attorno si fa
  /// piu' fitto invece di lasciarla uscire: cosi' il confine si capisce senza
  /// leggere niente"*. E' questo numero a farlo.
  double _spinge = 0;

  late final AnimationController _caduta = AnimationController(
    vsync: this,
    duration: LenteCheScopre.quantoDuraLaCaduta,
    value: widget.discesa >= 3 ? 0 : 1,
  );

  @override
  void initState() {
    super.initState();
    if (widget.discesa >= 3) _caduta.value = 0;
  }

  @override
  void didUpdateWidget(LenteCheScopre vecchio) {
    super.didUpdateWidget(vecchio);
    if (widget.discesa != vecchio.discesa) {
      _lente = null;
      if (widget.discesa >= 3) {
        _caduta.reverse(from: 1);
      } else {
        _caduta.value = 1;
      }
    }
  }

  @override
  void dispose() {
    _caduta.dispose();
    super.dispose();
  }

  /// **IL RETTANGOLO VERO DELL'IMMAGINE DENTRO LA SCENA.**
  ///
  /// L'illustrazione entra con `BoxFit.contain`, quindi **non riempie la
  /// scena**: le frazioni del rettangolo della testa parlano dell'immagine, e
  /// applicarle alla scena le sposterebbe di tutta la fascia vuota. E' la
  /// stessa famiglia di difetto della misura legata al lato corto, costata
  /// due giri nell'ordine DC.
  Rect _dentroLaScena(Size scena, Size sorgente) {
    if (sorgente.width <= 0 || sorgente.height <= 0) {
      return Offset.zero & scena;
    }
    final k = (scena.width / sorgente.width) < (scena.height / sorgente.height)
        ? scena.width / sorgente.width
        : scena.height / sorgente.height;
    final larga = sorgente.width * k;
    final alta = sorgente.height * k;
    return Rect.fromLTWH(
        (scena.width - larga) / 2, (scena.height - alta) / 2, larga, alta);
  }

  void _muovi(Offset dito, Rect immagine, double raggio) {
    final area = DoveStaLaTesta.areaDellaDiscesa(widget.nome, widget.discesa);
    final tenuto = DoveStaLaTesta.tieniDentro(
        dito: dito, immagine: immagine, area: area, raggio: raggio);
    final fuori = (dito - tenuto).distance;
    setState(() {
      _lente = tenuto;
      _spinge = raggio <= 0 ? 0 : (fuori / raggio).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final velato = widget.discesa < 3;
    return LayoutBuilder(
      builder: (context, vincoli) {
        final scena = Size(
          vincoli.maxWidth.isFinite ? vincoli.maxWidth : 360,
          vincoli.maxHeight.isFinite ? vincoli.maxHeight : 640,
        );
        return _ConLaMisuraVera(
          percorso: widget.immagine,
          costruisci: (sorgente) {
            final immagine = _dentroLaScena(scena, sorgente);
            final raggio = immagine.width * DoveStaLaTesta.raggioDellaLente;
            final area =
                DoveStaLaTesta.areaDellaDiscesa(widget.nome, widget.discesa);
            final partenza = widget.doveParte ?? const Offset(0.5, 0.5);
            final lente = _lente ??
                DoveStaLaTesta.tieniDentro(
                  dito: Offset(
                    immagine.left +
                        immagine.width *
                            (area.left +
                                (area.right - area.left) * partenza.dx),
                    immagine.top +
                        immagine.height *
                            (area.top + (area.bottom - area.top) * partenza.dy),
                  ),
                  immagine: immagine,
                  area: area,
                  raggio: raggio,
                );
            return GestureDetector(
              key: const Key('viaggio_lente'),
              behavior: HitTestBehavior.opaque,
              onPanStart: (d) => _muovi(d.localPosition, immagine, raggio),
              onPanUpdate: (d) => _muovi(d.localPosition, immagine, raggio),
              onPanEnd: (_) => setState(() => _spinge = 0),
              onTapDown: (d) => _muovi(d.localPosition, immagine, raggio),
              child: AnimatedBuilder(
                animation: _caduta,
                builder: (context, _) => Stack(
                  fit: StackFit.expand,
                  children: [
                    // **SOTTO C'E' L'ANIMALE VERO, in chiaro e per intero.**
                    Image.asset(widget.immagine,
                        key: const Key('viaggio_animale_vero'),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                    // **SOPRA, IL VELO INTERO**, senza nessun buco: e' la
                    // stessa immagine scurita e sfocata, cosi' la sagoma si
                    // intuisce sempre e non c'e' nessun nero pieno a
                    // nascondere che sotto ci sia qualcosa.
                    if (velato || _caduta.value > 0)
                      Opacity(
                        opacity: _caduta.value,
                        child: _ilVelo(scena),
                      ),
                    // **E SOPRA IL VELO, IL CERCHIO DELLA LENTE**, cioe' la
                    // sola porzione di animale che oggi si puo' vedere.
                    //
                    // **Qui c'era un `ShaderMask` con `BlendMode.dstIn`** che
                    // ritagliava il buco dal velo. Sul 767f596c quella
                    // maschera cancellava il velo **intero**: alla seconda e
                    // alla terza discesa l'animale si vedeva tutto, testa
                    // compresa, mentre lo schermo prometteva una lente. Un
                    // ritaglio e un gradiente fanno lo stesso disegno senza
                    // chiedere nessuna fusione a nessuno.
                    if (velato || _caduta.value > 0)
                      Opacity(
                        opacity: _caduta.value,
                        child: ClipPath(
                          key: const Key('viaggio_cerchio_della_lente'),
                          clipper: _IlCerchioDellaLente(
                              centro: lente, raggio: raggio),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(widget.immagine,
                                  key: const Key('viaggio_animale_scoperto'),
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox.shrink()),
                              // **IL BORDO SFUMATO**, dentro il ritaglio: dal
                              // cuore chiaro alla coltre piena esattamente sul
                              // raggio, che e' lo stesso numero con cui il
                              // centro viene tenuto dentro l'area. Una
                              // sfumatura che sbordasse scoprirebbe **a
                              // meta'** cio' che la Regola H pretende coperto
                              // del tutto, e scoperto a meta' e' scoperto.
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    center: Alignment(
                                      scena.width == 0
                                          ? 0
                                          : (lente.dx / scena.width) * 2 - 1,
                                      scena.height == 0
                                          ? 0
                                          : (lente.dy / scena.height) * 2 - 1,
                                    ),
                                    radius: scena.shortestSide == 0
                                        ? 1
                                        : raggio / (scena.shortestSide / 2),
                                    colors: [
                                      Colors.transparent,
                                      Colors.transparent,
                                      _coltre(),
                                    ],
                                    // **PIU' IL DITO SPINGE, PIU' IL BUCO SI
                                    // CHIUDE**: e' il velo che si fa fitto
                                    // invece di lasciarla uscire.
                                    stops: [
                                      0.0,
                                      0.70 - 0.30 * _spinge,
                                      1.0,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// **IL VELO: UNA COLTRE SCURA, E DENTRO LA SAGOMA SFOCATA.**
  ///
  /// Due strati e non uno, e la ragione sta nella riga dell'ordine *"scuro e
  /// SFOCATO, mai nero pieno, cosi' la sagoma complessiva si intuisce
  /// sempre"*. Una sola tinta nera darebbe un rettangolo e basta: chi guarda
  /// non saprebbe nemmeno che sotto c'e' qualcosa. Una sola sfocatura
  /// lascerebbe leggere il colore e il manto, e il nome arriverebbe alla
  /// prima discesa.
  ///
  /// **Sotto la coltre, sopra il fantasma**: la coltre dice che c'e' un velo,
  /// il fantasma dice che sotto c'e' un animale, e nessuno dei due dice
  /// quale.
  /// **IL COLORE DELLA COLTRE, in un posto solo.**
  ///
  /// Lo usano in due: la coltre che copre tutta la scena e la corona del
  /// cerchio della lente, che deve arrivare **esattamente allo stesso colore**
  /// sul raggio. Due numeri scritti in due posti diversi si sarebbero separati
  /// alla prima taratura, e il bordo del ritaglio sarebbe diventato visibile.
  Color _coltre() => const Color(0xFF06040C).withValues(
      alpha: (LenteCheScopre.quantoEScuroIlVelo + 0.12 * _spinge)
          .clamp(0.0, 1.0));

  Widget _ilVelo(Size scena) {
    // **LA SFOCATURA E' PROPORZIONALE ALLA SCENA, mai in pixel fissi.** E' la
    // lezione dell'ordine DC: sei pixel di sfocatura sono un velo su una
    // scena larga trecentonovanta e cancellano tutto dentro un tondo da
    // cinquantadue.
    final sigma = scena.shortestSide * LenteCheScopre.quantoSfocaIlVelo *
        (1 + 0.6 * _spinge);
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          key: const Key('viaggio_velo_dell_animale'),
          color: _coltre(),
        ),
        ImageFiltered(
          imageFilter: ui.ImageFilter.blur(
              sigmaX: sigma, sigmaY: sigma, tileMode: TileMode.decal),
          child: Opacity(
            // **IL FANTASMA E' AL CINQUANTACINQUE PER CENTO.** Piu' su si
            // legge il manto, piu' giu' sparisce la sagoma.
            opacity: 0.55,
            child: Image.asset(widget.immagine,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink()),
          ),
        ),
      ],
    );
  }
}

/// **LA MISURA VERA DELL'IMMAGINE, chiesta al suo file.**
///
/// Serve perche' i dodici **non hanno la stessa forma**: il gufo e' 537x865,
/// la volpe 894x575. Senza la misura vera non si sa dove `BoxFit.contain`
/// mette l'immagine dentro la scena, e le frazioni del rettangolo della testa
/// cadrebbero nel posto sbagliato.
///
/// **Finche' la misura non arriva si costruisce lo stesso**, con la forma
/// della scena: un attimo di lente in un punto approssimato e' meglio di una
/// schermata vuota, ed e' la legge della voce DC.16.
class _ConLaMisuraVera extends StatefulWidget {
  const _ConLaMisuraVera({required this.percorso, required this.costruisci});

  final String percorso;
  final Widget Function(Size) costruisci;

  @override
  State<_ConLaMisuraVera> createState() => _ConLaMisuraVeraState();
}

class _ConLaMisuraVeraState extends State<_ConLaMisuraVera> {
  Size? _misura;
  ImageStream? _flusso;
  ImageStreamListener? _ascolto;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chiedi();
  }

  @override
  void didUpdateWidget(_ConLaMisuraVera vecchio) {
    super.didUpdateWidget(vecchio);
    if (vecchio.percorso != widget.percorso) {
      _misura = null;
      _chiedi();
    }
  }

  void _chiedi() {
    _stacca();
    final flusso =
        AssetImage(widget.percorso).resolve(createLocalImageConfiguration(context));
    final ascolto = ImageStreamListener((info, _) {
      final m = Size(info.image.width.toDouble(), info.image.height.toDouble());
      if (mounted && _misura != m) setState(() => _misura = m);
    }, onError: (_, __) {
      // **UN ASSET CHE NON ARRIVA NON FERMA LA DISCESA.** Ordine DC voce 16.
    });
    flusso.addListener(ascolto);
    _flusso = flusso;
    _ascolto = ascolto;
  }

  void _stacca() {
    final f = _flusso;
    final a = _ascolto;
    if (f != null && a != null) f.removeListener(a);
    _flusso = null;
    _ascolto = null;
  }

  @override
  void dispose() {
    _stacca();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.costruisci(_misura ?? const Size(900, 760));
}

/// **L'OMBRA VERA DI UN ANIMALE VERO.** Ordine DE voce 03.
///
/// **Serve all'incontro, dove le ombre sono tre e se ne segue una.** Fino a
/// ieri quelle tre ombre le disegnava una formula, e la formula disegnava
/// **sempre un quadrupede**: chi seguiva l'ombra di un'aquila stava seguendo
/// il disegno di un lupo. Adesso l'ombra e' **la sagoma vera di quella
/// illustrazione**, presa dal suo canale alpha.
///
/// **E NON DICE IL NOME, che e' il vincolo della voce DC.02.** La sagoma e'
/// quasi nera e molto sfocata: si legge la massa, la postura e poco altro.
/// Che una delle tre abbia le ali e' un'informazione vera e non e' un nome,
/// ed e' esattamente il genere di cosa che un'ombra deve poter dire.
class OmbraDellAnimale extends StatelessWidget {
  const OmbraDellAnimale({
    super.key,
    required this.immagine,
    required this.quantaLuce,
  });

  final String immagine;

  /// Da 0 a 1: quanta luce le arriva addosso. La muove la scena.
  final double quantaLuce;

  /// **QUANTO SFOCA L'OMBRA**, in frazione del lato corto della scena.
  ///
  /// Il doppio della sfocatura del velo della lente: qui non c'e' nessuna
  /// lente che apra un buco, e l'unica difesa contro il nome e' la sfocatura.
  static const double quantoSfoca = 0.030;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, vincoli) {
          final lato = vincoli.biggest.shortestSide.isFinite
              ? vincoli.biggest.shortestSide
              : 320.0;
          return Stack(
            fit: StackFit.expand,
            children: [
              // **LA LUCE DIETRO, che e' cio' che rende un controluce un
              // controluce.** Senza, la sagoma scura finisce su un fondo
              // scuro e l'incontro e' uno schermo vuoto: difetto visto sul
              // telefono 767f596c il 10 settembre 2026, e costato due giri.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.08),
                    radius: 0.45 + 0.35 * quantaLuce,
                    colors: [
                      const Color(0xFFF0DDB0)
                          .withValues(alpha: 0.34 + 0.34 * quantaLuce),
                      const Color(0xFFB08A4E).withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
              ImageFiltered(
                imageFilter: ui.ImageFilter.blur(
                  sigmaX: lato * quantoSfoca,
                  sigmaY: lato * quantoSfoca,
                  tileMode: TileMode.decal,
                ),
                child: ColorFiltered(
                  // **`srcIn` TIENE LA FORMA E BUTTA IL COLORE**: quello che
                  // resta e' esattamente il canale alpha dell'illustrazione,
                  // cioe' la sua sagoma vera.
                  colorFilter: ColorFilter.mode(
                      const Color(0xFF07040D)
                          .withValues(alpha: 0.94 - 0.10 * quantaLuce),
                      BlendMode.srcIn),
                  child: Image.asset(immagine,
                      key: const Key('viaggio_ombra_vera'),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                ),
              ),
            ],
          );
        },
      );
}


/// **IL RITAGLIO CIRCOLARE DELLA LENTE.**
///
/// Un `ClipPath` e non una maschera di fusione: vedi la nota lunga dentro
/// `LenteCheScopre`. Il bordo netto di questo cerchio non si vede perche' il
/// gradiente che gli sta dentro arriva alla coltre piena proprio sul raggio.
class _IlCerchioDellaLente extends CustomClipper<Path> {
  const _IlCerchioDellaLente({required this.centro, required this.raggio});

  final Offset centro;
  final double raggio;

  @override
  Path getClip(Size size) =>
      Path()..addOval(Rect.fromCircle(center: centro, radius: raggio));

  @override
  bool shouldReclip(_IlCerchioDellaLente vecchio) =>
      vecchio.centro != centro || vecchio.raggio != raggio;
}

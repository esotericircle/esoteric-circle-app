import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/arts/art_catalog.dart';
import '../../core/arts/gli_sfondi_delle_schede.dart';
import '../../core/arts/le_arti_del_giorno.dart';
import '../../core/config/app_flags.dart';
import '../../core/entitlement/plan_catalog.dart';
import '../../core/lang/euphonic.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_controller.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/viaggio/diario_dei_viaggi.dart';
import '../../core/viaggio/la_promessa_del_viaggio.dart';
import '../maestri/maestro_screen.dart' show showArtPreview;
import '../maestri/art_navigation.dart';
import 'la_luce_delle_schede.dart';

/// **LA SCHEDA DI UN'ARTE, UNA SOLA PER TUTTA L'APP.** Ordine EO voci 02, 03,
/// 04, 05 e 06, 26 settembre 2026.
///
/// Il fondatore: ogni scheda e' *solo un'immagine d'impatto, senza testo
/// sovrapposto, con il titolo sotto*; *"potrei riservare l'angolo in alto a
/// destra come area con simbolo "i" per chi vuole informazioni prima di
/// entrare"*; *"le schede non funzionanti possiamo aggiungere in alto a
/// sinistra un lucchetto dorato anche"*, poi *"Ok per clessidra e tuoi
/// suggerimenti"*; sul titolo *"Si. Ma preferirei allineamento a sinistra"*.
///
/// - **L'immagine** e' lo sfondo del suo formato ([GliSfondiDelleSchede]),
///   senza niente sopra se non i due angoli e il riflesso dell'oro.
/// - **Il titolo** sta sotto, allineato a sinistra sul bordo dell'immagine,
///   nel carattere dei titoli delle schede di oggi (`titoloDiRiga`), su al
///   massimo due righe e **mai rimpicciolito**; dove l'arte ha
///   [ArtEntry.righeDelTitolo] segue quelle righe, le parole piccole in corpo
///   piccolo (ordine DE voce 02).
/// - **In alto a destra la "i"**, piccola e dorata, con un'area di tocco di
///   [areaDellaI] punti: gira la scheda e mostra le informazioni (EO.04).
/// - **In alto a sinistra** la clessidra sulle arti in arrivo, il lucchetto
///   sulle arti Premium: il lucchetto resta il segno del Premium e di
///   nient'altro.
/// - **Il tocco** su un'arte attiva la preme, la ingrandisce e la fa svanire
///   mentre sotto compare l'arte (EO.03); su un'arte Premium fa cio' che
///   faceva prima; su un'arte in arrivo gira la scheda (EO.05).
class LaSchedaDellArte extends StatefulWidget {
  const LaSchedaDellArte({
    super.key,
    required this.art,
    required this.maestro,
    required this.formato,
    required this.larghezza,
    this.onApri,
    this.onTieni,
    this.sfondoDelMaestro = false,
    this.mostraFase = AppFlags.isDemo,
    this.sfondo,
  });

  final ArtEntry art;

  /// **Uno sfondo proprio**, per la scheda che non e' un'arte del catalogo:
  /// la scheda "Consulta" in cima a ogni dominio (ordine EP voce 12).
  final String? sfondo;

  /// Il Maestro a cui l'arte appartiene: il colore del retro.
  final Maestro maestro;

  final FormatoDellaScheda formato;

  /// La larghezza dell'immagine, in punti: l'altezza viene dal formato.
  final double larghezza;

  /// Chi apre l'arte; se manca, [apriLArte].
  final Future<void> Function(BuildContext context)? onApri;

  /// La pressione lunga: nella riga delle arti preferite toglie l'arte,
  /// come faceva lo scaffale di prima dell'ordine EO.
  final VoidCallback? onTieni;

  /// **La riga "In arrivo", ordine EO voce 13**: lo sfondo del Maestro senza
  /// emblema e al centro l'icona dell'arte in oro.
  final bool sfondoDelMaestro;

  /// **La fase si dice solo nella Demo.** Alla persona si dice soltanto
  /// "In arrivo": la fase e' un dato di piano (la regola della card di
  /// prima, che la scheda eredita).
  final bool mostraFase;

  /// L'area che risponde al tocco della "i": almeno un centimetro.
  static const double areaDellaI = 48;

  /// Quanto la scheda si abbassa sotto il dito.
  static const double pressione = 0.95;

  /// **I TEMPI DEL TOCCO. Ordine EO voce 03**, *"Deve essere una transizione
  /// veloce"*, circa tre decimi di secondo in tutto.
  static const Duration tempoDellaPressione = Duration(milliseconds: 80);
  static const Duration tempoDellUscita = Duration(milliseconds: 220);

  /// Quanto dura il giro della scheda.
  static const Duration tempoDelGiro = Duration(milliseconds: 360);

  /// Quanto si ingrandisce mentre svanisce.
  static const double ingrandimento = 1.2;

  /// **LA LARGHEZZA VIENE DALLA PAROLA PIU' LUNGA.** Ordine EO voce 02:
  /// il titolo non si rimpicciolisce e non spezza una parola. Misurato col
  /// Cinzel vero a sedici punti: la parola piu' lunga del catalogo,
  /// "Astrocartografia", ne prende 181; a 180 nessun titolo supera le due
  /// righe. Le schede orizzontali sono larghe una volta e mezza. Tutto si
  /// moltiplica per la scala del testo che la persona ha scelto.
  ///
  /// **IN HOME LE SCHEDE SONO ALL'88 PER CENTO.** Ordine EP voce 02, 26
  /// settembre 2026. Il fondatore: *"Le tessere schede sono troppo grandi in
  /// home"*, e sulla domanda dei titoli lunghi *"Schede all'88%"*: 162 punti
  /// le verticali e le quadrate, 253 le orizzontali, coi titoli identici.
  /// **Nei domini restano 184 e 288**: *"nei singoli domini lasciamo la
  /// grandezza attuale"*.
  static double larghezzaPer(FormatoDellaScheda formato,
          {double scalaDelTesto = 1, bool inCasa = false}) =>
      (formato == FormatoDellaScheda.orizzontale
          ? (inCasa ? 253.0 : 288.0)
          : (inCasa ? 162.0 : 184.0)) *
      math.max(1, scalaDelTesto);

  /// Le righe che il titolo puo' prendere.
  static const int righeDelTitolo = 2;

  /// Lo stile del titolo: lo stesso delle schede di oggi.
  static TextStyle stileDelTitolo() =>
      TypographyTokens.titoloDiRiga().copyWith(color: ColorTokens.textPrimary);

  /// Lo stile della riga [i] di un titolo gia' deciso, come il Viaggio dello
  /// Sciamano: le parole piccole in corpo piccolo (ordine DE voce 02).
  static TextStyle stileDellaRigaDecisa(int i) {
    final pieno = stileDelTitolo();
    return i.isOdd
        ? pieno.copyWith(
            fontSize: (pieno.fontSize ?? 16) * 0.62,
            color: ColorTokens.textSecondary,
            height: 1.02,
            letterSpacing: 0.6)
        : pieno.copyWith(height: 1.02, letterSpacing: 1.6);
  }

  /// **L'ALTEZZA DEI TITOLI DI UNA RIGA**, cioe' del titolo piu' alto fra
  /// quelli di [arti] alla larghezza [larghezza]. Ordine EP voce 04: la riga
  /// della home finisce dove finiscono i suoi titoli, non tre righe dopo.
  static double altezzaDeiTitoli(
      List<ArtEntry> arti, double larghezza, TextScaler scala) {
    var massima = 0.0;
    for (final art in arti) {
      final righe = art.righeDelTitolo;
      var altezza = 0.0;
      for (var i = 0; i < (righe?.length ?? 1); i++) {
        final p = TextPainter(
          text: TextSpan(
              text: righe?[i] ?? art.title,
              style: righe == null ? stileDelTitolo() : stileDellaRigaDecisa(i)),
          textDirection: TextDirection.ltr,
          textScaler: scala,
          maxLines: righe == null ? righeDelTitolo : 1,
        )..layout(maxWidth: larghezza);
        altezza += p.height;
        p.dispose();
      }
      massima = math.max(massima, altezza);
    }
    return massima;
  }

  @override
  State<LaSchedaDellArte> createState() => LaSchedaDellArteState();
}

/// Lo stato della scheda: pubblico perche' le prove lo possano leggere.
class LaSchedaDellArteState extends State<LaSchedaDellArte>
    with TickerProviderStateMixin {
  /// **IL TOCCO E IL GIRO NON SI SPENGONO E NON SI ACCORCIANO.** L'ordine
  /// EO spegne con la riduzione del movimento solo il riflesso (voce 06) e
  /// il sollevamento (voce 07); il tocco (voce 03) e il giro (voci 04 e 05)
  /// sono cio' che il fondatore ha chiesto di vedere, e sul Realme del
  /// collaudo le tre scale delle animazioni sono a zero: Flutter lo legge
  /// come riduzione del movimento e con `AnimationBehavior.normal`
  /// accorcerebbe tutto di venti volte. Per questo `preserve`, come per i
  /// gesti dei riti.
  late final AnimationController _giro = AnimationController(
      vsync: this,
      duration: LaSchedaDellArte.tempoDelGiro,
      animationBehavior: AnimationBehavior.preserve)
    ..addListener(() => setState(() {}));
  bool _premuta = false;
  bool _inUscita = false;

  /// Vero quando si vede il retro.
  bool get girata => _giro.value > 0.5;

  final GlobalKey _immagine = GlobalKey();

  /// **LA PROMESSA DEL VIAGGIO**, la sola informazione che cambia col
  /// tempo. Ordini DE voce 02 e DQ voce 03: cambia al riconoscimento, e il
  /// numero vive nel Diario. Finche' il Diario non risponde vale la promessa
  /// di chi non e' ancora sceso, e un archivio muto non spegne la scheda.
  String? _promessa;

  @override
  void initState() {
    super.initState();
    if (widget.art.id != 'guide_animal') return;
    _promessa = LaPromessaDelViaggio.descrizionePer(0);
    final diario = DiarioDeiViaggi();
    unawaited(diario.carica().then((_) {
      if (mounted) {
        setState(() => _promessa =
            LaPromessaDelViaggio.descrizionePer(diario.apparizioni));
      }
    }).catchError((Object errore) {
      debugPrint('SCHEDE: il Diario dei viaggi non risponde ($errore), resta '
          'la promessa di chi non è ancora sceso');
    }));
  }

  @override
  void dispose() {
    _giro.dispose();
    super.dispose();
  }

  String get _sfondo => widget.sfondo ?? _sfondoDelCatalogo;

  String get _sfondoDelCatalogo => widget.sfondoDelMaestro
      ? GliSfondiDelleSchede.delMaestro(widget.maestro, widget.formato)
      : (GliSfondiDelleSchede.perArte(widget.art.id, widget.formato) ??
          GliSfondiDelleSchede.delMaestro(widget.maestro, widget.formato));

  double get _altezza => widget.larghezza / widget.formato.proporzione;

  Future<void> _gira() async {
    if (girata) {
      await _giro.reverse();
    } else {
      await _giro.forward();
    }
  }

  Future<void> _apri() async {
    final apri =
        widget.onApri ?? (c) => apriLArte(c, widget.art, widget.maestro);
    await apri(context);
  }

  /// **ENTRARE NELL'ARTE. Ordine EO voce 03.** La scheda si abbassa, poi si
  /// ingrandisce e svanisce sopra l'arte che intanto si apre sotto.
  Future<void> _entra() async {
    final cronometro = Stopwatch()..start();
    setState(() => _premuta = true);
    await Future<void>.delayed(LaSchedaDellArte.tempoDellaPressione);
    if (!mounted) return;
    final box = _immagine.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (box == null || overlay == null || !box.hasSize) {
      setState(() => _premuta = false);
      await _apri();
      return;
    }
    final rect = box.localToGlobal(Offset.zero) & box.size;
    // **L'USCITA HA UN TICCHETTIO SUO, NELL'OVERLAY.** La prima stesura la
    // animava col ticchettio della scheda, e sul Realme l'uscita si fermava a
    // meta' per sempre, sopra l'arte appena aperta: appena la nuova schermata
    // copre la home, Flutter ammutolisce i ticchettii della home, e la scheda
    // e' nella home. Le prove non lo vedevano perche' l'apertura finta non
    // copriva niente. L'overlay della radice sta sopra ogni schermata e non
    // si ammutolisce.
    final finita = Completer<void>();
    late final OverlayEntry entrata;
    entrata = OverlayEntry(
      builder: (_) => _LUscitaDellaScheda(
        rect: rect,
        immagine: _faccia(fronte: true, perLUscita: true),
        onFinita: () {
          if (!finita.isCompleted) finita.complete();
        },
      ),
    );
    overlay.insert(entrata);
    setState(() {
      _premuta = false;
      _inUscita = true;
    });
    final apertura = _apri();
    await finita.future;
    // La misura della voce EO.03 sul telefono: dal tocco alla fine
    // dell'uscita, pressione compresa.
    debugPrint('SCHEDA ${widget.art.id}: tocco e uscita in '
        '${cronometro.elapsedMilliseconds} ms');
    entrata.remove();
    if (mounted && girata) _giro.value = 0;
    await apertura;
    if (mounted) setState(() => _inUscita = false);
  }

  Future<void> _tocco() async {
    switch (widget.art.state) {
      case ArtState.attiva:
        await _entra();
      case ArtState.premium:
        await _apri();
      case ArtState.inArrivo:
        await _gira();
    }
  }

  Future<void> _toccoSulRetro() async {
    switch (widget.art.state) {
      case ArtState.attiva:
        await _entra();
      case ArtState.premium:
        await _apri();
      case ArtState.inArrivo:
        await _gira();
    }
  }

  @override
  Widget build(BuildContext context) {
    final angolo = _giro.value * math.pi;
    final retro = angolo > math.pi / 2;
    final faccia = retro
        ? Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi),
            child: _retro(),
          )
        : _faccia(fronte: true);
    return SizedBox(
      width: widget.larghezza,
      child: Column(
        key: Key('scheda_${widget.art.id}'),
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: _inUscita ? 0 : 1,
            child: AnimatedScale(
              scale: _premuta ? LaSchedaDellArte.pressione : 1,
              duration: LaSchedaDellArte.tempoDellaPressione,
              child: Transform(
                key: _immagine,
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateY(angolo),
                child: SizedBox(
                  width: widget.larghezza,
                  height: _altezza,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: GestureDetector(
                          key: Key('scheda_tocco_${widget.art.id}'),
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (_) {
                            if (!retro && widget.art.state == ArtState.attiva) {
                              setState(() => _premuta = true);
                            }
                          },
                          onTapCancel: () => setState(() => _premuta = false),
                          onTap: () => retro ? _toccoSulRetro() : _tocco(),
                          onLongPress: widget.onTieni,
                          child: faccia,
                        ),
                      ),
                      // **IL PUNTINO D'ORO DELLE ARTI DEL GIORNO**, ordine EP
                      // voce 06: in basso a destra, lontano dalla "i" in alto
                      // a destra e dalla clessidra e dal lucchetto in alto a
                      // sinistra.
                      if (!retro)
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: _IlPuntinoDelGiorno(id: widget.art.id),
                        ),
                      // **LA "i" E LA SUA AREA DI UN CENTIMETRO.** Sul retro
                      // lo stesso angolo rigira la scheda. **Girata di
                      // mezzo giro la pila e' specchiata**: l'angolo che a
                      // video sta in alto a destra, nelle coordinate della
                      // pila e' quello a sinistra. Senza questo scambio la
                      // "i" del retro finiva in alto a sinistra.
                      Positioned(
                        top: 0,
                        right: retro ? null : 0,
                        left: retro ? 0 : null,
                        child: GestureDetector(
                          key: Key('scheda_i_${widget.art.id}'),
                          behavior: HitTestBehavior.opaque,
                          onTap: _gira,
                          child: SizedBox(
                            width: LaSchedaDellArte.areaDellaI,
                            height: LaSchedaDellArte.areaDellaI,
                            child: Align(
                              alignment: Alignment(retro ? -0.55 : 0.55, -0.55),
                              child: _LaI(girata: retro),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          _IlTitolo(art: widget.art),
        ],
      ),
    );
  }

  /// Il fronte: l'immagine del formato, gli angoli, il riflesso.
  Widget _faccia({required bool fronte, bool perLUscita = false}) {
    final propria = MaestroPalette.forKey(ThemeKey.of(widget.maestro));
    final raggio = BorderRadius.circular(SpacingTokens.radiusSm + 4);
    return ClipRRect(
      borderRadius: raggio,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: raggio,
          border: Border.all(color: propria.gold.withValues(alpha: 0.55)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _sfondo,
              key: Key('scheda_immagine_${widget.art.id}'),
              fit: BoxFit.cover,
              cacheWidth: (widget.larghezza * 3).round(),
              errorBuilder: (_, __, ___) => ColoredBox(color: propria.deepest),
            ),
            if (widget.sfondoDelMaestro)
              Center(
                child: Icon(
                  widget.art.icon,
                  key: Key('scheda_icona_${widget.art.id}'),
                  size: widget.larghezza * 0.3,
                  color: propria.goldSoft,
                ),
              ),
            if (!perLUscita) IlRiflessoDellOro(chiave: widget.art.id),
            if (widget.art.state != ArtState.attiva)
              Positioned(
                top: SpacingTokens.sm,
                left: SpacingTokens.sm,
                child: _IlSegnoDellAngolo(
                    stato: widget.art.state, id: widget.art.id),
              ),
          ],
        ),
      ),
    );
  }

  /// Il retro: le informazioni dell'arte e, per le arti in arrivo, la fase.
  Widget _retro() {
    final propria = MaestroPalette.forKey(ThemeKey.of(widget.maestro));
    final raggio = BorderRadius.circular(SpacingTokens.radiusSm + 4);
    final art = widget.art;
    final stato = switch (art.state) {
      ArtState.inArrivo => widget.mostraFase && art.phase != null
          ? 'In arrivo, ${art.phase}'
          : 'In arrivo',
      // Come diceva la card di prima: con quale livello si apre.
      ArtState.premium => art.requiredTier == null
          ? 'Si apre con il Cerchio'
          : 'Si apre ${conPiano(PlanCatalog.forTier(art.requiredTier!).name)}',
      ArtState.attiva => 'Tocca per entrare',
    };
    return Container(
      key: Key('scheda_retro_${art.id}'),
      decoration: BoxDecoration(
        borderRadius: raggio,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [propria.surfaceElevated, propria.deepest],
        ),
        border: Border.all(color: propria.gold.withValues(alpha: 0.7)),
      ),
      padding: const EdgeInsets.fromLTRB(SpacingTokens.md, SpacingTokens.md,
          SpacingTokens.xl, SpacingTokens.md),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: math.max(
              120, widget.larghezza - SpacingTokens.md - SpacingTokens.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _promessa ?? art.teaser,
                key: Key('scheda_informazioni_${art.id}'),
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textPrimary, height: 1.3),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                stato,
                key: Key('scheda_fase_${art.id}'),
                style: TypographyTokens.etichetta()
                    .copyWith(color: propria.goldSoft, letterSpacing: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Apre un'arte come la apriva il dominio: la rotta del catalogo con la
/// nascita e il nome della persona, altrimenti l'anteprima.
Future<void> apriLArte(
    BuildContext context, ArtEntry art, Maestro maestro) async {
  // Nelle prove che montano la scheda da sola il profilo manca: si apre
  // senza nascita, come per chi non l'ha data.
  final profilo = context.read<ProfileController?>();
  final route = artRouteFor(
    art.id,
    userBirth: profilo == null || profilo.identity.isExample
        ? null
        : profilo.identity.birthMoment,
    userName: profilo != null && profilo.hasName ? profilo.vocative : null,
  );
  if (route != null) {
    LeArtiDelGiorno.istanza.aperta(art.id);
    await Navigator.of(context).push(route);
    return;
  }
  if (!context.mounted) return;
  await showArtPreview(context, art: art, maestro: maestro);
}

/// Il puntino d'oro, finche' l'arte del giorno non e' aperta oggi.
class _IlPuntinoDelGiorno extends StatelessWidget {
  const _IlPuntinoDelGiorno({required this.id});

  final String id;

  /// Il diametro del puntino, in punti.
  static const double diametro = 9;

  @override
  Widget build(BuildContext context) {
    if (!LeArtiDelGiorno.ids.contains(id)) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: LeArtiDelGiorno.istanza,
      builder: (context, _) {
        if (!LeArtiDelGiorno.istanza.daVedere(id)) {
          return const SizedBox.shrink();
        }
        return IgnorePointer(
          child: Container(
            key: Key('scheda_puntino_$id'),
            width: diametro,
            height: diametro,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorTokens.gold,
              border: Border.all(color: ColorTokens.goldBright, width: 1),
              boxShadow: [
                BoxShadow(
                    color: ColorTokens.gold.withValues(alpha: 0.7),
                    blurRadius: 6),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// La "i", piccola e dorata.
class _LaI extends StatelessWidget {
  const _LaI({required this.girata});

  final bool girata;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.45),
        border: Border.all(color: ColorTokens.goldLight.withValues(alpha: 0.9)),
      ),
      alignment: Alignment.center,
      child: Icon(
        girata ? Icons.close_rounded : Icons.info_outline_rounded,
        size: 15,
        color: ColorTokens.goldLight,
      ),
    );
  }
}

/// La clessidra delle arti in arrivo e il lucchetto del Premium.
class _IlSegnoDellAngolo extends StatelessWidget {
  const _IlSegnoDellAngolo({required this.stato, required this.id});

  final ArtState stato;
  final String id;

  @override
  Widget build(BuildContext context) {
    final inArrivo = stato == ArtState.inArrivo;
    return Container(
      key: Key(inArrivo ? 'scheda_clessidra_$id' : 'scheda_lucchetto_$id'),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.45),
        border: Border.all(color: ColorTokens.goldLight.withValues(alpha: 0.9)),
      ),
      alignment: Alignment.center,
      child: Icon(
        inArrivo ? Icons.hourglass_bottom_rounded : Icons.lock_rounded,
        size: 13,
        color: ColorTokens.goldLight,
      ),
    );
  }
}

/// **IL TITOLO, A SINISTRA, MAI RIMPICCIOLITO.** Ordine EO voce 02.
class _IlTitolo extends StatelessWidget {
  const _IlTitolo({required this.art});

  final ArtEntry art;

  @override
  Widget build(BuildContext context) {
    final pieno = LaSchedaDellArte.stileDelTitolo();
    final righe = art.righeDelTitolo;
    if (righe == null) {
      return Text(
        art.title,
        key: Key('scheda_titolo_${art.id}'),
        maxLines: LaSchedaDellArte.righeDelTitolo,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
        style: pieno,
      );
    }
    // Le righe gia' decise del Viaggio dello Sciamano: le parole piccole in
    // corpo piccolo, come oggi (ordine DE voce 02).
    return Column(
      key: Key('scheda_titolo_${art.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < righe.length; i++)
          Text(
            righe[i],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: LaSchedaDellArte.stileDellaRigaDecisa(i),
          ),
      ],
    );
  }
}

/// Il Maestro di un'arte, dal catalogo; se non si trova, quello attivo.
Maestro maestroDiArte(BuildContext context, String id) {
  for (final m in Maestro.values) {
    for (final s in ArtCatalog.forMaestro(m)) {
      if (s.arts.any((a) => a.id == id)) return m;
    }
  }
  return context.read<MaestroController?>()?.activeMaestro ?? Maestro.medora;
}

/// **LA SCHEDA CHE SI INGRANDISCE E SVANISCE.** Ordine EO voce 03. Vive
/// nell'overlay della radice, col suo controllore: vedi `_entra`.
class _LUscitaDellaScheda extends StatefulWidget {
  const _LUscitaDellaScheda({
    required this.rect,
    required this.immagine,
    required this.onFinita,
  });

  final Rect rect;
  final Widget immagine;
  final VoidCallback onFinita;

  @override
  State<_LUscitaDellaScheda> createState() => _LUscitaDellaSchedaState();
}

class _LUscitaDellaSchedaState extends State<_LUscitaDellaScheda>
    with SingleTickerProviderStateMixin {
  // `preserve`: con le animazioni del telefono a zero non si accorcia.
  late final AnimationController _uscita = AnimationController(
      vsync: this,
      duration: LaSchedaDellArte.tempoDellUscita,
      animationBehavior: AnimationBehavior.preserve)
    ..forward().whenComplete(widget.onFinita);

  @override
  void dispose() {
    _uscita.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _uscita,
      builder: (_, figlio) {
        final t = Curves.easeOut.transform(_uscita.value);
        return Positioned.fromRect(
          rect: widget.rect,
          child: IgnorePointer(
            child: Opacity(
              key: const Key('scheda_in_uscita'),
              opacity: 1 - t,
              child: Transform.scale(
                scale: LaSchedaDellArte.pressione +
                    (LaSchedaDellArte.ingrandimento -
                            LaSchedaDellArte.pressione) *
                        t,
                child: figlio,
              ),
            ),
          ),
        );
      },
      child: widget.immagine,
    );
  }
}

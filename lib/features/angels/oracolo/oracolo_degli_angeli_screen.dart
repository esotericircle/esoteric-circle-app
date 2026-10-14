import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/angels/angel_catalog.dart';
import '../../../core/angels/guardian_angels.dart';
import '../../../core/assets/family_image.dart';
import '../../../core/entitlement/entitlement_service.dart';
import '../../../core/entitlement/tier.dart';
import '../../../core/identity/birth_identity.dart';
import '../../../core/identity/profile_controller.dart';
import '../../../core/maestro/maestro.dart';
import '../../../core/oracolo_angeli/i_ruoli_e_l_estrazione.dart';
import '../../../core/oracolo_angeli/il_corpus_dell_oracolo.g.dart';
import '../../../core/oracolo_angeli/l_ora_degli_angeli.dart';
import '../../../core/oracolo_angeli/la_domanda_delicata.dart';
import '../../../core/oracolo_angeli/la_lettura_dell_oracolo.dart';
import '../../../core/oracolo_angeli/le_domande_dell_oracolo.dart';
import '../../../design_system/components/il_responso_in_tre_paragrafi.dart';
import '../../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../../design_system/components/titolo_del_responso.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../../design_system/typography/paragrafi_di_lettura.dart';
import '../../account/dati_di_nascita_screen.dart';
import '../../maestri/chat/chat_openers.dart';
import '../../maestri/rotta_arte.dart';
import '../../maestri/widgets/foglio_delle_fonti.dart';
import '../../ricordi/azioni_del_responso.dart';
import '../../scene/la_scena_in_video.dart';
import '../../sigilli/regia_del_cammino.dart';
import '../../tarot/tarot_card_art.dart';
import 'la_geometria_dell_altare.dart';

/// **L'ORACOLO DEGLI ANGELI.** Ordine FU, voci FU.02, FU.03, FU.04, FU.06,
/// FU.07, FU.08 e FU.11, 15 ottobre 2026.
///
/// La persona affida una domanda ai suoi tre angeli dell'onboarding:
/// l'Angelo Custode porta la carta di cosa fare, l'Angelo del Cuore quella
/// di cosa sentire, l'Angelo dell'Intelletto quella di cosa capire. Ogni
/// carta e' uno dei 72 Angeli. Medora da' il messaggio; sotto ogni carta
/// Caligo da' il rito dell'angelo. Fonte: proposta dell'Architetto del 14
/// ottobre 2026, approvata dal fondatore: *"Si, approvo tutto"*.
///
/// **La scena** (FU.02): all'apertura parte il video della Scala di
/// Giacobbe, una volta per apertura, e si ferma sull'ultimo fotogramma, coi
/// tre dorsi sull'altare; un tocco lo salta (FU.15). La domanda affidata
/// sale lungo la scala in lettere di luce, disegnate qui e non nel video,
/// poi i tre dorsi si girano nelle tre carte vere, nella loro posizione
/// esatta sull'altare (`GeometriaDellAltare`). Una nuova consultazione nella
/// stessa apertura non rifa' partire il video.
class OracoloDegliAngeliScreen extends StatefulWidget {
  const OracoloDegliAngeliScreen({
    super.key,
    this.fabbricaDellaScena,
    this.caso,
    this.chiamata,
    this.corpus,
    this.adesso,
    this.identita,
  });

  /// La finta del lettore video, per le prove headless.
  final FabbricaDiScena? fabbricaDellaScena;

  /// Il caso dell'estrazione; nullo, uno vero.
  final Random? caso;

  /// La chiamata al modello; nulla, quella vera (le prove passano la finta).
  final ChiamataDellOracolo? chiamata;

  /// Il corpus dei messaggi; nullo, quello generato.
  final Map<String, List<String>>? corpus;

  /// L'orologio, per le prove dell'angelo dell'ora.
  final DateTime Function()? adesso;

  /// La nascita da usare; nulla, quella del profilo.
  final BirthIdentity? identita;

  static Route<void> route() => PassaggioDelCerchio.rotta(
        (_) => const SogliaArte(
          id: 'angels_oracle',
          maestro: Maestro.medora,
          child: OracoloDegliAngeliScreen(),
        ),
      );

  @override
  State<OracoloDegliAngeliScreen> createState() =>
      _OracoloDegliAngeliScreenState();
}

/// Le fasi di una consultazione.
enum _Fase { domanda, saleLaDomanda, siGirano, risposta, cura }

class _OracoloDegliAngeliScreenState extends State<OracoloDegliAngeliScreen>
    with TickerProviderStateMixin {
  late final RegiaDellaScena _regia;
  late final AnimationController _lettere = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2400));
  late final AnimationController _giro = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500));
  final _domanda = TextEditingController();
  final _scorrimento = ScrollController();
  final _inizioDellaRisposta = GlobalKey();
  late final Random _caso = widget.caso ?? Random();
  late final DateTime _quando = DateTime.now();

  _Fase _fase = _Fase.domanda;
  String _affidata = '';
  List<CartaDellOracolo> _carte = const [];
  RispostaDellOracolo? _risposta;
  int _consultazioni = 0;
  Timer? _orologio;
  bool _avviata = false;
  bool _sottoIlTitolo = false;

  Map<String, List<String>> get _corpus => widget.corpus ?? corpusDellOracolo;

  DateTime _ora() => widget.adesso?.call() ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _regia = RegiaDellaScena(widget.fabbricaDellaScena ??
        () => LettoreDiScena.vero(GeometriaDellAltare.filmato))
      ..addListener(_ridisegna);
    _domanda.addListener(_ridisegna);
    _programmaLOra();
  }

  void _ridisegna() {
    if (mounted) setState(() {});
  }

  /// L'angelo dell'ora cambia da se' ogni venti minuti (FU.08): la schermata
  /// si ridisegna all'istante del cambio.
  void _programmaLOra() {
    _orologio?.cancel();
    final adesso = _ora();
    final attesa = LOraDegliAngeli.prossimoCambio(adesso).difference(adesso);
    _orologio = Timer(attesa + const Duration(seconds: 1), () {
      _ridisegna();
      _programmaLOra();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_avviata) return;
    _avviata = true;
    unawaited(_regia.avvia(context));
  }

  @override
  void dispose() {
    _orologio?.cancel();
    _regia
      ..removeListener(_ridisegna)
      ..dispose();
    _lettere.dispose();
    _giro.dispose();
    _domanda.dispose();
    _scorrimento.dispose();
    super.dispose();
  }

  T? _forse<T>({bool osserva = false}) {
    try {
      return osserva ? context.watch<T>() : context.read<T>();
    } catch (senzaProvider) {
      debugPrint('Oracolo degli Angeli: manca $T, ripiego ($senzaProvider)');
      return null;
    }
  }

  BirthIdentity get _identita =>
      widget.identita ??
      _forse<ProfileController>()?.identity ??
      BirthIdentity.example;

  AngelTriad get _triade => GuardianAngels.forBirth(_identita.toBirthDetails());

  bool get _sceneFerma => _regia.ferma;

  /// **AFFIDARE LA DOMANDA.** Una domanda delicata non estrae carte (FU.04):
  /// Medora risponde con cura. Altrimenti si estraggono le tre carte, la
  /// domanda sale lungo la scala, la lettura parte insieme alle lettere e i
  /// dorsi si girano.
  Future<void> _affida() async {
    final domanda = _domanda.text.trim();
    if (domanda.isEmpty || _fase == _Fase.saleLaDomanda) return;
    FocusManager.instance.primaryFocus?.unfocus();
    if (LaDomandaDelicata.e(domanda)) {
      setState(() {
        _affidata = domanda;
        _fase = _Fase.cura;
        _carte = const [];
        _risposta = null;
      });
      _scorriAllaRisposta();
      return;
    }
    final carte = EstrazioneDellOracolo.estrai(_triade, _caso);
    final variante = _consultazioni;
    final tier = _forse<EntitlementService>()?.tier ?? Tier.free;
    setState(() {
      _affidata = domanda;
      _carte = carte;
      _risposta = null;
      _fase = _Fase.saleLaDomanda;
      _consultazioni++;
    });
    _giro.value = 0;
    final lettura = LaLetturaDellOracolo.leggi(
      domanda: domanda,
      carte: carte,
      corpus: _corpus,
      variante: variante,
      profonda: tier.index >= Tier.tier2.index,
      chiamata: widget.chiamata,
    );
    await _lettere.forward(from: 0);
    if (!mounted) return;
    setState(() => _fase = _Fase.siGirano);
    await _giro.forward(from: 0);
    final risposta = await lettura;
    if (!mounted) return;
    setState(() {
      _risposta = risposta;
      _fase = _Fase.risposta;
    });
    unawaited(RegiaDelCammino.dopoUnGesto(context, 'oracolo_angeli'));
    _scorriAllaRisposta();
  }

  /// **UNA NUOVA CONSULTAZIONE** nella stessa apertura: il video non riparte,
  /// le carte tornano dorsi in dissolvenza e la persona affida la domanda
  /// nuova (FU.02).
  void _nuovaDomanda() {
    _giro.value = 0;
    _lettere.value = 0;
    _domanda.clear();
    setState(() {
      _fase = _Fase.domanda;
      _risposta = null;
      _carte = const [];
    });
    _scorrimento.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
  }

  void _scorriAllaRisposta() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = _inizioDellaRisposta.currentContext;
      if (c == null || !mounted) return;
      unawaited(Scrollable.ensureVisible(c,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          alignment: 0.1));
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    // IL TOCCO CHE SALTA IL VIDEO, ordine FU voce FU.15, punto unico.
    return IlToccoCheSalta(
      inCorso: _regia.inCorso,
      onSalta: _regia.salta,
      child: Scaffold(
        backgroundColor: palette.deepest,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          // Lo stesso velo della Sinastria evolutiva: leggero all'apertura,
          // denso quando la lettura passa sotto il titolo.
          backgroundColor:
              palette.deepest.withValues(alpha: _sottoIlTitolo ? 0.9 : 0.16),
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          iconTheme: IconThemeData(color: palette.goldSoft),
          title: TitoloCheNonSiRompe(
              chiaveDelTesto: const Key('oracolo_titolo'),
              testo: 'Oracolo degli Angeli',
              righe: 1,
              stile: TypographyTokens.titoloSezione()),
          actions: [
            FoglioDelleFonti.bottone(context,
                palette: palette,
                testo: TestiDelleFonti.oracoloAngeli,
                chiave: 'oracolo_fonti'),
            const AngoloDellaBarra(),
          ],
        ),
        body: NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.depth != 0) return false;
            final sotto = n.metrics.pixels > SpacingTokens.lg;
            if (sotto != _sottoIlTitolo) setState(() => _sottoIlTitolo = sotto);
            return false;
          },
          child: ListView(
            controller: _scorrimento,
            padding: EdgeInsets.zero,
            children: [
              LayoutBuilder(
                builder: (context, vincoli) =>
                    _laScena(vincoli.maxWidth, palette),
              ),
              Padding(
                padding: const EdgeInsets.all(SpacingTokens.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _LAngeloDellOra(
                      palette: palette,
                      adesso: _ora(),
                      triade: _triade,
                      corpus: _corpus,
                    ),
                    SizedBox(
                        key: _inizioDellaRisposta, height: SpacingTokens.lg),
                    if (_fase == _Fase.cura)
                      _LaCura(palette: palette, onDiNuovo: _nuovaDomanda),
                    if (_fase == _Fase.risposta && _risposta != null) ...[
                      _IlResponso(
                        palette: palette,
                        risposta: _risposta!,
                        carte: _carte,
                        corpus: _corpus,
                        variante: _consultazioni - 1,
                        quando: _quando,
                      ),
                      const SizedBox(height: SpacingTokens.lg),
                      Center(
                        child: OutlinedButton(
                          key: const Key('oracolo_nuova_domanda'),
                          onPressed: _nuovaDomanda,
                          style: OutlinedButton.styleFrom(
                              foregroundColor: palette.goldSoft,
                              side: BorderSide(color: palette.goldSoft)),
                          child: const Text('Affida una nuova domanda'),
                        ),
                      ),
                    ],
                    const SizedBox(height: SpacingTokens.xxl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// **LA SCENA**: il fotogramma a tutta larghezza, il video sopra finche'
  /// gira, i tre dorsi sull'altare quando la scena e' ferma, le lettere di
  /// luce, e la domanda sopra la scena.
  Widget _laScena(double w, MaestroPalette palette) {
    final h = GeometriaDellAltare.altezza(w);
    final cima = MediaQuery.paddingOf(context).top + kToolbarHeight;
    return SizedBox(
      key: const Key('oracolo_scena'),
      width: w,
      height: h,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: Image.asset(
              _sceneFerma
                  ? GeometriaDellAltare.ultimoFotogramma
                  : GeometriaDellAltare.primoFotogramma,
              key: const Key('oracolo_fotogramma'),
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
            ),
          ),
          if (_regia.filmatoInScena)
            Positioned.fill(
              child: IlFilmatoCheSfuma(
                key: const Key('oracolo_filmato'),
                saltato: _regia.saltata,
                child: _regia.disegna(),
              ),
            ),
          if (_sceneFerma)
            for (var i = 0; i < 3; i++)
              _CartaSullAltare(
                indice: i,
                larghezza: w,
                appare: !_regia.filmatoInScena || _regia.saltata,
                carta: _carte.length == 3 ? _carte[i] : null,
                giro: _giro,
                palette: palette,
              ),
          if (_fase == _Fase.saleLaDomanda)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  key: const Key('oracolo_lettere_di_luce'),
                  painter: _LettereDiLuce(
                    testo: _affidata,
                    progresso: _lettere,
                    scala: GeometriaDellAltare.scala(w),
                    colore: palette.goldSoft,
                  ),
                ),
              ),
            ),
          if (_sceneFerma && _fase == _Fase.domanda)
            Positioned(
              left: SpacingTokens.md,
              right: SpacingTokens.md,
              top: cima + SpacingTokens.xs,
              child: LaScenaFermaCheAppare(
                appare: true,
                child: _LaDomanda(
                  palette: palette,
                  controllo: _domanda,
                  onAffida: _affida,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// **UNA CARTA SULL'ALTARE**: il dorso posato in prospettiva esattamente
/// dove sta nel fotogramma, che si gira nella carta vera.
class _CartaSullAltare extends StatelessWidget {
  const _CartaSullAltare({
    required this.indice,
    required this.larghezza,
    required this.appare,
    required this.carta,
    required this.giro,
    required this.palette,
  });

  final int indice;
  final double larghezza;
  final bool appare;
  final CartaDellOracolo? carta;
  final Animation<double> giro;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final r = GeometriaDellAltare.cartaDritta(indice, larghezza);
    return Positioned.fromRect(
      rect: r,
      child: LaScenaFermaCheAppare(
        appare: appare,
        child: AnimatedBuilder(
          animation: giro,
          builder: (context, _) {
            final c = carta;
            // Le tre carte si girano una dopo l'altra, ognuna in un terzo
            // del tempo; la carta coperta (Intelletto senza ora) non si gira.
            final t = c == null || c.coperta
                ? 0.0
                : ((giro.value * 3) - indice).clamp(0.0, 1.0);
            final faccia = t > 0.5;
            return Transform(
              alignment: Alignment.bottomCenter,
              transform:
                  GeometriaDellAltare.posa(larghezza, giro: faccia ? t - 1 : t),
              child: faccia
                  ? LaCartaDellAngelo(
                      key: Key('oracolo_carta_${c!.ruolo.name}'),
                      angelo: c.angelo,
                      palette: palette,
                    )
                  : Image.asset(GeometriaDellAltare.dorso,
                      key: Key('oracolo_dorso_$indice'),
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.medium),
            );
          },
        ),
      ),
    );
  }
}

/// **LA CARTA DI UN ANGELO**: l'arte coi cartigli vuoti, e il numero e il
/// nome sovrapposti in Flutter, come nel resto del mazzo dei 72 (FU.03). Le
/// placche sono quelle della cornice madre, la stessa dei tarocchi
/// (`TarotFrame`).
class LaCartaDellAngelo extends StatelessWidget {
  const LaCartaDellAngelo({
    super.key,
    required this.angelo,
    required this.palette,
  });

  final Angel angelo;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, vincoli) {
      final w = vincoli.maxWidth;
      final h = vincoli.hasBoundedHeight ? vincoli.maxHeight : w * 1.5;
      Rect px(Rect n) =>
          Rect.fromLTRB(n.left * w, n.top * h, n.right * w, n.bottom * h);
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            FamilyImage.full(AssetFamily.angeli, angelo.artStem),
            fit: BoxFit.fill,
            filterQuality: FilterQuality.medium,
          ),
          if (w > SpacingTokens.xxl)
            Positioned.fromRect(
              rect: px(TarotFrame.cartiglioNumero),
              child:
                  CartiglioTesto(righe: ['${angelo.number}'], palette: palette),
            ),
          if (w > SpacingTokens.xxl)
            Positioned.fromRect(
              rect: px(TarotFrame.cartiglioNome),
              child: CartiglioTesto(righe: [angelo.name], palette: palette),
            ),
        ],
      );
    });
  }
}

/// **LE LETTERE DI LUCE**: la domanda affidata si scioglie in lettere che
/// salgono lungo la scala, dall'altare alla cima (FU.02). Disegno di
/// Flutter con la domanda vera, non video.
class _LettereDiLuce extends CustomPainter {
  _LettereDiLuce({
    required this.testo,
    required this.progresso,
    required this.scala,
    required this.colore,
  }) : super(repaint: progresso);

  final String testo;
  final Animation<double> progresso;
  final double scala;
  final Color colore;

  /// La scala nel fotogramma: il centro sta a meta' larghezza, l'altare a
  /// 1530, la cima a 0.
  static const double _centro = 540;
  static const double _partenza = 1530;

  @override
  void paint(Canvas canvas, Size size) {
    final lettere = testo.characters.where((c) => c.trim().isNotEmpty).toList();
    if (lettere.isEmpty) return;
    final t = progresso.value;
    final n = lettere.length;
    for (var i = 0; i < n; i++) {
      // Ogni lettera parte poco dopo la precedente e sale in 60% del tempo.
      final inizio = 0.4 * i / n;
      final locale = ((t - inizio) / 0.6).clamp(0.0, 1.0);
      if (locale <= 0) continue;
      final y = (_partenza - locale * _partenza) * scala;
      final ondeggio = sin((locale * 6) + i) * 18 * scala;
      final x = _centro * scala + ondeggio;
      final opacita = locale < 0.15
          ? locale / 0.15
          : (1 - (locale - 0.15) / 0.85).clamp(0.0, 1.0);
      final tp = TextPainter(
        text: TextSpan(
          text: lettere[i],
          style: TypographyTokens.titoloScheda().copyWith(
            color: colore.withValues(alpha: opacita),
            shadows: [
              Shadow(color: colore.withValues(alpha: opacita), blurRadius: 12),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_LettereDiLuce vecchio) =>
      vecchio.testo != testo || vecchio.colore != colore;
}

/// **LA DOMANDA**, sopra la scena: scritta o scelta fra quelle proposte.
class _LaDomanda extends StatefulWidget {
  const _LaDomanda({
    required this.palette,
    required this.controllo,
    required this.onAffida,
  });

  final MaestroPalette palette;
  final TextEditingController controllo;
  final VoidCallback onAffida;

  @override
  State<_LaDomanda> createState() => _LaDomandaState();
}

class _LaDomandaState extends State<_LaDomanda> {
  TemaDellOracolo _tema = TemaDellOracolo.amore;

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    return Container(
      key: const Key('oracolo_domanda'),
      padding: const EdgeInsets.all(SpacingTokens.sm),
      decoration: BoxDecoration(
        color: palette.deepest.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        border: Border.all(color: palette.goldSoft.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('oracolo_campo_domanda'),
                  controller: widget.controllo,
                  minLines: 1,
                  maxLines: 2,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => widget.onAffida(),
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Scrivi la tua domanda agli angeli',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              IconButton(
                key: const Key('oracolo_affida'),
                tooltip: 'Affida la domanda',
                color: palette.goldSoft,
                onPressed: widget.controllo.text.trim().isEmpty
                    ? null
                    : widget.onAffida,
                icon: const Icon(Icons.auto_awesome_rounded),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xxs),
          SizedBox(
            height: SpacingTokens.xl,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final t in TemaDellOracolo.values)
                  Padding(
                    padding: const EdgeInsets.only(right: SpacingTokens.xxs),
                    child: ChoiceChip(
                      key: Key('oracolo_tema_${t.name}'),
                      label: Text(t.nome),
                      selected: t == _tema,
                      onSelected: (_) => setState(() => _tema = t),
                    ),
                  ),
              ],
            ),
          ),
          for (final d in _tema.domande)
            TextButton(
              key: Key('oracolo_proposta_${_tema.domande.indexOf(d)}'),
              style: TextButton.styleFrom(
                foregroundColor: palette.goldSoft,
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: SpacingTokens.xxs),
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () {
                widget.controllo.text = d;
                widget.controllo.selection =
                    TextSelection.collapsed(offset: d.length);
              },
              child: Text(d, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
        ],
      ),
    );
  }
}

/// **L'ANGELO DELL'ORA E IL MESSAGGIO DEL GIORNO** (FU.08), senza modello.
class _LAngeloDellOra extends StatelessWidget {
  const _LAngeloDellOra({
    required this.palette,
    required this.adesso,
    required this.triade,
    required this.corpus,
  });

  final MaestroPalette palette;
  final DateTime adesso;
  final AngelTriad triade;
  final Map<String, List<String>> corpus;

  @override
  Widget build(BuildContext context) {
    final angelo = LOraDegliAngeli.dellOra(adesso);
    final delGiorno = LOraDegliAngeli.messaggioDelGiorno(
        triade: triade, giorno: adesso, corpus: corpus);
    return Container(
      key: const Key('oracolo_angelo_dell_ora'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        border: Border.all(color: palette.gold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: SpacingTokens.xxl + SpacingTokens.sm,
                height: (SpacingTokens.xxl + SpacingTokens.sm) * 1.5,
                child: LaCartaDellAngelo(angelo: angelo, palette: palette),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('L\'angelo di quest\'ora',
                        style: TypographyTokens.etichetta()
                            .copyWith(color: palette.goldSoft)),
                    const SizedBox(height: SpacingTokens.xxs),
                    Text(angelo.name,
                        key: const Key('oracolo_nome_dell_ora'),
                        style: TypographyTokens.titoloScheda()
                            .copyWith(color: ColorTokens.textPrimary)),
                    Text(LOraDegliAngeli.momentoDelRito(angelo),
                        style: TypographyTokens.didascalia()
                            .copyWith(color: ColorTokens.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          if (delGiorno != null) ...[
            const SizedBox(height: SpacingTokens.md),
            Text('Il messaggio di oggi, dal tuo ${delGiorno.ruolo.nome}',
                key: const Key('oracolo_messaggio_del_giorno'),
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft)),
            const SizedBox(height: SpacingTokens.xxs),
            ParagrafiDiLettura(
                testo: delGiorno.testo,
                stile: TypographyTokens.lettura()
                    .copyWith(color: ColorTokens.textPrimary)),
          ],
        ],
      ),
    );
  }
}

/// **LA RISPOSTA DI CURA** per le domande delicate (FU.04): nessuna carta.
class _LaCura extends StatelessWidget {
  const _LaCura({required this.palette, required this.onDiNuovo});

  final MaestroPalette palette;
  final VoidCallback onDiNuovo;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('oracolo_cura'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TitoloDelResponso(
          chiaveDelTesto: const Key('oracolo_titolo_cura'),
          testo: LaDomandaDelicata.titolo,
          allineamento: TextAlign.center,
          aCapoFraLeParole: true,
          stile: TypographyTokens.titoloSezione()
              .copyWith(color: palette.goldSoft, height: 1.25),
        ),
        const SizedBox(height: SpacingTokens.sm),
        ParagrafiDiLettura(
            testo: LaDomandaDelicata.paragrafi.join('\n\n'),
            stile: TypographyTokens.lettura()
                .copyWith(color: ColorTokens.textPrimary)),
        const SizedBox(height: SpacingTokens.lg),
        Center(
          child: OutlinedButton(
            key: const Key('oracolo_cura_torna'),
            onPressed: onDiNuovo,
            style: OutlinedButton.styleFrom(
                foregroundColor: palette.goldSoft,
                side: BorderSide(color: palette.goldSoft)),
            child: const Text('Torna alla domanda'),
          ),
        ),
      ],
    );
  }
}

/// **IL RESPONSO** (FU.06): il titolo che e' gia' la risposta, i tre
/// paragrafi col secondo nel riquadro, la Lunga nel suo riquadro, il Da dove
/// viene; poi le tre carte, ognuna col suo Parlane e il suo rito.
class _IlResponso extends StatelessWidget {
  const _IlResponso({
    required this.palette,
    required this.risposta,
    required this.carte,
    required this.corpus,
    required this.variante,
    required this.quando,
  });

  final MaestroPalette palette;
  final RispostaDellOracolo risposta;
  final List<CartaDellOracolo> carte;
  final Map<String, List<String>> corpus;
  final int variante;
  final DateTime quando;

  /// **DA DOVE VIENE**, una riga che dice anche chi scrive il legame.
  static const String daDoveViene =
      'I 72 nomi vengono dal versetto triplice dell\'Esodo, 14, 19-21; i '
      'loro cori e i loro salmi da Lenain, La Science cabalistique, 1823. I '
      'tuoi tre angeli vengono dal grado del Sole, dal giorno e dall\'ora '
      'della tua nascita. Il legame con la tua domanda lo scrive Medora.';

  @override
  Widget build(BuildContext context) {
    final perIlDiario = ResponsoDaCustodire(
      arte: 'oracolo_angeli',
      titolo: risposta.titolo,
      testo: risposta.paragrafi.join('\n\n'),
      perIlMaestro: [
        for (final c in carte)
          if (!c.coperta) '${c.ruolo.nome}: ${c.angelo.name}',
      ].join('\n'),
      dati: {
        'angeli': [
          for (final c in carte)
            if (!c.coperta) c.angelo.number.toString()
        ].join(','),
      },
    );
    return Column(
      key: const Key('oracolo_responso'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TitoloDelResponso(
          chiaveDelTesto: const Key('oracolo_titolo_del_responso'),
          testo: risposta.titolo,
          allineamento: TextAlign.center,
          aCapoFraLeParole: true,
          stile: TypographyTokens.titoloSezione()
              .copyWith(color: palette.goldSoft, height: 1.25),
        ),
        const SizedBox(height: SpacingTokens.sm),
        ResponsoInTreParagrafi(
          paragrafi: risposta.paragrafi,
          stile: TypographyTokens.lettura()
              .copyWith(color: ColorTokens.textPrimary),
          palette: palette,
          approfondimento: risposta.approfondimento,
          daDoveViene: daDoveViene,
        ),
        if (!risposta.dalModello) ...[
          const SizedBox(height: SpacingTokens.sm),
          Text(
            'Medora oggi risponde coi soli messaggi delle carte: il legame '
            'con la tua domanda arriva quando la rete torna.',
            key: const Key('oracolo_solo_corpus'),
            style: TypographyTokens.didascalia().copyWith(
                color: ColorTokens.textSecondary, fontStyle: FontStyle.italic),
          ),
        ],
        const SizedBox(height: SpacingTokens.lg),
        for (var i = 0; i < carte.length; i++) ...[
          _LaBollaDellaCarta(
            palette: palette,
            carta: carte[i],
            paragrafo: risposta.paragrafi[i],
            rito: corpus[LOraDegliAngeli.chiaveDelRito(carte[i].angelo)],
            variante: variante,
          ),
          const SizedBox(height: SpacingTokens.md),
        ],
        AzioniDelResponso(
          palette: palette,
          maestro: Maestro.medora,
          dorato: true,
          responso: perIlDiario,
          quando: quando,
          aperturaDellaChat: ChatOpeners.oracoloAngeli(carte.first.angelo.name,
              carte.first.ruolo.posizione.toLowerCase(), risposta.titolo),
        ),
      ],
    );
  }
}

/// **LA BOLLA DI UNA CARTA**: il medaglione del ruolo col nome dell'angelo
/// della persona che la porta, la carta, il Parlane con Medora (come nella
/// Stesa) e, chiuso finche' non lo apri, il rito con Caligo (FU.07).
class _LaBollaDellaCarta extends StatelessWidget {
  const _LaBollaDellaCarta({
    required this.palette,
    required this.carta,
    required this.paragrafo,
    required this.rito,
    required this.variante,
  });

  final MaestroPalette palette;
  final CartaDellOracolo carta;
  final String paragrafo;
  final List<String>? rito;
  final int variante;

  @override
  Widget build(BuildContext context) {
    const lato = SpacingTokens.xxl + SpacingTokens.lg;
    return Container(
      key: Key('oracolo_bolla_${carta.ruolo.name}'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  ClipOval(
                    child: Image.asset(carta.ruolo.medaglione,
                        width: SpacingTokens.xxl,
                        height: SpacingTokens.xxl,
                        fit: BoxFit.cover),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  SizedBox(
                    width: lato,
                    height: lato * 1.5,
                    child: carta.coperta
                        ? Image.asset(GeometriaDellAltare.dorso,
                            fit: BoxFit.fill)
                        : LaCartaDellAngelo(
                            angelo: carta.angelo, palette: palette),
                  ),
                ],
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(carta.ruolo.posizione.toUpperCase(),
                        style: TypographyTokens.etichetta()
                            .copyWith(color: palette.goldSoft)),
                    const SizedBox(height: SpacingTokens.xxs),
                    Text(carta.coperta ? 'Carta coperta' : carta.angelo.name,
                        style: TypographyTokens.titoloScheda()
                            .copyWith(color: ColorTokens.textPrimary)),
                    const SizedBox(height: SpacingTokens.xxs),
                    Text(
                        carta.portatore == null
                            ? 'La porta il tuo ${carta.ruolo.nome}, che si '
                                'rivela con l\'ora di nascita'
                            : 'La porta il tuo ${carta.ruolo.nome}, '
                                '${carta.portatore!.name}',
                        style: TypographyTokens.didascalia()
                            .copyWith(color: ColorTokens.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          if (carta.coperta) ...[
            const SizedBox(height: SpacingTokens.sm),
            Center(
              child: OutlinedButton(
                key: const Key('oracolo_aggiungi_l_ora'),
                onPressed: () =>
                    Navigator.of(context).push(DatiDiNascitaScreen.route()),
                style: OutlinedButton.styleFrom(
                    foregroundColor: palette.goldSoft,
                    side: BorderSide(color: palette.goldSoft)),
                child: const Text('Aggiungi l\'ora di nascita'),
              ),
            ),
          ] else ...[
            const SizedBox(height: SpacingTokens.sm),
            ParlaneConMaestroCompatto(
              keyDelPulsante: Key('oracolo_parlane_${carta.ruolo.name}'),
              palette: palette,
              maestro: Maestro.medora,
              frase: paragrafo,
              aperturaDellaChat: ChatOpeners.oracoloAngeli(carta.angelo.name,
                  carta.ruolo.posizione.toLowerCase(), paragrafo),
            ),
            const SizedBox(height: SpacingTokens.xs),
            _IlRitoConCaligo(
              angelo: carta.angelo,
              rito: rito,
              variante: variante,
              chiave: carta.ruolo.name,
            ),
          ],
        ],
      ),
    );
  }
}

/// **IL RITO CON CALIGO**, chiuso finche' la persona non lo apre (FU.07): il
/// salmo con la numerazione e l'edizione dichiarate, il momento dei venti
/// minuti dell'angelo in ora locale, e un testo breve nella voce di Caligo.
/// Nessun sigillo dell'angelo: la sua fonte non e' verificata.
class _IlRitoConCaligo extends StatefulWidget {
  const _IlRitoConCaligo({
    required this.angelo,
    required this.rito,
    required this.variante,
    required this.chiave,
  });

  final Angel angelo;
  final List<String>? rito;
  final int variante;
  final String chiave;

  @override
  State<_IlRitoConCaligo> createState() => _IlRitoConCaligoState();
}

class _IlRitoConCaligoState extends State<_IlRitoConCaligo> {
  bool _aperto = false;

  @override
  Widget build(BuildContext context) {
    final caligo = MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo));
    final rito = widget.rito;
    final testo = rito == null || rito.isEmpty
        ? null
        : rito[widget.variante % rito.length];
    final salmo = widget.angelo.lore?.psalm;
    return Container(
      decoration: BoxDecoration(
        color: caligo.deepest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
        border: Border.all(color: caligo.gold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextButton.icon(
            key: Key('oracolo_rito_${widget.chiave}'),
            onPressed: () => setState(() => _aperto = !_aperto),
            style: TextButton.styleFrom(
                foregroundColor: caligo.goldSoft,
                alignment: Alignment.centerLeft),
            icon: Icon(_aperto
                ? Icons.expand_less_rounded
                : Icons.expand_more_rounded),
            label: const Text('Il rito con Caligo'),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: !_aperto
                ? const SizedBox(width: double.infinity)
                : Padding(
                    key: Key('oracolo_rito_aperto_${widget.chiave}'),
                    padding: const EdgeInsets.fromLTRB(SpacingTokens.md, 0,
                        SpacingTokens.md, SpacingTokens.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Il momento: '
                            '${LOraDegliAngeli.momentoDelRito(widget.angelo)}',
                            style: TypographyTokens.etichetta()
                                .copyWith(color: caligo.goldSoft)),
                        if (salmo != null) ...[
                          const SizedBox(height: SpacingTokens.xs),
                          Text(salmo,
                              style: TypographyTokens.didascalia().copyWith(
                                  color: ColorTokens.textSecondary,
                                  fontStyle: FontStyle.italic)),
                        ],
                        if (testo != null) ...[
                          const SizedBox(height: SpacingTokens.xs),
                          ParagrafiDiLettura(
                              testo: testo,
                              stile: TypographyTokens.lettura()
                                  .copyWith(color: ColorTokens.textPrimary)),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

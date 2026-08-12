import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../core/sigilli/ora_rituale.dart';

import '../sigilli/regia_del_cammino.dart';

import '../../core/rituals/daily_elements.dart';
import '../../design_system/components/le_tre_righe_del_rito.dart';
import '../../design_system/components/riga_del_dono.dart';

import '../../core/astro/moon_phase.dart';
import '../../design_system/components/luna_reale.dart';
import '../../core/identity/birth_moon.dart';
import '../../core/maestro/maestro.dart';
import '../../core/rituals/daily_rituals.dart';
import '../../core/rituals/dream_rite_corpus.dart';
import '../../core/rituals/filo_del_giorno.dart';
import '../../core/rituals/sunset_rune.dart';
import '../../core/rituals/sunset_rune_memory.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/zodiac_figures.dart';
import '../../design_system/components/stelle_da_unire.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/breath_detector.dart';
import '../maestri/aura/meditation/meditation_audio.dart';
import '../tarot/stesa_senses.dart' show TiltListener;
import 'dream_rite_card.dart';
import '../../../design_system/components/borsellino.dart';
import '../../design_system/components/titolo_che_non_si_rompe.dart';
import '../maestri/rotta_arte.dart';

/// Rito del Sogno, ex Rito della Buonanotte: a rotazione fra i tre Maestri di
/// giorno in giorno, come il Rito dell'Alba.
///
/// Guarda al passato e al presente della giornata appena conclusa, mai al
/// futuro. Si apre nella foschia, che si dirada col fiato; emerge il cosmo
/// notturno reale di questo momento; si uniscono le stelle della costellazione
/// del segno in cui si trova la Luna adesso, letta da NightSky; dalla figura
/// unita scende il saluto della notte, ancorato a segno e fase reali.
/// Deterministico, nessuna AI a runtime.
///
/// La scena vive DENTRO il cosmo condiviso a tutto schermo (`CosmosBackground`),
/// non dentro un riquadro: la Luna, le stelle vicine e la costellazione stanno
/// su piani di parallasse diversi sopra quel cielo.
class DreamRiteScreen extends StatefulWidget {
  DreamRiteScreen({
    super.key,
    this.now,
    TonePlayer? player,
  }) : player = player ?? LettoreToniReale();

  final DateTime? now;

  /// Il lettore dei toni.
  ///
  /// Di default e' quello REALE: prima era silenzioso, quindi il rito prometteva
  /// un battito che non usciva mai dal telefono. I test continuano a iniettare
  /// il lettore muto, ed e' proprio per questo che il difetto non si vedeva.
  final TonePlayer player;

  static Route<void> route({
    DateTime? now,
    TonePlayer? player,
  }) =>
      MaterialPageRoute<void>(
        builder: (_) =>
            MaestroScope(child: DreamRiteScreen(now: now, player: player)),
      );

  @override
  State<DreamRiteScreen> createState() => _DreamRiteScreenState();
}

enum _Fase { nebbia, cielo, messaggio }

class _DreamRiteScreenState extends State<DreamRiteScreen>
    with TickerProviderStateMixin {
  late final DateTime _date = widget.now ?? DateTime.now();
  late final Maestro _maestro = DailyRituals.nightMaestro(_date);
  late final MaestroPalette _palette = MaestroPalette.forKey(ThemeKey.of(_maestro));
  late final BirthMoon _luna = DreamRiteCorpus.lunaDi(_date);
  late final ZodiacConstellation _figura =
      kZodiacConstellations.firstWhere((c) => c.sign == _luna.sign);

  /// Il respiro lento del cielo: pulsazione delle stelle e scintillio dei fili.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();


  final BreathDetector _fiato = BreathDetector();
  final TiltListener _tilt = TiltListener();
  StreamSubscription<double>? _livelli;
  Timer? _battito;

  _Fase _fase = _Fase.nebbia;

  /// Quanto la foschia si e' diradata, da 0 (fitta) a 1 (aperta).
  double _nebbia = 0;
  double _micLivello = 0;
  double _spintaDito = 0;

  /// LO STATO DELLA FIGURA arriva dal componente unico StelleDaUnire,
  /// ordine L voce 3: qui restano i due specchi che i testi leggono.
  int _unite = 0;
  bool _completa = false;

  /// La figura del segno della Luna, nella lingua del componente unico.
  late final FiguraDaUnire _figuraDaUnire = FiguraDaUnire(
    punti: [
      for (var i = 0; i < _figura.points.length; i++)
        PuntoDaUnire('stella ${i + 1}', _figura.points[i]),
    ],
    fili: _figura.edges,
  );

  /// Lo spostamento della vista col dito, quando il giroscopio non c'e'.
  Offset _panDito = Offset.zero;

  bool _riduciMovimento = false;
  bool _suono = false;

  /// La runa portata dentro la notte dalla Runa del Tramonto, se stasera l'hai
  /// fatta. Chiude l'arco fra i due Doni. Null se manca, e allora il Sogno si
  /// comporta esattamente come prima.
  String? _runaTramonto;

  @override
  void initState() {
    super.initState();
    _tilt.start();
    _tilt.addListener(_ridisegna);
    _avviaFiato();
    _battito = Timer.periodic(const Duration(milliseconds: 60), _passoFiato);
    _leggiCerniera();
  }

  Future<void> _leggiCerniera() async {
    final ultima = await SunsetRuneMemory.ultimaPerCerniera();
    if (ultima != null &&
        mounted &&
        // Solo se la runa e' della stessa sera, il giorno rituale coincide.
        ultima.giorno == SunsetRune.iso(SunsetRune.giornoRituale(_date))) {
      setState(() => _runaTramonto = ultima.rune);
    }
    // LA PAROLA DEL MATTINO TORNA QUI, ordine P voce 18.
    //
    // **E' cio' che rende il Sogno la chiusura del giorno invece di un rito
    // autoconcluso.** La forma c'era gia': Buonanotte, la costellazione, il
    // saluto di Caligo, la card da condividere. Mancava che RACCOGLIESSE la
    // giornata. Con la parola dell'alba e la runa del tramonto dentro, il rito
    // della buonanotte diventa quello che il nome promette.
    final parola = await FiloDelGiorno.parolaDiStamattina(_date);
    if (parola != null && mounted) {
      setState(() => _parolaDiStamattina = parola);
    }
  }

  /// La parola ricevuta all'alba di oggi, se il rito e' stato compiuto.
  String? _parolaDiStamattina;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _riduciMovimento = MediaQuery.of(context).disableAnimations;
    if (_riduciMovimento && _pulse.isAnimating) _pulse.stop();
  }

  @override
  void dispose() {
    _battito?.cancel();
    _livelli?.cancel();
    _fiato.dispose();
    _tilt.removeListener(_ridisegna);
    _tilt.dispose();
    _pulse.dispose();
    if (_suono) widget.player.stop();
    super.dispose();
  }

  void _ridisegna() {
    if (mounted) setState(() {});
  }

  // Il fiato reale, quando il microfono c'e'. Se manca, resta il dito.
  Future<void> _avviaFiato() async {
    final acceso = await _fiato.start();
    if (!acceso || !mounted) return;
    _livelli = _fiato.level.listen((v) => _micLivello = v);
  }

  double get _reazione => math.max(_micLivello, _spintaDito);

  void _passoFiato(Timer _) {
    if (_fase != _Fase.nebbia || !mounted) return;
    final prima = _nebbia;
    if (_reazione > 0.10) {
      _nebbia = (_nebbia + 0.035).clamp(0.0, 1.0);
    } else if (_nebbia > 0 && _nebbia < 1) {
      _nebbia = (_nebbia - 0.004).clamp(0.0, 1.0);
    }
    _spintaDito = (_spintaDito - 0.06).clamp(0.0, 1.0);
    if (_nebbia >= 1 && prima < 1) {
      _apriIlCielo();
    } else if (_nebbia != prima) {
      setState(() {});
    }
  }

  void _apriIlCielo() {
    if (_fase != _Fase.nebbia) return;
    // Il fiato ha finito il suo compito: si spegne il battito e il microfono.
    _battito?.cancel();
    _battito = null;
    _livelli?.cancel();
    _livelli = null;
    _fiato.stop();
    setState(() {
      _nebbia = 1;
      _fase = _Fase.cielo;
    });
  }

  void _allUnione(int indice) {
    setState(() => _unite = indice + 1);
  }

  void _allaFiguraCompleta() {
    setState(() => _completa = true);
    // IL SOGNO ENTRA NEL CAMMINO, ordine P voce 35: la figura si e' composta,
    // il rito e' compiuto.
    unawaited(RegiaDelCammino.dopoUnGesto(context, 'sogno',
        oraRituale: OraRituale.diAdesso()));
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _fase = _Fase.messaggio);
    });
  }

  Future<void> _cambiaSuono() async {
    setState(() => _suono = !_suono);
    if (_suono) {
      await widget.player.play(MeditationPreset.thetaBeat);
    } else {
      await widget.player.stop();
    }
  }

  Offset get _spostamento {
    if (_riduciMovimento) return Offset.zero;
    return Offset(_tilt.x, _tilt.y) * 320 + _panDito;
  }

  /// La fascia di cielo in cui vive la costellazione, dall'alto dello schermo.
  static const double _fasciaCielo = 0.46;

  @override
  Widget build(BuildContext context) {
    final saluto = DreamRiteCorpus.saluto(_date);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: _palette.goldSoft),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        // **IL TITOLO NON SI ROMPE**, ordine S voce 05: a capo fra le parole,
        // la misura scende solo quanto serve, e non si tronca mai. Col
        // borsellino nella riga delle azioni lo spazio del titolo si e'
        // ristretto, e un `Text` nudo qui torna a mettere i puntini.
        title: TitoloCheNonSiRompe(
            testo: 'Rito del Sogno',
            stile: TypographyTokens.display(size: 20)),
        actions: [
        // IL BORSELLINO, ordine S voce 06: stesso segno, stesso angolo, in
        // ogni schermata della pratica. Un saldo che appare e scompare non
        // si impara.
          const AngoloDellaBarra(),
          IconButton(
            key: const Key('dream_sources'),
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Da dove nasce questo dono',
            onPressed: _mostraProvenienza,
          ),
        ],
      ),
      // Il cosmo condiviso a tutto schermo: nero profondo verso l'indaco, campo
      // stellare denso, nebulose soffuse, parallasse a piu' piani. La scena del
      // Sogno vive dentro questo cielo, non sopra un riquadro.
      body: CosmosBackground(
        seed: 15,
        showZodiac: false,
        // I dischi dei pianeti del cosmo restano spenti qui: la scena mette in
        // campo la Luna reale e un suo pianeta lontano, senza sovrapporre sfere.
        showPlanets: false,
        child: LayoutBuilder(
          builder: (context, box) {
            final w = box.maxWidth;
            final h = box.maxHeight;
            return Stack(
              children: [
                // Luna reale e stelle vicine, su piani di parallasse diversi.
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, _) => CustomPaint(
                        painter: _ScenaPainter(
                          palette: _palette,
                          fase: _luna.phase,
                          t: _riduciMovimento ? 0.22 : _pulse.value,
                          luce: _nebbia,
                          quieta: _fase == _Fase.messaggio,
                          spostamento: _spostamento,
                        ),
                      ),
                    ),
                  ),
                ),
                // La costellazione del segno della Luna, coi fili di luce.
                if (_fase != _Fase.nebbia) ..._costellazione(w, h),
                // La foschia cosmica dell'apertura, che si dirada.
                if (_fase == _Fase.nebbia)
                  Positioned.fill(
                    child: GestureDetector(
                      key: const Key('dream_fog'),
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: (d) => _spintaDito =
                          (_spintaDito + d.delta.distance / 90).clamp(0.0, 1.0),
                      child: AnimatedBuilder(
                        animation: _pulse,
                        builder: (context, _) => CustomPaint(
                          painter: _FoschiaPainter(
                            palette: _palette,
                            apertura: _nebbia,
                            t: _riduciMovimento ? 0.22 : _pulse.value,
                          ),
                        ),
                      ),
                    ),
                  ),
                // Il testo del rito, sotto la fascia di cielo.
                Positioned(
                  left: 0,
                  right: 0,
                  top: h * _fasciaCielo,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      key: const Key('dream_rite'),
                      padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, 0,
                          SpacingTokens.lg, SpacingTokens.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_fase == _Fase.nebbia) ..._nelBuio(),
                          if (_fase == _Fase.cielo) ..._sottoIlCielo(),
                          if (_fase == _Fase.messaggio) ..._ilSaluto(saluto),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- La costellazione: fili di luce e stelle toccabili ---

  List<Widget> _costellazione(double w, double h) {
    // Il piano della costellazione si muove meno del primo piano.
    final off = _spostamento * 0.55;
    return [
      // Il ripiego a dito: si sposta la vista trascinando, quando il giroscopio
      // non c'e'. Sta sotto le stelle, cosi' il tocco sulla stella vince.
      if (!_riduciMovimento)
        Positioned.fill(
          child: GestureDetector(
            key: const Key('dream_pan'),
            behavior: HitTestBehavior.translucent,
            onPanUpdate: (d) => setState(() {
              _panDito = Offset(
                (_panDito.dx + d.delta.dx).clamp(-46.0, 46.0),
                (_panDito.dy + d.delta.dy).clamp(-46.0, 46.0),
              );
            }),
          ),
        ),
      // IL COMPONENTE UNICO, ordine L voce 3: fili, stelle grandi, la stella
      // che chiama il tocco e le zone toccabili vivono in StelleDaUnire, lo
      // stesso della rivelazione dell'Animale Guida. Qui restano la fascia
      // di cielo e la parallasse, che sono della scena.
      Positioned.fill(
        child: StelleDaUnire(
          figura: _figuraDaUnire,
          palette: _palette,
          keyPrefix: 'dream_star',
          spostamento: off,
          mappa: (p) => Offset(
            (0.12 + p.dx * 0.76) * w + off.dx,
            (0.13 + p.dy * 0.30) * h + off.dy,
          ),
          onTocco: _allUnione,
          onCompleta: _allaFiguraCompleta,
        ),
      ),
    ];
  }

  // --- I tre momenti sotto la fascia di cielo ---

  List<Widget> _nelBuio() => [
        Text(DreamRiteCorpus.invitoNebbia(_maestro),
            key: const Key('dream_invito'),
            textAlign: TextAlign.center,
            style: TypographyTokens.body(size: 16)
                .copyWith(color: ColorTokens.textPrimary, height: 1.55)),
        if (_runaTramonto != null) ...[
          const SizedBox(height: SpacingTokens.sm),
          Text('Porti dentro la notte la runa $_runaTramonto: '
              'lasciala parlare mentre chiudi il giorno.',
              key: const Key('dream_runa_tramonto'),
              textAlign: TextAlign.center,
              style: TypographyTokens.label(size: 12).copyWith(
                  color: _palette.goldSoft, letterSpacing: 0.3, height: 1.45)),
        ],
        // LA PAROLA DEL MATTINO, richiamata la sera. Ordine P voce 18.
        if (_parolaDiStamattina != null) ...[
          const SizedBox(height: SpacingTokens.sm),
          Text(FiloDelGiorno.richiamoDellaParola(_parolaDiStamattina!),
              key: const Key('dream_parola_del_mattino'),
              textAlign: TextAlign.center,
              style: TypographyTokens.didascalia().copyWith(
                  color: _palette.goldSoft, height: 1.45)),
        ],
        const SizedBox(height: SpacingTokens.md),
        _Riga(
          palette: _palette,
          icona: Icons.air,
          testo: 'Respira piano verso il telefono, oppure passa il dito sulla '
              'foschia: il ripiego vale sempre.',
        ),
        const SizedBox(height: SpacingTokens.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          child: LinearProgressIndicator(
            key: const Key('dream_breath_bar'),
            value: _nebbia,
            minHeight: 6,
            backgroundColor: _palette.deepest.withValues(alpha: 0.6),
            valueColor: AlwaysStoppedAnimation<Color>(_palette.goldSoft),
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        TextButton(
          key: const Key('dream_fog_skip'),
          onPressed: _apriIlCielo,
          child: Text('Dirada la nebbia',
              style: TypographyTokens.label(size: 12)
                  .copyWith(color: _palette.goldSoft)),
        ),
      ];

  List<Widget> _sottoIlCielo() => [
        Text(
            _completa
                ? 'La figura è unita.'
                : (_unite == 0
                    ? 'Alza il telefono verso il cielo.'
                    : 'Unisci le stelle.'),
            key: const Key('dream_invito_cielo'),
            textAlign: TextAlign.center,
            style: TypographyTokens.display(size: 20)
                .copyWith(color: _palette.goldSoft)),
        const SizedBox(height: SpacingTokens.xs),
        Text(
            'La costellazione di ${_luna.sign.italianName}, il segno in cui si '
            'trova la Luna adesso. Stelle unite $_unite su '
            '${_figura.points.length}.',
            key: const Key('dream_conteggio'),
            textAlign: TextAlign.center,
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textSecondary, height: 1.45)),
        const SizedBox(height: SpacingTokens.sm),
        _Riga(
          palette: _palette,
          icona: Icons.screen_rotation_alt_outlined,
          testo: _riduciMovimento
              ? 'Riduci Movimento è attivo: il cielo resta fermo, tocca le '
                  'stelle nel loro ordine.'
              : 'Muovi il telefono per guardarti intorno, oppure trascina col '
                  'dito. Tocca la stella che pulsa.',
        ),
      ];

  List<Widget> _ilSaluto(String saluto) => [
        // Chi parla, prima del saluto della notte.
        RigaDelDono(
          dono: DailyElement.night,
          giorno: _date,
          superficie: ColorTokens.neutralDeepest,
        ),
        // LE TRE RIGHE DEL RITO, ordine P voce 17.
        LeTreRigheDelRito(
          rito: DailyElement.night,
          inchiostro: ColorTokens.textPrimary,
          accento: _palette.goldSoft,
        ),
        const SizedBox(height: SpacingTokens.sm),
        Text('Il saluto di ${_maestro.displayName}',
            key: const Key('dream_message_title'),
            style: TypographyTokens.display(size: 19)
                .copyWith(color: _palette.goldSoft)),
        const SizedBox(height: SpacingTokens.xs),
        Text(DreamRiteCorpus.parola(_luna.sign).toUpperCase(),
            key: const Key('dream_word'),
            style: TypographyTokens.display(size: 32).copyWith(
                color: _palette.goldSoft, letterSpacing: 1.6)),
        const SizedBox(height: SpacingTokens.sm),
        Text(saluto,
            key: const Key('dream_message'),
            style: TypographyTokens.body(size: 16)
                .copyWith(color: ColorTokens.textPrimary, height: 1.6)),
        const SizedBox(height: SpacingTokens.sm),
        Text(DreamRiteCorpus.provenienza(_luna),
            key: const Key('dream_provenienza'),
            style: TypographyTokens.etichetta().copyWith(
                color: _palette.goldSoft.withValues(alpha: 0.85),
                letterSpacing: 0.5)),
        const SizedBox(height: SpacingTokens.lg),
        _Azioni(
          palette: _palette,
          luna: _luna,
          saluto: saluto,
          maestroNome: _maestro.displayName,
        ),
        const SizedBox(height: SpacingTokens.sm),
        TextButton.icon(
          key: const Key('dream_sound'),
          onPressed: _cambiaSuono,
          icon: Icon(_suono ? Icons.graphic_eq : Icons.music_note_outlined,
              size: 18, color: _palette.goldSoft),
          label: Text(
              _suono ? 'Battito theta acceso' : 'Battito theta, se lo vuoi',
              style: TypographyTokens.label(size: 12)
                  .copyWith(color: _palette.goldSoft)),
        ),
      ];

  void _mostraProvenienza() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheet) => Container(
        key: const Key('dream_sources_sheet'),
        padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
            SpacingTokens.lg, SpacingTokens.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_palette.surfaceElevated, _palette.deepest],
          ),
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SpacingTokens.radiusXl)),
          border: Border.all(color: _palette.gold.withValues(alpha: 0.3)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Da dove nasce questo dono',
                    style: TypographyTokens.display(size: 19)
                        .copyWith(color: _palette.goldSoft)),
                const SizedBox(height: SpacingTokens.sm),
                Text(DreamRiteCorpus.daDoveNasce(_luna),
                    style: TypographyTokens.corpo().copyWith(
                        color: ColorTokens.textPrimary, height: 1.45)),
                const SizedBox(height: SpacingTokens.lg),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(sheet).pop(),
                    child: Text('Va bene',
                        style: TypographyTokens.label(size: 13)
                            .copyWith(color: _palette.goldSoft)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Una riga di suggerimento, icona piu' testo, come negli altri riti.
class _Riga extends StatelessWidget {
  const _Riga(
      {required this.palette, required this.icona, required this.testo});

  final MaestroPalette palette;
  final IconData icona;
  final String testo;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icona, size: 14, color: palette.goldSoft),
        const SizedBox(width: 6),
        Expanded(
          child: Text(testo,
              style: TypographyTokens.etichetta().copyWith(
                color: palette.goldSoft.withValues(alpha: 0.75),
                letterSpacing: 0.2,
                height: 1.4,
              )),
        ),
      ],
    );
  }
}

/// Condividi la carta della notte, con la carta fuori campo per lo scatto.
class _Azioni extends StatefulWidget {
  const _Azioni({
    required this.palette,
    required this.luna,
    required this.saluto,
    required this.maestroNome,
  });

  final MaestroPalette palette;
  final BirthMoon luna;
  final String saluto;
  final String maestroNome;

  @override
  State<_Azioni> createState() => _AzioniState();
}

class _AzioniState extends State<_Azioni> {
  final GlobalKey _boundary = GlobalKey();
  bool _condividendo = false;
  bool _rendi = false;

  Future<void> _condividi() async {
    setState(() {
      _condividendo = true;
      _rendi = true;
    });
    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await shareDreamRiteCard(boundaryKey: _boundary, luna: widget.luna);
    } finally {
      if (mounted) setState(() => _condividendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const Key('dream_share'),
            style: OutlinedButton.styleFrom(
                foregroundColor: widget.palette.goldSoft,
                side: BorderSide(
                    color: widget.palette.gold.withValues(alpha: 0.6))),
            onPressed: _condividendo ? null : _condividi,
            icon: const Icon(Icons.ios_share_rounded),
            label: const Text('Condividi la carta della notte'),
          ),
        ),
        if (_rendi)
          Positioned(
            left: -3000,
            top: 0,
            child: RepaintBoundary(
              key: _boundary,
              child: DreamRiteCard(
                luna: widget.luna,
                palette: widget.palette,
                saluto: widget.saluto,
                maestroNome: widget.maestroNome,
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// I painter della scena: Luna reale, stelle vicine, foschia, fili di luce.
// ---------------------------------------------------------------------------


/// Disegna una stella premium: alone a gradiente, nucleo e una piccola raggiera.
void _stellaPremium(
  Canvas canvas,
  Offset c,
  double raggio,
  double alfa, {
  Color colore = Colors.white,
  bool raggiera = false,
}) {
  final a = alfa.clamp(0.0, 1.0);
  if (a <= 0.01) return;
  // Alone morbido.
  canvas.drawCircle(
    c,
    raggio * 7,
    Paint()
      ..shader = RadialGradient(colors: [
        colore.withValues(alpha: 0.32 * a),
        colore.withValues(alpha: 0.0),
      ]).createShader(Rect.fromCircle(center: c, radius: raggio * 7)),
  );
  // Raggiera sottile, solo per le piu' luminose.
  if (raggiera) {
    final r = raggio * 8.5;
    final penna = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = raggio * 0.55
      ..color = colore.withValues(alpha: 0.30 * a)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, raggio * 0.8);
    canvas.drawLine(c.translate(-r, 0), c.translate(r, 0), penna);
    canvas.drawLine(c.translate(0, -r), c.translate(0, r), penna);
  }
  // Nucleo.
  canvas.drawCircle(c, raggio * 1.6,
      Paint()..color = colore.withValues(alpha: 0.55 * a));
  canvas.drawCircle(c, raggio, Paint()..color = colore.withValues(alpha: a));
}

/// La Luna reale e le stelle vicine, sopra il cosmo condiviso. Piani diversi di
/// parallasse: le stelle lontane si muovono poco, la Luna un poco di piu', le
/// stelle vicine molto. Una nota tenue del Maestro resta solo ai margini.
class _ScenaPainter extends CustomPainter {
  _ScenaPainter({
    required this.palette,
    required this.fase,
    required this.t,
    required this.luce,
    required this.quieta,
    required this.spostamento,
  });

  final MaestroPalette palette;
  final MoonPhase fase;
  final double t;

  /// Quanto il cielo e' emerso dalla foschia, da 0 a 1.
  final double luce;

  /// Vero a rito concluso: il cielo si acquieta, le stelle calano di luce.
  final bool quieta;

  final Offset spostamento;

  @override
  void paint(Canvas canvas, Size size) {
    final calo = quieta ? 0.7 : 1.0;

    // Nota tenue del Maestro di turno, solo ai margini, mai sopra il cosmo.
    final bordo = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.95,
        colors: [
          palette.primary.withValues(alpha: 0.0),
          palette.primary.withValues(alpha: 0.10 * luce),
        ],
        stops: const [0.62, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bordo);

    // Stelle vicine, primo piano: poche, grandi, col battito sfasato. La
    // raggiera a croce resta a pochissime, le sole davvero brillanti, cosi' non
    // sa di preset: tutte le altre hanno solo nucleo e alone.
    final vicine = spostamento * 0.9;
    final rng = math.Random(41);
    var conRaggiera = 0;
    for (var i = 0; i < 16; i++) {
      final bx = rng.nextDouble();
      final by = rng.nextDouble() * 0.72;
      final base = 0.9 + rng.nextDouble() * 1.1;
      final sfasa = rng.nextDouble();
      final battito = 0.55 + 0.45 * math.sin((t + sfasa) * math.pi * 2);
      final raggiera = base > 1.72 && conRaggiera < 3;
      if (raggiera) conRaggiera++;
      _stellaPremium(
        canvas,
        Offset(bx * size.width + vicine.dx, by * size.height + vicine.dy),
        base,
        battito * luce * calo,
        colore: const Color(0xFFEAF0FF),
        raggiera: raggiera,
      );
    }

    // Stelle intermedie, piano di mezzo: piu' fitte, piu' piccole.
    final medie = spostamento * 0.45;
    for (var i = 0; i < 46; i++) {
      final bx = rng.nextDouble();
      final by = rng.nextDouble() * 0.8;
      final base = 0.4 + rng.nextDouble() * 0.6;
      final sfasa = rng.nextDouble();
      final battito = 0.4 + 0.5 * math.sin((t + sfasa) * math.pi * 2);
      _stellaPremium(
        canvas,
        Offset(bx * size.width + medie.dx, by * size.height + medie.dy),
        base,
        battito * 0.8 * luce * calo,
        colore: const Color(0xFFDCE6FF),
      );
    }

    // Un pianeta lontano, sul piano piu' profondo: piccolo, morbido, senza bordo
    // netto, con un alone atmosferico tenue.
    _pianetaLontano(canvas, size, spostamento * 0.16, luce * calo);

    // La Luna, sul suo piano, nella fase reale di stanotte.
    _luna(canvas, size, spostamento * 0.28, calo);
  }

  /// Un corpo distante nel cosmo, non una sfera in primo piano: l'alfa va a zero
  /// sul bordo, cosi' non c'e' contorno, e una sfumatura di fase lo illumina da
  /// un lato solo. Bassa opacita', perche' resti lontano.
  void _pianetaLontano(Canvas canvas, Size size, Offset off, double vis) {
    if (vis <= 0.01) return;
    final c = Offset(size.width * 0.15, size.height * 0.36) + off;
    final r = size.shortestSide * 0.026;

    // Alone atmosferico, appena percepibile.
    canvas.drawCircle(
      c,
      r * 3.0,
      Paint()
        ..shader = RadialGradient(colors: [
          CosmosNebula.cool.withValues(alpha: 0.07 * vis),
          const Color(0x00000000),
        ]).createShader(Rect.fromCircle(center: c, radius: r * 3.0))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 1.1),
    );

    // Il corpo: chiaro da un lato, in ombra dall'altro. La sfocatura sul corpo
    // stesso toglie ogni bordo, cosi' resta un corpo distante e non una biglia.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.5, -0.45),
          radius: 1.2,
          colors: [
            CosmosNebula.core.withValues(alpha: 0.17 * vis),
            CosmosNebula.mid.withValues(alpha: 0.07 * vis),
            CosmosNebula.mid.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.42),
    );
  }

  void _luna(Canvas canvas, Size size, Offset off, double calo) {
    final c = Offset(size.width * 0.74, size.height * 0.17) + off;
    final r = size.shortestSide * 0.078;
    final vis = luce * calo;
    if (vis <= 0.01) return;

    // Alone a piu' strati, morbido, che fa da luce.
    for (final s in const [4.6, 3.0, 1.9]) {
      canvas.drawCircle(
        c,
        r * s,
        Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFFCFDDFF).withValues(alpha: 0.15 * vis),
            const Color(0x00000000),
          ]).createShader(Rect.fromCircle(center: c, radius: r * s)),
      );
    }

    // LA LUNA E' UNA SOLA, e sta in `LunaReale`. Questo disegno e' nato qui,
    // dentro un metodo privato di una classe privata, quindi nessun'altra
    // superficie poteva usarlo: il consulto ne aveva una seconda versione
    // semplificata, che mostrava una meta' esatta mentre il testo diceva
    // "crescente". Adesso il corpo e' quello, e qui resta solo il posto.
    LunaReale.dipingi(
      canvas,
      c,
      r,
      illuminazione: fase.illumination,
      crescente: fase.waxing,
      visibilita: vis,
    );
  }

  @override
  bool shouldRepaint(_ScenaPainter old) =>
      old.t != t ||
      old.luce != luce ||
      old.quieta != quieta ||
      old.spostamento != spostamento;
}

/// La foschia cosmica dell'apertura: volute morbide sopra il cielo profondo,
/// che si diradano e rivelano il cosmo. Non un riquadro, un velo su tutto.
class _FoschiaPainter extends CustomPainter {
  _FoschiaPainter(
      {required this.palette, required this.apertura, required this.t});

  final MaestroPalette palette;
  final double apertura;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final velo = (1 - apertura).clamp(0.0, 1.0);
    if (velo <= 0.01) return;
    final rect = Offset.zero & size;

    // Il buio ovattato, che lascia intravedere il cosmo sotto.
    canvas.drawRect(
      rect,
      Paint()..color = const Color(0xFF04060E).withValues(alpha: 0.80 * velo),
    );

    // Volute di foschia, fredde, che respirano e si aprono dal centro.
    final rng = math.Random(17);
    for (var i = 0; i < 11; i++) {
      final bx = rng.nextDouble();
      final by = rng.nextDouble();
      final base = size.width * (0.24 + rng.nextDouble() * 0.34);
      final sfasa = rng.nextDouble();
      final respiro = 0.88 + 0.12 * math.sin((t + sfasa) * math.pi * 2);
      // Le volute al centro si aprono per prime.
      final dalCentro =
          ((Offset(bx, by) - const Offset(0.5, 0.42)).distance / 0.7)
              .clamp(0.0, 1.0);
      final resta = (velo * (0.45 + 0.55 * dalCentro)).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(bx * size.width, by * size.height),
        base * respiro,
        Paint()
          ..color = const Color(0xFF7C8AAE).withValues(alpha: 0.13 * resta)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, base * 0.55),
      );
    }

    // Una nota tenue del Maestro nella foschia, appena percepibile.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          radius: 0.9,
          colors: [
            palette.primary.withValues(alpha: 0.0),
            palette.primary.withValues(alpha: 0.10 * velo),
          ],
          stops: const [0.55, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_FoschiaPainter old) =>
      old.apertura != apertura || old.t != t;
}

/// La costellazione reale del segno della Luna: filamenti d'oro luminosi con
/// alone esterno, uno scintillio che corre lungo la linea, e le stelle della
/// figura che si accendono con un lampo morbido quando vengono unite.

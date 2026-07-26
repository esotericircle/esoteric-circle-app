import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../core/astro/sky_location.dart';
import '../../core/astro/sunset_time.dart';
import '../../core/astro/zodiac.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/maestro/maestro.dart';
import '../../core/identity/device_id.dart';
import '../../core/rituals/runes.dart';
import '../../core/rituals/sunset_rune.dart';
import '../../core/rituals/sunset_rune_corpus.dart';
import '../../core/rituals/sunset_rune_memory.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/app_services.dart';
import '../maestri/caligo/rune/bindrune.dart';
import '../maestri/chat/chat_openers.dart';
import '../maestri/chat/maestro_chat_screen.dart';
import 'rune_strokes.dart';
import 'sunset_rune_card.dart';

/// La Runa del Tramonto, dominio Caligo, versione definitiva.
///
/// Il Dono appartiene al tramonto. La runa nasce deterministica dal giorno
/// rituale incrociato con la carta di nascita e il segno; il responso e' runa,
/// verso, fase lunare reale e segno solare. Si getta la pietra scuotendo o
/// toccando, la si incide tenendo il dito, poi due voci: cosa lasci fuori e cosa
/// porti dentro la notte. Alla settima sera le rune si legano in una bindrune.
/// Zero rete, zero AI, ogni sensore ha il suo ripiego tattile.
class SunsetRuneScreen extends StatefulWidget {
  const SunsetRuneScreen({
    super.key,
    this.now,
    this.dataNascita,
    this.segno,
    this.location = const DisabledSkyLocation(),
  });

  final DateTime? now;
  final DateTime? dataNascita;
  final Zodiac? segno;

  /// Sorgente della posizione per l'ora del tramonto, non bloccante. Di default
  /// spenta: l'ora e' stimata dal fuso, come nelle anteprime e nei test.
  final SkyLocation location;

  static Route<void> route({
    DateTime? now,
    DateTime? dataNascita,
    Zodiac? segno,
    SkyLocation location = const GeolocatorSkyLocation(),
  }) =>
      MaterialPageRoute<void>(
        builder: (_) => MaestroScope(
          child: SunsetRuneScreen(
            now: now,
            dataNascita: dataNascita,
            segno: segno,
            location: location,
          ),
        ),
      );

  @override
  State<SunsetRuneScreen> createState() => _SunsetRuneScreenState();
}

enum _Fase { getto, incisione, lettura }

/// La scala orizzontale del contenuto visibile della pietra girata al valore di
/// flip [t]. Con la faccia B controruotata resta sempre positiva, cioe' il
/// contenuto non e' mai specchiato: a fine giro vale +1. Esposta per il test del
/// flip a due facce.
double sunsetFlipContentXScale(double t) {
  final base = math.cos(math.pi * t);
  return t >= 0.5 ? -base : base;
}

/// L'integratore dell'inclinazione: accumula la velocita' angolare attorno
/// all'asse lungo e dice quando scatta il giro. Se il moto inverte prima della
/// soglia, l'accumulo riparte da zero. Estratto per essere testabile.
class GiroInclinazione {
  double _accumulo = 0;

  /// La soglia cumulativa, in radianti, oltre cui il giro scatta.
  static const double soglia = 1.2;

  double get accumulo => _accumulo;

  /// Aggiorna con la velocita' angolare [vY] e il passo [dt] in secondi. Torna
  /// vero quando si supera la soglia, e in quel caso azzera l'accumulo.
  bool passo(double vY, double dt) {
    if (_accumulo != 0 && vY.sign != _accumulo.sign && vY.abs() > 0.2) {
      _accumulo = 0;
    }
    _accumulo += vY * dt;
    if (_accumulo.abs() > soglia) {
      _accumulo = 0;
      return true;
    }
    return false;
  }
}

class _SunsetRuneScreenState extends State<SunsetRuneScreen>
    with TickerProviderStateMixin {
  late final DateTime _ora = widget.now ?? DateTime.now();
  EstrazioneTramonto? _estrazione;
  EstrazioneTramonto get _e => _estrazione!;
  DateTime? _nascita;
  bool _risolta = false;
  final MaestroPalette _palette =
      MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo));

  // Ingresso della pietra, respiro dell'alone, rimbalzo del getto, flip della
  // rotazione. Inizializzati in initState, non pigri: cosi' dispose non crea mai
  // un ticker durante lo smontaggio se la scena non e' arrivata a costruirsi.
  late final AnimationController _ingresso;
  late final AnimationController _alone;
  late final AnimationController _rimbalzo;
  late final AnimationController _flip;

  Ticker? _incisioneTicker;
  StreamSubscription<AccelerometerEvent>? _shakeSub;
  StreamSubscription<GyroscopeEvent>? _giroSub;
  Duration _ultimoTick = Duration.zero;
  bool _primoTick = true; // alla ripresa il primo tick fissa la base, non avanza

  _Fase _fase = _Fase.getto;
  double _incisione = 0; // 0..1, quanto e' scavato il segno
  int _trattiFatti = 0; // per il feedback aptico a ogni tratto
  bool _completa = false; // crossfade tratti verso l'asset avvenuto
  bool _premuto = false;
  bool _giroFatto = false;
  bool _riduciMovimento = false;

  // Inclinazione: velocita' angolare integrata attorno all'asse lungo, e se il
  // giroscopio ha mai risposto, per non promettere un gesto che non funziona.
  final GiroInclinazione _inclinazione = GiroInclinazione();
  bool _giroDisponibile = false;
  bool _puoInclinare = false;

  // L'ora del tramonto e l'identita' deterministica.
  DateTime? _tramonto;
  bool _stimata = true;
  bool _oraNota = false;

  // Le due voci salvate, quando la sera e' gia' stata vissuta: si riproducono
  // invece di ricomporle, cosi' il testo non cambia fra due aperture.
  String? _lasciareSalvato;
  String? _portaSalvato;

  // La settimana e la cerniera.
  List<SeraSalvata> _settimana = [];

  int get _numeroTratti => (kRuneStrokes[_e.rune.name]?.length ?? 1);

  @override
  void initState() {
    super.initState();
    _ingresso = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();
    _alone = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3400))
      ..repeat(reverse: true);
    _rimbalzo = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 620));
    _flip = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _ascoltaScuotimento();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _riduciMovimento = MediaQuery.of(context).disableAnimations;
    if (_risolta) return;
    _risolta = true;
    // La runa nasce dalla carta dell'utente: la data di nascita arriva dai
    // parametri o dal profilo, quando c'e' e non e' l'esempio. L'ora si include
    // solo quando e' davvero nota.
    DateTime? nascita = widget.dataNascita;
    var oraNota = false;
    if (nascita == null) {
      try {
        final id = context.read<ProfileController>().identity;
        if (!id.isExample) {
          nascita = id.birthMoment;
          oraNota = id.hasBirthTime;
        }
      } catch (_) {
        // Nessun profilo nel contesto, per esempio nei test: resta anonimo.
      }
    }
    _nascita = nascita;
    _oraNota = oraNota;
    _prepara();
  }

  // Risolve l'identita' una sola volta, poi estrae. L'identita' e' la nascita
  // quando c'e', altrimenti l'id del dispositivo, cosi' due utenti anonimi non
  // ricevono la stessa runa. La fase lunare segue il tramonto stimato dal fuso,
  // calcolato subito e offline, senza attendere la geolocalizzazione.
  Future<void> _prepara() async {
    final offset = _ora.timeZoneOffset;
    final giorno = SunsetRune.giornoRituale(_ora);
    final stimato = SunsetTime.perData(giorno,
            lat: SunsetTime.latDiRipiego,
            lon: SunsetTime.longitudineDaFuso(offset),
            offset: offset) ??
        SunsetTime.oraMedia(giorno);
    final deviceId = _nascita == null ? await DeviceId.corrente() : '';
    final identita = SunsetRune.identitaPer(
        nascita: _nascita, oraNota: _oraNota, deviceId: deviceId);
    final e = SunsetRune.estrai(_ora,
        dataNascita: _nascita,
        segno: widget.segno,
        identita: identita,
        istanteTramonto: stimato);
    // Se stasera e' gia' stata vissuta, riproduci le voci salvate.
    final settimana = await SunsetRuneMemory.settimanaCorrente(e.giornoRituale);
    SeraSalvata? seraOggi;
    for (final s in settimana) {
      if (s.giorno == e.giornoIso) seraOggi = s;
    }
    if (!mounted) return;
    setState(() {
      _estrazione = e;
      _tramonto = stimato;
      _stimata = true;
      if (seraOggi != null) {
        _lasciareSalvato = seraOggi.lasciare;
        _portaSalvato = seraOggi.porta;
      }
    });
    _raffinaTramonto();
    _controllaRitorno();
  }

  @override
  void dispose() {
    _incisioneTicker?.dispose();
    _shakeSub?.cancel();
    _giroSub?.cancel();
    _ingresso.dispose();
    _alone.dispose();
    _rimbalzo.dispose();
    _flip.dispose();
    super.dispose();
  }

  // Raffina l'etichetta dell'ora con la posizione reale, se attiva. Non tocca
  // la fase ne' le voci: aggiorna solo il tramonto mostrato. Non blocca la scena.
  Future<void> _raffinaTramonto() async {
    final luogo = await widget.location.resolve();
    if (luogo == null || !mounted) return;
    final offset = _ora.timeZoneOffset;
    final t = SunsetTime.perData(_e.giornoRituale,
            lat: luogo.latitude, lon: luogo.longitude, offset: offset) ??
        SunsetTime.oraMedia(_e.giornoRituale);
    setState(() {
      _tramonto = t;
      _stimata = false;
    });
  }

  void _ascoltaScuotimento() {
    try {
      _shakeSub = accelerometerEventStream(
              samplingPeriod: const Duration(milliseconds: 66))
          .listen((ev) {
        final m = math.sqrt(ev.x * ev.x + ev.y * ev.y + ev.z * ev.z);
        if (m > 22) _getta();
      }, onError: (_) {}, cancelOnError: false);
    } catch (_) {
      // Nessun accelerometro: resta il tocco.
    }
  }

  // --- Gesto uno: il getto ---
  void _getta() {
    if (_fase != _Fase.getto) return;
    HapticFeedback.mediumImpact();
    _shakeSub?.cancel();
    _shakeSub = null;
    if (!_riduciMovimento) _rimbalzo.forward(from: 0);
    setState(() => _fase = _Fase.incisione);
  }

  // --- Gesto due: l'incisione ---
  void _inizioIncisione() {
    if (_fase != _Fase.incisione || _completa) return;
    _premuto = true;
    // Alla ripresa NON si azzera il progresso: il primo tick fissa solo la base
    // temporale, cosi' una pausa lunga fra due pressioni non incide di colpo.
    _primoTick = true;
    _incisioneTicker ??= createTicker(_passoIncisione);
    if (!_incisioneTicker!.isActive) _incisioneTicker!.start();
    setState(() {});
  }

  void _fineIncisione() {
    if (_fase != _Fase.incisione) return;
    _premuto = false;
    // Il progresso resta dov'e', ma il ticker si ferma: mentre il dito e'
    // alzato il tempo non deve accumularsi e poi scaricarsi tutto alla ripresa.
    // Nel ripiego Riduci Movimento l'incisione va da se', quindi non si ferma.
    if (!_riduciMovimento) _incisioneTicker?.stop();
    setState(() {});
  }

  void _passoIncisione(Duration elapsed) {
    if (_primoTick) {
      // Prima battuta dopo start: fissa la base, non fa avanzare nulla.
      _ultimoTick = elapsed;
      _primoTick = false;
      return;
    }
    var dt = (elapsed - _ultimoTick).inMilliseconds / 1000.0;
    _ultimoTick = elapsed;
    if (dt < 0) dt = 0;
    // Con Riduci Movimento l'incisione va da se' in 1.2 secondi; altrimenti
    // avanza solo mentre il dito preme, e la durata cresce coi tratti.
    final durata = _riduciMovimento ? 1.2 : _numeroTratti * 0.55;
    if (!_riduciMovimento) {
      // Solo nel gesto manuale: rete di sicurezza contro i frame lunghi, cosi'
      // una pausa fra due pressioni non incide di colpo. L'auto-incisione del
      // ripiego non si limita, deve arrivare in fondo nel suo tempo.
      if (dt > 0.05) dt = 0.05;
      if (!_premuto) return;
    }
    final prima = _incisione;
    _incisione = (_incisione + dt / durata).clamp(0.0, 1.0);
    // Feedback aptico a ogni tratto completato.
    final trattiOra = (_incisione * _numeroTratti).floor();
    if (trattiOra > _trattiFatti) {
      _trattiFatti = trattiOra;
      HapticFeedback.selectionClick();
    }
    if (_incisione >= 1 && prima < 1) {
      _completaIncisione();
    }
    setState(() {});
  }

  void _completaIncisione() {
    _incisioneTicker?.stop();
    HapticFeedback.mediumImpact();
    setState(() => _completa = true);
    // Crossfade dai tratti all'arte incisa, poi la lettura.
    Future<void>.delayed(const Duration(milliseconds: 1200), () async {
      if (!mounted) return;
      setState(() => _fase = _Fase.lettura);
      await _apriLettura();
    });
  }

  Future<void> _apriLettura() async {
    // Salva la sera e carica la settimana, per la striscia e il sigillo.
    final lasciare = _vocePrima();
    final porta = _vocePortare();
    await SunsetRuneMemory.scriviEstrazione(
        SunsetRuneMemory.seraDa(_e, lasciare: lasciare, porta: porta));
    final settimana = await SunsetRuneMemory.settimanaCorrente(_e.giornoRituale);
    if (mounted) setState(() => _settimana = settimana);
    // La lettura e' aperta: da qui in poi l'inclinazione svela la seconda voce.
    _ascoltaInclinazione();
  }

  // La clausola di insistenza, se la runa e' gia' tornata nei sette giorni.
  String? _insistenza;
  bool _ritorno = false;

  Future<void> _controllaRitorno() async {
    final ripetuta = await SunsetRuneMemory.runaRipetutaNegliUltimi7(
        _e.rune.name, _e.giornoRituale);
    if (ripetuta && mounted) {
      setState(() {
        _ritorno = true;
        _insistenza =
            SunsetRuneCorpus.insistenza(SunsetRune.indiceInsistenza(_e));
      });
    }
  }

  // Le voci: se la sera e' gia' stata vissuta si riproducono quelle salvate,
  // altrimenti si compongono dal corpus. Cosi' il testo non cambia fra due
  // aperture della stessa sera anche se la fase lunare intanto e' avanzata.
  String _vocePrima() =>
      _lasciareSalvato ??
      SunsetRuneCorpus.vocePrimaLasciare(_e, insistenzaClausola: _insistenza);
  String _vocePortare() =>
      _portaSalvato ??
      SunsetRuneCorpus.vocePortare(_e, insistenzaClausola: _insistenza);

  // --- Gesto tre: il giro della pietra, per inclinazione o doppio tap ---
  void _ascoltaInclinazione() {
    // Nel ripiego Riduci Movimento l'inclinazione non si propone: solo tocco.
    if (_riduciMovimento) return;
    try {
      _giroSub = gyroscopeEventStream(
              samplingPeriod: const Duration(milliseconds: 40))
          .listen(_passoGiro, onError: (_) {}, cancelOnError: false);
    } catch (_) {
      // Nessun giroscopio: resta il doppio tap.
    }
  }

  void _passoGiro(GyroscopeEvent ev) {
    if (_giroFatto || !mounted) return;
    // Al primo evento reale il giroscopio e' confermato: solo ora la scena puo'
    // proporre l'inclinazione, mai prima, cosi' non promette un gesto assente.
    if (!_giroDisponibile) {
      setState(() {
        _giroDisponibile = true;
        _puoInclinare = true;
      });
    }
    const dt = 0.04; // il periodo di campionamento, in secondi
    // ev.y: velocita' angolare attorno all'asse lungo del telefono.
    if (_inclinazione.passo(ev.y, dt)) _gira();
  }

  void _gira() {
    if (_giroFatto) return;
    HapticFeedback.selectionClick();
    // Dopo lo scatto niente piu' eventi: fine gesto, nessun rimbalzo.
    _giroSub?.cancel();
    _giroSub = null;
    setState(() => _giroFatto = true);
    if (!_riduciMovimento) _flip.forward(from: 0);
  }

  bool get _settimaSera => _settimana.length >= 7;

  List<String> get _runeSettimana =>
      _settimana.map((s) => s.rune).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: _palette.deepest.withValues(alpha: 0.32),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: _palette.goldSoft),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        // Il titolo intero, mai troncato: si rimpicciolisce quanto serve per
        // stare in larghezza anche fra le due icone della barra.
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text('La Runa del Tramonto',
              maxLines: 1,
              style: TypographyTokens.display(size: 19)),
        ),
        actions: [
          IconButton(
            key: const Key('sunset_sources'),
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Fonti e metodo',
            onPressed: _mostraFonti,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Il fondale del tramonto, coi tre slot webp e il ripiego procedurale.
          Positioned.fill(
            child: _Fondale(
              palette: _palette,
              completa: _completa,
              momento: _completa ? 2 : (_fase == _Fase.getto ? 0 : 1),
              riduciMovimento: _riduciMovimento,
            ),
          ),
          // In lettura una velatura scura crescente spegne il fondale sotto le
          // schede, cosi' il disco solare di ripiego non trapela dietro il testo.
          if (_fase == _Fase.lettura)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _palette.deepest.withValues(alpha: 0.35),
                      _palette.deepest.withValues(alpha: 0.82),
                    ],
                    stops: const [0.0, 0.4],
                  ),
                ),
              ),
            ),
          // Finche' l'identita' e l'estrazione non sono pronte, solo il fondale:
          // una manciata di frame, senza mai bloccare ne' lampeggiare contenuti.
          if (_estrazione != null)
            SafeArea(
              child:
                  _fase == _Fase.lettura ? _lettura() : _scenaPietra(),
            ),
        ],
      ),
    );
  }

  // La scena della pietra: getto e incisione, la pietra al centro.
  Widget _scenaPietra() {
    return Column(
      key: const Key('sunset_rune'),
      children: [
        const SizedBox(height: SpacingTokens.xxl),
        Expanded(
          child: Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_ingresso, _alone, _rimbalzo]),
              builder: (context, _) {
                final salita = _riduciMovimento
                    ? 0.0
                    : (1 - Curves.easeOutCubic.transform(_ingresso.value)) * 60;
                final gradi = _riduciMovimento
                    ? 0.0
                    : (1 - _ingresso.value) * 4 * math.pi / 180;
                final pop = _rimbalzo.isAnimating
                    ? 1 + 0.06 * (1 - Curves.easeOut.transform(_rimbalzo.value))
                    : 1.0;
                return Transform.translate(
                  offset: Offset(0, salita),
                  child: Transform.rotate(
                    angle: gradi,
                    child: Transform.scale(scale: pop, child: _pietra()),
                  ),
                );
              },
            ),
          ),
        ),
        _rigaOra(),
        const SizedBox(height: SpacingTokens.sm),
        _pillolaEgesti(),
        const SizedBox(height: SpacingTokens.xl),
      ],
    );
  }

  Widget _rigaOra() {
    final t = _tramonto;
    final ora = t == null
        ? ''
        : '${t.hour.toString().padLeft(2, '0')}:'
            '${t.minute.toString().padLeft(2, '0')}';
    if (!_stimata) {
      return Text('Tramonto delle $ora',
          key: const Key('sunset_ora'),
          style: TypographyTokens.label(size: 11).copyWith(
              color: _palette.goldSoft.withValues(alpha: 0.8),
              letterSpacing: 0.4));
    }
    return Column(
      children: [
        Text(
            t == null
                ? 'Ora stimata, la posizione non è attiva'
                : 'Ora stimata delle $ora, la posizione non è attiva',
            key: const Key('sunset_stimata'),
            textAlign: TextAlign.center,
            style: TypographyTokens.label(size: 11).copyWith(
                color: ColorTokens.textSecondary, letterSpacing: 0.3)),
        TextButton(
          key: const Key('sunset_attiva'),
          onPressed: _attivaPosizione,
          child: Text('Attiva la posizione',
              style: TypographyTokens.label(size: 11)
                  .copyWith(color: _palette.goldSoft)),
        ),
      ],
    );
  }

  Future<void> _attivaPosizione() async {
    // Riprova a risolvere la posizione, non blocca la scena.
    final luogo = await const GeolocatorSkyLocation().resolve();
    if (!mounted) return;
    if (luogo == null) {
      // Permesso negato o posizione assente: si spiega, in voce neutra, che si
      // usa un tramonto medio. Il Dono resta pienamente funzionante.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          key: Key('sunset_posizione_negata'),
          content: Text(
              'Senza posizione si usa un tramonto medio. La runa e le sue voci '
              'restano le stesse.'),
        ),
      );
      return;
    }
    final offset = _ora.timeZoneOffset;
    final t = SunsetTime.perData(_e.giornoRituale,
            lat: luogo.latitude, lon: luogo.longitude, offset: offset) ??
        SunsetTime.oraMedia(_e.giornoRituale);
    setState(() {
      _tramonto = t;
      _stimata = false;
    });
  }

  Widget _pietra() {
    const lato = 240.0;
    if (_fase == _Fase.getto) {
      // Pietra velata, in attesa del getto.
      return GestureDetector(
        key: const Key('sunset_getto_gesture'),
        behavior: HitTestBehavior.opaque,
        onTap: _getta,
        child: SizedBox(
          width: lato,
          height: lato,
          child: CustomPaint(
            key: const Key('sunset_stone'),
            painter: _PietraVelataPainter(
                palette: _palette, respiro: _alone.value),
          ),
        ),
      );
    }
    // Incisione: si tiene il dito e il segno si scava un tratto alla volta.
    return GestureDetector(
      key: const Key('sunset_incisione_gesture'),
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (_) => _inizioIncisione(),
      onLongPressEnd: (_) => _fineIncisione(),
      onTap: _riduciMovimento ? _inizioIncisione : null,
      child: SizedBox(
        width: lato,
        height: lato,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // I tratti scavati, che sfumano quando arriva l'asset.
            AnimatedOpacity(
              opacity: _completa ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 500),
              child: CustomPaint(
                key: const Key('sunset_incisione'),
                size: const Size(lato, lato),
                painter: _IncisionePainter(
                  runeName: _e.rune.name,
                  progresso: _incisione,
                  palette: _palette,
                  completa: _completa,
                ),
              ),
            ),
            // L'arte incisa vera, che appare al completamento.
            if (_completa)
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 500),
                child: SizedBox(
                  key: const Key('rune_glyph'),
                  width: lato * 0.9,
                  height: lato * 0.9,
                  child: _glifoAsset(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Il glifo nudo, senza orientamento: l'arte osso reale col ripiego al tratto.
  Widget _glifoRaw() {
    final r = _e.rune;
    return r.hasImage
        ? Image.asset(r.fullPath!,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => CustomPaint(
                  painter: RunePainter(
                      runeName: r.name,
                      color: Colors.white,
                      glow: _palette.goldSoft,
                      intensity: 1.0),
                ))
        : CustomPaint(
            painter: RunePainter(
                runeName: r.name,
                color: Colors.white,
                glow: _palette.goldSoft,
                intensity: 1.0),
          );
  }

  Widget _glifoAsset() {
    return _e.inOmbra
        ? Transform.rotate(angle: math.pi, child: _glifoRaw())
        : _glifoRaw();
  }

  // Una faccia della pietra girata. Fronte e retro sono orientamenti opposti del
  // glifo: il retro e' inciso al rovescio, non e' la stessa faccia specchiata.
  Widget _facciaGlifo({required bool retro}) {
    final capovolto = _e.inOmbra ^ retro;
    return capovolto
        ? Transform.rotate(angle: math.pi, child: _glifoRaw())
        : _glifoRaw();
  }


  Widget _pillolaEgesti() {
    final testo = _fase == _Fase.getto
        ? 'Scuoti per gettare la runa'
        : (_incisione > 0 && _incisione < 1 && !_premuto
            ? 'Il segno non è compiuto'
            : 'Tieni il dito sulla pietra');
    final ripiego = _fase == _Fase.getto
        ? 'Se preferisci, tocca la pietra per gettarla.'
        : (_riduciMovimento
            ? 'Un tocco incide il segno per intero.'
            : 'Tieni premuto: il segno si scava fino a dove arrivi.');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
              color: _palette.deepest.withValues(alpha: 0.5),
              border: Border.all(color: _palette.gold.withValues(alpha: 0.5)),
            ),
            child: Text(testo,
                key: const Key('sunset_prompt'),
                style: TypographyTokens.label(size: 12)
                    .copyWith(color: _palette.goldSoft, letterSpacing: 0.6)),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(ripiego,
              textAlign: TextAlign.center,
              style: TypographyTokens.label(size: 11).copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                  letterSpacing: 0.2)),
        ],
      ),
    );
  }

  // --- La lettura: due voci, striscia, sigillo, azioni ---
  Widget _lettura() {
    return SingleChildScrollView(
      key: const Key('sunset_rune'),
      padding: const EdgeInsets.fromLTRB(
          SpacingTokens.lg, SpacingTokens.xxl, SpacingTokens.lg, SpacingTokens.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_ritorno)
            Padding(
              padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
              child: Text(SunsetRuneCorpus.intestazioneRitorno(_e.rune.name),
                  key: const Key('sunset_ritorno'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.label(size: 12).copyWith(
                      color: _palette.goldSoft, letterSpacing: 0.4, height: 1.4)),
            ),
          // La pietra che gira per svelare la seconda voce.
          Center(child: _pietraGirata()),
          const SizedBox(height: SpacingTokens.md),
          Center(
            child: Text(_e.rune.name.toUpperCase(),
                key: const Key('sunset_nome'),
                style: TypographyTokens.display(size: 30)
                    .copyWith(color: _palette.goldSoft)),
          ),
          Center(
            child: Text(_e.rune.keyword.toUpperCase(),
                style: TypographyTokens.label(size: 11).copyWith(
                    color: ColorTokens.textSecondary, letterSpacing: 1.4)),
          ),
          const SizedBox(height: 2),
          Center(
            child: Text(
                _e.simmetrica
                    ? SunsetRuneCorpus.noteSimmetrica
                    : (_e.inOmbra ? 'verso d\'ombra' : 'verso dritto'),
                style: TypographyTokens.label(size: 12).copyWith(
                    color: _palette.goldSoft.withValues(alpha: 0.8),
                    letterSpacing: 0.6)),
          ),
          const SizedBox(height: SpacingTokens.lg),
          // Voce A: cosa lasci fuori.
          _bloccoVoce('Cosa lasci fuori', _vocePrima(), const Key('sunset_voce_uno')),
          const SizedBox(height: SpacingTokens.sm),
          Text(SunsetRuneCorpus.trasparenza(_e),
              key: const Key('sunset_trasparenza'),
              style: TypographyTokens.label(size: 11).copyWith(
                  color: ColorTokens.textSecondary, letterSpacing: 0.2)),
          const SizedBox(height: SpacingTokens.lg),
          // Voce B dietro la rotazione della pietra.
          if (!_giroFatto)
            _invitoGira()
          else
            _bloccoVoce('Cosa porti dentro la notte', _vocePortare(),
                const Key('sunset_voce_due')),
          const SizedBox(height: SpacingTokens.lg),
          _striscia(),
          if (_settimaSera) ...[
            const SizedBox(height: SpacingTokens.lg),
            _sigilloSettimana(),
          ],
          const SizedBox(height: SpacingTokens.lg),
          _azioni(),
          const SizedBox(height: SpacingTokens.xxxl),
        ],
      ),
    );
  }

  Widget _pietraGirata() {
    return AnimatedBuilder(
      animation: Listenable.merge([_alone, _flip]),
      builder: (context, _) {
        final t = _giroFatto ? (_riduciMovimento ? 1.0 : _flip.value) : 0.0;
        final angolo = math.pi * t;
        final mostraRetro = angolo > math.pi / 2;
        final m = Matrix4.identity()
          ..setEntry(3, 2, 0.0015)
          ..rotateY(angolo);
        // La faccia B e' controruotata di pi greco, cosi' il suo contenuto
        // appare diritto e non specchiato: e' il retro inciso della pietra.
        final faccia = mostraRetro
            ? Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(math.pi),
                child: _facciaGlifo(retro: true),
              )
            : _facciaGlifo(retro: false);
        return Transform(
          alignment: Alignment.center,
          transform: m,
          child: SizedBox(width: 150, height: 168, child: faccia),
        );
      },
    );
  }

  Widget _invitoGira() {
    return GestureDetector(
      key: const Key('sunset_gira_doppio'),
      onDoubleTap: _gira,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(SpacingTokens.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
          border: Border.all(color: _palette.gold.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Text('Gira la pietra',
                key: const Key('sunset_gira'),
                style: TypographyTokens.display(size: 18)
                    .copyWith(color: _palette.goldSoft)),
            const SizedBox(height: SpacingTokens.xs),
            // L'inclinazione si nomina solo quando il giroscopio ha risposto:
            // mai promettere un gesto che su questo dispositivo non funziona.
            Text(
                _puoInclinare
                    ? 'Inclina il telefono sull\'asse lungo, oppure tocca due '
                        'volte: la pietra mostra il suo rovescio.'
                    : 'Tocca due volte: la pietra mostra il suo rovescio.',
                textAlign: TextAlign.center,
                style: TypographyTokens.label(size: 11).copyWith(
                    color: ColorTokens.textSecondary, height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _bloccoVoce(String titolo, String testo, Key key) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        color: _palette.deepest.withValues(alpha: 0.42),
        border: Border.all(color: _palette.gold.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titolo.toUpperCase(),
              style: TypographyTokens.label(size: 12)
                  .copyWith(color: _palette.goldSoft, letterSpacing: 0.8)),
          const SizedBox(height: SpacingTokens.xs),
          Text(testo,
              style: TypographyTokens.body(size: 16)
                  .copyWith(color: ColorTokens.textPrimary, height: 1.55)),
        ],
      ),
    );
  }

  static final Map<String, Rune> _perNome = {
    for (final r in kElderFuthark) r.name: r,
  };

  Widget _striscia() {
    // Sette caselle per DATA, non per conteggio: i sette giorni rituali che
    // arrivano a oggi. Un giorno saltato lascia la sua casella vuota al suo
    // posto, senza spostare le altre.
    final oggi = _e.giornoRituale;
    final perGiorno = {for (final s in _settimana) s.giorno: s};
    return Column(
      key: const Key('sunset_settimana'),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var i = 0; i < 7; i++)
              _casella(oggi.subtract(Duration(days: 6 - i)), perGiorno),
          ],
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(_rigaSettimana(),
            key: const Key('sunset_settimana_riga'),
            textAlign: TextAlign.center,
            style: TypographyTokens.label(size: 11)
                .copyWith(color: ColorTokens.textSecondary, letterSpacing: 0.2)),
      ],
    );
  }

  Widget _casella(DateTime giornoCasella, Map<String, SeraSalvata> perGiorno) {
    final iso = SunsetRune.iso(giornoCasella);
    final sera = perGiorno[iso];
    final piena = sera != null;
    final oggi = iso == _e.giornoIso;
    return Container(
      key: piena ? Key('sunset_casella_$iso') : null,
      width: 30,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: piena
            ? _palette.surfaceElevated.withValues(alpha: 0.95)
            : Colors.transparent,
        border: Border.all(
            color: _palette.gold.withValues(alpha: piena ? 0.7 : 0.22),
            width: oggi ? 2 : 1),
        boxShadow: oggi
            ? [
                BoxShadow(
                    color: _palette.goldSoft.withValues(alpha: 0.5),
                    blurRadius: 8)
              ]
            : null,
      ),
      child: piena
          ? Padding(
              padding: const EdgeInsets.all(3),
              child: _miniaturaRuna(sera.rune))
          : null,
    );
  }

  // La miniatura rune_bone della sera, con la lettera come solo ripiego se
  // l'asset non c'e'.
  Widget _miniaturaRuna(String nome) {
    final r = _perNome[nome];
    if (r != null && r.hasImage) {
      return Image.asset(r.thumbPath!,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _letteraRuna(nome));
    }
    return _letteraRuna(nome);
  }

  Widget _letteraRuna(String nome) => Center(
        child: Text(nome.substring(0, 1),
            style: TypographyTokens.label(size: 13)
                .copyWith(color: _palette.goldSoft)),
      );

  String _rigaSettimana() {
    final n = _settimana.length;
    if (n <= 1) {
      return 'La prima delle sette. Questa striscia si riempie una sera per volta.';
    }
    if (n >= 7) {
      return 'Sette sere su sette. Le tue rune si sono legate.';
    }
    const parole = ['zero', 'prima', 'seconda', 'terza', 'quarta', 'quinta', 'sesta'];
    return '${_capitale(parole[n])} sera su sette. '
        'Alla settima le tue rune si legheranno.';
  }

  String _capitale(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Widget _sigilloSettimana() {
    // Il sigillo si compone solo alla settima sera, quindi la settimana e'
    // sempre piena: niente ramo "incompleta", che sarebbe irraggiungibile.
    final rune = _runeSettimana;
    final conteggi = <String, int>{};
    for (final r in rune) {
      conteggi[r] = (conteggi[r] ?? 0) + 1;
    }
    final ordinate = conteggi.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final ripetute = ordinate.any((e) => e.value > 1);
    final dueDom = ordinate.take(2).map((e) => e.key).toList();
    final didascalia = ripetute
        ? 'La settimana lega ${dueDom.first} e ${dueDom.last}: due segni che '
            'tornano, un legame solo.'
        : 'Sette segni diversi in sette sere: nessuno ha insistito, la '
            'settimana ti ha parlato una volta sola per volta.';
    return Container(
      key: const Key('sunset_sigillo'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        color: _palette.deepest.withValues(alpha: 0.5),
        border: Border.all(color: _palette.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text('IL SIGILLO DELLA SETTIMANA',
              style: TypographyTokens.label(size: 12)
                  .copyWith(color: _palette.goldSoft, letterSpacing: 0.8)),
          const SizedBox(height: SpacingTokens.sm),
          BindruneSigillo(
            runeNames: rune,
            oro: _palette.gold,
            alone: _palette.goldSoft,
            lato: 168,
            deduplica: true,
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(didascalia,
              textAlign: TextAlign.center,
              style: TypographyTokens.body(size: 14)
                  .copyWith(color: ColorTokens.textPrimary, height: 1.5)),
        ],
      ),
    );
  }

  Widget _azioni() {
    // Alla settima sera le azioni condividono il sigillo, con le sette rune per
    // la carta bindrune; prima condividono la singola pietra.
    return _Azioni(
      palette: _palette,
      estrazione: _e,
      runeSettimana: _settimaSera ? _runeSettimana : null,
    );
  }

  void _mostraFonti() {
    final tramonto = _tramonto;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheet) => Container(
        key: const Key('sunset_sources_sheet'),
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
                Text('Fonti e metodo',
                    style: TypographyTokens.display(size: 19)
                        .copyWith(color: _palette.goldSoft)),
                const SizedBox(height: SpacingTokens.sm),
                Text(_fontiEMetodo(tramonto),
                    style: TypographyTokens.body(size: 15).copyWith(
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

  String _fontiEMetodo(DateTime? tramonto) {
    final ora = tramonto == null
        ? 'in calcolo'
        : '${tramonto.hour.toString().padLeft(2, '0')}:'
            '${tramonto.minute.toString().padLeft(2, '0')}';
    final oraRiga = _stimata
        ? 'Il tramonto è stimato dal fuso, la posizione non è attiva: $ora.'
        : 'Il tramonto di stasera è calcolato sul tuo luogo: $ora.';
    return "L'Elder Futhark è l'alfabeto runico germanico di ventiquattro segni, "
        "nelle tre aett di Freyr, Hagal e Tyr, qui nell'ordine tradizionale. Il "
        "verso d'ombra o merkstave è una convenzione moderna: otto segni sono "
        "simmetrici e non lo hanno, quindi restano sempre dritti.\n\n"
        "L'estrazione è deterministica: nasce dalla data del tramonto incrociata "
        "con la tua data di nascita e col tuo segno, quindi la runa è tua e non "
        "la stessa per tutti. Il responso si compone di quattro fattori reali: la "
        "runa, il suo verso, la fase lunare vera della sera e il tuo segno solare.\n\n"
        "$oraRiga L'ora usa l'algoritmo NOAA, sul dispositivo, senza rete.\n\n"
        "Per intrattenimento e crescita personale, nessuna promessa deterministica.";
  }
}

// ===========================================================================
// I painter della scena.
// ===========================================================================

/// Il fondale del tramonto: se ci sono i tre webp li usa, altrimenti dipinge un
/// cielo di tramonto procedurale, orizzonte basso e sole per meta' sotto la
/// linea, rame verso viola, una stella singola. Nessun cerchio, nessuna raggiera.
class _Fondale extends StatelessWidget {
  const _Fondale({
    required this.palette,
    required this.completa,
    required this.momento,
    required this.riduciMovimento,
  });

  final MaestroPalette palette;
  final bool completa;

  /// Zero prima del getto, uno durante l'incisione, due dopo il completamento.
  final int momento;

  final bool riduciMovimento;

  // I tre slot dipinti, cablati come costanti. I file non esistono ancora: a
  // runtime l'errorBuilder ripiega sul procedurale, senza toccare stato_asset.
  static const List<String> _slots = [
    'assets/ritual_backgrounds/tramonto_prima_v1.webp',
    'assets/ritual_backgrounds/tramonto_al_v1.webp',
    'assets/ritual_backgrounds/tramonto_dopo_v1.webp',
  ];

  @override
  Widget build(BuildContext context) {
    final slot = _slots[momento.clamp(0, 2)];
    final vista = Image.asset(
      slot,
      key: ValueKey<String>(slot),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => CustomPaint(
          key: ValueKey<int>(momento.clamp(0, 2)),
          painter: _TramontoPainter(palette: palette, completa: completa)),
    );
    // Il cambio di stato del tramonto si dissolve invece di scattare. Con Riduci
    // Movimento la durata scende a zero e resta lo scambio diretto.
    return AnimatedSwitcher(
      duration:
          riduciMovimento ? Duration.zero : const Duration(milliseconds: 900),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      layoutBuilder: (current, previous) => Stack(
        fit: StackFit.expand,
        children: [...previous, if (current != null) current],
      ),
      child: vista,
    );
  }
}

class _TramontoPainter extends CustomPainter {
  _TramontoPainter({required this.palette, required this.completa});

  final MaestroPalette palette;
  final bool completa;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // Gradiente rame verso viola, che dopo l'incisione scende di un gradino.
    final alto = completa
        ? const Color(0xFF2A1230)
        : const Color(0xFF7A3B1E);
    final medio = completa
        ? const Color(0xFF3A1840)
        : const Color(0xFFB8632C);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF120818),
            alto,
            medio,
            palette.deepest,
          ],
          stops: const [0.0, 0.4, 0.66, 1.0],
        ).createShader(rect),
    );
    final orizzonte = size.height * 0.72;
    // Sole per meta' sotto la linea dell'orizzonte.
    final sole = Offset(size.width * 0.5, orizzonte);
    canvas.drawCircle(
      sole,
      size.width * 0.5,
      Paint()
        ..shader = RadialGradient(colors: [
          (completa ? const Color(0xFFCC8877) : const Color(0xFFFFE0A8))
              .withValues(alpha: completa ? 0.18 : 0.4),
          const Color(0x00000000),
        ]).createShader(Rect.fromCircle(center: sole, radius: size.width * 0.5)),
    );
    canvas.drawCircle(
      sole,
      size.width * 0.16,
      Paint()
        ..color = (completa ? const Color(0xFFB86A5A) : const Color(0xFFFFCE7A))
            .withValues(alpha: completa ? 0.5 : 0.85),
    );
    // La linea dell'orizzonte copre la meta' bassa del sole.
    canvas.drawRect(
      Rect.fromLTRB(0, orizzonte, size.width, size.height),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            medio.withValues(alpha: 0.9),
            palette.deepest,
          ],
        ).createShader(Rect.fromLTRB(0, orizzonte, size.width, size.height)),
    );
    // Una stella singola, sola nel cielo del tramonto.
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.22),
      2.2,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.22),
      7,
      Paint()
        ..shader = RadialGradient(colors: [
          Colors.white.withValues(alpha: 0.4),
          const Color(0x00000000),
        ]).createShader(Rect.fromCircle(
            center: Offset(size.width * 0.7, size.height * 0.22), radius: 7)),
    );
  }

  @override
  bool shouldRepaint(_TramontoPainter old) => old.completa != completa;
}

// I toni della pietra d'osso: avorio caldo in alto, osso ombrato in basso, una
// venatura grigia calda. Cosi' la pietra sta vicino all'asset osso reale e alla
// dissolvenza non c'e' salto di materiale. Il bordeaux di Caligo resta solo
// nell'ambiente attorno, non sulla pietra.
const Color _ossoAlto = Color(0xFFF0E6CC);
const Color _ossoBasso = Color(0xFF9E8C64);
const Color _ossoVena = Color(0xFF7B6E52);
const Color _ossoBordo = Color(0xFFCBB483);

/// Disegna la sagoma della pietra d'osso, scoperta, coi toni avorio: la sagoma
/// ad arco condivisa fra pietra velata e tavola d'incisione.
void _dipingiPietra(Canvas canvas, Rect rect, RRect rrect, {double vena = 0.5}) {
  // Ombra 2.5D morbida.
  canvas.drawRRect(
    rrect.shift(const Offset(0, 8)),
    Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
  );
  canvas.drawRRect(
    rrect,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_ossoAlto, _ossoBasso],
      ).createShader(rect),
  );
  // Una venatura grigia calda, appena accennata, che rompe la superficie piatta.
  final vx = rect.left + rect.width * vena;
  canvas.drawLine(
    Offset(vx, rect.top + rect.height * 0.18),
    Offset(vx - rect.width * 0.12, rect.bottom - rect.height * 0.2),
    Paint()
      ..strokeWidth = 1.4
      ..color = _ossoVena.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
  );
  canvas.drawRRect(
    rrect,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = _ossoBordo.withValues(alpha: 0.85),
  );
}

/// La pietra d'osso in stato velato, con un alone caldo che respira e un sigillo
/// coperto al centro. Mai un rettangolo nudo.
class _PietraVelataPainter extends CustomPainter {
  _PietraVelataPainter({required this.palette, required this.respiro});

  final MaestroPalette palette;
  final double respiro;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final w = size.width * 0.52;
    final h = size.height * 0.82;
    final rect = Rect.fromCenter(center: c, width: w, height: h);
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(w * 0.5),
      topRight: Radius.circular(w * 0.5),
      bottomLeft: const Radius.circular(16),
      bottomRight: const Radius.circular(16),
    );
    // Alone caldo, dell'ambiente attorno, che respira fra alpha 0.25 e 0.40.
    final a = 0.25 + 0.15 * respiro;
    canvas.drawRRect(
      rrect.inflate(20),
      Paint()
        ..color = palette.goldSoft.withValues(alpha: a)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );
    _dipingiPietra(canvas, rect, rrect);
    // Sigillo coperto al centro, appena intuibile.
    canvas.drawCircle(
      c,
      w * 0.22,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = _ossoVena.withValues(alpha: 0.4),
    );
  }

  @override
  bool shouldRepaint(_PietraVelataPainter old) => old.respiro != respiro;
}

/// L'incisione tratto per tratto, nell'ordine reale di kRuneStrokes, col raggio
/// che scende dall'orizzonte e la punta dove si sta scavando.
class _IncisionePainter extends CustomPainter {
  _IncisionePainter({
    required this.runeName,
    required this.progresso,
    required this.palette,
    required this.completa,
  });

  final String runeName;
  final double progresso;
  final MaestroPalette palette;
  final bool completa;

  @override
  void paint(Canvas canvas, Size size) {
    final strokes = kRuneStrokes[runeName];
    if (strokes == null) return;
    // La tavola di pietra scoperta su cui si scava: la stessa sagoma ad arco
    // della pietra velata, senza il velo, cosi' il getto atterra qui e la
    // superficie da incidere e' sempre visibile, anche prima del primo tratto.
    _tavola(canvas, size);
    // Il lato del glifo nasce dalla larghezza vera della pietra, con un margine
    // interno del 18% per lato: cosi' anche Dagaz, Gebo e Ingwaz restano dentro.
    final larghezzaPietra = size.width * 0.52;
    final lato = larghezzaPietra * 0.64;
    final left = (size.width - lato) / 2;
    final top = (size.height - lato) / 2;
    Offset map(Offset p) => Offset(left + p.dx * lato, top + p.dy * lato);

    // Lunghezze cumulative dei tratti, per scavare in proporzione.
    final lunghezze = <double>[];
    var totale = 0.0;
    for (final poly in strokes) {
      var l = 0.0;
      for (var i = 1; i < poly.length; i++) {
        l += (map(poly[i]) - map(poly[i - 1])).distance;
      }
      lunghezze.add(l);
      totale += l;
    }
    final daScavare = totale * progresso.clamp(0.0, 1.0);

    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lato * 0.05
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFFFFF3D0).withValues(alpha: 0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, lato * 0.03);
    final solco = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lato * 0.03
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = completa ? const Color(0xFFCC4B22) : const Color(0xFFFFF6DA);

    var fatto = 0.0;
    Offset? punta;
    for (var s = 0; s < strokes.length; s++) {
      final poly = strokes[s];
      if (fatto >= daScavare) break;
      final path = Path()..moveTo(map(poly.first).dx, map(poly.first).dy);
      var ultimo = poly.first;
      for (var i = 1; i < poly.length; i++) {
        final segLen = (map(poly[i]) - map(poly[i - 1])).distance;
        if (fatto + segLen <= daScavare) {
          path.lineTo(map(poly[i]).dx, map(poly[i]).dy);
          fatto += segLen;
          ultimo = poly[i];
        } else {
          final resto = (daScavare - fatto) / segLen;
          final p = Offset.lerp(poly[i - 1], poly[i], resto.clamp(0.0, 1.0))!;
          path.lineTo(map(p).dx, map(p).dy);
          fatto = daScavare;
          ultimo = p;
          break;
        }
      }
      canvas.drawPath(path, glow);
      canvas.drawPath(path, solco);
      punta = map(ultimo);
    }

    // Il raggio parte dalla linea d'orizzonte della pietra, il suo bordo basso,
    // non dal fondo del canvas, e svanisce con un gradiente prima di uscire.
    if (!completa && progresso > 0 && progresso < 1 && punta != null) {
      final orizzonte = Offset(
          size.width / 2, size.height / 2 + (size.height * 0.82) / 2 - 6);
      canvas.drawLine(
        orizzonte,
        punta,
        Paint()
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..shader = const LinearGradient(
            colors: [
              Color(0x00FFF3D0),
              Color(0x8CFFF3D0),
            ],
          ).createShader(Rect.fromPoints(orizzonte, punta)),
      );
      // Qualche scintilla sulla punta.
      final rng = math.Random((progresso * 1000).floor());
      for (var i = 0; i < 4; i++) {
        canvas.drawCircle(
          punta + Offset((rng.nextDouble() - 0.5) * 10, (rng.nextDouble() - 0.5) * 10),
          rng.nextDouble() * 1.4 + 0.4,
          Paint()..color = Colors.white.withValues(alpha: 0.8),
        );
      }
    }
  }

  // La pietra scoperta, superficie del segno. Sagoma e toni osso condivisi con
  // la pietra velata, cosi' alla dissolvenza verso l'asset non c'e' salto.
  void _tavola(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final w = size.width * 0.52;
    final h = size.height * 0.82;
    final rect = Rect.fromCenter(center: c, width: w, height: h);
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(w * 0.5),
      topRight: Radius.circular(w * 0.5),
      bottomLeft: const Radius.circular(16),
      bottomRight: const Radius.circular(16),
    );
    _dipingiPietra(canvas, rect, rrect, vena: 0.42);
  }

  @override
  bool shouldRepaint(_IncisionePainter old) =>
      old.progresso != progresso || old.completa != completa;
}

/// Condividi e Parlane con Caligo, con la carta fuori campo per lo scatto.
class _Azioni extends StatefulWidget {
  const _Azioni({
    required this.palette,
    required this.estrazione,
    this.runeSettimana,
  });

  final MaestroPalette palette;
  final EstrazioneTramonto estrazione;

  /// Le sette rune della settimana, quando si condivide dal sigillo: la carta
  /// diventa la bindrune invece della singola pietra.
  final List<String>? runeSettimana;

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
      await shareSunsetRuneCard(
          boundaryKey: _boundary, estrazione: widget.estrazione);
    } finally {
      // La carta fuori campo torna a non essere renderizzata: senza questo
      // resta a decodificare inutilmente dopo ogni condivisione.
      if (mounted) {
        setState(() {
          _condividendo = false;
          _rendi = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                key: const Key('sunset_share'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: palette.goldSoft,
                    side:
                        BorderSide(color: palette.gold.withValues(alpha: 0.6))),
                onPressed: _condividendo ? null : _condividi,
                icon: const Icon(Icons.ios_share_rounded),
                label: const Text('Condividi'),
              ),
              const SizedBox(height: SpacingTokens.sm),
              FilledButton.icon(
                key: const Key('sunset_consulta'),
                style: FilledButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: palette.onPrimary),
                onPressed: () {
                  final services = context.read<AppServices>();
                  final verso = widget.estrazione.inOmbra
                      ? 'in merkstave'
                      : 'dritta';
                  Navigator.of(context).push(MaestroChatScreen.route(
                      maestro: Maestro.caligo,
                      services: services,
                      initialUserMessage: ChatOpeners.runaTramonto(
                          widget.estrazione.rune.name, verso)));
                },
                icon: const Icon(Icons.forum_outlined),
                label: const Text('Parlane con Caligo'),
              ),
            ],
          ),
        ),
        if (_rendi)
          Positioned(
            left: -3000,
            top: 0,
            child: RepaintBoundary(
              key: _boundary,
              child: SunsetRuneCard(
                  estrazione: widget.estrazione,
                  palette: widget.palette,
                  runeSettimana: widget.runeSettimana),
            ),
          ),
      ],
    );
  }
}

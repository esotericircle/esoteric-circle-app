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

/// I tre fondali del tramonto, nell'ordine dei momenti: prima del getto, durante
/// l'incisione, dopo che il segno e' compiuto. Sono una lista sola, esposta,
/// cosi' schermata, precarico e catture non possono divergere sui percorsi.
const List<String> kFondaliTramonto = [
  'assets/ritual_backgrounds/tramonto_prima_v1.webp',
  'assets/ritual_backgrounds/tramonto_al_v1.webp',
  'assets/ritual_backgrounds/tramonto_dopo_v1.webp',
];

/// Il primo tratto della runa, in coordinate normalizzate, dalla stessa sorgente
/// che il painter usa per il simbolo: nessuna geometria duplicata.
///
/// Serve al fantasma del gesto, che mostra SOLO questo tratto. Mai il simbolo
/// intero: mostrarlo tutto brucerebbe la rivelazione, che e' il cuore del rito.
/// Vuoto se la runa non ha geometria.
List<Offset> primoTrattoDi(String nomeRuna) {
  final strokes = kRuneStrokes[nomeRuna];
  if (strokes == null || strokes.isEmpty) return const [];
  return strokes.first;
}

/// Il percorso della pietra vergine, cioe' l'osso senza segno, a partire dallo
/// stem della runa. Gli stem di `kElderFuthark` finiscono gia' in `_v1`, quindi
/// il suffisso di versione va tolto prima di riapplicarlo: senza questo il nome
/// uscirebbe con due versioni in coda e non troverebbe mai il file.
/// Null quando la runa non ha arte.
String? pathVergineDi(String? stem) {
  if (stem == null) return null;
  final base = stem.endsWith('_v1') ? stem.substring(0, stem.length - 3) : stem;
  return 'assets/img/rune_bone_vergine/${base}_vergine_v1.webp';
}

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

  // Il fantasma del gesto: un punto di luce che percorre il primo tratto della
  // runa vera, per insegnare il gesto a chi resta fermo. Compare solo dopo un
  // silenzio, mostra solo il primo tratto, e sparisce per sempre al primo tocco.
  Timer? _attesaFantasma;
  late final AnimationController _fantasma;
  bool _fantasmaVisibile = false;
  bool _fantasmaSpento = false;

  /// Quanto silenzio serve prima che l'invito si mostri: chi ha capito subito
  /// non lo vede mai.
  static const Duration _silenzioPrimaDelFantasma = Duration(milliseconds: 1500);

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
  Offset? _ultimoPunto; // dove stava il dito al passo precedente del tracciato
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
  String _identita = ''; // risolta una sola volta, riusata a ogni riestrazione

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
    _fantasma = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500));
    _ascoltaScuotimento();
  }

  /// Programma la comparsa del fantasma: solo in incisione, solo se non e' gia'
  /// stato spento, e solo dopo il silenzio.
  void _attendiFantasma() {
    if (_fantasmaSpento) return;
    _attesaFantasma?.cancel();
    _attesaFantasma = Timer(_silenzioPrimaDelFantasma, () {
      if (!mounted ||
          _fantasmaSpento ||
          _fase != _Fase.incisione ||
          _incisione > 0) {
        return;
      }
      setState(() => _fantasmaVisibile = true);
      // Con Riduci Movimento non viaggia nulla: resta un velo fermo.
      if (!_riduciMovimento) _fantasma.repeat();
    });
  }

  /// Il primo contatto del dito lo spegne, e non torna piu' per questa apertura.
  void _spegniFantasma() {
    _attesaFantasma?.cancel();
    _attesaFantasma = null;
    if (_fantasmaSpento && !_fantasmaVisibile) return;
    _fantasmaSpento = true;
    _fantasma.stop();
    if (_fantasmaVisibile) setState(() => _fantasmaVisibile = false);
  }

  bool _fondaliPrecaricati = false;

  // I tre fondali del tramonto, decodificati all'ingresso: senza questo la prima
  // dissolvenza mostrerebbe un lampo, perche' l'immagine del momento successivo
  // arriva mentre la transizione e' gia' partita.
  void _precaricaFondali() {
    if (_fondaliPrecaricati) return;
    _fondaliPrecaricati = true;
    for (final slot in kFondaliTramonto) {
      precacheImage(AssetImage(slot), context, onError: (_, __) {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _riduciMovimento = MediaQuery.of(context).disableAnimations;
    _precaricaFondali();
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
    _identita = identita;
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
    _ritornoFuture ??= _controllaRitorno();
    _cercaOssoVergine();
  }

  @override
  void dispose() {
    _attesaFantasma?.cancel();
    _fantasma.dispose();
    _incisioneTicker?.dispose();
    _shakeSub?.cancel();
    _giroSub?.cancel();
    _ingresso.dispose();
    _alone.dispose();
    _rimbalzo.dispose();
    _flip.dispose();
    super.dispose();
  }

  // Raffina l'ora del tramonto con la posizione reale, e con essa la fase lunare:
  // se la posizione c'e', la fase segue il tramonto VERO, non quello stimato dal
  // fuso. Runa e verso restano ancorati al solo giorno rituale, quindi non
  // cambiano mai. Usa `resolveSeConcesso`: aprire il Dono non chiede permessi,
  // la richiesta esplicita vive dietro "Attiva la posizione".
  Future<void> _raffinaTramonto() async {
    final luogo = await widget.location.resolveSeConcesso();
    if (luogo == null || !mounted) return;
    final offset = _ora.timeZoneOffset;
    final t = SunsetTime.perData(_e.giornoRituale,
            lat: luogo.latitude, lon: luogo.longitude, offset: offset) ??
        SunsetTime.oraMedia(_e.giornoRituale);
    setState(() {
      _tramonto = t;
      _stimata = false;
      _estrazione = _riestrai(t);
    });
  }

  /// Riestrae con l'istante di tramonto dato: cambia solo la fase lunare, la
  /// runa e il verso nascono dal giorno rituale e restano quelli.
  EstrazioneTramonto _riestrai(DateTime istante) => SunsetRune.estrai(
        _ora,
        dataNascita: _nascita,
        segno: widget.segno,
        identita: _identita,
        istanteTramonto: istante,
      );

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
    // Da qui parte il silenzio: se il dito non arriva, l'invito si mostra.
    _attendiFantasma();
  }

  // --- Gesto due: l'incisione ---
  //
  // Il segno si scava in due modi che si sommano: il tempo di pressione, che da
  // solo basta a compiere la runa, e il tracciamento del dito sulla pietra, che
  // e' il gesto vero del rituale e arriva in fondo prima. Nessuno dei due fa mai
  // regredire il progresso.

  /// Quanto percorso serve, in punti logici, perche' il solo tracciamento
  /// compia il segno. Cresce coi tratti come la durata a dito fermo: la pietra
  /// e' larga duecentoquaranta punti, quindi una runa a due tratti si incide con
  /// un paio di passate decise, e tracciando si arriva prima che stando fermi.
  double get _percorsoPerCompletare => _numeroTratti * 260.0;

  void _inizioIncisione([Offset? punto]) {
    if (_fase != _Fase.incisione || _completa) return;
    // Il dito e' arrivato: l'invito ha finito il suo compito.
    _spegniFantasma();
    _premuto = true;
    _ultimoPunto = punto;
    // Alla ripresa NON si azzera il progresso: il primo tick fissa solo la base
    // temporale, cosi' una pausa lunga fra due pressioni non incide di colpo.
    _primoTick = true;
    _incisioneTicker ??= createTicker(_passoIncisione);
    if (!_incisioneTicker!.isActive) _incisioneTicker!.start();
    setState(() {});
  }

  /// Il dito che traccia: ogni pezzo di percorso scava, in proporzione alla
  /// distanza coperta. Solo avanti, mai indietro.
  void _muoveIncisione(Offset punto) {
    if (_fase != _Fase.incisione || _completa) return;
    final precedente = _ultimoPunto;
    _ultimoPunto = punto;
    if (precedente == null) return;
    final tratto = (punto - precedente).distance;
    if (tratto <= 0) return;
    _avanza(tratto / _percorsoPerCompletare);
  }

  void _fineIncisione() {
    if (_fase != _Fase.incisione) return;
    _premuto = false;
    _ultimoPunto = null;
    // Il progresso resta dov'e', ma il ticker si ferma: mentre il dito e'
    // alzato il tempo non deve accumularsi e poi scaricarsi tutto alla ripresa.
    // Nel ripiego Riduci Movimento l'incisione va da se', quindi non si ferma.
    if (!_riduciMovimento) _incisioneTicker?.stop();
    setState(() {});
  }

  /// L'unico punto in cui il segno avanza, da qualunque contributo arrivi:
  /// tiene il feedback aptico a ogni tratto e il completamento in un posto solo.
  void _avanza(double quota) {
    if (quota <= 0 || _completa) return;
    final prima = _incisione;
    _incisione = (_incisione + quota).clamp(0.0, 1.0);
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
    _avanza(dt / durata);
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
    // Prima la clausola d'insistenza, POI la composizione: altrimenti il testo
    // persistito, e quindi il sigillo e la condivisione, potrebbe mancare la
    // clausola che l'utente ha letto dal vivo.
    await (_ritornoFuture ??= _controllaRitorno());
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

  // La clausola di insistenza, se la runa e' gia' tornata nei sette giorni. Il
  // Future e' memoizzato: la lettura avviene una volta sola, e la lettura la
  // attende prima di comporre e persistere.
  String? _insistenza;
  bool _ritorno = false;
  Future<void>? _ritornoFuture;

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
        // Nessuno scrim piatto: sul cielo fotografico taglierebbe una riga netta
        // all'altezza dell'orizzonte. Al suo posto una velatura che sfuma verso
        // il basso, che tiene leggibili titolo e icone senza tagliare la scena.
        backgroundColor: Colors.transparent,
        flexibleSpace: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _palette.deepest.withValues(alpha: 0.55),
                _palette.deepest.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
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
              style: TypographyTokens.display(size: 20)),
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
        const SizedBox(height: SpacingTokens.md),
        _invito(),
        const SizedBox(height: SpacingTokens.xl),
      ],
    );
  }

  /// L'ombra morbida dietro le lettere: tiene leggibile il testo sopra il
  /// fondale senza bisogno di uno sfondo pieno, che somiglierebbe a un comando.
  static const List<Shadow> _ombraTesto = [
    Shadow(color: Color(0xCC000000), blurRadius: 8),
    Shadow(color: Color(0x99000000), blurRadius: 3),
  ];

  /// La riga di stato, in cima al blocco in fondo: piccola e smorzata, e' una
  /// nota di servizio, non un messaggio del rito. Col luogo vero dice solo l'ora
  /// del tramonto, e allora il pulsante sotto non serve piu' e sparisce.
  Widget _rigaOra() {
    final t = _tramonto;
    final ora = t == null
        ? ''
        : '${t.hour.toString().padLeft(2, '0')}:'
            '${t.minute.toString().padLeft(2, '0')}';
    // Misura reale, sopra il minimo del token: a 10 sarebbe stata alzata a 12.5
    // in silenzio, e la gerarchia fra nota di servizio e invito sarebbe stata
    // solo dichiarata, non vera.
    final stile = TypographyTokens.label(size: 13).copyWith(
      color: Colors.white.withValues(alpha: 0.6),
      letterSpacing: 0.3,
      shadows: _ombraTesto,
    );
    if (!_stimata) {
      return Text('Tramonto alle $ora',
          key: const Key('sunset_ora'), style: stile);
    }
    return Column(
      children: [
        Text(
            t == null
                ? 'Ora stimata, la posizione non è attiva'
                : 'Ora stimata delle $ora, la posizione non è attiva',
            key: const Key('sunset_stimata'),
            textAlign: TextAlign.center,
            style: stile),
        const SizedBox(height: SpacingTokens.sm),
        // L'unica cosa toccabile della schermata, e si vede che lo e': bordo,
        // riempimento tenue in chiave oro, area di tocco piena.
        OutlinedButton(
          key: const Key('sunset_attiva'),
          onPressed: _attivaPosizione,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.lg, vertical: 10),
            backgroundColor: _palette.gold.withValues(alpha: 0.16),
            side: BorderSide(color: _palette.gold.withValues(alpha: 0.75)),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(SpacingTokens.radiusPill)),
          ),
          child: Text('Attiva la posizione',
              style: TypographyTokens.label(size: 12.5)
                  .copyWith(color: _palette.goldSoft, letterSpacing: 0.6)),
        ),
      ],
    );
  }

  Future<void> _attivaPosizione() async {
    // Riprova a risolvere la posizione, non blocca la scena.
    // Qui, e solo qui, si puo' chiedere il permesso: e' il gesto esplicito
    // dell'utente. Passa dalla sorgente iniettata, cosi' il ramo e' testabile.
    final luogo = await widget.location.resolve();
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
      // Col luogo vero anche la fase segue il tramonto vero.
      _estrazione = _riestrai(t);
    });
  }

  /// Il percorso dell'osso vergine della runa del giorno, cioe' la stessa pietra
  /// che si vedra' incisa, ancora senza segno. Cosi' fra attesa, incisione e
  /// lettura la materia e' la stessa e il passaggio non si vede.
  String? get _ossoVerginePath => pathVergineDi(_e.rune.stem);

  // Vero solo quando l'osso vergine della runa del giorno esiste davvero nel
  // bundle. Si verifica una volta, cosi' la scena non dipende dall'errorBuilder
  // di un'immagine che carica in differita, e la pietra c'e' dal primo frame.
  bool _ossoVergineCe = false;

  Future<void> _cercaOssoVergine() async {
    final path = _ossoVerginePath;
    if (path == null) return;
    try {
      await DefaultAssetBundle.of(context).load(path);
      if (mounted) setState(() => _ossoVergineCe = true);
    } catch (_) {
      // I ventiquattro file non ci sono ancora: resta la pietra dipinta. In
      // debug si dice quale percorso e' mancato: il silenzio su un asset
      // assente e' il modo in cui un percorso sbagliato passa inosservato.
      assert(() {
        debugPrint('Runa del Tramonto: osso vergine assente, cercato in $path');
        return true;
      }());
    }
  }

  Widget _pietraVergine(double lato) {
    if (_ossoVergineCe) {
      return Image.asset(
        _ossoVerginePath!,
        key: const Key('sunset_stone_vergine'),
        fit: BoxFit.contain,
      );
    }
    return CustomPaint(
      key: const Key('sunset_stone'),
      size: Size(lato, lato),
      painter: _PietraVelataPainter(palette: _palette, respiro: _alone.value),
    );
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
          child: _pietraVergine(lato),
        ),
      );
    }
    // Incisione: si tiene il dito e il segno si scava un tratto alla volta.
    return GestureDetector(
      key: const Key('sunset_incisione_gesture'),
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (d) => _inizioIncisione(d.localPosition),
      onLongPressMoveUpdate: (d) => _muoveIncisione(d.localPosition),
      onLongPressEnd: (_) => _fineIncisione(),
      onTap: _riduciMovimento ? _inizioIncisione : null,
      child: SizedBox(
        width: lato,
        height: lato,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // I tratti scavati, che sfumano quando arriva l'asset. Il fantasma
            // del gesto vive dentro lo stesso painter, sopra la pietra e sotto
            // i segni incisi.
            AnimatedOpacity(
              opacity: _completa ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 500),
              child: AnimatedBuilder(
                animation: _fantasma,
                builder: (context, _) => CustomPaint(
                  key: const Key('sunset_incisione'),
                  size: const Size(lato, lato),
                  painter: _IncisionePainter(
                    runeName: _e.rune.name,
                    progresso: _incisione,
                    palette: _palette,
                    completa: _completa,
                    fantasma: _fantasmaVisibile
                        ? (_riduciMovimento ? -1.0 : _fantasma.value)
                        : null,
                  ),
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


  /// Una riga sola di invito, che cambia con la fase e dice il gesto vero.
  ///
  /// Nessuno sfondo: la leggibilita' viene dall'ombra dietro le lettere, cosi'
  /// il testo non somiglia a un comando. Si scrive "sulla pietra" e non "sulla
  /// runa", perche' in quel momento la runa non c'e' ancora: c'e' una pietra
  /// vergine, e il simbolo e' il premio che emerge alla fine. L'a capo della riga
  /// dell'incisione e' imposto nella stringa, altrimenti l'ultima parola resta
  /// orfana da sola in fondo.
  String get _testoInvito {
    if (_fase == _Fase.getto) {
      return 'Scuoti il telefono o tocca la pietra\nper gettarla.';
    }
    if (_riduciMovimento) return 'Tocca la pietra per incidere il simbolo.';
    return 'Traccia con il dito sulla pietra\ne scopri il simbolo.';
  }

  Widget _invito() {
    // Appena il segno comincia, l'invito ha fatto il suo lavoro e si toglie di
    // mezzo: sfuma via e non torna. A incisione compiuta in fondo restano solo
    // la pietra e il simbolo.
    final visibile = _incisione <= 0;
    return AnimatedOpacity(
      opacity: visibile ? 1 : 0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
        child: Text(_testoInvito,
            key: const Key('sunset_invito'),
            textAlign: TextAlign.center,
            // L'invito e' un'istruzione del gesto, che nel design system sta
            // nella famiglia del corpo testo alla misura di guida, non fra le
            // etichette: label(size: 12) veniva per giunta alzato in silenzio a
            // 12.5 dal clamp, quindi la gerarchia non esisteva a video.
            style: TypographyTokens.body(size: TypographyTokens.guide).copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 0.5,
              height: 1.5,
              shadows: _ombraTesto,
            )),
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
                  style: TypographyTokens.label(size: 12.5).copyWith(
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
                style: TypographyTokens.label(size: 12.5).copyWith(
                    color: ColorTokens.textSecondary, letterSpacing: 1.4)),
          ),
          const SizedBox(height: 2),
          Center(
            child: Text(
                _e.simmetrica
                    ? SunsetRuneCorpus.noteSimmetrica
                    : (_e.inOmbra ? 'verso d\'ombra' : 'verso dritto'),
                style: TypographyTokens.label(size: 12.5).copyWith(
                    color: _palette.goldSoft.withValues(alpha: 0.8),
                    letterSpacing: 0.6)),
          ),
          const SizedBox(height: SpacingTokens.lg),
          // Voce A: cosa lasci fuori.
          _bloccoVoce('Cosa lasci fuori', _vocePrima(), const Key('sunset_voce_uno')),
          const SizedBox(height: SpacingTokens.sm),
          Text(SunsetRuneCorpus.trasparenza(_e),
              key: const Key('sunset_trasparenza'),
              style: TypographyTokens.label(size: 12.5).copyWith(
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
                style: TypographyTokens.display(size: 20)
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
                style: TypographyTokens.label(size: 12.5).copyWith(
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
              style: TypographyTokens.label(size: 12.5)
                  .copyWith(color: _palette.goldSoft, letterSpacing: 0.8)),
          const SizedBox(height: SpacingTokens.xs),
          Text(testo,
              style: TypographyTokens.body(size: 17)
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
            style: TypographyTokens.label(size: 12.5)
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
              style: TypographyTokens.label(size: 12.5)
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
              style: TypographyTokens.body(size: 17)
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
                    style: TypographyTokens.display(size: 20)
                        .copyWith(color: _palette.goldSoft)),
                const SizedBox(height: SpacingTokens.sm),
                Text(_fontiEMetodo(tramonto),
                    style: TypographyTokens.body(size: 17).copyWith(
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
    required this.momento,
    required this.riduciMovimento,
  });

  final MaestroPalette palette;

  /// Zero prima del getto, uno durante l'incisione, due dopo il completamento.
  final int momento;

  final bool riduciMovimento;

  // I tre fondali dipinti del tramonto, presenti in assets/ritual_backgrounds/
  // con l'orizzonte allineato al 35,5% su tutti e tre. Se mancassero,
  // l'errorBuilder ripiega sul procedurale senza toccare stato_asset.
  static const List<String> slots = kFondaliTramonto;

  @override
  Widget build(BuildContext context) {
    final quale = momento.clamp(0, 2);
    final slot = slots[quale];
    final vista = Image.asset(
      slot,
      key: ValueKey<String>(slot),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => CustomPaint(
          key: ValueKey<int>(quale),
          painter: _TramontoPainter(palette: palette, momento: quale)),
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

/// Il ripiego procedurale del fondale, quando i tre webp non ci sono. I tre
/// momenti dipingono tre frame DIVERSI: il sole scende, il cielo si spegne, le
/// stelle aumentano. Cosi' il ripiego resta distinguibile momento per momento e
/// la dissolvenza si vede anche senza asset.
class _TramontoPainter extends CustomPainter {
  _TramontoPainter({required this.palette, required this.momento});

  final MaestroPalette palette;

  /// Zero prima del getto, uno durante l'incisione, due dopo il completamento.
  final int momento;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // I tre cieli: rame pieno, rame che si spegne, viola di notte incipiente.
    const alti = [Color(0xFF7A3B1E), Color(0xFF5E2A22), Color(0xFF2A1230)];
    const medi = [Color(0xFFB8632C), Color(0xFF8E4527), Color(0xFF3A1840)];
    final alto = alti[momento];
    final medio = medi[momento];
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
    // Il disco scende momento per momento: a meta' fuori, poi appena sopra la
    // linea, poi quasi tutto sotto.
    const affondo = [0.0, 0.45, 0.85];
    final raggio = size.width * 0.16;
    final sole =
        Offset(size.width * 0.5, orizzonte + raggio * affondo[momento]);
    // Alone caldo, che si smorza col calare della luce.
    const aloneAlpha = [0.4, 0.28, 0.16];
    canvas.drawCircle(
      sole,
      size.width * 0.5,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFFE0A8).withValues(alpha: aloneAlpha[momento]),
          const Color(0x00000000),
        ]).createShader(Rect.fromCircle(center: sole, radius: size.width * 0.5)),
    );
    const dischi = [Color(0xFFFFCE7A), Color(0xFFE79A5E), Color(0xFFB86A5A)];
    const discoAlpha = [0.85, 0.7, 0.45];
    // Il disco sfuma sui bordi, cosi' il raccordo con l'orizzonte non e' una
    // cucitura netta ma un passaggio morbido.
    canvas.drawCircle(
      sole,
      raggio,
      Paint()
        ..shader = RadialGradient(
          colors: [
            dischi[momento].withValues(alpha: discoAlpha[momento]),
            dischi[momento].withValues(alpha: discoAlpha[momento]),
            dischi[momento].withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.72, 1.0],
        ).createShader(Rect.fromCircle(center: sole, radius: raggio)),
    );
    // La terra sotto l'orizzonte, con il bordo alto sfumato: il sole vi affonda
    // senza uno scalino.
    final terra = Rect.fromLTRB(0, orizzonte, size.width, size.height);
    canvas.drawRect(
      terra,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            medio.withValues(alpha: 0.0),
            medio.withValues(alpha: 0.92),
            palette.deepest,
          ],
          stops: const [0.0, 0.16, 1.0],
        ).createShader(terra),
    );
    // Le stelle: una sola all'inizio, tre a notte incipiente.
    const stelle = [
      [Offset(0.70, 0.22)],
      [Offset(0.70, 0.22), Offset(0.28, 0.16)],
      [Offset(0.70, 0.22), Offset(0.28, 0.16), Offset(0.52, 0.09)],
    ];
    for (final s in stelle[momento]) {
      final p = Offset(size.width * s.dx, size.height * s.dy);
      canvas.drawCircle(
          p, 2.2, Paint()..color = Colors.white.withValues(alpha: 0.9));
      canvas.drawCircle(
        p,
        7,
        Paint()
          ..shader = RadialGradient(colors: [
            Colors.white.withValues(alpha: 0.4),
            const Color(0x00000000),
          ]).createShader(Rect.fromCircle(center: p, radius: 7)),
      );
    }
  }

  @override
  bool shouldRepaint(_TramontoPainter old) => old.momento != momento;
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
void _dipingiPietra(Canvas canvas, Rect rect, RRect rrect) {
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
    // Al centro, un invito intenzionale invece di un segno muto: tre solchi
    // brevi che pulsano col respiro, il posto dove nascera' la runa. Non un
    // cerchio con una diagonale, che si leggeva come un difetto della texture.
    final pulsa = 0.28 + 0.22 * respiro;
    final passo = h * 0.055;
    for (var i = -1; i <= 1; i++) {
      final y = c.dy + i * passo;
      canvas.drawLine(
        Offset(c.dx - w * 0.13, y),
        Offset(c.dx + w * 0.13, y),
        Paint()
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round
          ..color = _ossoVena.withValues(alpha: pulsa * (i == 0 ? 1.0 : 0.6)),
      );
    }
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
    this.fantasma,
  });

  final String runeName;
  final double progresso;
  final MaestroPalette palette;
  final bool completa;

  /// Il fantasma del gesto: null quando non si mostra, da 0 a 1 la posizione nel
  /// ciclo del punto che viaggia, e il valore convenzionale -1 per il velo fermo
  /// del ripiego con Riduci Movimento.
  final double? fantasma;

  /// Lo stesso painter a un altro avanzamento. Serve alla misura dei pixel del
  /// solco, che deve poter fotografare stati diversi del rendering vero senza
  /// ricostruirne una copia approssimata.
  _IncisionePainter copiaCon({double? progresso, bool? completa}) =>
      _IncisionePainter(
        runeName: runeName,
        progresso: progresso ?? this.progresso,
        palette: palette,
        completa: completa ?? this.completa,
        fantasma: fantasma,
      );

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
    // Il fantasma sta qui: sopra la pietra, sotto i segni incisi che seguono.
    if (fantasma != null) {
      _dipingiFantasma(canvas, lato, left, top);
    }
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

    // Il segno e' un SOLCO scavato nella pietra, non un filo di luce: la
    // larghezza nasce dal lato del glifo, e la profondita' cresce col gesto,
    // cosi' a meta' incisione il solco e' meno inciso che a segno compiuto.
    final profondita = 0.45 + 0.55 * progresso.clamp(0.0, 1.0);
    final spessore = lato * (0.115 + 0.06 * profondita);
    // Ombra portata dentro il solco, sul bordo alto: e' l'osso che sporge sopra
    // lo scavo. Marcata, perche' su pietra chiara e' lei a far leggere il segno.
    // Regola: lo scarto su ciascun asse deve valere almeno 2.2 volte il sigma
    // della sfocatura. Prima era 0.20 di scarto contro 0.34 di sigma, cioe' lo
    // scarto era PIU' PICCOLO della sfocatura: l'ombra si spandeva concentrica
    // attorno al tratto e leggeva come alone, non come profondita'.
    const sigmaOmbra = 0.18;
    const scartoPerAsse = 0.50; // 0.50 su 0.18 fa 2.8, sopra la regola di 2.2
    final ombraAlta = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = spessore * 1.15
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFF2A1D0E).withValues(alpha: 0.55 * profondita)
      ..maskFilter =
          MaskFilter.blur(BlurStyle.normal, spessore * sigmaOmbra);
    final scartoOmbra =
        Offset(-spessore * scartoPerAsse, -spessore * scartoPerAsse);
    // Il fondo del solco: materia mancante, non luce. Bruno scuro con una
    // dominante calda che lo stacca dall'avorio della pietra senza sembrare
    // inchiostro steso sopra.
    final fondo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = spessore
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = (completa
              ? const Color(0xFF6E2410)
              : const Color(0xFF3A2410))
          .withValues(alpha: 0.82 + 0.10 * profondita);
    // Il nucleo piu' cupo al centro dello scavo: da' fondo al solco.
    final nucleo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = spessore * 0.52
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = (completa
              ? const Color(0xFF4A1408)
              : const Color(0xFF1C1206))
          .withValues(alpha: 0.55 * profondita);
    // Il lume sul bordo opposto all'ombra, in basso a destra: e' il labbro dello
    // scavo che prende luce, e chiude la lettura del rilievo.
    //
    // Qui contano insieme geometria, ordine di disegno e contrasto, e i primi
    // due tentativi hanno sbagliato proprio su questo.
    //
    // Il lume va disegnato PER ULTIMO, sopra il fondo: sotto verrebbe sepolto
    // lungo i tratti dritti e affiorerebbe solo ai capi tondi, cioe' come
    // puntini staccati. E va posato A CAVALLO del bordo dello scavo, non tutto
    // fuori: un bianco su avorio non ha contrasto e sparirebbe comunque, mentre
    // sul labbro, dove sotto c'e' il fondo scuro, si legge. Lo scarto e' quindi
    // 0.38 per lato, che in diagonale fa 0.537 dal centro; con meta' larghezza a
    // 0.11 il lume occupa da 0.43 a 0.65, cioe' scavalca il bordo del fondo, che
    // sta a 0.5. Cosi' corre continuo lungo tutto il tratto.
    final bordoLuce = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = spessore * 0.22
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFFFFF6DC).withValues(alpha: 0.72);
    final scartoLuce = Offset(spessore * 0.38, spessore * 0.38);

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
      // Quattro passate, nell'ordine in cui la luce cade davvero sull'intaglio:
      // l'ombra portata dall'osso che sporge, il fondo dello scavo, il nucleo
      // piu' cupo, e per ultimo il lume sul labbro opposto, che deve restare
      // sopra a tutto per non finire sepolto.
      canvas.drawPath(path.shift(scartoOmbra), ombraAlta);
      canvas.drawPath(path, fondo);
      canvas.drawPath(path, nucleo);
      canvas.drawPath(path.shift(scartoLuce), bordoLuce);
      punta = map(ultimo);
    }

    // Il raggio parte dalla linea d'orizzonte della pietra, il suo bordo basso,
    // non dal fondo del canvas, e svanisce con un gradiente prima di uscire.
    if (!completa && progresso > 0 && progresso < 1 && punta != null) {
      final orizzonte = Offset(
          size.width / 2, size.height / 2 + (size.height * 0.82) / 2 - 6);
      // Un accenno di luce, non una linea: il solco deve restare il solo segno
      // marcato sulla pietra, il raggio lo accompagna appena. Misura legata allo
      // spessore, mai in pixel fissi, altrimenti ingrassa quando il solco e'
      // sottile e si perde quando e' largo.
      canvas.drawLine(
        orizzonte,
        punta,
        Paint()
          ..strokeWidth = spessore * 0.14
          ..strokeCap = StrokeCap.round
          ..maskFilter =
              MaskFilter.blur(BlurStyle.normal, spessore * 0.14)
          ..shader = const LinearGradient(
            colors: [
              Color(0x00FFF3D0),
              Color(0x3DFFF3D0),
            ],
          ).createShader(Rect.fromPoints(orizzonte, punta)),
      );
      // Sulla punta non si aggiunge altro. Qui c'erano quattro scintille, e sono
      // state tolte: uno scalpello sulla pietra non fa scintille, e la luce del
      // rito e' gia' portata dal raggio verso l'orizzonte e dal labbro dello
      // scavo. In due tentativi hanno solo danneggiato l'intaglio, prima da
      // fuori, come dischi bianchi duri sull'avorio, poi da dentro, come velo
      // che faceva risalire il fondo del solco verso la punta invece di
      // chiuderla piena.
    }
  }

  /// Il fantasma del gesto: un punto di luce calda che percorre il PRIMO tratto
  /// della runa vera, con una scia corta dietro di se'. Insegna il gesto senza
  /// mostrare il simbolo, che resta la rivelazione della fine.
  ///
  /// Il ciclo dura quanto il controller: entra, percorre, esce, e resta un
  /// respiro di pausa prima di ricominciare. Col valore convenzionale -1, cioe'
  /// col ripiego di Riduci Movimento, non viaggia niente: il tratto appare come
  /// velo fermo a bassa opacita'.
  void _dipingiFantasma(Canvas canvas, double lato, double left, double top) {
    final t = fantasma!;
    final tratto = primoTrattoDi(runeName);
    if (tratto.length < 2) return;
    Offset map(Offset p) => Offset(left + p.dx * lato, top + p.dy * lato);

    // Il velo fermo del ripiego: tutto il primo tratto, chiaro e appena visibile.
    if (t < 0) {
      final path = Path()..moveTo(map(tratto.first).dx, map(tratto.first).dy);
      for (var i = 1; i < tratto.length; i++) {
        path.lineTo(map(tratto[i]).dx, map(tratto[i]).dy);
      }
      canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = lato * 0.07
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..color = const Color(0xFFFFE9B8).withValues(alpha: 0.30)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, lato * 0.03));
      return;
    }

    // Le fasi del ciclo: entrata, percorso, uscita, pausa.
    const entrata = 0.12;
    const uscita = 0.72;
    const finePausa = 0.85;
    if (t > finePausa) return; // il respiro fra un giro e l'altro
    double velo;
    if (t < entrata) {
      velo = t / entrata;
    } else if (t < uscita) {
      velo = 1;
    } else {
      velo = 1 - (t - uscita) / (finePausa - uscita);
    }
    final quota = t < entrata
        ? 0.0
        : (t > uscita ? 1.0 : (t - entrata) / (uscita - entrata));

    // Le lunghezze cumulative del tratto, per far scorrere il punto sul percorso.
    final punti = [for (final p in tratto) map(p)];
    var totale = 0.0;
    final tappe = <double>[0];
    for (var i = 1; i < punti.length; i++) {
      totale += (punti[i] - punti[i - 1]).distance;
      tappe.add(totale);
    }
    if (totale <= 0) return;

    Offset lungoIl(double distanza) {
      final d = distanza.clamp(0.0, totale);
      for (var i = 1; i < tappe.length; i++) {
        if (d <= tappe[i]) {
          final q = (d - tappe[i - 1]) / (tappe[i] - tappe[i - 1]);
          return Offset.lerp(punti[i - 1], punti[i], q)!;
        }
      }
      return punti.last;
    }

    final testa = lungoIl(totale * quota);
    // La scia, corta, che si assottiglia dietro la testa.
    final codaLunga = totale * 0.18;
    final scia = Path()..moveTo(testa.dx, testa.dy);
    const passi = 8;
    for (var i = 1; i <= passi; i++) {
      final p = lungoIl(totale * quota - codaLunga * (i / passi));
      scia.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
        scia,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = lato * 0.05
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = const Color(0xFFFFE9B8).withValues(alpha: 0.26 * velo)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, lato * 0.028));
    // Il punto di luce, tenue: suggerisce, non incide.
    canvas.drawCircle(
        testa,
        lato * 0.055,
        Paint()
          ..color = const Color(0xFFFFF3D6).withValues(alpha: 0.30 * velo)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, lato * 0.045));
    canvas.drawCircle(
        testa,
        lato * 0.022,
        Paint()
          ..color = const Color(0xFFFFF8E6).withValues(alpha: 0.62 * velo));
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
    _dipingiPietra(canvas, rect, rrect);
  }

  @override
  bool shouldRepaint(_IncisionePainter old) =>
      old.progresso != progresso ||
      old.completa != completa ||
      old.fantasma != fantasma;
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

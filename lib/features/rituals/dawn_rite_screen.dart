import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../../core/sigilli/ora_rituale.dart';
import 'package:provider/provider.dart';

import '../../core/identity/birth_identity.dart';
import '../../core/astro/natal_chart.dart';
import '../../core/identity/natal_identity.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/maestro/maestro.dart';
import '../../core/rituals/daily_rituals.dart';
import '../../core/astro/luogo_attuale.dart';
import '../../core/astro/sky_location.dart';
import '../../core/permissions/app_permission.dart';
import '../../core/permissions/avviso_del_permesso.dart';
import '../../core/permissions/esito_del_permesso.dart';
import '../../core/rituals/avvisi_del_rito.dart';
import '../../services/avvisi_locali.dart';
import '../../core/rituals/daily_elements.dart';
import '../../core/rituals/dawn_gift.dart';
import '../../core/rituals/filo_del_giorno.dart';
import '../../core/astro/solar_time.dart';
import '../../core/rituals/rito_alba.dart';
import '../../core/rituals/ritual_streak.dart';
import 'dove_sei_adesso.dart';
import 'ritual_gift_card.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../sigilli/regia_del_cammino.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../core/condivisione/porta_della_condivisione.dart';
import '../../../design_system/components/titolo_che_non_si_rompe.dart';
import '../maestri/rotta_arte.dart';
import '../../core/condivisione/premio_della_condivisione.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';

/// Rito dell'Alba, prototipo di riferimento dei cinque riti quotidiani.
///
/// Fondale reale cablato nello slot condiviso e Maestro a rotazione giornaliera,
/// entrambi gia' esistenti, restano il basamento. Sopra si costruisce il rito
/// completo: un gesto rituale di sollevamento dell'alba con un livello di luce
/// che cresce sopra la foto e uno stato rivelato che porge il dono del giorno.
///
/// Ogni gesto ha il suo ripiego tattile universale (tocco o tocco prolungato) e
/// tutte le animazioni rispettano Riduci Movimento.
class DawnRiteScreen extends StatefulWidget {
  const DawnRiteScreen({
    super.key,
    this.now,
    this.location = const DisabledSkyLocation(),
    this.avvisi = const AvvisiSpenti(),
  });

  /// IL SERVIZIO DEGLI AVVISI, spento di default.
  ///
  /// Il permesso si chiede **la prima volta che si apre questo rito**, non
  /// all'avvio dell'app, e con la spiegazione davanti. Chi dice no continua a
  /// usare tutto: nessuna funzione si chiude.
  final ServizioAvvisi avvisi;

  final DateTime? now;

  /// DOVE SEI STAMATTINA, per l'ora del sorgere.
  ///
  /// **Non e' il luogo di nascita**: un'alba e' dove sei adesso. Si legge con
  /// `resolveSeConcesso`, cioe' solo se il permesso e' gia' stato dato: il rito
  /// del mattino non apre una richiesta di posizione all'alba. Senza posizione
  /// il rito resta intero e non nomina l'ora, invece di nominarne una falsa.
  ///
  /// Spenta di default, come nella veduta del cielo, cosi' le prove non toccano
  /// il sensore.
  final SkyLocation location;

  /// La rotta dell'app vera parla col servizio VERO: fino all'ordine M
  /// nessuno costruiva `AvvisiLocali`, quindi il rito chiedeva il permesso e
  /// poi programmava sull'implementazione spenta di default, e nessun avviso
  /// partiva davvero sul telefono. Le prove continuano a iniettare il finto.
  static Route<void> route(
          {DateTime? now, SkyLocation? location, ServizioAvvisi? avvisi}) =>
      PassaggioDelCerchio.rotta<void>((_) => MaestroScope(
          child: DawnRiteScreen(
            now: now,
            location: location ?? const GeolocatorSkyLocation(),
            avvisi: avvisi ?? avvisiDelCerchio,
          ),
        ));

  @override
  State<DawnRiteScreen> createState() => _DawnRiteScreenState();
}

class _DawnRiteScreenState extends State<DawnRiteScreen>
    with TickerProviderStateMixin {

  /// L'ESITO DEL PERMESSO DEGLI AVVISI, nei tre valori distinti.
  ///
  /// Ordine 2166, voce 2. La richiesta tornava un si' o un no, quindi chi
  /// aveva negato per sempre restava senza avvisi e senza saperlo: il rito
  /// non diceva niente e le impostazioni erano l'unica via, mai nominata.
  EsitoDelPermesso? _esitoDegliAvvisi;
  // Livello di sollevamento dell'alba, da 0 (velato) a 1 (alba sollevata).
  double _progress = 0;
  bool _revealed = false;
  DawnGift? _gift;
  int _streak = 0;

  // Anima il completamento del gesto, o il ritorno se rilasciato troppo presto.
  late final AnimationController _lift;
  Animation<double>? _liftAnim;

  // Deriva lenta e brillio del riflesso, ambiente, ferma sotto Riduci Movimento.
  late final AnimationController _ambient;

  // I tre livelli del motore del sorgere, decodificati come immagini vere per
  // comporli in un solo canvas con i blend giusti (il sole in additivo).
  ui.Image? _nightImg;
  ui.Image? _dayImg;
  ui.Image? _sunImg;

  // Distanza di trascinamento verso l'alto che solleva del tutto l'alba.
  static const double _dragSpan = 220;
  // Oltre questa soglia, al rilascio, l'alba si compie da sola.
  static const double _completeThreshold = 0.55;

  @override
  void initState() {
    super.initState();
    _lift = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..addListener(() {
        final anim = _liftAnim;
        if (anim != null) setState(() => _progress = anim.value);
      });
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
    _loadLayers();
    // IL LUOGO ATTUALE SI LEGGE ALL'APERTURA, ordine P voce 23: e' conservato,
    // quindi non si chiede niente a nessuno per saperlo.
    DoveSonoAdesso.letto().then((luogo) {
      if (!mounted || luogo == null) return;
      setState(() => _luogoDichiarato = luogo);
      // Se il dono e' gia' composto, si ricompone con l'ora vera.
      if (_revealed) _ricomponiIlDono();
    });
    // Il permesso degli avvisi si chiede all'APERTURA del rito, dopo il primo
    // fotogramma, non all'avvio dell'app.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chiediAvvisiLaPrimaVolta();
    });
  }

  Future<void> _loadLayers() async {
    try {
      final imgs = await Future.wait([
        _resolveAsset('assets/ritual_backgrounds/dawn_sky_night.png'),
        _resolveAsset('assets/ritual_backgrounds/dawn_sky_day.png'),
        _resolveAsset('assets/ritual_backgrounds/dawn_sun.png'),
      ]);
      if (!mounted) return;
      setState(() {
        _nightImg = imgs[0];
        _dayImg = imgs[1];
        _sunImg = imgs[2];
      });
    } catch (_) {
      // Se un asset non si decodifica, il motore resta senza livelli e non
      // disegna nulla: nessun crash.
    }
  }

  // Risolve un asset in una ui.Image passando dal framework, cosi' sfrutta la
  // cache immagini e resta decodificabile anche in un test dopo precacheImage.
  Future<ui.Image> _resolveAsset(String asset) {
    final completer = Completer<ui.Image>();
    final stream = AssetImage(asset).resolve(const ImageConfiguration());
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        if (!completer.isCompleted) completer.complete(info.image);
        stream.removeListener(listener);
      },
      onError: (error, stack) {
        if (!completer.isCompleted) completer.completeError(error);
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
    return completer.future;
  }

  @override
  void dispose() {
    _lift.dispose();
    _ambient.dispose();
    _nightImg?.dispose();
    _dayImg?.dispose();
    _sunImg?.dispose();
    super.dispose();
  }

  bool get _reduceMotion => MediaQuery.of(context).disableAnimations;

  // Carta natale dell'utente dal profilo, se disponibile. Senza
  // ProfileController, per esempio montando lo screen da solo in un test, si
  // ripiega su null e il dono resta fondato ma senza ancora natale.
  BirthIdentity? _identity() {
    try {
      return context.read<ProfileController>().identity;
    } catch (_) {
      return null;
    }
  }

  /// LA CARTA NATALE, dalla stessa fonte da cui la prende l'Oroscopo.
  ///
  /// Serve al transito vero della scheda piena: senza carta non ci sono
  /// transiti da leggere, e la riga sparisce invece di dire di aspettare.
  NatalChart? _carta() {
    try {
      // IL CIELO VERO, non il ripiego. `chart` torna anche la carta
      // essenziale, che ha un astro solo: leggerci dei transiti vorrebbe dire
      // dichiarare un cielo che non e' stato calcolato.
      return context.read<BirthIdentityController>().cartaCompleta;
    } on ProviderNotFoundException catch (assente) {
      // NON E' UN CATCH MUTO, ed e' l'unico errore che qui si ignora.
      //
      // Nell'app vera questo provider sta sopra tutto, in `app.dart`: se
      // manca, siamo in una prova che monta la schermata da sola. Senza carta
      // il transito non c'e' e la riga sparisce, che e' esattamente cio' che
      // succede a chi non ha dato ora e luogo di nascita. Qualunque ALTRO
      // errore passa, perche' un cielo che non si calcola va visto.
      assert(() {
        // ignore: avoid_print
        print('Rito dell\'Alba senza BirthIdentityController: $assente');
        return true;
      }());
      return null;
    }
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_revealed) return;
    _lift.stop();
    setState(() {
      // Trascinare verso l'alto (delta negativo) solleva l'alba.
      _progress =
          (_progress - (d.primaryDelta ?? 0) / _dragSpan).clamp(0.0, 1.0);
    });
  }

  void _onDragEnd(DragEndDetails _) {
    if (_revealed) return;
    if (_progress >= _completeThreshold) {
      _complete();
    } else {
      _animateProgressTo(0);
    }
  }

  // Ripiego tattile universale: un tocco, o un tocco prolungato, compie il rito.
  void _tapComplete() {
    if (_revealed) return;
    _complete();
  }

  void _complete() {
    if (_reduceMotion) {
      setState(() => _progress = 1);
      _reveal();
      return;
    }
    _animateProgressTo(1, onDone: _reveal);
  }

  void _animateProgressTo(double target, {VoidCallback? onDone}) {
    _liftAnim = Tween<double>(begin: _progress, end: target).animate(
      CurvedAnimation(parent: _lift, curve: Curves.easeOutCubic),
    );
    _lift.forward(from: 0).then((_) {
      if (mounted) onDone?.call();
    });
  }

  void _reveal() {
    if (_revealed) return;
    final date = widget.now ?? DateTime.now();
    setState(() {
      _revealed = true;
      _gift = DawnGift.forChart(date,
          identity: _identity(),
          posizione: _posizione(date),
          carta: _carta());
    });
    _recordStreak(date).then((_) => _programmaAvviso());
    _aggiornaPosizione(date);
    // IL FILO DEL GIORNO, ordine P voce 18: la parola di stamattina si segna
    // qui, e stasera il Sigillo del Sogno la richiama. Senza questo la Parola del
    // Giorno resta un ornamento: nasce, sta un minuto a schermo e non torna.
    final parola = _gift?.word;
    if (parola != null) {
      unawaited(FiloDelGiorno.segnaLaParola(parola, date));
    }
    // E la domanda che Medora ha lasciato ieri nella stesa torna qui, nel dono
    // del mattino successivo, come chiede la voce 09.
    unawaited(FiloDelGiorno.domandaDiIeri(date).then((domanda) {
      if (mounted && domanda != null) {
        setState(() => _domandaDiIeri = domanda);
      }
    }));
  }

  /// La domanda lasciata ieri da Medora, se ieri c'e' stata una stesa.
  String? _domandaDiIeri;

  /// La posizione con cui si e' composto il rito, con la sua origine.
  ///
  /// **Tre strade in ordine di verita', ordine P voce 23**: il dispositivo, poi
  /// la citta' che la persona ha DICHIARATO nel profilo, poi la stima dal fuso
  /// che non si dichiara mai.
  PosizioneDiStamattina _posizione(DateTime date) =>
      PosizioneDiStamattina.da(_dovesSei, date.timeZoneOffset,
          dichiarato: _luogoDichiarato);

  /// La citta' in cui la persona ha detto di vivere, conservata fra un avvio e
  /// l'altro. Nulla finche' non l'ha detta.
  LuogoAttuale? _luogoDichiarato;

  /// Dove sei stamattina, se il permesso c'e' gia'. Null finche' non si sa.
  SkyPlace? _dovesSei;

  /// CHIEDE IL PERMESSO DEGLI AVVISI, una volta sola, alla prima apertura.
  ///
  /// **Qui e non all'avvio dell'app.** Chiedere di notificare a chi ha appena
  /// installato, senza che sappia cosa riceverebbe, e' il modo piu' sicuro di
  /// farsi dire di no. Qui la persona ha appena visto cos'e' il rito.
  ///
  /// **Chi dice no non perde niente**, e non gli si richiede piu': la risposta
  /// si accetta. Chi cambia idea passa dalle impostazioni di sistema.
  Future<void> _chiediAvvisiLaPrimaVolta() async {
    if (!widget.avvisi.disponibile) return;
    if (await AvvisiDelRito.giaChiesto()) return;
    if (!mounted) return;

    await AvvisiDelRito.segnaChiesto();
    final maestro = DailyRituals.dawnMaestro(widget.now ?? DateTime.now());
    if (!mounted) return;
    await requestPermissionWithPrelude(
      context,
      permission: AppPermission.notifications,
      palette: MaestroPalette.forKey(ThemeKey.of(maestro)),
      maestro: maestro,
      // NON si usa il testo generico dei permessi: quello parla di ritorni
      // solari e transiti, cioe' di avvisi che non esistono. Qui si dice cosa
      // si riceve davvero, uno al giorno, con l'ora dichiarata approssimata.
      copy: const PermissionCopy(
        icon: Icons.wb_twilight_rounded,
        title: 'Ti sveglio col sole?',
        body: AvvisiDelRito.spiegazione,
        cta: 'Avvisami all\'alba',
      ),
      // LA PORTA UNICA DEI TRE ESITI: il plugin sa dire solo si' o no, e la
      // porta ricava il no per sempre dal fatto che il dialogo di sistema
      // compare una volta sola. La ragione per esteso sta su
      // `PortaDelPermesso`.
      systemRequest: () async {
        final esito = await PortaDelPermesso.chiedi(
          AppPermission.notifications,
          richiestaDiSistema: widget.avvisi.chiediPermesso,
        );
        if (mounted) setState(() => _esitoDegliAvvisi = esito);
        return esito == EsitoDelPermesso.concesso;
      },
    );
    await _programmaAvviso();
  }

  /// Programma il prossimo avviso. Passa sempre dalla porta sola.
  Future<void> _programmaAvviso() async {
    final date = widget.now ?? DateTime.now();
    await AvvisiDelRito.programmaProssimo(
      servizio: widget.avvisi,
      adesso: date,
      posizione: _posizione(date),
    );
  }

  /// Chiede la posizione SOLO se il permesso e' gia' concesso, e ricompone il
  /// rito se arriva.
  ///
  /// **Non apre nessuna richiesta di permesso.** Chi apre il rito all'alba non
  /// deve trovarsi davanti una finestra di sistema: se la posizione c'e' gia',
  /// il rito guadagna l'ora del sorgere; se non c'e', resta intero senza.
  Future<void> _aggiornaPosizione(DateTime date) async {
    final luogo = await widget.location.resolveSeConcesso();
    if (!mounted || luogo == null) return;
    setState(() {
      _dovesSei = luogo;
      _gift = DawnGift.forChart(date,
          identity: _identity(),
          posizione: _posizione(date),
          carta: _carta());
    });
  }

  /// Ricompone il dono con la posizione che si conosce adesso.
  ///
  /// Esisteva in due copie, una in `_reveal` e una in `_aggiornaPosizione`, e
  /// con la citta' dichiarata sarebbero diventate tre: un punto solo.
  void _ricomponiIlDono() {
    final date = widget.now ?? DateTime.now();
    setState(() {
      _gift = DawnGift.forChart(date,
          identity: _identity(),
          posizione: _posizione(date),
          carta: _carta());
    });
  }

  Future<void> _recordStreak(DateTime date) async {
    final n = await const RitualStreak(id: 'dawn').recordToday(date);
    if (!mounted) return;
    // IL CAMMINO SE NE ACCORGE: il rito e' compiuto, non aperto.
    // L'ORA RITUALE SI MISURA, ordine P voce 35. Qui c'era 'alba' scritta a
    // mano: aprendo il rito a mezzogiorno il traguardo del cielo si accendeva
    // lo stesso, e il traguardo che non si affretta diventava il piu' facile
    // di tutti.
    // **PRIMA CHE IL SOLE SORGA DAVVERO, ordine BX voce 01.** Il corpus
    // chiede "un Rito dell'Alba compiuto prima che il sole sorga davvero, nel
    // tuo luogo", e l'app sapeva solo se il gesto cadeva nell'ORA RITUALE
    // dell'alba, che e' una fascia larga. Il sorgere vero l'app lo sa gia'
    // calcolare, `SolarTime.albaPerData`, e il rito conosce gia' la posizione
    // con cui si e' composto: qui le due cose si incontrano.
    //
    // **Senza posizione non si dice niente**, invece di inventare un sorgere:
    // il dettaglio resta assente e il gradino aspetta un mattino in cui la
    // posizione c'e'.
    final dove = _posizione(date);
    final sorgere = SunsetTime.albaPerData(date,
        lat: dove.lat, lon: dove.lon, offset: date.timeZoneOffset);
    final primaDelSole = sorgere != null && date.isBefore(sorgere);
    unawaited(RegiaDelCammino.dopoUnGesto(context, 'alba',
        oraRituale: OraRituale.diAdesso(),
        dettagli: primaDelSole
            ? const {'prima_del_sole': ['si']}
            : const <String, Object?>{}));
    setState(() => _streak = n);
  }

  /// **SI CONDIVIDE CIO' CHE SI VEDE, e all'Alba si vede la parola.**
  /// Ordine BB voce 06.
  ///
  /// La parola del giorno vive nell'Alba e solo li', **e non da sola**: porta
  /// con se' cosa indica, che e' la risposta alla domanda del fondatore "cosa
  /// ne faccio adesso di questa parola". Anche condividendola le due cose
  /// restano insieme: una parola spedita nuda a chi non ha l'app davanti
  /// sarebbe ancora piu' muta che a schermo.
  Future<void> _shareWord(DawnGift gift) async {
    final word = gift.word;
    if (word == null) return;
    // Si chiama "ragione" e non "perche" di proposito: il nome della
    // variabile finisce dentro l'interpolazione della stringa condivisa, e
    // l'esame degli accenti, che legge le stringhe come testo mostrato, vi
    // trovava un "perche" senza accento che nessuno avrebbe mai visto.
    final ragione = gift.rito?.perche;
    try {
      final andata = await PortaDellaCondivisione.testo(
          'La mia parola del giorno dal Rito dell\'Alba: $word.'
          '${ragione == null ? '' : ' $ragione'} Con Esoteric Circle.');
// Ordine BG voce 04: il premio dichiarato sul pulsante si paga qui,
// a condivisione davvero avvenuta.
if (andata && mounted) {
  await PremioDellaCondivisione.premia(context,
      cosa: 'Hai condiviso la parola del giorno');
}
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Condivisione non disponibile ora.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.now ?? DateTime.now();
    final maestro = DailyRituals.dawnMaestro(date);
    final palette = MaestroPalette.forKey(ThemeKey.of(maestro));

    return Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.4),
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        // **IL TITOLO NON SI ROMPE**, ordine S voce 05: a capo fra le
        // parole, la misura scende solo quanto serve, e non si tronca mai.
        // Col borsellino nella riga delle azioni lo spazio del titolo si e'
        // ristretto, e un `Text` nudo qui torna a mettere i puntini.
        title: TitoloCheNonSiRompe(
            chiaveDelTesto: const Key('alba_titolo'),
            testo: 'Rito dell\'Alba',
            stile: TypographyTokens.titoloDiSchermata()),
        // IL BORSELLINO, ordine S voce 06: stesso segno, stesso angolo, in
        // ogni schermata della pratica. Un saldo che appare e scompare non
        // si impara.
        actions: const [AngoloDellaBarra()],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Il motore del sorgere a livelli, composto in un solo canvas cosi' i
          // blend sono corretti: cielo notte-giorno in dissolvenza, sole in
          // additivo con la sua corona zodiacale, mare davanti che lo copre
          // sull'orizzonte, riflesso e luna che svanisce. La vecchia ruota in
          // basso non c'e' piu': la ruota ora e' la corona del sole.
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: Listenable.merge([_lift, _ambient]),
                builder: (context, _) => CustomPaint(
                  painter: _DawnScenePainter(
                    progress: _progress,
                    ambient: _reduceMotion ? 0 : _ambient.value,
                    reduceMotion: _reduceMotion,
                    night: _nightImg,
                    day: _dayImg,
                    sun: _sunImg,
                  ),
                ),
              ),
            ),
          ),
          // Scena e responso.
          SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  flex: 5,
                  child: Semantics(
                    button: true,
                    label:
                        'Solleva l\'alba. Trascina verso l\'alto, oppure tocca.',
                    onTap: _tapComplete,
                    child: GestureDetector(
                      key: const Key('ritual_gesture'),
                      behavior: HitTestBehavior.opaque,
                      onVerticalDragUpdate: _onDragUpdate,
                      onVerticalDragEnd: _onDragEnd,
                      onTap: _tapComplete,
                      onLongPress: _tapComplete,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (!_revealed)
                            Align(
                              // In alto sul cielo notturno, libero dal sole che
                              // invita a sorgere sull'orizzonte, in basso.
                              alignment: const Alignment(0, -0.4),
                              child: _LiftPrompt(
                                  palette: palette, progress: _progress),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, 0,
                        SpacingTokens.lg, SpacingTokens.lg),
                    child: (_revealed && _gift != null)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              RitualGiftCard(
                                key: const Key('ritual_content'),
                                gift: _gift!,
                                dono: DailyElement.dawn,
                                giorno: widget.now ?? DateTime.now(),
                                streak: _streak,
                                domandaDiIeri: _domandaDiIeri,
                                onShare: () => _shareWord(_gift!),
                              ),
                              // DOVE SEI ADESSO, ordine P voce 23. Compare solo
                              // quando l'ora del sorgere non si puo'
                              // dichiarare, cioe' quando il rito sta
                              // rinunciando a dire una cosa vera: chi legge ha
                              // appena visto cosa gli manca.
                              if (!_posizione(widget.now ?? DateTime.now())
                                  .oraDichiarabile) ...[
                                const SizedBox(height: SpacingTokens.md),
                                DoveSeiAdesso(
                                  palette: MaestroPalette.forKey(ThemeKey.of(
                                      DailyRituals.dawnMaestro(
                                          widget.now ?? DateTime.now()))),
                                  maestro: DailyRituals.dawnMaestro(
                                      widget.now ?? DateTime.now()),
                                  location: widget.location,
                                  suScelto: (luogo) {
                                    setState(() => _luogoDichiarato = luogo);
                                    _ricomponiIlDono();
                                  },
                                ),
                              ],
                              // L'ESITO DEGLI AVVISI, detto qui e non
                              // taciuto: chi ha negato per sempre non vedra'
                              // mai piu' comparire la richiesta, e senza
                              // questa riga il rito resterebbe muto sul
                              // perche' l'alba non lo chiama.
                              if (_esitoDegliAvvisi != null &&
                                  _esitoDegliAvvisi !=
                                      EsitoDelPermesso.concesso) ...[
                                const SizedBox(height: SpacingTokens.md),
                                AvvisoDelPermesso(
                                  chiave: 'alba',
                                  permesso: AppPermission.notifications,
                                  esito: _esitoDegliAvvisi!,
                                  palette: MaestroPalette.forKey(ThemeKey.of(
                                      DailyRituals.dawnMaestro(
                                          widget.now ?? DateTime.now()))),
                                  onRichiedi: () async {
                                    final esito =
                                        await PortaDelPermesso.chiedi(
                                      AppPermission.notifications,
                                      richiestaDiSistema:
                                          widget.avvisi.chiediPermesso,
                                    );
                                    if (!mounted) return;
                                    setState(
                                        () => _esitoDegliAvvisi = esito);
                                    if (esito ==
                                        EsitoDelPermesso.concesso) {
                                      await _programmaAvviso();
                                    }
                                  },
                                ),
                              ],
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// L'invito al gesto, che si accende man mano che l'alba si solleva.
class _LiftPrompt extends StatelessWidget {
  const _LiftPrompt({required this.palette, required this.progress});

  final MaestroPalette palette;
  final double progress;

  @override
  Widget build(BuildContext context) {
    // **VIA IL VELO DIETRO L'INVITO. Ordine AS voce 06.**
    //
    // Qui c'era un `RadialGradient` nero dentro un Container rettangolare, per
    // tenere leggibile il testo sul riflesso del sole. Ma un gradiente radiale
    // dentro un rettangolo lascia i quattro angoli piu' scuri del centro, e
    // quello che si vede e' un riquadro semitrasparente appoggiato sulla
    // scena: e' il "residuo di rettangolo sotto il sole" che Mauro ha visto.
    //
    // Il testo resta leggibile lo stesso, e non per fiducia: la riga
    // dell'invito ha la sua pillola scura, che e' un contenitore VOLUTO e con
    // un bordo, e la sorveglianza del contrasto del rito continua a misurarla.
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg, vertical: SpacingTokens.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.keyboard_double_arrow_up_rounded,
              color: palette.goldSoft.withValues(alpha: 0.6 + 0.4 * progress),
              size: 26),
          const SizedBox(height: SpacingTokens.sm),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
              color: palette.deepest.withValues(alpha: 0.5),
              border: Border.all(color: palette.gold.withValues(alpha: 0.5)),
            ),
            // **UNA RIGA SOLA, ordine AS voce 06.** Erano due, "Trascina verso
            // l'alto per sollevare l'alba" e sotto "Oppure tocca o tieni
            // premuto": dicevano tutte e due come si fa lo stesso gesto, e la
            // regola trasversale di quest'ordine dice che dove un testo si
            // puo' togliere si toglie invece di rimpicciolirlo. La via col
            // dito NON sparisce, che sarebbe togliere una possibilita': entra
            // nella stessa riga, e la riga cresce dal corpo della didascalia a
            // quello del testo di lettura.
            child: Text(
              'Trascina in alto, oppure tocca',
              // La chiave serve alla misura del contrasto, ordine P voce 11:
              // questo invito sta sul cielo notturno, cioe' nel regime scuro,
              // e la tabella lo misura insieme a quelli sul chiaro perche' la
              // voce chiede OGNI testo del rito, non solo il pannello.
              key: const Key('alba_invito_al_gesto'),
              textAlign: TextAlign.center,
              style: TypographyTokens.lettura()
                  .copyWith(color: palette.goldSoft, letterSpacing: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

/// Il dono del giorno, in forma strutturata e fondata. Porge tre livelli:
/// l'orientamento del giorno, la parola del giorno e la base apribile che
/// spiega da dove nasce. Finche' i contenuti verificati non arrivano, i testi
/// del cielo restano provvisori e marcati, mai inventati.
/// Il motore del sorgere del Rito dell'Alba, a livelli, composto in un solo
/// canvas cosi' i blend restano corretti.
///
/// Dal fondo alla superficie: il cielo che passa in dissolvenza dalla scena
/// notturna a quella diurna, e con esso la luna svanisce; il sole in blend
/// additivo che emerge dall'orizzonte e sale fino al posto della luna con la
/// sua corona zodiacale; il mare davanti che ne copre la parte bassa e passa
/// anch'esso da notte a giorno; il riflesso dorato che si accende sul mare. A
/// progresso zero mostra solo mezzo disco sull'orizzonte, come invito.
class _DawnScenePainter extends CustomPainter {
  _DawnScenePainter({
    required this.progress,
    required this.ambient,
    required this.reduceMotion,
    required this.night,
    required this.day,
    required this.sun,
  });

  final double progress;
  final double ambient;
  final bool reduceMotion;
  final ui.Image? night;
  final ui.Image? day;
  final ui.Image? sun;

  // Notte e giorno hanno lo stesso formato e lo stesso orizzonte; la luna sta al
  // punto dove il sole si ferma.
  static const double _sceneW = 704;
  static const double _sceneH = 1520;
  static const double _horizonFrac = 0.4993;
  static const double _moonFx = 0.462;
  static const double _moonFy = 0.210;
  // Frazione della larghezza dell'immagine del sole occupata dal disco.
  static const double _sunDiscFrac = 0.171;

  @override
  void paint(Canvas canvas, Size size) {
    final night = this.night, day = this.day, sun = this.sun;
    if (night == null || day == null || sun == null) return;
    final p = progress.clamp(0.0, 1.0);
    final w = size.width, h = size.height;

    final scale = math.max(w / _sceneW, h / _sceneH);
    final dstW = _sceneW * scale, dstH = _sceneH * scale;
    final dstL = (w - dstW) / 2, dstT = (h - dstH) / 2;
    const sceneSrc = Rect.fromLTWH(0, 0, _sceneW, _sceneH);
    final sceneDst = Rect.fromLTWH(dstL, dstT, dstW, dstH);
    final horizonY = dstT + _horizonFrac * dstH;
    Offset scenePoint(double fx, double fy) =>
        Offset(dstL + fx * dstW, dstT + fy * dstH);

    // Il sole sale dall'orizzonte al posto della luna.
    final rise = reduceMotion ? p : Curves.easeOutCubic.transform(p);
    final moon = scenePoint(_moonFx, _moonFy);
    final sunCenter = Offset(moon.dx, horizonY + (moon.dy - horizonY) * rise);
    final discR = w * (0.135 + 0.055 * p);

    // --- Cielo: sopra l'orizzonte, notte in dissolvenza verso il giorno ---
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, w, horizonY));
    canvas.drawImageRect(night, sceneSrc, sceneDst, Paint());
    if (p > 0) {
      canvas.drawImageRect(day, sceneSrc, sceneDst,
          Paint()..color = Colors.white.withValues(alpha: p));
    }
    canvas.restore();

    // --- Sole: additivo, il nero sparisce e l'aura si fonde ---
    _paintSun(canvas, sun, sunCenter, discR);

    // --- Mare: sotto l'orizzonte, davanti al sole, notte verso giorno ---
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, horizonY, w, h - horizonY));
    canvas.drawImageRect(night, sceneSrc, sceneDst, Paint());
    if (p > 0) {
      canvas.drawImageRect(day, sceneSrc, sceneDst,
          Paint()..color = Colors.white.withValues(alpha: p));
    }
    _paintReflection(canvas, w, h, horizonY, sunCenter.dx, p);
    canvas.restore();
  }

  void _paintSun(Canvas canvas, ui.Image sun, Offset center, double discR) {
    // Abbassa il cielo sotto il disco con un velo scuro morbido, che sfuma al
    // bordo: cosi' l'additivo dorato ci si posa sopra e il disco resta caldo e
    // non satura a bianco sul cielo diurno luminoso. Il velo sta tutto sotto il
    // disco, non lascia aloni scuri fuori.
    canvas.drawCircle(
      center,
      discR * 1.02,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.black.withValues(alpha: 0.5),
            Colors.black.withValues(alpha: 0.5),
            Colors.black.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: discR * 1.02)),
    );

    final sw = sun.width.toDouble(), sh = sun.height.toDouble();
    // Scala l'immagine cosi' il disco ha raggio discR sullo schermo. Il margine
    // nero ampio lascia i raggi liberi di estendersi senza taglio.
    final s = discR / (_sunDiscFrac * sw);
    final dst = Rect.fromCenter(center: center, width: sw * s, height: sh * s);
    // Additivo a intensita' ridotta: il nero sparisce e l'aura si fonde da sola,
    // ma sul cielo gia' abbassato il disco resta dorato, mantenendo comunque il
    // bagliore del sorgere.
    canvas.drawImageRect(
      sun,
      Rect.fromLTWH(0, 0, sw, sh),
      dst,
      Paint()
        ..blendMode = BlendMode.plus
        ..color = Colors.white.withValues(alpha: 0.78),
    );
  }

  void _paintReflection(
      Canvas canvas, double w, double h, double horizonY, double cx, double p) {
    if (p <= 0.001) return;
    final shimmer = reduceMotion ? 0.0 : math.sin(2 * math.pi * ambient);
    final half = w * (0.03 + 0.06 * p) * (1 + 0.06 * shimmer);
    final bottom = horizonY + (h - horizonY) * (0.4 + 0.6 * p);
    final rect = Rect.fromLTRB(cx - half, horizonY, cx + half, bottom);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFE2A6).withValues(alpha: 0.6 * p),
            const Color(0x00FFE2A6),
          ],
        ).createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14)
        ..blendMode = BlendMode.plus,
    );
  }

  @override
  bool shouldRepaint(_DawnScenePainter old) =>
      old.progress != progress ||
      old.ambient != ambient ||
      old.reduceMotion != reduceMotion ||
      old.night != night ||
      old.day != day ||
      old.sun != sun;
}

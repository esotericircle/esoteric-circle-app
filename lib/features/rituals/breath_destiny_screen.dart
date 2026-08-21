import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../../core/identity/birth_identity.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/maestro/maestro.dart';
import '../../core/permissions/app_permission.dart';
import '../../core/permissions/avviso_del_permesso.dart';
import '../../core/permissions/esito_del_permesso.dart';
import '../../core/rituals/daily_elements.dart';
import '../../core/rituals/dawn_gift.dart';
import '../../core/rituals/ritual_streak.dart';
import '../../design_system/components/guida_del_respiro.dart';
import '../../design_system/theme/accento_del_maestro.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../sigilli/regia_del_cammino.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../core/rituals/tempi_del_respiro.dart';
import '../../core/astro/natal_chart.dart';
import '../../core/astro/natal_chart_controller.dart';
import '../../core/horoscope/cielo_di_oggi.dart';
import '../../core/rituals/risposta_del_soffio.dart';
import 'ritual_gift_card.dart';
import '../../core/condivisione/porta_della_condivisione.dart';

/// Soffio del Destino, dominio Aura.
///
/// Stesso impianto degli altri riti, fondale piu' dono, con un motore proprio a
/// livelli composti in un solo canvas: il prato del mattino con l'alone verde di
/// Aura, il soffione al centro coi pappi luminosi in additivo, e i semi che, al
/// soffio, si staccano e volano via come scintille disegnate dal codice, a
/// comporre il visivo del dono. Il gesto e' il microfono, col ripiego di
/// spazzare col dito o tenere premuto. Sotto Riduci Movimento i semi volano via
/// subito. Il dono e' quello di Aura, fondato ma provvisorio, mai inventato.
/// LE SUPERFICI DEL SOFFIO, dichiarate dove si dipingono.
///
/// **Perche' esistono.** Due cose in questa schermata si leggevano male, e non
/// per il colore del testo: perche' non avevano nessuna superficie sotto. Il
/// contatore dei giri stava sui raggi del soffione e le due righe della
/// Risposta sul prato, che nella fase di luce piena e' chiaro: testo chiaro su
/// fondo chiaro, con un contrasto che nessuna scelta di tinta poteva salvare.
///
/// Il rimedio non e' scurire il testo, che sul prato scuro tornerebbe
/// illeggibile al contrario: e' dare a quel testo un velo suo, e misurare il
/// contrasto contro il velo invece che contro una scena che cambia.
class SuperficiDelSoffio {
  const SuperficiDelSoffio._();

  /// Il velo dietro il testo: scuro e quasi opaco, cosi' regge il contrasto
  /// qualunque cosa la scena stia facendo sotto.
  ///
  /// **E' lo stesso della guida del respiro, letto da li'**: il conteggio dei
  /// giri e la Risposta stanno sulla stessa schermata, e due veli diversi si
  /// vedrebbero come due rettangoli di grigio diverso a un dito di distanza.
  static const Color velo = veloDelConteggio;

  /// L'inchiostro del contatore dei giri, letto dalla guida che lo dipinge.
  static const Color inchiostro = inchiostroDelConteggio;

  /// Le due righe della Risposta: la prima piena, la seconda in tono minore.
  static const Color inchiostroDellaRisposta = Color(0xFFF3EFE6);
  static const Color inchiostroSecondarioDellaRisposta = Color(0xFFCFC9BC);

  /// DOVE CADE IL DISCO LUMINOSO, in frazioni della scena.
  ///
  /// **E' il centro di due cose, non di una.** Il disco lo dipinge il painter e
  /// l'anello del respiro lo dispone il layout: erano due centri decisi in due
  /// sistemi diversi, il primo a 0,26 dell'altezza del corpo e il secondo
  /// dentro una colonna allineata a -0,2 di una zona flex, quindi non potevano
  /// coincidere per costruzione, e a video si leggeva come un difetto di
  /// stampa.
  ///
  /// **E' l'anello a inseguire il disco, non il contrario.** Il disco cresce
  /// col soffio fin dal primo istante, mentre l'anello nasce solo a gesto
  /// compiuto: spostare il disco sull'anello avrebbe prodotto un salto proprio
  /// a meta' del rito.
  static const Offset centroDelDisco = Offset(0.5, 0.26);

  /// Il centro del disco in punti, dentro una scena di [misura].
  static Offset discoDentro(Size misura) => Offset(
        misura.width * centroDelDisco.dx,
        misura.height * centroDelDisco.dy,
      );
}

class BreathDestinyScreen extends StatefulWidget {
  const BreathDestinyScreen({super.key, this.now});

  final DateTime? now;

  static Route<void> route({DateTime? now}) => MaterialPageRoute<void>(
        builder: (_) => MaestroScope(child: BreathDestinyScreen(now: now)),
      );

  @override
  State<BreathDestinyScreen> createState() => _BreathDestinyScreenState();
}

class _BreathDestinyScreenState extends State<BreathDestinyScreen>
    with TickerProviderStateMixin {
  // Dispersione dei semi, da 0 (testa piena) a 1 (dono rivelato).
  double _progress = 0;
  bool _revealed = false;
  DawnGift? _gift;
  int _streak = 0;

  /// LA RISPOSTA DEL SOFFIO, dai transiti veri. Nulla quando il cielo non e'
  /// stato interrogato davvero, e in quel caso non compare niente al posto
  /// suo: una risposta senza cielo sarebbe un oroscopo da giornale.
  RispostaDelSoffio? _risposta;

  /// L'ESITO DEL PERMESSO DEL MICROFONO, nei suoi tre valori distinti.
  ///
  /// Ordine 2166, voce 2. Prima qui c'era solo il silenzio: `hasPermission`
  /// torna si' o no, e un no valeva per tutti e due i no. Chi aveva negato
  /// per sempre non vedeva comparire nessun dialogo e non veniva avvisato di
  /// niente: il rito sembrava sordo. Adesso l'esito arriva dalla porta unica
  /// e la scena lo dice.
  EsitoDelPermesso? _esitoDelMicrofono;

  late final AnimationController _disperse;
  Animation<double>? _disperseAnim;
  late final AnimationController _ambient; // brezza e brillio

  // IL PRATO NON SI CARICA PIU', ordine P voce 26: il fondale e' il cosmo
  // condiviso, e un asset che nessuno dipinge sarebbe memoria decodificata per
  // niente.
  ui.Image? _dandelionImg;

  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _micStream;
  StreamSubscription<Amplitude>? _micAmplitude;

  // Distanza di spazzata sul soffione che disperde del tutto i semi.
  static const double _sweepSpan = 240;
  static const double _completeThreshold = 0.5;

  @override
  void initState() {
    super.initState();
    _disperse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..addListener(() {
        final anim = _disperseAnim;
        if (anim != null) setState(() => _progress = anim.value);
      });
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _loadLayers();
    _startMic();
  }

  Future<void> _loadLayers() async {
    try {
      final soffione =
          await _resolveAsset('assets/ritual_backgrounds/breath_dandelion.png');
      if (!mounted) return;
      setState(() => _dandelionImg = soffione);
    } catch (_) {
      // Senza livelli il motore non disegna la scena, ma il rito resta
      // compibile col ripiego e il dono appare comunque.
    }
  }

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

  // Chiede il permesso del microfono e ascolta il livello audio: un soffio e' un
  // picco d'ampiezza. Se il permesso e' negato o il microfono non c'e', resta il
  // ripiego tattile, senza mai sollevare un errore.
  Future<void> _startMic() async {
    try {
      // LA PORTA UNICA: torna i tre esiti distinti, non un si' o un no.
      final esito = await PortaDelPermesso.chiedi(
        AppPermission.microphone,
        richiestaDiSistema: _recorder.hasPermission,
      );
      if (mounted) setState(() => _esitoDelMicrofono = esito);
      if (esito != EsitoDelPermesso.concesso) return;
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          numChannels: 1,
          sampleRate: 16000,
        ),
      );
      _micStream = stream.listen((_) {});
      _micAmplitude = _recorder
          .onAmplitudeChanged(const Duration(milliseconds: 160))
          .listen((amp) {
        // Un soffio deciso supera la soglia: i semi si liberano.
        if (!_revealed && amp.current > -18) _complete();
      });
    } catch (_) {
      // Microfono non disponibile o permesso negato: vale il ripiego.
    }
  }

  Future<void> _stopMic() async {
    await _micAmplitude?.cancel();
    await _micStream?.cancel();
    try {
      if (await _recorder.isRecording()) await _recorder.stop();
    } catch (_) {}
    await _recorder.dispose();
  }

  @override
  void dispose() {
    _stopMic();
    _disperse.dispose();
    _ambient.dispose();
    _dandelionImg?.dispose();
    super.dispose();
  }

  bool get _reduceMotion => MediaQuery.of(context).disableAnimations;

  /// LA CARTA NATALE, dalla stessa porta da cui la prende il Passaporto.
  ///
  /// Nulla quando non c'e', e allora la risposta non compare: senza carta non
  /// ci sono transiti sulla carta, e una risposta senza cielo sarebbe un
  /// oroscopo da giornale.
  NatalChart? _carta() {
    try {
      return context.read<NatalChartController>().chart;
    } catch (errore) {
      // NON E' UN GUASTO, e' un albero piu' povero: succede quando questa
      // schermata viene montata da sola, per esempio in una prova o in
      // un'anteprima, senza il fornitore della carta sopra di lei. Si dichiara
      // e si prosegue senza cielo, che e' esattamente il caso in cui la
      // risposta non deve comparire.
      debugPrint('Soffio, carta natale non raggiungibile: $errore');
      return null;
    }
  }

  BirthIdentity? _identity() {
    try {
      return context.read<ProfileController>().identity;
    } catch (_) {
      return null;
    }
  }

  // Ripiego a spazzata: il dito che scorre sul soffione disperde i semi.
  void _onPanUpdate(DragUpdateDetails d) {
    if (_revealed) return;
    _disperse.stop();
    setState(() {
      _progress = (_progress + d.delta.distance / _sweepSpan).clamp(0.0, 1.0);
    });
  }

  void _onPanEnd(DragEndDetails _) {
    if (_revealed) return;
    if (_progress >= _completeThreshold) {
      _complete();
    } else {
      _animateTo(0);
    }
  }

  // Ripiego a tocco prolungato.
  void _onLongPress() {
    if (_revealed) return;
    _complete();
  }

  void _complete() {
    if (_reduceMotion) {
      setState(() => _progress = 1);
      _reveal();
      return;
    }
    _animateTo(1, onDone: _reveal);
  }

  void _animateTo(double target, {VoidCallback? onDone}) {
    _disperseAnim = Tween<double>(begin: _progress, end: target).animate(
      CurvedAnimation(parent: _disperse, curve: Curves.easeOutCubic),
    );
    _disperse.forward(from: 0).then((_) {
      if (mounted) onDone?.call();
    });
  }

  void _reveal() {
    if (_revealed) return;
    final date = widget.now ?? DateTime.now();
    setState(() {
      _revealed = true;
      _gift = DawnGift.forMaestro(date, Maestro.aura, identity: _identity());
      _risposta = RispostaDelSoffio.diOggi(
        CieloDiOggi.perIlGiorno(adesso: date, carta: _carta()),
      );
    });
    _stopMic();
    _recordStreak(date);
  }

  Future<void> _recordStreak(DateTime date) async {
    final n = await const RitualStreak(id: 'breath').recordToday(date);
    if (!mounted) return;
    // IL CAMMINO SE NE ACCORGE: il rito e' compiuto, non aperto.
    unawaited(RegiaDelCammino.dopoUnGesto(context, 'soffio', oraRituale: null));
    setState(() => _streak = n);
  }

  Future<void> _shareWord(DawnGift gift) async {
    final word = gift.word;
    if (word == null) return;
    try {
      await PortaDellaCondivisione.testo('La mia parola del giorno dal Soffio del Destino: $word. '
              '${gift.orientation} Con Esoteric Circle.');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Condivisione non disponibile ora.')),
      );
    }
  }

  /// LA SCENA E L'ANELLO, per misurare la distanza fra i due centri.
  ///
  /// Non si calcola a mente: si guarda dove la figura del respiro e' finita
  /// davvero e si sposta di quanto manca. Un conto fatto sui flex e sugli
  /// allineamenti sarebbe giusto oggi e falso domani, al primo padding che
  /// qualcuno cambia.
  final GlobalKey _scena = GlobalKey();
  final GlobalKey _anello = GlobalKey();

  /// Quanto spostare l'anello perche' cada dentro il disco. Zero finche' non
  /// c'e' niente da misurare.
  double _inseguimento = 0;

  /// Misura la distanza fra i due centri e la corregge, una volta per frame.
  ///
  /// Si ferma da sola: appena i due coincidono lo scarto e' sotto il mezzo
  /// punto e non si chiede piu' nessun ridisegno.
  void _allineaLAnello() {
    final scena = _scena.currentContext?.findRenderObject();
    final anello = _anello.currentContext?.findRenderObject();
    if (scena is! RenderBox || anello is! RenderBox) return;
    if (!scena.hasSize || !anello.hasSize) return;
    final centroAnello = scena.globalToLocal(
        anello.localToGlobal(anello.size.center(Offset.zero)));
    final voluto = SuperficiDelSoffio.discoDentro(scena.size);
    final manca = voluto.dy - centroAnello.dy;
    if (manca.abs() < 0.5) return;
    if (!mounted) return;
    setState(() => _inseguimento += manca);
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.aura));
    // La misura si prende a frame finito, quando i due riquadri esistono
    // davvero: durante il build hanno ancora la misura del giro precedente.
    WidgetsBinding.instance.addPostFrameCallback((_) => _allineaLAnello());

    // IL FONDALE E' IL COSMO CONDIVISO, ordine P voce 26. Prima il Soffio si
    // dipingeva un prato suo dentro il pittore della scena: adesso passa da
    // `CosmosBackground`, la stessa porta del Sigillo del Sogno, quindi il cielo in
    // parallasse arriva anche qui e non c'e' un secondo fondale da mantenere.
    return CosmosBackground(
      seed: 31,
      child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.4),
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title:
            Text('Soffio del Destino', style: TypographyTokens.display(size: 20)),
      ),
      // LA SCENA HA UN NOME, ordine P voce 26.
      //
      // **Non e' una comodita' per le prove: e' la correzione di una misura
      // fragile.** La prova della concentricita' prendeva `Stack.first`, cioe'
      // il primo Stack che incontrava scendendo nell'albero, e finche' la
      // schermata cominciava col suo Scaffold quello era questa scena. Col cosmo
      // condiviso davanti il primo Stack e' quello del cosmo, alto 797 invece di
      // 741 e ancorato a zero invece che sotto la barra: la prova misurava un
      // altro riquadro e dichiarava 41,4 punti di scarto mentre l'anello era
      // centrato. L'inseguimento, misurato, converge a zero.
      //
      // Un riquadro che una prova deve misurare si chiama per nome.
      body: KeyedSubtree(
        key: const Key('soffio_scena'),
        child: Stack(
        key: _scena,
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: Listenable.merge([_disperse, _ambient]),
                builder: (context, _) => CustomPaint(
                  painter: _BreathScenePainter(
                    progress: _progress,
                    ambient: _reduceMotion ? 0 : _ambient.value,
                    reduceMotion: _reduceMotion,
                    palette: palette,
                    dandelion: _dandelionImg,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  flex: 6,
                  child: Semantics(
                    button: true,
                    label: 'Libera il tuo destino. Soffia, oppure spazza col '
                        'dito o tieni premuto.',
                    onTap: _onLongPress,
                    child: GestureDetector(
                      key: const Key('ritual_gesture'),
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      onLongPress: _onLongPress,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (!_revealed)
                            Align(
                              alignment: const Alignment(0, -0.55),
                              child: _BreathPrompt(palette: palette),
                            ),
                          // L'ESITO DEL MICROFONO, detto a schermo: il rito
                          // resta compibile col dito in ogni caso, ma chi ha
                          // negato deve sapere perche' il soffio non viene
                          // ascoltato, e chi ha negato PER SEMPRE deve sapere
                          // che l'unica via sono le impostazioni.
                          if (!_revealed &&
                              _esitoDelMicrofono != null &&
                              _esitoDelMicrofono !=
                                  EsitoDelPermesso.concesso)
                            Align(
                              alignment: const Alignment(0, 0.62),
                              child: AvvisoDelPermesso(
                                chiave: 'soffio',
                                permesso: AppPermission.microphone,
                                esito: _esitoDelMicrofono!,
                                palette: palette,
                                onRichiedi: () async {
                                  await _startMic();
                                },
                              ),
                            ),
                          // IL RESPIRO SI GUIDA, NON SI LEGGE.
                          //
                          // Compare a gesto compiuto, cioe' quando il rito del
                          // giorno c'e' e dichiara la sua cadenza. Prima qui
                          // non c'era niente: il testo diceva "sei tempi
                          // dentro e sei fuori, tre volte" e la persona
                          // contava a mente davanti a una figura ferma.
                          if (_revealed && _gift?.rito != null)
                            // L'ANELLO CADE DENTRO IL DISCO. L'allineamento di
                            // partenza non conta piu': qualunque esso sia, la
                            // misura a frame finito lo porta sul centro
                            // dichiarato da `SuperficiDelSoffio`.
                            Align(
                              alignment: Alignment.center,
                              child: Transform.translate(
                                offset: Offset(0, _inseguimento),
                                child: GuidaDelRespiro(
                                  key: const Key('guida_respiro'),
                                  chiaveDellaFigura: _anello,
                                  tempi: TempiDelRespiro(
                                    tempi: _gift!.rito!.tempi,
                                    giri: _gift!.rito!.giri,
                                  ),
                                  colore: palette.gold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                // LA SCHEDA STA SOTTO IL RESPIRO, MAI SOPRA, ordine 2164
                // voce 8. Visto da Mauro: il pulsante "Tocca per cominciare"
                // era tagliato a meta' dalla scheda dell'intenzione, quindi
                // non si poteva nemmeno premere per intero.
                //
                // La causa misurata: la guida del respiro insegue il disco
                // luminoso con una traslazione verso il basso, e con le
                // barre di sistema del telefono (una quarantina di punti in
                // meno) SBORDAVA dalla sua zona; la scheda, che viene dopo
                // nella colonna, si dipinge sopra e se lo mangiava. Con
                // sei contro tre la zona del respiro torna a contenerlo:
                // misurato 25,1 punti coperti prima, zero adesso, e il
                // tocco al centro arriva.
                Expanded(
                  flex: 3,
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
                                dono: DailyElement.breath,
                                giorno: widget.now ?? DateTime.now(),
                                streak: _streak,
                                onShare: () => _shareWord(_gift!),
                              ),
                              if (_risposta != null) ...[
                                const SizedBox(height: SpacingTokens.lg),
                                _LaRisposta(
                                    risposta: _risposta!, palette: palette),
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
      ),
      ),
    );
  }
}

/// LE DUE RIGHE DELLA RISPOSTA, e nient'altro.
///
/// Nessuna domanda alla persona, nessun compito, nessun esito promesso, e
/// nessun verbo all'imperativo: quella e' la forma del Rito dell'Alba, e i due
/// riti non devono somigliarsi.
class _LaRisposta extends StatelessWidget {
  const _LaRisposta({required this.risposta, required this.palette});

  final RispostaDelSoffio risposta;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    // LE RIGHE HANNO UNA SUPERFICIE, e non e' un vezzo: senza, stavano sul
    // prato chiaro e il contrasto era sotto la soglia. Misurato da
    // `test/il_soffio_si_legge_test.dart`.
    return Container(
      key: const Key('soffio_risposta'),
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: SuperficiDelSoffio.velo,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        border: Border.all(
            color: AccentoDelMaestro.su(Maestro.aura,
                    superficie: SuperficiDelSoffio.velo)
                .withValues(alpha: 0.35)),
      ),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('LA RISPOSTA',
            style: TypographyTokens.etichetta().copyWith(
                // Il Soffio e' di Aura, quindi il suo titolo e' verde, portato
                // dove si legge dalla stessa regola della scheda dei Doni.
                color: AccentoDelMaestro.su(Maestro.aura,
                    superficie: SuperficiDelSoffio.velo),
                letterSpacing: 3)),
        const SizedBox(height: SpacingTokens.sm),
        if (risposta.apre != null)
          Text(risposta.apre!,
              key: const Key('soffio_apre'),
              style: TypographyTokens.body(size: 16).copyWith(
                  color: SuperficiDelSoffio.inchiostroDellaRisposta,
                  height: 1.5)),
        if (risposta.apre != null && risposta.nonForzare != null)
          const SizedBox(height: SpacingTokens.sm),
        if (risposta.nonForzare != null)
          Text(risposta.nonForzare!,
              key: const Key('soffio_non_forzare'),
              style: TypographyTokens.body(size: 16).copyWith(
                  color: SuperficiDelSoffio.inchiostroSecondarioDellaRisposta,
                  height: 1.5)),
      ],
      ),
    );
  }
}

/// L'invito al soffio e il suo ripiego, chiari sul prato.
class _BreathPrompt extends StatelessWidget {
  const _BreathPrompt({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    // **VIA IL VELO, COME NELL'ALBA. Ordine AS voce 07.** Un `RadialGradient`
    // nero dentro un rettangolo lascia gli angoli piu' scuri del centro, e
    // quello che si vede e' un riquadro semitrasparente appoggiato sulla
    // scena. Il testo resta leggibile per la sua pillola, che e' un
    // contenitore voluto e con un bordo.
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg, vertical: SpacingTokens.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.air_rounded,
              color: palette.goldSoft.withValues(alpha: 0.9), size: 26),
          const SizedBox(height: SpacingTokens.sm),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
              color: palette.deepest.withValues(alpha: 0.5),
              border: Border.all(color: palette.gold.withValues(alpha: 0.5)),
            ),
            // **UNA RIGA SOLA, E PIU' GRANDE. Ordine AS voce 07.** Erano due,
            // e dicevano tutte e due come si fa lo stesso gesto; la prima per
            // giunta a corpo DODICI scritto a mano, cioe' sotto il pavimento
            // tipografico del progetto. La via col dito non sparisce, entra
            // nella stessa riga: togliere una possibilita' sarebbe un'altra
            // cosa dal togliere una ripetizione.
            child: Text(
              'Soffia, oppure spazza col dito',
              key: const Key('soffio_invito_al_gesto'),
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

/// Il motore del Soffio a livelli, composto in un solo canvas.
class _BreathScenePainter extends CustomPainter {
  _BreathScenePainter({
    required this.progress,
    required this.ambient,
    required this.reduceMotion,
    required this.palette,
    required this.dandelion,
  });

  final double progress;
  final double ambient;
  final bool reduceMotion;
  final MaestroPalette palette;
  final ui.Image? dandelion;

  // Testa del soffione nell'immagine (centro e raggio come frazioni).
  static const double _headFx = 0.501;
  static const double _headFy = 0.440;
  static const double _headRFrac = 0.244; // del lato dell'immagine

  @override
  void paint(Canvas canvas, Size size) {
    // IL PRATO NON SI DIPINGE PIU' QUI, ordine P voce 26.
    //
    // **Non era un fondale: era un LIVELLO dentro questo pittore**, che sulla
    // stessa tela disegna anche il soffione e i semi che volano al soffio,
    // cioe' il gesto del rito. Per questo toglierlo obbligava a decidere cosa
    // succede al soffione, e per questo era rimasto due volte.
    //
    // La decisione: il soffione resta esattamente dov'e', dipinto da qui,
    // perche' e' il gesto e non lo sfondo; il fondale passa a
    // `CosmosBackground`, che e' la destinazione gia' precedentata dal Rito del
    // Sogno. Sotto il soffione resta l'alone verde di Aura, che c'era gia' e
    // che adesso fa anche da terreno: un soffione sospeso nel vuoto non e'
    // quello che si voleva.
    final dandelion = this.dandelion;
    if (dandelion == null) return;
    final p = progress.clamp(0.0, 1.0);
    final w = size.width, h = size.height;
    final rect = Offset.zero & size;

    // --- Alone verde di Aura del dominio, dal basso ---
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, 0.35),
          radius: 0.9,
          colors: [
            palette.glow.withValues(alpha: 0.30),
            palette.glow.withValues(alpha: 0.0),
          ],
        ).createShader(rect),
    );

    // Geometria del soffione montato sul prato.
    final dw = dandelion.width.toDouble(), dh = dandelion.height.toDouble();
    final dstH = h * 0.62;
    final dstW = dstH * dw / dh;
    final headCenter = Offset(w * 0.5, h * 0.52);
    final dstTop = headCenter.dy - _headFy * dstH;
    final dstLeft = w * 0.5 - _headFx * dstW;
    final headR = _headRFrac * dstW;
    final giftCenter = SuperficiDelSoffio.discoDentro(size);

    // --- Visivo del dono, provvisorio: una forma energetica che si accende ---
    // man mano che le scintille dei semi salgono a comporla. La forma vera
    // verra' dal cantiere.
    _paintGiftForm(canvas, giftCenter, w, p);

    // --- Alone morbido d'aria attorno al soffione, appena un respiro ---
    final auraR = headR * 1.9;
    canvas.drawCircle(
      headCenter,
      auraR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            palette.goldSoft.withValues(alpha: 0.16),
            palette.glow.withValues(alpha: 0.06),
            const Color(0x00000000),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: headCenter, radius: auraR)),
    );

    // --- Soffione in composizione normale: l'alpha cotto dal fondo nero tiene
    // il dettaglio reale, i pappi coi bordi morbidi e lo stelo piantato. Niente
    // additivo, niente bruciatura a bianco. In due parti: lo stelo col
    // ricettacolo resta sempre, la testa si svuota progressivamente col soffio.
    const headBottomFy = 0.63, stemTopFy = 0.60;
    // **LO STELO SE NE VA DOPO I PETALI. Ordine AS voce 07.**
    //
    // Qui c'era scritto "sempre piantato nel prato", e si disegnava con una
    // `Paint()` piena: a soffio finito restava un gambo nudo in mezzo alla
    // scena, sotto il dono, come il resto di una cosa che non c'e' piu'. Un
    // soffione soffiato via non lascia il suo stelo in primo piano.
    //
    // Adesso lo stelo resta intero mentre la testa si dirada, cioe' finche' il
    // gesto e' in corso, e si dissolve nell'ULTIMO TERZO del soffio: quando i
    // pappi hanno finito di volare, se ne va anche lui. La soglia e' una sola
    // costante dichiarata qui, non un numero sparso nel disegno.
    const quandoLoSteloSiRitira = 0.7;
    final steloOpacita = p <= quandoLoSteloSiRitira
        ? 1.0
        : (1 - (p - quandoLoSteloSiRitira) / (1 - quandoLoSteloSiRitira))
            .clamp(0.0, 1.0);
    if (steloOpacita > 0.01) {
      canvas.drawImageRect(
        dandelion,
        Rect.fromLTWH(0, stemTopFy * dh, dw, dh * (1 - stemTopFy)),
        Rect.fromLTWH(
            dstLeft, dstTop + stemTopFy * dstH, dstW, dstH * (1 - stemTopFy)),
        Paint()..color = Colors.white.withValues(alpha: steloOpacita),
      );
    }
    // La testa, che si dirada fino allo spoglio col progredire del soffio.
    final headOpacity = (1 - p).clamp(0.0, 1.0);
    if (headOpacity > 0.01) {
      canvas.drawImageRect(
        dandelion,
        Rect.fromLTWH(0, 0, dw, dh * headBottomFy),
        Rect.fromLTWH(dstLeft, dstTop, dstW, dstH * headBottomFy),
        Paint()..color = Colors.white.withValues(alpha: headOpacity),
      );
    }

    // --- IL TERRENO: un orizzonte sfumato che assorbe la fine dello stelo ---
    //
    // **Difetto trovato GUARDANDO l'anteprima, non ragionando.** Tolto il prato
    // della voce 26, lo stelo del soffione finiva nel vuoto: l'immagine termina
    // a 637 punti su 741, e i cento punti sotto restavano cielo con un gambo
    // tagliato in mezzo. Il prato quella terminazione la copriva, ed e' il
    // secondo modo in cui il prato non era "solo un fondale".
    //
    // Il rimedio non e' rimettere una fotografia: e' un orizzonte, cioe' il
    // verde di Aura che sale dal bordo basso e assorbe lo stelo. Sta SOPRA il
    // soffione perche' deve assorbirlo, e SOTTO i semi perche' quelli volano.
    final orizzonte = Rect.fromLTWH(0, h * 0.72, w, h * 0.28);
    canvas.drawRect(
      orizzonte,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.glow.withValues(alpha: 0.0),
            palette.primary.withValues(alpha: 0.55),
            palette.deepest.withValues(alpha: 0.9),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(orizzonte),
    );

    // --- Semi che volano via verso l'alto come scintille, con deriva di vento --
    _paintSeeds(canvas, headCenter, headR, giftCenter, p);
  }

  void _drawCover(Canvas canvas, ui.Image img, Size size, Paint paint) {
    final iw = img.width.toDouble(), ih = img.height.toDouble();
    final scale = math.max(size.width / iw, size.height / ih);
    final dw = iw * scale, dh = ih * scale;
    final dst = Rect.fromLTWH(
        (size.width - dw) / 2, (size.height - dh) / 2, dw, dh);
    canvas.drawImageRect(img, Rect.fromLTWH(0, 0, iw, ih), dst, paint);
  }

  // Il visivo del dono, provvisorio ma costruito: un soffione di luce, non una
  // palla sfocata. Cuore definito, raggi che terminano in nodi luminosi, due
  // anelli fini e un alone verde-oro. Si accende col salire delle scintille. La
  // forma definitiva verra' dal cantiere.
  void _paintGiftForm(Canvas canvas, Offset center, double w, double p) {
    if (p <= 0.02) return;
    final breathe = reduceMotion ? 0.0 : math.sin(2 * math.pi * ambient);
    final r = w * (0.13 + 0.10 * p) * (1 + 0.025 * breathe);

    // Alone verde-oro d'aria, morbido, dietro alla forma.
    canvas.drawCircle(
      center,
      r * 1.7,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [
            palette.glow.withValues(alpha: 0.26 * p),
            const Color(0x00000000),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: r * 1.7)),
    );

    // Due anelli fini che danno struttura.
    Paint ring(double a, double sw) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..color = palette.gold.withValues(alpha: a * p);
    canvas.drawCircle(center, r, ring(0.5, 1.2));
    canvas.drawCircle(center, r * 0.5, ring(0.4, 1.0));

    // Raggi che terminano in nodi luminosi, come un soffione di luce.
    const n = 24;
    final ray = Paint()
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round
      ..color = palette.gold.withValues(alpha: 0.42 * p);
    for (var i = 0; i < n; i++) {
      final a = 2 * math.pi * i / n - math.pi / 2;
      final dir = Offset(math.cos(a), math.sin(a));
      final outer = center + dir * r * 0.92;
      canvas.drawLine(center + dir * r * 0.5, outer, ray);
      // Bagliore additivo e nodo definito al vertice.
      canvas.drawCircle(
        outer,
        3.4,
        Paint()
          ..blendMode = BlendMode.plus
          ..color = palette.goldSoft.withValues(alpha: 0.22 * p),
      );
      canvas.drawCircle(outer, 1.7,
          Paint()..color = palette.goldSoft.withValues(alpha: 0.85 * p));
    }

    // Cuore definito e luminoso.
    canvas.drawCircle(
      center,
      r * 0.4,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF6DC).withValues(alpha: 0.85 * p),
            const Color(0x00FFF6DC),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: r * 0.4)),
    );
    canvas.drawCircle(center, r * 0.09,
        Paint()..color = const Color(0xFFFFF9E8).withValues(alpha: 0.95 * p));
  }

  void _paintSeeds(Canvas canvas, Offset head, double headR, Offset gift,
      double p) {
    if (p <= 0.001) return;
    final rng = math.Random(31);
    const n = 90;
    final wind = reduceMotion ? 0.0 : math.sin(2 * math.pi * ambient);
    final paint = Paint()..blendMode = BlendMode.plus;
    for (var i = 0; i < n; i++) {
      final threshold = (i / n) * 0.85;
      if (p <= threshold) continue;
      final f = ((p - threshold) / (1 - threshold)).clamp(0.0, 1.0);
      // Punto di partenza sulla testa, arrivo verso la forma del dono.
      final a0 = rng.nextDouble() * 2 * math.pi;
      final r0 = math.sqrt(rng.nextDouble()) * headR;
      final start = head + Offset(math.cos(a0), math.sin(a0)) * r0;
      final endJitter = Offset(
          (rng.nextDouble() - 0.5) * headR * 1.6,
          (rng.nextDouble() - 0.5) * headR * 0.8);
      final end = gift + endJitter;
      final flightCurve = Curves.easeOut.transform(f);
      final windX = wind * headR * 0.5 * (rng.nextDouble() + 0.3) * f;
      final pos = Offset.lerp(start, end, flightCurve)! + Offset(windX, 0);
      // Scintilla: piu' viva a meta' volo, si spegne arrivando.
      final glow = (math.sin(f * math.pi)).clamp(0.0, 1.0);
      final radius = 1.0 + rng.nextDouble() * 1.6;
      canvas.drawCircle(
        pos,
        radius * 2.4,
        paint
          ..color = palette.goldSoft.withValues(alpha: 0.10 * glow)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      paint.maskFilter = null;
      canvas.drawCircle(
        pos,
        radius,
        paint..color = const Color(0xFFFFF6DC).withValues(alpha: 0.8 * glow),
      );
    }
  }

  @override
  bool shouldRepaint(_BreathScenePainter old) =>
      old.progress != progress ||
      old.ambient != ambient ||
      old.reduceMotion != reduceMotion ||
      old.palette != palette ||
      old.dandelion != dandelion;
}

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import '../../../core/chat/chat_message.dart';
import '../../../core/maestro/maestro.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../../services/ai/registro_dei_guasti.dart';
import '../../../services/live/porta_del_live.dart';
import '../../../services/voce/l_orecchio_del_live.dart';
import '../chat/maestro_chat_controller.dart';
import '../widgets/busto_del_maestro.dart';
import '../../../core/sensi/lo_schermo_acceso.dart';
import '../../../core/sensi/wav_da_pcm.dart';
import '../../shell/quale_musica_suona.dart';
import 'il_giudizio_della_frase.dart';
import 'il_parlato_del_maestro.dart';
import 'le_frasi_della_persona.dart';
import 'il_selettore_delle_voci.dart';
import 'la_scena_del_live.dart';
import 'la_cornice_della_finestra.dart';
import 'stato_della_schermata_live.dart';

/// **LA SCHERMATA LIVE.** Ordine EG voce 05.
///
/// ## COSA C'ERA PRIMA, E PERCHE' ERA MUTA
///
/// La 2277 entrava nella stanza e mostrava il volto di Protoface, **fermo e
/// muto**: il fondatore l'ha trovato cosi' il 23 settembre 2026. Protoface e'
/// soltanto il volto e si muove sull'audio che gli si manda, e nessuno
/// glielo mandava; il testo scritto finiva in un canale che nessuno leggeva.
///
/// ## LA CATENA, ADESSO
///
/// 1. Si apre la sessione sul server, che controlla diritto e minuti.
/// 2. Si entra nella stanza e si aspetta che il volto ci sia.
/// 3. Il Maestro saluta a voce, e il volto comincia a muoversi.
/// 4. Si ascolta la persona registrandola, e la frase intera si trascrive
///    quando ha finito davvero (`LOrecchioDelLive`, ordine EJ voce 01);
///    oppure la persona tiene premuto il microfono e parla quanto vuole;
///    oppure si legge cio' che scrive: il ripiego tattile che `CLAUDE.md`
///    rende obbligatorio.
/// 5. La risposta la da' **la stessa chat scritta**, con lo stesso Maestro, la
///    stessa memoria e le stesse regole, e resta scritta nella conversazione.
/// 6. La risposta diventa voce una frase alla volta, sul server con
///    Gemini-TTS, e il telefono la manda al volto sul flusso `lk.audio_stream`.
/// 7. Quando il volto ha finito di parlare, si torna ad ascoltare.
///
/// **Si ascolta solo quando il Maestro tace.** Il microfono sentirebbe la
/// voce del Maestro dall'altoparlante e la prenderebbe per una domanda.
class SchermataLive extends StatefulWidget {
  const SchermataLive({super.key, required this.maestro, this.chat});

  /// **LA ROTTA LA DICHIARA LA SCHERMATA, non chi la apre**, cosi' il LIVE
  /// entra col passaggio del Cerchio come ogni altra schermata.
  static Route<void> route({
    required Maestro maestro,
    MaestroChatController? chat,
  }) =>
      PassaggioDelCerchio.rotta<void>(
          (_) => SchermataLive(maestro: maestro, chat: chat));

  final Maestro maestro;

  /// **Il cervello e' quello della chat scritta.** Senza, il LIVE ha il volto
  /// ma non sa rispondere: la schermata lo dice invece di fingere.
  final MaestroChatController? chat;

  @override
  State<SchermataLive> createState() => _SchermataLiveState();
}

class _SchermataLiveState extends State<SchermataLive> {
  late QuadroDelLive _quadro =
      QuadroDelLive(momento: MomentoDelLive.siApre, maestro: widget.maestro);

  lk.Room? _stanza;
  Timer? _orologio;
  final _campo = TextEditingController();

  /// **L'ORECCHIO, ordine EJ voce 01.** Prima c'era il riconoscitore del
  /// telefono, che chiudeva da solo: dopo il silenzio iniziale e dopo ogni
  /// pausa, e la domanda troncata partiva lo stesso. Il fondatore, sulla
  /// 2278: *"mi lascia circa un secondo per parlare"*. Adesso l'app registra
  /// e decide lei quando la persona ha finito, con `IlSilenzioVero`.
  final _orecchio = LOrecchioDelLive();

  /// Il livello del microfono, fra 0 e 1, per la barra dell'ascolto. Sta in
  /// un notificatore suo perche' cambia venti volte al secondo, e ridisegnare
  /// la schermata intera ridisegnerebbe anche il volto.
  final _livello = ValueNotifier<double>(0);

  /// Vero mentre il Maestro sta parlando: in quel tempo non si ascolta.
  bool _parla = false;

  /// Vero mentre la chat compone la risposta.
  bool _pensa = false;

  /// Vero mentre il microfono e' aperto.
  bool _ascolta = false;

  /// Le frasi dette finora, che diventano domanda quando la persona smette.
  final _frasi = LeFrasiDellaPersona();

  /// **Cosa fare di una frase aperta su un suono continuo.** Ordine EM voce
  /// 04, secondo giro: con la televisione accesa, sul Realme, una frase e'
  /// rimasta aperta 141,6 secondi.
  final _giudizio = IlGiudizioDellaFrase();

  Completer<void>? _fineDellaVoce;

  /// **Vero mentre il fondatore sceglie la voce.** Ordine EM voce 08: col
  /// selettore aperto il microfono tace, e riparte quando si chiude.
  bool _nelSelettore = false;

  /// **LA TRASCRIZIONE ANTICIPATA.** Ordine EM voce 11, 25 settembre 2026.
  /// Il fondatore: *"Da quando faccio una domanda a quando ottengo risposta
  /// passano diversi secondi, circa 4."* Misurato sul Realme con la 2280, nel
  /// LIVE di Aura: dopo la fine del parlato due secondi di silenzio per
  /// chiudere la frase, poi da 1,31 a 1,93 secondi di trascrizione, da 1,59
  /// a 4,44 di risposta della chat e da 0,60 a 0,74 per il primo suono. La
  /// trascrizione aspettava che la frase fosse chiusa. Adesso comincia quando
  /// la frase va in pausa, a settecento millesimi: se la frase si chiude con
  /// quella stessa pausa, la trascrizione e' gia' pronta o quasi, e i due
  /// secondi di silenzio, che restano quelli dell'ordine EJ, lavorano
  /// invece di aspettare.
  ({int pausa, int giro, Future<String?> testo})? _anticipata;

  /// **L'ATTESA, MISURATA PEZZO PER PEZZO.** Ordine EM voce 11: dalla fine
  /// del parlato alla frase chiusa, alla trascrizione, alla risposta, al
  /// primo audio mandato al volto, al volto che parla nella stanza.
  DateTime? _fineDelParlato;
  final Map<String, int> _tappe = {};
  bool _attesaAperta = false;
  lk.EventsListener<lk.RoomEvent>? _ascoltatoreDellaStanza;

  @override
  void initState() {
    super.initState();
    // **Lo schermo non si spegne mentre si parla.** Ordine EK: il LIVE si fa
    // senza toccare il telefono, e allo spegnimento automatico il microfono
    // taceva e il LIVE si chiudeva. Vedi `LoSchermoAcceso`.
    unawaited(LoSchermoAcceso.tieni(true));
    // **La musica tace finche' il LIVE e' aperto.** Ordine EK voce 03: il
    // microfono la sentiva come una persona che parla, e la frase non si
    // chiudeva mai. Vedi `liveCheZittisce`.
    liveCheZittisce.value = true;
    unawaited(_apri());
    unawaited(_caricaIlFiltroDelVolto());
  }

  /// Il filtro che toglie il fondo bianco e il filo lungo la sagoma, se lo
  /// shader si carica; altrimenti resta il filtro colore, che toglie il fondo
  /// ma lascia il filo.
  ui.ImageFilter? _filtroDelVolto;

  Future<void> _caricaIlFiltroDelVolto() async {
    try {
      final programma =
          await ui.FragmentProgram.fromAsset('shaders/volto_senza_fondo.frag');
      // La toppa del Maestro, dopo la dimensione che scrive il motore: fuori
      // dal video quando non c'e'. **Lo shader riceve la finestra, non il
      // video intero**: il motore gli passa solo cio' che il ritaglio lascia
      // vedere, e la prima prova con le coordinate del video non ha
      // riempito niente. Qui la toppa si porta nelle frazioni della finestra.
      final inquadratura =
          InquadraturaDelVolto.di(widget.maestro, avatar: _avatarDellaSessione);
      final r = inquadratura.ritaglio;
      Rect nellaFinestra(Rect? t) => t == null
          ? const Rect.fromLTRB(-1, -1, -1, -1)
          : Rect.fromLTRB(
              (t.left - r.left) / r.width,
              (t.top - r.top) / r.height,
              (t.right - r.left) / r.width,
              (t.bottom - r.top) / r.height,
            );
      final toppa = nellaFinestra(inquadratura.toppa);
      final intatto = nellaFinestra(inquadratura.intatto);
      final shader = programma.fragmentShader()
        ..setFloat(2, toppa.left)
        ..setFloat(3, toppa.top)
        ..setFloat(4, toppa.right)
        ..setFloat(5, toppa.bottom)
        ..setFloat(6, intatto.left)
        ..setFloat(7, intatto.top)
        ..setFloat(8, intatto.right)
        ..setFloat(9, intatto.bottom);
      final filtro = ui.ImageFilter.shader(shader);
      if (mounted) setState(() => _filtroDelVolto = filtro);
    } catch (errore) {
      annotaGuastoInnocuo(
          'lo shader del volto non si carica, resta il filtro colore', errore);
    }
  }

  @override
  void dispose() {
    _orologio?.cancel();
    unawaited(_ascoltatoreDellaStanza?.dispose());
    _campo.dispose();
    unawaited(_orecchio.dispose());
    _livello.dispose();
    widget.chat?.nelLive = false;
    // **La stanza si chiude sempre**, anche col tasto indietro: una stanza
    // lasciata aperta continua a consumare minuti che nessuno usa.
    unawaited(_stanza?.disconnect());
    _chiudiLaSessione();
    unawaited(LoSchermoAcceso.tieni(false));
    liveCheZittisce.value = false;
    super.dispose();
  }

  /// L'avatar che il server ha scelto per questa sessione: decide
  /// l'inquadratura, `InquadraturaDelVolto.di`. Ordine EK voce 04.
  String? _avatarDellaSessione;

  /// La sessione di Protoface aperta da questa schermata, finche' non la si
  /// chiude: si chiude una volta sola.
  String? _sessioneAperta;

  /// **LASCIARE LA STANZA NON CHIUDE LA SESSIONE.** Ordine EK, guasto trovato
  /// fuori dal perimetro, padre l'ordine EG: Protoface la teneva accesa
  /// sessanta secondi dopo l'uscita, e li faceva pagare. Si chiama da ogni
  /// strada che esce: la croce, il tempo finito, il silenzio, il tasto
  /// indietro, e il volto che non arriva.
  void _chiudiLaSessione() {
    final id = _sessioneAperta;
    _sessioneAperta = null;
    if (id != null) unawaited(PortaDelLive.chiudi(id));
  }

  Future<void> _apri() async {
    final SessioneLive s;
    // **Il saluto si compone mentre la sessione si apre e il volto entra
    // nella stanza.** E' la prima cosa che la persona sente, e con la funzione
    // della voce ancora fredda arrivava dopo 3,3 secondi; chiesto dopo
    // l'apertura della sessione arrivava ancora dopo 4,4, misurati sul Realme.
    // Qui parte subito, e quel tempo si spende mentre si aspetta comunque. Se
    // la voce non nasce, il saluto la chiede di nuovo al momento di dirlo.
    final salutoPronto = PortaDelLive.voceAFlusso(
            widget.maestro, ilSalutoDellaVoceViva(widget.maestro))
        .toList()
        .catchError((Object errore) {
      annotaGuastoInnocuo('il saluto non si compone in anticipo', errore);
      return <({Uint8List pcm, int tasso, int canali})>[];
    });
    try {
      s = await PortaDelLive.apri(widget.maestro);
      _sessioneAperta = s.sessione;
      // **L'inquadratura la decide l'avatar che il server ha scelto**, e il
      // filtro del fondo si riconfigura su di lei. Ordine EK voce 04.
      _avatarDellaSessione = s.avatar;
      unawaited(_caricaIlFiltroDelVolto());
    } on IlLiveNonSiApre catch (e) {
      if (!mounted) return;
      setState(() => _quadro = _quadro.con(
            momento: MomentoDelLive.nonSiApre,
            perche: e.perche,
          ));
      return;
    }

    try {
      // **L'altoparlante, non l'auricolare.** Il LIVE si guarda tenendo il
      // telefono davanti, e su Android una chiamata WebRTC suona di default
      // nell'auricolare, cioe' vicino all'orecchio.
      final stanza = lk.Room(
        roomOptions: const lk.RoomOptions(
          defaultAudioOutputOptions: lk.AudioOutputOptions(speakerOn: true),
        ),
      );
      // **Il volto dice quando ha finito di parlare**, e solo allora si torna
      // ad ascoltare. E' il protocollo di Protoface sul flusso di dati.
      stanza.registerRpcMethod('lk.playback_finished', (dati) async {
        final fine = _fineDellaVoce;
        if (fine != null && !fine.isCompleted) fine.complete();
        return '';
      });
      stanza.addListener(_quandoLaStanzaCambia);
      // **Il volto che parla davvero nella stanza** chiude la misura
      // dell'attesa: e' il momento in cui la persona lo sente. Ordine EM voce
      // 11.
      _ascoltatoreDellaStanza = stanza.createListener()
        ..on<lk.ActiveSpeakersChangedEvent>((e) {
          if (_attesaAperta &&
              e.speakers.any((p) => p.identity == s.lavoratore)) {
            _attesaAperta = false;
            _segnaTappa('il volto parla');
            _scriviLAttesa();
          }
        });
      await stanza.connect(s.url, s.gettone);
      if (!mounted) {
        await stanza.disconnect();
        _chiudiLaSessione();
        return;
      }
      setState(() {
        _stanza = stanza;
        _quadro = _quadro.con(
          momento: MomentoDelLive.siAspettaIlVolto,
          sessione: s,
        );
      });
      _orologio = Timer.periodic(const Duration(seconds: 1), (_) => _batti());
      widget.chat?.nelLive = true;

      if (!await _aspettaIlVolto(s.lavoratore)) {
        annotaGuastoInnocuo(
          'il volto del LIVE non è entrato nella stanza, sessione '
          '${s.sessione}',
          StateError('nessun ${s.lavoratore} in 20 secondi'),
        );
        _chiudiLaSessione();
        if (!mounted) return;
        setState(() => _quadro = _quadro.con(
              momento: MomentoDelLive.nonSiApre,
              perche: PerchePerILiveNonSiApre.guasto,
            ));
        return;
      }
      if (!mounted) return;
      setState(() => _quadro = _quadro.con(momento: MomentoDelLive.vivo));
      await _dillo(ilSalutoDellaVoceViva(widget.maestro),
          giaPronta: salutoPronto);
      await _ascoltaLaPersona();
    } catch (errore) {
      annotaGuastoInnocuo('il LIVE non entra nella stanza', errore);
      if (!mounted) return;
      setState(() => _quadro = _quadro.con(
            momento: MomentoDelLive.nonSiApre,
            perche: PerchePerILiveNonSiApre.guasto,
          ));
    }
  }

  void _quandoLaStanzaCambia() {
    if (mounted) setState(() {});
  }

  /// Aspetta che il volto di Protoface sia nella stanza, fino a venti secondi.
  /// **Mandargli la voce prima che ci sia vuol dire mandarla a nessuno.**
  Future<bool> _aspettaIlVolto(String lavoratore) async {
    for (var i = 0; i < 40; i++) {
      final presente = _stanza?.remoteParticipants.values
              .any((p) => p.identity == lavoratore) ??
          false;
      if (presente) return true;
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!mounted) return false;
    }
    return false;
  }

  void _batti() {
    if (!mounted) return;
    final passati = _quadro.secondiPassati + 1;
    setState(() => _quadro = _quadro.con(secondiPassati: passati));
    if (passati == 8 || passati == 25) unawaited(_misuraIlVideo());
    // Mentre il Maestro parla o compone la risposta non e' silenzio, e
    // nemmeno mentre la persona dice una frase lunga o tiene premuto, o
    // mentre la sua frase si trascrive.
    if (QuadroDelLive.eUnSecondoDiSilenzio(
      parlaIlMaestro: _parla,
      pensaIlMaestro: _pensa,
      parlaLaPersona: _orecchio.staParlando,
      frasiInTrascrizione: _frasiInTrascrizione,
      nelSelettore: _nelSelettore,
    )) {
      _secondiDiSilenzio++;
    }
    if (_quadro.ilTempoEFinito) {
      unawaited(_chiudi(ComeFinisce.tempo));
    } else if (_quadro.chiudePerSilenzio(_secondiDiSilenzio)) {
      debugPrint('LIVE: chiusa dopo $_secondiDiSilenzio secondi di silenzio');
      unawaited(_chiudi(ComeFinisce.silenzio));
    }
  }

  /// **QUANTO E' GRANDE IL VOLTO CHE ARRIVA, E QUANTO LO SI MOSTRA.** Ordine
  /// EJ voce 03: il fondatore vede i mezzibusti sfocati. Si scrive nel
  /// registro la risoluzione del video ricevuto e la finestra a schermo in
  /// pixel veri, cosi' si sa se il limite e' il flusso, l'ingrandimento o
  /// l'immagine di partenza.
  Future<void> _misuraIlVideo() async {
    try {
      final traccia = _primaTracciaVideo();
      final stat = traccia is lk.RemoteVideoTrack
          ? await traccia.getReceiverStats()
          : null;
      if (!mounted) return;
      Size? finestra;
      void cerca(Element e) {
        if (finestra != null) return;
        if (e.widget.key == const Key('live_finestra')) {
          finestra = (e.renderObject as RenderBox?)?.size;
          return;
        }
        e.visitChildElements(cerca);
      }

      context.visitChildElements(cerca);
      final dpr = MediaQuery.devicePixelRatioOf(context);
      final ritaglio =
          InquadraturaDelVolto.di(widget.maestro, avatar: _avatarDellaSessione)
              .ritaglio;
      final f = finestra;
      debugPrint('LIVE VIDEO: ricevuto ${stat?.frameWidth}x'
          '${stat?.frameHeight} a ${stat?.framesPerSecond} fps, codec '
          '${stat?.mimeType}, decoder ${stat?.decoderImplementation}; '
          'finestra ${f == null ? '?' : '${(f.width * dpr).round()}x'
              '${(f.height * dpr).round()}'} px veri, ritaglio '
          '${(ritaglio.width * 1000).round()}x'
          '${(ritaglio.height * 1000).round()} millesimi del video');
    } catch (errore) {
      annotaGuastoInnocuo('la misura del video non riesce', errore);
    }
  }

  /// Secondi passati senza che nessuno abbia detto o scritto niente.
  int _secondiDiSilenzio = 0;

  /// Le frasi della persona che si stanno trascrivendo adesso: quel tempo non
  /// e' silenzio (`QuadroDelLive.eUnSecondoDiSilenzio`).
  int _frasiInTrascrizione = 0;

  /// Qualcuno ha detto o scritto qualcosa: il silenzio riparte da zero.
  void _cePresenza() => _secondiDiSilenzio = 0;

  Future<void> _chiudi([ComeFinisce? come]) async {
    _orologio?.cancel();
    await _orecchio.ferma();
    await _stanza?.disconnect();
    _chiudiLaSessione();
    if (!mounted) return;
    setState(() =>
        _quadro = _quadro.con(momento: MomentoDelLive.finito, fine: come));
  }

  // --- ASCOLTARE --------------------------------------------------------

  /// **Il microfono si apre quando il Maestro ha finito, e resta aperto.**
  /// Nessun tempo massimo per cominciare: il silenzio della stanza lo misura
  /// l'orologio dei trenta secondi, che chiude la sessione intera e non una
  /// frase. Il microfono resta aperto anche fra una frase e l'altra, e
  /// `LeFrasiDellaPersona` decide quando i pezzi detti diventano la domanda.
  Future<void> _ascoltaLaPersona() async {
    if (!mounted || _parla || _pensa || _ascolta || _nelSelettore) return;
    if (_quadro.momento != MomentoDelLive.vivo) return;
    _frasi.dimentica();
    _anticipata = null;
    _orecchio.suLivello = (l) => _livello.value = l;
    _orecchio.suFrase = (pcm, pausa) => unawaited(_unaFrase(pcm, pausa));
    _orecchio.suPausa = _inPausa;
    _orecchio.suControllo = _alControllo;
    setState(() => _ascolta = true);
    final aperto = await _orecchio.ascolta();
    if (mounted && !aperto) setState(() => _ascolta = false);
  }

  /// Una frase si e' chiusa: si trascrive tutto cio' che la persona ha detto
  /// finora, e parte come domanda solo se lei ha smesso di parlare.
  ///
  /// **IL RUMORE NON E' PRESENZA.** Sul Realme un rumore apriva ogni tanto
  /// una "frase" che Gemini trovava vuota, e ogni volta l'orologio del
  /// silenzio ripartiva da zero: la sessione non si chiudeva mai e consumava
  /// crediti. La presenza la da' solo una frase con parole.
  Future<void> _unaFrase(Uint8List pcm, int pausa) async {
    final frase = _orecchio.ultimaConsegnata;
    final fineDelParlato = _orecchio.ultimaVoce;
    final chiusaAl = DateTime.now();
    final anticipata = _anticipata;
    _anticipata = null;
    final giroPrima = _frasi.giro;
    final daTrascrivere = _frasi.chiusa(pcm);
    final pezzi = _frasi.pezziInAttesa;
    final orologio = Stopwatch()..start();
    var detto = '';
    var comeTrascritta = 'alla chiusura';
    var trascritta = false;
    _frasiInTrascrizione++;
    try {
      String? pronto;
      // La trascrizione e' pronta se l'ha cominciata la pausa che ha chiuso
      // la frase, o il controllo che l'ha chiusa (-2); non se l'ha chiusa la
      // mano (-1).
      if (anticipata != null &&
          pausa != -1 &&
          anticipata.pausa == pausa &&
          anticipata.giro == giroPrima) {
        pronto = await anticipata.testo;
        if (pronto != null) {
          comeTrascritta = pausa == -2 ? 'al controllo' : 'in pausa';
        }
      }
      detto = pronto ?? await _trascrivi(daTrascrivere.pcm);
      // **UNA FRASE DI VOCE VERA NON TORNA VUOTA AL PRIMO COLPO.** Ordine EM
      // voce 04, secondo giro. Sul Realme, nella stanza silenziosa, "Sono
      // dello Scorpione con ascendente Sagittario e la Luna in Capricorno"
      // e' tornata vuota dalla trascrizione anticipata, mentre il controllo
      // di un secondo e mezzo prima ne aveva quasi tutte le parole: la
      // domanda si e' persa e il LIVE si e' chiuso per silenzio. Con piu' di
      // un secondo di voce vera, si trascrive di nuovo l'audio intero.
      if (detto.isEmpty && _orecchio.voceDellaFrase(frase) >= laVoceChiara) {
        detto = await _trascrivi(daTrascrivere.pcm);
        comeTrascritta = '$comeTrascritta, poi di nuovo';
      }
      trascritta = true;
    } catch (errore) {
      annotaGuastoInnocuo('la frase del LIVE non si trascrive', errore);
    } finally {
      _frasiInTrascrizione--;
    }
    // **Una frase senza parole era sottofondo: la stanza impara il suo
    // livello.** Ordine EM voce 04, secondo giro. Non se la trascrizione e'
    // caduta: una domanda vera diventerebbe sottofondo.
    if (trascritta && detto.isEmpty) _orecchio.eraSottofondo(frase);
    final domanda = _frasi.trascritta(daTrascrivere.biglietto, detto,
        parlaDiNuovo: _orecchio.staParlando);
    debugPrint('LIVE: frase di ${daTrascrivere.pcm.length ~/ 32} ms in '
        '$pezzi pezzi, trascritta in ${orologio.elapsedMilliseconds} ms '
        'dalla chiusura, $comeTrascritta: «$detto» '
        '${domanda == null ? '(si ascolta ancora)' : '(parte)'}');
    // **UNA FRASE CHE TORNA VUOTA DUE VOLTE NON FA PARLARE IL MAESTRO.**
    // Ordine EM voce 04, secondo giro, 25 settembre 2026. Per un giro il
    // Maestro diceva "Non ho sentito bene: me lo ripeti?": sul Realme e'
    // scattato due volte su frasi aperte nell'istante in cui il microfono si
    // riapriva, cioe' sulla coda della sua stessa voce dall'altoparlante, e
    // mentre parlava il microfono era chiuso: la domanda vera che arrivava in
    // quel momento si e' persa, e quella dopo ha perso il nome del Maestro.
    // Resta la seconda trascrizione qui sopra, che non costa niente a chi
    // parla e salva la domanda tornata vuota per un inciampo.
    if (domanda == null || !mounted) return;
    if (_quadro.momento != MomentoDelLive.vivo || _parla || _pensa) return;
    _cePresenza();
    _fineDelParlato = fineDelParlato ?? chiusaAl;
    _tappe
      ..clear()
      ..['frase chiusa'] = chiusaAl.difference(_fineDelParlato!).inMilliseconds;
    _segnaTappa('trascritta');
    await _turno(domanda);
  }

  /// **Quanta voce vera rende incredibile una trascrizione vuota.** Ordine
  /// EM voce 04, secondo giro.
  static const Duration laVoceChiara = Duration(seconds: 1);

  /// **La frase e' in pausa: si comincia a trascriverla.** Ordine EM voce 11.
  /// Un guasto qui non si vede: alla chiusura la frase si trascrive di nuovo.
  void _inPausa(Uint8List pcm, int pausa) {
    final orologio = Stopwatch()..start();
    final audio = _frasi.anteprima(pcm);
    final testo = _trascrivi(audio).then<String?>((t) {
      debugPrint('LIVE: trascrizione anticipata in '
          '${orologio.elapsedMilliseconds} ms, pausa $pausa: «$t»');
      return t;
    }).catchError((Object errore) {
      annotaGuastoInnocuo('la trascrizione anticipata non riesce', errore);
      return null;
    });
    _anticipata = (pausa: pausa, giro: _frasi.giro, testo: testo);
  }

  /// **IL CONTROLLO DI UNA FRASE APERTA SU UN SUONO CONTINUO.** Ordine EM
  /// voce 04, secondo giro. Si trascrive cio' che e' stato detto finora, e
  /// `IlGiudizioDellaFrase` decide: solo sottofondo, la frase si scarta e la
  /// stanza impara; parole ferme, la frase parte con questa trascrizione;
  /// parole che crescono, si aspetta. Un guasto qui non si vede: la frase
  /// resta com'era.
  void _alControllo(Uint8List pcm, int frase, int controllo) {
    final orologio = Stopwatch()..start();
    final giro = _frasi.giro;
    unawaited(_trascrivi(_frasi.anteprima(pcm)).then((testo) {
      if (!mounted || !_ascolta) return;
      final cosa =
          _giudizio.giudica(frase: frase, controllo: controllo, testo: testo);
      debugPrint('LIVE: controllo $controllo della frase $frase in '
          '${orologio.elapsedMilliseconds} ms: «$testo», ${cosa.name}, '
          'sottofondo ${_orecchio.sottofondo?.round()}');
      switch (cosa) {
        case CosaFareDellaFrase.scarta:
          if (_orecchio.scarta(frase)) {
            _frasi.dimentica();
          } else {
            debugPrint('LIVE: la frase $frase non si scarta: sta sopra il '
                'sottofondo, o è il primo controllo vuoto senza sottofondo');
          }
        case CosaFareDellaFrase.chiudi:
          if (giro != _frasi.giro) return;
          _anticipata = (pausa: -2, giro: giro, testo: Future.value(testo));
          if (!_orecchio.chiudi(frase)) _anticipata = null;
        case CosaFareDellaFrase.aspetta:
          break;
      }
    }).catchError((Object errore) {
      annotaGuastoInnocuo('il controllo della frase non riesce', errore);
    }));
  }

  /// La trascrizione di [pcm], con le regole del LIVE di questo Maestro.
  Future<String> _trascrivi(Uint8List pcm) async {
    final detto = await LaTrascrizione.trascrivi(
        wavDaPcm(pcm, tasso: LOrecchioDelLive.tasso));
    // **Nel LIVE di Aura "Laura" e' Aura.** Ordine EM voce 01.
    return LaTrascrizione.nelLiveDi(widget.maestro, detto);
  }

  /// Segna una tappa dell'attesa, in millesimi dalla fine del parlato.
  void _segnaTappa(String nome) {
    final da = _fineDelParlato;
    if (da == null) return;
    _tappe[nome] = DateTime.now().difference(da).inMilliseconds;
  }

  /// **Il registro dell'attesa**, una riga per domanda. Ordine EM voce 11.
  void _scriviLAttesa() {
    debugPrint('LIVE ATTESA dalla fine del parlato: '
        '${_tappe.entries.map((e) => '${e.key} ${e.value} ms').join(', ')}');
  }

  /// **PREMI PER PARLARE.** Finche' la persona tiene premuto la frase non si
  /// chiude, qualunque pausa faccia; quando lascia, parte.
  Future<void> _premi() async {
    if (_parla || _pensa) return;
    _orecchio.aMano = true;
    _cePresenza();
    if (!_ascolta) unawaited(_ascoltaLaPersona());
    setState(() {});
  }

  Future<void> _lascia() async {
    if (!_orecchio.aMano) return;
    _orecchio.lascia();
    if (mounted) setState(() {});
  }

  // --- RISPONDERE -------------------------------------------------------

  /// Un turno: la persona ha detto o scritto [testo], il Maestro risponde.
  Future<void> _turno(String testo) async {
    final chat = widget.chat;
    if (chat == null || _pensa || _parla) return;
    await _orecchio.ferma();
    _frasi.dimentica();
    _livello.value = 0;
    _cePresenza();
    setState(() {
      _ascolta = false;
      _pensa = true;
      // **La domanda resta a video, e la risposta arrivera' sotto.** Ordine
      // EM voce 09.
      _quadro = _quadro.con(domanda: testo, sottotitolo: '');
    });
    final prima = chat.messages.length;
    final orologio = Stopwatch()..start();
    try {
      await chat.send(testo);
      _segnaTappa('risposta');
      debugPrint('LIVE: la chat ha risposto in '
          '${orologio.elapsedMilliseconds} ms (rigenerazioni finora: '
          'ancoraggio ${chat.rigenerazioniPerAncoraggio}, troncatura '
          '${chat.rigenerazioniPerTroncatura})');
    } catch (errore) {
      annotaGuastoInnocuo('la chat non risponde nel LIVE', errore);
    }
    if (!mounted) return;
    final nuovi = chat.messages.skip(prima);
    ChatMessage? risposta;
    for (final m in nuovi) {
      if (m.role == ChatRole.maestro && !m.pending) risposta = m;
    }
    setState(() => _pensa = false);
    if (risposta != null) {
      await _dillo(risposta.text, conAttesa: true);
    } else {
      _fineDelParlato = null;
    }
    await _ascoltaLaPersona();
  }

  /// **LA VOCE DEL MAESTRO, VERSO IL VOLTO.** Il testo diventa voce sul
  /// server, e il telefono la manda a Protoface sul flusso di byte
  /// `lk.audio_stream`: PCM a 16 bit con tasso e canali negli attributi, come
  /// pretende il suo protocollo.
  ///
  /// **Ogni pezzo d'audio parte verso il volto appena arriva.** La prima
  /// stesura aspettava la voce intera di ogni frase, e il fondatore ha
  /// sentito la risposta "molti secondi dopo". Adesso il primo pezzo arriva
  /// in meno di un secondo e la bocca comincia a muoversi mentre il resto si
  /// sta ancora componendo; la voce si compone piu' in fretta di quanto si
  /// pronunci, quindi il volto non resta mai senza niente da dire.
  Future<void> _dillo(
    String scritto, {
    Future<List<({Uint8List pcm, int tasso, int canali})>>? giaPronta,
    bool conAttesa = false,
  }) async {
    final stanza = _stanza;
    final s = _quadro.sessione;
    final io = stanza?.localParticipant;
    if (stanza == null || s == null || io == null) return;
    final pezzi = IlParlatoDelMaestro.pezzi(scritto);
    if (pezzi.isEmpty) return;

    setState(() {
      _parla = true;
      _quadro = _quadro.con(sottotitolo: IlParlatoDelMaestro.daDire(scritto));
    });
    final orologio = Stopwatch()..start();
    var secondiDiVoce = 0.0;
    Duration? primoSuono;
    // Il segnale di fine si prepara PRIMA di mandare la voce: un volto
    // veloce potrebbe dirlo prima che lo si stia aspettando.
    _fineDellaVoce = Completer<void>();
    try {
      lk.ByteStreamWriter? scrittore;
      for (final pezzo in pezzi) {
        final flusso = giaPronta != null && pezzi.length == 1
            ? _laVoceGiaPronta(giaPronta, pezzo)
            : PortaDelLive.voceAFlusso(widget.maestro, pezzo);
        await for (final voce in flusso) {
          scrittore ??= await io.streamBytes(lk.StreamBytesOptions(
            name: 'AUDIO_${DateTime.now().microsecondsSinceEpoch}',
            topic: 'lk.audio_stream',
            destinationIdentities: [s.lavoratore],
            attributes: {
              'sample_rate': '${voce.tasso}',
              'num_channels': '${voce.canali}',
            },
          ));
          if (primoSuono == null && conAttesa) {
            _segnaTappa('primo audio al volto');
            _attesaAperta = true;
          }
          primoSuono ??= orologio.elapsed;
          secondiDiVoce += voce.pcm.length / (2 * voce.canali * voce.tasso);
          await _scriviAPezzi(scrittore, voce.pcm);
        }
      }
      await scrittore?.close();
      debugPrint(
          'LIVE: primo suono al volto dopo ${primoSuono?.inMilliseconds} '
          'ms, audio di ${(secondiDiVoce * 1000).round()} ms, scritto in '
          '${orologio.elapsedMilliseconds} ms');
      // Si aspetta che il volto dica di aver finito; se non lo dice, si
      // aspetta quanto dura la voce dal primo suono, e un poco di margine.
      final resta = (primoSuono ?? Duration.zero) +
          Duration(milliseconds: (secondiDiVoce * 1000).round() + 3000) -
          orologio.elapsed;
      final detto = await _fineDellaVoce!.future.then((_) => true).timeout(
          resta.isNegative ? Duration.zero : resta,
          onTimeout: () => false);
      debugPrint('LIVE: il volto ha finito dopo ${orologio.elapsedMilliseconds}'
          ' ms, ${detto ? 'lo ha detto lui' : 'per tempo scaduto'}');
      // **LA CODA DELLA VOCE DEL VOLTO.** Il volto dice di aver finito quando
      // ha mandato l'ultimo pezzo, ma l'altoparlante lo sta ancora suonando:
      // sul Realme il microfono, riaperto subito, sentiva quella coda e apriva
      // una frase vuota dopo ogni risposta. Ordine EJ voce 01.
      await Future<void>.delayed(const Duration(milliseconds: 700));
    } catch (errore) {
      annotaGuastoInnocuo('l\'audio del Maestro non arriva al volto', errore);
    } finally {
      _fineDellaVoce = null;
      // Il silenzio si conta da quando il Maestro ha finito di parlare.
      _cePresenza();
      if (mounted) setState(() => _parla = false);
    }
  }

  /// La voce composta in anticipo; se non e' nata, si chiede adesso.
  Stream<({Uint8List pcm, int tasso, int canali})> _laVoceGiaPronta(
    Future<List<({Uint8List pcm, int tasso, int canali})>> giaPronta,
    String pezzo,
  ) async* {
    final tutta = await giaPronta;
    if (tutta.isEmpty) {
      yield* PortaDelLive.voceAFlusso(widget.maestro, pezzo);
    } else {
      yield* Stream.fromIterable(tutta);
    }
  }

  /// I pacchetti di LiveKit hanno un tetto: la voce si scrive a fette.
  static Future<void> _scriviAPezzi(
      lk.ByteStreamWriter scrittore, Uint8List pcm) async {
    const fetta = 15000;
    for (var da = 0; da < pcm.length; da += fetta) {
      final a = da + fetta < pcm.length ? da + fetta : pcm.length;
      await scrittore.write(Uint8List.sublistView(pcm, da, a));
    }
  }

  /// **IL SELETTORE DELLE VOCI FERMA L'ASCOLTO, E LO RIPRENDE.** Ordine EM
  /// voce 08, 25 settembre 2026. Il fondatore: *"Quando torno indietro dal
  /// selettore, il microfono non funziona più."* Due difetti insieme: il
  /// microfono restava aperto mentre le anteprime suonavano, e le avrebbe
  /// trascritte come domande; e il registratore, alla prima anteprima,
  /// perdeva il fuoco audio e si fermava per sempre (la cura sta in
  /// `LOrecchioDelLive.configurazione`). Adesso il microfono si chiude
  /// quando il selettore si apre, l'orologio del silenzio non conta, e alla
  /// chiusura l'ascolto riparte.
  Future<void> _apriIlSelettore() async {
    if (_nelSelettore) return;
    _nelSelettore = true;
    await _orecchio.ferma();
    if (mounted) setState(() => _ascolta = false);
    try {
      if (mounted) await IlSelettoreDelleVoci.apri(context, widget.maestro);
    } finally {
      _nelSelettore = false;
      if (mounted) {
        _cePresenza();
        unawaited(_ascoltaLaPersona());
      }
    }
  }

  /// **IL RIPIEGO TATTILE**: chi non puo' parlare scrive, e il Maestro
  /// risponde a voce lo stesso.
  Future<void> _mandaScritto() async {
    final testo = _campo.text.trim();
    if (testo.isEmpty) return;
    _campo.clear();
    await _turno(testo);
  }

  // --- DISEGNARE --------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // **Nero, e lo stesso nero ovunque.** Sul Realme la zona del video
      // restava blu notte mentre il resto dello schermo era nero puro, e si
      // intuiva ancora il riquadro che il filtro aveva appena tolto. Il
      // fondatore: "almeno mettiamo uno sfondo nero".
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.maestro.displayName),
        actions: [
          // **Il selettore delle voci, ordine EJ voce 02.** Lo vede solo chi
          // il server riconosce come fondatore.
          if (_quadro.sessione?.eFondatore ?? false)
            IconButton(
              key: const Key('live_voci'),
              tooltip: 'Scegli il timbro',
              icon: const Icon(Icons.record_voice_over),
              onPressed: () => unawaited(_apriIlSelettore()),
            ),
          if (_quadro.sessione != null)
            Padding(
              padding: const EdgeInsets.only(right: SpacingTokens.md),
              child: Center(
                child: Text(
                  key: const Key('live_tempo'),
                  _tempoAVideo(),
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textSecondary),
                ),
              ),
            ),
          IconButton(
            key: const Key('live_chiudi'),
            icon: const Icon(Icons.close),
            onPressed: () async {
              await _chiudi();
              if (context.mounted) Navigator.of(context).maybePop();
            },
          ),
        ],
      ),
      // **La scena ha le sue misure fisse**: il volto non cambia misura fra
      // una domanda e una risposta. Ordine EM voci 09 e 10, vedi
      // `LaScenaDelLive`.
      body: SafeArea(
        child: LaScenaDelLive(
          volto: _ilVolto(),
          domanda: _quadro.domanda,
          risposta: _quadro.sottotitolo,
          stato: _quadro.momento != MomentoDelLive.vivo
              ? ''
              : _pensa
                  ? 'Sto pensando.'
                  : _parla
                      ? ''
                      : _orecchio.aMano
                          ? 'Parla quanto vuoi, poi lascia.'
                          : _ascolta
                              ? 'Ti ascolto. Prenditi il tempo che serve.'
                              : 'Tieni premuto il microfono o scrivimi.',
          livello: _ascolta ? _laBarraDellAscolto() : null,
          tastiera: _quadro.siPuoScrivere ? _laTastiera() : null,
        ),
      ),
    );
  }

  String _tempoAVideo() {
    final s = _quadro.mancanoSecondi();
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  Widget _ilVolto() {
    if (_quadro.momento == MomentoDelLive.nonSiApre) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.xl),
          child: Text(
            key: const Key('live_rifiuto'),
            _quadro.laFraseDelRifiuto(),
            style: TypographyTokens.corpo(),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (_quadro.momento == MomentoDelLive.finito) {
      // **Il congedo, e la strada per tornare.** La voce viva si e' chiusa
      // da sola: si dice perche', e si offre il ritorno alla conversazione.
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BustoDelMaestro(maestro: widget.maestro, height: 180),
              const SizedBox(height: SpacingTokens.lg),
              Text(
                key: const Key('live_congedo'),
                _quadro.laFraseDellaFine(),
                style: TypographyTokens.corpo(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpacingTokens.lg),
              TextButton(
                key: const Key('live_torna_alla_chat'),
                // Il colore si dichiara: preso dal tema era il viola del
                // primario, a contrasto fra 1,40 e 2,53 su questi fondi.
                style: TextButton.styleFrom(
                    foregroundColor: ColorTokens.goldLight),
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Torna alla conversazione'),
              ),
            ],
          ),
        ),
      );
    }
    final traccia = _primaTracciaVideo();
    if (traccia == null) {
      // Finche' il volto non arriva, il ritratto del Maestro dalla porta unica.
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BustoDelMaestro(
                maestro: widget.maestro, height: 220, respira: true),
            const SizedBox(height: SpacingTokens.lg),
            Text(
              key: const Key('live_attesa'),
              _quadro.momento == MomentoDelLive.siApre
                  ? 'Sto arrivando.'
                  : 'Un momento e sono con te.',
              style: TypographyTokens.corpo(),
            ),
          ],
        ),
      );
    }
    // **IL FONDO BIANCO DEL VOLTO SI TOGLIE QUI.** Il video di Protoface
    // non porta il canale alpha, WebRTC non lo trasporta, e l'avatar e' nato
    // da un'immagine il cui fondo e' diventato bianco: il fondatore l'ha
    // visto come un riquadro bianco che "fa schifo". Protoface non ha
    // un'opzione di sfondo nella sessione. Il filtro rende trasparenti i
    // pixel quasi bianchi: pienamente sopra una media di 250 per canale,
    // per niente sotto 230, e in mezzo sfuma, cosi' il bordo non si sgrana.
    final filtro = _filtroDelVolto;
    final volto = filtro != null
        ? ImageFiltered(
            imageFilter: filtro,
            child: lk.VideoTrackRenderer(traccia, fit: lk.VideoViewFit.contain),
          )
        : ColorFiltered(
            colorFilter: const ColorFilter.matrix(<double>[
              1, 0, 0, 0, 0, //
              0, 1, 0, 0, 0, //
              0, 0, 1, 0, 0, //
              -_pendenzaDelBianco, -_pendenzaDelBianco, -_pendenzaDelBianco, 0,
              _pendenzaDelBianco * 750, //
            ]),
            child: lk.VideoTrackRenderer(traccia, fit: lk.VideoViewFit.contain),
          );
    return _FinestraDelVolto(
        maestro: widget.maestro, avatar: _avatarDellaSessione, volto: volto);
  }

  /// Quanto in fretta l'opacita' scende quando i tre canali insieme passano
  /// da 690 a 750, cioe' da una media di 230 a una di 250.
  static const _pendenzaDelBianco = 255 / 60;

  lk.VideoTrack? _primaTracciaVideo() {
    final altri = _stanza?.remoteParticipants.values;
    if (altri == null) return null;
    for (final p in altri) {
      for (final t in p.videoTrackPublications) {
        final traccia = t.track;
        if (traccia is lk.VideoTrack) return traccia;
      }
    }
    return null;
  }

  /// Il livello del microfono mentre si ascolta: la persona vede che la
  /// sua voce arriva, e che il microfono e' ancora aperto durante le pause.
  Widget _laBarraDellAscolto() => ValueListenableBuilder<double>(
        valueListenable: _livello,
        builder: (_, l, __) => SizedBox(
          key: const Key('live_livello'),
          width: 120,
          height: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: l,
              backgroundColor: ColorTokens.textSecondary.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(ColorTokens.goldLight),
            ),
          ),
        ),
      );

  Widget _laTastiera() => Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Row(
          children: [
            // **Tocca per aprire, tieni premuto per parlare senza limiti.**
            // Ordine EJ voce 01: finche' il dito resta sul microfono la frase
            // non si chiude, e parte quando lo si lascia.
            Semantics(
              button: true,
              label: 'Tieni premuto per parlare',
              child: GestureDetector(
                key: const Key('live_microfono'),
                behavior: HitTestBehavior.opaque,
                onTap: _parla || _pensa
                    ? null
                    : () => unawaited(_ascoltaLaPersona()),
                onLongPressStart:
                    _parla || _pensa ? null : (_) => unawaited(_premi()),
                onLongPressEnd: (_) => unawaited(_lascia()),
                onLongPressCancel: () => unawaited(_lascia()),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _orecchio.aMano
                        ? ColorTokens.goldLight.withValues(alpha: 0.25)
                        : Colors.transparent,
                    border: Border.all(
                      color: _ascolta
                          ? ColorTokens.goldLight
                          : ColorTokens.textSecondary,
                    ),
                  ),
                  child: Icon(
                    _ascolta ? Icons.mic : Icons.mic_none,
                    color: _parla || _pensa
                        ? ColorTokens.textSecondary
                        : ColorTokens.goldLight,
                  ),
                ),
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: TextField(
                key: const Key('live_campo'),
                controller: _campo,
                style: TypographyTokens.corpo(),
                decoration: const InputDecoration(hintText: 'Oppure scrivimi'),
                onChanged: (_) => _cePresenza(),
                onSubmitted: (_) => _mandaScritto(),
              ),
            ),
            IconButton(
              key: const Key('live_manda'),
              icon: const Icon(Icons.send),
              onPressed: _parla || _pensa ? null : _mandaScritto,
            ),
          ],
        ),
      );
}

/// **LA FINESTRA AD ARCO SUL VOLTO.** Ordine EG voce 05.
///
/// Il volto sta dietro una finestra: arco in alto, doppio filo d'oro, un alone
/// del colore del Maestro, e il **bordo basso dritto sul taglio del busto**,
/// cosi' il busto non finisce nel vuoto ma sul davanzale. Il ritaglio lo
/// decide [InquadraturaDelVolto], misurato Maestro per Maestro.
class _FinestraDelVolto extends StatelessWidget {
  const _FinestraDelVolto(
      {required this.maestro, required this.avatar, required this.volto});

  final Maestro maestro;

  /// L'avatar della sessione: decide l'inquadratura. Ordine EK voce 04.
  final String? avatar;
  final Widget volto;

  static const _cornice = 4.0;
  static const _raggioBasso = 6.0;

  @override
  Widget build(BuildContext context) {
    final (profondo, alone) = switch (maestro) {
      Maestro.medora => (ColorTokens.medoraDeep, ColorTokens.medoraGlow),
      Maestro.aura => (ColorTokens.auraDeep, ColorTokens.auraGlow),
      Maestro.caligo => (ColorTokens.caligoDeep, ColorTokens.caligoGlow),
    };
    final ritaglio = InquadraturaDelVolto.di(maestro, avatar: avatar).ritaglio;
    return LayoutBuilder(builder: (context, spazio) {
      const margine = SpacingTokens.lg;
      final altezzaMassima = spazio.maxHeight - margine;
      final larghezzaMassima = spazio.maxWidth - 2 * margine;
      var altezza = altezzaMassima;
      var larghezza = altezza * InquadraturaDelVolto.proporzione;
      if (larghezza > larghezzaMassima) {
        larghezza = larghezzaMassima;
        altezza = larghezza / InquadraturaDelVolto.proporzione;
      }
      final arco = BorderRadius.vertical(
        top: Radius.circular(larghezza / 2),
        bottom: const Radius.circular(_raggioBasso),
      );
      final arcoDentro = BorderRadius.vertical(
        top: Radius.circular(larghezza / 2 - _cornice),
        bottom: const Radius.circular(3),
      );
      // **LA CORNICE D'ALTARE, ordine EN voce 03**: il filo esterno, il
      // filetto interno, la chiave di volta e il davanzale, disegnati sopra
      // la finestra e attorno a lei. La forma e la fascia restano quelle.
      return Center(
        child: CustomPaint(
          key: const Key('live_cornice'),
          foregroundPainter: const LaCorniceDellaFinestra(
              fascia: _cornice, raggioBasso: _raggioBasso),
          child: Container(
            key: const Key('live_finestra'),
            width: larghezza,
            height: altezza,
            padding: const EdgeInsets.all(_cornice),
            decoration: BoxDecoration(
              borderRadius: arco,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ColorTokens.goldBright,
                  ColorTokens.gold,
                  ColorTokens.goldDeep,
                  ColorTokens.gold,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: alone.withValues(alpha: 0.35),
                  blurRadius: 32,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: arcoDentro,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.35),
                    radius: 0.95,
                    colors: [profondo, Colors.black],
                  ),
                ),
                position: DecorationPosition.background,
                child: LayoutBuilder(builder: (context, dentro) {
                  // Il lato del video, perche' la larghezza del ritaglio riempia
                  // la finestra; e il video si appoggia in basso, perche' il
                  // taglio del busto cada esattamente sul bordo.
                  final lato = dentro.maxWidth / ritaglio.width;
                  return Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Positioned(
                        left: -ritaglio.left * lato,
                        top: dentro.maxHeight - ritaglio.bottom * lato,
                        width: lato,
                        height: lato,
                        child: volto,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      );
    });
  }
}

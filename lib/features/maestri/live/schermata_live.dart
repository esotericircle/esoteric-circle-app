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
import '../../../services/voce/dettatura_vera.dart';
import '../chat/maestro_chat_controller.dart';
import '../widgets/busto_del_maestro.dart';
import 'il_parlato_del_maestro.dart';
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
/// 4. Si ascolta la persona con la dettatura del telefono, oppure si legge
///    cio' che scrive: il ripiego tattile che `CLAUDE.md` rende obbligatorio.
/// 5. La risposta la da' **la stessa chat scritta**, con lo stesso Maestro, la
///    stessa memoria e le stesse regole, e resta scritta nella conversazione.
/// 6. La risposta diventa voce una frase alla volta, sul server con
///    Gemini-TTS, e il telefono la manda al volto sul flusso `lk.audio_stream`.
/// 7. Quando il volto ha finito di parlare, si torna ad ascoltare.
///
/// **Si ascolta solo quando il Maestro tace.** La dettatura sentirebbe la
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

  /// **Nella lingua dell'app, come nella chat. Ordine DX voce 02**: senza,
  /// su iPhone il riconoscitore ascolta in inglese e scrive "Indicate" al
  /// posto di "quindi". **E si risponde appena la frase e' finale**, senza
  /// aspettare i tre secondi di silenzio della chat scritta: a ogni turno si
  /// sentirebbero. Un silenzio piu' corto non era la cura, e' stato provato:
  /// valeva anche per il silenzio iniziale, e l'ascolto moriva prima che la
  /// persona cominciasse a parlare.
  late final _dettatura = DettaturaVera(
    lingua: () => mounted ? Localizations.maybeLocaleOf(context) : null,
  );
  final _dallUltimaParola = Stopwatch();
  Timer? _attesaDellaFrase;

  /// Vero mentre il Maestro sta parlando: in quel tempo non si ascolta.
  bool _parla = false;

  /// Vero mentre la chat compone la risposta.
  bool _pensa = false;

  /// Vero mentre la dettatura e' in ascolto.
  bool _ascolta = false;

  String _ultimeParole = '';
  Completer<void>? _fineDellaVoce;

  @override
  void initState() {
    super.initState();
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
      final inquadratura = InquadraturaDelVolto.di(widget.maestro);
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
    _attesaDellaFrase?.cancel();
    _campo.dispose();
    unawaited(_dettatura.ferma());
    widget.chat?.nelLive = false;
    // **La stanza si chiude sempre**, anche col tasto indietro: una stanza
    // lasciata aperta continua a consumare minuti che nessuno usa.
    unawaited(_stanza?.disconnect());
    super.dispose();
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
      await stanza.connect(s.url, s.gettone);
      if (!mounted) {
        await stanza.disconnect();
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
    // Mentre il Maestro parla o compone la risposta non e' silenzio.
    if (!_parla && !_pensa) _secondiDiSilenzio++;
    if (_quadro.ilTempoEFinito) {
      unawaited(_chiudi(ComeFinisce.tempo));
    } else if (_quadro.chiudePerSilenzio(_secondiDiSilenzio)) {
      debugPrint('LIVE: chiusa dopo $_secondiDiSilenzio secondi di silenzio');
      unawaited(_chiudi(ComeFinisce.silenzio));
    }
  }

  /// Secondi passati senza che nessuno abbia detto o scritto niente.
  int _secondiDiSilenzio = 0;

  /// Qualcuno ha detto o scritto qualcosa: il silenzio riparte da zero.
  void _cePresenza() => _secondiDiSilenzio = 0;

  Future<void> _chiudi([ComeFinisce? come]) async {
    _orologio?.cancel();
    await _dettatura.ferma();
    await _stanza?.disconnect();
    if (!mounted) return;
    setState(() =>
        _quadro = _quadro.con(momento: MomentoDelLive.finito, fine: come));
  }

  // --- ASCOLTARE --------------------------------------------------------

  Future<void> _ascoltaLaPersona() async {
    if (!mounted || _parla || _pensa || _ascolta) return;
    if (_quadro.momento != MomentoDelLive.vivo) return;
    _ultimeParole = '';
    var chiuso = false;
    // La frase si chiude una volta sola: la dettatura puo' dichiararla finale
    // e poi dire anche "finito", e il Maestro risponde una volta.
    void chiudi(String perche) {
      _attesaDellaFrase?.cancel();
      if (chiuso) return;
      chiuso = true;
      if (mounted) setState(() => _ascolta = false);
      final detto = _ultimeParole.trim();
      if (detto.isEmpty) return;
      debugPrint('LIVE: frase chiusa ($perche) '
          '${_dallUltimaParola.elapsedMilliseconds} ms dopo l\'ultima parola');
      unawaited(_turno(detto));
    }

    final parte = await _dettatura.ascolta(
      parole: (p) {
        _ultimeParole = p;
        _cePresenza();
        _dallUltimaParola
          ..reset()
          ..start();
        // **Un secondo e mezzo senza parole nuove chiude la frase.** Il
        // riconoscitore di Android la chiudeva da se' 2,6 secondi dopo
        // l'ultima parola, misurati sul Realme il 23 settembre 2026: in una
        // conversazione e' un secondo di troppo a ogni turno. Il silenzio
        // iniziale non e' toccato: questo orologio parte solo dalla prima
        // parola, e prima c'e' la pausa di tre secondi della dettatura.
        _attesaDellaFrase?.cancel();
        _attesaDellaFrase = Timer(
          const Duration(milliseconds: 1500),
          () => chiudi('un secondo e mezzo senza parole'),
        );
        if (mounted) setState(() => _quadro = _quadro.con(sottotitolo: p));
      },
      frase: (p) {
        _ultimeParole = p;
        chiudi('frase finale');
      },
      finito: () => chiudi('fine ascolto'),
    );
    if (mounted) setState(() => _ascolta = parte);
  }

  // --- RISPONDERE -------------------------------------------------------

  /// Un turno: la persona ha detto o scritto [testo], il Maestro risponde.
  Future<void> _turno(String testo) async {
    final chat = widget.chat;
    if (chat == null || _pensa || _parla) return;
    await _dettatura.ferma();
    _cePresenza();
    setState(() {
      _pensa = true;
      _quadro = _quadro.con(sottotitolo: testo);
    });
    final prima = chat.messages.length;
    final orologio = Stopwatch()..start();
    try {
      await chat.send(testo);
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
    if (risposta != null) await _dillo(risposta.text);
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _ilVolto()),
            if (_quadro.sottotitolo.isNotEmpty)
              // **Il sottotitolo non ruba la finestra.** Una risposta di
              // trenta secondi, scritta per intero, spingeva il volto a meta'
              // schermo: qui ha un tetto, e oltre scorre.
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.2,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: Text(
                    key: const Key('live_sottotitolo'),
                    _quadro.sottotitolo,
                    style: TypographyTokens.corpo(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            if (_quadro.momento == MomentoDelLive.vivo)
              Padding(
                padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
                child: Text(
                  key: const Key('live_stato'),
                  _pensa
                      ? 'Sto pensando.'
                      : _parla
                          ? ''
                          : _ascolta
                              ? 'Ti ascolto.'
                              : 'Tocca il microfono o scrivimi.',
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textSecondary),
                ),
              ),
            if (_quadro.siPuoScrivere) _laTastiera(),
          ],
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
    return _FinestraDelVolto(maestro: widget.maestro, volto: volto);
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

  Widget _laTastiera() => Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Row(
          children: [
            IconButton(
              key: const Key('live_microfono'),
              icon: Icon(_ascolta ? Icons.mic : Icons.mic_none),
              onPressed: _parla || _pensa ? null : _ascoltaLaPersona,
            ),
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
  const _FinestraDelVolto({required this.maestro, required this.volto});

  final Maestro maestro;
  final Widget volto;

  static const _cornice = 4.0;

  @override
  Widget build(BuildContext context) {
    final (profondo, alone) = switch (maestro) {
      Maestro.medora => (ColorTokens.medoraDeep, ColorTokens.medoraGlow),
      Maestro.aura => (ColorTokens.auraDeep, ColorTokens.auraGlow),
      Maestro.caligo => (ColorTokens.caligoDeep, ColorTokens.caligoGlow),
    };
    final ritaglio = InquadraturaDelVolto.di(maestro).ritaglio;
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
        bottom: const Radius.circular(6),
      );
      final arcoDentro = BorderRadius.vertical(
        top: Radius.circular(larghezza / 2 - _cornice),
        bottom: const Radius.circular(3),
      );
      return Center(
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
      );
    });
  }
}

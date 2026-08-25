import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/rituals/filo_del_giorno.dart';
import '../../core/sensi/ascoltatore_scuotimento.dart';
import '../../core/maestro/maestro.dart';
import '../../core/tarot/tarot_reading.dart';
import '../../core/tarot/tarot_card.dart';
import '../../core/tarot/stesa_in_corso.dart';
import '../../core/tarot/tarot_spread.dart';
import '../../core/tarot/tarot_topic.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'attesa_di_medora.dart';
import 'stesa_choreography.dart';
import 'stesa_fan.dart';
import 'stesa_handoff.dart';
import '../sigilli/regia_del_cammino.dart';
import 'stesa_reveal.dart';
import 'stesa_senses.dart';
import 'stesa_share_card.dart';
import 'medora_stage.dart';
import 'tarot_card_art.dart';
import 'tarot_selectors.dart';
import '../maestri/rotta_arte.dart';
import '../../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../core/condivisione/premio_della_condivisione.dart';

/// Il rapporto delle carte del mazzo, due a tre.
const double kTarotAspect = 2 / 3;

/// Stesa a Tre Carte, la headline dei tarocchi di Medora.
///
/// Un ventaglio di carte coperte col dorso di Medora: se ne pescano tre, che si
/// girano con un flip e prendono posto in Passato, Presente, Futuro. Ogni carta
/// esce dritta o rovesciata, e il testo mostrato e' sempre quello del verso in
/// cui e' uscita. Il pescaggio passa da un seme opzionale, cosi' test e anteprima
/// sono riproducibili.
class StesaTreCarteScreen extends StatefulWidget {
  const StesaTreCarteScreen({
    super.key,
    this.seed,
    this.revealAll = false,
    this.topic,
    this.skipIntro = false,
  });

  /// L'argomento di partenza. Se nullo si parte da quello predefinito, la
  /// lettura generale. Serve all'anteprima e, in futuro, al deep link che
  /// arriva gia' con la domanda scelta.
  final TarotTopic? topic;

  /// Seme del pescaggio. Se nullo, ogni apertura e' una stesa nuova.
  final int? seed;

  /// Per l'anteprima e i test: parte con le tre carte gia' rivelate.
  final bool revealAll;

  /// Salta il bianco iniziale, quando la schermata si apre senza intro.
  ///
  /// L'intro cinematografica finisce in bianco pieno e la scena parte da li'
  /// per coprire il taglio. Arrivando da altrove quel bianco sarebbe un lampo
  /// senza motivo, quindi si salta: e' anche il modo in cui girano i test e
  /// l'anteprima.
  final bool skipIntro;

  static Route<void> route({int? seed}) => MaterialPageRoute<void>(
        builder: (_) => SogliaArte(id: 'tarot_spread_three', maestro: Maestro.medora, child: StesaTreCarteScreen(seed: seed)),
      );

  @override
  State<StesaTreCarteScreen> createState() => StesaTreCarteScreenState();
}

/// Lo stato della Stesa. **Pubblico apposta**: le prove della voce 05 devono
/// poter chiedere in che fase del taglio si trova la scena, e dedurlo dai pixel
/// vorrebbe dire misurare l'effetto invece della causa.
class StesaTreCarteScreenState extends State<StesaTreCarteScreen>
    with TickerProviderStateMixin {
  /// L'ORDINE DEL MAZZO, che i gesti cambiano davvero.
  ///
  /// **Ordine 2171 voce 6.** Fino al 10 agosto 2026 Taglia e Mischia
  /// lanciavano un'animazione e basta: la stesa restava quella pescata
  /// all'apertura, qualunque cosa facesse la persona. Un gesto che non tocca
  /// il risultato non e' un rito, e' una decorazione.
  late List<int> _mazzo = TarotSpread.mazzoMescolato(seed: widget.seed);

  /// Il seme che decide i versi: resta quello della stesa, cosi' lo stesso
  /// ordine da' sempre la stessa lettura.
  late final int _seme = widget.seed ?? 0;

  /// LA STESA IN CORSO, ordine P voce 04: le carte assegnate sono un DATO e
  /// non una funzione del mazzo. Prima qui c'era
  /// `TarotSpread.dalMazzo(_mazzo)`, ricalcolata dopo ogni gesto: le prime tre
  /// del mazzo corrente diventavano la stesa, quindi mischiando cambiavano le
  /// carte gia' scelte dalla persona. La legge del dominio vive in
  /// `StesaInCorso`.
  late StesaInCorso _stesa = _stesaIniziale();

  /// LA STESA DI PARTENZA, e con [StesaTreCarteScreen.revealAll] e' gia' fatta.
  ///
  /// **Difetto trovato dalla voce 10 e chiuso qui.** Con `revealAll` le tre
  /// posizioni restavano NON assegnate: la schermata mostrava le prime tre del
  /// mazzo residuo passando dal ripiego di [_spread], che costruisce le carte
  /// con `reversed: false`. Cioe' in anteprima e nelle prove nessuna carta
  /// usciva mai rovesciata, mentre nell'app vera una su tre lo e'. La cattura
  /// `stesa-tre-carte.png` era stata scelta apposta perche' portava due
  /// rovesciate, e da un pezzo non ne portava piu' nessuna.
  ///
  /// Adesso `revealAll` assegna davvero, passando dalla legge del dominio: le
  /// carte escono dal mazzo residuo ed entrano nella stesa col verso che
  /// `StesaInCorso` gli da', che e' lo stesso dell'app vera.
  StesaInCorso _stesaIniziale() {
    var stesa = StesaInCorso.nuova(mazzo: _mazzo, seme: _seme);
    if (!widget.revealAll) return stesa;
    // Ordine BN voce 02: si assegnano le prime posizioni dell'arco, e non tre
    // volte la posizione zero, che dalla cura non esiste piu' dopo la prima.
    for (var i = 0; i < SpreadPosition.values.length; i++) {
      stesa = stesa.assegna(SpreadPosition.values[i], dalVentaglio: i);
    }
    return stesa;
  }

  /// Le carte gia' assegnate, per le parti della schermata che le leggono.
  TarotSpread get _spread => TarotSpread([
        for (var i = 0; i < SpreadPosition.values.length; i++)
          _stesa.assegnate[i] ??
              DrawnCard(
                card: TarotDeck.cards[_stesa.mazzoResiduo.isEmpty
                    ? 0
                    : _stesa.mazzoResiduo[
                        i % _stesa.mazzoResiduo.length]],
                position: SpreadPosition.values[i],
                reversed: false,
              ),
      ]);

  /// LE TRE CARTE CHE IL MAZZO HA IN CIMA IN QUESTO MOMENTO.
  ///
  /// Serve alle prove: a ventaglio coperto i nomi non sono ancora a schermo,
  /// e senza questa finestra l'unico modo di sapere se Mischia ha davvero
  /// mosso il mazzo sarebbe scoprire le carte, cioe' finire il rito.
  @visibleForTesting
  TarotSpread get stesaCorrente => _spread;

  // --- La regia della scena ---

  /// La scena corrente. Ogni scena sa cosa mostrare e quali gesti accettare.
  late StesaScene _scene =
      widget.revealAll ? StesaScene.completa : StesaScene.handoff;

  late final AnimationController _handoff = AnimationController(
      vsync: this, duration: StesaTiming.handoff);
  late final AnimationController _ingresso = AnimationController(
      vsync: this, duration: StesaTiming.ingresso);
  late final AnimationController _respiro = AnimationController(
      vsync: this, duration: StesaTiming.respiro);
  late final AnimationController _taglio = AnimationController(
      vsync: this, duration: StesaTiming.taglio);
  late final AnimationController _mescola = AnimationController(
      vsync: this, duration: StesaTiming.mescolamento);
  late final AnimationController _volo = AnimationController(
      vsync: this, duration: StesaTiming.volo);

  /// Se il pannello dei selettori e' aperto. Parte richiuso, cosi' il
  /// ventaglio resta a portata senza scorrere oltre la configurazione.
  bool _setupAperto = false;

  /// Dove il mazzo e' stato tagliato l'ultima volta, IN INDICI DI CARTA del
  /// mazzo intero.
  ///
  /// **L'unita' e' dichiarata perche' prima erano due, e il gesto ne moriva.**
  /// Questo numero viveva fra 2 e 7, contato su `TarotSpread.fanSize`, cioe' su
  /// quante carte si pescano; il ventaglio invece lo confronta con gli indici
  /// delle settantotto. Il punto di taglio cadeva quindi sempre fuori dalla
  /// finestra che si vede, tutte le carte a schermo finivano dalla stessa parte
  /// del taglio, e le due meta' non si dividevano mai: a video si vedeva un
  /// blocco unico spostarsi e rientrare. Il difetto e' stato trovato
  /// GUARDANDO le quattro anteprime del taglio, non da una misura: la prova
  /// della voce 05 interrogava `TaglioPose` con indici scelti a mano, e da quel
  /// lato tutto tornava.
  int _taglioIndice = TarotDeck.cards.length ~/ 2;

  /// Quante volte si e' tagliato, per far variare il punto senza allontanarlo
  /// dalla meta'.
  int _tagliFatti = 0;

  /// GLI SCOSTAMENTI DAL CENTRO, in carte.
  ///
  /// Un taglio vero si fa verso la meta' del mazzo, e la meta' e' anche dove il
  /// ventaglio e' centrato: un punto a due carte dal fondo sarebbe legittimo nel
  /// dato e invisibile a schermo. Restando qui, la divisione si vede sempre.
  static const List<int> _scostamentiDelTaglio = [0, 3, -2, 5, -4];

  /// La carta del ventaglio che sta volando verso il suo slot.
  int? _inVolo;

  /// Suono e vibrazione, dietro un solo interruttore di silenzio.
  final SensiDellaStesa _sensi = SensiDellaStesa();

  /// L'interruttore di silenzio, che governa suono e vibrazione insieme.
  bool _silenzio = false;

  /// L'inclinazione delle carte posate, dal giroscopio. Senza sensore le
  /// carte restano ferme e composte, senza errori.
  final TiltListener _tilt = TiltListener();

  /// L'aura elementale della carta appena scoperta.
  late final AnimationController _reveal = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100));

  /// Quale posizione sta fiorendo, e con quale resa.
  int? _revealSlot;
  RevealSpec? _revealSpec;

  /// Il galleggiamento lento delle carte posate.
  late final AnimationController _galleggio = AnimationController(
      vsync: this, duration: const Duration(seconds: 6));

  /// Lo scuotimento del telefono, quando c'e' l'accelerometro.
  AscoltatoreScuotimento? _shake;

  /// Vero quando le animazioni di sistema sono spente: tutto arriva subito
  /// allo stato finale, senza moto.
  bool _reduceMotion = false;

  bool _avviata = false;

  /// QUALE FASE DEL TAGLIO E' IN SCENA QUANDO IL MOTO E' SPENTO.
  ///
  /// Con Riduci Movimento il taglio non scorre: si ferma sui quattro centri di
  /// fase, uno alla volta, con una dissolvenza fra l'uno e l'altro. Nullo
  /// quando il taglio scorre, perche' in quel caso la fase si legge dal tempo.
  int? _faseStatica;

  /// Il velo della dissolvenza fra due stati del taglio fermo.
  bool _statoInPiena = true;

  /// In che fase del taglio si trova la scena, da 0 a 3, oppure nullo se il
  /// taglio non e' in corso.
  @visibleForTesting
  int? get faseDelTaglioInScena => _scene != StesaScene.taglio
      ? null
      : (_faseStatica ?? TaglioFasi.faseAl(_taglio.value));

  /// DOVE SI STA TAGLIANDO, in indici di carta del mazzo intero.
  ///
  /// Serve alle prove per chiedere la cosa che conta: che le carte montate a
  /// schermo stiano da TUTTE E DUE le parti del taglio. Se stessero tutte dalla
  /// stessa, la divisione sarebbe un blocco unico che si sposta, ed e' il difetto
  /// che l'anteprima ha mostrato.
  @visibleForTesting
  int get puntoDelTaglio => _taglioIndice;

  /// L'INCLINAZIONE TENUTA FERMA durante un gesto del mazzo. Nulla fuori dal
  /// gesto, quando l'inclinazione la decide il giroscopio.
  Offset? _tiltFermo;

  /// FERMA L'AMBIENTE ATTORNO ALLE CARTE GIA' USCITE. Ordine P voce 05.
  ///
  /// **Le carte gia' estratte non partecipano al gesto: restano nelle loro
  /// posizioni, immobili, per tutta l'animazione.** Il galleggiamento e
  /// l'inclinazione dal giroscopio sono effetti d'ambiente, e su una carta gia'
  /// uscita durante il taglio diventavano un movimento che contraddice cio' che
  /// il taglio deve dire, cioe' che quella carta e' fuori dal mazzo e nessun
  /// gesto la tocca piu'.
  ///
  /// **Si FERMA dove sta, non si azzera.** Azzerarlo avrebbe fatto scattare la
  /// carta di due punti nell'istante in cui il gesto comincia, cioe' avrebbe
  /// sostituito un movimento lento con uno scatto secco. Misurato: 2,2 punti.
  void _fermaLAmbiente() {
    _galleggio.stop();
    _tiltFermo = Offset(_tilt.x, _tilt.y);
  }

  /// Riprende il galleggiamento quando il gesto e' finito.
  void _riprendiLAmbiente() {
    _tiltFermo = null;
    if (!_reduceMotion) _galleggio.repeat();
  }

  /// L'ATTESA DI MEDORA, fra l'ultima carta e il primo responso. Voce 06.
  StatoDellAttesa _attesa = StatoDellAttesa.assente;

  /// Vero quando il responso puo' stare a schermo: la stesa e' compiuta e
  /// Medora non la sta piu' coprendo. In dissolvenza il responso c'e' gia',
  /// sotto il velo che se ne va.
  bool get _responsoInScena =>
      _complete && _attesa != StatoDellAttesa.piena;

  /// Quante stese sono state chiuse in questa sessione: sposta il punto di
  /// partenza delle righe dell'attesa, cosi' due stese vicine non aprono sulla
  /// stessa frase.
  int _giroDellAttesa = 0;

  /// Quante carte sono gia' state pescate, da 0 a 3.
  late int _drawn = widget.revealAll ? SpreadPosition.values.length : 0;

  /// Quali carte del ventaglio sono gia' state prese.
  final Set<int> _taken = {};

  final GlobalKey _cardKey = GlobalKey();
  bool _sharing = false;
  bool _renderCard = false;

  /// I selettori prima della stesa. Le voci non pronte restano Coming soon.
  late TarotSetup _setup = TarotSetup(
      topic: widget.topic ?? TarotTopic.predefinito);

  /// La lettura a sette strati, letta dentro l'argomento scelto. E'
  /// deterministica: stesse carte e stesso argomento danno sempre lo stesso
  /// testo, quindi si puo' mettere in cache senza toccare l'LLM.
  TarotReading get _reading =>
      TarotReading.of(_spread, _setup.topic, depth: _setup.depth);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_avviata) return;
    _avviata = true;
    _shake = AscoltatoreScuotimento(onScuotimento: _mischia)..start();
    // Il giroscopio e il galleggiamento solo se il moto e' concesso: con
    // Riduci Movimento le carte stanno ferme e composte.
    if (!_reduceMotion) {
      _tilt.start();
      _galleggio.repeat();
    }
    _apriScena();
  }

  /// L'apertura: dal bianco dell'intro alla scena viva, poi le carte che
  /// nascono dal cosmo.
  Future<void> _apriScena() async {
    if (widget.revealAll) {
      // La stesa e' gia' fatta: nessuna coreografia da suonare.
      _handoff.value = 1;
      _ingresso.value = 1;
      return;
    }
    if (_reduceMotion) {
      // Riduci Movimento: si arriva subito alla posa di riposo.
      _handoff.value = 1;
      _ingresso.value = 1;
      if (mounted) setState(() => _scene = StesaScene.riposo);
      return;
    }
    if (widget.skipIntro) {
      _handoff.value = 1;
    } else {
      setState(() => _scene = StesaScene.handoff);
      await _handoff.forward();
      if (!mounted) return;
    }
    setState(() => _scene = StesaScene.ingresso);
    await _ingresso.forward();
    if (!mounted) return;
    setState(() => _scene = StesaScene.riposo);
    _respiro.repeat();
  }

  /// IL TAGLIO, che taglia davvero.
  ///
  /// La coreografia e' quella approvata nelle Decisioni del 3 agosto 2026: il
  /// ventaglio si ricompone in mazzo, il mazzo si divide in due, il taglio si
  /// ricompone, le carte si ristendono a partire dal mazzo.
  ///
  /// **E l'ordine cambia per davvero**: la meta' sotto sale sopra, quindi le
  /// tre carte che si pescheranno sono altre. Con Riduci Movimento il taglio
  /// avviene lo stesso, senza il volo: chi ha tolto le animazioni non perde
  /// il gesto, perde solo il moto.
  Future<void> _taglia() async {
    if (!_scene.accettaGesti) return;
    _sensi.momento(MomentoSensoriale.taglio);
    _fermaLAmbiente();
    setState(() {
      _scene = StesaScene.taglio;
      // Il punto di taglio cambia a ogni gesto e resta vicino alla meta', che e'
      // dove il mazzo si taglia davvero e dove il ventaglio guarda.
      _tagliFatti++;
      _taglioIndice = (TarotDeck.cards.length ~/ 2) +
          _scostamentiDelTaglio[_tagliFatti % _scostamentiDelTaglio.length];
    });
    if (_reduceMotion) {
      await _taglioAQuattroStati();
      if (!mounted) return;
    } else {
      await _taglio.forward(from: 0);
      if (!mounted) return;
    }
    _taglio.value = 0;
    setState(() {
      _faseStatica = null;
      _statoInPiena = true;
      // Il punto vero del taglio nel mazzo intero, non nel solo ventaglio:
      // tagliare nove carte su settantotto sarebbe un taglio finto.
      //
      // **Non c'e' piu' nessuna conversione**, e non serviva: il numero E' GIA'
      // un indice di carta. La moltiplicazione che stava qui era la stessa
      // confusione di unita' che rendeva invisibile la divisione a schermo, solo
      // vista dall'altro lato.
      final punto = _taglioIndice;
      // IL TAGLIO TOCCA SOLO IL MAZZO RESIDUO: le carte gia' uscite restano
      // dove sono, ed e' anche il modo visivo di dirlo alla persona.
      _stesa = _stesa.taglia(punto);
      _mazzo = List<int>.of(_stesa.mazzoResiduo);
      _scene = StesaScene.riposo;
    });
    _riprendiLAmbiente();
  }

  /// IL TAGLIO CON RIDUCI MOVIMENTO: quattro stati, non zero.
  ///
  /// **Ordine P voce 05.** Prima con Riduci Movimento il taglio saltava
  /// l'animazione per intero: le quattro fasi non diventavano quattro stati
  /// statici, diventavano niente, e chi ha chiesto di non vedere movimento
  /// perdeva il racconto del gesto. Riduci Movimento non toglie mai contenuto.
  ///
  /// La scena si ferma sul centro di ogni fase per la durata dichiarata di
  /// quella fase, e fra un fermo e l'altro passa una dissolvenza breve: nessuna
  /// carta scorre da un punto all'altro, cioe' non c'e' moto, ma tutti e quattro
  /// i momenti si vedono.
  Future<void> _taglioAQuattroStati() async {
    for (var fase = 0; fase < TaglioFasi.fasi.length; fase++) {
      if (!mounted) return;
      setState(() {
        _faseStatica = fase;
        _taglio.value = TaglioFasi.centroDi(fase);
        _statoInPiena = true;
      });
      final tenuta =
          TaglioFasi.fasi[fase].durata - TaglioFasi.dissolvenzaFraStati;
      await Future<void>.delayed(
          tenuta.isNegative ? Duration.zero : tenuta);
      if (!mounted) return;
      setState(() => _statoInPiena = false);
      await Future<void>.delayed(TaglioFasi.dissolvenzaFraStati);
    }
  }

  /// Il mescolamento a vortice, da scuotimento o dal tasto.
  Future<void> _mischia() async {
    if (!mounted || !_scene.accettaGesti) return;
    _sensi.momento(MomentoSensoriale.mescolamento);
    _fermaLAmbiente();
    setState(() => _scene = StesaScene.mescolamento);
    if (!_reduceMotion) {
      await _mescola.forward(from: 0);
      if (!mounted) return;
    }
    _mescola.value = 0;
    setState(() {
      // **IL MAZZO SI MESCOLA DAVVERO.** Senza questa riga il vortice era una
      // bella animazione sopra un mazzo immobile, e le tre carte restavano
      // quelle di prima: e' il difetto che Mauro e Dora hanno segnalato.
      // LA MISCHIA TOCCA SOLO IL MAZZO RESIDUO, per la stessa ragione.
      _stesa = _stesa.mischia();
      _mazzo = List<int>.of(_stesa.mazzoResiduo);
      _scene = StesaScene.riposo;
    });
    _riprendiLAmbiente();
  }

  @override
  void dispose() {
    _tilt.dispose();
    _reveal.dispose();
    _galleggio.dispose();
    _shake?.dispose();
    _handoff.dispose();
    _ingresso.dispose();
    _respiro.dispose();
    _taglio.dispose();
    _mescola.dispose();
    _volo.dispose();
    super.dispose();
  }

  /// L'ultima carta scoperta: e' quella su cui Medora posa lo sguardo.
  DrawnCard? get _active => _drawn == 0 ? null : _spread.cards[_drawn - 1];

  bool get _complete => _drawn >= SpreadPosition.values.length;

  /// La scelta: la carta si stacca dal ventaglio, vola nel suo slot con una
  /// scia di stelle, poi il flip la gira sulla faccia.
  Future<void> _pick(int fanIndex) async {
    if (_complete || _taken.contains(fanIndex)) return;
    if (!_scene.accettaGesti) return;
    _sensi.momento(MomentoSensoriale.volo);
    setState(() {
      _taken.add(fanIndex);
      _inVolo = fanIndex;
    });
    if (!_reduceMotion) {
      await _volo.forward(from: 0);
      if (!mounted) return;
    }
    final slot = _drawn;
    setState(() {
      _inVolo = null;
      // LA CARTA SI ASSEGNA QUI, e da questo momento e' immutabile: esce dal
      // mazzo residuo ed entra nella stesa.
      // **LA POSIZIONE TOCCATA E' LA CARTA, ordine BN voce 02.** Prima qui
      // passava l'indice del ventaglio come indice del mazzo RESIDUO, che e'
      // un'altra lista: gli indici slittavano a ogni presa, mischia e taglio
      // riordinavano il residuo sotto posizioni ferme, e oltre la lunghezza
      // si ripiegava sulla prima carta del mazzo.
      _stesa =
          _stesa.assegna(SpreadPosition.values[slot], dalVentaglio: fanIndex);
      _mazzo = List<int>.of(_stesa.mazzoResiduo);
      _drawn++;
      if (_complete) _scene = StesaScene.completa;
    });
    // LA STESA ENTRA NEL CAMMINO, ordine P voce 35. Qui, e non all'apertura
    // della scena: una scena si apre anche per sbaglio, una stesa COMPIUTA
    // no. Prima di questa voce la stesa non compariva in nessuno dei quattro
    // commit dell'ordine O, quindi non registrava niente e nessun traguardo
    // dei tarocchi poteva accendersi, ne' con tre stese ne' con trecento.
    if (_complete) {
      // **IL GESTO PORTA CIO' CHE LA SCENA SA, ordine AR voce 11.** Nel
      // momento in cui la stesa e' completa questa scena ha in mano le tre
      // carte uscite e l'argomento scelto: sono i dettagli che le condizioni
      // di profondita' e coincidenza chiedono (tutti e quattro i semi, la
      // stessa carta in due stese, i sedici argomenti del ventaglio). Non si
      // va a cercare niente altrove: e' tutto qui, gia' pronto.
      final carte = _spread.cards;
      unawaited(RegiaDelCammino.dopoUnGesto(
        context,
        'stesa',
        dettagli: {
          'carte': [for (final c in carte) c.card.stem],
          'semi': [
            for (final c in carte)
              if (c.card.seme != null) c.card.seme!.name,
          ],
          'maggiori': [
            for (final c in carte)
              if (c.card.arcana == TarotArcana.maggiore) c.card.stem,
          ],
          'argomento': (widget.topic ?? TarotTopic.predefinito).name,
        },
      ));
      // LA DOMANDA SI SALVA, ordine P voce 09 e voce 18.
      //
      // **Senza questo la domanda e' un finale carino che nessuno ricorda.** La
      // domanda esiste perche' e' cio' che riporta la persona domani: ricompare
      // nel dono del mattino successivo con la formula "Ieri Medora ti ha
      // lasciato questa domanda".
      unawaited(FiloDelGiorno.segnaLaDomanda(_reading.domanda, DateTime.now()));
    }
    // Il flip, poi la fioritura dell'elemento: la carta si scopre e il suo
    // seme parla un istante, prima di lasciarla pulita e leggibile.
    _sensi.momento(MomentoSensoriale.flip);
    await _fiorisci(slot);
    // MEDORA CI PENSA, ordine P voce 06: solo alla TERZA carta, perche' e' li'
    // che il responso comincia, e prima non c'e' niente da guardare insieme.
    if (_complete) await _medoraCiPensa();
  }

  /// L'ATTESA FRA L'ULTIMA CARTA E IL PRIMO RESPONSO. Ordine P voce 06.
  ///
  /// I responsi apparivano di colpo, e un responso istantaneo e' un responso
  /// letto da un archivio. La scena resta il minimo garantito di
  /// [AttesaDiMedora], che sono i tempi gia' approvati per il consulto e non una
  /// seconda copia loro, poi si dissolve.
  ///
  /// Non puo' restare a girare: la lettura e' deterministica e locale, quindi
  /// non aspetta nessuna rete, e cio' che la chiude e' il suo stesso minimo.
  Future<void> _medoraCiPensa() async {
    if (!mounted) return;
    setState(() {
      _attesa = StatoDellAttesa.piena;
      _giroDellAttesa++;
    });
    await Future<void>.delayed(
        AttesaDiMedora.minimaPer(riduciMovimento: _reduceMotion));
    if (!mounted) return;
    // La scena non sparisce di colpo: si dissolve, e il responso e' gia' sotto
    // di lei quando comincia a sparire. Nessuna parola viene tagliata.
    setState(() => _attesa = StatoDellAttesa.inUscita);
    await Future<void>.delayed(AttesaDiMedora.dissolvenza);
    if (!mounted) return;
    setState(() => _attesa = StatoDellAttesa.assente);
  }

  /// L'aura elementale della carta appena scoperta.
  ///
  /// Con Riduci Movimento non c'e' nessun moto: la carta appare gia' composta,
  /// e il momento sensoriale resta comunque, perche' il silenzio ha il suo
  /// interruttore e non si spegne col movimento.
  Future<void> _fiorisci(int slot) async {
    if (slot < 0 || slot >= _spread.cards.length) return;
    final spec = RevealSpec.of(_spread.cards[slot].card);
    _sensi.momento(MomentoSensoriale.reveal, solenne: spec.solenne);
    if (_reduceMotion) return;
    setState(() {
      _revealSlot = slot;
      _revealSpec = spec;
    });
    _reveal.duration = spec.durata;
    await _reveal.forward(from: 0);
    if (!mounted) return;
    // Finita la fioritura non resta nulla sopra la carta.
    setState(() {
      _revealSlot = null;
      _revealSpec = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // La stesa e' di Medora: blu e oro suoi, sempre.
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        // Il titolo legge il nome della stesa attiva: e' un dato della sua
        // definizione, non una stringa scritta qui. Quando arriveranno le
        // stese da sette e dieci carte il titolo cambiera' da solo.
        // **IL TITOLO NON SI ROMPE**, ordine S voce 05: a capo fra le
        // parole, la misura scende solo quanto serve, e non si tronca mai.
        // Col borsellino nella riga delle azioni lo spazio del titolo si e'
        // ristretto, e un `Text` nudo qui torna a mettere i puntini.
        title: TitoloCheNonSiRompe(
            chiaveDelTesto: const Key('stesa_titolo'),
            testo: _setup.tipo.nome,
            stile: TypographyTokens.titoloSezione()),
        // IL BORSELLINO, ordine S voce 06: stesso segno, stesso angolo, in
        // ogni schermata della pratica. Un saldo che appare e scompare non
        // si impara.
        actions: const [AngoloDellaBarra()],
      ),
      body: CosmosBackground(
        seed: 19,
        showZodiac: false,
        child: SafeArea(
          child: Stack(
            children: [
              _content(palette),
              // Il bianco con cui l'intro passa la mano: sta sopra la scena e
              // dissolve, cosi' il taglio fra video e app non si vede.
              AnimatedBuilder(
                animation: _handoff,
                builder: (context, _) => HandoffVeil(
                  key: const Key('stesa_handoff'),
                  opacity: 1 - _handoff.value,
                ),
              ),
              // La carta che vola dal ventaglio al suo slot, con la scia.
              if (_inVolo != null)
                AnimatedBuilder(
                  animation: _volo,
                  builder: (context, _) => _CartaInVolo(
                    key: const Key('stesa_volo'),
                    progress: _volo.value,
                    destinazione: _drawn,
                    palette: palette,
                    seed: _inVolo!,
                  ),
                ),
              // MEDORA CI PENSA, ordine P voce 06. Sta sopra la scena e sotto
              // il velo dell'intro: e' l'ultima cosa che si vede prima del
              // responso.
              if (_attesa.inScena)
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: _attesa == StatoDellAttesa.piena ? 1 : 0,
                    duration: AttesaDiMedora.dissolvenza,
                    child: AttesaDiMedora(
                      palette: palette,
                      riduciMovimento: _reduceMotion,
                      rotazione: _giroDellAttesa,
                    ),
                  ),
                ),
              if (_renderCard)
                Positioned(
                  left: -3000,
                  top: 0,
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: StesaShareCard(
                      spread: _spread,
                      palette: palette,
                      topic: _setup.topic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// I tre slot Passato Presente Futuro.
  ///
  /// Stanno sopra il ventaglio mentre si pesca e sopra la lettura quando la
  /// stesa e' fatta: e' lo stesso blocco, cambia solo dove si trova.
  Widget _slots(MaestroPalette palette) {
    return AnimatedBuilder(
      animation: Listenable.merge([_reveal, _galleggio, _tilt]),
      builder: (context, _) => _slotsRow(palette),
    );
  }

  Widget _slotsRow(MaestroPalette palette) {
    return Row(
      key: const Key('stesa_slots'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < SpreadPosition.values.length; i++) ...[
          Expanded(
            child: _Slot(
              position: SpreadPosition.values[i],
              drawn: i < _drawn ? _spread.cards[i] : null,
              palette: palette,
              revealSpec: _revealSlot == i ? _revealSpec : null,
              revealProgress: _revealSlot == i ? _reveal.value : 0,
              // DURANTE UN GESTO DEL MAZZO LE CARTE USCITE SONO IMMOBILI.
              //
              // Ordine P voce 05: il galleggiamento e l'inclinazione sono
              // effetti d'ambiente, e mentre il mazzo si taglia diventavano un
              // movimento che contraddice il senso del gesto. Le carte gia'
              // estratte non partecipano, ed e' il modo visivo di dire cio' che
              // la voce 04 dice nel dato.
              tiltX: _tiltFermo?.dx ?? _tilt.x,
              tiltY: _tiltFermo?.dy ?? _tilt.y,
              galleggio: _reduceMotion
                  ? 0
                  : TiltListener.fluttuazioneDi(i, _galleggio.value),
            ),
          ),
          if (i < SpreadPosition.values.length - 1)
            const SizedBox(width: SpacingTokens.xs),
        ],
      ],
    );
  }

  Widget _content(MaestroPalette palette) {
    return ListView(
      key: const Key('stesa_list'),
      // Sopra Medora c'era una fascia vuota che sprecava la parte migliore
      // dello schermo: il margine alto ora e' appena quello che serve a non
      // finire sotto la barra del titolo.
      padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.xs,
          SpacingTokens.lg, SpacingTokens.lg),
      children: [
        // Medora presiede la stesa. Finche' si pesca sta piu' raccolta: il
        // protagonista in quel momento e' il ventaglio interattivo, e il
        // ventaglio che lei tiene in mano deve restare un dettaglio del
        // ritratto, non un secondo invito in gara col primo.
        MedoraStage(
          palette: palette,
          active: _active,
          height: _complete ? 300 : 170,
          bustoFactor: _complete ? MedoraStage.bustoPieno : 0.34,
          bustoLarghezza: _complete ? 1.0 : 0.72,
        ),
        const SizedBox(height: SpacingTokens.sm),
        // La configurazione, richiusa nella sua riga di riepilogo.
        if (!_complete) ...[
          TarotSetupPanel(
            setup: _setup,
            palette: palette,
            aperto: _setupAperto,
            onToggle: () => setState(() => _setupAperto = !_setupAperto),
            onChanged: (s) => setState(() => _setup = s),
            onLocked: _showComingSoon,
          ),
          const SizedBox(height: SpacingTokens.sm),
        ],
        // Mentre si pesca, gli slot stanno appena SOPRA il ventaglio: cosi'
        // partenza e arrivo del volo sono nello stesso campo visivo e la carta
        // non vola mai verso uno slot fuori schermo.
        if (!_complete) ...[
          _slots(palette),
          const SizedBox(height: SpacingTokens.sm),
          // IL TESTO DELLE CARTE GIA' USCITE, A PIENA LARGHEZZA.
          //
          // **Ordine P voce 10, ed e' qui che il difetto si vedeva peggio.**
          // Con una carta sola scelta, il nome e la sintesi stavano nella
          // colonna della miniatura, cioe' un terzo dello schermo, mentre alla
          // loro destra due terzi restavano vuoti: "L'onda / trattenuta."
          // occupava due righe senza nessun motivo.
          if (_drawn > 0) ...[
            _BloccoDelleCarte(
              key: const Key('stesa_blocco_carte'),
              carte: _spread.cards.take(_drawn).toList(),
              palette: palette,
            ),
            const SizedBox(height: SpacingTokens.sm),
          ],
        ],
        // Colpo d'occhio: il ventaglio coperto, finche' restano carte da pescare.
        if (!_complete) ...[
          Text(
            _drawn == 0
                ? 'Scegli tre carte dal ventaglio'
                : 'Scegli ancora ${SpreadPosition.values.length - _drawn}',
            key: const Key('stesa_prompt'),
            textAlign: TextAlign.center,
            style: TypographyTokens.etichetta().copyWith(
                color: ColorTokens.textSecondary, letterSpacing: 1.2),
          ),
          const SizedBox(height: SpacingTokens.md),
          // Il ventaglio con la sua regia: ingresso a spirale, respiro,
          // taglio e vortice. Si ridisegna col battito delle quattro fasi.
          AnimatedBuilder(
            animation: Listenable.merge(
                [_ingresso, _respiro, _taglio, _mescola]),
            // LA DISSOLVENZA FRA I QUATTRO STATI DEL TAGLIO FERMO.
            //
            // Vale solo con Riduci Movimento: fuori da quel caso
            // `_statoInPiena` resta vero e questa opacita' non si muove mai.
            builder: (context, _) => AnimatedOpacity(
              opacity: _statoInPiena ? 1 : 0.15,
              duration: TaglioFasi.dissolvenzaFraStati,
              child: StesaFan(
                palette: palette,
                taken: _taken,
                onPick: _pick,
                scene: _scene,
                ingresso: _ingresso.value,
                respiro: _respiro.value,
                taglio: _taglio.value,
                mescolamento: _mescola.value,
                taglioIndice: _taglioIndice,
                reduceMotion: _reduceMotion,
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          // I gesti del mazzo. Lo scuotimento e' un di piu': questi tasti ci
          // sono sempre, cosi' chi non ha l'accelerometro non resta fuori.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GestoMazzo(
                key: const Key('stesa_taglia'),
                icona: Icons.content_cut_rounded,
                label: 'Taglia',
                palette: palette,
                attivo: _scene.accettaGesti,
                onTap: _taglia,
              ),
              const SizedBox(width: SpacingTokens.sm),
              _GestoMazzo(
                key: const Key('stesa_mischia'),
                icona: Icons.casino_rounded,
                label: 'Mischia',
                palette: palette,
                attivo: _scene.accettaGesti,
                onTap: _mischia,
              ),
              const SizedBox(width: SpacingTokens.sm),
              // Un solo interruttore per suono e vibrazione: chi zittisce
              // l'app non si aspetta di sentirla ancora vibrare in mano.
              _GestoMazzo(
                key: const Key('stesa_silenzio'),
                icona: _silenzio
                    ? Icons.volume_off_rounded
                    : Icons.volume_up_rounded,
                label: _silenzio ? 'Muto' : 'Suono',
                palette: palette,
                attivo: true,
                onTap: () => setState(() {
                  _silenzio = !_silenzio;
                  _sensi.silenzio = _silenzio;
                }),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _shake?.attivo ?? false
                ? 'Scuoti il telefono per mischiare'
                : 'Tocca Mischia per mescolare il mazzo',
            key: const Key('stesa_suggerimento_gesto'),
            textAlign: TextAlign.center,
            style: TypographyTokens.etichetta().copyWith(
                color: ColorTokens.textSecondary, letterSpacing: 0.8),
          ),
          const SizedBox(height: SpacingTokens.lg),
        ],
        // La sintesi memorabile, sopra le tre carte.
        if (_responsoInScena) ...[
          Text(_reading.sintesi,
              key: const Key('stesa_synthesis'),
              textAlign: TextAlign.center,
              style: TypographyTokens.titoloSezione()
                  .copyWith(color: palette.goldSoft, height: 1.25)),
          const SizedBox(height: SpacingTokens.md),
        ],
        if (_responsoInScena) _slots(palette),
        if (_responsoInScena) ...[
          const SizedBox(height: SpacingTokens.sm),
          // IL BLOCCO DELLE CARTE A PIENA LARGHEZZA, ordine P voce 10.
          _BloccoDelleCarte(
            key: const Key('stesa_blocco_carte'),
            carte: _spread.cards,
            palette: palette,
          ),
          const SizedBox(height: SpacingTokens.lg),
          // IL CONSIGLIO E' LA PRIMA COSA CHE SI LEGGE, ordine P voce 09.
          //
          // Stava in fondo, dopo il dialogo e la carta chiave, ed era la piu'
          // corta delle tre. E' la bolla che la persona porta via: adesso apre
          // il responso, e' la piu' lunga, e finisce con la domanda invece di
          // lasciarla a una bolla sua.
          _Strato(
            key: const Key('stesa_consiglio'),
            titolo: 'Il consiglio di Medora',
            testo: _reading.consiglio,
            palette: palette,
            inEvidenza: true,
          ),
          const SizedBox(height: SpacingTokens.lg),
          // Le tre posizioni col testo ricco letto nell'argomento. La lente sta
          // qui una volta sola: ripeterla su ogni posizione la rendeva una
          // formula.
          Text('${_reading.posizioni.first.apertura}, carta per carta',
              key: const Key('stesa_lente'),
              style: TypographyTokens.etichetta().copyWith(
                  color: palette.goldSoft.withValues(alpha: 0.9),
                  letterSpacing: 1.2)),
          const SizedBox(height: SpacingTokens.xs),
          for (final letta in _reading.posizioni) ...[
            BollaDellaPosizione(
              key: Key('stesa_letta_${letta.drawn.position.name}'),
              letta: letta,
              palette: palette,
              // LA BOLLA CHIAVE E' UNA DI QUESTE TRE, ordine P voce 07.
              perche: letta.drawn.position == _reading.chiave.drawn.position
                  ? _reading.chiave.perche
                  : null,
            ),
            const SizedBox(height: SpacingTokens.sm),
          ],
          const SizedBox(height: SpacingTokens.sm),
          Text(TarotSpread.closing,
              key: const Key('stesa_closing'),
              textAlign: TextAlign.center,
              style: TypographyTokens.didascalia().copyWith(
                  color: palette.goldSoft,
                  height: 1.4,
                  fontStyle: FontStyle.italic)),
          const SizedBox(height: SpacingTokens.lg),
          Center(
            child: FilledButton.icon(
              key: const Key('stesa_share'),
              onPressed: _sharing ? null : _onShare,
              style: FilledButton.styleFrom(
                backgroundColor: palette.gold,
                foregroundColor: palette.deepest,
                padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.xl, vertical: SpacingTokens.sm),
              ),
              icon: _sharing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.ios_share_rounded, size: 18),
              label: Text(
              _sharing
                  ? 'Preparo la card'
                  : PremioDellaCondivisione.etichetta(context),
                  style: TypographyTokens.etichetta()
                      .copyWith(letterSpacing: 0.6)),
            ),
          ),
        ],
            // IL DISCLAIMER E' USCITO DA QUI, ed era uno di SETTE.
            //
            // Le linee guida dicevano da sempre "una volta sola", e per
            // sette volte ognuno ha pensato che il proprio fosse quella
            // volta. Un disclaimer ripetuto smette di essere letto e
            // diventa un modo di scaricare la responsabilita' invece di
            // dirla. Adesso sta in un posto solo, nell'area privacy.
      ],
    );
  }

  void _showComingSoon(String voce) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$voce arriva presto nel Cerchio.')),
    );
  }

  Future<void> _onShare() async {
    setState(() {
      _sharing = true;
      _renderCard = true;
    });
    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final andata = await shareStesaCard(
        boundaryKey: _cardKey,
        text: 'La mia stesa a tre carte. Esoteric Circle.',
      );
if (andata && mounted) {
  // Ordine BG voce 04: il premio dichiarato sul pulsante si paga qui,
  // a condivisione davvero avvenuta.
  await PremioDellaCondivisione.premia(context,
      cosa: 'Hai condiviso la tua stesa');
}
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Non riesco a preparare la card ora.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _sharing = false;
          _renderCard = false;
        });
      }
    }
  }
}

/// Il ventaglio di carte coperte, col dorso di Medora.
class _Slot extends StatelessWidget {
  const _Slot({
    required this.position,
    required this.drawn,
    required this.palette,
    this.revealSpec,
    this.revealProgress = 0,
    this.tiltX = 0,
    this.tiltY = 0,
    this.galleggio = 0,
  });

  final SpreadPosition position;
  final DrawnCard? drawn;
  final MaestroPalette palette;

  /// L'aura elementale, quando questa carta si sta scoprendo.
  final RevealSpec? revealSpec;
  final double revealProgress;

  /// L'inclinazione dal giroscopio e il galleggiamento lento. A zero la carta
  /// resta ferma e composta: e' il ripiego statico.
  final double tiltX;
  final double tiltY;
  final double galleggio;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // La carta posata fluttua piano e si inclina col giroscopio, come
        // sospesa davanti a chi guarda. E' un effetto di superficie: non tocca
        // il testo sotto ne' il pescaggio.
        Transform.translate(
          offset: Offset(0, galleggio),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateX(tiltY)
              ..rotateY(tiltX),
            child: Stack(
              alignment: Alignment.center,
              // L'aura deve poter uscire dal bordo della carta: e' attorno a
              // lei che l'elemento fiorisce, non dentro.
              clipBehavior: Clip.none,
              children: [
                AspectRatio(
                  // LA CHIAVE DELLA CARTA POSATA, ordine P voce 05: la prova
                  // che verifica che una carta gia' estratta non si muova di un
                  // punto durante il taglio ha bisogno di un punto a cui
                  // agganciarsi, e dedurlo dal nome della carta la legherebbe
                  // al pescaggio.
                  key: Key('stesa_carta_${position.name}'),
                  aspectRatio: kTarotAspect,
                  child: drawn == null
                      ? _EmptySlot(palette: palette)
                      : _FlipCard(
                          key: ValueKey('${position.name}_${drawn!.card.stem}'),
                          drawn: drawn!,
                          palette: palette),
                ),
                // L'aura elementale, mentre la carta si scopre.
                if (revealSpec != null && revealProgress > 0)
                  Positioned.fill(
                    child: ElementalReveal(
                      key: Key('stesa_reveal_${position.name}'),
                      spec: revealSpec!,
                      progress: revealProgress,
                      palette: palette,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(position.label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TypographyTokens.etichetta().copyWith(
                color: palette.goldSoft, letterSpacing: 1.2)),
        // IL NOME, IL VERSO E LA SINTESI NON STANNO PIU' QUI.
        //
        // **Ordine P voce 10.** Erano dentro la colonna della miniatura, larga
        // un terzo dello schermo, quindi "L'onda trattenuta." andava a capo
        // dopo due parole mentre alla sua destra due terzi della larghezza
        // restavano vuoti. Adesso vivono in `_BloccoDelleCarte`, sotto la fila
        // delle tre carte, su tutta la larghezza disponibile.
      ],
    );
  }
}

/// IL BLOCCO DELLE CARTE USCITE, SU TUTTA LA LARGHEZZA. Ordine P voce 10.
///
/// Una riga per carta: la posizione, il nome, la marcatura del verso quando c'e'
/// e la frase di sintesi. La colonna e' quella della schermata, non quella della
/// miniatura, quindi le frasi vanno a capo per la loro lunghezza e non per la
/// larghezza di un'immagine.
///
/// **E ROVESCIATO SMETTE DI ESSERE UN MAIUSCOLETTO PICCOLO.** Era un'etichetta
/// in oro alla misura minima, cioe' la cosa meno leggibile della schermata
/// mentre e' l'unica che ribalta il significato della carta. Adesso e' una
/// marcatura: una pastiglia col bordo, alla misura della didascalia.
class _BloccoDelleCarte extends StatelessWidget {
  const _BloccoDelleCarte({
    super.key,
    required this.carte,
    required this.palette,
  });

  final List<DrawnCard> carte;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final drawn in carte) ...[
          // UN SOLO `Wrap` PER I QUATTRO PEZZI, e la ragione e' misurata due
          // volte.
          //
          // **Ordine P voce 10.** Nella prima stesura i pezzi stavano su una
          // `Row`: al nome restavano 156 punti su 328, quindi "Cinque di Spade"
          // andava a capo dopo due parole. Il difetto non era la colonna della
          // miniatura, era la riga CONDIVISA, e spostare il testo senza dargli
          // tutta la larghezza lo avrebbe riprodotto piu' in basso.
          //
          // **Poi le ho dato quattro righe in colonna, e un presidio esistente
          // e' caduto**: dopo due pescaggi il ventaglio finiva a 872 punti su
          // uno schermo da 844, cioe' fuori campo proprio mentre serve. Dentro
          // un `Wrap` ogni pezzo riceve tutta la larghezza per se', quindi il
          // nome non si spezza, e i pezzi corti si affiancano invece di
          // impilarsi: due righe invece di quattro.
          Wrap(
            spacing: SpacingTokens.xs,
            runSpacing: 2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(drawn.position.label.toUpperCase(),
                  style: TypographyTokens.etichetta().copyWith(
                      color: palette.goldSoft.withValues(alpha: 0.8),
                      letterSpacing: 1.2)),
              Text(drawn.card.name,
                  key: Key('stesa_name_${drawn.position.name}'),
                  style: TypographyTokens.titoloScheda().copyWith(
                      color: ColorTokens.textPrimary, height: 1.2)),
              if (drawn.reversed)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(SpacingTokens.radiusPill),
                    border: Border.all(
                        color: palette.gold.withValues(alpha: 0.6)),
                  ),
                  child: Text(drawn.versoLabel,
                      key: Key('stesa_reversed_${drawn.position.name}'),
                      style: TypographyTokens.didascalia()
                          .copyWith(color: palette.goldSoft)),
                ),
              Text(drawn.summary,
                  key: Key('stesa_meaning_${drawn.position.name}'),
                  style: TypographyTokens.didascalia().copyWith(
                      color: ColorTokens.textSecondary, height: 1.35)),
            ],
          ),
          const SizedBox(height: SpacingTokens.xs),
        ],
      ],
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: palette.gold.withValues(alpha: 0.28),
            style: BorderStyle.solid),
        color: palette.deepest.withValues(alpha: 0.35),
      ),
      child: Center(
        child: Icon(Icons.auto_awesome,
            size: 18, color: palette.gold.withValues(alpha: 0.35)),
      ),
    );
  }
}

/// La carta che si gira: dorso, mezzo giro, faccia. La rovesciata si mostra
/// ruotata di mezzo giro.
class _FlipCard extends StatefulWidget {
  const _FlipCard(
      {super.key, required this.drawn, required this.palette});

  final DrawnCard drawn;
  final MaestroPalette palette;

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.of(context).disableAnimations) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controller.value);
        final angle = (1 - t) * math.pi;
        final showBack = angle > math.pi / 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(angle),
          // A meta' giro il contenuto e' specchiato: va contro-ruotato il DORSO,
          // che si vede quando l'angolo e' oltre il quarto di giro. La faccia,
          // che si vede ad angolo zero, non va toccata, altrimenti resterebbe
          // specchiata a riposo e i cartigli si leggerebbero al contrario.
          child: showBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: CardBack(palette: widget.palette),
                )
              : _CardFace(drawn: widget.drawn, palette: widget.palette),
        );
      },
    );
  }
}

/// La faccia della carta, con i cartigli riempiti a runtime.
class _CardFace extends StatelessWidget {
  const _CardFace({required this.drawn, required this.palette});

  final DrawnCard drawn;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return TarotCardArt(
      card: drawn.card,
      palette: palette,
      reversed: drawn.reversed,
    );
  }
}


/// Dorso dipinto di ripiego: un cielo con la stella di Medora.

/// Uno strato della lettura: titolo in maiuscoletto, poi il testo.
class _Strato extends StatelessWidget {
  const _Strato({
    super.key,
    required this.titolo,
    required this.testo,
    required this.palette,
    this.inEvidenza = false,
  });

  final String titolo;
  final String testo;
  final MaestroPalette palette;

  /// Il consiglio si stacca dagli altri strati, e' quello che si porta a casa.
  ///
  /// **Ed e' l'unico strato che resta**: l'occhiello serviva alla bolla della
  /// carta chiave e il corsivo a quella della domanda, ed entrambe sono uscite
  /// con la voce 08 e la voce 09.
  final bool inEvidenza;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        color: inEvidenza
            ? palette.primary.withValues(alpha: 0.42)
            : palette.surfaceElevated.withValues(alpha: 0.55),
        border: Border.all(
            color: palette.gold.withValues(alpha: inEvidenza ? 0.55 : 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titolo.toUpperCase(),
              style: TypographyTokens.etichetta().copyWith(
                  color: palette.goldSoft.withValues(alpha: 0.85),
                  letterSpacing: 1.4)),
          const SizedBox(height: 6),
          Text(testo,
              style: TypographyTokens.corpo().copyWith(
                color: inEvidenza ? palette.goldSoft : ColorTokens.textPrimary,
                height: 1.5,
              )),
        ],
      ),
    );
  }
}

/// UNA DELLE TRE BOLLE DI POSIZIONE, e una delle tre e' LA CHIAVE.
///
/// **Ordine P voce 07.** La carta chiave aveva una bolla propria, che ripeteva
/// il nome di una carta gia' mostrata due volte piu' sopra. Adesso non e' una
/// bolla, e' uno STATO di questa: quando [perche] non e' nullo, la bolla si
/// distingue con un blu piu' intenso, un bordo acceso piu' spesso e la marcatura
/// che dice perche' e' quella.
///
/// **La distinzione si misura, non si stima.** Lo scarto fra la bolla chiave e
/// una bolla normale e' dichiarato in [scartoMinimoAPixel] e sorvegliato da una
/// prova differenziale a pixel: una evidenziazione che si vede solo a chi sa che
/// c'e' non e' una evidenziazione.
class BollaDellaPosizione extends StatelessWidget {
  const BollaDellaPosizione({
    super.key,
    required this.letta,
    required this.palette,
    this.perche,
  });

  final PosizioneLetta letta;
  final MaestroPalette palette;

  /// La ragione per cui questa e' la carta chiave, oppure nullo se non lo e'.
  final String? perche;

  bool get eLaChiave => perche != null;

  /// DI QUANTO LA BOLLA CHIAVE DEVE SCOSTARSI DALLE ALTRE DUE.
  ///
  /// Livelli medi di colore, da 0 a 255, misurati sulla fascia alta del rientro
  /// della bolla, cioe' dove non passa nessuna lettera. Diciotto perche' e' lo
  /// scarto che si legge da un colpo d'occhio a un braccio di distanza: sotto i
  /// dieci le due bolle si distinguono solo mettendole una accanto all'altra, e
  /// nella schermata vera non sono affiancate, sono una sotto l'altra.
  ///
  /// La soglia sta qui e non nella prova: e' una decisione di prodotto, e una
  /// soglia scritta dentro la sua misura non protegge niente.
  static const double scartoMinimoAPixel = 18;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        // IL BLU PIU' INTENSO: e' il primario del Maestro, non un colore nuovo.
        color: eLaChiave
            ? palette.primary.withValues(alpha: 0.62)
            : palette.surfaceElevated.withValues(alpha: 0.55),
        border: Border.all(
          color: palette.gold.withValues(alpha: eLaChiave ? 0.95 : 0.25),
          width: eLaChiave ? 2 : 1,
        ),
        boxShadow: eLaChiave
            ? [
                BoxShadow(
                  color: palette.gold.withValues(alpha: 0.28),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(letta.drawn.position.label.toUpperCase(),
                  style: TypographyTokens.etichetta().copyWith(
                      color: palette.goldSoft.withValues(alpha: 0.85),
                      letterSpacing: 1.4)),
              if (eLaChiave) ...[
                const SizedBox(width: SpacingTokens.xs),
                Icon(Icons.star_rounded, size: 15, color: palette.goldSoft),
                const SizedBox(width: 4),
                Text('LA CHIAVE',
                    style: TypographyTokens.etichetta().copyWith(
                        color: palette.goldSoft, letterSpacing: 1.4)),
              ],
            ],
          ),
          // I vuoti passano dai token: la bolla e' nata in questo ordine e non
          // aveva nessun diritto di portarsi dietro due misure scritte a mano.
          const SizedBox(height: SpacingTokens.xxs),
          Text(letta.drawn.displayName,
              style: TypographyTokens.titoloScheda()
                  .copyWith(color: palette.goldSoft, height: 1.2)),
          const SizedBox(height: SpacingTokens.xxs),
          Text(letta.testo,
              style: TypographyTokens.corpo().copyWith(
                  color: ColorTokens.textPrimary, height: 1.5)),
          // LA MARCATURA PICCOLA CHE DICE PERCHE' E' QUELLA.
          if (eLaChiave) ...[
            const SizedBox(height: SpacingTokens.xs),
            Text(perche!,
                key: Key('stesa_marcatura_${letta.drawn.position.name}'),
                style: TypographyTokens.didascalia().copyWith(
                    color: palette.goldSoft.withValues(alpha: 0.9),
                    height: 1.35,
                    fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }
}

/// Un gesto sul mazzo: taglia o mischia.
///
/// Resta sempre in campo, anche quando il telefono ha l'accelerometro: lo
/// scuotimento e' un di piu', mai l'unica strada per mescolare.
class _GestoMazzo extends StatelessWidget {
  const _GestoMazzo({
    super.key,
    required this.icona,
    required this.label,
    required this.palette,
    required this.attivo,
    required this.onTap,
  });

  final IconData icona;
  final String label;
  final MaestroPalette palette;
  final bool attivo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: attivo,
      label: label,
      child: GestureDetector(
        onTap: attivo ? onTap : null,
        child: AnimatedOpacity(
          opacity: attivo ? 1 : 0.4,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
              color: palette.surfaceElevated.withValues(alpha: 0.6),
              border:
                  Border.all(color: palette.gold.withValues(alpha: 0.45)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icona, size: 15, color: palette.goldSoft),
                const SizedBox(width: 6),
                Text(label,
                    style: TypographyTokens.didascalia()
                        .copyWith(color: palette.goldSoft)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// La carta che si stacca dal ventaglio e vola nel suo slot.
///
/// Sale dal ventaglio verso Passato, Presente o Futuro, si illumina lungo la
/// strada e lascia dietro di se' una scia di stelle. Arrivata a destinazione
/// sparisce, e il flip dello slot la gira sulla faccia.
class _CartaInVolo extends StatelessWidget {
  const _CartaInVolo({
    super.key,
    required this.progress,
    required this.destinazione,
    required this.palette,
    required this.seed,
  });

  /// Il punto del volo, da 0 a 1.
  final double progress;

  /// L'indice dello slot verso cui va, da 0 a 2.
  final int destinazione;

  final MaestroPalette palette;

  /// La carta del ventaglio da cui e' partita: da qui nasce la sua scia.
  final int seed;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            // Gli slot stanno in tre colonne, il ventaglio in basso.
            final colonna = (destinazione.clamp(0, 2) * 2 + 1) / 6;
            final e = Curves.easeInOutCubic.transform(progress.clamp(0.0, 1.0));
            final partenzaX = w * (0.2 + 0.6 * ((seed % 9) / 8));
            final x = partenzaX + (w * colonna - partenzaX) * e;
            final y = h * 0.72 + (h * 0.34 - h * 0.72) * e;
            const cardW = 66.0;

            return Stack(
              children: [
                Positioned(
                  left: x - cardW / 2,
                  top: y,
                  width: cardW,
                  child: Opacity(
                    // Sfuma sul finire: lo slot prende il testimone col flip.
                    opacity: progress > 0.88 ? (1 - progress) / 0.12 : 1,
                    child: Transform.scale(
                      // Si alza dal ventaglio, quindi cresce appena.
                      scale: 1 + 0.12 * math.sin(e * math.pi),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: palette.goldSoft.withValues(
                                  alpha: 0.45 * math.sin(e * math.pi)),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: AspectRatio(
                          aspectRatio: kTarotAspect,
                          child: CardBack(palette: palette),
                        ),
                      ),
                    ),
                  ),
                ),
                // La scia di stelle, dietro la carta.
                Positioned(
                  left: x - cardW,
                  top: y,
                  width: cardW * 2,
                  height: h * 0.4,
                  child: StardustTrail(
                    progress: e,
                    palette: palette,
                    seed: seed,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

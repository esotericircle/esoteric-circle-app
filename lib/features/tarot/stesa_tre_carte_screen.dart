import 'dart:async';
import '../maestri/chat/chat_openers.dart';
import '../ricordi/azioni_del_responso.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/rituals/filo_del_giorno.dart';
import '../../core/sensi/ascoltatore_scuotimento.dart';
import '../../core/maestro/maestro.dart';
import '../../core/astro/natal_chart.dart';
import '../../core/horoscope/cielo_di_oggi.dart';
import '../../core/horoscope/corrente_del_cielo.dart';
import '../../core/identity/natal_identity.dart';
import '../../core/tarot/tarot_reading.dart';
import '../../core/tarot/tarot_card.dart';
import '../../core/tarot/stesa_in_corso.dart';
import '../../core/astro/moon_phase.dart';
import '../../core/tarot/tarot_spread.dart';
import '../../core/tarot/tarot_topic.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../sigilli/celebrazione.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';
import 'attesa_di_medora.dart';
import 'stesa_choreography.dart';
import 'stesa_fan.dart';
import 'carta_ingrandita.dart';
import 'filo_fra_le_carte.dart';
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
import '../../core/entitlement/entitlement_service.dart';
import '../../core/entitlement/tier.dart';
import '../../core/entitlement/question_allowance.dart';
import '../pricing/upgrade_invite.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../design_system/components/riga_del_residuo.dart';
import '../../core/entitlement/budget_del_giorno.dart';
import '../../core/sensi/catalogo_suoni.dart';
import '../../core/sensi/palette_sensoriale.dart';

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

  static Route<void> route({int? seed}) =>
      PassaggioDelCerchio.rotta<void>((_) => SogliaArte(
          id: 'tarot_spread_three',
          maestro: Maestro.medora,
          child: StesaTreCarteScreen(seed: seed)));

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
    // Con revealAll la stesa nasce gia' compiuta e non c'e' nessuna attesa da
    // aspettare: il responso e' pronto da subito.
    _responsoPronto = true;
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
                    : _stesa.mazzoResiduo[i % _stesa.mazzoResiduo.length]],
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

  late final AnimationController _handoff =
      AnimationController(vsync: this, duration: StesaTiming.handoff);
  late final AnimationController _ingresso =
      AnimationController(vsync: this, duration: StesaTiming.ingresso);
  late final AnimationController _respiro =
      AnimationController(vsync: this, duration: StesaTiming.respiro);
  late final AnimationController _taglio =
      AnimationController(vsync: this, duration: StesaTiming.taglio);
  late final AnimationController _mescola =
      AnimationController(vsync: this, duration: StesaTiming.mescolamento);
  late final AnimationController _volo =
      AnimationController(vsync: this, duration: StesaTiming.volo);

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

  /// FA CORRERE IL FILO fra le tre carte, ordine BN voce 08.
  ///
  /// Finisce PRIMA che l'attesa cominci: sono due momenti in fila, non due
  /// cose sovrapposte. Con Riduci Movimento il filo si mostra fermo e intero
  /// per la stessa durata, e non si salta.
  Future<void> _corriIlFilo() async {
    if (!mounted) return;
    setState(() => _filoInScena = true);
    if (_reduceMotion) {
      _filo.value = 0.5; // il pieno del vigore, fermo
      await Future<void>.delayed(FiloFraLeCarte.durata);
    } else {
      await _filo.forward(from: 0);
    }
    if (!mounted) return;
    setState(() => _filoInScena = false);
  }

  /// APRE LA CARTA [slot] a tutta scena, ordine BN voce 04.
  ///
  /// Il testo mostrato e' `PosizioneLetta.testo`, cioe' lo stesso oggetto che
  /// riempie la bolla piu' in basso: la descrizione si legge da dove gia'
  /// vive, e non se ne scrive una seconda copia.
  Future<void> _apriLaCarta(int slot) async {
    final lette = _reading.posizioni;
    if (slot < 0 || slot >= lette.length) return;
    _sensi.momento(context, MomentoSensoriale.flip);
    await mostraLaCartaIngrandita(
      context,
      letta: lette[slot],
      palette: MaestroPalette.forKey(const ThemeKey.of(Maestro.medora)),
    );
  }

  /// L'aura elementale della carta appena scoperta.
  late final AnimationController _reveal = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100));

  /// Quale posizione sta fiorendo, e con quale resa.
  int? _revealSlot;
  RevealSpec? _revealSpec;

  /// Il galleggiamento lento delle carte posate.
  late final AnimationController _galleggio =
      AnimationController(vsync: this, duration: const Duration(seconds: 6));

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

  /// **VERO DA QUANDO LA STESA E' COMPLETA A QUANDO L'ATTESA E' FINITA.**
  /// Ordine BV voce 02: e' la finestra in cui la scena e' occupata, e comincia
  /// PRIMA che il gesto venga registrato, cioe' prima che un traguardo possa
  /// maturare. Senza di lui la festa nasceva nell'istante fra il gesto e
  /// l'inizio dell'animazione, trovava la scena libera e si apriva.
  bool _stoPerRiflettere = false;

  /// **IL RESPONSO APPARTIENE ALLA FASE CHE VIENE DOPO, ordine BN voce 03.**
  ///
  /// Parole del fondatore: "quando l'utente sceglie la terza o ultima Carta si
  /// vede per un attimo immediatamente la risposta e dopo un attimo parte
  /// l'animazione di riflessione, e' proprio una visione lampo molto
  /// fastidiosa in cui si vede gia' il responso e poi sopra parte
  /// l'animazione".
  ///
  /// Il difetto misurato: bastava `_complete` e che l'attesa non fosse ancora
  /// PIENA. Ma fra il `setState` della terza carta e l'inizio dell'attesa c'e'
  /// la fioritura dell'elemento, che dura: in quella finestra la condizione
  /// era gia' vera e il responso entrava in albero **prima** che Medora
  /// cominciasse a pensarci. Poi l'attesa gli si posava sopra, ed e' il lampo
  /// che il fondatore ha visto.
  ///
  /// `assente` non poteva distinguere "l'attesa non e' ancora cominciata" da
  /// "l'attesa e' finita", ed e' esattamente la stessa forma di difetto
  /// dell'ordine BK: due stati diversi che condividono lo stesso valore. Ora
  /// c'e' un fatto suo, [_responsoPronto], che diventa vero **una volta sola**
  /// e solo quando l'attesa e' finita davvero.
  bool get _responsoInScena =>
      _responsoPronto && _attesa != StatoDellAttesa.piena;

  /// LE TRE CARTE RESTANO IN SCENA FRA L'ULTIMA SCELTA E LA RIFLESSIONE.
  /// Ordine BZ voce 07.
  ///
  /// **Il difetto misurato.** Alla terza carta la stesa diventa compiuta, e da
  /// quell'istante la scena si svuotava: il pannello, gli slot e il ventaglio
  /// sono appesi a `!_complete`, il responso e le sue carte a
  /// [_responsoInScena], che e' falso finche' Medora non ha finito di pensare.
  /// Fra i due restava soltanto il ritratto, e dentro quel buco giravano due
  /// animazioni che nessuno poteva vedere: la fioritura dell'elemento della
  /// terza carta e il filo fra le carte dell'ordine BN voce 08. Sedici
  /// fotogrammi su sessanta, cioe' un secondo e sei decimi di ritratto solo.
  /// Parole del fondatore: "prima di tutto si vede per un secondo circa Medora
  /// da sola e poi parte l'animazione: ELIMINA LA PRIMA PARTE DOVE SI VEDE
  /// MEDORA DA SOLA".
  ///
  /// **Non si e' tolto il filo**, che dice che le tre carte sono una lettura
  /// sola: si e' rimesso in scena cio' su cui il filo corre. Chi guarda vede
  /// l'ultima carta fiorire e le tre carte legarsi, e poi Medora pensa.
  bool get _carteDopoLUltima => _complete && !_responsoPronto;

  /// Vero dal momento in cui Medora ha finito di pensare: da li' in poi il
  /// responso puo' stare in albero, e prima no.
  bool _responsoPronto = false;

  /// **IL FILO FRA LE TRE CARTE, ordine BN voce 08.** Corre una volta sola,
  /// fra la terza carta e l'inizio dell'attesa.
  late final AnimationController _filo =
      AnimationController(vsync: this, duration: FiloFraLeCarte.durata);

  /// Vero mentre il filo e' in scena.
  bool _filoInScena = false;

  /// Quante stese sono state chiuse in questa sessione: sposta il punto di
  /// partenza delle righe dell'attesa, cosi' due stese vicine non aprono sulla
  /// stessa frase.
  int _giroDellAttesa = 0;

  /// Quante carte sono gia' state pescate, da 0 a 3.
  late int _drawn = widget.revealAll ? SpreadPosition.values.length : 0;

  /// Quali carte del ventaglio sono gia' state prese.
  final Set<int> _taken = {};

  final GlobalKey _cardKey = GlobalKey();
  bool _renderCard = false;

  /// I selettori prima della stesa. Le voci non pronte restano Coming soon.
  late TarotSetup _setup =
      TarotSetup(topic: widget.topic ?? TarotTopic.predefinito);

  /// La lettura a sette strati, letta dentro l'argomento scelto. E'
  /// deterministica: stesse carte e stesso argomento danno sempre lo stesso
  /// testo, quindi si puo' mettere in cache senza toccare l'LLM.
  /// **E LA DOMANDA SCRITTA ENTRA NEL RESPONSO, ordine CQ voce 6.10.**
  ///
  /// Prima si fermava qui: il campo la raccoglieva, il ricordo la salvava e
  /// il riquadro la ripeteva a video, **e il motore non la vedeva mai**.
  /// Misurato: su una domanda di cinque parole portanti, nel testo del
  /// responso ne arrivavano zero.
  TarotReading get _reading => TarotReading.of(_spread, _setup.topic,
      depth: _setup.depth,
      fattoDelCielo: _fattoDelCielo,
      domandaScritta: _setup.domandaScritta);

  /// **IL CIELO VERO DI QUESTA PERSONA, ordine BN voce 07.**
  ///
  /// Le due arti vivevano nella stessa app senza parlarsi: la stesa non sapeva
  /// niente del cielo, mentre l'Oroscopo calcola gia' il transito vero dalla
  /// carta natale. La porta e' la stessa, `BirthIdentityController`, che vive
  /// nel guscio dell'app ed e' raggiungibile da qualunque schermata: alla
  /// stesa non mancava un dato, mancava la domanda.
  ///
  /// **Nulla quando il cielo vero non c'e'**: chi non ha ora e luogo di
  /// nascita ha `ceCieloVero` falso, e allora la riga non compare affatto e il
  /// consiglio resta quello di oggi. Nessuna frase generica travestita da
  /// transito.
  /// La carta natale, letta dalle dipendenze e non dal build.
  ///
  /// **`watch` qui sarebbe un errore, e l'ha detto una prova.** `_reading` non
  /// serve solo al build: lo chiamano il filo, la carta che si apre e il
  /// salvataggio della domanda, tutti fuori da un build. Un `watch` chiamato
  /// li' solleva, e il difetto non si vedeva come un errore di provider ma
  /// come una scena che non arrivava mai alla fase dopo.
  ///
  /// **Se la porta non c'e', non c'e' cielo, e non e' un errore**: la stesa si
  /// monta anche fuori dal guscio dell'app, per esempio in una prova che
  /// guarda una cosa sola. Senza controller non c'e' carta natale, e senza
  /// carta natale non c'e' cielo vero: e' lo stesso ripiego per una strada
  /// diversa.
  NatalChart? _cartaNatale;

  String? get _fattoDelCielo {
    final cielo = CieloDiOggi.perIlGiorno(adesso: _adesso, carta: _cartaNatale);
    if (!cielo.ceCieloVero) return null;
    return CorrenteDelCielo.fattoDelGiorno(cielo);
  }

  /// Il giorno della stesa, letto una volta sola: lo stesso istante per il
  /// cielo e per il responso.
  late final DateTime _adesso = DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cartaNatale =
        Provider.of<BirthIdentityController?>(context)?.cartaCompleta;
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
    _sensi.momento(context, MomentoSensoriale.taglio);
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
      await Future<void>.delayed(tenuta.isNegative ? Duration.zero : tenuta);
      if (!mounted) return;
      setState(() => _statoInPiena = false);
      await Future<void>.delayed(TaglioFasi.dissolvenzaFraStati);
    }
  }

  /// Il mescolamento a vortice, da scuotimento o dal tasto.
  Future<void> _mischia() async {
    if (!mounted || !_scene.accettaGesti) return;
    _sensi.momento(context, MomentoSensoriale.mescolamento);
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
    _filo.dispose();
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
    // **IL VENTAGLIO E' VIVO DA SUBITO.** Ordine CQ voce 1.03, 3 settembre
    // 2026, e ribalta l'ordine CO voce 07 per decisione del fondatore.
    //
    // CO.07 aveva messo un pulsante PRIMA delle carte, perche' la stesa
    // partiva sul primo tocco senza che nessuno l'avesse cominciata. La cura
    // era giusta nel movente e sbagliata nel posto: chiedeva di premere per
    // ottenere il permesso di scegliere. **Il fondatore lo vuole al
    // contrario**: si sceglie subito, e il pulsante sta DOPO le tre carte,
    // dove decide se leggere. Cosi' il gesto che costa e' uno solo, e non e'
    // il tocco su una carta.
    // **IL CANCELLO DELLA STESA, ordine BN voce 09.** Si guarda alla PRIMA
    // carta e non alla terza: chi non puo' stendere non deve scoprire di non
    // poterlo fare dopo aver posato due carte. Da qui in poi la stesa e'
    // cominciata, e cominciarla non costa niente: il conto si paga quando e'
    // compiuta.
    // **IL CANCELLO NON STA PIU' QUI**, sta su `_apriIlResponso`, che e' il
    // pulsante: ordine CQ voce 1.03. Guardarlo di nuovo a ogni carta sarebbe
    // la seconda porta sullo stesso permesso, e per di piu' farebbe pagare
    // una stesa a chi si limita a scegliere.
    _sensi.momento(context, MomentoSensoriale.volo);
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
    // Il flip, poi la fioritura dell'elemento: la carta si scopre e il suo
    // seme parla un istante, prima di lasciarla pulita e leggibile.
    _sensi.momento(context, MomentoSensoriale.flip);
    await _fiorisci(slot);
  }

  /// **IL RESPONSO SI APRE QUANDO LO CHIEDI, E SOLO ALLORA SI PAGA.**
  /// Ordine CQ voce 1.03, 3 settembre 2026.
  ///
  /// **Il fatto, parole del fondatore:** *"la stesa deve rimanere viva sin
  /// dall'inizio, l'utente sceglie le 3 carte e poi il pulsante diventa
  /// premibile."*
  ///
  /// **La provenienza e' l'ordine CO voce 07**, che aveva messo il pulsante
  /// prima delle carte. Qui il pulsante torna dopo, e cambia mestiere: non
  /// da' il permesso di scegliere, apre la lettura di cio' che si e' gia'
  /// scelto.
  ///
  /// **E' questo il gesto che costa.** Il cancello del piano si guarda qui e
  /// in nessun altro punto: tre carte posate e poi ripensarci non consuma
  /// niente, ed e' la stessa legge dell'ordine BN voce 09, spostata sul gesto
  /// che adesso la porta.
  Future<void> _apriIlResponso() async {
    if (!_complete || _responsoPronto || _stoPerRiflettere) return;
    if (!_laStesaSiPuoAprire(riprova: _apriIlResponso)) return;
    // Lo stesso momento sensoriale che l'ordine CO voce 07 aveva messo
    // sull'avvio: cambia il posto del pulsante, non cosa si sente premendolo.
    unawaited(PaletteSensoriale.momento(context,
        aptica: SchemaAptico.conferma, suono: SuonoDelCerchio.soglia));
    // LA STESA ENTRA NEL CAMMINO, ordine P voce 35. Qui, e non all'apertura
    // della scena: una scena si apre anche per sbaglio, una stesa COMPIUTA
    // no. Prima di questa voce la stesa non compariva in nessuno dei quattro
    // commit dell'ordine O, quindi non registrava niente e nessun traguardo
    // dei tarocchi poteva accendersi, ne' con tre stese ne' con trecento.

    // **IL GESTO PORTA CIO' CHE LA SCENA SA, ordine AR voce 11.** Nel
    // momento in cui la stesa e' completa questa scena ha in mano le tre
    // carte uscite e l'argomento scelto: sono i dettagli che le condizioni
    // di profondita' e coincidenza chiedono (tutti e quattro i semi, la
    // stessa carta in due stese, i sedici argomenti del ventaglio). Non si
    // va a cercare niente altrove: e' tutto qui, gia' pronto.
    // **IL CONSUMO VERO, ordine BN voce 09: qui e non alla prima carta.**
    // Una volta per stesa e non una per carta, nello stesso punto in cui la
    // stesa entra nel cammino, cioe' quando e' compiuta. Una stesa
    // cominciata e abbandonata non consuma niente.
    // **LA RIFLESSIONE SI DICHIARA PRIMA DEL GESTO, ordine BV voce 02.**
    // L'ordine BU aveva messo la dichiarazione dove l'animazione PARTE, e
    // per la festa che nasce mentre gira era giusto. Ma il caso vero e' un
    // altro, ed e' quello che il fondatore ha continuato a vedere: posando
    // l'ultima carta il traguardo matura qui sotto, la festa si apre in
    // quell'istante e trova la scena ancora libera, perche' Medora comincia
    // a pensare tre righe piu' giu'. **Chi sta per riflettere lo dice prima
    // di muovere qualunque cosa**, e da quel momento la scena e' occupata.
    _stoPerRiflettere = true;
    RiflessioniInCorso.entra(() =>
        mounted && (_stoPerRiflettere || _attesa != StatoDellAttesa.assente));
    final borsa = _forse<QuestionAllowance>(context);
    if (borsa != null) {
      borsa.registraStesa(
          _forse<EntitlementService>(context)?.tier ?? Tier.free);
    }
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
        // **IL VERSO DELLA CARTA, ordine BW voce 07.** Il corpus chiede "per
        // la prima volta una carta esce rovesciata e tu la leggi", e la
        // scena mandava carte, semi, maggiori e argomento: il verso restava
        // dentro la stesa e il gradino dormiva. Si mandano gli stemmi delle
        // sole carte uscite al rovescio, cosi' la domanda "e' mai successo"
        // e quella "quante volte" hanno tutte e due una risposta.
        'rovescio': [
          for (final c in carte)
            if (c.reversed) c.card.stem,
        ],
        // **LA CARTA E LA LUNA SOTTO CUI E' USCITA, ordine BX voce 01.** Il
        // corpus chiede "la stessa carta esce sotto tre fasi lunari
        // diverse": non basta sapere quali carte sono uscite, serve sapere
        // sotto quale cielo. Il dettaglio e' composto, 'carta@fase', ed e'
        // la forma che il diario sa interrogare.
        'carta_e_luna': [
          for (final c in carte)
            '${c.card.stem}@${MoonPhase.forDate(DateTime.now()).italianName}',
        ],
      },
    ));
    // LA DOMANDA SI SALVA, ordine P voce 09 e voce 18.
    //
    // **Senza questo la domanda e' un finale carino che nessuno ricorda.** La
    // domanda esiste perche' e' cio' che riporta la persona domani: ricompare
    // nel dono del mattino successivo con la formula "Ieri Medora ti ha
    // lasciato questa domanda".
    // **E SE LA DOMANDA L'HA SCRITTA LA PERSONA, SI RICORDA QUELLA.**
    // Ordine CO voce 05, 3 settembre 2026.
    //
    // Il filo del giorno riporta domani la domanda lasciata oggi, e fra le
    // due quella che vale di piu' e' quella che la persona ha scritto di suo
    // pugno: **e' la sola che lei riconosce come sua.** La domanda di
    // chiusura di Medora resta il ripiego di chi non ne ha scritta nessuna,
    // che e' la maggioranza delle volte.
    unawaited(FiloDelGiorno.segnaLaDomanda(
        _setup.domandaScritta ?? _reading.domanda, DateTime.now()));

    // IL FILO, ordine BN voce 08: dice che le tre carte sono una lettura sola,
    // e lo dice PRIMA che Medora cominci a pensare.
    await _corriIlFilo();
    // MEDORA CI PENSA, ordine P voce 06: dal pulsante, perche' e' li' che il
    // responso comincia, e prima non c'e' niente da guardare insieme.
    await _medoraCiPensa();
  }

  /// Un servizio del guscio, se c'e'. Torna nullo dove non c'e' nessun
  /// guscio, cioe' nelle anteprime e nelle prove che montano questa scena da
  /// sola: e' la stessa tolleranza che `corredoDelRiscatto` gia' usa, e non
  /// e' un modo per rendere facoltativo il gating nell'app vera.
  T? _forse<T>(BuildContext context, {bool osserva = false}) {
    try {
      return osserva ? context.watch<T>() : context.read<T>();
    } catch (errore) {
      return null;
    }
  }

  /// **LE DUE STRADE QUANDO LA RISERVA E' FINITA, ordine BN voce 09.**
  ///
  /// Mai un vicolo cieco: a stese esaurite il tocco sul ventaglio non e'
  /// muto, apre l'invito con le due strade, riscattare una stesa con gli Eos
  /// al prezzo del SERVER oppure salire di livello nel Cerchio. A riscatto
  /// avvenuto la stesa riparte da sola, sulla stessa carta che il dito aveva
  /// scelto, senza chiedere un secondo tocco.
  ///
  /// Il testo nomina le STESE e mai le gettate: sono due budget diversi, e
  /// una parola sbagliata qui manderebbe la persona a cercare il residuo
  /// dalla parte sbagliata dell'app.
  bool _laStesaSiPuoAprire({required VoidCallback riprova}) {
    final borsa = _forse<QuestionAllowance>(context);
    // **SENZA IL BORSELLINO NON SI SBARRA NIENTE.** Anteprime e prove
    // montano questa scena da sola, senza il guscio dell'app: li' il denaro
    // non esiste e una stesa non si puo' ne' contare ne' pagare. Che l'app
    // VERA quei due servizi li abbia sopra la rotta dei tarocchi non lo
    // decide questo `if`, lo dimostra la guardia
    // `test/il_gating_della_stesa_test.dart`, che legge `lib/app.dart`.
    if (borsa == null) return true;
    final piano = _forse<EntitlementService>(context)?.tier ?? Tier.free;
    if (borsa.puoiStendere(piano)) return true;
    final limite = borsa.limiteStese(piano);
    final riscatto = corredoDelRiscatto(
      context,
      budget: 'stese',
      cosaUna: 'una stesa completa',
      onSuccesso: (_) {
        if (!mounted) return;
        riprova();
      },
    );
    showUpgradeInvite(
      context,
      // **DUE SITUAZIONI DIVERSE MERITANO DUE FRASI DIVERSE.** Un piano che
      // le stese complete le compra in Eos non ha "finito" niente: non aveva
      // niente da finire, e dirgli che il giorno e' esaurito sarebbe falso.
      title: limite == 0
          ? 'La stesa completa si apre con gli Eos'
          : 'Le stese di oggi sono finite',
      message: limite == 0
          ? 'Nel tuo piano la stesa completa non è compresa: puoi aprirne '
              'una con gli Eos, oppure salire di livello nel Cerchio, dove '
              'le stese sono comprese ogni giorno.'
          : limite == 1
              ? 'La stesa del giorno è stata fatta. Puoi riscattarne una con '
                  'gli Eos, oppure salire di livello nel Cerchio: '
                  'dall\'Illuminato le stese sono senza limiti.'
              : 'Le $limite stese del giorno sono state fatte. Puoi '
                  'riscattarne una con gli Eos, oppure salire di livello nel '
                  'Cerchio: dall\'Illuminato le stese sono senza limiti.',
      riscattoLabel: riscatto.label,
      onRiscatta: riscatto.azione,
    );
    return false;
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
    // **LA DICHIARAZIONE E' GIA' STATA FATTA, ordine BV voce 02**, nel punto
    // in cui la stesa si e' completata: da li' in poi la scena e' occupata, e
    // qui comincia soltanto l'animazione. Se questa scena venisse aperta senza
    // passare di la', la riga qui sotto la dichiara lo stesso.
    if (!_stoPerRiflettere) {
      _stoPerRiflettere = true;
      RiflessioniInCorso.entra(() =>
          mounted && (_stoPerRiflettere || _attesa != StatoDellAttesa.assente));
    }
    setState(() {
      _attesa = StatoDellAttesa.piena;
      _giroDellAttesa++;
    });
    await Future<void>.delayed(
        AttesaDiMedora.minimaPer(riduciMovimento: _reduceMotion));
    if (!mounted) return;
    // La scena non sparisce di colpo: si dissolve, e il responso e' gia' sotto
    // di lei quando comincia a sparire. Nessuna parola viene tagliata.
    // Il responso nasce QUI, sotto il velo che comincia ad andarsene: non un
    // istante prima, o torna il lampo.
    setState(() {
      _attesa = StatoDellAttesa.inUscita;
      _responsoPronto = true;
    });
    await Future<void>.delayed(AttesaDiMedora.dissolvenza);
    if (!mounted) return;
    _stoPerRiflettere = false;
    setState(() => _attesa = StatoDellAttesa.assente);
    // Scena libera: la festa che ha aspettato riparte adesso, non fra
    // novanta secondi.
    if (mounted) {
      unawaited(RegiaDelCammino.svuotaLaCoda(context, appenaChiusaUna: true));
    }
  }

  /// L'aura elementale della carta appena scoperta.
  ///
  /// Con Riduci Movimento non c'e' nessun moto: la carta appare gia' composta,
  /// e il momento sensoriale resta comunque, perche' il silenzio ha il suo
  /// interruttore e non si spegne col movimento.
  Future<void> _fiorisci(int slot) async {
    if (slot < 0 || slot >= _spread.cards.length) return;
    final spec = RevealSpec.of(_spread.cards[slot].card);
    // **QUI LA RIVELAZIONE STRONCAVA LA CARTA. Ordine CQ voce 6.08.**
    //
    // `_fiorisci` viene chiamata solo da `_pesca`, nella riga subito dopo
    // il flip: i due suoni arrivavano al lettore unico nello stesso
    // fotogramma, e il secondo ferma il primo. **La carta durava zero
    // millesimi su settecento trenta**, e nessuna guardia lo vedeva perche
    // dalla porta del Cerchio uscivano tutti e due i suoni, come dovevano.
    //
    // La carta che si posa fa UN suono, ed e' la carta. **L'aptica della
    // fioritura resta**, solenne sui Maggiori: e' quella a dire che carta e',
    // e non si contende nessun lettore.
    _sensi.momento(context, MomentoSensoriale.reveal,
        solenne: spec.solenne, conSuono: false);
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
                      // Ordine BN voce 07: il cielo vero, se c'e'.
                      fattoDelCielo: _fattoDelCielo,
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
                    // **LA CARD SEGUE LA LENTE, NON LA DOMANDA. Ordine CQ
                    // voce 6.10.**
                    //
                    // La lente e' quella che la domanda ha scelto, cosi' la
                    // card parla dello stesso tema del responso letto. **La
                    // domanda scritta invece NON entra**, e non e' una
                    // dimenticanza: questa immagine esce dal telefono e la
                    // guardano altri, e la card mostra il primo paragrafo
                    // del consiglio, che con la domanda dentro sarebbe la
                    // domanda stessa. Chi condivide una lettura non sta
                    // condividendo cosa ha chiesto.
                    child: StesaShareCard(
                      spread: _spread,
                      palette: palette,
                      topic: _reading.topic,
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
  /// LA CHIAVE GLOBALE DEGLI SLOT, ordine BZ voce 07.
  ///
  /// I tre slot compaiono in TRE punti diversi della lista, secondo il momento:
  /// sopra il ventaglio mentre si pesca, sotto Medora fra l'ultima carta e la
  /// riflessione, sotto la sintesi a responso pronto. Senza una chiave globale
  /// Flutter, vedendoli cambiare posto, li considera widget nuovi: butta lo
  /// stato e le tre carte RIGIRANO SUL DORSO, perche' `_FlipCard` fa partire il
  /// suo giro quando nasce. **Si vede nell'anteprima**
  /// `stesa-dopo-l-ultima-carta.png`, che alla prima stesura mostrava tre dorsi
  /// dove dovevano esserci tre figure gia' scoperte. Con la chiave globale
  /// l'elemento trasloca invece di rinascere, e il giro resta fatto.
  ///
  /// Ne esiste UNO SOLO in albero per volta: i tre momenti si escludono a
  /// vicenda (`!_complete`, `_carteDopoLUltima`, `_responsoInScena`).
  final GlobalKey _chiaveDegliSlot = GlobalKey(debugLabel: 'stesa_slots');

  Widget _slots(MaestroPalette palette) {
    return KeyedSubtree(
      key: _chiaveDegliSlot,
      child: AnimatedBuilder(
        animation: Listenable.merge([_reveal, _galleggio, _tilt]),
        builder: (context, _) => _slotsRow(palette),
      ),
    );
  }

  Widget _slotsRow(MaestroPalette palette) {
    // IL FILO STA SOPRA LE TRE CARTE, ordine BN voce 08: si disegna sulla
    // fila intera, perche' e' la fila che deve leggersi come una cosa sola.
    final fila = _filaDelleCarte(palette);
    if (!_filoInScena) return fila;
    return Stack(
      children: [
        fila,
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _filo,
            builder: (context, _) => LayoutBuilder(
              builder: (context, vincoli) {
                final larga = vincoli.maxWidth / SpreadPosition.values.length;
                return FiloFraLeCarte(
                  centri: [
                    for (var i = 0; i < SpreadPosition.values.length; i++)
                      Offset(larga * (i + 0.5), vincoli.maxHeight * 0.42),
                  ],
                  dallaChiave: SpreadPosition.values
                      .indexOf(_reading.chiave.drawn.position),
                  avanzamento: _reduceMotion ? 0.5 : _filo.value,
                  palette: palette,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _filaDelleCarte(MaestroPalette palette) {
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
              // **LA CARTA SI APRE AL TOCCO, ordine BN voce 04.** Prima le
              // carte estratte erano l'unica cosa della scena a non
              // rispondere al dito: erano l'oggetto del rito e restavano mute.
              // Si apre solo quando c'e' qualcosa da leggere, cioe' a responso
              // pronto: prima non esiste ancora nessuna descrizione da
              // mostrare, e un ingrandimento vuoto sarebbe una porta su niente.
              onApri:
                  _responsoInScena && i < _drawn ? () => _apriLaCarta(i) : null,
              // **LA CHIAVE SI VEDE ANCHE NELLA STESA, ordine BN voce 05.**
              // Prima lo dichiarava solo la sua bolla, piu' in basso: chi
              // guardava le tre carte non sapeva quale delle tre reggesse la
              // lettura. Il segno e' della STESSA famiglia visiva della bolla,
              // cioe' l'oro pieno contro l'oro tenue, e non un secondo
              // linguaggio inventato qui.
              eLaChiave: _responsoInScena &&
                  i < _drawn &&
                  _reading.chiave.drawn.position == SpreadPosition.values[i],
              conIntestazione: _responsoInScena,
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
          // **L'INGRANDIMENTO ASPETTA IL RESPONSO, ordine CQ voce 6.09.**
          // Legato a `_complete` scattava alla terza carta, cioe' insieme
          // allo svuotamento: il ritratto raddoppiava mentre tutto il resto
          // spariva, ed era meta' della ragione per cui sembrava un'altra
          // schermata. Adesso Medora cresce quando il responso entra in
          // scena, che e' il momento in cui parla davvero.
          height: _responsoInScena ? 300 : 170,
          bustoFactor:
              _responsoInScena ? MedoraStage.bustoPieno : 0.34,
          bustoLarghezza: _responsoInScena ? 1.0 : 0.72,
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
          const SizedBox(height: SpacingTokens.xs),
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
          // **DODICI DIVENTANO OTTO, DUE VOLTE. Ordine CQ voce 2.11.** Le
          // etichette sono salite da dodici a quattordici punti e il
          // ventaglio e' finito sei punti e mezzo sotto la piega: la guardia
          // della coreografia lo ha visto. Gli otto punti si riprendono da
          // due arie fra blocchi, non dal testo: e' la stessa cura
          // dell'ordine BU voce 01, che aveva gia' fatto questo scambio.
          const SizedBox(height: SpacingTokens.xs),
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
            style: TypographyTokens.etichetta()
                .copyWith(color: ColorTokens.textSecondary, letterSpacing: 1.2),
          ),
          // **QUANTE NE RESTANO, DETTO PRIMA E NON DOPO. Ordine BN voce 09.**
          // Solo prima della prima carta: a stesa cominciata il conto e'
          // rumore, e a stesa finita sarebbe un rimprovero. Il numero arriva
          // dal listino attraverso il borsellino e non e' scritto qui.
          // **LA PORTA E' UNA SOLA, ordine CF voce 11.** Qui viveva un
          // contatore scritto apposta per questa schermata: diceva la
          // stessa cosa della riga comune, con parole sue e una regola
          // sua. Due porte sullo stesso fatto sono la famiglia di
          // difetti piu' numerosa del progetto, e questa in particolare
          // non conosceva la legge del silenzio, cioe' scriveva il
          // numero locale anche quando il server non aveva parlato.
          if (_drawn == 0)
            const RigaDelResiduo(
              budget: BudgetDelGiorno.stese,
              allineamento: MainAxisAlignment.center,
            ),
          // **OTTO E NON SEDICI, ordine BU voce 01.** I testi di contenuto
          // sono saliti alla misura di lettura, e sotto le carte pescate se
          // ne accumulano due: dopo due pescaggi il ventaglio finiva a 861
          // punti su uno schermo di 844, cioe' fuori campo, e una guardia
          // della coreografia lo ha visto. Lo spazio che si toglie qui e'
          // aria fra due blocchi; quello che si e' guadagnato sopra e'
          // testo che si legge.
          //
          // **E ZERO, ordine CQ voce 6.23 del 4 settembre 2026**: la prosa
          // e' salita da diciotto a venti punti e l'etichetta da dodici a
          // quattordici, e il ventaglio e' tornato fuori campo di **due
          // punti e mezzo**, 846,5 su 844. E' la stessa aria di allora, ed
          // e' finita: la prossima volta che questa guardia cade non ci
          // sara' piu' niente da togliere qui, e i punti andranno cercati
          // dentro il ventaglio, che si dimensiona sulla LARGHEZZA e non
          // guarda mai quanta altezza gli sia rimasta.
          const SizedBox(height: 0),
          // Il ventaglio con la sua regia: ingresso a spirale, respiro,
          // taglio e vortice. Si ridisegna col battito delle quattro fasi.
          AnimatedBuilder(
            animation:
                Listenable.merge([_ingresso, _respiro, _taglio, _mescola]),
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
          // **I GESTI VANNO A CAPO, NON SI STRINGONO.** Ordine CM voce 09,
          // famiglia D, 1 settembre 2026.
          //
          // Affiancati in una riga, a testo grande i tre gesti uscivano dal
          // bordo di trentatre punti, e portavano giu' sei catture del
          // corredo. Stringerli avrebbe voluto dire togliere le etichette,
          // cioe' **curare il traboccamento peggiorando proprio la cosa per
          // cui il testo grande esiste**. Con Wrap restano tutti e tre,
          // leggibili, e quando non ci stanno scendono di una riga.
          Wrap(
            alignment: WrapAlignment.center,
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.sm,
            children: [
              _GestoMazzo(
                key: const Key('stesa_taglia'),
                icona: Icons.content_cut_rounded,
                label: 'Taglia',
                palette: palette,
                attivo: _scene.accettaGesti,
                onTap: _taglia,
              ),
              _GestoMazzo(
                key: const Key('stesa_mischia'),
                icona: Icons.casino_rounded,
                label: 'Mischia',
                palette: palette,
                attivo: _scene.accettaGesti,
                onTap: _mischia,
              ),
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
            style: TypographyTokens.etichetta()
                .copyWith(color: ColorTokens.textSecondary, letterSpacing: 0.8),
          ),
          const SizedBox(height: SpacingTokens.lg),
        ],
        // **IL PULSANTE CHE APRE IL RESPONSO. Ordine CQ voce 1.03**, 3
        // settembre 2026, e ribalta l'ordine CO voce 07.
        //
        // **Sta fuori dal blocco `!_complete`, e la prima stesura di questa
        // voce ci era caduta dentro.** Li' spariva esattamente nell'istante in
        // cui doveva accendersi, cioe' alla terza carta, e nessuna prova che
        // lo cercava lo trovava piu'.
        //
        // C'e' sempre finche' il responso non e' aperto, e si accende solo a
        // tre carte posate: **chi arriva vede subito cosa dovra' premere**, e
        // vede anche che adesso non si puo'. Scegliere non consuma niente,
        // premere si'.
        if (!_responsoPronto) ...[
          const SizedBox(height: SpacingTokens.sm),
          Center(
            child: FilledButton.icon(
              key: const Key('stesa_inizia'),
              onPressed: _complete && !_stoPerRiflettere
                  ? () => unawaited(_apriIlResponso())
                  : null,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Leggi le Carte'),
              style: FilledButton.styleFrom(
                backgroundColor: palette.gold,
                foregroundColor: palette.deepest,
                disabledBackgroundColor: palette.gold.withValues(alpha: 0.22),
                disabledForegroundColor:
                    palette.deepest.withValues(alpha: 0.55),
                padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.lg, vertical: SpacingTokens.sm),
                textStyle: TypographyTokens.titoloDiRiga(),
              ),
            ),
          ),
          if (!_complete) ...[
            const SizedBox(height: SpacingTokens.xxs),
            Center(
              child: Text(
                'Scegli tre carte dal ventaglio, poi premi qui.',
                key: const Key('stesa_inizia_come'),
                textAlign: TextAlign.center,
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textSecondary),
              ),
            ),
          ],
          const SizedBox(height: SpacingTokens.md),
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
        // Le carte: quelle del responso, e quelle del momento fra l'ultima
        // scelta e la riflessione, che e' lo stesso blocco (ordine BZ voce
        // 07). Sotto, la spaziatura che le stacca da Medora quando sono sole.
        // **QUI LA SCHERMATA SEMBRAVA CAMBIARE, ordine CQ voce 6.09.**
        //
        // Parole del fondatore: *appena inserisco la terza carta, si apre
        // una nuova schermata con le 3 carte e il bottone*. **Non si apriva
        // nessuna schermata**: alla terza carta `_complete` diventa vero e
        // sparivano in blocco il pannello, gli slot, il blocco delle carte,
        // il ventaglio e il prompt, mentre Medora saliva da centosettanta a
        // trecento. Di tutta la pagina restavano un ritratto grande e un
        // pulsante, e a chi guarda quello e' un'altra schermata.
        //
        // Adesso le tre carte scelte restano sotto i loro slot, e il
        // pulsante sta sotto di loro: **la pagina e' la stessa di un attimo
        // prima, con una carta in piu' e un pulsante acceso.**
        if (_carteDopoLUltima) ...[
          _slots(palette),
          const SizedBox(height: SpacingTokens.xs),
          _BloccoDelleCarte(
            key: const Key('stesa_blocco_carte_scelte'),
            carte: _spread.cards,
            palette: palette,
          ),
          const SizedBox(height: SpacingTokens.sm),
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
          // **LA DOMANDA SCRITTA A MANO, RIPETUTA SOPRA IL RESPONSO.**
          // Ordine CO voce 05, 3 settembre 2026.
          //
          // Chi ha scritto la propria domanda deve vederla accanto alla
          // risposta: fra lo scriverla e il leggere ci sono tre carte pescate
          // e una scena di attesa, e una risposta che non nomina la domanda
          // sembra la risposta di un altro.
          //
          // **E ADESSO IL RESPONSO L'HA DAVVERO LETTA, ordine CQ voce 6.10.**
          //
          // Qui c'era scritto *non si finge che il testo del responso
          // l'abbia letta*, e allora era onesto: il responso nasceva dalle
          // sole carte e dalla tendina dell'argomento. Il fondatore ha
          // chiamato quel comportamento **la cosa piu' grave** dell'ordine
          // CQ, e adesso la domanda entra nel motore: si fa nominare in
          // cima al consiglio e sceglie la lente fra le sedici.
          //
          // **Questa riga resta lo stesso**, e non e' un doppione: e' la tua
          // domanda come l'hai scritta, mentre il responso la usa. Fra lo
          // scriverla e il leggere ci sono tre carte pescate e una scena di
          // attesa.
          if (_setup.domandaScritta != null) ...[
            Text('LA TUA DOMANDA',
                style: TypographyTokens.didascalia(weight: 600).copyWith(
                    color: palette.goldSoft.withValues(alpha: 0.85),
                    letterSpacing: 1.2)),
            const SizedBox(height: SpacingTokens.xxs),
            // **PASSA DA `ParagrafiDiLettura` come ogni testo nel ruolo
            // lettura**, e non e' una formalita': una domanda scritta a mano
            // puo' arrivare a centoquaranta battute, cioe' a piu' righe, e un
            // `Text` diretto nel ruolo di lettura e' la seconda porta da cui
            // il muro di testo rientra. L'ha detto la guardia dei paragrafi.
            ParagrafiDiLettura(
                testo: _setup.domandaScritta!,
                key: const Key('stesa_domanda_a_video'),
                stile: TypographyTokens.lettura().copyWith(
                    color: ColorTokens.textPrimary,
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: SpacingTokens.md),
          ],
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
          // **L'INTESTAZIONE DICE COSA SI STA PER LEGGERE, ordine BU voce 01.**
          // Parole del fondatore: "anziche' nel momento che vivi, carta per
          // carta scrivi ma in grande LE CARTE, UNA ALLA VOLTA". Era la lente
          // dell'argomento scritta al pavimento della scala; adesso e' un
          // titolo di sezione, e dice cosa viene dopo invece di ripetere cosa
          // si era chiesto.
          Text('LE CARTE, UNA ALLA VOLTA',
              key: const Key('stesa_lente'),
              style: TypographyTokens.titoloSezione().copyWith(
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
          ParagrafiDiLettura(
              testo: TarotSpread.closing,
              key: const Key('stesa_closing'),
              textAlign: TextAlign.center,
              stile: TypographyTokens.lettura().copyWith(
                  color: palette.goldSoft,
                  height: 1.4,
                  fontStyle: FontStyle.italic)),
          const SizedBox(height: SpacingTokens.lg),
          // **LE TRE AZIONI DA UNA PORTA SOLA, ordine CG voci 06 e 08.** Il
          // Condividi in oro resta com'era, perche' e' l'invito che chiude il
          // responso; accanto sono nati il Custodisci e il Parlane con Medora.
          AzioniDelResponso(
            palette: palette,
            maestro: Maestro.medora,
            dorato: true,
            responso: ResponsoDaCustodire(
              arte: 'stesa',
              titolo: 'La tua stesa a tre carte',
              testo: _spread.reading,
              dati: {
                'carte': _spread.cards.map((c) => c.card.name).join(','),
              },
            ),
            condividi: _onShare,
            aperturaDellaChat: ChatOpeners.stesa(
                _spread.cards.map((c) => c.card.name).toList()),
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

  /// **TORNA L\'ESITO invece di ingoiarlo, ordine CG voce 06.**
  Future<bool> _onShare() async {
    setState(() => _renderCard = true);
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
      return andata;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Non riesco a preparare la card ora.')),
        );
      }
      // Un errore non e' una condivisione avvenuta, quindi non custodisce.
      return false;
    } finally {
      // Chi spegne il pulsante mentre si condivide adesso e' la porta sola:
      // due stati per la stessa attesa sarebbero due verita'.
      if (mounted) setState(() => _renderCard = false);
    }
  }
}

/// Il ventaglio di carte coperte, col dorso di Medora.
class _Slot extends StatelessWidget {
  const _Slot({
    this.onApri,
    this.eLaChiave = false,
    this.conIntestazione = false,
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

  /// Cosa fa il tocco sulla carta, o nulla quando non c'e' niente da aprire.
  final VoidCallback? onApri;

  /// Se questa e' la carta che regge la lettura. Ordine BN voce 05.
  final bool eLaChiave;

  /// Se sopra le carte si tiene lo spazio delle parole. Ordine BZ voce 08.
  ///
  /// **Non e' sempre acceso, e la ragione e' misurata.** Lo spazio si riserva
  /// a tutte e tre le carte perche' restino allineate, ma MENTRE SI PESCA
  /// nessuna carta e' ancora la chiave: quei trentadue punti spingevano il
  /// ventaglio piu' in basso e una guardia della coreografia lo ha visto
  /// ("il ventaglio resta a portata anche dopo il secondo pescaggio"). Si
  /// tiene solo quando la chiave c'e' davvero, cioe' a responso in scena.
  final bool conIntestazione;

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
        // **LE PAROLE SOPRA LA CARTA CHIAVE, ordine BZ voce 08.**
        //
        // Parole del fondatore: "la Carta chiave evidenziata da cornice
        // azzurra FA ANCORA SCHIFO: va bene la carta ingrandita, ma sopra
        // bisogna scrivergli "Carta Chiave" ed e' meglio diminuire la
        // grandezza delle altre 2 carte". La cornice non c'e' piu': al suo
        // posto ci sono le parole, che dicono cosa sia invece di lasciarlo
        // indovinare a una linea di colore.
        //
        // **L'ALTEZZA E' RISERVATA A TUTTE E TRE**, anche a chi non scrive
        // niente: cosi' le tre carte restano allineate in cima e la chiave non
        // scende rispetto alle vicine. Trentadue punti per quindici di
        // scritta: l'aria che avanza non e' spreco, e' lo spazio in cui la
        // carta chiave CRESCE. Misurato: con venti punti la carta, scalata a
        // 1,10, saliva fino a 430,8 mentre le parole finivano a 440, cioe' le
        // copriva di nove punti.
        SizedBox(
          height: conIntestazione ? 32 : 0,
          child: eLaChiave
              ? Align(
                  alignment: Alignment.topCenter,
                  child: Text('Carta Chiave',
                      key: Key('stesa_parole_chiave_${position.name}'),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      // **E LE PAROLE SONO D'ORO, non azzurre.** Ordine
                      // CO voce 08, 3 settembre 2026. Il fondatore:
                      // "Carta Chiave e' azzurro su blu, non si legge".
                      //
                      // **Misurato, e aveva ragione**: `palette.glow` di
                      // Medora sui fondi veri di questa schermata sta fra
                      // 3,35 e 4,96 a uno, e la soglia per una lettera di
                      // tredici punti e' 4,5. Nessuna guardia lo aveva
                      // preso perche' nessuna stava guardando li': quella
                      // dei grigi spazza i due token di TESTO grigi, e
                      // l'accento del Maestro non e' un token di testo,
                      // e' il colore degli aloni e dei bordi, dove la
                      // soglia e' tre a uno. **Non c'era una guardia
                      // cieca: c'era un insieme senza guardia**, e adesso
                      // ce l'ha, gli_accenti_non_sono_inchiostro_test.
                      //
                      // L'oro sta fra 9,29 e 13,81, ed e' gia' la lingua
                      // con cui la bolla di questa stessa carta scrive
                      // "LA CHIAVE" piu' in basso: due posti che dicono
                      // la stessa cosa adesso la dicono nello stesso modo.
                      style: TypographyTokens.etichetta().copyWith(
                          color: palette.goldSoft, letterSpacing: 1.1)),
                )
              : null,
        ),
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
            // **LA CARTA CHIAVE E' PIU' GRANDE DELLE ALTRE DUE, ordine BV voce
            // 04.** Il fondatore: "il contorno della carta azzurro c'e', ma si
            // vede poco e non mette in evidenza la Carta chiave tra le tre".
            // Una linea segue il bordo e si confonde col profilo dorato della
            // carta; **una differenza di SCALA si vede da un metro**, non
            // copre un pixel della figura e non aggiunge nessun colore sopra.
            // Dieci per cento: abbastanza da leggersi a colpo d'occhio,
            // abbastanza poco da non toccare le vicine.
            child: Transform.scale(
                // **LA CHIAVE RESTA GRANDE E LE ALTRE DUE SCENDONO, ordine BZ
                // voce 08.** Prima lo scarto era il solo dieci per cento della
                // chiave; adesso le vicine scendono a ottantasei centesimi e lo
                // scarto dipinto arriva a un quarto abbondante, che e' cio' che
                // il fondatore ha chiesto quando ha detto di diminuire la
                // grandezza delle altre due.
                scale: eLaChiave ? 1.10 : 0.86,
                child: Stack(
                  alignment: Alignment.center,
                  // L'aura deve poter uscire dal bordo della carta: e' attorno a
                  // lei che l'elemento fiorisce, non dentro.
                  clipBehavior: Clip.none,
                  children: [
                    // **L'AREA TOCCABILE, ordine BN voce 04.** La carta e' ben
                    // piu' grande del minimo, ma il minimo si dichiara lo stesso:
                    // e' la stessa soglia che vale per ogni bersaglio dell'app, e
                    // scriverla qui vuol dire che nessuna futura riduzione della
                    // carta puo' portarla sotto senza che una prova lo dica.
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
                          : Semantics(
                              button: onApri != null,
                              label: onApri != null
                                  ? 'Apri la carta ${drawn!.card.name}'
                                  : null,
                              child: GestureDetector(
                                key: Key('stesa_apri_${position.name}'),
                                onTap: onApri,
                                behavior: HitTestBehavior.opaque,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                      minWidth: 48, minHeight: 48),
                                  child: _FlipCard(
                                    key: ValueKey(
                                        '${position.name}_${drawn!.card.stem}'),
                                    drawn: drawn!,
                                    palette: palette,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    // **LA CORNICE AZZURRA NON C'E' PIU', ordine BZ voce 08.**
                    //
                    // Parole del fondatore: "la Carta chiave evidenziata da
                    // cornice azzurra FA ANCORA SCHIFO". Era il terzo tentativo
                    // sulla stessa cosa: alone d'oro (BN.05), poi la sola linea
                    // azzurra (BU.02), poi la linea piu' spessa con la carta
                    // cresciuta (BV.04). Il segno adesso non si disegna piu' sopra
                    // la carta: sono le PAROLE sopra di lei, in cima a questa
                    // colonna, piu' lo scarto di misura con le vicine. Chi legge
                    // non deve piu' interpretare un colore.
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
                )),
          ),
        ),
        const SizedBox(height: SpacingTokens.xxs),
        Text(position.label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TypographyTokens.etichetta()
                .copyWith(color: palette.goldSoft, letterSpacing: 1.2)),
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
/// **IL CONTO DELLE STESE DEL GIORNO, ordine BN voce 09.**
///

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
                  style: TypographyTokens.titoloScheda()
                      .copyWith(color: ColorTokens.textPrimary, height: 1.2)),
              if (drawn.reversed)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(SpacingTokens.radiusPill),
                    border:
                        Border.all(color: palette.gold.withValues(alpha: 0.6)),
                  ),
                  child: Text(drawn.versoLabel,
                      key: Key('stesa_reversed_${drawn.position.name}'),
                      style: TypographyTokens.didascalia()
                          .copyWith(color: palette.goldSoft)),
                ),
              ParagrafiDiLettura(
                  testo: drawn.summary,
                  key: Key('stesa_meaning_${drawn.position.name}'),
                  stile: TypographyTokens.lettura()
                      .copyWith(color: ColorTokens.textSecondary, height: 1.2)),
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
  const _FlipCard({super.key, required this.drawn, required this.palette});

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
              : FacciaDellaCarta(drawn: widget.drawn, palette: widget.palette),
        );
      },
    );
  }
}

/// La faccia della carta, con i cartigli riempiti a runtime.
/// LA FACCIA DELLA CARTA, pubblica dall'ordine BN voce 04: la carta che si
/// apre al tocco mostra la stessa faccia della carta nella stesa, e una
/// seconda copia del disegno sarebbe due carte che possono divergere.
class FacciaDellaCarta extends StatelessWidget {
  const FacciaDellaCarta(
      {super.key, required this.drawn, required this.palette});

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
          // **IL TITOLO SALE DI UNA MISURA PIENA, ordine BN voce 06.** Parole
          // del fondatore: "vorrei che il titolo fosse piu' grande". Era
          // `etichetta`, cioe' il PAVIMENTO della scala a dodici punti: la
          // misura piu' piccola dell'app, data alla bolla che la persona
          // porta via. Adesso e' `titoloScheda`, diciotto, che e' il gradino
          // pieno successivo e non un numero scelto qui: la scala la decide
          // il design system, questa riga la usa.
          Text(titolo.toUpperCase(),
              key: const Key('stesa_consiglio_titolo'),
              maxLines: 1,
              style: TypographyTokens.titoloScheda().copyWith(
                  color: palette.goldSoft.withValues(alpha: 0.85),
                  letterSpacing: 1.4)),
          const SizedBox(height: 6),
          // **IL CONSIGLIO SI LEGGE, ordine BU voce 01.** Parole del fondatore:
          // "il testo nella bolla del consiglio di Medora e' monotono, tutto
          // giallo e senza paragrafi. inoltre e' scritto piccolo". Tre cose in
          // una frase, e sono tre cose diverse: la MISURA sale da `corpo` a
          // `lettura`, che e' il ruolo del testo che si legge per intero; il
          // COLORE lascia l'oro e prende quello del testo, perche' l'oro qui
          // dentro era su ogni riga e un accento su tutto non accenta niente;
          // i PARAGRAFI restano separati invece di fondersi, e li tiene
          // separati chi sa gia' farlo. Il titolo resta oro: quello e' un
          // titolo.
          ParagrafiDiLettura(
            testo: testo,
            stile: TypographyTokens.lettura().copyWith(
              color: ColorTokens.textPrimary,
            ),
          ),
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
        // **LO STESSO FONDO DELLE ALTRE, ordine BU voce 02.** La bolla chiave
        // aveva un fondo blu piu' intenso e un alone oro: due sovrapposizioni
        // per dire una cosa che la cornice dice gia'. Adesso si distingue come
        // la carta, con la stessa linea azzurra e niente altro.
        color: palette.surfaceElevated.withValues(alpha: 0.55),
        border: Border.all(
          color:
              eLaChiave ? palette.glow : palette.gold.withValues(alpha: 0.25),
          width: eLaChiave ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // **LA CARTA STA DENTRO LA SUA BOLLA. Ordine CO voce 06**, 3
          // settembre 2026.
          //
          // Le tre carte stanno in fila in cima alla schermata, e le tre bolle
          // che le leggono stanno sotto, una dietro l'altra. **Fra la carta e
          // il testo che la spiega si scorre**, e piu' si legge piu' la carta
          // e' lontana: chi arriva alla terza bolla ha la sua carta fuori
          // schermo da un pezzo e deve tornare su per sapere di quale si stia
          // parlando. Il nome scritto non basta a chi ha appena visto tre
          // figure e non le ha ancora imparate a memoria.
          //
          // Sta nell'intestazione e non sopra il testo, ed e' una scelta di
          // larghezza: una carta a tutta bolla mangerebbe l'altezza di uno
          // schermo, e una carta a fianco del testo lascerebbe alla lettura
          // duecentoquaranta punti su trecentosessanta. Qui la carta accompagna
          // il nome e la posizione, cioe' l'intestazione, **e il testo torna a
          // occupare la riga intera sotto di lei**.
          //
          // Rovesciata si vede rovesciata: e' la stessa carta che si e' girata
          // in cima, e vederla dritta qui sotto direbbe una cosa diversa da
          // quella che la parola "rovesciata" scrive accanto.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 54,
                height: 81,
                child: TarotCardArt(
                  key: Key('bolla_carta_${letta.drawn.position.name}'),
                  card: letta.drawn.card,
                  palette: palette,
                  reversed: letta.drawn.reversed,
                  // Alle misure piccole i cartigli non si leggono, e lo dice
                  // il widget stesso: il nome per esteso sta gia' accanto.
                  showCartigli: false,
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(letta.drawn.position.label.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TypographyTokens.etichetta().copyWith(
                                  color:
                                      palette.goldSoft.withValues(alpha: 0.85),
                                  letterSpacing: 1.4)),
                        ),
                        if (eLaChiave) ...[
                          const SizedBox(width: SpacingTokens.xs),
                          Icon(Icons.star_rounded,
                              size: 15, color: palette.goldSoft),
                          const SizedBox(width: 4),
                          Text('LA CHIAVE',
                              style: TypographyTokens.etichetta().copyWith(
                                  color: palette.goldSoft, letterSpacing: 1.4)),
                        ],
                      ],
                    ),
                    // I vuoti passano dai token: la bolla e' nata in questo
                    // ordine e non aveva nessun diritto di portarsi dietro due
                    // misure scritte a mano.
                    const SizedBox(height: SpacingTokens.xxs),
                    Text(letta.drawn.displayName,
                        style: TypographyTokens.titoloScheda()
                            .copyWith(color: palette.goldSoft, height: 1.2)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xs),
          // **ANCHE LE ALTRE BOLLE SALGONO, ordine BU voce 01**: "anche le
          // altre bolle hanno il font piccolo".
          ParagrafiDiLettura(
              testo: letta.testo,
              stile: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textPrimary)),
          // LA MARCATURA PICCOLA CHE DICE PERCHE' E' QUELLA.
          if (eLaChiave) ...[
            const SizedBox(height: SpacingTokens.xs),
            ParagrafiDiLettura(
                testo: perche!,
                key: Key('stesa_marcatura_${letta.drawn.position.name}'),
                stile: TypographyTokens.lettura().copyWith(
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
              color: palette.surfaceElevated.withValues(alpha: 0.6),
              border: Border.all(color: palette.gold.withValues(alpha: 0.45)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icona, size: 15, color: palette.goldSoft),
                const SizedBox(width: 6),
                // **IL TESTO DEVE POTER CEDERE.** Ordine CM voce 09, famiglia A.
                Flexible(
                    child: Text(label,
                        style: TypographyTokens.didascalia()
                            .copyWith(color: palette.goldSoft))),
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

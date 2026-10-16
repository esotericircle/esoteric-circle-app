import 'dart:math';
import '../scene/la_scena_in_video.dart';

import '../maestri/widgets/foglio_delle_fonti.dart';
import 'dart:async';
import '../maestri/chat/chat_openers.dart';
import '../ricordi/azioni_del_responso.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/rituals/filo_del_giorno.dart';
import '../../core/quality/quality_tier.dart';
import '../../core/sensi/ascoltatore_scuotimento.dart';
import '../../core/maestro/maestro.dart';
import '../../core/astro/natal_chart.dart';
import '../../core/horoscope/cielo_di_oggi.dart';
import '../../core/horoscope/corrente_del_cielo.dart';
import '../horoscope/answer_depth.dart';
import '../../core/identity/natal_identity.dart';
import '../../core/chat/la_marca_del_genere.dart';
import '../../core/tarot/domanda_della_persona.dart';
import '../../core/tarot/la_lettura_dal_modello.dart';
import '../../core/tarot/tarot_reading.dart';
import '../../core/tarot/tarot_card.dart';
import '../../core/tarot/stesa_in_corso.dart';
import '../../core/astro/moon_phase.dart';
import '../../core/tarot/tarot_spread.dart';
import '../../core/tarot/tarot_topic.dart';
import '../../core/tarot/la_stesa_conservata.dart';
import '../../core/tarot/le_uscite_delle_carte.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../sigilli/celebrazione.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';
import '../../design_system/components/il_responso_in_tre_paragrafi.dart';
import '../../design_system/components/titolo_del_responso.dart';
import '../../core/tarot/le_fonti_dei_tarocchi.dart';
import '../../design_system/components/cosmos_background.dart';
import 'il_tavolo_di_medora.dart';
import 'la_scena_della_stesa_in_video.dart';
import '../../core/sensi/la_suoneria.dart';
import '../../core/settings/settings_controller.dart';
import 'attesa_di_medora.dart';
import 'stesa_choreography.dart';
import 'stesa_fan.dart';
import '../../core/tarot/i_mazzi_scaricati.dart';
import 'carta_ingrandita.dart';
import 'il_mazzo_si_scarica.dart';
import 'filo_fra_le_carte.dart';
import 'stesa_handoff.dart';
import '../sigilli/regia_del_cammino.dart';
import 'stesa_reveal.dart';
import 'stesa_senses.dart';
import 'stesa_share_card.dart';
import 'tarot_card_art.dart';
import 'tarot_selectors.dart';
import '../maestri/rotta_arte.dart';
import '../../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../core/condivisione/premio_della_condivisione.dart';
import '../../core/entitlement/entitlement_service.dart';
import '../../core/entitlement/tier.dart';
import '../../core/entitlement/question_allowance.dart';
import '../../core/entitlement/plan_catalog.dart';
import '../../core/tarot/tarot_spread_type.dart';
import '../pricing/upgrade_invite.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../design_system/components/riga_del_residuo.dart';
import '../../core/entitlement/budget_del_giorno.dart';
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
    this.chiamata,
    this.chiave,
    this.tipo,
    this.mazzo,
    this.fabbricaDellaScena,
  });

  /// **CHI COSTRUISCE IL LETTORE DEL VIDEO DELLA SCENA**, ordine FS
  /// aggiunta: nullo, quello vero; le prove ne passano uno finto, come fa il
  /// Viaggio dello Sciamano con la discesa.
  final FabbricaDellaScena? fabbricaDellaScena;

  /// **IL MAZZO DI PARTENZA**, ordine FL: nullo, il Rider-Waite; le
  /// anteprime aprono Marsiglia e Thoth senza la tendina, per guardare il
  /// tavolo nuovo con ogni mazzo. Un mazzo non scaricato si disegna col
  /// Rider-Waite, come dalla tendina.
  final TarotDeckStyle? mazzo;

  /// **LA STESA DI PARTENZA**, ordine FK aggiunta 2: nulla, la stesa a tre
  /// carte; le prove e le anteprime aprono un'altra stesa senza la tendina.
  final TarotSpreadType? tipo;

  /// La chiave di lettura di partenza. Nulla, la Predittiva; le prove e le
  /// anteprime partono da un'altra chiave senza passare dalla tendina.
  final ReadingKey? chiave;

  /// La chiamata al modello per la lettura, ordine EQ voce 04. Nulla, quella
  /// vera a Flash; le prove ne passano una finta, come fa il Sigillo.
  final ChiamataDellaStesa? chiamata;

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
    with TickerProviderStateMixin, WidgetsBindingObserver {
  /// L'ORDINE DEL MAZZO, che i gesti cambiano davvero.
  ///
  /// **Ordine 2171 voce 6.** Fino al 10 agosto 2026 Taglia e Mischia
  /// lanciavano un'animazione e basta: la stesa restava quella pescata
  /// all'apertura, qualunque cosa facesse la persona. Un gesto che non tocca
  /// il risultato non e' un rito, e' una decorazione.
  late List<int> _mazzo = TarotSpread.mazzoMescolato(seed: widget.seed);

  /// **IL SEME CHE DECIDE I VERSI, E IN PRODUZIONE E' NUOVO A OGNI STESA.**
  /// Ordine DF voce 03, 11 settembre 2026.
  ///
  /// **IL DIFETTO CHE C'ERA, e vale la pena scriverlo per esteso perche' non
  /// si vedeva da nessuna parte.** Qui il ripiego del seme era **la costante
  /// zero**, e in produzione `widget.seed` e' **sempre nullo**: la rotta della
  /// schermata lo lascia nullo e nessuno lo passa. Quindi il seme dei versi
  /// valeva **zero, sempre, per chiunque, in ogni lettura della vita
  /// dell'app**.
  ///
  /// **La riga del difetto non si cita testualmente**, ed e' una lezione di
  /// casa: la guardia che sorveglia questo punto legge il sorgente, e un
  /// commento che riporta il ripiego per esteso la farebbe cadere pescando se
  /// stesso.
  ///
  /// **Conseguenza misurata**: `TarotSpread.versoDi` calcola il verso come
  /// `Random(indiceCarta * 7919 + seme).nextDouble() < 0.30`. Con `seme`
  /// fisso a zero, **il verso di ogni carta era una costante del mazzo**: Il
  /// Mondo usciva sempre dritto, e le ventitre carte che il conto dava per
  /// rovesciate uscivano **sempre** rovesciate, per tutti, per sempre. Le
  /// rovesciate erano il ventinove virgola cinque per cento del mazzo, quindi
  /// il conto globale tornava e nessuna prova se ne accorgeva: **il numero era
  /// giusto e il fatto era falso**. E' esattamente cio' che il fondatore
  /// chiama *"estrazione pilotata"*.
  ///
  /// **Attribuzione, regola TRE dell'ordine DF.** Il campo nasce con l'ordine
  /// P voce 04, che ha portato il verso in un punto solo perche' la stessa
  /// carta non cambiasse verso a ogni ricostruzione della schermata. Quel
  /// requisito era giusto e resta: **dentro una stesa** il verso non deve
  /// cambiare. Lo sbaglio e' stato usare lo zero come ripiego invece di un
  /// numero nuovo.
  ///
  /// **ADESSO**: col seme dichiarato, cioe' nelle prove e nelle anteprime, non
  /// cambia niente ed e' riproducibile come prima. Senza, il seme nasce dal
  /// caso **una volta per schermata**, quindi dentro la stessa lettura il
  /// verso di una carta resta fermo e **fra due letture cambia**.
  late final int _seme = widget.seed ?? Random().nextInt(1 << 31);

  /// LA STESA IN CORSO, ordine P voce 04: le carte assegnate sono un DATO e
  /// non una funzione del mazzo. Prima qui c'era
  /// `TarotSpread.dalMazzo(_mazzo)`, ricalcolata dopo ogni gesto: le prime tre
  /// del mazzo corrente diventavano la stesa, quindi mischiando cambiavano le
  /// carte gia' scelte dalla persona. La legge del dominio vive in
  /// `StesaInCorso`.
  late StesaInCorso _stesa = _stesaIniziale();

  /// Vero quando le carte a schermo sono la stesa conservata di oggi su
  /// questa domanda (ordine FI voce 27): il responso e' gia' stato pagato, e
  /// la schermata lo dice.
  bool _conservata = false;

  /// La firma della stesa: il tipo e la domanda (ordine FI voce 27).
  String get _firma => LaStesaConservata.firma(_setup.tipo,
      domandaScritta: _setup.domandaScritta, argomento: _setup.topic);

  /// **LA STESA COMPIUTA SU QUESTA DOMANDA TORNA.** Finche' nessuna carta e'
  /// stata presa, se oggi su questa domanda c'e' gia' una stesa compiuta le
  /// carte tornano quelle. Le prove e le anteprime col seme dichiarato non
  /// la cercano: sono stese scritte apposta.
  Future<void> _cercaLaStesaConservata() async {
    if (widget.seed != null || widget.revealAll || _drawn > 0) return;
    final firma = _firma;
    final carte = await LaStesaConservata.ritrova(firma, _setup.tipo);
    if (!mounted || carte == null || _drawn > 0 || firma != _firma) return;
    final uscite = await LaStesaConservata.usciteDi(firma);
    if (!mounted || _drawn > 0 || firma != _firma) return;
    _uscite = uscite;
    setState(() {
      _stesa =
          StesaInCorso.conservata(carte: carte, mazzo: _mazzo, seme: _seme);
      _mazzo = List<int>.of(_stesa.mazzoResiduo);
      _drawn = carte.length;
      _scene = StesaScene.completa;
      _conservata = true;
    });
  }

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
    var stesa =
        StesaInCorso.nuova(mazzo: _mazzo, seme: _seme, posizioni: _posizioni);
    if (!widget.revealAll) return stesa;
    // Con revealAll la stesa nasce gia' compiuta e non c'e' nessuna attesa da
    // aspettare: il responso e' pronto da subito.
    _responsoPronto = true;
    // Ordine BN voce 02: si assegnano le prime posizioni dell'arco, e non tre
    // volte la posizione zero, che dalla cura non esiste piu' dopo la prima.
    for (var i = 0; i < _posizioni.length; i++) {
      stesa = stesa.assegnaAlPosto(i, dalVentaglio: i);
    }
    return stesa;
  }

  /// Le carte gia' assegnate, per le parti della schermata che le leggono.
  TarotSpread get _spread => TarotSpread([
        for (var i = 0; i < _posizioni.length; i++)
          _stesa.assegnate[i] ??
              DrawnCard(
                card: TarotDeck.cards[_stesa.mazzoResiduo.isEmpty
                    ? 0
                    : _stesa.mazzoResiduo[i % _stesa.mazzoResiduo.length]],
                position: _posizioni[i],
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

  /// Le uscite con cui la lettura di casa sceglie le varianti (voce FI.18),
  /// per la guardia della rotazione.
  @visibleForTesting
  List<int>? get usciteCorrenti => _uscite;

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

  /// **LO SCORRIMENTO TORNA IN CIMA DOPO LA RIFLESSIONE. Ordine FN, 13
  /// ottobre 2026.** Il fondatore: dopo il tocco sul pulsante e dopo
  /// l'animazione di riflessione, la schermata deve risalire per mostrare
  /// Medora, il tavolo e le carte che si alzano in verticale, invece di
  /// restare dove l'utente l'aveva lasciata scorrendo.
  final ScrollController _scorrimento = ScrollController();

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
  /// **IL SIGNIFICATO GENERICO DELLA CARTA, ordine FK aggiunta voce A4.** Il
  /// fondatore: "se fai click sulle carte in alto si apre in sovrimpressione e
  /// ripete il testo scritto, mentre invece dovrebbe riportare il significato
  /// generico della Carta". **LAPIDE: "il testo mostrato e' PosizioneLetta.testo,
  /// lo stesso della bolla"**: la carta aperta ripeteva la lettura che sta gia'
  /// sotto. Adesso porta la voce della fonte dei significati nel suo verso
  /// (`DrawnCard.meaning`, da `tarot_card.dart`), come la carta di nascita del
  /// Passaporto.
  Future<void> _apriLaCarta(int slot) async {
    final lette = _reading.posizioni;
    if (slot < 0 || slot >= lette.length) return;
    _sensi.momento(context, MomentoSensoriale.flip);
    final letta = lette[slot];
    await mostraLaCartaIngrandita(
      context,
      letta: PosizioneLetta(
        drawn: letta.drawn,
        apertura: letta.apertura,
        testo: letta.drawn.meaning,
      ),
      palette: MaestroPalette.forKey(const ThemeKey.of(Maestro.medora)),
      mazzo: _setup.deck,
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

  /// Riprende l'ambiente quando il gesto e' finito.
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
  ///
  /// **E DAL 10 SETTEMBRE 2026 NESSUNO LO CHIEDE PIU'. Ordine DD voce 08.**
  /// Questo fatto reggeva il blocco montato SOTTO il pulsante, quello che
  /// riordinava la pagina. Adesso il blocco di sopra resta fino al responso e
  /// i pezzi stanno dove stavano: il momento fra l'ultima carta e la
  /// riflessione non ha piu' bisogno di una scena sua, perche' e' la stessa
  /// scena di prima con una carta in piu'.
  ///
  /// **Non si cancella**, perche' il fatto resta vero e nominato in tre
  /// commenti di questo file: e' l'istante che il fondatore ha visto tre
  /// volte, e la storia di come e' stato chiuso vive attaccata a lui.
  // ignore: unused_element
  bool get _carteDopoLUltima => _complete && !_responsoPronto;

  /// Vero dal momento in cui Medora ha finito di pensare: da li' in poi il
  /// responso puo' stare in albero, e prima no.
  bool _responsoPronto = false;

  /// L'istante di ogni responso mostrato: la chiave nel Diario.
  final _istanti = IstantiDeiResponsi();

  /// **LA LETTURA SCRITTA DAL MODELLO, ordine EQ voce 04.** Parte al tocco su
  /// "Leggi le Carte" e Medora la aspetta dentro la sua scena; nulla finche'
  /// non arriva, o se non regge: allora parla la lettura di casa.
  Future<LetturaDelModello?>? _letturaInArrivo;
  LetturaDelModello? _dalModello;

  /// Dal tocco su "Leggi le Carte" al testo, per il registro: e' l'attesa
  /// che il rapporto dell'ordine EQ misura sul telefono.
  final Stopwatch _dalTocco = Stopwatch();

  /// **IL FILO FRA LE TRE CARTE, ordine BN voce 08.** Corre una volta sola,
  /// fra la terza carta e l'inizio dell'attesa.
  late final AnimationController _filo =
      AnimationController(vsync: this, duration: FiloFraLeCarte.durata);

  // **LA SEQUENZA DEL TAVOLO, ordine FL voce 05.** Il fondatore: "dopo
  // l'animazione di riflessione, le carte si girano sul tavolo una alla volta
  // e dopo un secondo dall'ultima girata, si mettono in verticale
  // ingrandendosi per rendersi ben visibile all'utente". [_giro] gira la
  // carta di turno, [_alzo] le alza tutte insieme dal piano alla fila.
  late final AnimationController _giro = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 520));
  late final AnimationController _alzo = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 750));

  /// Quante carte si sono gia' girate sul tavolo.
  int _carteGirate = 0;

  /// Vero quando le carte sono in piedi: con [StesaTreCarteScreen.revealAll]
  /// la stesa nasce gia' compiuta, e la sequenza anche.
  late bool _sequenzaFatta = widget.revealAll;

  /// L'attesa fra l'ultima carta girata e le carte che si alzano: un secondo,
  /// come l'ha detto il fondatore.
  static const Duration attesaPrimaDiAlzarsi = Duration(seconds: 1);

  /// **LE ATTESE DELLA SEQUENZA SI CANCELLANO**: se la schermata si chiude a
  /// meta' sequenza, nessun timer resta appeso dopo di lei.
  final Set<Timer> _timerDelTavolo = {};

  Future<void> _attendi(Duration quanto) {
    final fatto = Completer<void>();
    late final Timer t;
    t = Timer(quanto, () {
      _timerDelTavolo.remove(t);
      fatto.complete();
    });
    _timerDelTavolo.add(t);
    return fatto.future;
  }

  /// La pila della schermata, per sapere dove sta un posto del tavolo.
  final GlobalKey _chiaveDellaPila = GlobalKey(debugLabel: 'stesa_pila');

  /// **LE CARTE SI GIRANO UNA ALLA VOLTA, POI SI ALZANO.** Con il movimento
  /// ridotto la sequenza non si recita: le carte sono gia' in piedi.
  /// **TORNA IN CIMA, DOVE STANNO MEDORA E IL TAVOLO.** Ordine FN, 13
  /// ottobre 2026: appena finita la riflessione, prima che le carte
  /// comincino a girarsi e ad alzarsi, lo scorrimento risale, cosi' chi ha
  /// letto le carte scorrendo in basso l'animazione non se la perde.
  void _risaliInCima() {
    if (!_scorrimento.hasClients) return;
    if (_reduceMotion) {
      _scorrimento.jumpTo(0);
    } else {
      unawaited(_scorrimento.animateTo(0,
          duration: const Duration(milliseconds: 400), curve: Curves.easeOut));
    }
  }

  Future<void> _laSequenzaDelTavolo() async {
    if (!mounted || _sequenzaFatta) return;
    if (_reduceMotion) {
      setState(() {
        _carteGirate = _posizioni.length;
        _sequenzaFatta = true;
      });
      return;
    }
    for (var i = 0; i < _posizioni.length; i++) {
      if (!mounted) return;
      _sensi.momento(context, MomentoSensoriale.flip);
      await _giro.forward(from: 0);
      if (!mounted) return;
      setState(() => _carteGirate = i + 1);
      _giro.value = 0;
      unawaited(_fiorisci(i));
      await _attendi(const Duration(milliseconds: 160));
    }
    await _attendi(attesaPrimaDiAlzarsi);
    if (!mounted) return;
    await _alzo.forward(from: 0);
    if (!mounted) return;
    setState(() => _sequenzaFatta = true);
  }

  /// Quanto e' girata la carta del posto [i] sul tavolo.
  double _girataDi(int i) {
    if (_sequenzaFatta || i < _carteGirate) return 1;
    if (i == _carteGirate) return _giro.value;
    return 0;
  }

  /// **DOVE ARRIVA LA CARTA IN VOLO**: il centro del suo posto sul tavolo,
  /// nelle coordinate della pila. Nulla se la scena non e' ancora disegnata.
  Offset? _arrivoSulTavolo(int posto) {
    final scena = _chiaveDegliSlot.currentContext?.findRenderObject();
    final pila = _chiaveDellaPila.currentContext?.findRenderObject();
    if (scena is! RenderBox || pila is! RenderBox || !scena.hasSize) {
      return null;
    }
    if (posto < 0 || posto >= _posizioni.length) return null;
    final w = scena.size.width;
    final sulPiano = GeometriaDelTavolo.carteSulPiano(_setup.tipo.tavolo, w);
    final centro = sulPiano.angoli[posto] +
        Offset(sulPiano.larghezza / 2,
            sulPiano.larghezza / kAspettoDellaCarta / 2);
    final nellaScena = GeometriaDelTavolo.proietta(centro, w);
    return pila.globalToLocal(scena.localToGlobal(nellaScena));
  }

  /// Vero mentre il filo e' in scena.
  bool _filoInScena = false;

  /// Quante stese sono state chiuse in questa sessione: sposta il punto di
  /// partenza delle righe dell'attesa, cosi' due stese vicine non aprono sulla
  /// stessa frase.
  int _giroDellAttesa = 0;

  /// Quante carte sono gia' state pescate, da 0 a 3.
  late int _drawn = widget.revealAll ? _posizioni.length : 0;

  /// Quali carte del ventaglio sono gia' state prese.
  final Set<int> _taken = {};

  final GlobalKey _cardKey = GlobalKey();
  bool _renderCard = false;

  /// I selettori prima della stesa. Le voci non pronte restano Coming soon.
  late TarotSetup _setup = TarotSetup(
      tipo: widget.tipo ?? TarotSpreadType.predefinita,
      topic: widget.topic ?? TarotTopic.predefinito,
      key: widget.chiave ?? ReadingKey.predittiva,
      deck: widget.mazzo ?? TarotDeckStyle.riderWaite);

  /// **LE POSIZIONI DELLA STESA SCELTA**, ordine FK aggiunta 2 voce A10: la
  /// schermata stende quello che la stesa dichiara, non tre carte fisse.
  /// LAPIDE: "SpreadPosition.treCarte" in quindici punti di questo file.
  List<SpreadPosition> get _posizioni => _setup.tipo.posizioni;

  /// **QUANTE CARTE, IN PAROLE, dalla stesa scelta. Ordine FS.** Il
  /// fondatore, sulla Croce Celtica: sotto il pannello si leggeva "Scegli
  /// tre carte dal ventaglio" anche con dieci. Era scritto a mano in quattro
  /// punti (l'invito, la riga sotto il pulsante, il titolo nel Diario e il
  /// testo della condivisione); adesso viene dal nome corto della stesa.
  String get _quanteCarte => _setup.tipo.breve.toLowerCase();

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
      domandaScritta: _setup.domandaScritta,
      dalModello: _dalModello,
      uscite: _uscite);

  /// **LE USCITE DI OGNI CARTA, ordine FI voce 18**: quante volte ognuna
  /// era gia' uscita a questa persona in quella posizione, che sceglie la
  /// variante del suo testo. Nulla prima del responso: vale la prima.
  List<int>? _uscite;

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
    // **"ALLEGGERISCI GRAFICA" FERMA IL GALLEGGIO ANCHE LUI. Ordine FN, 13
    // ottobre 2026.** Il fondatore: lo scorrimento resta a scatti "anche se
    // seleziono riduci animazione e alleggerisci grafica". Il tier basso del
    // `QualityTierController` non veniva mai letto qui: solo il Riduci
    // Movimento di sistema fermava il galleggiamento e il tilt del
    // giroscopio. Adesso i due si sommano, come gia' fa `osserva: true`
    // altrove in questa schermata per il tier.
    final tierBasso =
        _forse<QualityTierController>(context, osserva: true)?.tier ==
            QualityTier.low;
    _reduceMotion = MediaQuery.of(context).disableAnimations || tierBasso;
    if (_avviata) return;
    _avviata = true;
    // I mazzi gia' scaricati si leggono dal telefono, senza rete (ordine FJ
    // voce 12): poi la faccia della carta sa subito se disegnarli.
    unawaited(IMazziScaricati.diCasa.leggiIInstallati().then((_) {
      if (mounted) setState(() {});
    }));
    _shake = AscoltatoreScuotimento(onScuotimento: _mischia)..start();
    // Il giroscopio solo se il moto e' concesso: con Riduci Movimento le
    // carte stanno ferme e composte.
    //
    // **IL GALLEGGIAMENTO TORNA, E NON COSTA. Ordine FS, 13 ottobre 2026.**
    // LAPIDE: "IL GALLEGGIAMENTO E' TOLTO" (ordine FR, che lo diceva FQ).
    // Il costo non era il galleggiamento in se': era che ogni suo
    // fotogramma passava da `Listenable.merge` in `_laScena` e ricostruiva
    // l'intero `TavoloDiMedora`, immagine, Medora e dieci carte. Il
    // fondatore preferisce le carte che fluttuano, se lo scorrimento resta
    // fluido: adesso ogni carta in piedi ha un suo animatore piccolo
    // (`_Fluttua`) che sposta soltanto il livello gia' dipinto della carta
    // (`RepaintBoundary`), senza ricostruire ne' ridipingere niente.
    // Gia' a responso in scena (la stesa che si apre gia' fatta) il
    // giroscopio non parte: vedi `TiltListener.ferma`, ordine FS.
    if (!_reduceMotion && !_responsoPronto) {
      _tilt.start();
    }
    if (!_reduceMotion) _galleggio.repeat();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_apriIlFilmato());
    _apriScena();
    unawaited(_cercaLaStesaConservata());
  }

  /// **IL VIDEO DELLA SCENA, una volta per apertura.** Ordine FS aggiunta,
  /// voce FS.A2, 14 ottobre 2026: aprendo la Stesa, al posto della scena
  /// ferma parte il video del vortice, nello stesso riquadro e con lo stesso
  /// taglio, e si ferma sull'ultimo fotogramma. Si apre qui, dove la
  /// schermata si avvia una volta sola: una stesa rifatta nella stessa visita
  /// non lo rifa' partire. Con Riduci Movimento (o il tier basso, che qui
  /// vale lo stesso) il video non si apre e la scena e' ferma, con la posa
  /// dell'invito.
  LettoreDellaScena? _lettoreDellaScena;

  /// Vero quando il video l'ha fermato l'uscita dall'app, e va ripreso al
  /// ritorno.
  bool _filmatoSospesoDaNoi = false;

  /// **IL VIDEO SALTATO COL TOCCO**, ordine FU voce FU.15.
  bool _filmatoSaltato = false;

  /// Il video gira: un tocco in qualunque punto lo fa sfumare.
  bool get _videoInCorso {
    final l = _lettoreDellaScena;
    return !_filmatoSaltato && l != null && l.pronto && !l.finito && !l.fallito;
  }

  /// **LA SCENA E' FERMA**, ordine FX voce FXA.08: il video non c'e' (Riduci
  /// Movimento, grafica alleggerita), non si e' caricato, e' finito o e'
  /// stato saltato. Finche' e' falso, cioe' mentre il video si prepara o
  /// gira, sopra la scena si vede solo il video ([IlRestoDopoLaScena]).
  bool get _scenaFerma {
    final l = _lettoreDellaScena;
    return l == null || l.fallito || l.finito || _filmatoSaltato;
  }

  void _saltaIlVideo() {
    if (!_videoInCorso) return;
    setState(() => _filmatoSaltato = true);
    unawaited(_lettoreDellaScena?.sospendi());
  }

  Future<void> _apriIlFilmato() async {
    if (_reduceMotion) return;
    final lettore = (widget.fabbricaDellaScena ?? LettoreDellaScena.vero)();
    _lettoreDellaScena = lettore;
    lettore.ascolta(() {
      if (mounted) setState(() {});
    });
    await lettore.apri();
    if (!mounted ||
        !identical(_lettoreDellaScena, lettore) ||
        !lettore.pronto) {
      return;
    }
    // **L'AUDIO RISPETTA L'APP E IL TELEFONO.** L'interruttore e' quello di
    // suono e vibrazione, lo stesso dell'intro, che e' l'altro video con
    // l'audio: chi l'ha spento non sente niente. E il telefono in silenzioso
    // o in vibrazione tace anche lui (`LaSuoneria`). Il volume si dice prima
    // di partire.
    final suono =
        _forse<SettingsController>(context)?.suonoEVibrazione ?? false;
    final muto = !suono || await LaSuoneria.spenta();
    if (!mounted) return;
    await lettore.volume(muto ? 0 : 1);
    if (!mounted || !identical(_lettoreDellaScena, lettore)) return;
    await lettore.avvia();
  }

  /// **USCENDO DALL'APP IL VIDEO SI FERMA**, e al ritorno riprende da dove
  /// era, se non era gia' finito: un video che corre senza nessuno che lo
  /// guarda arriva alla fine da solo, e chi torna trova la scena gia' ferma.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final lettore = _lettoreDellaScena;
    if (lettore == null ||
        !lettore.pronto ||
        lettore.finito ||
        _filmatoSaltato) {
      return;
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      if (_filmatoSospesoDaNoi) return;
      _filmatoSospesoDaNoi = true;
      unawaited(lettore.sospendi());
    } else if (state == AppLifecycleState.resumed && _filmatoSospesoDaNoi) {
      _filmatoSospesoDaNoi = false;
      unawaited(lettore.avvia());
    }
  }

  /// Il video in scena, se e' cominciato; nullo, la scena ferma.
  Widget? get _filmatoInScena {
    final l = _lettoreDellaScena;
    if (l == null || l.fallito || !l.cominciato) return null;
    return l.disegna();
  }

  /// La posa di Medora a scena ferma: col mazzo chiuso, che e' il primo
  /// fotogramma, finche' il video si prepara; nell'invito, che e'
  /// l'ultimo, se il video non c'e' (Riduci Movimento) o non si carica.
  String get _posaDiMedora {
    final l = _lettoreDellaScena;
    return l == null || l.fallito || _filmatoSaltato
        ? GeometriaDelTavolo.posaDellInvito
        : GeometriaDelTavolo.posaDelMazzo;
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
    WidgetsBinding.instance.removeObserver(this);
    _lettoreDellaScena?.chiudi();
    _lettoreDellaScena = null;
    for (final t in _timerDelTavolo) {
      t.cancel();
    }
    _giro.dispose();
    _alzo.dispose();
    _filo.dispose();
    _tilt.dispose();
    _reveal.dispose();
    _galleggio.dispose();
    _scorrimento.dispose();
    _shake?.dispose();
    _handoff.dispose();
    _ingresso.dispose();
    _respiro.dispose();
    _taglio.dispose();
    _mescola.dispose();
    _volo.dispose();
    super.dispose();
  }

  bool get _complete => _drawn >= _posizioni.length;

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
      // Il posto e non la posizione, ordine FK aggiunta 2 voce A8: i due
      // `lato` della croce sono due posti.
      _stesa = _stesa.assegnaAlPosto(slot, dalVentaglio: fanIndex);
      _mazzo = List<int>.of(_stesa.mazzoResiduo);
      _drawn++;
      if (_complete) _scene = StesaScene.completa;
      // **IL PANNELLO SI CHIUDE ALLA PRIMA CARTA.** Richiesta del fondatore,
      // ordine FN, 13 ottobre 2026: scelta la prima carta, "Scegli la tua
      // stesa" deve chiudersi da solo per lasciare vedere il tavolo e il
      // ventaglio intero, non restare aperto sopra di loro.
      if (slot == 0) _setupAperto = false;
    });
    // Il flip, poi la fioritura dell'elemento: la carta si scopre e il suo
    // seme parla un istante, prima di lasciarla pulita e leggibile.
    // **LA CARTA SI POSA COPERTA SUL TAVOLO, ordine FL voce 05.** LAPIDE:
    // "il flip, poi la fioritura dell'elemento" a ogni presa. Adesso si
    // sente la carta che si posa, e la fioritura arriva quando la carta si
    // gira sul tavolo, dopo il pulsante.
    _sensi.momento(context, MomentoSensoriale.flip);
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
    // La stesa conservata e' gia' stata pagata quando si e' aperta la prima
    // volta: rileggerla non spende carte (ordine FI voce 27).
    if (!_conservata && !_laStesaSiPuoAprire(riprova: _apriIlResponso)) {
      return;
    }
    if (!_conservata && widget.seed == null && !widget.revealAll) {
      // Si contano le uscite una volta sola, qui, e si conservano con la
      // stesa: rileggerla ritrova le stesse varianti (voce FI.18).
      final firma = _firma;
      final carte = _spread.cards;
      unawaited(LeUsciteDelleCarte.conta(carte).then((uscite) {
        if (mounted) setState(() => _uscite = uscite);
        return LaStesaConservata.conserva(firma, carte, uscite: uscite);
      }));
    }
    // **LA LETTURA PARTE QUI, ordine EQ voce 04**, al gesto che la chiede e
    // prima del filo e della scena di Medora: sono circa cinque secondi, e la
    // chiamata a Flash ci sta quasi sempre dentro. Non si aspetta qui, si
    // aspetta in `_medoraCiPensa`.
    _dalTocco
      ..reset()
      ..start();
    final sua = DomandaDellaPersona.pulita(_setup.domandaScritta);
    _letturaInArrivo = LaLetturaDellaStesa.leggi(
      spread: _spread,
      domanda: sua ?? _setup.topic.label,
      argomento: _setup.topic.label,
      gruppo: _setup.topic.group,
      forma: LaMarcaDelGenere.formaCorrente,
      chiave: _setup.key,
      chiamata: widget.chiamata,
      // **LA PROFONDITA' ARRIVA AL MODELLO, ordine FN, 13 ottobre 2026.**
      // Prima la Lunga non cambiava niente: il parametro c'era, si salvava
      // nei dati, e nessuna chiamata lo leggeva.
      profonda: _setup.depth == AnswerDepth.profonda,
    );
    // Lo stesso momento sensoriale che l'ordine CO voce 07 aveva messo
    // sull'avvio: cambia il posto del pulsante, non cosa si sente premendolo.
    // **Senza suono dal 1 ottobre 2026**, ordine EU voce 03: alla pressione
    // dell'invio non suona niente, resta la vibrazione.
    unawaited(
        PaletteSensoriale.momento(context, aptica: SchemaAptico.conferma));
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
    if (borsa != null && !_conservata) {
      // **LE CARTE, NON LA STESA**, ordine EX voce 02: si contano tutte le
      // carte della stesa letta.
      borsa.registraStesa(
          _forse<EntitlementService>(context)?.tier ?? Tier.free,
          carte: _spread.cards.length);
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
    final carte = _spread.cards.length;
    if (borsa.puoiStendere(piano, carte: carte)) return true;
    final limite = borsa.limiteStese(piano);
    final restano = borsa.steseRimaste(piano) ?? 0;
    // Il numero del livello dopo, letto dalla matrice: all'Illuminato non c'e'
    // un livello dopo, e la frase non promette niente.
    const ordine = [Tier.free, Tier.tier1, Tier.tier2, Tier.tier3];
    final dopo = ordine.indexOf(piano) + 1;
    final piuInSu = dopo < ordine.length
        ? PlanCatalog.limiteGiornaliero(PlanCatalog.rigaStese, ordine[dopo])
        : null;
    // **IL RISCATTO COMPRA LE CARTE CHE MANCANO A QUESTA STESA.** Un
    // riscatto ridà tre carte (`QuestionAllowance.kCarteDelRiscatto`), e la
    // Croce Celtica ne chiede dieci: col riscatto unico il pagamento andava,
    // il cancello sbarrava di nuovo e il foglio si riapriva, 150 Eos a giro.
    // Adesso se ne comprano quanti servono, sotto un consenso solo, e il
    // pulsante dice quante carte e quanti Eos. Guardia:
    // `test/il_riscatto_copre_la_croce_celtica_test.dart`.
    //
    // **LA STESA INTERA, decisione del fondatore del 14 ottobre 2026** ("2
    // 400 EOS"): se il server manda nel listino il riscatto della stesa
    // intera e costa meno dei riscatti da tre, la Croce Celtica si riscatta
    // con UN riscatto che ridà le sue dieci carte, al prezzo del server. Un
    // server che non lo manda lascia la strada dei riscatti in fila.
    final intera = borsa.laStesaSiRiscattaIntera(piano, carte: carte);
    final volte = intera ? 1 : borsa.riscattiPerLaStesa(piano, carte: carte);
    final mancano = carte - restano;
    final descrizione =
        (widget.tipo ?? TarotSpreadType.predefinita).descrizione;
    final cosa = intera
        ? '${descrizione.substring(0, 1).toLowerCase()}'
            '${descrizione.substring(1)}'
        : volte <= 1 && carte <= QuestionAllowance.kCarteDelRiscatto
            ? 'una stesa completa'
            : mancano >= carte
                ? 'le $carte carte'
                : 'le $mancano carte che mancano';
    final messaggero = ScaffoldMessenger.maybeOf(context);
    final riscatto = corredoDelRiscatto(
      context,
      budget: intera ? QuestionAllowance.kRiscattoDellaStesaIntera : 'stese',
      cosaUna: cosa,
      riscatti: volte,
      onSuccesso: (pagato) {
        if (!mounted) return;
        // **SI RIPROVA SOLO SE ADESSO SI PUO'.** Richiamare la lettura alla
        // cieca era il giro: il cancello sbarrava e riapriva il foglio. Se il
        // riscatto si e' fermato a meta', lo si dice e il foglio resta chiuso.
        if (borsa.puoiStendere(piano, carte: carte)) {
          riprova();
          return;
        }
        final ora = borsa.steseRimaste(piano) ?? 0;
        messaggero?.removeCurrentSnackBar();
        messaggero?.showSnackBar(SnackBar(
          key: const Key('riscatto_non_basta'),
          content: Text('Spesi $pagato Eos, ma le carte non bastano ancora: '
              'ne hai $ora e questa stesa ne chiede $carte. Le carte '
              'comprate restano tue per oggi, riprova fra un momento.'),
        ));
      },
    );
    showUpgradeInvite(
      context,
      // **DUE SITUAZIONI DIVERSE MERITANO DUE FRASI DIVERSE.** Un piano che
      // le stese complete le compra in Eos non ha "finito" niente: non aveva
      // niente da finire, e dirgli che il giorno e' esaurito sarebbe falso.
      // **I NUMERI VERI, ordine EX voce 02.** Le frasi di prima dicevano
      // "dall'Illuminato le stese sono senza limiti" (l'Illuminato ne aveva
      // venti) e prevedevano un piano a zero stese che non esiste piu'.
      title: restano > 0
          ? 'Le carte di oggi non bastano'
          : 'Le carte di oggi sono finite',
      message: [
        restano > 0
            ? 'Ti ${restano == 1 ? 'resta una carta' : 'restano $restano carte'} '
                'e questa stesa ne chiede $carte.'
            : 'Le ${limite ?? 0} carte del giorno sono state estratte.',
        piuInSu == null
            ? 'Puoi riscattare ${intera || volte > 1 ? cosa : 'una stesa'} '
                'con gli Eos, oppure tornare domani.'
            : 'Puoi riscattare ${intera || volte > 1 ? cosa : 'una stesa'} '
                'con gli '
                'Eos, oppure salire di '
                'livello nel Cerchio: dal livello successivo le carte del '
                'giorno sono $piuInSu.',
      ].join(' '),
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
  /// **LAPIDE: "la lettura e' deterministica e locale, quindi non aspetta
  /// nessuna rete".** Dall'ordine EQ voce 04 la scena aspetta anche la
  /// lettura del modello, partita al tocco su "Leggi le Carte": resta il
  /// minimo garantito, e oltre il minimo resta finche' la lettura arriva, al
  /// massimo per la pazienza di `LaLetturaDellaStesa`. Non puo' restare a
  /// girare: `leggi` non fallisce mai, torna nulla, e allora parla la lettura
  /// di casa.
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
    final minimo = Future<void>.delayed(
        AttesaDiMedora.minimaPer(riduciMovimento: _reduceMotion));
    final inArrivo = _letturaInArrivo;
    if (inArrivo == null) {
      await minimo;
    } else {
      final esiti = await Future.wait<Object?>([minimo, inArrivo]);
      _dalModello = esiti[1] as LetturaDelModello?;
      // Il registro dice quanto si e' aspettato e da dove viene il testo: e'
      // la misura che il rapporto dell'ordine EQ legge sul telefono.
      debugPrint('STESA TEMPI: testo a ${_dalTocco.elapsedMilliseconds} ms '
          'dal tocco, lettura '
          '${_dalModello != null ? 'del modello' : 'di casa (${LaLetturaDellaStesa.ultimoScarto})'}'
          '${LaLetturaDellaStesa.ultimaCurata ? ', curata' : ''}'
          '${LaLetturaDellaStesa.ultimaRiscritta ? ', riscritta' : ''}'
          ', chiamate ${LaLetturaDellaStesa.ultimiTentativi}, riserve '
          '${LaLetturaDellaStesa.ultimeRiserve}, riscritture '
          '${LaLetturaDellaStesa.ultimeRiscritture}');
    }
    if (!mounted) return;
    // La scena non sparisce di colpo: si dissolve, e il responso e' gia' sotto
    // di lei quando comincia a sparire. Nessuna parola viene tagliata.
    // Il responso nasce QUI, sotto il velo che comincia ad andarsene: non un
    // istante prima, o torna il lampo.
    setState(() {
      _attesa = StatoDellAttesa.inUscita;
      _responsoPronto = true;
    });
    // **A RESPONSO IN SCENA IL GIROSCOPIO TACE, ordine FS.** Le carte si
    // alzano e si leggono scorrendo: ogni segnale del sensore ricostruiva
    // l'intero tavolo con le dieci carte in piedi, a scatti sotto il dito.
    _tilt.ferma();
    await Future<void>.delayed(AttesaDiMedora.dissolvenza);
    if (!mounted) return;
    _stoPerRiflettere = false;
    setState(() => _attesa = StatoDellAttesa.assente);
    _risaliInCima();
    unawaited(_laSequenzaDelTavolo());
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

    // IL TOCCO CHE SALTA IL VIDEO, ordine FU voce FU.15, punto unico.
    return IlToccoCheSalta(
      inCorso: _videoInCorso,
      onSalta: _saltaIlVideo,
      child: IlMazzoDellaStesa(
        mazzo: _setup.deck,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            // **SEMITRASPARENTE, non trasparente.** Il fondatore, 13 ottobre
            // 2026: la barra del titolo deve avere un velo, come nel resto
            // dell'app (vedi ad esempio `settings_screen.dart`,
            // `domain_screen.dart`). Con `Colors.transparent` la barra si
            // confondeva del tutto col cosmo sotto; ora porta lo stesso velo
            // di `palette.deepest` delle altre schermate.
            //
            // **IL VELO SI ALLEGGERISCE, 14 ottobre 2026.** Il fondatore: la
            // barra deve essere gia' semitrasparente all'apertura (non solo
            // scorrendo), cosi' il video di Medora che fa volare le carte si
            // vede piu' completo sotto di lei. Il velo era costante (mai legato
            // allo scorrimento), ma a 0,35 contro la scena scura dell'apertura
            // si leggeva quasi pieno; sceso a 0,16 la trama del video resta
            // visibile sotto il titolo fin dal primo fotogramma, e il titolo
            // resta leggibile.
            backgroundColor: palette.deepest.withValues(alpha: 0.16),
            elevation: 0,
            // **E RESTA SEMITRASPARENTE ANCHE SCORRENDO, ordine FS.** Il
            // fondatore sulla 2308: "la barra non e' semitrasparente". Per
            // Material 3 una barra con qualcosa che le scorre sotto prende
            // un'ombra e la tinta della superficie, e diventa piena: qui la
            // tinta resta il velo di `palette.deepest`.
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
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
            // **SU UNA RIGA. Ordine EQ voce 11.** Sull'iPhone 17 Pro "Stesa di
            // Tarocchi" andava su due righe nella testata: a una riga la
            // misura scende quanto serve, entro il minimo del titolo.
            title: TitoloCheNonSiRompe(
                chiaveDelTesto: const Key('stesa_titolo'),
                testo: _setup.tipo.nome,
                righe: 1,
                stile: TypographyTokens.titoloSezione()),
            // IL BORSELLINO, ordine S voce 06: stesso segno, stesso angolo, in
            // ogni schermata della pratica. Un saldo che appare e scompare non
            // si impara.
            // **LA FONTE ARRIVA A CHI LEGGE.** Ordine CS, voce S2 della
            // scansione: il mazzo Rider-Waite-Smith e la stesa a tre carte non erano dichiarati.
            actions: [
              FoglioDelleFonti.bottone(context,
                  palette: palette,
                  // **IL MAZZO E LA STESA DI QUESTA LETTURA**, ordine FK
                  // aggiunta voce A5: era `TestiDelleFonti.tarocchi`, lo stesso
                  // testo per ogni stesa e ogni mazzo.
                  testo: LeFontiDeiTarocchi.testo(_setup.deck, _setup.tipo),
                  chiave: 'tarocchi_fonti'),
              const AngoloDellaBarra(),
            ],
          ),
          // **IL COSMO TORNA, ordine FR voce 01, 13 ottobre 2026.** LAPIDE:
          // il gradiente piatto qui sotto era "LO SFONDO NUOVO" dell'ordine FL
          // voce 01 (12 ottobre 2026), scelto per far sfumare senza stacco il
          // drappo del tavolo (`TavoloDiMedora`) nel fondo della pagina. Il
          // fondatore, a video sulla build 2307: "non c'e' sfondo cosmico in
          // parallasse che c'e' in tutta l'app". Altre schermate con un
          // elemento fisico in primo piano (`rune_draw_screen.dart`,
          // `guide_animal_screen.dart`) mostrano gia' che `CosmosBackground`
          // convive bene con un tavolo o un'immagine sopra: la scelta FL non
          // era necessaria alla coerenza visiva, e questa voce la ribalta.
          // `CosmosBackground` porta gia' nel suo primo strato un gradiente
          // verticale scuro (da `palette.deepest`), quindi il tavolo continua
          // a posarsi su un fondo scuro coerente, con le stelle in parallasse
          // sopra invece del nero piatto.
          body: CosmosBackground(
            key: const Key('stesa_sfondo'),
            seed: 5,
            showZodiac: false,
            // **IL CONTENUTO PASSA SOTTO LA BARRA, ordine FS.** Con l'area
            // sicura anche in alto la lista cominciava sotto la barra e non ci
            // passava mai sotto, e il velo semitrasparente non si vedeva: si
            // vedeva solo il cosmo fermo. Il margine alto adesso sta dentro la
            // lista (`_content`), e scorrendo il tavolo e le carte passano
            // sotto la barra.
            child: SafeArea(
              top: false,
              child: Stack(
                key: _chiaveDellaPila,
                children: [
                  // **IL MARGINE ALTO SI LEGGE DENTRO IL CORPO**, ordine FS:
                  // il contesto della schermata sta sopra lo `Scaffold` e non
                  // conosce l'altezza della barra; quello del corpo si'.
                  Builder(
                    builder: (corpo) =>
                        _content(palette, MediaQuery.paddingOf(corpo).top),
                  ),
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
                        arrivo: _arrivoSulTavolo(_drawn),
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
                        //
                        // **LA LETTURA DEL MODELLO ENTRA SOLO SENZA DOMANDA
                        // SCRITTA. Ordine EQ voce 04.** Risponde alla domanda, e
                        // per la stessa ragione di qui sopra la card non la
                        // porta; senza domanda scritta e' la stessa che si legge
                        // in cima al responso, e la card non la contraddice.
                        child: StesaShareCard(
                          spread: _spread,
                          palette: palette,
                          topic: _reading.topic,
                          lettura: DomandaDellaPersona.pulita(
                                      _setup.domandaScritta) ==
                                  null
                              ? _dalModello
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// **LA SCENA**, larga quanto lo schermo anche se la lista ha i suoi
  /// margini: lo sfondo non si ferma a sedici punti dal bordo. E' alta fino
  /// al bordo davanti del tavolo; il drappo scende sotto il selettore e ci
  /// sfuma dietro (ordine FL voce 02: "subito sotto il tavolo il selettore").
  Widget _laScena(MaestroPalette palette) {
    return LayoutBuilder(builder: (context, vincoli) {
      final w = vincoli.maxWidth + 2 * SpacingTokens.lg;
      final s = GeometriaDelTavolo.scala(w);
      // A carte in piedi la scena si allunga fino sotto le loro scritte:
      // il titolo del responso comincia dopo, non sopra le etichette.
      final fila = GeometriaDelTavolo.fila(_setup.tipo.tavolo, w);
      final sottoLaFila = fila.zona.bottom +
          _Slot.distanzaDellaScritta +
          _Slot.altezzaDellEtichetta(context) * (fila.righe > 1 ? 2 : 1) +
          SpacingTokens.md;
      // **FINO A DOVE IL TAVOLO E' SPARITO, ordine FS.** Era il bordo
      // davanti del velluto, e il drappo sotto passava dietro il pannello
      // "Scegli la tua stesa": il fondatore lo ha visto come il pannello
      // sopra il tavolo. Adesso il pannello comincia dove l'immagine e' gia'
      // sfumata nel cosmo.
      final alta = math.max(
          (GeometriaDelTavolo.fineDellaSfumatura -
                  GeometriaDelTavolo.taglioInAlto) *
              s,
          _responsoPronto ? sottoLaFila : 0.0);
      return SizedBox(
        height: alta,
        child: OverflowBox(
          minWidth: w,
          maxWidth: w,
          minHeight: GeometriaDelTavolo.altezza(w),
          maxHeight: GeometriaDelTavolo.altezza(w),
          alignment: Alignment.topCenter,
          child: KeyedSubtree(
            key: _chiaveDegliSlot,
            // **UN LIVELLO SUO, ordine FS.** Lo scorrimento della pagina
            // sposta il tavolo senza ridipingerlo: senza questo confine
            // ogni fotogramma dello scorrimento ridisegnava immagine, Medora
            // e carte insieme al resto della lista.
            child: RepaintBoundary(
                child: AnimatedBuilder(
              animation:
                  Listenable.merge([_giro, _alzo, _reveal, _tilt, _filo]),
              builder: (context, _) => TavoloDiMedora(
                key: const Key('stesa_slots'),
                posti: _setup.tipo.tavolo,
                carte: [
                  for (var i = 0; i < _posizioni.length; i++)
                    i < _drawn ? _spread.cards[i] : null,
                ],
                palette: palette,
                girata: _responsoPronto ? _girataDi : null,
                alzata: _sequenzaFatta ? 1 : _alzo.value,
                chiave: _responsoInScena ? _postoDellaChiave : null,
                filaAlzata: (context, fila) => _filaAlzata(palette, fila),
                faccia: (carta) =>
                    FacciaDellaCarta(drawn: carta, palette: palette),
                posa: _posaDiMedora,
                filmato: _filmatoInScena,
                filmatoSaltato: _filmatoSaltato,
                scenaFerma: _scenaFerma,
              ),
            )),
          ),
        ),
      );
    });
  }

  final GlobalKey _chiaveDegliSlot = GlobalKey(debugLabel: 'stesa_slots');

  /// **IL POSTO DELLA CARTA CHIAVE**, contato nella stesa: i due `lato`
  /// della croce hanno la stessa posizione e due carte diverse.
  int get _postoDellaChiave => _spread.cards
      .indexWhere((c) => c.card.name == _reading.chiave.drawn.card.name);

  /// **LE CARTE IN PIEDI, AFFIANCATE E INGRANDITE**, ordine FL voce 05: la
  /// fila davanti al tavolo, con la posizione sotto ogni carta, la carta
  /// chiave illuminata da sotto, il tocco che apre il significato generico
  /// (ordine FK aggiunta voce A4, ordine FL voce 06) e il filo fra le carte.
  Widget _filaAlzata(MaestroPalette palette, FilaAlzata fila) {
    // **OGNI CARTA AL SUO POSTO IN PIEDI**, ordine FM aggiunta 1: la fila
    // decide la forma (una riga, piu' righe bilanciate per la Croce
    // Celtica, la croce per la croce a quattro), e qui ogni posto sta alle coordinate
    // della sua carta, con la testa sopra e la scritta sotto.
    final Widget carte = Stack(
      clipBehavior: Clip.none,
      children: [
        // L'altezza della pila: le carte, la testa sopra e la scritta sotto
        // l'ultima riga.
        SizedBox(
          width: fila.zona.width,
          height: fila.zona.height +
              fila.testa +
              (fila.righe > 1
                  ? FilaAlzata.sottoLaCartaInDueRighe
                  : FilaAlzata.sottoLaCartaInUnaRiga),
        ),
        for (var i = 0; i < _posizioni.length && i < fila.carte.length; i++)
          Positioned(
            left: fila.carte[i].left - fila.zona.left,
            top: fila.carte[i].top - fila.zona.top,
            child: _postoInPiedi(palette, fila, i),
          ),
      ],
    );
    if (!_filoInScena) return carte;
    return Stack(
      children: [
        carte,
        Positioned.fill(
          child: FiloFraLeCarte(
            centri: [
              for (final r in fila.carte)
                Offset(r.center.dx - fila.zona.left,
                    r.center.dy - fila.zona.top + fila.testa),
            ],
            dallaChiave: _postoDellaChiave,
            avanzamento: _reduceMotion ? 0.5 : _filo.value,
            palette: palette,
          ),
        ),
      ],
    );
  }

  Widget _postoInPiedi(MaestroPalette palette, FilaAlzata fila, int i) =>
      SizedBox(
        key: ValueKey('tavolo_posto_$i'),
        width: fila.larghezza,
        child: _Slot(
          position: _posizioni[i],
          drawn: i < _drawn ? _spread.cards[i] : null,
          palette: palette,
          onApri: _responsoInScena && i < _drawn ? () => _apriLaCarta(i) : null,
          eLaChiave: _responsoInScena && i < _drawn && i == _postoDellaChiave,
          conIntestazione: true,
          revealSpec: _revealSlot == i ? _revealSpec : null,
          revealProgress: _revealSlot == i ? _reveal.value : 0,
          tiltX: _tiltFermo?.dx ?? _tilt.x,
          tiltY: _tiltFermo?.dy ?? _tilt.y,
          galleggio: _reduceMotion ? null : _galleggio,
          indiceDelGalleggio: i,
          etichettaSuDueRighe: fila.righe > 1,
          scalaDellEtichetta:
              fila.righe > 1 ? _scalaDelleEtichette(fila.larghezza) : 1,
        ),
      );

  /// **UNA MISURA SOLA PER TUTTE LE DIDASCALIE IN PIEDI**, ordine FS: la
  /// piu' grande, fino a quella dell'etichetta, con cui ogni didascalia
  /// della stesa sta in due righe larghe [larga] senza spezzare una parola.
  double _scalaDelleEtichette(double larga) {
    final etichette = {for (final p in _posizioni) p.didascalia.toUpperCase()};
    final base = _Slot._stileDellEtichettaAlta;
    final scala = MediaQuery.textScalerOf(context);
    for (var s = 1.0; s > 0.5; s -= 0.02) {
      final stile = base.copyWith(fontSize: base.fontSize! * s);
      var regge = true;
      for (final testo in etichette) {
        if (_Slot._parolaPiuLunga(testo, stile, context) > larga) {
          regge = false;
          break;
        }
        final p = TextPainter(
          text: TextSpan(text: testo, style: stile),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          textScaler: scala,
        )..layout(maxWidth: larga);
        final righe = p.computeLineMetrics().length;
        p.dispose();
        if (righe > 2) {
          regge = false;
          break;
        }
      }
      if (regge) return s;
    }
    return 0.5;
  }

  Widget _content(MaestroPalette palette, double sottoLaBarra) {
    // **IL RESPONSO ENTRA NEL DIARIO DA SE'. Ordine FE voce 22.6.** La
    // porta sta in fondo a un elenco pigro, che la costruisce solo
    // quando la persona ci arriva: il responso si annota da
    // IlResponsoNelDiario, primo figlio dell'elenco, con lo stesso
    // istante della porta (una voce sola).
    final perIlDiario = ResponsoDaCustodire(
      arte: 'stesa',
      titolo: 'La tua stesa a $_quanteCarte',
      testo: _spread.reading,
      dati: {
        'carte': _spread.cards.map((c) => c.card.name).join(','),
        // **IL VERSO SI CUSTODISCE. Ordine EC voce 05.** Il
        // nome resta nudo perche' e' con quello che il
        // Ricordo ritrova la carta nel mazzo; il verso viaggia
        // accanto, uno per carta e nello stesso ordine. Una
        // carta rovesciata custodita come dritta e' un altro
        // responso, non una sfumatura.
        // La parola del rovescio si prende da `reversedWord`, mai
        // scritta a mano: e' accordata al genere della carta, ed e'
        // l'unico punto in cui quella parola si ricava.
        'versi': _spread.cards
            .map((c) => c.reversed ? c.card.reversedWord : 'dritta')
            .join(','),
      },
    );
    final quando = _istanti.di(perIlDiario);
    // **SOPRA IL VIDEO SOLO IL VIDEO**, ordine FX voce FXA.08: il pannello
    // della stesa, il ventaglio, i comandi e i suggerimenti stavano sotto la
    // scena e coprivano la meta' bassa del filmato mentre girava. Adesso
    // aspettano la scena ferma e compaiono in dissolvenza.
    final scena = _laScena(palette);
    return ListView(
      key: const Key('stesa_list'),
      controller: _scorrimento,
      // Sopra Medora c'era una fascia vuota che sprecava la parte migliore
      // dello schermo: il margine alto ora e' appena quello che serve a non
      // finire sotto la barra del titolo.
      //
      // **NESSUNA FASCIA FRA LA BARRA E LA SCENA.** Il fondatore, sulla 2309
      // e sulla 2310: "sopra la testa di Medora c'e' una barra azzurra piena
      // da eliminare". LAPIDE: `sottoLaBarra + SpacingTokens.xs`, otto punti
      // di cosmo senza il velo della barra. La scena sale sotto il velo
      // esattamente quanto la sua sfumatura in alto
      // (`GeometriaDelTavolo.sfumaturaInAlto`), cosi' l'immagine e' piena dal
      // bordo della barra in giu'.
      padding: EdgeInsets.fromLTRB(
          SpacingTokens.lg,
          sottoLaBarra -
              GeometriaDelTavolo.sfumaturaInAlto *
                  GeometriaDelTavolo.scala(MediaQuery.sizeOf(context).width),
          SpacingTokens.lg,
          SpacingTokens.lg),
      children: IlRestoDopoLaScena.attorno(scenaFerma: _scenaFerma, scena: {
        scena
      }, [
        if (_responsoPronto)
          IlResponsoNelDiario(
              maestro: Maestro.medora, responso: perIlDiario, quando: quando),
        // Medora presiede la stesa. Finche' si pesca sta piu' raccolta: il
        // protagonista in quel momento e' il ventaglio interattivo, e il
        // ventaglio che lei tiene in mano deve restare un dettaglio del
        // ritratto, non un secondo invito in gara col primo.
        // **LA SCENA: IL TAVOLO, MEDORA DIETRO, LE CARTE SUL PIANO.** Ordine
        // FL voci 01, 03 e 05. LAPIDE: "MedoraStage", il ritratto con
        // l'altezza che cresceva a responso in scena.
        scena,
        // Il pannello "Scegli la tua stesa" sfiora il bordo basso del tavolo
        // (il fondatore, 14 ottobre 2026): nessun margine fra i due.
        if (_responsoPronto) const SizedBox(height: SpacingTokens.sm),
        // La configurazione, richiusa nella sua riga di riepilogo.
        //
        // **RESTA ANCHE LEI FINO AL RESPONSO. Ordine DD voce 08.** Sparendo
        // alla terza carta si portava via **centodue punti** e faceva salire
        // tutto cio' che le sta sotto: e' lo stesso movimento che il
        // fondatore legge come una schermata nuova, in piccolo. Il momento in
        // cui la pagina cambia davvero e' uno solo, ed e' il responso.
        if (!_responsoPronto) ...[
          TarotSetupPanel(
            setup: _setup,
            palette: palette,
            aperto: _setupAperto,
            onToggle: () => setState(() => _setupAperto = !_setupAperto),
            onChanged: (s) {
              setState(() {
                // **UN'ALTRA STESA, ALTRI POSTI**, ordine FK aggiunta 2:
                // finche' nessuna carta e' presa la stesa in corso rinasce
                // con le posizioni della nuova; dopo, la stesa resta quella.
                //
                // **LA STESA TORNATA DA SOLA NON BLOCCA IL CAMBIO, ordine FR
                // voce 02, 13 ottobre 2026.** Il fondatore, a video: scelta
                // "la stesa a 4" vedeva carte gia' coperte sul tavolo, e da
                // li' non riusciva piu' a tornare a singola, tre o dieci. La
                // causa: `onChanged` richiama `_cercaLaStesaConservata` ogni
                // volta (riga sotto), e se oggi quella stesa era gia' stata
                // compiuta su questa domanda, torna intera da sola (ordine FI
                // voce 27) e alza `_drawn`. Quella non e' una stesa IN CORSO,
                // scelta e pescata ora: e' un ricordo tornato. La guardia di
                // prima guardava solo `_drawn`, che sale in entrambi i casi;
                // adesso guarda anche `_conservata`, che e' vera solo nel
                // secondo.
                if (s.tipo != _setup.tipo) {
                  if (_drawn == 0 || _conservata) {
                    _stesa = StesaInCorso.nuova(
                        mazzo: _mazzo,
                        seme: _seme,
                        posizioni: s.tipo.posizioni);
                    _drawn = 0;
                    _conservata = false;
                    _scene = StesaScene.riposo;
                  } else {
                    s = s.copyWith(tipo: _setup.tipo);
                  }
                }
                _setup = s;
              });
              unawaited(_cercaLaStesaConservata());
            },
            onLocked: _showComingSoon,
            piano: _forse<EntitlementService>(context)?.tier ?? Tier.free,
          ),
          const SizedBox(height: SpacingTokens.sm),
        ],
        // Mentre si pesca, gli slot stanno appena SOPRA il ventaglio: cosi'
        // partenza e arrivo del volo sono nello stesso campo visivo e la carta
        // non vola mai verso uno slot fuori schermo.
        //
        // **E CI RESTANO ANCHE DOPO LA TERZA CARTA. Ordine DD voce 08,
        // 10 settembre 2026, e la voce CQ 6.09 era stata chiusa due volte
        // senza chiudere questo.**
        //
        // **Cosa succedeva, misurato coi rettangoli veri** su una finestra
        // 360 per 1400, dopo la seconda carta e dopo la terza:
        //
        //     prima:  slot 348, prompt 656, ventaglio 676, gesti 838,
        //             pulsante 938
        //     dopo:   ventaglio 246, gesti 408, pulsante 508, slot 572,
        //             carte scelte 752
        //
        // **Non spariva piu' niente**, e le due guardie della voce 6.09
        // dicevano il vero: il ventaglio restava, le carte restavano, il
        // pulsante c'era. **Cambiava l'ORDINE.** Gli slot passavano da sopra
        // il ventaglio a sotto il pulsante, e tutta la pagina saliva di
        // **quattrocentotrenta punti** in un fotogramma. Chi guarda non
        // distingue una pagina riordinata da una pagina nuova: e' la stessa
        // segnalazione di sempre, con una causa diversa.
        //
        // **La condizione era `!_complete` e diventa `!_responsoPronto`**: il
        // blocco se ne va col responso, che e' un cambio di scena
        // dichiarato, e non con l'ultima carta, che non lo e'.
        // **LE CARTE STANNO SUL TAVOLO, NON IN FILA SOTTO IL SELETTORE.**
        // Ordine FL voci 02 e 03. LAPIDE: "gli slot e il testo delle carte
        // gia' uscite, sotto il selettore" (ordini P voce 10, BZ voce 07 e
        // DD voce 08). Le carte scelte si posano coperte sul tavolo della
        // scena, e i loro nomi arrivano col responso: scritti qui, direbbero
        // le carte prima che si girino.
        if (!_complete) ...[
          Text(
            _drawn == 0
                ? 'Scegli $_quanteCarte dal ventaglio'
                : 'Scegli ancora ${_posizioni.length - _drawn}',
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
        ],
        // **IL VENTAGLIO RESTA IN CAMPO ALLA TERZA CARTA. Ordine CQ voce
        // 6.09, riaperta il 5 settembre 2026 col telefono in mano.**
        //
        // Parole del fondatore: *in tarocchi rimane il difetto che quando
        // viene scelta la terza carta, c'e' una schermata in piu' dove poter
        // solo premere il pulsante*.
        //
        // **La prima cura aveva rimesso cio' che ARRIVA e non guardato cio'
        // che SPARISCE.** Alla terza carta `_complete` diventa vero, e con
        // lui se ne andava tutto questo blocco: il ventaglio compreso.
        // Rimettere le carte e il pulsante non bastava, perche' la pagina
        // perdeva comunque **il suo oggetto piu' grande** in un colpo, e una
        // pagina che perde il suo oggetto piu' grande e' un'altra pagina.
        //
        // Adesso il ventaglio se ne va col RESPONSO e non con l'ultima
        // carta: fra la terza carta e il tocco sul pulsante la scena e' la
        // stessa di un attimo prima, con una carta in piu' e un pulsante
        // acceso. Il ventaglio si attenua per dire che ha finito, e non
        // serve spegnerne i tocchi: `_pick` rifiuta gia' a stesa completa.
        if (!_responsoPronto) ...[
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
          //
          // **E IL VUOTO NON RESTA A ZERO, SPARISCE.** Un `SizedBox` alto
          // zero e' comunque un vuoto verticale per il censimento degli
          // spazi, che li conta e li registra: lasciarlo li' vorrebbe dire
          // tenere in elenco un'aria che non c'e' piu'. La guardia dei
          // vuoti l'ha detto allo stesso giro.
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
              // A stesa completa il ventaglio resta ma si ritira: non e'
              // piu' lui il posto dove guardare, ed e' il pulsante ad
              // esserlo. Non sparisce, perche' sparendo cambierebbe la
              // pagina.
              opacity: _complete ? 0.4 : (_statoInPiena ? 1 : 0.15),
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
          // **LA STESA CONSERVATA SI DICE**, ordine FI voce 27.
          if (_conservata) ...[
            const SizedBox(height: SpacingTokens.sm),
            Text(
              LaStesaConservata.riga,
              key: const Key('stesa_conservata'),
              textAlign: TextAlign.center,
              style: TypographyTokens.corpo()
                  .copyWith(color: palette.goldSoft, height: 1.4),
            ),
          ],
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
                'Scegli $_quanteCarte dal ventaglio, poi premi qui.',
                key: const Key('stesa_inizia_come'),
                textAlign: TextAlign.center,
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textSecondary),
              ),
            ),
          ],
          const SizedBox(height: SpacingTokens.md),
        ],
        // **IL TITOLO E LA DOMANDA, sopra le tre carte.**
        // Ordine DF voci 04.5 e 04.6, 11 settembre 2026.
        if (_responsoInScena) ...[
          // **IL TITOLO C'E' SEMPRE E NON HA UN PUNTO DENTRO.** Il fondatore
          // ha misurato che il titolo grande col significato della carta del
          // Presente **compariva in una lettura su quattro**, e che quando
          // c'era finiva con un punto fermo, perche' la sintesi del corpus e'
          // una frase e le frasi finiscono col punto. Un titolo con un punto
          // dentro si legge come due titoli.
          //
          // **E ADESSO E' LA RISPOSTA, non il significato di una carta.**
          // Ordine FK aggiunta voci A1 e A2. LAPIDE: "`VoceDellaStesa.titolo`,
          // la sintesi della carta del Presente senza il punto". Il fondatore:
          // *"un titolo che a colpo d'occhio e' gia' una risposta diretta"*.
          // Il titolo e' `TarotReading.titolo`: quello del modello o quello
          // della lettura di casa, disegnato dal punto comune.
          TitoloDelResponso(
              key: const Key('stesa_synthesis'),
              testo: _reading.titolo,
              allineamento: TextAlign.center,
              stile: TypographyTokens.titoloSezione()
                  .copyWith(color: palette.goldSoft, height: 1.25)),
          const SizedBox(height: SpacingTokens.xs),
          // **A CHE COSA STA RISPONDENDO QUESTA LETTURA.**
          // Ordine DF voce 04.6: *"la domanda posta non compare mai a schermo.
          // Chi legge non vede a che cosa sta rispondendo la lettura"*.
          //
          // **Verificato, e il fondatore aveva ragione a meta', che e' la
          // meta' peggiore**: un riquadro con la domanda c'era, ma **solo per
          // chi l'aveva scritta a mano**. Chi sceglieva un argomento
          // dall'elenco, che e' la via piu' breve e quindi la piu' usata, non
          // vedeva niente. Adesso questa riga c'e' sempre: la domanda quando
          // c'e', altrimenti il nome dell'argomento scelto.
          Text(
            _setup.domandaScritta?.trim().isNotEmpty == true
                ? '«${_setup.domandaScritta!.trim()}»'
                : _setup.topic.label,
            key: const Key('stesa_domanda_a_video'),
            textAlign: TextAlign.center,
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary),
          ),
          // **LA LETTURA DI CASA SI DICHIARA**, ordine FI voce 08: senza il
          // modello parla la lettura di casa, che e' nella chiave Predittiva.
          if (_dalModello == null && _setup.key != ReadingKey.predittiva) ...[
            const SizedBox(height: SpacingTokens.xs),
            Text(
              _setup.key.rigaDellaLetturaDiCasa,
              key: const Key('stesa_lettura_di_casa'),
              textAlign: TextAlign.center,
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textSecondary),
            ),
          ],
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
        // **QUI C'ERA IL SECONDO MONTAGGIO DEGLI SLOT E DELLE CARTE, ed e'
        // lui che riordinava la pagina.** Ordine DD voce 08, 10 settembre
        // 2026.
        //
        // La voce CQ 6.09 aveva rimesso a video cio' che spariva alla terza
        // carta, e lo aveva rimesso **qui sotto**, dopo il pulsante. Il
        // risultato: gli stessi pezzi, in un ordine diverso, con la pagina
        // che saliva di quattrocentotrenta punti. Adesso il blocco di sopra
        // resta fino al responso e questo non serve piu': **un pezzo solo,
        // in un posto solo.**
        // Le carte del responso sono in piedi sul tavolo, nella scena in cima
        // (ordine FL voce 05): qui sotto restano il loro testo e il responso.
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
          // **IL RIQUADRO CON LA TUA DOMANDA NON STA PIU' QUI.**
          // Ordine DF voce 04.6, 11 settembre 2026.
          //
          // C'era, e portava la domanda scritta a mano sopra il Consiglio.
          // **Adesso la domanda sta sotto il titolo**, in cima al responso e
          // non a meta', e ci sta **anche per chi non l'ha scritta**, col nome
          // dell'argomento scelto. Tenerne due sarebbe scrivere la stessa cosa
          // due volte nella stessa schermata, che e' il difetto della voce
          // DF.04.3 applicato a un'altra riga.
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
            // **TRE PARAGRAFI, IL SECONDO NEL RIQUADRO, POI DA DOVE VIENE.**
            // Ordine FK aggiunta voce A2.
            paragrafi: _reading.paragrafi,
            daDoveViene: TarotReading.daDoveViene(_spread,
                mazzo: _setup.deck.label, stesa: _setup.tipo.nome),
            // **SOLO QUI, NON NELLE TRE BOLLE.** Il fondatore, scelta fra le
            // due: l'approfondimento resta nel solo Consiglio di Medora.
            approfondimento: _reading.approfondimento,
          ),
          const SizedBox(height: SpacingTokens.sm),
          // **LA PRIMA BOLLA DI RISPOSTA AVEVA IL SUO PARLANE SOLO IN
          // FONDO. Ordine FN, 13 ottobre 2026.** Il fondatore: il Consiglio
          // di Medora e' la prima bolla che si legge, e il Parlane con
          // Medora le mancava del tutto. Qui apre la chat con lo STESSO
          // approfondimento del pulsante in fondo alla schermata, perche'
          // entrambi parlano dell'intero responso e non di una sola carta.
          ParlaneConMaestroCompatto(
            keyDelPulsante: const Key('stesa_consiglio_parlane'),
            palette: palette,
            maestro: Maestro.medora,
            frase: _reading.consiglio,
            aperturaDellaChat: ChatOpeners.stesa(
              _spread.cards.map((c) => c.displayName).toList(),
              domanda: _setup.domandaScritta ?? _setup.topic.label,
            ),
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
              domanda: _setup.domandaScritta ?? _setup.topic.label,
              // LA BOLLA CHIAVE E' UNA DI QUESTE TRE, ordine P voce 07.
              perche: letta.drawn.card.name == _reading.chiave.drawn.card.name
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
            responso: perIlDiario,
            quando: quando,
            condividi: _onShare,
            // **LA CHAT RICEVE LA DOMANDA E IL VERSO. Ordine EB voce 01.**
            // Qui passavano i soli `c.card.name`: tre nomi nudi, senza la
            // domanda a cui rispondevano e senza il rovescio. Adesso passa
            // `displayName`, che e' il nome col verso accordato, e la domanda
            // vera: quella scritta a mano se c'e', altrimenti l'argomento
            // della tendina, che e' la stessa scelta che la schermata fa per
            // dire a video a cosa si sta rispondendo.
            aperturaDellaChat: ChatOpeners.stesa(
              _spread.cards.map((c) => c.displayName).toList(),
              domanda: _setup.domandaScritta ?? _setup.topic.label,
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
      ]),
    );
  }

  void _showComingSoon(String voce) {
    // **LA STESA CHE IL PIANO NON APRE NON "ARRIVA PRESTO"**, ordine EX voce
    // 02: la stesa da dieci carte, quando sara' disponibile, si apre
    // dall'Adepto, e a chi non lo e' si dice come aprirla.
    final tipo =
        TarotSpreadType.values.where((t) => t.nome == voce).firstOrNull;
    if (tipo != null && tipo.disponibile) {
      showUpgradeInvite(
        context,
        title: 'La stesa a dieci carte è dell’Adepto',
        message: 'La stesa a dieci carte si apre dal piano Adepto in su, '
            'insieme a dieci carte al giorno.',
      );
      return;
    }
    // **LA CHIAVE CHE IL PIANO NON APRE**, ordine FI voce 32: esiste, e a chi
    // non l'ha si dice da quale piano si apre, come per la stesa da dieci.
    final chiave = ReadingKey.values.where((k) => k.label == voce).firstOrNull;
    final dal = chiave == null ? null : PlanCatalog.dalPiano(chiave.apribileDa);
    if (chiave != null && dal != null) {
      showUpgradeInvite(
        context,
        title: 'La chiave ${chiave.label}',
        message: '${dal.replaceFirst('Dall’', 'Si apre dal piano ')} in su. '
            '${chiave.tradizione}',
      );
      return;
    }
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
        text: 'La mia stesa a $_quanteCarte. Esoteric Circle.',
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
/// **LA CARTA CHE FLUTTUA DA SOLA. Ordine FS, 13 ottobre 2026.** Il
/// galleggiamento sposta il livello gia' dipinto della carta (il
/// `RepaintBoundary` qui dentro) e nient'altro: a ogni fotogramma si
/// ricostruisce un solo `Transform.translate`, la carta non si ridipinge e
/// il tavolo non se ne accorge. Prima lo stesso movimento ricostruiva
/// l'intero `TavoloDiMedora` a ogni fotogramma, e sulla Croce Celtica lo
/// scorrimento andava a scatti.
class _Fluttua extends StatelessWidget {
  const _Fluttua({
    required this.animazione,
    required this.indice,
    required this.child,
  });

  final Animation<double>? animazione;
  final int indice;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final a = animazione;
    final dipinta = RepaintBoundary(child: child);
    if (a == null) return dipinta;
    return AnimatedBuilder(
      animation: a,
      child: dipinta,
      builder: (context, carta) => Transform.translate(
        offset: Offset(0, TiltListener.fluttuazioneDi(indice, a.value)),
        child: carta,
      ),
    );
  }
}

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
    this.galleggio,
    this.indiceDelGalleggio = 0,
    this.etichettaSuDueRighe = false,
    this.scalaDellEtichetta = 1,
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

  /// Il galleggiamento lento, come animazione e non come valore: la carta lo
  /// segue da se' con [_Fluttua], senza che il tavolo si ricostruisca.
  /// Nullo, la carta sta ferma. Ordine FS.
  final Animation<double>? galleggio;

  /// Il posto della carta nella stesa, per sfasare il suo galleggiamento.
  final int indiceDelGalleggio;

  /// La scritta della posizione su piu' righe, per le carte strette della
  /// Croce Celtica in piedi: su una riga sola "CIO' CHE ATTRAVERSA"
  /// scenderebbe a una misura che non si legge.
  final bool etichettaSuDueRighe;

  /// La misura comune delle didascalie su piu' righe, rispetto a quella
  /// dell'etichetta: una sola per tutte le carte della stesa. Ordine FS.
  final double scalaDellEtichetta;

  /// La scala della carta chiave e quella delle vicine. Ordini BV voce 04 e
  /// BZ voce 08.
  // **LA CHIAVE NON E' PIU' GRANDE, ordine FL voce 04.** Il fondatore: "La
  // Carta chiave e' illuminata da sotto, non e' piu' grande". LAPIDE:
  // "scalaDellaChiave = 1.10, scalaDelleAltre = 0.86" (ordine BN voce 05).
  // Le carte hanno la stessa misura; la chiave ha la sua luce
  // ([luceDellaChiave]).
  static const double scalaDellaChiave = 1.0;
  static const double scalaDelleAltre = 1.0;

  /// **LA LUCE CHE SALE DA SOTTO LA CARTA CHIAVE**, disegnata da
  /// [LuceDellaChiave]: un alone che esce da dietro la carta su tutti i lati
  /// e una pozza viva sul velluto sotto il suo bordo basso. Il primo disegno,
  /// una sola ellisse tenue sotto la carta, il fondatore l'ha guardato e ha
  /// detto di migliorarlo (12 ottobre 2026): non si vedeva.
  static Widget luceDellaChiave(MaestroPalette palette) => IgnorePointer(
        child: CustomPaint(
          key: const Key('stesa_luce_della_chiave'),
          painter: LuceDellaChiave(palette),
        ),
      );

  /// **LA DISTANZA FRA OGNI CARTA E LA SUA SCRITTA**, uguale per le tre.
  /// Era sedici punti dall'ordine EQ voce 05 (quanto la carta vicina
  /// lasciava gia' prima); il fondatore, 12 ottobre 2026, guardando le
  /// anteprime: *"c'e' molto spazio tra carta e didascalia"*. Quattro punti,
  /// il piu' stretto dei token: la scritta resta leggibile ma incollata
  /// alla carta.
  static const double distanzaDellaScritta = SpacingTokens.xxs;

  /// Quanto l'etichetta sotto la carta puo' allargarsi oltre la carta: fino
  /// al posto vicino, che sul tavolo sta a 1,15 larghezze.
  static const double larghezzaDellEtichetta = 1.6;

  /// Lo stile dell'etichetta su piu' righe, per le carte strette in piedi.
  static TextStyle get _stileDellEtichettaAlta =>
      TypographyTokens.etichetta().copyWith(letterSpacing: 0.6, height: 1.1);

  /// **LA PAROLA PIU' LUNGA, misurata col motore del testo.** Ordine FS: la
  /// larghezza sotto la quale l'etichetta comincerebbe a spezzarla.
  static double _parolaPiuLunga(
      String testo, TextStyle stile, BuildContext context) {
    var massima = 0.0;
    for (final parola in testo.split(' ')) {
      final p = TextPainter(
        text: TextSpan(text: parola, style: stile),
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 1,
      )..layout();
      if (p.width > massima) massima = p.width;
      p.dispose();
    }
    return massima.ceilToDouble() + 1;
  }

  /// L'altezza della riga dell'etichetta, misurata col motore del testo.
  static double altezzaDellEtichetta(BuildContext context) => (TextPainter(
        text: TextSpan(
            text: 'A',
            style: TypographyTokens.etichetta().copyWith(letterSpacing: 1.2)),
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.textScalerOf(context),
      )..layout())
          .height;

  /// **LO SPAZIO DELLE PAROLE SOPRA LA CARTA CHIAVE**, per una colonna larga
  /// [larghezza]. Le parole sono alte quindici punti; la chiave, che cresce dal
  /// bordo basso, sale di un decimo della sua altezza; sei punti d'aria.
  /// Mai meno dei trentadue di prima.
  static double spazioDelleParole(double larghezza) =>
      math.max(32, 15 + larghezza / kTarotAspect * (scalaDellaChiave - 1) + 6);

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
        // **LO SPAZIO CRESCE CON LA CARTA. Ordine EQ voce 05.** La carta
        // chiave adesso cresce dal suo bordo basso, quindi tutta verso l'alto:
        // lo spazio delle parole si misura sulla larghezza della carta.
        LayoutBuilder(
          builder: (context, vincoli) => SizedBox(
            height: conIntestazione ? spazioDelleParole(vincoli.maxWidth) : 0,
            child: eLaChiave
                ? Align(
                    alignment: Alignment.topCenter,
                    // **LE DUE PAROLE STANNO SU UNA RIGA O NON STANNO.**
                    // Ordine DF voce 04.4, 11 settembre 2026. Il fondatore:
                    // *"la parola Carta sta isolata sopra la carta centrale e
                    // non dice niente"*.
                    //
                    // **La causa**: `maxLines: 1` con il ritorno a capo acceso.
                    // Nella colonna stretta della carta centrale la riga si
                    // spezzava dopo la prima parola, e la seconda riga, quella
                    // che porta la parola che conta, **veniva buttata via**.
                    // Restava un'etichetta che dice quello che si vede gia'.
                    //
                    // **La cura non e' accorciare la scritta**, che sono le
                    // parole del fondatore stesso: e' spegnere il ritorno a capo
                    // e lasciare che la scritta si rimpicciolisca quel tanto che
                    // serve a starci intera.
                    //
                    // **E PUO' USCIRE DI POCO DALLA CARTA**, ordine FK aggiunta
                    // 2 voce A10: sul tavolo le tre carte sono un po' piu'
                    // strette della fila di prima, e la scritta si era
                    // rimpicciolita sotto la misura che la guardia sui pixel
                    // pretende. Come l'etichetta sotto la carta, si allarga
                    // fino a [larghezzaDellEtichetta] volte la carta.
                    child: OverflowBox(
                      maxWidth: vincoli.maxWidth * larghezzaDellEtichetta,
                      alignment: Alignment.topCenter,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Carta Chiave',
                            key: Key('stesa_parole_chiave_${position.name}'),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            softWrap: false,
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
                      ),
                    ),
                  )
                : null,
          ),
        ),
        // La carta posata fluttua piano e si inclina col giroscopio, come
        // sospesa davanti a chi guarda. E' un effetto di superficie: non tocca
        // il testo sotto ne' il pescaggio.
        _Fluttua(
          animazione: galleggio,
          indice: indiceDelGalleggio,
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
                scale: eLaChiave ? scalaDellaChiave : scalaDelleAltre,
                // **DAL BORDO BASSO, ordine EQ voce 05.** Con la scala
                // attorno al centro la chiave debordava sotto di cinque
                // centesimi della sua altezza e copriva "PRESENTE", mentre le
                // vicine si ritiravano di sette: tre distanze diverse fra la
                // carta e la sua scritta. Dal bordo basso le tre carte
                // finiscono sulla stessa riga, e le tre scritte stanno alla
                // stessa distanza e allineate.
                alignment: Alignment.bottomCenter,
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
                    // **LA LUCE DELLA CHIAVE, ordine FL voce 04**: attorno
                    // alla carta dipinta e non alla colonna, che e' piu'
                    // larga di lei: la luce esce uguale dai quattro lati.
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        if (eLaChiave)
                          Positioned(
                            left: -LuceDellaChiave.oltre,
                            right: -LuceDellaChiave.oltre,
                            top: -LuceDellaChiave.oltre,
                            bottom: -LuceDellaChiave.oltre,
                            child: luceDellaChiave(palette),
                          ),
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
                                      // **GIA' SCOPERTA, NESSUN GIRO DA RIVEDERE.**
                                      // Ordine del 14 ottobre 2026, dal telefono
                                      // vero: risalendo con lo scorrimento oltre
                                      // la fila in piedi e tornando, il giro
                                      // della carta (dorso -> faccia) ripartiva
                                      // da capo. LAPIDE: `_FlipCard`, che
                                      // animava un giro di 650 ms a ogni
                                      // montaggio, indipendentemente da
                                      // `girata`: nella lista non pigra una
                                      // carta lontana dallo schermo viene
                                      // smontata e rimontata, e `_FlipCard`
                                      // ripartiva da zero ogni volta. Qui la
                                      // carta arriva SEMPRE gia' scoperta: il
                                      // giro vero e proprio lo fa
                                      // `_CartaSulTavolo` mentre e' ancora
                                      // sul tavolo (`girata`, guidato da
                                      // `_giro`), e quando questa fila appare
                                      // (`alzata >= 1`) la stesa e' gia'
                                      // completa da un pezzo: non serve
                                      // rivederlo.
                                      child: FacciaDellaCarta(
                                        key: ValueKey(
                                            '${position.name}_${drawn!.card.stem}'),
                                        drawn: drawn!,
                                        palette: palette,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ],
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
        const SizedBox(height: distanzaDellaScritta),
        // **SU UNA RIGA, E PUO' USCIRE DI POCO DALLA CARTA.** Ordine FK
        // aggiunta 2 voce A10, visto nelle anteprime della croce: con le
        // carte strette perche' il tavolo stia in una schermata, "IL LATO"
        // andava a capo lettera per lettera. L'etichetta resta intera su una
        // riga e scende di misura quanto serve.
        //
        // **MA NON OLTRE LO SPAZIO FRA LE CARTE**, ordine FL voce 05: nella
        // fila in piedi due carte stanno a otto punti, non a 1,15 larghezze
        // come sul tavolo in piano, e nell'anteprima della croce "IL
        // CONSULTANTE" copriva "IL LATO". L'etichetta si allarga al piu' della
        // meta' dello spazio per lato.
        //
        // **SU DUE RIGHE NIENTE ALLARGAMENTO, ordine FM aggiunta 1.**
        // L'allargamento di prima riempiva anche lo spazio del distacco fra
        // le carte: due etichette vicine, come "CIO' CHE COPRE" e "CIO' CHE
        // ATTRAVERSA", toccavano senza un pixel di margine e si leggevano
        // come una sola scritta ("CIO' CHECIO' CHE..."). Qui il testo va
        // gia' a capo da solo: resta dentro la sua carta, e il distacco
        // vero fra le carte diventa il distacco fra le scritte.
        LayoutBuilder(
          builder: (context, vincoli) {
            final largaDellEtichetta = etichettaSuDueRighe
                ? vincoli.maxWidth
                : vincoli.maxWidth + FilaAlzata.distanzaFraLeCarte;
            // **LE DIDASCALIE DELLA CROCE CELTICA, TUTTE DELLA STESSA MISURA
            // E ATTACCATE ALLA CARTA. Ordine FS, 14 ottobre 2026.** Il
            // fondatore, guardando la Croce Celtica in piedi: "avvicinare le
            // didascalie alla propria carta", e alcune "in maiuscolo, altre
            // in minuscolo, visivamente brutte". Le didascalie lunghe erano
            // rimpicciolite una per una dal `FittedBox` (in Cinzel, che ha
            // solo capitali, una capitale piccola si legge come una
            // minuscola), e ognuna stava al centro di uno spazio alto quattro
            // righe, lontana dalla carta. Adesso la misura e' una sola per
            // tutte, la piu' grande con cui ogni didascalia sta in due righe
            // senza spezzare una parola (`_scalaDelleEtichette`), e il testo
            // comincia subito sotto la carta. LAPIDE: il `FittedBox` per
            // didascalia e le quattro righe dell'ordine FM aggiunta 1.
            if (etichettaSuDueRighe) {
              return SizedBox(
                width: vincoli.maxWidth,
                height: altezzaDellEtichetta(context) * 2,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(position.didascalia.toUpperCase(),
                      key: Key('stesa_etichetta_${position.name}'),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: _stileDellEtichettaAlta.copyWith(
                          color: palette.goldSoft,
                          fontSize: _stileDellEtichettaAlta.fontSize! *
                              scalaDellEtichetta)),
                ),
              );
            }
            return SizedBox(
              width: vincoli.maxWidth,
              height: altezzaDellEtichetta(context),
              child: OverflowBox(
                maxWidth: largaDellEtichetta,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(position.etichetta.toUpperCase(),
                      key: Key('stesa_etichetta_${position.name}'),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      softWrap: false,
                      style: TypographyTokens.etichetta().copyWith(
                          color: palette.goldSoft, letterSpacing: 1.2)),
                ),
              ),
            );
          },
        ),
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
          // **IL SEGNO DEL VERSO STA SEMPRE ALLO STESSO POSTO. Ordine EQ voce
          // 06.** Nel `Wrap` unico il segno andava dove c'era posto: accanto
          // al nome per Gli Amanti, a capo per il Tre di Bastoni. Adesso la
          // posizione e il nome stanno sulla prima riga, il segno e la sintesi
          // sulla seconda, e il segno comincia la seconda riga in tutte e tre.
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
            ],
          ),
          // **LE DUE RIGHE SI TOCCANO, E L'ULTIMA VOCE NON PORTA ARIA SOTTO.**
          // Ordine EQ, difetto trovato dal cancello di GitHub: con le scritte
          // a sedici punti dalle carte (voce EQ.05) e due punti fra le righe
          // di ogni voce (EQ.06), dopo due pescaggi il ventaglio finiva a
          // 854,5 punti su uno schermo di 844. Qui si riprendono dodici
          // punti: i due fra le righe e gli otto dopo l'ultima voce, che col
          // vuoto del blocco facevano sedici fra il riepilogo e il ventaglio.
          // Fra una voce e l'altra l'aria resta quella di prima.
          Wrap(
            spacing: SpacingTokens.xs,
            runSpacing: 2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
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
          if (drawn != carte.last) const SizedBox(height: SpacingTokens.xs),
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

/// LAPIDE: "La carta che si gira: dorso, mezzo giro, faccia", `_FlipCard` e
/// `_FlipCardState`. Animavano un giro di 650 ms (dorso verso faccia) a ogni
/// montaggio del widget, chiamato da `didChangeDependencies` la prima volta
/// che lo stato esisteva: un giro vero per la prima rivelazione, quando
/// questa classe viveva nella stesa a tre carte di una volta. Da quando la
/// carta si gira SUL TAVOLO (`_CartaSulTavolo`, guidato da `girata`) e sale
/// gia' scoperta, questa fila non la vede mai coperta: il giro qui era
/// ridondante, e nella lista non pigra della schermata, risalendo con lo
/// scorrimento, il widget veniva smontato e rimontato, e ripartiva da zero
/// ogni volta. Rimosso il 14 ottobre 2026, segnalato dal fondatore sul
/// telefono vero. Guardia: `la_carta_resta_scoperta_risalendo_test.dart`.

/// La faccia della carta, con i cartigli riempiti a runtime.
/// LA FACCIA DELLA CARTA, pubblica dall'ordine BN voce 04: la carta che si
/// apre al tocco mostra la stessa faccia della carta nella stesa, e una
/// seconda copia del disegno sarebbe due carte che possono divergere.
class FacciaDellaCarta extends StatelessWidget {
  const FacciaDellaCarta(
      {super.key, required this.drawn, required this.palette, this.mazzo});

  final DrawnCard drawn;
  final MaestroPalette palette;

  /// Il mazzo con cui disegnarla; senza, quello della stesa (ordine FJ).
  final TarotDeckStyle? mazzo;

  @override
  Widget build(BuildContext context) {
    final m = mazzo ?? IlMazzoDellaStesa.di(context);
    return TarotCardArt(
      card: drawn.card,
      palette: palette,
      reversed: drawn.reversed,
      mazzo: m,
      arte: IMazziScaricati.diCasa.arteDi(m, drawn.card),
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
    this.paragrafi,
    this.daDoveViene,
    this.approfondimento = const [],
  });

  final String titolo;
  final String testo;
  final MaestroPalette palette;

  /// I tre paragrafi del responso, quando lo strato li porta separati: il
  /// secondo va nel riquadro (`ResponsoInTreParagrafi`).
  final List<String>? paragrafi;

  /// Il paragrafo piccolo in corsivo, in fondo.
  final String? daDoveViene;

  /// I due paragrafi dell'approfondimento della Lunga, ordine FN.
  final List<String> approfondimento;

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
          // **INTERO, SU UNA RIGA. Ordine EQ voce 12.** Qui c'era un `Text`
          // con `maxLines: 1` e il ritorno a capo acceso: "IL CONSIGLIO DI"
          // stava sulla prima riga e "MEDORA" andava sulla seconda, che veniva
          // buttata via. E' il difetto di "Carta Chiave" dell'ordine DF voce
          // 04.4, in un altro posto: la misura scende quanto serve.
          Align(
            alignment: Alignment.centerLeft,
            child: TitoloCheNonSiRompe(
                chiaveDelTesto: const Key('stesa_consiglio_titolo'),
                testo: titolo.toUpperCase(),
                righe: 1,
                allineamento: TextAlign.start,
                stile: TypographyTokens.titoloScheda().copyWith(
                    color: palette.goldSoft.withValues(alpha: 0.85),
                    letterSpacing: 1.4)),
          ),
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
          if (paragrafi != null)
            ResponsoInTreParagrafi(
              paragrafi: paragrafi!,
              daDoveViene: daDoveViene,
              palette: palette,
              approfondimento: approfondimento,
              stile: TypographyTokens.lettura().copyWith(
                color: ColorTokens.textPrimary,
              ),
            )
          else
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
    required this.domanda,
    this.perche,
  });

  final PosizioneLetta letta;
  final MaestroPalette palette;

  /// La domanda scritta a mano, o l'argomento della tendina: quella che il
  /// Parlane con Medora di questa bolla riporta in chat, ordine FN.
  final String domanda;

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
          const SizedBox(height: SpacingTokens.sm),
          // **IL PARLANE CON MEDORA DI OGNI BOLLA. Richiesta del fondatore,
          // 12 ottobre 2026.** Il pulsante in fondo alla schermata, dopo le
          // tre bolle e il Consiglio, si perde: chi legge una sola carta e
          // chiude non lo vede mai. Passa da `ParlaneConMaestroCompatto`,
          // la stessa porta di `AzioniDelResponso` (ordine CG voci 06 e 08,
          // ordine DX voce 03): un `Navigator.push` scritto qui a mano
          // sarebbe invisibile al censimento di quelle due guardie.
          ParlaneConMaestroCompatto(
            keyDelPulsante: Key('bolla_parlane_${letta.drawn.position.name}'),
            palette: palette,
            maestro: Maestro.medora,
            frase: letta.testo,
            aperturaDellaChat: ChatOpeners.cartaDellaStesa(
                domanda, letta.drawn.position.label, letta.drawn.displayName),
          ),
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
    this.arrivo,
  });

  /// **IL CENTRO DEL POSTO SUL TAVOLO**, ordine FL voce 03: la carta vola
  /// dove si posa. Nullo prima che la scena sia disegnata: allora vola verso
  /// la colonna del suo posto, come prima.
  final Offset? arrivo;

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
            const cardW = 66.0;
            final arrivoX = arrivo?.dx ?? w * colonna;
            final arrivoY = arrivo == null
                ? h * 0.34
                : arrivo!.dy - cardW / kTarotAspect / 2;
            final x = partenzaX + (arrivoX - partenzaX) * e;
            final y = h * 0.72 + (arrivoY - h * 0.72) * e;

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

/// **LA LUCE DELLA CARTA CHIAVE**, ordine FL voce 04: la chiave non e' piu'
/// grande delle altre, si illumina da sotto. Il fondatore, guardato il
/// secondo disegno (12 ottobre 2026): "dovrebbe essere meno esteso e uscire
/// dai 4 lati della carta chiave". Quindi un orlo di luce che segue il
/// rettangolo arrotondato della carta, uguale sui quattro lati e un poco piu'
/// vivo in basso, che si spegne in [oltre] punti. Lo disegnano anelli
/// concentrici sempre piu' tenui, mai un'ombra col blur: nelle anteprime il
/// blur usciva come una barra dagli spigoli netti.
class LuceDellaChiave extends CustomPainter {
  LuceDellaChiave(this.palette);

  final MaestroPalette palette;

  /// Quanto la luce esce dalla carta, in punti, su ogni lato.
  static const double oltre = 14;

  /// Quanto la luce e' piu' viva sotto il bordo basso, da dove sale.
  static const double spintaDalBasso = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final carta =
        Rect.fromLTRB(oltre, oltre, size.width - oltre, size.height - oltre);
    const anelli = 28;
    for (var k = anelli; k >= 0; k--) {
      final t = k / anelli;
      final d = oltre * t;
      // La luce piu' viva in basso: l'anello scende un poco man mano che si
      // allarga, cosi' sotto la carta e' piu' largo che in cima.
      final r = RRect.fromRectAndRadius(
        Rect.fromLTRB(carta.left - d, carta.top - d * 0.85, carta.right + d,
            carta.bottom + d + spintaDalBasso * t),
        Radius.circular(6 + d),
      );
      final forza = math.pow(1 - t, 2.2).toDouble();
      canvas.drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = oltre / anelli + 0.6
          ..color = Color.lerp(palette.gold, palette.goldSoft, 1 - t)!
              .withValues(alpha: 0.85 * forza),
      );
    }
  }

  @override
  bool shouldRepaint(LuceDellaChiave vecchia) => vecchia.palette != palette;
}

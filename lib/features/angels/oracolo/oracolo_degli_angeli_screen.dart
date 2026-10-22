import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/angels/angel_catalog.dart';
import '../../../core/angels/angel_lore.dart';
import '../../../core/angels/guardian_angels.dart';
import '../../../core/assets/family_image.dart';
import '../../../core/cerchio/il_cerchio_sociale.dart';
import '../../../core/condivisione/premio_della_condivisione.dart';
import '../../../core/entitlement/entitlement_service.dart';
import '../../../core/entitlement/listino_degli_eos.dart';
import '../../../core/entitlement/plan_catalog.dart';
import '../../../core/entitlement/question_allowance.dart';
import '../../../core/entitlement/tier.dart';
import '../../../core/identity/birth_identity.dart';
import '../../../core/identity/profile_controller.dart';
import '../../../core/maestro/maestro.dart';
import '../../../core/quality/quality_tier.dart';
import '../../../core/sensi/catalogo_suoni.dart';
import '../../../core/sensi/palette_sensoriale.dart';
import '../../../core/oracolo_angeli/i_ruoli_e_l_estrazione.dart';
import '../../../core/oracolo_angeli/il_corpus_dell_oracolo.g.dart';
import '../../../core/oracolo_angeli/l_ora_degli_angeli.dart';
import '../../../core/oracolo_angeli/la_lettura_dell_oracolo.dart';
import '../../../core/oracolo_angeli/la_risposta_dai_doni.dart';
import '../../../core/oracolo_angeli/le_domande_dell_oracolo.dart';
import '../../../core/responsi/la_forma_del_responso.dart';
import '../../../design_system/theme/app_theme.dart';
import '../../../design_system/transizioni/velo_del_cerchio.dart';
import '../../../design_system/components/borsellino.dart';
import '../../../design_system/components/cosmos_background.dart';
import '../../../design_system/components/la_singola_che_si_apre.dart';
import '../../../design_system/components/la_conferma_della_spesa.dart';
import '../../../design_system/components/il_responso_interpretato.dart';
import '../../../design_system/components/segno_della_provenienza.dart';
import '../../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../../design_system/typography/paragrafi_di_lettura.dart';
import '../../account/dati_di_nascita_screen.dart';
import '../../horoscope/answer_depth.dart';
import '../../maestri/chat/chat_openers.dart';
import '../../maestri/rotta_arte.dart';
import '../../maestri/widgets/foglio_delle_fonti.dart';
import '../../pricing/upgrade_invite.dart';
import '../../respiro_della_luna/i_comandi_dipinti.dart';
import '../../ricordi/azioni_del_responso.dart';
import '../../scene/la_scena_in_video.dart';
import '../../sigilli/celebrazione.dart';
import '../../sigilli/regia_del_cammino.dart';
import '../../tarot/attesa_di_medora.dart';
import '../../tarot/stesa_choreography.dart';
import '../../tarot/stesa_fan.dart';
import '../../tarot/stesa_senses.dart';
import '../../tarot/tarot_card_art.dart';
import '../../tarot/tarot_selectors.dart';
import 'la_carta_dell_angelo_aperta.dart';
import 'la_geometria_dell_altare.dart';
import 'la_scala_del_responso.dart';
import 'oracolo_share_card.dart';

/// **L'ORACOLO DEGLI ANGELI.** Ordine FU, voci FU.02, FU.03, FU.04, FU.06,
/// FU.07, FU.08 e FU.11, 15 ottobre 2026.
///
/// La persona affida una domanda ai suoi tre angeli dell'onboarding:
/// l'Angelo Custode porta la carta di cosa fare, l'Angelo del Cuore quella
/// di cosa sentire, l'Angelo dell'Intelletto quella di cosa capire. Ogni
/// carta e' uno dei 72 Angeli. Medora da' il messaggio; sotto ogni carta
/// Caligo da' il rito dell'angelo. Fonte: proposta dell'Architetto del 14
/// ottobre 2026, approvata dal fondatore: *"Si, approvo tutto"*.
///
/// **La scena** (FU.02): all'apertura parte il video della Scala di
/// Giacobbe, una volta per apertura, e si ferma sull'ultimo fotogramma, coi
/// tre dorsi sull'altare; un tocco lo salta (FU.15). La domanda affidata
/// sale lungo la scala in lettere di luce, disegnate qui e non nel video,
/// poi i tre dorsi si girano nelle tre carte vere, nella loro posizione
/// esatta sull'altare (`GeometriaDellAltare`). Una nuova consultazione nella
/// stessa apertura non rifa' partire il video.
///
/// **IL GIRO DELL'ORDINE FY**, 16 ottobre 2026. La persona scrive o sceglie
/// la domanda (dieci proposte per argomento, FY.13) e la affida; poi sceglie
/// le sue tre carte dal mazzo coperto dei 72, una per posizione, col
/// ventaglio della Stesa (FY.15); scelte le tre carte, il pulsante dipinto
/// "Avvia la lettura" fa salire la domanda e girare le carte: nulla parte da
/// solo (FY.16). Sotto le carte che si girano l'altare e' vuoto (FY.17). Ogni
/// carta porta chi e' l'angelo e che cosa porta, da Lenain (FY.18), e la
/// risposta e' una coppia sola, il titolo e un riquadro (FY.19). La nascita
/// prestata e la domanda per un amico sono uscite dall'Oracolo (FY.14).
///
/// **L'ORDINE GA**, 20 ottobre 2026.
/// - **GA.08, NESSUNA CARTA IN VISTA ALL'APERTURA.** Il fondatore:
///   *"L'oracolo degli angeli non mostra all'inizio, all'apertura, nessuna
///   Carta prima che l'utente le scelga"*. Riscrive cio' che sopra dice la
///   voce FU.02: i tre dorsi non stanno piu' sull'altare all'apertura ma
///   compaiono uno alla volta quando la persona li sceglie dal ventaglio; il
///   video si ferma prima che le carte alate scendano dalla scala e sfuma
///   sulla scena ferma, dove l'altare e' vuoto (`AltareVuoto`, tolto
///   dall'ordine GC: l'ultimo fotogramma del v2 e' gia' vuoto); la carta
///   dipinta dell'angelo dell'ora non sta piu' sotto la scena.
/// - **GA.03, GA.04 e GA.05, LA FORMA NUOVA DEL RESPONSO.** Il responso
///   principale e' un `IlResponsoInterpretato` dell'Oracolo: il titolo, la
///   risposta, il riquadro "Cosa fare adesso" e, nella Lunga (dall'Iniziato),
///   l'approfondimento e "Il salmo propiziatorio" dell'angelo del Custode,
///   dalla raccolta dei riti e mai dal modello; ogni carta singola e' breve,
///   col suo messaggio e il suo consiglio; il "Da dove viene" chiude la
///   consultazione una volta sola in fondo. Riscrive FY.19, la coppia sola.
class OracoloDegliAngeliScreen extends StatefulWidget {
  const OracoloDegliAngeliScreen({
    super.key,
    this.fabbricaDellaScena,
    this.caso,
    this.chiamata,
    this.corpus,
    this.adesso,
    this.identita,
  });

  /// La finta del lettore video, per le prove headless.
  final FabbricaDiScena? fabbricaDellaScena;

  /// Il caso dell'estrazione; nullo, uno vero.
  final Random? caso;

  /// La chiamata al modello; nulla, quella vera (le prove passano la finta).
  final ChiamataDellOracolo? chiamata;

  /// Il corpus dei messaggi; nullo, quello generato.
  final Map<String, List<String>>? corpus;

  /// L'orologio, per le prove dell'angelo dell'ora.
  final DateTime Function()? adesso;

  /// La nascita da usare; nulla, quella del profilo.
  final BirthIdentity? identita;

  /// **LA BARRA DEL TITOLO SEMPRE SEMITRASPARENTE**, ordine FY voce FY.20.
  /// Il fondatore: "Quando scorro in alto, la barra del titolo compare solida
  /// di botto e non piu' trasparente". Prima la barra passava da 0,16 a 0,9
  /// appena la lettura le scorreva sotto: adesso il velo e' uno solo, in ogni
  /// stato, e il titolo resta leggibile per l'ombra del suo testo, mai per il
  /// pieno.
  static const double veloDellaBarra = AppTheme.veloDellaBarra;

  /// **CHI E' L'ANGELO E CHE COSA PORTA** (FY.18), le righe della bolla di
  /// una carta, lette dalle prove senza montare la schermata.
  static String chiEDi(Angel a) => _LaBollaDellaCarta.chiE(a);
  static ({String testo, Provenienza da, String fonte})? cosaPortaDi(Angel a) =>
      _LaBollaDellaCarta.cosaPorta(a);

  static Route<void> route() => PassaggioDelCerchio.rotta(
        (_) => const SogliaArte(
          id: 'angels_oracle',
          maestro: Maestro.medora,
          child: OracoloDegliAngeliScreen(),
        ),
      );

  @override
  State<OracoloDegliAngeliScreen> createState() =>
      _OracoloDegliAngeliScreenState();
}

/// Le fasi di una consultazione.
///
/// **LA PREPARAZIONE** (GC.09): all'apertura la persona vede insieme la
/// domanda, la scelta fra una carta e tre, il ventaglio e il pulsante; la
/// lettura parte solo dal pulsante (FY.16). Dopo il pulsante la domanda sale
/// lungo la scala (FU.02), Medora riflette (GC.13), le carte si girano una
/// alla volta e si alzano (GC.14), e arriva il responso.
enum _Fase { domanda, saleLaDomanda, riflette, siGirano, risposta }

class _OracoloDegliAngeliScreenState extends State<OracoloDegliAngeliScreen>
    with TickerProviderStateMixin {
  late final RegiaDellaScena _regia;
  // **CREATI IN initState, NON PIGRI**, ordine GA voce GA.08. Erano
  // `late final` con l'inizializzatore: nascevano al primo uso. Con l'altare
  // vuoto all'apertura nessuno li usa prima di una consultazione, e chi
  // chiudeva l'Oracolo senza consultare li faceva nascere dentro `dispose`,
  // a schermata gia' smontata ("Looking up a deactivated widget's ancestor
  // is unsafe"). Prima li toccava il dorso sull'altare, a ogni apertura.
  late final AnimationController _lettere;
  late final AnimationController _giro;

  /// **IL VOLO, IL TAGLIO, LA MISCHIA E L'ALZATA DELLA STESA** (GC.09,
  /// GC.12, GC.14): le stesse durate della Stesa di Tarocchi
  /// (`StesaTiming`), e per l'alzata gli stessi 750 millisecondi.
  late final AnimationController _volo;
  late final AnimationController _taglio;
  late final AnimationController _mescola;
  late final AnimationController _alzo;
  final _domanda = TextEditingController();
  final _scorrimento = ScrollController();
  final _inizioDellaRisposta = GlobalKey();
  late final Random _caso = widget.caso ?? Random();
  late final DateTime _quando = DateTime.now();

  _Fase _fase = _Fase.domanda;

  /// **LA DOMANDA AFFIDATA**: quella che il pulsante rotondo ha affidato.
  /// Vuota finche' la persona non la affida; torna vuota se dopo la
  /// cambia, e allora il ventaglio e il pulsante si spengono finche' non la
  /// affida di nuovo (GC.09, la regola piu' semplice: il ventaglio si
  /// accende quando c'e' una domanda affidata).
  String _affidata = '';
  List<CartaDellOracolo> _carte = const [];
  RispostaDellOracolo? _risposta;
  int _consultazioni = 0;
  bool _avviata = false;

  /// **IL MAZZO COPERTO** della consultazione (FY.15): i 72 in ordine
  /// mescolato, gia' sotto gli occhi all'apertura (GC.09), e gli angeli
  /// scelti dalla persona, uno per posto, per NUMERO e non per posizione nel
  /// ventaglio: Mischia e Taglia riordinano il mazzo senza cambiare le carte
  /// gia' scelte.
  late List<int> _mazzo = EstrazioneDellOracolo.mescola(_caso);
  final List<int> _scelti = [];
  final _ilMazzo = GlobalKey();

  /// **UNA CARTA O TRE** (GC.09, GC.17): all'apertura la stesa a tre carte,
  /// quella che gia' esisteva (FU.03).
  int _quante = 3;

  /// **LA PROFONDITA'** (GC.19): all'apertura Breve.
  AnswerDepth _profondita = AnswerDepth.breve;

  /// La frase breve che dice perche' le carte scelte sono tornate nel mazzo
  /// (GC.09): la persona ha cambiato stesa a meta' scelta.
  String? _rigaDelCambio;

  /// **LA CARTA IN VOLO** (GC.12): il posto sull'altare dove sta arrivando, e
  /// il riquadro sullo schermo del dorso toccato, da dove parte.
  int? _inVolo;
  Rect? _partenzaDelVolo;

  /// Il punto del mazzo dove passa il taglio, come nella Stesa.
  int _taglioIndice = 36;
  int _tagliFatti = 0;

  /// **LE CARTE GIRATE FINORA** (GC.14): si girano una alla volta.
  int _carteGirate = 0;

  /// I sensi della Stesa: la vibrazione e i suoni delle carte, col suo
  /// interruttore (GC.12, GC.13, GC.14).
  final SensiDellaStesa _sensi = SensiDellaStesa();
  bool _silenzio = false;

  final _laPila = GlobalKey();
  final _laScenaInVista = GlobalKey();

  /// L'ASSAGGIO DEL VIANDANTE (FU.10): la consultazione a video scopre solo
  /// la carta del Custode.
  bool _assaggio = false;

  /// La card da condividere, dipinta fuori schermo solo mentre si condivide.
  final _cardKey = GlobalKey();
  bool _renderCard = false;

  Map<String, List<String>> get _corpus => widget.corpus ?? corpusDellOracolo;

  DateTime _ora() => widget.adesso?.call() ?? DateTime.now();

  /// Riduci Movimento o la grafica alleggerita, come nella Stesa.
  bool get _riduciMovimento {
    final tierBasso =
        _forse<QualityTierController>(osserva: true)?.tier == QualityTier.low;
    return MediaQuery.of(context).disableAnimations || tierBasso;
  }

  @override
  void initState() {
    super.initState();
    _lettere = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400));
    _giro = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 520));
    _volo = AnimationController(vsync: this, duration: StesaTiming.volo);
    _taglio = AnimationController(vsync: this, duration: StesaTiming.taglio);
    _mescola =
        AnimationController(vsync: this, duration: StesaTiming.mescolamento);
    _alzo = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 750));
    // **IL FILMATO DURA PER INTERO** (GC.07, GC Aggiunta): il v2 finisce
    // col tavolo vuoto, e nessun taglio lo ferma prima della sua fine.
    // LAPIDE, GA.08: `finoA: GeometriaDellAltare.finoAlleCarte`, 400 ms.
    _regia = RegiaDellaScena(widget.fabbricaDellaScena ??
        () => LettoreDiScena.vero(GeometriaDellAltare.filmato))
      ..addListener(_ridisegna);
    _domanda.addListener(_seCambiaLaDomanda);
  }

  void _ridisegna() {
    if (mounted) setState(() {});
  }

  /// La domanda cambiata dopo l'affido non e' piu' affidata (GC.09).
  void _seCambiaLaDomanda() {
    if (!mounted) return;
    setState(() {
      if (_affidata.isNotEmpty && _domanda.text.trim() != _affidata) {
        _affidata = '';
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_avviata) return;
    _avviata = true;
    unawaited(_regia.avvia(context));
  }

  @override
  void dispose() {
    _regia
      ..removeListener(_ridisegna)
      ..dispose();
    _lettere.dispose();
    _giro.dispose();
    _volo.dispose();
    _taglio.dispose();
    _mescola.dispose();
    _alzo.dispose();
    _domanda.dispose();
    _scorrimento.dispose();
    super.dispose();
  }

  T? _forse<T>({bool osserva = false}) {
    try {
      return osserva ? context.watch<T>() : context.read<T>();
    } catch (senzaProvider) {
      debugPrint('Oracolo degli Angeli: manca $T, ripiego ($senzaProvider)');
      return null;
    }
  }

  BirthIdentity get _identita =>
      widget.identita ??
      _forse<ProfileController>()?.identity ??
      BirthIdentity.example;

  AngelTriad get _triade => GuardianAngels.forBirth(_identita.toBirthDetails());

  bool get _sceneFerma => _regia.ferma;

  /// **I POSTI SULL'ALTARE** della stesa scelta: i tre di FU.03, oppure il
  /// posto unico al centro della stesa a una carta (GC.17).
  List<int> get _posti => _quante == 1 ? const [1] : const [0, 1, 2];

  /// **IL VENTAGLIO SI PUO' TOCCARE** (GC.09): c'e' una domanda affidata,
  /// mancano carte, e nessun gesto del mazzo e' in corso.
  bool get _ventaglioAttivo =>
      _fase == _Fase.domanda &&
      _affidata.isNotEmpty &&
      _scelti.length < _quante &&
      _inVolo == null &&
      !_taglio.isAnimating &&
      !_mescola.isAnimating;

  /// **AVVIA LA LETTURA SI ACCENDE** (GC.09) quando la domanda e' affidata e
  /// il numero di carte scelto e' completo.
  bool get _siPuoAvviare =>
      _fase == _Fase.domanda &&
      _affidata.isNotEmpty &&
      _scelti.length == _quante &&
      _inVolo == null;

  /// **AFFIDARE LA DOMANDA** (FY.15): la domanda resta affidata e il ventaglio
  /// si accende. Le consultazioni del giorno si contano qui, prima della
  /// scelta, cosi' nessuno sceglie le carte per poi trovare la porta chiusa
  /// (FU.10).
  ///
  /// **LAPIDE, ordine FV aggiunta voce FVA.01, 15 ottobre 2026.** Qui una
  /// domanda delicata non estraeva carte e riceveva la risposta di cura col
  /// numero da chiamare (ordine FU voce FU.04, `la_domanda_delicata.dart`, cancellato). Il
  /// fondatore: "Le domande sensibili si respingono elegantemente o, meglio,
  /// si rispondono elegantemente con sensibilità Senza prendersi
  /// responsabilità". La regola sta nell'istruzione al modello, la stessa
  /// delle chat dei Maestri.
  Future<void> _affida() async {
    final domanda = _domanda.text.trim();
    if (domanda.isEmpty || _fase != _Fase.domanda) return;
    FocusManager.instance.primaryFocus?.unfocus();
    if (!await _lePorteSonoAperte()) return;
    if (!mounted) return;
    setState(() => _affidata = domanda);
    _scorriAlMazzo();
  }

  /// **LE CONSULTAZIONI DEL GIORNO** (FU.10): finite, l'invito con le due
  /// strade, una consultazione in piu' a Eos o salire di piano. Finche' il
  /// server non porta il budget nel listino non si conta niente
  /// (`QuestionAllowance.contaGliOracoli`). La stesa a una carta conta come
  /// quella a tre (GC.17, il fondatore: *"conta come consultazione"*).
  Future<bool> _lePorteSonoAperte() async {
    final tier = _tier;
    final borsa = _forse<QuestionAllowance>();
    if (borsa == null || borsa.puoiConsultareGliAngeli(tier)) return true;
    await _leConsultazioniDiOggiSonoFinite();
    return mounted && borsa.puoiConsultareGliAngeli(tier);
  }

  /// **UNA CARTA O TRE** (GC.09): cambiare a meta' scelta rimette nel mazzo
  /// le carte gia' scelte, e lo dice.
  void _cambiaQuante(int quante) {
    if (quante == _quante || _fase != _Fase.domanda) return;
    setState(() {
      _quante = quante;
      _rigaDelCambio = _scelti.isEmpty
          ? null
          : 'Hai cambiato stesa: le carte scelte tornano nel mazzo, '
              'scegline ${quante == 1 ? 'una' : 'tre'}.';
      _scelti.clear();
    });
  }

  /// **UN DORSO SCELTO** (FY.15, GC.12): e' quel dorso, il dorso toccato, a
  /// volare dal suo posto nel ventaglio al suo posto sull'altare, col suono
  /// della carta della Stesa. Nella stesa a tre il primo e' la carta del
  /// Custode, il secondo del Cuore, il terzo dell'Intelletto; nella stesa a
  /// una la carta del momento, al centro.
  Future<void> _scegli(int indice, Rect? partenza) async {
    if (!_ventaglioAttivo || indice < 0 || indice >= _mazzo.length) return;
    final numero = _mazzo[indice];
    if (_scelti.contains(numero)) return;
    final posto = _posti[_scelti.length];
    // **IL SUONO DEL VOLO** (GC.12): la Stesa al volo vibra soltanto, e il
    // suono che usa per la carta e' `carta.mp3` (`SuonoDelCerchio.carta`,
    // quello che sente quando la carta si posa e si gira): lo stesso file,
    // nessun suono nuovo. Parte solo col Suono acceso e col telefono che lo
    // permette (`PaletteSensoriale.suona`), senza prendere il fuoco audio.
    _sensi.momento(context, MomentoSensoriale.volo);
    if (!_sensi.muto) {
      unawaited(PaletteSensoriale.suona(context, SuonoDelCerchio.carta));
    }
    setState(() {
      _rigaDelCambio = null;
      _scelti.add(numero);
      _inVolo = posto;
      _partenzaDelVolo = partenza;
    });
    if (!_riduciMovimento && partenza != null) {
      await _volo.forward(from: 0);
      if (!mounted) return;
    }
    setState(() {
      _inVolo = null;
      _partenzaDelVolo = null;
    });
  }

  /// **IL TAGLIO** (GC.09), lo stesso gesto della Stesa: il mazzo si divide
  /// nel punto del taglio e la seconda meta' passa sopra.
  Future<void> _taglia() async {
    if (!_ventaglioAttivo) return;
    _sensi.momento(context, MomentoSensoriale.taglio);
    const scostamenti = [0, 5, -4, 8, -7];
    setState(() {
      _tagliFatti++;
      _taglioIndice = 36 + scostamenti[_tagliFatti % scostamenti.length];
    });
    if (!_riduciMovimento) await _taglio.forward(from: 0);
    if (!mounted) return;
    _taglio.value = 0;
    setState(() => _mazzo = [
          ..._mazzo.sublist(_taglioIndice),
          ..._mazzo.sublist(0, _taglioIndice),
        ]);
  }

  /// **LA MISCHIA** (GC.09), lo stesso gesto della Stesa.
  Future<void> _mischia() async {
    if (!_ventaglioAttivo) return;
    _sensi.momento(context, MomentoSensoriale.mescolamento);
    if (!_riduciMovimento) await _mescola.forward(from: 0);
    if (!mounted) return;
    _mescola.value = 0;
    setState(() => _mazzo = EstrazioneDellOracolo.mescola(_caso));
  }

  /// **AVVIARE LA LETTURA** (FY.16, GC.13, GC.14), solo dal pulsante e solo
  /// con la domanda affidata e le carte scelte: la domanda sale lungo la
  /// scala, Medora riflette mentre la lettura arriva, l'effetto della
  /// rivelazione, poi le carte si girano una alla volta e si alzano.
  Future<void> _avviaLaLettura() async {
    if (!_siPuoAvviare) return;
    if (!await _lePorteSonoAperte()) return;
    if (!mounted) return;
    final tier = _tier;
    final domanda = _affidata;
    final carte = _quante == 1
        ? EstrazioneDellOracolo.dallaScelta(_scelti.first)
        : EstrazioneDellOracolo.dalleScelte(_triade, List<int>.of(_scelti));
    final variante = _consultazioni;
    // **L'ASSAGGIO DEL VIANDANTE** (FU.10): la carta del Custode dal corpus,
    // senza modello; Cuore e Intelletto restano col lucchetto e l'invito.
    // Nella stesa a una carta l'unica carta si scopre intera, e la lettura
    // e' quella del corpus (la riga "Solo il Custode" della matrice).
    final assaggio = !PlanCatalog.apre(RigaDelPiano.oracoloTreCarte, tier);
    // **LA LUNGA SCELTA NEL SELETTORE** (GC.19): solo per chi ha il piano.
    final profonda = _profondita == AnswerDepth.profonda &&
        PlanCatalog.apre(RigaDelPiano.oracoloLunga, tier);
    // GC.17: una carta o tre, e' una consultazione.
    _forse<QuestionAllowance>()?.registraOracolo(tier);
    final riduci = _riduciMovimento;
    setState(() {
      _carte = carte;
      _risposta = null;
      _fase = _Fase.saleLaDomanda;
      _consultazioni++;
      _assaggio = assaggio && _quante == 3;
      _carteGirate = 0;
    });
    _giro.value = 0;
    _alzo.value = 0;
    // La scena torna in vista: la domanda sale lungo la scala.
    if (_scorrimento.hasClients) {
      unawaited(_scorrimento.animateTo(0,
          duration: const Duration(milliseconds: 500), curve: Curves.easeOut));
    }
    final lettura = assaggio
        ? Future.value(LaLetturaDellOracolo.delCorpus(
            domanda: domanda,
            carte: carte,
            corpus: _corpus,
            variante: variante,
            // Ordine GA voce GA.06: nell'assaggio il Cuore e l'Intelletto
            // restano col lucchetto, e il responso non li nomina.
            soloIlCustode: true))
        : LaLetturaDellOracolo.leggi(
            domanda: domanda,
            carte: carte,
            corpus: _corpus,
            variante: variante,
            profonda: profonda,
            chiamata: widget.chiamata,
          );
    if (riduci) {
      _lettere.value = 1;
    } else {
      await _lettere.forward(from: 0);
    }
    if (!mounted) return;
    // **MEDORA RIFLETTE** (GC.13): l'animazione di riflessione della Stesa
    // (`AttesaDiMedora`), che dura finche' serve a preparare il responso e
    // non si taglia: il tocco la lascia correre. Chi riflette lo dichiara
    // prima, come la Stesa (ordine BV voce 02), cosi' nessuna festa le si
    // apre sopra.
    RiflessioniInCorso.entra(() => mounted && _fase == _Fase.riflette);
    setState(() => _fase = _Fase.riflette);
    final esiti = await Future.wait<Object?>([
      Future<void>.delayed(AttesaDiMedora.minimaPer(riduciMovimento: riduci)),
      lettura,
    ]);
    if (!mounted) return;
    final risposta = esiti[1] as RispostaDellOracolo;
    // **L'EFFETTO DOPO LA RIFLESSIONE** (GC.13): `rivelazione.mp3`, il suono
    // della rivelazione che la Stesa ha nel suo catalogo dei momenti
    // (`MomentoSensoriale.reveal`), una volta.
    _sensi.momento(context, MomentoSensoriale.reveal);
    setState(() {
      _risposta = risposta;
      _fase = _Fase.siGirano;
    });
    await Future<void>.delayed(AttesaDiMedora.dissolvenza);
    if (!mounted) return;
    await _leCarteSiGiranoESiAlzano(riduci);
    if (!mounted) return;
    setState(() => _fase = _Fase.risposta);
    unawaited(RegiaDelCammino.dopoUnGesto(context, 'oracolo_angeli'));
    _scorriAllaRisposta();
  }

  /// **LE CARTE SI GIRANO UNA ALLA VOLTA, POI SI ALZANO** (GC.14), con la
  /// sequenza della Stesa (`_laSequenzaDelTavolo`): ogni carta col suo
  /// suono, un respiro, poi tutte in piedi ingrandite.
  Future<void> _leCarteSiGiranoESiAlzano(bool riduci) async {
    if (riduci) {
      setState(() => _carteGirate = _carte.length);
      _alzo.value = 1;
      return;
    }
    for (var i = 0; i < _carte.length; i++) {
      if (!mounted) return;
      final c = _carte[i];
      final siGira = !c.coperta && !(_assaggio && i > 0);
      if (siGira) {
        _sensi.momento(context, MomentoSensoriale.flip);
        await _giro.forward(from: 0);
        if (!mounted) return;
      }
      setState(() => _carteGirate = i + 1);
      _giro.value = 0;
      await Future<void>.delayed(const Duration(milliseconds: 160));
    }
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    await _alzo.forward(from: 0);
  }

  /// **UNA NUOVA CONSULTAZIONE** nella stessa apertura: il video non riparte,
  /// le carte tornano nel mazzo e la persona affida la domanda nuova (FU.02).
  void _nuovaDomanda() {
    _giro.value = 0;
    _lettere.value = 0;
    _alzo.value = 0;
    _domanda.clear();
    setState(() {
      _fase = _Fase.domanda;
      _affidata = '';
      _risposta = null;
      _carte = const [];
      _mazzo = EstrazioneDellOracolo.mescola(_caso);
      _scelti.clear();
      _assaggio = false;
      _carteGirate = 0;
      _rigaDelCambio = null;
    });
    _scorrimento.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
  }

  Tier get _tier => _forse<EntitlementService>()?.tier ?? Tier.free;

  /// **MAI UN VICOLO CIECO** (FU.10): le consultazioni del giorno finite
  /// aprono l'invito con le due strade, una consultazione in piu' a Eos
  /// (prezzo dal listino del server, detto prima del gesto) oppure salire
  /// di piano.
  Future<void> _leConsultazioniDiOggiSonoFinite() async {
    final riscatto = corredoDelRiscatto(context,
        budget: QuestionAllowance.kOracoliAngeli,
        cosaUna: 'una consultazione degli Angeli');
    await showUpgradeInvite(
      context,
      title: 'Le consultazioni di oggi sono finite',
      message: 'Domani gli angeli tornano ad ascoltarti. Oppure affida '
          'questa domanda subito, o sali di piano per consultarli più volte '
          'ogni giorno.',
      riscattoLabel: riscatto.label,
      onRiscatta: riscatto.azione,
    );
  }

  /// **IL LUCCHETTO E L'INVITO** (FU.10): ogni voce che il piano chiude lo
  /// dice, con la strada per aprirla. Mai un vicolo cieco.
  Future<void> _invitoAlPiano(RigaDelPiano riga, String cosa) async {
    final dal = PlanCatalog.dalPiano((t) => PlanCatalog.apre(riga, t));
    final piano = dal?.replaceFirst('Dall’', '');
    await showUpgradeInvite(
      context,
      title: piano == null ? cosa : '$cosa è dell’$piano',
      message: piano == null
          ? '$cosa si apre con un piano del Cerchio.'
          : '$cosa si apre dal piano $piano in su, ogni giorno.',
    );
  }

  // **LAPIDE, ordine FY voce FY.14, 16 ottobre 2026.** Qui stavano la
  // domanda per un amico (i suoi tre angeli dalla nascita prestata col
  // codice) e il "Presta la tua nascita" dell'Oracolo, ordine FU voce FU.09.
  // Il fondatore: "Elimina presta la tua nascita e chiedi per un amico". La
  // Sinastria evolutiva e il Calendario Lunare tengono il loro gesto.

  /// **LA CARD DA CONDIVIDERE** (FU.09): le tre carte e il titolo, mai la
  /// domanda, mai la nascita. Torna l'esito vero, e il premio dichiarato si
  /// paga solo a condivisione avvenuta.
  Future<bool> _onShare() async {
    setState(() => _renderCard = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final andata = await shareOracoloCard(
        boundaryKey: _cardKey,
        text: 'I miei angeli hanno risposto. Esoteric Circle.',
      );
      if (andata && mounted) {
        await PremioDellaCondivisione.premia(context,
            cosa: 'Hai condiviso il tuo Oracolo degli Angeli');
      }
      return andata;
    } catch (errore) {
      debugPrint('Oracolo degli Angeli: la card non si prepara ($errore)');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Non riesco a preparare la card ora.')),
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => _renderCard = false);
    }
  }

  /// Il mazzo coperto in vista, in fondo alla finestra: sopra resta
  /// l'altare, dove volano i dorsi scelti.
  void _scorriAlMazzo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = _ilMazzo.currentContext;
      if (c == null || !mounted) return;
      unawaited(Scrollable.ensureVisible(c,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          alignment: 1));
    });
  }

  void _scorriAllaRisposta() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = _inizioDellaRisposta.currentContext;
      if (c == null || !mounted) return;
      unawaited(Scrollable.ensureVisible(c,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          alignment: 0.1));
    });
  }

  /// **DOVE ARRIVA LA CARTA IN VOLO** (GC.12): il riquadro del suo posto
  /// sull'altare, nelle coordinate della pila della schermata.
  Rect? _arrivoSullAltare(int posto) {
    final scena = _laScenaInVista.currentContext?.findRenderObject();
    final pila = _laPila.currentContext?.findRenderObject();
    if (scena is! RenderBox || pila is! RenderBox || !scena.hasSize) {
      return null;
    }
    final w = scena.size.width;
    final r = GeometriaDellAltare.sullAltare(posto, w)
        .shift(Offset(0, -_suDelVideo));
    final alto = pila.globalToLocal(scena.localToGlobal(r.topLeft));
    return alto & r.size;
  }

  /// **IL VIDEO SALE DI DIECI PIXEL DEL TELEFONO** (GC.10): dieci pixel
  /// fisici, convertiti in punti col rapporto di pixel del dispositivo. Sul
  /// Realme (densita' 3) sono 3,33 punti.
  double get _suDelVideo =>
      GeometriaDellAltare.pixelDaAlzare /
      MediaQuery.devicePixelRatioOf(context);

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    // IL TOCCO CHE SALTA IL VIDEO, ordine FU voce FU.15, punto unico.
    return IlToccoCheSalta(
      inCorso: _regia.inCorso,
      onSalta: _regia.salta,
      child: Scaffold(
        // **LO SFONDO E' COSMICO** (GC.16): era `palette.deepest`, un blu
        // pieno sotto la scena e dietro il responso. Adesso il cosmo della
        // Stesa di Tarocchi (`CosmosBackground`) sta dietro tutta la
        // schermata, la scena compresa, che lo copre col suo fotogramma.
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          key: const Key('oracolo_barra'),
          // **SEMPRE SEMITRASPARENTE** (FY.20): un velo solo in ogni stato,
          // anche scorrendo. Il colore e' esplicito, cosi' lo stato "sotto
          // la barra" di Material 3 non lo cambia, e nessuna elevazione ne'
          // tinta di superficie lo riempie.
          backgroundColor:
              palette.deepest.withValues(alpha: AppTheme.veloDellaBarra),
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          iconTheme: IconThemeData(color: palette.goldSoft),
          // Il titolo si legge sopra il testo che scorre per l'ombra scura
          // del suo inchiostro, non per una barra piena.
          title: TitoloCheNonSiRompe(
              chiaveDelTesto: const Key('oracolo_titolo'),
              testo: 'Oracolo degli Angeli',
              righe: 1,
              stile: TypographyTokens.titoloSezione().copyWith(shadows: [
                Shadow(color: palette.deepest, blurRadius: 4),
                Shadow(color: palette.deepest, blurRadius: 10),
              ])),
          actions: [
            FoglioDelleFonti.bottone(context,
                palette: palette,
                testo: TestiDelleFonti.oracoloAngeli,
                chiave: 'oracolo_fonti'),
            const AngoloDellaBarra(),
          ],
        ),
        body: CosmosBackground(
          key: const Key('oracolo_sfondo'),
          seed: 7,
          showZodiac: false,
          paletteOverride: palette,
          child: Stack(
            key: _laPila,
            children: [
              Positioned.fill(child: _ilCorpo(palette)),
              // **LA CARTA CHE VOLA** (GC.12): il dorso toccato, dal suo
              // posto nel ventaglio al suo posto sull'altare.
              if (_inVolo != null && _partenzaDelVolo != null)
                AnimatedBuilder(
                  animation: _volo,
                  builder: (context, _) {
                    final pila = _laPila.currentContext?.findRenderObject();
                    final arrivo = _arrivoSullAltare(_inVolo!);
                    if (pila is! RenderBox || arrivo == null) {
                      return const SizedBox.shrink();
                    }
                    final p = _partenzaDelVolo!;
                    final da = pila.globalToLocal(p.topLeft) & p.size;
                    final t = Curves.easeInOutCubic.transform(_volo.value);
                    final r = Rect.lerp(da, arrivo, t)!;
                    return Positioned.fromRect(
                      key: const Key('oracolo_carta_in_volo'),
                      rect: r,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                  color: palette.goldSoft.withValues(
                                      alpha: 0.45 * sin(t * pi)),
                                  blurRadius: 18,
                                  spreadRadius: 2),
                            ],
                          ),
                          child: Image.asset(GeometriaDellAltare.dorso,
                              fit: BoxFit.fill,
                              filterQuality: FilterQuality.medium),
                        ),
                      ),
                    );
                  },
                ),
              // **MEDORA RIFLETTE** (GC.13): l'attesa della Stesa, sopra la
              // scena.
              if (_fase == _Fase.riflette)
                Positioned.fill(
                  child: AttesaDiMedora(
                    key: const Key('oracolo_riflessione'),
                    palette: palette,
                    riduciMovimento: _riduciMovimento,
                    rotazione: _consultazioni,
                  ),
                ),
              // **LA CARD DA CONDIVIDERE**, fuori schermo e solo mentre si
              // condivide (FU.09): le tre carte e il titolo, mai la domanda,
              // mai i tre angeli della persona, che direbbero la nascita.
              if (_renderCard && _risposta != null)
                Positioned(
                  left: -3000,
                  top: 0,
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: OracoloShareCard(
                      carte: _carte,
                      titolo: OracoloShareCard.titoloPerLaCard(
                          _risposta!.titolo, _affidata),
                      palette: palette,
                      scoperte:
                          _assaggio ? const {RuoloDellAngelo.custode} : null,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ilCorpo(MaestroPalette palette) {
    final attivo = _ventaglioAttivo;
    return ListView(
      controller: _scorrimento,
      padding: EdgeInsets.zero,
      children: [
        LayoutBuilder(
          builder: (context, vincoli) => _laScena(vincoli.maxWidth, palette),
        ),
        // **SOPRA IL VIDEO SOLO IL VIDEO**, ordine FX voce FXA.08: tutto
        // cio' che sta sotto la scena aspetta la scena ferma e compare in
        // dissolvenza.
        IlRestoDopoLaScena(
          scenaFerma: _sceneFerma,
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // **L'ORDINE SOTTO IL TAVOLO** (GC.09): la domanda, la scelta
                // fra una carta e tre (con la profondita', GC.19), il
                // ventaglio coi suoi gesti e il pulsante, in quest'ordine,
                // tutti in vista all'apertura. LAPIDE: la domanda in
                // sovrimpressione sulla scena, in alto, e il mazzo che
                // compariva solo dopo averla affidata (ordine FY).
                if (_fase == _Fase.domanda) ...[
                  _LaDomanda(
                    palette: palette,
                    controllo: _domanda,
                    affidata: _affidata,
                    onAffida: _affida,
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  _LeOpzioni(
                    palette: palette,
                    quante: _quante,
                    profondita: _profondita,
                    piano: _tier,
                    onQuante: _cambiaQuante,
                    onProfondita: (d) => setState(() => _profondita = d),
                    onLocked: () => _invitoAlPiano(
                        RigaDelPiano.oracoloLunga, 'La risposta lunga'),
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  AnimatedBuilder(
                    animation: Listenable.merge([_taglio, _mescola]),
                    builder: (context, _) => _IlMazzoCoperto(
                      key: _ilMazzo,
                      palette: palette,
                      attivo: attivo,
                      affidata: _affidata.isNotEmpty,
                      quante: _quante,
                      scelti: _scelti.length,
                      presi: {
                        for (var i = 0; i < _mazzo.length; i++)
                          if (_scelti.contains(_mazzo[i])) i,
                      },
                      taglio: _taglio.value,
                      mescolamento: _mescola.value,
                      taglioIndice: _taglioIndice,
                      silenzio: _silenzio,
                      riduciMovimento: _riduciMovimento,
                      rigaDelCambio: _rigaDelCambio,
                      onScegli: (i, r) => unawaited(_scegli(i, r)),
                      onTaglia: () => unawaited(_taglia()),
                      onMischia: () => unawaited(_mischia()),
                      onSilenzio: () => setState(() {
                        _silenzio = !_silenzio;
                        _sensi.silenzio = _silenzio;
                      }),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Center(
                    child: PulsanteDipinto(
                      key: const Key('oracolo_avvia_la_lettura'),
                      testo: 'Avvia la lettura',
                      onTap: _siPuoAvviare
                          ? () => unawaited(_avviaLaLettura())
                          : null,
                    ),
                  ),
                  if (!_siPuoAvviare) ...[
                    const SizedBox(height: SpacingTokens.xxs),
                    Text(
                      _affidata.isEmpty
                          ? 'Affida la domanda col pulsante rotondo, poi '
                              'scegli ${_quante == 1 ? 'la tua carta' : 'le tre carte'}.'
                          : 'Scegli ${_quante == 1 ? 'la tua carta' : 'le tre carte'} '
                              'dal ventaglio, poi avvia la lettura.',
                      key: const Key('oracolo_come_si_avvia'),
                      textAlign: TextAlign.center,
                      style: TypographyTokens.corpo()
                          .copyWith(color: ColorTokens.textSecondary),
                    ),
                  ],
                  const SizedBox(height: SpacingTokens.lg),
                ],
                SizedBox(key: _inizioDellaRisposta, height: SpacingTokens.lg),
                if (_fase == _Fase.risposta && _risposta != null) ...[
                  _IlResponso(
                    palette: palette,
                    risposta: _risposta!,
                    carte: _carte,
                    corpus: _corpus,
                    variante: _consultazioni - 1,
                    quando: _quando,
                    assaggio: _assaggio,
                    riduciMovimento: _riduciMovimento,
                    onCondividi: _onShare,
                    onInvito: _invitoAlPiano,
                  ),
                  // LA RISPOSTA LUNGA (FU.10), dall'Iniziato dall'ordine GA
                  // voce GA.05: a chi non l'ha, il lucchetto e l'invito, mai
                  // un vicolo cieco. Dalla matrice nuova e' il solo
                  // Viandante, che e' nell'assaggio: il lucchetto c'e'
                  // anche li', perche' la Lunga e' cio' che il piano apre.
                  if (!PlanCatalog.apre(RigaDelPiano.oracoloLunga, _tier)) ...[
                    const SizedBox(height: SpacingTokens.sm),
                    _IlLucchetto(
                      chiave: 'oracolo_lucchetto_lunga',
                      palette: palette,
                      testo: 'La risposta lunga: Medora va più a fondo '
                          'nella tua domanda e ti dà il salmo propiziatorio '
                          'del tuo angelo',
                      onTap: () => _invitoAlPiano(
                          RigaDelPiano.oracoloLunga, 'La risposta lunga'),
                    ),
                  ],
                  const SizedBox(height: SpacingTokens.lg),
                  Center(
                    child: PulsanteDipinto(
                      key: const Key('oracolo_nuova_domanda'),
                      testo: 'Affida una nuova domanda',
                      onTap: _nuovaDomanda,
                    ),
                  ),
                  // **L'ANGELO DELL'ORA DOPO LA LETTURA** (GC.08): all'apertura
                  // non si vede nessun messaggio; l'angelo dell'ora e il
                  // messaggio del giorno (FU.08) arrivano solo a lettura
                  // fatta, in fondo.
                  const SizedBox(height: SpacingTokens.lg),
                  _LAngeloDellOra(
                    palette: palette,
                    adesso: _ora(),
                    triade: _triade,
                    corpus: _corpus,
                  ),
                ],
                const SizedBox(height: SpacingTokens.xxl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// **LA SCENA**: il fotogramma a tutta larghezza, il video sopra finche'
  /// gira, l'altare vuoto quando la scena e' ferma, i dorsi che la persona
  /// sceglie (GA.08: nessuno all'apertura), le lettere di luce, e le carte
  /// che si girano e si alzano (GC.14).
  ///
  /// **SALE DI DIECI PIXEL** (GC.10): il fotogramma, il video e tutto cio'
  /// che ci sta sopra salgono insieme di [_suDelVideo] punti, dietro la barra
  /// semitrasparente; la scena e' alta altrettanto di meno, cosi' cio' che
  /// sta sotto sale con lei.
  Widget _laScena(double w, MaestroPalette palette) {
    final h = GeometriaDellAltare.altezza(w);
    final su = _suDelVideo;
    final scelti = _scelti.length;
    return SizedBox(
      key: const Key('oracolo_scena'),
      width: w,
      height: h - su,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topCenter,
          minHeight: h,
          maxHeight: h,
          child: Transform.translate(
            offset: Offset(0, -su),
            child: SizedBox(
              key: _laScenaInVista,
              width: w,
              height: h,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      _sceneFerma
                          ? GeometriaDellAltare.ultimoFotogramma
                          : GeometriaDellAltare.primoFotogramma,
                      key: const Key('oracolo_fotogramma'),
                      fit: GeometriaDellAltare.taglio,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                  if (_regia.filmatoInScena)
                    Positioned.fill(
                      child: IlFilmatoCheSfuma(
                        key: const Key('oracolo_filmato'),
                        // **IL SALTO E LA FINE ARRIVANO ALLO STESSO
                        // FOTOGRAMMA** (GC.07): sotto il filmato sta il suo
                        // ultimo fotogramma, col tavolo vuoto del v2; il
                        // salto sfuma su di lui, e a filmato finito la
                        // dissolvenza passa fra due immagini uguali.
                        saltato: _regia.saltata || _sceneFerma,
                        child: _regia.disegna(),
                      ),
                    ),
                  // LAPIDE, FY.17: `AltareVuoto`, la fascia dell'altare dal
                  // primo fotogramma sopra l'ultimo, che nel v1 portava i tre
                  // dorsi dipinti. L'ultimo fotogramma del v2 ha l'altare
                  // vuoto (GC Aggiunta): la toppa non serve piu'.
                  if (_sceneFerma)
                    for (var k = 0; k < _posti.length; k++)
                      // **GA.08**: all'apertura e a ogni domanda nuova
                      // l'altare e' vuoto; mentre si sceglie stanno solo i
                      // dorsi gia' arrivati, poi le carte della lettura.
                      if (_fase == _Fase.domanda
                          ? k < scelti && _inVolo != _posti[k]
                          : k < _carte.length)
                        _CartaSullAltare(
                          posto: _posti[k],
                          larghezza: w,
                          carta: _fase == _Fase.domanda ? null : _carte[k],
                          // L'assaggio del Viandante gira solo il Custode.
                          chiusa: _assaggio && k > 0,
                          girata: k < _carteGirate,
                          staGirando:
                              k == _carteGirate && _fase == _Fase.siGirano,
                          giro: _giro,
                          alzo: _alzo,
                          parola: _fase == _Fase.domanda
                              ? null
                              : LaScalaDelResponso.parolaDi(_carte[k]),
                          palette: palette,
                          onApri: _fase == _Fase.risposta
                              ? () => _apriLaCarta(_carte[k])
                              : null,
                        ),
                  if (_fase == _Fase.saleLaDomanda)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          key: const Key('oracolo_lettere_di_luce'),
                          painter: _LettereDiLuce(
                            testo: _affidata,
                            progresso: _lettere,
                            scala: GeometriaDellAltare.scala(w),
                            colore: palette.goldSoft,
                            scalaDelTesto: MediaQuery.textScalerOf(context),
                          ),
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

  /// **LA CARTA IN PIEDI SI APRE** (GC.14): il foglio con la descrizione
  /// dell'angelo, dai dati gia' presenti.
  Future<void> _apriLaCarta(CartaDellOracolo c) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    return LaCartaDellAngeloAperta.apri(
      context,
      angelo: c.angelo,
      parola: LaScalaDelResponso.parolaDi(c),
      chiE: _LaBollaDellaCarta.chiE(c.angelo),
      cosaPorta: _LaBollaDellaCarta.cosaPorta(c.angelo),
      messaggio: LaLetturaDellOracolo.messaggioDellaCarta(
          _corpus, c, _consultazioni - 1),
      palette: palette,
    );
  }
}

/// **UNA CARTA SULL'ALTARE**: il dorso posato in prospettiva esattamente
/// dove sta nel fotogramma, che si gira nella carta vera.
///
/// **SI GIRA, SI ALZA E SI TOCCA** (GC.14). Il fondatore: *"Dopo
/// l'animazione di riflessione, le carte si girano sul tavolo una alla volta
/// con effetto sonoro e subito dopo si alzano in verticale ingrandendosi. Per
/// la stesa a 3 sopra ogni carta c'è scritto \"fare\", \"sentire\",
/// \"capire\", mentre per la stesa a 1 carta \"la carta del momento\". Se
/// faccio click su una carta in verticale ottengo una schermata popup con la
/// descrizione della carta angelo."* La carta si gira quando e' il suo turno
/// ([staGirando]); poi, con [alzo], passa dalla posa sull'altare alla posa in
/// piedi (`GeometriaDellAltare.inPiedi`), piu' grande, e sopra compare la sua
/// [parola] con la grafica della scritta della Stesa. In piedi, il tocco la
/// apre ([onApri]).
class _CartaSullAltare extends StatelessWidget {
  const _CartaSullAltare({
    required this.posto,
    required this.larghezza,
    required this.carta,
    required this.giro,
    required this.alzo,
    required this.palette,
    this.girata = false,
    this.staGirando = false,
    this.chiusa = false,
    this.parola,
    this.onApri,
  });

  /// Chiusa dal piano: resta dorso, come la carta coperta (FU.10).
  final bool chiusa;

  /// Il posto sull'altare: 0, 1 o 2; la carta del momento sta all'1.
  final int posto;
  final double larghezza;

  /// La carta della lettura; nulla mentre si sceglie, ed e' un dorso.
  final CartaDellOracolo? carta;
  final Animation<double> giro;
  final Animation<double> alzo;
  final MaestroPalette palette;

  /// Gia' girata, o girandosi adesso.
  final bool girata;
  final bool staGirando;

  /// La scritta sopra la carta in piedi.
  final String? parola;

  final VoidCallback? onApri;

  /// Lo stile della scritta: quello della scritta della Stesa sotto le sue
  /// carte in piedi (`_Slot._stileDellEtichettaAlta`).
  static TextStyle get stileDellaParola =>
      TypographyTokens.etichetta().copyWith(letterSpacing: 0.6, height: 1.1);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([giro, alzo]),
      builder: (context, _) {
        final c = carta;
        final a = Curves.easeInOutCubic.transform(alzo.value);
        final r = Rect.lerp(
            GeometriaDellAltare.cartaDritta(posto, larghezza),
            GeometriaDellAltare.inPiedi(posto, larghezza,
                unaSola: c?.delMomento ?? false),
            a)!;
        final siGira = c != null && !c.coperta && !chiusa;
        final t = !siGira
            ? 0.0
            : (girata ? 1.0 : (staGirando ? giro.value : 0.0));
        final faccia = t > 0.5;
        final cartaDisegnata = Transform(
          alignment: Alignment.bottomCenter,
          transform: GeometriaDellAltare.posa(larghezza,
              giro: faccia ? t - 1 : t, alzata: a),
          child: faccia
              ? LaCartaDellAngelo(
                  key: Key('oracolo_carta_${c!.delMomento ? 'momento' : c.ruolo.name}'),
                  angelo: c.angelo,
                  palette: palette,
                )
              : Image.asset(GeometriaDellAltare.dorso,
                  key: Key('oracolo_dorso_$posto'),
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.medium),
        );
        return Positioned.fromRect(
          rect: r,
          child: LaScenaFermaCheAppare(
            appare: true,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    key: Key('oracolo_in_piedi_$posto'),
                    behavior: HitTestBehavior.opaque,
                    onTap: a >= 1 ? onApri : null,
                    child: cartaDisegnata,
                  ),
                ),
                if (parola != null && a > 0)
                  Positioned(
                    left: -SpacingTokens.lg,
                    right: -SpacingTokens.lg,
                    bottom: r.height + SpacingTokens.xxs,
                    child: Opacity(
                      opacity: a,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(parola!.toUpperCase(),
                            key: Key('oracolo_parola_$posto'),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: stileDellaParola.copyWith(
                                color: palette.goldSoft,
                                shadows: [
                                  Shadow(
                                      color: palette.deepest, blurRadius: 6),
                                ])),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// **LA CARTA DI UN ANGELO**: l'arte coi cartigli vuoti, e il numero e il
/// nome sovrapposti in Flutter, come nel resto del mazzo dei 72 (FU.03). Le
/// placche sono quelle della cornice madre, la stessa dei tarocchi
/// (`TarotFrame`).
class LaCartaDellAngelo extends StatelessWidget {
  const LaCartaDellAngelo({
    super.key,
    required this.angelo,
    required this.palette,
  });

  final Angel angelo;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, vincoli) {
      final w = vincoli.maxWidth;
      final h = vincoli.hasBoundedHeight ? vincoli.maxHeight : w * 1.5;
      Rect px(Rect n) =>
          Rect.fromLTRB(n.left * w, n.top * h, n.right * w, n.bottom * h);
      // **ALLA MISURA IN CUI SI VEDE**, ordine GC voci GC.01 e GC.16: la
      // stessa regola delle carte dei Tarocchi (`TarotCardArt.gradinoPer`),
      // la miniatura del bundle per le carte piccole, l'arte piena
      // decodificata alla misura media o intera solo quando serve.
      final gradino = TarotCardArt.gradinoPer(
          w * (MediaQuery.maybeDevicePixelRatioOf(context) ?? 1));
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            gradino.miniatura
                ? FamilyImage.thumb(AssetFamily.angeli, angelo.artStem)
                : FamilyImage.full(AssetFamily.angeli, angelo.artStem),
            fit: BoxFit.fill,
            cacheWidth: gradino.decodifica,
            gaplessPlayback: true,
            filterQuality: FilterQuality.medium,
          ),
          if (w > SpacingTokens.xxl)
            Positioned.fromRect(
              rect: px(TarotFrame.cartiglioNumero),
              child:
                  CartiglioTesto(righe: ['${angelo.number}'], palette: palette),
            ),
          if (w > SpacingTokens.xxl)
            Positioned.fromRect(
              rect: px(TarotFrame.cartiglioNome),
              child: CartiglioTesto(righe: [angelo.name], palette: palette),
            ),
        ],
      );
    });
  }
}

/// **LE LETTERE DI LUCE**: la domanda affidata si scioglie in lettere che
/// salgono lungo la scala, dall'altare alla cima (FU.02). Disegno di
/// Flutter con la domanda vera, non video.
class _LettereDiLuce extends CustomPainter {
  _LettereDiLuce({
    required this.testo,
    required this.progresso,
    required this.scala,
    required this.colore,
    required this.scalaDelTesto,
  }) : super(repaint: progresso);

  final String testo;
  final Animation<double> progresso;
  final double scala;
  final Color colore;

  /// La scala del testo del sistema: le lettere si misurano come si vedono
  /// (guardia chi_misura_il_testo_usa_la_scala).
  final TextScaler scalaDelTesto;

  /// La scala nel fotogramma: il centro sta a meta' larghezza, l'altare a
  /// 1530, la cima a 0.
  static const double _centro = 540;
  static const double _partenza = 1530;

  @override
  void paint(Canvas canvas, Size size) {
    final lettere = testo.characters.where((c) => c.trim().isNotEmpty).toList();
    if (lettere.isEmpty) return;
    final t = progresso.value;
    final n = lettere.length;
    for (var i = 0; i < n; i++) {
      // Ogni lettera parte poco dopo la precedente e sale in 60% del tempo.
      final inizio = 0.4 * i / n;
      final locale = ((t - inizio) / 0.6).clamp(0.0, 1.0);
      if (locale <= 0) continue;
      final y = (_partenza - locale * _partenza) * scala;
      final ondeggio = sin((locale * 6) + i) * 18 * scala;
      final x = _centro * scala + ondeggio;
      final opacita = locale < 0.15
          ? locale / 0.15
          : (1 - (locale - 0.15) / 0.85).clamp(0.0, 1.0);
      final tp = TextPainter(
        text: TextSpan(
          text: lettere[i],
          style: TypographyTokens.titoloScheda().copyWith(
            color: colore.withValues(alpha: opacita),
            shadows: [
              Shadow(color: colore.withValues(alpha: opacita), blurRadius: 12),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
        textScaler: scalaDelTesto,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_LettereDiLuce vecchio) =>
      vecchio.testo != testo || vecchio.colore != colore;
}

/// **LA DOMANDA**, subito sotto il tavolo (GC.09): scritta o scelta fra
/// quelle proposte.
///
/// Ordine FY voce FY.13: dieci domande per argomento, nella voce di Medora.
/// Gli argomenti e il pulsante che affida sono i pezzi dipinti del ramo
/// (R8); le proposte sono righe da leggere, in un riquadro che scorre da
/// solo, cosi' dieci domande non coprono la schermata.
///
/// **LA TENDINA SI CHIUDE E IL PULSANTE HA LA FRECCIA DI INVIO** (GC.11). Il
/// fondatore: *"nel selettore della domanda, quando la domanda viene scelta,
/// la tendina con le domande sparisce. Cambia il simbolo del pulsante
/// rotondo con il simbolo di \"invio\" ovvero la freccia che curva di enter
/// della tastiera."* Toccata una proposta, la tendina si chiude e resta la
/// domanda scelta nel campo; il pulsante rotondo che affida mostra
/// `Icons.keyboard_return_rounded`, la freccia del tasto Invio, dal set di
/// icone gia' in uso. LAPIDE: `Icons.auto_awesome_rounded`, e la tendina
/// che restava aperta finche' non si ritoccava il tema.
///
/// **VALE L'ULTIMA DOMANDA** (GC.04): qui le due vie scrivono nello stesso
/// campo, quindi ne resta sempre una sola. Scegliere una proposta sostituisce
/// cio' che era scritto; scrivere dopo la scelta la cambia.
class _LaDomanda extends StatefulWidget {
  const _LaDomanda({
    required this.palette,
    required this.controllo,
    required this.affidata,
    required this.onAffida,
  });

  final MaestroPalette palette;
  final TextEditingController controllo;

  /// La domanda gia' affidata, o vuota.
  final String affidata;
  final VoidCallback onAffida;

  /// Quanto e' alto al massimo il riquadro delle proposte.
  static const double altezzaDelleProposte = 176;

  /// **IL SIMBOLO DEL PULSANTE CHE AFFIDA** (GC.11).
  static const IconData simboloDellInvio = Icons.keyboard_return_rounded;

  @override
  State<_LaDomanda> createState() => _LaDomandaState();
}

class _LaDomandaState extends State<_LaDomanda> {
  /// Nessun tema aperto all'inizio: il pannello resta basso. Le proposte si
  /// aprono toccando un tema e si chiudono scegliendone una (GC.11).
  TemaDellOracolo? _tema;

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final vuota = widget.controllo.text.trim().isEmpty;
    final affidata = widget.affidata.isNotEmpty &&
        widget.controllo.text.trim() == widget.affidata;
    final tema = _tema;
    return Container(
      key: const Key('oracolo_domanda'),
      padding: const EdgeInsets.all(SpacingTokens.sm),
      decoration: BoxDecoration(
        color: palette.deepest.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        border: Border.all(
            color: affidata
                ? palette.glow
                : palette.goldSoft.withValues(alpha: 0.4),
            width: affidata ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(affidata ? 'LA TUA DOMANDA È AFFIDATA' : 'LA TUA DOMANDA',
              key: const Key('oracolo_domanda_stato'),
              style: TypographyTokens.etichetta().copyWith(
                  color: affidata ? palette.glow : palette.goldSoft,
                  letterSpacing: 1.2)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('oracolo_campo_domanda'),
                  controller: widget.controllo,
                  minLines: 1,
                  maxLines: 2,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => widget.onAffida(),
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Scrivi la tua domanda agli angeli',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.xxs),
              Opacity(
                opacity: vuota || affidata ? 0.45 : 1,
                child: PulsanteTondoDipinto(
                  key: const Key('oracolo_affida'),
                  etichetta: 'Affida la domanda',
                  lato: 44,
                  onTap: vuota || affidata ? null : widget.onAffida,
                  figlio: Icon(_LaDomanda.simboloDellInvio,
                      key: const Key('oracolo_simbolo_dell_invio'),
                      color: palette.goldSoft),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xxs),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final t in TemaDellOracolo.values)
                  Padding(
                    padding: const EdgeInsets.only(right: SpacingTokens.xxs),
                    child: PulsanteDipinto(
                      key: Key('oracolo_tema_${t.name}'),
                      testo: t.nome,
                      altezza: 38,
                      onTap: () =>
                          setState(() => _tema = _tema == t ? null : t),
                    ),
                  ),
              ],
            ),
          ),
          if (tema != null) ...[
            const SizedBox(height: SpacingTokens.xs),
            // Una frase, non un'etichetta: nello stile della lettura breve,
            // perche' il maiuscoletto spaziato di un'etichetta su due righe
            // si legge come un muro di lettere (etichette_e_lettura).
            Text('${tema.nome}: dieci domande di Medora, scorri per leggerle',
                key: const Key('oracolo_tema_aperto'),
                style: TypographyTokens.didascalia()
                    .copyWith(color: palette.goldSoft)),
            ConstrainedBox(
              constraints: const BoxConstraints(
                  maxHeight: _LaDomanda.altezzaDelleProposte),
              child: ListView(
                key: const Key('oracolo_proposte'),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  for (var i = 0; i < tema.domande.length; i++)
                    GestureDetector(
                      key: Key('oracolo_proposta_$i'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        final d = tema.domande[i];
                        widget.controllo.text = d;
                        widget.controllo.selection =
                            TextSelection.collapsed(offset: d.length);
                        // GC.11: scelta la domanda, la tendina si chiude.
                        setState(() => _tema = null);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: SpacingTokens.xxs),
                        // Una proposta e' una frase da leggere: va a capo,
                        // non si tronca, e non e' in maiuscoletto.
                        child: Text(tema.domande[i],
                            style: TypographyTokens.corpo()
                                .copyWith(color: palette.goldSoft)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// **UNA CARTA O TRE, E LA PROFONDITA'** (GC.09, GC.17, GC.19), subito sotto
/// la domanda, con le stesse tendine della Stesa di Tarocchi
/// (`TendinaSelettore`): non un controllo nuovo.
///
/// La profondita': il fondatore, 22 ottobre 2026 alle 16:26, *"nel selettore
/// delle opzioni dell'oracolo degli angeli, vorrei l'opzione \"profondità\"
/// come nella stesa tarocchi. Ovviamente sarà esclusiva solo per gli utenti
/// premium a pagamento"*. Il cancello e' lo stesso della Stesa: la matrice
/// dei piani (`PlanCatalog.apre`), con la riga della Lunga dell'Oracolo
/// (`RigaDelPiano.oracoloLunga`, dall'Iniziato); per chi non ha il piano la
/// Lunga resta in vista col lucchetto e il suo tocco apre l'invito ai piani.
class _LeOpzioni extends StatelessWidget {
  const _LeOpzioni({
    required this.palette,
    required this.quante,
    required this.profondita,
    required this.piano,
    required this.onQuante,
    required this.onProfondita,
    required this.onLocked,
  });

  final MaestroPalette palette;
  final int quante;
  final AnswerDepth profondita;
  final Tier piano;
  final ValueChanged<int> onQuante;
  final ValueChanged<AnswerDepth> onProfondita;
  final VoidCallback onLocked;

  /// Le due stese dell'Oracolo.
  static const List<int> stese = [1, 3];

  static String nomeDellaStesa(int n) => n == 1 ? 'Una carta' : 'Tre carte';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, vincoli) {
      final larga = vincoli.maxWidth >= 300;
      final w = larga
          ? (vincoli.maxWidth - SpacingTokens.xs) / 2
          : vincoli.maxWidth;
      return Wrap(
        key: const Key('oracolo_opzioni'),
        spacing: SpacingTokens.xs,
        runSpacing: SpacingTokens.xs,
        children: [
          SizedBox(
            width: w,
            child: TendinaSelettore<int>(
              chiave: const Key('oracolo_quante_carte'),
              titolo: 'Quante carte',
              inRilievo: true,
              corrente: quante,
              voci: stese,
              palette: palette,
              etichetta: nomeDellaStesa,
              bloccata: (_) => false,
              onSelect: onQuante,
              onLocked: (_) {},
            ),
          ),
          SizedBox(
            width: w,
            child: TendinaSelettore<AnswerDepth>(
              chiave: const Key('oracolo_profondita'),
              titolo: 'Profondità',
              corrente: profondita,
              voci: AnswerDepth.shown,
              palette: palette,
              etichetta: (d) => d.label,
              bloccata: (d) =>
                  d.premium && !PlanCatalog.apre(RigaDelPiano.oracoloLunga, piano),
              perche: (d) =>
                  PlanCatalog.dalPiano(
                      (p) => PlanCatalog.apre(RigaDelPiano.oracoloLunga, p)) ??
                  'Coming soon',
              onSelect: onProfondita,
              onLocked: (_) => onLocked(),
            ),
          ),
        ],
      );
    });
  }
}

/// **IL MAZZO COPERTO**, ordine FY voce FY.15, 16 ottobre 2026. Il
/// fondatore: "Non si possono scegliere le carte".
///
/// Lo stesso gesto della Stesa (`StesaFan`): l'arco dei dorsi si sfoglia
/// col dito e un tocco sceglie la carta, qui coi 72 dorsi degli Angeli.
///
/// **SEMPRE IN VISTA, SPENTO FINCHE' LA DOMANDA NON E' AFFIDATA** (GC.09):
/// all'apertura il riquadro e' grigio, coi gesti Taglia, Mischia e Suono
/// della Stesa (`GestoDelMazzo`, lo stesso pezzo); si accende quando la
/// domanda e' affidata, e la riga sopra dice quale carta si sceglie.
class _IlMazzoCoperto extends StatelessWidget {
  const _IlMazzoCoperto({
    super.key,
    required this.palette,
    required this.attivo,
    required this.affidata,
    required this.quante,
    required this.scelti,
    required this.presi,
    required this.taglio,
    required this.mescolamento,
    required this.taglioIndice,
    required this.silenzio,
    required this.riduciMovimento,
    required this.onScegli,
    required this.onTaglia,
    required this.onMischia,
    required this.onSilenzio,
    this.rigaDelCambio,
  });

  final MaestroPalette palette;
  final bool attivo;
  final bool affidata;
  final int quante;
  final int scelti;
  final Set<int> presi;
  final double taglio;
  final double mescolamento;
  final int taglioIndice;
  final bool silenzio;
  final bool riduciMovimento;
  final String? rigaDelCambio;
  final void Function(int indice, Rect? riquadro) onScegli;
  final VoidCallback onTaglia;
  final VoidCallback onMischia;
  final VoidCallback onSilenzio;

  static const List<String> _ordinali = ['prima', 'seconda', 'terza'];

  /// La riga che guida la scelta, detta prima del gesto.
  static String guida(int quante, int scelti, {bool affidata = true}) {
    if (!affidata) {
      return 'Il mazzo si apre quando affidi la tua domanda.';
    }
    if (quante == 1) {
      return scelti >= 1
          ? 'La tua carta è sull\'altare. Quando vuoi, avvia la lettura.'
          : 'Scegli la tua carta, la carta del momento: sfoglia il mazzo '
              'col dito e tocca un dorso.';
    }
    const ruoli = RuoloDellAngelo.values;
    if (scelti >= ruoli.length) {
      return 'Le tre carte sono sull\'altare. Quando vuoi, avvia la lettura.';
    }
    final r = ruoli[scelti];
    return 'Scegli la ${_ordinali[scelti]} carta, '
        '${r.posizione.toLowerCase()}: la porta il tuo ${r.nome}. Sfoglia '
        'il mazzo col dito e tocca un dorso.';
  }

  @override
  Widget build(BuildContext context) {
    final completo = scelti >= quante;
    return Container(
      key: const Key('oracolo_mazzo_coperto'),
      padding: const EdgeInsets.all(SpacingTokens.sm),
      decoration: BoxDecoration(
        color: palette.deepest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        border: Border.all(color: palette.gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(guida(quante, scelti, affidata: affidata),
              key: const Key('oracolo_guida_della_scelta'),
              textAlign: TextAlign.center,
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textPrimary)),
          if (rigaDelCambio != null) ...[
            const SizedBox(height: SpacingTokens.xxs),
            Text(rigaDelCambio!,
                key: const Key('oracolo_riga_del_cambio'),
                textAlign: TextAlign.center,
                style: TypographyTokens.didascalia()
                    .copyWith(color: palette.goldSoft)),
          ],
          const SizedBox(height: SpacingTokens.xs),
          // **GRIGIO FINCHE' NON SI PUO' SCEGLIERE** (GC.09): il ventaglio e i
          // gesti restano in vista, velati, e non prendono tocchi.
          AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: affidata ? 1 : 0.4,
            child: IgnorePointer(
              ignoring: !affidata,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StesaFan(
                    palette: palette,
                    taken: presi,
                    onPick: (_) {},
                    onPickDa: (i, r) => onScegli(i, r),
                    // Scelte le carte, o a mazzo spento, il ventaglio non
                    // prende piu' tocchi.
                    scene: attivo && !completo
                        ? StesaScene.riposo
                        : StesaScene.completa,
                    ingresso: 1,
                    respiro: 0,
                    taglio: taglio,
                    mescolamento: mescolamento,
                    taglioIndice: taglioIndice,
                    reduceMotion: riduciMovimento,
                    carte: 72,
                    dorso: GeometriaDellAltare.dorso,
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: SpacingTokens.sm,
                    runSpacing: SpacingTokens.sm,
                    children: [
                      GestoDelMazzo(
                        key: const Key('oracolo_taglia'),
                        icona: Icons.content_cut_rounded,
                        label: 'Taglia',
                        palette: palette,
                        attivo: attivo,
                        onTap: onTaglia,
                      ),
                      GestoDelMazzo(
                        key: const Key('oracolo_mischia'),
                        icona: Icons.casino_rounded,
                        label: 'Mischia',
                        palette: palette,
                        attivo: attivo,
                        onTap: onMischia,
                      ),
                      GestoDelMazzo(
                        key: const Key('oracolo_silenzio'),
                        icona: silenzio
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        label: silenzio ? 'Muto' : 'Suono',
                        palette: palette,
                        attivo: affidata,
                        onTap: onSilenzio,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// **L'ANGELO DELL'ORA E IL MESSAGGIO DEL GIORNO** (FU.08), senza modello.
///
/// **LAPIDE, ordine GA voce GA.08, 20 ottobre 2026.** Qui accanto al nome
/// stava la carta dipinta dell'angelo dell'ora (`LaCartaDellAngelo`, piccola,
/// a sinistra): era una carta in vista all'apertura, fuori dal ventaglio. Il
/// fondatore: "L'oracolo degli angeli non mostra all'inizio, all'apertura,
/// nessuna Carta prima che l'utente le scelga". Restano il nome, i suoi venti
/// minuti e il messaggio del giorno.
class _LAngeloDellOra extends StatelessWidget {
  const _LAngeloDellOra({
    required this.palette,
    required this.adesso,
    required this.triade,
    required this.corpus,
  });

  final MaestroPalette palette;
  final DateTime adesso;
  final AngelTriad triade;
  final Map<String, List<String>> corpus;

  @override
  Widget build(BuildContext context) {
    final angelo = LOraDegliAngeli.dellOra(adesso);
    final delGiorno = LOraDegliAngeli.messaggioDelGiorno(
        triade: triade, giorno: adesso, corpus: corpus);
    return Container(
      key: const Key('oracolo_angelo_dell_ora'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        border: Border.all(color: palette.gold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('L\'angelo di quest\'ora',
              style: TypographyTokens.etichetta()
                  .copyWith(color: palette.goldSoft)),
          const SizedBox(height: SpacingTokens.xxs),
          Text(angelo.name,
              key: const Key('oracolo_nome_dell_ora'),
              style: TypographyTokens.titoloScheda()
                  .copyWith(color: ColorTokens.textPrimary)),
          Text(LOraDegliAngeli.momentoDelRito(angelo),
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textSecondary)),
          if (delGiorno != null) ...[
            const SizedBox(height: SpacingTokens.md),
            Text('Il messaggio di oggi',
                key: const Key('oracolo_messaggio_del_giorno'),
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft)),
            Text('dal tuo ${delGiorno.ruolo.nome}',
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textSecondary)),
            const SizedBox(height: SpacingTokens.xxs),
            ParagrafiDiLettura(
                testo: delGiorno.testo,
                stile: TypographyTokens.lettura()
                    .copyWith(color: ColorTokens.textPrimary)),
          ],
        ],
      ),
    );
  }
}

/// **IL RESPONSO NELLA FORMA NUOVA.** Ordine GA voci GA.03, GA.04 e GA.05,
/// 20 ottobre 2026. Il fondatore, 19 ottobre 2026: *"Per le risposte brevi
/// 2 paragrafi di cui il secondo messo in evidenza in un riquadro e questo
/// riquadro deve intitolarsi 'cosa fare adesso' [...] Per le risposte lunghe
/// aggiungi 2 paragrafi sempre con il primo in riquadro. Sotto sempre il
/// paragrafo in corsivo 'da dove viene'. Restano all'inizio i titoli, anche
/// per le singola carte"*; 20 ottobre 2026: *"Profondità lunga solo dal tier
/// 1 e solo per il responso principale e non per le singole carte"*.
///
/// Dall'alto: il responso principale (`IlResponsoInterpretato`, la forma in
/// un punto solo): il titolo, la risposta, "Cosa fare adesso" e, nella
/// Lunga, l'approfondimento e "Il salmo propiziatorio"; poi una bolla per
/// carta, ognuna col suo responso breve; in fondo il "Da dove viene", una
/// volta sola, per tutta la consultazione.
///
/// **LAPIDE, ordine FY voce FY.19, 16 ottobre 2026.** Qui il responso era
/// "una coppia sola": il titolo e un riquadro col legame scritto da Medora,
/// con dentro i due paragrafi della Lunga. Il fondatore aveva detto: "La
/// prima descrizione e' troppo lunga con risposta, riquadro e ancora
/// risposta e riquadro. Basta una coppia". La forma di GA.03 la supera: la
/// Breve resta una coppia (risposta e riquadro), la Lunga ne aggiunge una
/// seconda (approfondimento e salmo).
class _IlResponso extends StatelessWidget {
  const _IlResponso({
    required this.palette,
    required this.risposta,
    required this.carte,
    required this.corpus,
    required this.variante,
    required this.quando,
    required this.onCondividi,
    required this.onInvito,
    this.assaggio = false,
    this.riduciMovimento = false,
  });

  /// Riduci Movimento o grafica alleggerita: il colpo d'occhio e' fermo.
  final bool riduciMovimento;

  final MaestroPalette palette;
  final RispostaDellOracolo risposta;
  final List<CartaDellOracolo> carte;
  final Map<String, List<String>> corpus;
  final int variante;
  final DateTime quando;
  final bool assaggio;
  final Future<bool> Function() onCondividi;
  final Future<void> Function(RigaDelPiano riga, String cosa) onInvito;

  /// La riga dell'assaggio: dice che cosa si apre, e da dove.
  static const String rigaDellAssaggio =
      'Oggi ti risponde il tuo Angelo Custode. Con l\'Iniziato rispondono '
      'tutti e tre i tuoi angeli: Medora scrive la risposta alla tua domanda '
      'sulle tre carte e ti dà il salmo propiziatorio.';

  /// **LA BOLLA CHE NON RIPETE** (GA.05, "senza ripetere un secondo blocco
  /// per la stessa carta"): se il responso di una carta dice le stesse
  /// parole del responso principale, la bolla non le ripete.
  ///
  /// **LAPIDE, ordine GA voce GA.06, 20 ottobre 2026.** Qui la regola era
  /// "senza modello la bolla del Custode tace", perche' il responso
  /// principale era la carta del Custode copiata. Adesso il principale si
  /// compone dai doni dei tre angeli (`LaRispostaDaiDoni`) e la bolla del
  /// Custode porta il suo messaggio come le altre: la regola guarda le
  /// parole, non il ruolo.
  static bool ripeteIlPrincipale(
          RispostaDellOracolo r, ResponsoInterpretato? carta) =>
      carta != null && carta.risposta == r.responso.risposta;

  ResponsoInterpretato? _responsoDellaBolla(CartaDellOracolo carta) {
    final r = LaLetturaDellOracolo.responsoDellaCarta(corpus, carta, variante);
    return ripeteIlPrincipale(risposta, r) ? null : r;
  }

  @override
  Widget build(BuildContext context) {
    final scoperte = [
      for (var i = 0; i < carte.length; i++)
        if (!carte[i].coperta && !(assaggio && i > 0)) carte[i],
    ];
    final r = risposta.responso;
    final perIlDiario = ResponsoDaCustodire(
      arte: 'oracolo_angeli',
      titolo: r.titolo,
      testo: r.paragrafi.join('\n\n'),
      perIlMaestro: [
        for (final c in scoperte) '${c.ruolo.nome}: ${c.angelo.name}',
      ].join('\n'),
      dati: {
        'angeli':
            [for (final c in scoperte) c.angelo.number.toString()].join(','),
      },
    );
    final stile =
        TypographyTokens.lettura().copyWith(color: ColorTokens.textPrimary);
    // Il "Da dove viene" non sta sotto i paragrafi del responso principale:
    // chiude la consultazione, dopo le carte (GA.05).
    final principale = ResponsoInterpretato(
      arte: r.arte,
      titolo: r.titolo,
      risposta: r.risposta,
      cosaFare: r.cosaFare,
      approfondimento: r.approfondimento,
      rito: r.rito,
    );
    return Column(
      key: const Key('oracolo_responso'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // **COME NELLA STESA: PRIMA LE CARTE USCITE** (GC.15). Il fondatore:
        // *"come per la stesa di tarocchi, il responso all'inizio scrive le
        // carte uscite e poi i riquadri delle risposte"*. In cima il numero
        // di carte scelto (GC.17), poi le carte uscite, poi il colpo
        // d'occhio della scala di luce (GC.18), poi il titolo e i paragrafi.
        Text(carte.length == 1 ? 'STESA A UNA CARTA' : 'STESA A TRE CARTE',
            key: const Key('oracolo_quante_nel_responso'),
            textAlign: TextAlign.center,
            style: TypographyTokens.etichetta()
                .copyWith(color: palette.goldSoft, letterSpacing: 1.6)),
        const SizedBox(height: SpacingTokens.xs),
        _LeCarteUscite(carte: carte, assaggio: assaggio, palette: palette),
        const SizedBox(height: SpacingTokens.md),
        LaScalaDelResponso(
          carte: carte,
          palette: palette,
          chiuse: assaggio
              ? const {RuoloDellAngelo.cuore, RuoloDellAngelo.intelletto}
              : const {},
          ferma: riduciMovimento,
        ),
        const SizedBox(height: SpacingTokens.md),
        KeyedSubtree(
          key: const Key('oracolo_responso_principale'),
          child: IlResponsoInterpretato(
            responso: principale,
            chiave: 'oracolo_principale',
            palette: palette,
            allineamentoDelTitolo: TextAlign.center,
            stileDelTitolo: TypographyTokens.titoloSezione()
                .copyWith(color: palette.goldSoft, height: 1.25),
            // Ogni paragrafo della forma e' UN paragrafo (GA.03): non passa
            // da `ParagrafiDiLettura`, che lo spezzerebbe in due blocchi.
            stile: stile,
          ),
        ),
        if (assaggio) ...[
          const SizedBox(height: SpacingTokens.sm),
          Text(rigaDellAssaggio,
              key: const Key('oracolo_riga_dell_assaggio'),
              style: TypographyTokens.didascalia().copyWith(
                  color: ColorTokens.textSecondary,
                  fontStyle: FontStyle.italic)),
        ] else if (!risposta.dalModello) ...[
          const SizedBox(height: SpacingTokens.sm),
          Text(
            'Medora oggi risponde dai doni dei tre angeli usciti: la '
            'risposta scritta per te sulle tre carte arriva quando la rete '
            'torna.',
            key: const Key('oracolo_solo_corpus'),
            style: TypographyTokens.didascalia().copyWith(
                color: ColorTokens.textSecondary, fontStyle: FontStyle.italic),
          ),
        ],
        const SizedBox(height: SpacingTokens.lg),
        for (var i = 0; i < carte.length; i++) ...[
          if (assaggio && i > 0)
            _IlLucchetto(
              chiave: 'oracolo_lucchetto_${carte[i].ruolo.name}',
              palette: palette,
              testo: 'La carta del tuo ${carte[i].ruolo.nome}: '
                  '${carte[i].ruolo.posizione.toLowerCase()}',
              onTap: () => onInvito(
                  RigaDelPiano.oracoloTreCarte, 'La carta dei tre angeli'),
            )
          else
            _LaBollaDellaCarta(
              palette: palette,
              carta: carte[i],
              messaggio: LaLetturaDellOracolo.messaggioDellaCarta(
                  corpus, carte[i], variante),
              // **NELLA STESA A UNA CARTA IL RESPONSO E' QUELLO DELLA CARTA**
              // (GA.05, GC.05, GC.15): la bolla resta, con chi e' l'angelo,
              // il suo coro, il rito e il dono, ma il suo messaggio non si
              // ripete sotto il responso principale.
              responso: carte.length == 1 ? null : _responsoDellaBolla(carte[i]),
              parolaChiave: LaRispostaDaiDoni.dono(corpus, carte[i].angelo),
              rito: corpus[LOraDegliAngeli.chiaveDelRito(carte[i].angelo)],
              variante: variante,
            ),
          const SizedBox(height: SpacingTokens.md),
        ],
        if (r.daDoveViene case final fonte?)
          IlDaDoveViene(testo: fonte, chiave: 'oracolo_da_dove_viene'),
        const SizedBox(height: SpacingTokens.md),
        AzioniDelResponso(
          palette: palette,
          maestro: Maestro.medora,
          dorato: true,
          responso: perIlDiario,
          quando: quando,
          condividi: onCondividi,
          aperturaDellaChat: ChatOpeners.oracoloAngeli(carte.first.angelo.name,
              carte.first.ruolo.posizione.toLowerCase(), r.titolo),
        ),
      ],
    );
  }
}

/// **LE CARTE USCITE**, in cima al responso come nella Stesa (GC.15): la
/// parola del posto e il nome dell'angelo, una riga per carta. La carta
/// chiusa dall'assaggio e la carta coperta lo dicono.
class _LeCarteUscite extends StatelessWidget {
  const _LeCarteUscite({
    required this.carte,
    required this.assaggio,
    required this.palette,
  });

  final List<CartaDellOracolo> carte;
  final bool assaggio;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('oracolo_carte_uscite'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < carte.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: SpacingTokens.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(LaScalaDelResponso.parolaDi(carte[i]).toUpperCase(),
                    style: TypographyTokens.etichetta().copyWith(
                        color: palette.goldSoft.withValues(alpha: 0.8),
                        letterSpacing: 1.2)),
                Text(
                    carte[i].coperta
                        ? 'Carta coperta'
                        : (assaggio && i > 0
                            ? 'Col tuo piano resta chiusa'
                            : carte[i].angelo.name),
                    key: Key('oracolo_uscita_$i'),
                    style: TypographyTokens.titoloScheda().copyWith(
                        color: ColorTokens.textPrimary, height: 1.2)),
              ],
            ),
          ),
      ],
    );
  }
}

/// **IL LUCCHETTO E L'INVITO** (FU.10): la voce che il piano chiude resta
/// visibile, col lucchetto, e il tocco dice da quale piano si apre.
class _IlLucchetto extends StatelessWidget {
  const _IlLucchetto({
    required this.chiave,
    required this.palette,
    required this.testo,
    required this.onTap,
  });

  final String chiave;
  final MaestroPalette palette;
  final String testo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: palette.primary.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
      child: InkWell(
        key: Key(chiave),
        // Nessun click di sistema: il suono del Cerchio e' una scelta.
        enableFeedback: false,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: Row(
            children: [
              Icon(Icons.lock_rounded, color: palette.goldSoft),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(testo,
                    style: TypographyTokens.corpo()
                        .copyWith(color: ColorTokens.textPrimary)),
              ),
              Icon(Icons.chevron_right_rounded, color: palette.goldSoft),
            ],
          ),
        ),
      ),
    );
  }
}

/// **LA CARTA IN DONO A UN AMICO DEL CERCHIO** (FU.09): il prezzo si legge
/// sul pulsante, prima del gesto, dal listino; poi la scelta dell'amico, la
/// conferma unica della spesa (ordine FD voce 01) e la strada dei doni del
/// Cerchio (`IlCerchioSociale.mandaUnaCartaDegliAngeli`). Viaggia il numero
/// della carta e nient'altro.
class _IlDonoDellaCarta extends StatelessWidget {
  const _IlDonoDellaCarta({required this.palette, required this.angelo});

  final MaestroPalette palette;
  final Angel angelo;

  static VoceDelListino get voce => ListinoDegliEos.cartaDegliAngeliDaDonare;

  /// L'etichetta col prezzo, detta prima del gesto.
  static String get etichetta =>
      'Mandala in dono, ${ListinoDegliEos.prezzo(voce.costo)}';

  Future<void> _dona(BuildContext context) async {
    IlCerchioSociale? sociale;
    try {
      sociale = context.read<IlCerchioSociale>();
    } catch (senzaCerchio) {
      sociale = null;
    }
    final messaggero = ScaffoldMessenger.of(context);
    // Il borsellino serve alla conferma della spesa: senza, il dono non parte
    // e la riga lo dice, mai un errore muto.
    try {
      context.read<QuestionAllowance>();
    } catch (senzaBorsellino) {
      messaggero.showSnackBar(
          SnackBar(content: Text(EsitoDelGesto.silenzio.rigaPerLaPersona)));
      return;
    }
    final amici = sociale?.cerchio.amici ?? const <PersonaDelCerchio>[];
    if (sociale == null || amici.isEmpty) {
      messaggero.showSnackBar(const SnackBar(
          key: Key('oracolo_dono_senza_amici'),
          content: Text('Il dono va a un amico del Cerchio: quando ne avrai '
              'uno, la carta potrà raggiungerlo.')));
      return;
    }
    final amico = await foglioDelCerchio<PersonaDelCerchio>(
      context: context,
      backgroundColor: palette.deepest,
      builder: (c) => SafeArea(
        child: ListView(
          key: const Key('oracolo_dono_gli_amici'),
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(SpacingTokens.md),
              child: Text('A chi mandi ${angelo.name}?',
                  style: TypographyTokens.titoloScheda()
                      .copyWith(color: palette.goldSoft)),
            ),
            for (final a in amici)
              ListTile(
                key: Key('oracolo_dono_a_${a.uid}'),
                title: Text(a.nome,
                    style: TypographyTokens.corpo()
                        .copyWith(color: ColorTokens.textPrimary)),
                onTap: () => Navigator.of(c).pop(a),
              ),
          ],
        ),
      ),
    );
    if (amico == null || !context.mounted) return;
    final consenso =
        await LaConfermaDellaSpesa.degliEos(context, costo: voce.costo);
    if (consenso == null || !context.mounted) return;
    final esito = await sociale
        .mandaUnaCartaDegliAngeli(amico.uid, angelo.number, consenso: consenso);
    if (!context.mounted) return;
    final manca = esito.dati['manca'];
    if (!esito.ok && manca is num) {
      messaggero.showSnackBar(SnackBar(
          content: Text('Mancano ${ListinoDegliEos.prezzo(manca.toInt())} '
              'per mandare ${angelo.name}.')));
      await PortafoglioDelCerchio.apri(context);
      return;
    }
    messaggero.showSnackBar(SnackBar(
        key: const Key('oracolo_dono_esito'),
        content: Text(esito.ok
            ? 'La carta di ${angelo.name} è arrivata a ${amico.nome}.'
            : esito.rigaPerLaPersona)));
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        key: Key('oracolo_dono_${angelo.number}'),
        style: TextButton.styleFrom(foregroundColor: palette.goldSoft),
        onPressed: () => _dona(context),
        icon: const Icon(Icons.card_giftcard_rounded),
        label: Text(etichetta),
      ),
    );
  }
}

/// **LA BOLLA DI UNA CARTA**: il medaglione del ruolo col nome dell'angelo
/// della persona che la porta, la carta, il Parlane con Medora (come nella
/// Stesa), il dono a un amico (FU.09) e, chiuso finche' non lo apri, il rito
/// con Caligo (FU.07).
///
/// **CHI E' L'ANGELO E CHE COSA PORTA**, ordine FY voce FY.18, 16 ottobre
/// 2026. Il fondatore: "Le singole carte non hanno descrizione". Sotto la
/// carta, in poche righe: il numero, il coro e l'arcangelo che lo regge
/// (`AngelCatalog`), e che cosa porta secondo la tradizione, dal Corpus
/// degli Angeli (`AngelLore.tradition`, `docs/corpus/angeli.md`) col segno
/// della sua fonte, Lenain 1823, come nella scheda dell'angelo. Poi il suo
/// messaggio per questa domanda, dal corpus di Medora: e' cio' che prima
/// stava nei paragrafi della risposta (FY.19), e non si ripete se e' gia'
/// nel riquadro.
///
/// **LA CARTA SINGOLA NELLA FORMA NUOVA**, ordine GA voce GA.05, 20 ottobre
/// 2026: il messaggio diventa un `IlResponsoInterpretato` breve, il
/// messaggio e sotto il riquadro "Cosa fare adesso" col consiglio della
/// carta. Il titolo e' il nome dell'angelo, gia' nella testata della bolla
/// (`mostraIlTitolo: false`); niente "Da dove viene", che chiude la
/// consultazione una volta sola. Quando il responso principale dice le
/// stesse parole di questa carta la bolla non le ripete ([responso] nullo).
class _LaBollaDellaCarta extends StatelessWidget {
  const _LaBollaDellaCarta({
    required this.palette,
    required this.carta,
    required this.messaggio,
    required this.responso,
    required this.rito,
    required this.variante,
    this.parolaChiave = '',
  });

  /// **LA PAROLA CHIAVE DELL'ANGELO** (GC.18): il suo dono, dal corpus dei
  /// doni (`LaRispostaDaiDoni.dono`), accanto al segno del coro.
  final String parolaChiave;

  final MaestroPalette palette;
  final CartaDellOracolo carta;

  /// Il messaggio della carta per questa consultazione, dal corpus.
  final String messaggio;

  /// Il responso breve della carta; nullo se il responso principale e' gia'
  /// questa carta, o per la carta coperta.
  final ResponsoInterpretato? responso;
  final List<String>? rito;
  final int variante;

  String get _chiLaPorta => carta.delMomento
      // GC.17: la carta del momento non ha ruolo e non la porta nessuno.
      ? 'L\'hai scelta tu dal mazzo dei 72'
      : carta.portatore == null
          ? 'La porta il tuo ${carta.ruolo.nome}, che si rivela con l\'ora di '
              'nascita'
          : 'La porta il tuo ${carta.ruolo.nome}, ${carta.portatore!.name}';

  /// **IL SEGNO DEL CORO** (GC.18): uno dei nove segni dipinti dal fondatore
  /// (`assets/img/simboli/`, ordine GC). Il catalogo chiama "Potenze" il
  /// coro che il file chiama "potesta", e scrive "Virtu'" con l'apostrofo.
  static String segnoDelCoro(Angel a) {
    final nome = switch (a.choir.name) {
      'Potenze' => 'potesta',
      "Virtu'" => 'virtu',
      final altro => altro.toLowerCase(),
    };
    return 'assets/img/simboli/sig_coro_${nome}_v1.webp';
  }

  /// **CHI E'**, in una riga: il numero, il nome, il coro e chi lo regge.
  /// Il nome del coro col suo articolo ("degli Angeli", "dei Troni") e con
  /// l'accento vero ("Virtù": nel catalogo e' scritto con l'apostrofo).
  static String chiE(Angel a) {
    final coro = a.choir.name.replaceAll("u'", 'ù');
    final articolo = RegExp('^[AEIOU]').hasMatch(coro) ? 'degli' : 'dei';
    return '${a.number}. ${a.name}, del coro $articolo $coro, retto da '
        '${a.choir.archangel}.';
  }

  /// **CHE COSA PORTA**, con la sua fonte: il dominio secondo la tradizione
  /// (`AngelLore.tradition`, Lenain 1823) quando il Corpus lo regge;
  /// altrimenti la chiave di lettura di Medora (`AngelLore.reading`), col
  /// suo segno, mai spacciata per tradizione. Il dominio del coro non si usa:
  /// porta parole che la politica dell'Oracolo vieta.
  static ({String testo, Provenienza da, String fonte})? cosaPorta(Angel a) {
    final l = a.lore;
    if (l == null) return null;
    if (l.tradition.trim().isNotEmpty && !l.confidenzaBassa) {
      return (
        testo: l.tradition,
        da: Provenienza.tradizione,
        fonte: AngelLore.fonteDelDocumentato,
      );
    }
    if (l.reading.trim().isNotEmpty) {
      return (
        testo: l.reading,
        da: Provenienza.cerchio,
        fonte: AngelLore.voceDelMaestro,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const lato = SpacingTokens.xxl + SpacingTokens.lg;
    return Container(
      key: Key('oracolo_bolla_${carta.ruolo.name}'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  // **IL SIMBOLO DELLA CARTA** (GC.15): il medaglione del suo
                  // ruolo, quello sopra la carta nella cattura 07 del
                  // fondatore. La carta del momento non ha ruolo (GC.17): il
                  // suo simbolo e' quello dell'Oracolo che l'app ha gia', il
                  // segno della funzione nel catalogo delle arti
                  // (`ArtCatalog`, voce `angels_oracle`), in un cerchio d'oro.
                  if (carta.delMomento)
                    Container(
                      key: const Key('oracolo_simbolo_del_momento'),
                      width: SpacingTokens.xxl,
                      height: SpacingTokens.xxl,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: palette.deepest,
                        border: Border.all(color: palette.gold, width: 2),
                      ),
                      child: Icon(Icons.auto_stories_rounded,
                          color: palette.goldSoft),
                    )
                  else
                    ClipOval(
                      child: Image.asset(carta.ruolo.medaglione,
                          width: SpacingTokens.xxl,
                          height: SpacingTokens.xxl,
                          fit: BoxFit.contain),
                    ),
                  const SizedBox(height: SpacingTokens.xs),
                  SizedBox(
                    width: lato,
                    height: lato * 1.5,
                    child: carta.coperta
                        ? Image.asset(GeometriaDellAltare.dorso,
                            fit: BoxFit.fill)
                        : LaCartaDellAngelo(
                            angelo: carta.angelo, palette: palette),
                  ),
                ],
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        carta.delMomento
                            ? 'LA CARTA DEL MOMENTO'
                            : carta.ruolo.posizione.toUpperCase(),
                        style: TypographyTokens.etichetta()
                            .copyWith(color: palette.goldSoft)),
                    const SizedBox(height: SpacingTokens.xxs),
                    Text(carta.coperta ? 'Carta coperta' : carta.angelo.name,
                        style: TypographyTokens.titoloScheda()
                            .copyWith(color: ColorTokens.textPrimary)),
                    const SizedBox(height: SpacingTokens.xxs),
                    Text(_chiLaPorta,
                        style: TypographyTokens.didascalia()
                            .copyWith(color: ColorTokens.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          if (!carta.coperta) ...[
            const SizedBox(height: SpacingTokens.sm),
            // **IL CORO COME PICCOLO SEGNO, CON UNA PAROLA CHIAVE** (GC.18):
            // il segno dipinto del coro e il dono dell'angelo. Senza il file,
            // un cerchio nel colore dell'oro.
            Row(
              key: Key('oracolo_coro_${carta.ruolo.name}'),
              children: [
                SizedBox(
                  width: 34,
                  height: 34,
                  child: Image.asset(segnoDelCoro(carta.angelo),
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (_, __, ___) => DecoratedBox(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: palette.gold.withValues(alpha: 0.6)))),
                ),
                const SizedBox(width: SpacingTokens.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'CORO DEI ${carta.angelo.choir.name.replaceAll("u'", 'ù').toUpperCase()}',
                          style: TypographyTokens.etichetta().copyWith(
                              color: palette.goldSoft, letterSpacing: 1.1)),
                      if (parolaChiave.trim().isNotEmpty)
                        Text(
                            '${parolaChiave.trim()[0].toUpperCase()}'
                            '${parolaChiave.trim().substring(1)}',
                            key: Key('oracolo_parola_chiave_'
                                '${carta.ruolo.name}'),
                            style: TypographyTokens.titoloScheda().copyWith(
                                color: ColorTokens.textPrimary, height: 1.2)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.sm),
            Column(
              key: Key('oracolo_chi_e_${carta.ruolo.name}'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chi è',
                    style: TypographyTokens.etichetta()
                        .copyWith(color: palette.goldSoft)),
                const SizedBox(height: SpacingTokens.xxs),
                Text(chiE(carta.angelo),
                    style: TypographyTokens.didascalia()
                        .copyWith(color: ColorTokens.textPrimary)),
                if (cosaPorta(carta.angelo) case final porta?) ...[
                  const SizedBox(height: SpacingTokens.xs),
                  SegnoDellaProvenienza(
                      provenienza: porta.da,
                      palette: palette,
                      dettaglio: porta.fonte),
                  const SizedBox(height: SpacingTokens.xxs),
                  Text(porta.testo,
                      key: Key('oracolo_cosa_porta_${carta.ruolo.name}'),
                      style: TypographyTokens.didascalia().copyWith(
                          color: ColorTokens.textPrimary, height: 1.45)),
                ],
              ],
            ),
          ],
          if (carta.coperta) ...[
            const SizedBox(height: SpacingTokens.sm),
            Text('Perché resta coperta',
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft)),
            const SizedBox(height: SpacingTokens.xxs),
            ParagrafiDiLettura(
                key: Key('oracolo_messaggio_${carta.ruolo.name}'),
                testo: messaggio,
                stile: TypographyTokens.lettura()
                    .copyWith(color: ColorTokens.textPrimary)),
          ] else if (responso case final r?) ...[
            const SizedBox(height: SpacingTokens.sm),
            // **IL SUO MESSAGGIO PER TE: UN PARAGRAFO, CHIUSO ALL'APERTURA**
            // (GC.15, GC.18): il titolo "Il suo messaggio per te" in vista e
            // il paragrafo, intero, che si apre al tocco (strato 3 delle
            // Linee Guida V14). Niente riquadro "Cosa fare adesso" nella
            // carta singola (GC.05). Il nome dell'angelo e' gia' il titolo,
            // nella testata.
            KeyedSubtree(
              key: Key('oracolo_messaggio_${carta.ruolo.name}'),
              child: LaSingolaCheSiApre(
                responso: r,
                parolaChiave: '',
                etichetta: 'Il suo messaggio per te',
                chiave: 'oracolo_carta_singola_${carta.ruolo.name}',
                palette: palette,
                mostraIlTitolo: false,
              ),
            ),
          ],
          if (carta.coperta) ...[
            const SizedBox(height: SpacingTokens.sm),
            Center(
              child: PulsanteDipinto(
                key: const Key('oracolo_aggiungi_l_ora'),
                testo: 'Aggiungi l\'ora di nascita',
                onTap: () =>
                    Navigator.of(context).push(DatiDiNascitaScreen.route()),
              ),
            ),
          ] else ...[
            const SizedBox(height: SpacingTokens.sm),
            ParlaneConMaestroCompatto(
              keyDelPulsante: Key('oracolo_parlane_${carta.ruolo.name}'),
              palette: palette,
              maestro: Maestro.medora,
              frase: messaggio,
              aperturaDellaChat: ChatOpeners.oracoloAngeli(carta.angelo.name,
                  carta.ruolo.posizione.toLowerCase(), messaggio),
            ),
            _IlDonoDellaCarta(palette: palette, angelo: carta.angelo),
            const SizedBox(height: SpacingTokens.xs),
            _IlRitoConCaligo(
              angelo: carta.angelo,
              rito: rito,
              variante: variante,
              chiave: carta.ruolo.name,
            ),
          ],
        ],
      ),
    );
  }
}

/// **IL RITO CON CALIGO**, chiuso finche' la persona non lo apre (FU.07): il
/// salmo con la numerazione e l'edizione dichiarate, il momento dei venti
/// minuti dell'angelo in ora locale, e un testo breve nella voce di Caligo.
/// Nessun sigillo dell'angelo: la sua fonte non e' verificata.
class _IlRitoConCaligo extends StatefulWidget {
  const _IlRitoConCaligo({
    required this.angelo,
    required this.rito,
    required this.variante,
    required this.chiave,
  });

  final Angel angelo;
  final List<String>? rito;
  final int variante;
  final String chiave;

  @override
  State<_IlRitoConCaligo> createState() => _IlRitoConCaligoState();
}

class _IlRitoConCaligoState extends State<_IlRitoConCaligo> {
  bool _aperto = false;

  @override
  Widget build(BuildContext context) {
    final caligo = MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo));
    final rito = widget.rito;
    final testo = rito == null || rito.isEmpty
        ? null
        : rito[widget.variante % rito.length];
    final salmo = widget.angelo.lore?.psalm;
    return Container(
      decoration: BoxDecoration(
        color: caligo.deepest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
        border: Border.all(color: caligo.gold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextButton.icon(
            key: Key('oracolo_rito_${widget.chiave}'),
            onPressed: () => setState(() => _aperto = !_aperto),
            style: TextButton.styleFrom(
                foregroundColor: caligo.goldSoft,
                alignment: Alignment.centerLeft),
            icon: Icon(_aperto
                ? Icons.expand_less_rounded
                : Icons.expand_more_rounded),
            label: const Text('Il rito con Caligo'),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: !_aperto
                ? const SizedBox(width: double.infinity)
                : Padding(
                    key: Key('oracolo_rito_aperto_${widget.chiave}'),
                    padding: const EdgeInsets.fromLTRB(SpacingTokens.md, 0,
                        SpacingTokens.md, SpacingTokens.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Il momento: '
                            '${LOraDegliAngeli.momentoDelRito(widget.angelo)}',
                            style: TypographyTokens.etichetta()
                                .copyWith(color: caligo.goldSoft)),
                        if (salmo != null) ...[
                          const SizedBox(height: SpacingTokens.xs),
                          Text(salmo,
                              style: TypographyTokens.didascalia().copyWith(
                                  color: ColorTokens.textSecondary,
                                  fontStyle: FontStyle.italic)),
                        ],
                        if (testo != null) ...[
                          const SizedBox(height: SpacingTokens.xs),
                          ParagrafiDiLettura(
                              testo: testo,
                              stile: TypographyTokens.lettura()
                                  .copyWith(color: ColorTokens.textPrimary)),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

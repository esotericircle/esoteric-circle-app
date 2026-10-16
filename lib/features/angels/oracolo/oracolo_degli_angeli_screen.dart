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
import '../../../core/oracolo_angeli/i_ruoli_e_l_estrazione.dart';
import '../../../core/oracolo_angeli/il_corpus_dell_oracolo.g.dart';
import '../../../core/oracolo_angeli/l_ora_degli_angeli.dart';
import '../../../core/oracolo_angeli/la_lettura_dell_oracolo.dart';
import '../../../core/oracolo_angeli/le_domande_dell_oracolo.dart';
import '../../../design_system/transizioni/velo_del_cerchio.dart';
import '../../../design_system/components/borsellino.dart';
import '../../../design_system/components/la_conferma_della_spesa.dart';
import '../../../design_system/components/riquadro_in_evidenza.dart';
import '../../../design_system/components/segno_della_provenienza.dart';
import '../../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../../design_system/components/titolo_del_responso.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../../design_system/typography/paragrafi_di_lettura.dart';
import '../../account/dati_di_nascita_screen.dart';
import '../../maestri/chat/chat_openers.dart';
import '../../maestri/rotta_arte.dart';
import '../../maestri/widgets/foglio_delle_fonti.dart';
import '../../pricing/upgrade_invite.dart';
import '../../respiro_della_luna/i_comandi_dipinti.dart';
import '../../ricordi/azioni_del_responso.dart';
import '../../scene/la_scena_in_video.dart';
import '../../sigilli/regia_del_cammino.dart';
import '../../tarot/stesa_choreography.dart';
import '../../tarot/stesa_fan.dart';
import '../../tarot/tarot_card_art.dart';
import 'la_geometria_dell_altare.dart';
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
  static const double veloDellaBarra = 0.6;

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
/// **LA SCELTA** (FY.15): affidata la domanda, la persona sceglie le tre
/// carte dal mazzo coperto; la lettura parte solo dal pulsante (FY.16).
enum _Fase { domanda, scelta, saleLaDomanda, siGirano, risposta }

class _OracoloDegliAngeliScreenState extends State<OracoloDegliAngeliScreen>
    with TickerProviderStateMixin {
  late final RegiaDellaScena _regia;
  late final AnimationController _lettere = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2400));
  late final AnimationController _giro = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500));
  final _domanda = TextEditingController();
  final _scorrimento = ScrollController();
  final _inizioDellaRisposta = GlobalKey();
  late final Random _caso = widget.caso ?? Random();
  late final DateTime _quando = DateTime.now();

  _Fase _fase = _Fase.domanda;
  String _affidata = '';
  List<CartaDellOracolo> _carte = const [];
  RispostaDellOracolo? _risposta;
  int _consultazioni = 0;
  Timer? _orologio;
  bool _avviata = false;

  /// **IL MAZZO COPERTO** della consultazione (FY.15): i 72 in ordine
  /// mescolato, e i dorsi scelti dalla persona, uno per posizione.
  List<int> _mazzo = const [];
  final List<int> _scelti = [];
  final _ilMazzo = GlobalKey();

  /// L'ASSAGGIO DEL VIANDANTE (FU.10): la consultazione a video scopre solo
  /// la carta del Custode.
  bool _assaggio = false;

  /// La card da condividere, dipinta fuori schermo solo mentre si condivide.
  final _cardKey = GlobalKey();
  bool _renderCard = false;

  Map<String, List<String>> get _corpus => widget.corpus ?? corpusDellOracolo;

  DateTime _ora() => widget.adesso?.call() ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _regia = RegiaDellaScena(widget.fabbricaDellaScena ??
        () => LettoreDiScena.vero(GeometriaDellAltare.filmato))
      ..addListener(_ridisegna);
    _domanda.addListener(_ridisegna);
    _programmaLOra();
  }

  void _ridisegna() {
    if (mounted) setState(() {});
  }

  /// L'angelo dell'ora cambia da se' ogni venti minuti (FU.08): la schermata
  /// si ridisegna all'istante del cambio.
  void _programmaLOra() {
    _orologio?.cancel();
    final adesso = _ora();
    final attesa = LOraDegliAngeli.prossimoCambio(adesso).difference(adesso);
    _orologio = Timer(attesa + const Duration(seconds: 1), () {
      _ridisegna();
      _programmaLOra();
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
    _orologio?.cancel();
    _regia
      ..removeListener(_ridisegna)
      ..dispose();
    _lettere.dispose();
    _giro.dispose();
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

  /// **AFFIDARE LA DOMANDA** (FY.15): la domanda resta affidata e la persona
  /// passa a scegliere le sue tre carte dal mazzo coperto. Le consultazioni
  /// del giorno si contano qui, prima della scelta, cosi' nessuno sceglie le
  /// carte per poi trovare la porta chiusa (FU.10).
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
    setState(() {
      _affidata = domanda;
      _mazzo = EstrazioneDellOracolo.mescola(_caso);
      _scelti.clear();
      _carte = const [];
      _risposta = null;
      _fase = _Fase.scelta;
    });
    _scorriAlMazzo();
  }

  /// **LE CONSULTAZIONI DEL GIORNO** (FU.10): finite, l'invito con le due
  /// strade, una consultazione in piu' a Eos o salire di piano. Finche' il
  /// server non porta il budget nel listino non si conta niente
  /// (`QuestionAllowance.contaGliOracoli`).
  Future<bool> _lePorteSonoAperte() async {
    final tier = _tier;
    final borsa = _forse<QuestionAllowance>();
    if (borsa == null || borsa.puoiConsultareGliAngeli(tier)) return true;
    await _leConsultazioniDiOggiSonoFinite();
    return mounted && borsa.puoiConsultareGliAngeli(tier);
  }

  /// **UN DORSO SCELTO** (FY.15): il primo e' la carta del Custode, il
  /// secondo del Cuore, il terzo dell'Intelletto. Il dorso scelto si posa
  /// sull'altare, nella sua posizione.
  void _scegli(int indice) {
    if (_fase != _Fase.scelta ||
        _scelti.length >= RuoloDellAngelo.values.length ||
        _scelti.contains(indice)) {
      return;
    }
    setState(() => _scelti.add(indice));
  }

  /// **AVVIARE LA LETTURA** (FY.16), solo dal pulsante e solo con le tre
  /// carte scelte: la domanda sale lungo la scala, la lettura parte insieme
  /// alle lettere e i dorsi si girano.
  Future<void> _avviaLaLettura() async {
    if (_fase != _Fase.scelta ||
        _scelti.length < RuoloDellAngelo.values.length) {
      return;
    }
    if (!await _lePorteSonoAperte()) return;
    final tier = _tier;
    final domanda = _affidata;
    final carte = EstrazioneDellOracolo.dalleScelte(
        _triade, [for (final i in _scelti) _mazzo[i]]);
    final variante = _consultazioni;
    // **L'ASSAGGIO DEL VIANDANTE** (FU.10): la carta del Custode dal corpus,
    // senza modello; Cuore e Intelletto restano col lucchetto e l'invito.
    final assaggio = !PlanCatalog.apre(RigaDelPiano.oracoloTreCarte, tier);
    _forse<QuestionAllowance>()?.registraOracolo(tier);
    setState(() {
      _carte = carte;
      _risposta = null;
      _fase = _Fase.saleLaDomanda;
      _consultazioni++;
      _assaggio = assaggio;
    });
    _giro.value = 0;
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
            variante: variante))
        : LaLetturaDellOracolo.leggi(
            domanda: domanda,
            carte: carte,
            corpus: _corpus,
            variante: variante,
            // LA LUNGA E' DELL'ADEPTO (FU.06 e FU.10), letta dalla matrice.
            profonda: PlanCatalog.apre(RigaDelPiano.oracoloLunga, tier),
            chiamata: widget.chiamata,
          );
    await _lettere.forward(from: 0);
    if (!mounted) return;
    setState(() => _fase = _Fase.siGirano);
    await _giro.forward(from: 0);
    final risposta = await lettura;
    if (!mounted) return;
    setState(() {
      _risposta = risposta;
      _fase = _Fase.risposta;
    });
    unawaited(RegiaDelCammino.dopoUnGesto(context, 'oracolo_angeli'));
    _scorriAllaRisposta();
  }

  /// **UNA NUOVA CONSULTAZIONE** nella stessa apertura: il video non riparte,
  /// le carte tornano dorsi in dissolvenza e la persona affida la domanda
  /// nuova (FU.02).
  void _nuovaDomanda() {
    _giro.value = 0;
    _lettere.value = 0;
    _domanda.clear();
    setState(() {
      _fase = _Fase.domanda;
      _risposta = null;
      _carte = const [];
      _mazzo = const [];
      _scelti.clear();
      _assaggio = false;
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
  /// l'altare, dove si posano i dorsi scelti.
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

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    // IL TOCCO CHE SALTA IL VIDEO, ordine FU voce FU.15, punto unico.
    return IlToccoCheSalta(
      inCorso: _regia.inCorso,
      onSalta: _regia.salta,
      child: Scaffold(
        backgroundColor: palette.deepest,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          key: const Key('oracolo_barra'),
          // **SEMPRE SEMITRASPARENTE** (FY.20): un velo solo in ogni stato,
          // anche scorrendo. Il colore e' esplicito, cosi' lo stato "sotto
          // la barra" di Material 3 non lo cambia, e nessuna elevazione ne'
          // tinta di superficie lo riempie.
          backgroundColor: palette.deepest
              .withValues(alpha: OracoloDegliAngeliScreen.veloDellaBarra),
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
        body: Stack(
          children: [
            Positioned.fill(child: _ilCorpo(palette)),
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
    );
  }

  Widget _ilCorpo(MaestroPalette palette) {
    return ListView(
      controller: _scorrimento,
      padding: EdgeInsets.zero,
      children: [
        LayoutBuilder(
          builder: (context, vincoli) => _laScena(vincoli.maxWidth, palette),
        ),
        // **SOPRA IL VIDEO SOLO IL VIDEO**, ordine FX voce FXA.08:
        // l'angelo dell'ora stava sotto la scena anche a video in corso.
        // Adesso tutto cio' che sta sotto la scena aspetta la scena ferma
        // e compare in dissolvenza.
        IlRestoDopoLaScena(
          scenaFerma: _sceneFerma,
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_fase == _Fase.scelta) ...[
                  _IlMazzoCoperto(
                    key: _ilMazzo,
                    palette: palette,
                    domanda: _affidata,
                    scelti: _scelti,
                    onScegli: _scegli,
                    onAvvia: _avviaLaLettura,
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                ],
                _LAngeloDellOra(
                  palette: palette,
                  adesso: _ora(),
                  triade: _triade,
                  corpus: _corpus,
                ),
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
                    onCondividi: _onShare,
                    onInvito: _invitoAlPiano,
                  ),
                  // LA RISPOSTA LUNGA E' DELL'ADEPTO (FU.10): a chi non
                  // l'ha, il lucchetto e l'invito, mai un vicolo cieco.
                  if (!_assaggio &&
                      !PlanCatalog.apre(RigaDelPiano.oracoloLunga, _tier)) ...[
                    const SizedBox(height: SpacingTokens.sm),
                    _IlLucchetto(
                      chiave: 'oracolo_lucchetto_lunga',
                      palette: palette,
                      testo: 'La risposta lunga: Medora va più a fondo '
                          'nel legame fra la tua domanda e le tre carte',
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
  /// gira, i tre dorsi sull'altare quando la scena e' ferma, le lettere di
  /// luce, e la domanda sopra la scena.
  Widget _laScena(double w, MaestroPalette palette) {
    final h = GeometriaDellAltare.altezza(w);
    final cima = MediaQuery.paddingOf(context).top + kToolbarHeight;
    return SizedBox(
      key: const Key('oracolo_scena'),
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
                saltato: _regia.saltata,
                child: _regia.disegna(),
              ),
            ),
          // **SOTTO LE CARTE L'ALTARE VUOTO** (FY.17): a scena ferma la fascia
          // dell'altare viene dal primo fotogramma, dove l'altare e' ancora
          // sgombro. Le carte che si girano non lasciano piu' vedere i dorsi
          // dipinti nel video.
          if (_sceneFerma)
            const Positioned.fill(
              child: IgnorePointer(child: AltareVuoto()),
            ),
          if (_sceneFerma)
            for (var i = 0; i < 3; i++)
              // Mentre si sceglie, sull'altare stanno solo i dorsi scelti.
              if (_fase != _Fase.scelta || i < _scelti.length)
                _CartaSullAltare(
                  indice: i,
                  larghezza: w,
                  appare: !_regia.filmatoInScena ||
                      _regia.saltata ||
                      _fase == _Fase.scelta,
                  carta: _carte.length == 3 ? _carte[i] : null,
                  // L'assaggio del Viandante gira solo il Custode (FU.10).
                  chiusa: _assaggio && i > 0,
                  giro: _giro,
                  palette: palette,
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
          if (_sceneFerma && _fase == _Fase.domanda)
            Positioned(
              left: SpacingTokens.md,
              right: SpacingTokens.md,
              top: cima + SpacingTokens.xs,
              child: LaScenaFermaCheAppare(
                appare: true,
                child: _LaDomanda(
                  palette: palette,
                  controllo: _domanda,
                  onAffida: _affida,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// **L'ALTARE VUOTO**, ordine FY voce FY.17, 16 ottobre 2026. Il fondatore:
/// "Le carte si girano con sotto le carte coperte del video".
///
/// L'ultimo fotogramma porta i tre dorsi dipinti sull'altare; una carta che
/// si gira in prospettiva si stringe e li lasciava vedere sotto. Qui la
/// fascia dell'altare viene dal primo fotogramma, dove l'altare e' sgombro e
/// identico (scarto medio fuori dalle carte sotto 3 livelli su 255 ai lati e
/// sotto 12 sopra, misurato in `docs/collaudo/FY/oracolo/fy17_altare.txt`),
/// sfumata in alto e in basso: niente cucitura, niente dorsi dipinti.
class AltareVuoto extends StatelessWidget {
  const AltareVuoto({super.key});

  /// La fascia in pixel del fotogramma: i dorsi dipinti stanno fra 1535 e
  /// 1685 (`GeometriaDellAltare`), la fascia li copre con margine e sfuma
  /// in [sfumatura] pixel per lato.
  static const double cima = 1505;
  static const double fondo = 1715;
  static const double sfumatura = 16;

  @override
  Widget build(BuildContext context) {
    final h = GeometriaDellAltare.fotogramma.height;
    return ShaderMask(
      key: const Key('oracolo_altare_vuoto'),
      blendMode: BlendMode.dstIn,
      shaderCallback: (r) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0x00FFFFFF),
          Color(0x00FFFFFF),
          Color(0xFFFFFFFF),
          Color(0xFFFFFFFF),
          Color(0x00FFFFFF),
          Color(0x00FFFFFF),
        ],
        stops: [
          0,
          (cima - sfumatura) / h,
          cima / h,
          fondo / h,
          (fondo + sfumatura) / h,
          1,
        ],
      ).createShader(r),
      child: Image.asset(
        GeometriaDellAltare.primoFotogramma,
        fit: GeometriaDellAltare.taglio,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}

/// **UNA CARTA SULL'ALTARE**: il dorso posato in prospettiva esattamente
/// dove sta nel fotogramma, che si gira nella carta vera.
class _CartaSullAltare extends StatelessWidget {
  const _CartaSullAltare({
    required this.indice,
    required this.larghezza,
    required this.appare,
    required this.carta,
    required this.giro,
    required this.palette,
    this.chiusa = false,
  });

  /// Chiusa dal piano: resta dorso, come la carta coperta (FU.10).
  final bool chiusa;

  final int indice;
  final double larghezza;
  final bool appare;
  final CartaDellOracolo? carta;
  final Animation<double> giro;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final r = GeometriaDellAltare.cartaDritta(indice, larghezza);
    return Positioned.fromRect(
      rect: r,
      child: LaScenaFermaCheAppare(
        appare: appare,
        child: AnimatedBuilder(
          animation: giro,
          builder: (context, _) {
            final c = carta;
            // Le tre carte si girano una dopo l'altra, ognuna in un terzo
            // del tempo; la carta coperta (Intelletto senza ora) non si gira.
            final t = c == null || c.coperta || chiusa
                ? 0.0
                : ((giro.value * 3) - indice).clamp(0.0, 1.0);
            final faccia = t > 0.5;
            return Transform(
              alignment: Alignment.bottomCenter,
              transform:
                  GeometriaDellAltare.posa(larghezza, giro: faccia ? t - 1 : t),
              child: faccia
                  ? LaCartaDellAngelo(
                      key: Key('oracolo_carta_${c!.ruolo.name}'),
                      angelo: c.angelo,
                      palette: palette,
                    )
                  : Image.asset(GeometriaDellAltare.dorso,
                      key: Key('oracolo_dorso_$indice'),
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.medium),
            );
          },
        ),
      ),
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
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            FamilyImage.full(AssetFamily.angeli, angelo.artStem),
            fit: BoxFit.fill,
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

/// **LA DOMANDA**, sopra la scena: scritta o scelta fra quelle proposte.
///
/// Ordine FY voce FY.13: dieci domande per argomento, nella voce di Medora.
/// Gli argomenti e il pulsante che affida sono i pezzi dipinti del ramo
/// (R8); le proposte sono righe da leggere, in un riquadro che scorre da
/// solo, cosi' dieci domande non coprono la scena intera.
class _LaDomanda extends StatefulWidget {
  const _LaDomanda({
    required this.palette,
    required this.controllo,
    required this.onAffida,
  });

  final MaestroPalette palette;
  final TextEditingController controllo;
  final VoidCallback onAffida;

  /// Quanto e' alto al massimo il riquadro delle proposte.
  static const double altezzaDelleProposte = 176;

  @override
  State<_LaDomanda> createState() => _LaDomandaState();
}

class _LaDomandaState extends State<_LaDomanda> {
  /// Nessun tema aperto all'inizio: il pannello resta basso e lascia il
  /// volto di Medora alla scena. Le proposte si aprono toccando un tema.
  TemaDellOracolo? _tema;

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final vuota = widget.controllo.text.trim().isEmpty;
    final tema = _tema;
    return Container(
      key: const Key('oracolo_domanda'),
      padding: const EdgeInsets.all(SpacingTokens.sm),
      decoration: BoxDecoration(
        color: palette.deepest.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        border: Border.all(color: palette.goldSoft.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
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
                opacity: vuota ? 0.45 : 1,
                child: PulsanteTondoDipinto(
                  key: const Key('oracolo_affida'),
                  etichetta: 'Affida la domanda',
                  lato: 44,
                  onTap: vuota ? null : widget.onAffida,
                  figlio:
                      Icon(Icons.auto_awesome_rounded, color: palette.goldSoft),
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
            Text('${tema.nome}: dieci domande di Medora, scorri per leggerle',
                key: const Key('oracolo_tema_aperto'),
                style: TypographyTokens.etichetta()
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

/// **IL MAZZO COPERTO**, ordine FY voce FY.15, 16 ottobre 2026. Il
/// fondatore: "Non si possono scegliere le carte".
///
/// Lo stesso gesto della Stesa (`StesaFan`): l'arco dei dorsi si sfoglia
/// col dito e un tocco sceglie la carta, qui coi 72 dorsi degli Angeli. La
/// riga sopra dice quale carta si sceglie e chi la porta; scelte le tre, il
/// pulsante dipinto avvia la lettura (FY.16): prima e' spento, e nulla parte
/// da solo.
class _IlMazzoCoperto extends StatelessWidget {
  const _IlMazzoCoperto({
    super.key,
    required this.palette,
    required this.domanda,
    required this.scelti,
    required this.onScegli,
    required this.onAvvia,
  });

  final MaestroPalette palette;
  final String domanda;
  final List<int> scelti;
  final ValueChanged<int> onScegli;
  final VoidCallback onAvvia;

  static const List<String> _ordinali = ['prima', 'seconda', 'terza'];

  /// La riga che guida la scelta, detta prima del gesto.
  static String guida(int quante) {
    const ruoli = RuoloDellAngelo.values;
    if (quante >= ruoli.length) {
      return 'Le tre carte sono sull\'altare. Quando vuoi, avvia la lettura.';
    }
    final r = ruoli[quante];
    return 'Scegli la ${_ordinali[quante]} carta, '
        '${r.posizione.toLowerCase()}: la porta il tuo ${r.nome}. Sfoglia '
        'il mazzo col dito e tocca un dorso.';
  }

  @override
  Widget build(BuildContext context) {
    final tutte = scelti.length >= RuoloDellAngelo.values.length;
    return Column(
      key: const Key('oracolo_mazzo_coperto'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('La tua domanda: $domanda',
            key: const Key('oracolo_domanda_affidata'),
            textAlign: TextAlign.center,
            style: TypographyTokens.didascalia().copyWith(
                color: ColorTokens.textSecondary, fontStyle: FontStyle.italic)),
        const SizedBox(height: SpacingTokens.xs),
        Text(guida(scelti.length),
            key: const Key('oracolo_guida_della_scelta'),
            textAlign: TextAlign.center,
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textPrimary)),
        const SizedBox(height: SpacingTokens.xs),
        StesaFan(
          palette: palette,
          taken: scelti.toSet(),
          onPick: onScegli,
          // Scelte le tre, il ventaglio non prende piu' tocchi.
          scene: tutte ? StesaScene.completa : StesaScene.riposo,
          ingresso: 1,
          respiro: 0,
          taglio: 0,
          mescolamento: 0,
          taglioIndice: 0,
          reduceMotion: MediaQuery.disableAnimationsOf(context),
          carte: 72,
          dorso: GeometriaDellAltare.dorso,
        ),
        const SizedBox(height: SpacingTokens.sm),
        Center(
          child: PulsanteDipinto(
            key: const Key('oracolo_avvia_la_lettura'),
            testo: 'Avvia la lettura',
            onTap: tutte ? onAvvia : null,
          ),
        ),
      ],
    );
  }
}

/// **L'ANGELO DELL'ORA E IL MESSAGGIO DEL GIORNO** (FU.08), senza modello.
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: SpacingTokens.xxl + SpacingTokens.sm,
                height: (SpacingTokens.xxl + SpacingTokens.sm) * 1.5,
                child: LaCartaDellAngelo(angelo: angelo, palette: palette),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
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
                  ],
                ),
              ),
            ],
          ),
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

/// **IL RESPONSO, UNA COPPIA SOLA.** Ordine FY voce FY.19, 16 ottobre 2026.
/// Il fondatore: "La prima descrizione e' troppo lunga con risposta,
/// riquadro e ancora risposta e riquadro. Basta una coppia".
///
/// Prima: il titolo, il messaggio del Custode, il riquadro, il messaggio
/// dell'Intelletto e, nella Lunga, il secondo riquadro (ordine FU voce FU.06
/// e ordine FN). Adesso il titolo con la risposta e un riquadro solo: il
/// legame che Medora scrive fra la domanda e le tre carte, con dentro i due
/// paragrafi della Lunga. Cio' che dicevano gli altri blocchi non si perde:
/// il messaggio di ogni carta sta nella sua bolla, accanto a chi e'
/// l'angelo (FY.18).
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
  });

  final MaestroPalette palette;
  final RispostaDellOracolo risposta;
  final List<CartaDellOracolo> carte;
  final Map<String, List<String>> corpus;
  final int variante;
  final DateTime quando;
  final bool assaggio;
  final Future<bool> Function() onCondividi;
  final Future<void> Function(RigaDelPiano riga, String cosa) onInvito;

  /// **DA DOVE VIENE**, una riga che dice anche chi scrive il legame.
  static const String daDoveViene =
      'I 72 nomi vengono dal versetto triplice dell\'Esodo, 14, 19-21; i '
      'loro cori e i loro salmi da Lenain, La Science cabalistique, 1823. I '
      'tuoi tre angeli vengono dal grado del Sole, dal giorno e dall\'ora '
      'della tua nascita. Il legame con la tua domanda lo scrive Medora.';

  /// La riga dell'assaggio: dice che cosa si apre, e da dove.
  static const String rigaDellAssaggio =
      'Oggi ti risponde il tuo Angelo Custode. Con l\'Iniziato rispondono '
      'tutti e tre i tuoi angeli: Medora scrive il legame fra la tua '
      'domanda e le tre carte.';

  /// **IL RIQUADRO**, l'unico: il legame scritto da Medora (il secondo dei
  /// tre paragrafi della lettura); all'assaggio, il messaggio del Custode.
  static String ilRiquadro(RispostaDellOracolo r, {required bool assaggio}) =>
      assaggio ? r.paragrafi.first : r.paragrafi[1];

  @override
  Widget build(BuildContext context) {
    final scoperte = [
      for (var i = 0; i < carte.length; i++)
        if (!carte[i].coperta && !(assaggio && i > 0)) carte[i],
    ];
    final perIlDiario = ResponsoDaCustodire(
      arte: 'oracolo_angeli',
      titolo: risposta.titolo,
      testo:
          assaggio ? risposta.paragrafi.first : risposta.paragrafi.join('\n\n'),
      perIlMaestro: [
        for (final c in scoperte) '${c.ruolo.nome}: ${c.angelo.name}',
      ].join('\n'),
      dati: {
        'angeli':
            [for (final c in scoperte) c.angelo.number.toString()].join(','),
      },
    );
    final riquadro = ilRiquadro(risposta, assaggio: assaggio);
    final lettura =
        TypographyTokens.lettura().copyWith(color: ColorTokens.textPrimary);
    final approfondimento =
        assaggio ? const <String>[] : risposta.approfondimento;
    return Column(
      key: const Key('oracolo_responso'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TitoloDelResponso(
          chiaveDelTesto: const Key('oracolo_titolo_del_responso'),
          testo: risposta.titolo,
          allineamento: TextAlign.center,
          aCapoFraLeParole: true,
          stile: TypographyTokens.titoloSezione()
              .copyWith(color: palette.goldSoft, height: 1.25),
        ),
        const SizedBox(height: SpacingTokens.sm),
        RiquadroInEvidenza(
          key: const Key('oracolo_riquadro'),
          palette: palette,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ParagrafiDiLettura(
                  key: const Key('oracolo_testo_del_riquadro'),
                  testo: riquadro,
                  stile: lettura),
              // I due paragrafi della Lunga stanno nello stesso riquadro:
              // una coppia sola, non un secondo blocco (FY.19).
              for (var i = 0; i < approfondimento.length; i++) ...[
                const SizedBox(height: SpacingTokens.sm),
                Text(approfondimento[i],
                    key: Key('responso_approfondimento_$i'), style: lettura),
              ],
            ],
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
            'Medora oggi risponde coi soli messaggi delle carte: il legame '
            'con la tua domanda arriva quando la rete torna.',
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
              riquadro: riquadro,
              rito: corpus[LOraDegliAngeli.chiaveDelRito(carte[i].angelo)],
              variante: variante,
            ),
          const SizedBox(height: SpacingTokens.md),
        ],
        Text('Da dove viene',
            style: TypographyTokens.etichetta().copyWith(
                color: ColorTokens.textSecondary, letterSpacing: 1.2)),
        const SizedBox(height: SpacingTokens.xxs),
        Text(daDoveViene,
            key: const Key('oracolo_da_dove_viene'),
            style: TypographyTokens.didascalia().copyWith(
                color: ColorTokens.textSecondary,
                height: 1.35,
                fontStyle: FontStyle.italic)),
        const SizedBox(height: SpacingTokens.md),
        AzioniDelResponso(
          palette: palette,
          maestro: Maestro.medora,
          dorato: true,
          responso: perIlDiario,
          quando: quando,
          condividi: onCondividi,
          aperturaDellaChat: ChatOpeners.oracoloAngeli(carte.first.angelo.name,
              carte.first.ruolo.posizione.toLowerCase(), risposta.titolo),
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
class _LaBollaDellaCarta extends StatelessWidget {
  const _LaBollaDellaCarta({
    required this.palette,
    required this.carta,
    required this.messaggio,
    required this.riquadro,
    required this.rito,
    required this.variante,
  });

  final MaestroPalette palette;
  final CartaDellOracolo carta;

  /// Il messaggio della carta per questa consultazione, dal corpus.
  final String messaggio;

  /// Il testo del riquadro della risposta: se e' lo stesso messaggio, la
  /// bolla non lo ripete.
  final String riquadro;
  final List<String>? rito;
  final int variante;

  String get _chiLaPorta => carta.portatore == null
      ? 'La porta il tuo ${carta.ruolo.nome}, che si rivela con l\'ora di '
          'nascita'
      : 'La porta il tuo ${carta.ruolo.nome}, ${carta.portatore!.name}';

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
                    Text(carta.ruolo.posizione.toUpperCase(),
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
          if (messaggio != riquadro) ...[
            const SizedBox(height: SpacingTokens.sm),
            Text(
                carta.coperta
                    ? 'Perché resta coperta'
                    : 'Il suo messaggio per te',
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft)),
            const SizedBox(height: SpacingTokens.xxs),
            ParagrafiDiLettura(
                key: Key('oracolo_messaggio_${carta.ruolo.name}'),
                testo: messaggio,
                stile: TypographyTokens.lettura()
                    .copyWith(color: ColorTokens.textPrimary)),
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

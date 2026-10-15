import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/angels/angel_catalog.dart';
import '../../../core/angels/guardian_angels.dart';
import '../../../core/assets/family_image.dart';
import '../../../core/cerchio/il_cerchio_sociale.dart';
import '../../../core/condivisione/premio_della_condivisione.dart';
import '../../../core/entitlement/entitlement_service.dart';
import '../../../core/entitlement/listino_degli_eos.dart';
import '../../../core/entitlement/plan_catalog.dart';
import '../../../core/entitlement/question_allowance.dart';
import '../../../core/entitlement/tier.dart';
import '../../../core/synastry_evolutiva/cielo_evolutivo.dart';
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
import '../../../design_system/components/il_responso_in_tre_paragrafi.dart';
import '../../../design_system/components/la_conferma_della_spesa.dart';
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
import '../../ricordi/azioni_del_responso.dart';
import '../../scene/la_scena_in_video.dart';
import '../../sigilli/regia_del_cammino.dart';
import '../../synastry/la_nascita_dell_altra_persona.dart';
import '../../synastry/la_tua_nascita_per_una_lettura.dart';
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
enum _Fase { domanda, saleLaDomanda, siGirano, risposta }

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
  bool _sottoIlTitolo = false;

  /// **LA DOMANDA PER UN AMICO** (FU.09): il suo nome e i suoi tre angeli,
  /// dalla nascita prestata col suo consenso. Vale per una lettura sola: la
  /// nuova domanda torna a chi consulta.
  ({String nome, AngelTriad triade})? _perUnAmico;

  /// L'amico della consultazione a video, se la consultazione era per lui.
  String? _nomeDellAmicoLetto;

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

  /// **AFFIDARE LA DOMANDA.** Ogni domanda estrae le tre carte, come tutte le
  /// altre: la domanda sale lungo la scala, la lettura parte insieme alle
  /// lettere e i dorsi si girano.
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
    if (domanda.isEmpty || _fase == _Fase.saleLaDomanda) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final tier = _tier;
    // **LE CONSULTAZIONI DEL GIORNO** (FU.10): finite, l'invito con le due
    // strade, una consultazione in piu' a Eos o salire di piano. Finche' il
    // server non porta il budget nel listino non si conta niente
    // (`QuestionAllowance.contaGliOracoli`).
    final borsa = _forse<QuestionAllowance>();
    if (borsa != null && !borsa.puoiConsultareGliAngeli(tier)) {
      await _leConsultazioniDiOggiSonoFinite();
      if (!mounted || !borsa.puoiConsultareGliAngeli(tier)) return;
    }
    final amico = _perUnAmico;
    final carte = EstrazioneDellOracolo.estrai(amico?.triade ?? _triade, _caso);
    final variante = _consultazioni;
    // **L'ASSAGGIO DEL VIANDANTE** (FU.10): la carta del Custode dal corpus,
    // senza modello; Cuore e Intelletto restano col lucchetto e l'invito.
    final assaggio = !PlanCatalog.apre(RigaDelPiano.oracoloTreCarte, tier);
    borsa?.registraOracolo(tier);
    setState(() {
      _affidata = domanda;
      _carte = carte;
      _risposta = null;
      _fase = _Fase.saleLaDomanda;
      _consultazioni++;
      _assaggio = assaggio;
      _nomeDellAmicoLetto = amico?.nome;
    });
    _giro.value = 0;
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
            profonda: PlanCatalog.apre(RigaDelPiano.oracoloLungaEAmico, tier),
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
      // La nascita dell'amico valeva per una lettura sola (FU.09).
      _perUnAmico = null;
      _nomeDellAmicoLetto = null;
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

  /// **LA DOMANDA PER UN AMICO** (FU.09): rispondono i suoi tre angeli. La
  /// sua nascita passa solo col suo consenso, una volta per lettura, con lo
  /// stesso gesto della lettura a due telefoni (ordine FT): il codice che
  /// detta dal suo telefono, dato per l'Oracolo. Dall'Adepto (FU.10).
  Future<void> _chiediPerUnAmico() async {
    if (!PlanCatalog.apre(RigaDelPiano.oracoloLungaEAmico, _tier)) {
      await _invitoAlPiano(
          RigaDelPiano.oracoloLungaEAmico, 'La domanda per un amico');
      return;
    }
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final letta = await LaNascitaDellAltraPersona.chiedi(context, palette,
        perLOracolo: true);
    if (letta == null || !mounted) return;
    final sole = letta.cielo.longitudini[PuntoDelCieloEvolutivo.sole];
    if (sole == null) return;
    setState(() => _perUnAmico = (
          nome: letta.nome,
          triade: GliAngeliDiUnAmico.daNascitaPrestata(
            giorno: letta.cielo.giornoDiNascita,
            longitudineDelSole: sole,
            minutoLocale: letta.minutoLocale,
          ),
        ));
  }

  /// **PRESTARE LA PROPRIA NASCITA** a un amico che consulta per te: lo
  /// stesso gesto del consenso della lettura a due telefoni, dato per
  /// l'Oracolo. Aperto a ogni piano: prestare non costa niente.
  void _prestaLaNascita() {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    Navigator.of(context)
        .push(LaTuaNascitaPerUnaLettura.route(palette, perLOracolo: true));
  }

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
          // Lo stesso velo della Sinastria evolutiva: leggero all'apertura,
          // denso quando la lettura passa sotto il titolo.
          backgroundColor:
              palette.deepest.withValues(alpha: _sottoIlTitolo ? 0.9 : 0.16),
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          iconTheme: IconThemeData(color: palette.goldSoft),
          title: TitoloCheNonSiRompe(
              chiaveDelTesto: const Key('oracolo_titolo'),
              testo: 'Oracolo degli Angeli',
              righe: 1,
              stile: TypographyTokens.titoloSezione()),
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
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.depth != 0) return false;
        final sotto = n.metrics.pixels > SpacingTokens.lg;
        if (sotto != _sottoIlTitolo) setState(() => _sottoIlTitolo = sotto);
        return false;
      },
      child: ListView(
        controller: _scorrimento,
        padding: EdgeInsets.zero,
        children: [
          LayoutBuilder(
            builder: (context, vincoli) => _laScena(vincoli.maxWidth, palette),
          ),
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_fase == _Fase.domanda && _sceneFerma) ...[
                  _PerUnAmico(
                    palette: palette,
                    amico: _perUnAmico?.nome,
                    aperta: PlanCatalog.apre(
                        RigaDelPiano.oracoloLungaEAmico, _tier),
                    onChiedi: _chiediPerUnAmico,
                    onTornaATe: () => setState(() => _perUnAmico = null),
                    onPresta: _prestaLaNascita,
                  ),
                  const SizedBox(height: SpacingTokens.md),
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
                    amico: _nomeDellAmicoLetto,
                    onCondividi: _onShare,
                    onInvito: _invitoAlPiano,
                  ),
                  // LA RISPOSTA LUNGA E' DELL'ADEPTO (FU.10): a chi non
                  // l'ha, il lucchetto e l'invito, mai un vicolo cieco.
                  if (!_assaggio &&
                      !PlanCatalog.apre(
                          RigaDelPiano.oracoloLungaEAmico, _tier)) ...[
                    const SizedBox(height: SpacingTokens.sm),
                    _IlLucchetto(
                      chiave: 'oracolo_lucchetto_lunga',
                      palette: palette,
                      testo: 'La risposta lunga: Medora va più a fondo '
                          'nel legame fra la tua domanda e le tre carte',
                      onTap: () => _invitoAlPiano(
                          RigaDelPiano.oracoloLungaEAmico, 'La risposta lunga'),
                    ),
                  ],
                  const SizedBox(height: SpacingTokens.lg),
                  Center(
                    child: OutlinedButton(
                      key: const Key('oracolo_nuova_domanda'),
                      onPressed: _nuovaDomanda,
                      style: OutlinedButton.styleFrom(
                          foregroundColor: palette.goldSoft,
                          side: BorderSide(color: palette.goldSoft)),
                      child: const Text('Affida una nuova domanda'),
                    ),
                  ),
                ],
                const SizedBox(height: SpacingTokens.xxl),
              ],
            ),
          ),
        ],
      ),
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
          if (_sceneFerma)
            for (var i = 0; i < 3; i++)
              _CartaSullAltare(
                indice: i,
                larghezza: w,
                appare: !_regia.filmatoInScena || _regia.saltata,
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
class _LaDomanda extends StatefulWidget {
  const _LaDomanda({
    required this.palette,
    required this.controllo,
    required this.onAffida,
  });

  final MaestroPalette palette;
  final TextEditingController controllo;
  final VoidCallback onAffida;

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
              IconButton(
                key: const Key('oracolo_affida'),
                tooltip: 'Affida la domanda',
                color: palette.goldSoft,
                onPressed: widget.controllo.text.trim().isEmpty
                    ? null
                    : widget.onAffida,
                icon: const Icon(Icons.auto_awesome_rounded),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xxs),
          SizedBox(
            height: SpacingTokens.xl,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final t in TemaDellOracolo.values)
                  Padding(
                    padding: const EdgeInsets.only(right: SpacingTokens.xxs),
                    child: ChoiceChip(
                      key: Key('oracolo_tema_${t.name}'),
                      label: Text(t.nome),
                      selected: t == _tema,
                      onSelected: (si) => setState(() => _tema = si ? t : null),
                    ),
                  ),
              ],
            ),
          ),
          for (final d in _tema?.domande ?? const <String>[])
            TextButton(
              key: Key('oracolo_proposta_${_tema!.domande.indexOf(d)}'),
              style: TextButton.styleFrom(
                foregroundColor: palette.goldSoft,
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: SpacingTokens.xxs),
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () {
                widget.controllo.text = d;
                widget.controllo.selection =
                    TextSelection.collapsed(offset: d.length);
              },
              // Una proposta e' una frase da leggere: va a capo, non si
              // tronca, e non e' in maiuscoletto.
              child: Text(d,
                  style: TypographyTokens.corpo()
                      .copyWith(color: palette.goldSoft)),
            ),
        ],
      ),
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
    this.amico,
  });

  final MaestroPalette palette;
  final RispostaDellOracolo risposta;
  final List<CartaDellOracolo> carte;
  final Map<String, List<String>> corpus;
  final int variante;
  final DateTime quando;
  final bool assaggio;
  final String? amico;
  final Future<bool> Function() onCondividi;
  final Future<void> Function(RigaDelPiano riga, String cosa) onInvito;

  /// **DA DOVE VIENE**, una riga che dice anche chi scrive il legame.
  static const String daDoveViene =
      'I 72 nomi vengono dal versetto triplice dell\'Esodo, 14, 19-21; i '
      'loro cori e i loro salmi da Lenain, La Science cabalistique, 1823. I '
      'tuoi tre angeli vengono dal grado del Sole, dal giorno e dall\'ora '
      'della tua nascita. Il legame con la tua domanda lo scrive Medora.';

  /// Il Da dove viene della domanda per un amico: i tre angeli sono i suoi.
  static String daDoveVienePer(String amico) =>
      'I 72 nomi vengono dal versetto triplice dell\'Esodo, 14, 19-21; i '
      'loro cori e i loro salmi da Lenain, La Science cabalistique, 1823. I '
      'tre angeli di $amico vengono dal grado del Sole, dal giorno e '
      'dall\'ora della sua nascita, prestata per questa lettura. Il legame '
      'con la domanda lo scrive Medora.';

  /// La riga dell'assaggio: dice che cosa si apre, e da dove.
  static const String rigaDellAssaggio =
      'Oggi ti risponde il tuo Angelo Custode. Con l\'Iniziato rispondono '
      'tutti e tre i tuoi angeli: Medora scrive il legame fra la tua '
      'domanda e le tre carte.';

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
    final dove = amico == null ? daDoveViene : daDoveVienePer(amico!);
    return Column(
      key: const Key('oracolo_responso'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (amico != null) ...[
          Text('Rispondono gli angeli di $amico',
              key: const Key('oracolo_responso_per_l_amico'),
              textAlign: TextAlign.center,
              style:
                  TypographyTokens.corpo().copyWith(color: palette.goldSoft)),
          const SizedBox(height: SpacingTokens.xs),
        ],
        TitoloDelResponso(
          chiaveDelTesto: const Key('oracolo_titolo_del_responso'),
          testo: risposta.titolo,
          allineamento: TextAlign.center,
          aCapoFraLeParole: true,
          stile: TypographyTokens.titoloSezione()
              .copyWith(color: palette.goldSoft, height: 1.25),
        ),
        const SizedBox(height: SpacingTokens.sm),
        if (assaggio) ...[
          ParagrafiDiLettura(
              key: const Key('oracolo_paragrafo_dell_assaggio'),
              testo: risposta.paragrafi.first,
              stile: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textPrimary)),
          const SizedBox(height: SpacingTokens.sm),
          Text(rigaDellAssaggio,
              key: const Key('oracolo_riga_dell_assaggio'),
              style: TypographyTokens.didascalia().copyWith(
                  color: ColorTokens.textSecondary,
                  fontStyle: FontStyle.italic)),
          const SizedBox(height: SpacingTokens.sm),
          Text(dove,
              style: TypographyTokens.didascalia().copyWith(
                  color: ColorTokens.textSecondary,
                  fontStyle: FontStyle.italic)),
        ] else ...[
          ResponsoInTreParagrafi(
            paragrafi: risposta.paragrafi,
            stile: TypographyTokens.lettura()
                .copyWith(color: ColorTokens.textPrimary),
            palette: palette,
            approfondimento: risposta.approfondimento,
            daDoveViene: dove,
          ),
          if (!risposta.dalModello) ...[
            const SizedBox(height: SpacingTokens.sm),
            Text(
              'Medora oggi risponde coi soli messaggi delle carte: il legame '
              'con la tua domanda arriva quando la rete torna.',
              key: const Key('oracolo_solo_corpus'),
              style: TypographyTokens.didascalia().copyWith(
                  color: ColorTokens.textSecondary,
                  fontStyle: FontStyle.italic),
            ),
          ],
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
              paragrafo: risposta.paragrafi[i],
              rito: corpus[LOraDegliAngeli.chiaveDelRito(carte[i].angelo)],
              variante: variante,
              amico: amico,
            ),
          const SizedBox(height: SpacingTokens.md),
        ],
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

/// **LA DOMANDA PER UN AMICO E LA NASCITA PRESTATA** (FU.09), sotto la
/// scena mentre si affida la domanda. Chi chiede per un amico gli fa
/// dettare il codice dal suo telefono; chi presta la propria nascita da' il
/// consenso, per una lettura sola.
class _PerUnAmico extends StatelessWidget {
  const _PerUnAmico({
    required this.palette,
    required this.amico,
    required this.aperta,
    required this.onChiedi,
    required this.onTornaATe,
    required this.onPresta,
  });

  final MaestroPalette palette;

  /// Il nome dell'amico per cui si sta chiedendo, o nullo.
  final String? amico;

  /// Se il piano apre la domanda per un amico (dall'Adepto).
  final bool aperta;
  final VoidCallback onChiedi;
  final VoidCallback onTornaATe;
  final VoidCallback onPresta;

  @override
  Widget build(BuildContext context) {
    final stile = TextButton.styleFrom(foregroundColor: palette.goldSoft);
    if (amico != null) {
      return Row(
        key: const Key('oracolo_per_l_amico'),
        children: [
          Icon(Icons.people_alt_rounded, color: palette.goldSoft),
          const SizedBox(width: SpacingTokens.xs),
          Expanded(
            child: Text('Rispondono gli angeli di $amico',
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textPrimary)),
          ),
          TextButton(
            key: const Key('oracolo_torna_a_te'),
            style: stile,
            onPressed: onTornaATe,
            child: const Text('Torna a te'),
          ),
        ],
      );
    }
    return Wrap(
      spacing: SpacingTokens.sm,
      children: [
        TextButton.icon(
          key: const Key('oracolo_chiedi_per_un_amico'),
          style: stile,
          onPressed: onChiedi,
          icon: Icon(aperta ? Icons.people_alt_rounded : Icons.lock_rounded),
          label: const Text('Chiedi per un amico'),
        ),
        TextButton.icon(
          key: const Key('oracolo_presta_la_nascita'),
          style: stile,
          onPressed: onPresta,
          icon: const Icon(Icons.key_rounded),
          label: const Text('Presta la tua nascita'),
        ),
      ],
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
class _LaBollaDellaCarta extends StatelessWidget {
  const _LaBollaDellaCarta({
    required this.palette,
    required this.carta,
    required this.paragrafo,
    required this.rito,
    required this.variante,
    this.amico,
  });

  final MaestroPalette palette;
  final CartaDellOracolo carta;
  final String paragrafo;
  final List<String>? rito;
  final int variante;

  /// L'amico per cui si e' chiesto: le carte le portano i suoi angeli.
  final String? amico;

  String get _chiLaPorta {
    if (amico != null) {
      return carta.portatore == null
          ? 'La porta il ${carta.ruolo.nome} di $amico, che si rivela con '
              'la sua ora di nascita'
          : 'La porta il ${carta.ruolo.nome} di $amico, '
              '${carta.portatore!.name}';
    }
    return carta.portatore == null
        ? 'La porta il tuo ${carta.ruolo.nome}, che si rivela con l\'ora di '
            'nascita'
        : 'La porta il tuo ${carta.ruolo.nome}, ${carta.portatore!.name}';
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
          if (carta.coperta && amico != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            Text(
                'La sua ora di nascita non è arrivata col codice: la terza '
                'carta resta coperta.',
                key: const Key('oracolo_coperta_per_l_amico'),
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textSecondary)),
          ] else if (carta.coperta) ...[
            const SizedBox(height: SpacingTokens.sm),
            Center(
              child: OutlinedButton(
                key: const Key('oracolo_aggiungi_l_ora'),
                onPressed: () =>
                    Navigator.of(context).push(DatiDiNascitaScreen.route()),
                style: OutlinedButton.styleFrom(
                    foregroundColor: palette.goldSoft,
                    side: BorderSide(color: palette.goldSoft)),
                child: const Text('Aggiungi l\'ora di nascita'),
              ),
            ),
          ] else ...[
            const SizedBox(height: SpacingTokens.sm),
            ParlaneConMaestroCompatto(
              keyDelPulsante: Key('oracolo_parlane_${carta.ruolo.name}'),
              palette: palette,
              maestro: Maestro.medora,
              frase: paragrafo,
              aperturaDellaChat: ChatOpeners.oracoloAngeli(carta.angelo.name,
                  carta.ruolo.posizione.toLowerCase(), paragrafo),
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

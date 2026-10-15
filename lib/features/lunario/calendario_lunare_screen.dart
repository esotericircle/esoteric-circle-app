import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/luogo_attuale.dart';
import '../../core/cerchio/il_cerchio_sociale.dart';
import '../../core/condivisione/premio_della_condivisione.dart';
import '../../core/entitlement/entitlement_service.dart';
import '../../core/entitlement/listino_degli_eos.dart';
import '../../core/entitlement/plan_catalog.dart';
import '../../core/entitlement/tier.dart';
import '../../core/identity/birth_identity.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/lunario/il_giorno_lunare.dart';
import '../../core/lunario/il_motore_lunare.dart';
import '../../core/lunario/il_segno_del_giorno_tuo.dart';
import '../../core/lunario/le_attivita_del_lunario.dart';
import '../../core/lunario/le_lune_della_nasa.dart';
import '../../core/maestro/maestro.dart';
import '../../core/rituals/avvisi_del_rito.dart';
import '../../design_system/components/la_conferma_della_spesa.dart';
import '../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../design_system/components/titolo_del_responso.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';
import '../../services/avvisi_locali.dart';
import '../account/dati_di_nascita_screen.dart';
import '../maestri/rotta_arte.dart';
import '../maestri/widgets/foglio_delle_fonti.dart';
import '../pricing/upgrade_invite.dart';
import '../scene/la_scena_in_video.dart';
import '../sigilli/regia_del_cammino.dart';
import 'gli_eos_del_lunario.dart';
import 'i_promemoria_del_lunario.dart';
import 'il_piano_del_lunario.dart';
import 'la_card_del_mese.dart';
import 'la_geometria_del_velo.dart';
import 'la_luce_in_fusione.dart';
import 'la_luna_nel_castone.dart';
import 'trova_il_giorno_insieme.dart';

/// **IL CALENDARIO LUNARE PERSONALE: L'ALMANACCO DI MEDORA.** Ordine FV,
/// voci FV.02, FV.05, FV.06 (a video), FV.07 (a video), FV.08, FV.09, FV.11
/// e FV.13, 15 ottobre 2026. Il fondatore sulla proposta dell'Architetto:
/// *"Siz approvo tutto"*.
///
/// **La scena** (FV.02): all'apertura parte l'Almanacco di luce, una volta
/// per apertura, dalla regia comune delle scene; un tocco lo salta
/// (`IlToccoCheSalta`). Fermo il video, resta l'ultimo fotogramma come sfondo
/// e sul velo che Medora regge si posa il mese di trenta lune
/// (`GeometriaDelVelo.veloSulloSchermo`): la griglia e' piu' larga del velo
/// e lo lascia sotto come alone, come le carte della Sinastria VIP.
///
/// **Il mese** (FV.05): sette colonne dal lunedi', i nomi in italiano, ogni
/// giorno la sua Luna vera nel castone dipinto; le lune si accendono a
/// cascata dalla Luna nuova in avanti, con Riduci Movimento tutte insieme.
///
/// **TUTTO E' DIPINTO** (R9): lune, castone, emblemi, sigilli, aloni, scia e
/// seme sono asset; Flutter dispone, dissolve e muove soltanto. La guardia
/// e' `test/il_lunario_e_dipinto_test.dart`.
///
/// **NESSUNA CHIAMATA AL MODELLO** (R2): tutto e' calcolo sul telefono
/// (`IlMotoreLunare`) e corpus scritto (`LeRegoleDelLunario`, i giorni tuoi).
class CalendarioLunareScreen extends StatefulWidget {
  const CalendarioLunareScreen({
    super.key,
    this.fabbricaDellaScena,
    this.adesso,
    this.valuta,
    this.giorniTuoi,
    this.identita,
    this.avvisi,
    this.latitudine,
    this.delMese,
  });

  /// La finta del lettore video, per le prove headless.
  final FabbricaDiScena? fabbricaDellaScena;

  /// L'orologio, per le prove.
  final DateTime Function()? adesso;

  /// **LA PORTA DELLE REGOLE** (FV.06): nulla, quella del corpus.
  final ValutaIlGiorno? valuta;

  /// **LA PORTA DEI GIORNI TUOI** (FV.07): nulla, quella del corpus.
  final IGiorniTuoiDelMese? giorniTuoi;

  /// La nascita da usare; nulla, quella del profilo.
  final BirthIdentity? identita;

  /// Il punto degli avvisi; nullo, quello dell'app (`avvisiDelCerchio`).
  final ServizioAvvisi? avvisi;

  /// La latitudine della persona; nulla, quella di `DoveSonoAdesso`.
  final double? latitudine;

  /// Il motore dei giorni; nullo, `IlMotoreLunare.delMese`.
  final List<GiornoLunare> Function(int anno, int mese)? delMese;

  static Route<void> route() => PassaggioDelCerchio.rotta(
        (_) => const SogliaArte(
          id: 'lunar_calendar',
          maestro: Maestro.medora,
          child: CalendarioLunareScreen(),
        ),
      );

  /// **PUNTO DI UNIONE FV.06.** Finche' il corpus delle regole non e' nel
  /// ramo, nessun giorno si accende: il grado e' neutro e il perche' e'
  /// vuoto. All'unione al suo posto va `LeRegoleDelLunario.valuta`.
  static EsitoDelGiorno senzaRegole(AttivitaDelLunario a, GiornoLunare g) =>
      const EsitoDelGiorno(grado: GradoDelGiorno.neutro, perche: [], fonti: []);

  /// **PUNTO DI UNIONE FV.07.** Finche' il corpus dei giorni tuoi non e'
  /// nel ramo, nessun segno compare. All'unione al suo posto va la porta di
  /// `lib/core/lunario/i_giorni_tuoi.dart`.
  static List<SegnoDelGiornoTuo> senzaGiorniTuoi(
          BirthIdentity nascita, int anno, int mese) =>
      const [];

  @override
  State<CalendarioLunareScreen> createState() => _CalendarioLunareScreenState();
}

class _CalendarioLunareScreenState extends State<CalendarioLunareScreen>
    with TickerProviderStateMixin {
  late final RegiaDellaScena _regia;

  /// La cascata delle lune, dalla Luna nuova in avanti (FV.05).
  late final AnimationController _cascata = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2400));

  /// La scia d'oro che passa sul mese come la mano di Medora (FV.06).
  late final AnimationController _scia = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100));

  /// La dissolvenza degli aloni e delle lune spente (FV.06).
  late final AnimationController _aloni = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));

  late final IPromemoriaDelLunario _promemoria =
      IPromemoriaDelLunario(avvisi: widget.avvisi ?? avvisiDelCerchio);

  /// **GLI ACQUISTI A EOS** (FV.12): un mese extra, una proposta insieme.
  late final GliEosDelLunario _eos = GliEosDelLunario();

  late DateTime _oggi;
  late int _anno;
  late int _mese;
  CategoriaDelLunario? _categoria;
  AttivitaDelLunario? _attivita;
  double? _latitudine;
  bool _avviata = false;
  bool _cascataPartita = false;
  bool _riduciMovimento = false;
  final Map<String, List<GiornoLunare>> _mesi = {};

  /// La card da condividere, dipinta fuori schermo solo mentre si condivide.
  final _cardKey = GlobalKey();
  bool _renderCard = false;

  ValutaIlGiorno get _valuta =>
      widget.valuta ?? CalendarioLunareScreen.senzaRegole;

  IGiorniTuoiDelMese get _porteDeiGiorniTuoi =>
      widget.giorniTuoi ?? CalendarioLunareScreen.senzaGiorniTuoi;

  @override
  void initState() {
    super.initState();
    _oggi = _ora();
    _anno = _oggi.year;
    _mese = _oggi.month;
    _regia = RegiaDellaScena(widget.fabbricaDellaScena ??
        () => LettoreDiScena.vero(GeometriaDelVelo.filmato))
      ..addListener(_quandoLaScenaCambia);
    _promemoria.addListener(_ridisegna);
    unawaited(_promemoria.leggi());
    _eos.addListener(_ridisegna);
    unawaited(_eos.leggi());
    _latitudine = widget.latitudine;
    if (_latitudine == null) unawaited(_leggiIlLuogo());
  }

  DateTime _ora() => widget.adesso?.call() ?? DateTime.now();

  Future<void> _leggiIlLuogo() async {
    final luogo = await DoveSonoAdesso.letto();
    if (!mounted || luogo == null) return;
    setState(() => _latitudine = luogo.lat);
  }

  void _ridisegna() {
    if (mounted) setState(() {});
  }

  /// Fermo il video (finito, saltato, o mai partito), le lune si accendono.
  void _quandoLaScenaCambia() {
    if (!mounted) return;
    if (_regia.ferma && !_cascataPartita) {
      _cascataPartita = true;
      unawaited(_cascata.forward(from: 0));
    }
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _riduciMovimento = MediaQuery.of(context).disableAnimations;
    // Con Riduci Movimento le lune compaiono tutte insieme in dissolvenza.
    _cascata.duration = Duration(milliseconds: _riduciMovimento ? 600 : 2400);
    if (_avviata) return;
    _avviata = true;
    unawaited(_regia.avvia(context));
  }

  @override
  void dispose() {
    _regia
      ..removeListener(_quandoLaScenaCambia)
      ..dispose();
    _promemoria
      ..removeListener(_ridisegna)
      ..dispose();
    _eos
      ..removeListener(_ridisegna)
      ..dispose();
    _cascata.dispose();
    _scia.dispose();
    _aloni.dispose();
    super.dispose();
  }

  T? _forse<T>() {
    try {
      return context.read<T>();
    } catch (senzaProvider) {
      debugPrint('Calendario Lunare: manca $T, ripiego ($senzaProvider)');
      return null;
    }
  }

  BirthIdentity get _identita =>
      widget.identita ??
      _forse<ProfileController>()?.identity ??
      BirthIdentity.example;

  /// **IL PIANO** (FV.12): si legge qui, i limiti li scrive
  /// `IlPianoDelLunario` quando la voce FV.12 arriva.
  Tier get _tier => _forse<EntitlementService>()?.tier ?? Tier.free;

  bool get _ruota =>
      _latitudine != null && LeLuneDellaNasa.ruotaPer(_latitudine!);

  List<GiornoLunare> _giorniDel(int anno, int mese) => _mesi.putIfAbsent(
      '$anno-$mese',
      () => (widget.delMese ?? IlMotoreLunare.delMese)(anno, mese));

  List<GiornoLunare> get _giorni => _giorniDel(_anno, _mese);

  /// I giorni tuoi del mese, solo per la persona (FV.07): senza l'ora di
  /// nascita tacciono quelli che vengono dalla Luna di nascita.
  List<SegnoDelGiornoTuo> get _segniTuoi {
    final nascita = _identita;
    if (nascita.isExample) return const [];
    return [
      for (final s in _porteDeiGiorniTuoi(nascita, _anno, _mese))
        if (nascita.hasBirthTime || !s.tipo.dipendeDallOra) s,
    ];
  }

  Map<int, EsitoDelGiorno> get _esiti {
    final a = _attivita;
    if (a == null) return const {};
    return {for (final g in _giorni) g.giorno.day: _valuta(a, g)};
  }

  /// **SCORRERE I MESI** (FV.05), dal mese in corso fino a quelli che il
  /// piano apre, piu' i mesi extra comprati a Eos (FV.12). Oltre quel
  /// limite, l'invito con le due strade: mai un vicolo cieco.
  void _cambiaMese(int passo) {
    final nuovo = DateTime(_anno, _mese + passo);
    final primo = DateTime(_oggi.year, _oggi.month);
    final massimo =
        IlPianoDelLunario.mesiAvantiCon(tier: _tier, mesiExtra: _eos.mesiExtra);
    final ultimo = DateTime(_oggi.year, _oggi.month + massimo);
    if (nuovo.isBefore(primo)) return;
    if (nuovo.isAfter(ultimo)) {
      unawaited(_invitoDelMeseBloccato());
      return;
    }
    setState(() {
      _anno = nuovo.year;
      _mese = nuovo.month;
    });
    unawaited(_cascata.forward(from: 0));
    if (_attivita != null) _accendiGliAloni();
  }

  /// **MAI UN VICOLO CIECO** (FV.12): il mese oltre il piano apre l'invito
  /// con le due strade, un mese in piu' a Eos (prezzo dal listino, detto
  /// prima del gesto) oppure salire di piano.
  Future<void> _invitoDelMeseBloccato() async {
    final sociale = _forse<IlCerchioSociale>();
    final costo = ListinoDegliEos.meseExtraDelLunario.costo;
    final dal = PlanCatalog.dalPiano((t) =>
        IlPianoDelLunario.mesiAvanti(t) > IlPianoDelLunario.mesiAvanti(_tier));
    final piano = dal?.replaceFirst('Dall’', '');
    await showUpgradeInvite(
      context,
      title: piano == null
          ? 'Il tuo piano arriva fino a qui'
          : 'Più mesi avanti sono dell’$piano',
      message: piano == null
          ? 'Più mesi avanti si aprono con un piano del Cerchio.'
          : 'Più mesi avanti si aprono dal piano $piano in su. Oppure apri '
              'questo mese subito con gli Eos.',
      riscattoLabel: sociale == null
          ? null
          : 'Un mese di Calendario Lunare in più · $costo Eos',
      onRiscatta: sociale == null
          ? null
          : () async {
              final consenso =
                  await LaConfermaDellaSpesa.degliEos(context, costo: costo);
              if (consenso == null || !mounted) return;
              final esito =
                  await sociale.compraUnMeseDelLunario(consenso: consenso);
              if (esito.ok) {
                await _eos.aggiungiUnMeseExtra();
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(esito.rigaPerLaPersona)));
              }
            },
    );
  }

  void _scegliCategoria(CategoriaDelLunario c) {
    if (!IlPianoDelLunario.categoriaAperta(c, _tier)) {
      unawaited(_invitoDellaCategoria(c));
      return;
    }
    setState(() {
      if (_categoria == c) {
        _categoria = null;
        _attivita = null;
      } else {
        _categoria = c;
        _attivita = c.attivita.length == 1 ? c.attivita.first : null;
      }
    });
    if (_attivita != null) _accendiGliAloni();
  }

  /// **MAI UN VICOLO CIECO** (FV.12): la categoria chiusa dice da quale
  /// piano si apre.
  Future<void> _invitoDellaCategoria(CategoriaDelLunario c) async {
    final dal =
        PlanCatalog.dalPiano((t) => IlPianoDelLunario.categoriaAperta(c, t));
    final piano = dal?.replaceFirst('Dall’', '');
    await showUpgradeInvite(
      context,
      title: piano == null ? c.nome : '${c.nome} è dell’$piano',
      message: piano == null
          ? '${c.nome} si apre con un piano del Cerchio.'
          : '${c.nome} si apre dal piano $piano in su.',
    );
  }

  /// **TROVA IL GIORNO INSIEME** (FV.10), col lucchetto e l'invito quando il
  /// piano non lo apre (FV.12): oppure una proposta sola a Eos.
  Future<void> _apriTrovaInsieme() async {
    final sociale = _forse<IlCerchioSociale>();
    if (sociale == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(EsitoDelGesto.silenzio.rigaPerLaPersona)));
      return;
    }
    final aperto =
        IlPianoDelLunario.trovaInsiemeAperto(_tier) || _eos.proposteInsieme > 0;
    if (!aperto) {
      final costo = ListinoDegliEos.propostaInsiemeDelLunario.costo;
      final dal =
          PlanCatalog.dalPiano((t) => IlPianoDelLunario.trovaInsiemeAperto(t));
      final piano = dal?.replaceFirst('Dall’', '');
      await showUpgradeInvite(
        context,
        title: piano == null
            ? 'Trova il giorno insieme'
            : 'Trova il giorno insieme è dell’$piano',
        message: piano == null
            ? 'Trova il giorno insieme si apre con un piano del Cerchio.'
            : 'Trova il giorno insieme si apre dal piano $piano in su. '
                'Oppure sblocca una proposta sola con gli Eos.',
        riscattoLabel: 'Una proposta insieme · $costo Eos',
        onRiscatta: () async {
          final consenso =
              await LaConfermaDellaSpesa.degliEos(context, costo: costo);
          if (consenso == null || !mounted) return;
          final esito =
              await sociale.compraUnaPropostaInsieme(consenso: consenso);
          if (esito.ok) {
            await _eos.aggiungiUnaPropostaInsieme();
            if (mounted) unawaited(_apriIlFoglioInsieme(sociale));
          } else if (mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(esito.rigaPerLaPersona)));
          }
        },
      );
      return;
    }
    await _apriIlFoglioInsieme(sociale);
  }

  Future<void> _apriIlFoglioInsieme(IlCerchioSociale sociale) async {
    final dalPiano = IlPianoDelLunario.trovaInsiemeAperto(_tier);
    await apriTrovaIlGiornoInsieme(
      context,
      palette: MaestroPalette.forKey(const ThemeKey.of(Maestro.medora)),
      sociale: sociale,
      identitaMia: _identita,
      anno: _anno,
      mese: _mese,
      giorni: _giorni,
      ruota: _ruota,
      valuta: _valuta,
      giorniTuoi: widget.giorniTuoi,
      onPropostaMandata:
          dalPiano ? null : () => _eos.consumaUnaPropostaInsieme(),
    );
  }

  void _scegliAttivita(AttivitaDelLunario a) {
    setState(() => _attivita = _attivita == a ? null : a);
    if (_attivita != null) _accendiGliAloni();
  }

  /// **TROVA IL GIORNO** (FV.06): la scia d'oro passa sul mese, poi gli
  /// aloni compaiono sui giorni d'oro e i giorni da evitare si spengono.
  /// Con Riduci Movimento niente scia: gli aloni in dissolvenza.
  void _accendiGliAloni() {
    // La cascata finisce subito: le luci si posano sul mese gia' acceso.
    _cascata.value = 1;
    _aloni.value = 0;
    if (_riduciMovimento) {
      unawaited(_aloni.forward());
    } else {
      unawaited(_scia.forward(from: 0).then((_) {
        if (mounted) unawaited(_aloni.forward());
      }));
    }
    unawaited(RegiaDelCammino.dopoUnGesto(context, 'lunario'));
  }

  Future<void> _apriIlGiorno(GiornoLunare g) async {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final esito = _attivita == null ? null : _valuta(_attivita!, g);
    await foglioDelCerchio<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (foglio) => _IlFoglioDelGiorno(
        giorno: g,
        palette: palette,
        attivita: _attivita,
        esito: esito,
        segni: [
          for (final s in _segniTuoi)
            if (s.giorno.day == g.giorno.day) s,
        ],
        promemoria: _promemoria,
        oggi: _oggi,
        ruota: _ruota,
        adesso: _ora,
        promemoriaAperti: IlPianoDelLunario.promemoriaAperti(_tier),
      ),
    );
  }

  /// **LA CARD DEL MESE** (FV.11): le lune vere e, se c'e' un'attivita', i
  /// suoi giorni d'oro. Mai i giorni tuoi, mai l'intenzione.
  Future<bool> _condividi() async {
    setState(() => _renderCard = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final andata = await shareCardDelMese(
        boundaryKey: _cardKey,
        text: 'Le lune di ${IlMeseInItaliano.mesi[_mese - 1].toLowerCase()} '
            'nel Calendario di Medora. Esoteric Circle.',
      );
      if (andata && mounted) {
        await PremioDellaCondivisione.premia(context,
            cosa: 'Hai condiviso il tuo Calendario Lunare');
      }
      return andata;
    } catch (errore) {
      debugPrint('Calendario Lunare: la card non si prepara ($errore)');
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
          backgroundColor: palette.deepest.withValues(alpha: 0.16),
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          iconTheme: IconThemeData(color: palette.goldSoft),
          title: TitoloCheNonSiRompe(
              chiaveDelTesto: const Key('lunario_titolo'),
              testo: 'Calendario Lunare',
              righe: 1,
              stile: TypographyTokens.titoloSezione()),
          actions: [
            FoglioDelleFonti.bottone(context,
                palette: palette,
                testo: TestiDelleFonti.calendarioLunare,
                chiave: 'lunario_fonti'),
            const AngoloDellaBarra(),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, vincoli) =>
              _laScena(Size(vincoli.maxWidth, vincoli.maxHeight), palette),
        ),
      ),
    );
  }

  /// **LA SCENA**: l'ultimo fotogramma come sfondo fisso, il video sopra
  /// finche' gira, il mese sul velo quando la scena e' ferma, e sotto il
  /// mese la fila degli emblemi e le attivita'.
  Widget _laScena(Size schermo, MaestroPalette palette) {
    final ferma = _regia.ferma;
    final velo = GeometriaDelVelo.veloSulloSchermo(schermo);
    final cima = MediaQuery.paddingOf(context).top + kToolbarHeight;
    final fondo = MediaQuery.paddingOf(context).bottom;
    // LA GRIGLIA PIU' LARGA DEL VELO, che resta sotto come alone: sette
    // colonne nel velo vero sarebbero di 36 punti a 360 di larghezza, poche
    // per una Luna e il suo numero. Si allarga fino a 12 punti dai bordi,
    // centrata sul velo, e scende un poco sotto il suo orlo.
    final larghezza =
        (schermo.width - 2 * SpacingTokens.sm).clamp(velo.width, schermo.width);
    final griglia = Rect.fromLTRB(
      (velo.center.dx - larghezza / 2).clamp(0, schermo.width - larghezza),
      (velo.top - SpacingTokens.sm).clamp(cima + SpacingTokens.xxs, velo.top),
      (velo.center.dx + larghezza / 2).clamp(larghezza, schermo.width),
      velo.bottom + SpacingTokens.lg,
    );
    return Stack(
      key: const Key('lunario_scena'),
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned.fill(
          child: Image.asset(
            ferma
                ? GeometriaDelVelo.ultimoFotogramma
                : GeometriaDelVelo.primoFotogramma,
            key: const Key('lunario_fotogramma'),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => ColoredBox(color: palette.deepest),
          ),
        ),
        // IL VIDEO SI TOGLIE QUANDO FINISCE: l'ultimo fotogramma dipinto sta
        // gia' sotto (scarto misurato dalla voce FV.02), e le luci in fusione
        // schermo hanno bisogno dello sfondo nel loro stesso strato, che la
        // superficie del video non e'. Saltato, sfuma e poi non dipinge piu'.
        if (_regia.filmatoInScena && (!ferma || _regia.saltata))
          Positioned.fill(
            child: IlFilmatoCheSfuma(
              key: const Key('lunario_filmato'),
              saltato: _regia.saltata,
              child: _regia.disegna(),
            ),
          ),
        if (ferma) ...[
          Positioned.fromRect(
            rect: griglia,
            child: GestureDetector(
              key: const Key('lunario_mese_scorre'),
              onHorizontalDragEnd: (d) {
                final v = d.primaryVelocity ?? 0;
                if (v < -120) _cambiaMese(1);
                if (v > 120) _cambiaMese(-1);
              },
              child: _IlMese(
                anno: _anno,
                mese: _mese,
                giorni: _giorni,
                oggi: _oggi,
                ruota: _ruota,
                palette: palette,
                cascata: _cascata,
                scia: _scia,
                aloni: _aloni,
                esiti: _esiti,
                categoria: _categoria,
                segni: _segniTuoi,
                promemoria: _promemoria,
                onGiorno: _apriIlGiorno,
                onMese: _cambiaMese,
              ),
            ),
          ),
          Positioned(
            left: SpacingTokens.sm,
            right: SpacingTokens.sm,
            top: griglia.bottom + SpacingTokens.xxs,
            bottom: fondo + SpacingTokens.xxs,
            child: _IlPannello(
              palette: palette,
              categoria: _categoria,
              attivita: _attivita,
              esiti: _esiti,
              identita: _identita,
              conGiorniTuoi: _segniTuoi.isNotEmpty,
              promemoria: _promemoria,
              anno: _anno,
              mese: _mese,
              tier: _tier,
              onCategoria: _scegliCategoria,
              onAttivita: _scegliAttivita,
              onCondividi: _condividi,
              onTrovaInsieme: _apriTrovaInsieme,
              trovaInsiemeAperto: IlPianoDelLunario.trovaInsiemeAperto(_tier) ||
                  _eos.proposteInsieme > 0,
            ),
          ),
        ],
        // **LA CARD DEL MESE**, fuori schermo e solo mentre si condivide.
        if (_renderCard)
          Positioned(
            left: -3000,
            top: 0,
            child: RepaintBoundary(
              key: _cardKey,
              child: LaCardDelMese(
                anno: _anno,
                mese: _mese,
                giorni: _giorni,
                ruota: _ruota,
                attivita: _attivita,
                giorniDOro: {
                  for (final e in _esiti.entries)
                    if (e.value.grado == GradoDelGiorno.oro) e.key,
                },
              ),
            ),
          ),
      ],
    );
  }
}

/// **IL MESE DI TRENTA LUNE** (FV.05), posato sul velo.
///
/// **Un solo strato di pittura, per scelta**: le luci (aloni, scia, seme)
/// si posano in fusione schermo (`LaLuceInFusione`) e la fusione vale solo
/// contro cio' che sta nel loro stesso strato. Per questo qui non c'e' un
/// `Opacity`, un `PageView` o un `RepaintBoundary`: la cascata e lo
/// spegnimento passano dall'opacita' delle immagini e dal colore del testo,
/// che non aprono strati.
class _IlMese extends StatelessWidget {
  const _IlMese({
    required this.anno,
    required this.mese,
    required this.giorni,
    required this.oggi,
    required this.ruota,
    required this.palette,
    required this.cascata,
    required this.scia,
    required this.aloni,
    required this.esiti,
    required this.categoria,
    required this.segni,
    required this.promemoria,
    required this.onGiorno,
    required this.onMese,
  });

  final int anno;
  final int mese;
  final List<GiornoLunare> giorni;
  final DateTime oggi;
  final bool ruota;
  final MaestroPalette palette;
  final AnimationController cascata;
  final AnimationController scia;
  final AnimationController aloni;
  final Map<int, EsitoDelGiorno> esiti;
  final CategoriaDelLunario? categoria;
  final List<SegnoDelGiornoTuo> segni;
  final IPromemoriaDelLunario promemoria;
  final void Function(GiornoLunare) onGiorno;
  final void Function(int passo) onMese;

  static const String alone =
      'assets/img/calendario_lunare/luce_alone_oro_v1.webp';
  static const String sciaDOro =
      'assets/img/calendario_lunare/luce_scia_oro_v1.webp';
  static const String seme =
      'assets/img/calendario_lunare/seme_di_luce_v1.webp';
  static const String fuoriCorso =
      'assets/img/calendario_lunare/sig_luna_fuori_corso_v1.webp';

  /// L'ordine della cascata: dalla Luna nuova del mese in avanti, un giorno
  /// dopo l'altro; i giorni prima della Luna nuova vengono per ultimi.
  static List<int> ordineDellaCascata(List<GiornoLunare> giorni) {
    if (giorni.isEmpty) return const [];
    var nuova = giorni.indexWhere((g) => g.lunaNuova);
    if (nuova < 0) {
      // Il motore non segna ancora la Luna nuova: il giorno con
      // l'elongazione piu' vicina a zero.
      double distanza(GiornoLunare g) =>
          g.elongazione < 180 ? g.elongazione : 360 - g.elongazione;
      nuova = 0;
      for (var i = 1; i < giorni.length; i++) {
        if (distanza(giorni[i]) < distanza(giorni[nuova])) nuova = i;
      }
    }
    return [
      for (var i = 0; i < giorni.length; i++) (i - nuova) % giorni.length,
    ];
  }

  bool _eOggi(DateTime g) =>
      g.year == oggi.year && g.month == oggi.month && g.day == oggi.day;

  @override
  Widget build(BuildContext context) {
    final riduci = MediaQuery.of(context).disableAnimations;
    return LayoutBuilder(builder: (context, v) {
      final colonna = v.maxWidth / 7;
      const testata = 46.0;
      final righe = IlMeseInItaliano.righe(anno, mese);
      final riga = (v.maxHeight - testata) / righe;
      const numero = 16.0;
      const sigilli = 13.0;
      final lato = (riga - numero - sigilli).clamp(0.0, colonna - 2);
      final vuote = IlMeseInItaliano.vuoteIniziali(anno, mese);
      final ordine = ordineDellaCascata(giorni);
      Rect cella(int i) {
        final p = vuote + i;
        return Rect.fromLTWH(
            (p % 7) * colonna, testata + (p ~/ 7) * riga, colonna, riga);
      }

      // Il castone dentro la cella: sotto il numero, al centro.
      Rect castone(int i) {
        final c = cella(i);
        return Rect.fromCenter(
            center: Offset(c.center.dx, c.top + numero + lato / 2),
            width: lato,
            height: lato);
      }

      final mesePrima = DateTime(anno, mese - 1);
      final meseDopo = DateTime(anno, mese + 1);
      return AnimatedBuilder(
        animation: Listenable.merge([cascata, scia, aloni]),
        builder: (context, _) {
          final cascataFinita = cascata.value >= 1;
          double accensione(int i) {
            if (riduci) return cascata.value;
            final n = giorni.length;
            final inizio = ordine[i] / n * 0.8;
            return ((cascata.value - inizio) / 0.2).clamp(0.0, 1.0);
          }

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // LA TESTATA: il mese e i nomi dei giorni, in italiano.
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 28,
                child: Row(
                  children: [
                    _Passo(
                      chiave: 'lunario_mese_prima',
                      testo: '‹',
                      semantica: IlMeseInItaliano.mesi[mesePrima.month - 1],
                      onTap: () => onMese(-1),
                      palette: palette,
                    ),
                    Expanded(
                      child: Text(IlMeseInItaliano.titolo(anno, mese),
                          key: const Key('lunario_mese_titolo'),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TypographyTokens.titoloScheda().copyWith(
                              color: palette.goldSoft,
                              shadows: const [
                                Shadow(color: Colors.black, blurRadius: 6)
                              ])),
                    ),
                    _Passo(
                      chiave: 'lunario_mese_dopo',
                      testo: '›',
                      semantica: IlMeseInItaliano.mesi[meseDopo.month - 1],
                      onTap: () => onMese(1),
                      palette: palette,
                    ),
                  ],
                ),
              ),
              for (var c = 0; c < 7; c++)
                Positioned(
                  key: Key('lunario_colonna_$c'),
                  left: c * colonna,
                  width: colonna,
                  top: 30,
                  height: 16,
                  child: Text(IlMeseInItaliano.giorni[c],
                      textAlign: TextAlign.center,
                      style: TypographyTokens.etichetta().copyWith(
                          color: ColorTokens.textPrimary,
                          shadows: const [
                            Shadow(color: Colors.black, blurRadius: 4)
                          ])),
                ),
              // OGGI: l'alone d'oro dietro la sua Luna, quando nessuna
              // attivita' accende i giorni d'oro.
              for (var i = 0; i < giorni.length; i++)
                if (_eOggi(giorni[i].giorno) && esiti.isEmpty)
                  Positioned.fromRect(
                    rect: castone(i).inflate(lato * 0.45),
                    child: LaLuceInFusione(
                      key: const Key('lunario_oggi_alone'),
                      opacita: 0.75 * accensione(i),
                      child: Image.asset(alone,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox.shrink()),
                    ),
                  ),
              // GLI ALONI D'ORO dei giorni migliori (FV.06).
              for (var i = 0; i < giorni.length; i++)
                if (esiti[giorni[i].giorno.day]?.grado == GradoDelGiorno.oro)
                  Positioned.fromRect(
                    rect: castone(i).inflate(lato * 0.55),
                    child: LaLuceInFusione(
                      key: Key('lunario_oro_${giorni[i].giorno.day}'),
                      opacita: aloni.value,
                      child: Image.asset(alone,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox.shrink()),
                    ),
                  ),
              // LE LUNE.
              for (var i = 0; i < giorni.length; i++)
                Positioned.fromRect(
                  rect: cella(i),
                  child: _IlGiorno(
                    giorno: giorni[i],
                    oggi: _eOggi(giorni[i].giorno),
                    lato: lato,
                    altezzaNumero: numero,
                    altezzaSigilli: sigilli,
                    ruota: ruota,
                    palette: palette,
                    accensione: accensione(i) *
                        (esiti[giorni[i].giorno.day]?.grado ==
                                GradoDelGiorno.evitare
                            ? 1 - 0.7 * aloni.value
                            : 1),
                    esito: esiti[giorni[i].giorno.day],
                    categoria: categoria,
                    segni: [
                      for (final s in segni)
                        if (s.giorno.day == giorni[i].giorno.day) s,
                    ],
                    fissati: promemoria.delGiorno(giorni[i].giorno),
                    onTap: () => onGiorno(giorni[i]),
                  ),
                ),
              // IL SEME DI LUCE sulla Luna nuova (FV.09), posato quando la
              // cascata e' finita: prima le lune non sono ancora tutte accese.
              if (cascataFinita)
                for (var i = 0; i < giorni.length; i++)
                  if (giorni[i].lunaNuova)
                    Positioned.fromRect(
                      rect: castone(i).inflate(lato * 0.2),
                      child: IgnorePointer(
                        child: LaLuceInFusione(
                          key: Key('lunario_seme_${giorni[i].giorno.day}'),
                          child: Image.asset(seme,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink()),
                        ),
                      ),
                    ),
              // LA SCIA D'ORO, come la mano di Medora che passa sul mese.
              if (scia.isAnimating && !riduci)
                Positioned(
                  left: -v.maxWidth * 0.6 + scia.value * v.maxWidth * 1.6,
                  top: testata,
                  width: v.maxWidth * 0.6,
                  bottom: 0,
                  child: IgnorePointer(
                    child: LaLuceInFusione(
                      key: const Key('lunario_scia'),
                      opacita: scia.value < 0.85 ? 1 : (1 - scia.value) / 0.15,
                      child: Image.asset(sciaDOro,
                          fit: BoxFit.fill,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox.shrink()),
                    ),
                  ),
                ),
            ],
          );
        },
      );
    });
  }
}

/// Il passo da un mese all'altro, oltre allo scorrere col dito: un segno di
/// testo, non un'icona.
class _Passo extends StatelessWidget {
  const _Passo({
    required this.chiave,
    required this.testo,
    required this.semantica,
    required this.onTap,
    required this.palette,
  });

  final String chiave;
  final String testo;
  final String semantica;
  final VoidCallback onTap;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semantica,
      child: GestureDetector(
        key: Key(chiave),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: SpacingTokens.xl,
          height: 28,
          child: Center(
            child: Text(testo,
                style: TypographyTokens.titoloScheda()
                    .copyWith(color: palette.goldSoft)),
          ),
        ),
      ),
    );
  }
}

/// **UN GIORNO DEL MESE**: il numero, la Luna vera nel castone e sotto i
/// sigilli del giorno quando servono.
class _IlGiorno extends StatelessWidget {
  const _IlGiorno({
    required this.giorno,
    required this.oggi,
    required this.lato,
    required this.altezzaNumero,
    required this.altezzaSigilli,
    required this.ruota,
    required this.palette,
    required this.accensione,
    required this.esito,
    required this.categoria,
    required this.segni,
    required this.fissati,
    required this.onTap,
  });

  final GiornoLunare giorno;
  final bool oggi;
  final double lato;
  final double altezzaNumero;
  final double altezzaSigilli;
  final bool ruota;
  final MaestroPalette palette;

  /// Da 0 a 1: la cascata e lo spegnimento dei giorni da evitare, insieme.
  final double accensione;
  final EsitoDelGiorno? esito;
  final CategoriaDelLunario? categoria;
  final List<SegnoDelGiornoTuo> segni;
  final List<PromemoriaDelLunario> fissati;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final oro = esito?.grado == GradoDelGiorno.oro;
    final colore = oggi || oro ? palette.goldSoft : ColorTokens.textPrimary;
    final opacita = AlwaysStoppedAnimation(accensione);
    final piccoli = <String>[
      if (giorno.haFuoriCorso) _IlMese.fuoriCorso,
      if ((categoria?.mostraIlBiodinamico ?? false) &&
          giorno.tipoBiodinamico != null)
        giorno.tipoBiodinamico!.sigillo,
      for (final s in segni) s.sigillo,
      for (final f in fissati) f.attivita.categoria.emblema,
    ];
    return Semantics(
      button: true,
      label: '${giorno.giorno.day}, ${giorno.fase.nome}'
          '${oggi ? ', oggi' : ''}${oro ? ', giorno d\'oro' : ''}',
      child: GestureDetector(
        key: Key('lunario_giorno_${giorno.giorno.day}'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          children: [
            SizedBox(
              height: altezzaNumero,
              child: Text('${giorno.giorno.day}',
                  key: oggi ? const Key('lunario_oggi_numero') : null,
                  style: TypographyTokens.etichetta().copyWith(
                    color: colore.withValues(alpha: colore.a * accensione),
                    fontWeight: oggi ? FontWeight.w800 : null,
                    decoration: oggi ? TextDecoration.underline : null,
                    decorationColor: palette.goldSoft,
                    shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
                  )),
            ),
            _LaLunaAccesa(
              key: Key('lunario_luna_${giorno.giorno.day}'),
              elongazione: giorno.elongazione,
              ruota: ruota,
              lato: lato,
              opacita: opacita,
            ),
            SizedBox(
              height: altezzaSigilli,
              child: Row(
                key: Key('lunario_sigilli_${giorno.giorno.day}'),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final p in piccoli.take(3))
                    Image.asset(p,
                        width: altezzaSigilli,
                        height: altezzaSigilli,
                        opacity: opacita,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            SizedBox(width: altezzaSigilli)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// La Luna nel castone con l'opacita' sulle immagini e non in uno strato:
/// la stessa `LaLunaNelCastone` della card, accesa dalla cascata.
class _LaLunaAccesa extends StatelessWidget {
  const _LaLunaAccesa({
    super.key,
    required this.elongazione,
    required this.ruota,
    required this.lato,
    required this.opacita,
  });

  final double elongazione;
  final bool ruota;
  final double lato;
  final Animation<double> opacita;

  @override
  Widget build(BuildContext context) {
    final foto = LeLuneDellaNasa.immaginePer(elongazione);
    final luna = lato * LaLunaNelCastone.quotaDellaLuna;
    return SizedBox(
      width: lato,
      height: lato,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (foto != null)
            Transform.rotate(
              angle: ruota ? 3.141592653589793 : 0,
              child: Image.asset(foto,
                  width: luna,
                  height: luna,
                  opacity: opacita,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, __, ___) => SizedBox(width: luna)),
            ),
          Image.asset(LeLuneDellaNasa.castone,
              width: lato,
              height: lato,
              opacity: opacita,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, __, ___) => SizedBox(width: lato)),
        ],
      ),
    );
  }
}

/// **IL PANNELLO SOTTO IL MESE**: la fila degli undici emblemi (FV.06), le
/// attivita' della categoria, la riga che dice cosa succede, l'invito
/// all'ora di nascita (FV.07), i promemoria fissati (FV.08) e la card
/// (FV.11).
///
/// **SOTTO IL MESE, NON SOPRA, e lo si dichiara** (R1): l'ordine mette la
/// fila degli emblemi "sopra il mese", ma sopra il velo c'e' il volto di
/// Medora (dal 6 al 18 per cento dell'altezza del fotogramma): la fila lo
/// coprirebbe. Il fondatore il 23 agosto 2026: i Maestri stanno davanti.
class _IlPannello extends StatelessWidget {
  const _IlPannello({
    required this.palette,
    required this.categoria,
    required this.attivita,
    required this.esiti,
    required this.identita,
    required this.conGiorniTuoi,
    required this.promemoria,
    required this.anno,
    required this.mese,
    required this.tier,
    required this.onCategoria,
    required this.onAttivita,
    required this.onCondividi,
    required this.onTrovaInsieme,
    required this.trovaInsiemeAperto,
  });

  final MaestroPalette palette;
  final CategoriaDelLunario? categoria;
  final AttivitaDelLunario? attivita;
  final Map<int, EsitoDelGiorno> esiti;
  final BirthIdentity identita;
  final bool conGiorniTuoi;
  final IPromemoriaDelLunario promemoria;
  final int anno;
  final int mese;
  final Tier tier;
  final void Function(CategoriaDelLunario) onCategoria;
  final void Function(AttivitaDelLunario) onAttivita;
  final Future<bool> Function() onCondividi;

  /// **TROVA IL GIORNO INSIEME** (FV.10).
  final Future<void> Function() onTrovaInsieme;

  /// Se il piano (o un credito a Eos) apre "Trova il giorno insieme"
  /// (FV.12): col lucchetto quando non lo apre, mai un vicolo cieco.
  final bool trovaInsiemeAperto;

  String get _riga {
    final a = attivita;
    if (categoria == null) {
      return 'Tocca un giorno per leggerlo. Tocca un emblema per trovare il '
          'giorno giusto per ciò che vuoi fare.';
    }
    if (a == null) return 'Scegli che cosa vuoi fare.';
    final oro = esiti.values.where((e) => e.grado == GradoDelGiorno.oro);
    if (oro.isEmpty) {
      return 'Questo mese la Luna non accende giorni d\'oro per '
          '${a.nome.toLowerCase()}. Scorri al mese dopo.';
    }
    return 'I giorni d\'oro per ${a.nome.toLowerCase()} sono accesi: toccane '
        'uno per sapere perché.';
  }

  @override
  Widget build(BuildContext context) {
    final stileRiga =
        TypographyTokens.corpo().copyWith(color: ColorTokens.textPrimary);
    final fissatiDelMese = [
      for (final r in promemoria.fissati)
        if (r.giorno.year == anno && r.giorno.month == mese) r,
    ]..sort((a, b) => a.giorno.compareTo(b.giorno));
    return Container(
      key: const Key('lunario_pannello'),
      decoration: BoxDecoration(
        color: palette.deepest.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        border: Border.all(color: palette.goldSoft.withValues(alpha: 0.35)),
      ),
      child: ListView(
        key: const Key('lunario_pannello_scroll'),
        padding: const EdgeInsets.all(SpacingTokens.sm),
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              key: const Key('lunario_emblemi'),
              scrollDirection: Axis.horizontal,
              children: [
                for (final c in CategoriaDelLunario.values)
                  _LEmblema(
                    categoria: c,
                    scelta: categoria == c,
                    spenta: categoria != null && categoria != c,
                    aperta: IlPianoDelLunario.categoriaAperta(c, tier),
                    onTap: () => onCategoria(c),
                  ),
              ],
            ),
          ),
          if (categoria != null) ...[
            const SizedBox(height: SpacingTokens.xxs),
            Text(categoria!.nome,
                key: const Key('lunario_categoria_nome'),
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft)),
            if (categoria!.attivita.length > 1)
              Wrap(
                spacing: SpacingTokens.xxs,
                children: [
                  for (final a in categoria!.attivita)
                    ChoiceChip(
                      key: Key('lunario_attivita_${a.name}'),
                      label: Text(a.nome),
                      showCheckmark: false,
                      selected: attivita == a,
                      onSelected: (_) => onAttivita(a),
                    ),
                ],
              ),
          ],
          const SizedBox(height: SpacingTokens.xs),
          Text(_riga, key: const Key('lunario_riga'), style: stileRiga),
          if (promemoria.ultimoEsito == EsitoDelPromemoria.senzaPermesso) ...[
            const SizedBox(height: SpacingTokens.xs),
            Text(
                'Gli avvisi del telefono sono spenti per Esoteric Circle: il '
                'promemoria resta segnato sul mese, ma l\'avviso non '
                'arriverà. Puoi accenderli dalle impostazioni del telefono.',
                key: const Key('lunario_senza_permesso'),
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textSecondary)),
          ],
          if (conGiorniTuoi) ...[
            const SizedBox(height: SpacingTokens.xs),
            Text(
                'I sigilli d\'oro sotto le lune sono i giorni tuoi: li vedi '
                'solo tu.',
                key: const Key('lunario_giorni_tuoi_riga'),
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textSecondary)),
          ],
          if (identita.isExample || !identita.hasBirthTime) ...[
            const SizedBox(height: SpacingTokens.xs),
            Text(
                identita.isExample
                    ? 'Con la tua data di nascita sul mese compaiono i giorni '
                        'tuoi, che vedi solo tu.'
                    : 'Senza l\'ora di nascita due giorni tuoi tacciono: il '
                        'ritorno della tua Luna e la fase della tua nascita.',
                key: const Key('lunario_invito_ora'),
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textSecondary)),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: const Key('lunario_aggiungi_l_ora'),
                style: TextButton.styleFrom(foregroundColor: palette.goldSoft),
                onPressed: () =>
                    Navigator.of(context).push(DatiDiNascitaScreen.route()),
                child: Text(identita.isExample
                    ? 'Inserisci la tua nascita'
                    : 'Aggiungi l\'ora di nascita'),
              ),
            ),
          ],
          for (final r in fissatiDelMese)
            Row(
              key: Key('lunario_fissato_${r.chiave}'),
              children: [
                Image.asset(r.attivita.categoria.emblema,
                    width: SpacingTokens.lg,
                    height: SpacingTokens.lg,
                    errorBuilder: (_, __, ___) =>
                        const SizedBox(width: SpacingTokens.lg)),
                const SizedBox(width: SpacingTokens.xs),
                Expanded(
                  child: Text(
                      '${r.giorno.day} ${IlMeseInItaliano.mesi[r.giorno.month - 1].toLowerCase()}: ${r.attivita.nome.toLowerCase()}',
                      style: TypographyTokens.didascalia()
                          .copyWith(color: ColorTokens.textPrimary)),
                ),
                TextButton(
                  key: Key('lunario_togli_${r.chiave}'),
                  style:
                      TextButton.styleFrom(foregroundColor: palette.goldSoft),
                  onPressed: () => promemoria.togli(r),
                  child: const Text('Togli'),
                ),
              ],
            ),
          const SizedBox(height: SpacingTokens.xs),
          Center(
            child: Wrap(
              spacing: SpacingTokens.xs,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton.icon(
                  key: const Key('lunario_trova_insieme'),
                  onPressed: onTrovaInsieme,
                  style: OutlinedButton.styleFrom(
                      foregroundColor: palette.goldSoft,
                      side: BorderSide(color: palette.goldSoft)),
                  icon: Icon(trovaInsiemeAperto
                      ? Icons.people_alt_rounded
                      : Icons.lock_rounded),
                  label: const Text('Trova il giorno insieme'),
                ),
                OutlinedButton(
                  key: const Key('lunario_condividi'),
                  onPressed: onCondividi,
                  style: OutlinedButton.styleFrom(
                      foregroundColor: palette.goldSoft,
                      side: BorderSide(color: palette.goldSoft)),
                  child: const Text('Condividi il mese'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Un emblema dipinto della fila: la categoria scelta si fa piu' grande,
/// le altre si spengono in opacita'. Nessuna cornice disegnata.
///
/// **IL LUCCHETTO** (FV.12): la categoria che il piano non apre resta
/// visibile, spenta come le altre non scelte, con un piccolo lucchetto
/// sopra l'emblema dipinto, mai nascosta e mai un vicolo cieco.
class _LEmblema extends StatelessWidget {
  const _LEmblema({
    required this.categoria,
    required this.scelta,
    required this.spenta,
    required this.aperta,
    required this.onTap,
  });

  final CategoriaDelLunario categoria;
  final bool scelta;
  final bool spenta;
  final bool aperta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lato = scelta ? 54.0 : 44.0;
    return Semantics(
      button: true,
      selected: scelta,
      label: aperta ? categoria.nome : '${categoria.nome}, piano superiore',
      child: GestureDetector(
        key: Key('lunario_emblema_${categoria.name}'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: lato,
              height: lato,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(categoria.emblema,
                      opacity:
                          AlwaysStoppedAnimation(spenta || !aperta ? 0.45 : 1),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => SizedBox(width: lato)),
                  if (!aperta)
                    Icon(Icons.lock_rounded,
                        key: Key('lunario_lucchetto_${categoria.name}'),
                        size: lato * 0.4,
                        color: Colors.white.withValues(alpha: 0.9)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// **IL FOGLIO DEL GIORNO** (FV.05), nel formato del responso (Linee Guida
/// V13 sezione 26): il titolo che dice la Luna del giorno, poi cosa fare
/// (l'attivita' scelta, il promemoria, l'intenzione), poi i giorni tuoi, poi
/// il cielo del giorno in chiaro, e in fondo il "Da dove viene".
class _IlFoglioDelGiorno extends StatefulWidget {
  const _IlFoglioDelGiorno({
    required this.giorno,
    required this.palette,
    required this.attivita,
    required this.esito,
    required this.segni,
    required this.promemoria,
    required this.oggi,
    required this.ruota,
    required this.adesso,
    required this.promemoriaAperti,
  });

  final GiornoLunare giorno;
  final MaestroPalette palette;
  final AttivitaDelLunario? attivita;
  final EsitoDelGiorno? esito;
  final List<SegnoDelGiornoTuo> segni;
  final IPromemoriaDelLunario promemoria;
  final DateTime oggi;
  final bool ruota;
  final DateTime Function() adesso;
  final bool promemoriaAperti;

  static const List<String> giorniDellaSettimana = [
    'Lunedì',
    'Martedì',
    'Mercoledì',
    'Giovedì',
    'Venerdì',
    'Sabato',
    'Domenica',
  ];

  /// **DA DOVE VIENE**: il calcolo, la definizione e il metodo.
  static const String daDoveViene =
      'La fase, il segno e le ore fuori corso sono calcolati sul tuo telefono '
      'dalle posizioni astronomiche della Luna e del Sole, nell\'ora del '
      'luogo in cui ti trovi. La Luna fuori corso segue la definizione '
      'classica: dall\'ultimo aspetto maggiore della Luna a un pianeta fino '
      'al suo ingresso nel segno successivo. Il tipo di giorno viene dal '
      'metodo di Maria Thun, che guarda le costellazioni vere. Il modo in cui '
      'più regole fanno un giorno d\'oro è la chiave di Medora.';

  static String ora(DateTime t) =>
      '${t.hour}:${t.minute.toString().padLeft(2, '0')}';

  @override
  State<_IlFoglioDelGiorno> createState() => _IlFoglioDelGiornoState();
}

class _IlFoglioDelGiornoState extends State<_IlFoglioDelGiorno> {
  late final TextEditingController _intenzione = TextEditingController(
      text: widget.promemoria
              .intenzioni[IPromemoriaDelLunario.data(widget.giorno.giorno)] ??
          '');
  String? _esitoDetto;

  @override
  void initState() {
    super.initState();
    widget.promemoria.addListener(_ridisegna);
  }

  void _ridisegna() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.promemoria.removeListener(_ridisegna);
    _intenzione.dispose();
    super.dispose();
  }

  static String rigaDellEsito(EsitoDelPromemoria e) => switch (e) {
        EsitoDelPromemoria.programmato =>
          'Fissato. Il giorno prima, alle 20, te lo ricordo io.',
        EsitoDelPromemoria.senzaPermesso =>
          'Fissato sul mese. Gli avvisi del telefono sono spenti: l\'avviso '
              'non arriverà, ma il giorno resta segnato.',
        EsitoDelPromemoria.troppoTardi =>
          'Fissato sul mese. Il giorno prima è già passato: niente avviso.',
      };

  /// Il cielo del giorno in chiaro, un fatto per riga di lettura.
  String get _cielo {
    final g = widget.giorno;
    final righe = <String>[
      'È il giorno lunare ${g.giornoLunare}, con la Luna illuminata al '
          '${(g.illuminazione * 100).round()} per cento.',
      if (g.cambiDiSegno.isEmpty)
        'La Luna resta in ${g.segno.italianName} tutto il giorno.'
      else
        for (final c in g.cambiDiSegno)
          'La Luna entra in ${c.segno.italianName} alle '
              '${_IlFoglioDelGiorno.ora(c.istante)}.',
      if (g.fuoriCorso.isEmpty)
        'Oggi la Luna non è mai fuori corso.'
      else
        for (final f in g.fuoriCorso)
          'Fuori corso dalle ${_IlFoglioDelGiorno.ora(f.inizio)} alle '
              '${_IlFoglioDelGiorno.ora(f.fine)}.',
      if (g.tipoBiodinamico != null)
        '${g.tipoBiodinamico!.nome}, nel metodo di Maria Thun: elemento '
            '${g.tipoBiodinamico!.elemento}.',
    ];
    return righe.join('\n\n');
  }

  Future<void> _fissa() async {
    final a = widget.attivita!;
    final esito = await widget.promemoria.fissa(
        PromemoriaDelLunario(giorno: widget.giorno.giorno, attivita: a),
        adesso: widget.adesso());
    if (mounted) setState(() => _esitoDetto = rigaDellEsito(esito));
  }

  Future<void> _togli() async {
    await widget.promemoria.togli(PromemoriaDelLunario(
        giorno: widget.giorno.giorno, attivita: widget.attivita!));
    if (mounted) setState(() => _esitoDetto = 'Tolto dal mese.');
  }

  Future<void> _affidaLIntenzione() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final esito = await widget.promemoria.scriviLIntenzione(
        widget.giorno.giorno, _intenzione.text,
        adesso: widget.adesso());
    if (!mounted) return;
    setState(() => _esitoDetto = esito == null
        ? 'Nessuna intenzione: la Luna nuova resta com\'è.'
        : esito == EsitoDelPromemoria.programmato
            ? 'Affidata. Alla Luna piena te la ricordo.'
            : 'Affidata. Resta qui nel Calendario: gli avvisi del telefono '
                'sono spenti.');
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final g = widget.giorno;
    final esito = widget.esito;
    final attivita = widget.attivita;
    final fissato =
        attivita != null && widget.promemoria.eFissato(g.giorno, attivita);
    final lettura =
        TypographyTokens.lettura().copyWith(color: ColorTokens.textPrimary);
    final piccola = TypographyTokens.didascalia()
        .copyWith(color: ColorTokens.textSecondary);
    final bottone = OutlinedButton.styleFrom(
        foregroundColor: palette.goldSoft,
        side: BorderSide(color: palette.goldSoft));
    return Container(
      key: const Key('lunario_foglio'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.surfaceElevated, palette.deepest],
        ),
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(SpacingTokens.radiusXl)),
        border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.85),
          child: SingleChildScrollView(
            key: const Key('lunario_foglio_scroll'),
            padding: const EdgeInsets.fromLTRB(SpacingTokens.lg,
                SpacingTokens.md, SpacingTokens.lg, SpacingTokens.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: LaLunaNelCastone(
                      elongazione: g.elongazione,
                      ruota: widget.ruota,
                      lato: SpacingTokens.xxl * 1.5),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                    '${_IlFoglioDelGiorno.giorniDellaSettimana[g.giorno.weekday - 1]} '
                    '${g.giorno.day} '
                    '${IlMeseInItaliano.mesi[g.giorno.month - 1].toLowerCase()}',
                    textAlign: TextAlign.center,
                    style: TypographyTokens.etichetta()
                        .copyWith(color: palette.goldSoft)),
                const SizedBox(height: SpacingTokens.xxs),
                TitoloDelResponso(
                  chiaveDelTesto: const Key('lunario_foglio_titolo'),
                  testo: '${g.fase.nome} in ${g.segno.italianName}',
                  allineamento: TextAlign.center,
                  aCapoFraLeParole: true,
                  stile: TypographyTokens.titoloSezione()
                      .copyWith(color: palette.goldSoft, height: 1.25),
                ),
                if (attivita != null && esito != null) ...[
                  const SizedBox(height: SpacingTokens.md),
                  Text(
                      switch (esito.grado) {
                        GradoDelGiorno.oro =>
                          'Giorno d\'oro per ${attivita.nome.toLowerCase()}',
                        GradoDelGiorno.evitare =>
                          'Giorno da evitare per ${attivita.nome.toLowerCase()}',
                        GradoDelGiorno.neutro =>
                          'Per ${attivita.nome.toLowerCase()} è un giorno come '
                              'gli altri',
                      },
                      key: const Key('lunario_foglio_esito'),
                      style: TypographyTokens.titoloScheda()
                          .copyWith(color: palette.goldSoft)),
                  if (esito.perche.isNotEmpty) ...[
                    const SizedBox(height: SpacingTokens.xxs),
                    ParagrafiDiLettura(
                        key: const Key('lunario_foglio_perche'),
                        testo: esito.perche.join('\n\n'),
                        stile: lettura),
                  ],
                  if (esito.grado == GradoDelGiorno.oro &&
                      widget.promemoriaAperti) ...[
                    const SizedBox(height: SpacingTokens.sm),
                    Center(
                      child: OutlinedButton(
                        key: Key(fissato
                            ? 'lunario_togli_promemoria'
                            : 'lunario_fissa_promemoria'),
                        onPressed: fissato ? _togli : _fissa,
                        style: bottone,
                        child: Text(fissato
                            ? 'Togli il promemoria'
                            : 'Ricordamelo il giorno prima'),
                      ),
                    ),
                  ],
                ],
                if (g.lunaNuova) ...[
                  const SizedBox(height: SpacingTokens.md),
                  Text('La tua intenzione alla Luna nuova',
                      style: TypographyTokens.titoloScheda()
                          .copyWith(color: palette.goldSoft)),
                  Text(
                      'Se vuoi, scrivila in una riga. Resta solo qui, sul tuo '
                      'telefono: alla Luna piena te la ricordo.',
                      style: piccola),
                  TextField(
                    key: const Key('lunario_intenzione'),
                    controller: _intenzione,
                    maxLines: 1,
                    maxLength: 120,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _affidaLIntenzione(),
                    style: TypographyTokens.corpo()
                        .copyWith(color: ColorTokens.textPrimary),
                    decoration: const InputDecoration(
                        hintText: 'Che cosa affidi alla Luna nuova'),
                  ),
                  Center(
                    child: OutlinedButton(
                      key: const Key('lunario_affida_intenzione'),
                      onPressed: _affidaLIntenzione,
                      style: bottone,
                      child: const Text('Affidala alla Luna'),
                    ),
                  ),
                ],
                if (_esitoDetto != null) ...[
                  const SizedBox(height: SpacingTokens.xs),
                  Text(_esitoDetto!,
                      key: const Key('lunario_foglio_esito_promemoria'),
                      textAlign: TextAlign.center,
                      style: piccola),
                ],
                for (final s in widget.segni) ...[
                  const SizedBox(height: SpacingTokens.md),
                  Row(
                    key: Key('lunario_foglio_tuo_${s.tipo.name}'),
                    children: [
                      Image.asset(s.sigillo,
                          width: SpacingTokens.xl,
                          height: SpacingTokens.xl,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox(width: SpacingTokens.xl)),
                      const SizedBox(width: SpacingTokens.xs),
                      Expanded(
                        child: Text(s.titolo,
                            style: TypographyTokens.titoloScheda()
                                .copyWith(color: palette.goldSoft)),
                      ),
                    ],
                  ),
                  ParagrafiDiLettura(testo: s.testo, stile: lettura),
                ],
                const SizedBox(height: SpacingTokens.md),
                ParagrafiDiLettura(
                    key: const Key('lunario_foglio_cielo'),
                    testo: _cielo,
                    stile: lettura),
                const SizedBox(height: SpacingTokens.md),
                Text('Da dove viene',
                    style: TypographyTokens.etichetta()
                        .copyWith(color: palette.goldSoft)),
                const SizedBox(height: SpacingTokens.xxs),
                Text(_IlFoglioDelGiorno.daDoveViene,
                    key: const Key('lunario_foglio_da_dove_viene'),
                    style: piccola.copyWith(fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

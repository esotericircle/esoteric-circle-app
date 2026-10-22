import 'dart:async';
import '../scene/la_scena_in_video.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/il_segno_del_cielo.dart';
import '../../core/astro/meeus/corpo_celeste.dart';
import '../../core/entitlement/entitlement_service.dart';
import '../../core/entitlement/plan_catalog.dart';
import '../../core/entitlement/tier.dart';
import '../../core/maestro/maestro.dart';
import '../../core/ricordi/artwork_del_ricordo.dart';
import '../../core/sensi/la_suoneria.dart';
import '../../core/quality/quality_tier.dart';
import '../../core/settings/settings_controller.dart';
import '../../core/synastry_evolutiva/cielo_evolutivo.dart';
import '../../core/synastry_evolutiva/il_composito_e_keplero.dart';
import '../../core/synastry_evolutiva/il_corpus_della_sinastria_evolutiva.g.dart';
import '../../core/synastry_evolutiva/la_lettura_evolutiva.dart';
import '../../core/synastry_evolutiva/legame_e_eta.dart';
import '../../core/synastry_evolutiva/oggi_e_il_momento.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/il_responso_in_tre_paragrafi.dart';
import '../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../design_system/components/titolo_del_responso.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';
import '../maestri/chat/chat_openers.dart';
import '../maestri/rotta_arte.dart';
import '../maestri/widgets/foglio_delle_fonti.dart';
import '../pricing/upgrade_invite.dart';
import '../respiro_della_luna/i_comandi_dipinti.dart';
import '../ricordi/azioni_del_responso.dart';
import '../sigilli/regia_del_cammino.dart';
import 'il_ritratto_della_coppia.dart';
import 'lo_studio_di_medora.dart';

/// **LA SINASTRIA EVOLUTIVA.** Ordine FT, 14 ottobre 2026.
///
/// La scena (FT.02), il legame con lo sbarramento d'eta' (FT.04), Oggi fra
/// voi (FT.09), i cinque capitoli nel formato di casa (FT.06), gli intervalli
/// di Keplero (FT.08) e le tre esclusive dell'Adepto (FT.07 Composito, FT.10
/// Momento giusto, FT.11 Ritratto). **Livello visivo prima del testo**: ogni
/// parte comincia col suo medaglione o la sua figura. **Mai un vicolo
/// cieco**: cio' che il piano non apre resta visibile, col lucchetto e
/// l'invito (FT.13).
///
/// **SI APRE SULLA SCENA, ANCHE SENZA L'ALTRA PERSONA.** Ordine FY voce
/// FY.11, 16 ottobre 2026. Il fondatore: *"La sinastria evolutiva inizia con
/// una schermata nera e le funzioni social, niente altro"*. Il ponte
/// dell'ordine FT voce FT.14 chiedeva la nascita dell'altra persona prima di
/// aprire questa schermata, su un fondo nero. Adesso la schermata si apre
/// subito con lo studio di Medora e il suo video, e sotto, a scena ferma,
/// c'e' la scelta della persona ([chiediLaPersona]); data la nascita, la
/// lettura compare qui, sotto la stessa scena, senza un secondo video.
class SinastriaEvolutivaScreen extends StatefulWidget {
  const SinastriaEvolutivaScreen({
    super.key,
    required this.nomeTuo,
    required this.cieloTuo,
    this.nomeSuo,
    this.cieloSuo,
    this.chiediLaPersona,
    this.fabbricaDellaScena,
    this.oggi,
    this.amoreDalServer,
  }) : assert((nomeSuo == null) == (cieloSuo == null),
            'il nome e il cielo dell\'altra persona vanno insieme');

  final String nomeTuo;
  final CieloEvolutivo cieloTuo;

  /// L'altra persona. Nulli, la schermata si apre sulla scena e chiede chi
  /// e' con [chiediLaPersona].
  final String? nomeSuo;
  final CieloEvolutivo? cieloSuo;

  /// **LA SCELTA DELLA PERSONA**, ordine FY voce FY.11: apre la nascita
  /// dell'altra persona (a mano o col codice del suo telefono) e restituisce
  /// la persona, o nullo se chi legge ci ripensa. Il ponte
  /// `AvvioSinastriaEvolutiva` la passa con il conto delle coppie nuove.
  final Future<PersonaDellaSinastria?> Function(BuildContext context)?
      chiediLaPersona;

  /// La finta del lettore video, per le prove headless.
  final FabbricaDellaScenaSinastria? fabbricaDellaScena;

  /// Il giorno di Oggi fra voi e del Momento giusto; nullo, oggi.
  final DateTime? oggi;

  /// **IL VELO DELLA BARRA DEL TITOLO**, uno solo in ogni stato (ordine FY
  /// voce FY.20): semitrasparente, mai pieno.
  static const double veloDellaBarra = 0.45;

  /// **IL SECONDO CONTROLLO DELL'ETA'**, ordine FT voce FT.04: nella lettura
  /// a due telefoni il server rifa' lo sbarramento dei sedici anni con la
  /// nascita che ha nel consenso, e qui arriva il suo parere. Nullo con la
  /// nascita scritta a mano (il server non l'ha vista): decide l'app.
  final bool? amoreDalServer;

  static Route<void> route({
    required String nomeTuo,
    required CieloEvolutivo cieloTuo,
    required String nomeSuo,
    required CieloEvolutivo cieloSuo,
    bool? amoreDalServer,
  }) =>
      // **LA SOGLIA UNICA DELLE ARTI**: la Sinastria evolutiva e' un'arte
      // attiva dall'ordine FT, e come le altre si apre col suo cuore delle
      // preferite (guardia `tue_arti_schermata`).
      PassaggioDelCerchio.rotta(
        (_) => SogliaArte(
          id: 'synastry_depth',
          maestro: Maestro.medora,
          child: SinastriaEvolutivaScreen(
            nomeTuo: nomeTuo,
            cieloTuo: cieloTuo,
            nomeSuo: nomeSuo,
            cieloSuo: cieloSuo,
            amoreDalServer: amoreDalServer,
          ),
        ),
      );

  @override
  State<SinastriaEvolutivaScreen> createState() =>
      _SinastriaEvolutivaScreenState();
}

/// L'altra persona della lettura, come la restituisce la sua nascita.
typedef PersonaDellaSinastria = ({
  String nome,
  CieloEvolutivo cielo,
  bool? amoreDalServer,
});

class _SinastriaEvolutivaScreenState extends State<SinastriaEvolutivaScreen>
    with WidgetsBindingObserver {
  bool _reduceMotion = false;

  /// L'altra persona: dalla rotta, o scelta qui sotto la scena (FY.11).
  late String? _nomeSuo = widget.nomeSuo;
  late CieloEvolutivo? _cieloSuo = widget.cieloSuo;
  late bool? _amoreDalServer = widget.amoreDalServer;
  bool get _coppiaNota => _cieloSuo != null;
  String get _nome => _nomeSuo!;
  CieloEvolutivo get _suo => _cieloSuo!;
  bool _scegliendo = false;

  /// **L'ORA NON NOTA SI DICHIARA A VIDEO**, ordine FT voce FT.03: la Luna
  /// tace (`CieloEvolutivo.oraNota`), e chi legge sa perche' nessun
  /// aspetto la nomina. Nullo quando tutte e due le ore sono note.
  String? get _laLunaTace {
    final tua = widget.cieloTuo.oraNota;
    final sua = _suo.oraNota;
    if (tua && sua) return null;
    final chi = !tua && !sua
        ? 'Le vostre ore di nascita non sono note'
        : !tua
            ? 'La tua ora di nascita non è nota'
            : "L'ora di nascita di $_nome non è nota";
    return '$chi: la Luna, che in un giorno fa tredici gradi, tace in '
        'questa lettura invece di essere indovinata.';
  }

  /// **IL VIDEO SALTATO COL TOCCO**, ordine FU voce FU.15.
  bool _filmatoSaltato = false;

  /// **IL VIDEO HA UN TEMPO**, ordine FY voce FY.11. Questa scena tiene il
  /// suo lettore e non la regia comune, e dall'ordine FX voce FXA.08 il
  /// blocco sotto lo studio aspetta la scena ferma: un video che non si
  /// prepara, che e' pronto e non parte, o che parte e si blocca, lo teneva
  /// nascosto per sempre. Le stesse attese della regia comune
  /// ([RegiaDellaScena.attesaMassima]): passata l'attesa senza un video
  /// cominciato la scena e' ferma come se non si fosse caricato
  /// ([_scaduta]); un video cominciato che non arriva in fondo entro la sua
  /// durata piu' l'attesa sfuma come col tocco che salta.
  bool _scaduta = false;
  Timer? _attesaDelVideo;
  Timer? _attesaDellaFine;

  /// Il video gira: un tocco in qualunque punto lo fa sfumare.
  bool get _videoInCorso {
    final l = _lettore;
    return !_filmatoSaltato &&
        !_scaduta &&
        l != null &&
        l.pronto &&
        !l.finito &&
        !l.fallito;
  }

  void _saltaIlVideo() {
    if (!_videoInCorso) return;
    setState(() => _filmatoSaltato = true);
    unawaited(_lettore?.sospendi());
  }

  bool _avviata = false;
  LettoreDellaScenaSinastria? _lettore;
  bool _filmatoSospesoDaNoi = false;

  late final DateTime _oggi = widget.oggi ?? DateTime.now();
  late final DateTime _quando = DateTime.now();

  /// Il legame: amore se lo sbarramento d'eta' lo apre, altrimenti amicizia,
  /// finche' chi legge non ne sceglie uno.
  Legame? _legameScelto;
  Legame get _legame =>
      _legameScelto ?? (_amoreApribile ? Legame.amore : Legame.amicizia);

  bool get _amoreApribile =>
      _amoreDalServer != false &&
      SbarramentoDEta.legameApribile(
          Legame.amore, widget.cieloTuo.giornoDiNascita, _suo.giornoDiNascita,
          adesso: _oggi);

  final GlobalKey _chiaveDellaCard = GlobalKey();
  bool _cardInScena = false;

  // Il calcolo non dipende dal legame (FT.06: "il legame cambia la lettura,
  // non il calcolo"): si fa una volta sola, quando la coppia e' nota (la
  // persona si sceglie una volta per apertura, FY.11).
  late final IlComposito _composito = IlComposito.fra(widget.cieloTuo, _suo);
  late final List<Corda> _corde =
      IntervalliDiKeplero.fra(widget.cieloTuo, _suo);
  late final OggiFraVoi _oggiFraVoi = OggiFraVoi.per(
      tuo: widget.cieloTuo,
      suo: _suo,
      nomeSuo: _nome,
      giorno: _oggi,
      corpus: corpusDellaSinastriaEvolutiva);

  List<CapitoloLetto> get _capitoli => LetturaEvolutiva.componi(
      tuo: widget.cieloTuo,
      suo: _suo,
      nomeSuo: _nome,
      legame: _legame,
      corpus: corpusDellaSinastriaEvolutiva);

  /// Il segno della relazione: quello del Sole composito.
  String get _coppia =>
      ArtworkDelRicordo.percorsoDellaCoppia(IlSegnoDelCielo.dellaLongitudine(
          _composito.punti[PuntoDelCieloEvolutivo.sole]!));

  String get _segnoDellaCoppia => IlSegnoDelCielo.dellaLongitudine(
          _composito.punti[PuntoDelCieloEvolutivo.sole]!)
      .italianName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // **"ALLEGGERISCI GRAFICA" FERMA LA SCENA**, ordine FT voce FT.02: con
    // la grafica alleggerita, come con Riduci Movimento, il filmato non si
    // apre e Medora resta ferma, a mani aperte. Stessa lettura del tier dei
    // Tarocchi (ordine FN).
    final tierBasso =
        _forse<QualityTierController>(context, osserva: true)?.tier ==
            QualityTier.low;
    _reduceMotion = MediaQuery.of(context).disableAnimations || tierBasso;
    if (_avviata) return;
    _avviata = true;
    WidgetsBinding.instance.addObserver(this);
    unawaited(_apriIlFilmato());
    if (_coppiaNota) _nelCammino();
  }

  /// LA SINASTRIA EVOLUTIVA ENTRA NEL CAMMINO, col suo gesto: quando la
  /// coppia e' nota, dalla rotta o dalla scelta qui sotto la scena.
  void _nelCammino() {
    unawaited(RegiaDelCammino.dopoUnGesto(
      context,
      'sinastria_evolutiva',
      dettagli: {'con': _nome},
    ));
  }

  /// **LA SCELTA DELLA PERSONA**, ordine FY voce FY.11: la nascita
  /// dell'altra persona si apre sopra la scena, e la lettura torna qui.
  Future<void> _scegliLaPersona() async {
    final chiedi = widget.chiediLaPersona;
    if (chiedi == null || _scegliendo || _coppiaNota) return;
    setState(() => _scegliendo = true);
    final persona = await chiedi(context);
    if (!mounted) return;
    setState(() {
      _scegliendo = false;
      if (persona == null) return;
      _nomeSuo = persona.nome;
      _cieloSuo = persona.cielo;
      _amoreDalServer = persona.amoreDalServer;
    });
    if (persona != null) _nelCammino();
  }

  void _scade() {
    if (!mounted || _scaduta) return;
    final l = _lettore;
    if (l == null || l.fallito || l.finito || _filmatoSaltato) return;
    if (l.cominciato) return;
    debugPrint('La scena della Sinastria non parte entro '
        '${RegiaDellaScena.attesaMassima}, resta ferma');
    setState(() => _scaduta = true);
    unawaited(l.sospendi());
  }

  Future<void> _apriIlFilmato() async {
    if (_reduceMotion) return;
    final lettore =
        (widget.fabbricaDellaScena ?? LettoreDellaScenaSinastria.vero)();
    _lettore = lettore;
    lettore.ascolta(() {
      if (mounted) setState(() {});
    });
    // Se in questo tempo il video non e' ne' pronto ne' cominciato, la scena
    // e' ferma: vale per l'apertura che non risponde e per il video pronto
    // che non parte.
    _attesaDelVideo = Timer(RegiaDellaScena.attesaMassima, _scade);
    await lettore.apri();
    if (!mounted || !identical(_lettore, lettore) || !lettore.pronto) return;
    if (_scaduta) return;
    final suono =
        _forse<SettingsController>(context)?.suonoEVibrazione ?? false;
    final muto = !suono || await LaSuoneria.spenta();
    if (!mounted) return;
    await lettore.volume(muto ? 0 : 1);
    if (!mounted || !identical(_lettore, lettore) || _scaduta) return;
    // Un video che parte e si blocca prima della fine sfuma come col tocco.
    _attesaDellaFine = Timer(
        ScenaDellaSinastriaInVideo.durata + RegiaDellaScena.attesaMassima, () {
      if (!mounted) return;
      final l = _lettore;
      if (l == null || l.finito || l.fallito || _filmatoSaltato) return;
      if (!l.cominciato) {
        _scade();
        return;
      }
      debugPrint('La scena della Sinastria non arriva in fondo, sfuma');
      _saltaIlVideo();
    });
    _attesaDelVideo?.cancel();
    _attesaDelVideo = Timer(RegiaDellaScena.attesaMassima, _scade);
    await lettore.avvia();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final lettore = _lettore;
    if (lettore == null ||
        !lettore.pronto ||
        lettore.finito ||
        _filmatoSaltato ||
        _scaduta) {
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

  /// **LA SCENA E' FERMA**, ordine FX voce FXA.08: il video non c'e', non
  /// si e' caricato, e' finito o e' stato saltato. Finche' e' falso, sopra
  /// lo studio si vede solo il video ([IlRestoDopoLaScena]).
  bool get _scenaFerma {
    final l = _lettore;
    return l == null || l.fallito || l.finito || _filmatoSaltato || _scaduta;
  }

  Widget? get _filmatoInScena {
    final l = _lettore;
    if (l == null || l.fallito || _scaduta || !l.cominciato) return null;
    return l.disegna();
  }

  String get _posaDiMedora {
    final l = _lettore;
    return l == null || l.fallito || _filmatoSaltato || _scaduta
        ? GeometriaDelloStudio.posaDelleManiAperte
        : GeometriaDelloStudio.posaDellAstrolabio;
  }

  /// Un provider che puo' mancare (le prove montano la schermata da sola):
  /// senza, si va avanti col ripiego, come nella Stesa.
  T? _forse<T>(BuildContext context, {bool osserva = false}) {
    try {
      return osserva ? context.watch<T>() : context.read<T>();
    } catch (senzaProvider) {
      debugPrint('Sinastria evolutiva: manca $T, ripiego ($senzaProvider)');
      return null;
    }
  }

  @override
  void dispose() {
    _attesaDelVideo?.cancel();
    _attesaDellaFine?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _lettore?.chiudi();
    super.dispose();
  }

  void _scegliIlLegame(Legame l) {
    if (l == Legame.amore && !_amoreApribile) {
      // **UNA RIGA SOBRIA, senza spiegazioni sull'eta' dell'altra
      // persona** (FT.04).
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          key: Key('sinastria_amore_chiuso'),
          content: Text('Il legame amore si apre dai sedici anni.')));
      return;
    }
    setState(() => _legameScelto = l);
  }

  Future<void> _invito(String cosa, bool Function(Tier) apre) {
    final dal = PlanCatalog.dalPiano(apre) ?? 'Dal piano superiore';
    return showUpgradeInvite(
      context,
      title: '$cosa si apre ${dal[0].toLowerCase()}${dal.substring(1)}',
      message: 'Nel Cerchio la Sinastria evolutiva si legge per intero: '
          'tutti i capitoli, gli intervalli di Keplero, il cielo comune '
          'della vostra relazione, i giorni giusti e il ritratto da '
          'condividere.',
    );
  }

  Future<bool> _condividi(Tier tier, List<CapitoloLetto> capitoli) async {
    setState(() => _cardInScena = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      return await shareSinastriaEvolutivaCard(
        boundaryKey: _chiaveDellaCard,
        testo: 'La nostra sinastria evolutiva, su Esoteric Circle.',
      );
    } catch (errore) {
      debugPrint('La card della Sinastria evolutiva non parte: $errore');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Non riesco a preparare la card ora.')));
      }
      return false;
    } finally {
      if (mounted) setState(() => _cardInScena = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final tier =
        _forse<EntitlementService>(context, osserva: true)?.tier ?? Tier.free;
    // Senza l'altra persona non c'e' ancora una lettura: la scena e, sotto,
    // la scelta (FY.11).
    final coppia = _coppiaNota;
    final capitoli = coppia ? _capitoli : const <CapitoloLetto>[];
    final tuttiICapitoli =
        PlanCatalog.apre(RigaDelPiano.capitoliDellaSinastria, tier);
    final keplero = PlanCatalog.apre(RigaDelPiano.intervalliDiKeplero, tier);
    final adepto =
        PlanCatalog.apre(RigaDelPiano.compositoRitrattoMomento, tier);
    final perIlDiario = !coppia
        ? null
        : ResponsoDaCustodire(
            arte: 'sinastria_evolutiva',
            titolo: 'Con $_nome,${_legame.nome.toLowerCase()}',
            testo: capitoli.first.titolo,
            perIlMaestro: [
              for (final c in capitoli) '${c.capitolo.nome}: ${c.titolo}',
            ].join('\n'),
            dati: {
              'coppia': _segnoDellaCoppia,
              'con': _nome,
              'legame': _legame.name,
            },
          );
    // IL TOCCO CHE SALTA IL VIDEO, ordine FU voce FU.15, punto unico.
    return IlToccoCheSalta(
      inCorso: _videoInCorso,
      onSalta: _saltaIlVideo,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          // **LA BARRA RESTA SEMITRASPARENTE, SEMPRE.** Ordine FY voce
          // FY.20, il fondatore: *"Quando scorro in alto, la barra del titolo
          // compare solida di botto e non piu' trasparente"*. Qui il velo
          // passava da 0,16 a 0,9 appena il testo scorreva sotto il titolo
          // (ordine FT, anteprima ft_viandante_2): adesso e' uno solo, in ogni
          // stato, e il titolo resta leggibile sul velo.
          backgroundColor: palette.deepest
              .withValues(alpha: SinastriaEvolutivaScreen.veloDellaBarra),
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          iconTheme: IconThemeData(color: palette.goldSoft),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Indietro',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: TitoloCheNonSiRompe(
              chiaveDelTesto: const Key('sinastria_evolutiva_titolo'),
              testo: 'Sinastria evolutiva',
              righe: 1,
              stile: TypographyTokens.titoloSezione()),
          // Le fonti di tutta la lettura in un foglio solo, come nelle altre
          // arti (guardia `ogni_arte_dichiara_la_fonte`); ogni capitolo porta
          // anche il suo Da dove viene.
          actions: [
            FoglioDelleFonti.bottone(context,
                palette: palette,
                testo: TestiDelleFonti.sinastriaEvolutiva,
                chiave: 'sinastria_evolutiva_fonti'),
            // Lo spazio del cuore della soglia unica: nessuna azione ci
            // finisce sotto (guardia `il_cuore_e_il_tooltip_non_si_toccano`).
            const AngoloDellaBarra(),
          ],
        ),
        body: CosmosBackground(
          key: const Key('sinastria_evolutiva_sfondo'),
          seed: 7,
          showZodiac: false,
          child: SafeArea(
            top: false,
            child: Stack(
              children: [
                ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Il responso entra nel Diario da se', in cima all'elenco
                    // pigro (ordine FE voce 22.6).
                    if (perIlDiario != null)
                      IlResponsoNelDiario(
                        maestro: Maestro.medora,
                        responso: perIlDiario,
                        quando: _quando,
                      ),
                    // **LA SCENA PARTE DAL BORDO ALTO E PASSA SOTTO LA
                    // BARRA**, ordine GC voce GC.02, 22 ottobre 2026: il
                    // fondatore, sulla Stesa, *"La barra in alto del titolo
                    // deve essere semitrasparente in modo da fare vedere il
                    // video animazione sotto"*, regola permanente R12. LAPIDE:
                    // la scena cominciava sotto la barra (un margine alto
                    // quanto la barra di stato e la barra del titolo) e la
                    // barra copriva solo il cosmo. In cima allo studio c'e'
                    // l'arco della finestra: la testa di Medora comincia al
                    // pixel 403 dell'immagine, a 360 punti circa cinquanta
                    // punti sotto la barra, intera.
                    LoStudioDiMedora(
                      key: const Key('sinastria_evolutiva_scena'),
                      posa: _posaDiMedora,
                      filmato: _filmatoInScena,
                      filmatoSaltato: _filmatoSaltato,
                    ),
                    // **SOPRA IL VIDEO SOLO IL VIDEO**, ordine FX voce
                    // FXA.08: la coppia, i legami e i capitoli aspettano la
                    // scena ferma e compaiono in dissolvenza.
                    IlRestoDopoLaScena(
                      scenaFerma: _scenaFerma,
                      child: Padding(
                        padding: const EdgeInsets.all(SpacingTokens.md),
                        // Senza l'altra persona sotto la scena non c'e'
                        // niente: la scelta sta in fondo allo schermo, qui
                        // sotto nella pila.
                        child: !coppia
                            ? const SizedBox.shrink()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _LaCoppia(
                                    palette: palette,
                                    coppia: _coppia,
                                    nomeSuo: _nome,
                                    segno: _segnoDellaCoppia,
                                  ),
                                  if (_laLunaTace != null) ...[
                                    const SizedBox(height: SpacingTokens.sm),
                                    Text(_laLunaTace!,
                                        key:
                                            const Key('sinastria_ora_non_nota'),
                                        textAlign: TextAlign.center,
                                        style: TypographyTokens.didascalia()
                                            .copyWith(
                                                color:
                                                    ColorTokens.textSecondary,
                                                fontStyle: FontStyle.italic)),
                                  ],
                                  const SizedBox(height: SpacingTokens.md),
                                  _ILegami(
                                    palette: palette,
                                    scelto: _legame,
                                    amoreApribile: _amoreApribile,
                                    onScegli: _scegliIlLegame,
                                  ),
                                  const SizedBox(height: SpacingTokens.lg),
                                  _OggiFraVoiCard(
                                      palette: palette, oggi: _oggiFraVoi),
                                  const SizedBox(height: SpacingTokens.lg),
                                  for (var i = 0; i < capitoli.length; i++) ...[
                                    if (tuttiICapitoli || i < 2)
                                      _IlCapitolo(
                                          palette: palette,
                                          capitolo: capitoli[i])
                                    else
                                      _Chiuso(
                                        chiave:
                                            'capitolo_${capitoli[i].capitolo.name}',
                                        palette: palette,
                                        immagine:
                                            capitoli[i].capitolo.medaglione,
                                        titolo: capitoli[i].capitolo.nome,
                                        onApri: () => _invito(
                                            'Il capitolo ${capitoli[i].capitolo.nome.toLowerCase()}',
                                            (t) => PlanCatalog.apre(
                                                RigaDelPiano
                                                    .capitoliDellaSinastria,
                                                t)),
                                      ),
                                    const SizedBox(height: SpacingTokens.lg),
                                  ],
                                  if (keplero)
                                    _Keplero(
                                        palette: palette,
                                        corde: _corde,
                                        nomeSuo: _nome)
                                  else
                                    _Chiuso(
                                      chiave: 'keplero',
                                      palette: palette,
                                      immagine: 'aspetto_trigono_v1',
                                      titolo: 'Gli intervalli di Keplero',
                                      onApri: () => _invito(
                                          'Gli intervalli di Keplero',
                                          (t) => PlanCatalog.apre(
                                              RigaDelPiano.intervalliDiKeplero,
                                              t)),
                                    ),
                                  const SizedBox(height: SpacingTokens.lg),
                                  if (adepto) ...[
                                    _IlComposito(
                                        palette: palette,
                                        composito: _composito),
                                    const SizedBox(height: SpacingTokens.lg),
                                    _IlMomentoGiusto(
                                      palette: palette,
                                      giorni: IlMomentoGiusto.per(
                                          tuo: widget.cieloTuo,
                                          suo: _suo,
                                          nomeSuo: _nome,
                                          legame: _legame,
                                          da: _oggi,
                                          corpus:
                                              corpusDellaSinastriaEvolutiva),
                                      senzaGiorni:
                                          IlMomentoGiusto.testoSenzaGiorni(
                                              tuo: widget.cieloTuo,
                                              suo: _suo,
                                              nomeSuo: _nome,
                                              legame: _legame,
                                              corpus:
                                                  corpusDellaSinastriaEvolutiva),
                                      oggi: _oggi,
                                    ),
                                  ] else
                                    _Chiuso(
                                      chiave: 'adepto',
                                      palette: palette,
                                      immagine: 'legame_amore_v1',
                                      titolo:
                                          'Il cielo comune, il momento giusto e '
                                          'il ritratto della coppia',
                                      onApri: () => _invito(
                                          'Il cielo comune della relazione',
                                          (t) => PlanCatalog.apre(
                                              RigaDelPiano
                                                  .compositoRitrattoMomento,
                                              t)),
                                    ),
                                  const SizedBox(height: SpacingTokens.lg),
                                  AzioniDelResponso(
                                    palette: palette,
                                    maestro: Maestro.medora,
                                    dorato: true,
                                    responso: perIlDiario!,
                                    quando: _quando,
                                    condividi: () => _condividi(tier, capitoli),
                                    aperturaDellaChat:
                                        ChatOpeners.sinastriaEvolutiva(
                                            _nome,
                                            _legame.nome.toLowerCase(),
                                            capitoli.first.titolo),
                                  ),
                                  const SizedBox(height: SpacingTokens.xl),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
                // La card condivisibile, disegnata fuori campo solo durante lo
                // scatto: il ritratto per l'Adepto, il primo capitolo per gli
                // altri piani (FT.14).
                // **LA SCELTA DELLA PERSONA, IN FONDO ALLO SCHERMO**, ordine
                // FY voce FY.11: sulla scena ferma, sul pavimento dello studio
                // sotto Medora, e sempre dentro la prima schermata. Messa
                // sotto lo studio nell'elenco, a 360 per 797 il pulsante
                // stava sotto la piega, e la prima schermata tornava a essere
                // una scena senza un gesto. Anche lei aspetta la scena ferma
                // (FXA.08).
                if (!coppia)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: IlRestoDopoLaScena(
                      scenaFerma: _scenaFerma,
                      child: _LaSceltaDellaPersona(
                        scegliendo: _scegliendo,
                        onScegli: widget.chiediLaPersona == null
                            ? null
                            : _scegliLaPersona,
                      ),
                    ),
                  ),
                if (_cardInScena)
                  Positioned(
                    left: -3000,
                    top: 0,
                    child: RepaintBoundary(
                      key: _chiaveDellaCard,
                      child: adepto
                          ? RitrattoDellaCoppia(
                              palette: palette,
                              nomeSuo: _nome,
                              legame: _legame,
                              coppia: _coppia,
                              sintesi: _titoloDelComposito(),
                              capitoli: capitoli,
                            )
                          : CardDelCapitolo(
                              palette: palette,
                              nomeSuo: _nome,
                              legame: _legame,
                              capitolo: capitoli.first,
                            ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _titoloDelComposito() {
    final v =
        corpusDellaSinastriaEvolutiva['composito|${_composito.cella}|titolo']!;
    return v[
        LetturaEvolutiva.semeDellaCoppia(widget.cieloTuo, _suo) % v.length];
  }
}

/// **LA SCELTA DELLA PERSONA, SOTTO LA SCENA.** Ordine FY voce FY.11: la
/// prima cosa sotto lo studio di Medora, quando l'altra persona non e' ancora
/// nota. Dice dove sei, che cosa fare e che cosa ottieni; il gesto apre la
/// nascita dell'altra persona, a mano o col codice del suo telefono (FT.03,
/// e per la Sinastria resta, FY.14). Il pulsante e' il pezzo dipinto del
/// ramo (R8 dell'ordine FY, come FXA.02); il testo sta sul velo che sale dal
/// fondo, e non su un pannello, perche' il pannello dipinto, con la sua falce
/// e le sue cornici, era alto 263 punti e a 390 per 844 copriva Medora.
class _LaSceltaDellaPersona extends StatelessWidget {
  const _LaSceltaDellaPersona(
      {required this.scegliendo, required this.onScegli});

  final bool scegliendo;
  final VoidCallback? onScegli;

  @override
  Widget build(BuildContext context) {
    // Il velo sale dal fondo dello schermo e si spegne verso Medora: il
    // testo si legge sul pavimento dello studio senza un riquadro che la
    // copra.
    // L'ombra comune dell'app (ordine GA voce GA.10).
    const ombra = TypographyTokens.ombraDelTesto;
    return DecoratedBox(
      key: const Key('sinastria_la_scelta'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            ColorTokens.medoraDeepest.withValues(alpha: 0.9),
            ColorTokens.medoraDeepest.withValues(alpha: 0.7),
            ColorTokens.medoraDeepest.withValues(alpha: 0),
          ],
          stops: const [0, 0.6, 1],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.xl,
            SpacingTokens.lg, SpacingTokens.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Con chi leggo il tuo cielo?',
                key: const Key('sinastria_la_scelta_titolo'),
                textAlign: TextAlign.center,
                style: TypographyTokens.titoloScheda()
                    .copyWith(color: coloreSulVelluto, shadows: ombra)),
            const SizedBox(height: SpacingTokens.xxs),
            Text(
                'Scrivi la sua nascita o leggila dal suo telefono: leggo i '
                'vostri due cieli.',
                textAlign: TextAlign.center,
                style: TypographyTokens.didascalia().copyWith(
                    color: coloreSulVelluto.withValues(alpha: 0.9),
                    shadows: ombra)),
            const SizedBox(height: SpacingTokens.sm),
            PulsanteDipinto(
              key: const Key('sinastria_scegli_la_persona'),
              testo: scegliendo ? 'Un momento' : 'Scegli la persona',
              larghezzaPiena: true,
              onTap: scegliendo ? null : onScegli,
            ),
          ],
        ),
      ),
    );
  }
}

/// La coppia del segno della relazione, in cima: il primo colpo d'occhio.
class _LaCoppia extends StatelessWidget {
  const _LaCoppia({
    required this.palette,
    required this.coppia,
    required this.nomeSuo,
    required this.segno,
  });

  final MaestroPalette palette;
  final String coppia;
  final String nomeSuo;
  final String segno;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
          child: Image.asset(coppia,
              key: const Key('sinastria_evolutiva_coppia'),
              width: 96,
              height: 128,
              fit: BoxFit.cover),
        ),
        const SizedBox(width: SpacingTokens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tu e $nomeSuo',
                  key: const Key('sinastria_evolutiva_nomi'),
                  style: TypographyTokens.titoloSezione()
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: SpacingTokens.xxs),
              Text('Il segno della vostra relazione è $segno.',
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

/// I quattro legami, coi loro medaglioni. L'amore chiuso dallo sbarramento
/// d'eta' resta visibile, velato, e al tocco dice una riga sobria.
class _ILegami extends StatelessWidget {
  const _ILegami({
    required this.palette,
    required this.scelto,
    required this.amoreApribile,
    required this.onScegli,
  });

  final MaestroPalette palette;
  final Legame scelto;
  final bool amoreApribile;
  final ValueChanged<Legame> onScegli;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final l in Legame.values)
          Expanded(
            child: GestureDetector(
              key: Key('sinastria_legame_${l.name}'),
              behavior: HitTestBehavior.opaque,
              onTap: () => onScegli(l),
              child: Opacity(
                opacity: l == Legame.amore && !amoreApribile ? 0.4 : 1,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color:
                                l == scelto ? palette.gold : Colors.transparent,
                            width: 2),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                            immagineDellaSinastria('legame_${l.name}_v1'),
                            width: 56,
                            height: 56),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xxs),
                    Text(l.nome,
                        style: TypographyTokens.etichetta().copyWith(
                            color: l == scelto
                                ? palette.goldSoft
                                : ColorTokens.textSecondary)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Un medaglione rotondo.
class _Medaglione extends StatelessWidget {
  const _Medaglione(this.nome, {this.lato = 64});
  final String nome;
  final double lato;

  @override
  Widget build(BuildContext context) => ClipOval(
        child: Image.asset(immagineDellaSinastria(nome),
            width: lato, height: lato),
      );
}

class _OggiFraVoiCard extends StatelessWidget {
  const _OggiFraVoiCard({required this.palette, required this.oggi});
  final MaestroPalette palette;
  final OggiFraVoi oggi;

  @override
  Widget build(BuildContext context) {
    final capitolo = oggi.capitolo;
    return Container(
      key: const Key('sinastria_oggi_fra_voi'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        color: palette.primary.withValues(alpha: 0.35),
        border: Border.all(color: palette.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              if (capitolo != null) _Medaglione(capitolo.medaglione, lato: 52),
              if (oggi.transito != null) ...[
                const SizedBox(height: SpacingTokens.xxs),
                _GlifoDelPianeta(oggi.transito!,
                    lato: 26, colore: palette.goldSoft),
              ],
            ],
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Oggi fra voi',
                    style: TypographyTokens.titoloScheda()
                        .copyWith(color: palette.goldSoft)),
                const SizedBox(height: SpacingTokens.xxs),
                ParagrafiDiLettura(
                    testo: oggi.testo,
                    stile: TypographyTokens.lettura()
                        .copyWith(color: ColorTokens.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Un capitolo nel formato di casa: medaglioni, titolo, tre paragrafi col
/// secondo nel riquadro, "Da dove viene".
class _IlCapitolo extends StatelessWidget {
  const _IlCapitolo({required this.palette, required this.capitolo});
  final MaestroPalette palette;
  final CapitoloLetto capitolo;

  @override
  Widget build(BuildContext context) {
    final aspetto = capitolo.aspetto;
    return Column(
      key: Key('sinastria_capitolo_${capitolo.capitolo.name}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Medaglione(capitolo.capitolo.medaglione),
            if (aspetto != null) ...[
              const SizedBox(width: SpacingTokens.sm),
              _Medaglione('aspetto_${aspettoNelCorpus(aspetto.tipo)}_v1',
                  lato: 44),
            ],
          ],
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(capitolo.capitolo.nome.toUpperCase(),
            textAlign: TextAlign.center,
            style: TypographyTokens.etichetta()
                .copyWith(color: palette.goldSoft, letterSpacing: 2.0)),
        const SizedBox(height: SpacingTokens.xxs),
        TitoloDelResponso(
          chiaveDelTesto: Key('sinastria_titolo_${capitolo.capitolo.name}'),
          testo: capitolo.titolo,
          allineamento: TextAlign.center,
          aCapoFraLeParole: true,
          stile: TypographyTokens.titoloSezione()
              .copyWith(color: palette.goldSoft, height: 1.25),
        ),
        const SizedBox(height: SpacingTokens.sm),
        ResponsoInTreParagrafi(
          paragrafi: capitolo.paragrafi,
          daDoveViene: capitolo.daDoveViene,
          palette: palette,
          stile: TypographyTokens.lettura()
              .copyWith(color: ColorTokens.textPrimary),
        ),
      ],
    );
  }
}

/// Cio' che il piano non apre: visibile, velato, col lucchetto e l'invito.
class _Chiuso extends StatelessWidget {
  const _Chiuso({
    required this.chiave,
    required this.palette,
    required this.immagine,
    required this.titolo,
    required this.onApri,
  });

  final String chiave;
  final MaestroPalette palette;
  final String immagine;
  final String titolo;
  final VoidCallback onApri;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('sinastria_chiuso_$chiave'),
      onTap: onApri,
      enableFeedback: false,
      borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(SpacingTokens.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
          border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Opacity(opacity: 0.45, child: _Medaglione(immagine, lato: 52)),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Text(titolo,
                  style: TypographyTokens.titoloScheda()
                      .copyWith(color: ColorTokens.textSecondary)),
            ),
            Icon(Icons.lock_rounded, color: palette.goldSoft),
          ],
        ),
      ),
    );
  }
}

/// Le quattro corde di Keplero: prima la figura (l'arco maggiore sul cerchio
/// intero, come una corda divisa), poi il nome della consonanza e il testo.
class _Keplero extends StatelessWidget {
  const _Keplero(
      {required this.palette, required this.corde, required this.nomeSuo});
  final MaestroPalette palette;
  final List<Corda> corde;
  final String nomeSuo;

  String _chi(Corda c) {
    if (c.tuo == c.suo) {
      return c.tuo == PuntoDelCieloEvolutivo.sole
          ? 'I due Soli'
          : 'Le due Lune';
    }
    return '${c.tuo.ilTuo[0].toUpperCase()}${c.tuo.ilTuo.substring(1)} '
        '${c.tuo.nome} e ${c.suo.femminile ? "la" : "il"} ${c.suo.nome} '
        'di $nomeSuo';
  }

  /// **UN TESTO NON SI RIPETE A DUE RIGHE DI DISTANZA.** Con l'orbo di due
  /// gradi molte coppie cadono fuori da ogni consonanza su piu' di una corda,
  /// e il testo della "nessuna" usciva identico due volte di fila (anteprima
  /// ft_adepto_1, 14 ottobre 2026). Adesso: una corda con la sua consonanza
  /// porta il suo testo, e due corde sulla stessa consonanza prendono
  /// varianti diverse; le corde senza consonanza portano solo il nome e la
  /// corda, e il testo della "nessuna" si dice una volta sola, in fondo.
  List<String?> _testi() {
    final viste = <String, int>{};
    return [
      for (final c in corde)
        if (c.consonanza == null)
          null
        else
          (() {
            final v = corpusDellaSinastriaEvolutiva[
                'keplero_oggi_momento|keplero ${c.cella}|testo']!;
            final n = viste.update(c.cella, (x) => x + 1, ifAbsent: () => 0);
            return v[n % v.length].replaceAll('{nome}', nomeSuo);
          })(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final testi = _testi();
    final senza = corde.where((c) => c.consonanza == null).toList();
    return Column(
      key: const Key('sinastria_keplero'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('LE CONSONANZE DI KEPLERO',
            textAlign: TextAlign.center,
            style: TypographyTokens.etichetta()
                .copyWith(color: palette.goldSoft, letterSpacing: 2.0)),
        const SizedBox(height: SpacingTokens.sm),
        for (var i = 0; i < corde.length; i++) ...[
          Text(_chi(corde[i]),
              style: TypographyTokens.titoloScheda()
                  .copyWith(color: ColorTokens.textPrimary)),
          const SizedBox(height: SpacingTokens.xxs),
          _LaCorda(palette: palette, corda: corde[i]),
          const SizedBox(height: SpacingTokens.xxs),
          Text(
              corde[i].consonanza == null
                  ? 'Nessuna consonanza'
                  : '${corde[i].consonanza!.nome}, '
                      '${corde[i].consonanza!.rapporto}',
              style: TypographyTokens.etichetta()
                  .copyWith(color: palette.goldSoft)),
          if (testi[i] != null) ...[
            const SizedBox(height: SpacingTokens.xxs),
            ParagrafiDiLettura(
                testo: testi[i]!,
                stile: TypographyTokens.lettura()
                    .copyWith(color: ColorTokens.textPrimary)),
          ],
          const SizedBox(height: SpacingTokens.md),
        ],
        if (senza.isNotEmpty) ...[
          ParagrafiDiLettura(
              key: const Key('sinastria_keplero_nessuna'),
              testo: corpusDellaSinastriaEvolutiva[
                      'keplero_oggi_momento|keplero ${senza.first.cella}|testo']!
                  .first
                  .replaceAll('{nome}', nomeSuo),
              stile: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textPrimary)),
          const SizedBox(height: SpacingTokens.md),
        ],
        Text(IntervalliDiKeplero.daDoveViene,
            style: TypographyTokens.didascalia().copyWith(
                color: ColorTokens.textSecondary, fontStyle: FontStyle.italic)),
      ],
    );
  }
}

/// La corda divisa: l'arco minore e l'arco maggiore del cerchio, in
/// proporzione, come la corda divisa di Keplero.
class _LaCorda extends StatelessWidget {
  const _LaCorda({required this.palette, required this.corda});
  final MaestroPalette palette;
  final Corda corda;

  @override
  Widget build(BuildContext context) {
    final minore = (corda.separazione / 360).clamp(0.02, 0.5);
    return SizedBox(
      height: SpacingTokens.xs,
      child: Row(
        children: [
          Expanded(
            flex: (minore * 1000).round(),
            child: Container(
              decoration: BoxDecoration(
                color: palette.goldSoft,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          const SizedBox(width: 3),
          Expanded(
            flex: ((1 - minore) * 1000).round(),
            child: Container(
              decoration: BoxDecoration(
                color: palette.primary,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: palette.gold.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IlComposito extends StatelessWidget {
  const _IlComposito({required this.palette, required this.composito});
  final MaestroPalette palette;
  final IlComposito composito;

  @override
  Widget build(BuildContext context) {
    final cella = composito.cella;
    String scegli(String campo) {
      final v = corpusDellaSinastriaEvolutiva['composito|$cella|$campo']!;
      return v.first;
    }

    final a = composito.aspetto;
    return Column(
      key: const Key('sinastria_composito'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('IL CIELO COMUNE',
            textAlign: TextAlign.center,
            style: TypographyTokens.etichetta()
                .copyWith(color: palette.goldSoft, letterSpacing: 2.0)),
        const SizedBox(height: SpacingTokens.xs),
        if (a != null)
          Center(
              child: _Medaglione('aspetto_${aspettoNelCorpus(a.tipo)}_v1',
                  lato: 56)),
        const SizedBox(height: SpacingTokens.xs),
        TitoloDelResponso(
          chiaveDelTesto: const Key('sinastria_titolo_composito'),
          testo: scegli('titolo'),
          allineamento: TextAlign.center,
          aCapoFraLeParole: true,
          stile: TypographyTokens.titoloSezione()
              .copyWith(color: palette.goldSoft, height: 1.25),
        ),
        const SizedBox(height: SpacingTokens.sm),
        ParagrafiDiLettura(
            testo: scegli('testo'),
            stile: TypographyTokens.lettura()
                .copyWith(color: ColorTokens.textPrimary)),
        const SizedBox(height: SpacingTokens.sm),
        Text(
            a == null
                ? IlComposito.daDoveViene
                : 'Nel vostro cielo comune ${a.a.nome} e ${a.b.nome} sono in '
                    '${a.tipo.italianName.toLowerCase()}. '
                    '${IlComposito.daDoveViene}',
            style: TypographyTokens.didascalia().copyWith(
                color: ColorTokens.textSecondary, fontStyle: FontStyle.italic)),
      ],
    );
  }
}

class _IlMomentoGiusto extends StatelessWidget {
  const _IlMomentoGiusto({
    required this.palette,
    required this.giorni,
    required this.senzaGiorni,
    required this.oggi,
  });

  final MaestroPalette palette;
  final List<GiornoFavorevole> giorni;
  final String senzaGiorni;
  final DateTime oggi;

  static const _mesi = [
    'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno', //
    'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('sinastria_momento_giusto'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('IL MOMENTO GIUSTO',
            textAlign: TextAlign.center,
            style: TypographyTokens.etichetta()
                .copyWith(color: palette.goldSoft, letterSpacing: 2.0)),
        const SizedBox(height: SpacingTokens.sm),
        if (giorni.isEmpty)
          ParagrafiDiLettura(
              testo: senzaGiorni,
              stile: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textPrimary))
        else
          for (final g in giorni) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // **UNA COLONNA SOLA PER LE DATE**, larga quanto il mese piu'
                // lungo: col mese a misura propria il testo accanto partiva
                // piu' a destra a novembre che a dicembre (anteprima
                // ft_adepto_3, 14 ottobre 2026). SETTEMBRE, il piu' lungo,
                // si stringe invece di allargare la colonna.
                SizedBox(
                  width: SpacingTokens.xxl + SpacingTokens.xxl,
                  child: Column(
                    children: [
                      Text('${g.giorno.day}',
                          style: TypographyTokens.titoloSezione()
                              .copyWith(color: palette.goldSoft)),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(_mesi[g.giorno.month - 1],
                            maxLines: 1,
                            style: TypographyTokens.etichetta()
                                .copyWith(color: ColorTokens.textSecondary)),
                      ),
                      _GlifoDelPianeta(g.transito,
                          lato: 20, colore: palette.goldSoft),
                    ],
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: ParagrafiDiLettura(
                      testo: g.testo,
                      stile: TypographyTokens.lettura()
                          .copyWith(color: ColorTokens.textPrimary)),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.md),
          ],
        Text(IlMomentoGiusto.daDoveViene,
            style: TypographyTokens.didascalia().copyWith(
                color: ColorTokens.textSecondary, fontStyle: FontStyle.italic)),
      ],
    );
  }
}

/// **IL GLIFO DEL PIANETA DI PASSAGGIO.** Nel carattere dei simboli del
/// Cerchio (`NotoSansSymbols`, sottoinsieme): Cinzel e Garamond non portano
/// i glifi dei pianeti e a schermo usciva un quadratino vuoto (anteprima
/// ft_viandante_2, 14 ottobre 2026). Il Sole non e' nel sottoinsieme, e si
/// disegna come nella ruota natale: un cerchio col punto al centro.
class _GlifoDelPianeta extends StatelessWidget {
  const _GlifoDelPianeta(this.corpo,
      {required this.lato, required this.colore});
  final CorpoCeleste corpo;
  final double lato;
  final Color colore;

  @override
  Widget build(BuildContext context) {
    if (corpo == CorpoCeleste.sole) {
      return SizedBox.square(
        dimension: lato,
        child: CustomPaint(painter: _IlSoleDisegnato(colore)),
      );
    }
    return Text(corpo.glifo,
        textScaler: TextScaler.noScaling,
        style: TextStyle(
            fontFamily: 'NotoSansSymbols',
            fontSize: lato,
            height: 1,
            color: colore));
  }
}

class _IlSoleDisegnato extends CustomPainter {
  _IlSoleDisegnato(this.colore);
  final Color colore;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final r = size.shortestSide * 0.4;
    canvas.drawCircle(
        centro,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.shortestSide * 0.08
          ..color = colore);
    canvas.drawCircle(centro, r * 0.22, Paint()..color = colore);
  }

  @override
  bool shouldRepaint(_IlSoleDisegnato vecchio) => vecchio.colore != colore;
}

import 'dart:async';

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
import '../../core/synastry_approfondita/cielo_approfondito.dart';
import '../../core/synastry_approfondita/il_composito_e_keplero.dart';
import '../../core/synastry_approfondita/il_corpus_della_sinastria_approfondita.g.dart';
import '../../core/synastry_approfondita/la_lettura_approfondita.dart';
import '../../core/synastry_approfondita/legame_e_eta.dart';
import '../../core/synastry_approfondita/oggi_e_il_momento.dart';
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
import '../pricing/upgrade_invite.dart';
import '../ricordi/azioni_del_responso.dart';
import '../sigilli/regia_del_cammino.dart';
import 'il_ritratto_della_coppia.dart';
import 'lo_studio_di_medora.dart';

/// **LA SINASTRIA APPROFONDITA.** Ordine FT, 14 ottobre 2026.
///
/// La scena (FT.02), il legame con lo sbarramento d'eta' (FT.04), Oggi fra
/// voi (FT.09), i cinque capitoli nel formato di casa (FT.06), gli intervalli
/// di Keplero (FT.08) e le tre esclusive dell'Adepto (FT.07 Composito, FT.10
/// Momento giusto, FT.11 Ritratto). **Livello visivo prima del testo**: ogni
/// parte comincia col suo medaglione o la sua figura. **Mai un vicolo
/// cieco**: cio' che il piano non apre resta visibile, col lucchetto e
/// l'invito (FT.13).
class SinastriaApprofonditaScreen extends StatefulWidget {
  const SinastriaApprofonditaScreen({
    super.key,
    required this.nomeTuo,
    required this.cieloTuo,
    required this.nomeSuo,
    required this.cieloSuo,
    this.fabbricaDellaScena,
    this.oggi,
  });

  final String nomeTuo;
  final CieloApprofondito cieloTuo;
  final String nomeSuo;
  final CieloApprofondito cieloSuo;

  /// La finta del lettore video, per le prove headless.
  final FabbricaDellaScenaSinastria? fabbricaDellaScena;

  /// Il giorno di Oggi fra voi e del Momento giusto; nullo, oggi.
  final DateTime? oggi;

  static Route<void> route({
    required String nomeTuo,
    required CieloApprofondito cieloTuo,
    required String nomeSuo,
    required CieloApprofondito cieloSuo,
  }) =>
      PassaggioDelCerchio.rotta(
        (_) => SinastriaApprofonditaScreen(
          nomeTuo: nomeTuo,
          cieloTuo: cieloTuo,
          nomeSuo: nomeSuo,
          cieloSuo: cieloSuo,
        ),
      );

  @override
  State<SinastriaApprofonditaScreen> createState() =>
      _SinastriaApprofonditaScreenState();
}

class _SinastriaApprofonditaScreenState
    extends State<SinastriaApprofonditaScreen> with WidgetsBindingObserver {
  bool _reduceMotion = false;

  /// **L'ORA NON NOTA SI DICHIARA A VIDEO**, ordine FT voce FT.03: la Luna
  /// tace (`CieloApprofondito.oraNota`), e chi legge sa perche' nessun
  /// aspetto la nomina. Nullo quando tutte e due le ore sono note.
  String? get _laLunaTace {
    final tua = widget.cieloTuo.oraNota;
    final sua = widget.cieloSuo.oraNota;
    if (tua && sua) return null;
    final chi = !tua && !sua
        ? 'Le vostre ore di nascita non sono note'
        : !tua
            ? 'La tua ora di nascita non è nota'
            : "L'ora di nascita di ${widget.nomeSuo} non è nota";
    return '$chi: la Luna, che in un giorno fa tredici gradi, tace in '
        'questa lettura invece di essere indovinata.';
  }

  /// Vero quando la lettura e' scorsa sotto la barra del titolo.
  bool _sottoIlTitolo = false;
  bool _avviata = false;
  LettoreDellaScenaSinastria? _lettore;
  bool _filmatoSospesoDaNoi = false;

  late final DateTime _oggi = widget.oggi ?? DateTime.now();
  late final DateTime _quando = DateTime.now();

  /// Il legame: amore se lo sbarramento d'eta' lo apre, altrimenti amicizia.
  late Legame _legame = _amoreApribile ? Legame.amore : Legame.amicizia;

  bool get _amoreApribile => SbarramentoDEta.legameApribile(Legame.amore,
      widget.cieloTuo.giornoDiNascita, widget.cieloSuo.giornoDiNascita,
      adesso: _oggi);

  final GlobalKey _chiaveDellaCard = GlobalKey();
  bool _cardInScena = false;

  // Il calcolo non dipende dal legame (FT.06: "il legame cambia la lettura,
  // non il calcolo"): si fa una volta sola.
  late final IlComposito _composito =
      IlComposito.fra(widget.cieloTuo, widget.cieloSuo);
  late final List<Corda> _corde =
      IntervalliDiKeplero.fra(widget.cieloTuo, widget.cieloSuo);
  late final OggiFraVoi _oggiFraVoi = OggiFraVoi.per(
      tuo: widget.cieloTuo,
      suo: widget.cieloSuo,
      nomeSuo: widget.nomeSuo,
      giorno: _oggi,
      corpus: corpusDellaSinastriaApprofondita);

  List<CapitoloLetto> get _capitoli => LetturaApprofondita.componi(
      tuo: widget.cieloTuo,
      suo: widget.cieloSuo,
      nomeSuo: widget.nomeSuo,
      legame: _legame,
      corpus: corpusDellaSinastriaApprofondita);

  /// Il segno della relazione: quello del Sole composito.
  String get _coppia =>
      ArtworkDelRicordo.percorsoDellaCoppia(IlSegnoDelCielo.dellaLongitudine(
          _composito.punti[PuntoDelCieloApprofondito.sole]!));

  String get _segnoDellaCoppia => IlSegnoDelCielo.dellaLongitudine(
          _composito.punti[PuntoDelCieloApprofondito.sole]!)
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
    // LA SINASTRIA APPROFONDITA ENTRA NEL CAMMINO, col suo gesto.
    unawaited(RegiaDelCammino.dopoUnGesto(
      context,
      'sinastria_approfondita',
      dettagli: {'con': widget.nomeSuo},
    ));
  }

  Future<void> _apriIlFilmato() async {
    if (_reduceMotion) return;
    final lettore =
        (widget.fabbricaDellaScena ?? LettoreDellaScenaSinastria.vero)();
    _lettore = lettore;
    lettore.ascolta(() {
      if (mounted) setState(() {});
    });
    await lettore.apri();
    if (!mounted || !identical(_lettore, lettore) || !lettore.pronto) return;
    final suono =
        _forse<SettingsController>(context)?.suonoEVibrazione ?? false;
    final muto = !suono || await LaSuoneria.spenta();
    if (!mounted) return;
    await lettore.volume(muto ? 0 : 1);
    if (!mounted || !identical(_lettore, lettore)) return;
    await lettore.avvia();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final lettore = _lettore;
    if (lettore == null || !lettore.pronto || lettore.finito) return;
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

  Widget? get _filmatoInScena {
    final l = _lettore;
    if (l == null || l.fallito || !l.cominciato) return null;
    return l.disegna();
  }

  String get _posaDiMedora {
    final l = _lettore;
    return l == null || l.fallito
        ? GeometriaDelloStudio.posaDelleManiAperte
        : GeometriaDelloStudio.posaDellAstrolabio;
  }

  /// Un provider che puo' mancare (le prove montano la schermata da sola):
  /// senza, si va avanti col ripiego, come nella Stesa.
  T? _forse<T>(BuildContext context, {bool osserva = false}) {
    try {
      return osserva ? context.watch<T>() : context.read<T>();
    } catch (senzaProvider) {
      debugPrint('Sinastria approfondita: manca $T, ripiego ($senzaProvider)');
      return null;
    }
  }

  @override
  void dispose() {
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
    setState(() => _legame = l);
  }

  Future<void> _invito(String cosa, bool Function(Tier) apre) {
    final dal = PlanCatalog.dalPiano(apre) ?? 'Dal piano superiore';
    return showUpgradeInvite(
      context,
      title: '$cosa si apre ${dal[0].toLowerCase()}${dal.substring(1)}',
      message: 'Nel Cerchio la Sinastria approfondita si legge per intero: '
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
      return await shareSinastriaApprofonditaCard(
        boundaryKey: _chiaveDellaCard,
        testo: 'La nostra sinastria approfondita, su Esoteric Circle.',
      );
    } catch (errore) {
      debugPrint('La card della Sinastria approfondita non parte: $errore');
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
    final capitoli = _capitoli;
    final tuttiICapitoli =
        PlanCatalog.apre(RigaDelPiano.capitoliDellaSinastria, tier);
    final keplero = PlanCatalog.apre(RigaDelPiano.intervalliDiKeplero, tier);
    final adepto =
        PlanCatalog.apre(RigaDelPiano.compositoRitrattoMomento, tier);
    final perIlDiario = ResponsoDaCustodire(
      arte: 'sinastria_approfondita',
      titolo: 'Con ${widget.nomeSuo}, ${_legame.nome.toLowerCase()}',
      testo: capitoli.first.titolo,
      perIlMaestro: [
        for (final c in capitoli) '${c.capitolo.nome}: ${c.titolo}',
      ].join('\n'),
      dati: {
        'coppia': _segnoDellaCoppia,
        'con': widget.nomeSuo,
        'legame': _legame.name,
      },
    );
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // **IL VELO SEGUE LA LETTURA.** All'apertura lo stesso velo
        // leggero dei Tarocchi dopo la revisione del 15 ottobre 2026, cosi'
        // la scena di Medora si vede intera; appena il testo passa sotto il
        // titolo il velo si fa denso, altrimenti titolo e lettura si
        // sovrappongono (anteprima ft_viandante_2, 14 ottobre 2026).
        backgroundColor:
            palette.deepest.withValues(alpha: _sottoIlTitolo ? 0.9 : 0.16),
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
            chiaveDelTesto: const Key('sinastria_approfondita_titolo'),
            testo: 'Sinastria approfondita',
            righe: 1,
            stile: TypographyTokens.titoloSezione()),
      ),
      body: CosmosBackground(
        key: const Key('sinastria_approfondita_sfondo'),
        seed: 7,
        showZodiac: false,
        child: SafeArea(
          top: false,
          child: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n.depth != 0 || n.metrics.axis != Axis.vertical) {
                    return false;
                  }
                  final sotto = n.metrics.pixels > SpacingTokens.lg;
                  if (sotto != _sottoIlTitolo) {
                    setState(() => _sottoIlTitolo = sotto);
                  }
                  return false;
                },
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Il responso entra nel Diario da se', in cima all'elenco
                    // pigro (ordine FE voce 22.6).
                    IlResponsoNelDiario(
                      maestro: Maestro.medora,
                      responso: perIlDiario,
                      quando: _quando,
                    ),
                    Builder(
                      builder: (corpo) => Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.paddingOf(corpo).top),
                        child: LoStudioDiMedora(
                          key: const Key('sinastria_approfondita_scena'),
                          posa: _posaDiMedora,
                          filmato: _filmatoInScena,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(SpacingTokens.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _LaCoppia(
                            palette: palette,
                            coppia: _coppia,
                            nomeSuo: widget.nomeSuo,
                            segno: _segnoDellaCoppia,
                          ),
                          if (_laLunaTace != null) ...[
                            const SizedBox(height: SpacingTokens.sm),
                            Text(_laLunaTace!,
                                key: const Key('sinastria_ora_non_nota'),
                                textAlign: TextAlign.center,
                                style: TypographyTokens.didascalia().copyWith(
                                    color: ColorTokens.textSecondary,
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
                          _OggiFraVoiCard(palette: palette, oggi: _oggiFraVoi),
                          const SizedBox(height: SpacingTokens.lg),
                          for (var i = 0; i < capitoli.length; i++) ...[
                            if (tuttiICapitoli || i < 2)
                              _IlCapitolo(
                                  palette: palette, capitolo: capitoli[i])
                            else
                              _Chiuso(
                                chiave: 'capitolo_${capitoli[i].capitolo.name}',
                                palette: palette,
                                immagine: capitoli[i].capitolo.medaglione,
                                titolo: capitoli[i].capitolo.nome,
                                onApri: () => _invito(
                                    'Il capitolo ${capitoli[i].capitolo.nome.toLowerCase()}',
                                    (t) => PlanCatalog.apre(
                                        RigaDelPiano.capitoliDellaSinastria,
                                        t)),
                              ),
                            const SizedBox(height: SpacingTokens.lg),
                          ],
                          if (keplero)
                            _Keplero(
                                palette: palette,
                                corde: _corde,
                                nomeSuo: widget.nomeSuo)
                          else
                            _Chiuso(
                              chiave: 'keplero',
                              palette: palette,
                              immagine: 'aspetto_trigono_v1',
                              titolo: 'Gli intervalli di Keplero',
                              onApri: () => _invito(
                                  'Gli intervalli di Keplero',
                                  (t) => PlanCatalog.apre(
                                      RigaDelPiano.intervalliDiKeplero, t)),
                            ),
                          const SizedBox(height: SpacingTokens.lg),
                          if (adepto) ...[
                            _IlComposito(
                                palette: palette, composito: _composito),
                            const SizedBox(height: SpacingTokens.lg),
                            _IlMomentoGiusto(
                              palette: palette,
                              giorni: IlMomentoGiusto.per(
                                  tuo: widget.cieloTuo,
                                  suo: widget.cieloSuo,
                                  nomeSuo: widget.nomeSuo,
                                  legame: _legame,
                                  da: _oggi,
                                  corpus: corpusDellaSinastriaApprofondita),
                              senzaGiorni: IlMomentoGiusto.testoSenzaGiorni(
                                  tuo: widget.cieloTuo,
                                  suo: widget.cieloSuo,
                                  nomeSuo: widget.nomeSuo,
                                  legame: _legame,
                                  corpus: corpusDellaSinastriaApprofondita),
                              oggi: _oggi,
                            ),
                          ] else
                            _Chiuso(
                              chiave: 'adepto',
                              palette: palette,
                              immagine: 'legame_amore_v1',
                              titolo: 'Il cielo comune, il momento giusto e '
                                  'il ritratto della coppia',
                              onApri: () => _invito(
                                  'Il cielo comune della relazione',
                                  (t) => PlanCatalog.apre(
                                      RigaDelPiano.compositoRitrattoMomento,
                                      t)),
                            ),
                          const SizedBox(height: SpacingTokens.lg),
                          AzioniDelResponso(
                            palette: palette,
                            maestro: Maestro.medora,
                            dorato: true,
                            responso: perIlDiario,
                            quando: _quando,
                            condividi: () => _condividi(tier, capitoli),
                            aperturaDellaChat:
                                ChatOpeners.sinastriaApprofondita(
                                    widget.nomeSuo,
                                    _legame.nome.toLowerCase(),
                                    capitoli.first.titolo),
                          ),
                          const SizedBox(height: SpacingTokens.xl),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // La card condivisibile, disegnata fuori campo solo durante lo
              // scatto: il ritratto per l'Adepto, il primo capitolo per gli
              // altri piani (FT.14).
              if (_cardInScena)
                Positioned(
                  left: -3000,
                  top: 0,
                  child: RepaintBoundary(
                    key: _chiaveDellaCard,
                    child: adepto
                        ? RitrattoDellaCoppia(
                            palette: palette,
                            nomeSuo: widget.nomeSuo,
                            legame: _legame,
                            coppia: _coppia,
                            sintesi: _titoloDelComposito(),
                            capitoli: capitoli,
                          )
                        : CardDelCapitolo(
                            palette: palette,
                            nomeSuo: widget.nomeSuo,
                            legame: _legame,
                            capitolo: capitoli.first,
                          ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _titoloDelComposito() {
    final v = corpusDellaSinastriaApprofondita[
        'composito|${_composito.cella}|titolo']!;
    return v[
        LetturaApprofondita.semeDellaCoppia(widget.cieloTuo, widget.cieloSuo) %
            v.length];
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
              key: const Key('sinastria_approfondita_coppia'),
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
                  key: const Key('sinastria_approfondita_nomi'),
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
      return c.tuo == PuntoDelCieloApprofondito.sole
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
            final v = corpusDellaSinastriaApprofondita[
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
              testo: corpusDellaSinastriaApprofondita[
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
      final v = corpusDellaSinastriaApprofondita['composito|$cella|$campo']!;
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

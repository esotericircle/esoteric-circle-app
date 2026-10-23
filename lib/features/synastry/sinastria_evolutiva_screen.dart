import 'dart:async';
import '../scene/la_scena_in_video.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/amici/amici_offline.dart';
import '../../core/astro/il_segno_del_cielo.dart';
import '../../core/astro/meeus/corpo_celeste.dart';
import '../../core/cerchio/il_cerchio_sociale.dart';
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
import '../../core/synastry_evolutiva/la_lunga_della_sinastria.dart';
import '../../core/synastry_evolutiva/la_sinastria_condivisa.dart';
import '../../core/synastry_evolutiva/le_barre_della_sinastria.dart';
import '../../core/synastry_evolutiva/legame_e_eta.dart';
import '../../core/synastry_evolutiva/oggi_e_il_momento.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/il_responso_in_tre_paragrafi.dart';
import '../../design_system/components/riquadro_in_evidenza.dart';
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
import '../tarot/attesa_di_medora.dart';
import 'il_grafico_delle_barre.dart';
import 'il_ritratto_della_coppia.dart';
import 'la_tendina_della_sinastria.dart';
import 'lo_studio_di_medora.dart';

export 'la_tendina_della_sinastria.dart' show SceltaDellaSinastria;

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
/// una schermata nera e le funzioni social, niente altro"*. La schermata si
/// apre subito con lo studio di Medora e il suo video; data la nascita, la
/// lettura compare qui, sotto la stessa scena, senza un secondo video.
///
/// **RIFATTA CON CURA, ORDINE GD PARTE D**, 23 ottobre 2026. Il giudizio del
/// fondatore sulla funzione com'era: *"SEMPLICEMENTE FA CAGARE"*.
/// - GD.13: il video copre tutto lo schermo, sopra stanno la domanda sopra
///   la testa di Medora e il solo pulsante in basso;
/// - GD.14-GD.17: il pulsante apre la tendina che sale, semitrasparente, un
///   passo alla volta ([LaTendinaDellaSinastria]): online o offline, la
///   persona, il modulo della nascita, il legame, Breve o Lunga;
/// - GD.18: "Scopri la compatibilità", la riflessione di Medora (la stessa
///   scena della Stesa e dell'Oracolo, [AttesaDiMedora]) e la statua del
///   segno della relazione, grande e scontornata, sul tavolo;
/// - GD.19: le barre dell'infografica subito dopo il titolo e in ogni
///   bolla le sue, dello stesso tipo ([IlGraficoDelleBarre]);
/// - GD.21: con un amico del Cerchio la lettura arriva anche a lui;
/// - GD.22: la riga viva di oggi sulla scheda della coppia.
class SinastriaEvolutivaScreen extends StatefulWidget {
  const SinastriaEvolutivaScreen({
    super.key,
    required this.nomeTuo,
    required this.cieloTuo,
    this.nomeSuo,
    this.cieloSuo,
    this.legame,
    this.profondita = ProfonditaDellaSinastria.breve,
    this.chiediLaPersona,
    this.laCoppiaSiConta,
    this.nomeSuggerito,
    this.amici,
    this.fabbricaDellaScena,
    this.oggi,
    this.amoreDalServer,
  }) : assert((nomeSuo == null) == (cieloSuo == null),
            'il nome e il cielo dell\'altra persona vanno insieme');

  final String nomeTuo;
  final CieloEvolutivo cieloTuo;

  /// L'altra persona. Nulli, la schermata si apre sulla scena e chiede chi
  /// e' con la tendina.
  final String? nomeSuo;
  final CieloEvolutivo? cieloSuo;

  /// Il legame della lettura aperta con la coppia gia' nota; nullo, l'amore
  /// se lo sbarramento d'eta' lo apre, altrimenti l'amicizia.
  final Legame? legame;

  /// La profondita' della lettura aperta con la coppia gia' nota (GD.17).
  final ProfonditaDellaSinastria profondita;

  /// **LA SCELTA DELLA PERSONA.** Nulla, la tendina della GD.14
  /// ([LaTendinaDellaSinastria.apri]); le prove la sostituiscono con una
  /// scelta gia' fatta.
  final Future<SceltaDellaSinastria?> Function(BuildContext context)?
      chiediLaPersona;

  /// **IL CONTO DELLA COPPIA NUOVA** (FT.13, GD.16 e GD.22): vero se la
  /// lettura si puo' fare. Il ponte `AvvioSinastriaEvolutiva` conta qui le
  /// coppie nuove e una coppia gia' scoperta col suo legame si rilegge
  /// senza consumare. Nullo, la lettura si fa sempre.
  final Future<bool> Function(
      BuildContext context, SceltaDellaSinastria scelta)? laCoppiaSiConta;

  /// Il nome gia' noto (il segno 15, il confronto del cielo): riempie solo il
  /// campo del nome del modulo.
  final String? nomeSuggerito;

  /// La porta degli amici offline, per le prove (GD.20).
  final AmiciOffline? amici;

  /// La finta del lettore video, per le prove headless.
  final FabbricaDellaScenaSinastria? fabbricaDellaScena;

  /// Il giorno di Oggi fra voi e del Momento giusto; nullo, oggi.
  final DateTime? oggi;

  /// **IL VELO DELLA BARRA DEL TITOLO**, uno solo in ogni stato (ordine FY
  /// voce FY.20): semitrasparente, mai pieno.
  static const double veloDellaBarra = 0.45;

  /// La domanda sopra la testa di Medora, alla lettera del fondatore (GD.13).
  static const String laDomanda = 'Con chi vuoi scoprire la tua compatibilità?';

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
    Legame? legame,
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
            legame: legame,
            amoreDalServer: amoreDalServer,
          ),
        ),
      );

  @override
  State<SinastriaEvolutivaScreen> createState() =>
      _SinastriaEvolutivaScreenState();
}

class _SinastriaEvolutivaScreenState extends State<SinastriaEvolutivaScreen>
    with WidgetsBindingObserver {
  bool _reduceMotion = false;

  /// L'altra persona: dalla rotta, o scelta dalla tendina (GD.14).
  late String? _nomeSuo = widget.nomeSuo;
  late CieloEvolutivo? _cieloSuo = widget.cieloSuo;
  late bool? _amoreDalServer = widget.amoreDalServer;
  late Legame? _legameChiesto = widget.legame;
  late ProfonditaDellaSinastria _profondita = widget.profondita;
  bool get _coppiaNota => _cieloSuo != null;
  String get _nome => _nomeSuo!;
  CieloEvolutivo get _suo => _cieloSuo!;
  bool _scegliendo = false;

  /// **MEDORA RIFLETTE**, ordine GD voce GD.18: dopo "Scopri la
  /// compatibilità", la scena della Stesa e dell'Oracolo sopra lo studio,
  /// per il suo minimo garantito; poi la statua sul tavolo e la lettura.
  bool _riflettendo = false;
  Timer? _attesaDellaRiflessione;

  /// **LA RIGA DELLA CONSEGNA**, ordine GD voce GD.21: la lettura arrivata
  /// anche all'amico del Cerchio, o perche' no.
  String? _rigaDellaConsegna;

  final ScrollController _scorrimento = ScrollController();

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
  /// blocco sopra la scena aspetta la scena ferma: un video che non si
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
  DateTime _quando = DateTime.now();

  /// Il legame della lettura: quello chiesto, se si apre; l'amore chiuso
  /// dallo sbarramento d'eta' (FT.04) o dal no del server lascia il posto
  /// all'amicizia, come prima che si potesse scegliere.
  Legame get _legame {
    final chiesto = _legameChiesto;
    if (chiesto != null && (chiesto != Legame.amore || _amoreApribile)) {
      return chiesto;
    }
    return _amoreApribile && chiesto == null ? Legame.amore : Legame.amicizia;
  }

  bool get _amoreApribile =>
      _amoreDalServer != false &&
      SbarramentoDEta.legameApribile(
          Legame.amore, widget.cieloTuo.giornoDiNascita, _suo.giornoDiNascita,
          adesso: _oggi);

  final GlobalKey _chiaveDellaCard = GlobalKey();
  bool _cardInScena = false;

  // Il calcolo non dipende dal legame (FT.06: "il legame cambia la lettura,
  // non il calcolo"): si fa una volta per coppia, quando la coppia e' nota.
  // Non `late final`: un'altra sinastria (GD.16) porta un'altra coppia.
  IlComposito? _composito;
  List<Corda> _corde = const [];
  OggiFraVoi? _oggiFraVoi;
  List<CapitoloLetto> _capitoli = const [];

  void _calcola() {
    if (!_coppiaNota) return;
    _composito = IlComposito.fra(widget.cieloTuo, _suo);
    _corde = IntervalliDiKeplero.fra(widget.cieloTuo, _suo);
    _oggiFraVoi = OggiFraVoi.per(
        tuo: widget.cieloTuo,
        suo: _suo,
        nomeSuo: _nome,
        giorno: _oggi,
        corpus: corpusDellaSinastriaEvolutiva);
    _capitoli = LetturaEvolutiva.componi(
        tuo: widget.cieloTuo,
        suo: _suo,
        nomeSuo: _nome,
        legame: _legame,
        corpus: corpusDellaSinastriaEvolutiva);
  }

  /// Il segno della relazione: quello del Sole composito.
  String get _coppia =>
      ArtworkDelRicordo.percorsoDellaCoppia(IlSegnoDelCielo.dellaLongitudine(
          _composito!.punti[PuntoDelCieloEvolutivo.sole]!));

  String get _segnoDellaCoppia => IlSegnoDelCielo.dellaLongitudine(
          _composito!.punti[PuntoDelCieloEvolutivo.sole]!)
      .italianName;

  /// **LA RIGA VIVA DI OGGI**, ordine GD voce GD.22: la prima frase di Oggi
  /// fra voi (FT.09), che cambia col giorno senza modello. Rileggere la
  /// coppia non consuma niente: la riga si compone qui, dal corpus.
  String get _rigaViva {
    final t = _oggiFraVoi!.testo.trim();
    final fine = RegExp(r'[.!?](\s|$)').firstMatch(t);
    return fine == null ? t : t.substring(0, fine.start + 1);
  }

  @override
  void initState() {
    super.initState();
    _calcola();
  }

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
  /// coppia e' nota, dalla rotta o dalla tendina.
  void _nelCammino() {
    unawaited(RegiaDelCammino.dopoUnGesto(
      context,
      'sinastria_evolutiva',
      dettagli: {'con': _nome},
    ));
  }

  Future<SceltaDellaSinastria?> _laTendina(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final tier = _forse<EntitlementService>(context)?.tier ?? Tier.free;
    return LaTendinaDellaSinastria.apri(
      context,
      palette: palette,
      tier: tier,
      cieloTuo: widget.cieloTuo,
      oggi: _oggi,
      nomeSuggerito: widget.nomeSuggerito,
      amici: widget.amici,
    );
  }

  /// **LA SCELTA DELLA PERSONA**, ordini FY voce FY.11 e GD voci
  /// GD.14-GD.18: la tendina sale sopra la scena, il conto della coppia
  /// nuova, la riflessione di Medora e la lettura qui, sotto la stessa
  /// scena.
  Future<void> _scegliLaPersona() async {
    if (_scegliendo || _coppiaNota) return;
    setState(() => _scegliendo = true);
    final scelta = await (widget.chiediLaPersona ?? _laTendina)(context);
    if (!mounted) return;
    if (scelta == null) {
      setState(() => _scegliendo = false);
      return;
    }
    final conta = widget.laCoppiaSiConta;
    final puoi = conta == null ? true : await conta(context, scelta);
    if (!mounted) return;
    if (!puoi) {
      setState(() => _scegliendo = false);
      return;
    }
    setState(() {
      _scegliendo = false;
      _nomeSuo = scelta.nome;
      _cieloSuo = scelta.cielo;
      _amoreDalServer = scelta.amoreDalServer;
      _legameChiesto = scelta.legame;
      _profondita = scelta.profondita;
      _rigaDellaConsegna = null;
      _quando = DateTime.now();
      _riflettendo = true;
      _calcola();
    });
    _nelCammino();
    _attesaDellaRiflessione?.cancel();
    _attesaDellaRiflessione =
        Timer(AttesaDiMedora.minimaPer(riduciMovimento: _reduceMotion), () {
      if (mounted) setState(() => _riflettendo = false);
    });
    final uid = scelta.uidDelCerchio;
    if (uid != null) unawaited(_consegnaAllAmico(uid));
  }

  /// **LA LETTURA ARRIVA ANCHE ALL'AMICO DEL CERCHIO**, ordine GD voce
  /// GD.21: lo stesso responso appena composto, i capitoli che il piano di
  /// chi legge apre, nella forma della porta ([LaSinastriaCondivisa]),
  /// senza nascite. Solo a un amico del Cerchio ([IlCerchioSociale.
  /// mandaLaSinastria] non chiama la porta per gli altri).
  Future<void> _consegnaAllAmico(String uid) async {
    final sociale = _forse<IlCerchioSociale>(context);
    if (sociale == null) return;
    final tier = _forse<EntitlementService>(context)?.tier ?? Tier.free;
    final tutti = PlanCatalog.apre(RigaDelPiano.capitoliDellaSinastria, tier);
    final letti = tutti ? _capitoli : _capitoli.take(2).toList();
    final nome = _nome;
    final esito = await sociale.mandaLaSinastria(
        uid,
        LaSinastriaCondivisa.dai(
                legame: _legame, segno: _segnoDellaCoppia, capitoli: letti)
            .comeDati());
    if (!mounted) return;
    setState(() => _rigaDellaConsegna = esito.ok
        ? 'La vostra lettura è arrivata anche a $nome, nel suo Cerchio.'
        : esito.riga);
  }

  /// **UN'ALTRA SINASTRIA**, ordine GD voce GD.16: un altro legame, o
  /// un'altra persona, e' una sinastria nuova, che si sceglie dalla tendina
  /// e si conta come una coppia nuova.
  void _unAltraSinastria() {
    setState(() {
      _nomeSuo = null;
      _cieloSuo = null;
      _legameChiesto = null;
      _amoreDalServer = null;
      _rigaDellaConsegna = null;
      _profondita = ProfonditaDellaSinastria.breve;
      _capitoli = const [];
    });
    if (_scorrimento.hasClients) _scorrimento.jumpTo(0);
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
    _attesaDellaRiflessione?.cancel();
    _scorrimento.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _lettore?.chiudi();
    super.dispose();
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

  /// Le righe della riflessione: nominano i due cieli e il legame, mai un
  /// caricamento qualunque (la regola delle righe di [AttesaDiMedora]).
  List<String> get _righeDellaRiflessione => [
        'Medora mette il tuo cielo accanto a quello di $_nome.',
        'Medora cerca dove i vostri pianeti si guardano.',
        'Medora pesa il legame che hai scelto: ${_legame.nome.toLowerCase()}.',
        'Medora ascolta che cosa dice il vostro cielo comune.',
        'Medora tiene i vostri due cieli sotto gli occhi, senza fretta.',
      ];

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final tier =
        _forse<EntitlementService>(context, osserva: true)?.tier ?? Tier.free;
    final coppia = _coppiaNota;
    final capitoli = coppia ? _capitoli : const <CapitoloLetto>[];
    final tuttiICapitoli =
        PlanCatalog.apre(RigaDelPiano.capitoliDellaSinastria, tier);
    final keplero = PlanCatalog.apre(RigaDelPiano.intervalliDiKeplero, tier);
    final adepto =
        PlanCatalog.apre(RigaDelPiano.compositoRitrattoMomento, tier);
    // **LA LUNGA SOLO COL PIANO** (GD.17): una Lunga chiesta senza il piano
    // (una rotta vecchia, un piano sceso) si legge Breve.
    final lunga = coppia &&
        _profondita == ProfonditaDellaSinastria.lunga &&
        PlanCatalog.apre(RigaDelPiano.sinastriaLunga, tier);
    final testiDellaLunga = !lunga
        ? null
        : LaLungaDellaSinastria.per(
            tuo: widget.cieloTuo,
            suo: _suo,
            nomeSuo: _nome,
            legame: _legame,
            primo: capitoli.first,
            corpus: corpusDellaSinastriaEvolutiva);
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
    final bassoSicuro = MediaQuery.paddingOf(context).bottom;
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
          child: LayoutBuilder(builder: (context, vincoli) {
            final alto = vincoli.maxHeight;
            final largo = vincoli.maxWidth;
            // **LA SCENA PARTE DAL BORDO ALTO E PASSA SOTTO LA BARRA**,
            // ordine GC voce GC.02, regola permanente R12; dall'ordine GD
            // voce GD.13 copre tutto lo schermo. LAPIDE: la scena era alta
            // quanto il taglio a tutta larghezza (a 360 punti, 640) e sotto
            // stava il velo col testo, che la tagliava.
            final scena = LoStudioDiMedora(
              key: const Key('sinastria_evolutiva_scena'),
              posa: _posaDiMedora,
              filmato: _filmatoInScena,
              filmatoSaltato: _filmatoSaltato,
              altezza: alto,
              statua: coppia ? _segnoDellaCoppia.toLowerCase() : null,
              statuaVisibile: _scenaFerma && !_riflettendo,
              riduciMovimento: _reduceMotion,
            );
            final geometria =
                GeometriaDelloStudio.aTuttoSchermo(Size(largo, alto));
            final testa = geometria.origine.dy +
                GeometriaDelloStudio.testaDiMedora * geometria.scala;
            return Stack(
              children: [
                if (!coppia) ...[
                  Positioned.fill(child: scena),
                  // **LA DOMANDA SOPRA LA TESTA DI MEDORA**, ordine GD voce
                  // GD.13, alla lettera del fondatore.
                  Positioned(
                    left: SpacingTokens.lg,
                    right: SpacingTokens.lg,
                    bottom: alto - testa + SpacingTokens.xs,
                    child: IlRestoDopoLaScena(
                      scenaFerma: _scenaFerma,
                      // **CON LA TENDINA APERTA LA DOMANDA SI DISSOLVE**,
                      // simulazione da persona dell'ordine GD sul Realme: la
                      // tendina e' semitrasparente e il titolo della scena
                      // filtrava sotto le sue righe, illeggibili. La scena
                      // dipinta resta.
                      child: AnimatedOpacity(
                        opacity: _scegliendo ? 0 : 1,
                        duration: const Duration(milliseconds: 250),
                        child: Text(SinastriaEvolutivaScreen.laDomanda,
                            key: const Key('sinastria_la_domanda'),
                            textAlign: TextAlign.center,
                            style: TypographyTokens.suLaScena(
                                TypographyTokens.titoloSezione()
                                    .copyWith(color: coloreSulVelluto))),
                      ),
                    ),
                  ),
                  // **SOLO IL PULSANTE, IN BASSO**, ordine GD voce GD.13: via
                  // le due righe sotto il titolo. Anche lui aspetta la scena
                  // ferma (FXA.08).
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: IlRestoDopoLaScena(
                      scenaFerma: _scenaFerma,
                      // Anche il pulsante si dissolve sotto la tendina: il
                      // suo "Un momento" filtrava sotto le righe della scelta.
                      child: AnimatedOpacity(
                        opacity: _scegliendo ? 0 : 1,
                        duration: const Duration(milliseconds: 250),
                        child: _IlPulsanteInBasso(
                          scegliendo: _scegliendo,
                          bassoSicuro: bassoSicuro,
                          onScegli: _scegliLaPersona,
                        ),
                      ),
                    ),
                  ),
                ] else
                  ListView(
                    controller: _scorrimento,
                    padding: EdgeInsets.zero,
                    children: [
                      // Il responso entra nel Diario da se', in cima
                      // all'elenco pigro (ordine FE voce 22.6).
                      if (perIlDiario != null)
                        IlResponsoNelDiario(
                          maestro: Maestro.medora,
                          responso: perIlDiario,
                          quando: _quando,
                        ),
                      SizedBox(
                        height: alto,
                        child: Stack(
                          children: [
                            Positioned.fill(child: scena),
                            // **LA SCHEDA DELLA COPPIA, CON LA RIGA VIVA DI
                            // OGGI**, ordine GD voce GD.22.
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: IlRestoDopoLaScena(
                                scenaFerma: _scenaFerma && !_riflettendo,
                                child: _LaRigaViva(
                                  palette: palette,
                                  riga: _rigaViva,
                                  bassoSicuro: bassoSicuro,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // **SOPRA IL VIDEO SOLO IL VIDEO**, ordine FX voce
                      // FXA.08: la lettura aspetta la scena ferma e compare
                      // in dissolvenza.
                      IlRestoDopoLaScena(
                        scenaFerma: _scenaFerma && !_riflettendo,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                              SpacingTokens.md,
                              SpacingTokens.lg,
                              SpacingTokens.md,
                              SpacingTokens.md + bassoSicuro),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _LaCoppia(
                                palette: palette,
                                nomeSuo: _nome,
                                segno: _segnoDellaCoppia,
                                legame: _legame,
                              ),
                              const SizedBox(height: SpacingTokens.md),
                              // **LE BARRE SUBITO DOPO IL TITOLO**, ordine
                              // GD voce GD.19.
                              Container(
                                key: const Key('sinastria_barre_responso'),
                                child: IlGraficoDelleBarre(
                                  palette: palette,
                                  titolo: 'Quanto si guardano i vostri cieli, '
                                      'capitolo per capitolo',
                                  barre: LeBarreDellaSinastria.deiCapitoli(
                                      widget.cieloTuo, _suo),
                                ),
                              ),
                              if (_laLunaTace != null) ...[
                                const SizedBox(height: SpacingTokens.sm),
                                Text(_laLunaTace!,
                                    key: const Key('sinastria_ora_non_nota'),
                                    textAlign: TextAlign.center,
                                    style: TypographyTokens.didascalia()
                                        .copyWith(
                                            color: ColorTokens.textSecondary,
                                            fontStyle: FontStyle.italic)),
                              ],
                              const SizedBox(height: SpacingTokens.lg),
                              _OggiFraVoiCard(
                                palette: palette,
                                oggi: _oggiFraVoi!,
                                barre: LeBarreDellaSinastria.diOggi(
                                    widget.cieloTuo, _suo, _oggi),
                              ),
                              const SizedBox(height: SpacingTokens.lg),
                              for (var i = 0; i < capitoli.length; i++) ...[
                                if (tuttiICapitoli || i < 2)
                                  _IlCapitolo(
                                    palette: palette,
                                    capitolo: capitoli[i],
                                    barre: LeBarreDellaSinastria.delCapitolo(
                                        capitoli[i].capitolo,
                                        widget.cieloTuo,
                                        _suo),
                                    lunga: i == 0 ? testiDellaLunga : null,
                                  )
                                else
                                  _Chiuso(
                                    chiave:
                                        'capitolo_${capitoli[i].capitolo.name}',
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
                                          RigaDelPiano.intervalliDiKeplero, t)),
                                ),
                              const SizedBox(height: SpacingTokens.lg),
                              if (adepto) ...[
                                _IlComposito(
                                    palette: palette, composito: _composito!),
                                const SizedBox(height: SpacingTokens.lg),
                                _IlMomentoGiusto(
                                  palette: palette,
                                  giorni: IlMomentoGiusto.per(
                                      tuo: widget.cieloTuo,
                                      suo: _suo,
                                      nomeSuo: _nome,
                                      legame: _legame,
                                      da: _oggi,
                                      corpus: corpusDellaSinastriaEvolutiva),
                                  senzaGiorni: IlMomentoGiusto.testoSenzaGiorni(
                                      tuo: widget.cieloTuo,
                                      suo: _suo,
                                      nomeSuo: _nome,
                                      legame: _legame,
                                      corpus: corpusDellaSinastriaEvolutiva),
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
                                          RigaDelPiano.compositoRitrattoMomento,
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
                              if (_rigaDellaConsegna != null) ...[
                                const SizedBox(height: SpacingTokens.md),
                                Text(_rigaDellaConsegna!,
                                    key: const Key('sinastria_consegnata'),
                                    textAlign: TextAlign.center,
                                    style: TypographyTokens.didascalia()
                                        .copyWith(
                                            color: ColorTokens.textSecondary)),
                              ],
                              const SizedBox(height: SpacingTokens.lg),
                              // **UN'ALTRA SINASTRIA**, ordine GD voce GD.16.
                              PulsanteDipinto(
                                key: const Key('sinastria_un_altra'),
                                testo: 'Un\'altra sinastria',
                                larghezzaPiena: true,
                                onTap: _unAltraSinastria,
                              ),
                              const SizedBox(height: SpacingTokens.xs),
                              Text(
                                  'Un altro legame o un\'altra persona: una '
                                  'lettura nuova.',
                                  textAlign: TextAlign.center,
                                  style: TypographyTokens.didascalia().copyWith(
                                      color: ColorTokens.textSecondary)),
                              const SizedBox(height: SpacingTokens.xl),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                // **MEDORA RIFLETTE**, ordine GD voce GD.18: la scena della
                // Stesa e dell'Oracolo, sopra lo studio.
                if (_riflettendo && coppia)
                  Positioned.fill(
                    child: AttesaDiMedora(
                      key: const Key('sinastria_riflessione'),
                      palette: palette,
                      riduciMovimento: _reduceMotion,
                      righeProprie: _righeDellaRiflessione,
                    ),
                  ),
                // La card condivisibile, disegnata fuori campo solo durante
                // lo scatto: il ritratto per l'Adepto, il primo capitolo per
                // gli altri piani (FT.14).
                if (_cardInScena && coppia)
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
            );
          }),
        ),
      ),
    );
  }

  String _titoloDelComposito() {
    final v =
        corpusDellaSinastriaEvolutiva['composito|${_composito!.cella}|titolo']!;
    return v[
        LetturaEvolutiva.semeDellaCoppia(widget.cieloTuo, _suo) % v.length];
  }
}

/// **IL SOLO PULSANTE IN BASSO.** Ordine GD voce GD.13, il fondatore:
/// *"Prima di tutto, via tutto il testo e lascia solo il pulsante sotto"*.
/// LAPIDE: qui c'era `_LaSceltaDellaPersona` dell'ordine FY voce FY.11, col
/// titolo "Con chi leggo il tuo cielo?" e la riga "Scrivi la sua nascita o
/// leggila dal suo telefono: leggo i vostri due cieli." sopra il pulsante.
/// Il pulsante e' il pezzo dipinto del ramo; un velo che sale dal fondo, alto
/// quanto il pulsante e il suo respiro, lo stacca dal pavimento dello studio.
class _IlPulsanteInBasso extends StatelessWidget {
  const _IlPulsanteInBasso({
    required this.scegliendo,
    required this.bassoSicuro,
    required this.onScegli,
  });

  final bool scegliendo;
  final double bassoSicuro;
  final VoidCallback? onScegli;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const Key('sinastria_la_scelta'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            ColorTokens.medoraDeepest.withValues(alpha: 0.75),
            ColorTokens.medoraDeepest.withValues(alpha: 0),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.xl,
            SpacingTokens.lg, SpacingTokens.md + bassoSicuro),
        child: PulsanteDipinto(
          key: const Key('sinastria_scegli_la_persona'),
          testo: scegliendo ? 'Un momento' : 'Scegli la persona',
          larghezzaPiena: true,
          onTap: scegliendo ? null : onScegli,
        ),
      ),
    );
  }
}

/// **LA RIGA VIVA DELLA COPPIA**, ordine GD voce GD.22 (proposta
/// dell'Architetto approvata dal fondatore con "3 ok"): sulla scena, sotto la
/// statua, la prima frase di Oggi fra voi, che cambia ogni giorno; e sotto,
/// l'invito a scorrere verso la lettura.
class _LaRigaViva extends StatelessWidget {
  const _LaRigaViva({
    required this.palette,
    required this.riga,
    required this.bassoSicuro,
  });

  final MaestroPalette palette;
  final String riga;
  final double bassoSicuro;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            ColorTokens.medoraDeepest.withValues(alpha: 0.85),
            ColorTokens.medoraDeepest.withValues(alpha: 0),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.xl,
            SpacingTokens.lg, SpacingTokens.sm + bassoSicuro),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('OGGI FRA VOI',
                style: TypographyTokens.suLaScena(TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft, letterSpacing: 2.0))),
            const SizedBox(height: SpacingTokens.xxs),
            // Una riga sola sulla scena, non un testo narrato: il ruolo del
            // corpo, con l'ombra comune della scena.
            Text(riga,
                key: const Key('sinastria_riga_viva'),
                textAlign: TextAlign.center,
                style: TypographyTokens.suLaScena(TypographyTokens.corpo()
                    .copyWith(color: coloreSulVelluto))),
            const SizedBox(height: SpacingTokens.sm),
            // Nessuna freccia in giu': non e' toccabile, e una freccia
            // promette un tocco (guardia `ogni_freccia_mantiene`). La riga lo
            // dice a parole.
            Text('Scorri in su per leggere il vostro cielo',
                style: TypographyTokens.suLaScena(TypographyTokens.didascalia()
                    .copyWith(color: coloreSulVelluto))),
          ],
        ),
      ),
    );
  }
}

/// Il titolo del responso: i due nomi, il segno della relazione e il legame.
/// La figura sta gia' sul tavolo di Medora (GD.18): LAPIDE, qui c'era la
/// coppia dipinta piccola, 96 per 128, accanto al titolo.
class _LaCoppia extends StatelessWidget {
  const _LaCoppia({
    required this.palette,
    required this.nomeSuo,
    required this.segno,
    required this.legame,
  });

  final MaestroPalette palette;
  final String nomeSuo;
  final String segno;
  final Legame legame;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Tu e $nomeSuo',
            key: const Key('sinastria_evolutiva_nomi'),
            textAlign: TextAlign.center,
            style: TypographyTokens.titoloSezione()
                .copyWith(color: palette.goldSoft)),
        const SizedBox(height: SpacingTokens.xxs),
        Text(
            'Il segno della vostra relazione è $segno. Il legame: '
            '${legame.nome.toLowerCase()}.',
            textAlign: TextAlign.center,
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textSecondary)),
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
  const _OggiFraVoiCard(
      {required this.palette, required this.oggi, required this.barre});
  final MaestroPalette palette;
  final OggiFraVoi oggi;

  /// Quanto i transiti di oggi accendono ogni capitolo (GD.19).
  final List<BarraDellaSinastria> barre;

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
                const SizedBox(height: SpacingTokens.xs),
                // **LA SUA INFOGRAFICA**, ordine GD voce GD.19.
                Container(
                  key: const Key('sinastria_barre_oggi'),
                  child: IlGraficoDelleBarre(
                    palette: palette,
                    titolo: 'Quanto il cielo di oggi tocca ogni capitolo',
                    barre: barre,
                  ),
                ),
                const SizedBox(height: SpacingTokens.sm),
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
  const _IlCapitolo({
    required this.palette,
    required this.capitolo,
    required this.barre,
    this.lunga,
  });
  final MaestroPalette palette;
  final CapitoloLetto capitolo;

  /// Le barre delle tre coppie di punti del capitolo (GD.19).
  final List<BarraDellaSinastria> barre;

  /// **I DUE PARAGRAFI DELLA LUNGA**, solo nel primo capitolo (GD.17):
  /// l'approfondimento e nel riquadro col suo titolo il filo del cielo
  /// comune. Nulli alla Breve e in ogni altro capitolo.
  final ({String approfondimento, String filo})? lunga;

  TextStyle get stile =>
      TypographyTokens.lettura().copyWith(color: ColorTokens.textPrimary);

  /// La stessa distanza fra paragrafi di [ResponsoInTreParagrafi].
  double get distanza => (stile.fontSize ?? TypographyTokens.pavimento) * 1.2;

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
        // **LA SUA INFOGRAFICA, SUBITO DOPO IL TITOLO**, ordine GD voce GD.19.
        Container(
          key: Key('sinastria_barre_${capitolo.capitolo.name}'),
          child: IlGraficoDelleBarre(palette: palette, barre: barre),
        ),
        const SizedBox(height: SpacingTokens.md),
        ResponsoInTreParagrafi(
          paragrafi: capitolo.paragrafi,
          // Con la Lunga il "Da dove viene" scende sotto i due paragrafi in
          // piu', in fondo al capitolo come sempre.
          daDoveViene: lunga == null ? capitolo.daDoveViene : null,
          palette: palette,
          stile: stile,
        ),
        if (lunga != null) ...[
          SizedBox(height: distanza),
          // Il testo narrato passa da ParagrafiDiLettura (guardia
          // `etichette_e_lettura`).
          ParagrafiDiLettura(
              key: const Key('sinastria_lunga_approfondimento'),
              testo: lunga!.approfondimento,
              stile: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textPrimary)),
          SizedBox(height: distanza),
          RiquadroInEvidenza(
            key: const Key('sinastria_lunga_riquadro'),
            palette: palette,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(LaLungaDellaSinastria.titoloDelRiquadro,
                    key: const Key('sinastria_lunga_titolo'),
                    style: TypographyTokens.titoloScheda()
                        .copyWith(color: palette.goldSoft)),
                const SizedBox(height: SpacingTokens.xs),
                ParagrafiDiLettura(
                    key: const Key('sinastria_lunga_filo'),
                    testo: lunga!.filo,
                    stile: TypographyTokens.lettura()
                        .copyWith(color: ColorTokens.textPrimary)),
              ],
            ),
          ),
          SizedBox(height: distanza),
          Text('Da dove viene',
              style: TypographyTokens.etichetta().copyWith(
                  color: ColorTokens.textSecondary, letterSpacing: 1.2)),
          const SizedBox(height: SpacingTokens.xxs),
          Text('${capitolo.daDoveViene} ${IlComposito.daDoveViene}',
              key: const Key('responso_da_dove_viene'),
              style: TypographyTokens.didascalia().copyWith(
                  color: ColorTokens.textSecondary,
                  height: 1.35,
                  fontStyle: FontStyle.italic)),
        ],
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
        // **LA SUA INFOGRAFICA**, ordine GD voce GD.19: quanto ogni corda e'
        // vicina alla sua consonanza. LAPIDE: qui ogni corda portava la sua
        // corda divisa (l'arco minore e il maggiore, `_LaCorda`), un grafico
        // diverso da quello delle altre bolle.
        Container(
          key: const Key('sinastria_barre_keplero'),
          child: IlGraficoDelleBarre(
            palette: palette,
            titolo: 'Quanto ogni corda è vicina alla sua consonanza',
            barre: LeBarreDellaSinastria.diKeplero(corde, _chi),
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        for (var i = 0; i < corde.length; i++) ...[
          Text(_chi(corde[i]),
              style: TypographyTokens.titoloScheda()
                  .copyWith(color: ColorTokens.textPrimary)),
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
        // **LA SUA INFOGRAFICA**, ordine GD voce GD.19.
        Container(
          key: const Key('sinastria_barre_composito'),
          child: IlGraficoDelleBarre(
            palette: palette,
            barre: LeBarreDellaSinastria.delComposito(composito),
          ),
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
        // **LA SUA INFOGRAFICA**, ordine GD voce GD.19: quanto e' acceso
        // ciascuno dei giorni.
        if (giorni.isNotEmpty) ...[
          Container(
            key: const Key('sinastria_barre_momento'),
            child: IlGraficoDelleBarre(
              palette: palette,
              barre: LeBarreDellaSinastria.delMomento(
                  giorni, (g) => '${g.day} ${_mesi[g.month - 1]}'),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
        ],
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

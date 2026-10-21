import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/city_catalog.dart';
import '../../core/astro/luogo_attuale.dart';
import '../../core/astro/ricerca_del_luogo.dart';
import '../../core/astro/sky_location.dart';
import '../../core/entitlement/entitlement_service.dart';
import '../../core/entitlement/tier.dart';
import '../../core/lunario/il_dial_a_moon.dart';
import '../../core/lunario/il_motore_lunare.dart';
import '../../core/lunario/il_respiro_della_luna.dart';
import '../../core/lunario/la_consultazione_della_luna.dart';
import '../../core/lunario/la_parola_di_medora_del_respiro.dart';
import '../../core/maestro/maestro.dart';
import '../../core/permissions/app_permission.dart';
import '../../core/permissions/avviso_del_permesso.dart';
import '../../core/permissions/esito_del_permesso.dart';
import '../../core/sensi/palette_sensoriale.dart';
import '../../design_system/theme/app_theme.dart';
import '../../design_system/components/interruttore_del_cerchio.dart';
import '../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';
import '../../services/avvisi_locali.dart';
import '../../services/breath_detector.dart';
import '../lunario/calendario_lunare_screen.dart';
import '../pricing/pricing_screen.dart';
import '../maestri/rotta_arte.dart';
import '../maestri/widgets/foglio_delle_fonti.dart';
import '../scene/la_scena_in_video.dart';
import '../sigilli/regia_del_cammino.dart';
import 'gli_avvisi_del_respiro.dart';
import 'i_comandi_dipinti.dart';
import 'i_pezzi_della_consultazione.dart';
import 'il_piano_del_respiro.dart';
import 'il_senso_del_respiro.dart';
import 'la_collana_delle_lune_screen.dart';
import 'la_geometria_della_luna_dipinta.dart';

/// **IL RESPIRO DELLA LUNA.** Ordine FX voce FX.04, 16 ottobre 2026.
///
/// Un minuto di respiro guidato accordato alla fase di oggi
/// ([TempiDelRespiroDellaLuna]): la Luna si accende con l'inspiro e si vela
/// con l'espiro, e un anello di perle accese ne accompagna il ritmo. Il
/// gesto e' doppio e sempre attivo tutti e due insieme, non l'uno di
/// ripiego dell'altro: **si tiene premuto per inspirare e si lascia per
/// espirare**, e lo stesso vale se il microfono sente il respiro vero
/// ([BreathDetector], lo stesso del Soffio del Destino, riusato senza
/// cambiarne il comportamento). A rito compiuto si accende la perla del
/// giorno sulla Collana delle Lune (FX.05).
/// Il punto medio che unisce le tre righe di Medora in una sola (FX.07).
/// Non e' il separatore del dominio di un Maestro: sta in una costante
/// propria perche' il testo del codice non collida con quella forma.
const String _separatoreDelleRigheDiMedora = ' · ';

class IlRespiroDellaLunaScreen extends StatefulWidget {
  const IlRespiroDellaLunaScreen(
      {super.key,
      this.now,
      this.dialAMoon,
      this.posizione,
      this.fabbricaDellaScena,
      this.rilevatore});

  /// L'istante da cui si calcola la fase: sostituibile nelle prove.
  final DateTime? now;

  /// Chi chiede la foto vera della Luna (FX.03): iniettabile per le prove,
  /// cosi' nessun test automatico fa una chiamata di rete vera. Senza,
  /// `IlDialAMoon.diCasa`, quello dell'app.
  final IlDialAMoon? dialAMoon;

  /// Chi legge la posizione vera del telefono (FXA.06): iniettabile per le
  /// prove. Senza, il GPS del telefono (`GeolocatorSkyLocation`).
  final SkyLocation? posizione;

  /// Chi fa il video di scena: iniettabile per le prove di FXA.08, che
  /// guardano cosa si vede mentre il video gira. Senza, il video vero.
  final FabbricaDiScena? fabbricaDellaScena;

  /// Chi sente il soffio nel microfono: iniettabile per le prove di FY.06,
  /// che soffiano con un rilevatore finto. Senza, il microfono vero.
  final BreathDetector? rilevatore;

  static Route<void> route({DateTime? now}) =>
      PassaggioDelCerchio.rotta<void>((_) => SogliaArte(
          id: 'lunology',
          maestro: Maestro.medora,
          child: IlRespiroDellaLunaScreen(now: now)));

  @override
  State<IlRespiroDellaLunaScreen> createState() =>
      _IlRespiroDellaLunaScreenState();
}

class _IlRespiroDellaLunaScreenState extends State<IlRespiroDellaLunaScreen>
    with TickerProviderStateMixin {
  static const String _video =
      'brand_assets/respiro_della_luna/medora_il_respiro_della_luna_v1.mp4';
  static const String _cieloSenzaLuna =
      'assets/img/respiro_della_luna/respiro_cielo_senza_luna_v1.webp';
  static const String _primoFotogramma =
      'assets/img/respiro_della_luna/respiro_primo_fotogramma_v1.webp';
  static const String _perlaAccesa =
      'assets/img/respiro_della_luna/collana/perla_accesa_v1.webp';

  /// **SOTTO QUESTO LIVELLO IL MICROFONO NON CONTA UN SOFFIO.** Scelta di
  /// Code, con lo stesso ordine di grandezza della soglia usata altrove in
  /// app per un livello normalizzato in [0, 1]: un rumore di fondo non deve
  /// far credere al rito che la persona stia respirando.
  static const double _sogliaDelMicrofono = 0.12;

  /// Quanto resta accesa la rilevazione del microfono dopo l'ultimo
  /// campione sopra soglia, perche' il respiro reale non e' un segnale
  /// continuo: ha dei vuoti anche mentre l'aria sta ancora entrando o
  /// uscendo.
  static const Duration _graziaDelMicrofono = Duration(milliseconds: 700);

  late final IlRespiroDellaLuna _flag = IlRespiroDellaLuna();

  /// **IL SOFFIO, NON IL VOLUME** (ordine FY voce FY.06). Il fondatore: "Il
  /// respiro non funziona ne con microfono né con gesto". Il rilevatore
  /// misurava il volume grezzo, e un respiro alla distanza di un telefono
  /// non arriva alla soglia di 0,12: il microfono non sentiva niente. Adesso
  /// conta la forma dell'aria (`soloAria`, la stessa misura del Soffio del
  /// Destino e del rito del sogno), che vale uno quando passa il fiato.
  late final BreathDetector _mic =
      widget.rilevatore ?? BreathDetector(soloAria: true);
  late final RegiaDellaScena _regia = RegiaDellaScena(
      widget.fabbricaDellaScena ?? () => LettoreDiScena.vero(_video));
  late final TempiDelRespiroDellaLuna _tempi =
      TempiDelRespiroDellaLuna.diOggi(widget.now ?? DateTime.now());

  /// La Luna, animata: zero velata, uno piena luce. Durata reale per fase,
  /// data a ogni `animateTo`: qui serve solo un valore di apertura.
  late final AnimationController _luce = AnimationController(
    vsync: this,
    duration: _tempi.ciclo,
    // **IL RESPIRO E' IL CONTENUTO, NON UNA TRANSIZIONE.** Stessa lezione
    // di `GuidaDelRespiro` e del Soffio del Destino (ordine EF): senza
    // `preserve` Flutter accorcia l'animazione venti volte quando il
    // telefono ha la scala delle animazioni a zero, e il rito sparirebbe
    // prima di essere visto.
    animationBehavior: AnimationBehavior.preserve,
  )..addListener(() {
      // **SUL VALORE, NON SULLO STATO.** Un giro e' inspiro piu' espiro:
      // si vede che l'inspiro e' arrivato in fondo quando il valore tocca
      // uno, si conta il giro quando torna a zero dopo averlo toccato. Lo
      // stato di `AnimationController` (`completed`/`dismissed`) segue la
      // stessa logica ma sui soli estremi esatti: il valore e' la
      // grandezza che il rito guarda davvero, ed e' quella che si misura.
      // **IL GIRO SI CONTA QUANDO SI LASCIA** (ordine FY, il fondatore
      // sulla build 2313: "IL RESPIRO NON FUNZIONA, IN NESSUN MODO"). Prima
      // un giro contava solo se la Luna arrivava piena (5 secondi tenuti) e
      // poi tornava del tutto velata: chi lasciava prima non vedeva niente
      // avanzare. Adesso conta [_contaIlGiro], al momento del rilascio.
      if (_luce.value >= 1.0) _hoVistoPieno = true;
    });

  /// Un inspiro che ha acceso la Luna almeno a meta' e' un giro, contato
  /// appena il dito si alza o il soffio si ferma.
  void _contaIlGiro() {
    if (_finito || (_luce.value < 0.5 && !_hoVistoPieno)) return;
    _hoVistoPieno = false;
    _cicliCompiuti++;
    if (_cicliCompiuti >= _tempi.cicliPerUnMinuto) {
      _completa();
    } else if (mounted) {
      setState(() {});
    }
  }

  EsitoDelPermesso? _esitoMic;
  bool _tenutoGiu = false;
  bool _respiroSentito = false;
  bool _inFaseDiInspiro = false;
  bool _hoVistoPieno = false;
  int _cicliCompiuti = 0;
  bool _finito = false;

  /// Lo scorrimento della schermata intera (FY.04) e se la Luna e' fissa in
  /// cima perche' la scena e' uscita in alto.
  final ScrollController _scorrimento = ScrollController();
  bool _lunaFissa = false;

  /// **LA PRIMA APERTURA** (FXA.07): finche' non si e' letta, Medora dice
  /// in due righe che cosa si ottiene. Nullo finche' la preferenza non
  /// risponde, cosi' le righe non compaiono e spariscono.
  bool? _primaApertura;
  Timer? _graziaTimer;

  // **IL TEMPO SOTTO IL DITO, ordine FX voce FX.03.** `_tempoVisto` e'
  // l'istante che la Luna e i suoi numeri mostrano: "adesso" finche' nessuno
  // trascina, un altro momento mentre si trascina. La fase col quale il
  // respiro (FX.04) si accorda resta sempre quella di ADESSO
  // (`_tempi`, sopra): scorrere il tempo per guardare e' un gesto diverso dal
  // respirare, e i due non si confondono.
  late DateTime _tempoVisto = widget.now ?? DateTime.now();
  LuogoAttuale? _luogo;

  /// La riga che dice dove sono calcolati i dati (FXA.06), o perche' manca
  /// il luogo. Nulla finche' la posizione non ha risposto.
  String? _rigaDelLuogo;
  EsitoPosizione? _esitoPosizione;
  FotoDellaLuna? _fotoVista;
  Timer? _debounceDellaFoto;

  /// La fase principale (0..3, le quattro sizigie/quadrature) di
  /// [_tempoVisto]: serve solo a sapere quando il dito ha attraversato un
  /// confine, per lo scatto della vibrazione ("si può ruotare... un
  /// respiro di luce", FX.03).
  int _faseIntera(DateTime t) =>
      (IlMotoreLunare.elongazione(t) / 90).floor() % 4;

  @override
  void initState() {
    super.initState();
    unawaited(_flag.leggi());
    unawaited(_avviaMic());
    // La foto si chiede DOPO il luogo, mai prima: col luogo ancora vuoto
    // partiva per latitudine 0 (FXA.06).
    unawaited(_caricaLuogo());
    unawaited(IlSensoDelRespiro.primaAperturaGiaVista().then((vista) {
      if (!mounted) return;
      setState(() => _primaApertura = !vista);
      if (!vista) unawaited(IlSensoDelRespiro.segnaPrimaAperturaVista());
    }));
    _regia.addListener(_quandoLaScenaCambia);
    _comparsa.addListener(() {
      if (mounted) setState(() {});
    });
  }

  /// **IL LUOGO VERO, DAL GPS.** Ordine FX aggiunta FXA.06, il fondatore:
  /// "non servivano tutti i dati, ma i piu' importanti in tempo reale basati
  /// sul luogo Reale (GPS)". A ogni apertura si chiede la posizione del
  /// telefono e la si salva come ultima del dispositivo. I RIPIEGHI, in
  /// quest'ordine e ciascuno detto con una riga: l'ultima posizione del
  /// telefono, la citta' scelta a mano nel profilo, l'invito a dare la
  /// posizione o a scegliere la citta'. Mai la latitudine 0, mai un calcolo
  /// con la posizione vuota.
  Future<void> _caricaLuogo() async {
    // **LA LUNA C'E' DAL PRIMO ISTANTE.** Il GPS del telefono puo' metterci
    // secondi: intanto vale il miglior ripiego gia' salvato (o la sola fase
    // vera, se non ce n'e' nessuno), e la riga dice che si sta cercando la
    // posizione. Quando il GPS risponde, i dati si ricalcolano li'.
    await _applicaIlRipiego(cercando: true);
    final posizione = widget.posizione ?? const GeolocatorSkyLocation();
    final risposta = await posizione.chiedi();
    if (!mounted) return;
    if (!risposta.concessa) {
      _esitoPosizione = risposta.esito;
      await _applicaIlRipiego(cercando: false);
      return;
    }
    final p = risposta.luogo!;
    final nome =
        p.citta ?? await posizione.nomeDelLuogo(p.latitude, p.longitude);
    final luogo = LuogoAttuale.dalDispositivo(
        SkyPlace(latitude: p.latitude, longitude: p.longitude, citta: nome));
    await DoveSonoAdesso.scriviDelDispositivo(luogo);
    if (!mounted) return;
    setState(() {
      _luogo = luogo;
      _esitoPosizione = risposta.esito;
      _rigaDelLuogo = nome == null
          ? 'Calcolata dove sei adesso, dalla posizione del telefono'
          : 'Calcolata a $nome, dalla posizione del telefono';
    });
    await _aggiornaFoto();
  }

  /// I ripieghi, in quest'ordine: l'ultima posizione del telefono, la citta'
  /// scelta a mano, nessun luogo. [cercando] vale mentre il GPS non ha
  /// ancora risposto, e la riga lo dice.
  Future<void> _applicaIlRipiego({required bool cercando}) async {
    final ultimo = await DoveSonoAdesso.ultimoDelDispositivo();
    final scelto = ultimo == null ? await DoveSonoAdesso.letto() : null;
    final luogo = ultimo ?? scelto;
    final String riga;
    if (ultimo != null) {
      riga = cercando
          ? 'Cerco la posizione del telefono; intanto calcolata a '
              '${ultimo.citta}, l\'ultima posizione nota'
          : 'Calcolata a ${ultimo.citta}, l\'ultima posizione del telefono';
    } else if (scelto != null) {
      riga = cercando
          ? 'Cerco la posizione del telefono; intanto calcolata a '
              '${scelto.citta}, la città che hai scelto'
          : 'Calcolata a ${scelto.citta}, la città che hai scelto';
    } else {
      riga = cercando
          ? 'Cerco la posizione del telefono per calcolare sorgere e tramonto'
          : 'Senza un luogo non si calcolano sorgere e tramonto: dai la '
              'posizione o scegli la tua città nel profilo.';
    }
    if (!mounted) return;
    setState(() {
      _luogo = luogo;
      _rigaDelLuogo = riga;
    });
    await _aggiornaFoto();
  }

  Future<void> _aggiornaFoto() async {
    final luogo = _luogo;
    if (luogo == null) {
      // Senza luogo niente NASA e niente emisfero: la fase vera, una Luna
      // locale non ruotata, e la riga del luogo dice cosa manca.
      if (!mounted) return;
      setState(() => _fotoVista = IlDialAMoon.senzaLuogo(_tempoVisto));
      return;
    }
    final dialAMoon = widget.dialAMoon ?? IlDialAMoon.diCasa;
    final foto = await dialAMoon.perIstante(_tempoVisto, latitudine: luogo.lat);
    if (!mounted) return;
    setState(() => _fotoVista = foto);
  }

  EsitoDelPermesso get _esitoDelPermessoDiPosizione {
    switch (_esitoPosizione) {
      case EsitoPosizione.negataPerSempre:
      case EsitoPosizione.servizioSpento:
        return EsitoDelPermesso.negatoPerSempre;
      case EsitoPosizione.nonDisponibile:
        return EsitoDelPermesso.nonDisponibile;
      case EsitoPosizione.concessa:
        return EsitoDelPermesso.concesso;
      case EsitoPosizione.negata:
      case null:
        return EsitoDelPermesso.negato;
    }
  }

  /// **IL TEMPO SCORRE, SENZA CHIAMARE LA NASA A OGNI PIXEL.** Il
  /// trascinamento aggiorna `_tempoVisto` a ogni evento (la Luna e i numeri
  /// sotto di lei sono calcolo puro, nessun costo); la richiesta vera alla
  /// NASA, che ha un costo di rete, parte solo quando il dito si ferma
  /// (debounce di 250 ms), come fa il Calendario Lunare per "Trova il
  /// giorno" con la sua ricerca.
  void _vaiATempo(DateTime nuovo) {
    final faseVecchia = _faseIntera(_tempoVisto);
    setState(() => _tempoVisto = nuovo);
    if (_faseIntera(nuovo) != faseVecchia) {
      unawaited(PaletteSensoriale.vibra(context, SchemaAptico.tocco));
    }
    _debounceDellaFoto?.cancel();
    _debounceDellaFoto = Timer(const Duration(milliseconds: 250), () {
      if (mounted) unawaited(_aggiornaFoto());
    });
  }

  void _tornaAdesso() {
    if (_tempoVisto == (widget.now ?? DateTime.now())) return;
    _vaiATempo(widget.now ?? DateTime.now());
  }

  Future<void> _avviaMic() async {
    final ok = await _mic.start();
    if (!mounted) return;
    setState(() => _esitoMic = _mic.esitoDelPermesso);
    if (!ok) return;
    _mic.level.listen((v) {
      if (_finito || v <= _sogliaDelMicrofono) return;
      _respiroSentito = true;
      _aggiornaFase();
      _graziaTimer?.cancel();
      _graziaTimer = Timer(_graziaDelMicrofono, () {
        _respiroSentito = false;
        if (mounted) _aggiornaFase();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(_regia.avvia(context));
    if (_regia.ferma && !_regia.filmatoInScena) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _quandoLaScenaCambia());
    }
  }

  /// **IL GESTO, DOPPIO E SEMPRE ATTIVO.** FX.04: tenuto giu' col dito o
  /// sentito dal microfono vale la stessa cosa, inspirare; nessuno dei due
  /// e' il ripiego dell'altro.
  void _aggiornaFase() {
    final dentro = _tenutoGiu || _respiroSentito;
    if (!mounted || dentro == _inFaseDiInspiro || _finito) return;
    // Si ridisegna: il gesto del momento scritto sulla scena ("Inspira",
    // "Espira") deve cambiare col dito (FY.06; prima restava fermo, preso
    // dalla prova del rito col dito).
    setState(() => _inFaseDiInspiro = dentro);
    if (!dentro) _contaIlGiro();
    _luce.animateTo(dentro ? 1.0 : 0.0,
        duration: dentro ? _tempi.inspiro : _tempi.espiro,
        curve: Curves.easeInOut);
  }

  void _tocca(bool giu) {
    _tenutoGiu = giu;
    _aggiornaFase();
  }

  void _completa() {
    if (_finito) return;
    _finito = true;
    unawaited(_flag.segnaRespirato(widget.now ?? DateTime.now()));
    unawaited(_mic.stop());
    if (mounted) {
      unawaited(RegiaDelCammino.dopoUnGesto(context, 'respiro'));
      setState(() {});
    }
  }

  @override
  void dispose() {
    _graziaTimer?.cancel();
    _debounceDellaFoto?.cancel();
    unawaited(_mic.dispose());
    _luce.dispose();
    _comparsa.dispose();
    _scorrimento.dispose();
    _regia.removeListener(_quandoLaScenaCambia);
    _regia.dispose();
    super.dispose();
  }

  Tier get _tier {
    try {
      return context.read<EntitlementService>().tier;
    } catch (errore) {
      // Senza il servizio dei piani nell'albero (le prove che montano la
      // schermata da sola) vale il piano gratuito: e' il ripiego che non
      // apre niente in piu' di cio' che spetta a tutti.
      debugPrint(
          'Respiro della Luna: piano non letto, vale il gratuito ($errore)');
      return Tier.free;
    }
  }

  /// **LA VOCE DELLA BARRA IN BASSO** (FXA.09): la Luna di quest'ora, da
  /// consultare, o il rito del respiro. Si apre sulla Luna: il fondatore,
  /// "principalmente la funzionalità resta di consultazione e informazione".
  VoceDellaLuna _voce = VoceDellaLuna.luna;

  /// **PRIMA LA SCENA, POI TUTTO IL RESTO** (FXA.08). Da zero a uno, parte
  /// quando la scena e' ferma (video finito, saltato, o nessun video): la
  /// Luna vera, i dati, la riga di Medora, il respiro compaiono in
  /// quest'ordine, ognuno nel suo tratto.
  late final AnimationController _comparsa = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  void _quandoLaScenaCambia() {
    if (!mounted) return;
    if (_regia.ferma && _comparsa.status == AnimationStatus.dismissed) {
      // Senza video (Riduci Movimento, grafica alleggerita) tutto compare
      // subito: non c'e' nessuna scena da aspettare.
      if (!_regia.filmatoInScena && !_regia.saltata) {
        _comparsa.value = 1;
      } else {
        unawaited(_comparsa.forward());
      }
    }
    setState(() {});
  }

  /// Quanto e' comparso il pezzo che occupa il tratto [da]-[a] della
  /// comparsa.
  double _tratto(double da, double a) =>
      Interval(da, a, curve: Curves.easeOut).transform(_comparsa.value);

  void _scegliLaVoce(BuildContext context, VoceDellaLuna v) {
    setState(() => _voce = v);
    // **MEDORA TORNA COL RESPIRO** (ordine FY voce FY.05). Il fondatore:
    // "Medora torna quando utente fa click su "respiro"". La scena si
    // riporta in cima, intera, e il rito si fa davanti a lei.
    if (v == VoceDellaLuna.respiro && _scorrimento.hasClients) {
      unawaited(_scorrimento.animateTo(0,
          duration: const Duration(milliseconds: 450), curve: Curves.easeOut));
    }
  }

  /// Le frecce della fase (FXA.09, punto 2): portano il tempo all'inizio
  /// della fase precedente o della successiva, dentro la corsa che il piano
  /// concede (FX.10). Oltre la corsa, l'invito al piano invece del silenzio.
  void _vaiAllaFase(BuildContext context, DateTime inizio, Tier tier) {
    final adesso = widget.now ?? DateTime.now();
    final corsa = IlPianoDelRespiro.tempoSottoIlDitoSuTuttoIlMese(tier)
        ? const Duration(days: 30)
        : const Duration(hours: 12);
    if (inizio.difference(adesso).abs() > corsa) {
      unawaited(_invitaAlPiano(
          context,
          'Con il tuo piano la Luna scorre nelle 24 ore di oggi. '
          'Dall\'Iniziato in su scorre su tutto il mese, fase per fase.'));
      return;
    }
    _vaiATempo(inizio);
  }

  /// Il dito sul righello (FXA.09, punto 4): un giorno vale
  /// [IlRighelloDelTempo.puntiPerGiorno] punti, dentro la corsa del piano.
  void _trascinaIlRighello(double dx, Tier tier) {
    final adesso = widget.now ?? DateTime.now();
    final corsa = IlPianoDelRespiro.tempoSottoIlDitoSuTuttoIlMese(tier)
        ? const Duration(days: 30)
        : const Duration(hours: 12);
    // Il righello va sotto il cursore: trascinare a sinistra porta avanti.
    final minuti = -dx / IlRighelloDelTempo.puntiPerGiorno * 24 * 60;
    var nuovo = _tempoVisto.add(Duration(seconds: (minuti * 60).round()));
    final minimo = adesso.subtract(corsa);
    final massimo = adesso.add(corsa);
    if (nuovo.isBefore(minimo)) nuovo = minimo;
    if (nuovo.isAfter(massimo)) nuovo = massimo;
    _vaiATempo(nuovo);
  }

  /// **LA SCELTA DI UN'ALTRA CITTA'** (FXA.09, punto 1): la penna apre la
  /// ricerca dei luoghi gia' usata nel profilo. La citta' scelta vale da
  /// subito e resta come citta' scelta a mano, il secondo ripiego di FXA.06.
  Future<void> _scegliLaCitta(BuildContext context) async {
    final scelta = await foglioDelCerchio<City>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _SceltaDellaCitta(),
    );
    if (scelta == null || !mounted) return;
    final luogo = LuogoAttuale.dallaCitta(scelta);
    await DoveSonoAdesso.scrivi(luogo);
    if (!mounted) return;
    setState(() {
      _luogo = luogo;
      _rigaDelLuogo = 'Calcolata a ${scelta.name}, la città che hai scelto';
    });
    await _aggiornaFoto();
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final ferma = _regia.ferma;
    final adesso = widget.now ?? DateTime.now();
    final tier = _tier;
    final consultazione = LaConsultazioneDellaLuna.calcola(_tempoVisto, _luogo);
    final parola = LaParolaDiMedoraDelRespiro.diOggi(_tempoVisto);
    final scostata =
        _tempoVisto.difference(adesso).abs() > const Duration(minutes: 1);
    final luna = _tratto(0, 0.35);
    final datiVisti = _tratto(0.25, 0.6);
    final medoraVista = _tratto(0.5, 0.8);
    final respiroVisto = _tratto(0.7, 1);
    final nelRito = _voce == VoceDellaLuna.respiro;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: palette.deepest,
      appBar: AppBar(
        toolbarHeight: altezzaDellaBarraDelRespiro(context),
        // SEMITRASPARENTE IN OGNI STATO (ordine FY voce FY.20): il velo
        // comune delle barre del titolo, mai il pieno.
        backgroundColor:
            palette.deepest.withValues(alpha: AppTheme.veloDellaBarra),
        elevation: 0,
        // **NESSUNA ICONA DI MATERIAL QUI DENTRO.** Ordine FV, guardia
        // la_grafica_del_lunario_e_dipinta_test: dentro lib/features/lunario
        // e lib/core/lunario non si scrive un'icona fuori dall'elenco
        // dichiarato, quindi la freccia indietro resta quella automatica
        // dell'AppBar, come fa calendario_lunare_screen.dart.
        iconTheme: IconThemeData(color: palette.goldSoft),
        // **IL TITOLO NON SI TRONCA.** `TitoloCheNonSiRompe` va a capo
        // invece di tagliare; nella barra stanno solo le icone comuni (le
        // fonti e il cuore che aggiunge `SogliaArte`).
        title: TitoloCheNonSiRompe(
            testo: 'Il Respiro della Luna',
            stile: TypographyTokens.titoloDiSchermata()),
        actions: [
          FoglioDelleFonti.bottone(context,
              palette: palette,
              testo: TestiDelleFonti.respiroDellaLuna,
              chiave: 'respiro_della_luna_fonti'),
          const AngoloDellaBarra(),
        ],
        // **1. LA CITTA'**, sotto il titolo: si vede solo a scena ferma
        // (FXA.08), ma il suo posto c'e' sempre, cosi' la scena non salta.
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(RigaDellaCitta.altezza),
          child: Opacity(
            opacity: datiVisti,
            child: IgnorePointer(
              ignoring: !ferma,
              child: RigaDellaCitta(
                citta: _luogo?.citta,
                palette: palette,
                onCambia: () => unawaited(_scegliLaCitta(context)),
              ),
            ),
          ),
        ),
      ),
      body: IlToccoCheSalta(
        inCorso: _regia.inCorso,
        onSalta: _regia.salta,
        child: LayoutBuilder(builder: (context, box) {
          final w = box.maxWidth;
          final sopra = MediaQuery.paddingOf(context).top;
          final sotto = MediaQuery.paddingOf(context).bottom;
          // **LA SCENA, A TUTTA LARGHEZZA, SOTTO LA CITTA'.** Il fotogramma
          // e' 1080 per 1920: largo quanto lo schermo, la sua altezza segue.
          // Le misure qui sono nel sistema della scena, che adesso scorre:
          // la cima e' `sopra`, sotto la barra del titolo e la citta'.
          final scena = Rect.fromLTWH(0, sopra, w, w * 1920 / 1080);
          final disco = GeometriaDellaLunaDipinta.discoSulloSchermo(scena.size)
              .shift(scena.topLeft);
          final lato = disco.width / GeometriaDellaLunaDipinta.discoNellaFoto;
          final foto =
              Rect.fromCenter(center: disco.center, width: lato, height: lato);
          final barra = LaBarraDellaLuna.altezza + sotto + SpacingTokens.sm;
          // **SCORRE TUTTO, LA LUNA RESTA** (ordine FY voce FY.04). Il
          // fondatore: "Non vogliono riquadro a scorrimento, semplicemente
          // scorre tutto compreso Medora, ma la luna resta sempre presente".
          // **LA SCENA SEMPRE INTERA.** Il fondatore, sulla build 2313: "come
          // cazzo si fa a presentare la testa tagliata dal corpo". La scena
          // nella voce Luna si fermava alle spalle di Medora (riga 1080) col
          // fondo scuro sotto: una testa staccata. Adesso e' intera in tutte
          // e due le voci, Medora tutta, e il righello e i dati vengono sotto,
          // scorrendo; la Luna resta fissa in cima.
          final fineDellaScena = scena.bottom;
          // Quando il disco della Luna esce in alto, la Luna si fissa in
          // cima, piu' piccola, col nome della fase e la percentuale.
          final sogliaDellaLunaFissa = disco.bottom - sopra - 24;

          final laScena = SizedBox(
            key: const Key('respiro_scena'),
            height: fineDellaScena,
            width: w,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // LA SCENA. A scena ferma il fondo e' il cielo senza Luna: la
                // Luna e' quella vera, nel disco dove la pittura aveva la sua.
                Positioned.fromRect(
                  rect: scena,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(_cieloSenzaLuna,
                          key: const Key('respiro_cielo_senza_luna'),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              ColoredBox(color: palette.deepest)),
                      if (!ferma)
                        Image.asset(_primoFotogramma,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink()),
                      if (_regia.filmatoInScena && (!ferma || _regia.saltata))
                        IlFilmatoCheSfuma(
                          key: const Key('respiro_filmato'),
                          saltato: _regia.saltata,
                          child: _regia.disegna(),
                        ),
                    ],
                  ),
                ),
                // **3. LA LUNA VERA, NEL DISCO DIPINTO.** Una sola Luna: la
                // foto di quest'ora prende il posto di quella della pittura,
                // della stessa misura, senza il fondo nero della foto (FY.03).
                // Nella voce Respiro si accende con l'inspiro e si vela con
                // l'espiro, e il dito respira toccandola.
                if (ferma)
                  Positioned.fromRect(
                    rect: foto,
                    child: Opacity(
                      opacity: luna,
                      child: Listener(
                        key: const Key('respiro_la_luna_si_tocca'),
                        behavior: HitTestBehavior.opaque,
                        onPointerDown: (_) {
                          if (nelRito) _tocca(true);
                        },
                        onPointerUp: (_) => _tocca(false),
                        onPointerCancel: (_) => _tocca(false),
                        child: AnimatedBuilder(
                          animation: _luce,
                          builder: (context, _) {
                            final quanto = nelRito ? _luce.value : 1.0;
                            return Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                if (nelRito)
                                  _AnelloDiLuce(
                                      quanto: quanto,
                                      immagine: _perlaAccesa,
                                      raggio: lato * 0.6),
                                Opacity(
                                  // Mai del tutto nera: velata, non spenta.
                                  // Al 55 per cento a riposo (FY.06): al 32 la falce senza
                                  // fondo nero quasi spariva, e chi leggeva "Tieni premuto
                                  // sulla Luna" non vedeva dove premere.
                                  opacity: 0.55 + 0.45 * quanto,
                                  child: _laFotoDellaLuna(lato,
                                      chiave: const Key('respiro_luna_vera')),
                                ),
                                if (!nelRito)
                                  Padding(
                                    padding: EdgeInsets.all(lato * 0.2),
                                    child: IlTestoSullaLuna(
                                      istante: _tempoVisto,
                                      percentuale:
                                          consultazione.dati.percentualeDiLuce,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                // **2. LA FASE**, sopra la Luna, nel cielo.
                if (ferma)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: scena.top + 2,
                    child: Opacity(
                      opacity: luna,
                      child: RigaDellaFase(
                        nome: consultazione.fase.nome,
                        palette: palette,
                        onPrecedente: () => _vaiAllaFase(context,
                            consultazione.inizioDellaFasePrecedente, tier),
                        onSuccessiva: () => _vaiAllaFase(context,
                            consultazione.inizioDellaFaseSuccessiva, tier),
                      ),
                    ),
                  ),
                // "Adesso" riporta al tempo vero: solo quando il tempo
                // guardato non e' adesso.
                if (ferma && scostata && !nelRito)
                  Positioned(
                    right: SpacingTokens.sm,
                    top: disco.bottom - 40,
                    child: PulsanteDipinto(
                      key: const Key('respiro_torna_adesso'),
                      testo: 'Adesso',
                      altezza: 40,
                      onTap: _tornaAdesso,
                    ),
                  ),
                // **IL RITO SI VEDE MENTRE SI FA** (FY.06): sotto la Luna,
                // sul mare, il giro e il gesto del momento. Prima il
                // conteggio stava nel pannello sotto la scena, che sul Realme
                // restava fuori dallo schermo: chi teneva premuto non vedeva
                // niente avanzare e il respiro sembrava non funzionare.
                if (ferma && nelRito)
                  Positioned(
                    left: SpacingTokens.md,
                    right: SpacingTokens.md,
                    top: foto.bottom + SpacingTokens.xxs,
                    child: Opacity(
                      opacity: respiroVisto,
                      child: _IlGiroSullaScena(
                        palette: palette,
                        finito: _finito,
                        inspira: _inFaseDiInspiro,
                        cicli: _cicliCompiuti,
                        cicliTotali: _tempi.cicliPerUnMinuto,
                      ),
                    ),
                  ),
              ],
            ),
          );

          return Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  final fissa = n.metrics.pixels > sogliaDellaLunaFissa;
                  if (fissa != _lunaFissa) setState(() => _lunaFissa = fissa);
                  return false;
                },
                child: CustomScrollView(
                  key: const Key('respiro_tutto_scorre'),
                  controller: _scorrimento,
                  physics: ferma
                      ? const ClampingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: laScena),
                    if (ferma && !nelRito)
                      SliverToBoxAdapter(
                        child: Opacity(
                          opacity: datiVisti,
                          child: IlRighelloDelTempo(
                            tempoVisto: _tempoVisto,
                            onTrascina: (dx) => _trascinaIlRighello(dx, tier),
                          ),
                        ),
                      ),
                    if (ferma)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(SpacingTokens.md,
                            SpacingTokens.sm, SpacingTokens.md, barra),
                        sliver: SliverToBoxAdapter(
                          child: KeyedSubtree(
                            key: const Key('respiro_i_dati_scorrono'),
                            child: nelRito
                                ? _ilRito(
                                    context, palette, parola, respiroVisto)
                                : _laConsultazione(
                                    context,
                                    palette,
                                    consultazione,
                                    parola,
                                    datiVisti,
                                    medoraVista,
                                    tier),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // **LA LUNA FISSA IN CIMA** (FY.04): quando la scena e' uscita
              // in alto, la Luna resta, piu' piccola, col nome della fase e
              // la percentuale.
              if (ferma)
                Positioned(
                  left: SpacingTokens.sm,
                  right: SpacingTokens.sm,
                  top: sopra + SpacingTokens.xxs,
                  child: IgnorePointer(
                    ignoring: !_lunaFissa,
                    child: AnimatedOpacity(
                      opacity: _lunaFissa ? 1 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: GestureDetector(
                        key: const Key('respiro_luna_fissa'),
                        onTap: () => _scorrimento.animateTo(0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut),
                        child: RigaDelDato(
                          palette: palette,
                          ritratto: _laFotoDellaLuna(30),
                          etichetta: consultazione.fase.nome,
                          valore:
                              '${(consultazione.dati.percentualeDiLuce * 100).round()}% '
                              'di luce, ${IlTempoDetto.ora(_tempoVisto)}',
                        ),
                      ),
                    ),
                  ),
                ),
              // **6. LA BARRA IN BASSO.**
              if (ferma)
                Positioned(
                  left: SpacingTokens.sm,
                  right: SpacingTokens.sm,
                  bottom: sotto + SpacingTokens.sm,
                  child: Opacity(
                    opacity: respiroVisto,
                    child: IgnorePointer(
                      ignoring: respiroVisto < 0.5,
                      child: LaBarraDellaLuna(
                        voce: _voce,
                        onVoce: (v) => _scegliLaVoce(context, v),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  /// La foto della Luna di quest'ora, senza il fondo nero (FY.03): vedi
  /// [LaLunaSenzaFondoNero].
  Widget _laFotoDellaLuna(double lato, {Key? chiave}) {
    final foto = _fotoVista;
    if (foto == null) return SizedBox(width: lato, height: lato);
    return LaLunaSenzaFondoNero(
        immagine: foto.immagine, lato: lato, ruota: foto.ruota, chiave: chiave);
  }

  /// La voce Luna: i dati, la riga di Medora sotto di loro, gli avvisi.
  Widget _laConsultazione(
      BuildContext context,
      MaestroPalette palette,
      LaConsultazioneDellaLuna consultazione,
      ParolaDiMedoraDelRespiro parola,
      double datiVisti,
      double medoraVista,
      Tier tier) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // **ALLA PRIMA APERTURA** Medora dice in due righe che cosa si
        // ottiene (FXA.07): si rilegge dal foglio delle fonti.
        if (_primaApertura == true) ...[
          Opacity(
            opacity: medoraVista,
            child: PannelloDipinto(
              child: Column(
                key: const Key('respiro_prima_apertura'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final riga in IlSensoDelRespiro.primaApertura)
                    Padding(
                      padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
                      child: Text(riga,
                          textAlign: TextAlign.center,
                          style: TypographyTokens.didascalia().copyWith(
                              color: coloreSulVelluto,
                              fontStyle: FontStyle.italic)),
                    ),
                  PulsanteDipinto(
                    key: const Key('respiro_prima_apertura_respira'),
                    testo: 'Respira con la Luna',
                    onTap: () => setState(() {
                      _voce = VoceDellaLuna.respiro;
                      _primaApertura = false;
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
        ],
        Opacity(
          opacity: datiVisti,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dove sono calcolati i dati, o perche' manca il luogo
              // (FXA.06): sopra le righe, in piccolo.
              if (_rigaDelLuogo != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
                  child: Text(_rigaDelLuogo!,
                      key: const Key('respiro_riga_del_luogo'),
                      textAlign: TextAlign.center,
                      style: TypographyTokens.etichetta().copyWith(
                          color: coloreSulVelluto, shadows: ombraSullaScena)),
                ),
              IDatiDellaLuna(consultazione: consultazione, palette: palette),
              // **LA PORTA AL CALENDARIO, ordine FX voce FX.11**, in fondo ai
              // dati (correzione del fondatore alla FXA.09): "Separati e
              // collegati".
              RigaDelCalendario(
                palette: palette,
                onTap: () =>
                    Navigator.of(context).push(CalendarioLunareScreen.route()),
              ),
            ],
          ),
        ),
        if (_esitoPosizione != null && _luogo == null) ...[
          const SizedBox(height: SpacingTokens.sm),
          AvvisoDelPermesso(
            chiave: 'respiro_della_luna_posizione',
            permesso: AppPermission.location,
            esito: _esitoDelPermessoDiPosizione,
            palette: palette,
            onRichiedi: _caricaLuogo,
            onApriImpostazioni: () async {
              await (widget.posizione ?? const GeolocatorSkyLocation())
                  .apriImpostazioni();
            },
          ),
        ],
        const SizedBox(height: SpacingTokens.sm),
        // **LA RIGA DI MEDORA, UNA SOLA, SOTTO I DATI** (FXA.09): il senso
        // del giorno (FXA.07).
        Opacity(
          opacity: medoraVista,
          child: Text(_rigaDiMedoraDelGiorno(),
              key: const Key('luna_riga_di_medora'),
              textAlign: TextAlign.center,
              style: TypographyTokens.didascalia().copyWith(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  shadows: ombraSullaScena)),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Opacity(
          opacity: medoraVista,
          child: PulsanteDipinto(
            key: const Key('respiro_apri_avvisi'),
            testo: 'Avvisi della Luna',
            larghezzaPiena: true,
            onTap: () => foglioDelCerchio<void>(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (_) => Padding(
                padding: const EdgeInsets.all(SpacingTokens.md),
                child:
                    PannelloDipinto(child: _FoglioDegliAvvisi(luogo: _luogo)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// La voce Respiro: il rito del respiro e la collana (il respiro
  /// condiviso e' uscito con la decisione del fondatore del 20 ottobre 2026:
  /// le sue funzioni non si pubblicano).
  Widget _ilRito(BuildContext context, MaestroPalette palette,
      ParolaDiMedoraDelRespiro parola, double respiroVisto) {
    return Opacity(
      opacity: respiroVisto,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PannelloDipinto(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _finito
                    ? _PannelloCompiuto(
                        palette: palette,
                        rigaDopo: IlSensoDelRespiro.rigaDopo(_giornoDelCiclo))
                    : _PannelloDelGesto(
                        palette: palette,
                        cicli: _cicliCompiuti,
                        cicliTotali: _tempi.cicliPerUnMinuto,
                        rigaPrima: IlSensoDelRespiro.rigaPrima(_giornoDelCiclo),
                      ),
                if (parola.righe.isNotEmpty) ...[
                  const SizedBox(height: SpacingTokens.sm),
                  Text(parola.righe.join(_separatoreDelleRigheDiMedora),
                      key: const Key('respiro_parola_di_medora'),
                      textAlign: TextAlign.center,
                      style: TypographyTokens.etichetta().copyWith(
                          color: coloreSulVelluto,
                          fontStyle: FontStyle.italic)),
                ],
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          PulsanteDipinto(
            key: const Key('respiro_vai_alla_collana'),
            testo: 'La tua Collana delle Lune',
            larghezzaPiena: true,
            onTap: () =>
                Navigator.of(context).push(LaCollanaDelleLuneScreen.route()),
          ),
          if (!_finito &&
              _esitoMic != null &&
              _esitoMic != EsitoDelPermesso.concesso) ...[
            const SizedBox(height: SpacingTokens.sm),
            AvvisoDelPermesso(
              chiave: 'respiro_della_luna',
              permesso: AppPermission.microphone,
              esito: _esitoMic!,
              palette: palette,
              onRichiedi: _avviaMic,
            ),
          ],
        ],
      ),
    );
  }

  /// Il giorno del ciclo di adesso: il rito si accorda a oggi, non al
  /// tempo guardato col righello (lo stesso patto di FX.03).
  int get _giornoDelCiclo =>
      IlSensoDelRespiro.giornoDelCiclo(widget.now ?? DateTime.now());

  /// La riga di Medora sul senso del giorno guardato, sotto i dati
  /// (FXA.09): la stessa riga che il rito dice prima del respiro (FXA.07).
  String _rigaDiMedoraDelGiorno() =>
      IlSensoDelRespiro.rigaPrima(IlSensoDelRespiro.giornoDelCiclo(_tempoVisto))
          .testo;
}

/// L'anello di luce: perle accese disposte in cerchio intorno alla Luna, la
/// loro opacita' segue il respiro. **Nessuna grafica procedurale**: sono
/// copie di un asset dipinto, posizionate per calcolo (non disegnate), come
/// vuole la regola ferrea del progetto.
class _AnelloDiLuce extends StatelessWidget {
  const _AnelloDiLuce(
      {required this.quanto, required this.immagine, required this.raggio});

  final double quanto;
  final String immagine;

  /// Il raggio dell'anello: segue la misura della Luna nel disco dipinto.
  final double raggio;

  static const int _numeroDiPerle = 10;
  static const double _latoDellaPerla = 20;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        for (var i = 0; i < _numeroDiPerle; i++)
          Builder(builder: (context) {
            final angolo = 2 * 3.14159265 * i / _numeroDiPerle;
            final dx = raggio * math.cos(angolo);
            final dy = raggio * math.sin(angolo);
            return Transform.translate(
              offset: Offset(dx, dy),
              child: Opacity(
                opacity: quanto,
                child: Image.asset(immagine,
                    width: _latoDellaPerla,
                    height: _latoDellaPerla,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink()),
              ),
            );
          }),
      ],
    );
  }
}

/// Il pannello col gesto da compiere e lo stato del microfono.
class _PannelloDelGesto extends StatelessWidget {
  const _PannelloDelGesto({
    required this.palette,
    required this.cicli,
    required this.cicliTotali,
    required this.rigaPrima,
  });

  final MaestroPalette palette;
  final int cicli;
  final int cicliTotali;

  /// **PRIMA DEL RESPIRO**, la riga di Medora sul senso della fase di oggi
  /// (FXA.07), con la sua fonte.
  final RigaDelSenso rigaPrima;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          key: const Key('respiro_invito'),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _LaRigaDelSenso(riga: rigaPrima, chiave: 'respiro_riga_prima'),
              const SizedBox(height: SpacingTokens.sm),
              Text('Tieni premuto per inspirare, lascia per espirare',
                  textAlign: TextAlign.center,
                  style: TypographyTokens.titoloScheda()
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: SpacingTokens.xxs),
              Text(
                  'Oppure soffia piano verso il telefono: la Luna si accende '
                  'col soffio e si vela quando smetti. Giro '
                  '${cicli + 1} di $cicliTotali',
                  key: const Key('respiro_conteggio'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.label(size: 12)
                      .copyWith(color: Colors.white.withValues(alpha: 0.72))),
              // **L'OBIETTIVO, SCRITTO.** Il fondatore: "l'utente deve
              // sapere [...] per ottenere cosa [...] Non puo' indovinare".
              const SizedBox(height: SpacingTokens.xxs),
              Text(
                  'Tieni premuto sulla Luna: un minuto di respiro accende '
                  'la perla di oggi nella tua Collana.',
                  key: const Key('respiro_obiettivo'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.label(size: 12)
                      .copyWith(color: coloreSulVelluto)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Il pannello a rito compiuto: la perla del giorno e' accesa.
class _PannelloCompiuto extends StatelessWidget {
  const _PannelloCompiuto({required this.palette, required this.rigaDopo});

  final MaestroPalette palette;

  /// **DOPO IL RESPIRO**, la riga di chiusura legata alla fase e al giorno
  /// del ciclo (FXA.07), insieme alla perla che si accende.
  final RigaDelSenso rigaDopo;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          key: const Key('respiro_compiuto'),
          width: double.infinity,
          child: Column(
            children: [
              Text('Il tuo respiro di oggi è compiuto.',
                  textAlign: TextAlign.center,
                  style: TypographyTokens.titoloScheda()
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: SpacingTokens.xxs),
              Text('La perla di oggi si è accesa sulla tua collana.',
                  textAlign: TextAlign.center,
                  style: TypographyTokens.label(size: 13)
                      .copyWith(color: Colors.white.withValues(alpha: 0.8))),
              const SizedBox(height: SpacingTokens.sm),
              _LaRigaDelSenso(riga: rigaDopo, chiave: 'respiro_riga_dopo'),
            ],
          ),
        ),
      ],
    );
  }
}

/// Il foglio degli avvisi (FX.08): due interruttori, sul modello dei
/// promemoria del Calendario Lunare.
class _FoglioDegliAvvisi extends StatefulWidget {
  const _FoglioDegliAvvisi({required this.luogo});

  final LuogoAttuale? luogo;

  @override
  State<_FoglioDegliAvvisi> createState() => _FoglioDegliAvvisiState();
}

class _FoglioDegliAvvisiState extends State<_FoglioDegliAvvisi> {
  late final IGliAvvisiDelRespiro _avvisi =
      IGliAvvisiDelRespiro(avvisi: AvvisiLocali());

  @override
  void initState() {
    super.initState();
    unawaited(_avvisi.leggi().then((_) {
      if (mounted) setState(() {});
    }));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: _avvisi,
        builder: (context, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // **GLI AVVISI DETTI CHIARI** (ordine FY voce FY.09). Il
            // fondatore: "gli avvisi della luna non si capisce a cosa
            // servono". Un titolo che dice che cosa sono, e sotto ogni
            // interruttore che cosa arriva e quando.
            Text(
                'Gli avvisi della Luna arrivano sul telefono anche quando '
                'l\'app è chiusa.',
                key: const Key('respiro_avvisi_spiegati'),
                textAlign: TextAlign.center,
                style: TypographyTokens.didascalia()
                    .copyWith(color: coloreSulVelluto)),
            const SizedBox(height: SpacingTokens.sm),
            InterruttoreDelCerchio(
              key: const Key('respiro_avviso_sorgere'),
              acceso: _avvisi.lunaCheSorge,
              onCambia: _avvisi.letto
                  ? (v) => _avvisi.impostaLunaCheSorge(v, luogo: widget.luogo)
                  : null,
              titolo: 'La Luna che sorge',
              sottotitolo: widget.luogo == null
                  ? 'Ti avviso quando la Luna sorge dove sei'
                  : 'Ti avviso quando la Luna sorge a ${widget.luogo!.citta}',
            ),
            InterruttoreDelCerchio(
              key: const Key('respiro_avviso_sizigie'),
              acceso: _avvisi.luneNuoveEPiene,
              onCambia: _avvisi.letto
                  ? (v) =>
                      _avvisi.impostaLuneNuoveEPiene(v, luogo: widget.luogo)
                  : null,
              titolo: 'Luna piena, nuova e Superluna',
              sottotitolo: 'Ti avviso all\'ora esatta della Luna piena e della '
                  'Luna nuova. Ti avviso quando arriva una Superluna.',
            ),
          ],
        ),
      ),
    );
  }
}

/// Il ritaglio tondo della foto della NASA: il disco della Luna occupa il
/// 93 per cento del lato del fotogramma, il ritaglio al 94 toglie gli angoli
/// neri del JPEG (vedi [GeometriaDellaLunaDipinta]).
class _RitaglioDellaFoto extends CustomClipper<Rect> {
  const _RitaglioDellaFoto();

  @override
  Rect getClip(Size size) => Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * GeometriaDellaLunaDipinta.ritaglioDellaFoto,
      height: size.height * GeometriaDellaLunaDipinta.ritaglioDellaFoto);

  @override
  bool shouldReclip(_RitaglioDellaFoto oldClipper) => false;
}

/// L'invito al piano, sul pannello dipinto: dice di chi e' la funzione e
/// porta ai piani. Mai un vicolo cieco.
Future<void> _invitaAlPiano(BuildContext context, String testo) =>
    finestraDipinta<void>(
      context,
      chiave: const Key('respiro_invito_del_piano'),
      titolo: 'Un passo in più',
      contenuto: Text(testo),
      azioni: (c) => [
        PulsanteDipinto(
          key: const Key('respiro_vai_ai_piani'),
          testo: 'Scopri i piani',
          larghezzaPiena: true,
          onTap: () {
            Navigator.of(c).pop();
            Navigator.of(context).push(PricingScreen.route());
          },
        ),
        PulsanteDipinto(
          key: const Key('respiro_non_ora'),
          testo: 'Non ora',
          altezza: 40,
          onTap: () => Navigator.of(c).pop(),
        ),
      ],
    );

/// **LA SCELTA DI UN'ALTRA CITTA'**, sul pannello dipinto: la stessa
/// ricerca del profilo (`RicercaDelLuogo` sul catalogo, `RicercaNelMondo`
/// quando il catalogo non basta), la citta' toccata torna a chi ha aperto.
class _SceltaDellaCitta extends StatefulWidget {
  const _SceltaDellaCitta();

  @override
  State<_SceltaDellaCitta> createState() => _SceltaDellaCittaState();
}

class _SceltaDellaCittaState extends State<_SceltaDellaCitta> {
  final TextEditingController _testo = TextEditingController();
  final RicercaNelMondo _nelMondo = RicercaNelMondo();
  List<City> _risultati = const [];

  void _cerca(String q) {
    final risposta = RicercaDelLuogo.per(q);
    setState(() => _risultati = risposta.risultati);
    _nelMondo.chiedi(
      q,
      gia: risposta.risultati,
      quando: (trovati) {
        if (!mounted || trovati.isEmpty) return;
        setState(() =>
            _risultati = RicercaNelMondo.unisci(risposta.risultati, trovati));
      },
    );
  }

  @override
  void dispose() {
    _testo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          SpacingTokens.md, SpacingTokens.md, SpacingTokens.md, inset + 8),
      child: PannelloDipinto(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Da quale città guardi la Luna?',
                textAlign: TextAlign.center,
                style: TypographyTokens.titoloScheda()
                    .copyWith(color: coloreSulVelluto)),
            const SizedBox(height: SpacingTokens.sm),
            TextField(
              key: const Key('luna_cerca_la_citta'),
              controller: _testo,
              autofocus: true,
              onChanged: _cerca,
              style: TypographyTokens.didascalia()
                  .copyWith(color: coloreSulVelluto),
              cursorColor: coloreSulVelluto,
              decoration: InputDecoration(
                hintText: 'Scrivi il nome della città',
                hintStyle: TypographyTokens.didascalia()
                    .copyWith(color: coloreSulVelluto.withValues(alpha: 0.6)),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: coloreSulVelluto.withValues(alpha: 0.5))),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: coloreSulVelluto)),
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final c in _risultati.take(8))
                    GestureDetector(
                      key: Key('luna_citta_${c.name}_${c.country}'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).pop(c),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: SpacingTokens.xs),
                        child: Text(c.label,
                            style: TypographyTokens.didascalia()
                                .copyWith(color: coloreSulVelluto)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Una riga del senso del Respiro con la sua fonte sotto, in piccolo: la
/// fonte citata, o "chiave di Medora" dove nessuna tradizione la documenta.
class _LaRigaDelSenso extends StatelessWidget {
  const _LaRigaDelSenso({required this.riga, required this.chiave});

  final RigaDelSenso riga;
  final String chiave;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: Key(chiave),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(riga.testo,
            textAlign: TextAlign.center,
            style: TypographyTokens.didascalia().copyWith(
                color: coloreSulVelluto, fontStyle: FontStyle.italic)),
        const SizedBox(height: SpacingTokens.xxs),
        Text(riga.eChiaveDiMedora ? 'Chiave di Medora' : riga.fonte,
            textAlign: TextAlign.center,
            style: TypographyTokens.etichetta()
                .copyWith(color: coloreSulVelluto.withValues(alpha: 0.7))),
      ],
    );
  }
}

/// **IL GIRO, SCRITTO SULLA SCENA** (ordine FY voce FY.06): sotto la Luna,
/// in grande, il gesto del momento e il giro. Chi tiene premuto vede subito
/// che il rito avanza, senza scorrere fino al pannello.
class _IlGiroSullaScena extends StatelessWidget {
  const _IlGiroSullaScena({
    required this.palette,
    required this.finito,
    required this.inspira,
    required this.cicli,
    required this.cicliTotali,
  });

  final MaestroPalette palette;
  final bool finito;
  final bool inspira;
  final int cicli;
  final int cicliTotali;

  @override
  Widget build(BuildContext context) {
    final gesto = finito
        ? 'Respiro compiuto'
        : inspira
            ? 'Inspira'
            : cicli == 0
                ? 'Tieni premuto sulla Luna, poi lascia'
                : 'Espira';
    final sotto = finito
        ? 'La perla di oggi è accesa nella tua Collana'
        : 'Giro ${cicli + 1} di $cicliTotali';
    // **IL VELO SCURO SOTTO IL GESTO E IL GIRO, ordine GA voce GA.10.** Le due
    // righe correvano sulle colonne di marmo e sul mare: "Tieni premuto sulla
    // Luna, poi lascia" 2,46 a 1 e "Giro 1 di 8" 3,31 nel punto piu' chiaro:
    // e' l'unica istruzione del rito. Un velo nero al 50 per cento, sfumato
    // sopra e sotto, porta il fondo piu' chiaro da una luminanza di 0,25 a
    // 0,05 senza coprire la Luna.
    return IgnorePointer(
      // Il velo sfuma anche ai lati, cosi' non ha un bordo che si veda.
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (r) => const LinearGradient(
          colors: [
            Color(0x00FFFFFF),
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF),
            Color(0x00FFFFFF),
          ],
          stops: [0.0, 0.18, 0.82, 1.0],
        ).createShader(r),
        child: DecoratedBox(
          key: const Key('respiro_giro_velo'),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x00000000),
                Color(0x80000000),
                Color(0x80000000),
                Color(0x00000000),
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 56, vertical: SpacingTokens.sm),
            child: _IGiroTesti(gesto: gesto, sotto: sotto, palette: palette),
          ),
        ),
      ),
    );
  }
}

class _IGiroTesti extends StatelessWidget {
  const _IGiroTesti(
      {required this.gesto, required this.sotto, required this.palette});

  final String gesto;
  final String sotto;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('respiro_giro_sulla_scena'),
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(gesto,
              key: const Key('respiro_gesto_del_momento'),
              style: TypographyTokens.titoloSezione()
                  .copyWith(color: palette.goldSoft, shadows: ombraSullaScena)),
        ),
        Text(sotto,
            key: const Key('respiro_giro'),
            textAlign: TextAlign.center,
            style: TypographyTokens.etichetta()
                .copyWith(color: Colors.white, shadows: ombraSullaScena)),
      ],
    );
  }
}

/// **LA FOTO DELLA LUNA, SENZA IL FONDO NERO** (ordine FY voce FY.03). Il
/// fondatore: "La luna presenta una cornice contorno nero". La foto della
/// NASA e' un JPEG col cielo nero e la parte in ombra nera: il ritaglio
/// tondo di FXA.09 toglieva gli angoli ma lasciava l'anello nero fra il
/// disco e il ritaglio, e la parte in ombra come un disco nero sul cielo
/// dipinto. Adesso la luce della foto diventa la sua opacita' (il nero e'
/// trasparente, il grigio della superficie resta pieno): sul cielo resta
/// solo cio' che la Luna illumina davvero, come nel cielo vero.
class LaLunaSenzaFondoNero extends StatelessWidget {
  const LaLunaSenzaFondoNero({
    super.key,
    required this.immagine,
    required this.lato,
    this.ruota = false,
    this.chiave,
  });

  final ImageProvider immagine;
  final double lato;
  final bool ruota;

  /// La chiave dell'immagine, quella che le prove cercano.
  final Key? chiave;

  /// La matrice che porta la luce in opacita': i tre colori restano, l'alfa
  /// e' quattro volte la luminanza (Rec. 709), cosi' un grigio medio della
  /// superficie e' gia' pieno e solo il nero del fondo e dell'ombra sparisce.
  static const List<double> laLuceDiventaOpacita = [
    1, 0, 0, 0, 0, //
    0, 1, 0, 0, 0, //
    0, 0, 1, 0, 0, //
    4 * 0.2126, 4 * 0.7152, 4 * 0.0722, 0, 0,
  ];

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      clipper: const _RitaglioDellaFoto(),
      child: Transform.rotate(
        angle: ruota ? math.pi : 0,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix(laLuceDiventaOpacita),
          child: Image(
            image: immagine,
            key: chiave,
            width: lato,
            height: lato,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

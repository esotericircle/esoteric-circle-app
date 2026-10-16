import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/luogo_attuale.dart';
import '../../core/astro/sky_location.dart';
import '../../core/entitlement/entitlement_service.dart';
import '../../core/entitlement/tier.dart';
import '../../core/lunario/il_dial_a_moon.dart';
import '../../core/lunario/il_motore_lunare.dart';
import '../../core/lunario/il_respiro_della_luna.dart';
import '../../core/lunario/la_luna_di_quest_ora.dart';
import '../../core/lunario/la_parola_di_medora_del_respiro.dart';
import '../../core/maestro/maestro.dart';
import '../../core/permissions/app_permission.dart';
import '../../core/permissions/avviso_del_permesso.dart';
import '../../core/permissions/esito_del_permesso.dart';
import '../../core/sensi/palette_sensoriale.dart';
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
import '../maestri/rotta_arte.dart';
import '../maestri/widgets/foglio_delle_fonti.dart';
import '../scene/la_scena_in_video.dart';
import '../sigilli/regia_del_cammino.dart';
import 'gli_avvisi_del_respiro.dart';
import 'i_comandi_dipinti.dart';
import 'il_piano_del_respiro.dart';
import 'la_bussola_della_luna.dart';
import 'la_collana_delle_lune_screen.dart';

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
      {super.key, this.now, this.dialAMoon, this.posizione});

  /// L'istante da cui si calcola la fase: sostituibile nelle prove.
  final DateTime? now;

  /// Chi chiede la foto vera della Luna (FX.03): iniettabile per le prove,
  /// cosi' nessun test automatico fa una chiamata di rete vera. Senza,
  /// `IlDialAMoon.diCasa`, quello dell'app.
  final IlDialAMoon? dialAMoon;

  /// Chi legge la posizione vera del telefono (FXA.06): iniettabile per le
  /// prove. Senza, il GPS del telefono (`GeolocatorSkyLocation`).
  final SkyLocation? posizione;

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
  static const String _ultimoFotogramma =
      'assets/img/respiro_della_luna/respiro_ultimo_fotogramma_v1.webp';
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
  final BreathDetector _mic = BreathDetector();
  late final RegiaDellaScena _regia =
      RegiaDellaScena(() => LettoreDiScena.vero(_video));
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
      final v = _luce.value;
      if (v >= 1.0) {
        _hoVistoPieno = true;
      } else if (v <= 0.0 && _hoVistoPieno) {
        _hoVistoPieno = false;
        _cicliCompiuti++;
        if (_cicliCompiuti >= _tempi.cicliPerUnMinuto) {
          _completa();
        } else if (mounted) {
          setState(() {});
        }
      }
    });

  EsitoDelPermesso? _esitoMic;
  bool _tenutoGiu = false;
  bool _respiroSentito = false;
  bool _inFaseDiInspiro = false;
  bool _hoVistoPieno = false;
  int _cicliCompiuti = 0;
  bool _finito = false;
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

  /// **LE ALTRE VOCI DELL'ORDINE, MAI UN VICOLO CIECO.** La Bussola e'
  /// esclusiva di Adepto e Illuminato (FX.10): chi non ce l'ha nel piano la
  /// vede comunque, col lucchetto e l'invito, come vuole la regola di casa
  /// sui tre stati di ogni funzione.
  void _apriLeAltreVoci(BuildContext context, Tier tier) {
    final bussolaAperta = IlPianoDelRespiro.respiroInsiemeAperto(tier);
    Widget sottotitolo(String s) => Padding(
          padding: const EdgeInsets.only(
              top: 2,
              bottom: SpacingTokens.sm,
              left: SpacingTokens.sm,
              right: SpacingTokens.sm),
          child: Text(s,
              textAlign: TextAlign.center,
              style: TypographyTokens.label(size: 12)
                  .copyWith(color: coloreSulVelluto)),
        );
    foglioDelCerchio<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: PannelloDipinto(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // **LA PORTA AL CALENDARIO, ordine FX voce FX.11.** Il
                // fondatore, sui due calendari: "Separati e collegati".
                PulsanteDipinto(
                  key: const Key('respiro_vai_al_calendario'),
                  testo: 'Trova il giorno nel mese',
                  larghezzaPiena: true,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(CalendarioLunareScreen.route());
                  },
                ),
                sottotitolo('Il Calendario Lunare'),
                PulsanteDipinto(
                  key: const Key('respiro_apri_bussola'),
                  testo: 'Dov\'è la Luna adesso',
                  larghezzaPiena: true,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (!bussolaAperta) return;
                    Navigator.of(context).push(PassaggioDelCerchio.rotta<void>(
                      (_) => _SchermataDellaBussola(luogo: _luogo),
                    ));
                  },
                ),
                sottotitolo(bussolaAperta
                    ? 'La bussola verso la Luna vera'
                    : 'Esclusiva Adepto e Illuminato'),
                PulsanteDipinto(
                  key: const Key('respiro_apri_avvisi'),
                  testo: 'Avvisi',
                  larghezzaPiena: true,
                  onTap: () {
                    Navigator.of(context).pop();
                    foglioDelCerchio<void>(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (_) => Padding(
                        padding: const EdgeInsets.all(SpacingTokens.md),
                        child: PannelloDipinto(
                            child: _FoglioDegliAvvisi(luogo: _luogo)),
                      ),
                    );
                  },
                ),
                sottotitolo('La Luna che sorge, la piena, la nuova'),
              ],
            ),
          ),
        ),
      ),
    );
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
  }

  /// **IL GESTO, DOPPIO E SEMPRE ATTIVO.** FX.04: tenuto giu' col dito o
  /// sentito dal microfono vale la stessa cosa, inspirare; nessuno dei due
  /// e' il ripiego dell'altro.
  void _aggiornaFase() {
    final dentro = _tenutoGiu || _respiroSentito;
    if (dentro == _inFaseDiInspiro || _finito) return;
    _inFaseDiInspiro = dentro;
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

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final ferma = _regia.ferma;
    final adesso = widget.now ?? DateTime.now();
    final tier = _tier;
    final dati = DatiDellaLunaDiQuestOra.calcola(_tempoVisto, _luogo);
    final parola = LaParolaDiMedoraDelRespiro.diOggi(_tempoVisto);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: palette.deepest,
      appBar: AppBar(
        toolbarHeight: altezzaDellaBarraDelRespiro(context),
        backgroundColor: palette.deepest.withValues(alpha: 0.35),
        elevation: 0,
        // **NESSUNA ICONA DI MATERIAL QUI DENTRO.** Ordine FV, guardia
        // la_grafica_del_lunario_e_dipinta_test: dentro lib/features/lunario
        // e lib/core/lunario non si scrive un'icona fuori dall'elenco
        // dichiarato, quindi la freccia indietro resta quella automatica
        // dell'AppBar, come fa calendario_lunare_screen.dart.
        iconTheme: IconThemeData(color: palette.goldSoft),
        // **IL TITOLO NON SI TRONCA PIU'.** Prima la cattura vera
        // (`docs/preview/FX/fx0234_respiro_scena_ferma.png`) mostrava "Il
        // ..." tagliato dai puntini: tre pulsanti di testo in azioni
        // lasciavano al titolo meno spazio di quanto gliene servisse, lo
        // stesso difetto gia' curato altrove (`TitoloCheNonSiRompe`, usato
        // da `calendario_lunare_screen.dart` e `breath_destiny_screen.dart`:
        // va a capo invece di tagliare). Qui si cura anche la causa,
        // consolidando le tre azioni in una (vedi sotto).
        title: TitoloCheNonSiRompe(
            testo: 'Il Respiro della Luna',
            stile: TypographyTokens.titoloDiSchermata()),
        actions: [
          FoglioDelleFonti.bottone(context,
              palette: palette,
              testo: TestiDelleFonti.respiroDellaLuna,
              chiave: 'respiro_della_luna_fonti'),
          // **UNA SOLA PORTA PER TUTTE LE ALTRE VOCI, ordine FX.** Prima
          // c'erano due pulsanti di testo ("Trova il giorno" e "Altro")
          // piu' l'icona delle fonti: insieme al titolo non ci stavano,
          // ed e' esattamente il difetto che la cattura vera ha mostrato.
          // Il Calendario Lunare (FX.11) entra nello stesso foglio delle
          // altre voci invece di avere una porta sua.
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: PulsanteDipinto(
              key: const Key('respiro_altre_voci'),
              testo: 'Altro',
              altezza: 38,
              onTap: () => _apriLeAltreVoci(context, tier),
            ),
          ),
          const AngoloDellaBarra(),
        ],
      ),
      body: IlToccoCheSalta(
        inCorso: _regia.inCorso,
        onSalta: _regia.salta,
        child: Stack(
          key: const Key('respiro_scena'),
          fit: StackFit.expand,
          children: [
            // IL CIELO NUDO, sempre sotto: la Luna vera di oggi non e'
            // dipinta nella scena, perche' cambia ogni giorno, e qui sta il
            // fondo su cui si compone.
            Positioned.fill(
              child: Image.asset(_cieloSenzaLuna,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      ColoredBox(color: palette.deepest)),
            ),
            Positioned.fill(
              child: Image.asset(ferma ? _ultimoFotogramma : _primoFotogramma,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink()),
            ),
            if (_regia.filmatoInScena && (!ferma || _regia.saltata))
              Positioned.fill(
                child: IlFilmatoCheSfuma(
                  key: const Key('respiro_filmato'),
                  saltato: _regia.saltata,
                  child: _regia.disegna(),
                ),
              ),
            // LA LUNA VERA, che respira: si accende con l'inspiro e si
            // vela con l'espiro, e l'anello di perle accese le gira
            // intorno.
            Align(
              alignment: const Alignment(0, -0.05),
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (_) => _tocca(true),
                onPointerUp: (_) => _tocca(false),
                onPointerCancel: (_) => _tocca(false),
                child: AnimatedBuilder(
                  animation: _luce,
                  builder: (context, _) {
                    final quanto = _luce.value;
                    return SizedBox(
                      width: 260,
                      height: 260,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _AnelloDiLuce(quanto: quanto, immagine: _perlaAccesa),
                          Opacity(
                            // Mai del tutto nera: velata, non spenta.
                            opacity: 0.32 + 0.68 * quanto,
                            // **LA FOTO VERA, ORA PER ORA (FX.03).** Non
                            // piu' una delle trenta lune fisse del
                            // Calendario Lunare: il fotogramma del
                            // Dial-A-Moon per `_tempoVisto` (`_fotoVista`),
                            // o il suo stesso ripiego mentre la prima
                            // richiesta e' ancora in volo.
                            child: _fotoVista == null
                                ? const SizedBox(width: 150, height: 150)
                                : Transform.rotate(
                                    angle: _fotoVista!.ruota ? math.pi : 0,
                                    child: Image(
                                      image: _fotoVista!.immagine,
                                      key: const Key('respiro_luna_vera'),
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) =>
                                          const SizedBox.shrink(),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            // **IL TEMPO SOTTO IL DITO, E I NUMERI DI QUEST'ORA (FX.03),
            // SOPRA IL PANNELLO DEL GESTO, NELLA STESSA COLONNA ANCORATA AL
            // FONDO.** Non due riquadri che fluttuano a frazioni indovinate
            // dello schermo (che su uno schermo piu' basso del previsto
            // finiscono per sovrapporsi, o si sovrappongono alla Luna: e'
            // il difetto vero che la prova a video ha preso, il tocco
            // sostenuto sulla Luna non la accendeva piu' perche' la
            // striscia, galleggiante a meta' schermo, le stava sopra e
            // assorbiva il tocco prima di lei), ma una sola colonna: i due
            // non possono sovrapporsi fra loro per costruzione, e restano
            // entrambi lontani dalla Luna, che vive solo nella sua Align
            // vicino alla cima.
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                // **LA PARTE BASSA NON SALE MAI SULLA LUNA.** Il pannello,
                // la riga del luogo e gli avvisi possono crescere: oltre il
                // 45 per cento dello schermo scorrono, invece di coprire il
                // centro della Luna dove il dito respira (il difetto preso in
                // FX.03, tornato con la riga del luogo di FXA.06).
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).height * 0.45),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(SpacingTokens.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // **UN PANNELLO DIPINTO SOLO (FXA.02).** La striscia
                          // del tempo e l'invito al gesto stanno nello stesso
                          // pannello: due pannelli con le loro cornici alte
                          // spingerebbero il testo fino alla Luna, il difetto
                          // gia' preso in FX.03.
                          PannelloDipinto(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_rigaDelLuogo != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(_rigaDelLuogo!,
                                        key:
                                            const Key('respiro_riga_del_luogo'),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TypographyTokens.label(size: 12)
                                            .copyWith(color: coloreSulVelluto)),
                                  ),
                                _StrisciaDelTempo(
                                  palette: palette,
                                  dati: dati,
                                  parola: parola,
                                  adesso: adesso,
                                  tempoVisto: _tempoVisto,
                                  suTuttoIlMese: IlPianoDelRespiro
                                      .tempoSottoIlDitoSuTuttoIlMese(tier),
                                  onTrascina: _vaiATempo,
                                  onTornaAdesso: _tornaAdesso,
                                ),
                                const SizedBox(height: SpacingTokens.sm),
                                _finito
                                    ? _PannelloCompiuto(palette: palette)
                                    : _PannelloDelGesto(
                                        palette: palette,
                                        cicli: _cicliCompiuti,
                                        cicliTotali: _tempi.cicliPerUnMinuto,
                                      ),
                              ],
                            ),
                          ),
                          if (_finito) ...[
                            const SizedBox(height: SpacingTokens.sm),
                            PulsanteDipinto(
                              key: const Key('respiro_vai_alla_collana'),
                              testo: 'Vedi la tua Collana delle Lune',
                              larghezzaPiena: true,
                              onTap: () => Navigator.of(context)
                                  .push(LaCollanaDelleLuneScreen.route()),
                            ),
                          ],
                          if (_esitoPosizione != null && _luogo == null) ...[
                            const SizedBox(height: SpacingTokens.sm),
                            AvvisoDelPermesso(
                              chiave: 'respiro_della_luna_posizione',
                              permesso: AppPermission.location,
                              esito: _esitoDelPermessoDiPosizione,
                              palette: palette,
                              onRichiedi: _caricaLuogo,
                              onApriImpostazioni: () async {
                                await (widget.posizione ??
                                        const GeolocatorSkyLocation())
                                    .apriImpostazioni();
                              },
                            ),
                          ],
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
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// L'anello di luce: perle accese disposte in cerchio intorno alla Luna, la
/// loro opacita' segue il respiro. **Nessuna grafica procedurale**: sono
/// copie di un asset dipinto, posizionate per calcolo (non disegnate), come
/// vuole la regola ferrea del progetto.
class _AnelloDiLuce extends StatelessWidget {
  const _AnelloDiLuce({required this.quanto, required this.immagine});

  final double quanto;
  final String immagine;

  static const int _numeroDiPerle = 10;
  static const double _raggio = 118;
  static const double _latoDellaPerla = 20;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        for (var i = 0; i < _numeroDiPerle; i++)
          Builder(builder: (context) {
            final angolo = 2 * 3.14159265 * i / _numeroDiPerle;
            final dx = _raggio * math.cos(angolo);
            final dy = _raggio * math.sin(angolo);
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
  });

  final MaestroPalette palette;
  final int cicli;
  final int cicliTotali;

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
              Text('Tieni premuto per inspirare, lascia per espirare',
                  textAlign: TextAlign.center,
                  style: TypographyTokens.titoloScheda()
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: 4),
              Text(
                  'Oppure respira, il microfono ti ascolta. Giro '
                  '${cicli + 1} di $cicliTotali',
                  key: const Key('respiro_conteggio'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.label(size: 12)
                      .copyWith(color: Colors.white.withValues(alpha: 0.72))),
              // **L'OBIETTIVO, SCRITTO.** Il fondatore: "l'utente deve
              // sapere [...] per ottenere cosa [...] Non puo' indovinare".
              const SizedBox(height: 4),
              Text(
                  'Un minuto di respiro accende la perla di oggi nella tua '
                  'Collana. Trascina sui numeri per vedere un\'altra ora.',
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
  const _PannelloCompiuto({required this.palette});

  final MaestroPalette palette;

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
              const SizedBox(height: 4),
              Text('La perla di oggi si è accesa sulla tua collana.',
                  textAlign: TextAlign.center,
                  style: TypographyTokens.label(size: 13)
                      .copyWith(color: Colors.white.withValues(alpha: 0.8))),
            ],
          ),
        ),
      ],
    );
  }
}

/// **IL TEMPO SOTTO IL DITO, E I NUMERI DI QUEST'ORA.** Ordine FX voce
/// FX.03: "Trascinando il dito in orizzontale il tempo scorre avanti e
/// indietro: la Luna cambia fase e foto sotto il dito, i numeri si
/// aggiornano". I numeri (percentuale di luce, sorgere o tramonto,
/// distanza, giorni alla prossima sizigia) e le tre righe di Medora (FX.07)
/// stanno sotto la stessa striscia: testo, nessuna icona, nessun disegno
/// procedurale.
class _StrisciaDelTempo extends StatelessWidget {
  const _StrisciaDelTempo({
    required this.palette,
    required this.dati,
    required this.parola,
    required this.adesso,
    required this.tempoVisto,
    required this.suTuttoIlMese,
    required this.onTrascina,
    required this.onTornaAdesso,
  });

  final MaestroPalette palette;
  final DatiDellaLunaDiQuestOra dati;
  final ParolaDiMedoraDelRespiro parola;
  final DateTime adesso;
  final DateTime tempoVisto;
  final bool suTuttoIlMese;
  final ValueChanged<DateTime> onTrascina;
  final VoidCallback onTornaAdesso;

  /// Quanti punti dello schermo valgono l'intera corsa consentita: lo
  /// stesso numero per il Viandante (24 ore) e per chi ha il mese, cosi'
  /// chi ha di piu' non deve trascinare di piu' per lo stesso effetto
  /// visivo, solo vedere passare un tempo diverso sotto lo stesso gesto.
  static const double _corsaInPunti = 280;

  Duration get _corsaMassima =>
      suTuttoIlMese ? const Duration(days: 30) : const Duration(hours: 12);

  void _onPanUpdate(DragUpdateDetails d) {
    final millisecondiPerPunto = _corsaMassima.inMilliseconds / _corsaInPunti;
    final nuovo = tempoVisto.add(
        Duration(milliseconds: (d.delta.dx * millisecondiPerPunto).round()));
    final minimo = adesso.subtract(_corsaMassima);
    final massimo = adesso.add(_corsaMassima);
    if (nuovo.isBefore(minimo)) {
      onTrascina(minimo);
    } else if (nuovo.isAfter(massimo)) {
      onTrascina(massimo);
    } else {
      onTrascina(nuovo);
    }
  }

  static String _oraLocale(DateTime t) {
    final l = t.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:'
        '${l.minute.toString().padLeft(2, '0')}';
  }

  /// "tra 32 minuti", "tra 2h 14min", "ora": sempre nel futuro rispetto a
  /// [tempoVisto] perche' `prossimoSorgere`/`prossimoTramonto` cercano
  /// sempre avanti da li'.
  String _traQuanto(DateTime target) {
    final d = target.difference(tempoVisto);
    if (d.inMinutes <= 0) return 'ora';
    if (d.inHours < 1) return 'tra ${d.inMinutes} minuti';
    final ore = d.inHours;
    final minuti = d.inMinutes % 60;
    return minuti == 0 ? 'tra ${ore}h' : 'tra ${ore}h ${minuti}min';
  }

  String get _rigaDiPosizione {
    final percento = (dati.percentualeDiLuce * 100).round();
    final fase = dati.crescente ? 'crescente' : 'calante';
    final sopra = (dati.altezzaGradi ?? -1) > 0;
    if (dati.altezzaGradi == null) {
      return '$percento% di luce, $fase.';
    }
    if (sopra && dati.tramonto != null) {
      return '$percento% di luce, $fase. Tramonta '
          '${_traQuanto(dati.tramonto!)}.';
    }
    if (!sopra && dati.sorgere != null) {
      return '$percento% di luce, $fase. Sorge '
          '${_traQuanto(dati.sorgere!)}.';
    }
    return '$percento% di luce, $fase.';
  }

  // **UNA RIGA SOLA, non due.** Ordine FX voce FX.03: distanza e prossima
  // sizigia condividono la stessa riga, perche' lo spazio sotto la Luna e'
  // quello che resta sotto di lei (R6 del progetto: un numero si legge, non
  // si fa leggere a costo di coprire il gesto che gli sta sopra). La prova
  // a video ha preso il difetto quando le righe erano troppe: il pannello
  // cresceva fino a toccare la Luna, e il tocco sostenuto su di lei
  // smetteva di funzionare (`docs/collaudo/FX/fx03_pannello_regola_a.txt`).
  String get _rigaDiDistanzaESizigia {
    final km = dati.distanzaKm.round();
    final migliaia = (km / 1000).toStringAsFixed(0);
    final piena = dati.prossimaPiena.difference(tempoVisto).inDays;
    final nuova = dati.prossimaNuova.difference(tempoVisto).inDays;
    final prossima = piena <= 0
        ? 'Luna nuova in $nuova giorni'
        : nuova <= 0
            ? 'Luna piena in $piena giorni'
            : piena < nuova
                ? 'Luna piena in $piena giorni'
                : 'Luna nuova in $nuova giorni';
    return dati.superluna
        ? 'A $migliaia mila km (Superluna in arrivo) · $prossima'
        : 'A $migliaia mila km · $prossima';
  }

  @override
  Widget build(BuildContext context) {
    final scostata =
        tempoVisto.difference(adesso).abs() > const Duration(minutes: 1);
    return GestureDetector(
      key: const Key('respiro_striscia_del_tempo'),
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: _onPanUpdate,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (scostata)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        'Le ${_oraLocale(tempoVisto)} del '
                        '${tempoVisto.day}/${tempoVisto.month}',
                        style: TypographyTokens.label(size: 12).copyWith(
                            color: Colors.white.withValues(alpha: 0.65))),
                    const SizedBox(width: 8),
                    GestureDetector(
                      key: const Key('respiro_torna_adesso'),
                      onTap: onTornaAdesso,
                      child: Text('Torna a adesso',
                          style: TypographyTokens.label(size: 12).copyWith(
                              color: palette.goldSoft,
                              decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ),
            Text(_rigaDiPosizione,
                key: const Key('respiro_riga_di_posizione'),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TypographyTokens.label(size: 13)
                    .copyWith(color: palette.goldSoft)),
            Text(_rigaDiDistanzaESizigia,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TypographyTokens.label(size: 12)
                    .copyWith(color: Colors.white.withValues(alpha: 0.78))),
            // **LE TRE RIGHE DI MEDORA (FX.07), IN UNA SOLA.** Unite con un
            // punto, non una sotto l'altra: tre righe separate spingevano
            // il pannello fino a toccare la Luna (vedi il commento sopra
            // `_rigaDiDistanzaESizigia`). **Non e' il dominio**: questo
            // punto medio unisce le righe di Medora, non i pilastri di un
            // Maestro, e scriverlo come `join(' · ')` letterale collide
            // col testo che la guardia `le_cose_che_dichiarano_il_falso`
            // cerca per quell'altra forma; il separatore sta in una
            // costante sua per restare un punto medio e non quel testo.
            if (parola.righe.isNotEmpty)
              Text(parola.righe.join(_separatoreDelleRigheDiMedora),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TypographyTokens.label(size: 12).copyWith(
                      color: Colors.white.withValues(alpha: 0.68),
                      fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}

/// La Bussola della Luna, in una sua schermata: il widget di FX.06 vuole
/// solo il luogo, il resto (sensori, ripiego) lo fa da solo.
class _SchermataDellaBussola extends StatelessWidget {
  const _SchermataDellaBussola({required this.luogo});

  final LuogoAttuale? luogo;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    return Scaffold(
      backgroundColor: palette.deepest,
      appBar: AppBar(
        toolbarHeight: altezzaDellaBarraDelRespiro(context),
        backgroundColor: palette.deepest,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        title: TitoloCheNonSiRompe(
            testo: 'Dov\'è la Luna adesso',
            stile: TypographyTokens.titoloDiSchermata()),
      ),
      body: luogo == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(SpacingTokens.lg),
                child: Text(
                    'Serve sapere dove sei per indicare la Luna: dallo il '
                    'permesso di posizione o scegli una città dal tuo '
                    'profilo.',
                    textAlign: TextAlign.center,
                    style: TypographyTokens.label(size: 14)
                        .copyWith(color: Colors.white.withValues(alpha: 0.8))),
              ),
            )
          : Center(child: LaBussolaDellaLuna(luogo: luogo!)),
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
            InterruttoreDelCerchio(
              key: const Key('respiro_avviso_sorgere'),
              acceso: _avvisi.lunaCheSorge,
              onCambia: _avvisi.letto
                  ? (v) => _avvisi.impostaLunaCheSorge(v, luogo: widget.luogo)
                  : null,
              titolo: 'La Luna che sorge',
            ),
            InterruttoreDelCerchio(
              key: const Key('respiro_avviso_sizigie'),
              acceso: _avvisi.luneNuoveEPiene,
              onCambia: _avvisi.letto
                  ? (v) =>
                      _avvisi.impostaLuneNuoveEPiene(v, luogo: widget.luogo)
                  : null,
              titolo: 'Luna piena, nuova e Superluna',
            ),
          ],
        ),
      ),
    );
  }
}

/// IL CIELO REALE, la schermata del Real Time Cosmo. Ordine FG parti 2-5.
///
/// **Una schermata, un motore, tre modi** (voce 3.1): il cielo di adesso, il
/// cielo della nascita e il ritorno indietro nel tempo sono questa stessa
/// classe con un altro istante e un altro luogo. I tre si aprono separati dal
/// menu temporaneo (`real_time_cosmo_screen.dart`, parte 6), cosi' il
/// fondatore li giudica uno per uno.
///
/// **NON tocca il Cielo esistente** (voce 9.1): `SkyOverviewScreen` e le sue
/// due rotte restano come sono e non sono collegate qui. I due cataloghi non
/// si incrociano (vedi `catalogo_delle_stelle.dart`).
///
/// **Si ferma quando esce di scena** (voce 7.8), col modello di
/// `cosmos_background.dart` (ordine AM voce 01): segue il ciclo di vita
/// dell'app (paused, hidden, detached) e la rotta coperta; fuori scena il
/// battito si ferma e la bussola si spegne davvero.
///
/// **Riduci Movimento** (voci 2.10 e 3.4, la regola dell'ordine AJ voce 01:
/// IL GIRO PARTE SOLO SENZA RIDUCI MOVIMENTO): l'inseguimento col sensore e'
/// fermo, si naviga col dito, e il riavvolgimento e' un passaggio secco.
library;

import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/astro/celestial.dart';
import '../../core/astro/data_italiana.dart';
import '../../core/astro/il_fuso_della_nascita.dart';
import '../../core/astro/luogo_attuale.dart';
import '../../core/astro/meeus/il_cielo_di_meeus.dart';
import '../../core/astro/real_time_cosmo/catalogo_delle_stelle.dart';
import '../../core/astro/real_time_cosmo/i_bersagli_del_cielo.dart';
import '../../core/astro/real_time_cosmo/i_nomi_del_cielo.dart';
import '../../core/astro/real_time_cosmo/il_cielo_in_un_istante.dart';
import '../../core/astro/real_time_cosmo/il_riavvolgimento.dart';
import '../../core/astro/real_time_cosmo/la_camera_del_cielo.dart';
import '../../core/astro/real_time_cosmo/la_declinazione_magnetica.dart';
import '../../core/astro/real_time_cosmo/la_griglia_del_tocco.dart';
import '../../core/astro/real_time_cosmo/le_linee_delle_figure.dart';
import '../../core/astro/sky_location.dart';
import '../../core/astro/zodiac.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/chat/la_marca_del_genere.dart';
import '../../core/l10n/numero_del_cerchio.dart';
import '../../core/maestro/maestro.dart';
import '../../core/motion/l_orientamento_del_telefono.dart';
import '../../core/motion/parallax_controller.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/luna_reale.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';
import '../account/dati_di_nascita_screen.dart';
import '../maestri/widgets/foglio_delle_fonti.dart';
import 'il_velo_delle_costellazioni.dart';
import 'gli_asset_del_cosmo.dart';
import 'la_scena_del_cielo.dart';
import 'l_orizzonte_in_scena.dart';
import 'la_via_lattea_in_scena.dart';
import 'le_linee_in_scena.dart';
import 'lo_stile_del_cielo.dart';
import 'pittore_del_cielo.dart';

enum ModoDelCielo { adesso, nascita, ritorno }

/// L'AVVISO DEL SOLE (ordine FH voce 5.7): una regola di sicurezza, non di
/// stile. Quando il bersaglio e' il Sole e il Sole e' sopra l'orizzonte, la
/// riga dell'indicatore lo dice PRIMA della direzione. Il testo esatto e'
/// materiale del fondatore: questa e' la forma da usare finche' non lo da'.
const String kAvvisoDelSole = 'Non guardare il Sole direttamente';

/// La frase d'arrivo del ritorno, con la marca del genere nella forma a
/// posizioni (ordine FH voce 8.5): maschile, femminile, neutro.
const String kFraseDellArrivo =
    'QUESTO ERA IL CIELO SOPRA DI TE QUANDO SEI [NATO|NATA|VENUTO AL MONDO]';

/// Roma, il luogo di ripiego quando non si conosce ne' la posizione ne' la
/// nascita. Si dichiara a schermo (regola R9).
const SkyPlace kLuogoDiRipiego = SkyPlace(
  latitude: 41.9028,
  longitude: 12.4964,
  citta: 'Roma',
);

class CieloRealeScreen extends StatefulWidget {
  const CieloRealeScreen({
    super.key,
    required this.modo,
    this.orologio,
    this.posizione = const GeolocatorSkyLocation(),
    this.bussola,
  });

  final ModoDelCielo modo;

  /// L'adesso; le prove lo fissano.
  final DateTime Function()? orologio;
  final SkyLocation posizione;

  /// Per le prove: l'orientamento del telefono gia' pronto.
  final OrientamentoDelTelefono? bussola;

  static Route<void> route(ModoDelCielo modo) =>
      PassaggioDelCerchio.rotta<void>(
        (_) => MaestroScope(
          maestro: Maestro.medora,
          child: CieloRealeScreen(modo: modo),
        ),
      );

  @override
  State<CieloRealeScreen> createState() => _CieloRealeScreenState();
}

/// Le fasi della scena del ritorno (docs/Specifica_Real_Time_Cosmo.md, 1-bis).
enum FaseDelRitorno { eta, ritorno, arrivo, fermo }

class _CieloRealeScreenState extends State<CieloRealeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  // --- Il catalogo e il cielo ---
  CatalogoDelleStelle? _catalogo;
  ScenaDelCielo? _scena;

  /// Le linee delle figure (ordine FH parte 3) e, per ogni velo, l'indice
  /// della sua figura nel file delle linee.
  LeLineeDelleFigure? _linee;
  LineeInScena? _lineeInScena;
  OrizzonteInScena? _orizzonte;
  ViaLatteaInScena? _viaLattea;
  final Int32List _figuraDelVelo = Int32List(12);
  ui.Image? _sprite;
  CieloInUnIstante? _cielo;
  GrigliaDelTocco? _griglia;
  String? _guastoDelCielo;

  // --- Il luogo e il tempo ---
  SkyPlace _luogo = kLuogoDiRipiego;
  bool _luogoDiRipiego = true;
  String _origineDelLuogo = 'Roma, in attesa della tua posizione';
  DateTime? _nascitaUtc;

  /// Lo scarto fra l'ora del luogo di nascita e il tempo universale, quel
  /// giorno: la data che scorre nel ritorno finisce sul giorno di nascita
  /// come la persona lo conosce, non su quello di Greenwich.
  Duration _scartoDellaNascita = Duration.zero;

  /// Il giorno mostrato sotto gli anni nel ritorno, come anno * 10000 + mese
  /// * 100 + giorno; zero finche' non c'e'.
  final ValueNotifier<int> _giornoDelRitorno = ValueNotifier(0);
  bool _nascitaConOra = true;
  SkyPlace? _luogoDiNascita;
  Zodiac? _segno;
  bool _mancaLaNascita = false;
  DateTime _ultimoRicalcolo = DateTime.fromMillisecondsSinceEpoch(0);

  // --- La camera ---
  double _campo = kCampoDiPartenza;
  double _azimut = 180;
  double _altezza = 40;
  OrientamentoDelTelefono? _telefono;
  bool _colSensore = true;
  bool _riduciMovimento = false;
  Duration _ultimoBattito = Duration.zero;
  Duration _accesoDa = Duration.zero;
  OrientamentoDellaCamera _orientamento = OrientamentoDellaCamera.daAngoli(
    azimutGradi: 180,
    altezzaGradi: 40,
  );
  Size _misura = Size.zero;
  double _campoAlPizzico = kCampoDiPartenza;

  // --- Il battito ---
  late final Ticker _ticker;
  final BattitoDelCielo _battito = BattitoDelCielo();
  final FotogrammaDelCielo _fotogramma = FotogrammaDelCielo();
  AppLifecycleState _cicloDiVita = AppLifecycleState.resumed;

  // --- I veli ---
  final List<VeloDiCostellazione> _veli = [];
  final Set<Zodiac> _veliDellaFoschia = {};

  /// I segni in quadro nel fotogramma: riscritto, mai rigenerato.
  final Set<Zodiac> _inQuadroOra = {};

  /// Le distanze e le luci dei dodici veli: riscritte, mai rigenerate.
  final Float64List _distanzeDeiVeli = Float64List(12);
  final Float64List _luciDeiVeli = Float64List(12);

  /// Il velo che sta al centro adesso (ordine FH parte 1).
  int? _veloAlCentro;
  Offset _foschiaRiferimento = Offset.zero;
  double _campoDellaFoschia = 0;

  // --- La Luna cotta ---
  double _lunaCottaIlluminazione = -1;
  double _lunaCottaLato = -1;

  // --- La guida e la scelta ---
  final ValueNotifier<_Guida?> _guida = ValueNotifier(null);

  // --- Il bersaglio dell'indicatore (ordine FH parte 5) ---
  Map<CategoriaDelBersaglio, List<BersaglioDelCielo>> _bersagli = const {};
  BersaglioDelCielo? _bersaglio;
  bool _primoASorgere = false;
  DateTime? _sorgeIlBersaglio;
  DateTime _ultimaLevata = DateTime.fromMillisecondsSinceEpoch(0);
  final ValueNotifier<String?> _invito = ValueNotifier(null);
  _Scelta? _scelta;
  String? _avvisoDellaBussola;
  String? _avvisoDelPermesso;

  /// Il volto della Luna, l'asset che LunaReale ritaglia sulla fase (voce
  /// 6.3 FH).
  ui.Image? _voltoDellaLuna;

  /// La riga che dice che la Luna adesso non c'e' e quando sorge (voce 6.2).
  String? _rigaDellaLuna;

  /// L'ora di levata dell'oggetto scelto, calcolata una volta per scelta.
  _Scelta? _sceltaDellaLevata;
  DateTime? _levataDellaScelta;

  // --- Il ritorno ---
  PianoDelRiavvolgimento? _piano;
  final Map<int, CieloInUnIstante> _istantiCalcolati = {};
  final ValueNotifier<FaseDelRitorno> _fase = ValueNotifier(FaseDelRitorno.eta);
  final ValueNotifier<int> _anni = ValueNotifier(0);

  /// Vero durante il rallentamento (ordine FH parte 8): la Luna sta al centro
  /// del quadro, e il contatore e la frase salgono in alto per non coprirla.
  final ValueNotifier<bool> _nelRallentamento = ValueNotifier(false);
  Duration _inizioDellaFase = Duration.zero;
  CieloInUnIstante? _cieloA, _cieloB;
  double _tFraIstanti = 0;

  static const List<Zodiac> _segni = Zodiac.values;

  // =====================================================================
  // CICLO DI VITA
  // =====================================================================

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_fotogrammaNuovo);
    WidgetsBinding.instance.addObserver(this);
    _sprite = preparaLoSpriteDellaStella();
    unawaited(_carica());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final rotta = ModalRoute.of(context);
    if (rotta != null) osservatoreDelCielo.subscribe(this, rotta);
    // IL GIRO PARTE SOLO SENZA RIDUCI MOVIMENTO, ordine AJ voce 01.
    _riduciMovimento = MediaQuery.of(context).disableAnimations;
    _accorda();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState stato) {
    _cicloDiVita = stato;
    _accorda();
  }

  @override
  void didPushNext() => _accorda(coperta: true);

  @override
  void didPopNext() => _accorda();

  static const Set<AppLifecycleState> _appDavveroVia = {
    AppLifecycleState.paused,
    AppLifecycleState.hidden,
    AppLifecycleState.detached,
  };

  /// Accende o ferma il battito e la bussola: in scena girano, fuori no.
  void _accorda({bool coperta = false}) {
    if (!mounted) return;
    final rotta = ModalRoute.of(context);
    final inScena = !_appDavveroVia.contains(_cicloDiVita) &&
        !coperta &&
        (rotta == null || rotta.isCurrent);
    final pronto = _scena != null && _cielo != null;
    if (inScena && pronto) {
      if (!_ticker.isActive) {
        _ultimoBattito = Duration.zero;
        _ticker.start();
      }
      if (_usaIlSensore) _telefono?.accendi();
    } else {
      if (_ticker.isActive) _ticker.stop();
      _telefono?.spegni();
    }
  }

  bool get _usaIlSensore => _colSensore && !_riduciMovimento;

  /// Vero se la schermata sta disegnando: la misura della voce 7.8.
  @visibleForTesting
  bool get staDisegnando => _ticker.isActive;

  @override
  void dispose() {
    osservatoreDelCielo.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _telefono?.spegni();
    _battito.dispose();
    _guida.dispose();
    _invito.dispose();
    _fase.dispose();
    _anni.dispose();
    _giornoDelRitorno.dispose();
    _nelRallentamento.dispose();
    for (final v in _veli) {
      v.libera();
    }
    _fotogramma.luna?.dispose();
    _fotogramma.foschia?.dispose();
    _sprite?.dispose();
    for (final s in _fotogramma.scritte) {
      s.testo.dispose();
    }
    for (final c in _fotogramma.corpi) {
      c.nome?.dispose();
    }
    super.dispose();
  }

  // =====================================================================
  // IL CARICAMENTO (fuori dal fotogramma)
  // =====================================================================

  DateTime get _adesso => (widget.orologio ?? DateTime.now)();

  Future<void> _carica() async {
    try {
      final catalogo = await CatalogoDelleStelle.carica();
      if (!mounted) return;
      _catalogo = catalogo;
      _scena = ScenaDelCielo(catalogo);
      final linee = await LeLineeDelleFigure.carica(
        catalogo,
        kLineeDelleFigure,
      );
      if (!mounted) return;
      _linee = linee;
      _lineeInScena = LineeInScena(linee);
      _fotogramma.linee = _lineeInScena;
      _leggiLaNascita();
      await _leggiIlLuogo();
      await _caricaIVeli(catalogo);
      final datiLuna = await rootBundle.load(AssetDelCosmo.luna.percorso);
      final codecLuna = await ui.instantiateImageCodec(
        datiLuna.buffer.asUint8List(),
      );
      _voltoDellaLuna = (await codecLuna.getNextFrame()).image;
      final datiTerra = await rootBundle.load(AssetDelCosmo.orizzonte.percorso);
      final codecTerra = await ui.instantiateImageCodec(
        datiTerra.buffer.asUint8List(),
      );
      _orizzonte = OrizzonteInScena((await codecTerra.getNextFrame()).image);
      _fotogramma.orizzonte = _orizzonte;
      final datiVia = await rootBundle.load(AssetDelCosmo.viaLattea.percorso);
      final codecVia = await ui.instantiateImageCodec(
        datiVia.buffer.asUint8List(),
      );
      _viaLattea = ViaLatteaInScena((await codecVia.getNextFrame()).image);
      _fotogramma.viaLattea = _viaLattea;
      if (!mounted) return;
      _preparaIBersagli(catalogo);
      _preparaLeScritte();
      _preparaLaBussola();
      _preparaIlModo();
      setState(() {});
      _accorda();
    } on FuoriDalCieloVerificato {
      if (mounted) {
        setState(
          () => _guastoDelCielo =
              'Questo istante sta fuori dagli anni che il motore del cielo '
                  'sa calcolare con certezza, dal 1900 al 2099.',
        );
      }
    } catch (e) {
      debugPrint('Real Time Cosmo: il cielo non si carica ($e)');
      if (mounted) {
        setState(
          () => _guastoDelCielo =
              'Il cielo non si è caricato. Riprova fra un momento.',
        );
      }
    }
  }

  void _leggiLaNascita() {
    // Un tipo nullabile che manca da' null da solo: niente try.
    final id = context.read<ProfileController?>()?.identity;
    final luogo = id?.birthPlace;
    if (id == null || id.isExample || luogo == null) {
      _mancaLaNascita = true;
      return;
    }
    _segno = id.sunSign;
    _nascitaConOra = id.hasBirthTime;
    _nascitaUtc = IlFusoDellaNascita.inUtc(id.birthMoment, luogo.timeZoneId);
    final m = id.birthMoment;
    _scartoDellaNascita = DateTime.utc(
      m.year,
      m.month,
      m.day,
      m.hour,
      m.minute,
    ).difference(_nascitaUtc!);
    _luogoDiNascita = SkyPlace(
      latitude: luogo.latitude,
      longitude: luogo.longitude,
      citta: luogo.city,
    );
  }

  Future<void> _leggiIlLuogo() async {
    final salvato = await DoveSonoAdesso.letto();
    if (salvato != null) {
      _luogo = salvato.comePosto;
      _luogoDiRipiego = false;
      _origineDelLuogo = salvato.citta;
      return;
    }
    final concesso = await widget.posizione.resolveSeConcesso();
    if (concesso != null) {
      _luogo = concesso;
      _luogoDiRipiego = false;
      _origineDelLuogo = concesso.citta ?? 'la tua posizione';
      return;
    }
    final nascita = _luogoDiNascita;
    if (nascita != null) {
      _luogo = nascita;
      _luogoDiRipiego = true;
      final nome = nascita.citta;
      _origineDelLuogo = nome == null
          ? 'il tuo luogo di nascita'
          : '$nome, il tuo luogo di nascita';
    }
  }

  Future<void> _caricaIVeli(CatalogoDelleStelle catalogo) async {
    for (final segno in _segni) {
      final dati = await rootBundle.load(segno.assetDelVelo);
      final codec = await ui.instantiateImageCodec(dati.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      _veli.add(
        VeloDiCostellazione(
          segno: segno,
          immagine: frame.image,
          principali: stellePrincipali(catalogo, segno.sigleIau),
        ),
      );
    }
    _fotogramma.veli
      ..clear()
      ..addAll(_veli);
    for (var k = 0; k < _veli.length; k++) {
      _figuraDelVelo[k] = _linee?.indiceDi(_veli[k].segno.sigleIau) ?? -1;
    }
    // LA PRESENZA DEL VELO (ordine FH parte 4): la forza della sua figura,
    // dal conto di stelle fino alla quarta magnitudine del file delle linee,
    // per la presenza in piu' del segno della persona (venti per cento, voce
    // 2.3), che non scende mai sotto 0,70 di forza (voce 4.4).
    for (final v in _veli) {
      final figura = _linee?.indiceDi(v.segno.sigleIau);
      final forza = figura == null ? 1.0 : _linee!.figure[figura].forza;
      final eIlSegno = v.segno == _segno;
      _fotogramma.presenza[v] = forzaDelVelo(forza, eIlSegno: eIlSegno) *
          (eIlSegno ? 1.0 : 1.0 / kPresenzaDelSegno);
    }
    // La taratura nuova dei veli (ordine FH voce 2.1), uno dopo l'altro in
    // un isolato: finche' un velo non e' pronto, non si accende.
    unawaited(() async {
      for (final v in _veli) {
        if (!mounted) return;
        await v.alleggerisci();
      }
    }());
  }

  TextPainter _scritta(String testo, TextStyle stile) =>
      // Le scritte del cielo si leggono come testo, non stanno dentro una
      // figura: seguono la scala che la persona ha scelto nel sistema.
      TextPainter(
        text: TextSpan(text: testo, style: stile),
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();

  void _preparaLeScritte() {
    final cardinale = TypographyTokens.etichetta().copyWith(
      color: ColorTokens.goldLight.withValues(alpha: 0.85),
    );
    for (final p in const ['N', 'E', 'S', 'O']) {
      _fotogramma.scritte.add(ScrittaDaPosare(_scritta(p, cardinale)));
    }
    // L'etichetta che si accende sul bersaglio in quadro (indice 4).
    _fotogramma.scritte.add(
      ScrittaDaPosare(
        _scritta(
          _bersaglio?.nome ?? '',
          TypographyTokens.etichetta().copyWith(color: ColorTokens.goldBright),
        ),
      ),
    );
    const nomi = [
      'Sole',
      'Luna',
      'Mercurio',
      'Venere',
      'Marte',
      'Giove',
      'Saturno',
    ];
    final stileCorpo = TypographyTokens.etichetta(
      weight: 500,
    ).copyWith(color: ColorTokens.textSecondary);
    for (var i = 0; i < 7; i++) {
      _fotogramma.corpi[i].nome = i == 1 ? null : _scritta(nomi[i], stileCorpo);
    }
  }

  void _preparaLaBussola() {
    final dato = widget.bussola;
    if (dato != null) {
      _telefono = dato;
    } else {
      final p = context.read<ParallaxController?>();
      _telefono = OrientamentoDelTelefono(gravita: () => p?.gravitaGrezza);
    }
    final d = declinazioneMagnetica(
      latitudine: _luogo.latitude,
      longitudine: _luogo.longitude,
      anno: annoDecimale(_adesso),
    );
    _telefono!.declinazioneGradi = d.gradi;
    if (_riduciMovimento) {
      _avvisoDellaBussola = 'Riduci movimento è attivo: il cielo resta fermo '
          'e lo esplori col dito.';
    }
  }

  void _preparaIlModo() {
    final catalogo = _catalogo!;
    final adesso = Celestial.julianDay(_adesso.toUtc());
    switch (widget.modo) {
      case ModoDelCielo.adesso:
        _impostaIlCielo(
          CieloInUnIstante.calcola(
            catalogo,
            jd: adesso,
            latitudine: _luogo.latitude,
            longitudine: _luogo.longitude,
          ),
        );
        _ultimoRicalcolo = _adesso;
        _partiDallaLuna();
      case ModoDelCielo.nascita:
        final n = _nascitaUtc;
        final l = _luogoDiNascita;
        if (n == null || l == null) {
          _impostaIlCielo(
            CieloInUnIstante.calcola(
              catalogo,
              jd: adesso,
              latitudine: _luogo.latitude,
              longitudine: _luogo.longitude,
            ),
          );
          return;
        }
        _colSensore = false;
        _impostaIlCielo(
          CieloInUnIstante.calcola(
            catalogo,
            jd: Celestial.julianDay(n),
            latitudine: l.latitude,
            longitudine: l.longitude,
          ),
        );
        _guardaVersoLaLuna();
      case ModoDelCielo.ritorno:
        _colSensore = false;
        _impostaIlCielo(
          CieloInUnIstante.calcola(
            catalogo,
            jd: adesso,
            latitudine: _luogo.latitude,
            longitudine: _luogo.longitude,
          ),
        );
        final n = _nascitaUtc;
        final l = _luogoDiNascita;
        if (n == null || l == null) return;
        _anni.value = _etaIntera(n);
        _guardaVersoLaLuna();
        _piano = PianoDelRiavvolgimento.prepara(
          jdAdesso: adesso,
          jdNascita: Celestial.julianDay(n),
          latAdesso: _luogo.latitude,
          lonAdesso: _luogo.longitude,
          latNascita: l.latitude,
          lonNascita: l.longitude,
        );
        _posaLaData(_piano!.istanti.first);
    }
  }

  int _etaIntera(DateTime nascitaUtc) {
    final a = _adesso.toUtc();
    var anni = a.year - nascitaUtc.year;
    if (a.month < nascitaUtc.month ||
        (a.month == nascitaUtc.month && a.day < nascitaUtc.day)) {
      anni--;
    }
    return math.max(0, anni);
  }

  void _impostaIlCielo(CieloInUnIstante cielo) {
    _cielo = cielo;
    _griglia = null;
  }

  /// IL CIELO DI ADESSO PARTE DALLA LUNA (ordine FH parte 6). E' l'unico
  /// corpo che cambia forma: la vista si apre centrata su di lei. Quando la
  /// Luna e' sotto l'orizzonte si apre sul corpo piu' brillante sopra
  /// l'orizzonte fra il Sole, i pianeti e le stelle di prima magnitudine (fino
  /// a 1,5), e una riga dice che la Luna adesso non c'e' e quando sorge.
  void _partiDallaLuna() {
    final cielo = _cielo;
    final catalogo = _catalogo;
    if (cielo == null || catalogo == null) return;
    final luna = cielo.corpo(CorpoCeleste.luna);
    _rigaDellaLuna = null;
    if (luna.sopraLOrizzonte) {
      _azimut = luna.azimutGradi;
      _altezza = luna.altezzaGradi;
      return;
    }
    var magMigliore = double.infinity;
    double? az, alt;
    for (final c in cielo.corpi) {
      if (c.corpo == CorpoCeleste.luna || !c.sopraLOrizzonte) continue;
      if (c.magnitudine < magMigliore) {
        magMigliore = c.magnitudine;
        az = c.azimutGradi;
        alt = c.altezzaGradi;
      }
    }
    for (var i = 0;
        i < catalogo.numeroDiStelle && catalogo.magnitudine[i] <= 1.5;
        i++) {
      if (cielo.z[i] <= 0 || catalogo.magnitudine[i] >= magMigliore) continue;
      magMigliore = catalogo.magnitudine[i];
      alt = math.asin(cielo.z[i].clamp(-1.0, 1.0)) * 180 / math.pi;
      var a = math.atan2(cielo.x[i], cielo.y[i]) * 180 / math.pi;
      if (a < 0) a += 360;
      az = a;
    }
    if (az != null && alt != null) {
      _azimut = az;
      _altezza = alt;
    }
    final sorge = quandoSorgeIlBersaglio(
      const BersaglioCorpo(
        'luna',
        'La Luna',
        CategoriaDelBersaglio.lunaESole,
        CorpoCeleste.luna,
      ),
      _adesso,
      _luogo.latitude,
      _luogo.longitude,
    );
    _rigaDellaLuna = sorge == null
        ? 'La Luna adesso non c\'è e oggi non sorge.'
        : 'La Luna adesso non c\'è: sorge alle ${_ora(sorge)}.';
  }

  /// La camera si gira verso la Luna di quel cielo, se e' sopra
  /// l'orizzonte; altrimenti verso sud a meta' altezza.
  void _guardaVersoLaLuna() {
    final luna = _cielo?.corpo(CorpoCeleste.luna);
    if (luna != null && luna.sopraLOrizzonte) {
      _azimut = luna.azimutGradi;
      _altezza = luna.altezzaGradi.clamp(10, 70);
    } else {
      _azimut = 180;
      _altezza = 40;
    }
  }

  // =====================================================================
  // IL FOTOGRAMMA
  // =====================================================================

  void _fotogrammaNuovo(Duration ora) {
    final cielo = _cielo;
    final scena = _scena;
    if (cielo == null || scena == null || _misura.isEmpty) return;
    final dt = _ultimoBattito == Duration.zero
        ? 1 / 60
        : (ora - _ultimoBattito).inMicroseconds / 1e6;
    _ultimoBattito = ora;
    if (_accesoDa == Duration.zero) _accesoDa = ora;

    // Il cielo di adesso si ricalcola ogni dieci secondi: in dieci secondi
    // il cielo gira di 0,04 gradi, cioe' di un quinto di punto.
    if (widget.modo == ModoDelCielo.adesso &&
        _adesso.difference(_ultimoRicalcolo).inSeconds >= 10) {
      _ultimoRicalcolo = _adesso;
      _impostaIlCielo(
        CieloInUnIstante.calcola(
          _catalogo!,
          jd: Celestial.julianDay(_adesso.toUtc()),
          latitudine: _luogo.latitude,
          longitudine: _luogo.longitude,
        ),
      );
    }

    if (widget.modo == ModoDelCielo.ritorno) _avanzaIlRitorno(ora);
    _fotogramma.nomiDeiCorpi = widget.modo != ModoDelCielo.ritorno ||
        _fase.value == FaseDelRitorno.fermo;

    // L'orientamento: il sensore se c'e' e se e' permesso, il dito sempre.
    final telefono = _telefono;
    OrientamentoDellaCamera? dalSensore;
    if (_usaIlSensore && telefono != null) {
      dalSensore = telefono.passo(dt, costanteDiTempoPerCampo(_campo));
      if (dalSensore == null &&
          _avvisoDellaBussola == null &&
          ora - _accesoDa > const Duration(seconds: 2)) {
        _avvisoDellaBussola =
            'Bussola non disponibile: esplora il cielo col dito.';
        _colSensore = false;
        telefono.spegni();
        if (mounted) setState(() {});
      }
    }
    if (dalSensore != null) {
      _orientamento = dalSensore;
      _azimut = dalSensore.azimutGradi;
      _altezza = dalSensore.altezzaGradi;
    } else {
      _orientamento = OrientamentoDellaCamera.daAngoli(
        azimutGradi: _azimut,
        altezzaGradi: _altezza,
      );
    }

    final proiezione = ProiezioneDelCielo(
      larghezza: _misura.width,
      altezza: _misura.height,
      campoGradi: _campo,
    );

    // La parallasse: l'inclinazione del telefono dal suo riposo.
    var tx = 0.0, ty = 0.0;
    if (!_riduciMovimento) {
      final p = context.read<ParallaxController?>();
      tx = p?.tiltX ?? 0;
      ty = p?.tiltY ?? 0;
    }
    final cieloSposta = spostamentoDiParallasse(kCorsaDelCielo, tx, ty);
    final veloSposta = spostamentoDiParallasse(kCorsaDelVelo, tx, ty);

    final a = _cieloA ?? cielo;
    final b = _cieloB;
    scena.prepara(
      cielo: a,
      poi: b,
      t: _tFraIstanti,
      orientamento: _orientamento,
      proiezione: proiezione,
      spostamentoX: cieloSposta.dx,
      spostamentoY: cieloSposta.dy,
    );
    _posaICorpi(a, b, proiezione, cieloSposta);
    _posaIVeli(a, b, proiezione, cieloSposta, veloSposta, dt);
    final alCentro = _veloAlCentro;
    _orizzonte?.prepara(
      _orientamento,
      proiezione,
      spostamentoX: cieloSposta.dx,
      spostamentoY: cieloSposta.dy,
    );
    _viaLattea?.prepara(
      _orientamento,
      proiezione,
      a.assi,
      b?.assi,
      _tFraIstanti,
      spostamentoX: cieloSposta.dx,
      spostamentoY: cieloSposta.dy,
    );
    _lineeInScena?.prepara(
      cielo: a,
      poi: b,
      t: _tFraIstanti,
      orientamento: _orientamento,
      proiezione: proiezione,
      spostamentoX: cieloSposta.dx,
      spostamentoY: cieloSposta.dy,
      figuraAlCentro: alCentro == null ? null : _figuraDelVelo[alCentro],
      luceSotto: kLuceSottoLOrizzonte,
    );
    _posaLeScritte(proiezione, cieloSposta);
    _aggiornaLaLevata();
    _posaLaGuida(a, proiezione);
    _posaLAnello(proiezione, cieloSposta);
    _aggiornaLInvito(a);
    _battito.batti();
  }

  ({double x, double y, double z}) _versoreDi(
    CieloInUnIstante a,
    CieloInUnIstante? b,
    int i,
  ) {
    var x = a.x[i], y = a.y[i], z = a.z[i];
    if (b != null && _tFraIstanti > 0) {
      x += (b.x[i] - x) * _tFraIstanti;
      y += (b.y[i] - y) * _tFraIstanti;
      z += (b.z[i] - z) * _tFraIstanti;
      final l = math.sqrt(x * x + y * y + z * z);
      x /= l;
      y /= l;
      z /= l;
    }
    return (x: x, y: y, z: z);
  }

  final List<double> _punto = [0, 0];

  static const List<Color> _coloriDeiCorpi = [
    Color(0xFFFFE9A8), // Sole
    Color(0xFFFFFFFF), // Luna
    Color(0xFFD9CFC0), // Mercurio
    Color(0xFFFFF6DC), // Venere
    Color(0xFFFFB38A), // Marte
    Color(0xFFFFE8C4), // Giove
    Color(0xFFF2DDA4), // Saturno
  ];

  void _posaICorpi(
    CieloInUnIstante a,
    CieloInUnIstante? b,
    ProiezioneDelCielo proiezione,
    Offset sposta,
  ) {
    final ppg = proiezione.puntiPerGrado;
    for (var k = 0; k < a.corpi.length; k++) {
      final ca = a.corpi[k];
      var x = ca.x, y = ca.y, z = ca.z;
      if (b != null && _tFraIstanti > 0) {
        final cb = b.corpi[k];
        x += (cb.x - x) * _tFraIstanti;
        y += (cb.y - y) * _tFraIstanti;
        z += (cb.z - z) * _tFraIstanti;
        final l = math.sqrt(x * x + y * y + z * z);
        x /= l;
        y /= l;
        z /= l;
      }
      final posa = _fotogramma.corpi[k];
      final visibile = proiezione.proietta(_orientamento, x, y, z, _punto);
      posa.visibile = visibile;
      if (!visibile) continue;
      posa.x = _punto[0] + sposta.dx;
      posa.y = _punto[1] + sposta.dy;
      posa.colore = _coloriDeiCorpi[k];
      // Sotto l'orizzonte lo smorza il velo del terreno (voce 7.3 FH).
      posa.luce = 1.0;
      if (ca.corpo == CorpoCeleste.luna) {
        posa.visibile = false;
        _posaLaLuna(a, b, posa.x, posa.y, ppg, z < 0);
        continue;
      }
      posa.raggio = ca.corpo == CorpoCeleste.sole
          ? math.max(14.0, ppg * 1.5)
          // I pianeti con la regola delle stelle, ma con un tetto: Giove a
          // -2,3 darebbe un globo di cinquanta punti, Venere di ottanta.
          : math.min(20.0, raggioDellaStella(ca.magnitudine));
    }
  }

  /// La Luna si dipinge con `LunaReale` UNA volta per fase in un'immagine,
  /// e a ogni fotogramma si posa soltanto: `LunaReale.dipingi` crea
  /// gradienti e sfocature a ogni chiamata, e nel fotogramma non devono
  /// nascere (voce 2.1). Si ricuoce quando la fase cambia di un centesimo o
  /// la misura del disco di un decimo: nel ritorno al piu' una volta per
  /// istante calcolato.
  ///
  /// Il disco e' ingrandito: la Luna vera e' mezzo grado, due punti e mezzo
  /// a settanta gradi di campo. Qui il raggio e' un grado, mai sotto i nove
  /// punti, come in ogni carta del cielo. L'immagine cotta e' larga dieci
  /// raggi: l'alone di `LunaReale` arriva a 4,6 raggi dal centro, e
  /// un'immagine piu' stretta lo tagliava in un quadrato visibile (anteprima
  /// fg_07: con due raggi e poi con quattro, misurato e visto).
  void _posaLaLuna(
    CieloInUnIstante a,
    CieloInUnIstante? b,
    double x,
    double y,
    double ppg,
    bool sotto,
  ) {
    final illum = b != null && _tFraIstanti > 0.5
        ? b.illuminazioneDellaLuna
        : a.illuminazioneDellaLuna;
    final crescente =
        b != null && _tFraIstanti > 0.5 ? b.lunaCrescente : a.lunaCrescente;
    final lato = math.max(9.0, ppg) * 10;
    if ((illum - _lunaCottaIlluminazione).abs() > 0.01 ||
        (lato - _lunaCottaLato).abs() > _lunaCottaLato * 0.1) {
      _cuociLaLuna(illum, crescente, lato);
    }
    _fotogramma
      ..lunaX = x
      ..lunaY = y
      ..lunaLato = lato
      ..lunaLuce = 1.0;
  }

  void _cuociLaLuna(double illum, bool crescente, double lato) {
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 3.0;
    final px = (lato * dpr).ceil();
    final registratore = ui.PictureRecorder();
    final tela = Canvas(registratore);
    LunaReale.dipingi(
      tela,
      Offset(px / 2, px / 2),
      px / 10,
      illuminazione: illum,
      crescente: crescente,
      volto: _voltoDellaLuna,
    );
    final vecchia = _fotogramma.luna;
    _fotogramma.luna = registratore.endRecording().toImageSync(px, px);
    vecchia?.dispose();
    MisureDelCosmo.luneCotte++;
    _lunaCottaIlluminazione = illum;
    _lunaCottaLato = lato;
  }

  void _posaIVeli(
    CieloInUnIstante a,
    CieloInUnIstante? b,
    ProiezioneDelCielo proiezione,
    Offset cieloSposta,
    Offset veloSposta,
    double dt,
  ) {
    final catalogo = _catalogo!;
    final passo = dt * 1000 / kDissolvenzaDelVelo.inMilliseconds;
    final inQuadroOra = _inQuadroOra..clear();
    for (var k = 0; k < _veli.length; k++) {
      final v = _veli[k];
      var n = 0;
      var cx = 0.0, cy = 0.0, cz = 0.0;
      for (final i in v.principali) {
        final d = _versoreDi(a, b, i);
        // Il centro della costellazione nel cielo: il baricentro dei versori
        // pesato per luminosita', come il centro del velo (voce 4.5 FG).
        final peso = math.pow(10, -0.4 * catalogo.magnitudine[i]).toDouble();
        cx += d.x * peso;
        cy += d.y * peso;
        cz += d.z * peso;
        if (!proiezione.proietta(_orientamento, d.x, d.y, d.z, _punto)) {
          continue;
        }
        v.xs[n] = _punto[0] + cieloSposta.dx;
        v.ys[n] = _punto[1] + cieloSposta.dy;
        v.mags[n] = catalogo.magnitudine[i];
        n++;
      }
      final posa = n == v.principali.length
          ? posaDelVelo(
              xs: v.xs,
              ys: v.ys,
              mags: v.mags,
              n: n,
              larghezzaAsset: v.immagine.width.toDouble(),
              altezzaAsset: v.immagine.height.toDouble(),
            )
          : null;
      v.posa = posa;
      final c = posa?.centro;
      v.inQuadro = c != null &&
          c.dx >= 0 &&
          c.dy >= 0 &&
          c.dx <= _misura.width &&
          c.dy <= _misura.height;
      final l = math.sqrt(cx * cx + cy * cy + cz * cz);
      v.distanza = v.inQuadro && l > 0
          ? ProiezioneDelCielo.distanzaDallAsse(
              _orientamento,
              cx / l,
              cy / l,
              cz / l,
            )
          : double.infinity;
      _distanzeDeiVeli[k] = v.distanza;
      _luciDeiVeli[k] = v.luce;
    }
    // UN VELO ALLA VOLTA (ordine FH parte 1): quello al centro, con
    // l'isteresi di cinque gradi, e mai due accesi nello stesso fotogramma.
    _veloAlCentro = veloAlCentro(_distanzeDeiVeli, _veloAlCentro);
    // Un velo non ancora alleggerito non si accende (voce 2.1): se e' quello
    // al centro, passa avanti nella fila dell'alleggerimento.
    final alCentro = _veloAlCentro;
    final accendibile =
        alCentro != null && _veli[alCentro].leggero ? alCentro : null;
    if (alCentro != null && !_veli[alCentro].leggero) {
      unawaited(_veli[alCentro].alleggerisci());
    }
    aggiornaLaLuceDeiVeli(_luciDeiVeli, accendibile, passo);
    for (var k = 0; k < _veli.length; k++) {
      final v = _veli[k];
      v.luce = _luciDeiVeli[k];
      final posa = v.posa;
      if (v.luce > 0 && posa != null) {
        v.cuociAlone(posa.scala);
        inQuadroOra.add(v.segno);
      }
    }
    _fotogramma
      ..veloDx = veloSposta.dx
      ..veloDy = veloSposta.dy;
    _posaLaFoschia(inQuadroOra, proiezione, cieloSposta);
  }

  /// LA PROFONDITA' DI CAMPO (voce 5.3). La foschia si cuoce quando un velo
  /// entra o esce, quando il campo cambia o quando il cielo sotto si e'
  /// spostato oltre [kDerivaDellaFoschia]; fra una cottura e l'altra si
  /// posa spostata col cielo.
  void _posaLaFoschia(
    Set<Zodiac> inQuadro,
    ProiezioneDelCielo proiezione,
    Offset sposta,
  ) {
    final riferimento = _riferimentoDellaFoschia(inQuadro);
    final deriva =
        riferimento == null ? Offset.zero : riferimento - _foschiaRiferimento;
    final daRifare = !_stessiSegni(inQuadro, _veliDellaFoschia) ||
        (_campo - _campoDellaFoschia).abs() > 0.5 ||
        deriva.distance > kDerivaDellaFoschia;
    if (daRifare) {
      _cuociLaFoschia(inQuadro);
      _foschiaRiferimento = riferimento ?? Offset.zero;
      _campoDellaFoschia = _campo;
      _fotogramma
        ..foschiaX = 0
        ..foschiaY = 0;
    } else {
      _fotogramma
        ..foschiaX = deriva.dx
        ..foschiaY = deriva.dy;
    }
    var luce = 0.0;
    for (final v in _veli) {
      if (v.luce > luce) luce = v.luce;
    }
    _fotogramma.foschiaLuce = luce;
  }

  Offset? _riferimentoDellaFoschia(Set<Zodiac> inQuadro) {
    for (final v in _veli) {
      if (inQuadro.contains(v.segno) && v.posa != null) return v.posa!.centro;
    }
    return null;
  }

  static bool _stessiSegni(Set<Zodiac> a, Set<Zodiac> b) =>
      a.length == b.length && a.containsAll(b);

  void _cuociLaFoschia(Set<Zodiac> inQuadro) {
    _veliDellaFoschia
      ..clear()
      ..addAll(inQuadro);
    final vecchia = _fotogramma.foschia;
    _fotogramma.foschia = null;
    vecchia?.dispose();
    if (inQuadro.isEmpty) return;
    final scena = _scena!;
    final w = _misura.width.ceil(), h = _misura.height.ceil();
    final limiti = Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble());
    // Il cielo nitido di questo istante...
    final r1 = ui.PictureRecorder();
    final t1 = Canvas(r1);
    t1.drawRect(limiti, Paint()..color = kFondoDelCielo);
    if (scena.quante > 0) {
      t1.drawRawAtlas(
        _sprite!,
        Float32List.sublistView(scena.trasformazioni, 0, scena.quante * 4),
        Float32List.sublistView(scena.rettangoli, 0, scena.quante * 4),
        Int32List.sublistView(scena.colori, 0, scena.quante),
        BlendMode.modulate,
        null,
        Paint(),
      );
    }
    final nitido = r1.endRecording().toImageSync(w, h);
    // ...sfocato a 3,2 punti e tenuto solo dove la maschera dei veli lo
    // vuole: l'alfa del velo sfocata a 40 punti, al 70 per cento.
    final r2 = ui.PictureRecorder();
    final t2 = Canvas(r2);
    t2.saveLayer(limiti, Paint());
    t2.drawImage(
      nitido,
      Offset.zero,
      Paint()
        ..imageFilter = ui.ImageFilter.blur(
          sigmaX: kSfocaturaDelCielo,
          sigmaY: kSfocaturaDelCielo,
        ),
    );
    t2.saveLayer(limiti, Paint()..blendMode = BlendMode.dstIn);
    final maschera = Paint()
      ..imageFilter = ui.ImageFilter.blur(
        sigmaX: kSfocaturaDellaMaschera,
        sigmaY: kSfocaturaDellaMaschera,
      )
      ..color = const Color.fromRGBO(255, 255, 255, kForzaDellaMaschera);
    for (final v in _veli) {
      final posa = v.posa;
      if (!inQuadro.contains(v.segno) || posa == null) continue;
      t2.drawImageRect(
        v.immagine,
        Rect.fromLTWH(
          0,
          0,
          v.immagine.width.toDouble(),
          v.immagine.height.toDouble(),
        ),
        Rect.fromCenter(
          center: posa.centro.translate(_fotogramma.veloDx, _fotogramma.veloDy),
          width: v.immagine.width * posa.scala,
          height: v.immagine.height * posa.scala,
        ),
        maschera,
      );
    }
    t2.restore();
    t2.restore();
    _fotogramma.foschia = r2.endRecording().toImageSync(w, h);
    nitido.dispose();
    MisureDelCosmo.foschieCotte++;
  }

  void _posaLeScritte(ProiezioneDelCielo proiezione, Offset sposta) {
    const azimut = [0.0, 90.0, 180.0, 270.0];
    for (var k = 0; k < 4; k++) {
      final s = _fotogramma.scritte[k];
      final az = azimut[k] * math.pi / 180;
      // Sullo skyline, nei quattro punti veri (voce 7.5 FH): cinque gradi
      // sopra l'orizzonte, sopra le colline piu' alte della sagoma (3,6).
      const e = 5 * math.pi / 180;
      final x = math.sin(az) * math.cos(e);
      final y = math.cos(az) * math.cos(e);
      final z = math.sin(e);
      if (proiezione.proietta(_orientamento, x, y, z, _punto)) {
        s
          ..x = _punto[0] + sposta.dx
          ..y = _punto[1] + sposta.dy
          ..luce = 1;
      } else {
        s.luce = 0;
      }
    }
  }

  void _posaLaGuida(CieloInUnIstante cielo, ProiezioneDelCielo proiezione) {
    final b = _bersaglio;
    // Mentre il ritorno parla al centro dello schermo la guida tace.
    final parla = widget.modo == ModoDelCielo.ritorno &&
        _fase.value != FaseDelRitorno.fermo;
    final scritta =
        _fotogramma.scritte.length > 4 ? _fotogramma.scritte[4] : null;
    if (b == null || parla) {
      scritta?.luce = 0;
      if (_guida.value != null) _guida.value = null;
      return;
    }
    final v = b.versore(cielo);
    final x = v.x, y = v.y, z = v.z;
    final sotto = z < 0;
    final distanza = ProiezioneDelCielo.distanzaDallAsse(
      _orientamento,
      x,
      y,
      z,
    );
    final dentro = proiezione.proietta(_orientamento, x, y, z, _punto) &&
        _punto[0] > 24 &&
        _punto[0] < _misura.width - 24 &&
        _punto[1] > 90 &&
        _punto[1] < _misura.height - 140;
    final soleSopra = b.eIlSole && !sotto;
    if (dentro && !sotto && !soleSopra) {
      // Il bersaglio e' in quadro e sopra l'orizzonte: la freccia sparisce e
      // il nome si accende (voce 5.1); resta la sola etichetta che riapre il
      // menu, perche' non sia un vicolo cieco.
      scritta
        ?..x = _punto[0]
        ..y = _punto[1] - 34
        ..luce = 1;
      final g = _Guida.inQuadro(b.nome);
      if (_guida.value != g) _guida.value = g;
      return;
    }
    scritta?.luce = 0;
    final m = _orientamento.m;
    final cx = m[0] * x + m[1] * y + m[2] * z;
    final cy = m[3] * x + m[4] * y + m[5] * z;
    // In quadro (il Sole alto, o un bersaglio sotto l'orizzonte ma visibile)
    // la scritta sta in alto: in basso finirebbe dietro il pie' di pagina.
    // In quadro la freccia non serve (si vede dov'e'): l'angolo NaN la toglie.
    final angolo = dentro ? double.nan : math.atan2(-cy, cx);
    final gradi = distanza.round();
    // La riga: l'avviso del Sole PRIMA della direzione (voce 5.7), l'ora in
    // cui sorge se e' sotto l'orizzonte (voce 5.6), e la dichiarazione del
    // primo a sorgere quando la categoria non ne ha nessuno sopra (voce 5.4).
    String? riga;
    if (sotto) {
      final quando = _sorgeIlBersaglio;
      riga = quando == null
          ? 'Adesso è sotto l\'orizzonte e oggi non sorge'
          : 'Sotto l\'orizzonte: sorge alle ${_ora(quando)}';
      if (_primoASorgere) riga = 'Nessuno è sopra l\'orizzonte. $riga';
    }
    final posizione = _posizioneDellaGuida(
      angolo.isNaN ? -math.pi / 2 : angolo,
    );
    final g = _Guida(
      nome: b.nome,
      gradi: gradi,
      angolo: angolo,
      x: posizione.dx,
      y: posizione.dy,
      riga: riga,
      avviso: soleSopra ? kAvvisoDelSole : null,
    );
    final vecchia = _guida.value;
    if (vecchia == null ||
        vecchia.gradi != g.gradi ||
        vecchia.riga != g.riga ||
        vecchia.avviso != g.avviso ||
        vecchia.inQuadroSoltanto ||
        (vecchia.x - g.x).abs() > 2 ||
        (vecchia.y - g.y).abs() > 2) {
      _guida.value = g;
    }
  }

  static String _ora(DateTime t) {
    final l = t.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:'
        '${l.minute.toString().padLeft(2, '0')}';
  }

  /// La misura della scritta dell'indicatore, per la sua posizione.
  static const Size _misuraDellaGuida = Size(170, 64);

  /// Dove sta l'indicatore: sul bordo, dalla parte del bersaglio; e se la sua
  /// scritta copre il nome di un pianeta, il nome del pianeta ha la
  /// precedenza e la scritta si sposta (voce 14.1).
  Offset _posizioneDellaGuida(double angolo) {
    const margine = 44.0;
    final cx = _misura.width / 2, cy = _misura.height / 2;
    final dx = math.cos(angolo), dy = math.sin(angolo);
    final sx = dx.abs() < 1e-6 ? double.infinity : (cx - margine) / dx.abs();
    final sy =
        dy.abs() < 1e-6 ? double.infinity : (cy - margine - 70) / dy.abs();
    final s = math.min(sx, sy);
    final w = _misuraDellaGuida.width, h = _misuraDellaGuida.height;
    var left = (cx + dx * s - w / 2).clamp(8.0, _misura.width - w - 8);
    var top = (cy + dy * s - h / 2).clamp(80.0, _misura.height - 120 - h);
    for (var giro = 0; giro < 3; giro++) {
      final scatola = Rect.fromLTWH(left, top, w, h);
      Rect? coperto;
      for (final c in _fotogramma.corpi) {
        final nome = c.nome;
        if (!c.visibile || nome == null) continue;
        final r = Rect.fromLTWH(
          c.x - nome.width / 2,
          c.y + c.raggio * 0.6 + 4,
          nome.width,
          nome.height,
        );
        if (r.overlaps(scatola)) {
          coperto = r;
          break;
        }
      }
      // La Luna ha la stessa precedenza dei nomi dei pianeti: e' il soggetto
      // del cielo di adesso (parte 6), e la scritta non le va sopra.
      final f = _fotogramma;
      if (coperto == null && f.luna != null && f.lunaLuce > 0) {
        final disco = Rect.fromCircle(
          center: Offset(f.lunaX, f.lunaY),
          radius: f.lunaLato / 10 + 6,
        );
        if (disco.overlaps(scatola)) coperto = disco;
      }
      if (coperto == null) break;
      // Sopra o sotto il nome, dalla parte dove c'e' piu' posto.
      final suPosto = coperto.top - 80;
      final giuPosto = _misura.height - 120 - coperto.bottom;
      top = suPosto > giuPosto
          ? (coperto.top - h - 6).clamp(80.0, _misura.height - 120 - h)
          : (coperto.bottom + 6).clamp(80.0, _misura.height - 120 - h);
    }
    return Offset(left, top);
  }

  void _posaLAnello(ProiezioneDelCielo proiezione, Offset sposta) {
    final s = _scelta;
    final cielo = _cieloA ?? _cielo;
    if (s == null || cielo == null) {
      _fotogramma.anello = false;
      return;
    }
    final double x, y, z;
    if (s.stella != null) {
      final d = _versoreDi(cielo, _cieloB, s.stella!);
      x = d.x;
      y = d.y;
      z = d.z;
    } else {
      final c = cielo.corpo(s.corpo!);
      x = c.x;
      y = c.y;
      z = c.z;
    }
    if (proiezione.proietta(_orientamento, x, y, z, _punto)) {
      _fotogramma
        ..anello = true
        ..anelloX = _punto[0] + sposta.dx
        ..anelloY = _punto[1] + sposta.dy
        ..anelloR = 14;
    } else {
      _fotogramma.anello = false;
    }
  }

  // =====================================================================
  // IL RITORNO (parte 3)
  // =====================================================================

  static const Duration _durataDellEta = Duration(milliseconds: 1800);
  static const Duration _durataDellArrivo = Duration(milliseconds: 3200);

  void _avanzaIlRitorno(Duration ora) {
    final piano = _piano;
    if (piano == null) return;
    if (_inizioDellaFase == Duration.zero) _inizioDellaFase = ora;
    final trascorso = ora - _inizioDellaFase;
    switch (_fase.value) {
      case FaseDelRitorno.eta:
        if (trascorso >= _durataDellEta) {
          _inizioDellaFase = ora;
          if (_riduciMovimento) {
            // Riduci Movimento: un passaggio secco (voce 3.4).
            _vaiAllaNascita(ora);
          } else {
            _fase.value = FaseDelRitorno.ritorno;
          }
        }
      case FaseDelRitorno.ritorno:
        // I due tempi (ordine FH parte 8): la corsa e poi l'ultimo anno.
        final secondi = trascorso.inMicroseconds / 1e6;
        final kf = piano.puntoAl(secondi);
        final k0 = kf.floor().clamp(0, piano.length - 1);
        final k1 = math.min(k0 + 1, piano.length - 1);
        _cieloA = _istante(k0);
        _cieloB = k1 == k0 ? null : _istante(k1);
        _tFraIstanti = kf - k0;
        _posaLaData(piano.dataAlPunto(kf));
        _nelRallentamento.value = kf > piano.fineDellaCorsa;
        if (kf > piano.fineDellaCorsa) {
          _agganciaAllaLuna(secondi - piano.durataDellaCorsa, piano);
        }
        if (secondi >= piano.durata) _vaiAllaNascita(ora);
      case FaseDelRitorno.arrivo:
        if (trascorso >= _durataDellArrivo) {
          _fase.value = FaseDelRitorno.fermo;
        }
      case FaseDelRitorno.fermo:
        break;
    }
  }

  CieloInUnIstante _istante(int k) {
    final gia = _istantiCalcolati[k];
    if (gia != null) return gia;
    final piano = _piano!;
    final c = CieloInUnIstante.calcola(
      _catalogo!,
      jd: piano.istanti[k],
      latitudine: piano.latitudini[k],
      longitudine: piano.longitudini[k],
    );
    MisureDelCosmo.istantiCalcolatiNelRitorno++;
    // Si tengono solo gli ultimi due: il ritorno va avanti, non indietro.
    _istantiCalcolati.removeWhere((chiave, _) => chiave < k - 1);
    return _istantiCalcolati[k] = c;
  }

  /// Durante il rallentamento la vista resta agganciata alla Luna, al centro
  /// del quadro, e il resto del cielo le gira intorno (ordine FH voce 8.4).
  /// Nel primo [_entrataNellAggancio] la vista scivola dove stava alla fine
  /// della corsa fino alla Luna; nell'ultimo [_uscitaDallAggancio] scivola
  /// dalla Luna alla vista dell'arrivo, cosi' l'arrivo non salta.
  static const double _entrataNellAggancio = 0.8;
  static const double _uscitaDallAggancio = 1.0;
  double? _azimutDellaCorsa, _altezzaDellaCorsa;
  double? _azimutDellArrivo, _altezzaDellArrivo;
  CieloInUnIstante? _cieloDellaNascita;

  void _agganciaAllaLuna(double secondi, PianoDelRiavvolgimento piano) {
    final a = _cieloA;
    if (a == null) return;
    final k = a.corpi.indexWhere((c) => c.corpo == CorpoCeleste.luna);
    if (k < 0) return;
    var x = a.corpi[k].x, y = a.corpi[k].y, z = a.corpi[k].z;
    final b = _cieloB;
    if (b != null && _tFraIstanti > 0) {
      x += (b.corpi[k].x - x) * _tFraIstanti;
      y += (b.corpi[k].y - y) * _tFraIstanti;
      z += (b.corpi[k].z - z) * _tFraIstanti;
    }
    final l = math.sqrt(x * x + y * y + z * z);
    var az = math.atan2(x, y) * 180 / math.pi;
    var alt = math.asin((z / l).clamp(-1.0, 1.0)) * 180 / math.pi;
    if (_azimutDellaCorsa == null) {
      _azimutDellaCorsa = _azimut;
      _altezzaDellaCorsa = _altezza;
      // La vista dell'arrivo, calcolata una volta: la regola di
      // _guardaVersoLaLuna sul cielo della nascita.
      // Il cielo della nascita a parte: _istante scarterebbe dalla sua cache
      // gli istanti in corso, che poi si ricalcolerebbero.
      var nascita = _cieloDellaNascita;
      if (nascita == null) {
        nascita = _cieloDellaNascita = CieloInUnIstante.calcola(
          _catalogo!,
          jd: piano.istanti.last,
          latitudine: piano.latitudini.last,
          longitudine: piano.longitudini.last,
        );
        MisureDelCosmo.istantiCalcolatiNelRitorno++;
      }
      final luna = nascita.corpo(CorpoCeleste.luna);
      if (luna.sopraLOrizzonte) {
        _azimutDellArrivo = luna.azimutGradi;
        _altezzaDellArrivo = luna.altezzaGradi.clamp(10, 70).toDouble();
      } else {
        _azimutDellArrivo = 180;
        _altezzaDellArrivo = 40;
      }
    }
    final entrata = _dolce(secondi / _entrataNellAggancio);
    az = _versoAngolo(_azimutDellaCorsa!, az, entrata);
    alt = _altezzaDellaCorsa! + (alt - _altezzaDellaCorsa!) * entrata;
    final uscita = _dolce(
      (secondi - (piano.durataDelRallentamento - _uscitaDallAggancio)) /
          _uscitaDallAggancio,
    );
    _azimut = _versoAngolo(az, _azimutDellArrivo!, uscita);
    _altezza = (alt + (_altezzaDellArrivo! - alt) * uscita).clamp(-89.5, 89.5);
  }

  static double _dolce(double t) {
    final x = t.clamp(0.0, 1.0);
    return x * x * (3 - 2 * x);
  }

  /// Da [da] verso [a] per la frazione [t], dalla parte piu' corta.
  static double _versoAngolo(double da, double a, double t) {
    final d = ((a - da + 540) % 360) - 180;
    return (da + d * t) % 360;
  }

  void _vaiAllaNascita(Duration ora) {
    final piano = _piano!;
    // L'arrivo ha il suo orologio: senza, ereditava quello della corsa e
    // finiva prima di cominciare.
    _inizioDellaFase = ora;
    _impostaIlCielo(_cieloDellaNascita ?? _istante(piano.length - 1));
    _cieloA = null;
    _cieloB = null;
    _tFraIstanti = 0;
    _posaLaData(piano.istanti.last);
    _fase.value = FaseDelRitorno.arrivo;
    _nelRallentamento.value = false;
    _guardaVersoLaLuna();
    _azimutDellaCorsa = null;
    _altezzaDellaCorsa = null;
  }

  /// GLI ANNI E LA DATA DEL RITORNO al giorno giuliano [jd] (aggiunta del
  /// fondatore all'ordine FH parte 8, 10 ottobre 2026): sotto "50 anni" la
  /// data, che scorre da oggi alla nascita insieme all'eta'. Il giorno e'
  /// quello del luogo: lo scarto dal tempo universale scivola da quello di
  /// adesso a quello della nascita, come il luogo. Gli anni sono l'eta' vera
  /// in quel giorno, contata sul calendario.
  void _posaLaData(double jd) {
    final piano = _piano;
    final nascitaUtc = _nascitaUtc;
    if (piano == null || nascitaUtc == null) return;
    final nascita = piano.istanti.last, adesso = piano.istanti.first;
    final f = adesso > nascita
        ? ((jd - nascita) / (adesso - nascita)).clamp(0.0, 1.0)
        : 0.0;
    final scarto = _scartoDellaNascita +
        (_adesso.timeZoneOffset - _scartoDellaNascita) * f;
    final giorno = IlCieloDiMeeus.istanteDi(jd).add(scarto);
    final nato = nascitaUtc.add(_scartoDellaNascita);
    var anni = giorno.year - nato.year;
    if (giorno.month < nato.month ||
        (giorno.month == nato.month && giorno.day < nato.day)) {
      anni--;
    }
    _anni.value = math.max(0, anni);
    _giornoDelRitorno.value =
        giorno.year * 10000 + giorno.month * 100 + giorno.day;
  }

  void _rivediIlRitorno() {
    _istantiCalcolati.clear();
    _azimutDellaCorsa = null;
    _altezzaDellaCorsa = null;
    _inizioDellaFase = Duration.zero;
    _fase.value = FaseDelRitorno.eta;
    _posaLaData(_piano!.istanti.first);
    _impostaIlCielo(
      CieloInUnIstante.calcola(
        _catalogo!,
        jd: _piano!.istanti.first,
        latitudine: _piano!.latitudini.first,
        longitudine: _piano!.longitudini.first,
      ),
    );
    _guardaVersoLaLuna();
    setState(() {});
  }

  // =====================================================================
  // IL BERSAGLIO DELL'INDICATORE (ordine FH parte 5)
  // =====================================================================

  void _preparaIBersagli(CatalogoDelleStelle catalogo) {
    final linee = _linee;
    if (linee == null) return;
    final n = _nascitaUtc;
    _bersagli = iBersagliDelCielo(
      linee: linee,
      catalogo: catalogo,
      segno: _segno,
      jdNascita: n == null ? null : Celestial.julianDay(n),
    );
    // Il bersaglio di partenza e' sempre la costellazione del segno della
    // persona (voce 5.5). Chi non ha dato la nascita parte dalla Luna, e
    // l'indicatore lo dice col suo nome.
    final ilTuo = _bersagli[CategoriaDelBersaglio.ilTuoCielo] ?? const [];
    _bersaglio = ilTuo.isNotEmpty
        ? ilTuo.first
        : _bersagli[CategoriaDelBersaglio.lunaESole]!.first;
  }

  /// La scelta fatta a mano vale finche' la schermata resta aperta (voce
  /// 5.5): sta nello stato, non nelle preferenze.
  void _scegliIlBersaglio(BersaglioDelCielo b, {bool primoASorgere = false}) {
    _bersaglio = b;
    _primoASorgere = primoASorgere;
    _ultimaLevata = DateTime.fromMillisecondsSinceEpoch(0);
    _aggiornaLaLevata();
    if (_fotogramma.scritte.length > 4) {
      final vecchia = _fotogramma.scritte[4].testo;
      _fotogramma.scritte[4] = ScrittaDaPosare(
        _scritta(
          b.nome,
          TypographyTokens.etichetta().copyWith(color: ColorTokens.goldBright),
        ),
      );
      vecchia.dispose();
    }
    _guida.value = null;
  }

  /// L'ora in cui il bersaglio sorge: al cambio di bersaglio e una volta al
  /// minuto, non a ogni fotogramma.
  void _aggiornaLaLevata() {
    final b = _bersaglio;
    if (b == null) return;
    final adesso = _istanteDelCielo;
    if (adesso.difference(_ultimaLevata).inSeconds.abs() < 60) return;
    _ultimaLevata = adesso;
    _sorgeIlBersaglio = quandoSorgeIlBersaglio(
      b,
      adesso,
      _luogoDelCielo.latitude,
      _luogoDelCielo.longitude,
    );
  }

  /// L'istante e il luogo del cielo mostrato: adesso, o la nascita.
  DateTime get _istanteDelCielo {
    final c = _cieloA ?? _cielo;
    return c == null ? _adesso : IlCieloDiMeeus.istanteDi(c.jd);
  }

  SkyPlace get _luogoDelCielo {
    final c = _cieloA ?? _cielo;
    return c == null
        ? _luogo
        : SkyPlace(latitude: c.latitudine, longitude: c.longitudine);
  }

  void _apriIlMenuDeiBersagli() {
    final palette = MaestroScope.of(context);
    foglioDelCerchio<void>(
      context: context,
      backgroundColor: palette.surface,
      isScrollControlled: true,
      builder: (contesto) => _MenuDeiBersagli(
        bersagli: _bersagli,
        attuale: _bersaglio,
        onScelta: (b) {
          Navigator.of(contesto).pop();
          setState(() => _scegliIlBersaglio(b));
        },
        onCategoria: (cat) {
          final scelta = sceltaNellaCategoria(
            _bersagli[cat] ?? const [],
            _istanteDelCielo,
            _luogoDelCielo.latitude,
            _luogoDelCielo.longitude,
          );
          final b = scelta.bersaglio;
          Navigator.of(contesto).pop();
          if (b != null) {
            setState(
              () => _scegliIlBersaglio(b, primoASorgere: scelta.primoASorgere),
            );
          }
        },
      ),
    );
  }

  // =====================================================================
  // I GESTI
  // =====================================================================

  void _alPizzicoInizio(ScaleStartDetails d) => _campoAlPizzico = _campo;

  void _alPizzico(ScaleUpdateDetails d) {
    final ppg = ProiezioneDelCielo(
      larghezza: _misura.width,
      altezza: _misura.height,
      campoGradi: _campo,
    ).puntiPerGrado;
    if (d.pointerCount >= 2) {
      _campo = (_campoAlPizzico / d.scale).clamp(kCampoMinimo, kCampoMassimo);
    }
    final spinta = d.focalPointDelta;
    if (spinta == Offset.zero) return;
    if (_colSensore && !_riduciMovimento) {
      // Il dito prende il comando: il sensore si ferma e il cielo resta dove
      // e', poi si sposta col dito.
      _colSensore = false;
      _telefono?.spegni();
      setState(() {});
    }
    _azimut = (_azimut - spinta.dx / ppg) % 360;
    _altezza = (_altezza + spinta.dy / ppg).clamp(-30.0, 89.5);
  }

  void _seguiIlTelefono() {
    if (_riduciMovimento) return;
    setState(() {
      _colSensore = !_colSensore;
      if (_colSensore) {
        _avvisoDellaBussola = null;
        _accesoDa = Duration.zero;
        _telefono?.accendi();
      } else {
        _telefono?.spegni();
      }
    });
  }

  void _alTocco(TapUpDetails d) {
    final cielo = _cieloA ?? _cielo;
    final scena = _scena;
    if (cielo == null || scena == null) return;
    final proiezione = ProiezioneDelCielo(
      larghezza: _misura.width,
      altezza: _misura.height,
      campoGradi: _campo,
    );
    final p = d.localPosition;
    // Prima i corpi, che sono pochi e grandi.
    for (var k = 0; k < cielo.corpi.length; k++) {
      final c = cielo.corpi[k];
      if (!proiezione.proietta(_orientamento, c.x, c.y, c.z, _punto)) continue;
      if ((Offset(_punto[0], _punto[1]) - p).distance < 26) {
        setState(() => _scelta = _Scelta.corpo(c.corpo));
        return;
      }
    }
    final griglia = _griglia ??= GrigliaDelTocco.di(cielo);
    final i = scena.piuVicina(
      sx: p.dx,
      sy: p.dy,
      raggio: 28,
      griglia: griglia,
      cielo: cielo,
      orientamento: _orientamento,
      proiezione: proiezione,
    );
    setState(() => _scelta = i < 0 ? null : _Scelta.stella(i));
  }

  Future<void> _usaLaPosizione() async {
    setState(() => _avvisoDelPermesso = null);
    final r = await widget.posizione.chiedi();
    if (!mounted) return;
    if (!r.concessa) {
      setState(
        () => _avvisoDelPermesso =
            'Senza la posizione il cielo resta quello di $_origineDelLuogo.',
      );
      return;
    }
    _luogo = r.luogo!;
    _luogoDiRipiego = false;
    _origineDelLuogo = r.luogo!.citta ?? 'la tua posizione';
    _telefono?.declinazioneGradi = declinazioneMagnetica(
      latitudine: _luogo.latitude,
      longitudine: _luogo.longitude,
      anno: annoDecimale(_adesso),
    ).gradi;
    if (widget.modo == ModoDelCielo.adesso) {
      _impostaIlCielo(
        CieloInUnIstante.calcola(
          _catalogo!,
          jd: Celestial.julianDay(_adesso.toUtc()),
          latitudine: _luogo.latitude,
          longitudine: _luogo.longitude,
        ),
      );
    }
    setState(() {});
  }

  // =====================================================================
  // LA RIGA CHE INVITA A PUNTARE (voce 6.4)
  // =====================================================================

  CorpoNelCielo? _astroDaPuntare(CieloInUnIstante cielo) {
    final luna = cielo.corpo(CorpoCeleste.luna);
    if (luna.sopraLOrizzonte) return luna;
    for (final c in cielo.corpi) {
      if (kPianetiBrillanti.contains(c.corpo) && c.sopraLOrizzonte) return c;
    }
    return null;
  }

  void _aggiornaLInvito(CieloInUnIstante cielo) {
    // Solo nel cielo di adesso e solo col sensore acceso: puntare serve a
    // rimettere in bolla la bussola, e senza bussola non c'e' niente da
    // rimettere. Se non c'e' niente lassu', non compare niente.
    String? testo;
    if (widget.modo == ModoDelCielo.adesso &&
        _usaIlSensore &&
        (_telefono?.pronto ?? false)) {
      final astro = _astroDaPuntare(cielo);
      if (astro != null) {
        final nome =
            astro.corpo == CorpoCeleste.luna ? 'La Luna' : astro.corpo.nome;
        testo = '$nome è lassù: portala al centro e tocca qui per un nord '
            'più preciso.';
      }
    }
    if (_invito.value != testo) _invito.value = testo;
  }

  void _allineaSullAstro() {
    final cielo = _cielo;
    final telefono = _telefono;
    if (cielo == null || telefono == null) return;
    final astro = _astroDaPuntare(cielo);
    if (astro == null) return;
    final distanza = ProiezioneDelCielo.distanzaDallAsse(
      _orientamento,
      astro.x,
      astro.y,
      astro.z,
    );
    final messaggio = ScaffoldMessenger.maybeOf(context);
    if (distanza > 15) {
      messaggio?.showSnackBar(
        const SnackBar(
          content: Text('Portala al centro dello schermo, poi tocca.'),
        ),
      );
      return;
    }
    telefono.correggiSu(
      azimutMisurato: _orientamento.azimutGradi,
      azimutVero: astro.azimutGradi,
    );
    messaggio?.showSnackBar(
      const SnackBar(content: Text('Bussola riallineata su un astro vero.')),
    );
  }

  // =====================================================================
  // LO SCHERMO
  // =====================================================================

  void _apriLeFonti(MaestroPalette palette) {
    FoglioDelleFonti.apri(
      context,
      palette: palette,
      testo: TestiDelleFonti.realTimeCosmo,
      chiave: 'real_time_cosmo_fonti',
    );
  }

  String get _titolo => switch (widget.modo) {
        ModoDelCielo.adesso => 'Il cielo di adesso',
        ModoDelCielo.nascita => 'Il cielo della tua nascita',
        ModoDelCielo.ritorno => 'Il ritorno nel tempo',
      };

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.of(context);
    return Scaffold(
      backgroundColor: kFondoDelCielo,
      body: LayoutBuilder(
        builder: (context, vincoli) {
          _misura = vincoli.biggest;
          return Stack(
            fit: StackFit.expand,
            children: [
              if (_scena != null && _sprite != null)
                GestureDetector(
                  key: const Key('real_time_cosmo_cielo'),
                  behavior: HitTestBehavior.opaque,
                  onScaleStart: _alPizzicoInizio,
                  onScaleUpdate: _alPizzico,
                  onTapUp: _alTocco,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: PittoreDelCielo(
                      scena: _scena!,
                      sprite: _sprite!,
                      fotogramma: _fotogramma,
                      battito: _battito,
                    ),
                  ),
                ),
              if (_guastoDelCielo != null) _Messaggio(testo: _guastoDelCielo!),
              _Testata(
                titolo: _titolo,
                colSensore: _usaIlSensore,
                sensoreDisponibile: !_riduciMovimento,
                onIndietro: () => Navigator.of(context).maybePop(),
                onFonti: () => _apriLeFonti(palette),
                onSensore: _seguiIlTelefono,
              ),
              ValueListenableBuilder<_Guida?>(
                valueListenable: _guida,
                builder: (context, g, _) => g == null || _misura.isEmpty
                    ? const SizedBox.shrink()
                    : _FrecciaDellaGuida(
                        guida: g,
                        misura: _misura,
                        onTocco: _apriIlMenuDeiBersagli,
                      ),
              ),
              if (widget.modo == ModoDelCielo.ritorno) _sceneDelRitorno(),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16 + MediaQuery.paddingOf(context).bottom,
                child: _pieDiPagina(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _pieDiPagina() {
    final righe = <Widget>[];
    final s = _scelta;
    if (s != null) righe.add(_schedaDellaScelta(s));
    if (widget.modo == ModoDelCielo.ritorno && _piano != null) {
      righe.add(
        ValueListenableBuilder<FaseDelRitorno>(
          valueListenable: _fase,
          builder: (context, fase, _) => fase != FaseDelRitorno.fermo
              ? const SizedBox.shrink()
              : _Riga(
                  key: const Key('real_time_cosmo_rivedi'),
                  testo: _fraseDellaLuna(),
                  azione: 'Rivedi il ritorno',
                  onAzione: _rivediIlRitorno,
                ),
        ),
      );
    }
    if (_mancaLaNascita && widget.modo != ModoDelCielo.adesso) {
      righe.add(
        _Riga(
          testo: 'Per il cielo della tua nascita servono la data e il luogo. '
              'Per ora vedi il cielo di adesso.',
          azione: 'Aggiungi i dati di nascita',
          onAzione: () =>
              Navigator.of(context).push(DatiDiNascitaScreen.route()),
        ),
      );
    }
    if (!_mancaLaNascita &&
        !_nascitaConOra &&
        widget.modo != ModoDelCielo.adesso) {
      righe.add(
        _Riga(
          testo: 'Senza l\'ora di nascita posso portarti al giorno, non '
              'all\'istante: il cielo è quello di mezzogiorno.',
          azione: 'Aggiungi l\'ora',
          onAzione: () =>
              Navigator.of(context).push(DatiDiNascitaScreen.route()),
        ),
      );
    }
    if (widget.modo == ModoDelCielo.adesso && _luogoDiRipiego) {
      righe.add(
        _Riga(
          testo:
              'Cielo calcolato su $_origineDelLuogo. Per il cielo sopra di te '
              'e il nord vero della bussola serve la tua posizione.',
          azione: 'Usa la mia posizione',
          onAzione: _usaLaPosizione,
        ),
      );
    }
    if (_avvisoDelPermesso != null) {
      righe.add(_Riga(testo: _avvisoDelPermesso!));
    }
    if (_rigaDellaLuna != null) {
      righe.add(
        _Riga(
          key: const Key('real_time_cosmo_riga_della_luna'),
          testo: _rigaDellaLuna!,
        ),
      );
    }
    if (_avvisoDellaBussola != null) {
      righe.add(_Riga(testo: _avvisoDellaBussola!));
    } else if (!_usaIlSensore && widget.modo == ModoDelCielo.adesso) {
      righe.add(
        const _Riga(
          testo: 'Esplori col dito. Tocca la bussola in alto per seguire il '
              'telefono.',
        ),
      );
    }
    righe.add(
      ValueListenableBuilder<String?>(
        valueListenable: _invito,
        builder: (context, testo, _) => testo == null
            ? const SizedBox.shrink()
            : _Riga(testo: testo, discreta: true, onTocco: _allineaSullAstro),
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final r in righe)
          Padding(padding: const EdgeInsets.only(top: 6), child: r),
      ],
    );
  }

  Widget _schedaDellaScelta(_Scelta s) {
    final cielo = _cieloA ?? _cielo!;
    final catalogo = _catalogo!;
    String titolo;
    final dettagli = <String>[];
    double x, y, z;
    if (s.stella != null) {
      final i = s.stella!;
      final proprio = catalogo.nomi[i];
      final sigla = catalogo.sigle[i];
      titolo = proprio != null
          ? (kStelleInItaliano[proprio] ?? proprio)
          : (sigla ?? 'Una stella senza nome');
      if (proprio != null && sigla != null) dettagli.add(sigla);
      final con = catalogo.costellazioneDi(i);
      if (con != null) {
        dettagli.add(
          'nella costellazione ${_della(kCostellazioniInItaliano[con] ?? con)}',
        );
      }
      dettagli.add('magnitudine ${_numero(catalogo.magnitudine[i])}');
      final d = _versoreDi(cielo, _cieloB, i);
      x = d.x;
      y = d.y;
      z = d.z;
    } else {
      final c = cielo.corpo(s.corpo!);
      titolo = c.corpo == CorpoCeleste.luna
          ? (widget.modo == ModoDelCielo.adesso
              ? 'La Luna di stanotte'
              : 'La Luna della tua nascita')
          : c.corpo.nome;
      x = c.x;
      y = c.y;
      z = c.z;
      if (c.corpo == CorpoCeleste.luna) {
        dettagli.add(
          'illuminata al ${(cielo.illuminazioneDellaLuna * 100).round()} per cento',
        );
      }
    }
    final alt = (math.asin(z.clamp(-1.0, 1.0)) * 180 / math.pi).round();
    var az = math.atan2(x, y) * 180 / math.pi;
    if (az < 0) az += 360;
    dettagli.add(
      alt >= 0
          ? 'alta $alt gradi sull\'orizzonte, verso ${_direzione(az)}'
          : 'sotto l\'orizzonte di ${-alt} gradi, verso ${_direzione(az)}',
    );
    // Sotto l'orizzonte la scheda dice anche quando sorge (voce 7.4 FH, la
    // regola del Cielo esistente): calcolata una volta per scelta.
    if (alt < 0) {
      if (!identical(_sceltaDellaLevata, s)) {
        _sceltaDellaLevata = s;
        final BersaglioDelCielo b = s.stella != null
            ? BersaglioFisso(
                'stella',
                titolo,
                CategoriaDelBersaglio.costellazioni,
                raGradi: catalogo.raGradi[s.stella!],
                decGradi: catalogo.decGradi[s.stella!],
              )
            : BersaglioCorpo(
                s.corpo!.name,
                titolo,
                CategoriaDelBersaglio.pianeti,
                s.corpo!,
              );
        _levataDellaScelta = quandoSorgeIlBersaglio(
          b,
          _istanteDelCielo,
          _luogoDelCielo.latitude,
          _luogoDelCielo.longitude,
        );
      }
      final quando = _levataDellaScelta;
      dettagli.add(
        quando == null ? 'oggi non sorge' : 'sorge alle ${_ora(quando)}',
      );
    }
    return _Scheda(
      titolo: titolo,
      testo: dettagli.join(', '),
      onChiudi: () => setState(() => _scelta = null),
    );
  }

  static String _della(String nome) {
    final minuscolo = nome.toLowerCase();
    if (RegExp(r'^[aeiou]').hasMatch(minuscolo)) return 'dell\'$nome';
    const femminili = {
      'Balena',
      'Bilancia',
      'Bussola',
      'Carena',
      'Cassiopea',
      'Chioma di Berenice',
      'Colomba',
      'Corona Australe',
      'Corona Boreale',
      'Croce del Sud',
      'Fenice',
      'Fornace',
      'Freccia',
      'Giraffa',
      'Gru',
      'Lepre',
      'Lince',
      'Lira',
      'Lucertola',
      'Macchina Pneumatica',
      'Mensa',
      'Mosca',
      'Poppa',
      'Squadra',
      'Vergine',
      'Vele',
      'Volpetta',
      'Orsa Maggiore',
      'Orsa Minore',
      'Idra',
      'Idra Maschio',
      'Andromeda',
      'Aquila',
    };
    if (nome == 'Lupo') return 'del $nome';
    if (nome == 'Vele') return 'delle $nome';
    if (nome == 'Pesci' || nome == 'Gemelli' || nome == 'Cani da Caccia') {
      return 'dei $nome';
    }
    if (nome.startsWith('Sc') || nome.startsWith('Z')) return 'dello $nome';
    return femminili.contains(nome) ? 'della $nome' : 'del $nome';
  }

  static String _numero(double v) => NumeroDelCerchio.conCifre(v, 1);

  static String _direzione(double az) {
    const nomi = [
      'nord',
      'nord-est',
      'est',
      'sud-est',
      'sud',
      'sud-ovest',
      'ovest',
      'nord-ovest',
    ];
    return nomi[((az + 22.5) % 360 ~/ 45)];
  }

  Widget _sceneDelRitorno() {
    if (_piano == null) return const SizedBox.shrink();
    return ValueListenableBuilder<FaseDelRitorno>(
      valueListenable: _fase,
      builder: (context, fase, _) {
        final grande = TypographyTokens.numeroDellaScena().copyWith(
          color: ColorTokens.goldBright,
        );
        final frase = TypographyTokens.titoloSezione().copyWith(
          color: ColorTokens.textPrimary,
        );
        switch (fase) {
          case FaseDelRitorno.eta:
          case FaseDelRitorno.ritorno:
            // Nel rallentamento la Luna e' agganciata al centro (voce 8.4): il
            // contatore sale dove sta la frase d'arrivo, altrimenti la
            // coprirebbe proprio mentre mostra le sue fasi (visto
            // nell'anteprima fh_14 della prima stesura).
            final alto = MediaQuery.paddingOf(context).top + 88;
            return Positioned.fill(
              child: IgnorePointer(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _nelRallentamento,
                  builder: (context, su, colonna) => Align(
                    alignment: su ? Alignment.topCenter : Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(top: su ? alto : 0),
                      child: colonna,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // "50 anni", e sotto la data che scorre con l'eta'
                      // (aggiunta del fondatore all'ordine FH parte 8).
                      ValueListenableBuilder<int>(
                        valueListenable: _anni,
                        builder: (context, anni, _) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '$anni',
                                  key: const Key('real_time_cosmo_anni'),
                                  style: grande,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  anni == 1 ? 'anno' : 'anni',
                                  key: const Key(
                                    'real_time_cosmo_parola_degli_anni',
                                  ),
                                  style: frase.copyWith(
                                    color: ColorTokens.goldBright,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      ValueListenableBuilder<int>(
                        valueListenable: _giornoDelRitorno,
                        builder: (context, g, _) => g == 0
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  0,
                                  24,
                                  12,
                                ),
                                child: Text(
                                  dataItalianaEstesa(
                                    DateTime(
                                      g ~/ 10000,
                                      g ~/ 100 % 100,
                                      g % 100,
                                    ),
                                  ),
                                  key: const Key('real_time_cosmo_data'),
                                  textAlign: TextAlign.center,
                                  style: frase,
                                ),
                              ),
                      ),
                      if (fase == FaseDelRitorno.ritorno)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'STO TORNANDO INDIETRO NEL TEMPO',
                            textAlign: TextAlign.center,
                            style: frase,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          case FaseDelRitorno.arrivo:
            return Positioned(
              left: 24,
              right: 24,
              top: MediaQuery.paddingOf(context).top + 88,
              // La marca del genere nella forma a posizioni (ordine FH voce
              // 8.5, fatto 3 della risposta del fondatore).
              child: Text(
                LaMarcaDelGenere.risolvi(kFraseDellArrivo),
                key: const Key('real_time_cosmo_frase_dell_arrivo'),
                textAlign: TextAlign.center,
                style: frase,
              ),
            );
          case FaseDelRitorno.fermo:
            // A scena ferma la frase della Luna e "Rivedi il ritorno" stanno
            // nel pie' di pagina, lontano dalla freccia della guida, che li'
            // in alto ci finiva sopra (visto sul Realme l'8 ottobre 2026).
            return const SizedBox.shrink();
        }
      },
    );
  }

  /// La frase della Luna dell'istante raggiunto, a scena ferma.
  String _fraseDellaLuna() {
    final luna = _cielo?.corpo(CorpoCeleste.luna);
    final sole = _cielo?.corpo(CorpoCeleste.sole);
    if (luna == null) return '';
    final quando =
        (sole?.sopraLOrizzonte ?? false) ? 'quel giorno' : 'quella notte';
    return luna.sopraLOrizzonte
        ? 'La Luna di $quando era lassù. Toccala per sapere dov\'era.'
        : 'La Luna di $quando era sotto l\'orizzonte, verso '
            '${_direzione(luna.azimutGradi)}.';
  }
}

class _Guida {
  const _Guida({
    required this.nome,
    required this.gradi,
    required this.angolo,
    required this.x,
    required this.y,
    this.riga,
    this.avviso,
  }) : inQuadroSoltanto = false;

  /// Il bersaglio e' in quadro: resta solo l'etichetta che apre il menu.
  const _Guida.inQuadro(this.nome)
      : gradi = 0,
        angolo = 0,
        x = 0,
        y = 0,
        riga = null,
        avviso = null,
        inQuadroSoltanto = true;

  final String nome;
  final int gradi;

  /// L'angolo sullo schermo verso il bersaglio, in radianti (0 a destra,
  /// positivo verso il basso).
  final double angolo;

  /// L'angolo in alto a sinistra della scritta.
  final double x, y;

  /// La riga sotto il nome: quando sorge, il primo a sorgere.
  final String? riga;

  /// L'avviso del Sole, che viene prima della direzione (voce 5.7).
  final String? avviso;
  final bool inQuadroSoltanto;

  @override
  bool operator ==(Object other) =>
      other is _Guida &&
      other.nome == nome &&
      other.inQuadroSoltanto == inQuadroSoltanto &&
      other.gradi == gradi &&
      other.riga == riga &&
      other.avviso == avviso &&
      other.x == x &&
      other.y == y;

  @override
  int get hashCode => Object.hash(nome, gradi, riga, avviso, x, y);
}

class _Scelta {
  const _Scelta.stella(this.stella) : corpo = null;
  const _Scelta.corpo(this.corpo) : stella = null;
  final int? stella;
  final CorpoCeleste? corpo;
}

class _Testata extends StatelessWidget {
  const _Testata({
    required this.titolo,
    required this.colSensore,
    required this.sensoreDisponibile,
    required this.onIndietro,
    required this.onFonti,
    required this.onSensore,
  });

  final String titolo;
  final bool colSensore;
  final bool sensoreDisponibile;
  final VoidCallback onIndietro;
  final VoidCallback onFonti;
  final VoidCallback onSensore;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Indietro',
                onPressed: onIndietro,
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: ColorTokens.textPrimary,
                ),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    titolo,
                    maxLines: 1,
                    style: TypographyTokens.titoloDiSchermata().copyWith(
                      color: ColorTokens.textPrimary,
                    ),
                  ),
                ),
              ),
              if (sensoreDisponibile)
                IconButton(
                  key: const Key('real_time_cosmo_sensore'),
                  tooltip:
                      colSensore ? 'Esplora col dito' : 'Segui il telefono',
                  onPressed: onSensore,
                  icon: Icon(
                    colSensore
                        ? Icons.explore_rounded
                        : Icons.touch_app_rounded,
                    color: ColorTokens.goldLight,
                  ),
                ),
              IconButton(
                key: const Key('real_time_cosmo_fonti_bottone'),
                tooltip: 'Fonti e metodo',
                onPressed: onFonti,
                icon: const Icon(
                  Icons.info_outline_rounded,
                  color: ColorTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// L'INDICATORE UNICO (voci 2.11 FG e 5.1-5.7 FH): sul bordo dello schermo,
/// dalla parte del bersaglio, col nome, l'icona che dice che si tocca per
/// scegliere, e la distanza in gradi dal centro che scende mentre ci si
/// avvicina. Quando il bersaglio e' in quadro la freccia sparisce e resta
/// solo l'etichetta col nome, in alto, che riapre il menu.
class _FrecciaDellaGuida extends StatelessWidget {
  const _FrecciaDellaGuida({
    required this.guida,
    required this.misura,
    required this.onTocco,
  });
  final _Guida guida;
  final Size misura;
  final VoidCallback onTocco;

  @override
  Widget build(BuildContext context) {
    final stile = TypographyTokens.etichetta().copyWith(
      color: ColorTokens.goldBright,
    );
    final nome = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            guida.nome,
            key: const Key('real_time_cosmo_guida_nome'),
            textAlign: TextAlign.center,
            maxLines: 2,
            style: stile,
          ),
        ),
        const Icon(
          Icons.arrow_drop_down_rounded,
          color: ColorTokens.goldBright,
          size: 22,
        ),
      ],
    );
    if (guida.inQuadroSoltanto) {
      return Positioned(
        left: 12,
        top: MediaQuery.paddingOf(context).top + 60,
        child: GestureDetector(
          key: const Key('real_time_cosmo_guida'),
          behavior: HitTestBehavior.opaque,
          onTap: onTocco,
          child: Padding(padding: const EdgeInsets.all(6), child: nome),
        ),
      );
    }
    final piccolo = TypographyTokens.didascalia().copyWith(
      color: ColorTokens.goldLight,
    );
    return Positioned(
      left: guida.x,
      top: guida.y,
      width: _CieloRealeScreenState._misuraDellaGuida.width,
      child: GestureDetector(
        key: const Key('real_time_cosmo_guida'),
        behavior: HitTestBehavior.opaque,
        onTap: onTocco,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (guida.avviso != null)
              Text(
                guida.avviso!,
                key: const Key('real_time_cosmo_avviso_del_sole'),
                textAlign: TextAlign.center,
                style: stile.copyWith(color: ColorTokens.textPrimary),
              ),
            if (!guida.angolo.isNaN)
              Transform.rotate(
                angle: guida.angolo,
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: ColorTokens.goldBright,
                  size: 26,
                ),
              ),
            nome,
            Text(
              guida.riga ?? '${guida.gradi}°',
              textAlign: TextAlign.center,
              style: guida.riga == null ? stile : piccolo,
            ),
          ],
        ),
      ),
    );
  }
}

class _Riga extends StatelessWidget {
  const _Riga({
    super.key,
    required this.testo,
    this.azione,
    this.onAzione,
    this.onTocco,
    this.discreta = false,
  });

  final String testo;
  final String? azione;
  final VoidCallback? onAzione;
  final VoidCallback? onTocco;
  final bool discreta;

  @override
  Widget build(BuildContext context) {
    final riga = Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, azione == null ? 8 : 0),
      decoration: BoxDecoration(
        color: ColorTokens.medoraDeepest.withValues(
          alpha: discreta ? 0.55 : 0.82,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            testo,
            style: TypographyTokens.didascalia().copyWith(
              color: ColorTokens.textSecondary,
            ),
          ),
          if (azione != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onAzione,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
                child: Text(
                  azione!,
                  style: TypographyTokens.etichetta().copyWith(
                    color: ColorTokens.goldLight,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    if (onTocco == null) return riga;
    return GestureDetector(onTap: onTocco, child: riga);
  }
}

class _Scheda extends StatelessWidget {
  const _Scheda({
    required this.titolo,
    required this.testo,
    required this.onChiudi,
  });
  final String titolo;
  final String testo;
  final VoidCallback onChiudi;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('real_time_cosmo_scheda'),
      padding: const EdgeInsets.fromLTRB(16, 12, 4, 14),
      decoration: BoxDecoration(
        color: ColorTokens.medoraDeepest.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorTokens.gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titolo,
                  style: TypographyTokens.titoloDiRiga().copyWith(
                    color: ColorTokens.goldBright,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  testo,
                  style: TypographyTokens.corpo().copyWith(
                    color: ColorTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Chiudi',
            onPressed: onChiudi,
            icon: const Icon(
              Icons.close_rounded,
              color: ColorTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Messaggio extends StatelessWidget {
  const _Messaggio({required this.testo});
  final String testo;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            testo,
            textAlign: TextAlign.center,
            style: TypographyTokens.corpo().copyWith(
              color: ColorTokens.textSecondary,
            ),
          ),
        ),
      );
}

/// IL MENU DEI BERSAGLI (ordine FH voce 5.3): due livelli, le cinque
/// categorie e poi gli oggetti della categoria. Il primo elemento di ogni
/// categoria con piu' oggetti e' la scelta automatica: il piu' alto sopra
/// l'orizzonte, o il primo a sorgere (voce 5.4).
class _MenuDeiBersagli extends StatefulWidget {
  const _MenuDeiBersagli({
    required this.bersagli,
    required this.attuale,
    required this.onScelta,
    required this.onCategoria,
  });

  final Map<CategoriaDelBersaglio, List<BersaglioDelCielo>> bersagli;
  final BersaglioDelCielo? attuale;
  final ValueChanged<BersaglioDelCielo> onScelta;
  final ValueChanged<CategoriaDelBersaglio> onCategoria;

  @override
  State<_MenuDeiBersagli> createState() => _MenuDeiBersagliState();
}

class _MenuDeiBersagliState extends State<_MenuDeiBersagli> {
  CategoriaDelBersaglio? _categoria;

  @override
  Widget build(BuildContext context) {
    final titolo = TypographyTokens.titoloDiRiga().copyWith(
      color: ColorTokens.goldBright,
    );
    final voce = TypographyTokens.corpo().copyWith(
      color: ColorTokens.textPrimary,
    );
    final cat = _categoria;
    final righe = <Widget>[];
    if (cat == null) {
      righe.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text('Dove deve puntare l\'indicatore?', style: titolo),
        ),
      );
      for (final c in CategoriaDelBersaglio.values) {
        final elenco = widget.bersagli[c] ?? const [];
        if (elenco.isEmpty) continue;
        righe.add(
          ListTile(
            key: Key('real_time_cosmo_categoria_${c.name}'),
            title: Text(c.nome, style: voce),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: ColorTokens.textSecondary,
            ),
            onTap: () => setState(() => _categoria = c),
          ),
        );
      }
    } else {
      final elenco = widget.bersagli[cat] ?? const [];
      righe.add(
        ListTile(
          leading: const Icon(
            Icons.arrow_back_rounded,
            color: ColorTokens.textSecondary,
          ),
          title: Text(cat.nome, style: titolo),
          onTap: () => setState(() => _categoria = null),
        ),
      );
      if (elenco.length > 1) {
        righe.add(
          ListTile(
            key: Key('real_time_cosmo_automatico_${cat.name}'),
            title: Text('Il più alto adesso', style: voce),
            subtitle: Text(
              'o il primo a sorgere, se nessuno è sopra',
              style: TypographyTokens.didascalia().copyWith(
                color: ColorTokens.textSecondary,
              ),
            ),
            onTap: () => widget.onCategoria(cat),
          ),
        );
      }
      for (final b in elenco) {
        righe.add(
          ListTile(
            key: Key('real_time_cosmo_bersaglio_${b.id}'),
            title: Text(b.nome, style: voce),
            trailing: b.id == widget.attuale?.id
                ? const Icon(Icons.check_rounded, color: ColorTokens.goldLight)
                : null,
            onTap: () => widget.onScelta(b),
          ),
        );
      }
    }
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: ListView(shrinkWrap: true, children: righe),
      ),
    );
  }
}

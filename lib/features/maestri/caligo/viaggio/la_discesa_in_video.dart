import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/sensi/catalogo_suoni.dart';
import '../../../../core/sensi/palette_sensoriale.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import 'il_tunnel_che_scende.dart';

/// **LA DISCESA E' UN FILMATO, E LO GOVERNA IL DITO.** Ordine DI voce 09,
/// 12 settembre 2026.
///
/// **Il fondatore, sul tunnel disegnato:** *"una persona normale, vedendo solo
/// quella specie di animazione, capisce che sta entrando in un tunnel o fosso
/// o quello che dovrebbe essere?"*. No: vedeva una texture che scorre e un
/// cerchio di luce. Adesso vede il bosco dall'alto, le radici che convergono in
/// un buco, il buio, la galleria di radici e la luce dorata in fondo: otto
/// secondi girati apposta e consegnati dal fondatore.
///
/// **IL PRINCIPIO RESTA QUELLO DELL'ORDINE DC**: non e' un'animazione che
/// parte, e' una scena che risponde alla mano. Col dito premuto il filmato va,
/// col dito alzato rallenta fino a fermarsi, e il tamburo continua a battere:
/// *"il contrasto fra il tamburo che continua e l'immagine ferma dice da solo
/// che si e' fermata la persona, non il Mondo di Sotto"*.
class DiscesaInVideo {
  const DiscesaInVideo._();

  /// **IL PERCORSO E' SPEZZATO IN PEZZI SENZA BARRE**, come quello della
  /// roccia: una barra scritta dentro una stringa viene letta come un elenco
  /// di participi dalla guardia `niente_vocativo_a_schermo`.
  static const String _dentro = 'brand_assets';
  static const String _dove = 'mondo_di_sotto';
  static const String _file = 'discesa_v1.mp4';
  static const String _fermo = 'discesa_v1_primo_fotogramma.webp';

  /// Il filmato del fondatore: 720 per 1280, 24 fotogrammi al secondo, 8,000
  /// secondi, muto. L'impronta sta in `docs/stato_asset.json`.
  static const String filmato = '$_dentro/$_dove/$_file';

  /// **IL PRIMO FOTOGRAMMA COME IMMAGINE FERMA.** L'ordine: *"prima del primo
  /// tocco si mostra il primo fotogramma come immagine ferma, mai uno schermo
  /// nero"*. E' il fotogramma zero del filmato, estratto senza toccare il
  /// filmato: quando il lettore parte, l'immagine sotto e il filmato sopra
  /// sono la stessa cosa, e il passaggio non si vede.
  static const String primoFotogramma = '$_dentro/$_dove/$_fermo';

  /// **QUANTO DURA LA DISCESA COL DITO SEMPRE PREMUTO: quanto il filmato.**
  ///
  /// **Qui c'erano venti secondi**, ordini DE voce 06 e DG voce 06, per la
  /// prima discesa e per le altre. Il tempo adesso non lo decide una costante:
  /// lo decide il filmato che il fondatore ha fatto girare, e il tunnel di
  /// riserva lo segue, perche' chi scende non deve accorgersi di quale dei
  /// due sta guardando.
  static const Duration durata = Duration(seconds: 8);

  /// **LA RAMPA DEL DITO: mezzo secondo, in dieci gradini.** L'ordine: *"dito
  /// alzato: la velocita' scende da 1.0 a 0 in 500 millisecondi con
  /// setPlaybackSpeed, poi pause. Nessun blocco secco. Dito ripremuto: la
  /// velocita' risale da 0 a 1.0 in 500 millisecondi"*.
  ///
  /// **Il primo gradino della salita e' il tocco stesso.** Il lettore non
  /// accetta la velocita' zero, e un filmato fermo che aspetta cinquanta
  /// millisecondi prima di muoversi e' un dito che non risponde: al tocco si
  /// parte a un decimo, e al decimo gradino si e' a uno.
  static const Duration rampa = Duration(milliseconds: 500);

  /// Quanti gradini ha la rampa.
  static const int gradini = 10;

  /// Ogni quanto si sale o si scende di un gradino.
  static Duration get passoDellaRampa => rampa ~/ gradini;

  /// **LA DISSOLVENZA VERSO LA NEBBIA.** L'ordine: *"l'ultimo fotogramma del
  /// filmato e' luce dorata e non nebbia: senza la dissolvenza si vede uno
  /// stacco secco"*.
  static const Duration dissolvenzaVersoLaNebbia = Duration(milliseconds: 500);

  /// **DOPO QUANTO COMPARE "Salta la discesa"**, dalla seconda discesa in
  /// poi. Alla prima no: la prima discesa si fa.
  static const Duration quandoSiPuoSaltare = Duration(milliseconds: 1500);

  /// **IL COLORE SOTTO IL PRIMO FOTOGRAMMA**, misurato su di lui: la media
  /// dei suoi pixel. Se l'immagine tardasse un fotogramma a decodificarsi,
  /// sotto non c'e' il nero ma il colore del bosco.
  static const Color fondo = Color(0xFF232736);
}

/// **IL LETTORE DELLA DISCESA, dietro una porta sola.**
///
/// E' la stessa forma di `LettoreDiRivelazione`, da cui l'ordine dice di
/// copiare, e per la stessa ragione: in una prova headless non c'e' nessuna
/// piattaforma che decodifichi un filmato, e senza una finta al posto del
/// lettore vero **nessuna misura della rampa, del primo fotogramma o della
/// fine si potrebbe prendere**. Rispetto a quello aggiunge la velocita', la
/// pausa e la ripresa, perche' qui il filmato non parte da solo: lo muove il
/// dito.
///
/// **Chi lo implementa promette di non lanciare mai.** Un file mancante o un
/// codec rifiutato si dichiarano con [fallito], e la discesa scende nel
/// tunnel di riserva.
abstract class LettoreDellaDiscesa {
  /// Il lettore vero, con `video_player`.
  factory LettoreDellaDiscesa.vero() = _LettoreDellaDiscesaVero;

  /// Prepara il filmato **senza farlo partire**. Non lancia mai.
  Future<void> apri();

  /// Vero quando il filmato e' pronto a partire.
  bool get pronto;

  /// Vero quando [apri] ha finito senza riuscirci.
  bool get fallito;

  /// Vero quando il filmato e' andato oltre il primo fotogramma: da li' in
  /// poi lo si mostra, prima c'e' l'immagine ferma.
  bool get cominciato;

  /// Vero quando il filmato e' arrivato in fondo.
  bool get finito;

  /// Chi ascolta i cambi di stato: uno solo, e nullo per smettere.
  void ascolta(VoidCallback? quandoCambia);

  /// Parte, o riparte da dove si era fermato. **Mai un salto**: l'ordine
  /// vieta `seekTo`, che su Android si aggancia ai fotogrammi chiave e
  /// produce scatti.
  Future<void> avvia();

  /// Si ferma dov'e'.
  Future<void> sospendi();

  /// La velocita', fra un decimo e uno.
  Future<void> velocita(double quanto);

  /// Il fotogramma corrente, a schermo pieno.
  Widget disegna();

  /// Libera tutto. Va chiamata sempre, anche se [apri] non ce l'ha fatta.
  void chiudi();
}

/// Chi costruisce il lettore. La finta delle prove si mette qui.
typedef FabbricaDellaDiscesa = LettoreDellaDiscesa Function();

class _LettoreDellaDiscesaVero implements LettoreDellaDiscesa {
  _LettoreDellaDiscesaVero();

  VideoPlayerController? _c;
  VoidCallback? _quandoCambia;
  bool _pronto = false;
  bool _fallito = false;
  bool _cominciato = false;
  bool _finito = false;

  @override
  bool get pronto => _pronto;

  @override
  bool get fallito => _fallito;

  @override
  bool get cominciato => _cominciato;

  @override
  bool get finito => _finito;

  @override
  void ascolta(VoidCallback? quandoCambia) => _quandoCambia = quandoCambia;

  @override
  Future<void> apri() async {
    final c = VideoPlayerController.asset(DiscesaInVideo.filmato);
    _c = c;
    try {
      await c.initialize();
      // Chiuso mentre si preparava: la persona se n'e' andata dalla soglia.
      if (!identical(_c, c)) return;
      // **MUTO, e lo e' gia' il file.** Lo si dice lo stesso al lettore: il
      // suono di questa scena e' il tamburo, che sta in un livello suo.
      await c.setVolume(0);
      await c.setLooping(false);
      c.addListener(_guarda);
      _pronto = true;
    } catch (errore) {
      // **PERCHE' QUESTO ERRORE SI ASSORBE**, come nel lettore della
      // rivelazione: file assente, codec rifiutato o nessuna piattaforma che
      // decodifichi vogliono tutti la stessa risposta, cioe' il tunnel di
      // riserva. Rilanciare trasformerebbe un filmato che manca in una
      // discesa che si rompe. L'errore non si butta: chi apre la console lo
      // trova.
      debugPrint('Il filmato della discesa non si prepara, si scende nel '
          'tunnel di riserva: $errore');
      _fallito = true;
    }
    _quandoCambia?.call();
  }

  void _guarda() {
    final c = _c;
    if (c == null) return;
    final v = c.value;
    var cambiato = false;
    if (!_cominciato && v.position > Duration.zero) {
      _cominciato = true;
      cambiato = true;
    }
    if (!_finito &&
        v.isInitialized &&
        v.duration > Duration.zero &&
        (v.isCompleted || v.position >= v.duration)) {
      _finito = true;
      cambiato = true;
    }
    if (cambiato) _quandoCambia?.call();
  }

  @override
  Future<void> avvia() async {
    // **A FILMATO FINITO NON SI RIPARTE**: `play` di video_player, a
    // posizione uguale alla durata, torna all'inizio con un salto.
    if (_finito) return;
    try {
      await _c?.play();
    } catch (errore) {
      debugPrint('Il filmato della discesa non riparte: $errore');
    }
  }

  @override
  Future<void> sospendi() async {
    try {
      await _c?.pause();
    } catch (errore) {
      debugPrint('Il filmato della discesa non si ferma: $errore');
    }
  }

  @override
  Future<void> velocita(double quanto) async {
    try {
      await _c?.setPlaybackSpeed(
          quanto.clamp(1 / DiscesaInVideo.gradini, 1.0).toDouble());
    } catch (errore) {
      debugPrint('La velocità del filmato non cambia: $errore');
    }
  }

  /// **BoxFit.cover, come il lettore della rivelazione**: il filmato e' 9 a
  /// 16 e lo schermo e' piu' alto, e con `contain` resterebbero due bande.
  @override
  Widget disegna() {
    final c = _c;
    if (c == null) return const SizedBox.shrink();
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: c.value.size.width,
        height: c.value.size.height,
        child: VideoPlayer(c),
      ),
    );
  }

  @override
  void chiudi() {
    final c = _c;
    _c = null;
    _quandoCambia = null;
    if (c == null) return;
    c.removeListener(_guarda);
    c.pause().catchError((Object _) {});
    c.dispose().catchError((Object _) {});
  }
}

/// **COSA FA UN GRADINO DELLA RAMPA.**
enum PassoDellaRampa {
  /// Niente: la rampa e' ferma dove deve stare.
  niente,

  /// La velocita' e' cambiata, e va detta al lettore.
  velocita,

  /// La velocita' e' arrivata a zero: il lettore si mette in pausa.
  ferma,
}

/// **LA RAMPA DEL DITO, pura.** Ordine DI voce 09.
///
/// Sta fuori dal widget perche' una guardia la possa percorrere gradino per
/// gradino senza montare niente, e perche' la stessa rampa muove sia il
/// filmato sia il tunnel di riserva: chi scende nel tunnel rallenta e riparte
/// come chi scende nel filmato.
class RampaDelDito {
  int _gradino = 0;
  bool _premuto = false;

  /// La velocita' di adesso, da zero a uno.
  double get velocita => _gradino / DiscesaInVideo.gradini;

  /// Vero quando la rampa e' arrivata dove il dito la vuole.
  bool get ferma =>
      _premuto ? _gradino == DiscesaInVideo.gradini : _gradino == 0;

  /// **IL DITO SI POSA.** Torna vero se si parte da fermi: chi chiama deve
  /// far partire il lettore, al primo gradino.
  bool premi() {
    _premuto = true;
    if (_gradino > 0) return false;
    _gradino = 1;
    return true;
  }

  /// **IL DITO SI ALZA.** Non ci si ferma di colpo: da qui la rampa scende.
  void alza() => _premuto = false;

  /// **FERMA SUBITO**, senza rampa: l'app se ne va, e nessuno sta guardando
  /// rallentare.
  void fermaSubito() {
    _premuto = false;
    _gradino = 0;
  }

  /// **UN GRADINO**, in su se il dito e' premuto, in giu' se non lo e'.
  PassoDellaRampa passo() {
    if (_premuto) {
      if (_gradino >= DiscesaInVideo.gradini) return PassoDellaRampa.niente;
      _gradino++;
      return PassoDellaRampa.velocita;
    }
    if (_gradino == 0) return PassoDellaRampa.niente;
    _gradino--;
    return _gradino == 0 ? PassoDellaRampa.ferma : PassoDellaRampa.velocita;
  }
}

/// **L'ALONE SOTTO IL POLPASTRELLO.** Ordine DI voce 09.
///
/// L'ordine: *"sotto il polpastrello si disegna in Flutter un alone che pulsa
/// a circa quattro battiti e mezzo al secondo, alla cadenza del tamburo. Serve
/// a dichiarare nel primo mezzo secondo che il controllo e' della persona."*
///
/// **Il primo battito cade al tocco**, non dopo: e' la risposta del Mondo di
/// Sotto al dito che si posa, e deve arrivare prima di qualunque altra cosa.
///
/// **Col `Timer`, non con un `AnimationController`**: sul telefono di collaudo
/// le scale di animazione valgono zero, e un alone fatto col controller
/// resterebbe fermo proprio li'.
class AloneDelPolpastrello extends StatefulWidget {
  const AloneDelPolpastrello({super.key, required this.colore});

  final Color colore;

  /// **QUANTO E' GRANDE**: il raggio della scatola in cui pulsa. Un
  /// polpastrello copre una ventina di punti, e l'alone deve vedersi attorno
  /// al dito, non sotto.
  static const double raggio = 64;

  /// **LA FORMA DEL BATTITO**, da uno sul colpo a quasi zero prima del
  /// successivo. Un colpo di tamburo e' un attacco e una coda, non un'onda:
  /// per questo e' un esponenziale che cade, e non un seno.
  static double battito(Duration dalTocco) => math.exp(-5 * faseAl(dalTocco));

  /// **DOVE SI E' DENTRO IL BATTITO**, da zero sul colpo a quasi uno prima del
  /// successivo, alla cadenza del tamburo.
  static double faseAl(Duration dalTocco) {
    final battiti = dalTocco.inMicroseconds /
        Duration.microsecondsPerSecond *
        IlTamburoDellaDiscesa.battitiAlSecondo;
    return battiti - battiti.floorToDouble();
  }

  @override
  State<AloneDelPolpastrello> createState() => _AloneDelPolpastrelloState();
}

class _AloneDelPolpastrelloState extends State<AloneDelPolpastrello> {
  final Stopwatch _dalTocco = Stopwatch()..start();
  Timer? _battito;

  @override
  void initState() {
    super.initState();
    // Sessanta volte al secondo, e solo finche' il dito e' posato: l'alone
    // nasce col tocco e muore con lui.
    _battito = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _battito?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = _dalTocco.elapsed;
    return CustomPaint(
      size: const Size.square(AloneDelPolpastrello.raggio * 2),
      painter: PittoreDellAlone(
        battito: AloneDelPolpastrello.battito(t),
        fase: AloneDelPolpastrello.faseAl(t),
        colore: widget.colore,
      ),
    );
  }
}

/// Il pittore dell'alone. Pubblico perche' una guardia lo possa dipingere.
class PittoreDellAlone extends CustomPainter {
  PittoreDellAlone({
    required this.battito,
    required this.fase,
    required this.colore,
  });

  final double battito;
  final double fase;
  final Color colore;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    // **IL CUORE DELL'ALONE**, che si gonfia sul colpo e si sgonfia nella
    // coda.
    final cuore = r * (0.52 + 0.20 * battito);
    canvas.drawCircle(
      centro,
      cuore,
      Paint()
        ..shader = RadialGradient(colors: [
          colore.withValues(alpha: 0.30 + 0.35 * battito),
          colore.withValues(alpha: 0.10 + 0.12 * battito),
          colore.withValues(alpha: 0),
        ], stops: const [0.0, 0.55, 1.0])
            .createShader(Rect.fromCircle(center: centro, radius: cuore)),
    );
    // **L'ONDA DEL COLPO**, che parte dal dito e si allarga fino al bordo,
    // come la pelle del tamburo che vibra: dice il battito anche a chi
    // tiene il telefono muto.
    canvas.drawCircle(
      centro,
      r * (0.40 + 0.56 * fase),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = colore.withValues(alpha: 0.55 * (1 - fase)),
    );
  }

  @override
  bool shouldRepaint(PittoreDellAlone vecchio) =>
      vecchio.battito != battito ||
      vecchio.fase != fase ||
      vecchio.colore != colore;
}

/// **LA DISCESA, a schermo pieno.** Ordine DI voce 09.
///
/// Il filmato se c'e', il tunnel disegnato se non c'e'. Chi la monta le passa
/// il lettore **gia' aperto**: l'ordine vuole che il filmato si prepari mentre
/// la persona sceglie o scrive la domanda, cosi' la riproduzione parte senza
/// attesa.
class LaDiscesa extends StatefulWidget {
  const LaDiscesa({
    super.key,
    required this.lettore,
    required this.conosciuta,
    required this.palette,
    required this.quandoFinisce,
  });

  /// Il lettore del filmato. Nullo, o [LettoreDellaDiscesa.fallito], vuol
  /// dire il tunnel di riserva.
  final LettoreDellaDiscesa? lettore;

  /// Vero dalla seconda discesa in poi: e' li' che si puo' saltare.
  final bool conosciuta;

  final MaestroPalette palette;

  /// Si chiama una volta sola, a discesa compiuta o saltata, con la quota a
  /// cui si era nel tunnel di riserva: la nebbia entra in dissolvenza sopra
  /// cio' che si stava guardando, non sopra un'altra cosa.
  final ValueChanged<double> quandoFinisce;

  @override
  State<LaDiscesa> createState() => _LaDiscesaState();
}

class _LaDiscesaState extends State<LaDiscesa> with WidgetsBindingObserver {
  final RampaDelDito _rampa = RampaDelDito();

  /// Il battito della rampa, e nel tunnel anche quello del cammino.
  Timer? _battito;
  Timer? _attesaDelSalto;

  /// Dove sta il dito, per l'alone. Nullo quando non c'e' nessun dito.
  Offset? _dito;
  bool _siPuoSaltare = false;
  bool _finita = false;

  /// Vero quando al lettore e' stato detto di andare, e non di fermarsi.
  bool _inCorsa = false;

  /// **QUANTO SI E' SCESI NEL TUNNEL DI RISERVA**, da 0 a 1.
  double _scesi = 0;

  LettoreDellaDiscesa? get _lettore => widget.lettore;

  /// Il filmato c'e' ed e' pronto.
  bool get _colFilmato => _lettore?.pronto ?? false;

  /// **SI SCENDE NEL TUNNEL**: il filmato non c'e', o non si e' preparato.
  bool get _nellaRiserva => _lettore == null || _lettore!.fallito;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lettore?.ascolta(_cambia);
    if (widget.conosciuta) {
      _attesaDelSalto = Timer(DiscesaInVideo.quandoSiPuoSaltare, () {
        if (mounted) setState(() => _siPuoSaltare = true);
      });
    }
    // **IL TAMBURO COMINCIA CON LA DISCESA**, prima del dito: e' lui che
    // chiama giu', e chi arriva qui lo sente battere prima di toccare.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(PaletteSensoriale.tamburo(context));
    });
  }

  @override
  void didUpdateWidget(LaDiscesa vecchio) {
    super.didUpdateWidget(vecchio);
    if (!identical(vecchio.lettore, widget.lettore)) {
      vecchio.lettore?.ascolta(null);
      widget.lettore?.ascolta(_cambia);
    }
  }

  /// **L'APP SE NE VA: IL FILMATO SI FERMA SUBITO, E AL RITORNO ASPETTA IL
  /// DITO.** L'ha trovato la guardia `nessuna_sorgente_resta_accesa_in_
  /// sottofondo`, che pretende da ogni lettore di sapere quando l'app se ne
  /// va.
  ///
  /// **Il difetto che c'era dietro, e non era il suono**: il filmato e' muto.
  /// `video_player` sospende da solo col telefono in tasca, ma al ritorno
  /// **riprende da solo se stava andando**: chi scendeva col dito premuto e
  /// riceveva una telefonata, tornando, avrebbe visto la discesa andare avanti
  /// senza nessun dito. Qui ci si ferma gia' allo stato `inactive`, che viene
  /// prima di `paused`: quando `video_player` guarda, il filmato e' fermo, e al
  /// ritorno non riparte niente finche' la persona non preme.
  @override
  void didChangeAppLifecycleState(AppLifecycleState stato) {
    if (stato == AppLifecycleState.resumed || _finita) return;
    _rampa.fermaSubito();
    _battito?.cancel();
    _battito = null;
    if (_colFilmato && _inCorsa) unawaited(_lettore!.sospendi());
    _inCorsa = false;
    if (mounted) setState(() => _dito = null);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _battito?.cancel();
    _attesaDelSalto?.cancel();
    _lettore?.ascolta(null);
    // **IL TAMBURO SI ALLONTANA MENTRE LA GALLERIA SVANISCE**: la
    // dissolvenza verso la nebbia e lo spegnimento durano lo stesso mezzo
    // secondo.
    PaletteSensoriale.fermaIlTamburo();
    super.dispose();
  }

  void _cambia() {
    if (!mounted || _finita) return;
    final lettore = _lettore;
    if (lettore != null && lettore.finito) {
      _finisci(1);
      return;
    }
    // **IL FILMATO ARRIVA A DITO GIA' POSATO**: si parte da dove la rampa e'
    // arrivata, senza aspettare un altro tocco.
    if (_colFilmato && _dito != null && !_inCorsa) {
      unawaited(lettore!.velocita(math.max(_rampa.velocita, 0.1)));
      unawaited(lettore.avvia());
      _inCorsa = true;
    }
    // **IL FILMATO NON C'E' A DITO POSATO**: il tunnel prende il suo posto e
    // la rampa comincia a muovere lui.
    if (_nellaRiserva && _dito != null) _accendiIlBattito();
    setState(() {});
  }

  void _giu(PointerDownEvent e) {
    if (_finita) return;
    final daFermi = _rampa.premi();
    if (_colFilmato && (daFermi || !_inCorsa)) {
      unawaited(_lettore!.velocita(_rampa.velocita));
      unawaited(_lettore!.avvia());
      _inCorsa = true;
    }
    _accendiIlBattito();
    setState(() => _dito = e.localPosition);
  }

  void _muovi(PointerMoveEvent e) {
    if (_dito == null) return;
    setState(() => _dito = e.localPosition);
  }

  void _su() {
    _rampa.alza();
    _accendiIlBattito();
    if (mounted) setState(() => _dito = null);
  }

  void _accendiIlBattito() {
    // **A DISCESA FINITA NON SI RIACCENDE NIENTE.** Il dito che si alza dopo
    // la fine arriva lo stesso qui: il sistema consegna l'alzata a chi ha
    // ricevuto il tocco, anche se nel frattempo e' stato smontato. Senza
    // questa riga un battito da cinquanta millisecondi restava acceso per
    // sempre dopo ogni discesa, e l'ha trovato la prova della durata.
    if (!mounted || _finita) return;
    if (_battito != null) return;
    _battito = Timer.periodic(DiscesaInVideo.passoDellaRampa, _unGradino);
  }

  void _unGradino(Timer t) {
    if (!mounted || _finita) {
      t.cancel();
      return;
    }
    final lettore = _lettore;
    final esito = _rampa.passo();
    if (_colFilmato && lettore != null) {
      switch (esito) {
        case PassoDellaRampa.velocita:
          unawaited(lettore.velocita(_rampa.velocita));
        case PassoDellaRampa.ferma:
          unawaited(lettore.sospendi());
          _inCorsa = false;
        case PassoDellaRampa.niente:
          break;
      }
      if (_rampa.ferma) {
        t.cancel();
        _battito = null;
      }
      return;
    }
    if (_nellaRiserva) {
      // **IL TUNNEL SCENDE ALLA VELOCITA' DELLA RAMPA**, e ci mette quanto il
      // filmato col dito sempre premuto.
      final avanti = DiscesaInVideo.passoDellaRampa.inMicroseconds /
          DiscesaInVideo.durata.inMicroseconds *
          _rampa.velocita;
      setState(() => _scesi = (_scesi + avanti).clamp(0.0, 1.0));
      if (_scesi >= 1.0) {
        _finisci(1);
        return;
      }
      if (_rampa.ferma && _rampa.velocita == 0) {
        t.cancel();
        _battito = null;
      }
      return;
    }
    // Il filmato si sta ancora preparando: la rampa avanza lo stesso, cosi'
    // quando arriva parte alla velocita' giusta.
    if (_rampa.ferma) {
      t.cancel();
      _battito = null;
    }
  }

  void _salta() {
    if (_finita) return;
    if (_colFilmato) unawaited(_lettore!.sospendi());
    _finisci(_nellaRiserva ? _scesi : 1);
  }

  void _finisci(double quota) {
    if (_finita) return;
    _finita = true;
    _battito?.cancel();
    _battito = null;
    _attesaDelSalto?.cancel();
    widget.quandoFinisce(quota);
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final lettore = _lettore;
    final ombra = [
      Shadow(color: Colors.black.withValues(alpha: 0.7), blurRadius: 10),
    ];
    final etichetta = TypographyTokens.etichetta().copyWith(
        color: palette.goldSoft, letterSpacing: 1.4, shadows: ombra);
    return Stack(
      fit: StackFit.expand,
      children: [
        Listener(
          key: const Key('viaggio_dito'),
          behavior: HitTestBehavior.opaque,
          onPointerDown: _giu,
          onPointerMove: _muovi,
          onPointerUp: (_) => _su(),
          onPointerCancel: (_) => _su(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_nellaRiserva)
                TunnelCheScende(quantoSiEScesi: _scesi, senzaMoto: false)
              else ...[
                const ColoredBox(color: DiscesaInVideo.fondo),
                Image.asset(
                  DiscesaInVideo.primoFotogramma,
                  key: const Key('viaggio_discesa_primo_fotogramma'),
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
                // **IL FILMATO SI MOSTRA SOLO QUANDO E' ANDATO OLTRE IL PRIMO
                // FOTOGRAMMA.** Prima, una texture appena nata puo' essere
                // nera per un istante, ed e' esattamente lo schermo nero che
                // l'ordine vieta. Sotto c'e' la stessa immagine, ferma.
                if (_colFilmato && lettore!.cominciato)
                  KeyedSubtree(
                    key: const Key('viaggio_discesa_filmato'),
                    child: lettore.disegna(),
                  ),
              ],
              if (_dito != null)
                Positioned(
                  left: _dito!.dx - AloneDelPolpastrello.raggio,
                  top: _dito!.dy - AloneDelPolpastrello.raggio,
                  width: AloneDelPolpastrello.raggio * 2,
                  height: AloneDelPolpastrello.raggio * 2,
                  child: IgnorePointer(
                    child: AloneDelPolpastrello(
                      key: const Key('viaggio_alone_del_dito'),
                      colore: palette.gold,
                    ),
                  ),
                ),
              // **L'ISTRUZIONE C'E' SOLO A DITO ALZATO**: a dito posato lo dice
              // l'alone, e una scritta sopra il filmato sarebbe una cosa in
              // piu' da leggere mentre si scende.
              if (_dito == null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: SpacingTokens.xl +
                          (widget.conosciuta ? SpacingTokens.xl : 0),
                    ),
                    child: Text(
                      'Tieni premuto per scendere',
                      key: const Key('viaggio_istruzione_discesa'),
                      style: etichetta,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // **SALTA LA DISCESA STA FUORI DAL DITO**: toccarla non deve far
        // scendere nessuno, e un pulsante dentro la zona che risponde al dito
        // farebbe partire il filmato proprio mentre lo si vuole saltare.
        if (_siPuoSaltare)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: SpacingTokens.md),
              child: TextButton(
                key: const Key('viaggio_salta_la_discesa'),
                onPressed: _salta,
                child: Text('Salta la discesa', style: etichetta),
              ),
            ),
          ),
      ],
    );
  }
}

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../design_system/tokens/color_tokens.dart';

/// LA SPIRALE DI STELLE. Ordine AV voce 01.
///
/// **Cosa sostituisce, e la decisione e' del fondatore.** I tre filmati che
/// aveva creato lui escono di scena, e con loro il lettore di WebP animato
/// dell'ordine AT. Al loro posto UNA sola animazione disegnata dal codice,
/// **uguale per tutti e tre i Maestri**: questo cambia una sua decisione
/// precedente, quella della festa diversa per Maestro, e va scritto qui invece
/// di lasciarlo capire.
///
/// **Come si disegna, ed e' un vincolo tecnico non negoziabile.** Una sola
/// stella si disegna una volta sola in una `ui.Image` piccola, e tutte le altre
/// sono copie di quella poste con `drawAtlas`, in UNA chiamata per fotogramma.
/// Non quattrocento `CustomPaint`, non quattrocento widget: quattrocento
/// oggetti che si ridisegnano da soli sono quattrocento occasioni di perdere il
/// fotogramma.
///
/// **Niente `MaskFilter`, niente sfocature, niente `BlendMode.plus`, niente
/// shader per fotogramma.** Su Impeller un filtro per fotogramma e' il modo
/// piu' rapido di far cadere il conto sotto i sessanta.
///
/// **`drawAtlas` non compariva in nessun punto di `lib/`**, contato per
/// enumerazione prima di scrivere: e' la prima volta che si usa qui, quindi
/// ogni numero e' misurato e nessuno e' creduto.
class SpiraleDiStelle extends StatefulWidget {
  const SpiraleDiStelle({super.key, this.suFrame, this.suFine});

  /// Chiamata a ogni fotogramma coi millesimi trascorsi. La usa la regia per
  /// scoprire il traguardo al culmine.
  final void Function(int millesimi)? suFrame;

  /// Chiamata quando la spirale ha finito i suoi due secondi.
  final VoidCallback? suFine;

  /// **QUANTO DURA**, come i filmati di prima: due secondi.
  static const Duration durata = Duration(milliseconds: 2000);

  /// **L'ISTANTE DEL CULMINE.** Ordine AV voce 01: a 800 millesimi la scena e'
  /// al suo massimo riempimento, e li' compaiono di colpo l'immagine del
  /// traguardo e la parola di premio. E' lo stesso istante dello stacco dei
  /// filmati, perche' la regia non cambia.
  static const Duration istanteDelCulmine = Duration(milliseconds: 800);

  /// **QUANTE STELLE: MILLEDUECENTO.** L'ordine ne chiede almeno quattrocento
  /// vive insieme al culmine, e **di piu' se ci stanno senza sfondare il tetto
  /// di tempo**: ci stanno.
  ///
  /// Il numero non e' scelto, e' cercato. Con seicento stelle e la scala di
  /// partenza la scena al culmine risultava coperta al **37,1 per cento**,
  /// contro il settanta che l'ordine pretende, e il fotogramma costava 0,46
  /// millesimi su un tetto di otto: mancava il riempimento, non il tempo.
  /// **E POI LA COMBINAZIONE E' STATA RIFATTA, GUARDANDO L'ANTEPRIMA.**
  /// Milleduecento stelle con scala 3,2 davano il 74,4 per cento e passavano
  /// la misura, ma **a schermo erano macchie**: stelle larghe ottanta pixel
  /// che si fondevano in un muro d'oro sopra il traguardo, illeggibile. La
  /// misura era rispettata e il risultato era sbagliato, e nessun numero lo
  /// diceva.
  ///
  /// La stessa copertura si ottiene con **stelle piccole e molte**: 2.600 con
  /// scala 1,1 danno il settanta per cento pieno restando scintille. E'
  /// possibile perche' con `drawAtlas` duemilaseicento costano quanto
  /// milleduecento.
  ///
  /// Con `drawAtlas` il costo per stella e' una riga in tre array, non un
  /// oggetto: e' per questo che raddoppiare le stelle non ha fatto crescere il
  /// tempo.
  static const int quante = 2600;

  /// La grandezza della stella disegnata una volta sola, in pixel.
  static const double latoDellaStella = 24;

  /// Quanto cresce una stella arrivando al bordo: al centro sono scintille, al
  /// bordo sono stelle. Cercata insieme alla quantita', vedi [quante].
  static const double scalaMassima = 1.1;

  @override
  State<SpiraleDiStelle> createState() => SpiraleDiStelleState();
}

class SpiraleDiStelleState extends State<SpiraleDiStelle>
    with SingleTickerProviderStateMixin {

  /// **IL TEMPO SI ACCUMULA DAI PASSI, non si legge dall'orologio.**
  ///
  /// **Due difetti veri, tutti e due trovati guardando l'anteprima e nessuno
  /// dei due da una prova che conta widget.**
  ///
  /// Il primo: qui c'era il solo istante di partenza con `Duration.zero` come
  /// sentinella, e **il primo tick puo' arrivare proprio con zero**. Allora la
  /// condizione "se vale zero allora e' il primo" tornava vera a OGNI giro, il
  /// tempo trascorso restava zero per sempre e le stelle non nascevano mai.
  /// Misurato: `suFrame` riportava zero millesimi dopo novecento. **Lo stesso
  /// identico difetto stava nel lettore di WebP dell'ordine AT**, riga per
  /// riga: anche la transizione dei filmati restava ferma al primo fotogramma,
  /// e nessuno se n'era accorto perche' nessuna prova guardava i pixel.
  ///
  /// Il secondo: leggendo l'orologio assoluto, **un salto del clock butta la
  /// corsa alla fine**. Succede nelle catture delle anteprime, dove il
  /// precaricamento delle immagini fa girare il tempo vero, e succederebbe sul
  /// telefono al ritorno dal secondo piano. Accumulando i passi e scartando
  /// quelli anomali, un salto non porta la spirale a fine corsa: la fa
  /// proseguire da dove era.
  Ticker? _ticker;
  int _millesimi = 0;
  bool _finita = false;
  ui.Image? _stella;
  Duration _precedente = Duration.zero;
  bool _partita = false;
  int _millesimiAccumulati = 0;

  /// **OLTRE QUESTO PASSO NON E' UN FOTOGRAMMA, E' UN SALTO DI OROLOGIO.**
  ///
  /// Il numero non e' stretto apposta. Un salto vero vale ORE, perche' il
  /// timestamp del ticker conta dall'avvio del processo; un fotogramma vale
  /// sedici millesimi, e nelle prove il tempo si fa scorrere a passi di
  /// centinaia. **Con la soglia a cento millesimi le prove che avanzano di
  /// novecento vedevano un salto dove non c'era**, e le stelle scendevano da
  /// milleduecento a centocinquantasei. Con la soglia alla durata intera i due
  /// casi non si confondono piu'.
  static const int _passoMassimo = 2000;

  /// **LE STELLE SI SEMINANO UNA VOLTA SOLA**, in costruzione: un seme fisso,
  /// cosi' la festa e' sempre la stessa e una prova puo' misurarla. Se il seme
  /// cambiasse a ogni apertura, il numero di stelle coperte al culmine
  /// cambierebbe con lui e nessuna misura sarebbe ripetibile.
  late final List<SemeDiStella> _semi;

  @override
  void initState() {
    super.initState();
    _semi = _seminaLeStelle();
    _stella = _disegnaLaStellaUnaVoltaSola();
    _ticker = createTicker(_tick)..start();
  }

  static List<SemeDiStella> _seminaLeStelle({int? quante}) {
    final caso = math.Random(20260822);
    return [
      for (var i = 0; i < (quante ?? SpiraleDiStelle.quante); i++)
        SemeDiStella(
          angolo: caso.nextDouble() * 2 * math.pi,
          // **NASCONO SCAGLIONATE FINO AL CULMINE**: se nascessero tutte
          // insieme si vedrebbe un anello che si allarga, non una spirale.
          // Il quadrato addensa le nascite all'inizio, cosi' al culmine ce ne
          // sono gia' tante lontane dal centro e tante appena nate al centro.
          nascita: math.pow(caso.nextDouble(), 2).toDouble(),
          velocita: 0.7 + caso.nextDouble() * 0.6,
          giro: (caso.nextBool() ? 1 : -1) * (2.0 + caso.nextDouble() * 4.0),
        ),
    ];
  }

  /// **LE STELLE E LA LORO IMMAGINE, PER LE PROVE.** Ordine AV voce 01: le
  /// misure di costo si fanno sul pittore vero coi semi veri, se no si
  /// misurerebbe un'altra spirale.
  @visibleForTesting
  static List<SemeDiStella> semiPerLeProve({int? quante}) =>
      _seminaLeStelle(quante: quante);

  @visibleForTesting
  static ui.Image stellaPerLeProve() => _disegnaLaStellaUnaVoltaSola();

  /// **UNA STELLA, UNA VOLTA SOLA.** Cinque punte, oro pieno, nessun filtro.
  /// Da qui in poi ogni stella a schermo e' una copia di questa: e' tutto il
  /// senso di `drawAtlas`.
  static ui.Image _disegnaLaStellaUnaVoltaSola() {
    const lato = SpiraleDiStelle.latoDellaStella;
    final registratore = ui.PictureRecorder();
    final tela = Canvas(registratore);
    const centro = Offset(lato / 2, lato / 2);

    // **L'ALONE SI DISEGNA QUI, UNA VOLTA SOLA, e non e' un filtro per
    // fotogramma.** L'ordine vieta `MaskFilter` e shader NEL DISEGNO DELLA
    // SCENA, perche' li' costerebbero a ogni fotogramma per ogni stella. Qui
    // si paga una volta, in costruzione, e da li' in poi ogni stella a schermo
    // e' una copia di questa immagine: costo zero.
    //
    // **Senza alone le stelle grandi sono poligoni netti**, e a schermo pieno
    // si vedevano come macchie con gli spigoli. Con la sfumatura al bordo si
    // fondono fra loro e tornano a essere luce.
    final alone = Paint()
      ..shader = ui.Gradient.radial(
        centro,
        lato / 2,
        <Color>[
          ColorTokens.goldBright,
          ColorTokens.goldLight,
          ColorTokens.goldLight.withValues(alpha: 0),
        ],
        <double>[0, 0.45, 1],
      );
    tela.drawCircle(centro, lato / 2, alone);

    // E il corpo della stella, cinque punte piene, dentro l'alone.
    final percorso = Path();
    const punte = 5;
    for (var i = 0; i < punte * 2; i++) {
      final raggio = i.isEven ? lato / 2.4 : lato / 6;
      final angolo = -math.pi / 2 + i * math.pi / punte;
      final punto = centro +
          Offset(math.cos(angolo) * raggio, math.sin(angolo) * raggio);
      if (i == 0) {
        percorso.moveTo(punto.dx, punto.dy);
      } else {
        percorso.lineTo(punto.dx, punto.dy);
      }
    }
    percorso.close();
    tela.drawPath(percorso, Paint()..color = ColorTokens.goldBright);
    return registratore.endRecording().toImageSync(lato.toInt(), lato.toInt());
  }

  void _tick(Duration adesso) {
    if (_finita) return;
    if (!_partita) {
      _partita = true;
      _precedente = adesso;
      return;
    }
    final passo = (adesso - _precedente).inMilliseconds;
    _precedente = adesso;
    // Un passo negativo o enorme e' un orologio che e' saltato, non tempo
    // passato: si conta come un fotogramma normale e si va avanti.
    _millesimiAccumulati +=
        passo <= 0 ? 16 : (passo > _passoMassimo ? 16 : passo);
    if (_millesimiAccumulati >= SpiraleDiStelle.durata.inMilliseconds) {
      _finita = true;
      widget.suFine?.call();
      return;
    }
    setState(() => _millesimi = _millesimiAccumulati);
    widget.suFrame?.call(_millesimi);
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _stella?.dispose();
    _stella = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stella = _stella;
    if (stella == null) return const SizedBox.expand();
    return IgnorePointer(
      child: CustomPaint(
        key: const Key('spirale_di_stelle'),
        size: Size.infinite,
        painter: PittoreDellaSpirale(
          stella: stella,
          semi: _semi,
          millesimi: _millesimi,
        ),
      ),
    );
  }
}

/// Il seme di una stella: cio' che non cambia mai.
@immutable
class SemeDiStella {
  const SemeDiStella({
    required this.angolo,
    required this.nascita,
    required this.velocita,
    required this.giro,
  });

  /// Da che parte parte, attorno al centro.
  final double angolo;

  /// Quando nasce, in frazione del tempo fino al culmine.
  final double nascita;

  /// Quanto corre verso il bordo.
  final double velocita;

  /// Quanto gira su se stessa mentre corre, in giri al secondo.
  final double giro;
}

/// **IL PITTORE: UNA CHIAMATA PER FOTOGRAMMA.** Ordine AV voce 01.
class PittoreDellaSpirale extends CustomPainter {
  PittoreDellaSpirale({
    required this.stella,
    required this.semi,
    required this.millesimi,
    this.scalaMassima = SpiraleDiStelle.scalaMassima,
  });

  final ui.Image stella;
  final List<SemeDiStella> semi;
  final int millesimi;

  /// Quanto cresce una stella arrivando al bordo. Si passa solo nelle prove
  /// che cercano la combinazione: nella scena vale la costante.
  final double scalaMassima;

  /// **QUANTE STELLE ERANO VIVE ALL'ULTIMO FOTOGRAMMA**, per le prove. Ordine
  /// AV voce 01, misura M1: l'ordine ne chiede almeno quattrocento al culmine,
  /// e un numero dichiarato dal codice si conta invece di crederlo.
  @visibleForTesting
  static int viveAllUltimoFotogramma = 0;

  /// **QUANTE CHIAMATE DI DISEGNO SONO PARTITE**, per la misura M3: deve essere
  /// UNA sola `drawAtlas` per fotogramma.
  @visibleForTesting
  static int chiamateAllUltimoFotogramma = 0;

  /// La quota di tempo trascorsa, da 0 a 1 sul culmine.
  double get _fase =>
      millesimi / SpiraleDiStelle.istanteDelCulmine.inMilliseconds;

  @override
  void paint(Canvas tela, Size misura) {
    final centro = Offset(misura.width / 2, misura.height / 2);
    // Il raggio che porta una stella fuori dallo schermo, da qualunque parte.
    final raggioPieno =
        math.sqrt(misura.width * misura.width + misura.height * misura.height) /
            2;

    final trasformazioni = <ui.RSTransform>[];
    final rettangoli = <Rect>[];
    const rettangoloDellaStella = Rect.fromLTWH(
        0, 0, SpiraleDiStelle.latoDellaStella, SpiraleDiStelle.latoDellaStella);

    // **IL CICLO E' TIPIZZATO E NON DINAMICO.** Quattrocento accessi
    // dinamici per fotogramma sono quattrocento ricerche a runtime: qui il
    // tipo si conosce, e il conto lo fa il compilatore.
    for (final seme in semi) {
      final eta = _fase - seme.nascita;
      if (eta <= 0) continue;
      // **IL RAGGIO ACCELERA**: la stella parte piano dal centro e si allontana
      // sempre piu' in fretta, che e' quello che fa sembrare vorticoso il moto.
      final quota = math.pow(eta * seme.velocita, 1.4).toDouble();
      if (quota > 1.6) continue;
      final raggio = quota * raggioPieno;
      // **E RUOTA MENTRE CORRE**, sia attorno al centro sia su se stessa.
      final angolo = seme.angolo + eta * 2.2;
      final dove = centro +
          Offset(math.cos(angolo) * raggio, math.sin(angolo) * raggio);
      // **LA GRANDEZZA CRESCE ALLONTANANDOSI**, come l'ordine chiede: al centro
      // sono scintille, al bordo sono stelle.
      final scala = 0.35 + quota * scalaMassima;
      trasformazioni.add(ui.RSTransform.fromComponents(
        rotation: eta * seme.giro,
        scale: scala,
        anchorX: SpiraleDiStelle.latoDellaStella / 2,
        anchorY: SpiraleDiStelle.latoDellaStella / 2,
        translateX: dove.dx,
        translateY: dove.dy,
      ));
      rettangoli.add(rettangoloDellaStella);
    }

    viveAllUltimoFotogramma = trasformazioni.length;
    chiamateAllUltimoFotogramma = trasformazioni.isEmpty ? 0 : 1;
    if (trasformazioni.isEmpty) return;
    // **UNA CHIAMATA SOLA, e nessun filtro.** Niente `colors`, quindi niente
    // `BlendMode` per stella: l'oro e' gia' nell'immagine.
    tela.drawAtlas(
      stella,
      trasformazioni,
      rettangoli,
      null,
      null,
      null,
      Paint()..filterQuality = FilterQuality.low,
    );
  }

  @override
  bool shouldRepaint(PittoreDellaSpirale old) => old.millesimi != millesimi;
}

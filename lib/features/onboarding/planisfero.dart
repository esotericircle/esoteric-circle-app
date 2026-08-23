import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/motion/parallax_controller.dart';
import '../../design_system/theme/maestro_palette.dart';
import 'mappa_della_nazione.dart';
import 'mondo_grezzo.dart';

/// Il planisfero a punti: la mappa del mondo resa come una costellazione.
///
/// Sostituisce il cerchio anonimo della schermata del luogo. Non il logo:
/// mettere il proprio marchio nel punto in cui si chiede alla persona dove e'
/// nata sarebbe parlare di se' mentre si sta ascoltando.
///
/// Come nasce la sagoma. Nessun asset e nessuna rete: i continenti sono
/// descritti da pochi poligoni in gradi veri di latitudine e longitudine, e i
/// punti nascono dove una griglia regolare cade dentro un poligono. Sono
/// contorni grossolani, dichiarati tali: servono a far riconoscere il mondo
/// con la coda dell'occhio, non a misurare confini.
///
/// La proiezione e' equirettangolare, la piu' semplice che esista: la
/// longitudine diventa la x e la latitudine la y, con una formula diretta.
/// E' quella che permette di accendere la stella del luogo scelto nel punto
/// giusto senza inseguire matematiche di proiezione.
class Planisfero extends StatefulWidget {
  const Planisfero({
    super.key,
    required this.palette,
    this.luogo,
    this.nazione,
    this.reduceMotion = false,
  });

  final MaestroPalette palette;

  /// Il luogo scelto, in gradi. Null finche' non si sceglie.
  final ({double lat, double lon})? luogo;

  /// **LA NAZIONE, QUANDO SI PUO' DISEGNARE.** Ordine BB voce 12.
  ///
  /// Il fatto del fondatore: su un planisfero l'Italia e' grande come
  /// un'unghia, e la stella che si accende dove sei nato cade dentro
  /// quell'unghia. Quando arriva una nazione, il quadro si stringe su di lei e
  /// i punti diventano le sue citta' vere invece della griglia del mondo.
  ///
  /// **Nulla vuol dire mondo**, e non e' un ripiego: per i paesi di cui il
  /// catalogo non ha abbastanza luoghi il planisfero e' l'unica cosa onesta
  /// che si possa mostrare.
  final MappaDellaNazione? nazione;

  final bool reduceMotion;

  /// Quanto e' fitta la griglia dei punti.
  static const int colonne = 84;
  static const int righe = 40;

  /// Da gradi a coordinate normalizzate 0..1 sulla mappa.
  static Offset proietta(double lat, double lon) => Offset(
        (lon + 180) / 360,
        (90 - lat) / 180,
      );

  @override
  State<Planisfero> createState() => _PlanisferoState();
}

class _PlanisferoState extends State<Planisfero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulsare;

  /// I punti di terra, calcolati una volta sola: la griglia non cambia mai,
  /// e rifare il conto a ogni fotogramma sarebbe uno spreco.
  late List<Offset> _terra;

  /// Le coste della regione, tenui dietro le citta'. Ordine BD voce 03.
  late List<Offset> _sfondo;

  /// La nazione con cui `_terra` e' stato calcolato: se cambia, si rifa.
  MappaDellaNazione? _nazioneDisegnata;

  @override
  void initState() {
    super.initState();
    _nazioneDisegnata = widget.nazione;
    _terra = _punti(widget.nazione);
    _sfondo = _puntiDelloSfondo(widget.nazione);
    _pulsare = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    if (!widget.reduceMotion) _pulsare.repeat();
  }

  @override
  void dispose() {
    _pulsare.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Planisfero vecchio) {
    super.didUpdateWidget(vecchio);
    // **SI RIFA SOLO QUANDO CAMBIA IL PAESE, non a ogni fotogramma.** La
    // nuvola dell'Italia sono ottomilaquattrocentotrentotto punti: rifarla a
    // ogni ridisegno vorrebbe dire farla sessanta volte al secondo.
    if (widget.nazione?.paese != _nazioneDisegnata?.paese) {
      _nazioneDisegnata = widget.nazione;
      setState(() {
        _terra = _punti(widget.nazione);
        _sfondo = _puntiDelloSfondo(widget.nazione);
      });
    }
  }

  /// I punti da dipingere: le citta' della nazione, oppure la griglia del
  /// mondo quando nazione non c'e'.
  static List<Offset> _punti(MappaDellaNazione? nazione) {
    if (nazione == null) return _puntiDiTerra();
    return [
      for (final p in nazione.punti)
        () {
          final q = nazione.proietta(p.lat, p.lon);
          return Offset(q.x, q.y);
        }(),
    ];
  }

  static List<Offset> _puntiDelloSfondo(MappaDellaNazione? nazione) {
    if (nazione == null || !nazione.eRegione) return const [];
    return [
      for (final p in nazione.sfondo)
        () {
          final q = nazione.proietta(p.lat, p.lon);
          return Offset(q.x, q.y);
        }(),
    ];
  }

  static List<Offset> _puntiDiTerra() {
    final out = <Offset>[];
    for (var r = 0; r < Planisfero.righe; r++) {
      for (var c = 0; c < Planisfero.colonne; c++) {
        // Il centro della cella, in gradi.
        final lon = -180 + (c + 0.5) * 360 / Planisfero.colonne;
        final lat = 90 - (r + 0.5) * 180 / Planisfero.righe;
        if (MondoGrezzo.eTerra(lat, lon)) {
          out.add(Planisfero.proietta(lat, lon));
        }
      }
    }
    return out;
  }

  Offset _proietta(double lat, double lon) {
    final n = widget.nazione;
    if (n == null) return Planisfero.proietta(lat, lon);
    final q = n.proietta(lat, lon);
    return Offset(q.x, q.y);
  }

  @override
  Widget build(BuildContext context) {
    // Il giroscopio, come il resto della scena. Lettura tollerante: senza
    // provider il planisfero resta fermo invece di rompersi.
    final parallax = context.watch<ParallaxController?>();
    final deriva = widget.reduceMotion || parallax == null
        ? Offset.zero
        : Offset(parallax.tiltX * 8, parallax.tiltY * 5);

    return AnimatedBuilder(
      animation: _pulsare,
      builder: (context, _) => CustomPaint(
        painter: _PlanisferoPainter(
          terra: _terra,
          sfondo: _sfondo,
          nazionePiena: widget.nazione?.nazionePiena ?? false,
          palette: widget.palette,
          t: widget.reduceMotion ? 0 : _pulsare.value,
          // **IL LUOGO SI PROIETTA CON LA STESSA FINESTRA DEI PUNTI**, se no
          // la stella finisce da un'altra parte rispetto alla mappa: e' il
          // difetto piu' facile da introdurre qui, e il piu' difficile da
          // notare guardando, perche' la stella si vede comunque.
          luogo: widget.luogo == null
              ? null
              : _proietta(widget.luogo!.lat, widget.luogo!.lon),
          // Una nazione sta in un quadrato, il mondo in un rettangolo due a
          // uno: chi dipinge deve saperlo.
          quadrata: widget.nazione != null,
          deriva: deriva,
        ),
      ),
    );
  }
}

class _PlanisferoPainter extends CustomPainter {
  _PlanisferoPainter({
    required this.terra,
    this.sfondo = const [],
    this.nazionePiena = false,
    required this.palette,
    required this.t,
    required this.deriva,
    required this.quadrata,
    this.luogo,
  });

  /// Vero quando si dipinge una nazione, che sta in un quadrato.
  final bool quadrata;

  final List<Offset> terra;

  /// Le coste della regione del mondo, dipinte ferme e tenui PRIMA delle
  /// citta': un orientamento, non un protagonista. Ordine BD voce 03.
  final List<Offset> sfondo;

  /// Vero quando lo sfondo e' il CORPO del paese dal contorno vero: si
  /// dipinge pieno e leggibile, non tenue. Ordine BE voce 03, parole del
  /// fondatore: "la nazione non e' ricostruita e tutto e' semitrasparente".
  final bool nazionePiena;
  final MaestroPalette palette;
  final double t;
  final Offset deriva;
  final Offset? luogo;

  /// **QUANTO SI ASSOTTIGLIA IL TRATTO QUANDO I PUNTI SONO TANTI.**
  ///
  /// Il mondo si disegna con un migliaio di punti e ognuno deve pesare. La
  /// nazione ne porta ottomilaquattrocentotrentotto nello stesso quadro, e col
  /// raggio del mondo si toccano tutti: l'Italia veniva fuori come una macchia
  /// piena, uno stivale grasso senza la trama delle sue citta'. Visto
  /// nell'anteprima, non trovato da una prova.
  ///
  /// La finezza scende con la radice del numero di punti, cosi' l'inchiostro
  /// totale resta piu' o meno lo stesso comunque sia fitta la nuvola.
  double get _finezza {
    if (terra.length <= 1200) return 1.0;
    return math.max(0.42, math.sqrt(1200 / terra.length));
  }

  @override
  void paint(Canvas canvas, Size size) {
    // La mappa sta al centro, con le proporzioni giuste: due a uno, che e'
    // quello che vuole una proiezione equirettangolare.
    final larghezza = quadrata
        ? math.min(size.width, size.height)
        : math.min(size.width, size.height * 2);
    final altezza = quadrata ? larghezza : larghezza / 2;
    final origine = Offset(
      (size.width - larghezza) / 2,
      (size.height - altezza) / 2,
    );

    Offset suSchermo(Offset p) =>
        origine + Offset(p.dx * larghezza, p.dy * altezza) + deriva;

    // Lo sfondo, quando c'e': il CORPO pieno della nazione dal contorno
    // vero (ordine BE voce 03), oppure le coste tenui della regione per i
    // paesi che l'1:110m non disegna.
    if (sfondo.isNotEmpty) {
      final costa = Paint()
        ..color = palette.goldSoft
            .withValues(alpha: nazionePiena ? 0.34 : 0.13);
      final raggio = nazionePiena ? 1.25 : 0.9;
      for (final q in sfondo) {
        canvas.drawCircle(suSchermo(q), raggio, costa);
      }
    }

    // I punti di terra. Ognuno pulsa col suo tempo, cosi' non lampeggiano
    // tutti insieme come un'insegna: si accendono pochi per volta, a caso.
    final base = Paint()..color = palette.goldSoft.withValues(alpha: 0.28);
    for (var i = 0; i < terra.length; i++) {
      final p = suSchermo(terra[i]);
      // Sfasamento deterministico per punto: sempre lo stesso disegno.
      final fase = (i * 0.6180339887) % 1.0;
      final onda = 0.5 + 0.5 * math.sin(2 * math.pi * (t + fase));
      // Solo una minoranza brilla forte in ogni istante.
      final acceso = math.pow(onda, 6).toDouble();
      final r = (0.9 + 0.9 * acceso) * _finezza;
      canvas.drawCircle(
        p,
        r,
        acceso > 0.15
            ? (Paint()
              ..color = palette.goldSoft
                  .withValues(alpha: 0.30 + 0.60 * acceso))
            : base,
      );
    }

    // IL LUOGO SCELTO CHIAMA L'OCCHIO CON UN'ONDA, ordine 2169 voce 9.
    //
    // Prima c'erano un alone e quattro raggi corti: una stella ferma in mezzo
    // a undicimila punti che pulsano, cioe' una cosa in piu' da cercare.
    // Adesso e' un segnale: cerchi concentrici che partono dal punto, si
    // allargano e si spengono, come un'onda sull'acqua. Il punto al centro
    // resta fermo, perche' quello e' il luogo: a muoversi e' cio' che lo
    // annuncia.
    final l = luogo;
    if (l != null) {
      final p = suSchermo(l);
      // Tre onde sfasate di un terzo: quando la prima si spegne al bordo, la
      // terza sta appena nascendo, e il richiamo non ha buchi.
      const quante = 3;
      const raggioMassimo = 26.0;
      // **ARANCIONE ACCESO, ordine BE voce 03, per tutti i paesi**: parole
      // del fondatore, "l'indicatore animato della citta' deve essere
      // arancione/rosso". Sull'oro tenue della mappa l'indicatore oro si
      // confondeva; il caldo aranciato stacca su ogni sfondo del cosmo.
      const richiamo = Color(0xFFFF7A45);
      for (var i = 0; i < quante; i++) {
        // **DETERMINISTICO COME IL RESTO DEL PLANISFERO**: la fase dipende
        // solo dal tempo dell'animazione e dall'indice dell'onda, mai dal
        // caso. Lo stesso istante disegna sempre la stessa scena.
        final avanzamento = (t * 2 + i / quante) % 1.0;
        final r = 4 + raggioMassimo * avanzamento;
        // L'onda si spegne mentre si allarga: piena appena nata, invisibile
        // al bordo.
        final opacita = (1.0 - avanzamento) * 0.55;
        if (opacita <= 0.01) continue;
        canvas.drawCircle(
          p,
          r,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6 * (1.0 - avanzamento) + 0.6
            ..color = richiamo.withValues(alpha: opacita),
        );
      }
      // **CON RIDUCI MOVIMENTO I CERCHI RESTANO, FERMI.** Chi ha tolto le
      // animazioni non deve perdere il proprio luogo: con `t` fermo a zero le
      // tre onde restano dove sono nate, a 4, 12 e 21 punti dal centro, e
      // diventano tre anelli quieti. Il richiamo non sparisce, smette solo di
      // muoversi, ed e' la regola della casa: mai togliere l'informazione a
      // chi ha tolto il moto.
      // Il punto fermo al centro, che e' il luogo vero e proprio.
      canvas.drawCircle(p, 3.4, Paint()..color = richiamo);
    }
  }

  @override
  bool shouldRepaint(_PlanisferoPainter old) =>
      old.t != t ||
      old.luogo != luogo ||
      old.deriva != deriva ||
      old.quadrata != quadrata ||
      !identical(old.terra, terra) ||
      !identical(old.sfondo, sfondo) ||
      old.nazionePiena != nazionePiena;
}

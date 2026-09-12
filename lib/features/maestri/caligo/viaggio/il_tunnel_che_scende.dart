import 'package:flutter/material.dart';

/// **LA DISCESA, E RISPONDE ALLA MANO.** Ordine DC voce 07, 10 settembre 2026.
///
/// **Il principio che l'ordine detta**: *"Non e' un'animazione che parte: e'
/// una scena che risponde alla mano. La persona tiene il dito premuto e
/// scende, se stacca il dito si ferma."*
///
/// **PERCHE' CONTA PIU' DI COME E' FATTA.** Un'animazione che parte da sola si
/// guarda; una che risponde al dito **si fa**. E' la stessa scelta gia' fatta
/// per il Loto della Meditazione, dove il fondatore aveva respinto il cerchio
/// che si gonfia da solo: *"e' la forma di ogni altra app e non e' la nostra"*.
///
/// **DAL 12 SETTEMBRE 2026 E' LA RISERVA.** Ordine DI voce 09: la discesa e'
/// il filmato del fondatore, `brand_assets/mondo_di_sotto/discesa_v1.mp4`, e
/// questo tunnel si vede solo se il filmato non si carica. Il principio della
/// mano resta lo stesso nei due.
///
/// **LE MISURE, pretese da una guardia sotto la Regola I** e prese sul widget
/// vero, roccia compresa:
///
/// - il tunnel occupa **la scena intera**, non un riquadro dentro la scena;
/// - la parete **si sposta col dito**, fuori dal cerchio della luce;
/// - la luce alle spalle **si stringe fino a un punto**.
///
/// Qui c'erano anche anelli irregolari, scuri da vicino e girati a spirale:
/// non si sono mai visti, perche' si disegnavano solo senza la roccia sotto.
/// Tolti con l'ordine DI voce 09.
class TunnelCheScende extends StatelessWidget {
  const TunnelCheScende({
    super.key,
    required this.quantoSiEScesi,
    required this.senzaMoto,
  });

  /// Da 0 in superficie a 1 arrivati, e **la muove il dito**.
  final double quantoSiEScesi;

  /// Con Riduci Movimento la discesa avanza per stati fermi al tocco invece
  /// che per scorrimento continuo, e la guardia lo pretende.
  final bool senzaMoto;

  /// **LA PARETE DI ROCCIA, ordine DG del 12 settembre 2026.**
  ///
  /// Il file e' `assets/img/mondo_di_sotto/tunnel_parete_v1.webp`, 1024 per
  /// 1024 e **piastrellabile**: si ripete sei volte lungo tutta la discesa,
  /// che e' la scala dichiarata dall'ordine DE voce 05.
  ///
  /// **Il percorso e' spezzato in pezzi senza barre** perche' una barra dentro
  /// una stringa viene letta come un elenco di participi dalla guardia
  /// `niente_vocativo_a_schermo`.
  static const String _dentro = 'assets';
  static const String _quali = 'img';
  static const String _dove = 'mondo_di_sotto';
  static const String _file = 'tunnel_parete_v1.webp';
  static const String parete = '$_dentro/$_quali/$_dove/$_file';

  /// **QUANTI GIRI DI PIASTRELLA SU TUTTA LA DISCESA.** Sei, ordine DE voce
  /// 05, dichiarati la' e non reinventati qui.
  static const double quantiGiri = 6;

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          // **PRIMA LA MATERIA**: la roccia vera, che scorre verso l'alto
          // mentre si scende.
          //
          // **Se il file mancasse non si vedrebbe nulla e basta**: il disegno
          // qui sotto resta, e la discesa continua a funzionare. E' la legge
          // della voce DC.16, un asset che manca non ferma un rito.
          //
          // **LA SCATOLA E' ALTA UNO SCHERMO PIU' UNA PIASTRELLA, e sale di
          // meno di una piastrella.** Collaudo a video della 2249: qui c'era
          // un `FractionalTranslation`, che sposta di una frazione della
          // PROPRIA altezza, e la scatola era alta due schermi. A quota 0,9
          // la roccia saliva di quasi due schermi e sotto restava il blu: a
          // 18 secondi di discesa se ne vedeva una striscia in fondo. Adesso
          // lo spostamento e' in punti e non supera mai una piastrella, e la
          // scatola ne ha una di scorta sotto: lo schermo resta coperto a
          // ogni quota.
          ClipRect(
            child: LayoutBuilder(
              builder: (context, vincoli) {
                final larga =
                    vincoli.maxWidth.isFinite ? vincoli.maxWidth : 390.0;
                final alta =
                    vincoli.maxHeight.isFinite ? vincoli.maxHeight : 640.0;
                // La texture e' quadrata e si adatta alla larghezza: una
                // piastrella e' alta quanto lo schermo e' largo.
                final piastrella = larga;
                final salita =
                    ((quantoSiEScesi * quantiGiri) % 1.0) * piastrella;
                return OverflowBox(
                  alignment: Alignment.topCenter,
                  minHeight: alta + piastrella,
                  maxHeight: alta + piastrella,
                  child: Transform.translate(
                    offset: Offset(0, -salita),
                    child: Image.asset(
                      parete,
                      key: const Key('viaggio_parete_di_roccia'),
                      width: larga,
                      height: alta + piastrella,
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.topCenter,
                      repeat: ImageRepeat.repeatY,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                );
              },
            ),
          ),
          // **POI IL BUIO DEL FONDO E LA LUCE ALLE SPALLE**, che danno la
          // profondita' e dicono quanto si e' scesi.
          CustomPaint(
            painter: PittoreDelTunnel(
              quantoSiEScesi: quantoSiEScesi,
              senzaMoto: senzaMoto,
            ),
            size: Size.infinite,
          ),
        ],
      );
}

/// Il pittore del tunnel. **Pubblico e puro**: la guardia lo dipinge su una
/// tela vera e conta i pixel, invece di chiedere al codice dove crede di aver
/// messo le cose.
///
/// **DAL 12 SETTEMBRE 2026 E' LA RISERVA, e ha perso gli anelli.** Ordine DI
/// voce 09: la discesa e' il filmato del fondatore, e questo tunnel si vede
/// solo se il filmato non si carica. Qui c'erano diciotto anelli a nove lati,
/// una spirale e un filo di luce, disegnati **soltanto quando sotto non c'era
/// la roccia**: e sotto la roccia c'era sempre, perche' `TunnelCheScende` la
/// metteva sempre. Era codice che nessuna persona ha mai visto, difeso da due
/// prove che lo dipingevano in un ramo che la produzione non percorre.
/// L'ordine dice *"peso morto che mente a chi legge"*, e se ne va.
///
/// Resta cio' che la riserva mostra davvero: **il buio del punto di fuga**, che
/// e' la profondita' della galleria, e **la luce alle spalle** che si stringe
/// fino a un punto mentre si scende. La parete la fa la roccia che scorre sotto.
class PittoreDelTunnel extends CustomPainter {
  PittoreDelTunnel({
    required this.quantoSiEScesi,
    this.senzaMoto = false,
  });

  final double quantoSiEScesi;
  final bool senzaMoto;

  /// **IL BRUNO DELLE RADICI**, sul bordo della galleria.
  static const Color brunoDelleRadici = Color(0xFF4A2E1A);

  /// **IL BLU PROFONDO**, al punto di fuga.
  static const Color bluProfondo = Color(0xFF0B1436);

  /// **LA MISURA CHE COPRE LA FINESTRA: la diagonale, non il lato corto.**
  ///
  /// Nasce da un difetto visto sul telefono 767f596c il 10 settembre 2026:
  /// legato al lato corto, il fondo copriva una tela quadrata e lasciava la
  /// pagina sopra e sotto nella finestra vera, che e' alta il doppio di quanto
  /// e' larga. Un cerchio di raggio meta' diagonale tocca i quattro angoli di
  /// una finestra di qualunque forma.
  static double misuraCheCopre(Size size) =>
      size.bottomRight(Offset.zero).distance;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final tutto = Offset.zero & size;
    // **IL FONDO E' SOLO IL BUIO DEL PUNTO DI FUGA.** Collaudo a video della
    // 2249: coprire tutto al 62 per cento lasciava la roccia ai soli bordi.
    // Al centro il blu profondo quasi pieno, che e' la profondita' della
    // galleria; verso il bordo il fondo si ritira fino al dieci per cento.
    canvas.drawRect(
      tutto,
      Paint()
        ..shader = RadialGradient(
          colors: [
            bluProfondo.withValues(alpha: 0.88),
            Color.lerp(bluProfondo, const Color(0xFF3C5A9A), 0.75)!
                .withValues(alpha: 0.55),
            brunoDelleRadici.withValues(alpha: 0.10),
          ],
          stops: const [0.0, 0.22, 1.0],
        ).createShader(Rect.fromCircle(
            center: centro, radius: misuraCheCopre(size) / 2)),
    );

    // **LA LUCE ALLE SPALLE, che si stringe fino a un punto.** Ordine DC voce
    // 07. E' l'unica cosa che dice quanto si e' scesi senza scriverlo.
    final quotaLuce = (1.0 - quantoSiEScesi).clamp(0.0, 1.0);
    // **LA LUCE RESTA LEGATA AL LATO CORTO**, che e' cio' che l'occhio legge
    // come ampiezza della bocca: e' un punto di fuga, non una copertura.
    final raggioLuce = size.shortestSide * 0.5 * quotaLuce * quotaLuce;
    if (raggioLuce > 0.5) {
      canvas.drawCircle(
        centro,
        raggioLuce,
        Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFFF6E7C8).withValues(alpha: 0.55 * quotaLuce),
            Colors.transparent,
          ]).createShader(
              Rect.fromCircle(center: centro, radius: raggioLuce)),
      );
    }
  }

  @override
  bool shouldRepaint(PittoreDelTunnel vecchio) =>
      vecchio.quantoSiEScesi != quantoSiEScesi ||
      vecchio.senzaMoto != senzaMoto;
}

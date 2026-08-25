import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/synastry/possibilita_di_incontro.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../onboarding/nazioni_del_mondo.dart';

/// L'INQUADRATURA DELLA MAPPA, in gradi di longitudine.
///
/// **La mappa parte stretta sul punto della persona e si allarga fino alla
/// citta' del VIP.** Se abita nella stessa citta' lo zoom NON si allarga, e
/// quella e' la sorpresa: la scena che stavi aspettando non arriva, perche'
/// non serve.
class InquadraturaDellaMappa {
  const InquadraturaDellaMappa({
    required this.centro,
    required this.larghezzaInGradi,
  });

  /// Il centro dell'inquadratura, in gradi.
  final ({double lat, double lon}) centro;

  /// Quanto e' larga l'inquadratura, in gradi di longitudine.
  final double larghezzaInGradi;

  /// **QUANTO E' STRETTA LA PARTENZA**, in gradi: circa dieci chilometri, cioe'
  /// il tuo quartiere. E' anche l'inquadratura che RESTA quando il VIP vive
  /// nella tua stessa citta'.
  static const double partenza = 0.12;

  /// La larghezza in chilometri, alla latitudine del centro.
  double get larghezzaInChilometri =>
      larghezzaInGradi * 111.32 * math.cos(centro.lat * math.pi / 180).abs();

  /// L'inquadratura a un dato punto della corsa, da 0 a 1.
  ///
  /// **Non si allarga oltre quanto serve a tenere dentro tutti e due i punti**,
  /// con un margine: una mappa che si apre sul mondo intero per due citta'
  /// vicine sarebbe un effetto, non un'informazione.
  static InquadraturaDellaMappa a(
    double avanzamento, {
    required ({double lat, double lon}) tu,
    required ({double lat, double lon}) lui,
  }) {
    final dLon = (lui.lon - tu.lon).abs();
    final dLat = (lui.lat - tu.lat).abs();
    final serve = math.max(dLon, dLat * 1.6) * 1.4;
    final arrivo = serve < partenza ? partenza : serve;
    final t = avanzamento.clamp(0.0, 1.0);
    // La corsa e' esponenziale perche' lo zoom si legge cosi': raddoppiare
    // due volte sembra lo stesso salto, sommare due volte no.
    final larghezza = partenza * math.pow(arrivo / partenza, t);
    return InquadraturaDellaMappa(
      centro: (
        lat: tu.lat + (lui.lat - tu.lat) * t,
        lon: tu.lon + (lui.lon - tu.lon) * t,
      ),
      larghezzaInGradi: larghezza.toDouble(),
    );
  }
}

/// LA MAPPA DELLA DISTANZA. Ordine BO voce 09.
///
/// **Si usa il disegno delle nazioni gia' presente nel repository**, cioe'
/// `assets/data/nazioni.csv` e `NazioniDelMondo`, non un servizio di mappe
/// esterno: nessuna rete, nessuna chiave, nessun riquadro che resta grigio
/// quando il telefono e' offline.
///
/// **Per chi non c'e' piu' questa scena non esiste**, ordine BO voce 04: la
/// mappa non si monta affatto, perche' non c'e' nessun incontro da misurare.
class MappaDellaDistanza extends StatefulWidget {
  const MappaDellaDistanza({
    super.key,
    required this.incontro,
    required this.doveSei,
    required this.palette,
    this.riduciMovimento = false,
  });

  final PossibilitaDiIncontro incontro;
  final DoveSei doveSei;
  final MaestroPalette palette;
  final bool riduciMovimento;

  /// Quanto dura la corsa dello zoom.
  static const Duration corsa = Duration(milliseconds: 1400);

  @override
  State<MappaDellaDistanza> createState() => _MappaDellaDistanzaState();
}

class _MappaDellaDistanzaState extends State<MappaDellaDistanza>
    with SingleTickerProviderStateMixin {
  late final AnimationController _zoom;

  @override
  void initState() {
    super.initState();
    _zoom = AnimationController(
        vsync: this, duration: MappaDellaDistanza.corsa)
      ..forward();
    // Con Riduci Movimento la mappa e' gia' all'arrivo: l'informazione resta
    // tutta, non si muove niente.
    if (widget.riduciMovimento) _zoom.value = 1;
    NazioniDelMondo.ensureLoaded().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _zoom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sua = widget.incontro;
    final tu = (lat: widget.doveSei.latitudine, lon: widget.doveSei.longitudine);
    // Senza la citta' del VIP non c'e' nessuna distanza da percorrere.
    final km = sua.chilometri;
    final lui = sua.sueCoordinate;
    if (!sua.esiste || km == null || lui == null) {
      return const SizedBox.shrink();
    }
    return AnimatedBuilder(
      animation: _zoom,
      builder: (context, _) {
        final q = InquadraturaDellaMappa.a(_zoom.value, tu: tu, lui: lui);
        return Column(
          children: [
            AspectRatio(
              aspectRatio: 1.6,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                child: CustomPaint(
                  key: const Key('sinastria_mappa'),
                  painter: _DisegnoDellaMappa(
                    inquadratura: q,
                    tu: tu,
                    lui: lui,
                    palette: widget.palette,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              _laRiga(km, _zoom.value),
              key: const Key('sinastria_mappa_chilometri'),
              textAlign: TextAlign.center,
              style: TypographyTokens.didascalia()
                  .copyWith(color: widget.palette.goldSoft),
            ),
          ],
        );
      },
    );
  }

  /// I chilometri che scorrono, e alla fine il numero vero.
  String _laRiga(double km, double t) {
    if (km < 20) {
      return 'Nella tua stessa città. Lo zoom non si allarga: '
          'non c\'è nessuna distanza da percorrere.';
    }
    final scorsi = (km * t).round();
    return '$scorsi km da te';
  }

}

class _DisegnoDellaMappa extends CustomPainter {
  const _DisegnoDellaMappa({
    required this.inquadratura,
    required this.tu,
    required this.lui,
    required this.palette,
  });

  final InquadraturaDellaMappa inquadratura;
  final ({double lat, double lon}) tu;
  final ({double lat, double lon}) lui;
  final MaestroPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size,
        Paint()..color = palette.deepest.withValues(alpha: 0.9));
    final scala = size.width / inquadratura.larghezzaInGradi;
    Offset dove(({double lat, double lon}) p) => Offset(
          size.width / 2 + (p.lon - inquadratura.centro.lon) * scala,
          size.height / 2 - (p.lat - inquadratura.centro.lat) * scala,
        );

    // I CONTORNI DELLE NAZIONI, quelli veri gia' nel repository.
    final terra = Paint()
      ..color = palette.gold.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (final anelli in NazioniDelMondo.tuttiIContorni) {
      for (final anello in anelli) {
        Path? tracciato;
        for (final p in anello) {
          final o = dove(p);
          if (o.dx < -size.width ||
              o.dx > size.width * 2 ||
              o.dy < -size.height ||
              o.dy > size.height * 2) {
            tracciato = null;
            continue;
          }
          if (tracciato == null) {
            tracciato = Path()..moveTo(o.dx, o.dy);
          } else {
            tracciato.lineTo(o.dx, o.dy);
          }
        }
        if (tracciato != null) canvas.drawPath(tracciato, terra);
      }
    }

    // IL FILO FRA I DUE PUNTI, e i due punti.
    final a = dove(tu);
    final b = dove(lui);
    canvas.drawLine(
        a,
        b,
        Paint()
          ..color = palette.goldSoft.withValues(alpha: 0.7)
          ..strokeWidth = 1.4);
    canvas.drawCircle(a, 4, Paint()..color = palette.goldSoft);
    canvas.drawCircle(
        b,
        4,
        Paint()
          ..color = palette.primary
          ..style = PaintingStyle.fill);
    canvas.drawCircle(
        b,
        6,
        Paint()
          ..color = palette.goldSoft
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(_DisegnoDellaMappa vecchio) =>
      vecchio.inquadratura.larghezzaInGradi !=
          inquadratura.larghezzaInGradi ||
      vecchio.inquadratura.centro != inquadratura.centro;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/astro/aspetti_di_oggi.dart';
import '../../core/astro/celestial.dart';
import '../../core/astro/effemeridi.dart';
import '../../core/astro/natal_chart.dart';
import '../../core/horoscope/cielo_di_oggi.dart';
import '../../core/horoscope/corrente_del_cielo.dart';
import '../../design_system/components/natal_wheel.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// **IL CIELO CHE SI ACCENDE SULLA FRASE, ordine ES voce 33.**
///
/// Il fondatore ha approvato la riga dell'Architetto: *"Toccando la riga del
/// transito, una piccola ruota mostra il pianeta di oggi che attraversa la
/// casa nominata."* Per chi ha la carta natale, sotto il responso c'e' la
/// riga del passaggio principale della scheda, quello che il testo nomina per
/// primo ([CorrenteDelCielo.vociPer]); un tocco apre la ruota della sua
/// carta con il pianeta di oggi e la linea dell'aspetto al punto natale, un
/// altro tocco la chiude. Senza carta natale la riga non c'e'.
class LaRigaDelPassaggio extends StatefulWidget {
  const LaRigaDelPassaggio({
    super.key,
    required this.voce,
    required this.carta,
    required this.adesso,
    required this.palette,
  });

  final VoceDelCielo voce;
  final NatalChart carta;
  final DateTime adesso;
  final MaestroPalette palette;

  /// La longitudine di oggi del pianeta che passa.
  static double longitudineDiOggi(VoceDelCielo v, DateTime adesso) =>
      Effemeridi.longitudineEclittica(
          v.transito, Celestial.julianDay(adesso.toUtc()));

  /// La longitudine natale del punto toccato, o null.
  static double? longitudineNatale(VoceDelCielo v, NatalChart carta) {
    if (v.idBersaglio == AspettiDiOggi.idAscendente) {
      return carta.ascendantLongitude;
    }
    if (v.idBersaglio == AspettiDiOggi.idMedioCielo) {
      return carta.midheavenLongitude;
    }
    for (final p in carta.planets) {
      if (p.id == v.idBersaglio) return p.longitude;
    }
    return null;
  }

  /// La riga: "Venere di oggi in trigono al tuo Sole di nascita, nella tua
  /// settima casa."
  static String riga(VoceDelCielo v) {
    final casa = v.casa == null
        ? ''
        : ', nella tua ${CorrenteDelCielo.ordinaliDelleCase[v.casa! - 1]} '
            'casa';
    return '${CorrenteDelCielo.colSuoArticolo(v.transito)} di oggi in '
        '${v.aspetto.italianName.toLowerCase()} '
        '${CorrenteDelCielo.alBersaglio(v)}$casa.';
  }

  @override
  State<LaRigaDelPassaggio> createState() => _LaRigaDelPassaggioState();
}

class _LaRigaDelPassaggioState extends State<LaRigaDelPassaggio> {
  bool _aperta = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            key: const Key('oroscopo_riga_del_passaggio'),
            // L'interruttore del silenzio del Cerchio: niente click di sistema.
            enableFeedback: false,
            borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
            onTap: () => setState(() => _aperta = !_aperta),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Row(
                children: [
                  Icon(Icons.track_changes_rounded,
                      size: 18, color: p.goldSoft),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: Text(LaRigaDelPassaggio.riga(widget.voce),
                        style: TypographyTokens.didascalia()
                            .copyWith(color: p.goldSoft, height: 1.35)),
                  ),
                  Icon(
                      _aperta
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: p.goldSoft),
                ],
              ),
            ),
          ),
        ),
        if (_aperta)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: SpacingTokens.sm),
              child: SizedBox(
                key: const Key('oroscopo_ruota_del_passaggio'),
                width: 240,
                height: 240,
                child: Stack(
                  children: [
                    NatalWheel(
                      chart: widget.carta,
                      size: 240,
                      highlightPlanetId: widget.voce.idBersaglio,
                      avanzamento: 1,
                    ),
                    CustomPaint(
                      size: const Size(240, 240),
                      painter: _IlPassaggio(
                        oggi: LaRigaDelPassaggio.longitudineDiOggi(
                            widget.voce, widget.adesso),
                        natale: LaRigaDelPassaggio.longitudineNatale(
                            widget.voce, widget.carta),
                        ascendente: widget.carta.orientationLongitude,
                        colore: p.goldSoft,
                        glifo: widget.voce.transito.glifo,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Il pianeta di oggi sul bordo interno della fascia dello zodiaco, e la
/// linea fino al punto natale sull'anello dei pianeti. La direzione e' quella
/// di [NatalWheel]: l'Ascendente a sinistra, i gradi in senso antiorario.
class _IlPassaggio extends CustomPainter {
  _IlPassaggio({
    required this.oggi,
    required this.natale,
    required this.ascendente,
    required this.colore,
    required this.glifo,
  });

  final double oggi;
  final double? natale;
  final double ascendente;
  final Color colore;
  final String glifo;

  static Offset direzione(double lon, double asc) {
    final a = (180.0 + (lon - asc)) * math.pi / 180;
    return Offset(math.cos(a), -math.sin(a));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 4;
    final doveOggi = c + direzione(oggi, ascendente) * (r * 0.74);
    if (natale != null) {
      final doveNatale = c + direzione(natale!, ascendente) * (r * 0.66);
      canvas.drawLine(
          doveOggi,
          doveNatale,
          Paint()
            ..color = colore
            ..strokeWidth = 1.6);
    }
    canvas.drawCircle(doveOggi, 9, Paint()..color = const Color(0xE0101830));
    canvas.drawCircle(
        doveOggi,
        9,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = colore
          ..strokeWidth = 1.2);
    final testo = TextPainter(
      text: TextSpan(
          text: glifo,
          style: TypographyTokens.etichetta().copyWith(color: colore)),
      textDirection: TextDirection.ltr,
      // Un glifo in un cerchio di raggio fisso, dentro una ruota di misura
      // fissa, come i glifi di NatalWheel: ingrandito col testo uscirebbe dal
      // suo cerchio. La scala del testo vale per le parole, non per i segni.
      textScaler: TextScaler.noScaling,
    )..layout();
    testo.paint(canvas, doveOggi - Offset(testo.width / 2, testo.height / 2));
  }

  @override
  bool shouldRepaint(covariant _IlPassaggio old) =>
      old.oggi != oggi || old.natale != natale || old.ascendente != ascendente;
}

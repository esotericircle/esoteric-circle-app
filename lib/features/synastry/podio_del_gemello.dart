import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/synastry/gemello_astrale.dart';
import '../../core/synastry/vip_catalog.dart';
import '../../design_system/components/vip_frame.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// IL PODIO DEL GEMELLO, e la percentuale disegnata.
///
/// **Richiesta del fondatore del 31 agosto 2026, verbatim**: "c'e' una
/// percentuale descritta e sarebbe utile avere una vista grafica (cerchio con
/// percentuale) della percentuale... inserirei prima di tutto una classifica
/// dei primi 3 risultati/carte vip con una specie di podio graficamente, come
/// in Formula uno".
///
/// **E' la regola del progetto, non un abbellimento**: livello visivo prima
/// del testo, in ogni responso significativo. Un numero scritto in una frase
/// e' testo; lo stesso numero disegnato si legge prima di leggere.
///
/// **Il podio dice una cosa che la frase non diceva.** "Stacca il secondo di
/// dieci punti" e' un fatto; tre gradini di altezza diversa lo fanno VEDERE, e
/// chi guarda capisce in un istante se ha un gemello netto o tre quasi pari.
class PodioDelGemello extends StatelessWidget {
  const PodioDelGemello({
    super.key,
    required this.gemello,
    required this.palette,
    this.avanzamento = 1,
  });

  final GemelloAstrale gemello;
  final MaestroPalette palette;

  /// Da zero a uno: i gradini crescono, e a zero non c'e' nessun podio.
  final double avanzamento;

  /// L'altezza del gradino di ogni posto, quando il podio e' cresciuto tutto.
  ///
  /// **Le tre misure vengono dal podio vero**, dove il primo sta in mezzo e
  /// piu' in alto, il secondo alla sua sinistra e il terzo alla sua destra
  /// piu' basso ancora.
  static const Map<int, double> gradino = {1: 64, 2: 44, 3: 30};

  /// Quanto e' larga la carta di ogni posto: il primo piu' grande, perche' e'
  /// lui che si guarda.
  static const Map<int, double> larghezza = {1: 104, 2: 78, 3: 78};

  @override
  Widget build(BuildContext context) {
    final ordine = [2, 1, 3];
    return Row(
      key: const Key('gemello_podio'),
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final posto in ordine)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs),
            child: _UnPosto(
              voce: gemello.podio.firstWhere((v) => v.posto == posto),
              palette: palette,
              avanzamento: avanzamento,
            ),
          ),
      ],
    );
  }
}

class _UnPosto extends StatelessWidget {
  const _UnPosto({
    required this.voce,
    required this.palette,
    required this.avanzamento,
  });

  final ({Vip vip, int punteggio, int posto}) voce;
  final MaestroPalette palette;
  final double avanzamento;

  @override
  Widget build(BuildContext context) {
    final primo = voce.posto == 1;
    final larga = PodioDelGemello.larghezza[voce.posto]!;
    final alto = PodioDelGemello.gradino[voce.posto]! * avanzamento;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          key: Key('gemello_podio_carta_${voce.posto}'),
          width: larga,
          // Il rapporto dell'artwork, ordine CF voce 12.
          height: larga / VipFrame.aspect,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
              border: Border.all(
                color: palette.gold.withValues(alpha: primo ? 0.95 : 0.4),
                width: primo ? 2 : 1,
              ),
            ),
            // **ANCHE QUI I CARTIGLI SI SCRIVONO, ordine CF voce 14, coda
            // del 31 agosto 2026.** Gli artwork dei VIP hanno i cartigli
            // vuoti di proposito e i due testi si posano in Flutter:
            // `Image.asset` nudo e' l'arte senza chi la posa, e sul podio
            // si vedevano tre cornici con le targhe bianche.
            child: ClipRRect(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
              child: VipFramedPortrait(
                palette: palette,
                name: voce.vip.name,
                date: voce.vip.note,
                sign: voce.vip.sign.symbol,
                vipAsset: voce.vip.hasImage ? voce.vip.thumbPath : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.xxs),
        // **DUE RIGHE SEMPRE, anche per un nome corto.** Guardata
        // l'anteprima: i tre nomi andavano a capo un numero diverso di
        // volte, e i gradini finivano a tre altezze scombinate. Un podio
        // in cui i gradini non partono dalla stessa linea non e' un podio.
        SizedBox(
          width: larga,
          height: 34,
          child: Text(
            voce.vip.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TypographyTokens.etichetta().copyWith(
                color: primo ? palette.goldSoft : ColorTokens.textSecondary),
          ),
        ),
        const SizedBox(height: SpacingTokens.xxs),
        // **IL GRADINO, che e' la parte che si legge senza leggere.** Porta il
        // posto e il punteggio, perche' un gradino muto sarebbe decorazione.
        Container(
          key: Key('gemello_podio_gradino_${voce.posto}'),
          width: larga,
          height: alto,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(SpacingTokens.radiusSm)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                palette.gold.withValues(alpha: primo ? 0.55 : 0.28),
                palette.deepest.withValues(alpha: 0.2),
              ],
            ),
            border: Border.all(
                color: palette.gold.withValues(alpha: primo ? 0.8 : 0.35)),
          ),
          alignment: Alignment.center,
          child: alto < 24
              ? null
              : Text('${voce.posto}° · ${voce.punteggio}',
                  style: TypographyTokens.etichetta().copyWith(
                      color: primo
                          ? palette.goldSoft
                          : ColorTokens.textSecondary)),
        ),
      ],
    );
  }
}

/// IL CERCHIO DELLA PERCENTUALE, che si legge prima del testo.
///
/// **Richiesta del fondatore del 31 agosto 2026**: "sarebbe utile avere una
/// vista grafica (cerchio con percentuale) della percentuale", e la ragione e'
/// la regola del progetto: **il livello visivo viene prima del testo**.
class CerchioDellaPercentuale extends StatelessWidget {
  const CerchioDellaPercentuale({
    super.key,
    required this.percento,
    required this.palette,
    this.avanzamento = 1,
    this.misura = 132,
  });

  final int percento;
  final MaestroPalette palette;

  /// Da zero a uno: l'arco si riempie, e il numero conta insieme a lui.
  final double avanzamento;

  final double misura;

  @override
  Widget build(BuildContext context) {
    final quanti = (percento * avanzamento).round();
    return SizedBox(
      key: const Key('gemello_cerchio_percentuale'),
      width: misura,
      height: misura,
      child: CustomPaint(
        painter: _PitturaDelCerchio(
          frazione: percento / 100 * avanzamento,
          oro: palette.gold,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$quanti%',
                  key: const Key('gemello_percentuale_numero'),
                  style: TypographyTokens.cerimoniale()
                      .copyWith(color: palette.goldSoft)),
              Text('di cielo in comune',
                  textAlign: TextAlign.center,
                  style: TypographyTokens.etichetta()
                      .copyWith(color: ColorTokens.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PitturaDelCerchio extends CustomPainter {
  const _PitturaDelCerchio({required this.frazione, required this.oro});

  final double frazione;
  final Color oro;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    const spessore = 8.0;
    final raggio = (size.shortestSide - spessore) / 2;
    canvas.drawCircle(
      centro,
      raggio,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = spessore
        ..color = oro.withValues(alpha: 0.18),
    );
    if (frazione <= 0) return;
    canvas.drawArc(
      Rect.fromCircle(center: centro, radius: raggio),
      -math.pi / 2,
      2 * math.pi * frazione.clamp(0.0, 1.0),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = spessore
        ..color = oro,
    );
  }

  @override
  bool shouldRepaint(_PitturaDelCerchio vecchia) =>
      vecchia.frazione != frazione || vecchia.oro != oro;
}

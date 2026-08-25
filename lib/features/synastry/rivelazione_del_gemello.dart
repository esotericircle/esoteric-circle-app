import 'package:flutter/material.dart';

import '../../core/synastry/gemello_astrale.dart';
import '../../core/synastry/vip_catalog.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// LA RIVELAZIONE DEL GEMELLO ASTRALE. Ordine BO voce 10.
///
/// **I volti sfilano veloci e si fermano su uno.** E' il gesto della lotteria,
/// e qui e' onesto perche' il risultato e' gia' deciso prima che la sfilata
/// cominci: non si sta sorteggiando niente, si sta rivelando un calcolo.
class RivelazioneDelGemello extends StatefulWidget {
  const RivelazioneDelGemello({
    super.key,
    required this.gemello,
    required this.palette,
    this.riduciMovimento,
  });

  final GemelloAstrale gemello;
  final MaestroPalette palette;

  /// **Nullo vuol dire "chiedilo a chi guarda"**, e non "no". Passarlo come
  /// falso per default era un modo per dimenticarselo: una scena che deve
  /// stare ferma con Riduci Movimento non puo' dipendere da chi la monta
  /// ricordandosene.
  final bool? riduciMovimento;

  /// Quanto dura la sfilata.
  static const Duration sfilata = Duration(milliseconds: 1600);

  /// Quanti volti passano al secondo, al massimo della corsa.
  static const int voltiAlSecondo = 14;

  @override
  State<RivelazioneDelGemello> createState() => _RivelazioneDelGemelloState();
}

class _RivelazioneDelGemelloState extends State<RivelazioneDelGemello>
    with SingleTickerProviderStateMixin {
  late final AnimationController _corsa;

  @override
  void initState() {
    super.initState();
    _corsa = AnimationController(
        vsync: this, duration: RivelazioneDelGemello.sfilata);
    // **Con Riduci Movimento il gemello e' gia' li'**, fermo e dichiarato:
    // nessuna sfilata, e nessun momento saltato in silenzio, perche' il
    // momento e' uno solo.
    _corsa.value = 0;
  }

  @override
  void dispose() {
    _corsa.dispose();
    super.dispose();
  }

  /// Quale volto e' a video in questo istante.
  ///
  /// La corsa rallenta come una ruota che si ferma, e **l'ultimo fotogramma e'
  /// sempre il gemello**: non e' il caso che decide dove si ferma, e' il
  /// calcolo, e la sfilata e' solo il modo di dirlo.
  Vip _volto(double t) {
    if (t >= 1) return widget.gemello.vip;
    final rallentata = Curves.easeOutCubic.transform(t);
    final quanti = (RivelazioneDelGemello.sfilata.inMilliseconds / 1000 *
            RivelazioneDelGemello.voltiAlSecondo)
        .round();
    final i = (rallentata * quanti).floor() % VipCatalog.vips.length;
    return VipCatalog.vips[i];
  }

  bool _fermo(BuildContext context) =>
      widget.riduciMovimento ?? MediaQuery.of(context).disableAnimations;

  bool _partita = false;

  @override
  Widget build(BuildContext context) {
    if (!_partita) {
      _partita = true;
      if (_fermo(context)) {
        _corsa.value = 1;
      } else {
        _corsa.forward();
      }
    }
    return AnimatedBuilder(
      animation: _corsa,
      builder: (context, _) {
        final finita = _corsa.value >= 1;
        final vip = _volto(_corsa.value);
        return Column(
          key: const Key('sinastria_gemello'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('IL TUO GEMELLO ASTRALE',
                style: TypographyTokens.etichetta().copyWith(
                    color: widget.palette.goldSoft, letterSpacing: 1.6)),
            const SizedBox(height: SpacingTokens.sm),
            SizedBox(
              width: 120,
              height: 120 / 0.78,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                  border: Border.all(
                      color: widget.palette.gold
                          .withValues(alpha: finita ? 0.9 : 0.35),
                      width: finita ? 2 : 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                  child: vip.hasImage
                      ? Image.asset(vip.thumbPath!, fit: BoxFit.contain)
                      : Icon(Icons.auto_awesome,
                          color: widget.palette.goldSoft),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(vip.name,
                key: const Key('sinastria_gemello_nome'),
                textAlign: TextAlign.center,
                style: TypographyTokens.titoloScheda()
                    .copyWith(color: widget.palette.goldSoft)),
            if (finita) ...[
              const SizedBox(height: SpacingTokens.xs),
              Text(widget.gemello.annuncio,
                  key: const Key('sinastria_gemello_annuncio'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textSecondary)),
            ],
          ],
        );
      },
    );
  }
}

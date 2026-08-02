import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/maestro/consulto_del_cielo.dart';
import '../../core/maestro/natal_context.dart';
import '../../core/quality/quality_tier.dart';
import '../theme/maestro_scope.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';

/// L'attesa e' il Maestro che consulta il tuo cielo.
///
/// Vive nel design system e non dentro la chat perche' le superfici che
/// aspettano una risposta sono DUE, la chat e il Consulta: contare le porte
/// prima costa una cartella diversa, contarle dopo costa una seconda copia che
/// diverge.
///
/// Non e' un'animazione decorativa: cio' che passa sono i dati veri di chi sta
/// aspettando, presi da [ConsultoDelCielo] con costo di inferenza zero. Con
/// Riduci Movimento o Quality Tier basso non si muove nulla e resta la riga che
/// dichiara cosa si sta consultando, perche' **l'informazione non e'
/// l'animazione**.
class ConsultoDelCieloView extends StatefulWidget {
  const ConsultoDelCieloView({
    super.key,
    required this.natal,
    this.durataBattuta = const Duration(milliseconds: 1400),
  });

  /// I dati di questa persona. Se e' vuoto la scena consulta il solo Sole e lo
  /// dichiara, invece di inventare un segno.
  final NatalContext natal;

  /// Quanto resta a schermo ogni battuta.
  final Duration durataBattuta;

  @override
  State<ConsultoDelCieloView> createState() => _ConsultoDelCieloViewState();
}

class _ConsultoDelCieloViewState extends State<ConsultoDelCieloView> {
  late final List<BattutaDelConsulto> _battute =
      ConsultoDelCielo.battutePer(widget.natal);
  int _corrente = 0;
  Timer? _passo;

  @override
  void initState() {
    super.initState();
    // Il timer parte nel primo frame utile, cosi' chi legge `disableAnimations`
    // lo trova gia' deciso.
    WidgetsBinding.instance.addPostFrameCallback((_) => _avvia());
  }

  void _avvia() {
    if (!mounted || _battute.length <= 1) return;
    if (MediaQuery.of(context).disableAnimations) return;
    _passo = Timer.periodic(widget.durataBattuta, (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_corrente >= _battute.length - 1) {
        t.cancel();
        return;
      }
      setState(() => _corrente++);
    });
  }

  @override
  void dispose() {
    _passo?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final riduciMovimento = MediaQuery.of(context).disableAnimations;
    final qualita = context.watch<QualityTierController>().tier;
    final fermo = riduciMovimento || qualita == QualityTier.low;

    // Fermi, si mostra la PRIMA battuta e basta: e' la piu' personale, ed e'
    // l'informazione. Il movimento e' cio' che si toglie, non il contenuto.
    final battuta = _battute[fermo ? 0 : _corrente];

    final riga = Column(
      key: const Key('consulto_del_cielo'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Sto consultando',
          style: TypographyTokens.body(size: 13)
              .copyWith(color: palette.goldSoft),
        ),
        const SizedBox(height: SpacingTokens.xxs),
        Text(
          battuta.frase,
          key: ValueKey('consulto_${battuta.corpo}'),
          textAlign: TextAlign.center,
          style: TypographyTokens.display(size: 18)
              .copyWith(color: palette.textPrimary),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.lg,
        vertical: SpacingTokens.md,
      ),
      child: fermo
          ? riga
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              child: KeyedSubtree(
                key: ValueKey(battuta.corpo),
                child: riga,
              ),
            ),
    );
  }
}

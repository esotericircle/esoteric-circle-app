import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/condivisione/premio_della_condivisione.dart';
import '../../core/horoscope/astro_tradition.dart';
import '../../core/horoscope/i_segni_delle_tradizioni.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';
import 'la_testa_della_tradizione.dart';
import 'oroscopo_share_card.dart';

/// **LA RIVELAZIONE DEL SEGNO, ordine ES voce 35.**
///
/// La riga dell'Architetto, approvata dal fondatore con l'ordine: *"La prima
/// volta che la persona sceglie Cinese o Vedica, la figura in bronzo appare
/// con la sua animazione e la frase "Il tuo segno cinese è il Cavallo". È il
/// momento da condividere."*
///
/// **Una volta sola per tradizione**, e si segna prima di mostrarla: una
/// rivelazione che torna a ogni apertura non rivela piu' niente. **Solo col
/// segno certo**: con la Luna che cambia segno nel giorno di nascita e l'ora
/// che manca, la Vedica ha due segni possibili, e rivelarne uno sarebbe
/// indovinare; la rivelazione aspetta il giorno che l'ora c'e'.
abstract final class LaRivelazioneDelSegno {
  static const String chiave = 'oroscopo_segno_rivelato';

  static const Set<AstroTradition> tradizioni = {
    AstroTradition.cinese,
    AstroTradition.vedica,
  };

  /// Se la rivelazione di [t] e' gia' stata vista su questo telefono.
  static Future<bool> giaVista(AstroTradition t) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getStringList(chiave) ?? const []).contains(t.name);
    } catch (errore) {
      // Senza disco si considera vista: meglio non rivelare che rivelare
      // a ogni apertura.
      return true;
    }
  }

  static Future<void> _segnaVista(AstroTradition t) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final viste = {...?prefs.getStringList(chiave), t.name}.toList()..sort();
      await prefs.setStringList(chiave, viste);
    } catch (errore) {
      // Se il disco non scrive, la rivelazione tornera' la prossima volta:
      // e' il male minore.
    }
  }

  /// Mostra la rivelazione se e' la prima volta. Non fa niente per le altre
  /// tradizioni, senza segno o col segno incerto.
  static Future<void> forseMostra(
    BuildContext context, {
    required AstroTradition tradizione,
    required SegnoDellaTradizione? segno,
    required MaestroPalette palette,
  }) async {
    if (!tradizioni.contains(tradizione) || segno == null || !segno.certo) {
      return;
    }
    final figura = LaTestaDellaTradizione.figura(tradizione, segno);
    if (figura == null) return;
    if (await giaVista(tradizione)) return;
    await _segnaVista(tradizione);
    if (!context.mounted) return;
    await dialogoGeneraleDelCerchio<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Chiudi',
      pageBuilder: (_, __, ___) => _LaRivelazione(
        segno: segno,
        figura: figura,
        palette: palette,
        // **IL FONDO DICHIARATO, ordine AL voce 04**, come la carta
        // ingrandita: questa porta non e' un foglio di Material, il fondo
        // e' il velo e la tessera ci galleggia sopra.
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

class _LaRivelazione extends StatefulWidget {
  const _LaRivelazione({
    required this.segno,
    required this.figura,
    required this.palette,
    required this.backgroundColor,
  });

  final SegnoDellaTradizione segno;
  final String figura;
  final MaestroPalette palette;
  final Color backgroundColor;

  @override
  State<_LaRivelazione> createState() => _LaRivelazioneState();
}

class _LaRivelazioneState extends State<_LaRivelazione>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  final GlobalKey _card = GlobalKey();
  bool _condividendo = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // **CON RIDUCI MOVIMENTO LA FIGURA E' GIA' LI'**: la rivelazione resta,
    // l'animazione no.
    if (MediaQuery.of(context).disableAnimations) {
      _c.value = 1;
    } else if (!_c.isAnimating && _c.value == 0) {
      unawaited(_c.forward());
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _condividi() async {
    setState(() => _condividendo = true);
    try {
      final andata = await shareOroscopoCard(
          boundaryKey: _card, text: '${widget.segno.frase}. Esoteric Circle.');
      // Il premio della condivisione avvenuta, dichiarato sul pulsante.
      if (andata && mounted) {
        await PremioDellaCondivisione.premia(context,
            cosa: 'Hai condiviso il tuo segno');
      }
    } finally {
      if (mounted) setState(() => _condividendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final figura = CurvedAnimation(
        parent: _c, curve: const Interval(0, 0.7, curve: Curves.easeOutBack));
    final luce = CurvedAnimation(parent: _c, curve: const Interval(0, 0.6));
    final frase = CurvedAnimation(
        parent: _c, curve: const Interval(0.45, 1, curve: Curves.easeOut));
    return ColoredBox(
      color: widget.backgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RepaintBoundary(
                key: _card,
                child: Container(
                  key: const Key('rivelazione_del_segno'),
                  padding: const EdgeInsets.all(SpacingTokens.lg),
                  decoration: BoxDecoration(
                    color: p.deepest,
                    borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
                    border: Border.all(color: p.gold.withValues(alpha: 0.5)),
                  ),
                  child: AnimatedBuilder(
                    animation: _c,
                    builder: (context, _) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 220,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Opacity(
                                opacity: luce.value.clamp(0.0, 1.0),
                                child: Container(
                                  width: 220,
                                  height: 220,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(colors: [
                                      p.gold.withValues(alpha: 0.35),
                                      p.gold.withValues(alpha: 0),
                                    ]),
                                  ),
                                ),
                              ),
                              Opacity(
                                opacity: figura.value.clamp(0.0, 1.0),
                                child: Transform.scale(
                                  scale: 0.6 + 0.4 * figura.value,
                                  child: Image.asset(widget.figura,
                                      key: const Key('rivelazione_figura'),
                                      height: 190,
                                      fit: BoxFit.contain),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.md),
                        Opacity(
                          opacity: frase.value.clamp(0.0, 1.0),
                          child: Text(
                            widget.segno.frase,
                            key: const Key('rivelazione_frase'),
                            textAlign: TextAlign.center,
                            style: TypographyTokens.titoloScheda()
                                .copyWith(color: p.goldSoft),
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.xs),
                        Text('Esoteric Circle',
                            style: TypographyTokens.didascalia()
                                .copyWith(color: ColorTokens.textMuted)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              Wrap(
                spacing: SpacingTokens.sm,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    key: const Key('rivelazione_condividi'),
                    onPressed: _condividendo ? null : _condividi,
                    icon: const Icon(Icons.ios_share_rounded),
                    label: Text(PremioDellaCondivisione.etichetta(context)),
                  ),
                  TextButton(
                    key: const Key('rivelazione_continua'),
                    onPressed: () => Navigator.of(context).pop(),
                    child:
                        Text('Continua', style: TextStyle(color: p.goldSoft)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

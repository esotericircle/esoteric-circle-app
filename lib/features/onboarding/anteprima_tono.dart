import 'package:flutter/material.dart';

import '../../core/chat/user_profile.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// L'anteprima della voce: una frase del Maestro, scritta nel tono scelto.
///
/// La schermata "Come vuoi che ti parli" chiedeva di scegliere senza mostrare
/// niente: si sceglieva un'etichetta grammaticale al buio. Qui la stessa cosa
/// viene detta in tutti i modi possibili, e la differenza si sente invece di
/// doverla immaginare.
///
/// Le frasi dicono LA STESSA COSA: e' l'unico modo perche' il confronto sia
/// onesto. Se cambiassero anche di contenuto, chi sceglie sceglierebbe il
/// contenuto, non il tono.
///
/// Sono curatela redazionale nostra, non tradizione: nessuna promessa di
/// esito, niente salute, denaro o eventi garantiti. Una frase di benvenuto e
/// basta.
class AnteprimaTono extends StatefulWidget {
  const AnteprimaTono({
    super.key,
    required this.tono,
    required this.palette,
    this.reduceMotion = false,
  });

  /// Il tono scelto adesso. Null finche' non si sceglie: allora si invita.
  final CourtesyForm? tono;

  final MaestroPalette palette;
  final bool reduceMotion;

  /// Quanto ci mette la frase a scriversi per intero.
  static const Duration scrittura = Duration(milliseconds: 1400);

  /// La frase d'esempio per ciascun tono. Stessa cosa detta in tre modi.
  static String frasePer(CourtesyForm tono) => switch (tono) {
        CourtesyForm.masculine =>
          'Bentornato. Sei arrivato fin qui, e il tuo cielo ti aspettava.',
        CourtesyForm.feminine =>
          'Bentornata. Sei arrivata fin qui, e il tuo cielo ti aspettava.',
        CourtesyForm.neutral =>
          'Che bello vederti. Sei arrivata fin qui, o arrivato: il tuo cielo '
              'ti aspettava comunque.',
        CourtesyForm.unknown =>
          'Il cerchio ti accoglie. Il tuo cielo ti aspettava.',
      };

  @override
  State<AnteprimaTono> createState() => _AnteprimaTonoState();
}

class _AnteprimaTonoState extends State<AnteprimaTono>
    with SingleTickerProviderStateMixin {
  late final AnimationController _penna;

  @override
  void initState() {
    super.initState();
    _penna = AnimationController(
      vsync: this,
      duration: AnteprimaTono.scrittura,
    );
    if (widget.tono != null) _scrivi();
  }

  @override
  void didUpdateWidget(covariant AnteprimaTono old) {
    super.didUpdateWidget(old);
    // Cambiando scelta la frase si RISCRIVE da capo: e' il gesto che fa capire
    // che la voce e' cambiata, piu' del testo stesso.
    if (old.tono != widget.tono && widget.tono != null) _scrivi();
  }

  void _scrivi() {
    if (widget.reduceMotion) {
      _penna.value = 1;
      return;
    }
    _penna
      ..stop()
      ..value = 0
      ..forward();
  }

  @override
  void dispose() {
    _penna.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tono = widget.tono;
    if (tono == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
        child: Text(
          'Scegli qui sopra, e senti come suona.',
          key: const Key('anteprima_tono_invito'),
          textAlign: TextAlign.center,
          style: TypographyTokens.body(size: 14)
              .copyWith(color: ColorTokens.textSecondary, height: 1.5),
        ),
      );
    }

    final frase = AnteprimaTono.frasePer(tono);
    return AnimatedBuilder(
      animation: _penna,
      builder: (context, _) {
        // La penna scrive lettera per lettera. Il resto della frase resta al
        // suo posto ma trasparente, cosi' il riquadro non si allunga mentre
        // si scrive e il testo sotto non salta.
        final quante = (frase.length * _penna.value).round();
        return Container(
          key: const Key('anteprima_tono'),
          padding: const EdgeInsets.all(SpacingTokens.md),
          decoration: BoxDecoration(
            color: widget.palette.surface.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
            border: Border.all(
                color: widget.palette.gold.withValues(alpha: 0.28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('LA TUA GUIDA TI DIRA\'',
                  style: TypographyTokens.label(size: 10).copyWith(
                      color: widget.palette.goldSoft, letterSpacing: 2)),
              const SizedBox(height: SpacingTokens.xs),
              RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  style: TypographyTokens.body(size: 15).copyWith(
                      color: ColorTokens.textPrimary, height: 1.5),
                  children: [
                    TextSpan(text: frase.substring(0, quante)),
                    // Il cursore, finche' scrive.
                    if (quante < frase.length)
                      TextSpan(
                        text: '|',
                        style: TextStyle(color: widget.palette.goldSoft),
                      ),
                    TextSpan(
                      text: frase.substring(quante),
                      style: const TextStyle(color: Colors.transparent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Quante lettere sono gia' scritte, per i test.
  @visibleForTesting
  int get scritte {
    final tono = widget.tono;
    if (tono == null) return 0;
    return (AnteprimaTono.frasePer(tono).length * _penna.value).round();
  }
}

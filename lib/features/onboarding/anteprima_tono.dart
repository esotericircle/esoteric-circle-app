import 'dart:math' as math;

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
          'Bentornato. Sei arrivato fin qui: il tuo cielo ti aspettava.',
        CourtesyForm.feminine =>
          'Bentornata. Sei arrivata fin qui: il tuo cielo ti aspettava.',
        // Un neutro vero NON elenca i participi, li evita: "sei arrivata, o
        // arrivato" obbliga chi legge a scegliere quale meta' della frase gli
        // appartiene, che e' il contrario di una forma neutra.
        CourtesyForm.neutral =>
          'Che bello vederti qui. Il tuo cielo ti aspettava.',
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
          'Scegli qui sopra per sentire come suona.',
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
              Text('LA TUA GUIDA TI DIRÀ',
                  style: TypographyTokens.label(size: 11).copyWith(
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


/// Le onde della voce: anelli che si propagano dal centro verso fuori.
///
/// Sostituiscono il cerchio anonimo in cima alla schermata del genere. Il
/// colore dice la scelta prima delle parole: blu per il maschile, rosa per il
/// femminile, arcobaleno per il neutro. E' una scelta di Mauro, non una
/// convenzione che ci siamo inventati, ed e' l'unico posto dell'app dove il
/// colore porta un significato di genere.
class OndeDellaVoce extends StatefulWidget {
  const OndeDellaVoce({
    super.key,
    required this.tono,
    this.reduceMotion = false,
  });

  /// Il genere scelto. Null prima di scegliere: le onde restano neutre e
  /// pallide, senza fingere una scelta che non c'e'.
  final CourtesyForm? tono;

  final bool reduceMotion;

  /// I colori di ciascuna scelta. Il neutro ne porta piu' di uno, quindi qui
  /// stanno liste e non colori singoli.
  static List<Color> coloriPer(CourtesyForm? tono) => switch (tono) {
        CourtesyForm.masculine => const [
            Color(0xFF4E7BE8),
            Color(0xFF6FA8E0),
            Color(0xFF2F4FA8),
          ],
        CourtesyForm.feminine => const [
            Color(0xFFE86FA8),
            Color(0xFFF0A0C8),
            Color(0xFFB84F84),
          ],
        CourtesyForm.neutral => const [
            Color(0xFFE0733A),
            Color(0xFFE8C463),
            Color(0xFF3FA07A),
            Color(0xFF4E7BE8),
            Color(0xFF9B6FE0),
          ],
        CourtesyForm.unknown || null => const [
            Color(0xFF8A8FA8),
            Color(0xFFA8ADC0),
          ],
      };

  @override
  State<OndeDellaVoce> createState() => _OndeDellaVoceState();
}

class _OndeDellaVoceState extends State<OndeDellaVoce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _onda;

  @override
  void initState() {
    super.initState();
    _onda = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (!widget.reduceMotion) _onda.repeat();
  }

  @override
  void dispose() {
    _onda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _onda,
      builder: (context, _) => CustomPaint(
        key: const Key('onde_della_voce'),
        painter: OndePainter(
          colori: OndeDellaVoce.coloriPer(widget.tono),
          t: widget.reduceMotion ? 0.35 : _onda.value,
        ),
      ),
    );
  }
}

/// Il disegno delle onde. Pubblico perche' i colori sono l'unica cosa che un
/// test possa misurare senza guardare i pixel.
class OndePainter extends CustomPainter {
  OndePainter({required this.colori, required this.t});

  final List<Color> colori;
  final double t;

  /// Quante onde vivono insieme.
  static const int quante = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final rMax = math.min(size.width, size.height) / 2 - 4;
    if (rMax <= 0) return;

    for (var i = 0; i < quante; i++) {
      // Ogni onda parte sfasata dalle altre e corre verso fuori, dove
      // svanisce: e' cosi' che si propaga un suono.
      final k = ((t + i / quante) % 1.0);
      final r = rMax * (0.12 + 0.88 * k);
      final alfa = (1 - k) * (1 - k) * 0.85;
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6 * (1 - k) + 0.6
          ..color = colori[i % colori.length].withValues(alpha: alfa),
      );
    }

    // Il centro da cui la voce parte.
    canvas.drawCircle(
      c,
      5,
      Paint()..color = colori.first.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(OndePainter old) =>
      old.t != t || old.colori != colori;
}

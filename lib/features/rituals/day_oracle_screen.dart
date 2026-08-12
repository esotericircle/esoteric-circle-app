import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../core/sigilli/ora_rituale.dart';

import '../sigilli/regia_del_cammino.dart';

import '../../core/rituals/daily_elements.dart';
import '../../design_system/components/riga_del_dono.dart';

import '../../core/maestro/maestro.dart';
import '../../core/rituals/daily_rituals.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'ritual_view.dart';

/// Oracolo del Giorno, dominio Medora.
///
/// La rivelazione arriva al giroscopio sul device, inclinando il telefono; qui,
/// e sempre, il ripiego universale e' lo scorrimento del dito. L'oracolo e'
/// deterministico dal giorno.
class DayOracleScreen extends StatefulWidget {
  const DayOracleScreen({super.key, this.now});

  final DateTime? now;

  static Route<void> route({DateTime? now}) => MaterialPageRoute<void>(
        builder: (_) => MaestroScope(child: DayOracleScreen(now: now)),
      );

  @override
  State<DayOracleScreen> createState() => _DayOracleScreenState();
}

class _DayOracleScreenState extends State<DayOracleScreen> {
  /// Quante volte si e' chiesto di riprovare. Cambia la chiave della vista,
  /// cosi' il rito riparte davvero invece di restare dov'era.
  int _tentativo = 0;

  @override
  Widget build(BuildContext context) {
    final date = widget.now ?? DateTime.now();
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final oracle = DailyRituals.dayOracle(date);

    return RitualView(
      key: ValueKey('oracolo_$_tentativo'),
      title: 'Oracolo del Giorno',
      palette: palette,
      rito: DailyElement.oracle,
      // Slot del fondale condiviso: qui si cabla il PNG dell'oracolo quando
      // arrivera'. Per ora null, fondo procedurale coerente col cosmo.
      backgroundAsset: null,
      // IL GIROSCOPIO ADESSO C'E' DAVVERO, ordine P voce 16.
      //
      // **Il modo esatto in cui l'Oracolo non funzionava.** Il gesto dichiarato
      // qui era `swipe`, e `RitualGesture` non aveva nemmeno un valore per
      // l'inclinazione: nessuna riga di questa app leggeva il giroscopio per
      // l'Oracolo. Intanto il commento in testa al file diceva "la rivelazione
      // arriva al giroscopio sul device" e la riga a schermo diceva "Inclina il
      // telefono": l'app chiedeva un gesto che non aveva nessun effetto, e chi
      // lo faceva non poteva capire perche' non succedesse niente. Non era un
      // dato mancante ne' una condizione rara: era una promessa scritta in due
      // punti e mantenuta in nessuno.
      //
      // Il ripiego tattile resta obbligatorio e sta dentro `RitualGesture.tilt`:
      // tocco e scorrimento svelano comunque.
      gesture: RitualGesture.tilt,
      // NESSUNO STATO SENZA USCITA. L'oracolo di oggi nasce da una funzione
      // locale e deterministica, quindi non c'e' nessuna rete che possa non
      // tornare: il ripiego scatta solo se il corpus restasse senza righe, che
      // e' una cintura e non un caso atteso. Esiste perche' il giorno che
      // l'Oracolo passasse da un motore vero, il posto dove agganciarlo c'e'
      // gia', invece di essere una schermata muta da scoprire sul telefono.
      ripiego: oracle.trim().isEmpty
          ? (
              etichetta: 'Il cielo di oggi non si è lasciato leggere. '
                  'Non è colpa tua: riprova fra un istante.',
              riprova: () => setState(() => _tentativo++),
            )
          : null,
      // L'ORACOLO ENTRA NEL CAMMINO, ordine P voce 35: alla rivelazione, che
      // e' il momento in cui il dono e' davvero ricevuto.
      onReveal: () => unawaited(RegiaDelCammino.dopoUnGesto(
          context, 'oracolo',
          oraRituale: OraRituale.diAdesso(adesso: date))),
      // COSA STAI PER RICEVERE, prima del gesto: nessuno compie un gesto senza
      // sapere cosa ne esce.
      cosaRicevi: 'Il cielo di oggi ha una riga per te e la stessa per tutta '
          'la giornata: non cambia se la riapri.',
      prompt: 'Inclina o scorri per rivelare',
      sensorHint:
          'Inclina il telefono, oppure scorri col dito: il ripiego tattile vale sempre.',
      visualBuilder: (context, revealed, t, inclinazione) => CustomPaint(
        painter: _OraclePainter(
            palette: palette,
            t: t,
            revealed: revealed,
            inclinazione: inclinazione),
      ),
      revealed: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chi parla, prima del responso.
          RigaDelDono(
            dono: DailyElement.oracle,
            giorno: date,
            superficie: ColorTokens.neutralDeepest,
          ),
          Text('Il cielo di oggi dice',
              style: TypographyTokens.display(size: 18)
                  .copyWith(color: palette.goldSoft)),
          const SizedBox(height: SpacingTokens.sm),
          Text(oracle,
              style: TypographyTokens.body(size: 16)
                  .copyWith(color: ColorTokens.textPrimary, height: 1.5)),
        ],
      ),
    );
  }
}

class _OraclePainter extends CustomPainter {
  _OraclePainter({
    required this.palette,
    required this.t,
    required this.revealed,
    required this.inclinazione,
  });

  final MaestroPalette palette;
  final double t;
  final bool revealed;

  /// L'INCLINAZIONE DEL TELEFONO, in radianti sui due assi.
  ///
  /// Ordine P voce 16: il cielo REAGISCE al giroscopio. Il disco si sposta come
  /// se la carta del cielo fosse sospesa e la mano la inclinasse. A zero, cioe'
  /// senza sensore, la scena e' esattamente quella di prima: nessuno perde
  /// niente, chi ha il sensore guadagna un cielo che risponde.
  final Offset inclinazione;

  /// Di quanti punti si sposta il cielo alla massima inclinazione.
  ///
  /// [TiltListener] limita a 0,06 radianti, quindi con questo fattore lo
  /// scostamento massimo vale 42 punti: si vede, e non fa uscire il disco.
  static const double scostamentoPerRadiante = 700;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero) +
        Offset(inclinazione.dx * scostamentoPerRadiante,
            inclinazione.dy * scostamentoPerRadiante);
    final r = size.shortestSide * 0.34;

    // Disco celeste, un velo che si dirada rivelando la luce.
    canvas.drawCircle(
      center,
      r * 1.6,
      Paint()
        ..shader = RadialGradient(colors: [
          palette.glow.withValues(alpha: revealed ? 0.45 : 0.2),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(center: center, radius: r * 1.6)),
    );

    // Anelli concentrici, come una carta del cielo.
    for (var k = 1; k <= 4; k++) {
      canvas.drawCircle(
        center,
        r * k / 4,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = palette.gold.withValues(alpha: 0.18),
      );
    }

    // Dodici raggi con piccole stelle sui vertici.
    for (var i = 0; i < 12; i++) {
      final a = 2 * math.pi * i / 12 - math.pi / 2 + t * 0.2;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        center + dir * r * 0.2,
        center + dir * r,
        Paint()
          ..strokeWidth = 0.8
          ..color = palette.gold.withValues(alpha: revealed ? 0.4 : 0.16),
      );
      canvas.drawCircle(center + dir * r, revealed ? 2.4 : 1.4,
          Paint()..color = Colors.white.withValues(alpha: revealed ? 0.9 : 0.4));
    }

    // Cuore luminoso, piu' acceso da rivelato.
    canvas.drawCircle(
      center,
      r * 0.18,
      Paint()
        ..shader = RadialGradient(colors: [
          Colors.white.withValues(alpha: revealed ? 0.95 : 0.5),
          palette.goldSoft.withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: center, radius: r * 0.4)),
    );
  }

  @override
  bool shouldRepaint(_OraclePainter old) =>
      old.t != t ||
      old.revealed != revealed ||
      old.palette != palette ||
      old.inclinazione != inclinazione;
}

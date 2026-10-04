import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/cerchio/i_segni_del_cerchio.dart';
import '../../../core/cerchio/il_cerchio_sociale.dart';
import '../../../core/cerchio/le_icone_del_cerchio.dart';
import '../../../core/maestro/maestro.dart';
import '../../../design_system/components/cosmos_background.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/theme/maestro_scope.dart';
import '../../../design_system/tokens/color_tokens.dart';

/// **I DISEGNI DEL CERCHIO SOCIALE, ordine EY.** Il livello visivo viene prima
/// del testo (Linee Guida UX, sezione 2): ogni cosa nuova del motore sociale
/// ha il suo colpo d'occhio. Qui stanno l'icona tonda del profilo, il
/// semaforino, i segni animati, i volti delle reazioni e i tre doni.

/// La palette del Maestro di una persona, o quella neutra del Cerchio.
MaestroPalette paletteDi(Maestro? m) =>
    m == null ? MaestroPalette.neutral : MaestroPalette.forKey(ThemeKey.of(m));

/// L'icona tonda del profilo, dai quattro set disegnati. **Mai una foto.**
class IconaTonda extends StatelessWidget {
  const IconaTonda({
    super.key,
    required this.icona,
    this.lato = 48,
    this.spenta = false,
    this.anello,
  });

  final String icona;
  final double lato;
  final bool spenta;
  final Color? anello;

  @override
  Widget build(BuildContext context) {
    final i = IconaDelProfilo.da(icona);
    final palette = MaestroScope.forse(context) ?? MaestroPalette.neutral;
    Widget immagine = Image.asset(
      i.asset,
      fit: BoxFit.cover,
      alignment: i.eUnaCarta ? const Alignment(0, -0.2) : Alignment.center,
      errorBuilder: (_, __, ___) => ColoredBox(color: palette.surfaceElevated),
    );
    if (spenta) {
      immagine = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.2, 0.2, 0.2, 0, 0, //
          0.2, 0.2, 0.2, 0, 0,
          0.2, 0.2, 0.2, 0, 0,
          0, 0, 0, 0.55, 0,
        ]),
        child: immagine,
      );
    }
    return Container(
      width: lato,
      height: lato,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.deepest,
        border: Border.all(
            color:
                anello ?? palette.gold.withValues(alpha: spenta ? 0.25 : 0.7),
            width: lato > 60 ? 2.5 : 1.5),
        boxShadow: spenta
            ? null
            : [
                BoxShadow(
                    color: palette.gold.withValues(alpha: 0.25),
                    blurRadius: lato * 0.2),
              ],
      ),
      child: ClipOval(child: immagine),
    );
  }
}

/// **IL SEMAFORINO, ordine EY voce 05**: accanto al nome. Spento, arancione
/// chiaro (aspetto io), arancione pieno (mi aspetta), verde (amici). Il rosso
/// non c'e': vive solo nell'elenco delle persone bloccate.
class Semaforino extends StatelessWidget {
  const Semaforino({super.key, required this.semaforo, this.lato = 12});

  final Semaforo semaforo;
  final double lato;

  static const Color verde = Color(0xFF4BE37A);
  static const Color arancione = Color(0xFFFFA23A);

  /// Il nome per chi legge con la voce: il colore non basta.
  static String nomeDi(Semaforo s) => switch (s) {
        Semaforo.spento => 'nessun legame',
        Semaforo.arancioneChiaro => 'invito mandato, in attesa',
        Semaforo.arancionePieno => 'ti ha invitato',
        Semaforo.verde => 'amici',
      };

  @override
  Widget build(BuildContext context) {
    final (riempi, bordo) = switch (semaforo) {
      Semaforo.spento => (Colors.transparent, ColorTokens.textSecondary),
      Semaforo.arancioneChiaro => (
          arancione.withValues(alpha: 0.35),
          arancione
        ),
      Semaforo.arancionePieno => (arancione, arancione),
      Semaforo.verde => (verde, verde),
    };
    return Semantics(
      label: nomeDi(semaforo),
      child: Container(
        key: Key('semaforino_${semaforo.name}'),
        width: lato,
        height: lato,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: riempi,
          border: Border.all(color: bordo, width: 1.5),
          boxShadow: semaforo == Semaforo.spento ||
                  semaforo == Semaforo.arancioneChiaro
              ? null
              : [
                  BoxShadow(color: riempi.withValues(alpha: 0.6), blurRadius: 6)
                ],
        ),
      ),
    );
  }
}

/// Un disegno che respira: lo usa ogni segno, reazione e dono. Con le
/// animazioni spente resta fermo al suo stato pieno.
class _Respiro extends StatefulWidget {
  const _Respiro({required this.disegna});

  final CustomPainter Function(double t) disegna;

  @override
  State<_Respiro> createState() => _RespiroState();
}

class _RespiroState extends State<_Respiro>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2400));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _c.value = 0.5;
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(painter: widget.disegna(_c.value)),
      );
}

/// **IL DISEGNO DI UN SEGNO**, nella palette del Maestro di chi lo manda.
class DisegnoDelSegno extends StatelessWidget {
  const DisegnoDelSegno(
      {super.key, required this.motivo, this.maestro, this.lato = 64});

  final MotivoDelSegno motivo;
  final Maestro? maestro;
  final double lato;

  @override
  Widget build(BuildContext context) {
    final p = paletteDi(maestro);
    return SizedBox(
      width: lato,
      height: lato,
      child: _Respiro(
          disegna: (t) => _PittoreDelSegno(motivo, p.gold, p.goldSoft, t)),
    );
  }
}

class _PittoreDelSegno extends CustomPainter {
  _PittoreDelSegno(this.motivo, this.oro, this.chiaro, this.t);

  final MotivoDelSegno motivo;
  final Color oro;
  final Color chiaro;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final respiro = 0.9 + 0.1 * math.sin(t * 2 * math.pi);
    canvas.drawCircle(
        c,
        r * 0.95,
        Paint()
          ..shader = RadialGradient(colors: [
            oro.withValues(alpha: 0.35 * respiro),
            oro.withValues(alpha: 0),
          ]).createShader(Rect.fromCircle(center: c, radius: r)));
    final linea = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.08
      ..strokeCap = StrokeCap.round
      ..color = chiaro;
    final pieno = Paint()..color = chiaro;
    final s = r * 0.5 * respiro;
    switch (motivo) {
      case MotivoDelSegno.fiamma:
        final path = Path()
          ..moveTo(c.dx, c.dy - s * 1.2)
          ..quadraticBezierTo(c.dx + s, c.dy, c.dx, c.dy + s)
          ..quadraticBezierTo(c.dx - s, c.dy, c.dx, c.dy - s * 1.2);
        canvas.drawPath(path, pieno);
      case MotivoDelSegno.luna:
        // La falce: il disco meno un disco spostato, senza dipingere il fondo.
        final falce = Path.combine(
          PathOperation.difference,
          Path()..addOval(Rect.fromCircle(center: c, radius: s)),
          Path()
            ..addOval(Rect.fromCircle(
                center: c.translate(s * 0.5, -s * 0.2), radius: s * 0.8)),
        );
        canvas.drawPath(falce, pieno);
      case MotivoDelSegno.stella:
      case MotivoDelSegno.sole:
        final raggi = motivo == MotivoDelSegno.sole ? 12 : 5;
        final path = Path();
        for (var i = 0; i < raggi * 2; i++) {
          final a = -math.pi / 2 + i * math.pi / raggi + t * 0.6;
          final rr = i.isEven
              ? s * 1.2
              : s * (motivo == MotivoDelSegno.sole ? 0.8 : 0.45);
          final p = c + Offset(math.cos(a) * rr, math.sin(a) * rr);
          i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(path..close(), pieno);
      case MotivoDelSegno.spirale:
        final path = Path();
        for (var i = 0; i <= 60; i++) {
          final a = i / 60 * 4 * math.pi + t * 2 * math.pi;
          final rr = s * 1.2 * i / 60;
          final p = c + Offset(math.cos(a) * rr, math.sin(a) * rr);
          i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(path, linea);
      case MotivoDelSegno.onda:
        for (var k = -1; k <= 1; k++) {
          final path = Path();
          for (var i = 0; i <= 30; i++) {
            final x = c.dx - s * 1.3 + i / 30 * s * 2.6;
            final y = c.dy +
                k * s * 0.6 +
                math.sin(i / 30 * 2 * math.pi + t * 2 * math.pi) * s * 0.2;
            i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
          }
          canvas.drawPath(path, linea);
        }
      case MotivoDelSegno.mano:
        canvas.drawCircle(c.translate(0, s * 0.3), s * 0.55, pieno);
        for (var i = 0; i < 4; i++) {
          final x = c.dx - s * 0.45 + i * s * 0.3;
          canvas.drawLine(
              Offset(x, c.dy + s * 0.1), Offset(x, c.dy - s * 0.9), linea);
        }
      case MotivoDelSegno.sentiero:
        final path = Path()
          ..moveTo(c.dx - s * 1.1, c.dy + s)
          ..cubicTo(c.dx + s, c.dy + s * 0.6, c.dx - s, c.dy - s * 0.4,
              c.dx + s * 1.1, c.dy - s);
        canvas.drawPath(path, linea);
        canvas.drawCircle(
            path
                .computeMetrics()
                .first
                .getTangentForOffset(path.computeMetrics().first.length * t)!
                .position,
            r * 0.09,
            pieno);
      case MotivoDelSegno.pianeta:
        canvas.drawCircle(c, s * 0.7, pieno);
        canvas.drawOval(
            Rect.fromCenter(center: c, width: s * 2.6, height: s * 0.8), linea);
      case MotivoDelSegno.carta:
        final rect = RRect.fromRectAndRadius(
            Rect.fromCenter(center: c, width: s * 1.3, height: s * 2),
            Radius.circular(r * 0.08));
        canvas.drawRRect(rect, linea);
        canvas.drawCircle(c, s * 0.3, pieno);
      case MotivoDelSegno.runa:
        canvas.drawLine(
            c.translate(-s * 0.3, -s), c.translate(-s * 0.3, s), linea);
        canvas.drawLine(
            c.translate(-s * 0.3, -s * 0.5), c.translate(s * 0.5, -s), linea);
        canvas.drawLine(
            c.translate(-s * 0.3, 0), c.translate(s * 0.5, -s * 0.5), linea);
      case MotivoDelSegno.respiro:
        for (var k = 1; k <= 3; k++) {
          canvas.drawCircle(c, s * 0.4 * k * respiro,
              linea..color = chiaro.withValues(alpha: 1 - k * 0.25));
        }
    }
  }

  @override
  bool shouldRepaint(_PittoreDelSegno old) => old.t != t || old.oro != oro;
}

/// **IL VOLTO DI UNA REAZIONE, ordine EY voce 11**: figure disegnate e non
/// caratteri, cosi' si vedono uguali su ogni telefono. Nulla di offensivo:
/// la pernacchia e' una linguaccia, gli occhi al cielo sono occhi al cielo.
class VoltoDellaReazione extends StatelessWidget {
  const VoltoDellaReazione({super.key, required this.reazione, this.lato = 44});

  final Reazione reazione;
  final double lato;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: lato,
        height: lato,
        child: _Respiro(disegna: (t) => _PittoreDelVolto(reazione, t)),
      );
}

class _PittoreDelVolto extends CustomPainter {
  _PittoreDelVolto(this.reazione, this.t);

  final Reazione reazione;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 * 0.9;
    const giallo = Color(0xFFF2C14E);
    const scuro = Color(0xFF3A2410);
    final tratto = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.1
      ..strokeCap = StrokeCap.round
      ..color = scuro;
    if (reazione == Reazione.luce) {
      for (var i = 0; i < 8; i++) {
        final a = i * math.pi / 4 + t * math.pi;
        canvas.drawLine(
            c + Offset(math.cos(a), math.sin(a)) * r * 0.35,
            c + Offset(math.cos(a), math.sin(a)) * r * 0.95,
            tratto..color = giallo);
      }
      canvas.drawCircle(c, r * 0.3, Paint()..color = giallo);
      return;
    }
    if (reazione == Reazione.pensiero) {
      canvas.drawCircle(c.translate(r * 0.1, -r * 0.2), r * 0.55,
          Paint()..color = const Color(0xFFDCD3F5));
      canvas.drawCircle(c.translate(-r * 0.5, r * 0.55), r * 0.14,
          Paint()..color = const Color(0xFFDCD3F5));
      canvas.drawCircle(c.translate(-r * 0.75, r * 0.8), r * 0.08,
          Paint()..color = const Color(0xFFDCD3F5));
      return;
    }
    canvas.drawCircle(c, r, Paint()..color = giallo);
    final occhioY = c.dy - r * 0.2;
    final guarda = reazione == Reazione.occhiAlCielo;
    for (final x in [c.dx - r * 0.35, c.dx + r * 0.35]) {
      if (reazione == Reazione.sorriso || reazione == Reazione.abbraccio) {
        canvas.drawArc(
            Rect.fromCircle(center: Offset(x, occhioY), radius: r * 0.15),
            math.pi,
            math.pi,
            false,
            tratto);
      } else {
        canvas.drawCircle(
            Offset(x, occhioY), r * 0.18, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(x, occhioY - (guarda ? r * 0.08 : 0)),
            r * 0.08, Paint()..color = scuro);
      }
    }
    switch (reazione) {
      case Reazione.pernacchia:
        canvas.drawLine(c.translate(-r * 0.35, r * 0.35),
            c.translate(r * 0.35, r * 0.35), tratto);
        final lingua = 0.25 + 0.08 * math.sin(t * 2 * math.pi);
        canvas.drawOval(
            Rect.fromLTWH(
                c.dx - r * 0.18, c.dy + r * 0.35, r * 0.36, r * lingua * 1.6),
            Paint()..color = const Color(0xFFE86A7A));
      case Reazione.occhiAlCielo:
        canvas.drawLine(c.translate(-r * 0.3, r * 0.45),
            c.translate(r * 0.3, r * 0.45), tratto);
      case Reazione.grazie:
        canvas.drawArc(
            Rect.fromCircle(center: c.translate(0, r * 0.2), radius: r * 0.35),
            0.2,
            math.pi - 0.4,
            false,
            tratto);
      case Reazione.abbraccio:
        canvas.drawArc(
            Rect.fromCircle(center: c.translate(0, r * 0.15), radius: r * 0.4),
            0.3,
            math.pi - 0.6,
            false,
            tratto);
        canvas.drawArc(
            Rect.fromCircle(center: c, radius: r * 1.15),
            math.pi * 0.6,
            math.pi * 0.8,
            false,
            tratto..color = const Color(0xFFE86A7A));
      case Reazione.sorriso:
        canvas.drawArc(
            Rect.fromCircle(center: c.translate(0, r * 0.1), radius: r * 0.45),
            0.3,
            math.pi - 0.6,
            false,
            tratto);
      case Reazione.luce:
      case Reazione.pensiero:
        break;
    }
  }

  @override
  bool shouldRepaint(_PittoreDelVolto old) => old.t != t;
}

/// **IL DISEGNO DI UN DONO, ordine EY voce 12**: il cenno, la scintilla, il
/// sigillo. Resta nel profilo di chi lo riceve come ornamento.
class DisegnoDelDono extends StatelessWidget {
  const DisegnoDelDono(
      {super.key, required this.dono, this.maestro, this.lato = 56});

  final Dono dono;
  final Maestro? maestro;
  final double lato;

  @override
  Widget build(BuildContext context) {
    final p = paletteDi(maestro);
    return SizedBox(
      width: lato,
      height: lato,
      child: _Respiro(
          disegna: (t) => _PittoreDelDono(dono, p.gold, p.goldSoft, t)),
    );
  }
}

class _PittoreDelDono extends CustomPainter {
  _PittoreDelDono(this.dono, this.oro, this.chiaro, this.t);

  final Dono dono;
  final Color oro;
  final Color chiaro;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final linea = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.08
      ..strokeCap = StrokeCap.round
      ..color = chiaro;
    switch (dono) {
      case Dono.cenno:
        // Una mano che saluta: tre archi che si aprono.
        for (var k = 1; k <= 3; k++) {
          canvas.drawArc(
              Rect.fromCircle(
                  center: c.translate(-r * 0.3, 0), radius: r * 0.25 * k),
              -0.7 + 0.15 * math.sin(t * 2 * math.pi),
              1.4,
              false,
              linea..color = chiaro.withValues(alpha: 1 - k * 0.22));
        }
      case Dono.scintilla:
        final path = Path();
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4 + t * math.pi / 2;
          final rr = i.isEven ? r * 0.85 : r * 0.22;
          final p = c + Offset(math.cos(a) * rr, math.sin(a) * rr);
          i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(path..close(), Paint()..color = chiaro);
      case Dono.sigillo:
        canvas.drawCircle(c, r * 0.8, Paint()..color = oro);
        canvas.drawCircle(c, r * 0.8, linea..color = chiaro);
        canvas.drawCircle(c, r * 0.55, linea..strokeWidth = r * 0.04);
        for (var i = 0; i < 6; i++) {
          final a = i * math.pi / 3 + t * 0.8;
          canvas.drawLine(
              c, c + Offset(math.cos(a), math.sin(a)) * r * 0.5, linea);
        }
    }
  }

  @override
  bool shouldRepaint(_PittoreDelDono old) => old.t != t;
}

/// **I PULSANTI DI TESTO DEL CERCHIO SONO D'ORO.** Senza, un `TextButton`
/// eredita il viola primario del tema, che sul nero delle schermate sociali
/// non si legge: visto nelle anteprime (Rinnova, Revoca, Sblocca).
///
/// **E IL CIELO DEL CERCHIO SOTTO**: lo sfondo cosmico del menu' utente, non
/// il nero pieno. Il fondatore il 4 ottobre 2026: "Tutte le anteprime che
/// riguardano il cerchio hanno sfondo nero, anziché lo sfondo cosmico
/// dell'app". Le schermate del Cerchio hanno la Scaffold trasparente.
Widget conIPulsantiDOro(BuildContext context, Widget figlio, {int seme = 23}) {
  final tema = Theme.of(context);
  return CosmosBackground(
    key: const Key('cerchio_cosmo'),
    seed: seme,
    child: Theme(
      data: tema.copyWith(
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: MaestroPalette.neutral.goldSoft),
        ),
      ),
      child: figlio,
    ),
  );
}

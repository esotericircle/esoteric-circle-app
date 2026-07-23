import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/archetypes/archetype.dart';
import '../../../../core/archetypes/archetype_scoring.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/typography_tokens.dart';

/// La ruota astrolabio del profilo archetipico.
///
/// E' il livello visivo che arriva prima del testo: si legge il profilo a colpo
/// d'occhio, con la fetta del dominante accesa in oro, prima di leggere una
/// sola parola. La statua NON sta dentro la ruota, sta sopra: qui c'e' solo il
/// cielo dei dodici.
///
/// L'anello esterno porta i dodici nomi, ognuno sopra la sua fetta, col testo
/// CURVATO che segue la circonferenza. I nomi della meta' inferiore sono
/// capovolti di mezzo giro, cosi' restano leggibili e mai a testa in giu'.
/// Nessun glifo: l'anello porta solo i nomi. Il poligono verde del profilo e'
/// grande, riempie il disco interno, ma resta dentro l'anello senza coprirlo.
class ArchetypeWheel extends StatelessWidget {
  const ArchetypeWheel({
    super.key,
    required this.profilo,
    required this.palette,
    this.avanzamento = 1.0,
    this.lato = 360,
    this.etichette = true,
    this.accendiSecondo = false,
  });

  final ArchetypeProfile profilo;
  final MaestroPalette palette;

  /// Da zero a uno: quanto e' posato l'astrolabio. A uno la ruota e' intera e
  /// la fetta del dominante e' accesa.
  final double avanzamento;

  final double lato;

  /// I nomi sull'anello esterno. Si spengono nella mini-ruota della card.
  final bool etichette;

  /// Accende anche la fetta del co-dominante, in un tono piu' tenue, cosi' il
  /// legame "accanto Il Ribelle" si legge nella ruota. Spento sul responso, dove
  /// il co-dominante e' gia' scritto sotto il nome, acceso sulla card.
  final bool accendiSecondo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('archetype_wheel'),
      width: lato,
      height: lato,
      child: CustomPaint(
        painter: _AstrolabioPainter(
          profilo: profilo,
          palette: palette,
          avanzamento: avanzamento.clamp(0.0, 1.0),
          etichette: etichette,
          accendiSecondo: accendiSecondo,
        ),
      ),
    );
  }
}

class _AstrolabioPainter extends CustomPainter {
  _AstrolabioPainter({
    required this.profilo,
    required this.palette,
    required this.avanzamento,
    required this.etichette,
    required this.accendiSecondo,
  });

  final ArchetypeProfile profilo;
  final MaestroPalette palette;
  final double avanzamento;
  final bool etichette;
  final bool accendiSecondo;

  static const int n = 12;
  static const double _passo = 2 * math.pi / n;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    // L'anello dei nomi occupa la corona esterna; il disco del profilo sta
    // dentro. Con le etichette si lascia spazio all'anello, senza si usa quasi
    // tutto il raggio.
    final rEsterno = size.shortestSide / 2 - 2;
    final rDisco = etichette ? rEsterno * 0.80 : rEsterno * 0.94;

    final iDom = profilo.dominante.ordineCanonico;

    // Disegna la fetta i, dal centro all'arco, in oro con l'alpha dato. Cresce
    // col posarsi dell'astrolabio.
    void fetta(int i, double alpha) {
      final aStart = _angoloFetta(i) - _passo / 2;
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy)
          ..arcTo(Rect.fromCircle(center: c, radius: rDisco), aStart,
              _passo * avanzamento, false)
          ..close(),
        Paint()
          ..style = PaintingStyle.fill
          ..color = palette.gold.withValues(alpha: alpha * avanzamento),
      );
    }

    // Sul responso (senza accendiSecondo) la fetta del dominante sta SOTTO il
    // poligono, come e' sempre stata. Sulla card le fette accese si disegnano
    // invece SOPRA il poligono, piu' avanti, cosi' restano leggibili anche dove
    // il verde le coprirebbe.
    if (!accendiSecondo) {
      fetta(iDom, 0.22);
    }

    // Le tre corone di riferimento: danno la scala senza numeri.
    final filo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = palette.gold.withValues(alpha: 0.22);
    for (final q in [0.34, 0.67, 1.0]) {
      canvas.drawCircle(c, rDisco * q, filo);
    }

    // Le dodici linee di divisione delle fette.
    final divisione = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = palette.gold.withValues(alpha: 0.16);
    for (var i = 0; i < n; i++) {
      final a = _angoloFetta(i) - _passo / 2;
      canvas.drawLine(c, c + Offset(math.cos(a), math.sin(a)) * rDisco, divisione);
    }

    // Il profilo, poligono a dodici vertici sulle fette. Grande: parte da una
    // base piu' alta e usa quasi tutto il disco, cosi' la distribuzione del
    // test si legge con forza.
    final massimo =
        Archetype.values.map(profilo.percentualeDi).fold<double>(0.0001, math.max);
    final punti = <Offset>[];
    for (var i = 0; i < n; i++) {
      final quota = profilo.percentualeDi(Archetype.values[i]) / massimo;
      final lung = rDisco * (0.22 + 0.78 * quota) * avanzamento;
      final a = _angoloFetta(i);
      punti.add(c + Offset(math.cos(a), math.sin(a)) * lung);
    }
    final forma = Path()..addPolygon(punti, true);
    canvas.drawPath(
      forma,
      Paint()
        ..style = PaintingStyle.fill
        ..color = palette.primary.withValues(alpha: 0.34 * avanzamento),
    );
    canvas.drawPath(
      forma,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = palette.glow.withValues(alpha: 0.90 * avanzamento),
    );
    // Sulla card: le fette accese SOPRA il poligono. Il co-dominante in tono
    // tenue, il dominante in oro pieno sopra di lui, cosi' l'oro resta il piu'
    // acceso e il legame "accanto" si legge anche dove il verde copre.
    if (accendiSecondo) {
      if (profilo.secondo != null) fetta(profilo.secondo!.ordineCanonico, 0.16);
      fetta(iDom, 0.24);
    }

    canvas.drawCircle(punti[iDom], 6 * avanzamento, Paint()..color = palette.goldSoft);

    if (!etichette) return;

    // L'anello esterno: i dodici nomi curvati lungo la circonferenza, ognuno
    // centrato sulla sua fetta. La meta' inferiore si capovolge di mezzo giro
    // per restare leggibile. I nomi stanno vicino al bordo esterno, dove l'arco
    // e' piu' lungo, e la taglia del carattere e' UNA sola per tutti e dodici:
    // si prende la piu' grande che tiene il nome piu' lungo (Esploratore) dentro
    // la sua fetta con un margine visibile sui due lati, cosi' nessun nome tocca
    // i vicini, ne' in alto ne' in basso.
    final rTesto = rEsterno - 7;
    const riempi = 0.84; // quota della fetta occupata dal testo, resto a margine
    final arcoMax = _passo * riempi * rTesto;
    // Misura il nome piu' largo a una taglia di riferimento, poi scala: con la
    // spaziatura proporzionale alla taglia la larghezza cresce in modo lineare,
    // quindi una sola scalatura basta.
    const riferimento = 12.0;
    var largMax = 0.0;
    for (final a in Archetype.values) {
      largMax = math.max(largMax,
          _larghezzaTesto(a.nome.toUpperCase(), _stileAnello(riferimento)));
    }
    final taglia = (riferimento * arcoMax / largMax).clamp(7.0, 12.0).toDouble();
    for (var i = 0; i < n; i++) {
      _nomeCurvo(
        canvas,
        c,
        rTesto,
        _angoloFetta(i),
        Archetype.values[i].nome.toUpperCase(),
        _stileAnello(taglia, dom: i == iDom),
      );
    }
  }

  /// Lo stile di un nome sull'anello: taglia unica, spaziatura proporzionale
  /// (cosi' la larghezza scala lineare con la taglia) e peso uguale per tutti.
  /// Il dominante si distingue solo per il colore oro, mai per la dimensione.
  /// Si costruisce a mano, senza passare da `label()`, perche' quello imporrebbe
  /// il minimo leggibile del testo dritto e i dodici nomi non starebbero.
  TextStyle _stileAnello(double taglia, {bool dom = false}) => TextStyle(
        fontFamily: TypographyTokens.displayFamily,
        fontSize: taglia,
        fontVariations: const [FontVariation('wght', 600)],
        fontWeight: FontWeight.w600,
        letterSpacing: taglia * 0.08,
        color: dom
            ? palette.goldSoft
            : palette.textSecondary.withValues(alpha: 0.9),
      );

  /// La larghezza del testo come somma delle larghezze dei singoli glifi, lo
  /// stesso conto che fa `_nomeCurvo` quando li dispone sull'arco.
  double _larghezzaTesto(String testo, TextStyle stile) {
    var w = 0.0;
    for (final ch in testo.characters) {
      final tp = TextPainter(
        text: TextSpan(text: ch, style: stile),
        textDirection: TextDirection.ltr,
      )..layout();
      w += tp.width;
    }
    return w;
  }

  /// Disegna [testo] curvato su un arco di raggio [r] centrato sull'angolo
  /// [centro]. Lettera per lettera, tangente alla circonferenza. Se il centro
  /// sta nella meta' bassa, il testo si capovolge cosi' resta dritto.
  void _nomeCurvo(Canvas canvas, Offset c, double r, double centro, String testo,
      TextStyle stile) {
    // Larghezze delle lettere, per distribuirle sull'arco simmetricamente.
    final glifi = <TextPainter>[];
    var larghezzaTot = 0.0;
    for (final ch in testo.characters) {
      final tp = TextPainter(
        text: TextSpan(text: ch, style: stile),
        textDirection: TextDirection.ltr,
      )..layout();
      glifi.add(tp);
      larghezzaTot += tp.width;
    }
    if (larghezzaTot == 0) return;

    // L'angolo totale occupato dal testo, e da dove parte.
    final angoloTot = larghezzaTot / r;
    // Meta' bassa: sin(centro) > 0 nel sistema con y verso il basso e centro a
    // partire da -pi/2 in alto. Si capovolge il testo.
    final capovolto = math.sin(centro) > 0.02;

    var ang = capovolto ? centro + angoloTot / 2 : centro - angoloTot / 2;
    for (final tp in glifi) {
      final dAng = tp.width / r;
      final aCar = ang + (capovolto ? -dAng / 2 : dAng / 2);
      final pos = c + Offset(math.cos(aCar), math.sin(aCar)) * r;
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      // Tangente: il testo segue la curva. Capovolto aggiunge mezzo giro.
      canvas.rotate(aCar + math.pi / 2 + (capovolto ? math.pi : 0));
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
      ang += capovolto ? -dAng : dAng;
    }
  }

  /// L'angolo del centro della fetta i, in senso orario dall'alto.
  double _angoloFetta(int i) => -math.pi / 2 + i * _passo;

  @override
  bool shouldRepaint(_AstrolabioPainter old) =>
      old.avanzamento != avanzamento ||
      old.profilo.dominante != profilo.dominante ||
      old.profilo.secondo != profilo.secondo ||
      old.etichette != etichette ||
      old.accendiSecondo != accendiSecondo;
}

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/condivisione/porta_della_condivisione.dart';
import '../../../synastry/sinastria_share_card.dart' show captureBoundaryPng;

import '../../../../core/brand/brand.dart';
import '../../../../core/maestro/chakra_del_giorno.dart';
import '../../../../core/maestro/colore_del_centro.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';

/// **LA CARD DEL RESPIRO.** Ordine DB voce 10, 9 settembre 2026. Chiude anche
/// la voce CZ.09, che era rimasta ferma su lavoro non montato.
///
/// **Parole dell'ordine**: *"I tempi reali di inspiro e di espiro disegnano una
/// figura. Siccome nessuno respira come un altro, quella figura e' diversa ogni
/// volta e diversa da quella di chiunque."*
///
/// **PERCHE' LA FIGURA E' DAVVERO DIVERSA, e non e' un modo di dire.** Non
/// nasce da una categoria ne' da un numero arrotondato: nasce dalla **quota del
/// dentro** di ogni respiro, cioe' da quanto pesa l'inspiro sul respiro
/// intero, che e' un numero in virgola mobile misurato al millisecondo. Due
/// persone non hanno mai la stessa serie, e la stessa persona non la ripete
/// due volte.
///
/// **E' la stessa lezione della card del Viso**, imparata l'8 settembre: quella
/// diceva *"una costellazione su 104.976 possibili"* e prometteva unicita' che
/// a 382 utenti non reggeva. **Qui la promessa regge**, perche' la figura viene
/// da misure continue e non da caselle, ed e' per questo che il testo puo'
/// dirlo.
///
/// **CHI HA SCELTO IL RESPIRO GUIDATO**, e non il proprio, ottiene la card con
/// la forma del ritmo guidato, **dichiarata come tale**: sarebbe la figura
/// dell'app e non la sua, e spacciarla per sua sarebbe la prima bugia di questa
/// funzione.
class CardDelRespiro extends StatelessWidget {
  const CardDelRespiro({
    super.key,
    required this.figura,
    required this.giorno,
    required this.guidato,
    this.larghezza = 320,
  });

  /// Le quote del dentro, un valore per respiro, da zero a uno.
  final List<double> figura;

  /// Il giorno, da cui vengono il centro e il colore.
  final DateTime giorno;

  /// Se il respiro era guidato dall'app invece che proprio.
  final bool guidato;

  final double larghezza;

  @override
  Widget build(BuildContext context) {
    final colore = ColoreDelCentro.di(giorno);
    final centro = ChakraDelGiorno.di(giorno);
    return Container(
      key: const Key('card_del_respiro'),
      width: larghezza,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(const Color(0xFF0B0620), colore, 0.18)!,
            const Color(0xFF07030F),
          ],
        ),
        border: Border.all(color: colore.withValues(alpha: 0.55), width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('IL TUO RESPIRO DI OGGI',
                key: const Key('card_respiro_titolo'),
                style: TypographyTokens.label(size: 12).copyWith(
                    color: ColoreDelCentro.bordoDi(colore),
                    letterSpacing: 2.0)),
            const SizedBox(height: SpacingTokens.md),
            SizedBox(
              width: larghezza * 0.82,
              height: larghezza * 0.52,
              child: CustomPaint(
                painter: PittoreDellaFigura(figura: figura, colore: colore),
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            // **LE TRE RIGHE DI AURA**, che legano il respiro di oggi al
            // centro di oggi. Ordine DB voce 10, e nessuna promette un
            // effetto: dicono cosa e' successo e cosa portarsi dietro.
            Text(
              righeDiAura(figura, giorno, guidato).join('\n'),
              key: const Key('card_respiro_righe'),
              textAlign: TextAlign.center,
              style: TypographyTokens.corpo()
                  .copyWith(color: const Color(0xFFF2E4C9), height: 1.5),
            ),
            const SizedBox(height: SpacingTokens.sm),
            // **IL PIEDE E' A CORPO E NON IN MAIUSCOLETTO**, e lo ha chiesto
            // una guardia: in maiuscoletto questa riga andava a capo, e *"il
            // maiuscoletto e' un segnale, non un testo: quando va a capo
            // diventa un muro di lettere larghe"*.
            Text('Esoteric Circle · Aura · ${centro.italiano}',
                style: TypographyTokens.corpo().copyWith(
                    color: ColoreDelCentro.bordoDi(colore)
                        .withValues(alpha: 0.75),
                    letterSpacing: 1.0)),
            const SizedBox(height: 2),
            Text(Brand.domain,
                key: const Key('card_respiro_indirizzo'),
                style: TypographyTokens.corpo().copyWith(
                    color: ColoreDelCentro.bordoDi(colore)
                        .withValues(alpha: 0.9),
                    letterSpacing: 0.8)),
          ],
        ),
      ),
    );
  }

  /// **LE TRE RIGHE, e sono tre e non due.** Ordine DB voce 10: *"tre righe di
  /// Aura che legano il respiro di oggi al centro di oggi, piu' una frase da
  /// portare nella giornata"*.
  ///
  /// **Nessuna promessa di effetto**, e la guardia della voce DB.11 lo
  /// pretende su ogni testo di questa funzione.
  static List<String> righeDiAura(
      List<double> figura, DateTime giorno, bool guidato) {
    final centro = ChakraDelGiorno.di(giorno);
    final quanti = figura.length;
    // La forma media del respiro: sopra la meta' e' un respiro che tiene
    // dentro, sotto e' uno che lascia andare.
    final media = figura.isEmpty
        ? 0.5
        : figura.reduce((a, b) => a + b) / figura.length;
    final forma = media > 0.55
        ? 'hai tenuto dentro più a lungo di quanto hai lasciato andare'
        : media < 0.45
            ? 'hai lasciato andare più a lungo di quanto hai tenuto dentro'
            : 'dentro e fuori si sono tenuti in equilibrio';
    return [
      guidato
          ? 'Questa è la forma del ritmo guidato, non del tuo.'
          : '$quanti respiri: nessuno uguale al precedente.',
      'Oggi è acceso ${centro.italiano}, che apre su ${centro.governa}: $forma.',
      'Portati dietro questo: la calma non si trova, si tiene.',
    ];
  }
}

/// Il pittore della figura del respiro. **Pubblico apposta**: la sua geometria
/// e' la cosa da misurare, e una guardia deve poterlo interrogare senza
/// montare una schermata.
class PittoreDellaFigura extends CustomPainter {
  PittoreDellaFigura({required this.figura, required this.colore});

  final List<double> figura;
  final Color colore;

  /// **QUANTO SONO DIVERSE DUE FIGURE**, come distanza media punto per punto.
  /// Serve alla guardia che prova che due respiri non danno lo stesso disegno.
  static double distanzaFra(List<double> a, List<double> b) {
    final quanti = a.length < b.length ? a.length : b.length;
    if (quanti == 0) return 0;
    var somma = 0.0;
    for (var i = 0; i < quanti; i++) {
      somma += (a[i] - b[i]).abs();
    }
    return somma / quanti;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (figura.isEmpty) return;
    final centro = size.center(Offset.zero);
    final raggio = size.shortestSide / 2 * 0.92;

    // **UNA CORONA DI RAGGI, uno per respiro.** Il raggio lungo e' un respiro
    // che ha tenuto dentro, quello corto uno che ha lasciato andare presto:
    // la figura si legge senza spiegazioni, e nessuna e' uguale a un'altra.
    final passo = 2 * math.pi / figura.length;
    final via = Path();
    for (var i = 0; i < figura.length; i++) {
      final q = figura[i].clamp(0.0, 1.0);
      final r = raggio * (0.35 + 0.65 * q);
      final a = -math.pi / 2 + i * passo;
      final punto = centro + Offset(math.cos(a), math.sin(a)) * r;
      if (i == 0) {
        via.moveTo(punto.dx, punto.dy);
      } else {
        via.lineTo(punto.dx, punto.dy);
      }
      canvas.drawCircle(
          punto, 2.4, Paint()..color = ColoreDelCentro.bordoDi(colore));
    }
    via.close();
    canvas.drawPath(
        via,
        Paint()
          ..style = PaintingStyle.fill
          ..color = colore.withValues(alpha: 0.30));
    canvas.drawPath(
        via,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = ColoreDelCentro.bordoDi(colore).withValues(alpha: 0.85));
  }

  @override
  bool shouldRepaint(covariant PittoreDellaFigura vecchio) =>
      vecchio.colore != colore ||
      vecchio.figura.length != figura.length;
}

/// **CONDIVIDE LA CARD, DAL PUNTO UNICO.** Ordine DB voce 10: *"passa dal
/// punto unico della condivisione. Non se ne scrive un altro."*
///
/// E' la stessa strada dell'Oroscopo e del Sigillo: il PNG nasce dal boundary,
/// finisce in un file temporaneo del telefono e va alla porta. **Nessun
/// server**, e l'esito vero risale a chi ha chiamato, perche' il premio della
/// condivisione si paga solo a condivisione avvenuta.
Future<bool> condividiLaCardDelRespiro({
  required GlobalKey boundaryKey,
  required String testo,
}) async {
  final png = await captureBoundaryPng(boundaryKey);
  if (png == null) return false;
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/card_del_respiro.png');
  await file.writeAsBytes(png, flush: true);
  return PortaDellaCondivisione.daFile(file.path, testo: testo);
}

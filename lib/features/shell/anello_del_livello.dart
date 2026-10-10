import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/sigilli/diario_del_cammino.dart';
import '../../core/sigilli/sentieri.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// L'ANELLO DEL LIVELLO ATTORNO AL VOLTO. Ordine CF voce 01.
///
/// **Parole del fondatore**: "visivamente un cerchio a riempimento intorno
/// all'icona del profilo che visivamente rappresentera' il livello XP".
///
/// **IL LIVELLO XP NON ESISTE ANCORA, e questo widget non lo inventa.** Il
/// fondatore lo ha approvato come lavoro futuro e non lo ha ordinato: qui si
/// costruisce il POSTO e la FORMA, e il valore arriva dall'unica grandezza di
/// progressione che il progetto possiede gia', i Sigilli del Cammino.
/// La porta e' `DiarioDelCammino.progressoDelCammino` e non ce n'e'
/// un'altra, perche' due conteggi della stessa cosa sono la famiglia di
/// difetti piu' numerosa di questo progetto.
///
/// **Il denominatore sono i raggiungibili, non i 165.** Cinquantuno traguardi
/// dei centosessantacinque sono dormienti, cioe' scritti e non ancora
/// agganciati a un gesto vivo: contarli farebbe un anello che non puo'
/// chiudersi nemmeno giocando per anni, e sarebbe una promessa falsa
/// disegnata addosso al volto della persona.
///
/// **Senza il Diario non si casca e non si mente.** La barra vive nel
/// `builder` di `MaterialApp` e in molte prove sopra di lei non c'e' nessun
/// provider: in quel caso l'anello si disegna vuoto, che e' il vero, invece
/// di far cadere quaranta prove lontane da qui.
class AnelloDelLivello extends StatelessWidget {
  const AnelloDelLivello(
      {super.key, required this.misuraDelVolto, required this.child});

  /// Il diametro del volto attorno a cui l'anello gira.
  final double misuraDelVolto;

  final Widget child;

  /// Lo stacco fra il bordo del volto e l'anello.
  static const double stacco = 2;

  /// Lo spessore del tratto dell'anello.
  static const double spessore = 2.5;

  /// Il diametro esterno, che e' la misura che la barra deve contenere.
  static double diametroPer(double misuraDelVolto) =>
      misuraDelVolto + 2 * (stacco + spessore);

  /// **IL PROGRESSO, LETTO IN UN PUNTO SOLO E SENZA CASCARE.**
  static ({int accesi, int quanti}) progresso(BuildContext context) {
    try {
      return context.watch<DiarioDelCammino>().progressoDelCammino;
    } catch (errore) {
      // **NON E' UN CATCH MUTO, ed e' l\'unico esito possibile.** L\'unico
      // errore che questa lettura puo' sollevare e' il provider assente,
      // e in quel caso il progresso non e' ignoto: e' zero, perche' senza
      // Diario nessun Sigillo e' acceso. Propagarlo farebbe cadere la
      // barra sottile in ogni prova che non monta l\'app intera.
      assert(() {
        // ignore: avoid_print
        print('anello del livello senza Diario sopra di se: $errore');
        return true;
      }());
      return (accesi: 0, quanti: Sentieri.raggiungibili.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.forse(context) ?? MaestroPalette.medora;
    final p = progresso(context);
    final frazione = p.quanti == 0 ? 0.0 : p.accesi / p.quanti;
    final diametro = diametroPer(misuraDelVolto);
    return SizedBox(
      key: const Key('anello_del_livello'),
      width: diametro,
      height: diametro,
      child: CustomPaint(
        painter: _PitturaDellAnello(frazione: frazione, oro: palette.gold),
        child: Center(child: child),
      ),
    );
  }
}

class _PitturaDellAnello extends CustomPainter {
  const _PitturaDellAnello({required this.frazione, required this.oro});

  final double frazione;
  final Color oro;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final raggio = (size.shortestSide - AnelloDelLivello.spessore) / 2;
    // La traccia: sempre visibile, cosi' il posto dell'anello si vede anche
    // a zero e la persona capisce che c'e' qualcosa da riempire.
    canvas.drawCircle(
      centro,
      raggio,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = AnelloDelLivello.spessore
        ..color = oro.withValues(alpha: 0.20),
    );
    if (frazione <= 0) return;
    // Il riempimento parte in cima e gira in senso orario.
    canvas.drawArc(
      Rect.fromCircle(center: centro, radius: raggio),
      -math.pi / 2,
      2 * math.pi * frazione.clamp(0.0, 1.0),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = AnelloDelLivello.spessore
        ..color = oro,
    );
  }

  @override
  bool shouldRepaint(_PitturaDellAnello vecchia) =>
      vecchia.frazione != frazione || vecchia.oro != oro;
}

/// IL NUMERO ACCANTO AL VOLTO. Ordine CF voce 01.
///
/// **Testo provvisorio, e va dichiarato.** Il fondatore ha chiesto "il livello
/// di esperienza" accanto al volto: finche' il livello XP non esiste, qui c'e'
/// il numero dei Sigilli accesi, che e' lo STESSO numero che riempie
/// l'anello e non un secondo conto. I testi definitivi li approva lui.
class NumeroDelLivello extends StatelessWidget {
  const NumeroDelLivello({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.forse(context) ?? MaestroPalette.medora;
    final p = AnelloDelLivello.progresso(context);
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Text(
        '${p.accesi}',
        key: const Key('barra_numero_del_livello'),
        // **DICIOTTO E NON DODICI, e la ragione e' misurata.** Ordine CF
        // voce 01. Alla misura del pavimento l'oro del Maestro faceva 5,42
        // contro i 7,0 che la legge chiede a un testo piccolo, e il
        // censimento dei grigi lo ha visto subito. Le vie erano due:
        // schiarire l'oro fino a non essere piu' oro, oppure alzare il
        // numero. **Alzarlo e' la via giusta due volte**: sopra i diciotto
        // punti e mezzo la soglia diventa 4,5 e l'oro passa senza
        // cambiare colore, e la voce CF.10 dice che nel Cerchio si legge
        // troppo piccolo.
        style: TypographyTokens.titoloScheda().copyWith(color: palette.gold),
      ),
    );
  }
}

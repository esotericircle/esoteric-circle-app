import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../core/tarot/tarot_spread_type.dart';

/// **IL TAVOLO DELLA STESA, letto dal dato.** Ordine FK, aggiunta 2 voce A10,
/// 11 ottobre 2026.
///
/// Prima le carte stavano in una fila scritta nella schermata, tre `Expanded`
/// in una `Row`, mentre il dato che dice dove sta ogni carta,
/// `TarotSpreadType.tavolo`, era dichiarato per ogni stesa e nessuno lo
/// leggeva. **La regola va nel dato**: adesso la schermata stende quello che
/// la stesa dichiara, e una stesa nuova non chiede una riga di schermata.
///
/// **LE UNITA' DEL TAVOLO sono larghezze di carta**: fra due posti vicini c'e'
/// sempre 0,15 di vuoto, in orizzontale (1,15 di passo) e in verticale (1,65
/// di passo per una carta alta 1,5). In verticale un'unita' vale l'altezza
/// della cella diviso 1,5, cosi' anche l'etichetta sotto la carta trova il suo
/// posto senza che due celle si sovrappongano.
class TavoloDellaStesa extends StatelessWidget {
  const TavoloDellaStesa({
    super.key,
    required this.posti,
    required this.carta,
    required this.altezzaDellaCella,
    this.larghezzaMassima = larghezzaMassimaDellaCarta,
    this.altezzaMassima = double.infinity,
  });

  /// **IL TAVOLO SI VEDE TUTTO IN UNA SCHERMATA.** Visto nelle anteprime a
  /// 360 per 797 la sera del 12 ottobre 2026: la croce, alta tre celle e un
  /// terzo, metteva il consultante sotto la piega, e chi guarda la stesa non
  /// vedeva le quattro carte insieme. Oltre questa altezza le carte si
  /// rimpiccioliscono finche' il tavolo ci sta.
  final double altezzaMassima;

  final List<PostoSulTavolo> posti;

  /// La carta al posto [posto], larga [larghezza].
  final Widget Function(BuildContext context, int posto, double larghezza)
      carta;

  /// L'altezza di una cella (la carta con le sue scritte) per una carta larga
  /// quanto il parametro.
  final double Function(double larghezzaCarta) altezzaDellaCella;

  /// Oltre questa larghezza una carta non cresce: la carta sola non occupa
  /// lo schermo intero.
  final double larghezzaMassima;

  /// La larghezza massima di una carta sul tavolo, in punti logici: la carta
  /// sola resta poco piu' grande delle tre della stesa a tre carte.
  static const double larghezzaMassimaDellaCarta = 150;

  /// **LA DISPOSIZIONE**, calcolata e non dipinta: la usano la schermata, il
  /// filo fra le carte e la prova che nessuna carta esca dallo schermo.
  static ({double larghezza, double altezza, List<Offset> angoli, Size misura})
      disponi(
    List<PostoSulTavolo> posti,
    double larghezzaDisponibile,
    double Function(double larghezzaCarta) altezzaDellaCella, {
    double larghezzaMassima = larghezzaMassimaDellaCarta,
    double altezzaMassima = double.infinity,
  }) {
    var minX = double.infinity, maxX = -double.infinity;
    var minY = double.infinity, maxY = -double.infinity;
    for (final p in posti) {
      minX = math.min(minX, p.x);
      maxX = math.max(maxX, p.x);
      minY = math.min(minY, p.y);
      maxY = math.max(maxY, p.y);
    }
    final campata = maxX - minX + 1;
    final righe = (maxY - minY) / 1.5 + 1;
    var larghezza = math.min(larghezzaDisponibile / campata, larghezzaMassima);
    var altezza = altezzaDellaCella(larghezza);
    // Le scritte non scalano con la carta: si stringe per passi, finche' il
    // tavolo intero sta sotto l'altezza massima.
    for (var passo = 0;
        passo < 8 && righe * altezza > altezzaMassima && larghezza > 56;
        passo++) {
      larghezza = math.max(56, larghezza * altezzaMassima / (righe * altezza));
      altezza = altezzaDellaCella(larghezza);
    }
    final passoVerticale = altezza / 1.5;
    final scarto = (larghezzaDisponibile - campata * larghezza) / 2;
    return (
      larghezza: larghezza,
      altezza: altezza,
      angoli: [
        for (final p in posti)
          Offset(
              scarto + (p.x - minX) * larghezza, (p.y - minY) * passoVerticale),
      ],
      misura:
          Size(larghezzaDisponibile, (maxY - minY) * passoVerticale + altezza),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, vincoli) {
      final d = disponi(posti, vincoli.maxWidth, altezzaDellaCella,
          larghezzaMassima: larghezzaMassima, altezzaMassima: altezzaMassima);
      return SizedBox(
        width: d.misura.width,
        height: d.misura.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < posti.length; i++)
              Positioned(
                key: ValueKey('tavolo_posto_$i'),
                left: d.angoli[i].dx,
                top: d.angoli[i].dy,
                width: d.larghezza,
                // Di traverso, come la seconda carta della Croce Celtica.
                child: posti[i].diTraverso
                    ? Transform.rotate(
                        angle: math.pi / 2,
                        child: carta(context, i, d.larghezza))
                    : carta(context, i, d.larghezza),
              ),
          ],
        ),
      );
    });
  }
}

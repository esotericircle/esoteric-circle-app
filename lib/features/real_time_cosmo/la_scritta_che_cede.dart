/// LA SCRITTA DELL'INDICATORE CEDE IL POSTO. Ordine FH voce 14.1 (lavorata
/// nella parte 5, portata qui perche' una prova la possa misurare).
///
/// Quando la scritta dell'indicatore copre il nome di un pianeta, o il disco
/// della Luna, la precedenza e' loro: la scritta si sposta sopra o sotto
/// l'ostacolo, dalla parte dove c'e' piu' posto, restando fra la testata
/// ([kMargineAlto]) e il pie' di pagina ([kMargineBasso]). Tre giri al piu':
/// spostandosi la scritta puo' finire su un altro nome.
library;

import 'dart:ui';

/// Il posto riservato alla testata e al pie' di pagina.
const double kMargineAlto = 80;
const double kMargineBasso = 120;

/// L'altezza della scritta larga [w] e alta [h], messa a [left] e [top] in
/// uno schermo alto [altezza], dopo aver ceduto il posto agli [ostacoli]
/// (uno per indice, nessuno dove non c'e').
double altezzaCheCede({
  required double left,
  required double top,
  required double w,
  required double h,
  required double altezza,
  required int ostacoli,
  required Rect? Function(int) ostacolo,
  double margineAlto = kMargineAlto,
  double margineBasso = kMargineBasso,
}) {
  var t = top;
  for (var giro = 0; giro < 3; giro++) {
    final scatola = Rect.fromLTWH(left, t, w, h);
    Rect? coperto;
    for (var i = 0; i < ostacoli; i++) {
      final r = ostacolo(i);
      if (r != null && r.overlaps(scatola)) {
        coperto = r;
        break;
      }
    }
    if (coperto == null) break;
    // Sopra o sotto l'ostacolo, dalla parte dove c'e' piu' posto.
    final suPosto = coperto.top - margineAlto;
    final giuPosto = altezza - margineBasso - coperto.bottom;
    t = suPosto > giuPosto
        ? (coperto.top - h - 6).clamp(margineAlto, altezza - margineBasso - h)
        : (coperto.bottom + 6).clamp(margineAlto, altezza - margineBasso - h);
  }
  return t;
}

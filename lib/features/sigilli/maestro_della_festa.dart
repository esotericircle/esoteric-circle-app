import '../../core/maestro/maestro.dart';
import '../../core/sigilli/sentieri.dart';
import '../../core/sigilli/traguardo.dart';

/// DI CHI E' LA FESTA, quando i traguardi celebrati sono piu' di uno.
///
/// **La regola, che viene dall'ordine AO voce 05 e sopravvive alla
/// demolizione**: e' del traguardo PIU' IMPORTANTE, cioe' del primo grande se
/// ce n'e' uno, e a parita' del primo nominato. Prima viveva in
/// `direzione_della_festa.dart` insieme alle particelle; quel file muore con
/// l'ordine AT voce 03, ma questa risposta serve ancora, perche' decide QUALE
/// transizione parte e di che colore e' la scena.
class MaestroDellaFesta {
  const MaestroDellaFesta._();

  static Maestro di(List<Traguardo> traguardi, List<Sentiero> sentieri) {
    if (sentieri.isEmpty) return Maestro.medora;
    for (var i = 0; i < traguardi.length && i < sentieri.length; i++) {
      if (traguardi[i].eGrande) return sentieri[i].maestro;
    }
    return sentieri.first.maestro;
  }
}

// **PERCHE' QUESTA CLASSE E' SOPRAVVISSUTA A DUE DEMOLIZIONI.** Ordine AV voce
// 01. Viveva in `direzione_della_festa.dart` con le particelle, morte
// nell'ordine AT; e poi in `transizione_di_stelle.dart` col lettore di WebP,
// morto qui. La risposta che da' pero' serve ancora: **di chi e' la festa
// quando i traguardi celebrati sono piu' di uno**, e da lei viene il colore
// della scena. Adesso ha una casa sua, e la prossima demolizione non la
// trovera' in mezzo.
//
// **Cio' che NON decide piu' e' l'animazione**: la spirale e' una sola e
// uguale per tutti e tre i Maestri, decisione del fondatore del 22 agosto 2026.

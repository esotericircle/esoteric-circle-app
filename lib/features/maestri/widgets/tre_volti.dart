import 'package:flutter/material.dart';

import '../../../core/maestro/maestro.dart';
import 'maestro_bust.dart';

/// I TRE VOLTI DEL CERCHIO, sovrapposti: il segno che dice PIU' VOCI.
///
/// **Perche' esiste.** Al suo posto c'era un'icona a bilancia, e il fondatore
/// ci ha letto il segno della Bilancia. Il significato di un simbolo non lo
/// decide il contesto nella testa di chi disegna, lo decide l'occhio di chi
/// guarda, e su una superficie che parla di lettura astrologica il rischio e'
/// piu' alto, non piu' basso.
///
/// **Nessuna arte nuova.** Sono i tre mezzi busti che l'app usa gia' ovunque,
/// nella stessa forma tonda, messi in fila con una sovrapposizione: il segno
/// piu' antico che esista per dire "sono in piu' di uno" senza prendere in
/// prestito un simbolo che appartiene a qualcun altro.
class TreVolti extends StatelessWidget {
  const TreVolti({super.key, this.misura = 26});

  /// Il diametro di ogni volto.
  final double misura;

  /// Quanto ogni volto copre il precedente, in frazione del diametro.
  ///
  /// Un terzo: abbastanza da leggersi come un gruppo, poco abbastanza da
  /// riconoscere i tre. Sovrapposti di meta' diventano una macchia sola.
  static const double sovrapposizione = 1 / 3;

  @override
  Widget build(BuildContext context) {
    // Nell'ordine fisso del cerchio, lo stesso di ogni altra superficie: i tre
    // non si presentano in un ordine diverso a seconda di dove li incontri.
    const volti = Maestro.fixedOrder;
    final passo = misura * (1 - sovrapposizione);
    return SizedBox(
      width: passo * (volti.length - 1) + misura,
      height: misura,
      child: Stack(
        children: [
          for (var i = 0; i < volti.length; i++)
            Positioned(
              left: passo * i,
              child: MaestroBust(
                maestro: volti[i],
                ring: misura,
                popOut: false,
              ),
            ),
        ],
      ),
    );
  }
}

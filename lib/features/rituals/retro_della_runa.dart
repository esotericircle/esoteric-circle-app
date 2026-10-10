/// IL RETRO VERGINE DI UNA RUNA, UNA PORTA SOLA.
///
/// **Perche' esiste questo file.** Una runa coperta si mostrava in TRE modi
/// diversi: il sacchetto dell'Estrazione usava i retri veri, la Runa del
/// Tramonto pure ma con la propria copia del codice, e le pietre coperte sul
/// telo mostravano LA MINIATURA DEL FRONTE a opacita' 0,35, cioe' il fronte
/// velato: peggio di uno slot, perche' anticipava la runa che la persona
/// doveva ancora scoprire. Visto da Mauro sul telefono, ordine del 7 agosto
/// 2026. Tre porte per la stessa cosa sono due di troppo: adesso chiunque
/// mostri una runa coperta passa da qui, e una prova enumera i punti e cade
/// se uno fa da se'.
///
/// **Il retro e' quello della SUA pietra.** Non c'e' un dorso unico: ogni
/// runa ha il proprio osso, con la sua forma e la sua venatura. Un retro non
/// dice quale runa sia, ed e' esattamente il motivo per cui e' il solo volto
/// giusto di una runa coperta.
library;

import 'package:flutter/material.dart';

/// Il percorso della pietra vergine, cioe' l'osso senza segno, a partire dallo
/// stem della runa. Gli stem di `kElderFuthark` finiscono gia' in `_v1`, quindi
/// il suffisso di versione va tolto prima di riapplicarlo: senza questo il nome
/// uscirebbe con due versioni in coda e non troverebbe mai il file.
/// Null quando la runa non ha arte.
String? pathVergineDi(String? stem) {
  if (stem == null) return null;
  final base = stem.endsWith('_v1') ? stem.substring(0, stem.length - 3) : stem;
  return 'assets/img/rune_bone_vergine/${base}_vergine_v1.webp';
}

/// Il retro vergine, come widget: l'osso della runa, senza segno.
///
/// Il [ripiego] e' il volto quando l'asset manca: ogni superficie dichiara il
/// suo, la Runa del Tramonto ha il velo che respira, l'Estrazione il sasso
/// dipinto. Se nessuno lo passa, vale il sasso neutro qui sotto: mai un vuoto
/// al posto di una pietra, che si leggerebbe come un guasto.
class RetroDellaRuna extends StatelessWidget {
  const RetroDellaRuna({
    super.key,
    required this.stem,
    this.width,
    this.height,
    this.ripiego,
  });

  /// Lo stem della runa, da [Rune.stem]. Null se la runa non ha arte.
  final String? stem;

  final double? width;
  final double? height;

  /// Il volto quando l'asset manca, dichiarato dalla superficie che chiama.
  final WidgetBuilder? ripiego;

  @override
  Widget build(BuildContext context) {
    final percorso = pathVergineDi(stem);
    Widget faiRipiego(BuildContext c) => ripiego?.call(c) ?? _sassoDipinto();
    return SizedBox(
      width: width,
      height: height,
      child: percorso == null
          ? faiRipiego(context)
          : Image.asset(percorso,
              fit: BoxFit.contain, errorBuilder: (c, _, __) => faiRipiego(c)),
    );
  }

  /// Il ripiego di default: un sasso d'osso dipinto, neutro.
  Widget _sassoDipinto() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const RadialGradient(colors: [
            Color(0xFFE8DFC9),
            Color(0xFFCFC3A6),
          ]),
          border: Border.all(color: const Color(0x40C9A961)),
        ),
      );
}

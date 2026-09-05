import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/identity/natal_identity.dart';
import '../../core/maestro/consiglio_finale.dart';
import '../../core/maestro/maestro.dart';
import '../../core/rituals/sunset_rune.dart';
import '../theme/maestro_palette.dart';
import '../theme/maestro_scope.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';

/// LA RIGA DEL CONSIGLIO: la stella e una riga sola, in oro.
///
/// **Vive nel design system e non dentro la chat perche' le superfici sono
/// DUE**, la bolla della conversazione e le tre carte del Consiglio del
/// Cerchio, ed e' esattamente la ragione per cui la scena dell'attesa vive
/// qui accanto: due copie della stessa riga divergono al primo ritocco.
///
/// **La stella e non la freccia.** La freccia promette un altrove, la stella
/// dichiara un dono. Quella che stava qui prima non era nemmeno toccabile:
/// dentro la carta del Consiglio, risalendo gli antenati per rientro, non
/// c'era nessun gesto. Era decorazione travestita da comando, e una
/// decorazione che somiglia a un comando e' peggio di nessun comando.
///
/// **E' sempre l'ULTIMA cosa della bolla**, anche dopo che il seguito e' stato
/// rivelato: chi la mette in pagina la mette in fondo, e il testo che la
/// precede e' gia' stato privato della sua riga da [ConsiglioFinale.corpoDa].
class RigaDelConsiglio extends StatelessWidget {
  const RigaDelConsiglio({
    super.key,
    required this.maestro,
    required this.testo,
    required this.quando,
    this.palette,
  });

  /// Chi ha parlato. Decide a cosa e' agganciato l'invito a tornare.
  final Maestro maestro;

  /// Il testo INTERO consegnato dal Maestro, con la sua riga marcata dentro.
  /// La composizione sta in [ConsiglioFinale]: qui non si taglia niente.
  final String testo;

  /// Il giorno da cui si guarda. L'invito parla del giorno dopo.
  final DateTime quando;

  /// La palette da usare. Nulla vuol dire quella dello scope, che in chat e'
  /// gia' quella del Maestro che parla.
  final MaestroPalette? palette;

  @override
  Widget build(BuildContext context) {
    final tinta = palette ?? context.palette;
    // L'IDENTITA' PER LA RUNA DELLA SERA, dalla stessa fonte del rituale.
    //
    // La runa del tramonto e' gia' deterministica per persona e per giorno, e
    // qui non se ne ripesca una seconda: si chiede la stessa chiave che usa la
    // schermata del rituale, cosi' l'invito di Caligo nomina la runa che la
    // persona trovera' davvero domani sera.
    final nascita = context.watch<BirthIdentityController>();
    final identita = SunsetRune.identitaPer(
      nascita: nascita.details?.date,
      oraNota: nascita.details?.time != null,
      deviceId: 'cerchio',
    );
    final riga = ConsiglioFinale.componi(
      maestro,
      testo: testo,
      quando: quando,
      identita: identita,
      segno: nascita.sunSign,
    );
    if (riga.isEmpty) return const SizedBox.shrink();

    return Padding(
      key: Key('consiglio_${maestro.id}'),
      padding: const EdgeInsets.only(top: SpacingTokens.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LA STELLA E' UN'ICONA, non il carattere del marcatore.
          //
          // Il carattere U+2726 non sta nel font del progetto, e nell'anteprima
          // a 360 per 797 usciva come un quadratino vuoto: un glifo che il font
          // non conosce diventa una scatola, ed e' esattamente il genere di
          // difetto che si vede solo guardando l'immagine.
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.auto_awesome, size: 13, color: tinta.goldSoft),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              riga,
              style: TypographyTokens.corpo().copyWith(
                color: tinta.goldSoft,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

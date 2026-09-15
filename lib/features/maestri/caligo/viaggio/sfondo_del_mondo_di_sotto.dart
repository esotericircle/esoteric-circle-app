import 'package:flutter/material.dart';

import 'il_bosco_della_soglia.dart';

/// **LO SLOT DEL MONDO DI SOTTO: prima l'immagine vera, poi il dipinto.**
/// Ordine DC voce 21, 10 settembre 2026.
///
/// **DA DOVE NASCE.** Il fondatore, guardando la soglia: *"la mia idea e'
/// sostituire le immagini vettoriali procedurali che fanno schifo con quelle
/// piu' realistiche create da Nano Banana"*.
///
/// **QUESTO E' IL POSTO DOVE ENTRERANNO, e non serve toccare nient'altro.**
/// La schermata chiede uno sfondo a questo componente e non sa come sia
/// fatto: finche' il file non c'e', dipinge; il giorno che arriva, lo mostra.
/// **Nessuna misura, nessun riquadro e nessuna guardia cambiano**, perche' lo
/// slot ha la stessa forma nei due casi.
///
/// **E' lo stesso mestiere di `RitualBackdrop`**, che dall'ordine dei rituali
/// fa esattamente questo col fondale del cielo: un PNG quando c'e', il fondo
/// procedurale quando manca. Qui il ripiego non e' un fondo generico, e' la
/// scena giusta dipinta a mano, quindi **l'app non e' mai brutta in attesa di
/// un asset**.
///
/// **I FILE CHE QUESTO SLOT ASPETTA** stanno elencati in
/// `docs/ordini/DC_asset_da_generare.md`, con la forma, il rapporto e il
/// perche' di ognuno.
class SfondoDelMondoDiSotto extends StatelessWidget {
  const SfondoDelMondoDiSotto({super.key, this.quale = SfondoDelViaggio.bosco});

  final SfondoDelViaggio quale;

  @override
  Widget build(BuildContext context) => Image.asset(
        quale.percorso,
        fit: BoxFit.cover,
        // **IL RIPIEGO DIPINGE LA STESSA SCENA.** Un asset che manca non
        // lascia un buco e non lascia un fondo generico: lascia il bosco.
        errorBuilder: (context, error, stack) => CustomPaint(
          key: Key('sfondo_dipinto_${quale.name}'),
          size: Size.infinite,
          painter: PittoreDelBosco(),
        ),
      );
}

/// **GLI SFONDI CHE IL VIAGGIO PUO' AVERE**, col percorso che aspettano.
///
/// I nomi sono quelli con cui i file vanno consegnati. Chi genera l'immagine
/// non deve leggere il codice: legge questo elenco.
enum SfondoDelViaggio {
  /// La soglia: il bosco al crepuscolo con l'apertura nella terra in mezzo.
  bosco('assets/img/mondo_di_sotto/soglia_bosco_v1.webp'),

  /// Il fondo della galleria, dove la nebbia si apre.
  fondo('assets/img/mondo_di_sotto/fondo_nebbia_v1.webp');

  const SfondoDelViaggio(this.percorso);

  /// Il percorso dell'asset, che e' anche il nome del file da consegnare.
  final String percorso;
}

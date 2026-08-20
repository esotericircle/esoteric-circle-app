import 'package:flutter/material.dart';

/// UN TITOLO NON SI SPEZZA IN MEZZO A UNA PAROLA. Ordine AS voce 05.
///
/// **Il difetto, visto sull'anteprima e da nessuna prova.** Nella celebrazione
/// il nome "La Costellazione nascente" a corpo 34 usciva cosi':
/// `LA COSTELLAZI` a capo `ONE NASCENTE`. Non e' un caso limite del corpus: e'
/// cio' che Flutter fa quando una parola SINGOLA e' piu' larga della riga, cioe'
/// la taglia dove capita. Nessuna prova poteva accorgersene, perche' il testo
/// c'e' tutto e il widget e' nell'albero: si vede solo guardando.
///
/// **La cura: il corpo si adatta alla parola piu' lunga.** Si misura la parola
/// piu' larga col `TextPainter`, che e' lo stesso motore che poi disegna, e si
/// scende di corpo finche' ci sta, fino a un minimo dichiarato. Sotto quel
/// minimo si preferisce spezzare che rendere illeggibile: e' una scelta, ed e'
/// scritta qui.
///
/// **Perche' non un `FittedBox`.** Quello scala tutto il blocco, comprese le
/// righe corte, e su due righe di lunghezza diversa produce due corpi diversi
/// dentro lo stesso titolo. Qui il corpo resta uno solo per tutto il titolo.
class TitoloCheNonSiSpezza extends StatelessWidget {
  const TitoloCheNonSiSpezza(
    this.testo, {
    super.key,
    required this.stile,
    this.allineamento = TextAlign.center,
    this.minimo = 20,
  });

  final String testo;
  final TextStyle stile;
  final TextAlign allineamento;

  /// Sotto questo corpo non si scende: un titolo illeggibile e' peggio di un
  /// titolo spezzato.
  final double minimo;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, vincoli) {
        final larghezza = vincoli.maxWidth;
        final partenza = stile.fontSize ?? 34;
        var corpo = partenza;
        if (larghezza.isFinite && larghezza > 0) {
          // La parola piu' lunga: e' lei che decide, perche' e' l'unica che
          // non si puo' mandare a capo.
          final parole = testo.split(RegExp(r'\s+'));
          var piuLarga = 0.0;
          for (final parola in parole) {
            final pittore = TextPainter(
              text: TextSpan(text: parola, style: stile),
              textDirection: TextDirection.ltr,
              maxLines: 1,
            )..layout();
            if (pittore.width > piuLarga) piuLarga = pittore.width;
          }
          if (piuLarga > larghezza && piuLarga > 0) {
            corpo = (partenza * larghezza / piuLarga).floorToDouble();
            if (corpo < minimo) corpo = minimo;
          }
        }
        return Text(
          testo,
          textAlign: allineamento,
          style: corpo == partenza ? stile : stile.copyWith(fontSize: corpo),
        );
      },
    );
  }
}

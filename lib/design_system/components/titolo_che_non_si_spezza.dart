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

  /// **IL CORPO PIU' GRANDE CON CUI IL TESTO ENTRA SU UNA RIGA.** Ordine AU
  /// voce 07.
  ///
  /// **Perche' e' iterativo e non una proporzione.** La prima stesura
  /// calcolava `partenza * larghezza / larghezzaDellaParola`, cioe' dava per
  /// scontato che dimezzando il corpo si dimezzi la larghezza. Non e' vero
  /// quando lo stile porta una spaziatura fra le lettere: quella e' un numero
  /// ASSOLUTO e non scala col corpo, quindi su "CONGRATULAZIONI", che ha
  /// sedici lettere e 1,6 punti di spaziatura, restano venticinque punti
  /// fissi che il conto non vede. Misurato: su uno schermo da 320 punti la
  /// proporzione dava 24 e la parola andava a capo lo stesso.
  ///
  /// Adesso si misura, e se non entra si scende di un punto e si rimisura.
  /// Sono al piu' una quindicina di misure su una stringa corta, una volta per
  /// costruzione.
  static double corpoCheEntra(
    String testo,
    TextStyle stile,
    double larghezza, {
    double minimo = 20,
  }) {
    final partenza = stile.fontSize ?? 34;
    if (!larghezza.isFinite || larghezza <= 0) return partenza;
    // La parola piu' lunga: e' lei che decide, perche' e' l'unica che non si
    // puo' mandare a capo.
    final parole = testo.split(RegExp(r'\s+'));
    for (var corpo = partenza; corpo > minimo; corpo -= 1) {
      var entra = true;
      for (final parola in parole) {
        final pittore = TextPainter(
          text: TextSpan(text: parola, style: stile.copyWith(fontSize: corpo)),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();
        if (pittore.width > larghezza) {
          entra = false;
          break;
        }
      }
      if (entra) return corpo;
    }
    // Sotto il minimo non si scende: un titolo illeggibile e' peggio di un
    // titolo spezzato.
    return minimo;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, vincoli) {
        final corpo =
            corpoCheEntra(testo, stile, vincoli.maxWidth, minimo: minimo);
        return Text(
          testo,
          textAlign: allineamento,
          style: corpo == (stile.fontSize ?? 34)
              ? stile
              : stile.copyWith(fontSize: corpo),
        );
      },
    );
  }
}

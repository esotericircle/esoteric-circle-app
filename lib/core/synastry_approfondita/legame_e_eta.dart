/// **I QUATTRO LEGAMI DELLA SINASTRIA APPROFONDITA.** Ordine FT voce FT.06:
/// amore, amicizia, famiglia, lavoro. Il legame cambia la lettura, non il
/// calcolo (lo stesso cielo, le stesse longitudini, le stesse undici
/// posizioni: vedi `cielo_approfondito.dart`).
enum Legame {
  amore('Amore'),
  amicizia('Amicizia'),
  famiglia('Famiglia'),
  lavoro('Lavoro');

  const Legame(this.nome);
  final String nome;
}

/// **LO SBARRAMENTO DI ETA' SUL LEGAME AMORE.** Ordine FT voce FT.04, 14
/// ottobre 2026.
///
/// Il fondatore: *"l'amore dai 16 anni in su"*. Il legame amore si apre solo
/// se ENTRAMBE le persone hanno almeno sedici anni compiuti al giorno della
/// lettura; amicizia, famiglia e lavoro non hanno limite. **Il controllo
/// vive due volte**: qui (`lib`) e sul server
/// (`functions/src/sinastria_approfondita.ts`, `haAlmeno16Anni`): il server
/// non si fida dell'app, perche' un client modificato potrebbe dire
/// un'altra data di nascita.
abstract final class SbarramentoDEta {
  const SbarramentoDEta._();

  /// Sedici anni, non un giorno di meno: compiuti vuol dire che il
  /// compleanno dei sedici e' gia' passato (o cade oggi) alla data [adesso].
  static const int etaMinimaPerLAmore = 16;

  /// Quanti anni compiuti ha chi e' nato il [nascita], al giorno [adesso].
  /// Lo stesso calcolo in entrambi i lati: non "sottrai l'anno", perche'
  /// nato il 29 febbraio di un anno bisestile, controllato un anno non
  /// bisestile, il compleanno cade il 1 marzo (giorno dopo il 28 febbraio),
  /// non il 28: qui si confronta mese e giorno, e basta.
  static int anniCompiuti(DateTime nascita, DateTime adesso) {
    var anni = adesso.year - nascita.year;
    final compleannoGiaPassato = (adesso.month > nascita.month) ||
        (adesso.month == nascita.month && adesso.day >= nascita.day);
    if (!compleannoGiaPassato) anni--;
    return anni;
  }

  /// Vero se [nascita] ha compiuto almeno [etaMinimaPerLAmore] anni al
  /// giorno [adesso] (oggi, se omesso).
  static bool haAlmeno16Anni(DateTime nascita, {DateTime? adesso}) =>
      anniCompiuti(nascita, adesso ?? DateTime.now()) >= etaMinimaPerLAmore;

  /// Vero se il [legame] si puo' aprire fra due persone nate [nascitaTua] e
  /// [nascitaSua]. Solo il legame amore ha un limite: gli altri tre sono
  /// sempre aperti, qualunque sia l'eta'.
  static bool legameApribile(
    Legame legame,
    DateTime nascitaTua,
    DateTime nascitaSua, {
    DateTime? adesso,
  }) {
    if (legame != Legame.amore) return true;
    final ora = adesso ?? DateTime.now();
    return haAlmeno16Anni(nascitaTua, adesso: ora) &&
        haAlmeno16Anni(nascitaSua, adesso: ora);
  }
}

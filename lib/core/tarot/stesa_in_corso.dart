import 'tarot_card.dart';
import 'tarot_spread.dart';

/// LA STESA IN CORSO: la legge del dominio dei tarocchi, ordine P voce 04.
///
/// **UNA CARTA, UNA VOLTA ASSEGNATA A UNA POSIZIONE, E' IMMUTABILE FINO ALLA
/// CHIUSURA DELLA STESA. Mischia e taglio operano SOLTANTO sulle carte non
/// ancora estratte.**
///
/// **Il difetto che questa classe chiude, e la sua causa vera.** Negli scatti
/// delle 03:13 e delle 03:14 la posizione PASSATO mostrava prima La Papessa e
/// poi, dopo una mischia, Re di Coppe rovesciato: la carta che la persona
/// aveva scelto era stata riestratta. La causa non era grafica. La stesa non
/// esisteva come dato: era una FUNZIONE del mazzo, `TarotSpread.dalMazzo`, che
/// prende sempre le prime tre carte dell'ordine corrente. Mescolando il mazzo
/// cambiavano le prime tre, quindi cambiava la stesa. E' la causa (a)
/// dell'ordine nella sua forma piu' radicale: le carte gia' uscite non erano
/// mai state salvate, quindi non potevano restare.
///
/// **Perche' e' il difetto piu' grave possibile in questa app.** Se la carta
/// cambia, la persona capisce che il responso non dipende da lei. Una stesa e'
/// una stesa perche' la carta uscita e' QUELLA, e perche' l'ha scelta lei.
class StesaInCorso {
  const StesaInCorso._({
    required this.assegnate,
    required this.mazzoResiduo,
    required this.seme,
  });

  /// Una stesa che comincia: nessuna carta assegnata, il mazzo intero da
  /// pescare.
  factory StesaInCorso.nuova({required List<int> mazzo, int seme = 0}) =>
      StesaInCorso._(
        assegnate: List<DrawnCard?>.filled(SpreadPosition.values.length, null),
        mazzoResiduo: List<int>.unmodifiable(mazzo),
        seme: seme,
      );

  /// Le carte assegnate alle posizioni, nell'ordine di `SpreadPosition`.
  /// Nulla dove la posizione e' ancora vuota.
  final List<DrawnCard?> assegnate;

  /// LE CARTE NON ANCORA ESTRATTE, e sono le sole che mischia e taglio
  /// toccano. Il mazzo residuo si rimescola, la stesa no.
  final List<int> mazzoResiduo;

  final int seme;

  /// Quante posizioni sono gia' state scelte.
  int get quanteAssegnate => assegnate.where((c) => c != null).length;

  bool get eCompleta => quanteAssegnate == SpreadPosition.values.length;

  /// La stesa finita, quando tutte le posizioni sono piene.
  TarotSpread? get stesaCompiuta => eCompleta
      ? TarotSpread([for (final c in assegnate) c!])
      : null;

  /// ASSEGNA la prossima carta del mazzo residuo alla posizione data.
  ///
  /// La carta esce dal residuo ed entra nella stesa: da quel momento nessun
  /// gesto la puo' piu' toccare. Se la posizione e' gia' piena non succede
  /// niente, perche' riassegnarla sarebbe esattamente il difetto.
  StesaInCorso assegna(SpreadPosition posizione, {int? daIndice}) {
    final i = SpreadPosition.values.indexOf(posizione);
    if (assegnate[i] != null || mazzoResiduo.isEmpty) return this;
    final quale = daIndice != null && daIndice >= 0 &&
            daIndice < mazzoResiduo.length
        ? daIndice
        : 0;
    final indiceCarta = mazzoResiduo[quale];
    final nuove = List<DrawnCard?>.of(assegnate);
    nuove[i] = DrawnCard(
      card: TarotDeck.cards[indiceCarta],
      position: posizione,
      // IL VERSO NASCE COL SEME E COLLA CARTA, non col momento: cosi' la
      // stessa carta pescata due volte nella stessa stesa non cambia verso
      // fra una ricostruzione e l'altra della schermata.
      reversed: TarotSpread.versoDi(indiceCarta, seme),
    );
    final residuo = List<int>.of(mazzoResiduo)..removeAt(quale);
    return StesaInCorso._(
      assegnate: nuove,
      mazzoResiduo: List<int>.unmodifiable(residuo),
      seme: seme,
    );
  }

  /// MISCHIA il solo mazzo residuo. Le carte assegnate non si toccano.
  StesaInCorso mischia({int? seme}) => StesaInCorso._(
        assegnate: assegnate,
        mazzoResiduo: List<int>.unmodifiable(
          List<int>.of(mazzoResiduo)..shuffle(TarotSpread.casoCon(seme)),
        ),
        seme: this.seme,
      );

  /// TAGLIA il solo mazzo residuo: la meta' sotto sale sopra, come nel gesto
  /// vero. Un taglio non mescola niente, cambia solo da dove si comincia.
  StesaInCorso taglia(int punto) {
    if (mazzoResiduo.length < 2) return this;
    return StesaInCorso._(
      assegnate: assegnate,
      mazzoResiduo:
          List<int>.unmodifiable(TarotSpread.taglia(mazzoResiduo, punto)),
      seme: seme,
    );
  }
}

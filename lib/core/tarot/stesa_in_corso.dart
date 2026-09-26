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
/// **LA POSIZIONE NEL VENTAGLIO E' LA CARTA, ordine BN voce 02.** Parole del
/// fondatore: "quando l'utente fa click su una carta, deve essere quella
/// carta ad essere estratta, quella corrispondente a dove il dito ha fatto
/// tap".
///
/// Il difetto misurato: il ventaglio mostra **settantotto posizioni fisse** e
/// passava l'indice della posizione toccata come indice del MAZZO RESIDUO,
/// che e' un'altra lista e si accorcia a ogni carta. Tre conseguenze, tutte
/// vere insieme: dopo la prima presa gli indici slittano di uno; dopo una
/// mischia o un taglio il residuo si riordina mentre le posizioni restano
/// ferme, quindi sotto il dito c'e' un'altra carta senza che niente lo
/// mostri; e toccando una posizione oltre la lunghezza del residuo il codice
/// **ripiegava su zero**, cioe' dava la prima carta del mazzo a chi ne aveva
/// toccata un'altra.
///
/// La cura non e' aggiustare la traduzione fra i due indici: e' non avere due
/// indici. Il mazzo si tiene DISPOSTO, cioe' si sa quale carta sta sotto ogni
/// posizione del ventaglio, e chi assegna passa la posizione toccata. Mischia
/// e taglio riordinano le carte SOTTO le posizioni ancora libere, che e'
/// esattamente cio' che quei due gesti promettono a chi li guarda.
class StesaInCorso {
  const StesaInCorso._({
    required this.assegnate,
    required this.mazzoDisposto,
    required this.seme,
  });

  /// Una stesa che comincia: nessuna carta assegnata, il mazzo intero da
  /// pescare.
  factory StesaInCorso.nuova({required List<int> mazzo, int seme = 0}) =>
      StesaInCorso._(
        assegnate: List<DrawnCard?>.filled(SpreadPosition.values.length, null),
        mazzoDisposto: List<int?>.unmodifiable(mazzo),
        seme: seme,
      );

  /// Le carte assegnate alle posizioni, nell'ordine di `SpreadPosition`.
  /// Nulla dove la posizione e' ancora vuota.
  final List<DrawnCard?> assegnate;

  /// IL MAZZO COM'E' DISPOSTO SOTTO IL VENTAGLIO: una voce per ogni posizione
  /// dell'arco, con l'indice della carta che ci sta sotto, e **nulla** dove la
  /// carta e' gia' stata presa. La lunghezza non cambia mai: sono le posizioni
  /// del ventaglio, e il ventaglio non si accorcia mentre lo si sfoglia.
  final List<int?> mazzoDisposto;

  /// LE CARTE NON ANCORA ESTRATTE, e sono le sole che mischia e taglio
  /// toccano. Il mazzo residuo si rimescola, la stesa no.
  ///
  /// E' una VISTA di [mazzoDisposto], non un secondo dato: due liste da tenere
  /// d'accordo sarebbero la famiglia di difetto che questa classe esiste per
  /// chiudere.
  List<int> get mazzoResiduo => [
        for (final c in mazzoDisposto)
          if (c != null) c
      ];

  final int seme;

  /// Quante posizioni sono gia' state scelte.
  int get quanteAssegnate => assegnate.where((c) => c != null).length;

  bool get eCompleta => quanteAssegnate == SpreadPosition.values.length;

  /// La stesa finita, quando tutte le posizioni sono piene.
  TarotSpread? get stesaCompiuta =>
      eCompleta ? TarotSpread([for (final c in assegnate) c!]) : null;

  /// ASSEGNA la prossima carta del mazzo residuo alla posizione data.
  ///
  /// La carta esce dal residuo ed entra nella stesa: da quel momento nessun
  /// gesto la puo' piu' toccare. Se la posizione e' gia' piena non succede
  /// niente, perche' riassegnarla sarebbe esattamente il difetto.
  /// [dalVentaglio] e' la posizione TOCCATA nell'arco, e la carta e' quella
  /// che ci sta sotto. Se quella posizione e' gia' stata presa, o non esiste,
  /// **non si assegna niente**: prima si ripiegava sulla prima carta del
  /// mazzo, cioe' si dava a chi aveva toccato una posizione una carta che non
  /// aveva scelto. Un gesto senza risposta e' meglio di una risposta falsa.
  StesaInCorso assegna(SpreadPosition posizione, {required int dalVentaglio}) {
    final i = SpreadPosition.values.indexOf(posizione);
    if (assegnate[i] != null) return this;
    if (dalVentaglio < 0 || dalVentaglio >= mazzoDisposto.length) return this;
    final indiceCarta = mazzoDisposto[dalVentaglio];
    if (indiceCarta == null) return this;
    final nuove = List<DrawnCard?>.of(assegnate);
    nuove[i] = DrawnCard(
      card: TarotDeck.cards[indiceCarta],
      position: posizione,
      // IL VERSO NASCE COL SEME E COLLA CARTA, non col momento: cosi' la
      // stessa carta pescata due volte nella stessa stesa non cambia verso
      // fra una ricostruzione e l'altra della schermata.
      reversed: TarotSpread.versoDi(indiceCarta, seme),
    );
    // La posizione resta nell'arco e diventa VUOTA: il ventaglio continua a
    // mostrarla come presa, e nessun indice slitta.
    final disposto = List<int?>.of(mazzoDisposto)..[dalVentaglio] = null;
    return StesaInCorso._(
      assegnate: nuove,
      mazzoDisposto: List<int?>.unmodifiable(disposto),
      seme: seme,
    );
  }

  /// MISCHIA il solo mazzo residuo. Le carte assegnate non si toccano.
  ///
  /// Le carte rimaste si rimescolano e tornano nelle POSIZIONI ancora libere
  /// dell'arco: chi mescola vede il ventaglio identico e sa che sotto le
  /// carte sono cambiate, che e' quello che una mischia fa davvero.
  StesaInCorso mischia({int? seme}) => _conResiduo(
        List<int>.of(mazzoResiduo)..shuffle(TarotSpread.casoCon(seme)),
      );

  /// TAGLIA il solo mazzo residuo: la meta' sotto sale sopra, come nel gesto
  /// vero. Un taglio non mescola niente, cambia solo da dove si comincia.
  StesaInCorso taglia(int punto) {
    if (mazzoResiduo.length < 2) return this;
    return _conResiduo(TarotSpread.taglia(mazzoResiduo, punto));
  }

  /// Rimette [carte] nelle posizioni libere dell'arco, nell'ordine dato.
  ///
  /// Le posizioni gia' prese restano vuote: sono i buchi che il ventaglio
  /// mostra, e riempirli vorrebbe dire far ricomparire nel mazzo carte che
  /// sono gia' sul tavolo.
  StesaInCorso _conResiduo(List<int> carte) {
    final disposto = List<int?>.of(mazzoDisposto);
    var k = 0;
    for (var i = 0; i < disposto.length; i++) {
      if (disposto[i] == null) continue;
      disposto[i] = carte[k++];
    }
    return StesaInCorso._(
      assegnate: assegnate,
      mazzoDisposto: List<int?>.unmodifiable(disposto),
      seme: seme,
    );
  }
}

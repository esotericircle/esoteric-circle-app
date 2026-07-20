import 'dart:math';

import 'tarot_card.dart';

/// Le tre posizioni della stesa, nell'ordine di lettura.
enum SpreadPosition {
  passato('Passato'),
  presente('Presente'),
  futuro('Futuro');

  const SpreadPosition(this.label);

  final String label;
}

/// Una carta pescata: la carta, la sua posizione e il verso in cui e' uscita.
///
/// Il verso decide quale testo del corpus si mostra, dritto o rovesciato: sono
/// sempre coerenti, non si mostra mai il dritto su una carta rovesciata.
class DrawnCard {
  const DrawnCard({
    required this.card,
    required this.position,
    required this.reversed,
  });

  final TarotCard card;
  final SpreadPosition position;
  final bool reversed;

  /// La parola del rovescio accordata alla carta, vuota se la carta e' dritta.
  ///
  /// E' l'unico punto da cui la parola si prende, in tutta l'app: sotto la
  /// miniatura, nelle intestazioni degli strati, sulla carta chiave e nella
  /// card condivisibile. Scritta a mano da qualche parte, tornerebbe il
  /// maschile fisso su "La Papessa" o su "Gli Amanti".
  String get versoLabel => reversed ? card.reversedWord : '';

  /// Il nome come si legge sotto la carta, con la parola del rovescio accordata.
  String get displayName =>
      reversed ? '${card.name} ${card.reversedWord}' : card.name;

  /// La riga di significato dal corpus, del verso giusto.
  String get meaning => reversed ? card.reversed : card.upright;

  /// La sintesi breve dal corpus, del verso giusto.
  String get summary => reversed ? card.reversedSummary : card.uprightSummary;
}

/// Una stesa a tre carte, Passato Presente Futuro, nella voce di Medora.
///
/// Il pescaggio e' casuale ma passa da un seme opzionale, cosi' test e anteprima
/// sono riproducibili. Nessuna carta si ripete nella stessa stesa.
class TarotSpread {
  const TarotSpread(this.cards);

  final List<DrawnCard> cards;

  /// Probabilita' che una carta esca rovesciata.
  static const double reversedChance = 0.30;

  /// Quante carte si mostrano nel ventaglio coperto.
  static const int fanSize = 9;

  DrawnCard get passato => cards[0];
  DrawnCard get presente => cards[1];
  DrawnCard get futuro => cards[2];

  /// La riga di sintesi memorabile, dalla sintesi breve della carta del
  /// Presente: e' il colpo d'occhio sopra le tre carte.
  String get synthesis => presente.summary;

  /// La lettura che concatena le tre posizioni in modo fluido.
  String get reading =>
      'Alle tue spalle ${passato.displayName}: ${passato.meaning} '
      'Nel momento che vivi ${presente.displayName}: ${presente.meaning} '
      'Davanti a te ${futuro.displayName}: ${futuro.meaning}';

  /// La riga di chiusura, sempre nella cornice della consapevolezza.
  static const String closing =
      'Il cielo inclina, non obbliga: la scelta resta tua.';

  /// Il disclaimer, mostrato una sola volta in fondo alla schermata.
  static const String disclaimer =
      'I tarocchi sono tradizione reale, qui per intrattenimento e crescita: '
      'nessuna promessa sul futuro, sempre uno spazio di scelta.';

  /// Pesca tre carte distinte dal mazzo, ognuna dritta o rovesciata.
  ///
  /// Con [seed] la stesa e' riproducibile: stesso seme, stessa stesa. Senza,
  /// ogni pescaggio e' nuovo.
  static TarotSpread draw({int? seed}) {
    final random = seed == null ? Random() : Random(seed);
    final indici = List<int>.generate(TarotDeck.cards.length, (i) => i)
      ..shuffle(random);
    return TarotSpread([
      for (var i = 0; i < SpreadPosition.values.length; i++)
        DrawnCard(
          card: TarotDeck.cards[indici[i]],
          position: SpreadPosition.values[i],
          reversed: random.nextDouble() < reversedChance,
        ),
    ]);
  }
}

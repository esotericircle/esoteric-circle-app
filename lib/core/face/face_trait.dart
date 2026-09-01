/// I tratti del volto letti dalla Personologia, la fisiognomica di Edward
/// Vincent Jones resa popolare da Naomi Tickle.
///
/// La geometria del volto si MISURA (il file `face_classifier.dart`, puro e
/// deterministico); i significati sono la tradizione con la nostra curatela, e
/// stanno nel corpus. Qui c'e' solo la tassonomia: le categorie del volto e, per
/// ognuna, le varianti con il nome e il titolo evocativo che la variante da' al
/// responso quando e' il tratto dominante.
library;

/// Le undici categorie che si leggono dal volto, nell'ordine in cui si
/// presentano e che scioglie i pareggi di marcatezza.
enum FaceCategory {
  formaVolto('Forma del volto'),
  fronte('Fronte'),
  sopracciglia('Sopracciglia'),
  distanzaOcchi('Distanza degli occhi'),
  grandezzaOcchi('Grandezza degli occhi'),
  naso('Naso'),
  labbra('Labbra'),
  bocca('Bocca'),
  mento('Mento'),
  mascella('Mascella'),
  zigomi('Zigomi');

  const FaceCategory(this.titolo);

  /// Il nome della categoria, come si mostra a video.
  final String titolo;

  /// L'ordine canonico, che scioglie i pareggi di marcatezza fra tratti.
  int get ordine => index;
}

/// Una variante di un tratto del volto: la forma tonda, la mascella larga, e
/// cosi' via. Porta la categoria a cui appartiene, il nome che si legge nella
/// riga del tratto e il titolo evocativo che intitola il responso quando e' il
/// tratto piu' marcato.
enum FaceTrait {
  // Forma del volto.
  voltoTondo(FaceCategory.formaVolto, 'Volto tondo', 'Il calore che accoglie'),
  voltoQuadrato(
      FaceCategory.formaVolto, 'Volto quadrato', 'La forza che resta salda'),
  voltoOvale(FaceCategory.formaVolto, 'Volto ovale', 'La mente che riflette'),
  voltoTriangolare(FaceCategory.formaVolto, 'Volto triangolare',
      'L\'immaginazione che accende'),

  // Fronte.
  fronteSfuggente(FaceCategory.fronte, 'Fronte sfuggente',
      'Il pensiero che corre al risultato'),
  fronteVerticale(FaceCategory.fronte, 'Fronte verticale',
      'Il metodo che precede la scelta'),

  // Sopracciglia.
  sopraccigliaDritte(
      FaceCategory.sopracciglia, 'Sopracciglia dritte', 'La logica sui fatti'),
  sopraccigliaCurve(FaceCategory.sopracciglia, 'Sopracciglia curve',
      'Lo sguardo che va alle persone'),
  sopraccigliaAngolo(FaceCategory.sopracciglia, 'Sopracciglia ad angolo',
      'La mente che mette ordine'),

  // Distanza degli occhi.
  occhiRavvicinati(FaceCategory.distanzaOcchi, 'Occhi ravvicinati',
      'La messa a fuoco che non perde il tempo'),
  occhiDistanziati(FaceCategory.distanzaOcchi, 'Occhi distanziati',
      'Lo sguardo ampio che tollera'),

  // Grandezza degli occhi.
  occhiGrandi(FaceCategory.grandezzaOcchi, 'Occhi grandi',
      'Il cuore aperto alle emozioni'),
  occhiRaccolti(FaceCategory.grandezzaOcchi, 'Occhi raccolti',
      'La concentrazione che intuisce'),

  // Naso.
  nasoLungo(FaceCategory.naso, 'Naso lungo', 'Il piano che valuta prima'),
  nasoCorto(FaceCategory.naso, 'Naso corto', 'Il presente che agisce'),

  // Labbra.
  labbraPiene(FaceCategory.labbra, 'Labbra piene', 'La generosità che dona'),
  labbraSottili(
      FaceCategory.labbra, 'Labbra sottili', 'La misura che pesa le parole'),

  // Bocca.
  boccaLarga(FaceCategory.bocca, 'Bocca larga', 'L\'apertura che accoglie'),
  boccaPiccola(
      FaceCategory.bocca, 'Bocca piccola', 'Il raccoglimento che custodisce'),

  // Mento.
  mentoAmpio(FaceCategory.mento, 'Mento ampio', 'La costanza che tiene'),
  mentoAPunta(FaceCategory.mento, 'Mento a punta', 'L\'agilità che si adatta'),

  // Mascella.
  mascellaLarga(
      FaceCategory.mascella, 'Mascella larga', 'La volontà che non molla'),
  mascellaStretta(FaceCategory.mascella, 'Mascella stretta',
      'La flessibilità che asseconda'),

  // Zigomi.
  zigomiAlti(FaceCategory.zigomi, 'Zigomi alti', 'L\'amore della sfida'),
  zigomiMorbidi(FaceCategory.zigomi, 'Zigomi morbidi', 'La ricerca del calore');

  const FaceTrait(this.categoria, this.nome, this.titoloEvocativo);

  /// La categoria del volto a cui appartiene.
  final FaceCategory categoria;

  /// Il nome della variante, come si legge nella riga del tratto.
  final String nome;

  /// Il titolo evocativo che intitola il responso quando questo tratto e' il
  /// piu' marcato.
  final String titoloEvocativo;

  /// Le varianti di una categoria, nell'ordine di dichiarazione.
  static List<FaceTrait> perCategoria(FaceCategory c) =>
      FaceTrait.values.where((t) => t.categoria == c).toList(growable: false);
}

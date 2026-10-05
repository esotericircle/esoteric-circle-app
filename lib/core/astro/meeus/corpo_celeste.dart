/// I dieci corpi del cielo dell'app. Ordine FD voce 02: stava dentro
/// `Effemeridi`, il motore del 2020-2030 cancellato con quest'ordine, e
/// adesso sta accanto alla porta sola, `IlCieloDiMeeus`.
enum CorpoCeleste {
  sole('Sole', '☉', 'sun'),
  luna('Luna', '☽', 'moon'),
  mercurio('Mercurio', '☿', 'mercury'),
  venere('Venere', '♀', 'venus'),
  marte('Marte', '♂', 'mars'),
  giove('Giove', '♃', 'jupiter'),
  saturno('Saturno', '♄', 'saturn'),
  urano('Urano', '♅', 'uranus'),
  nettuno('Nettuno', '♆', 'neptune'),
  plutone('Plutone', '♇', 'pluto');

  const CorpoCeleste(this.nome, this.glifo, this.id);

  /// Nome italiano, come lo mostra la carta natale.
  final String nome;

  /// Glifo astronomico, stesso repertorio della carta natale.
  final String glifo;

  /// L'identificatore che usa la carta natale (`PlanetPosition.id`), cosi' il
  /// lato transito e il lato natale si riconoscono senza una tabella di mezzo.
  final String id;
}

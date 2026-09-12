/// I dodici archetipi del Test Archetipo, dominio Aura.
///
/// La teoria e' di Jung, i dodici e il questionario vengono dalla tradizione di
/// Pearson e Mark (Pearson-Marr Archetype Indicator). Nessun animale: quello e'
/// il territorio di Caligo.
///
/// L'ORDINE DI DICHIARAZIONE E' L'ORDINE CANONICO e non e' decorativo: e' la
/// regola che scioglie i pareggi nel punteggio. A parita' di punti vince chi
/// viene prima, quindi `Archetype.values` va letto come una graduatoria e non
/// va riordinato senza sapere che si cambia il risultato dei pareggi.
enum Archetype {
  innocente('Innocente', 'L\'Innocente'),
  esploratore('Esploratore', 'L\'Esploratore'),
  saggio('Saggio', 'Il Saggio'),
  eroe('Eroe', 'L\'Eroe'),
  ribelle('Ribelle', 'Il Ribelle'),
  mago('Mago', 'Il Mago'),
  realista('Realista', 'Il Realista'),
  amante('Amante', 'L\'Amante'),
  giullare('Giullare', 'Il Giullare'),
  custode('Custode', 'Il Custode'),
  sovrano('Sovrano', 'Il Sovrano'),
  creatore('Creatore', 'Il Creatore');

  const Archetype(this.nome, this.conArticolo);

  /// Il nome a video, con l'iniziale maiuscola.
  final String nome;

  /// Il nome con l'articolo determinativo, elisione compresa: "Il Realista",
  /// "L'Eroe". E' un dato per archetipo e non una regola calcolata, perche'
  /// l'elisione italiana ha eccezioni che una regola generica sbaglierebbe.
  final String conArticolo;

  /// Lo stem dell'arte nel bundle, senza cartella ne' estensione.
  ///
  /// Le dodici statue stanno in `assets/img/archetipi/` alla misura piena e in
  /// `assets/img_thumb/archetipi/` in miniatura, come le altre famiglie.
  String get stem => 'arc_${name}_v1';

  /// L'arte piena, per la scheda dell'archetipo.
  String get artePiena => 'assets/img/archetipi/$stem.webp';

  /// La miniatura, per la ruota e per la card da condividere.
  String get arteThumb => 'assets/img_thumb/archetipi/$stem.webp';

  /// La posizione nell'ordine canonico, da zero. Piu' bassa vince i pareggi.
  int get ordineCanonico => index;
}

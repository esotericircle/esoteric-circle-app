/// I tipi di stesa che il Cerchio offre.
///
/// Il nome non e' una stringa scritta a mano nella schermata: e' un dato della
/// definizione della stesa. Cosi' il titolo in alto segue da solo la stesa
/// attiva, e quando arriveranno quelle da sette e dieci carte non ci sara' da
/// ricordarsi di cambiare anche il titolo.
enum TarotSpreadType {
  treCarte(
    nome: 'Stesa a Tre Carte',
    breve: 'Tre Carte',
    carte: 3,
    descrizione: 'Passato, Presente, Futuro',
    disponibile: true,
  ),
  setteCarte(
    nome: 'Stesa a Sette Carte',
    breve: 'Sette Carte',
    carte: 7,
    descrizione: 'La lettura estesa',
    disponibile: false,
  ),
  dieciCarte(
    nome: 'Stesa a Dieci Carte',
    breve: 'Dieci Carte',
    carte: 10,
    descrizione: 'La croce celtica',
    disponibile: false,
  );

  const TarotSpreadType({
    required this.nome,
    required this.breve,
    required this.carte,
    required this.descrizione,
    required this.disponibile,
  });

  /// Il nome per esteso, quello che va nel titolo della schermata.
  final String nome;

  /// Il nome corto, per i selettori e il riepilogo.
  final String breve;

  /// Quante carte compongono la stesa.
  final int carte;

  /// Cosa promette la stesa, in poche parole.
  final String descrizione;

  /// Se e' gia' apribile o se resta Coming soon col lucchetto.
  final bool disponibile;

  /// La stesa della Demo, l'unica viva.
  static const TarotSpreadType predefinita = TarotSpreadType.treCarte;
}

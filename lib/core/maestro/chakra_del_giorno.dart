/// I SETTE CHAKRA, UNO PER GIORNO DELLA SETTIMANA.
///
/// **Perche' esiste.** Il consiglio finale di ogni Maestro chiude invitando a
/// tornare, e l'invito e' agganciato a qualcosa che cambia da solo: per Medora
/// il cielo, per Caligo la runa della sera, per Aura il chakra del giorno.
/// L'invito e' diverso perche' il mondo e' diverso, non perche' qualcuno ha
/// pescato un sinonimo.
///
/// **Sette e sette.** I chakra principali sono sette e i giorni sono sette:
/// l'accostamento e' biiettivo, quindi ogni giorno ha il suo e ogni chakra il
/// suo giorno, e due giorni vicini non ne mostrano mai lo stesso. E' una
/// pratica contemporanea diffusa, non una fonte antica: la dichiariamo per
/// quello che e', una curatela, come gia' facciamo per l'animale guida
/// derivato dal segno.
///
/// I nomi sono in sanscrito traslitterato e in italiano, perche' il primo e'
/// il nome vero e il secondo e' quello che si legge.
library;

/// Un chakra: il nome sanscrito, quello italiano e cio' che governa.
class Chakra {
  const Chakra({
    required this.nome,
    required this.italiano,
    required this.governa,
  });

  /// Il nome sanscrito traslitterato, per esempio Anahata.
  final String nome;

  /// Il nome italiano, per esempio "il cuore".
  final String italiano;

  /// Cio' su cui apre, in poche parole. E' la materia dell'invito.
  final String governa;
}

/// Il chakra di un giorno, e la tavola dei sette.
abstract final class ChakraDelGiorno {
  /// I sette, nell'ordine dal basso verso l'alto, che e' quello tradizionale.
  static const List<Chakra> tutti = [
    Chakra(
        nome: 'Muladhara', italiano: 'la radice', governa: 'ciò che ti tiene'),
    Chakra(
        nome: 'Svadhisthana',
        italiano: 'il sacro',
        governa: 'ciò che ti muove'),
    Chakra(nome: 'Manipura', italiano: 'il fuoco', governa: 'ciò che decidi'),
    Chakra(nome: 'Anahata', italiano: 'il cuore', governa: 'ciò che accogli'),
    Chakra(nome: 'Vishuddha', italiano: 'la gola', governa: 'ciò che dici'),
    Chakra(nome: 'Ajna', italiano: 'il terzo occhio', governa: 'ciò che vedi'),
    Chakra(
        nome: 'Sahasrara', italiano: 'la corona', governa: 'ciò che ti supera'),
  ];

  /// Il chakra di quel giorno.
  ///
  /// `DateTime.weekday` va da 1, lunedi', a 7, domenica: meno uno da' l'indice.
  /// Funzione pura: stesso giorno, stesso chakra, sempre.
  static Chakra di(DateTime giorno) =>
      tutti[(giorno.weekday - 1) % tutti.length];
}

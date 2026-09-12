import 'chakra_del_giorno.dart';
import 'memoria_del_respiro.dart';

/// **IL WOW CHE NASCE DALLA MEMORIA.** Ordine DB voce 09, 9 settembre 2026.
///
/// **Parole dell'ordine**: *"L'effetto Wow di questa funzione non e' solo
/// l'animazione. E' il momento in cui l'app dimostra di essersi accorta...
/// Alla fine di una sessione, quando la memoria ha qualcosa da dire, Aura dice
/// una cosa sola che sa soltanto perche' ricorda."*
///
/// **UNA FRASE, MAI DUE.** Ed e' una regola strutturale e non uno stile: due
/// osservazioni di fila diventano un rapporto sulla persona, e un rapporto e'
/// esattamente cio' che il vincolo della voce DB.08 vieta, *"nessun Maestro
/// deve mai dire alla persona che la sta osservando"*.
///
/// **E SOLO QUANDO C'E' QUALCOSA DI VERO DA DIRE.** Se la memoria non ha
/// niente, non si inventa niente e la sessione si chiude com'e'. **Una
/// osservazione falsa distrugge in una riga la fiducia che dieci vere hanno
/// costruito**, e per questo ogni frase qui dentro ha una soglia sotto la
/// quale non nasce: due giorni di fila non sono una striscia, due sessioni non
/// sono un'abitudine, e sei sono il minimo per dire che le sessioni si
/// allungano.
///
/// **L'ORDINE IN CUI SI SCEGLIE, ed e' una scelta motivata.** Quando piu' di
/// una osservazione e' vera insieme, vince **la piu' rara**: la prima volta su
/// un centro capita sette volte in una vita di pratica, la terza sera di fila
/// capita spesso. Dire la cosa comune quando ce n'era una rara e' sprecare
/// l'unico momento in cui l'app poteva stupire.
abstract final class CioCheAuraRicorda {
  /// **LA FRASE, o nulla.**
  ///
  /// [centroDiOggi] e' l'indice del centro appena respirato, e serve a sapere
  /// se e' la prima volta che quel centro viene toccato.
  static String? unaCosaSola(
    MemoriaDelRespiro memoria, {
    required int centroDiOggi,
  }) {
    final sessioni = memoria.sessioni;
    if (sessioni.isEmpty) return null;

    // 1. **LA PRIMA VOLTA SU QUESTO CENTRO.** La piu' rara: in una vita di
    // pratica capita sette volte. Si guarda se prima di oggi quel centro non
    // era mai stato toccato.
    final primaDiOggi = sessioni.skip(1);
    final maiToccato = !primaDiOggi.any((s) => s.centro == centroDiOggi);
    if (maiToccato && primaDiOggi.isNotEmpty) {
      // **LA PREPOSIZIONE LA COMPONE CHI CONOSCE IL NOME.** Ordine DA voce
      // 06: stava qui come funzione privata, e il secondo posto che ne ha
      // avuto bisogno ha scritto "su il cuore".
      final centro = ChakraDelGiorno
          .tutti[centroDiOggi % ChakraDelGiorno.tutti.length];
      return 'È la prima volta che respiri ${centro.conSu}.';
    }

    // 2. **IL RITORNO DOPO UNA LUNGA ASSENZA.** Rara anche questa, e la piu'
    // preziosa: chi torna dopo undici giorni sta ricominciando, e accorgersene
    // vale piu' di qualunque altra cosa.
    if (sessioni.length >= 2) {
      final scarto =
          sessioni.first.quando.difference(sessioni[1].quando).inDays;
      if (scarto >= 7) {
        return 'Erano $scarto giorni. Il fiore era rimasto dov\'era.';
      }
    }

    // 3. **LA STRISCIA.** Da tre in su: due sere di fila capitano per caso.
    final fila = memoria.giorniDiFila;
    if (fila >= 3) {
      return 'È la $fila' 'ª sera di fila.';
    }

    // 4. **IL RESPIRO PIU' LENTO DI PRIMA.** Vuole sei sessioni, perche' con
    // meno il confronto e' rumore.
    final cambia = memoria.quantoCambiaLaDurata;
    if (cambia != null && cambia >= 0.20) {
      return 'Oggi sei rimasto più a lungo della settimana scorsa.';
    }
    if (cambia != null && cambia <= -0.20) {
      return 'Oggi è stata più breve del solito e va bene così.';
    }

    // 5. **IL CENTRO MAI TOCCATO**, che e' la domanda che il fiore pone da
    // solo. Solo quando ne resta uno soltanto: con cinque spenti non e'
    // un'osservazione, e' l'elenco di cio' che manca.
    final mai = memoria.centriMaiToccati;
    if (mai.length == 1) {
      final nome = ChakraDelGiorno.tutti[mai.first].italiano;
      return 'Ti manca solo $nome perché il fiore sia intero.';
    }

    // **NIENTE DA DIRE.** E allora non si dice niente: la sessione si chiude
    // come si e' chiusa, e nessuno si accorge che manca una frase.
    return null;
  }

}

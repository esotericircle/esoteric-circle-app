/// **IL BLOCCO DI CORTESIA, uno solo per tutti i prompt che scrivono per la
/// persona.** Ordine DL voce 04, 14 settembre 2026.
///
/// Prima viveva dentro le regole comuni dei Maestri, e lo ricevevano tre
/// prompt su sei fra quelli che producono prosa: la sintesi comparativa non
/// riceveva nemmeno il profilo, il distillato di memoria chiedeva al modello di
/// dedurre la forma gia' nota, e la lettura del mese imponeva il femminile a
/// tutti. **Adesso chi scrive un testo che la persona leggera' chiama questo
/// blocco**, e la prova `ogni_prompt_di_prosa_dichiara_la_forma` lo pretende.
///
/// **Sta in `core/chat`, accanto alla porta del genere**, perche' lo usano
/// sia i Maestri sia il Viaggio, e il Viaggio non deve dipendere dai servizi
/// dell'AI per sapere come si parla a una persona.
library;

import 'user_profile.dart';

abstract final class IlBloccoDiCortesia {
  /// L'intestazione del blocco, per chi deve riconoscerlo dentro un prompt.
  static const String intestazione = 'COME TI RIVOLGI ALLA PERSONA:';

  /// Il blocco per [profile]: il nome, se c'e', e la forma.
  ///
  /// **La frase sul genere passa dalla porta del genere**, ordine DL voce 01:
  /// qui c'era uno `switch` sulla forma, il quinto posto dell'app dove si
  /// decideva come parlare a qualcuno. **E la frase sul nome non dice piu'
  /// "Chiamalo"**: era un pronome maschile per chiunque, dentro lo stesso
  /// prompt che per chi aveva scelto il femminile diceva "rivolgiti a lei".
  static String per(UserProfile profile) {
    final buffer = StringBuffer()..writeln(intestazione);
    if (profile.hasName) {
      buffer.writeln('- Il nome della persona è ${profile.displayName}: '
          'usalo quando serve, senza ripeterlo a ogni frase.');
    } else {
      buffer.writeln('- Non conosci ancora il nome della persona. Puoi '
          'chiederlo una volta con delicatezza, senza insistere.');
    }
    buffer.writeln(riga(profile.courtesyForm));
    return buffer.toString();
  }

  /// Il blocco per la sola forma, quando il nome non serve: la forma della
  /// persona che sta usando l'app, se non se ne dichiara un'altra.
  static String perForma([CourtesyForm? forma]) =>
      '$intestazione\n${riga(forma ?? LaMarcaDelGenere.formaCorrente)}\n';

  /// La riga sul genere, dalla porta.
  static String riga(CourtesyForm forma) => forma.agree(
        masculine: '- Rivolgiti alla persona al maschile: aggettivi e '
            'participi riferiti alla persona vanno al maschile.',
        feminine: '- Rivolgiti alla persona al femminile: aggettivi e '
            'participi riferiti alla persona vanno al femminile.',
        neutral: '- Usa formulazioni neutre: nessun aggettivo o participio '
            'riferito alla persona deve dire se è un uomo o una donna. Scrivi '
            '"sei qui" invece di un participio, "prenditi cura di te" invece '
            'di un riflessivo col genere.',
      );
}

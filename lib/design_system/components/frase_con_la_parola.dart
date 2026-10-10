import 'package:flutter/material.dart';

/// **LA PAROLA DEL GIORNO, DENTRO UNA FRASE, SI VEDE.** Ordine DD voce 02,
/// 10 settembre 2026.
///
/// **Il fatto del fondatore**: la Parola del giorno, quando compare dentro una
/// frase, non si distingue dal resto. La sera il Sigillo del Sogno scriveva
/// *"Stamattina la tua parola era Fiducia"*, e quella parola, che e' la sola
/// cosa che chi legge deve portarsi via, aveva lo stesso peso di *"stamattina"*
/// e di *"era"*.
///
/// **La regola, e vale ovunque la parola compaia dentro una frase**: fra
/// virgolette basse e in grassetto. Le virgolette la staccano dal discorso
/// anche dove il grassetto non arriva, cioe' in un testo condiviso o in un
/// messaggio di chat; il grassetto la fa trovare all'occhio in un colpo.
///
/// **Perche' un widget e non un `copyWith` sul posto.** I punti che mostrano
/// la parola dentro una frase sono piu' di uno, e ognuno che la scrivesse a
/// modo suo sarebbe un posto in cui la regola si perde. Qui la regola sta
/// scritta una volta, e una guardia enumera i punti che devono passare da qui.
class FraseConLaParola extends StatelessWidget {
  const FraseConLaParola({
    super.key,
    required this.frase,
    required this.parola,
    required this.stile,
    this.textAlign = TextAlign.start,
  });

  /// La frase intera, con la parola gia' dentro **fra virgolette basse**.
  final String frase;

  /// La parola da mettere in risalto, senza virgolette.
  final String parola;

  final TextStyle stile;
  final TextAlign textAlign;

  /// Come la parola si scrive dentro una frase: **fra virgolette basse**.
  /// Sta qui e non sparsa nelle stringhe, cosi' chi scrive una frase nuova
  /// non deve ricordarsi la convenzione.
  static String virgolettata(String parola) => '«$parola»';

  @override
  Widget build(BuildContext context) {
    final cercata = virgolettata(parola);
    final dove = frase.indexOf(cercata);
    // **SE LA PAROLA NON C'E', SI SCRIVE LA FRASE E BASTA.** Una frase
    // storpiata perche' la parola e' cambiata sarebbe peggio di una frase
    // senza risalto, e la guardia pretende comunque che i punti veri la
    // portino.
    if (dove < 0) {
      return Text(frase, style: stile, textAlign: textAlign);
    }
    return Text.rich(
      TextSpan(
        style: stile,
        children: [
          TextSpan(text: frase.substring(0, dove)),
          TextSpan(
            text: cercata,
            style: stile.copyWith(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: frase.substring(dove + cercata.length)),
        ],
      ),
      textAlign: textAlign,
    );
  }
}

import '../maestro/consiglio_finale.dart';
import '../maestro/maestro.dart';
import '../maestro/voce_del_maestro.dart';

/// **L'ALTRO MAESTRO SI NOMINA IN FONDO.** Ordine EQ voce 02, 27 settembre
/// 2026.
///
/// Il fondatore: *"Risponde sempre nel merito con la sua arte (Calìgo: un
/// rito per l'amore). L'altro Maestro lo nomina solo in fondo, come consiglio
/// in più."* Nelle catture Calìgo apriva con *"Per i legami e il destino c'è
/// Medora"*; nel collaudo con Gemini vero, con la regola nuova gia' scritta
/// nell'istruzione, Medora ha aperto ancora una volta con *"Non posso
/// indicarti un rito da compiere per l'apertura della tua bottega, perché i
/// riti sono l'arte di Calìgo."* (`docs/collaudo/EQ/eq02/dopo4/`).
///
/// **Qui la si guarda a valle, e non si chiede di nuovo**: la prima frase che
/// nomina un altro Maestro si sposta in fondo al corpo, prima della riga
/// d'oro, dove la regola la vuole. Il contenuto resta tutto, cambia solo il
/// posto; nel LIVE una seconda chiamata sarebbe attesa pura.
abstract final class IlRimandoInFondo {
  /// L'altro Maestro che la prima frase del corpo di [risposta] nomina, o
  /// null. [chi] e' il Maestro che risponde: il suo nome non conta.
  static Maestro? chiNominaInApertura(String risposta, Maestro chi) {
    final prima =
        ConsiglioFinale.primaFraseDi(ConsiglioFinale.corpoDa(risposta));
    for (final altro in Maestro.values) {
      if (altro == chi) continue;
      if (_nomina(prima, altro)) return altro;
    }
    return null;
  }

  /// **LA RISPOSTA CON IL RIMANDO IN FONDO.** Se [risposta] non apre con un
  /// altro Maestro, o se il corpo e' fatto della sola frase del rimando, torna
  /// com'e'. Il segno del chiarimento `[[CHIEDO]]` ferma tutto: chi chiede non
  /// ha ancora risposto, e la sua prima frase e' la domanda.
  static String conIlRimandoInFondo(String risposta, Maestro chi) {
    if (risposta.contains('[[')) return risposta;
    if (chiNominaInApertura(risposta, chi) == null) return risposta;
    final corpo = ConsiglioFinale.corpoDa(risposta);
    final prima = ConsiglioFinale.primaFraseDi(corpo);
    final resto = corpo.substring(prima.length).trim();
    if (resto.isEmpty) return risposta;
    final riga = ConsiglioFinale.sintesiDa(risposta);
    final nuovo = '$resto\n\n$prima';
    return riga == null ? nuovo : '$nuovo\n${ConsiglioFinale.stella} $riga';
  }

  /// Vero se [frase] nomina [maestro]: il nome come lo scrive l'app, con o
  /// senza accento, e con la maiuscola. **Aura con la maiuscola**, perche'
  /// "la tua aura" e' una parola comune e non la Maestra.
  static bool _nomina(String frase, Maestro maestro) {
    final nome = VoceDelMaestro.nomeDetto(maestro);
    final senzaAccento = nome
        .replaceAll('ì', 'i')
        .replaceAll('à', 'a')
        .replaceAll('è', 'e')
        .replaceAll('ò', 'o')
        .replaceAll('ù', 'u');
    for (final n in {nome, senzaAccento}) {
      final trovato = RegExp('(^|[^\\p{L}])$n(?![\\p{L}])', unicode: true)
          .firstMatch(frase);
      if (trovato == null) continue;
      final prima =
          frase.substring(0, trovato.start + trovato.group(1)!.length);
      if (RegExp(r"(\b(la|tua|sua|mia)\s+|\b(un|l)['’])$",
              caseSensitive: false)
          .hasMatch(prima)) {
        continue;
      }
      return true;
    }
    return false;
  }
}

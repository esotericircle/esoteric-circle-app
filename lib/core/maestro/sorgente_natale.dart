import '../identity/natal_identity.dart';
import 'natal_context.dart';

/// L'UNICA sorgente del contesto natale corrente.
///
/// Prima ogni superficie se lo componeva per conto suo: la stessa riga,
/// `hasBirth ? NatalContext.fromNatal(...) : NatalContext.none`, stava scritta
/// due volte, in `maestro_chat_screen.dart` e in `ask_maestri_screen.dart`. Due
/// copie della stessa regola sono due porte, e infatti una delle due lo usava
/// per il benvenuto e non per il Maestro, cioe' i dati natali arrivavano alla
/// frase di accoglienza e non alla risposta.
///
/// Adesso la regola sta qui, e le superfici la LEGGONO. Chi apre la terza
/// superficie domani non deve ricordarsi niente: chiede il contesto a questo
/// punto, oppure la prova che enumera i chiamanti lo denuncia.
class SorgenteNatale {
  const SorgenteNatale._();

  /// Il contesto natale corrente dai dati di nascita.
  ///
  /// Puro: prende il controllore e restituisce il dato, senza toccare il
  /// `BuildContext`. Cosi' si prova senza montare uno schermo.
  static NatalContext daIdentita(BirthIdentityController identita) {
    if (!identita.hasBirth) return NatalContext.none;
    return NatalContext.fromNatal(
      chart: identita.chart,
      facts: identita.facts,
    );
  }
}

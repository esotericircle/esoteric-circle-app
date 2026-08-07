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
    final base = NatalContext.fromNatal(
      chart: identita.chart,
      facts: identita.facts,
    );
    // IL SEGNO SOLARE NON HA BISOGNO DELLA CARTA: basta la data, e il
    // controller lo sa gia' (identita.sunSign, con la ragione scritta la').
    // Senza questa riga, prima che la carta arrivi il contesto usciva senza
    // segno, e tutto cio' che sul segno si personalizza, l'emblema
    // dell'attesa, le domande personali sul Sole, taceva pur avendo il dato.
    if (base.sunSign == null && identita.sunSign != null) {
      return NatalContext(
        sunSign: identita.sunSign!.italianName,
        moonSign: base.moonSign,
        ascendant: base.ascendant,
        lifeNumber: base.lifeNumber,
        lifeNumberTitle: base.lifeNumberTitle,
        moonIllumination: base.moonIllumination,
      );
    }
    return base;
  }
}

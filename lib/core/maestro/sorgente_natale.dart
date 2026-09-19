import '../identity/natal_identity.dart';
import '../sigilli/diario_del_cammino.dart';
import '../sigilli/sentieri.dart';
import '../sigilli/traguardo.dart';
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
  /// **E IL PROSSIMO PASSO DEL CAMMINO PASSA DA QUI.**
  /// Ordine CQ voce 2.15, 4 settembre 2026.
  ///
  /// [diario] e' facoltativo perche' non tutte le superfici ce l'hanno, e una
  /// sorgente che lo PRETENDE farebbe cadere le prove che montano una
  /// schermata da sola: e' la stessa tolleranza che il progetto usa gia' per
  /// i servizi del guscio. Senza diario il contesto esce come prima, e nel
  /// prompt non compare nessuna riga sul Cammino.
  static NatalContext daIdentita(BirthIdentityController identita,
      {DiarioDelCammino? diario}) {
    final (nome, apre) = _prossimoPasso(diario);
    if (!identita.hasBirth) {
      return nome == null
          ? NatalContext.none
          : NatalContext(
              prossimoTraguardo: nome, cosaApreIlProssimoTraguardo: apre);
    }
    final base = NatalContext.fromNatal(
      chart: identita.chart,
      facts: identita.facts,
      prossimoTraguardo: nome,
      cosaApreIlProssimoTraguardo: apre,
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
        prossimoTraguardo: base.prossimoTraguardo,
        cosaApreIlProssimoTraguardo: base.cosaApreIlProssimoTraguardo,
      );
    }
    return base;
  }

  /// Il prossimo gradino da prendere, scelto fra i tre sentieri: quello piu'
  /// vicino a chi cammina, cioe' col numero di posizione piu' basso.
  ///
  /// **Uno e non tre.** Il contesto di una conversazione non e' un cruscotto:
  /// tre nomi di gradino dentro un'istruzione di sistema diventano un elenco
  /// che il modello ripete, e la regola dei due strati vuole che il Maestro
  /// parli, non che legga il Cammino.
  static (String?, String?) _prossimoPasso(DiarioDelCammino? diario) {
    if (diario == null) return (null, null);
    Traguardo? migliore;
    for (final s in Sentiero.values) {
      final t = diario.prossimoDi(s);
      if (t == null) continue;
      if (migliore == null || t.posizione < migliore.posizione) migliore = t;
    }
    return (migliore?.nome, migliore?.cosaApre);
  }
}

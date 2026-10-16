import 'package:flutter/foundation.dart';

import 'le_carte_nella_posizione_dati.dart';
import 'tarot_card.dart';
import 'tarot_spread.dart';
import 'tarot_topic.dart';

/// **LA CARTA NELLA SUA POSIZIONE.** Ordine EQ voce 04, 27 settembre 2026.
///
/// Prima "Le carte, una alla volta" mostrava per ogni carta il testo fisso del
/// suo verso, uguale nel passato, nel presente e nel futuro e per qualunque
/// domanda: l'Architetto l'ha letto nel codice e il fondatore nelle catture.
/// Qui ogni carta ha un testo per verso e per posizione, scritti una volta
/// sola. Servono alla lettura di casa, quando il modello non risponde; al
/// modello no, perche' lo parafrasava invece di leggere la carta sulla
/// domanda (sonde 13 e 14 dell'ordine EQ).
///
/// **LE DICIASSETTE POSIZIONI, LE TRE VARIANTI E I REGISTRI.** Ordine FI voci
/// 17, 20 e 24 e aggiunta A3, 11 ottobre 2026. La fonte sta in
/// `docs/corpus/tarocchi_posizione/`, un file per posizione piu' quello dei
/// registri, e `tool/genera_carte_nella_posizione.py` la legge e scrive il
/// Dart senza chiamare nessun modello: i testi li scrive l'Architetto.
abstract final class LeCarteNellaPosizione {
  static String _verso(DrawnCard d) => d.reversed ? 'capovolta' : 'dritta';

  /// La chiave dello scheletro della carta [d]: posizione, nome e verso.
  static String chiaveDi(DrawnCard d) =>
      '${d.position.name}|${d.card.name}|${_verso(d)}';

  /// Le varianti piene dello scheletro della carta [d], da una a tre; vuoto
  /// se la sua posizione aspetta ancora i testi.
  static List<String> variantiDi(DrawnCard d) =>
      (fonteDiProva ?? scheletriDelleCarte)[chiaveDi(d)] ?? const [];

  /// Una fonte con tre varianti per la guardia della rotazione, finche' il
  /// corpus vero ne porta una sola: la prova la toglie quando ha finito.
  @visibleForTesting
  static Map<String, List<String>>? fonteDiProva;

  static final Set<SpreadPosition> _conLaFonte = {
    for (final p in SpreadPosition.values)
      if (TarotDeck.cards.every((c) => [false, true].every((capovolta) {
            final v = scheletriDelleCarte[
                '${p.name}|${c.name}|${capovolta ? 'capovolta' : 'dritta'}'];
            return v != null && v.isNotEmpty;
          })))
        p,
  };

  /// **SE LA POSIZIONE [p] HA LA SUA FONTE**: almeno una variante per tutte
  /// le centocinquantasei carte-verso. Aggiunta A6 e A7: una stesa resta
  /// Coming soon finche' una sua posizione non ce l'ha, invece di ripiegare
  /// sul testo del verso, che direbbe la stessa cosa in posizioni diverse.
  static bool haLaFonte(SpreadPosition p) => _conLaFonte.contains(p);

  /// Il testo della carta [d] nella sua posizione, alla sua [uscita]: la
  /// prima volta la prima variante, la seconda la seconda, poi si ricomincia
  /// (voce FI.18). **Se il corpus non la porta**, il significato del suo
  /// verso: non succede, perche' una stesa con una posizione senza fonte non
  /// si apre, e la guardia del corpus lo pretende.
  static String di(DrawnCard d, {int uscita = 0}) {
    final varianti = variantiDi(d);
    if (varianti.isEmpty) return d.meaning;
    return varianti[uscita % varianti.length];
  }

  /// **IL REGISTRO DELLA CARTA [d] NEL [gruppo]**, il metodo di Dora (voce
  /// FI.20): di che cosa parla quella carta in amore, nel lavoro o nel
  /// cammino. Null finche' la fonte dei registri non lo porta.
  static String? registroDi(DrawnCard d, TarotTopicGroup gruppo) {
    final righe = registriDelleCarte['${d.card.name}|${_verso(d)}'];
    if (righe == null || righe.length != TarotTopicGroup.values.length) {
      return null;
    }
    return righe[gruppo.index];
  }

  /// **IL MONTAGGIO DELLA LETTURA DI CASA** (aggiunta A3): lo scheletro della
  /// posizione e dopo di lui il registro del gruppo dell'argomento, nello
  /// stesso paragrafo. Lo scheletro dice che cosa la carta fa in quel posto,
  /// il registro di che cosa parla in quell'ambito.
  static String letturaDiCasa(DrawnCard d, TarotTopicGroup gruppo,
      {int uscita = 0}) {
    final scheletro = di(d, uscita: uscita);
    final registro = registroDi(d, gruppo);
    return registro == null ? scheletro : '$scheletro $registro';
  }
}

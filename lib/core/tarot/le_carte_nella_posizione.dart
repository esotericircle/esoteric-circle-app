import 'package:flutter/foundation.dart';

import '../chat/la_marca_del_genere.dart';
import '../responsi/i_riti_propiziatori.dart';
import '../responsi/la_forma_del_responso.dart';
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
    return LaMarcaDelGenere.risolvi(varianti[uscita % varianti.length]);
  }

  /// **IL REGISTRO DELLA CARTA [d] NEL [gruppo]**, il metodo di Dora (voce
  /// FI.20): di che cosa parla quella carta in amore, nel lavoro o nel
  /// cammino. Null finche' la fonte dei registri non lo porta.
  static String? registroDi(DrawnCard d, TarotTopicGroup gruppo) {
    final righe = registriDelleCarte['${d.card.name}|${_verso(d)}'];
    if (righe == null || righe.length != TarotTopicGroup.values.length) {
      return null;
    }
    return LaMarcaDelGenere.risolvi(righe[gruppo.index]);
  }

  /// **LA MARCA DEL GENERE SI RISOLVE QUI**, ordine GA. Il corpus delle
  /// posizioni porta le marche a tre vie (`[maschile|femminile|neutro]`)
  /// dove una frase da' un genere a chi legge, e lo strumento misura ogni
  /// forma fra 40 e 50 parole. Prima di questa riga nessuno le risolveva: lo
  /// scheletro arrivava a video con le quadre e, contato grezzo, usciva dalla
  /// misura (51 e 53 parole su nove responsi di carta: li ha trovati la prova
  /// `la_stesa_ha_la_forma_nuova_test.dart`). PADRE: ordine FK Parte 1 e
  /// voce FK.08 (commit 4f650dd9), che ha portato le marche nel Dart delle
  /// posizioni (22 righe prima dell'ordine GA) senza che il codice le
  /// risolvesse. Lo scheletro, il registro, il titolo e il cosa fare passano
  /// tutti da `LaMarcaDelGenere.risolvi`, con la forma di chi legge.
  ///
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

  /// **IL TITOLO DELLA CARTA [d] NELLA SUA POSIZIONE**, ordine GA voci
  /// GA.03 e GA.05: il fondatore, 19 ottobre 2026, *"Restano all'inizio i
  /// titoli, anche per le singola carte"*. Uno per le tre varianti, dal
  /// corpus (`docs/corpus/tarocchi_posizione/titoli.md`). Se manca, la
  /// sintesi del verso senza il punto: non succede, la guardia del corpus
  /// pretende tutti i 2.340 titoli.
  static String titoloDi(DrawnCard d) {
    final t = titoliDelleCarte[chiaveDi(d)];
    if (t != null && t.trim().isNotEmpty) {
      return LaMarcaDelGenere.risolvi(t.trim());
    }
    var s = d.summary.trim();
    while (s.endsWith('.')) {
      s = s.substring(0, s.length - 1).trimRight();
    }
    return s;
  }

  /// La chiave del "cosa fare" della carta [d] nel [gruppo]: nome, verso e
  /// gruppo, come in `cosaFareDelleCarte`.
  static String chiaveDelCosaFare(DrawnCard d, TarotTopicGroup gruppo) =>
      '${d.card.name}|${_verso(d)}|${gruppo.name}';

  /// Le varianti del "Cosa fare adesso" della carta [d] nel [gruppo].
  static List<String> cosaFareVariantiDi(DrawnCard d, TarotTopicGroup gruppo) =>
      cosaFareDelleCarte[chiaveDelCosaFare(d, gruppo)] ?? const [];

  /// **IL "COSA FARE ADESSO" DELLA CARTA [d]**, ordine GA voci GA.03 e
  /// GA.07: per carta, verso e gruppo dell'argomento, alla sua [uscita] come
  /// lo scheletro (la prima volta la prima variante, poi la seconda, poi la
  /// terza, poi si ricomincia: la stessa carta che torna non ripete il suo
  /// riquadro). Vuoto se il corpus non lo porta: non succede, la guardia del
  /// corpus pretende le 1.404 voci.
  static String cosaFareDi(DrawnCard d, TarotTopicGroup gruppo,
      {int uscita = 0}) {
    final varianti = cosaFareVariantiDi(d, gruppo);
    if (varianti.isEmpty) return '';
    return LaMarcaDelGenere.risolvi(varianti[uscita % varianti.length]);
  }

  /// **IL RESPONSO DELLA CARTA [d] NELLA FORMA NUOVA**, ordine GA voce GA.05:
  /// *"Le singole carte e le singole rune hanno sempre il responso breve: il
  /// loro titolo, un paragrafo e il riquadro 'Cosa fare adesso'"*, tutto dal
  /// corpus (decisione del fondatore del 20 ottobre 2026, "Carte dal
  /// corpus"). Senza il "Da dove viene", che chiude la consultazione una
  /// volta sola in fondo.
  static ResponsoInterpretato responsoDi(DrawnCard d, TarotTopicGroup gruppo,
          {int uscita = 0}) =>
      ResponsoInterpretato(
        arte: ArteInterpretata.tarocchi,
        titolo: titoloDi(d),
        risposta: letturaDiCasa(d, gruppo, uscita: uscita),
        cosaFare: cosaFareDi(d, gruppo, uscita: uscita),
      );

  /// Il verso come lo nomina la raccolta dei riti: e' la CHIAVE delle
  /// intestazioni di `docs/corpus/riti/contemplazione_dei_tarocchi.md`, non
  /// una parola mostrata (quella viene sempre da `TarotCard.reversedWord`,
  /// accordata al genere della carta: la guardia
  /// `tarot_accordo_rovescio_test.dart`).
  static const String _chiaveDelRovescio = "rovesciata";

  static String _versoDelRito(DrawnCard d) =>
      d.reversed ? _chiaveDelRovescio : 'dritta';

  /// **LA CONTEMPLAZIONE PROPIZIATORIA DELLA CARTA [d]**, ordine GA voce
  /// GA.04: la carta tenuta davanti agli occhi per qualche respiro, con una
  /// frase breve da ripetere legata al suo significato. Dal corpus dei riti
  /// (`docs/corpus/riti/contemplazione_dei_tarocchi.md`), mai dal modello:
  /// *"Nessuna formula inventata: ciò che non ha fonte non entra"*.
  static String? contemplazioneDi(DrawnCard d) => IRitiPropiziatori.rito(
      IRitiPropiziatori.contemplazione, [d.card.name, _versoDelRito(d)]);

  /// La riga del "Da dove viene" della contemplazione della carta [d].
  static String? fonteDellaContemplazione(DrawnCard d) =>
      IRitiPropiziatori.fonte(
          IRitiPropiziatori.contemplazione, [d.card.name, _versoDelRito(d)]);
}

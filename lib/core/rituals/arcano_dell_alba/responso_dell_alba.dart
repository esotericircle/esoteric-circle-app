import '../../tarot/tarot_card.dart';
import 'attribuzioni_degli_arcani.dart';
import 'forme_dell_alba.dart';
import 'lettura_dell_alba.dart';
import 'letture_dell_alba_dati.dart';
import 'stato_dell_alba.dart';

/// **IL RESPONSO DELL'ARCANO DELL'ALBA, in tre movimenti.** Ordine DT voce 08,
/// 17 settembre 2026.
///
/// Tre compiti disgiunti, e nessun movimento fa quello di un altro: **la
/// carta** nominata col verso e l'attribuzione; **il dono**, cioe' la parola
/// della carta e la cosa da fare; **la chiusura di Medora**, che e' il solo
/// posto dove puo' comparire il filo con ieri.
///
/// **Nessun modello.** Decisione di Mauro del 17 settembre 2026 e voce 21: il
/// testo si compone da letture scritte a mano, e che i movimenti non si
/// sovrappongano lo garantisce una prova sul corpus, non un controllo qui.
class ResponsoDellAlba {
  const ResponsoDellAlba({
    required this.lettura,
    required this.carta,
    required this.primo,
    required this.secondo,
    required this.terzo,
    this.ieri,
    this.relazione,
  });

  final LetturaDellAlba lettura;

  /// La carta del mazzo, per il disegno e per il nome.
  final TarotCard carta;

  /// La carta, col verso e l'attribuzione.
  final String primo;

  /// Il dono.
  final String secondo;

  /// La chiusura di Medora, col filo in fondo quando c'e'.
  final String terzo;

  /// Lo stato di ieri, quando il filo lo richiama.
  final StatoDellAlba? ieri;

  /// La relazione documentata che autorizza il filo.
  final RelazioneFraArcani? relazione;

  StatoDellAlba get stato => lettura.stato;
  AttribuzioneDellArcano get attribuzione => lettura.attribuzione;
  FamigliaDellArcano get famiglia => attribuzione.famiglia;
  String? get parola => lettura.parola;

  /// A che cosa serve il gesto del secondo movimento.
  String get perche => lettura.perche;

  /// La carta del mazzo dall'indice delle attribuzioni, per nome.
  static TarotCard cartaDi(int indice) {
    final nome = AttribuzioneDellArcano.tutte[indice].nomeDellaCarta;
    return TarotDeck.cards.firstWhere((c) => c.name == nome);
  }

  /// La carta nominata col suo verso, dentro una frase: *"la Torre
  /// rovesciata"*.
  static String cartaColVerso(StatoDellAlba stato) {
    final carta = cartaDi(stato.carta);
    return '${FormeDellAlba.nomeInFrase(carta.name)} '
        '${FormeDellAlba.verso(carta.reversedWord, rovescio: stato.rovescio)}';
  }

  /// Le letture di uno stato, nell'ordine del corpus.
  static List<LetturaDellAlba> lettureDi(StatoDellAlba stato,
          {List<LetturaDellAlba> corpus = lettureDellAlba}) =>
      [
        for (final l in corpus)
          if (l.stato == stato) l
      ];

  /// La relazione che il filo nomina fra oggi e ieri, dalla piu' stretta; null
  /// se non ce n'e' nessuna documentata.
  static RelazioneFraArcani? relazioneFra(
      StatoDellAlba oggi, StatoDellAlba ieri) {
    final trovate = RelazioniFraArcani.fra(
      AttribuzioneDellArcano.tutte[oggi.carta],
      AttribuzioneDellArcano.tutte[ieri.carta],
    );
    for (final r in FormeDellAlba.precedenza) {
      if (trovate.contains(r)) return r;
    }
    return null;
  }

  /// **COMPONE I TRE MOVIMENTI** da una lettura e dalle scelte gia' fatte.
  static ResponsoDellAlba componi(
    LetturaDellAlba lettura, {
    required int apertura,
    required int clausola,
    StatoDellAlba? ieri,
    int filo = 0,
  }) {
    final attribuzione = lettura.attribuzione;
    final clausole = FormeDellAlba.clausole[attribuzione.famiglia]!;
    final primo = '${FormeDellAlba.aperture[apertura]} '
        '${cartaColVerso(lettura.stato)}, '
        '${clausole[clausola % clausole.length].replaceAll('{di}', FormeDellAlba.diAttribuzione(attribuzione))}.';
    final relazione = ieri == null ? null : relazioneFra(lettura.stato, ieri);
    final forme = relazione == null ? null : FormeDellAlba.filo[relazione]!;
    final terzo = forme == null
        ? lettura.medora
        : '${lettura.medora} '
            '${forme[filo % forme.length].replaceAll('{ieri}', cartaColVerso(ieri!))}';
    return ResponsoDellAlba(
      lettura: lettura,
      carta: cartaDi(lettura.carta),
      primo: primo,
      secondo: lettura.dono,
      terzo: terzo,
      ieri: relazione == null ? null : ieri,
      relazione: relazione,
    );
  }
}

import 'dart:math';

import '../angels/angel_catalog.dart';
import '../angels/guardian_angels.dart';

/// **I TRE RUOLI DELL'ORACOLO DEGLI ANGELI.** Ordine FU voce FU.03, 15
/// ottobre 2026. Il fondatore: *"in onboarding però, assegniamo ad ogni
/// utente 3 angeli: Angelo Custode, Angelo del Cuore e Angelo
/// dell'intelletto"*.
///
/// Ogni carta dell'Oracolo e' portata da uno dei tre angeli della persona e
/// ha la sua posizione: il Custode porta la carta di cosa fare, il Cuore
/// quella di cosa sentire, l'Intelletto quella di cosa capire. L'ordine di
/// questo elenco e' l'ordine delle carte sull'altare e dei paragrafi del
/// responso (voce FU.06).
enum RuoloDellAngelo {
  custode(
    nome: 'Angelo Custode',
    posizione: 'Cosa fare',
    corpus: 'custode',
    medaglione: 'assets/img/oracolo_angeli/medaglione_custode_v1.webp',
  ),
  cuore(
    nome: 'Angelo del Cuore',
    posizione: 'Cosa sentire',
    corpus: 'cuore',
    medaglione: 'assets/img/oracolo_angeli/medaglione_cuore_v1.webp',
  ),
  intelletto(
    nome: 'Angelo dell\'Intelletto',
    posizione: 'Cosa capire',
    corpus: 'intelletto',
    medaglione: 'assets/img/oracolo_angeli/medaglione_intelletto_v1.webp',
  );

  const RuoloDellAngelo({
    required this.nome,
    required this.posizione,
    required this.corpus,
    required this.medaglione,
  });

  final String nome;

  /// La posizione della carta, detta come la vede la persona.
  final String posizione;

  /// Il file del corpus dei messaggi (`docs/corpus/oracolo_angeli/`).
  final String corpus;

  /// Il medaglione del ruolo, sopra la carta.
  final String medaglione;

  /// L'angelo della persona che porta la carta di questo ruolo. L'Angelo
  /// dell'Intelletto viene dall'ora di nascita: senza l'ora e' nullo, e la
  /// terza carta resta coperta con l'invito a inserirla (FU.03).
  Angel? dellaPersona(AngelTriad triade) => switch (this) {
        RuoloDellAngelo.custode => triade.guardian,
        RuoloDellAngelo.cuore => triade.heart,
        RuoloDellAngelo.intelletto => triade.intellect,
      };
}

/// **UNA CARTA DELL'ORACOLO**: l'angelo estratto fra i 72, il ruolo, e
/// l'angelo della persona che la porta (nullo per l'Intelletto senza ora).
class CartaDellOracolo {
  const CartaDellOracolo({
    required this.ruolo,
    required this.angelo,
    required this.portatore,
  });

  final RuoloDellAngelo ruolo;
  final Angel angelo;
  final Angel? portatore;

  /// La carta si scopre solo se si conosce chi la porta.
  bool get coperta => portatore == null;
}

/// **L'ESTRAZIONE**, sul telefono: tre angeli diversi a caso fra i 72, uno
/// per ruolo (FU.03). Il caso si passa da fuori, cosi' una prova lo fissa.
abstract final class EstrazioneDellOracolo {
  static List<CartaDellOracolo> estrai(AngelTriad triade, Random caso) {
    final numeri = <int>{};
    while (numeri.length < RuoloDellAngelo.values.length) {
      numeri.add(caso.nextInt(72) + 1);
    }
    final estratti = numeri.toList();
    return [
      for (var i = 0; i < RuoloDellAngelo.values.length; i++)
        CartaDellOracolo(
          ruolo: RuoloDellAngelo.values[i],
          angelo: AngelCatalog.byNumber(estratti[i]),
          portatore: RuoloDellAngelo.values[i].dellaPersona(triade),
        ),
    ];
  }

  /// **IL MAZZO COPERTO**, ordine FY voce FY.15: i 72 angeli in un ordine
  /// mescolato dal caso. La persona sceglie i dorsi; il dorso toccato e' la
  /// posizione nel mazzo, e la carta che esce e' quella che sta li'.
  static List<int> mescola(Random caso) =>
      [for (var n = 1; n <= 72; n++) n]..shuffle(caso);

  /// **LE CARTE SCELTE DALLA PERSONA**, ordine FY voce FY.15: una per
  /// posizione, nell'ordine dei ruoli (il primo dorso scelto e' la carta del
  /// Custode, il secondo del Cuore, il terzo dell'Intelletto). [numeri] sono
  /// i numeri degli angeli dei dorsi toccati, diversi fra loro.
  static List<CartaDellOracolo> dalleScelte(
      AngelTriad triade, List<int> numeri) {
    assert(numeri.length == RuoloDellAngelo.values.length &&
        numeri.toSet().length == numeri.length);
    return [
      for (var i = 0; i < RuoloDellAngelo.values.length; i++)
        CartaDellOracolo(
          ruolo: RuoloDellAngelo.values[i],
          angelo: AngelCatalog.byNumber(numeri[i]),
          portatore: RuoloDellAngelo.values[i].dellaPersona(triade),
        ),
    ];
  }
}

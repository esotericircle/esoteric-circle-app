/// I RIASSUNTI DELLA TIMELINE, TUTTI DETERMINISTICI. Ordine CG voce 02.
///
/// **Sono conti e fatti, mai prosa generata da un modello.** Nessuna chiamata
/// all'AI nasce dall'apertura della timeline, a nessuno dei quattro livelli.
/// La lettura in prosa esiste, sta nella voce CG.11, ed e' un'altra cosa: si
/// scrive una volta al mese, per chi ha il piano, e sui riassunti calcolati
/// qui invece che sui testi pieni.
///
/// **Si calcolano sul telefono, dai dati che il telefono ha gia'.** Aprire un
/// livello qualunque non deve costare NESSUNA lettura di Firestore quando
/// l'indice e' caldo, ed e' la misura di accettazione dell'ordine.
///
/// **UN GIORNO NON HA UN COLORE, ed e' una decisione del fondatore del 31
/// agosto 2026**: "e' probabile che ne usi piu' di uno e l'app spinge a
/// usarli giornalmente tutti e tre, a partire dai Doni del giorno". Il colore
/// del Maestro sta sulla singola voce. Qui si calcola il Maestro DOMINANTE di
/// un periodo, che e' un'altra cosa e si dichiara come tale: "soprattutto con
/// Caligo", non "il giorno di Caligo".
library;

import 'voce_del_ricordo.dart';

/// Il riassunto di un pezzo di tempo: un giorno, una settimana, un mese, un
/// anno. La stessa forma per tutti e quattro, perche' quattro forme diverse
/// darebbero quattro conteggi diversi della stessa cosa.
class RiassuntoDelTempo {
  const RiassuntoDelTempo({
    required this.chiave,
    required this.quanteVoci,
    required this.perMaestro,
    required this.perArte,
    required this.quantiTraguardi,
    required this.quantiDoni,
    required this.eosGuadagnati,
  });

  /// La chiave del periodo: `2026`, `2026-08`, `2026-08-31`, oppure la
  /// settimana come `2026-08-24..2026-08-30`.
  final String chiave;

  final int quanteVoci;

  /// Quante voci per Maestro. Vuoto quando non c'e' stato niente.
  final Map<String, int> perMaestro;

  /// Quante voci per arte, che e' cio' che regge il raggruppamento del giorno.
  final Map<String, int> perArte;

  final int quantiTraguardi;

  /// Quanti dei cinque Doni sono stati aperti in quel periodo, contati per
  /// arte distinta e non per volte: cinque Doni aperti tre volte fanno cinque.
  final int quantiDoni;

  final int eosGuadagnati;

  bool get vuoto => quanteVoci == 0;

  /// **IL MAESTRO DOMINANTE, e nullo quando non ce n'e' uno.**
  ///
  /// Nullo su un periodo vuoto e nullo IN CASO DI PAREGGIO: dire "soprattutto
  /// con Aura" quando Aura e Caligo stanno a pari merito sarebbe un fatto
  /// falso, e i riassunti di questa schermata sono fatti.
  String? get maestroDominante {
    if (perMaestro.isEmpty) return null;
    final ordinati = perMaestro.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (ordinati.length > 1 && ordinati[0].value == ordinati[1].value) {
      return null;
    }
    return ordinati.first.key;
  }

  /// Il peso del periodo rispetto al piu' pieno di quelli accanto, da 0 a 1.
  /// Serve alle dodici caselle dell'anno, che si leggono a colpo d'occhio.
  double pesoContro(int massimo) =>
      massimo <= 0 ? 0 : (quanteVoci / massimo).clamp(0.0, 1.0);
}

/// Chi calcola i riassunti. Non tocca la rete e non tocca nessun modello.
class RiassuntiDelTempo {
  const RiassuntiDelTempo._();

  /// **QUANTE VOCI UGUALI PRIMA DI RAGGRUPPARLE.** Ordine CG voce 02.
  ///
  /// **Tre, e il numero viene da un conto.** I tetti del giorno letti sulla
  /// matrice danno 14 voci al giorno al Viandante e 250 all'Illuminato: un
  /// elenco piatto regge a quattordici e non regge a duecentocinquanta.
  /// Raggruppando sopra le tre voci uguali, un giorno da 250 diventa al
  /// massimo un elenco di gruppi quanti sono i gesti che esistono, cioe'
  /// poco piu' di venti, mentre un giorno da 14 resta quasi tutto disteso.
  ///
  /// **Sotto le tre non si raggruppa**, perche' una riga che dice "Rune, due
  /// gettate" e si apre su due righe fa fare due tocchi per vedere cio' che
  /// stava gia' li'.
  static const int sopraQuanteSiRaggruppa = 3;

  /// Il riassunto di un elenco di voci gia' filtrato.
  static RiassuntoDelTempo di(
    String chiave,
    List<VoceDelRicordo> voci, {
    Set<String> gestiDeiDoni = const {},
    int eosGuadagnati = 0,
  }) {
    final perMaestro = <String, int>{};
    final perArte = <String, int>{};
    var traguardi = 0;
    for (final v in voci) {
      perMaestro[v.maestro] = (perMaestro[v.maestro] ?? 0) + 1;
      perArte[v.arte] = (perArte[v.arte] ?? 0) + 1;
      if (v.tipo == TipoDelRicordo.traguardo) traguardi++;
    }
    final doni = perArte.keys.where(gestiDeiDoni.contains).length;
    return RiassuntoDelTempo(
      chiave: chiave,
      quanteVoci: voci.length,
      perMaestro: Map.unmodifiable(perMaestro),
      perArte: Map.unmodifiable(perArte),
      quantiTraguardi: traguardi,
      quantiDoni: doni,
      eosGuadagnati: eosGuadagnati,
    );
  }

  /// Le voci di un giorno, raggruppate come vanno mostrate.
  ///
  /// Un gruppo con una voce sola e' una riga normale; un gruppo con piu' di
  /// [sopraQuanteSiRaggruppa] voci si mostra chiuso, col suo conto, e si apre
  /// toccandolo.
  static List<GruppoDelGiorno> gruppiDelGiorno(List<VoceDelRicordo> voci) {
    final perArte = <String, List<VoceDelRicordo>>{};
    for (final v in voci) {
      perArte.putIfAbsent(v.arte, () => []).add(v);
    }
    final fuori = <GruppoDelGiorno>[];
    for (final voce in perArte.entries) {
      final dentro = voce.value..sort((a, b) => a.quando.compareTo(b.quando));
      if (dentro.length > sopraQuanteSiRaggruppa) {
        fuori.add(GruppoDelGiorno(arte: voce.key, voci: dentro, chiuso: true));
      } else {
        for (final v in dentro) {
          fuori.add(GruppoDelGiorno(arte: voce.key, voci: [v], chiuso: false));
        }
      }
    }
    // In ordine di tempo, sulla PRIMA voce del gruppo: un gruppo sta dove il
    // suo primo gesto e' successo, che e' dove la persona lo cerca.
    fuori.sort((a, b) => a.voci.first.quando.compareTo(b.voci.first.quando));
    return List.unmodifiable(fuori);
  }

  /// Le chiavi dei giorni di una settimana, dal lunedi' alla domenica.
  static String chiaveDellaSettimana(DateTime giorno) {
    final lunedi = giorno.subtract(Duration(days: giorno.weekday - 1));
    final domenica = lunedi.add(const Duration(days: 6));
    return '${VoceDelRicordo.chiaveDelGiorno(lunedi)}'
        '..${VoceDelRicordo.chiaveDelGiorno(domenica)}';
  }

  /// Il lunedi' della settimana che contiene [giorno].
  static DateTime lunediDi(DateTime giorno) {
    final nudo = DateTime(giorno.year, giorno.month, giorno.day);
    return nudo.subtract(Duration(days: nudo.weekday - 1));
  }
}

/// Un gruppo di voci di uno stesso giorno.
class GruppoDelGiorno {
  const GruppoDelGiorno({
    required this.arte,
    required this.voci,
    required this.chiuso,
  });

  final String arte;
  final List<VoceDelRicordo> voci;

  /// Vero quando il gruppo si mostra col suo conto e si apre toccandolo.
  final bool chiuso;

  int get quante => voci.length;
}

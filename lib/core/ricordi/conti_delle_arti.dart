/// IL CONTO DI OGNI ARTE, DICHIARATO IN UN PUNTO SOLO. Ordine CG voce 10.
///
/// **Cosa dice l'ordine, e cosa vuol dire.** Per ogni arte si conserva il
/// CONTO e non il CONTENUTO: quante gettate, quante stese, quali traguardi,
/// quanti Eos, con quale Maestro, a che ora. Sono i numeri che reggono i
/// riassunti della timeline. Il contenuto di quei gesti non si conserva,
/// tranne i custoditi della voce CG.06.
///
/// **Perche' questo file esiste accanto a `GestiDelleArti`.** Quello dichiara
/// chi MANDA un gesto ai traguardi, e la sua guardia va dai traguardi ai
/// gesti: risponde alla domanda "questo traguardo puo' accendersi?". Qui la
/// domanda e' l'opposta e nessuno la faceva: "questa arte del catalogo scrive
/// il suo conto?". Un'arte nuova che nascesse domani senza scriverlo non
/// farebbe cadere nessuna delle guardie di prima, perche' nessun traguardo la
/// nominerebbe: comparirebbe nel Santuario e sparirebbe dai Ricordi, e la
/// timeline della persona avrebbe un buco che nessuno vede.
///
/// **Un'arte senza conto si DICHIARA, non si nasconde.** E' la stessa regola
/// di `GestiDelleArti`: dove il conto non c'e' si scrive perche', e la
/// guardia legge la ragione invece di ignorare la riga.
library;

import '../rituals/daily_elements.dart';

/// Il legame fra un'arte del catalogo e il gesto che ne tiene il conto.
class ContoDellArte {
  const ContoDellArte({
    required this.arte,
    this.gesto,
    this.perche,
  });

  /// L'identificativo dell'arte, quello di `ArtCatalog`.
  final String arte;

  /// Il gesto che il Diario del Cammino registra per quest'arte, cioe' la
  /// parola che finisce in `DiarioDelCammino.segna`. Nullo quando l'arte non
  /// tiene un conto, e allora [perche] lo dice.
  final String? gesto;

  /// Perche' quest'arte non tiene un conto, quando non lo tiene.
  final String? perche;

  bool get contato => gesto != null;
}

/// L'elenco, arte per arte.
class ContiDelleArti {
  const ContiDelleArti._();

  /// **SOLO LE ARTI VIVE.** Le arti in arrivo non hanno una schermata, quindi
  /// non hanno niente da contare: pretendere un conto da loro vorrebbe dire
  /// scrivere oggi il nome di un gesto che nascera' fra sei mesi, e un nome
  /// scritto in anticipo e' un nome che nessuno rilegge quando l'arte arriva.
  /// La guardia lo verifica sullo STATO del catalogo, non su questo elenco.
  static const List<ContoDellArte> tutte = [
    ContoDellArte(arte: 'horoscope', gesto: 'oroscopo'),
    ContoDellArte(arte: 'synastry_vip', gesto: 'sinastria'),
    ContoDellArte(arte: 'tarot_spread_three', gesto: 'stesa'),
    ContoDellArte(arte: 'archetype_test', gesto: 'archetipo'),
    ContoDellArte(arte: 'face_constellation', gesto: 'viso'),
    ContoDellArte(arte: 'rune_draw', gesto: 'gettata'),
    ContoDellArte(arte: 'guide_animal', gesto: 'animale_guida'),
    ContoDellArte(arte: 'magic_sigil', gesto: 'sigillo'),
    // **LA MEDITAZIONE CONTA, e il suo gesto e' dichiarato dormiente
    // altrove.** L'ordine BS voce 01 aveva gia' scritto che i gradini della
    // meditazione esistono e il corpus li tiene dormienti, perche' oggi la
    // meditazione non ha una fine che la scena possa segnare. Il GESTO pero'
    // c'e' e la schermata lo manda: nei Ricordi una meditazione aperta e' un
    // momento della giornata come gli altri, e va contata.
    ContoDellArte(arte: 'meditation', gesto: 'meditazione'),
  ];

  static ContoDellArte? di(String arte) {
    for (final c in tutte) {
      if (c.arte == arte) return c;
    }
    return null;
  }

  /// Il gesto che tiene il conto di un'arte, quando c'e'.
  static String? gestoDi(String arte) => di(arte)?.gesto;

  /// Le arti censite che un conto ce l'hanno.
  static List<ContoDellArte> get contate =>
      tutte.where((c) => c.contato).toList(growable: false);

  /// Le arti censite che un conto non ce l'hanno, con la loro ragione.
  static List<ContoDellArte> get senzaConto =>
      tutte.where((c) => !c.contato).toList(growable: false);

  /// **I DONI DEL GIORNO, che arti del catalogo non sono.**
  ///
  /// I cinque Doni non compaiono in `ArtCatalog` perche' non sono arti dello
  /// scaffale: sono il rito quotidiano. Contano lo stesso, e nella timeline
  /// sono le voci piu' frequenti di una giornata, quindi il loro conto va
  /// dichiarato qui invece di darlo per scontato.
  ///
  /// **La chiave e' il Dono e non una stringa a mano**: cosi' un Dono nuovo
  /// che nascesse domani non potrebbe entrare nell'elenco dei Doni senza
  /// entrare anche qui, e la guardia lo vede.
  static const Map<DailyElement, String> gestiDeiDoni = {
    DailyElement.dawn: 'alba',
    DailyElement.breath: 'soffio',
    DailyElement.oracle: 'oracolo',
    DailyElement.rune: 'tramonto',
    DailyElement.night: 'sogno',
  };

  /// Il gesto di un Dono, che e' il suo conto.
  static String? gestoDelDono(DailyElement dono) => gestiDeiDoni[dono];

  /// **TUTTI I GESTI CHE LA TIMELINE PUO' MOSTRARE**, arti e Doni insieme.
  static List<String> get tuttiIGesti => [
        for (final c in contate) c.gesto!,
        ...gestiDeiDoni.values,
      ];
}

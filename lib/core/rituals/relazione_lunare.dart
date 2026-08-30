import '../astro/zodiac.dart';

/// LA RELAZIONE FRA LA LUNA DI STANOTTE E LA TUA. Ordine CE voce 13.
///
/// **E' l'aspetto per segno, tecnica occidentale documentata.** Nella pratica
/// astrologica classica il rapporto fra un pianeta in transito e lo stesso
/// pianeta natale si legge dall'angolo che li separa, e quando si lavora per
/// segno e non per grado gli angoli diventano cinque: congiunzione a zero,
/// sestile a sessanta, quadratura a novanta, trigono a centoventi, opposizione
/// a centottanta. La Luna in transito sulla Luna natale e' anzi l'esempio da
/// manuale, perche' e' il ciclo piu' breve e piu' sentito: si chiude in
/// ventotto giorni e ognuno lo riconosce addosso.
///
/// **Perche' serve qui.** Il quarto fumetto del tutorial promette che i cinque
/// Doni nascono "incrociando il Cielo di oggi e la tua Carta natale". Il
/// Sigillo del Sogno, misurato, guardava soltanto la Luna di stanotte: era la
/// stessa notte identica per tutti. La Luna di nascita e' il dato natale che
/// questo Dono ha gia' nelle mani, ed e' calcolabile sul telefono senza rete.
///
/// **La premessa dell'ordine su questo Dono era falsa.** L'ordine dava il
/// Sigillo per "Luna di stanotte e Luna di nascita, cielo si', carta natale
/// no". Misurato: la Luna di nascita non c'era affatto.
enum RelazioneLunare {
  congiunzione(
    passi: 0,
    nome: 'congiunzione',
    riga: 'Stanotte la Luna torna dov\'era quando sei nato: è il tuo ritorno '
        'lunare, il momento in cui il sentire ricomincia da capo.',
  ),
  sestile(
    passi: 2,
    nome: 'sestile',
    riga: 'Stanotte la Luna guarda la tua di sbieco, in sestile: una mano '
        'tesa, che però va presa.',
  ),
  quadratura(
    passi: 3,
    nome: 'quadratura',
    riga: 'Stanotte la Luna taglia la tua ad angolo retto: una tensione che '
        'chiede un movimento, non una risposta.',
  ),
  trigono(
    passi: 4,
    nome: 'trigono',
    riga: 'Stanotte la Luna e la tua si guardano in trigono, lo stesso '
        'elemento: quello che senti scorre senza attrito.',
  ),
  opposizione(
    passi: 6,
    nome: 'opposizione',
    riga: 'Stanotte la Luna sta esattamente di fronte alla tua. Certe figure '
        'si vedono bene solo da lontano.',
  ),
  nessuna(
    passi: -1,
    nome: 'nessun aspetto',
    riga: 'Stanotte la Luna non forma nessun angolo maggiore con la tua: una '
        'notte che non tira da nessuna parte.',
  );

  const RelazioneLunare({
    required this.passi,
    required this.nome,
    required this.riga,
  });

  /// Quanti segni separano le due Lune, contati per la via piu' breve.
  final int passi;

  /// Il nome dell'aspetto, come lo chiama la tradizione.
  final String nome;

  /// **TESTO PROVVISORIO, da approvare.** La riga che entra nel responso: i
  /// testi definitivi li approva il fondatore.
  final String riga;

  /// La relazione fra la Luna di [stanotte] e quella di [nascita], per segno.
  ///
  /// La distanza si conta per la via piu' breve, perche' un aspetto e' un
  /// angolo e un angolo non ha verso: sette segni avanti e cinque indietro
  /// sono lo stesso angolo.
  static RelazioneLunare fra(Zodiac stanotte, Zodiac nascita) {
    final avanti = (stanotte.index - nascita.index) % 12;
    final passi = avanti > 6 ? 12 - avanti : avanti;
    for (final r in RelazioneLunare.values) {
      if (r.passi == passi) return r;
    }
    return RelazioneLunare.nessuna;
  }
}

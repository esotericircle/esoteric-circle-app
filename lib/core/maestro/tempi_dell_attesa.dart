/// QUANTO DURA L'ATTESA, e perche' dura esattamente cosi'.
///
/// **Il dato che ha fatto nascere questo file.** La risposta arrivava di colpo
/// e sapeva di macchina: nessuna pausa, nessun segno che qualcuno stesse
/// guardando qualcosa. La scena del consulto esisteva gia' ma durava quanto
/// durava la rete, quindi con una rete veloce lampeggiava e spariva.
///
/// **I numeri non sono stimati, sono misurati.** Dieci chiamate reali IN FILA
/// sulla strada viva il 3 agosto 2026, non in parallelo, perche' cinque per
/// volta si accodano fra loro e gonfierebbero il numero:
///
/// ```
/// RETE   minimo 1,21s   mediana 1,51s   massimo 1,83s
/// ```
///
/// Da PC su rete fissa, quindi un telefono su rete mobile sta piu' in alto: per
/// questo il tetto tiene un margine largo invece di stare al filo del misurato.
class TempiDellAttesa {
  const TempiDellAttesa._();

  /// Quanto resta a schermo ogni riga del consulto.
  static const Duration durataBattuta = Duration(milliseconds: 900);

  /// QUANTO DURA LA SCENA COME MINIMO, anche se la risposta arriva prima.
  ///
  /// Senza questo la scena viveva quanto la rete, cioe' fra 1,21s e 1,83s, e
  /// con la rete al minimo compariva e spariva: un lampo non e' una pausa, e
  /// una pausa che lampeggia da' meno credibilita' di nessuna pausa.
  ///
  /// Due battute intere, cosi' chi guarda vede il Maestro passare da un dato
  /// suo a un pensiero suo. Sta sopra la rete mediana misurata, quindi nel caso
  /// tipico e' questo numero a comandare e non la rete.
  static const Duration durataMinima = Duration(milliseconds: 1800);

  /// Quanto ci mette la scena a sparire quando la risposta e' pronta.
  ///
  /// Non sparisce di colpo: se la risposta arriva prima della durata minima la
  /// scena si chiude in dissolvenza, e nessuna parola viene tagliata.
  static const Duration dissolvenza = Duration(milliseconds: 260);

  /// CON RIDUCI MOVIMENTO I TEMPI SI ACCORCIANO.
  ///
  /// Chi ha chiesto di non vedere movimento non ha chiesto di aspettare di
  /// piu': resta la riga che dichiara cosa il Maestro sta consultando, e la
  /// pausa si riduce a quanto basta perche' la riga si legga.
  static const Duration durataMinimaRidotta = Duration(milliseconds: 700);

  /// IL TETTO ALLA PRIMA PAROLA. Oltre questo la credibilita' diventa attesa.
  static const Duration tettoAllaPrimaParola = Duration(seconds: 4);

  /// IL TETTO AL TESTO COMPLETO, cioe' quando la persona ha finito di leggere
  /// comparire l'ultima lettera.
  static const Duration tettoAlTestoCompleto = Duration(seconds: 10);

  /// La rete PEGGIORE misurata il 3 agosto 2026, in millisecondi.
  ///
  /// Sta qui come dato e non come commento perche' una prova ci calcola sopra:
  /// il tempo alla prima parola e' `max(rete, durataMinima) + dissolvenza`, ed
  /// e' un massimo e non una somma, perche' la scena e la rete corrono insieme.
  static const int reteMassimaMisurataMs = 1830;

  /// Quanti caratteri al secondo scrive la macchina da scrivere.
  ///
  /// Sessanta: su settanta parole italiane, che sono circa quattrocentotrenta
  /// caratteri, fanno poco piu' di sette secondi. E' la velocita' a cui il
  /// testo si legge mentre compare invece di essere raggiunto dagli occhi.
  static const double caratteriAlSecondo = 60;

  /// Quanto dura la scrittura di [caratteri], senza sforare [tetto].
  ///
  /// **Il tetto non e' un dettaglio.** A sessanta caratteri al secondo una
  /// risposta da centosedici parole, che e' la piu' lunga misurata, ci
  /// metterebbe dodici secondi da sola: sforerebbe il tetto ai dieci senza che
  /// nessuno se ne accorga finche' non capita a qualcuno. Quando il testo e'
  /// lungo si scrive piu' in fretta, perche' fra le due cose che decidono il
  /// tempo, quante parole scrive il modello e quanto in fretta le mostriamo,
  /// **la seconda e' l'unica che possiamo scegliere**.
  static Duration durataDiScrittura(int caratteri, Duration tetto) {
    final naturale = Duration(
        milliseconds: (caratteri / caratteriAlSecondo * 1000).round());
    return naturale > tetto ? tetto : naturale;
  }

  /// Il tempo alla prima parola con una rete di [reteMs].
  ///
  /// Pubblico apposta: la prova non rifa' il conto per conto suo, chiama
  /// questo. Due copie della stessa aritmetica divergono, e allora la prova
  /// finisce per verificare se stessa.
  static Duration allaPrimaParola(int reteMs, {bool riduciMovimento = false}) {
    final minima = riduciMovimento ? durataMinimaRidotta : durataMinima;
    final scena = reteMs > minima.inMilliseconds ? reteMs : minima.inMilliseconds;
    return Duration(
        milliseconds: scena + (riduciMovimento ? 0 : dissolvenza.inMilliseconds));
  }

  /// Quanto tempo resta alla macchina da scrivere per finire dentro il tetto.
  ///
  /// **Serve perche' il tetto vale anche sulla risposta piu' lunga.** A
  /// sessanta caratteri al secondo una risposta da centosedici parole
  /// impiegherebbe dodici secondi da sola, cioe' sforerebbe il tetto senza che
  /// nessuno se ne accorga finche' non capita. Quando il testo e' lungo si
  /// scrive piu' in fretta invece di sforare: e' l'unica delle due cose che
  /// possiamo scegliere.
  static Duration perScrivere(int reteMs, {bool riduciMovimento = false}) {
    final speso = allaPrimaParola(reteMs, riduciMovimento: riduciMovimento);
    final resto = tettoAlTestoCompleto - speso;
    return resto.isNegative ? Duration.zero : resto;
  }
}

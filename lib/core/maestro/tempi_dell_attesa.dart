/// QUANTO DURA L'ATTESA, e perche' dura esattamente cosi'.
///
/// **Il dato che ha fatto nascere questo file.** La risposta arrivava di colpo
/// e sapeva di macchina: nessuna pausa, nessun segno che qualcuno stesse
/// guardando qualcosa. La scena del consulto esisteva gia' ma durava quanto
/// durava la rete, quindi con una rete veloce lampeggiava e spariva.
///
/// **I numeri non sono stimati, sono misurati.** Chiamate reali IN FILA sulla
/// strada viva, non in parallelo, perche' cinque per volta si accodano fra
/// loro e gonfierebbero il numero.
///
/// ```
/// 3 agosto 2026, dieci chiamate: minimo 1,21s  mediana 1,51s  massimo 1,83s
/// 4 agosto 2026, dieci chiamate: minimo 1,19s  mediana 1,41s  massimo 2,09s
/// 4 agosto 2026, dieci chiamate: minimo 1,22s  mediana 1,54s  massimo 1,73s
/// ```
///
/// Le due misure del 4 agosto sono le prime possibili: fino al 3 lo strumento
/// prendeva `429 RESOURCE_EXHAUSTED` e la misura restava parziale, per via
/// dell'account di fatturazione ancora di prova.
///
/// Da PC su rete fissa, quindi un telefono su rete mobile sta piu' in alto: per
/// questo il tetto tiene un margine largo invece di stare al filo del misurato.
class TempiDellAttesa {
  const TempiDellAttesa._();

  /// QUANTE BATTUTE HA LA SCENA COME MINIMO GARANTITO. DUE.
  ///
  /// **Minimo, non massimo.** Fino al 4 agosto 2026 erano tutte quelle che la
  /// scena mostrava, e finite quelle finiva la scena. Adesso se la risposta
  /// tarda le frasi RICOMINCIANO dalla prima, senza che l'emblema si scolori:
  /// un caricamento che riparte da zero dice che qualcosa e' andato storto,
  /// e non e' andato storto niente, sta solo rispondendo.
  ///
  /// **Il dato che ha fatto scendere questo numero.** Erano tre, e sul telefono
  /// del fondatore con la build 2140 ognuna durava MENO DI UN SECONDO: tre
  /// battute dentro un'attesa da due o tre secondi non sono una riflessione,
  /// sono un lampo ripetuto tre volte.
  ///
  /// La correzione non poteva essere allungare l'attesa, perche' il tetto alla
  /// prima parola resta quattro secondi e non si sposta. Restava l'altra strada:
  /// meno battute, ciascuna abbastanza lunga da leggersi.
  ///
  /// Due e non una: chi guarda vede il Maestro passare da un DATO suo a un
  /// PENSIERO suo, che e' la cosa che rende la pausa una riflessione invece di
  /// un caricamento con sopra una frase.
  static const int battuteDellaScena = 2;

  /// Quanto resta a schermo ogni riga del consulto.
  ///
  /// DUEMILA, netti. Il numero e' salito due volte, e ogni volta perche' il
  /// fondatore lo ha guardato sul telefono e non si faceva in tempo a leggere:
  /// da 900 a 1600 il 4 agosto 2026, da 1600 a 2000 il giorno dopo. A 1600 le
  /// due righe stavano dentro i 3,46 secondi della prima parola, dissolvenza
  /// compresa, e sembravano sei difetti di seguito.
  static const Duration durataBattuta = Duration(milliseconds: 2000);

  /// QUANTO DURA LA SCENA COME MINIMO, anche se la risposta arriva prima.
  ///
  /// Senza questo la scena viveva quanto la rete, cioe' fra 1,21s e 1,83s, e
  /// con la rete al minimo compariva e spariva: un lampo non e' una pausa, e
  /// una pausa che lampeggia da' meno credibilita' di nessuna pausa.
  ///
  /// **NON E' UN NUMERO SCRITTO, E' IL PRODOTTO DEGLI ALTRI DUE.** La scena
  /// dura quanto le sue battute intere: chi domani cambia quante sono o quanto
  /// durano non deve ricordarsi di venire a correggere anche qui, perche' due
  /// numeri che devono restare d'accordo prima o poi non lo restano.
  ///
  /// Oggi fa 3200 millisecondi, cioe' due battute da 1600. Con la dissolvenza
  /// il tempo alla prima parola diventa 3460, sotto il tetto di quattro secondi
  /// con 540 millisecondi di margine, e sopra la rete peggiore misurata di
  /// 1830: nel caso tipico e' questo numero a comandare, non la rete.
  /// `final` e non `const` perche' un prodotto fra una Duration e un intero non
  /// e' costante: e' il prezzo per non riscrivere il 1600 una seconda volta,
  /// che sarebbe proprio il difetto contro cui questa riga esiste.
  static final Duration durataMinima = durataBattuta * battuteDellaScena;

  /// QUANTO CI METTE L'EMBLEMA A COLORARSI, da monocromo a colore pieno.
  ///
  /// Tre secondi, cioe' meno dei quattro del minimo garantito: quando la
  /// seconda frase finisce, l'emblema e' gia' pieno da un secondo. Se durasse
  /// quanto la scena, chi guarda vedrebbe una barra di avanzamento travestita
  /// da emblema, e una barra promette una fine che noi non conosciamo.
  ///
  /// Non pulsa, non ruota, non ricomincia. Arrivato pieno resta pieno, anche
  /// se la risposta tarda e le frasi ripartono.
  static const Duration colorazioneDellEmblema = Duration(seconds: 3);

  /// QUANTO RESTA FERMO SUL GRIGIO SPENTO, prima di cominciare a salire.
  ///
  /// **Il numero che ha fatto nascere questa attesa.** La curva era lineare su
  /// tre secondi, e la saturazione dell'arte arriva al massimo a 0,4263: a
  /// meta' tempo il colore c'era gia' quasi tutto, quindi il grigio, che e' il
  /// segnale, durava un istante. Un secondo intero fermo sullo spento e' cio'
  /// che rende leggibile "aspetta, sto lavorando".
  static const Duration grigioPrimaDiSalire = Duration(seconds: 1);

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
  ///
  /// **Salito da quattro secondi a quattro e mezzo il 5 agosto 2026, ed e' una
  /// decisione del fondatore, non una deriva.** Due righe da due secondi fanno
  /// quattro secondi di scena, piu' la dissolvenza: 4260. Il vecchio tetto
  /// avrebbe vietato la scena che l'ordine chiede. Quando due vincoli si
  /// contraddicono, chi decide e' chi ha guardato lo schermo.
  static const Duration tettoAllaPrimaParola = Duration(milliseconds: 4500);

  /// IL TETTO AL TESTO COMPLETO, cioe' quando la persona ha finito di leggere
  /// comparire l'ultima lettera.
  static const Duration tettoAlTestoCompleto = Duration(seconds: 10);

  /// La rete PEGGIORE misurata, in millisecondi, su tutte le esecuzioni.
  ///
  /// Sta qui come dato e non come commento perche' una prova ci calcola sopra:
  /// il tempo alla prima parola e' `max(rete, durataMinima) + dissolvenza`, ed
  /// e' un massimo e non una somma, perche' la scena e la rete corrono insieme.
  ///
  /// **Saliva da 1830 il 4 agosto 2026.** Le prime dieci chiamate riuscite
  /// dopo il rientro dal 429 hanno reso un massimo di 2090, cioe' oltre un
  /// quarto in piu' di quanto la costante dichiarasse. Lasciarla a 1830 avrebbe
  /// voluto dire una costante che dichiara il falso, e per giunta nel verso che
  /// fa sembrare il margine piu' largo di quanto sia.
  static const int reteMassimaMisurataMs = 2090;

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
  /// Quanto si sta SOTTO il tetto invece di arrivarci al filo.
  ///
  /// Senza, il conto atterrava esatto su dieci secondi e zero millesimi per
  /// ogni risposta abbastanza lunga, perche' il tetto e' quello che decide.
  /// "Meno di dieci secondi" non e' "dieci secondi": un vincolo rispettato
  /// all'uguale e' un vincolo che il primo arrotondamento fa saltare.
  static const Duration margineSottoIlTetto = Duration(milliseconds: 300);

  static Duration perScrivere(int reteMs, {bool riduciMovimento = false}) {
    final speso = allaPrimaParola(reteMs, riduciMovimento: riduciMovimento);
    final resto = tettoAlTestoCompleto - margineSottoIlTetto - speso;
    return resto.isNegative ? Duration.zero : resto;
  }
}

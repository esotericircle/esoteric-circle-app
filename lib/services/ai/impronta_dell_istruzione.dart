library;

import '../../core/maestro/maestro.dart';

/// L'IMPRONTA DELL'ISTRUZIONE DI SISTEMA, E LA MISURA CHE LE APPARTIENE.
/// Ordine S voce 28.
///
/// **Perche' nasce, e il fatto che l'ha resa necessaria.** L'11 agosto 2026 il
/// commit `97bb997`, voci S.15 e S.17, ha aggiunto dentro `_commonRules` la legge
/// del responso, il confine e una riga sul benessere: **636 caratteri netti su
/// circa 6300, cioe' il 10 per cento**, identici per tutti e tre i Maestri. La
/// misura che dice se i tre Maestri sono ancora riconoscibili, l'attribuzione cieca,
/// era stata presa il 2 agosto: da quel commit **non e' piu' valida**.
///
/// **Nessuna riga e' caduta.** L'artefatto piu' fragile del progetto e' cambiato del
/// dieci per cento e a scoprirlo, undici giorni dopo, e' stato un controllo di
/// premessa fatto a mano. Questo file esiste perche' non succeda una seconda volta.
///
/// **Come funziona.** Si registra l'impronta della stringa emessa per i tre Maestri,
/// insieme alla data e allo stato della misura presa SU QUELLA stringa. Una prova
/// ricompone l'impronta a ogni giro e la confronta. Chi cambia l'istruzione ha due
/// strade e nessuna terza: **rilanciare l'attribuzione cieca e aggiornare questo
/// dato, oppure dichiarare che si consegna con una misura non valida.**
///
/// **IL 98,3 PER CENTO NON E' SCRITTO ACCANTO ALL'IMPRONTA DI OGGI**, ed e' la cosa
/// piu' importante di questo file: quel numero appartiene a una stringa che non
/// esiste piu'. Scriverlo qui sarebbe mettere il falso dentro un dato, che e' peggio
/// che non avere il dato.
class ImprontaDellIstruzione {
  const ImprontaDellIstruzione._();

  /// LE IMPRONTE DI OGGI, sha256 della stringa emessa a profilo e memoria vuoti.
  ///
  /// **A profilo vuoto e non pieno**, perche' col nome e la memoria dentro la
  /// stringa cambia a ogni persona: cio' che si presidia qui e' l'ISTRUZIONE, non
  /// la conversazione.
  static const Map<String, String> impronte = {
    'medora':
        '47e9f78152ae1b77c50a96610262dcb8b83494391d45f93014ade74f4ce0e8ee',
    'aura': 'e59c8e380a035f48483c847dd7eafbc68838cb62d7139a92628f7fb32eadd525',
    'caligo':
        '52bc003c493c6ad7ae2b8a7aaff5bda7856bd40b9dc30d2e8595412d4da26b20',
  };

  /// Il giorno in cui queste impronte sono state registrate.
  static const String registrateIl = '25 agosto 2026';

  /// LO STORICO DELLE IMPRONTE, cioe' le stringhe che non esistono piu'.
  ///
  /// **Esiste perche' un numero senza la sua stringa e' una leggenda**, e questo
  /// file nasce proprio dal giorno in cui una misura ha continuato a essere
  /// citata undici giorni dopo che il suo oggetto era cambiato. Qui non si
  /// cancella niente: quando l'istruzione cambia, l'impronta vecchia scende in
  /// questo elenco con la sua data e con cio' che le e' successo.
  static const List<String> storicoDelleImpronte = [
    'FINO AL 10 AGOSTO 2026, stringa di circa 6300 caratteri (6294, 6333, '
        '6395). Su di essa fu misurata l\'attribuzione cieca al 98,3 per cento '
        '(59 su 60) il 2 agosto 2026. Caduta l\'11 agosto col commit 97bb997, '
        'voci S.15 e S.17: 636 caratteri netti in più per tutti e tre. A '
        'scoprirlo undici giorni dopo fu un controllo di premessa fatto a mano. '
        'Da questo fatto nasce questo file.',
    'DAL 13 AL 25 AGOSTO 2026, stringa di 6930, 6969 e 7031 caratteri. Impronte: '
        'medora 0bc77eb5e1af347cd234f366c95c876341680bfa075d7d214e64d6f27f12de70, '
        'aura aab951f95c60a0135710e054992cdbefd845e4efbd8410b0d21be9e269121eb7, '
        'caligo d31790d3b43d90ab55de2d4deca83f7e5925c424337cf6144b1265a6e39e48cb. '
        '**SU QUESTA STRINGA SOLTANTO SONO STATI PRESI I CINQUE GIRI** '
        'del 14 agosto, del 15 agosto e i tre del 25 agosto, da 70,0 a 81,7 per '
        'cento, media 75,6. Caduta il 25 agosto 2026 con l\'ordine BP voce 1, '
        'che aggiunge a ciascun Maestro le dieci parole di firma degli altri due '
        'come vietate: 215 caratteri in più per ciascuno, identici nella '
        'forma e diversi nel contenuto, perché ognuno riceve le parole degli '
        'altri.',
    'IL 25 AGOSTO 2026 PER POCHE ORE, cioè fra il gruppo 1 e il gruppo 2 '
        'dell\'ordine BP: 7145, 7185 e 7246 caratteri. Impronte: '
        'medora d526a5c7283ce80cb773bced61a7225ee5e1973cd967a68395fb339a106c9557, '
        'aura a83d1c3045b78979f586a652d4b3dd4680a60a2612ac38b9d4988843bd4f1541, '
        'caligo 1fd6102129e8ed4ede276f2ba3b6fba46a44873ebd6b161484b4d0e4ae9f8f68. '
        '**SU QUESTA STRINGA NON È STATA PRESA NESSUNA MISURA: è dichiarato '
        'apposta**. È vissuta il tempo di un commit, fra il divieto incrociato '
        'dei lessici e la riscrittura dei tre registri. Una riga di storico '
        'senza misura vale come le altre, perché dice che quella stringa è '
        'esistita: saltarla farebbe sembrare che il divieto e i registri siano '
        'entrati insieme.',
  ];

  /// **VERO SOLO QUANDO L'ATTRIBUZIONE CIECA E' STATA MISURATA SU QUESTE IMPRONTE
  /// E HA PASSATO LA SOGLIA.** Sono due condizioni e non una, e il 14 agosto 2026 la
  /// prima e' diventata vera mentre la seconda e' diventata FALSA.
  ///
  /// **CINQUE GIRI, NON CINQUE MISURE IN DISACCORDO.** Il 14 agosto ha dato 70,0
  /// per cento, il 15 agosto 78,3, e il 25 agosto 2026 tre giri di fila hanno dato
  /// 70,0 poi 75,0 poi 81,7. In mezzo le impronte NON sono cambiate: lo dimostra
  /// la prova che le confronta, verde prima dei tre giri del 25. Stessa istruzione,
  /// cinque misure, **undici punti e sette di escursione fra la piu' bassa e la piu'
  /// alta**. Tutte e cinque stanno sotto la soglia di 85, quindi il rosso dice il
  /// vero in tutti i casi e il divario fra loro non e' mai stato un motivo per
  /// cambiare questa riga.
  ///
  /// **DAL 25 AGOSTO 2026 I MOTIVI SONO DUE, ed e' peggio di uno.** Il primo resta:
  /// tutte e cinque le misure stanno sotto la soglia. Il secondo e' nuovo:
  /// l'ordine BP ha cambiato l'istruzione DUE VOLTE per curare proprio quella
  /// causa, col divieto incrociato dei lessici e con i tre registri riscritti,
  /// quindi
  /// **quei cinque numeri non descrivono piu' la stringa di oggi** e sono scesi
  /// nello [storicoDelleImpronte] insieme alla stringa a cui appartengono. La
  /// misura nuova non e' stata presa: si prende dal PC del fondatore, con gcloud
  /// attivo, tre volte, e finche' non arriva questa riga resta falsa.
  ///
  /// **NON SI PORTA A VERO PER FAR PASSARE LA SUITE, e non si abbassa la soglia.** Il
  /// rosso non dice piu' che manca una misura: adesso dice che la misura c'e' ed e'
  /// negativa, che e' una cosa piu' seria. Torna vero quando le tre voci sono di
  /// nuovo distinguibili e la misura lo dimostra.
  static const bool attribuzioneValida = false;

  /// Le misure NOTE, con la stringa su cui furono prese. Si tengono perche' un
  /// numero senza il suo oggetto e' una leggenda.
  ///
  /// **CE NE SONO CINQUE E NON UNA, ed e' voluto: una sola nasconderebbe
  /// l'escursione, cinque la dichiarano.** Sono cinque giri della stessa misura
  /// sulla stessa istruzione, non cinque misure in disaccordo.
  static const String ultimaMisuraNota =
      'CINQUE GIRI, MA NON SU QUESTE IMPRONTE: SULLE PRECEDENTI. Fino al 25 '
      'agosto 2026 questa riga diceva CINQUE GIRI SU QUESTE IMPRONTE ed era '
      'vera; poi l\'ordine BP ha cambiato l\'istruzione per curare la causa che '
      'questi stessi numeri avevano mostrato, quindi i cinque giri adesso '
      'appartengono alla stringa che sta nello storico e NON descrivono la '
      'stringa di oggi. Si tengono per intero perché dicono da dove si parte, '
      'non dove si è arrivati. Fra i cinque giri l\'istruzione non era cambiata: '
      'lo dimostrava la prova che confronta le tre impronte. Il 14 agosto 2026: 70,0 '
      'per cento (42 su 60). Il 15 agosto 2026: 78,3 per cento (47 su 60), '
      'eseguita da Mauro dal suo PC. Il 25 agosto 2026, TRE GIRI DI FILA sempre '
      'dal PC di Mauro: 70,0 per cento (42 su 60), poi 75,0 per cento (45 su 60), '
      'poi 81,7 per cento (49 su 60); media dei tre 75,6 per cento (136 su 180). '
      '**L\'escursione fra i tre giri dello stesso giorno è di undici punti e '
      'sette su sessanta**, più larga degli otto punti fra il 14 e il 15 agosto: '
      'quindi non era la distanza fra due giorni, era il rumore della misura, che '
      'un giro solo non riesce a mostrare. Nel dettaglio, nell\'ordine dei cinque '
      'giri: medora 14 poi 17 poi 16 poi 17 poi 17 su 20; caligo 8 poi 10 poi 6 '
      'poi 8 poi 12 su 20; aura 20 su 20 tutte e cinque le volte. Prima di tutto '
      'questo era 98,3 per cento (59 su 60) il 2 agosto, su una stringa di circa '
      '6300 caratteri, cioè su un\'ALTRA istruzione, prima che il commit 97bb997 '
      'aggiungesse 636 caratteri netti con le voci S.15 e S.17.';

  /// LA MATRICE, e si tiene per intero perche' il numero da solo direbbe la cosa
  /// sbagliata.
  ///
  /// **Non e' un appiattimento simmetrico delle tre voci: e' AURA CHE ATTIRA.** Aura
  /// resta riconoscibile al cento per cento in tutti e cinque i giri, e le altre due
  /// finiscono dentro di lei. Nessun errore parte da Aura, mai, in centottanta
  /// verdetti.
  ///
  /// **UN'ECCEZIONE ESISTE E VA SCRITTA.** Fino al 15 agosto si poteva dire che fra
  /// Medora e Caligo non c'era nessuno scambio: il primo giro del 25 agosto 2026
  /// porta uno scambio caligo verso medora, quindi quella frase adesso non regge
  /// piu' senza questa riga. E' un caso su centottanta, e cancellarlo per tenere
  /// pulita una frase sarebbe la stessa cosa che scrivere il 98,3 accanto
  /// all'impronta di oggi.
  ///
  /// **QUI STANNO TUTTI E CINQUE I GIRI, per la stessa ragione di
  /// [ultimaMisuraNota]**: il totale si muove di undici punti e sette fra il giro
  /// piu' basso e il piu' alto, mentre **l'unico fatto fermo e' che Aura non viene
  /// mai scambiata**, e un fatto che regge a cinque giri vale piu' di un totale che
  /// si muove. Il secondo fatto, meno fermo ma piu' grave, e' che **Caligo e' la
  /// voce che si perde**: 40, 50, 30, 40 e 60 per cento nei cinque giri, trenta
  /// punti di oscillazione, ed e' li' che sta il grosso degli errori. Chi vorra'
  /// riportare questa misura sopra la soglia comincia da Caligo, non da Medora.
  static const String matrice =
      'GIRO DEL 14 AGOSTO 2026: medora 14 su 20 (70,0 per cento), sei volte '
      'scambiata per aura; aura 20 su 20 (100 per cento); caligo 8 su 20 '
      '(40,0 per cento), dodici volte scambiato per aura; diciotto errori, '
      'tutti verso aura. '
      'GIRO DEL 15 AGOSTO 2026: medora 17 su 20 (85,0 per cento); aura 20 su 20 '
      '(100 per cento); caligo 10 su 20 (50,0 per cento); tredici errori, '
      'tutti verso aura. '
      'PRIMO GIRO DEL 25 AGOSTO 2026: medora 16 su 20 (80,0 per cento), quattro '
      'volte scambiata per aura; aura 20 su 20 (100 per cento); caligo 6 su 20 '
      '(30,0 per cento), tredici volte scambiato per aura e UNA VOLTA PER MEDORA; '
      'diciotto errori, diciassette verso aura più quell\'unico verso medora. '
      'SECONDO GIRO DEL 25 AGOSTO 2026: medora 17 su 20 (85,0 per cento), tre '
      'volte scambiata per aura; aura 20 su 20 (100 per cento); caligo 8 su 20 '
      '(40,0 per cento), dodici volte scambiato per aura; quindici errori, tutti '
      'verso aura. '
      'TERZO GIRO DEL 25 AGOSTO 2026: medora 17 su 20 (85,0 per cento), tre volte '
      'scambiata per aura; aura 20 su 20 (100 per cento); caligo 12 su 20 (60,0 '
      'per cento), otto volte scambiato per aura; undici errori, tutti verso aura. '
      'Verdetti illeggibili: zero in tutti e cinque i giri. Caso cieco 33,3 per '
      'cento, soglia 85.';

  /// Cosa si deve fare perche' [attribuzioneValida] torni vero.
  ///
  /// **QUESTA PROVA NON SI ESEGUE UNA VOLTA SOLA, e i tre giri del 25 agosto 2026
  /// lo dimostrano meglio dei due di agosto:** stessa istruzione, stesse impronte,
  /// stesso giorno, uno dietro l'altro, e undici punti e sette su sessanta di
  /// differenza fra il primo e il terzo. **Chi ne esegue uno solo e ci lavora sopra
  /// sta inseguendo il rumore**, e rischia di dichiarare guarita una voce che il
  /// giro dopo ricade, o malata una che stava bene: il 25 agosto Caligo e' passato
  /// dal 30 al 60 per cento in tre giri, senza che nessuno toccasse una riga.
  ///
  /// **Tre giri, e si guarda l'escursione prima del totale.** Costa
  /// **ventotto secondi a giro**, non i trenta minuti che dice il tetto scritto
  /// in `tool/attribuzione_cieca.dart`: quel tetto e' la protezione contro una
  /// chiamata di rete che si pianta, non una stima del costo, e non va letto
  /// come una ragione per eseguirla una volta sola.
  static const String comeSiRimisura =
      'flutter test tool/attribuzione_cieca.dart, dal PC con una sessione gcloud '
      'attiva. TRE VOLTE: si riportano tutti e tre i giri con la loro '
      'escursione, perché un giro solo non dice dove sta questa misura. Costa '
      'ventotto secondi a giro, non trenta minuti. Dal 25 agosto 2026 lo '
      'strumento stampa anche il RITMO DELLE VOCI, tre numeri per Maestro sulle '
      'risposte di quel giro: frase mediana in parole, domande, parole che '
      'ammorbidiscono. Quel blocco va riportato insieme alla matrice, perché la '
      'matrice dice se il giudice distingue i tre Maestri mentre il ritmo dice se '
      'il registro nuovo ha morso: se Caligo resta basso con la frase mediana '
      'già scesa, la causa non è più il registro. Poi si scrive qui il '
      'risultato: attribuzioneValida torna vero solo se la misura passa la '
      'soglia, mai per far passare la suite.';


  static String? per(Maestro maestro) => impronte[maestro.id];
}

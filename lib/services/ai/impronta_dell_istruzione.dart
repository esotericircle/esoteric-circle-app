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
        '0bc77eb5e1af347cd234f366c95c876341680bfa075d7d214e64d6f27f12de70',
    'aura': 'aab951f95c60a0135710e054992cdbefd845e4efbd8410b0d21be9e269121eb7',
    'caligo':
        'd31790d3b43d90ab55de2d4deca83f7e5925c424337cf6144b1265a6e39e48cb',
  };

  /// Il giorno in cui queste impronte sono state registrate.
  static const String registrateIl = '13 agosto 2026';

  /// **VERO SOLO QUANDO L'ATTRIBUZIONE CIECA E' STATA MISURATA SU QUESTE IMPRONTE
  /// E HA PASSATO LA SOGLIA.** Sono due condizioni e non una, e il 14 agosto 2026 la
  /// prima e' diventata vera mentre la seconda e' diventata FALSA.
  ///
  /// **DUE GIRI, NON DUE MISURE IN DISACCORDO.** Il 14 agosto ha dato 70,0 per
  /// cento, il 15 agosto 78,3, e in mezzo le impronte NON sono cambiate: lo
  /// dimostra la prova che le confronta, che e' verde. Stessa istruzione, due
  /// giorni, otto punti di differenza. **Tutti e due stanno sotto la soglia di
  /// 85**, quindi il rosso dice il vero in tutti e due i casi e il divario fra
  /// loro non e' mai stato un motivo per cambiare questa riga.
  ///
  /// **NON SI PORTA A VERO PER FAR PASSARE LA SUITE, e non si abbassa la soglia.** Il
  /// rosso non dice piu' che manca una misura: adesso dice che la misura c'e' ed e'
  /// negativa, che e' una cosa piu' seria. Torna vero quando le tre voci sono di
  /// nuovo distinguibili e la misura lo dimostra.
  static const bool attribuzioneValida = false;

  /// Le misure NOTE, con la stringa su cui furono prese. Si tengono perche' un
  /// numero senza il suo oggetto e' una leggenda.
  ///
  /// **CE NE SONO DUE E NON UNA, ed e' voluto: una sola nasconderebbe
  /// l'escursione, due la dichiarano.** Sono due giri della stessa misura sulla
  /// stessa istruzione, non due misure in disaccordo.
  static const String ultimaMisuraNota =
      'DUE GIRI SU QUESTE IMPRONTE. L\'istruzione non è cambiata in mezzo: lo '
      'dimostra la prova che confronta le tre impronte. Il 14 agosto 2026: 70,0 '
      'per cento (42 su 60). Il 15 agosto 2026: 78,3 per cento (47 su 60), '
      'eseguita da Mauro dal suo PC. **L\'escursione fra i due giri è di otto '
      'punti su sessanta**, quindi un giro solo non basta a dire dove sta '
      'questa misura. Nel dettaglio: medora 14 e poi 17 su 20, caligo 8 e poi '
      '10 su 20, aura 20 su 20 tutte e due le volte. Prima di tutto questo era '
      '98,3 per cento (59 su 60) il 2 agosto, su una stringa di circa 6300 '
      'caratteri, cioè su un\'ALTRA istruzione, prima che il commit 97bb997 '
      'aggiungesse 636 caratteri netti con le voci S.15 e S.17.';

  /// LA MATRICE, e si tiene per intero perche' il numero da solo direbbe la cosa
  /// sbagliata.
  ///
  /// **Non e' un appiattimento simmetrico delle tre voci: e' AURA CHE ATTIRA.** Aura
  /// resta riconoscibile al cento per cento, e le altre due finiscono dentro di lei.
  /// In tutti gli errori la risposta e' stata attribuita ad Aura: nessuno scambio
  /// nella direzione opposta, nessuno scambio fra Medora e Caligo.
  ///
  /// **QUI STANNO TUTTI E DUE I GIRI, per la stessa ragione di
  /// [ultimaMisuraNota]**: fra il 14 e il 15 agosto il totale si e' mosso di otto
  /// punti, mentre **l'unico fatto fermo e' che Aura non viene mai scambiata**, e
  /// un fatto che regge a due giri vale piu' di un totale che si muove.
  static const String matrice =
      'GIRO DEL 14 AGOSTO 2026: medora 14 su 20 (70,0 per cento), sei volte '
      'scambiata per aura; aura 20 su 20 (100 per cento); caligo 8 su 20 '
      '(40,0 per cento), dodici volte scambiato per aura; diciotto errori, '
      'tutti verso aura. '
      'GIRO DEL 15 AGOSTO 2026: medora 17 su 20 (85,0 per cento); aura 20 su 20 '
      '(100 per cento); caligo 10 su 20 (50,0 per cento); tredici errori, '
      'tutti verso aura. '
      'Verdetti illeggibili: zero. Caso cieco 33,3 per cento, soglia 85.';

  /// Cosa si deve fare perche' [attribuzioneValida] torni vero.
  ///
  /// **QUESTA PROVA NON SI ESEGUE UNA VOLTA SOLA, e i due giri del 14 e del 15
  /// agosto 2026 dicono perche':** stessa istruzione, stesse impronte, otto punti
  /// su sessanta di differenza. **Chi ne esegue uno solo e ci lavora sopra sta
  /// inseguendo il rumore**, e rischia di dichiarare guarita una voce che il giro
  /// dopo ricade, o malata una che stava bene.
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
      'ventotto secondi a giro, non trenta minuti. Poi si scrive qui il '
      'risultato: attribuzioneValida torna vero solo se la misura passa la '
      'soglia, mai per far passare la suite.';


  static String? per(Maestro maestro) => impronte[maestro.id];
}

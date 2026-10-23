import 'package:esoteric_circle/core/viaggio/la_domanda_del_viaggio.dart';

/// **LE DOMANDE LIBERE DI PROVA, scritte PRIMA della tabella che le
/// classifica.** Ordine DI voce 02, 12 settembre 2026.
///
/// **Perche' prima.** Chi scrive la tabella delle parole e anche le domande su
/// cui la si giudica puo' scrivere, senza accorgersene, le domande che la
/// tabella sa gia' riconoscere. Queste sono state scritte come le scriverebbe
/// una persona che apre il Viaggio con qualcosa in testa, e congelate prima
/// della prima riga di `IlTemaDellaDomandaLibera`.
///
/// **Tre gruppi, e la differenza conta.** Il primo, [gruppoDellOrdine], e' la
/// prova che l'ordine chiede: venti domande, almeno tre per tema, e devono
/// passare tutte.
///
/// **Il secondo, [gruppoScrittoPrima], NON e' una prova indipendente, e va
/// detto.** Doveva esserlo: e' stato scritto prima della tabella per non
/// essere guardato mentre la si costruiva. Ma chi ha scritto la tabella aveva
/// appena scritto quelle domande, e rileggendola ci sono indizi che le
/// ricalcano parola per parola, *"tra quanto"*, *"dico di si"*,
/// *"nascondendo"*, *"verso dove"*. Il suo dodici su dodici non misura niente,
/// e si tiene solo perche' resta una prova di regressione.
///
/// **Il terzo, [gruppoDopoLaTabella], e' la misura onesta.** E' stato scritto
/// **dopo** che la tabella era congelata, impronta SHA-256 che comincia con
/// `d337f60a665d0306`, e la tabella non e' stata toccata dopo averlo letto.
/// Il suo esito si riporta com'e'.
///
/// La prima domanda del primo gruppo e' **quella vera** che il fondatore ha
/// visto ricevere la frase scritta per chi non chiede niente.
const List<(String, TemaDellaDomanda)> gruppoDellOrdine = [
  // --- un tempo che non arriva
  ('Mia sorella diventerà presto mamma?', TemaDellaDomanda.attesa),
  ('Quando arriverà la risposta del colloquio?', TemaDellaDomanda.attesa),
  ('Aspetto da mesi una notizia che non arriva mai.', TemaDellaDomanda.attesa),
  ('Riuscirò finalmente ad avere un figlio?', TemaDellaDomanda.attesa),
  // --- una scelta da fare
  ('Devo accettare il nuovo lavoro o restare dove sono?',
      TemaDellaDomanda.scelta),
  ('Non so se trasferirmi a Milano o rimanere qui.', TemaDellaDomanda.scelta),
  ('Firmo il contratto oppure aspetto un’offerta migliore?',
      TemaDellaDomanda.scelta),
  ('Quale delle due case dovrei comprare?', TemaDellaDomanda.scelta),
  // --- una persona
  ('Cosa prova davvero Marco per me?', TemaDellaDomanda.persona),
  ('Posso fidarmi della mia collega?', TemaDellaDomanda.persona),
  ('Perché mia madre è sempre così fredda con me?', TemaDellaDomanda.persona),
  // --- un blocco che non si supera
  ('Perché non riesco mai a finire quello che inizio?',
      TemaDellaDomanda.blocco),
  ('Ho paura di parlare in pubblico e mi blocco ogni volta.',
      TemaDellaDomanda.blocco),
  ('Come faccio a smettere di rimandare tutto?', TemaDellaDomanda.blocco),
  // --- una direzione da prendere
  ('Che strada devo prendere nella vita?', TemaDellaDomanda.direzione),
  ('Mi sento perso, non so cosa voglio fare da grande.',
      TemaDellaDomanda.direzione),
  ('Qual è il mio scopo?', TemaDellaDomanda.direzione),
  // --- qualcosa che è finito
  ('Come supero la fine della mia relazione?', TemaDellaDomanda.finito),
  ('Mio padre è morto e non riesco ad andare avanti.',
      TemaDellaDomanda.finito),
  ('Mi hanno licenziato dopo dieci anni, e adesso?', TemaDellaDomanda.finito),
];

/// Il gruppo scritto prima della tabella, che la tabella ha finito per
/// ricalcare: prova di regressione, non misura indipendente.
const List<(String, TemaDellaDomanda)> gruppoScrittoPrima = [
  ('Tra quanto potrò andare in pensione?', TemaDellaDomanda.attesa),
  ('Il mio libro verrà pubblicato?', TemaDellaDomanda.attesa),
  ('Meglio l’università o cominciare a lavorare subito?',
      TemaDellaDomanda.scelta),
  ('Dico di sì alla proposta di matrimonio?', TemaDellaDomanda.scelta),
  ('Il mio amico Luca mi sta nascondendo qualcosa?', TemaDellaDomanda.persona),
  ('Come posso ricucire il rapporto con mio fratello?',
      TemaDellaDomanda.persona),
  ('Continuo a sabotarmi da solo e non capisco perché.',
      TemaDellaDomanda.blocco),
  ('C’è qualcosa che mi impedisce di essere felice?', TemaDellaDomanda.blocco),
  ('Verso dove sto andando?', TemaDellaDomanda.direzione),
  ('Che cosa dovrei fare della mia vita adesso che ho quarant’anni?',
      TemaDellaDomanda.direzione),
  ('Il mio cane non c’è più e la casa è vuota.', TemaDellaDomanda.finito),
  ('È davvero finita con lei?', TemaDellaDomanda.finito),
];

/// **IL GRUPPO SCRITTO DOPO LA TABELLA CONGELATA**, e la tabella non e' stata
/// toccata dopo averlo letto. Due domande per tema, scritte come le scrive una
/// persona, eufemismi compresi. **Il suo esito si riporta com'e'.**
const List<(String, TemaDellaDomanda)> gruppoDopoLaTabella = [
  ('Mio figlio troverà mai un lavoro stabile?', TemaDellaDomanda.attesa),
  ('Ci vorrà ancora molto prima che guarisca?', TemaDellaDomanda.attesa),
  ('Vendere la macchina adesso ha senso?', TemaDellaDomanda.scelta),
  ('Mi iscrivo al corso di yoga o lascio perdere?', TemaDellaDomanda.scelta),
  ('Mia figlia è felice con il suo ragazzo?', TemaDellaDomanda.persona),
  ('Che cosa vuole da me il mio vicino di casa?', TemaDellaDomanda.persona),
  ('Perché procrastino sempre le cose importanti?', TemaDellaDomanda.blocco),
  ('Ogni volta che sto per farcela mi fermo.', TemaDellaDomanda.blocco),
  ('Sono sulla strada giusta con il mio lavoro?', TemaDellaDomanda.direzione),
  ('Cosa dovrei cambiare per sentirmi più realizzato?',
      TemaDellaDomanda.direzione),
  ('Mia nonna se n’è andata la settimana scorsa.', TemaDellaDomanda.finito),
  ('Il negozio ha chiuso e non so come ripartire.', TemaDellaDomanda.finito),
];

/// **IL QUARTO GRUPPO, scritto dopo il SECONDO congelamento della tabella**,
/// impronta che comincia con `c3bf70df5cbdf461`. Il terzo era stato letto
/// prima di cambiare la tabella, quindi non misurava piu' niente di
/// indipendente. Due domande per tema, con le forme difficili che le persone
/// usano davvero. **Il suo esito si riporta com'e'.**
const List<(String, TemaDellaDomanda)> gruppoDopoIlSecondoCongelamento = [
  ('Avrò presto una promozione?', TemaDellaDomanda.attesa),
  ('Mio marito tornerà a casa?', TemaDellaDomanda.attesa),
  ('Faccio bene a lasciare l’università?', TemaDellaDomanda.scelta),
  ('Tra Roma e Torino dove mi conviene vivere?', TemaDellaDomanda.scelta),
  ('Mio suocero mi sopporta?', TemaDellaDomanda.persona),
  ('Chi è davvero la persona che frequento?', TemaDellaDomanda.persona),
  ('Perché mi sento sempre stanco e senza voglia di fare niente?',
      TemaDellaDomanda.blocco),
  ('Non riesco a dimagrire, cosa mi frena?', TemaDellaDomanda.blocco),
  ('Qual è la mia vera vocazione?', TemaDellaDomanda.direzione),
  ('Che direzione deve prendere la mia carriera?', TemaDellaDomanda.direzione),
  ('Il mio matrimonio è arrivato al capolinea?', TemaDellaDomanda.finito),
  ('Ho chiuso l’attività di famiglia, e ora?', TemaDellaDomanda.finito),
];

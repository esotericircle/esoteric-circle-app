// GENERATO da tool/gli_enigmi_dal_corpus.py su
// docs/corpus/Corpus_Il_Ritratto.md. Non si modifica a mano.
// ignore_for_file: lines_longer_than_80_chars

import 'il_ritratto.dart';

/// Le sezioni del corpus, nell'ordine del corpus.
const List<String> sezioniDelRitratto = [
  'Come mi muovo nel mondo',
  'Il tempo e le cose da fare',
  'Con gli altri',
  'Come decido',
  'Le mie manie',
  'Cosa mi fa paura',
  'Cosa mi fa stare bene',
  'Come lavoro',
  'Le mie parole',
  'Quello che tengo',
  'Scelte libere, mai proposte dal sistema',
];

/// Le 120 caratteristiche: fuoco 27, terra 32, aria 26, acqua 30, libere 5; 12 marcate, 13 marche del genere.
const List<TrattoDelRitratto> trattiDelCorpus = [
  TrattoDelRitratto(
      1,
      'Arrivo sempre dieci minuti prima, anche quando so che gli altri faranno tardi.',
      ElementoDelTratto.terra,
      0),
  TrattoDelRitratto(
      2, 'Parto senza avere deciso dove dormo.', ElementoDelTratto.fuoco, 0),
  TrattoDelRitratto(3, 'Prenoto tutto tre mesi prima e stampo i biglietti.',
      ElementoDelTratto.terra, 0),
  TrattoDelRitratto(
      4,
      'Cambio strada solo per vedere una via che non ho mai fatto.',
      ElementoDelTratto.fuoco,
      0),
  TrattoDelRitratto(
      5, 'Guido piano e lascio passare tutti.', ElementoDelTratto.acqua, 0),
  TrattoDelRitratto(6, 'Conosco a memoria la strada e la faccio sempre uguale.',
      ElementoDelTratto.terra, 0),
  TrattoDelRitratto(
      7, 'Mi perdo anche con il navigatore acceso.', ElementoDelTratto.aria, 0),
  TrattoDelRitratto(8, 'Cammino più veloce di chi ho accanto, sempre.',
      ElementoDelTratto.fuoco, 0),
  TrattoDelRitratto(
      9,
      'Non salgo in macchina con chi guida male, nemmeno per cinque minuti.',
      ElementoDelTratto.terra,
      0),
  TrattoDelRitratto(10, 'Porto sempre uno zaino più pesante del necessario.',
      ElementoDelTratto.terra, 0),
  TrattoDelRitratto(11, 'Faccio le cose all\'ultimo e vengono meglio.',
      ElementoDelTratto.fuoco, 1),
  TrattoDelRitratto(12, 'Comincio a preparare la valigia una settimana prima.',
      ElementoDelTratto.terra, 1),
  TrattoDelRitratto(
      13,
      'Ho una lista per tutto e la riscrivo quando si sporca.',
      ElementoDelTratto.terra,
      1),
  TrattoDelRitratto(
      14,
      'Rimando la cosa più facile e faccio prima quella difficile.',
      ElementoDelTratto.fuoco,
      1),
  TrattoDelRitratto(
      15, 'Mi sveglio prima della sveglia.', ElementoDelTratto.terra, 1),
  TrattoDelRitratto(
      16, 'Spengo la sveglia cinque volte.', ElementoDelTratto.acqua, 1),
  TrattoDelRitratto(17, 'Rispondo ai messaggi dopo due giorni e poi mi scuso.',
      ElementoDelTratto.aria, 1),
  TrattoDelRitratto(18, 'Rispondo in tre secondi a qualunque ora.',
      ElementoDelTratto.aria, 1),
  TrattoDelRitratto(
      19, 'Rifaccio il letto anche in vacanza.', ElementoDelTratto.terra, 1),
  TrattoDelRitratto(
      20,
      'Lavo i piatti subito, non li lascio mai nel lavandino.',
      ElementoDelTratto.terra,
      1),
  TrattoDelRitratto(
      21,
      'Sono [quello|quella|la persona] che tiene i contatti del gruppo.',
      ElementoDelTratto.aria,
      2),
  TrattoDelRitratto(22, 'Sparisco per settimane e poi torno come niente fosse.',
      ElementoDelTratto.fuoco, 2),
  TrattoDelRitratto(
      23,
      'Organizzo io le cene e mi arrabbio se nessuno conferma.',
      ElementoDelTratto.fuoco,
      2),
  TrattoDelRitratto(
      24, 'Dico sempre di sì e poi me ne pento.', ElementoDelTratto.acqua, 2),
  TrattoDelRitratto(25, 'Faccio il primo passo quando c\'è da chiarire.',
      ElementoDelTratto.fuoco, 2),
  TrattoDelRitratto(26, 'Aspetto che sia l\'altro a scrivere per primo.',
      ElementoDelTratto.acqua, 2),
  TrattoDelRitratto(27, 'Mi accorgo subito quando qualcuno non sta bene.',
      ElementoDelTratto.acqua, 2),
  TrattoDelRitratto(28, 'Non mi accorgo di niente finché non me lo dicono.',
      ElementoDelTratto.aria, 2),
  TrattoDelRitratto(
      29,
      'Sono [quello|quella|la persona] che fa ridere quando la situazione è tesa.',
      ElementoDelTratto.aria,
      2),
  TrattoDelRitratto(
      30,
      'Quando litigo divento [silenzioso|silenziosa|una persona silenziosa] invece che [rumoroso|rumorosa|rumorosa].',
      ElementoDelTratto.acqua,
      2),
  TrattoDelRitratto(31, 'Difendo chi viene attaccato anche se ha torto.',
      ElementoDelTratto.fuoco, 2),
  TrattoDelRitratto(
      32, 'Ascolto molto e parlo poco.', ElementoDelTratto.acqua, 2),
  TrattoDelRitratto(33, 'Interrompo gli altri senza accorgermene.',
      ElementoDelTratto.fuoco, 2),
  TrattoDelRitratto(
      34, 'Ricordo i compleanni di tutti.', ElementoDelTratto.acqua, 2),
  TrattoDelRitratto(35, 'Dimentico i compleanni e me ne vergogno ogni volta.',
      ElementoDelTratto.aria, 2),
  TrattoDelRitratto(36, 'Abbraccio anche chi conosco da dieci minuti.',
      ElementoDelTratto.fuoco, 2),
  TrattoDelRitratto(
      37,
      'Non mi piace [essere toccato da|essere toccata da|il contatto fisico con] chi non conosco bene.',
      ElementoDelTratto.terra,
      2),
  TrattoDelRitratto(38, 'Preferisco una persona per volta che dieci insieme.',
      ElementoDelTratto.acqua, 2),
  TrattoDelRitratto(39, 'Nelle feste finisco sempre a parlare in cucina.',
      ElementoDelTratto.aria, 2),
  TrattoDelRitratto(
      40, 'Me ne vado dalle feste senza salutare.', ElementoDelTratto.aria, 2),
  TrattoDelRitratto(41, 'Decido di pancia e quasi sempre indovino.',
      ElementoDelTratto.fuoco, 3),
  TrattoDelRitratto(
      42,
      'Faccio un elenco di pro e contro, anche per il ristorante.',
      ElementoDelTratto.terra,
      3),
  TrattoDelRitratto(43, 'Chiedo il parere a tutti e poi faccio come dicevo io.',
      ElementoDelTratto.aria, 3),
  TrattoDelRitratto(44, 'Non decido mai, lascio decidere agli altri.',
      ElementoDelTratto.acqua, 3),
  TrattoDelRitratto(45, 'Cambio idea tre volte e poi torno alla prima.',
      ElementoDelTratto.aria, 3),
  TrattoDelRitratto(
      46,
      'Quando ho deciso non torno indietro nemmeno se sbaglio.',
      ElementoDelTratto.terra,
      3),
  TrattoDelRitratto(
      47,
      'Leggo tutte le recensioni prima di comprare qualunque cosa.',
      ElementoDelTratto.terra,
      3),
  TrattoDelRitratto(
      48,
      'Compro la prima cosa che mi piace e non guardo il prezzo.',
      ElementoDelTratto.fuoco,
      3),
  TrattoDelRitratto(
      49,
      'Mi fido del primo istinto su una persona e non lo cambio.',
      ElementoDelTratto.acqua,
      3),
  TrattoDelRitratto(50, 'Ho bisogno di dormirci sopra prima di rispondere.',
      ElementoDelTratto.terra, 3),
  TrattoDelRitratto(
      51, 'Perdo le chiavi ogni settimana.', ElementoDelTratto.aria, 4),
  TrattoDelRitratto(52, 'Controllo due volte di avere chiuso la porta.',
      ElementoDelTratto.terra, 4),
  TrattoDelRitratto(
      53, 'Non rispondo mai alla prima chiamata.', ElementoDelTratto.acqua, 4),
  TrattoDelRitratto(54, 'Mangio sempre la stessa cosa quando sono fuori.',
      ElementoDelTratto.terra, 4),
  TrattoDelRitratto(55, 'Non mangio due volte di fila nello stesso posto.',
      ElementoDelTratto.fuoco, 4),
  TrattoDelRitratto(56, 'Metto la sveglia a un orario che finisce per sette.',
      ElementoDelTratto.aria, 4),
  TrattoDelRitratto(57, 'Non riesco a leggere un libro senza finirlo.',
      ElementoDelTratto.terra, 4),
  TrattoDelRitratto(58, 'Comincio cinque libri e non ne finisco nessuno.',
      ElementoDelTratto.aria, 4),
  TrattoDelRitratto(59, 'Rileggo i messaggi prima di mandarli, sempre.',
      ElementoDelTratto.terra, 4),
  TrattoDelRitratto(
      60, 'Mando il messaggio e poi lo cancello.', ElementoDelTratto.acqua, 4),
  TrattoDelRitratto(
      61, 'Metto la musica appena entro in casa.', ElementoDelTratto.fuoco, 4),
  TrattoDelRitratto(62, 'Ho bisogno di silenzio totale per concentrarmi.',
      ElementoDelTratto.terra, 4),
  TrattoDelRitratto(63, 'Mi addormento solo con un rumore di fondo.',
      ElementoDelTratto.acqua, 4),
  TrattoDelRitratto(
      64, 'Tengo il telefono muto da anni.', ElementoDelTratto.terra, 4),
  TrattoDelRitratto(
      65, 'Guardo le stesse serie dieci volte.', ElementoDelTratto.acqua, 4),
  TrattoDelRitratto(
      66,
      'Mi spaventa più [restare fermo|restare ferma|l\'immobilità] che sbagliare strada.',
      ElementoDelTratto.fuoco,
      5),
  TrattoDelRitratto(67, 'Mi spaventa l\'idea di dover ricominciare da capo.',
      ElementoDelTratto.terra, 5),
  TrattoDelRitratto(68, 'Ho paura di annoiarmi più che di stancarmi.',
      ElementoDelTratto.aria, 5),
  TrattoDelRitratto(69, 'Ho paura di deludere chi conta su di me.',
      ElementoDelTratto.acqua, 5),
  TrattoDelRitratto(70, 'Non sopporto di non sapere cosa succede dopo.',
      ElementoDelTratto.terra, 5),
  TrattoDelRitratto(71, 'Mi mette a disagio essere al centro dell\'attenzione.',
      ElementoDelTratto.acqua, 5),
  TrattoDelRitratto(
      72,
      'Mi mette a disagio [non essere notato|non essere notata|non ricevere attenzione].',
      ElementoDelTratto.fuoco,
      5),
  TrattoDelRitratto(73, 'Temo più il silenzio di una persona che le sue urla.',
      ElementoDelTratto.acqua, 5),
  TrattoDelRitratto(
      74, 'Mi spaventa l\'idea di legarmi troppo.', ElementoDelTratto.aria, 5),
  TrattoDelRitratto(
      75,
      'Mi spaventa l\'idea di restare [solo|sola|in solitudine].',
      ElementoDelTratto.acqua,
      5),
  TrattoDelRitratto(76, 'Mi rimette al mondo camminare senza meta.',
      ElementoDelTratto.fuoco, 6),
  TrattoDelRitratto(77, 'Mi rimette al mondo mettere ordine in un cassetto.',
      ElementoDelTratto.terra, 6),
  TrattoDelRitratto(
      78,
      'Mi rimette al mondo una conversazione lunga con una persona sola.',
      ElementoDelTratto.acqua,
      6),
  TrattoDelRitratto(
      79,
      'Mi rimette al mondo imparare una cosa nuova e inutile.',
      ElementoDelTratto.aria,
      6),
  TrattoDelRitratto(80, 'Mi rimette al mondo cucinare per qualcuno.',
      ElementoDelTratto.terra, 6),
  TrattoDelRitratto(81, 'Sto bene in mezzo alla gente che non conosco.',
      ElementoDelTratto.aria, 6),
  TrattoDelRitratto(82, 'Sto bene solo in casa mia, con la porta chiusa.',
      ElementoDelTratto.terra, 6),
  TrattoDelRitratto(83, 'Mi serve l\'acqua vicino per sentirmi a posto.',
      ElementoDelTratto.acqua, 6),
  TrattoDelRitratto(84, 'Mi serve vedere lontano, la collina o il mare.',
      ElementoDelTratto.fuoco, 6),
  TrattoDelRitratto(
      85, 'Dormo meglio quando piove.', ElementoDelTratto.acqua, 6),
  TrattoDelRitratto(
      86,
      'Finisco sempre quello che comincio, anche quando non serve più.',
      ElementoDelTratto.terra,
      7),
  TrattoDelRitratto(87, 'Comincio dieci cose e ne porto in fondo due.',
      ElementoDelTratto.fuoco, 7),
  TrattoDelRitratto(
      88, 'Lavoro meglio sotto pressione.', ElementoDelTratto.fuoco, 7),
  TrattoDelRitratto(
      89, 'Sotto pressione mi blocco.', ElementoDelTratto.acqua, 7),
  TrattoDelRitratto(
      90,
      'Rifaccio tre volte la stessa cosa finché non è come la voglio.',
      ElementoDelTratto.terra,
      7),
  TrattoDelRitratto(
      91, 'Preferisco fatto che perfetto.', ElementoDelTratto.fuoco, 7),
  TrattoDelRitratto(92, 'Chiedo aiuto solo quando è troppo tardi.',
      ElementoDelTratto.terra, 7),
  TrattoDelRitratto(
      93, 'Chiedo aiuto subito e non mi vergogno.', ElementoDelTratto.aria, 7),
  TrattoDelRitratto(
      94,
      'Spiego le cose agli altri meglio di come le faccio io.',
      ElementoDelTratto.aria,
      7),
  TrattoDelRitratto(95, 'Imparo guardando, non leggendo le istruzioni.',
      ElementoDelTratto.fuoco, 7),
  TrattoDelRitratto(
      96,
      'Leggo le istruzioni fino in fondo prima di toccare qualcosa.',
      ElementoDelTratto.terra,
      7),
  TrattoDelRitratto(97, 'Mi distraggo ogni dieci minuti e torno subito.',
      ElementoDelTratto.aria, 7),
  TrattoDelRitratto(98, 'Se mi interrompono devo ricominciare da capo.',
      ElementoDelTratto.terra, 7),
  TrattoDelRitratto(99, 'Parlo con le mani.', ElementoDelTratto.fuoco, 8),
  TrattoDelRitratto(
      100,
      'Rispondo con una battuta anche quando dovrei [stare serio|stare seria|mantenere la serietà].',
      ElementoDelTratto.aria,
      8),
  TrattoDelRitratto(101, 'Faccio più domande di quante risposte do.',
      ElementoDelTratto.aria, 8),
  TrattoDelRitratto(
      102,
      'Racconto le cose dall\'inizio, sempre, anche quando non serve.',
      ElementoDelTratto.terra,
      8),
  TrattoDelRitratto(
      103,
      'Vado subito al punto [e sembro brusco|e sembro brusca|con modi che sembrano bruschi].',
      ElementoDelTratto.fuoco,
      8),
  TrattoDelRitratto(
      104,
      'Mi accorgo di avere parlato troppo solo quando ho finito.',
      ElementoDelTratto.aria,
      8),
  TrattoDelRitratto(
      105, 'Scrivo meglio di come parlo.', ElementoDelTratto.acqua, 8),
  TrattoDelRitratto(
      106,
      'Non so dire di no e lo dico con mille giri di parole.',
      ElementoDelTratto.acqua,
      8),
  TrattoDelRitratto(
      107,
      'Dico quello che penso e poi mi pento della forma, mai del contenuto.',
      ElementoDelTratto.fuoco,
      8),
  TrattoDelRitratto(
      108,
      'Non racconto mai i fatti miei [per primo|per prima|senza che me lo chiedano].',
      ElementoDelTratto.acqua,
      8),
  TrattoDelRitratto(
      109, 'Conservo i biglietti dei concerti.', ElementoDelTratto.acqua, 9),
  TrattoDelRitratto(
      110, 'Butto via tutto una volta all\'anno.', ElementoDelTratto.fuoco, 9),
  TrattoDelRitratto(111, 'Ho ancora il primo telefono che ho avuto.',
      ElementoDelTratto.acqua, 9),
  TrattoDelRitratto(
      112, 'Non ho foto stampate da nessuna parte.', ElementoDelTratto.aria, 9),
  TrattoDelRitratto(
      113,
      'Tengo una penna che non scrive più perché me l\'ha data qualcuno.',
      ElementoDelTratto.acqua,
      9),
  TrattoDelRitratto(
      114, 'Rileggo i messaggi vecchi.', ElementoDelTratto.acqua, 9),
  TrattoDelRitratto(115, 'Cancello le conversazioni appena finiscono.',
      ElementoDelTratto.aria, 9),
  TrattoDelRitratto(
      116,
      'Mi hanno detto almeno una volta che [sembro più serio|sembro più seria|do un\'impressione più seria] di quanto sono.',
      ElementoDelTratto.libera,
      10),
  TrattoDelRitratto(
      117,
      'Mi hanno detto almeno una volta che non sembro la mia età.',
      ElementoDelTratto.libera,
      10),
  TrattoDelRitratto(
      118,
      'La prima impressione che faccio non è quasi mai quella giusta.',
      ElementoDelTratto.libera,
      10),
  TrattoDelRitratto(
      119,
      '[Sono cambiato molto|Sono cambiata molto|Ho cambiato molto di me] negli ultimi tre anni.',
      ElementoDelTratto.libera,
      10),
  TrattoDelRitratto(
      120,
      'Quello che gli altri vedono di me non è quello che vedo io.',
      ElementoDelTratto.libera,
      10),
];

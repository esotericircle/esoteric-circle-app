import 'chakra_del_giorno.dart';

/// **LA FREQUENZA DELLA MEDITAZIONE DI OGGI, ASSEGNATA DA AURA.**
/// Ordine CZ voce 06, 8 settembre 2026.
///
/// **Il fatto del fondatore**: *"Un menu' di frequenze davanti a chi non ha
/// criterio per scegliere e' la forma sbagliata: Aura non e' un lettore
/// multimediale, e' una guida, e una guida decide."*
///
/// **Perche' il chakra del giorno e non altro.** Esiste gia' nell'app, e' il
/// dato di Aura che cambia da solo ogni giorno, ed e' biiettivo sui sette
/// giorni della settimana: ogni giorno ha il suo centro e ogni centro il suo
/// giorno. Da qui viene anche **il primo motivo per tornare domani**, che non
/// ha bisogno di nessuna notifica: domani il centro e' un altro.
///
/// **LE CORRISPONDENZE, e da dove vengono davvero.** Sono quelle che l'ordine
/// indica, e sono **la tradizione moderna del solfeggio**, non una fonte
/// antica: la corrispondenza fra i sei toni del solfeggio e i chakra e' una
/// costruzione della fine del Novecento. Si scrive qui perche' chi legge
/// questo file deve sapere cosa sta assegnando, e la stessa cosa si dice alla
/// persona nel foglio delle fonti.
///
/// **Nessuna promessa.** Questo modulo assegna un numero e una riga che dice
/// **cosa lavora secondo la tradizione**. Non dice che guarisce, non dice che
/// ripara, non dice che agisce sul corpo. E' la funzione dove la tentazione di
/// promettere e' piu' alta, ed e' la stessa famiglia del difetto degli Angeli
/// che ha aperto l'ordine CS.
abstract final class FrequenzaDelGiorno {
  /// La frequenza in hertz che la tradizione moderna assegna a ogni centro.
  ///
  /// L'ordine delle sette voci segue quello dei chakra dal basso verso l'alto,
  /// che e' l'ordine di `ChakraDelGiorno.tutti`: la corrispondenza si legge
  /// per posizione e non per nome, cosi' aggiungere un centro senza la sua
  /// frequenza non compila.
  static const List<double> hertzPerCentro = [
    396, // Muladhara, la radice
    417, // Svadhisthana, il sacro
    528, // Manipura, il fuoco
    639, // Anahata, il cuore
    741, // Vishuddha, la gola
    852, // Ajna, il terzo occhio
    963, // Sahasrara, la corona
  ];

  /// La frequenza di oggi, in hertz.
  ///
  /// Funzione pura: stesso giorno, stessa frequenza, sempre.
  static double di(DateTime giorno) {
    final indice = giorno.weekday - 1;
    return hertzPerCentro[indice % hertzPerCentro.length];
  }

  /// Il centro acceso oggi.
  static Chakra centroDi(DateTime giorno) => ChakraDelGiorno.di(giorno);

  /// **LA RIGA CON CUI AURA DICE PERCHE' E' QUESTA**, e non un'altra.
  ///
  /// Una riga sola, come l'ordine chiede. Nomina il centro, cio' che governa e
  /// il numero: chi legge sa da dove viene la scelta e non deve sceglierla lui.
  ///
  /// **Non promette niente**: dice a cosa il centro apre, non cosa succedera'
  /// a chi respira.
  static String perche(DateTime giorno) {
    final c = centroDi(giorno);
    final hz = di(giorno).round();
    // **NIENTE VIRGOLA SEGUITA DA "E".** Regola di casa, e qui la prima
    // stesura la violava due volte: *"il sacro, Svadhisthana, che apre..."* e
    // *"i 417 hertz, ed è la frequenza"*. La riga si riscrive, non si deroga.
    return 'Oggi è acceso ${c.italiano} (${c.nome}) e apre su '
        '${c.governa}: la tradizione gli accosta i $hz hertz. È la '
        'frequenza di questa sessione.';
  }

  /// **LE TRE RIGHE PRIMA DI COMINCIARE.** Ordine CZ voce 07, e sono tre e non
  /// una di piu'.
  ///
  /// Cosa lavora questa frequenza secondo la tradizione, quanto dura la
  /// sessione, cosa si ha in mano alla fine. Il verbo della prima riga e'
  /// **secondo la tradizione**, e resta scritto: e' cio' che separa una
  /// corrispondenza culturale da una promessa.
  static List<String> lePrimeTreRighe(DateTime giorno, Duration durata) {
    final c = centroDi(giorno);
    final hz = di(giorno).round();
    final minuti = durata.inMinutes;
    return [
      'Secondo la tradizione i $hz hertz accompagnano ${c.italiano}, '
          'cioè ${c.governa}.',
      'La sessione dura $minuti minuti. La puoi chiudere quando vuoi.',
      'Alla fine avrai la forma del tuo respiro, diversa da quella di '
          'chiunque altro.',
    ];
  }
}

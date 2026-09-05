/// LE DOMANDE DEL CERCHIO, IN UN PUNTO SOLO. Ordine S voce 21, decisione D4 di
/// Mauro del 13 agosto 2026.
///
/// **Perche' nasce qui.** Le domande proposte esistevano in DUE posti: le sei
/// liste della chat, per Maestro, e i cinque suggerimenti della gettata di rune in
/// `rune_cast.dart`. Due elenchi della stessa cosa sono due elenchi da tenere
/// d'accordo a mano, e nessuna prova poteva dire quale fosse quello giusto.
///
/// **Le due famiglie sono quelle che la chat aveva gia'**, GENERICHE e PERSONALI:
/// non se ne inventano altre, e i nomi restano quelli che la persona legge nel
/// pannello dei suggerimenti.
///
/// **Ogni domanda dichiara DOVE serve**, perche' non tutte servono in tutti i
/// posti: "Tira una carta per me" e' un comando alla chat e come domanda di una
/// gettata non vuol dire niente, mentre "In amore, dove sto andando?" vale in
/// entrambi i posti. E le PERSONALI dichiarano anche di quale DATO hanno bisogno:
/// se quel dato manca, la domanda non si mostra invece di promettere qualcosa che
/// l'app non sa.
library;

import '../maestro/maestro.dart';

/// Le due famiglie, le stesse della chat.
enum FamigliaDellaDomanda {
  generiche('Domande frequenti'),
  personali('Domande personali');

  const FamigliaDellaDomanda(this.etichetta);

  /// Come si legge a schermo. Le etichette restano quelle che la chat mostrava.
  final String etichetta;
}

/// Dove una domanda serve.
enum DoveServeLaDomanda { chat, gettata }

/// Il dato di cui una domanda personale ha bisogno per avere senso.
enum DatoPerLaDomanda {
  sole,
  luna,
  ascendente,
  segno,
  runaDiIeriSera,
  parolaDiStamattina,
  animaleGuida,
  archetipo,
}

/// Una domanda proposta, col suo posto e il suo dato.
class DomandaDelCerchio {
  const DomandaDelCerchio(
    this.testo, {
    required this.famiglia,
    required this.dove,
    this.maestro,
    this.dato,
  });

  final String testo;
  final FamigliaDellaDomanda famiglia;

  /// Dove questa domanda si propone. Una domanda puo' servire in due posti.
  final Set<DoveServeLaDomanda> dove;

  /// Il Maestro a cui appartiene, quando la domanda e' del suo dominio. Nulla per
  /// le domande della gettata, che sono di Caligo per collocazione ma non parlano
  /// del suo dominio: parlano della persona.
  final Maestro? maestro;

  /// Il dato che serve perche' la domanda abbia senso. Nulla quando non serve
  /// niente.
  final DatoPerLaDomanda? dato;
}

/// L'elenco unico.
class DomandeDelCerchio {
  const DomandeDelCerchio._();

  /// LE OTTO GENERICHE DELLA GETTATA. Le prime cinque sono quelle che esistevano
  /// in `kRuneDomandeSuggerite`, tenute parola per parola: cio' che funziona non
  /// si riscrive per il gusto di riscriverlo. Le altre tre sono le domande di
  /// sblocco, che l'elenco vecchio non aveva.
  static const List<DomandaDelCerchio> generichePerLaGettata = [
    DomandaDelCerchio('Cosa devo sapere sul mio momento?',
        famiglia: FamigliaDellaDomanda.generiche,
        dove: {DoveServeLaDomanda.gettata}),
    DomandaDelCerchio('In amore, dove sto andando?',
        famiglia: FamigliaDellaDomanda.generiche,
        dove: {DoveServeLaDomanda.gettata}),
    DomandaDelCerchio('Nel lavoro, quale passo fare?',
        famiglia: FamigliaDellaDomanda.generiche,
        dove: {DoveServeLaDomanda.gettata}),
    DomandaDelCerchio('Una scelta mi blocca: cosa la scioglie?',
        famiglia: FamigliaDellaDomanda.generiche,
        dove: {DoveServeLaDomanda.gettata}),
    DomandaDelCerchio('Cosa mi sfugge di questa situazione?',
        famiglia: FamigliaDellaDomanda.generiche,
        dove: {DoveServeLaDomanda.gettata}),
    DomandaDelCerchio('Cosa conviene lasciare andare adesso?',
        famiglia: FamigliaDellaDomanda.generiche,
        dove: {DoveServeLaDomanda.gettata}),
    DomandaDelCerchio('Su cosa vale la pena insistere?',
        famiglia: FamigliaDellaDomanda.generiche,
        dove: {DoveServeLaDomanda.gettata}),
    DomandaDelCerchio('Cosa non sto guardando di me?',
        famiglia: FamigliaDellaDomanda.generiche,
        dove: {DoveServeLaDomanda.gettata}),
  ];

  /// LE OTTO PERSONALI DELLA GETTATA, che nascono da CARTA E CAMMINO insieme,
  /// come Mauro ha deciso: i tre luminari dalla carta, la runa di ieri sera e la
  /// parola di stamattina dal filo fra i riti. Ognuna dichiara il suo dato, e
  /// senza quel dato non si mostra.
  static const List<DomandaDelCerchio> personaliPerLaGettata = [
    DomandaDelCerchio('Il mio Sole: dove mi chiede coraggio?',
        famiglia: FamigliaDellaDomanda.personali,
        dove: {DoveServeLaDomanda.gettata},
        dato: DatoPerLaDomanda.sole),
    DomandaDelCerchio('La mia Luna: cosa chiede adesso?',
        famiglia: FamigliaDellaDomanda.personali,
        dove: {DoveServeLaDomanda.gettata},
        dato: DatoPerLaDomanda.luna),
    DomandaDelCerchio('Il mio Ascendente: cosa mostro e cosa nascondo?',
        famiglia: FamigliaDellaDomanda.personali,
        dove: {DoveServeLaDomanda.gettata},
        dato: DatoPerLaDomanda.ascendente),
    DomandaDelCerchio('La runa di ieri sera: cosa continua oggi?',
        famiglia: FamigliaDellaDomanda.personali,
        dove: {DoveServeLaDomanda.gettata},
        dato: DatoPerLaDomanda.runaDiIeriSera),
    DomandaDelCerchio('La parola di stamattina: dove la ritrovo?',
        famiglia: FamigliaDellaDomanda.personali,
        dove: {DoveServeLaDomanda.gettata},
        dato: DatoPerLaDomanda.parolaDiStamattina),
    DomandaDelCerchio('Il mio segno in questo periodo: cosa cambia?',
        famiglia: FamigliaDellaDomanda.personali,
        dove: {DoveServeLaDomanda.gettata},
        dato: DatoPerLaDomanda.segno),
    DomandaDelCerchio('Il mio animale guida: cosa mi dice ora?',
        famiglia: FamigliaDellaDomanda.personali,
        dove: {DoveServeLaDomanda.gettata},
        dato: DatoPerLaDomanda.animaleGuida),
    DomandaDelCerchio('Il mio archetipo: quale passo mi somiglia?',
        famiglia: FamigliaDellaDomanda.personali,
        dove: {DoveServeLaDomanda.gettata},
        dato: DatoPerLaDomanda.archetipo),
  ];

  /// LE DOMANDE DELLE CHAT, spostate qui dalla vista che le mostrava.
  ///
  /// **Sono le stesse, parola per parola e nello stesso ordine:** questa voce
  /// sposta la loro casa, non le riscrive. Riscriverle sarebbe stato un altro
  /// lavoro, e mescolarlo a questo avrebbe reso impossibile dire quale delle
  /// due cose ha rotto qualcosa.
  static const List<DomandaDelCerchio> dellaChat = [
    DomandaDelCerchio('Cosa dicono le stelle sul mio amore?',
        famiglia: FamigliaDellaDomanda.generiche,
        maestro: Maestro.medora,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Che indicano gli astri sul mio lavoro?',
        famiglia: FamigliaDellaDomanda.generiche,
        maestro: Maestro.medora,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Dove si apre la mia fortuna in questi giorni?',
        famiglia: FamigliaDellaDomanda.generiche,
        maestro: Maestro.medora,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Le stelle sostengono un mio traguardo?',
        famiglia: FamigliaDellaDomanda.generiche,
        maestro: Maestro.medora,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Cosa muove le mie relazioni ora?',
        famiglia: FamigliaDellaDomanda.generiche,
        maestro: Maestro.medora,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Parlami del mio segno',
        famiglia: FamigliaDellaDomanda.generiche,
        maestro: Maestro.medora,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Tira una carta per me',
        famiglia: FamigliaDellaDomanda.generiche,
        maestro: Maestro.medora,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Parlami dei miei transiti',
        famiglia: FamigliaDellaDomanda.generiche,
        maestro: Maestro.medora,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Cosa illumina il mio Sole?',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.medora,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Parlami del mio Sole',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.medora,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('La forza del mio Sole',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.medora,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Il mio Sole come mi guida?',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.medora,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Cosa sente la mia Luna?',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.medora,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Parlami della mia Luna',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.medora,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('La mia Luna e le emozioni',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.medora,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Il bisogno della mia Luna',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.medora,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Cosa mostra il mio Ascendente?',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.medora,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Parlami del mio Ascendente',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.medora,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('L\'Ascendente e la mia maschera',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.medora,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('La prima impressione del mio Ascendente',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.medora,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Come apro il cuore all\'amore?',
        famiglia: FamigliaDellaDomanda.generiche,
        maestro: Maestro.aura,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Un respiro per la tensione del lavoro',
        famiglia: FamigliaDellaDomanda.generiche,
        maestro: Maestro.aura,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Come mi apro al flusso che arriva?',
        famiglia: FamigliaDellaDomanda.generiche,
        maestro: Maestro.aura,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Come trovo la calma prima di un traguardo?',
        famiglia: FamigliaDellaDomanda.generiche,
        maestro: Maestro.aura,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Come porto equilibrio nelle mie relazioni?',
        famiglia: FamigliaDellaDomanda.generiche,
        maestro: Maestro.aura,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Guidami in una meditazione breve',
        famiglia: FamigliaDellaDomanda.generiche,
        maestro: Maestro.aura,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Quale chakra devo riequilibrare?',
        famiglia: FamigliaDellaDomanda.generiche,
        maestro: Maestro.aura,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Un respiro per calmare la mente',
        famiglia: FamigliaDellaDomanda.generiche,
        maestro: Maestro.aura,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Il mio Sole e la mia energia vitale',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.aura,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Come nutro la luce del mio Sole?',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.aura,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Il mio Sole e il chakra del plesso',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.aura,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('La forza del mio Sole nel corpo',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.aura,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('La mia Luna e il chakra del cuore',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.aura,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Come accolgo le emozioni della mia Luna?',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.aura,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('La mia Luna e il respiro',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.aura,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Il bisogno di quiete della mia Luna',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.aura,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Il mio Ascendente e la mia presenza',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.aura,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Come abito il mio Ascendente col respiro?',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.aura,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Il mio Ascendente e l\'energia che mostro',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.aura,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('La prima impressione del mio Ascendente',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.aura,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Quale runa parla del mio amore?',
        famiglia: FamigliaDellaDomanda.generiche,
        maestro: Maestro.caligo,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Un simbolo per la forza nel lavoro',
        famiglia: FamigliaDellaDomanda.generiche,
        maestro: Maestro.caligo,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Una runa per attirare abbondanza',
        famiglia: FamigliaDellaDomanda.generiche,
        maestro: Maestro.caligo,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Quale rito sostiene un mio traguardo?',
        famiglia: FamigliaDellaDomanda.generiche,
        maestro: Maestro.caligo,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Cosa dicono i simboli delle mie relazioni?',
        famiglia: FamigliaDellaDomanda.generiche,
        maestro: Maestro.caligo,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Estrai una runa per me',
        famiglia: FamigliaDellaDomanda.generiche,
        maestro: Maestro.caligo,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Un simbolo di protezione',
        famiglia: FamigliaDellaDomanda.generiche,
        maestro: Maestro.caligo,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Qual è il mio animale guida?',
        famiglia: FamigliaDellaDomanda.generiche,
        maestro: Maestro.caligo,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Il mio Sole e la runa del potere',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.caligo,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Quale simbolo veste il mio Sole?',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.caligo,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Il mio Sole e la mia volontà',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.caligo,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('L\'archetipo del mio Sole',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.caligo,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('La mia Luna e la runa dell\'acqua',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.caligo,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Quale simbolo abita la mia Luna?',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.caligo,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('La mia Luna e l\'ombra',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.caligo,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('L\'archetipo della mia Luna',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.caligo,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Il mio Ascendente e la maschera rituale',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.caligo,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Quale runa apre il mio Ascendente?',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.caligo,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('Il mio Ascendente e la soglia',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.caligo,
        dove: {DoveServeLaDomanda.chat}),
    DomandaDelCerchio('L\'archetipo del mio Ascendente',
        famiglia: FamigliaDellaDomanda.personali,
        maestro: Maestro.caligo,
        dove: {DoveServeLaDomanda.chat}),
  ];

  /// LE DOMANDE DELLA GETTATA, per famiglia, con i dati che la persona ha.
  ///
  /// Una personale senza il suo dato NON si mostra: una domanda che nomina la tua
  /// Luna quando l'app non sa la tua Luna e' una promessa che nessuno mantiene.
  static List<DomandaDelCerchio> perLaGettata(
    FamigliaDellaDomanda famiglia, {
    Set<DatoPerLaDomanda> datiDisponibili = const {},
  }) {
    final elenco = famiglia == FamigliaDellaDomanda.generiche
        ? generichePerLaGettata
        : personaliPerLaGettata;
    return elenco
        .where((d) => d.dato == null || datiDisponibili.contains(d.dato))
        .toList(growable: false);
  }

  /// Le domande della chat di un Maestro, per famiglia. E' la lista che
  /// `SuggestionSets` mostra: la sua casa e' qui.
  static List<String> perLaChat(
          Maestro maestro, FamigliaDellaDomanda famiglia) =>
      dellaChat
          .where((d) => d.maestro == maestro && d.famiglia == famiglia)
          .map((d) => d.testo)
          .toList(growable: false);
}

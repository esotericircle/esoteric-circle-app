/// **LE FRASI DEI CORPORA CHE IL CONFINE SEGNA, IN ATTESA DELL'ARCHITETTO.**
/// Ordine EV, voce EV.07, 1 ottobre 2026.
///
/// L'Architetto ha corretto le tre frasi col futuro di un gesto che il
/// rapporto EU gli aveva segnalato, e ha deciso che il confine torna com'era
/// prima dell'ordine EU: il futuro di un gesto scelto non e' piu'
/// un'eccezione. Misurato il confine di prima su tutte le 6192 voci dei
/// dodici corpora, **le frasi segnate sono quindici, non tre**: il rapporto EU
/// guardava solo le schede che le prove componevano (l'Occidentale, tre
/// giorni dell'anno), e la quarta, "Scrivi la data in cui partirai davvero",
/// stava nel commento dell'eccezione e non nel rapporto.
///
/// Code non tocca i testi dei corpora (regola fissa 11). Queste frasi si
/// dichiarano una per una, col file e la riga, e le prove del confine le
/// lasciano passare finche' l'Architetto non le riscrive: la guardia
/// `il_confine_passa_sui_dodici_corpora_test.dart` pretende che l'elenco dica
/// il vero, cioe' che ognuna ci sia ancora e sia ancora segnata, e che
/// nessun'altra frase dei corpora superi il confine. Quando l'Architetto
/// manda i testi nuovi, l'elenco si svuota e la guardia lo pretende.
class FraseInAttesa {
  const FraseInAttesa(this.corpus, this.riga, this.parola, this.frase);
  final String corpus;
  final int riga;
  final String parola;
  final String frase;
}

const List<FraseInAttesa> frasiDeiCorporaInAttesa = [
  FraseInAttesa('oroscopo_eu_cinese_giorno.md', 330, 'porterai',
      'Prima di riattaccare fissa una data per andarla a trovare: giorno, ora e che cosa porterai, anche solo un dolce o il giornale del mattino.'),
  FraseInAttesa('oroscopo_eu_cinese_giorno.md', 816, 'tornerai',
      'Occupatene subito oppure fissa il giorno in cui tornerai a farlo.'),
  FraseInAttesa('oroscopo_eu_cinese_giorno.md', 1000, 'saluterai',
      'Prima di uscire decidi l\'ora in cui saluterai e rispettala, anche se il caffè va bene.'),
  FraseInAttesa('oroscopo_eu_cinese_giorno.md', 1554, 'riprenderai',
      'La sera, a casa, riprenderai da un punto già caldo e non sprecherai l\'inizio a ricordare dove avevi interrotto.'),
  FraseInAttesa('oroscopo_eu_cinese_mese.md', 107, 'porterai',
      'Avverti prima i tuoi con due righe su chi porterai, così nessuno si trova a improvvisare domande.'),
  FraseInAttesa('oroscopo_eu_cinese_settimana.md', 66, 'restituirai',
      'Finito il lavoro, segna sul calendario la data in cui restituirai il favore e diglielo subito, a voce.'),
  FraseInAttesa('oroscopo_eu_cinese_settimana.md', 870, 'verificherai',
      'Poi fissa un traguardo modesto per le prossime quattro settimane e scrivilo su un foglio, accanto alla data in cui lo verificherai.'),
  FraseInAttesa('oroscopo_eu_occidentale_giorno.md', 535, 'partirai',
      'Scrivi la data in cui partirai davvero e cerchiala sul calendario.'),
  FraseInAttesa('oroscopo_eu_occidentale_settimana.md', 587, 'passerai',
      'Se l\'idea ti pesa troppo, rispondi con garbo che passerai solo per il brindisi.'),
  FraseInAttesa('oroscopo_eu_vedica_giorno.md', 311, 'guarderai',
      'Se arriva una richiesta nuova, annotala sul retro: la guarderai domani mattina con calma, a lista chiusa.'),
  FraseInAttesa('oroscopo_eu_vedica_giorno.md', 1438, 'chiuderai',
      'Decidi ora l\'orario in cui chiuderai il computer e scrivilo su un foglietto attaccato allo schermo.'),
  FraseInAttesa('oroscopo_eu_vedica_giorno.md', 1577, 'rileggerai',
      'Porta con te un libro letto che non rileggerai e lascialo nello scaffale del bar o della biblioteca.'),
  FraseInAttesa('oroscopo_eu_vedica_giorno.md', 1635, 'comprerai',
      'Domani, prima di fare la spesa, consultalo: comprerai meno e cucinerai con più calma.'),
  FraseInAttesa('oroscopo_eu_vedica_giorno.md', 1698, 'deciderai',
      'Domani imposta un promemoria qualche giorno prima di ciascuna scadenza: deciderai ogni volta con lucidità.'),
  FraseInAttesa('oroscopo_eu_vedica_settimana.md', 594, 'porterai',
      'Alla prossima telefonata spiega con gentilezza che tieni a entrambe le persone e che non porterai messaggi.'),
];

/// Vero quando la violazione cade su una frase dichiarata qui sopra.
bool eInAttesaDellArchitetto(String intorno) =>
    frasiDeiCorporaInAttesa.any((f) => f.frase == intorno.trim());

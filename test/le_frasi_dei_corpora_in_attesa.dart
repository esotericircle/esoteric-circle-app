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

// **LAPIDE: dalla voce EV.07 alla EV Aggiunta qui stavano quindici frasi**
// col futuro di un gesto, in attesa dei testi dell'Architetto. Il 2 ottobre
// 2026 l'Architetto ha controllato i dodici corpora interi, ha trovato le
// frasi con un verbo al futuro rivolto a chi legge (54 frasi, 56 parole, per
// il conto di Code) e le ha riscritte tutte. L'elenco e' vuoto; la guardia
// `i_corpora_non_dicono_il_futuro_test.dart` tiene il futuro fuori.
const List<FraseInAttesa> frasiDeiCorporaInAttesa = [];

/// Vero quando la violazione cade su una frase dichiarata qui sopra.
bool eInAttesaDellArchitetto(String intorno) =>
    frasiDeiCorporaInAttesa.any((f) => f.frase == intorno.trim());

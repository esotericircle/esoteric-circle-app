/// Il nome della persona, scritto come si scrive un nome.
///
/// Vive qui, da solo, per una ragione imparata sbagliando. La prima volta la
/// normalizzazione era finita dentro `IdentityController.setName`, e sembrava
/// il posto giusto perche' li' il nome entra. Solo che il nome entra da DUE
/// porte: quella e `ProfileController.setProfile`, che scrive lo stesso nome
/// dentro `UserProfile`. La home legge la seconda, quindi mostrava ancora
/// "mauro" minuscolo mentre sette test dichiaravano la cosa chiusa: i test
/// coprivano una porta sola.
///
/// La lezione: quando un dato entra da piu' porte, la regola non sta in una
/// porta, sta nel dato. Da qui la passano tutte e due.
library;

/// Normalizza un nome proprio.
///
/// Nessuno scrive il proprio nome tutto minuscolo per scelta, e nessuno lo
/// urla tutto maiuscolo: sono la fretta della tastiera e il blocco maiuscole.
/// Le maiuscole INTERNE volute si riconoscono e restano, quindi McDonald non
/// diventa Mcdonald. I separatori dei nomi composti (spazio, trattino,
/// apostrofo dritto o tipografico) aprono ciascuno una nuova iniziale.
String normalizzaNomeProprio(String grezzo) {
  final pulito = grezzo.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (pulito.isEmpty) return '';

  const separatori = {' ', '-', "'", '’'};

  String parolaAttorno(int i) {
    var inizio = i;
    while (inizio > 0 && !separatori.contains(pulito[inizio - 1])) {
      inizio--;
    }
    var fine = i;
    while (fine < pulito.length && !separatori.contains(pulito[fine])) {
      fine++;
    }
    return pulito.substring(inizio, fine);
  }

  final buf = StringBuffer();
  var iniziale = true;
  for (var i = 0; i < pulito.length; i++) {
    final ch = pulito[i];
    if (separatori.contains(ch)) {
      buf.write(ch);
      iniziale = true;
      continue;
    }
    if (iniziale) {
      buf.write(ch.toUpperCase());
      iniziale = false;
      continue;
    }
    // Dentro la parola si abbassa solo se la parola e' TUTTA maiuscola, cioe'
    // un urlo da blocco maiuscole. Una maiuscola isolata dentro un nome e'
    // voluta e va lasciata stare.
    final parola = parolaAttorno(i);
    buf.write(parola == parola.toUpperCase() ? ch.toLowerCase() : ch);
  }
  return buf.toString();
}

/// **VERBATIM VUOL DIRE LE STESSE PAROLE, non gli stessi byte.** Ordine BS voce
/// 01. Il corpus e' un file di lavoro e chi lo scrive batte l'apostrofo: "e'",
/// "Meta'", "affinita'". Le stringhe che finiscono a video hanno pero' una
/// regola di casa, sorvegliata da `testo_a_video_test`, che pretende l'accento
/// vero: a video la differenza si vede e fa sembrare l'app scritta male. Il
/// generatore quindi accenta mentre scrive, e questa funzione fa la stessa cosa
/// al testo del corpus prima di confrontarlo. **La parola resta identica,
/// cambia il segno che la chiude**: e' ortografia, non riscrittura, e un
/// traguardo che cambiasse parola cadrebbe qui lo stesso.
String conGliAccenti(String testo) {
  const vocali = {'a': 'à', 'e': 'è', 'i': 'ì', 'o': 'ò', 'u': 'ù'};
  return testo.replaceAllMapped(RegExp(r"\w+'(?![a-zA-Z])"), (m) {
    final parola = m.group(0)!;
    final corpo = parola.substring(0, parola.length - 1);
    if (corpo.isEmpty) return parola;
    final ultima = corpo[corpo.length - 1].toLowerCase();
    if (!vocali.containsKey(ultima)) return parola;
    // Le parole in -che' e i due monosillabi ne' e se' vogliono l'accento
    // acuto: perche', poiche', finche'.
    final acuta = corpo.toLowerCase().endsWith('che') ||
        corpo.toLowerCase() == 'ne' ||
        corpo.toLowerCase() == 'se';
    var accentata = acuta ? 'é' : vocali[ultima]!;
    if (corpo[corpo.length - 1] == corpo[corpo.length - 1].toUpperCase() &&
        corpo[corpo.length - 1] != corpo[corpo.length - 1].toLowerCase()) {
      accentata = accentata.toUpperCase();
    }
    return corpo.substring(0, corpo.length - 1) + accentata;
  });
}

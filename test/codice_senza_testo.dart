/// **CIO' CHE UN SORGENTE CHIAMA, NON CIO' CHE NOMINA.** Ordine CM voce 02.
///
/// **Perche' esiste.** Le guardie che leggono altri sorgenti cercano dentro il
/// testo il nome di una funzione, e trovano anche le volte in cui quel nome
/// sta dentro una stringa o dentro un commento. E' come contare la parola
/// "veleno" in un manuale di tossicologia e concluderne che il libro e'
/// avvelenato.
///
/// Il caso che l'ha fatta nascere e' preciso: la guardia della quadratura del
/// registro cerca `sorgentiDiLib(` dentro le altre prove, quindi quel nome
/// compare nel suo testo dentro una stringa. Senza questa porta, il registro
/// la classificava fra le guardie che passano dalla porta comune, **cosa che
/// non fa**, e nessuno se ne sarebbe accorto perche' il conto restava coerente
/// con se stesso. **Un conto sbagliato che quadra e' peggio di uno che non
/// quadra**, perche' non chiede di essere guardato.
///
/// **Non e' un analizzatore.** Toglie i commenti e il contenuto delle
/// stringhe, e tanto basta per distinguere una chiamata da una citazione. Se
/// un giorno servisse la precisione vera si legge l'albero sintattico, e
/// questa porta e' il posto dove farlo una volta per tutte.
String codiceSenzaTesto(String sorgente) {
  const apici = ['"""', "'''", '"', "'"];
  final fuori = StringBuffer();
  var i = 0;

  while (i < sorgente.length) {
    // I commenti di riga.
    if (sorgente.startsWith('//', i)) {
      final fine = sorgente.indexOf('\n', i);
      if (fine < 0) break;
      fuori.write('\n');
      i = fine + 1;
      continue;
    }

    // I commenti a blocco, che in Dart si annidano.
    if (sorgente.startsWith('/*', i)) {
      var livello = 1;
      i += 2;
      while (i < sorgente.length && livello > 0) {
        if (sorgente.startsWith('/*', i)) {
          livello++;
          i += 2;
        } else if (sorgente.startsWith('*/', i)) {
          livello--;
          i += 2;
        } else {
          i++;
        }
      }
      fuori.write(' ');
      continue;
    }

    // Le stringhe, in tutte le forme che Dart ammette. Il prefisso `r` toglie
    // il valore di fuga alla barra rovescia, e va guardato: senza, una stringa
    // grezza che finisce con una barra sposterebbe la fine.
    String? apice;
    for (final a in apici) {
      if (sorgente.startsWith(a, i)) {
        apice = a;
        break;
      }
    }
    if (apice != null) {
      final grezza = i > 0 && sorgente[i - 1] == 'r';
      var j = i + apice.length;
      while (j < sorgente.length) {
        if (!grezza && sorgente[j] == r'\') {
          j += 2;
          continue;
        }
        if (sorgente.startsWith(apice, j)) break;
        j++;
      }
      // Al posto del contenuto resta una stringa vuota, cosi' il codice
      // intorno mantiene la sua forma.
      fuori.write(apice);
      fuori.write(apice);
      i = j < sorgente.length ? j + apice.length : sorgente.length;
      continue;
    }

    fuori.write(sorgente[i]);
    i++;
  }

  return fuori.toString();
}

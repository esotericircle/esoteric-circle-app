/// DOVE SI FERMA LA CHAT quando arriva una risposta nuova.
///
/// **Il dato che ha fatto nascere questo file.** Il 2 agosto 2026 le risposte
/// sono passate da quaranta a novanta parole, e nell'anteprima a 360 per 797 si
/// e' visto il difetto: la bolla e' piu' alta dello schermo, la chat scorreva in
/// fondo come qualunque chat, e **la prima riga restava sopra la piega**. La
/// prima riga di Medora e' la sua immagine celeste, cioe' il primo dei quattro
/// strati del responso: la persona arrivava a meta' di una lettura senza averne
/// letto l'inizio, e per trovarlo doveva scorrere indietro.
///
/// **In una chat normale si scorre in fondo perche' i messaggi sono corti.** Qui
/// il messaggio E' il contenuto: settanta parole sono una lettura, e una lettura
/// si comincia dall'inizio. Al fondo ci arriva la persona leggendo.
///
/// Funzione pura: si prova senza montare uno schermo, e la prova a coordinate
/// verifica separatamente che a 360 punti logici il conto torni davvero.
class ScorrimentoDellaLettura {
  const ScorrimentoDellaLettura._();

  /// Quanto spazio resta SOPRA l'inizio della risposta, in punti logici.
  ///
  /// Serve alla domanda che l'ha generata: una lettura senza la domanda sopra
  /// e' una risposta senza sapere a cosa. Novantasei punti sono una domanda di
  /// due righe piu' il suo margine, e le domande di una chat sono corte quasi
  /// sempre. Quando la domanda e' piu' lunga se ne vede la fine, che e' la
  /// parte attaccata alla risposta, quindi la piu' utile a capire.
  static const double spazioPerLaDomanda = 96;

  /// L'offset a cui portare la lista.
  ///
  /// **Si parte da DOVE LA RISPOSTA STA ADESSO e si corregge la differenza**,
  /// invece di calcolare da zero l'offset che la rivelerebbe. La prima stesura
  /// chiedeva quell'offset a `getOffsetToReveal`, e misurata a 360 per 797
  /// lasciava la risposta a 417 punti dall'alto invece che a 96: mezzo schermo
  /// alla conversazione vecchia. Correggere una differenza misurata non ha
  /// questo problema, perche' non deve indovinare come una libreria interpreta
  /// un allineamento dentro una lista rovesciata.
  ///
  /// **Il segno e' quello di una lista ROVESCIATA**, dove l'offset cresce verso
  /// i messaggi vecchi: farlo crescere scopre cio' che sta SOPRA e spinge in
  /// giu' cio' che si guarda. E' il contrario di una lista normale, ed e'
  /// esattamente il tipo di segno che si sbaglia a mente: per questo il conto
  /// sta qui, dove una prova lo interroga senza montare uno schermo.
  ///
  /// Tutte le coordinate sono globali, in punti logici.
  static double bersaglio({
    required double offsetAttuale,
    required double cimaDellaRisposta,
    required double cimaDellaLista,
    required double massimo,
  }) {
    final dove = cimaDellaLista + spazioPerLaDomanda;
    final voluto = offsetAttuale + (dove - cimaDellaRisposta);
    if (voluto < 0) return 0;
    return voluto > massimo ? massimo : voluto;
  }
}

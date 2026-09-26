/// **LE FIGURE DELLA STESA: le immagini con cui la lettura parla.** Ordine DS
/// voce 09, 17 settembre 2026.
///
/// **Il fatto**, sulla cattura di un fondatore esterno che ha sottolineato a
/// mano le due righe: *"e' un passaggio stretto che si attraversa, non un
/// muro"* e quattro righe sotto *"c'e' un nodo da sciogliere e non un muro"*.
/// Stessa figura, stessa negazione, nello stesso responso. I pezzi che
/// compongono il Consiglio vengono da tavole diverse, e nessuna sapeva cosa
/// avevano gia' detto le altre.
///
/// **Una figura e' una famiglia di parole**, non una parola: *"nodo"* e
/// *"sciogliere"* sono la stessa immagine, e *"muro"* e *"ostacolo"* sono la
/// stessa barriera. Contarle come parole diverse lascerebbe passare proprio la
/// ripetizione che il fondatore ha visto.
abstract final class FigureDellaStesa {
  /// Le famiglie, ciascuna col suo nome e le forme che la dicono.
  static final Map<String, RegExp> famiglie = {
    'barriera': RegExp(r'\b(mur[oi]|ostacol[oi])\b'),
    'nodo': RegExp(r'\b(nod[oi]|sciogli\w*|sciolt[aoie])\b'),
    'strada': RegExp(r'\b(strad[ae])\b'),
    'passo': RegExp(r'\b(pass[oi])\b'),
    'passaggio': RegExp(r'\b(passaggi[oi]?)\b'),
    'terreno': RegExp(r'\b(terren[oi])\b'),
    'rotta': RegExp(r'\b(rott[ae])\b'),
    'vento': RegExp(r'\b(vent[oi])\b'),
    'granello': RegExp(r'\b(granell[oi])\b'),
    'frana': RegExp(r'\b(fran[ae])\b'),
    'intoppo': RegExp(r'\b(intopp[oi])\b'),
    'traguardo': RegExp(r'\b(traguard[oi])\b'),
    'freno': RegExp(r'\b(fren[oia]|frenare)\b'),
    'soglia': RegExp(r'\b(sogli[ae])\b'),
    'ponte': RegExp(r'\b(pont[ei])\b'),
    'seme': RegExp(r'\b(sem[ei])\b'),
    'radice': RegExp(r'\b(radic[ei])\b'),
    'luce': RegExp(r'\b(luc[ei])\b'),
    'ombra': RegExp(r'\b(ombr[ae])\b'),
    'nebbia': RegExp(r'\b(nebbi[ae])\b'),
    'fuoco': RegExp(r'\b(fuoc[oh]i?)\b'),
    'chiave': RegExp(r'\b(chiav[ei])\b'),
    'peso': RegExp(r'\b(pes[oi])\b'),
  };

  /// Le figure che [testo] usa.
  static Set<String> di(String testo) {
    final basso = testo.toLowerCase();
    return {
      for (final f in famiglie.entries)
        if (f.value.hasMatch(basso)) f.key,
    };
  }

  /// Le figure che compaiono in piu' di uno dei [pezzi], con i pezzi.
  ///
  /// **Si conta per pezzo e non per frase**: un pezzo solo puo' riprendere la
  /// sua parola, *"ha una radice. E la radice e' il Fante"*, ed e' una scelta
  /// di stile. Due pezzi diversi che dicono la stessa immagine sono la
  /// ripetizione che il fondatore ha sottolineato.
  static Map<String, List<String>> ripetuteFra(List<String> pezzi) {
    final dove = <String, List<String>>{};
    for (final f in pezzi) {
      for (final figura in di(f)) {
        dove.putIfAbsent(figura, () => []).add(f.trim());
      }
    }
    dove.removeWhere((_, pezzi) => pezzi.length < 2);
    return dove;
  }

  /// Le figure che compaiono in piu' di una frase di [testo], con le frasi.
  /// Serve quando i pezzi non si conoscono, come in un testo gia' scritto.
  static Map<String, List<String>> ripetute(String testo) {
    final frasi = testo
        .split(RegExp(r'(?<=[.!?…])\s+|\n+'))
        .where((f) => f.trim().isNotEmpty)
        .toList();
    final dove = <String, List<String>>{};
    for (final f in frasi) {
      for (final figura in di(f)) {
        dove.putIfAbsent(figura, () => []).add(f.trim());
      }
    }
    dove.removeWhere((_, frasi) => frasi.length < 2);
    return dove;
  }
}

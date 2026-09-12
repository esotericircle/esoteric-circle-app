# -*- coding: utf-8 -*-
"""CQ2.13: il tetto ferma la scena, mai l'accensione ne' gli Eos."""
NL = chr(10)
CR = chr(13)
D = 'lib/core/sigilli/diario_del_cammino.dart'


def cambia(percorso, vecchio, nuovo, quante=1):
    grezzo = open(percorso, 'rb').read().decode('utf-8')
    crlf = CR in grezzo
    s = grezzo.replace(CR + NL, NL) if crlf else grezzo
    assert s.count(vecchio) == quante, (percorso, s.count(vecchio),
                                        vecchio[:70])
    s = s.replace(vecchio, nuovo)
    open(percorso, 'wb').write(
        (s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
    assert nuovo.split(NL)[0].strip() in \
        open(percorso, 'rb').read().decode('utf-8'), percorso
    print('FATTO', percorso)


# --- 1. tutti i soddisfatti maturano, la scala esce di qui ---------------
cambia(D, """    final prossimi = <String>{
      for (final s in Sentiero.values)
        if (prossimoDi(s) case final t?) t.id,
    };
    final soddisfatti = <Traguardo>[];
    for (final traguardo in Sentieri.tuttiITraguardi) {
      if (_accesi.contains(traguardo.id)) continue;
      if (!prossimi.contains(traguardo.id)) continue;""",
       """    // **E LA SCALA E' USCITA DA QUI. Ordine CQ voce 2.13**, 3 settembre
    // 2026, decisione del fondatore: *il tetto delle feste non deve mai
    // toccare l'accensione del Sigillo ne' l'accredito degli Eos, solo la
    // scena della festa.*
    //
    // **La misura della voce 2.12 ha detto perche'.** Quattrocento giorni di
    // uso onesto con dodici arti al giorno: **centododici traguardi
    // soddisfatti e TREDICI accesi.** I tre sentieri restavano fermi su
    // gradini che chiedono arti che chi fa i Doni del giorno non tocca, e
    // dietro di loro aspettavano novantanove gradini gia' guadagnati. La
    // scala non ritardava: murava.
    //
    // Adesso qui maturano tutti quelli soddisfatti, quindi si accendono tutti
    // e i loro Eos arrivano tutti. **La scala vive nella scena**, cioe' in
    // [meritaLaScena]: e' li' che il fondatore l'aveva voluta, ed e' li' che
    // il conto del giorno peggiore resta quello dell'ordine CP voce 01.
    final soddisfatti = <Traguardo>[];
    for (final traguardo in Sentieri.tuttiITraguardi) {
      if (_accesi.contains(traguardo.id)) continue;""")

# --- 2. si accendono tutti, e non piu' uno per volta --------------------
cambia(D, """    _apriIlGiorno();
    if (!laStradaELibera) return const <Traguardo>[];
    final soddisfatti = quelliSoddisfatti(stato);
    if (soddisfatti.isEmpty) return const <Traguardo>[];
    return <Traguardo>[soddisfatti.first];
  }""",
       """    _apriIlGiorno();
    // **SI ACCENDONO TUTTI. Ordine CQ voce 2.13**, e sostituisce la riga
    // dell'ordine CP voce 01 che ne tornava uno solo dietro il freno della
    // strada libera.
    //
    // Quel freno serviva a non far vedere una raffica di feste, ed era il
    // posto sbagliato: fermava il PREMIO per governare la SCENA. Chi ha
    // guadagnato un Sigillo lo ha guadagnato, e i suoi Eos sono suoi, anche
    // se la sua festa arrivera' domani o non arrivera' affatto.
    //
    // La scena la governa [meritaLaScena], che la scala ce l'ha ancora
    // intera: al massimo tre gradini per volta, uno per Maestro, e uno solo
    // a schermo.
    return quelliSoddisfatti(stato);
  }

  /// **SE QUESTO GRADINO MERITA UNA SCENA, ADESSO.**
  /// Ordine CQ voce 2.13, 3 settembre 2026.
  ///
  /// **Qui vive la scala dell'ordine CP voce 01**, e vive solo qui: e' il
  /// gradino che chi cammina sta per prendere sul suo sentiero, e la strada
  /// dev'essere libera, cioe' nessuna festa deve essere in attesa di essere
  /// congedata.
  ///
  /// **Cio' che non merita la scena non perde niente**: e' gia' acceso, i suoi
  /// Eos sono gia' arrivati, e il suo nome sta nel Journal. Non gli manca il
  /// premio, gli manca il fuoco d'artificio, ed e' esattamente cio' che il
  /// fondatore ha chiesto quando ha visto otto feste in due funzionalita'.
  bool meritaLaScena(Traguardo traguardo) {
    if (!laStradaELibera) return false;
    for (final s in Sentiero.values) {
      if (prossimoDi(s)?.id == traguardo.id) return true;
    }
    return false;
  }""")

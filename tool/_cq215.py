# -*- coding: utf-8 -*-
"""CQ2.15: il ponte fra il motore delle date e il contesto dei Maestri."""
NL = chr(10)
CR = chr(13)


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


# --- 1. il contesto della persona porta anche cio' che arriva -----------
cambia('lib/core/maestro/natal_context.dart',
       """  const NatalContext({
    this.sunSign,
    this.moonSign,
    this.ascendant,
    this.lifeNumber,
    this.lifeNumberTitle,
    this.moonIllumination,
  });""",
       """  const NatalContext({
    this.sunSign,
    this.moonSign,
    this.ascendant,
    this.lifeNumber,
    this.lifeNumberTitle,
    this.moonIllumination,
    this.prossimoTraguardo,
    this.cosaApreIlProssimoTraguardo,
  });

  /// **IL PROSSIMO GRADINO DEL SUO CAMMINO.** Ordine CQ voce 2.15,
  /// 4 settembre 2026.
  ///
  /// **Sta qui e non in un parametro nuovo**, e la ragione e' misurata: il
  /// metodo `reply` dei fornitori AI e' implementato da undici doppioni nelle
  /// prove, e in Dart aggiungere un parametro all'interfaccia li invalida
  /// tutti. Questo oggetto invece e' gia' "cio' che sappiamo di questa
  /// persona adesso", passa da tutte le porte, e il prossimo passo del suo
  /// Cammino e' esattamente un fatto di quel genere.
  ///
  /// Nullo quando il Cammino non ha un prossimo gradino da nominare, e in
  /// quel caso nel contesto non compare nessuna riga: **un titolo vuoto
  /// insegna al modello che quella sezione va riempita.**
  final String? prossimoTraguardo;

  /// Cosa apre quel gradino, dalle parole del corpus. Serve a dire perche'
  /// vale la pena, senza promettere niente.
  final String? cosaApreIlProssimoTraguardo;""")

cambia('lib/core/maestro/natal_context.dart',
       """  factory NatalContext.fromNatal({NatalChart? chart, NatalFacts? facts}) {
    return NatalContext(""",
       """  factory NatalContext.fromNatal({
    NatalChart? chart,
    NatalFacts? facts,
    String? prossimoTraguardo,
    String? cosaApreIlProssimoTraguardo,
  }) {
    return NatalContext(
      prossimoTraguardo: prossimoTraguardo,
      cosaApreIlProssimoTraguardo: cosaApreIlProssimoTraguardo,""")

# --- 2. l'istruzione di sistema porta il blocco -------------------------
cambia('lib/services/ai/maestro_persona.dart',
       """      if (ancoraggi.isNotEmpty) ...['', LenteDelCielo.istruzionePer(maestro)],""",
       """      if (ancoraggi.isNotEmpty) ...['', LenteDelCielo.istruzionePer(maestro)],
      // **CIO' CHE ARRIVA. Ordine CQ voce 2.15**, 4 settembre 2026, e chiude
      // la regola 8 del fondatore: i Maestri devono sapere gli eventi in
      // arrivo e il prossimo passo del Cammino. Il motore delle date esisteva
      // da tre ordini e nessuno lo portava qui dentro.
      if (_cioCheArriva(natal).isNotEmpty) ...['', _cioCheArriva(natal)],""")

cambia('lib/services/ai/maestro_persona.dart',
       """  /// Istruzione di sistema completa per una conversazione con [maestro].""",
       """  /// **IL BLOCCO DI CIO' CHE ARRIVA, composto qui perche' qui c'e' il
  /// contesto della persona.** Ordine CQ voce 2.15.
  ///
  /// Gli eventi del cielo si calcolano dal segno solare, che e' il solo dato
  /// che questo oggetto porta sempre quando c'e' una nascita: senza segno non
  /// si calcola niente e il blocco non compare, invece di comparire coi soli
  /// eventi generali spacciati per personali.
  static String _cioCheArriva(NatalContext natal) {
    Zodiac? segno;
    for (final z in Zodiac.values) {
      if (z.italianName == natal.sunSign) segno = z;
    }
    final eventi = segno == null
        ? const <EventoInArrivo>[]
        : ProssimiEventi.da(adesso: DateTime.now(), segno: segno);
    return CioCheArriva.blocco(
      eventi: eventi,
      prossimoTraguardo: natal.prossimoTraguardo,
      cosaApre: natal.cosaApreIlProssimoTraguardo,
    );
  }

  /// Istruzione di sistema completa per una conversazione con [maestro].""")

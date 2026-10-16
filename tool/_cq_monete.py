# -*- coding: utf-8 -*-
"""Le monete volano davvero, e il loro suono e' piu' basso.

Ordine CQ, rilancio del 3 settembre 2026: *"manca anche l'animazione dei coins
che vanno verso il borsellino sincronizzato con l'effetto audio che bisogna
ridurre un po' il volume."*
"""
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
    prima = nuovo.split(NL)[0].strip()
    assert prima in open(percorso, 'rb').read().decode('utf-8'), percorso
    print('FATTO', percorso)


# --- 1. ogni suono dichiara quanto forte esce ---------------------------
cambia('lib/core/sensi/catalogo_suoni.dart',
       """  const SuonoDelCerchio(this.file, this.durataAttesa);

  /// Il nome del file atteso dentro `assets/audio/`.
  final String file;

  /// Quanto dovrebbe durare, per chi sceglie l'asset.
  final Duration durataAttesa;""",
       """  const SuonoDelCerchio(this.file, this.durataAttesa, {this.volume = 1.0});

  /// Il nome del file atteso dentro `assets/audio/`.
  final String file;

  /// Quanto dovrebbe durare, per chi sceglie l'asset.
  final Duration durataAttesa;

  /// **QUANTO FORTE ESCE, E LO DICHIARA IL SUONO.**
  /// Ordine CQ, rilancio del 3 settembre 2026.
  ///
  /// **Il fatto, parole del fondatore:** *"l'effetto audio bisogna ridurre un
  /// po' il volume"*, detto delle monete.
  ///
  /// **Sta nel catalogo e non nel motore**, per la stessa ragione per cui ci
  /// sta la durata: e' una proprieta' del suono, non del lettore. Un
  /// abbassamento scritto dentro il motore varrebbe per tutti e tredici, e
  /// per abbassarne uno solo bisognerebbe scrivere un caso speciale in un
  /// posto dove i suoni non hanno un nome.
  ///
  /// **Le normalizzazioni dell'ordine CN restano intere.** Li' i tredici file
  /// sono stati portati alla stessa forza misurata in LUFS, cioe' resi
  /// confrontabili fra loro; questo numero e' una decisione sopra quella
  /// misura, per un suono che il fondatore sente troppo forte nel suo
  /// momento. Uno non sostituisce l'altra.
  final double volume;""")

cambia('lib/core/sensi/catalogo_suoni.dart',
       """  /// Gli Eos che arrivano nella borsa. Due secondi interi, e nemmeno
  /// questo si accorcia, per la stessa ragione della festa.
  eos('eos.mp3', Duration(milliseconds: 2000)),""",
       """  /// Gli Eos che arrivano nella borsa. Due secondi interi, e nemmeno
  /// questo si accorcia, per la stessa ragione della festa.
  ///
  /// **ESCE AL SESSANTACINQUE PER CENTO.** Ordine CQ, rilancio del 3
  /// settembre 2026, decisione del fondatore: il tintinnio delle monete e'
  /// piu' forte del suo momento. E' l'unico dei tredici che non esce pieno,
  /// e la ragione e' che accompagna un'animazione invece di annunciare un
  /// fatto: un accompagnamento che copre cio' che accompagna e' un
  /// accompagnamento sbagliato.
  eos('eos.mp3', Duration(milliseconds: 2000), volume: 0.65),""")

# --- 2. il motore ubbidisce al catalogo ---------------------------------
cambia('lib/core/sensi/motore_audio.dart',
       """  Future<Duration?> effetto(String percorsoAsset) async {
    if (senzaLettori) return null;
    try {
      await _preparaGliEffetti();""",
       """  Future<Duration?> effetto(String percorsoAsset,
      {double volume = 1.0}) async {
    if (senzaLettori) return null;
    try {
      await _preparaGliEffetti();
      // Il volume di questo suono, dichiarato nel catalogo. Si imposta prima
      // di suonare e resta finche' un altro suono non lo cambia: il lettore
      // degli effetti e' uno solo e li suona uno alla volta.
      await _effetti.setVolume(volume.clamp(0.0, 1.0));""")

cambia('lib/core/sensi/palette_sensoriale.dart',
       """    await _motore.effetto(suono.percorso);""",
       """    await _motore.effetto(suono.percorso, volume: suono.volume);""")

# --- 3. le monete volano anche dove il borsellino non e' montato --------
cambia('lib/design_system/components/volo_degli_eos.dart',
       """    final arrivo = DoveStaIlBorsellino.scatola()?.center;
    if (arrivo == null) return false;""",
       """    // **UN VOLO SENZA BORSELLINO A SCHERMO NON SI FERMA PIU'.**
    // Ordine CQ, rilancio del 3 settembre 2026.
    //
    // **Il fatto, parole del fondatore:** *"manca l'animazione dei coins che
    // vanno verso il borsellino."*
    //
    // Qui c'era scritto **meglio niente che un volo verso il nulla**, e per
    // la scena immersiva era giusto. Ma il caso vero non e' quello: e' la
    // festa che si chiude, la barra che sta tornando, e il borsellino che in
    // quell'istante non ha ancora un riquadro misurabile. **Il suono usciva
    // e le monete no**, cioe' esattamente il difetto che l'ordine CO voce 19
    // aveva chiuso nel verso opposto, tornato dall'altro lato.
    //
    // Il ripiego non e' "il nulla": e' **l'angolo in alto a destra**, che e'
    // dove il borsellino vive in ogni schermata che ce l'ha. Le monete
    // arrivano dove la persona guardera' fra un istante, invece di non
    // partire affatto.
    final scatola = DoveStaIlBorsellino.scatola();""")

cambia('lib/design_system/components/volo_degli_eos.dart',
       """    final partenza = Offset(schermo.width / 2, schermo.height / 2);""",
       """    final partenza = Offset(schermo.width / 2, schermo.height / 2);
    final arrivo = scatola?.center ??
        Offset(schermo.width - angoloDelBorsellino.dx, angoloDelBorsellino.dy);""")

cambia('lib/design_system/components/volo_degli_eos.dart',
       """  /// QUANTE SCINTILLE PARTONO, al massimo.""",
       """  /// **DOVE ARRIVANO LE MONETE QUANDO NESSUN BORSELLINO E' MISURABILE**,
  /// contato dal bordo destro e dall'alto. E' il posto in cui il segno del
  /// borsellino vive nella barra: non e' una seconda verita' sulla sua
  /// posizione, e' il ripiego per l'istante in cui la barra non e' ancora
  /// montata.
  static const Offset angoloDelBorsellino = Offset(48, 40);

  /// QUANTE SCINTILLE PARTONO, al massimo.""")

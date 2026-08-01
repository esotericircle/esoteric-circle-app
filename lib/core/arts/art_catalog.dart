import 'package:flutter/material.dart';

import '../config/app_flags.dart';
import '../entitlement/tier.dart';
import '../maestro/maestro.dart';

/// Le fasi di lavorazione di un'arte, in ordine di lontananza.
///
/// Servono a due cose, e per entrambe conta l'ORDINE, non il nome: dire con
/// onesta' quanto e' lontana un'arte nella vista Demo, e decidere che cosa ha
/// senso mostrare alla persona. Una funzione promessa per un domani troppo
/// lontano non e' un invito, e' rumore: alla persona si mostra fino alla Fase 2,
/// il resto resta nel piano e si vede solo agli investitori.
///
/// I nomi stanno qui e non sparsi nel catalogo, cosi' un refuso non crea in
/// silenzio una fase sconosciuta: un test verifica che ogni fase usata sia una
/// di queste.
class ArtPhase {
  const ArtPhase._();

  static const String mvp = 'MVP';
  static const String fase2 = 'Fase 2';
  static const String faseSuccessiva = 'Fase successiva';
  static const String fase3 = 'Fase 3';
  static const String fase4 = 'Fase 4';
  static const String fase5 = 'Fase 5';
  static const String viralita = 'Fase viralità sociale';

  /// Dalla piu' vicina alla piu' lontana. "Fase successiva" sta subito dopo la
  /// Fase 2, quindi e' gia' oltre la soglia di quel che si mostra alla persona.
  static const List<String> ordine = [
    mvp,
    fase2,
    faseSuccessiva,
    fase3,
    fase4,
    fase5,
    viralita,
  ];

  /// L'ultima fase che la persona vede. Oltre questa, l'arte resta nel piano.
  static const String sogliaUtente = fase2;

  /// L'ordinale di una fase. Senza fase vale zero, cioe' la piu' vicina: le
  /// arti attive e le Premium non hanno fase e si mostrano sempre. Una fase
  /// sconosciuta finisce in fondo, quindi nel dubbio resta nascosta.
  static int rank(String? phase) {
    if (phase == null) return 0;
    final i = ordine.indexOf(phase);
    return i < 0 ? ordine.length : i;
  }
}

/// Lo stato di un'arte del Cerchio, uno dei tre, coerente in tutta l'app.
///
/// Lo scopo dei tre stati e' far desiderare la funzione: Premium e In arrivo si
/// devono leggere benissimo, mai un velo che le renda illeggibili.
enum ArtState {
  /// Usabile ora: card piena e vivida, si apre al tocco.
  attiva,

  /// Fatta ma chiusa dietro il Cerchio: lucchetto piccolo e testo nitido che
  /// dice cosa da' e come si sblocca.
  premium,

  /// Fase futura: velo leggero piu' etichetta di fase, testo pienamente
  /// leggibile.
  inArrivo,
}

/// Un'arte del Cerchio dentro una sottocategoria del dominio di un Maestro.
///
/// Questa e' la fonte unica dello stato delle arti: niente stato forzato dalla
/// schermata, quel che si vede e' quel che dice il catalogo. Le arti [attiva]
/// devono avere una rotta reale (`artRouteFor`), e un test lo verifica.
@immutable
class ArtEntry {
  const ArtEntry({
    required this.id,
    required this.title,
    required this.teaser,
    required this.icon,
    required this.state,
    this.requiredTier,
    this.phase,
    this.cornice = false,
  });

  final String id;
  final String title;
  final String teaser;
  final IconData icon;
  final ArtState state;

  /// Il livello che sblocca l'arte, quando e' [ArtState.premium] oppure quando
  /// arrivera' gia' riservata a un livello.
  final Tier? requiredTier;

  /// La fase in cui l'arte e' pianificata, quando e' [ArtState.inArrivo]: per
  /// esempio "MVP", "Fase 2". E' l'etichetta onesta che si mostra sulla card.
  final String? phase;

  /// Se l'arte mostra la CORNICE onesta di quel che e': un cammino di
  /// intrattenimento e crescita personale, mai una cura e mai una previsione
  /// certa. Vale per il benessere di Aura come per gli oracoli di Caligo.
  final bool cornice;
}

/// Una sottocategoria del dominio di un Maestro: il riquadro col suo titolo, con
/// dentro le arti che le appartengono.
@immutable
class ArtSection {
  const ArtSection({required this.title, required this.arts});

  final String title;
  final List<ArtEntry> arts;
}

/// Il catalogo categorizzato delle arti, per Maestro.
///
/// Riconcilia in un punto solo quel che prima viveva sparso fra il catalogo dei
/// feature flag e lo scaffale del Santuario: qui c'e' il nome a video, la
/// sottocategoria e lo stato vero. Il dominio del Maestro legge solo di qui.
class ArtCatalog {
  const ArtCatalog._();

  /// La cornice onesta delle arti, in un punto solo.
  ///
  /// Accompagnano il respiro, l'umore, il presagio e il simbolo come cammino di
  /// consapevolezza: non sono una cura e non sono una previsione certa. Si
  /// mostra dovunque un'arte con [ArtEntry.cornice] si presenti.
  static const String disclaimerCornice =
      'Cornice di intrattenimento e crescita personale, non cura medica né '
      'previsione certa del futuro. Le scelte importanti restano sempre tue.';

  /// Le sottocategorie di un Maestro, nell'ordine in cui si mostrano.
  static List<ArtSection> forMaestro(Maestro maestro) {
    switch (maestro) {
      case Maestro.medora:
        return _medora;
      case Maestro.aura:
        return _aura;
      case Maestro.caligo:
        return _caligo;
    }
  }

  /// Tutte le arti di tutti i Maestri, per i controlli di coerenza.
  static List<ArtEntry> get all => [
        for (final m in Maestro.values)
          for (final s in forMaestro(m)) ...s.arts,
      ];

  /// Le arti attive di un Maestro, quelle che si aprono davvero.
  static List<ArtEntry> activeOf(Maestro maestro) => [
        for (final s in forMaestro(maestro))
          for (final a in s.arts)
            if (a.state == ArtState.attiva) a,
      ];

  /// Se un'arte si mostra nella vista corrente.
  ///
  /// Nella Demo per gli investitori si mostra tutto, perche' li' il piano E' il
  /// contenuto. Nella vista della persona si mostrano le attive, le Premium e
  /// le in arrivo fino alla soglia ([ArtPhase.sogliaUtente]): quel che sta
  /// oltre non si cancella dal catalogo, semplicemente non si racconta ancora.
  ///
  /// Con [esente] la soglia non si applica: e' il caso di una sottocategoria
  /// tutta in cammino, che sta gia' chiusa dietro un tocco e quindi puo'
  /// mostrarsi intera senza allungare l'elenco di quel che si puo' fare adesso.
  static bool isVisible(ArtEntry art,
      {bool demo = AppFlags.isDemo, bool esente = false}) {
    if (demo || esente) return true;
    if (art.state != ArtState.inArrivo) return true;
    return ArtPhase.rank(art.phase) <=
        ArtPhase.rank(ArtPhase.sogliaUtente);
  }

  /// Se una sottocategoria ha almeno un'arte viva adesso.
  static bool hasActive(ArtSection section) =>
      section.arts.any((a) => a.state == ArtState.attiva);

  /// Le arti di una sottocategoria come si mostrano nella vista corrente.
  ///
  /// La soglia delle fasi vale dove c'e' qualcosa di vivo, perche' li' ogni
  /// riga in piu' allontana la cosa che si puo' fare adesso. Dove non c'e'
  /// nulla di vivo il gruppo e' gia' raccolto dietro un tocco, quindi si mostra
  /// intero: e' un assaggio di strada, non rumore.
  static List<ArtEntry> visibleArts(ArtSection section,
      {bool demo = AppFlags.isDemo}) {
    final esente = !hasActive(section);
    return [
      for (final a in section.arts)
        if (isVisible(a, demo: demo, esente: esente)) a,
    ];
  }

  /// Le sottocategorie di un Maestro come si mostrano davvero.
  ///
  /// Tre cose in un punto solo, valide per tutti e tre i domini: si filtrano le
  /// arti che la vista corrente non mostra, si lasciano cadere le
  /// sottocategorie rimaste vuote, e si mettono davanti quelle che hanno
  /// qualcosa di vivo, perche' chi apre il dominio deve trovare per prima la
  /// cosa che puo' fare adesso. L'ordine dichiarato nel catalogo si conserva
  /// dentro i due gruppi.
  static List<ArtSection> visibleFor(Maestro maestro,
      {bool demo = AppFlags.isDemo}) {
    final piene = <ArtSection>[];
    final inCammino = <ArtSection>[];
    for (final s in forMaestro(maestro)) {
      final arti = visibleArts(s, demo: demo);
      if (arti.isEmpty) continue;
      final sezione = ArtSection(title: s.title, arts: arti);
      (hasActive(sezione) ? piene : inCammino).add(sezione);
    }
    return [...piene, ...inCammino];
  }

  // --- Medora: Astrologia, Cartomanzia, Destino ---
  static const List<ArtSection> _medora = [
    ArtSection(title: 'Astrologia', arts: [
      ArtEntry(
        id: 'horoscope',
        title: 'Oroscopo Personalizzato',
        teaser: 'Le quattro schede del tuo giorno, sul tuo segno di nascita.',
        icon: Icons.auto_awesome,
        state: ArtState.attiva,
      ),
      ArtEntry(
        id: 'natal_chart',
        title: 'Carta Natale interattiva',
        teaser: 'La tua mappa celeste coi transiti, da esplorare al tocco.',
        icon: Icons.explore_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.mvp,
      ),
      ArtEntry(
        id: 'planetary_returns',
        title: 'Ritorni Planetari',
        teaser: 'Saturn Return e Solar Return, le soglie che tornano.',
        icon: Icons.refresh_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase2,
      ),
      ArtEntry(
        id: 'pet_astrology',
        title: 'Pet Astrology',
        teaser: 'Il cielo di chi ti fa compagnia, letto con dolcezza.',
        icon: Icons.pets_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase2,
      ),
      // Le astrologie non occidentali (vedica, cinese, maya, celtica, egizia,
      // araba) non hanno una card propria: vivono come tradizioni dentro
      // l'Oroscopo Personalizzato, cosi' non occupano spazio nel dominio.
      ArtEntry(
        id: 'astrocartography',
        title: 'Astrocartografia',
        teaser: 'I luoghi del mondo dove il tuo cielo si accende.',
        icon: Icons.map_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase4,
      ),
    ]),
    ArtSection(title: 'Compatibilità', arts: [
      ArtEntry(
        id: 'synastry_vip',
        title: 'Sinastria VIP',
        teaser: 'La tua affinità con una stella, calcolata dal cielo.',
        icon: Icons.favorite_rounded,
        state: ArtState.attiva,
      ),
      // La compatibilita' unificata: i tre livelli, astrale, angelico e
      // archetipico, vivono qui dentro e non piu' come tre card sparse su tre
      // Maestri.
      ArtEntry(
        id: 'synastry_depth',
        title: 'Sinastria Approfondita',
        teaser:
            'La lettura di coppia completa sui tre livelli, astrale, angelico e archetipico.',
        icon: Icons.favorite_border_rounded,
        state: ArtState.premium,
        requiredTier: Tier.tier2,
      ),
      ArtEntry(
        id: 'friends_compatibility',
        title: 'Compatibilità tra Amici',
        teaser: 'La sinastria fra te e le persone vere del tuo cerchio.',
        icon: Icons.group_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.viralita,
      ),
    ]),
    ArtSection(title: 'Cartomanzia', arts: [
      ArtEntry(
        id: 'tarot_spread_three',
        title: 'Stesa di Tarocchi',
        teaser: 'Il ventaglio di Medora: scegli le carte e leggi il filo.',
        icon: Icons.style,
        state: ArtState.attiva,
      ),
      ArtEntry(
        id: 'angels_oracle',
        title: 'Oracolo degli Angeli',
        teaser: 'La stesa dei settantadue nomi, per una risposta alta.',
        icon: Icons.auto_stories_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase2,
      ),
      ArtEntry(
        id: 'angel_cards',
        title: 'Carte Angeliche Oracolari',
        teaser: 'Un mazzo di luce, per messaggi brevi e chiari.',
        icon: Icons.filter_drama_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase4,
      ),
    ]),
    ArtSection(title: 'Lunologia', arts: [
      ArtEntry(
        id: 'lunology',
        title: 'Il Respiro della Luna',
        teaser:
            'Il cruscotto lunare del presente: fase con la percentuale reale, Luna nel segno, i trenta giorni lunari, il calendario biodinamico, la Luna fuori corso e i consigli per categoria.',
        icon: Icons.nightlight_round,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase2,
      ),
      ArtEntry(
        id: 'fertility_windows',
        title: 'Finestre Fertili',
        teaser:
            'Il calcolo della fertilità su base lunare col metodo Jonas, in un calendario visivo.',
        icon: Icons.spa_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.faseSuccessiva,
      ),
      ArtEntry(
        id: 'lunar_affinity',
        title: 'Affinità Lunare',
        teaser:
            'La compatibilità di fase lunare fra due persone, con la card da condividere.',
        icon: Icons.brightness_2_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase2,
      ),
      ArtEntry(
        id: 'lunar_calendar',
        title: 'Calendario Lunare Personale',
        teaser:
            'La vista mensile a calendario, coi rituali e le indicazioni per ogni fase.',
        icon: Icons.calendar_month_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.faseSuccessiva,
      ),
    ]),
    ArtSection(title: 'Destino', arts: [
      ArtEntry(
        id: 'guardian_angel',
        title: 'Angelo Custode personale',
        teaser: 'Il tuo fra i settantadue, dalla tua data di nascita.',
        icon: Icons.shield_moon_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.mvp,
      ),
      ArtEntry(
        id: 'karmic_reading',
        title: 'Lettura Karmica',
        teaser: 'I Nodi Lunari: da dove vieni e dove stai andando.',
        icon: Icons.all_inclusive_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase2,
      ),
      ArtEntry(
        id: 'narrative_destiny',
        title: 'Destino Narrativo',
        teaser:
            'Il tuo cammino verso l\'anima e il destino, raccontato in tappe, ognuna con la sua immagine.',
        icon: Icons.menu_book_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.faseSuccessiva,
      ),
    ]),
  ];

  // --- Aura: Chakra, Energia, Archetipi ---
  //
  // Tutte le arti di Aura toccano il benessere della persona, quindi portano la
  // cornice onesta: intrattenimento e crescita personale, mai cura.
  static const List<ArtSection> _aura = [
    ArtSection(title: 'Chakra', arts: [
      ArtEntry(
        id: 'chakra_scan',
        title: 'Scan dei Chakra',
        teaser: 'I sette centri che si illuminano col loro livello.',
        icon: Icons.blur_circular_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.mvp,
        cornice: true,
      ),
      ArtEntry(
        id: 'crystal_therapy',
        title: 'Cristalloterapia',
        teaser: 'Le pietre giuste per riequilibrare la tua energia.',
        icon: Icons.diamond_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.mvp,
        cornice: true,
      ),
      ArtEntry(
        id: 'crystal_oracle',
        title: 'Oracolo dei Cristalli',
        teaser: 'Estrai la pietra che ti parla oggi.',
        icon: Icons.auto_awesome_outlined,
        state: ArtState.inArrivo,
        phase: ArtPhase.mvp,
        cornice: true,
      ),
      ArtEntry(
        id: 'crystal_ball',
        title: 'Sfera di Cristallo',
        teaser: 'Uno sguardo intuitivo dentro la sfera.',
        icon: Icons.panorama_fish_eye,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase2,
        cornice: true,
      ),
      ArtEntry(
        id: 'energy_cleansing',
        title: 'Purificazione Energetica',
        teaser: 'Un gesto per liberare il campo da ciò che pesa.',
        icon: Icons.water_drop_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.mvp,
        cornice: true,
      ),
      ArtEntry(
        id: 'aura_analysis',
        title: 'Analisi dell\'Aura',
        teaser: 'I colori della tua aura e cosa raccontano.',
        icon: Icons.brightness_7,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase4,
        cornice: true,
      ),
    ]),
    ArtSection(title: 'Energia', arts: [
      ArtEntry(
        id: 'meditation',
        // LA PAROLA "VOCE" ESCE finche' la voce non c'e'. Un nome che promette
        // una cosa che l'arte non fa e' la stessa bugia dei due nomi per una
        // schermata sola: chi entra si aspetta una guida parlata e trova il
        // respiro e il suono.
        title: 'Meditazione',
        teaser: 'Il respiro e la quiete, guidati dal ritmo e dal suono.',
        icon: Icons.self_improvement,
        state: ArtState.attiva,
        cornice: true,
      ),
      // LE FREQUENZE NON SONO UN'ARTE A PARTE, e per questo la voce e' uscita
      // dal catalogo invece di diventare attiva.
      //
      // 432, 528 e i battiti binaurali sono gia' vivi DENTRO la Meditazione:
      // dichiararli in arrivo era falso, e dichiararli attivi avrebbe creato
      // due voci sulla stessa rotta, cioe' due nomi per una schermata sola.
      // E' esattamente la bugia da cui nasce questa voce, e correggerla in un
      // verso creandola nell'altro non sarebbe stato correggerla.
      //
      // Se un giorno le frequenze avranno una schermata loro, la voce torna.
      ArtEntry(
        id: 'sleep_stories',
        title: 'Sleep Stories',
        teaser: 'Racconti dolci che accompagnano il tuo sonno.',
        icon: Icons.bedtime_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.mvp,
        cornice: true,
      ),
      ArtEntry(
        id: 'daily_affirmations',
        title: 'Affermazioni del Giorno',
        teaser: 'Una parola potenziante, cucita sul tuo cielo del giorno.',
        icon: Icons.format_quote_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.mvp,
        cornice: true,
      ),
      // Nota per il team, mai a video: contenuti e grafiche dei mudra vanno
      // disegnati e scritti da noi, mai ripresi da fonti terze, per il diritto
      // d'autore.
      ArtEntry(
        id: 'mudra',
        title: 'Mudra',
        teaser: 'Gesti delle mani che orientano la tua energia.',
        icon: Icons.waving_hand_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase2,
        cornice: true,
      ),
      ArtEntry(
        id: 'belief_art',
        title: 'Arte delle Convinzioni',
        teaser: 'Un percorso guidato per radicare pensieri che ti sostengono.',
        icon: Icons.psychology_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase2,
        cornice: true,
      ),
      ArtEntry(
        id: 'biorhythm',
        title: 'Bioritmo',
        teaser: 'Le tue tre onde, fisica, emotiva e mentale, dal giorno di nascita.',
        icon: Icons.show_chart_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase2,
        cornice: true,
      ),
      ArtEntry(
        id: 'lucid_dreams',
        title: 'Sogni Lucidi',
        teaser: 'Tecniche per riconoscere il sogno e viverlo da protagonista.',
        icon: Icons.nights_stay_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase5,
        cornice: true,
      ),
    ]),
    ArtSection(title: 'Archetipi', arts: [
      ArtEntry(
        id: 'archetype_test',
        title: 'Test Archetipo',
        teaser: 'Scopri quale dei dodici archetipi ti guida.',
        icon: Icons.psychology_alt,
        state: ArtState.attiva,
        cornice: true,
      ),
      ArtEntry(
        id: 'face_constellation',
        title: 'Costellazione del Viso',
        teaser:
            'La videocamera legge i tuoi tratti e li unisce in una costellazione.',
        icon: Icons.face_retouching_natural,
        state: ArtState.attiva,
        cornice: true,
      ),
      ArtEntry(
        id: 'mood_tracker',
        title: 'Mood Tracker',
        teaser: 'Il tuo umore giorno per giorno, in dialogo coi transiti.',
        icon: Icons.mood_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.mvp,
        cornice: true,
      ),
      ArtEntry(
        id: 'palmistry',
        title: 'Chiromanzia Ibrida',
        teaser: 'Le linee della mano lette insieme al tuo cielo.',
        icon: Icons.back_hand,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase2,
        cornice: true,
      ),
      // La Compatibilita' Archetipica non vive piu' qui: il suo contenuto e' il
      // livello archetipico dentro la Sinastria Approfondita di Medora.
      ArtEntry(
        id: 'graphology',
        title: 'Grafologia Esoterica',
        teaser: 'La tua scrittura col dito rivela chi sei.',
        icon: Icons.draw_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase4,
        cornice: true,
      ),
      ArtEntry(
        id: 'voice_analysis',
        title: 'Cosmic Voice Analysis',
        teaser: 'La tua voce racconta il tuo stato energetico.',
        icon: Icons.mic_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase4,
        cornice: true,
      ),
    ]),
  ];

  // --- Caligo: Rune, Rituali, Cabala ---
  //
  // Vincolo di contenuto, mai a video: i riti attingono soltanto a pratiche
  // reali e documentate, mai inventate, e restano fuori i riti sulla volonta'
  // di terzi. Il Cerchio accompagna chi lo chiede, non agisce su altri.
  static const List<ArtSection> _caligo = [
    ArtSection(title: 'Rune', arts: [
      ArtEntry(
        id: 'rune_draw',
        title: 'Estrazione Rune',
        teaser: 'Scuoti e lancia le pietre, leggi il presagio di Caligo.',
        icon: Icons.casino,
        state: ArtState.attiva,
        cornice: true,
      ),
      ArtEntry(
        id: 'i_ching',
        title: 'I-Ching',
        teaser: 'I sessantaquattro esagrammi del Libro dei Mutamenti.',
        icon: Icons.view_headline_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase2,
        cornice: true,
      ),
      ArtEntry(
        id: 'pendulum',
        title: 'Pendolo',
        teaser: 'Poni la domanda, il pendolo oscilla la risposta.',
        icon: Icons.swap_vert_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase2,
        cornice: true,
      ),
      ArtEntry(
        id: 'coffee_reading',
        title: 'Lettura dei Fondi di Caffè',
        teaser: 'Le figure nella tazza raccontano il tuo domani.',
        icon: Icons.local_cafe_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase2,
        cornice: true,
      ),
      ArtEntry(
        id: 'dream_reading',
        title: 'Interpretazione dei Sogni',
        teaser: 'Racconta il sogno, i suoi simboli ti parlano.',
        icon: Icons.cloud_queue_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase2,
        cornice: true,
      ),
    ]),
    ArtSection(title: 'Rituali', arts: [
      ArtEntry(
        id: 'guide_animal',
        title: 'Animale Guida',
        teaser: 'Il tuo animale di potere emerge dalla nebbia.',
        icon: Icons.pets_rounded,
        state: ArtState.attiva,
        cornice: true,
      ),
      ArtEntry(
        id: 'animal_message',
        title: 'Messaggio dall\'Animale',
        teaser: 'La voce del tuo animale, giorno per giorno.',
        icon: Icons.record_voice_over_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.mvp,
        cornice: true,
      ),
      ArtEntry(
        id: 'micro_rituals',
        title: 'Micro-rituali',
        teaser: 'Candela, mantra e parola d\'intenzione, riti brevi e veri.',
        icon: Icons.local_fire_department_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.mvp,
        cornice: true,
      ),
      ArtEntry(
        id: 'daily_invocation',
        title: 'Invocazione del Giorno',
        teaser: 'L\'invocazione quotidiana nella voce di Caligo.',
        icon: Icons.campaign_outlined,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase2,
        cornice: true,
      ),
      ArtEntry(
        id: 'guided_rituals',
        title: 'Rituali Guidati Interattivi',
        teaser: 'Riti guidati passo passo, più profondi.',
        icon: Icons.route_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase4,
        cornice: true,
      ),
    ]),
    // La MAGIA e' la terza sottocategoria distintiva di Caligo. Il
    // Briefing Operativo prescrive tre funzioni distintive per Maestro e la
    // chat non e' una di quelle, quindi con l'uscita dell'Albero della Vita
    // Caligo era rimasto a due contro le tre di Medora e di Aura.
    //
    // Il Sigillo NON e' una voce nuova: e' il 'Sigillo Magico Personale' che
    // stava fra i Rituali, col teaser che gia' diceva 'trasforma la tua
    // intenzione in un sigillo'. Aggiungerne un secondo avrebbe promesso due
    // volte la stessa cosa, quindi quello e' stato spostato qui e acceso.
    ArtSection(title: 'Magia', arts: [
      ArtEntry(
        id: 'magic_sigil',
        title: 'Sigillo dell\'Intenzione',
        teaser: 'La tua intenzione diventa un glifo che è solo tuo.',
        icon: Icons.gesture_rounded,
        state: ArtState.attiva,
        phase: ArtPhase.mvp,
        cornice: true,
      ),
      // I nomi delle tre vie colorate sono PROVVISORI: dipendono dal
      // confronto di Mauro con Gaetano Daguraz, il praticante reale. Stanno
      // in ViaMagica, un punto solo, quindi cambiarli costa una riga.
      ArtEntry(
        id: 'magia_rossa',
        title: 'Magia Rossa',
        teaser: 'Il cuore e il desiderio, con le loro regole.',
        icon: Icons.favorite_border_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase2,
        cornice: true,
      ),
      ArtEntry(
        id: 'magia_bianca',
        title: 'Magia Bianca',
        teaser: 'Protezione e chiarezza, i confini che si tracciano.',
        icon: Icons.shield_moon_outlined,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase2,
        cornice: true,
      ),
      ArtEntry(
        id: 'magia_verde',
        title: 'Magia Verde',
        teaser: 'Erbe e natura, il sapere che viene dalla terra.',
        icon: Icons.local_florist_outlined,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase2,
        cornice: true,
      ),
      // OPERA AL NERO, mai 'Magia Nera'. Nella lettura alchemica la nigredo
      // e' la fase di dissoluzione che precede la rinascita, non un
      // maleficio, e Caligo nei briefing e' il custode che la magia nera la
      // conosce senza praticarla. E' anche cio' che tiene la voce lontana da
      // problemi in revisione degli store.
      ArtEntry(
        id: 'opera_al_nero',
        title: 'Opera al Nero',
        teaser: 'La nigredo, dissoluzione che prepara la rinascita.',
        icon: Icons.dark_mode_outlined,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase2,
        cornice: true,
      ),
    ]),
    ArtSection(title: 'Cabala', arts: [
      // L'Albero della Vita e' uscito del tutto dalla Demo per decisione di
      // Mauro: il concetto resta nei documenti, per la Fase 2 del Journal, non
      // qui. Con lui restano fuori i settantadue nomi dello Shem, che erano
      // contenuto suo e non una card a se'.
      ArtEntry(
        id: 'angel_numbers',
        title: 'Numeri Ricorrenti',
        teaser: 'I numeri ricorrenti e il messaggio che portano.',
        icon: Icons.repeat_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.mvp,
        cornice: true,
      ),
      // La Compatibilita' Angelica non vive piu' qui: il suo contenuto e' il
      // livello angelico dentro la Sinastria Approfondita di Medora.
      ArtEntry(
        id: 'numerology',
        title: 'Numerologia del Destino',
        teaser: 'Il numero della tua vita e della tua anima.',
        icon: Icons.pin_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase3,
        cornice: true,
      ),
      ArtEntry(
        id: 'human_design',
        title: 'Human Design',
        teaser: 'Il tuo schema energetico, tipo e autorità.',
        icon: Icons.hub_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase3,
        cornice: true,
      ),
      ArtEntry(
        id: 'cosmic_wrapped',
        title: 'Cosmic Wrapped',
        teaser: 'Il tuo anno esoterico raccolto in una sintesi.',
        icon: Icons.card_giftcard_rounded,
        state: ArtState.inArrivo,
        phase: ArtPhase.fase3,
        cornice: true,
      ),
    ]),
  ];
}

import 'package:flutter/material.dart';

import '../entitlement/tier.dart';
import '../maestro/maestro.dart';

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
        id: 'synastry_vip',
        title: 'Sinastria VIP',
        teaser: 'La tua affinità con una stella, calcolata dal cielo.',
        icon: Icons.favorite_rounded,
        state: ArtState.attiva,
      ),
      ArtEntry(
        id: 'natal_chart',
        title: 'Carta Natale interattiva',
        teaser: 'La tua mappa celeste coi transiti, da esplorare al tocco.',
        icon: Icons.explore_rounded,
        state: ArtState.inArrivo,
        phase: 'MVP',
      ),
      ArtEntry(
        id: 'synastry_depth',
        title: 'Sinastria Approfondita',
        teaser:
            'La lettura di coppia completa, aspetto per aspetto, con i tempi del legame.',
        icon: Icons.favorite_border_rounded,
        state: ArtState.premium,
        requiredTier: Tier.tier2,
      ),
      ArtEntry(
        id: 'lunology',
        title: 'Il Respiro della Luna',
        teaser: 'Lunologia: le fasi che accompagnano il tuo mese.',
        icon: Icons.nightlight_round,
        state: ArtState.inArrivo,
        phase: 'Fase 2',
      ),
      ArtEntry(
        id: 'lunar_affinity',
        title: 'Affinità Lunare',
        teaser: 'L\'intesa fra due Lune, oltre il segno solare.',
        icon: Icons.brightness_2_rounded,
        state: ArtState.inArrivo,
        phase: 'Fase 2',
      ),
      ArtEntry(
        id: 'planetary_returns',
        title: 'Ritorni Planetari',
        teaser: 'Saturn Return e Solar Return, le soglie che tornano.',
        icon: Icons.refresh_rounded,
        state: ArtState.inArrivo,
        phase: 'Fase 2',
      ),
      ArtEntry(
        id: 'pet_astrology',
        title: 'Pet Astrology',
        teaser: 'Il cielo di chi ti fa compagnia, letto con dolcezza.',
        icon: Icons.pets_rounded,
        state: ArtState.inArrivo,
        phase: 'Fase 2',
      ),
      ArtEntry(
        id: 'vedic_astrology',
        title: 'Astrologia Vedica',
        teaser: 'Le tradizioni siderali, coi loro tempi e le loro case.',
        icon: Icons.brightness_7,
        state: ArtState.inArrivo,
        phase: 'Fase 3',
        requiredTier: Tier.tier3,
      ),
      ArtEntry(
        id: 'bazi',
        title: 'Astrologia Cinese Ba Zi',
        teaser: 'I quattro pilastri del destino, dalla tua ora di nascita.',
        icon: Icons.grid_view_rounded,
        state: ArtState.inArrivo,
        phase: 'Fase 3',
      ),
      ArtEntry(
        id: 'other_traditions',
        title: 'Maya, celtica, egizia, araba',
        teaser: 'Le altre tradizioni del cielo, ciascuna con la sua voce.',
        icon: Icons.public_rounded,
        state: ArtState.inArrivo,
        phase: 'Fase 4',
      ),
      ArtEntry(
        id: 'astrocartography',
        title: 'Astrocartografia',
        teaser: 'I luoghi del mondo dove il tuo cielo si accende.',
        icon: Icons.map_rounded,
        state: ArtState.inArrivo,
        phase: 'Fase 4',
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
        phase: 'Fase 2',
      ),
      ArtEntry(
        id: 'angel_cards',
        title: 'Carte Angeliche Oracolari',
        teaser: 'Un mazzo di luce, per messaggi brevi e chiari.',
        icon: Icons.filter_drama_rounded,
        state: ArtState.inArrivo,
        phase: 'Fase 4',
      ),
    ]),
    ArtSection(title: 'Destino', arts: [
      ArtEntry(
        id: 'guardian_angel',
        title: 'Angelo Custode personale',
        teaser: 'Il tuo fra i settantadue, dalla tua data di nascita.',
        icon: Icons.shield_moon_rounded,
        state: ArtState.inArrivo,
        phase: 'MVP',
      ),
      ArtEntry(
        id: 'karmic_reading',
        title: 'Lettura Karmica',
        teaser: 'I Nodi Lunari: da dove vieni e dove stai andando.',
        icon: Icons.all_inclusive_rounded,
        state: ArtState.inArrivo,
        phase: 'Fase 2',
      ),
    ]),
  ];

  // --- Aura: Chakra, Energia, Archetipi ---
  // Il catalogo completo di Aura arriva in un passaggio successivo: qui ci sono
  // le funzioni gia' note, mappate nelle sue tre arti.
  static const List<ArtSection> _aura = [
    ArtSection(title: 'Chakra', arts: [
      ArtEntry(
        id: 'chakra_scan',
        title: 'Scan dei Chakra',
        teaser: 'I sette centri, uno per uno, con quel che chiedono.',
        icon: Icons.blur_circular_rounded,
        state: ArtState.inArrivo,
        phase: 'Fase 2',
      ),
    ]),
    ArtSection(title: 'Energia', arts: [
      ArtEntry(
        id: 'meditation',
        title: 'Meditazione',
        teaser: 'Suono generato e respiro guidato, con la cimatica.',
        icon: Icons.self_improvement,
        state: ArtState.attiva,
      ),
      ArtEntry(
        id: 'frequencies',
        title: 'Frequenze',
        teaser: 'Campane, mantra e battiti binaurali, da ascoltare.',
        icon: Icons.graphic_eq_rounded,
        state: ArtState.inArrivo,
        phase: 'Fase 2',
      ),
    ]),
    ArtSection(title: 'Archetipi', arts: [
      ArtEntry(
        id: 'archetype_test',
        title: 'Test Archetipo',
        teaser: 'L\'archetipo junghiano che ti muove, in poche domande.',
        icon: Icons.psychology_alt,
        state: ArtState.inArrivo,
        phase: 'MVP',
      ),
      ArtEntry(
        id: 'face_constellation',
        title: 'Costellazione del Viso',
        teaser: 'I tratti del tuo volto diventano una costellazione.',
        icon: Icons.face_retouching_natural,
        state: ArtState.inArrivo,
        phase: 'Fase 2',
      ),
      ArtEntry(
        id: 'palmistry',
        title: 'Chiromanzia',
        teaser: 'La mano che unisce i tratti stabili ai transiti del giorno.',
        icon: Icons.back_hand,
        state: ArtState.inArrivo,
        phase: 'Fase 2',
      ),
    ]),
  ];

  // --- Caligo: Rune, Rituali, Cabala ---
  // Anche qui il catalogo completo arriva dopo: per ora le funzioni gia' note.
  static const List<ArtSection> _caligo = [
    ArtSection(title: 'Rune', arts: [
      ArtEntry(
        id: 'rune_draw',
        title: 'Estrazione Rune',
        teaser: 'Getta le rune dell\'antico Futhark e leggi il presagio.',
        icon: Icons.casino,
        state: ArtState.inArrivo,
        phase: 'MVP',
      ),
      ArtEntry(
        id: 'extended_oracles',
        title: 'Oracoli Estesi',
        teaser: 'I-Ching, pendolo e altri modi di interrogare il profondo.',
        icon: Icons.blur_on,
        state: ArtState.inArrivo,
        phase: 'Fase 3',
      ),
    ]),
    ArtSection(title: 'Rituali', arts: [
      ArtEntry(
        id: 'magic_sigil',
        title: 'Sigillo Magico',
        teaser: 'Traccia il tuo sigillo e dagli un\'intenzione.',
        icon: Icons.gesture_rounded,
        state: ArtState.inArrivo,
        phase: 'Fase 2',
      ),
      ArtEntry(
        id: 'candle_ritual',
        title: 'Rito della Candela',
        teaser: 'Un rito semplice, che si accende e si accompagna.',
        icon: Icons.local_fire_department_rounded,
        state: ArtState.inArrivo,
        phase: 'Fase 3',
      ),
    ]),
    ArtSection(title: 'Cabala', arts: [
      ArtEntry(
        id: 'tree_of_life',
        title: 'Albero della Vita',
        teaser: 'Le dieci sfere e i sentieri che le uniscono.',
        icon: Icons.account_tree_rounded,
        state: ArtState.inArrivo,
        phase: 'Fase 2',
      ),
      ArtEntry(
        id: 'numerology',
        title: 'Numerologia del Destino',
        teaser: 'Il tuo numero della vita e i numeri che ti accompagnano.',
        icon: Icons.pin_rounded,
        state: ArtState.inArrivo,
        phase: 'Fase 2',
      ),
    ]),
  ];
}

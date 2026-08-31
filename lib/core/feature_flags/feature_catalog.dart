import 'package:flutter/material.dart';

import '../entitlement/tier.dart';
import '../maestro/maestro.dart';
import '../santuario/function_shelf.dart';
import 'feature_flag.dart';

/// Catalogo delle funzioni dell'app note al client.
///
/// In C1 il catalogo e' volutamente parziale: contiene funzioni di esempio
/// scelte per mostrare in Home tutti e tre gli stati (attiva, Coming soon,
/// premium bloccata). Man mano che i checkpoint aggiungono funzioni reali,
/// le voci si aggiungono qui e i loro id restano allineati ai parametri
/// Remote Config.
///
/// Gli stati di default riflettono la mappa dei feature flag della Demo
/// (Handoff Fase C sezione 6): nella Demo alcune funzioni sono attive, altre
/// Coming soon, altre premium.
class FeatureCatalog {
  FeatureCatalog._();

  static const List<FeatureDefinition> _dichiarate = [
    // --- Attive (dominio Medora) ---
    FeatureDefinition(
      id: 'natal_chart',
      title: 'Carta Natale',
      teaser: 'La tua mappa celeste, calcolata sulle effemeridi svizzere.',
      icon: Icons.auto_awesome,
      owner: Maestro.medora,
    ),
    FeatureDefinition(
      id: 'tarot_spread_three',
      title: 'Stesa di Tarocchi',
      teaser: 'Passato, Presente e Futuro nel ventaglio di Medora.',
      icon: Icons.style,
      owner: Maestro.medora,
    ),

    // --- Attive (dominio Aura) ---
    FeatureDefinition(
      id: 'archetype_test',
      title: 'Test Archetipo',
      teaser: 'Scopri il tuo archetipo junghiano.',
      icon: Icons.psychology_alt,
      owner: Maestro.aura,
    ),

    // --- Attive (dominio Caligo) ---
    FeatureDefinition(
      id: 'rune_draw',
      title: 'Estrazione Rune',
      teaser: 'Lancia le rune e ascolta il presagio di Caligo.',
      icon: Icons.casino,
      owner: Maestro.caligo,
    ),

    // --- I RICORDI DEL CERCHIO, ordine CG voce 13 ---
    //
    // **QUESTA VOCE SUPERA LO SCOPE DELLA DEMO CONGELATO**, e va scritto
    // perche' altrimenti la prossima sessione trova due decisioni che si
    // contraddicono. Parole del fondatore, 31 agosto 2026: "la 7 perche'
    // voglio che entri nella demo".
    //
    // **ATTIVA e non premium.** La timeline, la ricerca e le Carte sono di
    // tutti; la sola parte che chiede un piano e' la lettura in prosa del
    // mese, che vive nella voce CG.11 e ha il suo cancello li'.
    //
    // **Non sta sullo scaffale del Santuario, e non e' una dimenticanza**: il
    // Cosmic Journal non e' un'arte, e ha tre porte sue, cioe' il menu'
    // utente, il Passaporto e la riga in cima a ogni chat.
    FeatureDefinition(
      id: 'ricordi_del_cerchio',
      title: 'Cosmic Journal',
      teaser:
          'Il tuo cammino e i tuoi ricordi, giorno per giorno, con le carte '
          'che hai custodito.',
      icon: Icons.auto_stories_outlined,
      defaultAvailability: RemoteAvailability.enabled,
    ),

    // --- Coming soon (non ancora pronte in questa fase) ---
    // Viva, non piu' in arrivo: lo scaffale del Santuario e il manifest
    // `docs/stato_funzioni.json` la dicono viva da tempo, e questo catalogo
    // era rimasto indietro. Tre fonti per lo stesso stato, con una che
    // diceva il contrario delle altre due.
    FeatureDefinition(
      id: 'face_constellation',
      title: 'Costellazione del Viso',
      teaser:
          'La videocamera trasforma i tratti del tuo volto in una costellazione.',
      icon: Icons.face_retouching_natural,
      owner: Maestro.aura,
      defaultAvailability: RemoteAvailability.enabled,
    ),
    FeatureDefinition(
      id: 'palmistry',
      title: 'Chiromanzia',
      teaser:
          'La lettura della mano che unisce i tuoi tratti stabili ai transiti del giorno. Presto disponibile.',
      icon: Icons.back_hand,
      owner: Maestro.aura,
      defaultAvailability: RemoteAvailability.comingSoon,
    ),
    FeatureDefinition(
      id: 'extended_oracles',
      title: 'Oracoli Estesi',
      teaser:
          'I-Ching, pendolo, cristalli e fondi di caffè si uniranno al cerchio. Presto disponibili.',
      icon: Icons.blur_on,
      owner: Maestro.caligo,
      defaultAvailability: RemoteAvailability.comingSoon,
    ),

    // --- Premium bloccate (richiedono un tier superiore) ---
    FeatureDefinition(
      id: 'masters_memory',
      title: 'Memoria dei Maestri',
      teaser:
          'I Maestri ricordano il tuo cammino. Disponibile con l\'abbonamento.',
      icon: Icons.hub,
      requiredTier: Tier.tier1,
    ),
    FeatureDefinition(
      id: 'synastry_depth',
      title: 'Sinastria Approfondita',
      teaser:
          'La lettura di coppia completa, aspetto per aspetto. Disponibile con l\'abbonamento.',
      icon: Icons.favorite,
      owner: Maestro.medora,
      requiredTier: Tier.tier2,
    ),
    FeatureDefinition(
      id: 'vedic_astrology',
      title: 'Astrologia Vedica',
      teaser:
          'Le tradizioni siderali, esclusiva dei livelli superiori.',
      icon: Icons.brightness_7,
      owner: Maestro.medora,
      requiredTier: Tier.tier3,
    ),
  ];

  static List<FeatureDefinition> forMaestro(Maestro maestro) =>
      all.where((f) => f.owner == maestro).toList(growable: false);

  static FeatureDefinition? byId(String id) {
    for (final f in all) {
      if (f.id == id) return f;
    }
    return null;
  }

  /// Tutte le funzioni che il catalogo conosce.
  ///
  /// Le dichiarate qui, PIU' quelle dello scaffale del Santuario che qui non
  /// avevano una definizione: erano sei su dieci, quindi il catalogo dei flag
  /// non conosceva piu' della meta' di cio' che l'app mostra. Derivarle invece
  /// di ricopiarle evita che le due liste divergano ancora, come e' gia'
  /// successo alla Costellazione del Viso.
  static List<FeatureDefinition> get all {
    final noti = _dichiarate.map((f) => f.id).toSet();
    return [
      ..._dichiarate,
      for (final fn in FunctionShelf.functions)
        if (!noti.contains(fn.id))
          FeatureDefinition(
            id: fn.id,
            title: fn.title,
            teaser: fn.teaser,
            icon: fn.icon,
            owner: fn.maestro,
            defaultAvailability: fn.live
                ? RemoteAvailability.enabled
                : RemoteAvailability.comingSoon,
          ),
    ];
  }
}

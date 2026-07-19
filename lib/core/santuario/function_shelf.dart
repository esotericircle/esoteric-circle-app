import 'package:flutter/material.dart';

import '../maestro/maestro.dart';

/// Una funzione dello scaffale del Santuario: cosa mostra la card e se e' viva.
class ShelfFunction {
  const ShelfFunction({
    required this.id,
    required this.title,
    required this.teaser,
    required this.icon,
    required this.maestro,
    this.live = false,
  });

  final String id;
  final String title;
  final String teaser;
  final IconData icon;
  final Maestro maestro;

  /// Vero se la funzione ha gia' una schermata reale e si apre. Altrimenti resta
  /// una card in arrivo, con badge Coming soon e anticipo elegante al tocco, mai
  /// un vicolo cieco.
  final bool live;
}

/// Lo scaffale delle funzioni del Santuario, in ordine di apertura.
///
/// L'ordine iniziale privilegia le funzioni piu' popolari. In seguito si
/// personalizza sulle funzioni piu' usate dalla persona: [ordered] accetta una
/// classifica d'uso opzionale e vi riordina lo scaffale, tenendo in coda, nel
/// loro ordine di default, le funzioni non ancora usate.
///
/// Questo file e' sola configurazione: si cambia l'ordine o si aggiunge una card
/// modificando questa lista, senza toccare la logica del Santuario.
class FunctionShelf {
  const FunctionShelf._();

  static const List<ShelfFunction> functions = [
    ShelfFunction(
      id: 'tarot_spread_three',
      title: 'Stesa a Tre Carte',
      teaser: 'Passato, presente e futuro nel ventaglio di Medora.',
      icon: Icons.style,
      maestro: Maestro.medora,
      live: true,
    ),
    ShelfFunction(
      id: 'synastry_vip',
      title: 'Sinastria VIP',
      teaser: 'La tua affinità con una stella, calcolata dal cielo.',
      icon: Icons.favorite_rounded,
      maestro: Maestro.medora,
      live: true,
    ),
    ShelfFunction(
      id: 'archetype_test',
      title: 'Test Archetipo',
      teaser: 'Scopri il tuo archetipo junghiano con Aura.',
      icon: Icons.psychology_alt,
      maestro: Maestro.aura,
    ),
    ShelfFunction(
      id: 'face_constellation',
      title: 'Costellazione del Viso',
      teaser: 'I tratti del tuo volto diventano una costellazione.',
      icon: Icons.face_retouching_natural,
      maestro: Maestro.aura,
    ),
    ShelfFunction(
      id: 'day_oracle',
      title: 'Oracolo del Giorno',
      teaser: 'Il presagio di oggi, gratuito ogni giorno.',
      icon: Icons.wb_twilight,
      maestro: Maestro.medora,
      live: true,
    ),
    ShelfFunction(
      id: 'horoscope',
      title: 'Oroscopo',
      teaser: 'Le quattro schede del tuo giorno, nella voce di Medora.',
      icon: Icons.auto_awesome,
      maestro: Maestro.medora,
      live: true,
    ),
    ShelfFunction(
      id: 'sunset_rune',
      title: 'Runa del Tramonto',
      teaser: 'La runa che scende con la sera, da svelare.',
      icon: Icons.brightness_3,
      maestro: Maestro.caligo,
      live: true,
    ),
    ShelfFunction(
      id: 'meditation',
      title: 'Meditazione',
      teaser: 'Suono generato e respiro guidato, con Aura.',
      icon: Icons.self_improvement,
      maestro: Maestro.aura,
      live: true,
    ),
  ];

  /// Lo scaffale ordinato. Con [usageRanking] (gli id piu' usati per primi) le
  /// funzioni usate salgono in testa nell'ordine dato; le altre seguono
  /// nell'ordine di default. Senza classifica resta l'ordine popolare iniziale.
  static List<ShelfFunction> ordered([List<String> usageRanking = const []]) {
    if (usageRanking.isEmpty) return functions;
    final byId = {for (final f in functions) f.id: f};
    final result = <ShelfFunction>[];
    final seen = <String>{};
    for (final id in usageRanking) {
      final f = byId[id];
      if (f != null && seen.add(id)) result.add(f);
    }
    for (final f in functions) {
      if (seen.add(f.id)) result.add(f);
    }
    return result;
  }
}

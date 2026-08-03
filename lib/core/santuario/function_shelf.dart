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

  /// Le funzioni dell'elenco sotto l'eroe.
  ///
  /// I Doni del giorno NON stanno qui: l'Oracolo del Giorno e la Runa del
  /// Tramonto vivono nella striscia in cima, che e' la loro casa, e comparivano
  /// anche in questo elenco. La stessa cosa due volte nella stessa schermata fa
  /// sembrare l'elenco piu' pieno di quello che e', e toglie posto alle arti che
  /// hanno solo questa strada per farsi trovare.
  static const List<ShelfFunction> functions = [
    ShelfFunction(
      id: 'tarot_spread_three',
      title: 'Stesa di Tarocchi',
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
      live: true,
    ),
    ShelfFunction(
      id: 'face_constellation',
      title: 'Costellazione del Viso',
      teaser: 'I tratti del tuo volto diventano una costellazione.',
      icon: Icons.face_retouching_natural,
      maestro: Maestro.aura,
      live: true,
    ),
    ShelfFunction(
      id: 'horoscope',
      title: 'Oroscopo',
      teaser: 'Le quattro schede del tuo giorno, raccontate da Medora.',
      icon: Icons.auto_awesome,
      maestro: Maestro.medora,
      live: true,
    ),
    ShelfFunction(
      id: 'guide_animal',
      title: 'Animale Guida',
      teaser: 'Il tuo totem dal cielo, letto da Caligo.',
      icon: Icons.pets,
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

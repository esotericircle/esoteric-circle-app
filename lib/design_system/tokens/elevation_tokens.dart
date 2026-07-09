import 'package:flutter/material.dart';

/// Layer 1: primitivi di profondita' per l'estetica Materico 2.5D.
///
/// Il 2.5D nasce da ombre stratificate (una scura in basso per il distacco
/// dal fondo, una chiara e tenue in alto come luce radente) senza rendering
/// 3D pieno. Questi set di ombre sono i mattoni; i componenti li combinano
/// con i colori del Maestro attivo per l'alone colorato.
///
/// Riferimento: Master Tecnico, design system Materico 2.5D (profondita' e
/// ombre senza 3D pieno).
class ElevationTokens {
  ElevationTokens._();

  /// Ombra morbida di base per superfici a riposo (card, tessere).
  static List<BoxShadow> resting({Color glow = Colors.transparent}) => [
        // Distacco dal fondo.
        const BoxShadow(
          color: Color(0x66000000),
          blurRadius: 24,
          spreadRadius: -6,
          offset: Offset(0, 14),
        ),
        // Alone colorato tenue del Maestro attivo.
        BoxShadow(
          color: glow.withValues(alpha: 0.16),
          blurRadius: 32,
          spreadRadius: -4,
          offset: const Offset(0, 6),
        ),
      ];

  /// Ombra piu' marcata per elementi sollevati (pressione, focus, hero).
  static List<BoxShadow> raised({Color glow = Colors.transparent}) => [
        const BoxShadow(
          color: Color(0x80000000),
          blurRadius: 40,
          spreadRadius: -8,
          offset: Offset(0, 22),
        ),
        BoxShadow(
          color: glow.withValues(alpha: 0.28),
          blurRadius: 48,
          spreadRadius: -2,
          offset: const Offset(0, 4),
        ),
      ];

  /// Luce radente superiore, resa come sottile bordo chiaro sul contorno.
  static const Color topHighlight = Color(0x26FFFFFF);
}

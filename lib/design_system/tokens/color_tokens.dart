import 'package:flutter/material.dart';

/// Layer 1 del Design Token System: i primitivi.
///
/// Sono i valori di colore grezzi, senza significato semantico. Nessun
/// widget usa direttamente questi valori: passano sempre attraverso i token
/// semantici della palette del Maestro (vedi `MaestroPalette`). Tenerli
/// isolati qui permette di ritoccare la tavolozza in un solo punto.
///
/// Riferimento: Master Tecnico, Design Token System a tre layer (primitivi,
/// semantici, di componente).
class ColorTokens {
  ColorTokens._();

  // --- Oro, filo conduttore comune a tutti i Maestri ---
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF0D77B);
  static const Color goldBright = Color(0xFFF6E7A8);
  static const Color goldDeep = Color(0xFFA67C1A);

  // --- Medora: blu profondo con oro ---
  static const Color medoraDeepest = Color(0xFF060B1A);
  static const Color medoraDeep = Color(0xFF0A1330);
  static const Color medoraSurface = Color(0xFF12204A);
  static const Color medoraPrimary = Color(0xFF2E4CA6);
  static const Color medoraGlow = Color(0xFF4C7BE8);

  // --- Aura: verde smeraldo con oro ---
  static const Color auraDeepest = Color(0xFF03140F);
  static const Color auraDeep = Color(0xFF072A20);
  static const Color auraSurface = Color(0xFF0C3F2F);
  static const Color auraPrimary = Color(0xFF10A37A);
  static const Color auraGlow = Color(0xFF2ED8A7);

  // --- Caligo: rosso con oro ---
  static const Color caligoDeepest = Color(0xFF1A0406);
  static const Color caligoDeep = Color(0xFF350A0D);
  static const Color caligoSurface = Color(0xFF551317);
  static const Color caligoPrimary = Color(0xFFB0262E);
  static const Color caligoGlow = Color(0xFFE8555C);

  // --- Stato neutro: cosmo nero profondo con oro e un velo viola lontano ---
  static const Color neutralDeepest = Color(0xFF010208);
  static const Color neutralDeep = Color(0xFF080718);
  static const Color neutralSurface = Color(0xFF1C1338);
  static const Color neutralPrimary = Color(0xFF5A3AA6);
  static const Color neutralGlow = Color(0xFF8A6BE0);

  // --- Neutri di testo e superfici trasparenti ---
  static const Color textPrimary = Color(0xFFF4F1E8);
  static const Color textSecondary = Color(0xFFC7C2B4);
  static const Color textMuted = Color(0xFF8A8578);

  // Velo scuro per il glassmorphism e le superfici in vetro.
  static const Color glassTint = Color(0x1AFFFFFF);
  static const Color glassStroke = Color(0x33FFFFFF);
  static const Color scrim = Color(0x99000000);

  // Stato disabilitato / Coming soon: grigio desaturato.
  static const Color comingSoonVeil = Color(0xB3121016);
  static const Color lockedVeil = Color(0xCC0B0A0F);
}

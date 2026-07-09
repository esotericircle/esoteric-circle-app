import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'color_tokens.dart';

/// Layer 1: primitivi tipografici.
///
/// Due famiglie: una serif evocativa e cerimoniale per i titoli e le voci
/// dei Maestri (Cinzel), una serif leggibile e calda per il corpo del testo
/// (EB Garamond). Il pacchetto google_fonts carica i font a runtime e ripiega
/// sul font di sistema se la rete non e' disponibile, quindi non servono
/// asset binari nel repository.
///
/// Riferimento: Master Tecnico, sistema tipografico del design system.
class TypographyTokens {
  TypographyTokens._();

  /// Serif cerimoniale per display, titoli e nomi dei Maestri.
  static TextStyle display(
          {double size = 34, FontWeight weight = FontWeight.w600}) =>
      GoogleFonts.cinzel(
        fontSize: size,
        fontWeight: weight,
        height: 1.15,
        letterSpacing: 1.2,
        color: ColorTokens.textPrimary,
      );

  /// Serif leggibile per il testo narrato e il corpo.
  static TextStyle body(
          {double size = 16, FontWeight weight = FontWeight.w400}) =>
      GoogleFonts.ebGaramond(
        fontSize: size,
        fontWeight: weight,
        height: 1.45,
        color: ColorTokens.textPrimary,
      );

  /// Costruisce il TextTheme completo dell'app a partire dalle due famiglie.
  static TextTheme buildTextTheme() {
    return TextTheme(
      displayLarge: display(size: 44, weight: FontWeight.w700),
      displayMedium: display(size: 34),
      displaySmall: display(size: 28),
      headlineMedium: display(size: 24, weight: FontWeight.w500),
      headlineSmall: display(size: 20, weight: FontWeight.w500),
      titleLarge: display(size: 18, weight: FontWeight.w600),
      titleMedium: body(size: 16, weight: FontWeight.w600),
      titleSmall: body(size: 14, weight: FontWeight.w600),
      bodyLarge: body(size: 17),
      bodyMedium: body(size: 15),
      bodySmall: body(size: 13).copyWith(color: ColorTokens.textSecondary),
      labelLarge: GoogleFonts.cinzel(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
        color: ColorTokens.textPrimary,
      ),
      labelMedium: GoogleFonts.cinzel(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.6,
        color: ColorTokens.textSecondary,
      ),
    );
  }
}

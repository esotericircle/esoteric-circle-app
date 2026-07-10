import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'color_tokens.dart';

/// Layer 1: primitivi tipografici.
///
/// Due famiglie incluse nel bundle come asset locali (nessuna rete): una serif
/// cerimoniale per i titoli e le voci dei Maestri (Cinzel), una serif leggibile
/// e calda per il corpo del testo (EB Garamond). Sono font variabili: il peso
/// si applica a runtime con `FontVariation('wght', ...)`, cosi' la resa e'
/// precisa e prevedibile su mobile e in anteprima web.
///
/// Riferimento: Master Tecnico, sistema tipografico del design system.
class TypographyTokens {
  TypographyTokens._();

  static const String _display = 'Cinzel';
  static const String _body = 'EBGaramond';

  /// Minimi leggibili non negoziabili: nessun testo scende sotto queste soglie,
  /// qualunque valore passi il chiamante. Cosi' anche le etichette cerimoniali
  /// restano nitide su schermo e in anteprima. I font restano scalabili: il
  /// `textScaler` di sistema si applica sopra queste basi.
  static const double minDisplay = 20;
  static const double minBody = 16;
  static const double minLabel = 12.5;

  static List<FontVariation> _wght(double weight) =>
      [FontVariation('wght', weight)];

  /// Serif cerimoniale per display, titoli e nomi dei Maestri.
  static TextStyle display({double size = 34, double weight = 600}) => TextStyle(
        fontFamily: _display,
        fontSize: math.max(size, minDisplay),
        fontVariations: _wght(weight),
        fontWeight: _nearest(weight),
        height: 1.18,
        letterSpacing: 1.2,
        color: ColorTokens.textPrimary,
      );

  /// Serif leggibile per il testo narrato e il corpo.
  static TextStyle body({double size = 16, double weight = 400}) => TextStyle(
        fontFamily: _body,
        fontSize: math.max(size, minBody),
        fontVariations: _wght(weight),
        fontWeight: _nearest(weight),
        height: 1.5,
        color: ColorTokens.textPrimary,
      );

  /// Etichetta in stile cerimoniale (maiuscoletto spaziato).
  static TextStyle label({double size = 13, double weight = 600}) => TextStyle(
        fontFamily: _display,
        fontSize: math.max(size, minLabel),
        fontVariations: _wght(weight),
        fontWeight: _nearest(weight),
        letterSpacing: 1.6,
        color: ColorTokens.textPrimary,
      );

  /// Costruisce il TextTheme completo dell'app a partire dalle due famiglie.
  static TextTheme buildTextTheme() {
    return TextTheme(
      displayLarge: display(size: 44, weight: 700),
      displayMedium: display(size: 34),
      displaySmall: display(size: 28),
      headlineMedium: display(size: 24, weight: 500),
      headlineSmall: display(size: 20, weight: 500),
      titleLarge: display(size: 18, weight: 600),
      titleMedium: body(size: 17, weight: 600),
      titleSmall: body(size: 15, weight: 600),
      bodyLarge: body(size: 18),
      bodyMedium: body(size: 16),
      bodySmall: body(size: 15).copyWith(color: ColorTokens.textSecondary),
      labelLarge: label(size: 14),
      labelMedium: label(size: 12, weight: 600)
          .copyWith(color: ColorTokens.textSecondary),
    );
  }

  /// Mappa un peso numerico sul FontWeight piu' vicino, usato come fallback e
  /// per la semantica; la resa reale passa da FontVariation.
  static FontWeight _nearest(double weight) {
    final index = ((weight / 100).round().clamp(1, 9)) - 1;
    return FontWeight.values[index];
  }
}

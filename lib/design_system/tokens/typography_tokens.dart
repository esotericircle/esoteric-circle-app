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

  /// Famiglia cerimoniale (Cinzel). Pubblica perche' l'anello curvo della ruota
  /// archetipica costruisce uno stile su misura, con una dimensione calcolata
  /// per far stare i dodici nomi sull'arco, e quindi non passa da `label()` che
  /// imporrebbe il minimo leggibile pensato per il testo dritto.
  static const String displayFamily = 'Cinzel';
  static const String _display = displayFamily;
  static const String _body = 'EBGaramond';

  /// Minimi di sola leggibilita': sono una rete di sicurezza contro il testo
  /// illeggibile, non una misura di progetto.
  ///
  /// Erano 20, 17 e 12.5, ed erano tarati male: su 571 chiamate con misura
  /// esplicita sotto `lib/`, 457 stavano sotto il proprio minimo, cioe' l'ottanta
  /// per cento, su 64 file. Un sistema in cui otto chiamate su dieci violano il
  /// minimo non ha un problema nei punti di chiamata: ha un minimo inventato. E
  /// il danno non era teorico, perche' il clamp e' silenzioso: `label(size: 10)`
  /// e `label(size: 12)` finivano tutti e due a 12.5, quindi la gerarchia che il
  /// codice dichiarava non esisteva a video, e nessuno se ne accorgeva.
  ///
  /// Ora sono soglie di leggibilita' vera. Chi vuole una misura piu' grande la
  /// chiede, e la ottiene; chi ne chiede una piu' piccola del minimo sta
  /// scrivendo testo che non si legge, e viene fermato da
  /// `test/tipografia_minimi_test.dart`. I font restano scalabili: il
  /// `textScaler` di sistema si applica sopra queste basi.
  static const double minDisplay = 16;
  static const double minBody = 13;
  static const double minLabel = 11;

  /// Dimensione del corpo informativo: ogni testo che spiega, istruisce o guida
  /// (sottotitoli, istruzioni del gesto, righe di aiuto, descrizioni) usa questa
  /// misura generosa, ben leggibile sul cosmo. Le etichette decorative in
  /// maiuscoletto restano invece compatte con `label()`.
  ///
  /// Resta a 18 e il ragionamento regge anche coi minimi nuovi, anzi meglio: ora
  /// e' una misura scelta per la guida e non il minimo del corpo testo appena
  /// arrotondato, quindi dice davvero qualcosa quando la si chiede.
  static const double guide = 18;

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

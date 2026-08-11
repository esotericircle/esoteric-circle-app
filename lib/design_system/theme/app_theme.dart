import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'maestro_palette.dart';

/// Costruisce il `ThemeData` base dell'app.
///
/// I colori per-Maestro sono applicati dai componenti che leggono
/// `context.palette` (vedi `MaestroScope`), cosi' l'intera interfaccia puo'
/// sfumare al cambio di Maestro. Questo tema serve come base scura coerente
/// per i widget Material standard (dialog, snackbar, testo di default).
class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    const base = MaestroPalette.neutral;
    final scheme = ColorScheme.fromSeed(
      seedColor: base.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: base.primary,
      secondary: ColorTokens.gold,
      surface: base.surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: base.deepest,
      textTheme: TypographyTokens.buildTextTheme(),
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: ColorTokens.textPrimary,
      ),
      iconTheme: const IconThemeData(color: ColorTokens.textPrimary),
      // NESSUN AVVISO DI SISTEMA COL FONDO BIANCO, ordine L voce 1c. Il
      // gating non passa piu' dalle SnackBar, ma le poche di servizio che
      // restano (condivisioni fallite, esiti brevi) devono vestire il buio
      // dell'app, non la superficie inversa chiara di fabbrica.
      snackBarTheme: SnackBarThemeData(
        backgroundColor: base.surfaceElevated,
        contentTextStyle: TypographyTokens.corpo()
            .copyWith(color: ColorTokens.textPrimary),
      ),
    );
  }
}

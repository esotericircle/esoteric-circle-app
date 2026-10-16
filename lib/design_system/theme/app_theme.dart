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

  /// **IL VELO PIU' FITTO CHE UNA BARRA DEL TITOLO PUO' PRENDERE.** Ordine FY
  /// voce 20, 16 ottobre 2026. Il fondatore, sulla build 2312: *"Quando
  /// scorro in alto, la barra del titolo compare solida di botto e non piu'
  /// trasparente"*, e poi *"Tutte le barre del titolo di ogni funzionalita'
  /// devono restare sempre semitrasparenti, tutte e per sempre"*.
  ///
  /// Nessuna barra del titolo supera questo velo, in nessuno stato: a riposo,
  /// scorsa, con qualcosa che le passa sotto. Il titolo resta leggibile
  /// perche' al sessanta per cento il colore piu' chiaro dell'app che le
  /// scorre sotto si spegne abbastanza da lasciare all'oro e al testo
  /// primario almeno 3 di contrasto, il minimo dei titoli grandi; e cio' che
  /// scorre sotto si vede ancora, come il fondatore vuole. Lo misura
  /// `le_barre_del_titolo_restano_semitrasparenti_test`.
  static const double veloDellaBarra = 0.6;

  static ThemeData dark() {
    const base = MaestroPalette.neutral;
    final scheme = ColorScheme.fromSeed(
      seedColor: base.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: base.primary,
      // **LA SCRITTA SUL COLORE PRIMARIO SI LEGGE.** Visto sul Realme il 30
      // settembre 2026, nella rivelazione del segno e nell'oroscopo di
      // un'amica: "Condividi" e "Manda a Lucia" stavano in viola scuro sul
      // pulsante viola, 1,6 di contrasto. Il primario lo si dichiarava qui, il
      // colore di cio' che ci sta sopra no: restava quello che lo schema
      // calcola dal seme per il SUO primario, che e' chiaro, e quindi era
      // scuro. Dodici pulsanti pieni dell'app non dichiarano uno stile e lo
      // prendevano da qui. **PROVENIENZA IGNOTA**: il tema non l'ha mai
      // dichiarato, e nessuna voce lo ha tolto. La tavolozza lo dice da
      // sempre (`onPrimary`), adesso lo dice anche lo schema.
      onPrimary: base.onPrimary,
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
      // **LA BARRA NON CAMBIA QUANDO LE SI SCORRE SOTTO.** Ordine FY voce 20.
      // In Material 3 una barra con qualcosa che le scorre sotto sale a
      // un'elevazione di 3 (`scrolledUnderElevation` di fabbrica), ci mette
      // l'ombra e la tinta della superficie, e senza un fondo dichiarato
      // prende `surfaceContainer`, che e' pieno. Qui si spegne tutto per ogni
      // barra dell'app, in un punto solo: chi scrive una barra nuova senza
      // pensarci la trova gia' semitrasparente in ogni stato.
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        foregroundColor: ColorTokens.textPrimary,
      ),
      iconTheme: const IconThemeData(color: ColorTokens.textPrimary),
      // **NESSUN SUONO CHE IL FONDATORE NON ABBIA SCELTO.**
      // Ordine CQ voce 1.08, 3 settembre 2026.
      //
      // **Il fatto, parole del fondatore:** *"togli ogni effetto sonoro che
      // non ho scelto io."*
      //
      // **La causa, misurata e non dedotta.** Ogni comando Material chiama
      // il ritorno di sistema quando lo si preme, e su Android quel richiamo fa
      // suonare al SISTEMA il suo click e vibrare il telefono. Non e' un
      // suono di questa app: non sta nel catalogo, non passa dalla porta
      // unica, non conosce l'interruttore del silenzio del Cerchio, e nessuna
      // guardia del catalogo poteva vederlo perche' non e' un file negli
      // asset. **In tutta l'app non c'era un solo `enableFeedback` scritto**,
      // quindi valeva ovunque il vero di fabbrica.
      //
      // Si spegne QUI, sul tema, e non comando per comando: un interruttore
      // per comando vorrebbe dire che il primo che si dimentica riporta il
      // click di sistema, e nessuno saprebbe dove cercarlo. Gli `InkWell`
      // scritti a mano non leggono il tema e portano il loro, ed e' una
      // guardia a contarli.
      //
      // **PROVENIENZA IGNOTA.** Il comportamento e' quello di fabbrica di
      // Flutter: non c'e' una voce che lo abbia introdotto, c'e' un ordine
      // che non lo ha mai spento.
      filledButtonTheme: const FilledButtonThemeData(
          style: ButtonStyle(enableFeedback: false)),
      elevatedButtonTheme: const ElevatedButtonThemeData(
          style: ButtonStyle(enableFeedback: false)),
      textButtonTheme:
          const TextButtonThemeData(style: ButtonStyle(enableFeedback: false)),
      outlinedButtonTheme: const OutlinedButtonThemeData(
          style: ButtonStyle(enableFeedback: false)),
      iconButtonTheme:
          const IconButtonThemeData(style: ButtonStyle(enableFeedback: false)),
      segmentedButtonTheme: const SegmentedButtonThemeData(
          style: ButtonStyle(enableFeedback: false)),
      listTileTheme: const ListTileThemeData(enableFeedback: false),
      dropdownMenuTheme: const DropdownMenuThemeData(
          inputDecorationTheme: InputDecorationTheme()),
      menuButtonTheme:
          const MenuButtonThemeData(style: ButtonStyle(enableFeedback: false)),
      // NESSUN AVVISO DI SISTEMA COL FONDO BIANCO, ordine L voce 1c. Il
      // gating non passa piu' dalle SnackBar, ma le poche di servizio che
      // restano (condivisioni fallite, esiti brevi) devono vestire il buio
      // dell'app, non la superficie inversa chiara di fabbrica.
      snackBarTheme: SnackBarThemeData(
        backgroundColor: base.surfaceElevated,
        contentTextStyle:
            TypographyTokens.corpo().copyWith(color: ColorTokens.textPrimary),
      ),
    );
  }
}

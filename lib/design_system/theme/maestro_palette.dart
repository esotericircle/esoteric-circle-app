import 'package:flutter/material.dart';

import '../../core/maestro/maestro.dart';
import '../tokens/color_tokens.dart';

/// Layer 2 del Design Token System: i token semantici.
///
/// Una `MaestroPalette` traduce i primitivi di `ColorTokens` nei ruoli
/// concreti che i componenti consumano (fondo, superficie, primario, oro,
/// alone). Ogni Maestro, piu' lo stato neutro, ha la sua palette. Il resto
/// dell'app non conosce mai i valori grezzi: chiede sempre alla palette.
///
/// Riferimento: Master Tecnico (palette tematiche dei Maestri) e Handoff
/// Fase C sezione 5.
@immutable
class MaestroPalette {
  const MaestroPalette({
    required this.key,
    required this.label,
    required this.backgroundGradient,
    required this.surface,
    required this.surfaceElevated,
    required this.primary,
    required this.glow,
    required this.gold,
    required this.goldSoft,
    required this.onPrimary,
    required this.textPrimary,
    required this.textSecondary,
  });

  /// Chiave semantica (Maestro o neutro) a cui la palette appartiene.
  final ThemeKey key;
  final String label;

  /// Gradiente di fondo immersivo, dal piu' scuro al piu' saturo.
  final List<Color> backgroundGradient;
  final Color surface;
  final Color surfaceElevated;

  /// **IL PRIMARIO E' UN COLORE DI MARCHIO, E NON PORTA MAI TESTO.**
  /// Ordine CL voce 08, misurato dall'ordine CI.
  ///
  /// I quattro primari delle tavolozze, contro i sette fondi veri del
  /// censimento dei grigi, fanno ventotto coppie: **ventisei non arrivano
  /// nemmeno a 4,5 di contrasto**, cioe' alla soglia dei titoli grandi,
  /// figurarsi ai 7 che questo progetto pretende dai testi piccoli. Solo
  /// `aura.primary` regge, e solo su due fondi su sette.
  ///
  /// **Sta benissimo su un bordo, su un riempimento, su un anello, su un
  /// alone.** Non deve mai essere il colore di una parola che qualcuno deve
  /// leggere.
  ///
  /// **Il modo in cui il difetto entra non e' scriverlo**, ed e' la parte da
  /// ricordare: nessuno ha mai scritto `color: palette.primary` su un testo.
  /// La riga "I giorni prima" era viola perche' un `TextButton` senza stile
  /// prende il primario dello SCHEMA MATERIAL, che e' quello della tavolozza
  /// neutra. Il colore arriva **per eredita'**, e per questo la guardia che
  /// lo sorveglia non cerca una stringa nel sorgente: enumera i comandi che
  /// il colore non lo dichiarano.
  ///
  /// Sorvegliato da `test/il_censimento_dei_grigi_test.dart`, due prove: "il
  /// primario non porta mai testo" e "nessun comando di testo prende il
  /// colore dal tema senza dirlo".
  final Color primary;

  /// Colore dell'alone luminoso, usato per bagliori e ombre colorate.
  final Color glow;
  final Color gold;
  final Color goldSoft;
  final Color onPrimary;
  final Color textPrimary;
  final Color textSecondary;

  // --- Palette dei tre Maestri e dello stato neutro ---

  static const MaestroPalette medora = MaestroPalette(
    key: ThemeKey.of(Maestro.medora),
    label: 'Medora',
    backgroundGradient: [
      ColorTokens.medoraDeepest,
      ColorTokens.medoraDeep,
      ColorTokens.medoraSurface,
    ],
    surface: ColorTokens.medoraSurface,
    surfaceElevated: Color(0xFF1A2C63),
    primary: ColorTokens.medoraPrimary,
    glow: ColorTokens.medoraGlow,
    gold: ColorTokens.gold,
    goldSoft: ColorTokens.goldLight,
    onPrimary: ColorTokens.textPrimary,
    textPrimary: ColorTokens.textPrimary,
    textSecondary: ColorTokens.textSecondary,
  );

  static const MaestroPalette aura = MaestroPalette(
    key: ThemeKey.of(Maestro.aura),
    label: 'Aura',
    backgroundGradient: [
      ColorTokens.auraDeepest,
      ColorTokens.auraDeep,
      ColorTokens.auraSurface,
    ],
    surface: ColorTokens.auraSurface,
    surfaceElevated: Color(0xFF115240),
    primary: ColorTokens.auraPrimary,
    glow: ColorTokens.auraGlow,
    gold: ColorTokens.gold,
    goldSoft: ColorTokens.goldLight,
    // **L'INCHIOSTRO SULLO SMERALDO E' SCURO, ordine GA voce GA.10.** Il
    // crema sul verde di Aura faceva 2,84 a 1 ("SCEGLI IL SINTOMO",
    // "Comincia", "Inquadra il tuo volto"): il verde e' il piu' luminoso dei
    // tre primari; l'inchiostro scuro gli da' 5,89. PROVENIENZA IGNOTA: la
    // tavolozza ha sempre dichiarato lo stesso crema per tutti i Maestri.
    onPrimary: ColorTokens.auraDeepest,
    textPrimary: ColorTokens.textPrimary,
    textSecondary: ColorTokens.textSecondary,
  );

  static const MaestroPalette caligo = MaestroPalette(
    key: ThemeKey.of(Maestro.caligo),
    label: 'Caligo',
    backgroundGradient: [
      ColorTokens.caligoDeepest,
      ColorTokens.caligoDeep,
      ColorTokens.caligoSurface,
    ],
    surface: ColorTokens.caligoSurface,
    surfaceElevated: Color(0xFF6B1A1F),
    primary: ColorTokens.caligoPrimary,
    glow: ColorTokens.caligoGlow,
    gold: ColorTokens.gold,
    goldSoft: ColorTokens.goldLight,
    onPrimary: ColorTokens.textPrimary,
    textPrimary: ColorTokens.textPrimary,
    textSecondary: ColorTokens.textSecondary,
  );

  static const MaestroPalette neutral = MaestroPalette(
    key: ThemeKey.neutral(),
    label: 'Il Cerchio',
    backgroundGradient: [
      ColorTokens.neutralDeepest,
      ColorTokens.neutralDeep,
      ColorTokens.neutralSurface,
    ],
    surface: ColorTokens.neutralSurface,
    surfaceElevated: Color(0xFF2E1C57),
    primary: ColorTokens.neutralPrimary,
    glow: ColorTokens.neutralGlow,
    gold: ColorTokens.gold,
    goldSoft: ColorTokens.goldLight,
    onPrimary: ColorTokens.textPrimary,
    textPrimary: ColorTokens.textPrimary,
    textSecondary: ColorTokens.textSecondary,
  );

  /// Restituisce la palette per una chiave di tema.
  static MaestroPalette forKey(ThemeKey key) {
    switch (key.maestro) {
      case Maestro.medora:
        return medora;
      case Maestro.aura:
        return aura;
      case Maestro.caligo:
        return caligo;
      case null:
        return neutral;
    }
  }

  /// Colore dominante per gli sfondi e le ombre (il piu' saturo del gradiente).
  Color get deepest => backgroundGradient.first;

  /// **L'INCHIOSTRO SULL'ORO, ordine GA voce GA.10.** Il testo di un
  /// pulsante pieno d'oro e' scuro, mai il crema di [onPrimary]: il crema sta
  /// sul primario viola, blu, verde o rosso del Maestro; sull'oro
  /// (`D4AF37`) fa 1,86 a 1, cioe' non si legge (visto sul Realme in "Chiama
  /// nel tuo Cerchio", "Apri la rubrica", "Manda il link" e "Compila il
  /// Ritratto"). Il fondo piu' scuro del Maestro sull'oro fa da 9,3 a 9,9.
  ///
  /// **PROVENIENZA IGNOTA** per i dodici pulsanti che avevano
  /// `backgroundColor: palette.gold` con `foregroundColor: palette.onPrimary`:
  /// l'accoppiata e' entrata copiando lo stile del pulsante primario, e
  /// nessuna voce l'ha mai misurata. Sorvegliata da
  /// `i_testi_da_leggere_hanno_il_contrasto_test`.
  Color get onGold => deepest;

  /// Interpola due palette. E' il cuore della dissolvenza cromatica al cambio
  /// di Maestro: interpolando ogni ruolo di colore, l'intera interfaccia
  /// transita da un tema all'altro in modo continuo, non a scatto.
  static MaestroPalette lerp(MaestroPalette a, MaestroPalette b, double t) {
    Color c(Color x, Color y) => Color.lerp(x, y, t)!;
    final int stops = a.backgroundGradient.length;
    return MaestroPalette(
      // La chiave semantica segue la destinazione una volta superata la meta'.
      key: t < 0.5 ? a.key : b.key,
      label: t < 0.5 ? a.label : b.label,
      backgroundGradient: List<Color>.generate(
        stops,
        (i) => c(a.backgroundGradient[i], b.backgroundGradient[i]),
      ),
      surface: c(a.surface, b.surface),
      surfaceElevated: c(a.surfaceElevated, b.surfaceElevated),
      primary: c(a.primary, b.primary),
      glow: c(a.glow, b.glow),
      gold: c(a.gold, b.gold),
      goldSoft: c(a.goldSoft, b.goldSoft),
      onPrimary: c(a.onPrimary, b.onPrimary),
      textPrimary: c(a.textPrimary, b.textPrimary),
      textSecondary: c(a.textSecondary, b.textSecondary),
    );
  }
}

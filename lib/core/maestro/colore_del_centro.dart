import 'dart:ui';

import 'chakra_del_giorno.dart';

/// **IL COLORE DEI SETTE CENTRI, SECONDO LA TRADIZIONE.**
/// Ordine DB voce 04, 9 settembre 2026.
///
/// **Parole dell'ordine**: *"Il bianco e nero esce. Il fiore prende la palette
/// del centro acceso oggi, secondo la tradizione: rosso per Muladhara, arancio
/// per Svadhisthana, giallo per Manipura, verde per Anahata, azzurro per
/// Vishuddha, indaco per Ajna, viola per Sahasrara."*
///
/// **DA DOVE VIENE QUESTA CORRISPONDENZA, e va detta per quello che e'.** I
/// sette colori dell'arcobaleno associati ai sette centri non stanno nelle
/// fonti sanscrite: nel Sat-Cakra-Nirupana di Purnananda, 1577, i cakra
/// portano colori diversi da questi, e il rosso sta in cima e non in basso.
/// **La scala arcobaleno e' una convenzione occidentale del Novecento**,
/// diffusa a partire dalle letture teosofiche e poi dal New Age.
///
/// **Si usa lo stesso, e si dichiara.** E' la corrispondenza che chiunque
/// riconosce, ed e' quella che l'ordine chiede per nome: **non si spaccia per
/// millenaria.** E' la stessa regola applicata al solfeggio nella voce DB.02.
///
/// **PERCHE' UNA PORTA PROPRIA E NON UNA COSTANTE NEL PITTORE.** Il colore del
/// centro serve al fiore, alla card del respiro e domani a qualunque altra
/// scena che parli del centro di oggi: scritto dentro il pittore sarebbe una
/// verita' sola finche' non ne nasce una seconda da qualche altra parte.
abstract final class ColoreDelCentro {
  /// I sette colori, nello stesso ordine dei sette centri.
  ///
  /// Sono tinte profonde e non primarie da schermo: la scena di questa app e'
  /// un cielo notturno, e un rosso puro su fondo scuro vibra invece di
  /// posarsi.
  static const List<Color> perCentro = [
    Color(0xFFC0392B), // Muladhara, la radice: rosso
    Color(0xFFE07A28), // Svadhisthana, il sacro: arancio
    Color(0xFFE3B505), // Manipura, il fuoco: giallo
    Color(0xFF2E9E6B), // Anahata, il cuore: verde
    Color(0xFF2E86C1), // Vishuddha, la gola: azzurro
    Color(0xFF3A4FA0), // Ajna, il terzo occhio: indaco
    Color(0xFF7D4FA8), // Sahasrara, la corona: viola
  ];

  /// Il colore del centro acceso in [giorno].
  static Color di(DateTime giorno) =>
      perCentro[(giorno.weekday - 1) % perCentro.length];

  /// Il colore del centro all'indice [i], protetto dai fuori scala.
  static Color allIndice(int i) => perCentro[i % perCentro.length];

  /// **LA SFUMATURA DI UN ANELLO**, piu' satura al cuore e piu' tenue verso
  /// fuori. Ordine DB voce 04: *"il colore non e' piatto: ogni anello ha la
  /// sua sfumatura"*.
  ///
  /// [quota] va da zero al cuore a uno all'anello piu' esterno.
  static Color sfumato(Color base, double quota) {
    final q = quota.clamp(0.0, 1.0);
    // Verso fuori il colore si schiarisce e perde un poco di corpo: e' come
    // si comporta un petalo vero, che al bordo e' piu' sottile.
    return Color.lerp(base, const Color(0xFFF2E4C9), 0.30 * q) ?? base;
  }

  /// **IL FILO DI LUCE SUL BORDO DEL PETALO.** Sempre piu' chiaro della
  /// tinta, mai bianco puro: il bianco su un cielo notturno taglia.
  static Color bordoDi(Color base) =>
      Color.lerp(base, const Color(0xFFFFF6E0), 0.55) ?? base;

  /// **IL CIELO TINTO DEL CENTRO DI OGGI.** Ordine DB voce 04: *"il fondo non
  /// e' bianco e non e' nero piatto: e' il cielo cosmico dell'app, tinto
  /// appena del colore del centro di oggi"*. Appena: sette centesimi, che si
  /// vedono soltanto se si guardano due giorni di seguito.
  static Color cieloTinto(Color base) =>
      base.withValues(alpha: 0.07);

  /// Il nome del centro di [giorno], per i testi che devono nominarlo.
  static String nomeDi(DateTime giorno) => ChakraDelGiorno.di(giorno).italiano;
}

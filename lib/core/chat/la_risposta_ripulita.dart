import '../maestro/voce_del_maestro.dart';

/// **LA RISPOSTA RIPULITA DALLE FRASI FATTE E DAGLI ERRORI DI REGOLA.** Ordine
/// EJ voci 05 e 08, 24 settembre 2026.
///
/// Il fondatore ha letto *"Comprendo la tua inquietudine"*, una frase che la
/// voce dei Maestri vieta per nome da mesi: il divieto arrivava al modello, e
/// il modello ogni tanto la scriveva lo stesso. Nel collaudo EJ del 24
/// settembre, primo giro, due risposte su diciotto aprivano cosi'
/// (*"Comprendo che il lavoro possa essere fonte di inquietudine"*, *"Capisco
/// che l'idea di fermarti possa sembrare difficile"*), e sei portavano la
/// virgola prima di "e" che le regole di lingua del progetto vietano.
///
/// **Una regola che il modello rispetta quasi sempre si fa rispettare
/// sempre a valle**, come il cielo detto e il marcatore: qui, prima che il
/// testo arrivi a schermo.
///
/// - Una frase che comincia con un'apertura vietata **si toglie intera**: sono
///   formule di empatia che non dicono niente alla persona, e la risposta
///   diretta sta nella frase dopo. Se togliendola la risposta restasse vuota,
///   resta com'e'.
/// - Il trattino lungo diventa una virgola.
/// - La virgola prima di "e" o "ed" se ne va.
abstract final class LaRispostaRipulita {
  static String applica(String testo) {
    final righe = testo.split('\n');
    final fuori = <String>[];
    for (final riga in righe) {
      fuori.add(_regoleDiLingua(_senzaFrasiFatte(riga)));
    }
    final pulito = fuori.join('\n');
    return pulito.trim().isEmpty ? _regoleDiLingua(testo) : pulito;
  }

  /// Le frasi di una riga, tagliate dopo la punteggiatura forte.
  static List<String> _frasi(String riga) =>
      riga.split(RegExp(r'(?<=[.!?…])\s+'));

  static String _senzaFrasiFatte(String riga) {
    final t = riga.trimLeft();
    // La riga del consiglio e il segno della domanda non si toccano: sono
    // marcatori che l'app legge.
    if (t.startsWith('✦') || t.startsWith('[[')) return riga;
    final frasi = _frasi(riga);
    final tenute = [
      for (final f in frasi)
        if (VoceDelMaestro.aperturaVietataDi(f) == null) f,
    ];
    if (tenute.length == frasi.length) return riga;
    return tenute.join(' ');
  }

  static String _regoleDiLingua(String riga) =>
      riga.replaceAll(RegExp('\\s*\u2014\\s*'), ', ').replaceAllMapped(
          RegExp(r',\s+(e|ed)\s', caseSensitive: false), (m) => ' ${m[1]} ');
}

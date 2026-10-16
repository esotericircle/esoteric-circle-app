import '../chat/maestro_memory.dart';
import '../chat/user_profile.dart';
import 'natal_context.dart';

/// Un ancoraggio: un dato che esiste SOLO per questa persona.
///
/// E' cio' che rende una risposta sua invece che di chiunque. Una risposta che
/// non ne porta nessuno potrebbe essere stata scritta per chiunque altro, ed e'
/// il difetto che questo file esiste per misurare.
class Ancoraggio {
  const Ancoraggio({required this.nome, required this.valore});

  /// Come si chiama il dato, per esempio "segno solare". Serve al rapporto e
  /// all'istruzione piu' stringente, non alla ricerca.
  final String nome;

  /// Il valore vero, per esempio "Cancro". E' questo che va cercato nel testo.
  final String valore;

  @override
  String toString() => '$nome: $valore';
}

/// Quali ancoraggi esistono per questa persona, e se la risposta ne porta uno.
///
/// Pubblica e pura: la stessa regola serve al controllo a valle nella chat, alla
/// prova che la misura, e domani al Consulta. Due copie divergono sempre.
///
/// **La regola non scatta quando non c'e' niente da ancorare.** Senza data di
/// nascita non si pretende un segno e non si inventa: se [disponibiliPer] torna
/// vuoto, qualunque risposta e' valida. Meglio nessun ancoraggio che uno falso.
class VerificaAncoraggio {
  const VerificaAncoraggio._();

  /// Gli ancoraggi disponibili per questa persona, dal piu' personale al piu'
  /// generale. Un campo assente NON compare: non si riempie con un segnaposto.
  static List<Ancoraggio> disponibiliPer({
    required NatalContext natal,
    UserProfile? profile,
    MaestroMemory memory = MaestroMemory.empty,
  }) {
    final trovati = <Ancoraggio>[];

    void aggiungi(String nome, String? valore) {
      final v = valore?.trim();
      if (v == null || v.isEmpty) return;
      trovati.add(Ancoraggio(nome: nome, valore: v));
    }

    aggiungi('ascendente', natal.ascendant);
    aggiungi('segno lunare', natal.moonSign);
    aggiungi('segno solare', natal.sunSign);
    aggiungi('fase lunare di nascita', natal.moonPhase);
    if (natal.lifeNumber != null) {
      trovati.add(Ancoraggio(
        nome: 'numero della vita',
        valore: natal.lifeNumber.toString(),
      ));
      aggiungi('titolo del numero della vita', natal.lifeNumberTitle);
    }
    // I fatti della memoria sono ancoraggi a pieno titolo: "me ne avevi parlato
    // a giugno" e' personale quanto un ascendente, e a volte di piu'.
    for (final fatto in memory.facts) {
      aggiungi('fatto della memoria', fatto);
    }
    return trovati;
  }

  /// L'ancoraggio che [risposta] nomina, se ne nomina uno.
  ///
  /// Confronta il VALORE e non il nome del campo: la persona legge "Cancro",
  /// non "segno solare". Il confronto e' senza maiuscole, e per i fatti di
  /// memoria basta una parola lunga in comune, perche' un fatto e' una frase e
  /// il Maestro la riformula invece di ripeterla alla lettera.
  static Ancoraggio? ancoraggioIn(
    String risposta,
    List<Ancoraggio> disponibili,
  ) {
    final testo = risposta.toLowerCase();
    for (final ancoraggio in disponibili) {
      final valore = ancoraggio.valore.toLowerCase();
      if (valore.length <= 24) {
        if (testo.contains(valore)) return ancoraggio;
        continue;
      }
      // Un fatto lungo: basta una parola sostanziosa in comune.
      for (final parola in valore.split(RegExp(r'[^a-zàèéìòù]+'))) {
        if (parola.length >= 5 && testo.contains(parola)) return ancoraggio;
      }
    }
    return null;
  }

  /// Vero se la risposta e' accettabile.
  ///
  /// Senza ancoraggi disponibili e' SEMPRE vero: il controllo non pretende cio'
  /// che non esiste.
  static bool eAncorata(String risposta, List<Ancoraggio> disponibili) {
    if (disponibili.isEmpty) return true;
    return ancoraggioIn(risposta, disponibili) != null;
  }
}

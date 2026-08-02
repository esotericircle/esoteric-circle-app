import 'natal_context.dart';

/// Una battuta del consulto: cosa il Maestro sta guardando adesso.
class BattutaDelConsulto {
  const BattutaDelConsulto({
    required this.corpo,
    required this.frase,
    required this.eGenerale,
  });

  /// Il corpo o il punto guardato, per il segno visivo: `ascendente`, `luna`,
  /// `sole`. E' una chiave, non una frase: la scelta dell'immagine sta nella
  /// vista, il dato sta qui.
  final String corpo;

  /// Cosa si legge sotto, gia' in italiano. Per esempio "la tua Luna in Pesci".
  final String frase;

  /// Vero quando la battuta NON e' di questa persona ma del cielo di tutti.
  /// Serve alla vista per dirlo invece di lasciarlo credere.
  final bool eGenerale;

  @override
  String toString() => '$corpo: $frase';
}

/// Cosa il Maestro consulta mentre la risposta arriva.
///
/// **Funzione pura, e nessuna inferenza.** Le battute nascono dai dati gia' sul
/// dispositivo: costo zero, rete zero. Si provano senza montare uno schermo,
/// che e' la ragione per cui il testo vive qui e non dentro un widget.
///
/// **Un dato che manca fa SALTARE la sua battuta, e non la fa sostituire.** Due
/// battute vere valgono piu' di tre di cui una inventata: e' la stessa regola
/// dell'ancoraggio, vista dal lato dello schermo.
class ConsultoDelCielo {
  const ConsultoDelCielo._();

  /// Quante battute al massimo. Oltre tre l'attesa smette di essere un consulto
  /// e diventa un'attesa allungata a forza.
  static const int massimoBattute = 3;

  /// Le battute per questa persona, dalla piu' personale alla piu' generale.
  ///
  /// L'ordine non e' estetico: l'Ascendente dipende dall'ora e dal luogo esatti,
  /// la Luna dal giorno, il Sole dal mese. Chi guarda vede scendere il grado di
  /// intimita' del dato, e la prima cosa che legge e' la piu' sua.
  static List<BattutaDelConsulto> battutePer(NatalContext natal) {
    final battute = <BattutaDelConsulto>[];

    void aggiungi(String corpo, String? segno, String Function(String) frase) {
      if (battute.length >= massimoBattute) return;
      final s = segno?.trim();
      if (s == null || s.isEmpty) return;
      battute.add(BattutaDelConsulto(
        corpo: corpo,
        frase: frase(s),
        eGenerale: false,
      ));
    }

    aggiungi('ascendente', natal.ascendant, (s) => 'il tuo Ascendente in $s');
    aggiungi('luna', natal.moonSign, (s) => 'la tua Luna in $s');
    aggiungi('sole', natal.sunSign, (s) => 'il tuo Sole in $s');

    // La fase lunare di nascita entra solo se resta posto: e' un dato vero, ma
    // meno immediato dei tre segni.
    if (battute.length < massimoBattute) {
      final fase = natal.moonPhase?.trim();
      if (fase != null && fase.isNotEmpty) {
        battute.add(BattutaDelConsulto(
          corpo: 'fase',
          frase: 'la $fase sotto cui sei nato',
          eGenerale: false,
        ));
      }
    }

    // Senza carta natale si consulta il solo Sole, e LO SI DICE: la battuta
    // dichiara di essere generale, cosi' nessuno la scambia per sua.
    if (battute.isEmpty) {
      return const [
        BattutaDelConsulto(
          corpo: 'sole',
          frase: 'il Sole di oggi, che è di tutti',
          eGenerale: true,
        ),
      ];
    }
    return battute;
  }

  /// Vero se il consulto e' solo generale, cioe' non c'e' nulla di questa
  /// persona da guardare. La vista lo usa per dirlo con garbo.
  static bool eSoloGenerale(NatalContext natal) =>
      battutePer(natal).every((b) => b.eGenerale);
}

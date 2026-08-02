import 'ancoraggio.dart';
import 'lente_del_cielo.dart';
import 'maestro.dart';
import 'natal_context.dart';

/// Una battuta del consulto: cosa il Maestro sta guardando adesso.
class BattutaDelConsulto {
  const BattutaDelConsulto({
    required this.corpo,
    required this.frase,
    required this.eGenerale,
    this.ancoraggio,
  });

  /// Il dato da cui nasce, quando ce n'e' uno. La vista lo usa per scegliere
  /// COSA disegnare, e la lente per scegliere COME dirlo: cosi' l'immagine e
  /// la frase vengono dallo stesso dato invece che da due strade diverse.
  final Ancoraggio? ancoraggio;

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
  static List<BattutaDelConsulto> battutePer(
    NatalContext natal, {
    Maestro? maestro,
  }) {
    // Le battute nascono dagli ANCORAGGI, cioe' dallo stesso elenco che il
    // Maestro riceve nella persona. Prima erano un secondo elenco scritto qui,
    // e due elenchi della stessa cosa prima o poi divergono.
    final ancoraggi = VerificaAncoraggio.disponibiliPer(natal: natal);
    final battute = <BattutaDelConsulto>[];
    for (final ancoraggio in ancoraggi) {
      if (battute.length >= massimoBattute) break;
      // Solo i dati che hanno un corpo da guardare: un fatto di memoria e' un
      // ottimo ancoraggio per la risposta, ma non e' qualcosa che si consulta
      // nel cielo.
      if (!_siGuardaNelCielo(ancoraggio.nome)) continue;
      battute.add(BattutaDelConsulto(
        corpo: _corpoDi(ancoraggio.nome),
        frase: maestro == null
            ? _fraseNeutra(ancoraggio)
            : LenteDelCielo.battuta(maestro, ancoraggio),
        eGenerale: false,
        ancoraggio: ancoraggio,
      ));
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

  /// Quali ancoraggi si guardano nel cielo. Un fatto di memoria no: e' un
  /// ancoraggio vero per la risposta, ma non e' un corpo da consultare.
  static bool _siGuardaNelCielo(String nome) => const {
        'ascendente',
        'segno lunare',
        'segno solare',
        'fase lunare di nascita',
      }.contains(nome);

  /// La chiave del corpo, per la vista.
  static String _corpoDi(String nome) => switch (nome) {
        'ascendente' => 'ascendente',
        'segno lunare' => 'luna',
        'segno solare' => 'sole',
        'fase lunare di nascita' => 'fase',
        _ => 'punto',
      };

  /// La frase senza lente, quando il Maestro non e' noto.
  static String _fraseNeutra(Ancoraggio ancoraggio) => switch (ancoraggio.nome) {
        'ascendente' => 'il tuo Ascendente in ${ancoraggio.valore}',
        'segno lunare' => 'la tua Luna in ${ancoraggio.valore}',
        'segno solare' => 'il tuo Sole in ${ancoraggio.valore}',
        'fase lunare di nascita' =>
          'la ${ancoraggio.valore} sotto cui sei nato',
        _ => ancoraggio.valore,
      };

  /// Vero se il consulto e' solo generale, cioe' non c'e' nulla di questa
  /// persona da guardare. La vista lo usa per dirlo con garbo.
  static bool eSoloGenerale(NatalContext natal) =>
      battutePer(natal).every((b) => b.eGenerale);
}

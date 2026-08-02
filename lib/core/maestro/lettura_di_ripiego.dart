import '../chat/maestro_memory.dart';
import '../chat/user_profile.dart';
import 'ancoraggio.dart';
import 'frase_di_ripiego.dart';
import 'maestro.dart';
import 'natal_context.dart';

/// Quando la voce tace, il Maestro consegna comunque una LETTURA VERA.
///
/// Prima diceva soltanto che non poteva leggere, e la conversazione si fermava
/// li': un vicolo cieco, che la casa non ammette. Adesso dice che non e' la sua
/// voce **e poi legge lo stesso**, con i dati che l'app ha gia' sul
/// dispositivo. Costo di inferenza zero, rete zero.
///
/// **Non e' un finto responso AI.** E' un responso onesto di altro tipo, e lo
/// dichiara due volte: nella frase di ripiego che apre, e nell'etichetta
/// [RipiegoDelMaestro.etichetta] che la bolla mostra sotto.
///
/// Funzione pura, quindi si prova senza montare uno schermo e senza rete.
class LetturaDiRipiego {
  const LetturaDiRipiego._();

  /// La lettura completa: il ripiego dichiarato, poi cio' che si puo' leggere
  /// davvero, poi una via che porta da qualche parte.
  static String componi({
    required Maestro maestro,
    required String domanda,
    required NatalContext natal,
    UserProfile? profile,
    MaestroMemory memory = MaestroMemory.empty,
  }) {
    final ancoraggi = VerificaAncoraggio.disponibiliPer(
      natal: natal,
      profile: profile,
      memory: memory,
    );
    final buffer = StringBuffer(RipiegoDelMaestro.silenzioDi(maestro));

    // Cio' che si puo' leggere lo stesso. Se non c'e' niente NON si inventa: si
    // salta, e resta la via d'uscita. Meglio una riga in meno che una falsa.
    final lettura = _letturaDaiDati(maestro, ancoraggi);
    if (lettura != null) {
      buffer
        ..writeln()
        ..writeln()
        ..write(lettura);
    }

    buffer
      ..writeln()
      ..writeln()
      ..write(_viaDiUscita(maestro));
    return buffer.toString();
  }

  /// La lettura vera, costruita sul primo ancoraggio disponibile, nella lente
  /// del Maestro. Nulla se non c'e' nessun dato: un dato assente si tace.
  static String? _letturaDaiDati(
    Maestro maestro,
    List<Ancoraggio> ancoraggi,
  ) {
    if (ancoraggi.isEmpty) return null;
    final primo = ancoraggi.first;
    switch (maestro) {
      case Maestro.medora:
        return 'Quello che posso dirti senza leggere il cielo di adesso è '
            'quello che il cielo di allora ha già scritto: '
            '${primo.nome} ${primo.valore}. Da lì si riparte sempre.';
      case Maestro.aura:
        return 'Quello che resta leggibile anche adesso è '
            '${primo.nome} ${primo.valore}, col respiro che lo accompagna. '
            'Il corpo non ha bisogno che io parli per sapere dove sei.';
      case Maestro.caligo:
        return 'Un segno resta leggibile anche nella nebbia: '
            '${primo.nome} ${primo.valore}. Tienilo, finché non torno a '
            'vedere il resto.';
    }
  }

  /// La via che porta da qualche parte, nella lente del Maestro.
  ///
  /// Non e' un invito generico a riprovare: e' un'arte che esiste, funziona
  /// offline e appartiene a questo Maestro. Chi resta senza voce non resta
  /// senza porta.
  static String _viaDiUscita(Maestro maestro) {
    switch (maestro) {
      case Maestro.medora:
        return 'Intanto la tua carta natale è già calcolata e non ha bisogno '
            'di me: aprila, poi guarda le case dove i pianeti si affollano.';
      case Maestro.aura:
        return 'Intanto fai un respiro contato: quattro dentro, sei fuori, '
            'tre volte. Quello lo puoi fare senza di me. Funziona uguale.';
      case Maestro.caligo:
        return 'Intanto tira una runa: il presagio è nel segno, non nella mia '
            'voce. Il segno lo puoi tirare adesso.';
    }
  }
}

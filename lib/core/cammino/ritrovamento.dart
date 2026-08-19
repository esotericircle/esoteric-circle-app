import '../astro/zodiac.dart';
import 'cammino_da_custodire.dart';

/// I PASSI DEL RITO CHE CHIEDONO UN DATO DI NASCITA.
///
/// Sono quelli che il ritrovamento puo' saltare, perche' il Cerchio ha gia'
/// la risposta. Gli altri passi del Risveglio, l'accoglienza, il vocativo e
/// il Sigillo, non chiedono un dato: chiedono un momento, e quello si vive
/// una volta sola.
enum PassoDelRito { data, ora, luogo, nome }

/// COSA IL CERCHIO HA RITROVATO, E COSA RESTA DA CHIEDERE. Ordine AP voce 05.
///
/// **La domanda di Mauro**: rifare l'onboarding quando si e' gia' registrati
/// non ha senso. Chi rientra col suo account ha gia' dato la sua nascita al
/// Cerchio, e richiedergliela e' come se il Cerchio non lo conoscesse.
///
/// **La regola vive in UN punto solo, e non e' un vezzo.** La stessa domanda
/// arriva da due strade diverse, la porta piccola della voce 04 e il
/// "Continua come" della voce 06: se ognuna decidesse per conto suo, un
/// giorno una delle due chiederebbe di nuovo la nascita a chi l'aveva gia'
/// data. E' la regola delle due porte applicata a una decisione invece che a
/// un dato.
///
/// **Se l'identita' e' PARZIALE si salta solo la parte gia' fatta**, e si
/// dichiara: chi ha dato il giorno ma non l'ora si vede chiedere l'ora, non
/// tutto da capo. L'ora e' la distinzione che decide se l'Ascendente esiste,
/// quindi saltarla per comodita' vorrebbe dire chiudere una porta per sempre.
class Ritrovamento {
  const Ritrovamento._({
    required this.passiDaChiedere,
    required this.cartaRitrovata,
    required this.quantiTraguardi,
    required this.quantiEos,
    required this.nome,
    required this.segno,
  });

  /// Tutti i passi che chiedono un dato: e' cio' che si fa alla prima volta.
  static const List<PassoDelRito> tuttiIPassi = PassoDelRito.values;

  /// Cosa resta da chiedere, in ordine di rito.
  final List<PassoDelRito> passiDaChiedere;

  /// Vero se il Cerchio aveva abbastanza per rifare la carta natale.
  final bool cartaRitrovata;

  /// Quanti Sigilli sono tornati accesi.
  final int quantiTraguardi;

  /// Quanti Eos aveva il borsellino al ritorno.
  final int quantiEos;

  /// Il nome ritrovato, per salutare chi torna con quello che e' suo.
  final String? nome;

  /// **IL SEGNO, ordine AQ voce 04.** Non e' un dato in piu' custodito: nasce
  /// dal giorno di nascita che il Cerchio ha restituito, come nasce ovunque
  /// nell'app. Nullo quando il giorno non e' tornato, e allora l'emblema non
  /// compare: meglio niente che il segno di qualcun altro.
  final Zodiac? segno;

  /// Vero se non c'e' piu' niente da chiedere: il rito non si rifa'.
  bool get siSalta => passiDaChiedere.isEmpty;

  /// Vero se c'e' qualcosa che valga la pena mostrare.
  ///
  /// Chi entra con un account nuovo non deve vedere una scena che celebra il
  /// ritrovamento di zero cose: sarebbe una promessa mantenuta a vuoto.
  bool get qualcosaDaMostrare =>
      cartaRitrovata || quantiTraguardi > 0 || quantiEos > 0;

  /// Legge cosa il Cerchio ha restituito e decide.
  static Ritrovamento da(CamminoDaCustodire? cammino, {int saldoEos = 0}) {
    final identita = cammino?.identita;
    final manca = <PassoDelRito>[
      if (identita?.giorno == null) PassoDelRito.data,
      if (identita?.ora == null) PassoDelRito.ora,
      if (identita?.luogo == null) PassoDelRito.luogo,
      if (identita?.nome == null) PassoDelRito.nome,
    ];
    return Ritrovamento._(
      passiDaChiedere: manca,
      // **LA CARTA SI DICE RITROVATA SOLO COL GIORNO**, che e' il minimo per
      // calcolarla: annunciarla senza sarebbe promettere un cielo che non si
      // puo' tracciare.
      cartaRitrovata: identita?.giorno != null,
      quantiTraguardi: cammino?.sigilli.length ?? 0,
      quantiEos: saldoEos,
      nome: identita?.nome,
      segno: identita?.giorno == null ? null : Zodiac.fromDate(identita!.giorno!),
    );
  }
}

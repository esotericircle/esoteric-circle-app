import '../../services/server/porta_del_cerchio.dart';
import 'listino_degli_eos.dart';
import 'question_allowance.dart';

/// Come e' andata una spesa, detto in modo che chi chiama sappia cosa dire.
enum EsitoDellaSpesa {
  /// Il server ha scalato gli Eos: si puo' procedere.
  fatta,

  /// Non ce ne sono abbastanza: si mostra lo stato esaurito e la ricarica.
  saldoInsufficiente,

  /// Il server non ha risposto: non si e' speso niente e non si procede.
  nonRiuscita,
}

/// LA PORTA UNICA DELLA SPESA IN EOS. Ordine AN voce 05.
///
/// **Il saldo lo scala il SERVER, sempre.** Un conteggio locale sarebbe un
/// secondo saldo, e al primo movimento perso i due direbbero numeri diversi
/// nella stessa schermata: e' la stessa ragione per cui il registro dei
/// movimenti non somma niente. Qui si chiede, si aspetta la risposta e si
/// applica il numero che il server dice.
///
/// **Il costo non lo decide chi chiama**: arriva dal listino, che e' l'unica
/// porta dei prezzi. Chi chiama passa la voce, non una cifra.
class SpesaDegliEos {
  const SpesaDegliEos._();

  /// Spende il costo di una voce del listino.
  ///
  /// Torna [EsitoDellaSpesa.fatta] solo quando il server ha davvero scalato
  /// gli Eos: chi chiama non procede su nessun altro esito, perche' dare
  /// l'esperienza senza aver incassato e' un regalo che nessuno ha deciso.
  static Future<EsitoDellaSpesa> perLaVoce({
    required PortaDelCerchio porta,
    required QuestionAllowance borsa,
    required VoceDelListino voce,
    required String idMovimento,
  }) async {
    if (borsa.saldoEos < voce.costo) return EsitoDellaSpesa.saldoInsufficiente;
    try {
      final saldo = await porta.muoviGliEos(
        causale: 'spesa',
        motivo: voce.id,
        idMovimento: idMovimento,
        quanti: voce.costo,
      );
      if (saldo == null) return EsitoDellaSpesa.nonRiuscita;
      await borsa.applicaSaldo(saldo);
      return EsitoDellaSpesa.fatta;
    } catch (errore) {
      // Il rifiuto del server e la rete assente si somigliano da qui: in
      // tutti e due i casi non si e' speso niente e non si procede.
      return EsitoDellaSpesa.nonRiuscita;
    }
  }

  /// UN IDENTIFICATIVO PER OGNI SPESA, e serve davvero: se la risposta si
  /// perde e il client ritenta, senza questo la persona pagherebbe due
  /// volte. Il server ricorda cio' che ha gia' visto.
  static String nuovoMovimento(String idVoce) =>
      PortaDelCerchio.nuovoIdentificativo('spesa-$idVoce');
}

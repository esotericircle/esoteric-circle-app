import '../../services/server/porta_del_cerchio.dart';
import 'sentieri.dart';

/// COME SI CONDIVIDE UN TRAGUARDO, e quanto vale.
///
/// **Una logica sola, e questa e' quella.** L'ordine O chiede che la
/// celebrazione a schermo pieno e quella in sovrimpressione portino allo
/// stesso bonus, senza scriverne un secondo. Qui c'e' l'unico punto del
/// client che sa quali sono i modi di condividere; quanto valgono lo decide
/// il server, in `functions/src/borsellino.ts`, perche' gli Eos sono denaro e
/// il telefono non li scrive.
enum ModoDellaCondivisione {
  /// L'invito che porta un download: il massimo.
  invitoConDownload('invito_con_download', 'Invita qualcuno nel Cerchio'),

  /// Il social pubblico: alto.
  socialPubblico('social_pubblico', 'Condividi pubblicamente'),

  /// La condivisione privata verificabile: medio.
  condivisionePrivata('condivisione_privata', 'Manda a qualcuno');

  const ModoDellaCondivisione(this.motivo, this.etichetta);

  /// Il motivo che il server riconosce nel listino.
  final String motivo;

  /// Come si legge sul pulsante.
  final String etichetta;
}

/// IL PREMIO DI UN TRAGUARDO, chiesto al server per nome e non per importo.
///
/// Il client dice "ho acceso questo Sigillo" e il server sa quanto vale dalla
/// posizione: chiedere un importo sarebbe chiedere al borsellino di aprirsi
/// da solo.
class PremioDelTraguardo {
  const PremioDelTraguardo._();

  static String motivoDi(Traguardo traguardo) {
    if (traguardo.eGrande) return 'traguardo_grande_${traguardo.posizione}';
    return traguardo.posizione <= 3
        ? 'traguardo_mini_primi_tre'
        : 'traguardo_mini';
  }

  /// Accredita il premio del traguardo. Torna il saldo nuovo, oppure nullo se
  /// il server non risponde: in quel caso il Sigillo resta acceso lo stesso e
  /// il premio si riprende alla prossima sincronia, perche' il movimento
  /// porta il suo identificativo e non si conta due volte.
  static Future<int?> accredita(
    PortaDelCerchio porta,
    Traguardo traguardo,
  ) =>
      porta.muoviGliEos(
        causale: 'premio_sigillo',
        motivo: motivoDi(traguardo),
        idMovimento: 'traguardo-${traguardo.id}',
      );

  /// Accredita il BONUS della condivisione, una volta sola per traguardo e
  /// dentro il tetto giornaliero che il server sorveglia.
  static Future<int?> bonus(
    PortaDelCerchio porta,
    Traguardo traguardo,
    ModoDellaCondivisione modo,
  ) =>
      porta.muoviGliEos(
        causale: 'bonus_condivisione',
        motivo: modo.motivo,
        idMovimento: 'bonus-${traguardo.id}-${modo.motivo}',
      );
}

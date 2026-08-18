import '../brand/brand.dart';
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
  invitoConDownload(
    'invito_con_download',
    'Invita qualcuno nel Cerchio',
    quandoArriva: 'I suoi Eos arrivano quando il tuo amico scarica il '
        'Cerchio.',
    subitoPagato: false,
  ),

  /// Il social pubblico: alto.
  socialPubblico(
    'social_pubblico',
    'Condividi pubblicamente',
    quandoArriva: 'I suoi Eos arrivano a condivisione avvenuta.',
    subitoPagato: true,
  ),

  /// La condivisione privata verificabile: medio.
  condivisionePrivata(
    'condivisione_privata',
    'Manda a qualcuno',
    quandoArriva: 'I suoi Eos arrivano a condivisione avvenuta.',
    subitoPagato: true,
  );

  const ModoDellaCondivisione(
    this.motivo,
    this.etichetta, {
    required this.quandoArriva,
    required this.subitoPagato,
  });

  /// Il motivo che il server riconosce nel listino.
  final String motivo;

  /// Come si legge sul pulsante.
  final String etichetta;

  /// **QUANDO IL PREMIO ARRIVA, detto PRIMA del tocco.** Ordine AN voce 08:
  /// la persona deve sapere cosa fa arrivare gli Eos, e la frase non puo'
  /// promettere piu' di quanto il codice sappia.
  final String quandoArriva;

  /// **SE IL BONUS SI ACCREDITA SUBITO, a condivisione avvenuta.**
  ///
  /// Per l'INVITO e' falso, e qui si dice la verita' invece di fingere:
  /// sapere che l'amico ha scaricato richiede un'attribuzione
  /// dell'installazione che nel progetto NON esiste (verificato: nessun
  /// Dynamic Link, nessun Install Referrer). Pagare l'invito all'apertura
  /// del foglio, mostrando "quando il tuo amico scarica", sarebbe una bugia
  /// a schermo. Quindi l'invito resta DICHIARATO IN ATTESA e si accreditera'
  /// quando l'attribuzione esistera', in un ordine suo che comincera'
  /// scegliendo la strada con l'Architetto.
  final bool subitoPagato;
}

/// COSA SI MANDA DAVVERO, per ciascuno dei tre modi. Ordine S voce 08.
///
/// **I tre pulsanti non facevano niente, ed era la violazione piu' cara.** Un
/// controllo o e' collegato a qualcosa o e' dichiarato inattivo: non esiste la
/// terza possibilita'. Toccandoli si segnava il traguardo come condiviso e si
/// chiedeva il bonus al server, ma **nessun foglio di sistema si apriva**: non
/// era stato condiviso niente con nessuno, e il bonus della condivisione era un
/// premio per un gesto mai avvenuto.
///
/// **I tre testi sono tre perche' i tre gesti sono tre.** L'invito parla a chi
/// non e' ancora nel Cerchio e porta il link, perche' senza link non c'e' nessun
/// download da attribuire; il pubblico si legge davanti a estranei e non da' del
/// tu a nessuno; il privato e' un messaggio a una persona sola.
class TestoDellaCondivisione {
  const TestoDellaCondivisione._();

  static String perIlTraguardo(Traguardo traguardo, ModoDellaCondivisione modo) {
    switch (modo) {
      case ModoDellaCondivisione.invitoConDownload:
        return 'Sto camminando nel Cerchio e ho appena acceso un Sigillo: '
            '"${traguardo.nome}". Vieni a vedere il tuo cielo. ${Brand.url}';
      case ModoDellaCondivisione.socialPubblico:
        return 'Un Sigillo acceso nel Cerchio: "${traguardo.nome}". '
            '${traguardo.frase} ${Brand.name}.';
      case ModoDellaCondivisione.condivisionePrivata:
        return 'Guarda cosa ho acceso nel Cerchio: "${traguardo.nome}". '
            '${traguardo.frase}';
    }
  }
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

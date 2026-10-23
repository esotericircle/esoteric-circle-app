import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'dart:async';

import '../../design_system/theme/maestro_scope.dart';
import '../../features/sigilli/regia_del_cammino.dart';
import 'porta_della_condivisione.dart';
import '../entitlement/question_allowance.dart';
import '../sigilli/bonus_della_condivisione.dart';
import '../entitlement/registro_degli_eos.dart';
import '../../services/app_services.dart';
import '../../services/server/porta_del_cerchio.dart';

/// **OGNI CONDIVISIONE PREMIA, E LO DICE PRIMA.** Ordine BG voce 04.
///
/// Parole del fondatore: "quando ho la risposta da una funzionalita' e
/// propone la condivisione, non dovrebbe indicarmi il numero di Eos che
/// guadagno? Controlla che sia cosi' come REGOLA per tutte le funzionalita'".
/// La regola esisteva sulle card dei traguardi (ordine BB voce 04): questa
/// e' la sua casa per tutte le altre condivisioni dell'app.
///
/// **Due meta', una promessa.** [etichetta] scrive sul pulsante quanto vale
/// la condivisione, col numero del SERVER e mai inventato, e tace quando il
/// tetto del giorno e' raggiunto o il server non ha ancora parlato (un
/// pulsante che promette un bonus che non arriverebbe e' una bugia scritta
/// bene). [premia] paga DOPO che la condivisione e' avvenuta davvero, con un
/// movimento idempotente: il tetto vero lo tiene il server nella sua
/// transazione, qui si applica il saldo che risponde e si scrive il registro.
class PremioDellaCondivisione {
  const PremioDellaCondivisione._();

  /// Il motivo del server per le condivisioni delle arti e dei responsi.
  static const String motivo = 'condivisione_arte';

  /// L'etichetta del pulsante: "Condividi · +15 Eos" quando il premio
  /// arriverebbe davvero, [base] e basta negli altri casi.
  static String etichetta(BuildContext context, {String base = 'Condividi'}) {
    final QuestionAllowance borsa;
    try {
      borsa = context.read<QuestionAllowance>();
    } catch (errore) {
      return base;
    }
    final quanti = borsa.eosPerLaCondivisione(motivo);
    if (quanti == null || !borsa.condivisioneAncoraPremiata) return base;
    return '$base · +$quanti Eos';
  }

  /// Paga il premio di una condivisione AVVENUTA. Da chiamare quando la
  /// porta della condivisione ha detto si', mai quando lo si spera.
  ///
  /// [cosa] e' la frase del registro, in parole della persona: "Hai
  /// condiviso l'oroscopo". Il silenzio sugli esiti e' voluto: chi ha
  /// appena condiviso sta finendo un rito, e il premio che non arriva (rete
  /// assente, tetto raggiunto) non deve rompere il momento; il saldo giusto
  /// torna con la prossima sincronia.
  /// **IL RESPONSO MANDATO IN PRIVATO ENTRA NEL CAMMINO. Ordine BX voce 10.**
  ///
  /// Il corpus porta tre voci, una per Maestro, che chiedono "mandi un
  /// responso a qualcuno in privato, non al mondo". Dormivano perche' la regia
  /// sapeva che si era condiviso, non DOVE. Adesso la porta della
  /// condivisione ricorda quale applicazione ha ricevuto e da li' si legge il
  /// canale; **quando non lo riconosce non si registra niente**, invece di
  /// contare per privato una condivisione che forse era una piazza.
  ///
  /// Il Maestro e' quello della scena: i responsi vivono dentro lo scope del
  /// proprio Maestro, e il gesto porta il suo nome cosi' le tre voci non
  /// misurano lo stesso identico fatto.
  static void _segnaIlCanale(BuildContext context) {
    final canale = PortaDellaCondivisione.canaleDellUltima;
    if (canale == null) return;
    String? maestro;
    try {
      maestro = MaestroScope.of(context).key.maestro?.name;
    } catch (senzaScope) {
      maestro = null;
    }
    unawaited(RegiaDelCammino.dopoUnGesto(
      context,
      'condivisione',
      dettagli: {
        'canale': [canale],
        // **UNA CHIAVE PER MAESTRO, e non una coppia.** Le tre voci del corpus
        // sono tre fatti distinti, uno per Maestro: con una chiave sola che
        // porta il nome del Maestro come valore, una condivisione privata di
        // Aura avrebbe acceso anche il gradino di Caligo, perche' la varieta'
        // conta quanti valori diversi si sono visti, non quale.
        if (maestro != null && canale == 'privato') 'privato_$maestro': ['si'],
      },
    ));
  }

  static Future<void> premia(BuildContext context,
      {required String cosa}) async {
    // Il canale si segna PRIMA di parlare col server: e' un fatto del
    // cammino, e non deve dipendere da una rete che puo' non rispondere.
    _segnaIlCanale(context);
    final QuestionAllowance borsa;
    try {
      borsa = context.read<QuestionAllowance>();
    } catch (errore) {
      return;
    }
    PortaDelCerchio porta;
    try {
      porta = context.read<AppServices>().porta;
    } catch (errore) {
      return;
    }
    RegistroDegliEos? registro;
    try {
      registro = context.read<RegistroDegliEos>();
    } catch (errore) {
      registro = null;
    }
    if (!porta.viva) return;
    final prima = borsa.saldoEos;
    final saldo = await porta.muoviGliEos(
      causale: causaleDelBonusDellaCondivisione,
      motivo: motivo,
      idMovimento: PortaDelCerchio.nuovoIdentificativo(motivo),
    );
    if (saldo == null) return;
    final arrivati = saldo - prima;
    if (arrivati > 0) {
      borsa.condivisionePremiata();
      await registro?.segna(quanti: arrivati, perche: cosa);
    }
    await borsa.applicaSaldo(saldo);
  }
}

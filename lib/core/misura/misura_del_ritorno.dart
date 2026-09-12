import 'package:shared_preferences/shared_preferences.dart';

/// LA MISURA DEL RITORNO. Ordine CC voce 09.
///
/// **Cosa chiede la voce:** "non si sa quante persone tornano il giorno dopo,
/// quante dopo una settimana, quale notifica le riporta dentro, quanti
/// arrivano in fondo a un rito e quanti lo abbandonano. Che quelle grandezze
/// si possano leggere."
///
/// **LE CINQUE SCELTE CHE HO PRESO, e ognuna col suo perche'.**
///
/// **1. Nessuno strumento nuovo, nessun pacchetto nuovo.** Firebase Analytics
/// avrebbe portato una dipendenza, un secondo identificativo pubblicitario e
/// un secondo posto dove vivono i dati di una persona, proprio mentre l'ordine
/// CB voce 05 ha appena messo una scadenza a ognuno. Il Cerchio ha gia' una
/// porta verso il server, `PortaDelCerchio`, e sa gia' scrivere sotto
/// `users/{uid}`: la misura passa da li'.
///
/// **2. Si contano i GESTI, non le persone.** Non esiste nessun profilo di
/// comportamento: esiste un contatore per tipo di evento e per giorno. Da
/// quello si legge quante persone tornano, e non si legge chi.
///
/// **3. Il consenso si chiede, e chi dice no usa l'app intera.** E' scritto
/// nella voce, ed e' anche l'unica forma onesta: una misura che serve a noi
/// non puo' costare niente a chi la concede e non deve togliere niente a chi
/// la nega. Senza consenso questa classe non manda niente, e nemmeno accoda.
///
/// **4. Gli eventi sono POCHI e dichiarati uno per uno.** Un elenco chiuso e'
/// l'unico modo perche' la privacy policy possa dire il vero: se domani
/// qualcuno ne aggiunge uno, la prova cade finche' non lo dichiara qui.
///
/// **5. Nessun testo scritto dalla persona esce mai.** Gli eventi portano un
/// nome e, al massimo, una parola di contesto scelta da un elenco chiuso.
enum EventoDelRitorno {
  /// L'app si e' aperta. E' l'evento da cui nascono il ritorno del giorno dopo
  /// e quello della settimana: non serve altro per misurarli.
  apertura('apertura'),

  /// La persona e' entrata dopo aver toccato una notifica. Risponde a "quale
  /// notifica le riporta dentro".
  ritornoDaAvviso('ritorno_da_avviso'),

  /// Un rito e' cominciato. Insieme a [ritoCompiuto] risponde a "quanti
  /// arrivano in fondo e quanti lo abbandonano".
  ritoCominciato('rito_cominciato'),

  /// Un rito e' arrivato in fondo.
  ritoCompiuto('rito_compiuto'),

  /// Un responso e' stato condiviso. E' la sola porta di crescita che l'app
  /// ha, e non sapere quanto si usa vuol dire non saperne niente.
  responsoCondiviso('responso_condiviso');

  const EventoDelRitorno(this.nome);

  /// Il nome che viaggia verso il server. Corto e stabile: un nome che cambia
  /// spezza in due la serie storica.
  final String nome;
}

/// IL CONSENSO ALLA MISURA, e la memoria di cosa e' stato chiesto.
///
/// **Tre stati, non due.** Non chiesto, concesso, negato. Senza il terzo, chi
/// ha detto no e chi non ha ancora risposto sarebbero la stessa cosa, e l'app
/// glielo richiederebbe a ogni avvio.
enum ConsensoAllaMisura { nonChiesto, concesso, negato }

/// LA MEMORIA DEL CONSENSO, sotto un prefisso che la cancellazione porta via.
abstract final class ConsensoDellaMisura {
  /// **La chiave sta sotto `permesso.`**, che e' gia' nell'elenco di
  /// `CioCheETuo`: chi cancella tutto se ne va anche da qui, e al rientro la
  /// domanda torna, che e' giusto perche' per l'app e' una persona nuova.
  static const String chiave = 'permesso.misuraDelRitorno';

  static Future<ConsensoAllaMisura> letto() async {
    try {
      final p = await SharedPreferences.getInstance();
      final v = p.getBool(chiave);
      if (v == null) return ConsensoAllaMisura.nonChiesto;
      return v ? ConsensoAllaMisura.concesso : ConsensoAllaMisura.negato;
    } catch (errore) {
      // Senza disco non si presume nessun consenso: e' l'unico verso in cui
      // sbagliare non costa niente a nessuno.
      return ConsensoAllaMisura.nonChiesto;
    }
  }

  static Future<void> segna(bool concesso) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(chiave, concesso);
    } catch (errore) {
      // Best effort: senza disco la domanda tornera', e non e' un guasto.
    }
  }
}

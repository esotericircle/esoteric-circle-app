import 'package:shared_preferences/shared_preferences.dart';

import 'app_permission.dart';

/// I TRE ESITI DI UNA RICHIESTA DI PERMESSO, distinti fino a schermo.
///
/// **Perche' non basta un si' o un no.** Con l'ordine 2161 il permesso di
/// posizione del Tramonto ha imparato a distinguere il no di oggi dal no per
/// sempre: prima li appiattiva, e a chi aveva negato per sempre il dialogo di
/// sistema non compariva piu' e la schermata non lo diceva, quindi il
/// pulsante sembrava rotto. Appiattire due esiti in uno e' la stessa forma
/// della regola messa in una porta sola: un'informazione che esisteva e viene
/// buttata a monte.
///
/// Quella regola vale per TUTTI i permessi, non solo per la posizione, ed e'
/// questo enum a tenerla.
enum EsitoDelPermesso {
  /// La funzione parte.
  concesso,

  /// Negato adesso: la schermata lo dice, resta usabile col ripiego, e si
  /// puo' richiedere.
  negato,

  /// Negato per sempre: il sistema non mostrera' piu' la richiesta, quindi
  /// l'unica via e' aprire le impostazioni.
  negatoPerSempre,

  /// Il dispositivo non ha quel sensore, o la piattaforma non lo espone.
  nonDisponibile,
}

/// LA PORTA UNICA DELLE RICHIESTE DI PERMESSO.
///
/// **Come si distingue il no di oggi dal no per sempre, e perche' e' un
/// ragionamento e non una lettura.** Il sistema, per microfono, fotocamera,
/// galleria e notifiche, risponde solo si' o no: non esiste una domanda che
/// dica "mostrerai ancora il dialogo?". La distinzione si ricava dal fatto
/// che il dialogo di sistema compare UNA volta sola: se la richiesta era gia'
/// stata fatta in passato e torna ancora negata, vuol dire che il dialogo non
/// e' comparso affatto, cioe' che la persona ha gia' scelto per sempre.
///
/// E' un'inferenza, non un dato del sistema, e sta scritto qui perche' nessuno
/// la scambi per una lettura. La posizione NON passa da qui: Geolocator il
/// dato ce l'ha davvero (`deniedForever`), e leggere batte sempre dedurre.
class PortaDelPermesso {
  const PortaDelPermesso._();

  static String _chiave(AppPermission p) => 'permesso.${p.name}.gia_chiesto';

  /// Chiede il permesso e torna l'esito nei suoi tre valori.
  ///
  /// [richiestaDiSistema] e' la vera richiesta del plugin, che torna solo
  /// si' o no: e' l'unica cosa che il sistema sa dire.
  static Future<EsitoDelPermesso> chiedi(
    AppPermission permesso, {
    required Future<bool> Function() richiestaDiSistema,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final giaChiesto = prefs.getBool(_chiave(permesso)) ?? false;
    bool concesso;
    try {
      concesso = await richiestaDiSistema();
    } catch (_) {
      // Un plugin che solleva vuol dire piattaforma senza quel sensore: e'
      // un caso diverso da un no, e la schermata lo dice diversamente.
      return EsitoDelPermesso.nonDisponibile;
    }
    await prefs.setBool(_chiave(permesso), true);
    if (concesso) return EsitoDelPermesso.concesso;
    return giaChiesto
        ? EsitoDelPermesso.negatoPerSempre
        : EsitoDelPermesso.negato;
  }

  /// Dimentica di aver chiesto: serve alle prove e a chi ripulisce i dati.
  static Future<void> dimentica(AppPermission permesso) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chiave(permesso));
  }
}

/// Cosa dire alla persona per ciascun esito, in un punto solo.
///
/// Le frasi vivono qui e non nelle schermate: due schermate che scrivono a
/// mano lo stesso avviso diventano due frasi diverse il giorno che una viene
/// corretta.
class ParoleDelPermesso {
  const ParoleDelPermesso._();

  /// Il titolo dell'avviso quando il permesso non c'e'.
  static String titolo(AppPermission p, EsitoDelPermesso esito) {
    switch (esito) {
      case EsitoDelPermesso.negatoPerSempre:
        return 'Il permesso resta chiuso';
      case EsitoDelPermesso.nonDisponibile:
        return 'Questo dispositivo non ce l\'ha';
      case EsitoDelPermesso.negato:
        return 'Per ora si fa col tocco';
      case EsitoDelPermesso.concesso:
        return '';
    }
  }

  /// La spiegazione, che dice sempre cosa resta possibile.
  static String corpo(AppPermission p, EsitoDelPermesso esito,
      {required String ripiego}) {
    switch (esito) {
      case EsitoDelPermesso.negatoPerSempre:
        return 'Il sistema non mostrera\' piu\' la richiesta: si riapre solo '
            'dalle impostazioni del telefono. $ripiego';
      case EsitoDelPermesso.nonDisponibile:
        return 'Qui manca il sensore che servirebbe. $ripiego';
      case EsitoDelPermesso.negato:
        return '$ripiego Puoi cambiare idea quando vuoi.';
      case EsitoDelPermesso.concesso:
        return '';
    }
  }

  /// Cosa scrivere sul pulsante: chiedere ancora, oppure aprire le
  /// impostazioni quando chiedere non serve piu' a niente.
  static String? azione(EsitoDelPermesso esito) {
    switch (esito) {
      case EsitoDelPermesso.negatoPerSempre:
        return 'Apri le impostazioni';
      case EsitoDelPermesso.negato:
        return 'Chiedi di nuovo';
      case EsitoDelPermesso.nonDisponibile:
      case EsitoDelPermesso.concesso:
        return null;
    }
  }
}

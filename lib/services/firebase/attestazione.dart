import 'dart:async';

import '../ai/registro_dei_guasti.dart';

/// Come e' andata l'attestazione dell'app all'avvio.
enum EsitoAttestazione {
  /// Installata e funzionante: le chiamate portano il token.
  installata,

  /// NON installata, per scelta dichiarata: su questa build l'attestazione non
  /// puo' riuscire, e provarci fermerebbe ogni chiamata.
  nonInstallataPerScelta,

  /// Installata ma fallita: il token non si e' ottenuto. La conversazione
  /// prosegue lo stesso, e il fatto NON si tace.
  fallita,
}

/// Chi installa davvero l'attestazione. Un confine, per poterla far fallire in
/// prova senza Firebase.
abstract interface class InstallatoreAttestazione {
  /// Installa il fornitore. Solleva se non ci riesce.
  Future<void> installa();
}

/// L'attestazione dell'app, e il compromesso che la governa.
///
/// **IL DATO CHE HA FATTO NASCERE QUESTA CLASSE.** Build 2132, dal pannello di
/// messa a punto sul telefono:
///
///     reply: FirebaseException
///     [firebase_app_check/unknown] Error returned from API.
///     code: 403 body: App attestation failed.
///
/// **Dove nasce, letto nel sorgente dell'SDK e non supposto.** In
/// `firebase_ai-3.13.1/lib/src/base_model.dart:292` il costruttore delle
/// intestazioni fa `await effectiveAppCheck.getToken()` SENZA guardia: se quella
/// riga solleva, la chiamata all'AI non parte nemmeno. L'eccezione nasce
/// nell'ACQUISIZIONE DEL TOKEN, non nella chiamata al modello, ed e' per questo
/// che una prova REST diretta passava: quella non passa da App Check.
///
/// **Perche' l'imposizione spenta lato server non bastava.** Sono due cose
/// diverse: imposizione spenta vuol dire che il SERVER non pretende il token,
/// mentre il CLIENT prova comunque a procurarselo prima di partire. Play
/// Integrity non puo' attestare un'app installata da App Distribution, cioe'
/// fuori dal Play Store, quindi il tentativo fallisce sul telefono e nessuna
/// impostazione lato server lo tocca.
///
/// **LA VIA SCELTA: non installare il fornitore su quella strada.**
/// In `firebase_ai` l'aggancio e' `app.getService<FirebaseAppCheck>()`, e in
/// `firebase_app_check-0.4.5/lib/src/firebase_app_check.dart:46` il servizio si
/// registra SOLO quando qualcuno tocca `FirebaseAppCheck.instance`. Non
/// toccandolo, `getService` torna null, l'SDK salta l'intestazione e la
/// chiamata parte. Non c'e' niente da tollerare e nessuna eccezione da
/// inghiottire: il token non si chiede perche' nessuno lo pretende.
///
/// **COMPROMESSO DICHIARATO, DATATO E REVERSIBILE, 2 agosto 2026.**
/// Finche' resta cosi', le chiamate dell'app non portano attestazione. Il
/// rischio e' lo stesso gia' accettato per `natalChart` il 31 luglio: chiunque
/// conosca l'indirizzo puo' far chiamare un servizio a pagamento.
///
/// **La condizione che lo chiude**, ed e' una sola: quando l'app sara' su una
/// traccia di test interno del Play Store, Play Integrity la riconoscera',
/// l'attestazione tornera' a costare nulla e questa scelta va disfatta
/// rimettendo [installaSempre] a vero. E' la voce 24 del Registro.
class Attestazione {
  Attestazione._();

  /// Vero quando l'attestazione si installa comunque.
  ///
  /// Da rimettere a VERO il giorno in cui l'app sara' su una traccia di test
  /// interno del Play Store. E' l'unico interruttore da toccare.
  static const bool installaSempre = false;

  /// Se su questa build l'attestazione va installata.
  ///
  /// Fuori dalla release si installa sempre: li' il fornitore di debug funziona
  /// e serve a produrre il token da registrare in console. E' la strada che
  /// tornera' buona per tutti quando l'app sara' sul Play Store.
  static bool vaInstallata({required bool releaseMode}) =>
      installaSempre || !releaseMode;

  /// La ragione, in italiano, di cio' che e' successo. Mai vuota: il pannello
  /// di messa a punto la mostra, e un pannello che tace e' gia' costato due
  /// giri a questo progetto.
  static String ragioneDi(EsitoAttestazione esito) {
    switch (esito) {
      case EsitoAttestazione.installata:
        return 'Attestazione installata.';
      case EsitoAttestazione.nonInstallataPerScelta:
        return 'Attestazione NON installata, per scelta datata del 2 agosto '
            '2026: su una build che arriva da App Distribution Play Integrity '
            'non può attestare l\'app: il tentativo fermerebbe ogni chiamata '
            'prima di partire. Nessun servizio impone l\'attestazione, quindi '
            'il token non serve. Si torna indietro quando l\'app sarà su una '
            'traccia di test interno del Play Store.';
      case EsitoAttestazione.fallita:
        return 'Attestazione installata ma NON riuscita: le chiamate partono '
            'senza token. Nessun servizio lo impone, quindi rispondono lo '
            'stesso.';
    }
  }

  /// Installa l'attestazione quando serve, e NON si ferma se fallisce.
  ///
  /// Registra sempre l'esito nel [registro]: la conversazione prosegue, ma
  /// nessuno deve poter credere che l'attestazione stia funzionando.
  static Future<EsitoAttestazione> installa({
    required bool releaseMode,
    required InstallatoreAttestazione installatore,
    required RegistroDeiGuasti registro,
  }) async {
    if (!vaInstallata(releaseMode: releaseMode)) {
      registro.registra(
        operazione: 'attestazione',
        errore: StateError(ragioneDi(EsitoAttestazione.nonInstallataPerScelta)),
      );
      return EsitoAttestazione.nonInstallataPerScelta;
    }
    try {
      await installatore.installa();
      return EsitoAttestazione.installata;
    } catch (errore, traccia) {
      // NON si rilancia: un'attestazione che non riesce non deve impedire di
      // parlare, visto che nessuno la pretende. Ma non si tace nemmeno.
      annotaGuastoInnocuo('installando l\'attestazione', errore, traccia);
      registro.registra(operazione: 'attestazione', errore: errore);
      return EsitoAttestazione.fallita;
    }
  }
}

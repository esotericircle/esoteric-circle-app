/// **LA REGIONE DEI DATI, E I MODELLI CHE CI RISPONDONO.** Ordine DJ voce 03,
/// 13 settembre 2026.
///
/// **La regola permanente, parole del fondatore:** *"il runtime chiama solo
/// modelli disponibili nella regione dove stanno i dati, e chi scrive un
/// ordine verifica la disponibilita' regionale prima di nominare un
/// modello."* Per questa app passano data e luogo di nascita e domande su
/// famiglia, salute e denaro: tenere quel traffico in Europa vale piu' di
/// mezza generazione di modello, ed e' cio' che diciamo a chi la usa.
///
/// **Qui stanno la regione e i modelli verificati in lei, con la data della
/// verifica.** Ogni chiamata a Vertex AI dell'app legge la regione da qui, e
/// la guardia `i_modelli_stanno_nella_regione_dei_dati` pretende che ogni
/// modello nominato in `lib` e nel server sia in questo elenco. **Un modello
/// entra nell'elenco solo dopo una chiamata vera nella regione**, non dopo
/// averlo letto in un annuncio: l'ordine DI nominava Gemini 3.5 Flash Lite e
/// Gemini 3.6 Flash, che rispondono soltanto dall'endpoint `global`.
abstract final class LaRegioneDeiDati {
  /// **LA REGIONE**, la stessa di Firestore e delle funzioni del server.
  static const String regione = 'europe-west1';

  /// **I MODELLI CHE RISPONDONO IN [regione]**, col giorno della verifica.
  ///
  /// Verificati il 13 settembre 2026 alle 16:56 UTC con una chiamata vera a
  /// `europe-west1-aiplatform.googleapis.com`, risposta 200. Nella stessa
  /// verifica Gemini 3.6 Flash e Gemini 3.5 Flash Lite hanno risposto 404.
  static const Map<String, String> modelliVerificati = {
    'gemini-2.5-flash': '13 settembre 2026',
    'gemini-2.5-flash-lite': '13 settembre 2026',
  };
}

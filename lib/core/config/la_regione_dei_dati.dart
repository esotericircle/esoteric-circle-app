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
  ///
  /// **La voce del Maestro nel LIVE**, ordine EG voce 01, verificata il 23
  /// settembre 2026 con una chiamata vera a `generateContent` in
  /// `europe-west1`: risposta 200 con audio `audio/L16;codec=pcm;rate=24000`.
  /// La guardia l'ha vista rossa prima che entrasse qui.
  ///
  /// **La voce Pro**, verificata il 24 settembre 2026 durante l'ordine EK,
  /// quando il fondatore ha chiesto di scegliere lui le voci dei Maestri:
  /// `generateContent` in `europe-west1` risponde 200 con audio a 24.000
  /// campioni al secondo, e `streamGenerateContent` da' il primo suono in
  /// 1,06-1,13 secondi su tre giri. La guardia l'ha vista rossa prima.
  static const Map<String, String> modelliVerificati = {
    'gemini-2.5-flash': '13 settembre 2026',
    'gemini-2.5-flash-lite': '13 settembre 2026',
    'gemini-2.5-flash-tts': '23 settembre 2026',
    'gemini-2.5-pro-tts': '24 settembre 2026',
  };

  /// **L'UNICA ECCEZIONE: LE VOCI CHIRP 3 HD, SOLO SULL'ENDPOINT "eu".**
  /// Ordine EM voce 02, 25 settembre 2026.
  ///
  /// Il fondatore aveva chiesto le voci Chirp nel selettore del LIVE (ordine
  /// EK, *"Prova ad aggiungere anche le voci Chirp nel selettore"*), e le
  /// Chirp 3 HD in [regione] non ci sono: il 24 settembre 2026
  /// `europe-west1-texttospeech.googleapis.com` ha risposto *"Voice
  /// it-IT-Chirp3-HD-Aoede not found"*, mentre le trenta voci italiane
  /// rispondono su "eu" e su "global". Alla domanda se concedere
  /// un'eccezione limitata alla voce sull'endpoint multiregionale "eu", che
  /// tiene i dati nell'Unione Europea, il fondatore ha risposto *"Sì"*.
  ///
  /// **Cosa vale e cosa no.** Vale per la sola sintesi delle voci Chirp 3 HD,
  /// e solo sull'indirizzo qui sotto; **mai "global"**, e tutto il resto,
  /// compresa la voce Gemini-TTS, resta in [regione]. La guardia
  /// `le_voci_stanno_in_europa_test.dart` pretende che ogni indirizzo della
  /// voce scritto nell'app e nel server stia in [regione] o in questo elenco.
  static const Map<String, String> eccezioniDellaVoce = {
    'eu-texttospeech.googleapis.com':
        'le voci Chirp 3 HD, 25 settembre 2026, ordine EM voce 02',
  };
}

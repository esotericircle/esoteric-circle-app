/// LA PRIVACY POLICY DI ESOTERIC CIRCLE. Ordine BH voce 07.
///
/// Parole del fondatore: "completa nel modo piu' professionale e aggiornato
/// legalmente tutta la parte di privacy policy". Il testo vive qui, in una
/// casa sola, come dato: la schermata lo monta e le guardie lo leggono.
/// Scritto per il GDPR (regolamento UE 2016/679) e per le regole degli
/// store; la lingua e' quella dell'app, semplice e vera. Ogni sezione dice
/// cio' che il codice fa davvero: quando il codice cambia, questa pagina
/// cambia con lui, mai il contrario.
library;

/// Una sezione della policy: un titolo e il suo testo.
class SezioneDellaPolicy {
  const SezioneDellaPolicy({required this.titolo, required this.corpo});

  final String titolo;
  final String corpo;
}

/// La data dell'ultima revisione, mostrata in testa.
const String dataDellaPolicy = '24 agosto 2026';

/// Il titolare del trattamento e il contatto.
const String titolareDellaPolicy =
    'Esoteric Circle (esotericircle.app). Per ogni domanda o richiesta sui '
    'tuoi dati scrivi a info@esotericircle.com.';

const List<SezioneDellaPolicy> sezioniDellaPolicy = [
  SezioneDellaPolicy(
    titolo: 'Quali dati trattiamo',
    corpo: 'Account: la tua email, il nome che scegli e le vie di accesso '
        '(Google, Apple oppure email con parola). Nascita: giorno, ora e '
        'luogo, che servono a calcolare la tua carta natale; puoi usare '
        'l\'app anche senza fornirli. Conversazioni: le domande che fai ai '
        'Maestri e le loro risposte, con la memoria che i Maestri '
        'distillano per ricordarti. Cammino: i gesti compiuti nell\'app, i '
        'Sigilli accesi, gli Eos del borsellino. Preferenze: notifiche, '
        'qualità grafica, lingua.',
  ),
  SezioneDellaPolicy(
    titolo: 'I sensori restano sul tuo telefono',
    corpo: 'La fotocamera, il microfono, il movimento e la posizione si '
        'usano solo nel momento del rito che li chiede, sempre con la '
        'spiegazione prima. Le immagini della Costellazione del Viso e le '
        'foto per le card si elaborano sul dispositivo e non vengono '
        'caricate. Il microfono ascolta il soffio senza registrare audio. '
        'La posizione serve a mostrare il cielo sopra di te; le coordinate '
        'restano sul telefono.',
  ),
  SezioneDellaPolicy(
    titolo: 'Perché li trattiamo e con quale base',
    corpo: 'Per darti il servizio che chiedi (esecuzione del contratto): '
        'calcolo del cielo, risposte dei Maestri, borsellino, cammino '
        'custodito. Col tuo consenso: notifiche e sensori, che puoi '
        'revocare quando vuoi dalle impostazioni. Per legittimo interesse: '
        'sicurezza e prevenzione degli abusi, come descritto più sotto.',
  ),
  SezioneDellaPolicy(
    titolo: 'Intelligenza artificiale',
    corpo: 'Le risposte dei Maestri sono generate da modelli di '
        'intelligenza artificiale (Google Gemini, su Vertex AI). Per '
        'generarle, le tue domande e il contesto della conversazione '
        'vengono inviati ai server di Google Cloud nella regione europea. '
        'I contenuti astrologici di base non sono generati dall\'AI: l\'AI '
        'interpreta e personalizza. Nessuna decisione con effetti legali '
        'viene presa in modo automatizzato. I responsi sono un\'esperienza '
        'di intrattenimento e crescita personale, non una cura medica né '
        'una previsione certa del futuro.',
  ),
  SezioneDellaPolicy(
    titolo: 'Dove vivono i dati',
    corpo: 'Su Google Cloud e Firebase (Google Ireland Limited come '
        'responsabile del trattamento), nella regione europe-west1 '
        '(Belgio, Unione Europea). Non vendiamo i tuoi dati e non li '
        'condividiamo con terzi per pubblicità.',
  ),
  SezioneDellaPolicy(
    titolo: 'Quanto li conserviamo',
    corpo: 'Finché il tuo account vive. Se cancelli i tuoi dati o il tuo '
        'account, la cancellazione è immediata e totale, sul telefono e '
        'sul server: non c\'è un periodo di attesa.',
  ),
  SezioneDellaPolicy(
    titolo: 'Prevenzione degli abusi',
    corpo: 'Il dono di benvenuto si riceve una volta sola per email. Per '
        'impedire che la cancellazione e la nuova registrazione lo '
        'moltiplichino, quando il dono viene pagato conserviamo '
        'un\'impronta cifrata dell\'email (hash SHA-256, non l\'indirizzo '
        'in chiaro), che resta anche dopo la cancellazione dell\'account. '
        'Da quell\'impronta non si può risalire a chi sei: è una misura '
        'pseudonimizzata, fondata sul legittimo interesse a prevenire le '
        'frodi. Se alla cancellazione ci dici perché te ne vai, il tuo '
        'commento viene salvato in forma anonima, senza nessun legame con '
        'te.',
  ),
  SezioneDellaPolicy(
    titolo: 'I tuoi diritti',
    corpo: 'Puoi scaricare i tuoi dati in un file (voce "Scarica i tuoi '
        'dati"), correggerli dal profilo, cancellarli o cancellare '
        'l\'account in ogni momento, senza chiedere il permesso a nessuno. '
        'Hai inoltre diritto di opporti al trattamento, di chiederne la '
        'limitazione e di presentare reclamo al Garante per la protezione '
        'dei dati personali (gpdp.it) o all\'autorità del tuo paese.',
  ),
  SezioneDellaPolicy(
    titolo: 'Minori',
    corpo: 'L\'app non è destinata a chi ha meno di 16 anni. Se pensi che '
        'un minore ci abbia dato i suoi dati, scrivici e li cancelleremo.',
  ),
  SezioneDellaPolicy(
    titolo: 'Aggiornamenti di questa pagina',
    corpo: 'Se la policy cambia, la data in testa cambia con lei; per i '
        'cambiamenti importanti te lo diremo dentro l\'app. Questa '
        'versione riflette ciò che l\'app fa davvero alla data indicata.',
  ),
];

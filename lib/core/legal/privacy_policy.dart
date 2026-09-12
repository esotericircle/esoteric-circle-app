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
    // **I NUMERI QUI SONO GLI STESSI CHE IL SERVER USA. Ordine CB voce 05.**
    // Fino a quest'ordine questa sezione diceva "finché il tuo account vive",
    // e da quando esistono le scadenze non sarebbe più stato vero. Una prova
    // lega ogni numero di questa pagina al listino delle scadenze: se un tempo
    // cambia nel codice e non qui, la prova cade prima che la pagina diventi
    // una bugia pubblicata.
    corpo: 'Quello che è tuo resta finché vive il tuo account: il cammino, i '
        'Sigilli, gli Eos, la carta natale, il profilo e le coppie della '
        'Sinastria. Quello che è un registro, invece, ha una scadenza: la '
        'memoria delle conversazioni coi Maestri resta 12 mesi, il registro '
        'dei movimenti degli Eos 24 mesi, i segni tecnici dei consumi '
        'giornalieri 30 giorni, le tue letture del viso e lo storico '
        'dell\'Archetipo 24 mesi sul telefono. Scaduto quel tempo li '
        'cancelliamo noi, senza che tu debba chiedere niente. Se cancelli i '
        'tuoi dati o il tuo account, la cancellazione è immediata e totale, '
        'sul telefono e sul server: non c\'è un periodo di attesa.\n\n'
        'Del testo delle conversazioni teniamo per intero le più recenti; '
        'dopo due settimane ne conserviamo un riassunto per Maestro e per '
        'settimana insieme ai fatti che ne emergono; il testo integrale '
        'sparisce comunque ai 12 mesi. I riassunti e i fatti restano oltre, '
        'perché sono ciò che permette al Maestro di riconoscerti. '
        'L\'indice dei Ricordi del Cerchio, cioè le righe che dicono quando '
        'hai usato quale arte e con quale Maestro, resta 24 mesi. '
        'I responsi che scegli di custodire, col gesto Custodisci o '
        'condividendoli, non scadono: restano finché vive il tuo account, '
        'perché sono esattamente ciò che hai dichiarato di voler tenere. '
        'Per mandarti le notifiche del Cerchio anche ad app chiusa teniamo il '
        'gettone del tuo apparecchio, insieme ai Doni che hai acceso, alle '
        'ore che hai scelto, al tuo fuso orario: senza quelle tre cose non '
        'sapremmo a che ora raggiungerti. Il gettone sparisce quando spegni '
        'le notifiche e quando cancelli il tuo account.',
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
        'frodi. La conserviamo 24 mesi. Se alla cancellazione ci dici '
        'perché te ne vai, il tuo commento viene salvato in forma anonima '
        'senza nessun legame con te. Anche quello lo conserviamo 24 mesi.',
  ),
  SezioneDellaPolicy(
    titolo: 'La misura di come va l\'app',
    // **QUESTA SEZIONE NASCE CON LA MISURA, ordine CC voce 09.** La policy e'
    // dato dentro l'app dall'ordine BH voce 07, e una guardia ancora le sue
    // affermazioni al codice: qui i cinque eventi sono gli stessi cinque che
    // il client dichiara e che il server ammette, e se le tre liste divergono
    // la prova cade.
    corpo: 'Se ce lo permetti, contiamo cinque gesti per capire cosa '
        'funziona: le aperture dell\'app, i riti cominciati, i riti finiti, i '
        'ritorni da una notifica e i responsi condivisi. Sono numeri per '
        'giorno, non un profilo: non registriamo chi ha fatto cosa, non '
        'registriamo niente che tu abbia scritto e non usiamo nessun '
        'identificativo pubblicitario. Te lo chiediamo una volta e la '
        'risposta si cambia dalle Impostazioni; se dici no, l\'app resta '
        'esattamente com\'è. I conti restano 24 mesi.',
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

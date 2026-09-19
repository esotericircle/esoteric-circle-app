/// LE CONDIZIONI D'USO DI ESOTERIC CIRCLE. Ordine EA voce 18.
///
/// **Prima di quest'ordine non esistevano**, ed era una scelta scritta:
/// *"il Cerchio non ha termini di servizio"* (ordine CF, dichiarato in
/// `consensi_della_registrazione.dart`). La voce 18 mette privacy policy,
/// condizioni d'uso e disclaimer in una pagina sola, quindi le condizioni
/// nascono qui, e il fondatore ha deciso il 20 settembre 2026 che le
/// scrivesse chi esegue l'ordine.
///
/// **VANNO LETTE DA UNA PERSONA PRIMA DELLA PUBBLICAZIONE.** Questo testo e'
/// scritto per essere onesto e chiaro, non per essere un parere legale: prima
/// che l'app arrivi sugli store, il fondatore o un legale devono rileggerlo e
/// correggerlo dove serve. La riga vale finche' qualcuno non la cancella
/// avendo fatto quella lettura.
///
/// Come la policy, il testo vive qui come dato: la pagina lo monta e le
/// guardie lo leggono. Ogni frase dice cio' che il codice fa davvero.
library;

import 'privacy_policy.dart' show SezioneDellaPolicy;

/// La data dell'ultima revisione delle condizioni.
const String dataDelleCondizioni = '20 settembre 2026';

const List<SezioneDellaPolicy> sezioniDelleCondizioni = [
  SezioneDellaPolicy(
    titolo: 'Che cos\'è Esoteric Circle',
    corpo: 'Esoteric Circle è un\'app di intrattenimento e crescita '
        'personale che poggia su tradizioni esoteriche documentate: '
        'astrologia, cartomanzia, rune, chakra, numerologia e rituali. Tre '
        'Maestri guidati da intelligenza artificiale interpretano quelle '
        'tradizioni e ti parlano. Usando l\'app accetti queste condizioni.',
  ),
  SezioneDellaPolicy(
    titolo: 'Che cosa non è',
    corpo: 'Non è medicina, non è psicoterapia, non è consulenza legale e '
        'non è consulenza finanziaria. Nessun responso è una diagnosi, una '
        'cura o una previsione certa, e nessuno va usato per decisioni di '
        'salute, di denaro o di legge: per quelle esistono i professionisti. '
        'Le scelte importanti restano sempre tue.',
  ),
  SezioneDellaPolicy(
    titolo: 'Chi può usarla',
    corpo: 'L\'app è per persone maggiorenni. Se hai meno di diciotto anni '
        'non puoi usarla e non puoi creare un account.',
  ),
  SezioneDellaPolicy(
    titolo: 'Il tuo account',
    corpo: 'Puoi usare gran parte dell\'app senza registrarti. Se ti '
        'registri, l\'accesso è tuo e non si presta: quello che accade da '
        'quell\'account è tuo. Puoi cancellare i tuoi dati o l\'intero '
        'account quando vuoi, dal menu del tuo account; la cancellazione '
        'dell\'account è definitiva, e con lui se ne vanno il cammino, i '
        'Sigilli e gli Eos.',
  ),
  SezioneDellaPolicy(
    titolo: 'Gli Eos e i piani',
    corpo: 'Gli Eos sono il credito interno del Cerchio: servono solo dentro '
        'l\'app, non sono denaro, non hanno valore fuori di qui, non si '
        'convertono e non si rimborsano in denaro. I piani in abbonamento si '
        'acquistano e si disdicono dallo store da cui hai scaricato l\'app, '
        'Apple o Google, e sono le loro regole a governare pagamenti, '
        'rinnovi e rimborsi. Quello che hai già pagato e non hai ancora '
        'usato resta tuo finché il piano è attivo.',
  ),
  SezioneDellaPolicy(
    titolo: 'Come si usa, e come non si usa',
    corpo: 'Non usare l\'app per fare del male a qualcuno, per aggirarne le '
        'difese, per automatizzarne le richieste o per rivendere quello che '
        'ti restituisce come se fosse un servizio tuo. Non scrivere ai '
        'Maestri dati di altre persone senza che loro lo sappiano. Se un uso '
        'mette a rischio il servizio o le altre persone, possiamo sospendere '
        'l\'accesso, e ti diciamo perché.',
  ),
  SezioneDellaPolicy(
    titolo: 'I testi, le immagini e quello che scrivi tu',
    corpo: 'Le illustrazioni, i testi, i nomi e il disegno dell\'app sono '
        'nostri o di chi ce li ha concessi, e restano loro: puoi usarli '
        'dentro l\'app e condividere i responsi che l\'app ti offre di '
        'condividere. Quello che scrivi tu resta tuo: ci serve solo per '
        'darti la risposta, per ricordare la conversazione e per farti '
        'scaricare i tuoi dati, come racconta la privacy policy.',
  ),
  SezioneDellaPolicy(
    titolo: 'Le risposte dei Maestri',
    corpo: 'Le risposte sono generate da modelli di intelligenza '
        'artificiale a partire dalle tradizioni e dai calcoli veri del '
        'cielo. Possono sbagliare, possono ripetersi e non sono verità '
        'verificate: sono una lettura simbolica. Il calcolo astronomico, '
        'invece, è calcolo, e quando un responso poggia su di lui l\'app '
        'dice da dove viene.',
  ),
  SezioneDellaPolicy(
    titolo: 'Quando il servizio non c\'è',
    corpo: 'Facciamo del nostro meglio perché l\'app funzioni, ma non '
        'possiamo prometterti che sia sempre raggiungibile: la rete cade, i '
        'fornitori si fermano, una versione nuova può avere difetti. Non '
        'rispondiamo dei danni che nascono dall\'aver preso un responso per '
        'un consiglio professionale, e non escludiamo nessuna '
        'responsabilità che la legge non permetta di escludere, a cominciare '
        'dai casi di dolo e colpa grave.',
  ),
  SezioneDellaPolicy(
    titolo: 'Se queste condizioni cambiano',
    corpo: 'Se cambiamo qualcosa di importante te lo diciamo dentro l\'app '
        'prima che valga, e la data in testa a questa pagina dice sempre '
        'quando è stata scritta l\'ultima versione. Se non sei d\'accordo '
        'puoi smettere di usare l\'app e cancellare l\'account.',
  ),
  SezioneDellaPolicy(
    titolo: 'Legge e contatti',
    corpo: 'Vale la legge italiana, e restano fermi i diritti che la legge '
        'riconosce ai consumatori, compreso il foro del luogo in cui vivi. '
        'Per qualunque cosa scrivi a info@esotericircle.com.',
  ),
];

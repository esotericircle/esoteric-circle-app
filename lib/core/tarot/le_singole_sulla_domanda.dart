import '../responsi/la_forma_del_responso.dart';
import 'la_carta_nella_risposta.dart';
import 'la_domanda_letta.dart';
import 'le_carte_nella_posizione.dart';
import 'tarot_spread.dart';
import 'tarot_topic.dart';

/// **LE CARTE SINGOLE LETTE SULLA DOMANDA.** Ordine GA voce GA.06, terzo giro,
/// 21 ottobre 2026.
///
/// Il lettore cieco indipendente ha trovato le singole *"scritte sul tema
/// della lente e non sulla domanda"*: a chi chiedeva se investire i risparmi
/// in borsa, "Il Papa" diceva *"Cerca un mentore: scrivi oggi a una persona
/// esperta del tuo campo"*, e la Regina di Denari *"anche la tua carriera e'
/// un giardino che chiede acqua"*; a chi chiedeva di una causa, le singole
/// parlavano di partenze rimandate. Il corpus delle singole e' per gruppo
/// dell'argomento scelto (amore, lavoro, vita), non per domanda.
///
/// **Due cure, e nessuna finge di sapere cio' che non sa.**
/// - Il gruppo viene dalla domanda quando la domanda lo dice
///   (`LaDomandaLetta.gruppoDelleSingole`): una promozione e' lavoro anche se
///   l'argomento scelto era la vita.
/// - Su salute, legge e denaro il registro e' quello della vita e il "Cosa fare
///   adesso" della carta non da' nessun gesto del corpus: dice che cosa la
///   carta mostra, che non e' un'indicazione, e rimanda a chi e' competente.
///   Tre testi per tema, a rotazione sul posto della carta, cosi' le singole
///   di una stessa stesa non ripetono la stessa frase.
///
/// PADRE: ordine GA voce GA.03 e GA.07 (le singole dal corpus per gruppo
/// dell'argomento), commit del 20 ottobre 2026.
abstract final class LeSingoleSullaDomanda {
  static ResponsoInterpretato di(
    DrawnCard d,
    LaDomandaLetta domanda,
    TarotTopic argomento, {
    int uscita = 0,
    int posto = 0,
    int base = 0,
  }) {
    final dalCorpus = LeCarteNellaPosizione.responsoDi(
        d, domanda.gruppoDelleSingole(argomento),
        uscita: uscita);
    final sensibile = domanda.sensibile;
    if (sensibile == null) return dalCorpus;
    return ResponsoInterpretato(
      arte: ArteInterpretata.tarocchi,
      titolo: dalCorpus.titolo,
      risposta: dalCorpus.risposta,
      cosaFare: cosaFareSensibile(sensibile, d, base + posto),
    );
  }

  /// Il "Cosa fare adesso" di una carta singola su salute, legge o denaro.
  static String cosaFareSensibile(TemaSensibile tema, DrawnCard d, int posto) {
    final testi = _testi[tema]!;
    final k = LaCartaNellaRisposta.di(d);
    // **Sulla salute mai il tema della carta, solo il tono**: *"una fine che
    // libera"* accanto a un intervento sarebbe crudele.
    final t = tema == TemaSensibile.salute
        ? switch (k.tono) {
            TonoDellaCarta.favorevole => 'un tono sereno',
            TonoDellaCarta.condizionato => 'un invito alla pazienza',
            TonoDellaCarta.sfavorevole => 'una tensione comprensibile',
          }
        : k.tema;
    return testi[posto % testi.length].replaceAll('{t}', t);
  }

  /// Da 38 a 45 parole senza il tema, che ne porta da due a cinque: ogni
  /// testo sta fra 40 e 50 parole con qualunque carta.
  static const Map<TemaSensibile, List<String>> _testi = {
    TemaSensibile.salute: [
      'Qui la carta mostra {t}: vedi in questo un invito a ordinare le '
          'domande da fare, non un\'indicazione sulla cura. Per ogni scelta sulla '
          'salute conta il parere di un medico: scrivi i dubbi, portali alla '
          'prossima visita e ascolta le risposte con calma.',
      'In questo posto la carta indica {t}: non dice nulla sull\'esito né su '
          'ciò che devi fare per la tua salute. Usala per notare come vivi '
          'l\'attesa e per preparare le domande da rivolgere al medico che ti segue, '
          'l\'unico a poterti consigliare.',
      'Questa carta richiama {t} e nient\'altro: nessun segno può sostituire '
          'una visita. Se qualcosa ti preoccupa parlane con il medico, annota '
          'sintomi e dubbi prima dell\'incontro e porta con te una persona di '
          'fiducia, se questo ti dà sostegno.',
      'Qui la carta porta {t} e non va letta come una previsione sulla '
          'salute. Serve a ricordarti di ascoltarti con calma. Ogni scelta su '
          'esami, cure e tempi spetta al medico: segna ciò che senti e ciò che '
          'vuoi chiedere, poi parlane apertamente alla prossima visita.',
      'In questa posizione la carta porta {t}, ma non dice nulla sul tuo '
          'stato di salute. Concediti qualche momento di quiete senza cercare '
          'risposte nelle carte. Se qualcosa ti preoccupa, prenota una visita '
          'o chiama un medico: una persona competente può ascoltarti e darti '
          'indicazioni utili.',
    ],
    TemaSensibile.legge: [
      'Qui la carta mostra {t}: riguarda il modo in cui vivi la questione, '
          'non il suo esito. Per le scelte legali conta il parere di un '
          'professionista: metti in ordine date e documenti, scrivi le domande '
          'e portale a un avvocato che valuti il tuo caso.',
      'In questo posto la carta indica {t}, senza dire nulla su come andrà la '
          'vicenda. Usala per chiarirti che cosa ti preoccupa e con quale '
          'spirito la affronti; le decisioni sulle mosse da compiere spettano '
          'a chi è competente in materia.',
      'Questa carta richiama {t}: è uno spunto per ordinare i pensieri, non un '
          'consiglio giuridico. Raccogli i fatti con le date, annota ciò che '
          'vuoi chiedere e affidati a un professionista abilitato per ogni '
          'scelta che ha conseguenze reali.',
      'Qui la carta porta {t}: non dice chi ha ragione né come finisce la '
          'vicenda. Usala per capire con quale animo la vivi. Per ogni mossa '
          'concreta, dai termini alle firme, affidati a un avvocato e porta '
          'con te tutti i documenti in ordine.',
      'In questa posizione la carta mostra {t}, senza alcun valore '
          'giuridico. Non serve a prevedere un\'udienza né a scegliere una '
          'strategia. Può aiutarti a notare che cosa ti pesa davvero; poi '
          'scrivi le domande e porta tutto a un professionista abilitato.',
    ],
    TemaSensibile.denaro: [
      'Qui la carta mostra {t}: vedi in questo uno spunto sul tuo modo di '
          'guardare il denaro, non un\'indicazione su cosa fare. Per '
          'scegliere su risparmi e investimenti non bastano le carte: scrivi '
          'le domande e portale a un consulente abilitato e indipendente.',
      'In questo posto la carta indica {t}, senza dire se una scelta '
          'economica convenga. Usala per capire con quale stato d\'animo ti '
          'avvicini alla decisione: prima di muovere qualsiasi somma chiedi sempre '
          'un parere scritto a chi è abilitato a darlo.',
      'Questa carta richiama {t}: una riflessione sul modo di affrontare la '
          'questione, non un verdetto sul denaro. Calcola con calma quanto '
          'puoi permetterti di perdere, annota i dubbi e discutili con un '
          'consulente competente e indipendente prima di impegnarti.',
      'Qui la carta porta {t}: un\'immagine sul tuo rapporto con i soldi, non '
          'un consiglio d\'acquisto. Prima di impegnare qualsiasi somma scrivi '
          'cifre, rischi e scadenze: poi fai verificare tutto da un consulente '
          'abilitato e indipendente prima di firmare.',
      'In questa posizione la carta mostra {t}, senza dire se un investimento '
          'o una spesa convenga. Tienila come spunto di riflessione. Per '
          'decidere servono dati, costi e rischi spiegati da chi è abilitato a '
          'farlo: chiedi un parere scritto e prenditi il tempo di leggerlo.',
    ],
  };
}

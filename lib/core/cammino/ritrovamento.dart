import '../astro/zodiac.dart';
import 'cammino_da_custodire.dart';

/// COSA HA PORTATO IL GIRO DEL CUSTODE, E PERCHE' NON HA PORTATO NIENTE.
/// Ordine AZ voce 01, fatto F1.
///
/// **Nasce da un nulla che voleva dire tre cose.** Il giro rispondeva `null`
/// quando non c'era un borsellino da interrogare, quando il server non aveva
/// risposto e quando il server aveva detto di no. Chi lo chiamava non poteva
/// dire niente alla persona **proprio perche' non sapeva cosa fosse successo**,
/// e quel silenzio e' il fatto F1: si tocca, non si entra, e nessuno spiega.
class EsitoDelGiro {
  const EsitoDelGiro({
    this.cammino,
    this.rifiutatoDalServer = false,
    this.senzaRisposta = false,
    this.codice,
  });

  /// Cio' che il server ha fuso, quando ha risposto.
  final CamminoDaCustodire? cammino;

  /// Il server ha risposto, e ha risposto di no. Riprovare non basta.
  final bool rifiutatoDalServer;

  /// Il server non ha risposto. Riprovare ha senso.
  final bool senzaRisposta;

  /// Il codice del rifiuto, per il registro dei guasti. **Non si mostra mai a
  /// schermo**: alla persona si parla in italiano, non in codici.
  final String? codice;
}

/// I PASSI DEL RITO CHE CHIEDONO UN DATO DI NASCITA.
///
/// Sono quelli che il ritrovamento puo' saltare, perche' il Cerchio ha gia'
/// la risposta. Gli altri passi del Risveglio, l'accoglienza, il vocativo e
/// il Sigillo, non chiedono un dato: chiedono un momento, e quello si vive
/// una volta sola.
enum PassoDelRito { data, ora, luogo, nome }

/// COSA IL CERCHIO HA RITROVATO, E COSA RESTA DA CHIEDERE. Ordine AP voce 05.
///
/// **La domanda di Mauro**: rifare l'onboarding quando si e' gia' registrati
/// non ha senso. Chi rientra col suo account ha gia' dato la sua nascita al
/// Cerchio, e richiedergliela e' come se il Cerchio non lo conoscesse.
///
/// **La regola vive in UN punto solo, e non e' un vezzo.** La stessa domanda
/// arriva da due strade diverse, la porta piccola della voce 04 e il
/// "Continua come" della voce 06: se ognuna decidesse per conto suo, un
/// giorno una delle due chiederebbe di nuovo la nascita a chi l'aveva gia'
/// data. E' la regola delle due porte applicata a una decisione invece che a
/// un dato.
///
/// **Se l'identita' e' PARZIALE si salta solo la parte gia' fatta**, e si
/// dichiara: chi ha dato il giorno ma non l'ora si vede chiedere l'ora, non
/// tutto da capo. L'ora e' la distinzione che decide se l'Ascendente esiste,
/// quindi saltarla per comodita' vorrebbe dire chiudere una porta per sempre.
class Ritrovamento {
  const Ritrovamento._({
    required this.passiDaChiedere,
    required this.cartaRitrovata,
    required this.quantiTraguardi,
    required this.quantiEos,
    this.cerchioAppenaNato = false,
    required this.nome,
    required this.segno,
    this.rifiutatoDalServer = false,
    this.senzaRisposta = false,
    this.identita,
  });

  /// **L'IDENTITA' CHE IL CERCHIO CUSTODIVA.** Ordine AZ, trovato sul
  /// telefono del fondatore il 22 agosto 2026, ed e' il fatto F2.
  ///
  /// **Serve a chi deve RIPRENDERE il rito invece di rifarlo.** La logica per
  /// ripartire dal passo che manca esisteva gia' e funzionava, ma viveva
  /// nell'`initState` del Risveglio e si applicava **solo se lo schermo veniva
  /// costruito con l'identita' ritrovata**. Chi rientrava trovava lo schermo
  /// gia' montato senza, quindi quella logica non girava mai e il rito
  /// ripartiva dall'accoglienza: e' esattamente "sono costretto a rifare
  /// l'onboarding per intero".
  final IdentitaDaCustodire? identita;

  /// **IL SERVER HA DETTO DI NO.** Ordine AZ voce 01, fatto F1.
  ///
  /// Fino alla 2192 il giro del Custode aveva un modo solo di andare storto:
  /// tornare nulla. Ma i modi sono due, e chiedono due frasi diverse. Questo
  /// e' il primo: il server ha risposto, e ha risposto di no, con uno fra
  /// `unauthenticated`, `permission-denied`, `invalid-argument` e
  /// `failed-precondition`. **Non serve riprovare fra un minuto**: qualcosa va
  /// fatto, e la persona deve saperlo.
  final bool rifiutatoDalServer;

  /// **IL SERVER NON HA RISPOSTO.** Ordine AZ voce 01, fatto F1.
  ///
  /// L'altro modo: rete assente, funzione non raggiungibile, tempo scaduto.
  /// Qui riprovare ha senso, e la frase giusta e' un'altra. **Confondere i due
  /// casi vuol dire mandare a controllare l'account chi ha solo il telefono in
  /// galleria**, e viceversa.
  final bool senzaRisposta;

  /// Vero se qualcosa e' andato storto, in uno dei due modi.
  bool get eAndataStorta => rifiutatoDalServer || senzaRisposta;

  /// **COSA SI DICE A CHI E' ENTRATO E NON HA VISTO NIENTE.** Ordine AZ voce
  /// 01, ed e' la cura del fatto F1.
  ///
  /// **Sta qui, in un punto solo, e non e' un vezzo.** Il giro dopo il
  /// riconoscimento e' chiamato da tre posti diversi: il Risveglio, il passo
  /// della custodia e l'area account. Se ognuno decidesse cosa dire, un
  /// giorno uno dei tre tacerebbe, ed e' esattamente cio' che e' successo:
  /// tacevano tutti e tre.
  ///
  /// **E' nulla quando non c'e' niente da dire**, cioe' quando il giro e'
  /// andato bene: chi entra e arriva a casa non ha bisogno di un avviso.
  ///
  /// **CORTA, e la misura viene dal telefono del fondatore.** La prima
  /// stesura diceva la stessa cosa in tre frasi: sullo schermo vero occupava
  /// **cinque righe** e schiacciava il "Riprova" contro il bordo. Un avviso
  /// che si legge in un secondo vale piu' di uno completo che non si legge.
  /// Cio' che si e' tolto e' il consiglio su cosa fare dopo: sta nel pulsante,
  /// che e' il posto giusto.
  String? get cosaDireAllaPersona {
    if (rifiutatoDalServer) {
      // **NIENTE CODICI TECNICI.** Il codice del rifiuto va nel registro dei
      // guasti, non negli occhi di chi legge.
      return "Sei dentro, ma il Cerchio non si è aperto. Il tuo cammino è al "
          "sicuro.";
    }
    if (senzaRisposta) {
      return 'Sei dentro, ma il Cerchio non risponde. Controlla la '
          'connessione.';
    }
    return null;
  }

  /// Tutti i passi che chiedono un dato: e' cio' che si fa alla prima volta.
  static const List<PassoDelRito> tuttiIPassi = PassoDelRito.values;

  /// Cosa resta da chiedere, in ordine di rito.
  final List<PassoDelRito> passiDaChiedere;

  /// Vero se il Cerchio aveva abbastanza per rifare la carta natale.
  final bool cartaRitrovata;

  /// Quanti Sigilli sono tornati accesi.
  final int quantiTraguardi;

  /// Quanti Eos aveva il borsellino al ritorno.
  final int quantiEos;

  /// Il nome ritrovato, per salutare chi torna con quello che e' suo.
  final String? nome;

  /// **IL SEGNO, ordine AQ voce 04.** Non e' un dato in piu' custodito: nasce
  /// dal giorno di nascita che il Cerchio ha restituito, come nasce ovunque
  /// nell'app. Nullo quando il giorno non e' tornato, e allora l'emblema non
  /// compare: meglio niente che il segno di qualcun altro.
  final Zodiac? segno;

  /// Vero se non c'e' piu' niente da chiedere: il rito non si rifa'.
  bool get siSalta => passiDaChiedere.isEmpty;

  /// **IL CERCHIO E' NATO IN QUESTA SESSIONE**: il benvenuto e' stato
  /// accreditato dall'ultima sincronia. Ordine BG voce 01.
  final bool cerchioAppenaNato;

  /// Vero se c'e' qualcosa che valga la pena mostrare.
  ///
  /// Chi entra con un account nuovo non deve vedere una scena che celebra il
  /// ritrovamento di zero cose: sarebbe una promessa mantenuta a vuoto.
  ///
  /// **E LA DOTE DI NASCITA NON E' UNA COSA TENUTA.** Ordine BG voce 01: un
  /// Cerchio appena nato ha gia' la dote intera (benvenuto piu' giorno), e per
  /// questa regola sembrava un ritorno: "Il Cerchio ti aveva tenuto tutto,
  /// la dote" detto a chi non aveva niente da ritrovare. Se il Cerchio e'
  /// appena nato, gli Eos non contano come ritrovamento.
  bool get qualcosaDaMostrare =>
      cartaRitrovata ||
      quantiTraguardi > 0 ||
      (!cerchioAppenaNato && quantiEos > 0);

  /// Legge cosa il Cerchio ha restituito e decide.
  static Ritrovamento da(
    CamminoDaCustodire? cammino, {
    int saldoEos = 0,
    bool cerchioAppenaNato = false,
    bool rifiutatoDalServer = false,
    bool senzaRisposta = false,
  }) {
    final identita = cammino?.identita;
    // **L'ORA NON TRATTIENE PIU' NESSUNO NEL RITO. Ordine CF voce 06.**
    //
    // **Il fatto del fondatore, verbatim**: "sono rimasto alla piena
    // schermata del risveglio anziche' portarmi alla home."
    //
    // **La causa, misurata.** `siSalta` e' vero solo quando questo elenco e'
    // vuoto, e qui dentro c'era l'ora. Ma l'ora nel Cerchio e' un dato
    // FACOLTATIVO per costruzione: l'Ascendente si calcola quando c'e' e si
    // dichiara assente quando non c'e', e il rito stesso offre "non la so".
    // Chi ha risposto cosi' aveva `ora` nulla per sempre, quindi il rito non
    // si saltava mai piu': a ogni reinstallazione lo rifaceva per intero, e
    // non c'era nessuna risposta che potesse liberarlo.
    //
    // **Non si perde niente**: l'ora resta chiedibile dal menu' utente, in
    // "Dati di nascita", che e' il posto dove un dato facoltativo si aggiunge
    // quando la persona lo scopre. Cio' che trattiene restano il giorno, il
    // luogo e il nome, che senza non c'e' ne' carta ne' vocativo.
    final manca = <PassoDelRito>[
      if (identita?.giorno == null) PassoDelRito.data,
      if (identita?.luogo == null) PassoDelRito.luogo,
      if (identita?.nome == null) PassoDelRito.nome,
    ];
    return Ritrovamento._(
      passiDaChiedere: manca,
      // **LA CARTA SI DICE RITROVATA SOLO COL GIORNO**, che e' il minimo per
      // calcolarla: annunciarla senza sarebbe promettere un cielo che non si
      // puo' tracciare.
      cartaRitrovata: identita?.giorno != null,
      quantiTraguardi: cammino?.sigilli.length ?? 0,
      quantiEos: saldoEos,
      cerchioAppenaNato: cerchioAppenaNato,
      nome: identita?.nome,
      segno:
          identita?.giorno == null ? null : Zodiac.fromDate(identita!.giorno!),
      rifiutatoDalServer: rifiutatoDalServer,
      senzaRisposta: senzaRisposta,
      identita: identita,
    );
  }
}

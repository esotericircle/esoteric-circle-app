/// **I CONTROLLI DEL COLLAUDO, separati da chi li esegue.** Ordine EC voce
/// 02, 21 settembre 2026.
///
/// **Perche' stanno in un file loro.** L'ordine chiede che ogni controllo
/// nuovo nasca rosso secondo la regola A, cioe' che lo si veda cadere su una
/// risposta costruita apposta col difetto. Finche' i controlli vivevano
/// dentro il collaudo, per provarli bisognava chiamare Gemini: **una regola
/// che si puo' provare solo pagando non la prova nessuno**. Qui sono
/// funzioni pure, e `test/i_controlli_del_collaudo_prendono_i_difetti_test.dart`
/// li fa cadere uno per uno senza rete.
///
/// **Il controllo del chiarimento non sta qui**, perche' non e' puro: chiede
/// al modello, con una domanda chiusa, se una risposta scritta in liberta'
/// dice di non aver capito. Vive nel collaudo insieme a chi sa parlare.
library;

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/immersive_intents.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/voce_del_maestro.dart';

/// Cio' che ci si aspetta da un turno.
class AtteseDelTurno {
  const AtteseDelTurno({
    this.apreIlPulsante = false,
    this.deveNominare = const [],
  });

  final bool apreIlPulsante;
  final List<String> deveNominare;
}

/// L'esito dei controlli su un turno: le cadute e le parole altrui incontrate.
class EsitoDeiControlli {
  const EsitoDeiControlli(this.cadute, this.confusioni);

  final List<String> cadute;
  final List<String> confusioni;
}

/// **Le frasi con cui un Maestro devia invece di rispondere.** Sono gli
/// inviti e le etichette dei pulsanti del codice: se compaiono nel testo di
/// una risposta, il Maestro sta rimandando la persona altrove invece di
/// risponderle.
List<String> frasiCheDeviano() => [
      for (final i in ImmersiveIntents.all) ...[i.invite, i.buttonLabel],
    ];

/// I controlli su un turno, tutti insieme. [dette] sono le risposte gia' date
/// nella conversazione, per riconoscere una ripetizione.
EsitoDeiControlli controllaIlTurno({
  required Maestro maestro,
  required ChatMessage risposta,
  required AtteseDelTurno attese,
  required int numeroDelTurno,
  required List<String> dette,
}) {
  final cadute = <String>[];
  final confusioni = <String>[];
  final n = numeroDelTurno;

  // --- EB.03: il pulsante solo se l'utente lo chiede.
  final haIlPulsante = risposta.intentId != null;
  if (haIlPulsante != attese.apreIlPulsante) {
    cadute.add(attese.apreIlPulsante
        ? 'turno $n: la persona ha chiesto l\'arte e il pulsante non c\'e\''
        : 'turno $n: e\' comparso il pulsante ${risposta.intentId} e nessuno '
            'l\'ha chiesto, al posto della risposta');
  }

  // --- EB.02: risponde nel merito, e nessun invito al posto della risposta.
  if (!attese.apreIlPulsante) {
    if (risposta.text.trim().isEmpty) {
      cadute.add('turno $n: il Maestro non ha detto niente');
    }
    for (final deviazione in frasiCheDeviano()) {
      if (risposta.text.contains(deviazione)) {
        cadute.add('turno $n: la risposta contiene un invito del codice, '
            '"$deviazione": il Maestro rimanda altrove invece di rispondere');
      }
    }
    // **ALMENO UNA DELLE FIGURE, non una in particolare.** Ordine ED voce 01.
    //
    // **Il difetto che ha cambiato questa misura.** Pretendeva che la
    // risposta nominasse OGNI parola dell'elenco, e sulla gettata di Caligo
    // l'elenco era la prima runa: al rifiuto Caligo rispondeva *"Hai gia'
    // compiuto la tua gettata, non ti chiedo di farne un'altra, il mio
    // compito e' interpretare i segni che hai gia' rivelato"* e nominava
    // **Ansuz**, che e' una delle tre. Il comportamento era esatto e la
    // misura sbagliata. **La grandezza giusta e' stare nel merito di quel
    // responso**, cioe' nominarne almeno una figura: quale, lo decide il
    // Maestro. Non e' una soglia abbassata, e' un'altra grandezza: su una
    // risposta che non ne nomina nessuna questo controllo cade come prima.
    if (attese.deveNominare.isNotEmpty) {
      final basso = risposta.text.toLowerCase();
      final nominate = attese.deveNominare
          .where((p) => basso.contains(p.toLowerCase()))
          .toList();
      if (nominate.isEmpty) {
        cadute.add('turno $n: la risposta non nomina nessuna delle figure '
            'del responso che la persona ha in mano '
            '(${attese.deveNominare.join(", ")}), quindi non risponde nel '
            'merito di quello che e\' stato chiesto');
      }
    }
  }

  // --- EB.05: non ripete una frase gia' detta.
  final pulito = risposta.text.trim();
  if (pulito.isNotEmpty && dette.contains(pulito)) {
    cadute.add('turno $n: il Maestro ha ripetuto parola per parola una '
        'risposta gia\' data');
  }

  // --- EB.08: ogni Maestro con la sua voce.
  //
  // **QUI SI MISURA UN TASSO, NON SI CHIUDE UN CANCELLO, e la ragione va
  // letta prima di credere al verde.** Il divieto incrociato del lessico vive
  // nell'istruzione dall'ordine BP voce 1. Su testo GENERATO il modello lo
  // rispetta quasi sempre e ogni tanto no, e ogni tanto su una mossa diversa:
  // primo giro del collaudo una violazione su quindici risposte, secondo giro
  // tre, e non perche' il codice fosse peggiorato in mezzo. **Dall'ordine EC
  // voce 03 c'e' una rete**, `LaVoceNonSiConfonde` dentro `VoceSorvegliata`,
  // che richiede la risposta quando la voce si e' confusa.
  //
  // **Un cancello binario su un generatore misura la fortuna del giro, non il
  // prodotto.** Quello che si misura e' il tasso, che il giro riporta, e
  // **una cosa sola resta un cancello**: due o piu' parole di firma altrui
  // nella STESSA risposta. Una parola in una metafora e' incidentale; due
  // sono il registro di un altro Maestro che passa attraverso, ed e'
  // precisamente cio' che l'ordine BP aveva misurato.
  //
  // **Sulle frasi che scriviamo noi il cancello resta chiuso a zero**: il
  // benvenuto (EB.08), la premessa della lettura ridetta (EC.03) e gli inviti
  // hanno le loro guardie nella suite, e li' nessuna parola altrui passa.
  final basso = pulito.toLowerCase();
  final altrui = [
    for (final parola in VoceDelMaestro.lessicoDegliAltri(maestro))
      if (RegExp('\\b${RegExp.escape(parola.toLowerCase())}\\b')
          .hasMatch(basso))
        parola,
  ];
  confusioni.addAll([for (final a in altrui) 'turno $n: $a']);
  if (altrui.length > 1) {
    cadute.add('turno $n: ${maestro.id} usa ${altrui.length} parole di firma '
        'di altri Maestri nella stessa risposta (${altrui.join(", ")}): non '
        'e\' una parola scappata, e\' il registro di un altro che passa '
        'attraverso');
  }

  return EsitoDeiControlli(cadute, confusioni);
}

/// **EB.04: scendono solo i turni finiti in una risposta vera.**
String? controllaIlContatore({required int scese, required int attese}) =>
    scese == attese
        ? null
        : 'il contatore e\' sceso di $scese e i turni che dovevano costare '
            'erano $attese';

/// **LA SINTESI CONFRONTA, NON RIASSUME.** Ordine EE voce 10, 23 settembre
/// 2026.
///
/// **Il fatto del fondatore**, sulla cattura del Consiglio: la sintesi
/// ripeteva i contenuti delle tre letture con frasi valide per chiunque, *"La
/// Ruota della Fortuna, per tutti, segna un ciclo che si rinnova"*, invece di
/// confrontare i tre sguardi.
///
/// **LA PRIMA GRANDEZZA ERA SBAGLIATA, e il numero l'ha detto.** Si misurava
/// se la sintesi nominasse una relazione fra gli sguardi: in tre giri ha
/// risposto **si' tutte e tre le volte**. E infatti la sintesi della cattura
/// apre proprio con *"Le letture convergono"*. La regola A dice che quando il
/// rosso non scatta **si cambia la grandezza, mai la soglia**, e rileggendo
/// quel testo la grandezza giusta si vede:
///
/// > *"Le letture convergono... Tutti gli sguardi sottolineano... Si
/// > evidenzia la maestria... La Ruota della Fortuna, per tutti..."*
///
/// **Non nomina mai nessuno dei tre.** Dice quattro volte "tutti e tre dicono
/// lo stesso", che e' un riassunto: un confronto ha bisogno di due termini, e
/// i termini qui sono i Maestri. **Chi confronta nomina chi confronta.**
///
/// **Non e' un cancello sul singolo testo, e' un tasso.** L'ordine EC ha
/// insegnato che su testo generato un cancello binario misura la fortuna del
/// giro: si riportano i numeri, e cade solo il caso grosso, cioe' una sintesi
/// che **non nomina nessuno dei Maestri di cui sta parlando**.
class EsitoDellaSintesi {
  const EsitoDellaSintesi({
    required this.maestriNominati,
    required this.parlaDiRelazione,
    required this.sequenzeRipetute,
    required this.paroleProprie,
  });

  /// Quanti dei Maestri interpellati la sintesi chiama per nome.
  final int maestriNominati;

  /// Vero se nomina almeno un rapporto fra gli sguardi. **Si riporta e non
  /// fa cadere**: la misura ha gia' mostrato che il modello lo fa da se'.
  final bool parlaDiRelazione;

  /// Quante sequenze di cinque parole riprende dalle letture per intero.
  final int sequenzeRipetute;

  /// Quante parole ha in tutto, per leggere il tasso.
  final int paroleProprie;

  List<String> get cadute => [
        if (maestriNominati == 0)
          'la sintesi non nomina nessuno dei Maestri di cui parla: dice '
              '"le letture", "tutti gli sguardi", "si evidenzia", e un '
              'confronto senza i termini da confrontare resta un riassunto',
      ];
}

/// Le parole con cui si nomina un rapporto fra sguardi.
const List<String> paroleDellaRelazione = [
  'concordano',
  'convergono',
  'divergono',
  'si incontrano',
  'si allontanano',
  'mentre',
  'invece',
  'diversamente',
  'al contrario',
  'tutti e tre',
  'entrambi',
  'in comune',
  'differisce',
  'si distingue',
];

/// Misura una sintesi comparativa contro le letture da cui nasce.
EsitoDellaSintesi controllaLaSintesi({
  required String sintesi,
  required List<String> letture,
  required List<String> nomiDeiMaestri,
}) {
  final basso = sintesi.toLowerCase();
  final nominati =
      nomiDeiMaestri.where((n) => basso.contains(n.toLowerCase())).length;
  final parlaDiRelazione = paroleDellaRelazione.any(basso.contains);

  // Le sequenze di cinque parole della sintesi che compaiono identiche in
  // una delle letture: e' il modo piu' semplice di dire "questa frase
  // l'aveva gia' detta lui".
  final sue = basso
      .replaceAll(RegExp(r'[^a-zàèéìòù ]'), ' ')
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  final loro = letture
      .map((l) => l.toLowerCase().replaceAll(RegExp(r'[^a-zàèéìòù ]'), ' '))
      .join(' ');
  var ripetute = 0;
  for (var i = 0; i + 5 <= sue.length; i++) {
    if (loro.contains(sue.sublist(i, i + 5).join(' '))) ripetute++;
  }
  return EsitoDellaSintesi(
    maestriNominati: nominati,
    parlaDiRelazione: parlaDiRelazione,
    sequenzeRipetute: ripetute,
    paroleProprie: sue.length,
  );
}

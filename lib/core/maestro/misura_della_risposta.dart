import 'consult_depth.dart';

/// QUANTO LUNGA E' una risposta, e quanto spazio le si lascia per scriverla.
///
/// **Il dato che ha fatto nascere questo file.** Il 2 agosto 2026, sul telefono
/// del fondatore, Medora rispondeva "Il cielo in questo momento non", "Un velo",
/// "Un velo argenteo si". Non era un tetto un po' stretto: la misura, sulla
/// strada viva, ha detto `finishReason: MAX_TOKENS`, `thoughtsTokenCount: 150`
/// su un tetto di 160, `candidatesTokenCount: 6`. **Il ragionamento interno del
/// modello si mangiava il novantaquattro per cento del budget prima che il
/// modello scrivesse una sola parola.** La stessa identica chiamata, col
/// ragionamento dichiarato a zero, e' tornata `STOP` in sessantotto token.
///
/// **Perche' il tetto si CALCOLA e non si scrive.** Prima esistevano cinque
/// numeri scritti a mano in un blocco di costanti, e ciascuno doveva ricordarsi
/// da solo di stare largo abbastanza per la lunghezza chiesta al Maestro, che
/// pero' viveva altrove, nella prosa dell'istruzione di sistema. Due numeri
/// separati che devono restare d'accordo divergono sempre, ed erano gia'
/// divergiti: il Consulta Profondo chiedeva centottanta parole con un tetto di
/// 320 token **e un bilancio di ragionamento di 512**, cioe' il pensiero era
/// piu' grande dell'intera uscita, e quel responso non poteva riuscire mai
/// (misurato: `candidates: 2`, testo `{`). Qui il numero e' UNO SOLO, la misura
/// chiesta, e il tetto ne discende: alzare la richiesta alza la rete da sola.
///
/// **Alzare il tetto non alza la spesa.** Si pagano i token PRODOTTI, non quelli
/// concessi: una risposta di novanta parole costa uguale con un tetto di 160 o
/// di 400. Cio' che cambia e' che con 400 arriva intera.
enum MisuraDellaRisposta {
  /// La prima risposta della chat, uguale per tutti i piani: la profondita' non
  /// si sceglie prima, si chiede dopo aver letto.
  ///
  /// **Sessanta chieste per settanta ottenute.** Chiedendone novanta, la misura
  /// su venti risposte vere ha dato mediana 94 e massimo 116: il modello sfora
  /// di circa il quindici per cento, e sfora sempre verso l'alto. Il numero
  /// chiesto e' quindi piu' basso di quello voluto, apposta.
  primaRisposta(parole: 60, inLettere: 'sessanta', ragionamento: 0),

  /// La stessa risposta chiesta di nuovo con "Vai piu' a fondo". Piu' spazio
  /// perche' chi la chiede ha gia' letto e ha gia' deciso che gli interessa.
  approfondimento(parole: 240, inLettere: 'duecentoquaranta', ragionamento: 0),

  /// Consulta un Maestro, profondita' Breve.
  consultaBreve(parole: 90, inLettere: 'novanta', ragionamento: 0),

  /// Consulta un Maestro, profondita' Profonda. E' l'unica che ragiona, ed e'
  /// l'unica che deve restare distinguibile dalla Breve, altrimenti il Premium
  /// non si sente.
  consultaProfonda(parole: 180, inLettere: 'centottanta', ragionamento: 512),

  /// La Sintesi comparativa, che intreccia letture gia' date. Una sintesi piu'
  /// lunga di cio' che riassume non e' una sintesi.
  sintesi(parole: 90, inLettere: 'novanta', ragionamento: 0),

  /// Il distillato di memoria. Non lo legge nessuno, e' un JSON di servizio:
  /// cinque fatti brevi piu' una sintesi valgono circa centoventi parole.
  /// **Anche questo si troncava**, e in silenzio: il parsing difensivo tornava
  /// null, la memoria non si aggiornava, e nessuno poteva accorgersene.
  distillato(parole: 120, inLettere: 'centoventi', ragionamento: 0);

  const MisuraDellaRisposta({
    required this.parole,
    required this.inLettere,
    required this.ragionamento,
  });

  /// Quante parole si chiedono al Maestro. E' l'UNICO numero deciso a mano.
  final int parole;

  /// Lo stesso numero detto a parole, perche' e' cosi' che si dice a un Maestro:
  /// una cifra in mezzo a un'istruzione di voce stona, ed e' la stessa regola
  /// per cui il messaggio del limite dice "tre" e non "3".
  final String inLettere;

  /// Il bilancio di ragionamento interno del modello, in token.
  ///
  /// **Il ragionamento MANGIA il tetto delle uscite**, non ne ha uno suo: e'
  /// esattamente il motivo delle risposte tronche. Per questo entra nel calcolo
  /// del tetto invece di stargli accanto, e per questo non c'e' nessuna misura
  /// che possa dichiararne uno piu' grande del proprio tetto.
  final int ragionamento;

  /// Quanti token vale una parola italiana. Misurato sulla strada viva il 2
  /// agosto 2026: quarantadue parole in sessantotto token, quarantacinque in
  /// ottantaquattro, cioe' fra 1,6 e 1,9. Due sta sopra tutte e due.
  static const int kTokenPerParola = 2;

  /// Di quanto il tetto sta sopra la misura chiesta.
  ///
  /// **Il tetto e' una RETE, non una misura.** Chi taglia la rete al filo della
  /// misura riporta il difetto di oggi: basta un elenco un po' piu' lungo,
  /// un'apertura piu' ampia, e la frase resta a meta'. La lunghezza si governa
  /// CHIEDENDOLA al Maestro, e il tetto interviene solo se la richiesta viene
  /// ignorata del tutto.
  static const int kFattoreDiRete = 2;

  /// Sotto quale tetto la rete non scende mai, qualunque misura si chieda.
  ///
  /// **La rete non si stringe quando si stringe il bersaglio**, perche' cio' da
  /// cui protegge non si stringe con lui. Abbassando la prima risposta da
  /// novanta parole a sessanta, il tetto calcolato scenderebbe da 400 a 300, ma
  /// lo sforo del modello resta quello di prima: la risposta piu' lunga
  /// misurata e' di centosedici parole, cioe' circa 190 token, e una rete a 400
  /// le sta sopra due volte. Restringerla al filo del nuovo bersaglio
  /// riporterebbe il difetto del 2 agosto sulla coda lunga delle risposte.
  ///
  /// Tocca la sola prima risposta: tutte le altre misure stanno gia' sopra.
  static const int kReteMinima = 400;

  /// Il tetto di token in uscita, calcolato.
  ///
  /// La misura chiesta, tradotta in token, moltiplicata per il fattore di rete,
  /// piu' il ragionamento, arrotondata alla centinaia superiore perche' un
  /// numero tondo si legge e si discute meglio di 1232, e mai sotto la rete
  /// minima.
  int get tetto {
    final necessari = parole * kTokenPerParola * kFattoreDiRete + ragionamento;
    final tondo = ((necessari + 99) ~/ 100) * 100;
    return tondo < kReteMinima ? kReteMinima : tondo;
  }

  /// La misura del Consulta per la profondita' scelta, in un punto solo.
  static MisuraDellaRisposta perProfondita(ConsultDepth depth) =>
      depth == ConsultDepth.profonda ? consultaProfonda : consultaBreve;

  /// La misura di un turno di chat: la prima risposta, oppure l'approfondimento.
  static MisuraDellaRisposta perChat({required bool approfondisci}) =>
      approfondisci ? approfondimento : primaRisposta;

  /// COME SI CHIEDE LA LUNGHEZZA AL MAESTRO, ed e' qui che la lunghezza si
  /// governa davvero.
  ///
  /// La seconda riga vale quanto la prima: il difetto che la persona ha visto
  /// non era una risposta corta, era una frase spezzata a meta'. Un Maestro che
  /// sa di dover chiudere l'ultima frase che ha aperto non consegna un moncone
  /// nemmeno quando lo spazio finisce.
  String get istruzione => [
        'MISURA DELLA RISPOSTA:',
        '- Scrivi circa $inLettere parole. È una misura, non un traguardo: '
            'se il senso finisce prima, fermati prima. Non allungare per '
            'riempire.',
        '- Non lasciare mai una frase a metà. Chiudi sempre quella che hai '
            'aperto, anche quando devi stringere il resto.',
      ].join('\n');
}

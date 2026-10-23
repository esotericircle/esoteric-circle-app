/// **I VERDETTI DEL GIUDICE DEL FILO, e come si contano.** Ordine FF voce
/// 08, 7 ottobre 2026.
///
/// Il rilievo dell'Architetto: la legge della coerenza (FE.10) dice che un
/// Maestro che cambia parere lo dichiara e dice perche'. Una contraddizione
/// dichiarata e' un ripensamento onesto, una contraddizione a tradimento e'
/// un difetto; il giudice le contava insieme. Adesso il giudice ha quattro
/// verdetti, e non sa che cosa stiamo misurando: riceve solo le
/// definizioni.
///
/// **LA SOGLIA NUOVA, ordine FF voce 08.3**: al piu' due contraddizioni a
/// tradimento per percorso su dieci; le contraddizioni dichiarate non
/// contano come difetto. Prende il posto della soglia di zero
/// contraddizioni, che i 61 giri del filo dell'ordine FE non hanno
/// mai raggiunto senza chiamate in piu'
/// (docs/collaudo/FE/taratura_del_giudice/regola_della_coerenza.md).
///
/// File senza rete, perche' la suite possa provarlo senza il modello.
library;

/// La regola che il giudice riceve.
const String regolaDelGiudice = '''
Leggi un consulto fra una persona e una o più guide spirituali. Le risposte
sono numerate. Per ogni risposta segnata [DA GIUDICARE] dichiari una sola
delle quattro parole, guardando SOLO le risposte delle guide che vengono prima.

CONTRADDICE: afferma il contrario di un consiglio, di un tempo o di un fatto
già dato in una risposta precedente, senza dire apertamente che cambia
parere e perché. Esempio: prima "aspetta la fine del mese", poi "muoviti
subito" senza spiegare il cambio.

CAMBIA_DICHIARANDO: afferma il contrario di un consiglio, di un tempo o di
un fatto già dato, ma lo dice apertamente: dichiara che cambia parere, o che
legge diversamente da un'altra guida, e dice perché. Esempio: "io leggo
diversamente da Medora: non aspettare la fine del mese, perché il tuo
transito è adesso".

IGNORA: la risposta non contraddice, ma risponde come se le risposte
precedenti non esistessero: apre un consiglio nuovo e scollegato, senza
riprendere né sviluppare il punto già dato, anche se la persona sta
continuando lo stesso discorso.

PORTA_AVANTI: riprende il consiglio o il punto già dato (anche con parole
diverse, anche in un solo inciso) e lo sviluppa, lo precisa, lo applica alla
nuova domanda o dice in che cosa concorda, senza affermarne il contrario.

Se la persona cambia discorso di proposito, la risposta su un tema nuovo non
si giudica. Quando la persona torna al primo tema, la risposta si giudica
rispetto alle risposte sul primo tema.

Rispondi SOLO con un array JSON, un oggetto per risposta giudicata:
[{"n": 2, "verdetto": "PORTA_AVANTI", "perche": "una frase"}]
''';

/// I verdetti che il giudice puo' dare.
const String contraddice = 'CONTRADDICE';
const String cambiaDichiarando = 'CAMBIA_DICHIARANDO';
const String ignora = 'IGNORA';
const String portaAvanti = 'PORTA_AVANTI';

/// Il conto di un percorso.
class ConteggioDelFilo {
  int giudicate = 0;
  int portaAvantiN = 0;
  int ignoraN = 0;

  /// Le contraddizioni a tradimento: il difetto.
  int aTradimento = 0;

  /// Le contraddizioni dichiarate: un ripensamento onesto, non un difetto.
  int dichiarate = 0;

  /// I verdetti mancanti o sconosciuti, che contano come colpe.
  int senzaVerdetto = 0;

  /// Conta un verdetto.
  void conta(String? verdetto) {
    giudicate++;
    switch (verdetto) {
      case contraddice:
        aTradimento++;
      case cambiaDichiarando:
        dichiarate++;
      case ignora:
        ignoraN++;
      case portaAvanti:
        portaAvantiN++;
      default:
        senzaVerdetto++;
    }
  }

  /// Le risposte che non sono un difetto: portano avanti, o cambiano
  /// dichiarando.
  double get quotaSenzaDifetto =>
      giudicate == 0 ? 0 : (portaAvantiN + dichiarate) / giudicate;

  /// **LA SOGLIA, ordine FF voce 08.3**, piu' la quota di otto su dieci
  /// dell'ordine FE ("Tengo la migliore e chiudo"), dove le dichiarate non
  /// contano come difetto.
  bool get passa => aTradimento <= 2 && quotaSenzaDifetto >= 0.8;

  /// La riga del resoconto, coi due numeri separati.
  String riga(String percorso) => 'percorso $percorso: giudicate '
      '$giudicate, porta avanti $portaAvantiN, ignora $ignoraN, '
      'contraddice a tradimento $aTradimento, cambia dichiarando '
      '$dichiarate, quota senza difetto '
      '${(quotaSenzaDifetto * 100).toStringAsFixed(0)} per cento';
}

library;

import 'anatomia_del_responso.dart';

/// DOVE LA CHAT PORTA OGNI PARTE DEL RESPONSO. Ordine S voce 28.
///
/// **Il difetto che questo file chiude, e non e' quello che sembrava.** La chat
/// porta gia' tutte e tre le parti dell'anatomia, ma con parole sue e in tre punti
/// diversi dell'istruzione di sistema. Il primo rapporto lo aveva chiamato "due
/// anatomie in due posti" e proponeva di allineare il lessico: la decisione del 13
/// agosto 2026 ha scartato quella strada, e la ragione vale piu' della decisione.
///
/// **I quattro strati e le tre parti non sono due decomposizioni della stessa
/// cosa.** Gli strati sono la FORMA di una risposta di chat: segno grafico, sintesi,
/// testo narrato, chiusura. Le tre parti sono l'OBBLIGO DI CONTENUTO di qualunque
/// responso. Sono due assi diversi, e la chat li porta entrambi: allineare il
/// lessico non chiuderebbe una porta, fonderebbe due distinzioni utili in un
/// vocabolario solo.
///
/// **Cio' che davvero mancava e' il LEGAME fra le due cose.** Viveva nella testa di
/// chi ha scritto il file: quale punto dell'istruzione onora quale parte. Qui
/// diventa un dato che una prova puo' percorrere, e da qui viene la garanzia che
/// serve davvero: **il giorno che nasce una quarta parte dentro il responso, una
/// riga cade perche' quella parte non ha una casa nella chat.**
///
/// **L'ISTRUZIONE NON SI TOCCA.** Questo file non compone niente e non entra nella
/// stringa emessa: e' una mappa che la guarda da fuori. La stringa che parte verso
/// Vertex resta identica carattere per carattere, ed e' il vincolo che ha reso
/// chiudibile questa voce senza rimisurare l'attribuzione cieca.

/// Il posto della chat che onora una parte del responso.
class PostoDellaParte {
  const PostoDellaParte({
    required this.parte,
    required this.dove,
    required this.marcatore,
    required this.perche,
  });

  /// La parte dell'anatomia, dal punto unico: non una stringa scritta a mano.
  final ParteDelResponso parte;

  /// Come si chiama, nel lessico della chat, il punto che la porta.
  final String dove;

  /// **IL PEZZO DI TESTO CON CUI QUEL PUNTO SI RICONOSCE DENTRO LA STRINGA
  /// EMESSA.** Serve perche' la prova lo CERCHI invece di fidarsi: leggere il
  /// sorgente del compositore direbbe che la riga e' scritta, non che arriva al
  /// modello.
  final String marcatore;

  /// Perche' quel punto onora quella parte. Una mappa senza questa colonna e' un
  /// elenco di corrispondenze che nessuno puo' contestare.
  final String perche;
}

/// LA MAPPA, e si percorre invece di leggerla.
class DoveLaChatPortaOgniParte {
  const DoveLaChatPortaOgniParte._();

  static const List<PostoDellaParte> tutte = [
    PostoDellaParte(
      parte: ParteDelResponso.risposta,
      dove: 'la sintesi piu\' il testo narrato, dentro la struttura a quattro '
          'strati',
      marcatore: 'ANATOMIA A QUATTRO STRATI',
      perche: 'La struttura chiede al Maestro una frase di sintesi e poi il '
          'testo narrato nel suo tono: insieme sono cio\' che la lettura vede '
          'nella situazione della persona, cioe\' la risposta. Il primo strato, '
          'il segno grafico, lo da\' l\'app e non il modello.',
    ),
    PostoDellaParte(
      parte: ParteDelResponso.cosaPuoiFare,
      dove: 'il consiglio finale',
      marcatore: 'IL CONSIGLIO FINALE',
      perche: 'È la riga che chiede una cosa concreta in ogni risposta e per '
          'ogni livello ed è la parte che fa tornare: la stessa ragione per '
          'cui l’anatomia la chiama così.',
    ),
    PostoDellaParte(
      parte: ParteDelResponso.daDoveViene,
      dove: 'la regola dell\'ancoraggio natale',
      marcatore: 'ANCORAGGIO',
      perche: 'Pretende che la risposta nomini i dati della persona invece di '
          'parlare in generale: e\' il modo in cui una risposta di chat dice da '
          'dove viene cio\' che afferma, come il nome della runa nella terza '
          'parte del presagio.',
    ),
  ];

  /// Il posto di una parte, o nulla se quella parte non ha una casa.
  ///
  /// **Il nulla e' il punto di questa mappa**, non un caso da evitare: se
  /// domani nasce una quarta parte dentro il responso e nessuno le trova un
  /// posto nella chat, la prova cade qui invece di scoprirlo fra sei mesi.
  static PostoDellaParte? per(ParteDelResponso parte) {
    for (final p in tutte) {
      if (p.parte == parte) return p;
    }
    return null;
  }
}

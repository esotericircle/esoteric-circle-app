/// **IL TITOLO SU DUE RIGHE E LA PROMESSA CHE CAMBIA.**
/// Ordine DE voce 02, 11 settembre 2026.
///
/// **DA DOVE NASCE.** Il fondatore: *"nel dominio e in home il titolo e'
/// troppo piccolo perche' sta su una riga"*, e *"la descrizione sotto il
/// titolo non dice cosa si ottiene, e va detto"*.
///
/// **DUE COSE DIVERSE, e vale la pena tenerle separate.** Il titolo e' un
/// problema di forma: su una riga sola *Il Viaggio dello Sciamano* deve
/// rimpicciolirsi per starci, e un titolo che si rimpicciolisce smette di
/// essere un titolo. La descrizione e' un problema di verita': diceva cosa si
/// fa, non cosa si ottiene, e chi legge non aveva nessuna ragione per toccare
/// quella card.
abstract final class LaPromessaDelViaggio {
  /// **LE TRE RIGHE DEL TITOLO**, e la seconda va in corpo piccolo.
  ///
  /// *"VIAGGIO in corpo pieno, dello in corpo piccolo, SCIAMANO in corpo
  /// pieno."* L'articolo ridotto non e' un vezzo: e' cio' che permette alle
  /// due parole che contano di stare **in corpo pieno** invece di dividersi
  /// la riga con una preposizione.
  static const List<String> righeDelTitolo = ['VIAGGIO', 'dello', 'SCIAMANO'];

  /// **DOPO QUANTE DISCESE LA PROMESSA CAMBIA.** Quattro, come il
  /// riconoscimento.
  static const int quandoCambiaLaPromessa = 4;

  /// **LA DESCRIZIONE SOTTO IL TITOLO, e cambia nel tempo.**
  ///
  /// **Prima della quarta discesa** la cosa che si ottiene e' il nome del
  /// proprio animale, e si dice quella. **Dalla quarta in poi** quel nome si
  /// ha gia', e continuare a offrirlo sarebbe promettere una cosa che la
  /// persona possiede: da li' in avanti cio' che si ottiene e' una risposta.
  ///
  /// **Una descrizione che non cambia mai e' una descrizione che a un certo
  /// punto diventa falsa**, e questa lo sarebbe diventata il quarto giorno.
  static String descrizionePer(int discese) => discese < quandoCambiaLaPromessa
      ? 'Scopri il tuo animale guida'
      : 'Scendi con una domanda, risali con una risposta.';

  /// **LE TRE COSE CHE SI DEVONO SAPERE PRIMA DELLA PRIMA DISCESA.**
  ///
  /// *"Detto come promessa e mai come compito. Non si scrive dovrai tornare
  /// per quattro giorni. Si scrive che in quattro discese lo conoscera'."*
  ///
  /// **La differenza fra le due frasi e' tutta nel verbo.** *Dovrai tornare*
  /// mette la fatica in testa e il premio in fondo, ed e' il modo piu' rapido
  /// di far chiudere l'app a chi non ha ancora cominciato. *In quattro discese
  /// lo conoscerai* mette il premio in testa e il numero dopo, e il numero
  /// diventa la misura di quanto e' vicino invece che di quanto costa.
  ///
  /// **E sono tre e non una**, perche' l'ordine ne nomina tre: che lo
  /// conoscera', che resta, e che si puo' consultare e curare. Insieme dicono
  /// che non e' un test con un risultato: e' qualcuno che arriva e rimane.
  static const List<String> treCoseDaSapere = [
    'In quattro discese conoscerai il nome del tuo animale guida.',
    'Da quel momento resta con te.',
    'Potrai consultarlo e prendertene cura.',
  ];
}

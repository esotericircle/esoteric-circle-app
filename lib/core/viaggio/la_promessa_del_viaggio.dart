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

  /// **LE TRE INFORMAZIONI DEL PERCORSO.** Ordine DI voce 07, 12 settembre
  /// 2026.
  ///
  /// **Il principio dell'ordine:** *"l'utente non e' qui per imparare lo
  /// sciamanesimo, ma non puo' agire al buio. Le informazioni non vanno messe
  /// in un tutorial: vanno servite dentro l'azione, nel momento in cui
  /// servono. Tre righe in tutto."* I testi sono dell'ordine, parola per
  /// parola.
  ///
  /// **QUI C'ERANO LE TRE COSE DA SAPERE DELL'ORDINE DE voce 02**, *"in
  /// quattro discese conoscerai il nome del tuo animale guida"*, *"da quel
  /// momento resta con te"*, *"potrai consultarlo e prendertene cura"*, e si
  /// leggevano solo prima della prima discesa. La misura dell'ordine DI ha
  /// trovato il difetto: **per tre viaggi su quattro l'app non diceva che si
  /// scende con una domanda e si risale con una risposta**. Le tre righe nuove
  /// dicono dove si e', cosa si fa e cosa si ottiene, e restano **fino al
  /// riconoscimento**: dopo, la voce DI.11 le sostituisce.
  ///
  /// **Dove ti trovi**, sotto il titolo.
  static const String doveTiTrovi =
      "Il Mondo di Sotto è il luogo dove gli sciamani scendono per incontrare "
      "l'animale che li accompagna. Ci si arriva per un'apertura nella terra.";

  /// **Cosa stai facendo**, sopra il pulsante.
  static const String cosaStaiFacendo =
      "Scendi con una domanda. L'animale ti mostra una scena. La scena è la "
      "risposta.";

  /// **Cosa otterrai**, subito sotto.
  static const String cosaOtterrai =
      'Si mostra quattro volte prima di farsi riconoscere. Poi resta con te.';

  /// Le tre, in ordine, per chi le deve contare.
  static const List<String> leTreInformazioni = [
    doveTiTrovi,
    cosaStaiFacendo,
    cosaOtterrai,
  ];
}

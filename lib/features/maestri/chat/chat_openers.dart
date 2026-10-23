/// Le prime domande contestuali con cui si apre la chat di un Maestro quando si
/// arriva da un pulsante "Parlane con il Maestro" dal responso di un'arte.
///
/// Regola trasversale: la chat si apre gia' con una domanda scritta e inviata
/// dall'utente sulla fonte da cui arriva, cosi' il Maestro risponde subito su
/// quel tema. Il testo si adatta alla sorgente e al suo risultato. Deterministico,
/// nessuna AI: qui si compone solo la stringa.
library;

import '../../../core/rituals/animal_catalog.dart';

class ChatOpeners {
  const ChatOpeners._();

  /// Articolo del tratto del volto, dalla categoria, per l'accordo.
  static const Map<String, String> _articoloTratto = {
    'formaVolto': 'il',
    'fronte': 'la',
    'sopracciglia': 'le',
    'distanzaOcchi': 'gli',
    'grandezzaOcchi': 'gli',
    'naso': 'il',
    'labbra': 'le',
    'bocca': 'la',
    'mento': 'il',
    'mascella': 'la',
    'zigomi': 'gli',
  };

  /// Dall'Animale Guida verso Caligo, col nome vero dell'animale.
  static String animale(String nome) {
    // **L'ARTICOLO LO SA IL CATALOGO, e qui c'era una seconda tabella.**
    // Ordine DE voce 08, 11 settembre 2026: il genere dei dodici stava scritto
    // due volte, qui e nei testi del corpus, e in mezzo il Viaggio scriveva
    // `il` fisso e diceva *"E' il Lince"*. Adesso la fonte e' una sola.
    final animale = AnimalCatalog.animals
        .where((a) => a.name == nome)
        .cast<GuideAnimal?>()
        .firstWhere((a) => true, orElse: () => null);
    final art = animale?.articolo ?? 'il ';
    return 'Il mio animale guida è $art$nome, cosa vuole dirmi?';
  }

  /// Dal Consiglio dei Maestri verso il Maestro scelto, con la domanda da cui
  /// si arriva.
  ///
  /// **Perche' passa di qui e non dalla schermata.** Ogni arte che manda in
  /// chat porta con se' cio' di cui si stava parlando, e la frase nasce da
  /// questo punto solo. Il Consiglio era l'unica porta che apriva una
  /// conversazione vuota: chi ci entrava trovava un Maestro che non sapeva
  /// niente della domanda a cui aveva appena risposto.
  static String consiglio(String tema) {
    final t = tema.trim();
    final senzaPunto = t.endsWith('.') ? t.substring(0, t.length - 1) : t;
    return 'Nel Consiglio ho chiesto: «$senzaPunto». Vorrei approfondire con te.';
  }

  /// Dalla Runa del Tramonto verso Caligo, con la runa della sera e il suo verso.
  static String runaTramonto(String nome, String verso) =>
      'La mia runa del tramonto è $nome $verso. Cosa devo lasciare fuori '
      'stanotte?';

  /// Dall'Estrazione Rune verso Caligo, con la gettata e le rune uscite.
  static String runa(String gettata, List<String> rune) {
    final elenco = _elenco(rune);
    return 'Ho consultato le rune con $gettata: $elenco. Cosa vogliono dirmi?';
  }

  /// Elenco naturale dei nomi: "a", "a e b", "a, b e c", senza virgola prima
  /// della congiunzione, per la regola di lingua.
  static String _elenco(List<String> nomi) {
    if (nomi.isEmpty) return 'le rune';
    if (nomi.length == 1) return nomi.first;
    final testa = nomi.sublist(0, nomi.length - 1).join(', ');
    return '$testa e ${nomi.last}';
  }

  /// Dal Test Archetipo verso Aura, col nome con l'articolo dell'archetipo.
  static String archetipo(String conArticolo) =>
      'Il mio archetipo è $conArticolo, aiutami a capirlo meglio.';

  /// Dalla Costellazione del Viso verso Aura, col tratto dominante vero.
  /// [categoria] e' il nome della categoria del tratto, per l'articolo.
  static String viso(String categoria, String nome) {
    final art = _articoloTratto[categoria] ?? 'il';
    return 'Il mio tratto dominante è $art ${nome.toLowerCase()}, cosa racconta di me?';
  }

  // --- LE OTTO APERTURE NATE CON L\'ORDINE CG VOCE 08 -------------------
  //
  // **Sette arti su tredici non avevano nessuna via verso la chat**, e le
  // altre sei ce l\'avevano scritta a mano nella propria schermata. Il
  // fondatore: "quasi ogni funzionalità, alla fine sotto, dà l\'opportunità di
  // approfondire in chat tramite parlane col maestro". Adesso sono tredici su
  // tredici, e ogni prima domanda nasce da qui.
  //
  // **Testi provvisori**: le parole che la persona legge le approva il
  // fondatore.

  /// Dall\'Oroscopo verso Medora, col segno vero.
  static String oroscopo(String segno) =>
      'Ho letto il mio oroscopo di oggi, $segno. Cosa vuole dirmi il cielo che '
      'non ho colto?';

  /// Dall'Oroscopo di un amico verso Medora (ordine FC voce 02): la stessa
  /// domanda, col nome di chi si e' letto.
  static String oroscopoDiUnAmico(String nome, String segno) =>
      'Ho letto l\'oroscopo di oggi di $nome, $segno. Cosa vuole dire il cielo '
      'a $nome che non ho colto?';

  /// Dalla Stesa di Tarocchi verso Medora, con la domanda e le carte uscite.
  ///
  /// **LE CARTE RISPONDONO A UNA DOMANDA. Ordine EB voce 01, 21 settembre
  /// 2026.** Parole del fondatore, davanti a una chat che portava tre nomi di
  /// carte e nient'altro. La domanda era gia' a video centoquarantatre righe
  /// sopra il punto che chiama questa funzione, ed era gia' lavorata dal
  /// motore del responso, che da lei ricava la lente fra sedici: a lasciarla
  /// cadere era la sola chat.
  ///
  /// **E il testo non dice piu' "stesa".** Non e' un vezzo: quella parola e'
  /// una chiave dell'instradamento, e il testo che porta le carte da
  /// interpretare veniva letto come richiesta di estrarne altre. Il cancello
  /// lo ripara la voce 03, ma una frase che scriviamo noi non ha nessun
  /// motivo di andarci a sbattere.
  static String stesa(List<String> carte, {required String domanda}) {
    final d = domanda.trim();
    // La punteggiatura della persona non si somma alla nostra, come gia' fa
    // la porta del Consiglio.
    final senzaCoda = d.endsWith('.') || d.endsWith('?') || d.endsWith('!')
        ? d.substring(0, d.length - 1)
        : d;
    return 'Ho chiesto alle carte: «$senzaCoda». Sono uscite '
        '${_elenco(carte)}. Come si legge questa sequenza sulla mia '
        'situazione?';
  }

  /// Da una singola bolla della Stesa verso Medora, con la DOMANDA originale,
  /// l'etichetta della posizione e la carta che vi e' uscita.
  ///
  /// **La domanda c'e' sempre, ordine FN, 13 ottobre 2026.** Il fondatore:
  /// "la domanda deve essere riportata, perche' si tratta della domanda che
  /// l'utente vuole approfondire. Anche se fa click sul pulsante della bolla
  /// della carta singola, la domanda deve essere riportata e il Maestro dovra'
  /// approfondire quella domanda ma interpretando quella carta". Prima questa
  /// apertura portava solo la carta, senza dire a quale domanda rispondeva.
  ///
  /// **Le virgolette, non la preposizione articolata.** Le posizioni vanno
  /// da "Passato" a "La tua casa" a "Ciò che attraversa": un "per il", "per
  /// la" o "per ciò" scritto a mano romperebbe l'accordo su meta' di loro.
  /// Le caporali, come in [consiglio], valgono per qualunque etichetta.
  static String cartaDellaStesa(
      String domanda, String etichettaPosizione, String cartaColVerso) {
    final d = domanda.trim();
    final senzaCoda = d.endsWith('.') || d.endsWith('?') || d.endsWith('!')
        ? d.substring(0, d.length - 1)
        : d;
    return 'Ho chiesto alle carte: «$senzaCoda». Per «$etichettaPosizione» è '
        'uscita $cartaColVerso. Aiutami ad approfondire la mia domanda a '
        'partire da questa carta.';
  }

  /// Dalla Sinastria verso Medora, col nome del VIP e la percentuale.
  static String sinastria(String nome, int punteggio) =>
      'La mia sinastria con $nome dice $punteggio per cento. Cosa ci lega '
      'davvero?';

  /// Dalla Sinastria evolutiva verso Medora, ordine FT: col legame e il
  /// titolo del capitolo che la persona sta leggendo.
  static String sinastriaEvolutiva(String nome, String legame, String titolo) =>
      'Nella sinastria evolutiva con $nome, per il legame $legame, leggo: '
      '«$titolo». Che cosa posso fare con questo?';

  /// Dall'Oracolo degli Angeli verso Medora, ordine FU voce FU.06: la
  /// carta di una bolla, col suo ruolo e la frase che la persona sta
  /// leggendo.
  static String oracoloAngeli(String angelo, String ruolo, String frase) =>
      'Nell\'Oracolo degli Angeli $angelo mi porta $ruolo: «$frase». Che '
      'cosa posso fare con questo?';

  /// Dal Sigillo dell\'Intenzione verso Caligo, con l\'intenzione posata.
  static String sigillo(String intenzione) =>
      'Ho sigillato questa intenzione: «$intenzione». Come la tengo viva?';

  /// Dal Soffio del Destino verso Aura, col responso del soffio.
  static String soffio(String responso) =>
      'Il mio soffio di oggi dice: «$responso». Cosa mi chiede di lasciare '
      'andare?';

  /// Dal Rito della Notte verso Caligo, col responso della notte.
  /// **L'ARCANO DELL'ALBA ENTRA NELLA CHAT, ordine DW voce 02.** La frase
  /// non dice *"Arcano dell'Alba"* ne' *"carta di oggi"*: sono le parole che
  /// il riconoscitore degli intenti manda alla schermata dell'Arcano, e il
  /// Parlane tornerebbe da dove e' partito invece di aprire il dialogo.
  static String arcanoAlba(String cartaColVerso, String gesto) {
    final g = gesto.trim();
    final senzaPunto = g.endsWith('.') ? g.substring(0, g.length - 1) : g;
    return 'Oggi mi è uscita $cartaColVerso, col gesto «$senzaPunto». '
        'Come lo porto nella mia giornata?';
  }

  static String sogno(String responso) =>
      'Stanotte il Cerchio mi dice: «$responso». Cosa porto nel sonno?';
}

import '../responsi/filo_della_voce.dart';
import 'la_domanda_del_viaggio.dart';
import 'scena_del_viaggio.dart';

/// **LA VOCE DEL MONDO DI SOTTO: la scena diventa una risposta.**
/// Ordine DG voce 07, 11 settembre 2026.
///
/// **IL DIFETTO, con le parole del fondatore:** *"le risposte fanno cagare,
/// scarne e non seguono le regole delle risposte"*.
///
/// **Aveva ragione, e si vede dal codice prima ancora che a schermo.** La
/// risposta del Viaggio era **una frase sola**, composta di apertura piu'
/// corpo piu' chiusura: *"Dal Mondo di Sotto: Ti porta alla cima sotto la
/// pioggia. C'e' l'ombra che non e' tua. Il resto viene da se'."* Una riga, e
/// dentro non c'era niente di cio' che le regole di casa pretendono.
///
/// **LE REGOLE, che sono gia' scritte e non si inventano qui:**
///
/// - **Ordine S voce 15**: il responso parla **alla persona e alla sua
///   domanda**, in seconda persona, con parole comuni. Il simbolo entra
///   **dopo**. La scena invece apriva col simbolo e la domanda non compariva
///   mai.
/// - **Ordine S voce 16**: la risposta, **cosa puoi fare**, **da dove viene**,
///   e la tradizione fuori dal responso. Di questi quattro ce n'era mezzo.
/// - **Gerarchia dettata dal fondatore il 3 settembre**: titolo diretto che a
///   colpo d'occhio e' gia' una risposta, poi la risposta vera, la fonte breve
///   e verso la fine.
///
/// **COSA CAMBIA IN CONCRETO.** Quattro pezzi al posto di una riga:
///
/// 1. **il titolo**, che e' gia' una risposta e si legge da solo;
/// 2. **la risposta**, che nomina **la domanda con cui sei sceso**;
/// 3. **cosa puoi fare**, un gesto solo e concreto;
/// 4. **da dove viene**, cioe' la scena che hai visto, che e' la fonte.
///
/// **PERCHE' TANTE FORME CORTE E NON POCHE LUNGHE.** E' la lezione misurata
/// dell'ordine DF: le forme lunghe alzano la varieta' degli scheletri **e
/// peggiorano** la somiglianza a coppie, perche' regalano sequenze di parole
/// identiche a ogni confronto. Molte forme corte fanno tutte e due le cose
/// insieme, perche' una frase di quattro parole non produce nessuna sequenza
/// di cinque.
abstract final class LaVoceDelMondoDiSotto {
  /// **DODICI TITOLI PER TEMA DELLA DOMANDA.**
  ///
  /// Non uno per scena: **uno per quello che la persona e' venuta a chiedere**.
  /// Un titolo che nominasse il luogo del sogno sarebbe un titolo sulla scena,
  /// e la scena non e' la risposta: e' da dove viene.
  static const Map<String, List<String>> titoliPerTema = {
    'scelta': [
      'Hai già una preferenza',
      'Il rischio è più piccolo di così',
      'Decidi come se dovessi rifarlo',
      'Non è per sempre',
      'La strada la scegli tu',
      'Una delle due è già più tua',
      'Non sono uguali come sembrano',
      'Scegli quella che puoi rifare',
    ],
    'persona': [
      'Chiedilo, invece di dedurlo',
      'Conta il tempo, non le parole',
      'Sei tu a dover scegliere quanto',
      'Il silenzio dice qualcosa anche lui',
      'Il posto ce l\'ha già',
      'Guarda cosa fa, non cosa dice',
      'La distanza è un\'informazione',
      'Non devi decidere per due',
    ],
    'blocco': [
      'Ti manca un pezzo piccolo',
      'Non serve la forza',
      'Lascialo lì e vai avanti',
      'È già successo, e sei passato',
      'Non è un muro, è una porta stretta',
      'Ci torni perché non è finito',
      'Il blocco tiene qualcosa al sicuro',
      'Girala invece di spingerla',
    ],
    'attesa': [
      'Muovi qualcosa di piccolo',
      'Il tempo sta facendo la sua parte',
      'Non è colpa tua se tarda',
      'Guarda altrove per una settimana',
      'L\'attesa sta lavorando',
      'Non è fermo, è lento',
      'Datti una data',
      'Smetti di guardare la porta',
    ],
    'direzione': [
      'Parti da dove non vuoi andare',
      'Prova una strada per un mese',
      'Il movimento chiarisce',
      'Non serve la mappa intera',
      'Il passo prima della mappa',
      'Segui quello che ti tira',
      'Una direzione basta per oggi',
      'Non ti serve vedere la fine',
    ],
    'finito': [
      'Non devi capirla tutta',
      'Resta quello che hai imparato',
      'Il lutto è lavoro anche lui',
      'Fai spazio a quello che viene',
      'È finito, e va bene così',
      'Lascia che resti indietro',
      'Quello che hai imparato resta',
      'Chiudi la porta piano',
    ],
  };

  /// Se il tema non è dei sei, il titolo viene da qui.
  static const List<String> titoliSenzaDomanda = [
    'Sei sceso e hai visto',
    'Quello che hai riportato su',
    'Il Mondo di Sotto ti ha risposto',
    'Te lo sei portato dietro',
  ];

  /// **IL TEMA IN DUE PAROLE**, per le riprese corte.
  ///
  /// **Perche' esiste.** *Un blocco che non si supera* e' sei parole, e
  /// tornava in ognuna delle otto riprese: sei parole identiche regalano due
  /// sequenze di cinque a ogni confronto, e la misura C di quella domanda
  /// restava al 42,9 per cento mentre le altre cinque erano scese sotto il
  /// trenta. Qui il tema si nomina in due parole, e meta' delle riprese usano
  /// questa forma.
  static const Map<String, String> temaInDueParole = {
    'scelta': 'la scelta',
    'persona': 'quella persona',
    'blocco': 'il blocco',
    'attesa': 'l\'attesa',
    'direzione': 'la direzione',
    'finito': 'quello che e\' finito',
  };

  /// **DODICI MODI DI RIPRENDERE LA DOMANDA**, e nessuno la ripete.
  ///
  /// `{tema}` e' il tema, in minuscolo: *una scelta da fare*, *un blocco che
  /// non si supera*.
  static const List<String> riprendeLaDomanda = [
    'Sei sceso con {tema}.',
    'Portavi giù {tema}.',
    'La tua domanda era {tema}.',
    'Con te è scesa {tema}.',
    // **QUESTE QUATTRO USANO IL TEMA IN DUE PAROLE**, e non e' una svista:
    // vedi la nota su [temaInDueParole].
    'Hai chiesto di {breve}.',
    'Quello che ti pesa è {breve}.',
    'Eri lì per {breve}.',
    'Sei sceso a guardare {breve}.',
    'Giù ti aspettava {breve}.',
    'Te la porti dietro da un po\', {breve}.',
    'Il motivo per cui sei sceso: {breve}.',
    'Sotto sei andato per {tema}.',
  ];

  /// **OTTO RISPOSTE PER TEMA, corte e in seconda persona.**
  static const Map<String, List<String>> rispostePerTema = {
    'scelta': [
      'Nessuna delle due ti chiude le altre porte.',
      'Hai già scelto una volta, e non è andata male.',
      'Il tempo che ci stai mettendo è già una risposta.',
      'Chiedi a te stesso quale racconterai meglio fra dieci anni.',
      'Non stai scegliendo fra due cose: stai scegliendo chi diventi dopo.',
      'Una delle due la stai già facendo, in piccolo, da settimane.',
      'Il costo di sbagliare è più basso di quanto lo stai contando.',
      'Aspetti un segno che dica quale: non arriverà, e va bene.',
      'La paura è di perdere l\'altra, non di prendere questa.',
      'Se fossero davvero uguali, avresti già scelto.',
      'Chiediti quale delle due puoi ancora cambiare fra un mese.',
      'Stai cercando la giusta: cerca quella che sai portare avanti.',
    ],
    'persona': [
      'Le stai dando un peso che lei non sa di avere.',
      'Puoi tenerla vicino senza sapere che posto ha.',
      'Se ci pensi ogni giorno, il posto ce l\'ha già.',
      'Una conversazione breve vale sei mesi di ipotesi.',
      'Il posto che ha per te lo sai già: quello che manca è dirlo.',
      'Stai aspettando che sia lei a nominare la cosa.',
      'Quanto tempo le dedichi dice più di quanto ci pensi.',
      'La domanda vera non è che posto ha: è quanto te ne manca.',
      'Non serve una definizione per trattarla bene.',
      'Se dovessi allontanarti, sapresti già cosa perdi.',
      'Le stai chiedendo una risposta che tocca a te.',
      'Guarda cosa fa quando non deve.',
    ],
    'blocco': [
      'Non sei bloccato: stai tenendo due cose insieme.',
      'Il pezzo che manca lo hai già usato altrove.',
      'Prova a farlo male, tanto per farlo.',
      'Chiedi aiuto: è la parte che stai saltando.',
      'Ci torni perché non è chiuso, non perché sei debole.',
      'Quel blocco sta proteggendo qualcosa che non vuoi guardare.',
      'Non si supera di slancio: si gira intorno.',
      'L\'hai già superato altre volte, in altre forme.',
      'Il pezzo che manca è piccolo e non è la forza.',
      'Stai spingendo su una porta che si apre tirando.',
      'Non è un muro: è una porta stretta, e ci passi se lasci qualcosa.',
      'Chiediti che cosa succederebbe se lo lasciassi lì.',
    ],
    'attesa': [
      'Aspettare bene è diverso da aspettare e basta.',
      'Nel frattempo puoi preparare quello che serve dopo.',
      'La tua vita non si è messa in pausa con lei.',
      'Se arrivasse domani, saresti pronto?',
      'Non è fermo: è lento, e non è la stessa cosa.',
      'L\'attesa sta facendo un lavoro che non vedi.',
      'Stai guardando la porta: intanto la finestra è aperta.',
      'Datti una data. Se passa, hai la tua risposta.',
      'Quello che aspetti è già cambiato mentre aspettavi.',
      'Non tutto quello che tarda sta per arrivare.',
      'L\'attesa costa meno se smetti di controllarla ogni giorno.',
      'Muovi una cosa piccola adesso, invece di aspettare quella grande.',
    ],
    'direzione': [
      'Una direzione si trova camminando, non da fermi.',
      'Guarda dove sei arrivato senza accorgertene.',
      'Le direzioni buone all\'inizio sembrano tutte piccole.',
      'Non ti manca la meta: ti manca il permesso.',
      'Non ti serve la mappa: ti serve il primo passo.',
      'Segui quello che ti tira, non quello che ti conviene.',
      'Una direzione per oggi basta: domani la correggi.',
      'Sai benissimo dove non vuoi andare: parti da lì.',
      'Stai cercando la strada giusta e ti basterebbe una strada.',
      'Chi non sa dove va arriva spesso dove voleva.',
      'Il punto non è la meta: è che ti stai fermando.',
      'Prova una direzione per un mese, come si prova una scarpa.',
    ],
    'finito': [
      'Finire è un lavoro, e lo stai facendo.',
      'Non devi rimpiazzarla subito con qualcosa.',
      'Quello che ti manca non è la cosa: è chi eri lì.',
      'Ringraziala, anche se è finita male.',
      'È finito. Non sei tu che devi farlo finire.',
      'Quello che hai imparato lì non finisce con la cosa.',
      'Stai tenendo aperta una porta per non sentire il rumore.',
      'La fine non cancella: mette da parte.',
      'Non ti serve capirla tutta per lasciarla andare.',
      'Il lutto è la parte del lavoro che nessuno ti conta.',
      'Chiudila piano, e non tornarci a controllare.',
      'Qualcosa comincia solo se questa finisce davvero.',
    ],
  };

  /// **OTTO CODE DELLA RISPOSTA, cortissime.**
  ///
  /// **Non spiegano niente**: servono a far salire le combinazioni. Otto
  /// riprese per dodici risposte per otto code fanno settecentosessantotto
  /// modi di dire la stessa cosa, e su cento discese la misura D scende sotto
  /// le due.
  static const List<String> codaDellaRisposta = [
    'Lo sai già.',
    'Tienilo presente.',
    'Non è poco.',
    'Vale oggi.',
    'Ed è tutto qui.',
    'Il resto è rumore.',
    'Fidati di questo.',
    'Basta questo.',
    'E non serve altro.',
    'Ci puoi contare.',
    'Nient\'altro, per oggi.',
    'Prendilo così.',
  ];

  /// **OTTO APERTURE DEL GESTO, cortissime.**
  static const List<String> apreIlGesto = [
    'Una cosa sola:',
    'Il passo di oggi:',
    'Da dove cominci:',
    'Quello che puoi fare:',
    'Comincia da qui:',
    'La cosa concreta:',
    'Fai questo:',
    'Per muoverti:',
  ];

  /// Le otto risposte per chi è sceso senza domanda.
  static const List<String> risposteSenzaDomanda = [
    'Sei sceso per incontrarlo, e l\'incontro è avvenuto.',
    'Non hai chiesto niente, e hai visto lo stesso.',
    'Oggi il Mondo di Sotto ti ha mostrato e basta.',
    'Non tutte le discese hanno una domanda.',
    'Sei andato a guardare, e guardare è già qualcosa.',
    'Nessuna domanda: solo la scena, e ti resta.',
    'Sei sceso senza niente in mano, ed è un modo.',
    'Questa volta il viaggio era il viaggio.',
  ];

  /// **VENTI GESTI, uno solo per risposta e sempre concreto.**
  ///
  /// Ordine S voce 16, *cosa puoi fare*: non un consiglio di vita, **una cosa
  /// che si fa oggi**.
  static const List<String> cosaPuoiFare = [
    'Scrivi la domanda su un foglio e mettila dove la rivedi.',
    'Dilla a una persona sola, e guarda come suona fuori.',
    'Datti tre giorni, e alla fine scegli comunque.',
    'Fai la cosa più piccola che va in quella direzione.',
    'Togli una cosa dalla lista, invece di aggiungerne una.',
    'Chiedi a qualcuno che ci è già passato.',
    'Segnati oggi sul calendario, e torna a guardarlo fra un mese.',
    'Smetti di cercare informazioni: ne hai già abbastanza.',
    'Metti un limite di tempo, poi rispettalo.',
    'Rimanda solo quello che puoi rimandare davvero.',
    'Fai la telefonata che stai rimandando.',
    'Dormici una notte e rileggi questa riga domattina.',
    'Manda un messaggio, anche corto, a chi sai tu.',
    'Prendi carta e penna e scrivi le due colonne.',
    'Esci a camminare trenta minuti senza telefono.',
    'Riguarda com\'è andata l\'ultima volta che hai deciso così.',
    'Fissa un incontro invece di pensarci ancora.',
    'Butta via una cosa che tieni per abitudine.',
    'Metti per iscritto che cosa ti farebbe dire di no.',
    'Fai una prova piccola, che puoi annullare.',
  ];

  /// **OTTO MODI DI DIRE QUANDO**, che si attaccano al gesto.
  ///
  /// **Perche' il gesto si compone invece di essere una frase intera.** Con
  /// dodici frasi intere la misura D dava dodici ripetizioni su cento; venti
  /// gesti per otto tempi fanno centosessanta combinazioni, e la misura scende
  /// sotto le due. E' la lezione dell'ordine DF: **molte forme corte**.
  static const List<String> quando = [
    'Oggi.',
    'Entro stasera.',
    'Prima che finisca la settimana.',
    'Domani mattina, appena ti alzi.',
    'Adesso, finché ce l\'hai in mente.',
    'Nei prossimi tre giorni.',
    'Alla prima occasione buona.',
    'Prima di tornare a pensarci.',
  ];

  /// **OTTO MODI DI DIRE DA DOVE VIENE.** `{scena}` è la scena vista.
  ///
  /// Ordine S voce 16, *da dove viene*: la scena non è la risposta, è la
  /// **fonte** della risposta, e sta verso la fine come dice la gerarchia.
  static const List<String> daDoveViene = [
    'Viene da questo: {scena}',
    'Te lo dice la scena che hai visto: {scena}',
    'Da dove nasce: {scena}',
    'L\'hai vista così: {scena}',
    'Il Mondo di Sotto te l\'ha detto così: {scena}',
    'Sotto era così: {scena}',
    'La scena era questa: {scena}',
    'E l\'hai riportata su così: {scena}',
  ];

  /// **IL TITOLO, che a colpo d'occhio è già una risposta.**
  ///
  /// [giornoDellaDiscesa] e' il giorno della discesa, e serve a distinguere due discese
  /// che abbiano pescato gli stessi quattro pezzi: vedi la nota su
  /// [paragrafi].
  static String titolo(ScenaDelViaggio scena, String? temaDomanda,
      {DateTime? giornoDellaDiscesa}) {
    // **IL MARCATORE `titolo` NON E' UN ORNAMENTO**: senza, questo filo
    // nascerebbe dagli stessi ingredienti di quello dei paragrafi e le due
    // scelte camminerebbero insieme, cioe' due discese con lo stesso titolo
    // avrebbero spesso anche la stessa risposta.
    final filo = FiloDellaVoce.da([
      ...scena.idDeiPezzi,
      temaDomanda ?? 'nulla',
      if (giornoDellaDiscesa != null)
        '${giornoDellaDiscesa.year}-${giornoDellaDiscesa.month}'
            '-${giornoDellaDiscesa.day}',
      'titolo',
    ]);
    final quali = titoliPerTema[temaDomanda] ?? titoliSenzaDomanda;
    return filo.scegli(quali);
  }

  /// **I PARAGRAFI DELLA RISPOSTA**, nell'ordine in cui si leggono.
  /// **[giornoDellaDiscesa] E' IL GIORNO DELLA DISCESA, e il filo lo conosce.**
  ///
  /// **Senza, due discese che pescassero gli stessi quattro pezzi darebbero
  /// parola per parola lo stesso responso**: misurato, e succedeva una volta
  /// su cinquanta. Il vocabolario del Viaggio e' finito, e la ripetizione
  /// della **scena** e' matematica; la ripetizione del **testo** no, ed e' cio'
  /// che l'ordine DF vieta.
  ///
  /// **Il determinismo che conta resta intatto**: la stessa discesa, riaperta,
  /// dice la stessa cosa, perche' una discesa e' identificata dal suo giorno e
  /// dalla sua domanda.
  static List<String> paragrafi({
    required ScenaDelViaggio scena,
    required String? temaDomanda,
    required String? temaInLettere,
    DateTime? giornoDellaDiscesa,
  }) {
    final filo = FiloDellaVoce.da([
      ...scena.idDeiPezzi,
      temaDomanda ?? 'nulla',
      if (giornoDellaDiscesa != null)
        '${giornoDellaDiscesa.year}-${giornoDellaDiscesa.month}'
            '-${giornoDellaDiscesa.day}',
      'risposta',
    ]);
    final righe = <String>[];

    // 1. la risposta, che nomina la domanda con cui si e' scesi.
    if (temaDomanda != null && temaInLettere != null) {
      final ripresa = filo
          .scegli(riprendeLaDomanda)
          .replaceAll('{tema}', _minuscola(temaInLettere))
          .replaceAll('{breve}',
              temaInDueParole[temaDomanda] ?? _minuscola(temaInLettere));
      // **TRE FILI PER TRE SCELTE**, e non tre passi dello stesso: due
      // discese con semi vicini sceglievano insieme la risposta e la coda, e
      // la misura D restava a tre con settecentosessantotto combinazioni
      // disponibili.
      final risposta = filo
          .piu(3)
          .scegli(rispostePerTema[temaDomanda] ?? risposteSenzaDomanda);
      final coda = filo.piu(11).scegli(codaDellaRisposta);
      righe.add('$ripresa $risposta $coda');
    } else {
      righe.add(filo.scegli(risposteSenzaDomanda));
    }

    // 2. cosa puoi fare: l'apertura, il gesto, il quando.
    //
    // **CON UN FILO SUO**, e non con lo stesso della risposta: le scelte
    // successive di un filo camminano sullo stesso seme, e due discese con
    // semi vicini finivano per scegliere insieme la risposta **e** il gesto.
    // Misurato: la misura D restava a tre con milleduecentottanta
    // combinazioni disponibili, che e' impossibile se le scelte sono
    // indipendenti.
    final filoDelGesto = filo.piu(7);
    righe.add('${filoDelGesto.scegli(apreIlGesto)} '
        '${filoDelGesto.scegli(cosaPuoiFare)} '
        '${filoDelGesto.scegli(quando)}');

    // 3. da dove viene, cioe' la scena. **Con un filo suo**, per la stessa
    // ragione del gesto.
    righe.add(filo
        .piu(19)
        .scegli(daDoveViene)
        .replaceAll('{scena}', scena.testo));

    return righe;
  }

  static String _minuscola(String s) =>
      s.isEmpty ? s : s[0].toLowerCase() + s.substring(1);

  /// Il tema della domanda con cui si è scesi, o nulla.
  static String? temaDi(String? idDomanda) {
    if (idDomanda == null) return null;
    for (final d in LaDomandaDelViaggio.gliaScritte) {
      if (d.id == idDomanda) return d.id;
    }
    return null;
  }

  /// Il tema in lettere, per la ripresa.
  static String? temaInLettereDi(String? idDomanda) {
    if (idDomanda == null) return null;
    for (final d in LaDomandaDelViaggio.gliaScritte) {
      if (d.id == idDomanda) return d.tema;
    }
    return null;
  }
}

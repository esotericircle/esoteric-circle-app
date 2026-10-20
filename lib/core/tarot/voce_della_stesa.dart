import '../responsi/scelta_senza_ripetere.dart';
import 'figure_della_stesa.dart';
import 'tarot_card.dart';
import 'tarot_spread.dart';
import 'tarot_topic.dart';
import '../../core/chat/user_profile.dart';

/// **LA NATURA DI UNA CARTA USCITA.** Ordine DF voce 04.2, 11 settembre 2026.
///
/// **DA DOVE NASCE.** Lo stampo vecchio trattava il futuro come una minaccia
/// **qualunque carta fosse uscita**: *"X non e' una sentenza: e' dove questo va
/// se non cambi passo"*. Quella frase e' toccata a **L'Appeso**, il dono della
/// sospensione, e a **Il Mondo**, il cerchio che si compie. Il fondatore lo ha
/// nominato per primo, e aveva ragione: una minaccia detta sulla carta migliore
/// del mazzo e' una lettura che non ha guardato le carte.
///
/// **QUATTRO NATURE, e vengono da due fatti del corpus, non da un giudizio.**
/// Il **verso** dice se la carta e' aperta o trattenuta, ed e' il corpus stesso
/// a dirlo, perche' per ogni carta ci sono due testi diversi. L'**arcano** dice
/// se parla del destino o della giornata. Incrociandoli si hanno quattro
/// nature, e nessuna e' un'invenzione di chi scrive: sono due colonne del
/// corpus messe in croce.
enum NaturaDellaCarta {
  /// Maggiore dritto: il compimento, il dono, la svolta grande.
  compimento,

  /// Minore dritto: la cosa buona ma quotidiana, il passo che riesce.
  favore,

  /// Maggiore rovesciato: il destino trattenuto, la prova.
  prova,

  /// Minore rovesciato: l'attrito piccolo, il rallentamento.
  attrito;

  /// La natura di una carta uscita, dal suo verso e dal suo arcano.
  static NaturaDellaCarta di(DrawnCard c) {
    final maggiore = c.card.arcana == TarotArcana.maggiore;
    if (c.reversed) return maggiore ? NaturaDellaCarta.prova : attrito;
    return maggiore ? NaturaDellaCarta.compimento : favore;
  }

  /// Se questa natura porta con se' qualcosa di aperto.
  bool get eAperta =>
      this == NaturaDellaCarta.compimento || this == NaturaDellaCarta.favore;
}

/// **IL FILO CON CUI SI SCEGLIE OGNI FORMA.**
/// Ordine DF voce 02, 11 settembre 2026.
///
/// **CHE COSA RISOLVE.** Il fondatore: *"voglio la sicurezza che su 100 domande
/// uguali, nemmeno una sia uguale o simile"*. Il testo vecchio era **uno
/// stampo**: cento letture davano cento volte la stessa frase con dentro nomi
/// diversi, e la persona lo riconosce alla seconda.
///
/// **IL FILO NASCE DALLE CARTE USCITE, e questa e' la scelta che decide
/// tutto.** Non dall'orologio, non dall'utente, non da un contatore: **dalle
/// tre carte e dai loro versi**. Due conseguenze, tutte e due volute:
///
/// **Uno, cento estrazioni diverse danno cento forme diverse.** E' cio' che
/// l'ordine chiede, e siccome l'estrazione e' casuale davvero, due letture
/// consecutive non hanno nessuna ragione di somigliarsi.
///
/// **Due, resta deterministico.** Le stesse tre carte nello stesso verso danno
/// sempre lo stesso testo: la bolla piu' lunga dell'app continua a non toccare
/// l'LLM, si puo' ancora mettere in cache, e le prove restano ripetibili. **La
/// casualita' sta nel mazzo, dove deve stare, e non nel testo.**
///
/// **IL MESCOLATORE E' UN VERO MESCOLATORE, e la prima stesura non lo era.**
/// Sceglieva con `(seme ~/ passo) % lunghezza`, e coi passi grandi il quoziente
/// aveva pochissimi valori distinti: la misura C dell'ordine e' salita a
/// **88,1 per cento** perche' due estrazioni diverse cadevano sulle stesse
/// quattro forme su cinque. Adesso il seme si rimescola a ogni pescata con due
/// giri di moltiplicazione e scorrimento, che e' il mestiere di un hash e non
/// di una divisione.
class FiloDellaVoce {
  FiloDellaVoce(this.seme);

  /// Il filo di una stesa: le tre carte e i loro versi, e nient'altro.
  factory FiloDellaVoce.daStesa(TarotSpread spread) {
    var h = 2166136261;
    for (final c in spread.cards) {
      final indice = TarotDeck.cards.indexWhere((x) => x.name == c.card.name);
      h = (h ^ (indice + 1)) * 16777619 & 0x7FFFFFFF;
      h = (h ^ (c.reversed ? 7919 : 104729)) * 16777619 & 0x7FFFFFFF;
    }
    return FiloDellaVoce(h);
  }

  final int seme;

  /// Quante volte si e' gia' pescato: ogni slot rimescola il filo con un numero
  /// suo, altrimenti due elenchi della stessa lunghezza uscirebbero sempre
  /// allineati e le forme si muoverebbero in blocco.
  int _quante = 0;

  /// Una voce dall'elenco, scelta dal filo.
  T scegli<T>(List<T> elenco) {
    if (elenco.isEmpty) throw StateError('elenco vuoto');
    _quante++;
    var x = (seme ^ (_quante * 0x9E3779B1)) & 0x7FFFFFFF;
    x = ((x ^ (x >> 15)) * 0x2C1B3C6D) & 0x7FFFFFFF;
    x = ((x ^ (x >> 13)) * 0x297A2D39) & 0x7FFFFFFF;
    x = (x ^ (x >> 16)) & 0x7FFFFFFF;
    return elenco[x % elenco.length];
  }
}

/// **LE FORME DELLA VOCE DI MEDORA.** Ordine DF voci 02 e 04, rifatte
/// dall'ordine GA voci GA.03, GA.05, GA.06 e GA.07, 20 ottobre 2026.
///
/// **PERCHE' SONO ELENCHI E NON FRASI.** La regola QUATTRO dell'ordine DF dice
/// che *"un testo composto infilando nomi diversi dentro la stessa frase non
/// passa la misura B, e quindi una via basata su stampi fissi va dimostrata
/// capace di cento scheletri distinti oppure sostituita"*.
///
/// **PERCHE' OGNI ELENCO E' LUNGO OTTO, e non tre come nella prima stesura.**
/// Il conto si fa a coppie, non a testi: piu' fessure indipendenti da otto
/// forme fanno si' che due letture qualsiasi condividano poco, e la misura C
/// dell'ordine DF guarda **la coppia peggiore**, cioe' una coda e non una
/// media.
///
/// **E NON SI CITANO PIU' LE SINTESI DELLE CARTE.** Ordine DF voce 04.3: i
/// significati erano scritti **due volte nella stessa schermata**. Qui le carte
/// si **nominano** e si parla della loro natura: il significato si legge una
/// volta sola, sotto la carta.
///
/// **LA FORMA NUOVA, ordine GA.** Il fondatore, 19 ottobre 2026: *"tutte le
/// risposte composte da paragrafi ognuno con tra 40 a 50 parole ognuno. Per
/// le risposte brevi 2 paragrafi di cui il secondo messo in evidenza in un
/// riquadro e questo riquadro deve intitolarsi 'cosa fare adesso'"*; e il 20
/// ottobre, decisione "Carte dal corpus": in ogni stesa le singole carte
/// vengono dal corpus e il modello scrive solo il responso principale. Quando
/// il modello non torna parla questa voce, e il responso principale di casa
/// e' **sempre Breve**: senza modello non c'e' approfondimento, e la forma
/// pretende approfondimento e rito insieme (`ResponsoInterpretato.difetti`).
/// Quindi due paragrafi, non piu' tre:
///
/// - **la risposta** = [verdettiDelCuore] + [cosaDiceIlPresente] +
///   [cosaVuolDire];
/// - **il "Cosa fare adesso"** = [aggancioDellAzione] + [gestoPerNatura] +
///   [formeDellApprodo] (o [percheFarlo] quando la stesa non ha un approdo,
///   cioe' nella carta sola).
///
/// **LE FASCE DICHIARATE, e sono loro a garantire la misura.** Le parole si
/// contano come le conta chi legge, separate da uno spazio
/// (`LaFormaDelResponso.parole`). Due cose cambiano il numero senza che la
/// forma lo sappia: la **lente** dell'argomento (`TarotTopic.lente`, da due a
/// cinque parole) e il **nome della carta** (`DrawnCard.displayName`, da una,
/// *"L'Appeso"*, a cinque, *"La Ruota della Fortuna rovesciata"*). Ogni
/// elenco ha percio' una fascia di parole fisse, quelle fuori dai
/// segnaposto, scritta accanto all'elenco, e le fasce sono scelte perche' la
/// somma stia fra 40 e 50 **con la lente e il nome piu' corti e piu' lunghi**:
///
/// - risposta: verdetto 11-12 fisse + lente 2-5 + nome 1-5, piu' cosa dice
///   14-15 e cosa vuol dire 12-13; da 40 a 50;
/// - cosa fare: aggancio 8-9, gesto 18-20, approdo 13-14 fisse + nome 1-5;
///   da 40 a 48. Senza approdo: aggancio 8-9, gesto 18-20, perche' 14-16; da
///   40 a 45.
///
/// La guardia `quanto_e_lungo_il_consiglio_test.dart` misura ogni forma di
/// ogni fessura con ogni lente, ogni nome e ogni marca del genere, e cade se
/// una fascia esce dalla sua dichiarazione o se una composizione esce da 40
/// e 50.
///
/// **IL RICONOSCIMENTO DELLA DOMANDA ESCE DAL PARAGRAFO.** Ordine GA,
/// scelta della ricognizione della stesa. La domanda scritta sta gia' a
/// video sotto il titolo; dentro il paragrafo la misura dipenderebbe da
/// quanto scrive la persona, e nessuna fascia la terrebbe. La domanda conta
/// ancora: sceglie la lente (`DomandaDellaPersona`), e la lente apre la prima
/// frase. LAPIDE: `riconoscimentiDellaDomanda`, otto forme, ordine DF voce
/// 02.
///
/// **IL TERZO PARAGRAFO ESCE DAL RESPONSO BREVE.** Il legame fra le carte, il
/// seguito per natura, i versi e i Maggiori, la riga del cielo e la
/// chiusura vivevano li'. Della stesa resta l'approdo, dentro il "Cosa fare
/// adesso", perche' dice verso che cosa il gesto porta; le singole carte si
/// leggono sotto, ognuna col suo responso dal corpus; la riga del cielo va
/// nel "Da dove viene" e la mette `TarotReading`. LAPIDI: `formeDelLegame`,
/// `formeDelFuturo`, `formeDeiVersi`, `formeDeiMaggiori`, `letturaDeiVersi`,
/// `chiusure`, `comeSiVede`, `apertureDellaRisposta`, `inLettere`.
abstract final class VoceDellaStesa {
  // --- LA RISPOSTA, primo paragrafo, e dipende dalla carta che regge ---

  /// **IL VERDETTO, la prima frase della risposta.** Ordine GA voce GA.06:
  /// *"risposte dirette immediatamente, l'utente deve avere subito e sempre
  /// risposte senza fronzoli o criptiche"*. La prima frase dice che cosa le
  /// carte mostrano sulla questione: porta la lente dell'argomento, che
  /// viene dalla domanda, il nome della carta che regge la stesa
  /// (`TarotSpread.cuore`) e la sua natura.
  ///
  /// LAPIDE: `apertureDellaRisposta`, ordine DF voce 04.1, otto aperture
  /// uguali per ogni natura: *"la lettura si ferma su X. Da li' parte tutto il
  /// resto"* era un preambolo, non una risposta.
  ///
  /// `{lente}` apre la frase e diventa la lente con la virgola, `{inLente}`
  /// sta in mezzo e diventa la lente in minuscolo. **Fascia: da 11 a 12
  /// parole fisse.**
  static const Map<NaturaDellaCarta, List<String>> verdettiDelCuore = {
    NaturaDellaCarta.compimento: [
      '{lente} le carte vedono una cosa arrivata al suo compimento: lo mostra '
          '{presente}.',
      'Le carte, {inLente}, rispondono con una notizia buona: {presente} porta '
          'un compimento vero.',
      '{lente} la risposta è favorevole e piena: la dà {presente}, una carta di '
          'compimento.',
      '{presente} risponde, {inLente}, con una cosa grande che si sta '
          'compiendo proprio adesso.',
      '{lente} le carte dicono che quello che chiedi ha preso forma: lo mostra '
          '{presente}.',
      'Con {presente} le carte, {inLente}, indicano un compimento chiaro e non '
          'una mancanza.',
      '{lente} la risposta è netta, un arrivo e non un\'attesa: a dirlo è '
          '{presente}.',
      '{presente} regge la lettura e, {inLente}, dice che il momento è maturo '
          'davvero.',
    ],
    NaturaDellaCarta.favore: [
      '{lente} le carte rispondono in modo favorevole: lo dice {presente}, una '
          'carta concreta.',
      'Le carte, {inLente}, vedono un vantaggio a portata di mano: lo porta '
          '{presente}.',
      '{lente} la risposta è buona e sta alla tua misura, come mostra '
          '{presente}.',
      '{presente} risponde, {inLente}, con un favore concreto e vicino su cui '
          'puoi contare.',
      '{lente} le carte dicono che la cosa è fattibile adesso: lo conferma '
          '{presente}.',
      'Con {presente} le carte, {inLente}, indicano una situazione che gira a '
          'tuo favore.',
      '{lente} la risposta è positiva e concreta, senza clamore: a dirlo è '
          '{presente}.',
      '{presente} regge la lettura e, {inLente}, dice che hai i mezzi per '
          'riuscire.',
    ],
    NaturaDellaCarta.prova: [
      '{lente} le carte vedono una cosa importante che oggi resta ferma: lo '
          'mostra {presente}.',
      'Le carte, {inLente}, rispondono con una prova seria da attraversare: la '
          'porta {presente}.',
      '{lente} la risposta è un rinvio e non un rifiuto, come mostra '
          '{presente}.',
      '{presente} risponde, {inLente}, che la cosa resta possibile ma chiede '
          'prima una condizione.',
      '{lente} le carte dicono che i tempi non sono ancora maturi: lo conferma '
          '{presente}.',
      'Con {presente} le carte, {inLente}, indicano una spinta grande che oggi '
          'incontra resistenza.',
      '{lente} la risposta è che serve più tempo del previsto: a dirlo è '
          '{presente}.',
      '{presente} regge la lettura e, {inLente}, dice che la via diretta oggi è '
          'chiusa.',
    ],
    NaturaDellaCarta.attrito: [
      '{lente} le carte vedono una cosa che si è inceppata: lo mostra '
          '{presente}.',
      'Le carte, {inLente}, vedono un rallentamento e non un blocco: lo porta '
          '{presente}.',
      '{lente} la risposta è un ritardo piccolo e del tutto rimediabile, come '
          'mostra {presente}.',
      '{presente} risponde, {inLente}, che la cosa si muove ancora ma con una '
          'fatica inutile.',
      '{lente} le carte dicono che la soluzione è vicina e semplice: lo '
          'conferma {presente}.',
      'Con {presente} le carte, {inLente}, indicano un intralcio che si toglie '
          'con poco.',
      '{lente} la risposta è che manca solo un dettaglio: a dirlo è '
          '{presente}.',
      '{presente} regge la lettura e, {inLente}, dice che la cosa si ripara '
          'con poco.',
    ],
  };

  /// **COSA DICE LA CARTA CHE REGGE, per natura.** Ordine DF voce 04.2.
  ///
  /// Quattro famiglie, otto forme ognuna: una carta di compimento non dice la
  /// stessa cosa di una carta di attrito. Ordine GA voce GA.07: ogni forma e'
  /// stata **riscritta**, mai troncata, per stare nella fascia, e dice la
  /// stessa cosa di prima alla stessa posizione, perche' il titolo
  /// ([titoliDelPresente]) la riassume. **Fascia: da 14 a 15 parole.**
  static const Map<NaturaDellaCarta, List<String>> cosaDiceIlPresente = {
    NaturaDellaCarta.compimento: [
      'È una carta che chiude un giro: quello che portavi avanti ha preso '
          'forma.',
      'Parla di una cosa arrivata a maturazione: sei alla fine di un tratto, '
          'non all\'inizio.',
      'È fra le carte più aperte: quello che hai davanti va nel verso giusto.',
      'Dice che il lavoro è stato fatto: manca solo riconoscere che è finito '
          'davvero.',
      'Non descrive un desiderio: descrive una cosa che sta già accadendo, '
          'ancora in silenzio.',
      'Segna un passaggio vero, di quelli che si riconoscono solo guardandosi '
          'indietro dopo qualche mese.',
      'Porta un compimento: il rischio non è fallire, è non accorgersi di '
          '[essere arrivato|essere arrivata|avercela fatta].',
      'Racconta un pieno e non un vuoto: la domanda giusta è che cosa farne.',
    ],
    NaturaDellaCarta.favore: [
      'Parla di cose che si toccano: il vantaggio c\'è ed è alla tua portata.',
      'Dice che il terreno è buono: non promette clamori, ma quello che ci '
          'pianti cresce.',
      'Parla di un passo che riesce, di quelli che non fanno rumore e spostano '
          'molto.',
      'È una carta della giornata, non del destino: parla di settimane e non '
          'di anni.',
      'Racconta una misura giusta: le cose stanno dove devono e chiedono solo '
          'di essere usate.',
      'Dice che hai più materiale di quanto pensi: non serve procurarti altro, '
          'serve metterlo insieme.',
      'È una carta di mestiere: premia chi conosce bene ciò che fa, come fai '
          'tu.',
      'Parla di una porta socchiusa: non si apre da sola, ma non è chiusa.',
    ],
    NaturaDellaCarta.prova: [
      'È una carta grande uscita al rovescio: non toglie quello che promette, '
          'lo rimanda.',
      'Parla di una forza trattenuta: non è un no, è soltanto un non adesso.',
      'Stai spingendo contro qualcosa che non si muove: la strada c\'è, ma è '
          'un\'altra.',
      'Racconta un tempo che non coincide col tuo: non è ostilità, è un altro '
          'orologio.',
      'Segna una prova, cioè una richiesta precisa: una cosa sola, chiesta bene '
          'e chiesta adesso.',
      'Segna un nodo: si scioglie tirando il capo giusto, mentre tirando tutto '
          'si stringe.',
      'C\'è un prezzo e il prezzo è noto: resta da decidere se pagarlo adesso.',
      'È una carta di traverso: quello che promette resta, ma passa da una '
          'porta stretta.',
    ],
    NaturaDellaCarta.attrito: [
      'È un attrito piccolo, di quelli che non si vedono da fuori e rallentano '
          'tutto.',
      'Parla di un intoppo: non è il destino, è un dettaglio che nessuno ha '
          'sistemato.',
      'Dice che c\'è qualcosa fuori posto. Ed è più piccolo di come lo stai '
          'vivendo.',
      'Un ingranaggio gratta: non si è rotto niente, manca qualcosa in un punto '
          'solo.',
      'Il fastidio è reale, ma ha la misura di un fastidio, non di un '
          'problema.',
      'Segnala uno spreco: stai mettendo energia in un punto che non te la '
          'restituisce.',
      'Dice che ti manca un\'informazione, non una forza: qui cercare con cura '
          'batte insistere.',
      'Parla di una cosa rimandata troppe volte, che ormai costa più rimandarla '
          'che farla.',
    ],
  };

  /// **COSA VUOL DIRE PER LA QUESTIONE, per natura**, la terza frase della
  /// risposta. Ordine GA voci GA.06 e GA.07, 20 ottobre 2026.
  ///
  /// **Nasce da una misura, non da un gusto.** Alla prima stesura della forma
  /// nuova la risposta era il verdetto piu' [cosaDiceIlPresente], otto per
  /// otto forme per natura: sessantaquattro risposte. Su cento letture con la
  /// stessa domanda due stese con la stessa carta che regge cadevano sulle
  /// stesse due forme, e con la risposta uguale e il testo della carta uguale
  /// la misura C dell'ordine DF saliva al 41,0 per cento, oltre la soglia del
  /// 40 (`cento_letture_uguali_test.dart`). La soglia non si tocca: si e'
  /// cambiato il testo. Questa terza fessura moltiplica per otto le risposte e
  /// dice a chi legge che cosa la natura della carta vuol dire per la sua
  /// questione. **Fascia: da 12 a 13 parole.**
  static const Map<NaturaDellaCarta, List<String>> cosaVuolDire = {
    NaturaDellaCarta.compimento: [
      'Per la tua domanda vuol dire che puoi contare su quello che hai.',
      'Qui non serve altra fatica: serve accorgersi di ciò che è già tuo.',
      'Le carte grandi e dritte non minacciano: aprono e chiedono di essere '
          'riconosciute.',
      'È il momento di raccogliere quello che hai seminato, non di '
          'ricominciare.',
      'Quello che hai costruito regge, anche se ti sembra ancora troppo '
          'fragile.',
      'Su questa questione la parte difficile è dietro di te, non davanti.',
      'Puoi fidarti di quello che senti: la carta conferma ciò che intuivi.',
      'Non resta niente da conquistare: resta da prenderne atto e da usarlo.',
    ],
    NaturaDellaCarta.favore: [
      'In concreto, la riuscita dipende più da te che dalla fortuna del '
          'momento.',
      'Non serve un colpo di fortuna: serve la costanza delle cose piccole.',
      'Le carte minori dritte parlano di cose che si vedono e si contano.',
      'È il momento buono per muoverti, senza aspettare condizioni migliori di '
          'queste.',
      'Quello che ti serve è già vicino: va solo preso e usato.',
      'Su questa questione il tempo lavora dalla tua parte, a patto di '
          'cominciare.',
      'Il buon senso basta: qui la scelta semplice è anche quella che '
          'funziona.',
      'Non è una promessa di miracoli: è una base solida su cui contare.',
    ],
    NaturaDellaCarta.prova: [
      'Sulla tua questione vuol dire prepararti bene invece di insistere a '
          'vuoto.',
      'Non è una condanna: è un tratto difficile che si attraversa con calma.',
      'Le carte rovesciate trattengono: quello che chiedi resta, ma con un '
          'altro tempo.',
      'Forzare adesso costa più che aspettare: la pazienza qui è una scelta '
          'attiva.',
      'Quello che desideri non sparisce affatto: chiede soltanto un\'altra via '
          'per arrivare.',
      'Su questa questione la fretta è l\'unico vero nemico che hai adesso.',
      'Puoi fidarti di questo rallentamento: ti sta proteggendo da una mossa '
          'sbagliata.',
      'Non è un fallimento: è una tappa che chiede più preparazione del '
          'previsto.',
    ],
    NaturaDellaCarta.attrito: [
      'Per quello che chiedi conta sistemare un dettaglio prima di giudicare '
          'tutto.',
      'Non è un segnale di fine: è un granello che si toglie subito.',
      'Le carte minori rovesciate frenano senza fermare: la strada resta del '
          'tutto aperta.',
      'Insistere a testa bassa non serve: serve guardare dove la cosa si '
          'inceppa.',
      'Quello che ti frena ha un nome preciso: trovarlo è metà del lavoro.',
      'Su questa questione basta poco per tornare a muoverti di nuovo con '
          'facilità.',
      'Non serve un esperto: serve un\'ora di attenzione onesta sul punto '
          'giusto.',
      'Il ritardo è reale ma si recupera, se te ne occupi adesso.',
    ],
  };

  /// **IL TITOLO DELLA LETTURA DI CASA, uno per ogni cosa che dice il
  /// presente.** Ordine FK aggiunta voci A1 e A2, 11 ottobre 2026.
  ///
  /// Il fondatore, 3 settembre 2026: *"un titolo che a colpo d'occhio e' gia'
  /// una risposta diretta e poi sotto la risposta vera"*. Il titolo e' la
  /// frase di [cosaDiceIlPresente] detta in poche parole, **alla stessa
  /// posizione dell'elenco**, cosi' titolo e risposta non possono dire due
  /// cose diverse. Non nomina la carta, perche' il simbolo non apre mai (Linee
  /// Guida, sezione 2). Da 3 a 8 parole, senza punto in fondo.
  ///
  /// **LAPIDE: "il titolo e' la sintesi della carta del Presente"**, ordine
  /// DF voce 04.5. Quella era il significato di una carta, non la risposta
  /// alla domanda: due persone con domande diverse e lo stesso Presente
  /// leggevano lo stesso titolo.
  static const Map<NaturaDellaCarta, List<String>> titoliDelPresente = {
    NaturaDellaCarta.compimento: [
      'Un giro si chiude',
      'La cosa è arrivata a maturazione',
      'Il movimento va nel verso giusto',
      'Il lavoro è fatto',
      'Sta già accadendo',
      'Un passaggio vero',
      'Il traguardo è già qui',
      'Il pieno c\'è: decidi cosa farne',
    ],
    NaturaDellaCarta.favore: [
      'Il vantaggio è alla tua portata',
      'Il terreno è buono',
      'Un passo che riesce',
      'Questione di settimane, non di anni',
      'Le cose stanno dove devono',
      'Hai più di quanto pensi',
      'Il tuo mestiere ti premia',
      'La porta è socchiusa',
    ],
    NaturaDellaCarta.prova: [
      'Non è tolto: è rimandato',
      'Non è un no: è un non adesso',
      'La strada c\'è, ma è un\'altra',
      'Il tempo giusto non è ancora il tuo',
      'Una prova che chiede una cosa sola',
      'Il nodo si scioglie dal capo giusto',
      'C\'è un prezzo noto da pagare',
      'Resta, ma passa da una porta stretta',
    ],
    NaturaDellaCarta.attrito: [
      'Un attrito piccolo frena tutto',
      'Un dettaglio da sistemare',
      'È più piccolo di come lo vivi',
      'Manca un pezzo in un punto solo',
      'Un fastidio vero ma piccolo',
      'Energia nel punto sbagliato',
      'Ti manca un\'informazione',
      'Rimandare ormai costa di più',
    ],
  };

  // --- IL "COSA FARE ADESSO", secondo paragrafo, nel riquadro ---

  /// **GLI AGGANCI DELL'AZIONE, la prima frase del riquadro.** Ordine DF voce
  /// 02, misura D.
  ///
  /// Nell'ordine DF portavano il nome della carta che regge, perche' il
  /// paragrafo dell'azione era **l'unico senza un nome di carta dentro** e su
  /// cento letture si ripeteva nove volte. Nella forma nuova il nome nel
  /// riquadro lo porta l'approdo ([formeDellApprodo]), che dice verso che
  /// cosa il gesto porta: due nomi di carta nello stesso riquadro avrebbero
  /// sommato due incertezze di lunghezza, e la fascia non le avrebbe tenute.
  /// Valgono per qualunque stesa ([valeOvunque]). **Fascia: da 8 a 9
  /// parole.**
  static const List<String> aggancioDellAzione = [
    'Quello che le carte chiedono è una cosa sola.',
    'Le carte indicano un gesto preciso: è questo.',
    'Da qui viene un\'indicazione precisa e facile da seguire.',
    'La mossa suggerita si fa in pochi giorni.',
    'In pratica, la lettura ti chiede soltanto questo.',
    'Le carte non lasciano il consiglio nel vago: eccolo.',
    'Ecco che cosa farne adesso, stando alle carte lette.',
    'Il gesto che le carte mettono davanti è piccolo.',
    'Con questa lettura in mano, il compito è chiaro.',
    'Tradotta in un gesto, la lettura dice proprio questo.',
    'La lettura porta un compito breve e chiaro.',
    'Non serve un piano intero: serve una cosa sola.',
  ];

  /// **IL GESTO, otto per natura: che cosa fare e che cosa non fare.**
  /// Ordine DF voce 02, riscritto dall'ordine GA voce GA.06: *"L'utente deve
  /// avere una risposta o una guida, deve sapere cosa fare o non fare"*. Ogni
  /// forma porta il gesto concreto e subito dopo la cosa da non fare, e il
  /// gesto resta agganciato alla natura della carta che regge. **Fascia: da
  /// 18 a 20 parole.**
  static const Map<NaturaDellaCarta, List<String>> gestoPerNatura = {
    NaturaDellaCarta.compimento: [
      'Dichiara che è finita: dillo, scrivilo o mandalo a qualcuno. E non '
          'aggiungere un altro ritocco per paura di consegnare.',
      'Usa adesso quello che hai costruito, invece di aspettare di [sentirti '
          'più pronto|sentirti più pronta|avere più certezze]. Non rimandarlo a '
          'un momento migliore.',
      'Dai una data precisa alla consegna, entro questa settimana. Non '
          'lasciarla aperta: una data vaga diventa una data mai.',
      'Mostra il risultato a una persona che conta e lascia che lo veda '
          'davvero. Non nasconderlo dietro le solite scuse.',
      'Togli le ultime cose che hai aggiunto e guarda se non era già finito '
          'prima. Non ricominciare da capo.',
      'Segna il traguardo in un posto dove puoi ritrovarlo, anche solo una riga '
          'sul calendario. Non farlo passare in silenzio.',
      'Chiedi adesso quello che rimandavi a quando [saresti stato più forte|'
          'saresti stata più forte|avresti avuto più forza]. Non aspettare un '
          'permesso che nessuno ti deve dare.',
      'Scrivi in poche righe che cosa hai imparato in questo tratto e tienile '
          'con te. Non buttarle via domani.',
    ],
    NaturaDellaCarta.favore: [
      'Fai oggi il passo concreto che rimandi da tempo, anche se piccolo. Non '
          'aspettare di avere tutto chiaro.',
      'Scegli una sola cosa fra quelle aperte e portala a termine. Non aprirne '
          'un\'altra prima di averla chiusa.',
      'Chiedi apertamente quello che finora hai solo sperato che ti venisse '
          'offerto. Non pretendere che lo indovinino da soli.',
      'Metti un numero su quello che stai valutando: quanto costa, quanto '
          'rende, entro quando. Non decidere a sensazione.',
      'Cerca chi ha già fatto questa cosa e fagli due domande precise. Non '
          'chiedere un parere generico a tutti.',
      'Rendi visibile quello che sai fare, anche con una riga sola in più. Non '
          'lasciare che resti un segreto.',
      'Fissa tu la prima scadenza, prima che te la fissi qualcun altro. Non '
          'farti dettare i tempi da chi aspetta.',
      'Fai la versione piccola della cosa grande che hai in mente, questa '
          'settimana. Non progettare oltre prima di averla provata.',
    ],
    NaturaDellaCarta.prova: [
      'Smetti di spingere per qualche giorno e guarda che cosa si muove da '
          'solo. Non forzare la porta.',
      'Cerca il pezzo che manca invece di ripetere il tentativo. Non rifare la '
          'stessa cosa sperando in un esito diverso.',
      'Rimanda di una settimana la decisione che stai per prendere di fretta. '
          'Non firmare e non promettere niente sotto pressione.',
      'Scrivi su un foglio quale condizione dovrebbe cambiare perché questa '
          'cosa funzioni. Non insistere finché quella condizione resta ferma.',
      'Prova la stessa cosa in una versione che, se va male, non ti costa '
          'niente. Non giocarti tutto subito.',
      'Parla con chi ti sta dicendo di no e chiedi cosa servirebbe per un sì. '
          'Non prenderlo come un rifiuto.',
      'Prenditi il tempo che serve, ma mettici una scadenza scritta. Non '
          'lasciare che l\'attesa diventi una scusa comoda per fermarti.',
      'Cambia una sola variabile invece di rifare tutto il piano. Non buttare '
          'via quello che fin qui ha funzionato bene.',
    ],
    NaturaDellaCarta.attrito: [
      'Togli oggi l\'intoppo più piccolo fra quelli che hai in mente. Non '
          'cominciare dal più grande perché fa più paura.',
      'Metti per iscritto che cosa esattamente si è inceppato e dove. Non '
          'lamentartene con nessuno prima di averlo nominato bene.',
      'Parla presto con la persona che sta dall\'altra parte dell\'inghippo. '
          'Non provare a sistemarlo in segreto, senza dirglielo.',
      'Dai mezz\'ora a questa cosa oggi stesso. Non dedicarle un minuto di più: '
          'il resto della giornata è tuo.',
      'Elimina un passaggio invece di renderlo più veloce. Non aggiungere '
          'controlli a un meccanismo che è già troppo lento.',
      'Controlla la cosa più banale prima di cercare la causa complicata. Non '
          'chiamare rinforzi per un guasto da poco.',
      'Rinuncia a quello che ti costa più di quanto rende e dillo chiaramente. '
          'Non continuare per abitudine o per orgoglio.',
      'Rifai con calma la parte che la prima volta hai fatto di corsa. Non '
          'saltare i dettagli che sembrano inutili.',
    ],
  };

  /// **L'APPRODO, l'ultima frase del riquadro: verso che cosa il gesto
  /// porta.** Ordine GA voci GA.06 e GA.07, dalle forme del seguito
  /// dell'ordine DF voce 04.2.
  ///
  /// **E' la riparazione della voce DF.04.2 che resta.** La formula unica
  /// *"X non e' una sentenza: e' dove questo va se non cambi passo"* toccava a
  /// **L'Appeso** e a **Il Mondo**: una minaccia detta sulla carta del
  /// compimento. L'approdo **parla come la carta che e' uscita**: verso una
  /// carta aperta il gesto e' la via per arrivarci, verso una carta chiusa e'
  /// il modo di attraversarla o di non incontrarla. Nessuna forma la da' per
  /// certa (regola dell'ordine S voce 17, ribadita da GA.06), e nessuna dice
  /// "futuro": la stesa a quattro e la Croce Celtica approdano all'esito.
  /// `{futuro}` diventa il nome della carta d'approdo (`TarotSpread.approdo`).
  /// **Fascia: da 13 a 14 parole fisse.**
  static const Map<NaturaDellaCarta, List<String>> formeDellApprodo = {
    NaturaDellaCarta.compimento: [
      '{futuro} chiude la lettura su un compimento: questo gesto è la via '
          'diretta per arrivarci.',
      'In fondo c\'è {futuro}: è lì che questo gesto ti accompagna, un giorno '
          'alla volta.',
      'La lettura si chiude con {futuro}: il gesto di oggi serve a restare in '
          'cammino.',
      '{futuro} aspetta in fondo alla stesa: fare questo adesso è il modo di '
          'andarci incontro.',
      'Con {futuro} in fondo alla lettura, ogni gesto fatto adesso va nella '
          'direzione giusta.',
      'Dove la lettura si chiude c\'è {futuro}: questo gesto è il primo tratto '
          'per arrivarci.',
      '{futuro} sta in fondo alla stesa e dice che lo sforzo ha un approdo '
          'vero.',
      'L\'ultima carta è {futuro}, fra le più aperte: questo gesto ti tiene '
          'sulla sua linea.',
    ],
    NaturaDellaCarta.favore: [
      '{futuro} chiude la lettura su una nota concreta: questo gesto è il modo '
          'di raggiungerla.',
      'In fondo c\'è {futuro}: un risultato che somiglia al lavoro che ci metti '
          'adesso.',
      'La lettura si chiude con {futuro}: cose che si vedono e si contano, se '
          'cominci.',
      '{futuro} aspetta in fondo alla stesa: è il seguito di questo gesto, non '
          'una sorpresa.',
      'Con {futuro} in fondo alla lettura, il seguito dipende più da te che '
          'dalle circostanze.',
      'Dove la lettura si chiude c\'è una cosa che si costruisce e non capita: '
          '{futuro}.',
      '{futuro} sta in fondo alla stesa: una carta piccola e dritta, che chiede '
          'solo costanza.',
      'L\'ultima carta è {futuro}: un risultato alla portata, se il gesto si fa '
          'adesso.',
    ],
    NaturaDellaCarta.prova: [
      '{futuro} chiude la lettura con una prova: questo gesto serve a renderla '
          'più leggera.',
      'In fondo c\'è {futuro}: un tratto difficile, più leggero se questo gesto '
          'viene prima.',
      '{futuro} chiude la lettura rimandando, non negando: il gesto di oggi '
          'prepara proprio quel momento.',
      '{futuro} aspetta in fondo: non toglie l\'arrivo, sposta la data e il '
          'gesto la prepara.',
      'Con {futuro} in fondo alla lettura, il gesto vale doppio: ti prepara '
          'alla prova.',
      'In chiusura c\'è {futuro}: una prova che costa meno se ti muovi fin da '
          'subito.',
      '{futuro} sta in fondo: una carta di traverso, che chiede preparazione e '
          'non paura.',
      'L\'ultima carta è {futuro}: conviene guardarla adesso, finché c\'è tempo '
          'per scegliere come arrivarci.',
    ],
    NaturaDellaCarta.attrito: [
      '{futuro} chiude la lettura su un attrito piccolo: questo gesto lo toglie '
          'prima che cresca.',
      'In fondo c\'è {futuro}: un avviso utile, che questo gesto rende innocuo '
          'per tempo.',
      'La lettura si chiude con {futuro}: un granello da togliere adesso, '
          'finché è ancora piccolo.',
      '{futuro} aspetta in fondo alla stesa e si smonta appena qualcuno ci '
          'guarda davvero.',
      'Con {futuro} in fondo alla lettura, il gesto di oggi evita un inciampo '
          'domani.',
      'Dove la lettura si chiude c\'è {futuro}: se ti muovi adesso, '
          'quell\'intralcio non lo incontri.',
      '{futuro} sta in fondo alla stesa: avverte e non minaccia. E un avviso '
          'si usa.',
      'L\'ultima carta è {futuro}: la più facile da smentire, con un gesto '
          'come questo.',
    ],
  };

  /// **LA RAGIONE, otto e valgono per ogni gesto, quando la stesa non ha un
  /// approdo** (la carta sola). Dicono **perche' quel gesto sposta
  /// qualcosa**, e nessuna promette niente. **Fascia: da 14 a 16 parole.**
  static const List<String> percheFarlo = [
    'Qui conta muoversi più che trovare il momento perfetto, che arriva dopo '
        'il primo gesto.',
    'Una cosa finita vale più di molte iniziate: è lei a cambiare davvero la '
        'situazione.',
    'Un gesto piccolo fatto oggi sposta più di un gesto grande rimandato a un '
        'giorno migliore.',
    'Finché resta nella testa è un pensiero; appena esce diventa una cosa che '
        'si può maneggiare.',
    'È la mossa che costa meno fra tutte quelle che stai considerando in '
        'questi giorni.',
    'Serve a togliere l\'incertezza. E l\'incertezza, più della fatica, è la '
        'parte che stanca.',
    'Da lì in poi la situazione smette di dipendere solo dall\'attesa e torna '
        'nelle tue mani.',
    'È un gesto semplice, ma cambia le cose più di molti giorni passati a '
        'ragionarci sopra.',
  ];

  /// **UNA FORMA CHE VALE PER QUALUNQUE STESA.** Ordine FK aggiunta 2 voce
  /// A8: non nomina il numero tre ne' le posizioni del passato, del presente
  /// e del futuro (i segnaposto fra graffe non contano, li riempie la stesa).
  /// Dall'ordine GA ogni forma della voce vale ovunque: la stesa a una, a
  /// quattro e a dieci carte hanno la stessa varieta' di quella a tre.
  static bool valeOvunque(String forma) => !RegExp(
          r'(?<![A-Za-zÀ-ÿ])(tre|passato|presente|futuro|spalle)(?![A-Za-zÀ-ÿ])',
          caseSensitive: false)
      .hasMatch(forma.replaceAll(RegExp(r'\{\w+\}'), ''));

  /// **SCEGLIE UNA FORMA SENZA RIPETERE UN'IMMAGINE GIA' DETTA.** Ordine DS
  /// voce 09.
  ///
  /// Il filo sceglie come sempre, e il filo consuma come sempre: le letture
  /// che non incontravano una ripetizione restano identiche al carattere. Se
  /// la forma scelta usa una figura che un altro pezzo ha gia' detto, si
  /// passa alla forma successiva della stessa tavola che non la usa. Solo se
  /// nessuna forma della tavola e' libera si tiene quella scelta: una tavola
  /// intera sulla stessa figura sarebbe un difetto della tavola, e la guardia
  /// lo direbbe. Le forme di una tavola stanno tutte nella stessa fascia di
  /// parole, quindi il salto non sposta la misura.
  static String senzaRipetere(
      FiloDellaVoce filo, List<String> forme, Set<String> usate,
      {List<String>? pezzi}) {
    final scelta = filo.scegli(forme);
    final da = forme.indexOf(scelta);
    // L'impianto e' uno solo dall'ordine DT voce 27: qui gli si danno le forme
    // nell'ordine del filo e le figure come marche.
    final tenuta = SceltaSenzaRipetere.primoLibero(
          [
            for (var k = 0; k < forme.length; k++)
              forme[(da + k) % forme.length]
          ],
          FigureDellaStesa.di,
          usate,
        ) ??
        scelta;
    usate.addAll(FigureDellaStesa.di(tenuta));
    pezzi?.add(tenuta);
    return tenuta;
  }

  /// **LE OTTO APERTURE DI UNA POSIZIONE.** Ordine DF voce 02, misura C.
  ///
  /// **Era una sola, ed era la lente dell'argomento**: *"Sul denaro che ti
  /// riguarda,"* apriva **tutte e tre** le posizioni di **tutte** le cento
  /// letture. Quindici parole identiche per testo, trecento sequenze comuni
  /// regalate a ogni coppia, e nessuna di quelle sequenze diceva niente.
  static const List<String> apertureDellaPosizione = [
    'In questa posizione',
    'Qui la carta dice che',
    'Su questo punto',
    'Quello che si legge qui è che',
    'La carta in questa casella racconta che',
    'A questo posto della stesa',
    'Qui',
    'In questo tratto della lettura',
  ];

  /// **LA RIGA DEL CIELO VERO**, in un punto solo: la dice la lettura di casa
  /// e, dall'ordine EQ voce 04, anche quella scritta dal modello. Ordine DS
  /// voce 09: dice a cosa si accosta il cielo, le tre carte. Dall'ordine GA
  /// non sta nei paragrafi del responso: va nel "Da dove viene", e la mette
  /// `TarotReading`.
  static String rigaDelCielo(String cielo) =>
      'Accanto a queste tre carte c\'è il cielo di oggi. $cielo';

  /// L'apertura della posizione [quale], contata da zero, per questa stesa.
  static String aperturaDellaPosizione(TarotSpread spread, int quale) {
    final filo = FiloDellaVoce(FiloDellaVoce.daStesa(spread).seme + quale * 97);
    return filo.scegli(apertureDellaPosizione);
  }

  // **IL TITOLO DELLA SINTESI DELLA CARTA NON C'E' PIU'.** Ordine FK
  // aggiunta voci A1 e A2. Qui viveva `titolo(spread)`, la sintesi della
  // carta del Presente senza il punto (ordine DF voci 04.5 e 04.9): era il
  // significato di una carta e non la risposta alla domanda. Il titolo adesso
  // e' `TarotReading.titolo`, quello del modello o [titoliDelPresente].

  /// **I DUE PARAGRAFI DEL RESPONSO PRINCIPALE DI CASA**, la risposta e il
  /// "Cosa fare adesso". Ordine DF voci 02 e 04.9, ordine GA voce GA.03.
  ///
  /// **L'ORDINE DI LETTURA, che e' la voce DF.04.9 e adesso la GA.06.** Il
  /// fondatore, ordine DF: *"il Consiglio apre con il verdetto e mette le
  /// carte in fondo"*; ordine GA: *"risposte dirette immediatamente"*. La
  /// carta che regge e' nella prima frase, e la prima frase e' la risposta.
  ///
  /// [domandaScritta] non entra nei paragrafi (vedi l'intestazione della
  /// classe): la firma resta perche' i chiamanti la passano.
  static List<String> paragrafi(
    TarotSpread spread,
    TarotTopic topic, {
    String? domandaScritta,
    String? fattoDelCielo,
  }) {
    final c = _componi(spread, topic, fattoDelCielo: fattoDelCielo);
    return [c.risposta, c.cosaFare];
  }

  /// **IL TITOLO DELLA LETTURA DI CASA**: quello di [titoliDelPresente] che
  /// sta alla posizione della risposta scelta.
  static String titoloDellaLettura(
    TarotSpread spread,
    TarotTopic topic, {
    String? domandaScritta,
    String? fattoDelCielo,
  }) =>
      _componi(spread, topic, fattoDelCielo: fattoDelCielo).titolo;

  /// **IL RESPONSO PRINCIPALE DI CASA NELLA FORMA NUOVA.** Ordine GA voci
  /// GA.03, GA.05 e GA.07, 20 ottobre 2026: quando il modello non torna, il
  /// responso principale della stesa e' questo, il titolo, la risposta e il
  /// "Cosa fare adesso", ogni paragrafo da 40 a 50 parole
  /// (`LaFormaDelResponso`) in ogni composizione. La domanda di chiusura e la
  /// riga del cielo non stanno qui: la prima resta un dato
  /// (`TarotReading.domanda`), la seconda va nel "Da dove viene".
  static ({String titolo, String risposta, String cosaFare}) responsoDiCasa(
    TarotSpread spread,
    TarotTopic topic, {
    String? domandaScritta,
    String? fattoDelCielo,
  }) {
    final c = _componi(spread, topic, fattoDelCielo: fattoDelCielo);
    return (titolo: c.titolo, risposta: c.risposta, cosaFare: c.cosaFare);
  }

  /// **I PEZZI DEL RESPONSO, uno per scelta.** Ordine DS voce 09: la guardia
  /// delle figure li conta pezzo per pezzo, perche' un pezzo solo puo'
  /// riprendere la sua parola (*"Un nodo si scioglie... il nodo"*) e due
  /// pezzi diversi non devono dire la stessa immagine. Il fatto del cielo e'
  /// un pezzo anche lui, e sta per primo: non sta piu' nei paragrafi, ma si
  /// legge nella stessa schermata, nel "Da dove viene", e le forme scelte gli
  /// girano intorno.
  static List<String> pezzi(
    TarotSpread spread,
    TarotTopic topic, {
    String? domandaScritta,
    String? fattoDelCielo,
  }) =>
      _componi(spread, topic, fattoDelCielo: fattoDelCielo).pezzi;

  /// **RIEMPIE UNA FORMA**: la marca del genere prima, sul modello della
  /// frase (ordine DL voce 02: un nome con una quadra dentro non deve
  /// diventare una marca), poi i segnaposto. Pubblica perche' la guardia
  /// della misura riempia le forme esattamente come le riempie la voce.
  static String riempi(
    String forma, {
    required String lente,
    String presente = '',
    String futuro = '',
  }) =>
      LaMarcaDelGenere.risolvi(forma)
          .replaceAll('{lente}', '$lente,')
          .replaceAll('{inLente}', _minuscola(lente))
          .replaceAll('{presente}', presente)
          .replaceAll('{futuro}', futuro);

  static String _minuscola(String s) =>
      s.isEmpty ? s : s[0].toLowerCase() + s.substring(1);

  static ({
    String risposta,
    String cosaFare,
    List<String> pezzi,
    String titolo,
  }) _componi(
    TarotSpread spread,
    TarotTopic topic, {
    String? fattoDelCielo,
  }) {
    final filo = FiloDellaVoce.daStesa(spread);
    // **LE FIGURE GIA' DETTE, a partire dal cielo**, che non si sceglie: e'
    // il fatto vero del giorno, e sono le forme scelte a girargli intorno.
    final cielo = fattoDelCielo?.trim() ?? '';
    final usate = FigureDellaStesa.di(cielo);
    final pezzi = <String>[if (cielo.isNotEmpty) cielo];
    // **LA STESA DI N CARTE, ordine FK aggiunta 2 voce A8.** Fuori dalla
    // stesa a tre carte si scelgono solo le forme che valgono per qualunque
    // numero di carte; dall'ordine GA lo sono tutte, e il filtro resta come
    // cintura per la forma che un giorno non lo fosse.
    final aTre = spread.eATreCarte;
    String scegli(List<String> forme) {
      final buone =
          aTre ? forme : forme.where(valeOvunque).toList(growable: false);
      return senzaRipetere(filo, buone.isEmpty ? forme : buone, usate,
          pezzi: pezzi);
    }

    final natura = NaturaDellaCarta.di(spread.cuore);
    final approdo = spread.approdo;
    String riempiQui(String forma) => riempi(forma,
        lente: topic.lente,
        presente: spread.cuore.displayName,
        futuro: approdo?.displayName ?? '');

    // --- LA RISPOSTA: il verdetto, che cosa dice la carta che regge, che
    // cosa vuol dire per la questione ---
    final verdetto = riempiQui(scegli(verdettiDelCuore[natura]!));
    final formeDelCuore = cosaDiceIlPresente[natura]!;
    final formaDetta = scegli(formeDelCuore);
    final titolo =
        titoliDelPresente[natura]![formeDelCuore.indexOf(formaDetta)];
    final vuolDire = riempiQui(scegli(cosaVuolDire[natura]!));
    final risposta = '$verdetto ${riempiQui(formaDetta)} $vuolDire';

    // --- IL "COSA FARE ADESSO": l'aggancio, il gesto, l'approdo ---
    final aggancio = riempiQui(scegli(aggancioDellAzione));
    final gesto = riempiQui(scegli(gestoPerNatura[natura]!));
    final perche = approdo == null
        ? riempiQui(scegli(percheFarlo))
        : riempiQui(scegli(formeDellApprodo[NaturaDellaCarta.di(approdo)]!));
    final cosaFare = '$aggancio $gesto $perche';

    return (
      risposta: risposta,
      cosaFare: cosaFare,
      pezzi: pezzi,
      titolo: titolo,
    );
  }
}

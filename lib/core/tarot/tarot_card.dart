import '../assets/family_image.dart';

/// Il seme di un Arcano Minore, con l'elemento tradizionale.
enum TarotSeme {
  bastoni('Bastoni', 'fuoco'),
  coppe('Coppe', 'acqua'),
  denari('Denari', 'terra'),
  spade('Spade', 'aria');

  const TarotSeme(this.italianName, this.elemento);
  final String italianName;
  final String elemento;
}

/// Il tipo di Arcano.
enum TarotArcana { maggiore, minore }

/// Una carta dei tarocchi, nella voce di Medora: nome, tipo, seme e numero se
/// Minore, il verso dritto e il verso rovesciato (sintesi piu' riga ciascuno) e
/// l'arte bundlata (famiglia `mazzo-tarocchi`).
class TarotCard {
  const TarotCard({
    required this.name,
    required this.arcana,
    this.seme,
    this.number,
    required this.uprightSummary,
    required this.upright,
    required this.reversedSummary,
    required this.reversed,
    required this.stem,
  });

  final String name;
  final TarotArcana arcana;

  /// Seme e numero, valorizzati solo per i Minori.
  final TarotSeme? seme;
  final int? number;

  final String uprightSummary;
  final String upright;
  final String reversedSummary;
  final String reversed;
  final String stem;

  String get thumbPath => FamilyImage.thumb(AssetFamily.tarocchi, stem);
  String get fullPath => FamilyImage.full(AssetFamily.tarocchi, stem);

  /// Il numero d'ordine di un Arcano Maggiore, da 0 a 21, letto dallo stem.
  /// Null per i Minori.
  int? get majorNumber {
    if (arcana != TarotArcana.maggiore) return null;
    final m = RegExp(r'^tar_rw_(\d{2})_').firstMatch(stem);
    return m == null ? null : int.parse(m.group(1)!);
  }

  /// Vero per le quattro carte di corte di ogni seme: Fante, Cavaliere, Regina,
  /// Re. Nel cartiglio superiore al loro posto va l'emblema del seme, perche' la
  /// parola per esteso in quella placca stretta risulterebbe illeggibile.
  bool get isCorte =>
      arcana == TarotArcana.minore && number != null && number! >= 11;

  /// Il numerale del cartiglio superiore: romano per i Maggiori, arabo per i
  /// Minori numerati, il nome della figura per le carte di corte.
  String get numeral {
    if (arcana == TarotArcana.maggiore) {
      return _romani[majorNumber ?? 0];
    }
    switch (number) {
      case 11:
        return 'Fante';
      case 12:
        return 'Cavaliere';
      case 13:
        return 'Regina';
      case 14:
        return 'Re';
      default:
        return '${number ?? ''}';
    }
  }

  static const List<String> _romani = [
    '0', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', //
    'XI', 'XII', 'XIII', 'XIV', 'XV', 'XVI', 'XVII', 'XVIII', 'XIX', 'XX', 'XXI'
  ];
}

/// Il mazzo completo dei 78 Arcani, dal corpus `docs/corpus/tarocchi.md`, legati
/// all'arte Rider-Waite per nome (Maggiori) e per seme e numero (Minori).
class TarotDeck {
  const TarotDeck._();

  /// Stem del dorso del mazzo, per le carte coperte.
  static const String dorsoStem = 'tar_rw_dorso_medora_v1';
  static String get dorsoThumb => FamilyImage.thumb(AssetFamily.tarocchi, dorsoStem);
  static String get dorsoFull => FamilyImage.full(AssetFamily.tarocchi, dorsoStem);

  static const List<TarotCard> cards = [
    TarotCard(name: 'Il Matto', arcana: TarotArcana.maggiore, seme: null, number: null, uprightSummary: 'Il salto nel vuoto.', upright: 'Un nuovo inizio ti chiama: parti leggero, con fiducia e cuore aperto, anche senza vedere tutta la strada.', reversedSummary: 'Il passo avventato.', reversed: 'Slancio senza direzione, o timore che ti trattiene sull\'orlo: prima di partire, senti se è coraggio o fuga.', stem: 'tar_rw_00_il-matto_v1'),
    TarotCard(name: 'Il Mago', arcana: TarotArcana.maggiore, seme: null, number: null, uprightSummary: 'Il potere di creare.', upright: 'Hai gli strumenti e la volontà: è il momento di manifestare, di trasformare l\'idea in gesto.', reversedSummary: 'Il potere sprecato.', reversed: 'Talento che resta inusato, o parole che promettono più di quanto mantieni: riporta l\'intenzione al gesto onesto.', stem: 'tar_rw_01_il-mago_v1'),
    TarotCard(name: 'La Papessa', arcana: TarotArcana.maggiore, seme: null, number: null, uprightSummary: 'Il sapere del silenzio.', upright: 'Ascolta l\'intuizione, ciò che sai senza spiegarlo: un mistero si svela solo alla mente quieta.', reversedSummary: 'L\'intuito messo a tacere.', reversed: 'Stai coprendo una voce interiore che sa: torna al silenzio, il segreto aspetta solo di essere ascoltato.', stem: 'tar_rw_02_la-papessa_v1'),
    TarotCard(name: 'L\'Imperatrice', arcana: TarotArcana.maggiore, seme: null, number: null, uprightSummary: 'La forza che genera.', upright: 'Abbondanza, creatività, cura: qualcosa fiorisce nelle tue mani, lascialo crescere con dolcezza.', reversedSummary: 'La cura dimenticata.', reversed: 'Creatività bloccata, o attenzione che scordi di dare a te stessa: rifiorisci nutrendo prima la tua radice.', stem: 'tar_rw_03_l-imperatrice_v1'),
    TarotCard(name: 'L\'Imperatore', arcana: TarotArcana.maggiore, seme: null, number: null, uprightSummary: 'La struttura che protegge.', upright: 'Ordine, autorità, fondamenta solide: è tempo di dare forma e regola a ciò che costruisci.', reversedSummary: 'La regola che soffoca.', reversed: 'Controllo troppo stretto, oppure fondamenta che mancano: cerca l\'ordine che protegge, non quello che imprigiona.', stem: 'tar_rw_04_l-imperatore_v1'),
    TarotCard(name: 'Il Papa', arcana: TarotArcana.maggiore, seme: null, number: null, uprightSummary: 'La guida antica.', upright: 'Tradizione, insegnamento, senso condiviso: cerca un maestro, oppure diventa maestro di te stesso.', reversedSummary: 'La regola da rivedere.', reversed: 'Un sapere ricevuto che non ti appartiene più: cerca il tuo senso, anche fuori dal sentiero già tracciato.', stem: 'tar_rw_05_l-ierofante_v1'),
    TarotCard(name: 'Gli Amanti', arcana: TarotArcana.maggiore, seme: null, number: null, uprightSummary: 'La scelta del cuore.', upright: 'Amore e bivio: una decisione che riguarda i tuoi valori più veri. Scegli con tutto te stesso.', reversedSummary: 'La scelta rimandata.', reversed: 'Dubbio, disaccordo, valori in conflitto: la decisione chiede sincerità con te prima che con gli altri.', stem: 'tar_rw_06_gli-amanti_v1'),
    TarotCard(name: 'Il Carro', arcana: TarotArcana.maggiore, seme: null, number: null, uprightSummary: 'La volontà che vince.', upright: 'Direzione, slancio, controllo: tieni le redini delle tue forze opposte e vai avanti.', reversedSummary: 'Le redini allentate.', reversed: 'Forze che tirano in versi opposti: fermati, ritrova il centro, poi riprendi la guida.', stem: 'tar_rw_07_il-carro_v1'),
    TarotCard(name: 'La Forza', arcana: TarotArcana.maggiore, seme: null, number: null, uprightSummary: 'La forza gentile.', upright: 'Coraggio dolce: domini l\'istinto con la mano ferma e il cuore mite, non con la violenza.', reversedSummary: 'Il dominio perso.', reversed: 'Un dubbio sulla tua tenuta, o una durezza con te stessa: la vera forza è la mano gentile, torna a trattarti con mitezza.', stem: 'tar_rw_08_la-forza_v1'),
    TarotCard(name: 'L\'Eremita', arcana: TarotArcana.maggiore, seme: null, number: null, uprightSummary: 'La luce interiore.', upright: 'Ritiro, ricerca, saggezza: rallenta e cerca dentro, la tua lanterna illumina un passo alla volta.', reversedSummary: 'Il ritiro che isola.', reversed: 'Una solitudine che pesa invece di illuminare: la tua lanterna serve anche per tornare tra gli altri.', stem: 'tar_rw_09_l-eremita_v1'),
    TarotCard(name: 'La Ruota della Fortuna', arcana: TarotArcana.maggiore, seme: null, number: null, uprightSummary: 'Il giro del destino.', upright: 'I cicli girano, qualcosa cambia: accogli la svolta, nulla resta fermo per sempre.', reversedSummary: 'Il giro che resiste.', reversed: 'Un ciclo sembra bloccato, o gira storto: anche la sosta è parte del moto, presto la ruota riparte.', stem: 'tar_rw_10_la-ruota-della-fortuna_v1'),
    TarotCard(name: 'La Giustizia', arcana: TarotArcana.maggiore, seme: null, number: null, uprightSummary: 'La bilancia della verità.', upright: 'Equilibrio, causa ed effetto, responsabilità: raccogli ciò che hai seminato, con lucidità.', reversedSummary: 'Il conto sospeso.', reversed: 'Una verità evitata, oppure una responsabilità rimandata: guardala in faccia, l\'equilibrio torna quando sei onesto.', stem: 'tar_rw_11_la-giustizia_v1'),
    TarotCard(name: 'L\'Appeso', arcana: TarotArcana.maggiore, seme: null, number: null, uprightSummary: 'Il dono della sospensione.', upright: 'Fermati e capovolgi lo sguardo: da un\'attesa apparente nasce una comprensione nuova.', reversedSummary: 'La sospensione che pesa.', reversed: 'Un\'attesa che sa di stallo, un sacrificio senza senso: cambia lo sguardo, oppure scendi dall\'albero e agisci.', stem: 'tar_rw_12_l-appeso_v1'),
    TarotCard(name: 'La Morte', arcana: TarotArcana.maggiore, seme: null, number: null, uprightSummary: 'La fine che libera.', upright: 'Qualcosa si chiude perché altro nasca: lascia andare senza paura, la trasformazione è vita.', reversedSummary: 'La fine trattenuta.', reversed: 'Resisti a un cambiamento già arrivato: lasciare andare fa meno male dell\'aggrapparsi, la vita vuole scorrere.', stem: 'tar_rw_13_la-morte_v1'),
    TarotCard(name: 'La Temperanza', arcana: TarotArcana.maggiore, seme: null, number: null, uprightSummary: 'La misura che guarisce.', upright: 'Armonia, pazienza, giusto dosaggio: unisci gli opposti con calma e ritrova l\'equilibrio.', reversedSummary: 'La misura perduta.', reversed: 'Eccessi, fretta, opposti che non si parlano: rallenta, ridosa, ritrova il ritmo che guarisce.', stem: 'tar_rw_14_la-temperanza_v1'),
    TarotCard(name: 'Il Diavolo', arcana: TarotArcana.maggiore, seme: null, number: null, uprightSummary: 'L\'ombra da guardare.', upright: 'Catene, tentazioni, attaccamenti: riconosci ciò che ti lega e la sua presa si allenta.', reversedSummary: 'La catena che si spezza.', reversed: 'Ti accorgi di un legame che ti tratteneva: il primo passo per liberarti è averlo visto, adesso scioglilo.', stem: 'tar_rw_15_il-diavolo_v1'),
    TarotCard(name: 'La Torre', arcana: TarotArcana.maggiore, seme: null, number: null, uprightSummary: 'Il crollo che rivela.', upright: 'Cade all\'improvviso ciò che era falso: doloroso, ma ti libera per costruire sul vero.', reversedSummary: 'Il crollo evitato.', reversed: 'Rimandi una scossa necessaria, oppure ne esci a fatica: meglio un vero che vacilla che un falso che regge.', stem: 'tar_rw_16_la-torre_v1'),
    TarotCard(name: 'La Stella', arcana: TarotArcana.maggiore, seme: null, number: null, uprightSummary: 'La speranza ritrovata.', upright: 'Dopo la tempesta, una luce dolce: fiducia, ispirazione, la promessa che guarirai.', reversedSummary: 'La speranza offuscata.', reversed: 'Una fiducia stanca, un\'ispirazione lontana: la luce non è spenta, solo velata, concediti di crederci ancora.', stem: 'tar_rw_17_le-stelle_v1'),
    TarotCard(name: 'La Luna', arcana: TarotArcana.maggiore, seme: null, number: null, uprightSummary: 'Il velo dei sogni.', upright: 'Inconscio, illusioni, paure notturne: non tutto è chiaro, procedi con intuito e prudenza.', reversedSummary: 'Il velo che si dirada.', reversed: 'Paure che perdono forza, una confusione che si chiarisce: ciò che temevi al buio si mostra più piccolo alla luce.', stem: 'tar_rw_18_la-luna_v1'),
    TarotCard(name: 'Il Sole', arcana: TarotArcana.maggiore, seme: null, number: null, uprightSummary: 'La gioia piena.', upright: 'Chiarezza, calore, successo: un tempo luminoso in cui le cose fioriscono e il cuore ride.', reversedSummary: 'La gioia velata.', reversed: 'Un entusiasmo trattenuto, una luce che fatichi a sentire: il sole c\'è, lascia cadere ciò che lo copre.', stem: 'tar_rw_19_il-sole_v1'),
    TarotCard(name: 'Il Giudizio', arcana: TarotArcana.maggiore, seme: null, number: null, uprightSummary: 'La chiamata al risveglio.', upright: 'Un bilancio, una rinascita: rispondi alla voce che ti chiama a una vita più vera.', reversedSummary: 'La chiamata inascoltata.', reversed: 'Rimandi un bilancio, oppure giudichi te con durezza: la rinascita chiede ascolto e perdono, non condanna.', stem: 'tar_rw_20_il-giudizio_v1'),
    TarotCard(name: 'Il Mondo', arcana: TarotArcana.maggiore, seme: null, number: null, uprightSummary: 'Il cerchio che si compie.', upright: 'Pienezza, traguardo, integrazione: un ciclo si chiude in armonia, sei arrivato.', reversedSummary: 'Il cerchio quasi chiuso.', reversed: 'Un traguardo a un passo, un pezzo ancora da integrare: non fermarti adesso, la pienezza chiede l\'ultimo tratto.', stem: 'tar_rw_21_il-mondo_v1'),
    TarotCard(name: 'Asso di Bastoni', arcana: TarotArcana.minore, seme: TarotSeme.bastoni, number: 1, uprightSummary: 'La scintilla che accende.', upright: 'Un impulso nuovo, un\'ispirazione ardente: afferra la fiamma, è il momento di iniziare.', reversedSummary: 'La scintilla che tarda.', reversed: 'Slancio bloccato, o una partenza rimandata: ritrova il desiderio prima di accendere.', stem: 'tar_rw_bastoni_01_v1'),
    TarotCard(name: 'Due di Bastoni', arcana: TarotArcana.minore, seme: TarotSeme.bastoni, number: 2, uprightSummary: 'Lo sguardo lontano.', upright: 'Un progetto che prende forma, una scelta di direzione: guarda l\'orizzonte e decidi la rotta.', reversedSummary: 'Il piano incerto.', reversed: 'Paura di osare, o direzione confusa: chiarisci cosa vuoi davvero prima di muoverti.', stem: 'tar_rw_bastoni_02_v1'),
    TarotCard(name: 'Tre di Bastoni', arcana: TarotArcana.minore, seme: TarotSeme.bastoni, number: 3, uprightSummary: 'Le navi in mare.', upright: 'L\'attesa dei frutti, l\'espansione avviata: hai seminato, ora guarda arrivare ciò che hai messo in moto.', reversedSummary: 'L\'attesa che pesa.', reversed: 'Ritardi, o aspettative deluse: pazienta, oppure correggi la rotta senza scoraggiarti.', stem: 'tar_rw_bastoni_03_v1'),
    TarotCard(name: 'Quattro di Bastoni', arcana: TarotArcana.minore, seme: TarotSeme.bastoni, number: 4, uprightSummary: 'La festa della soglia.', upright: 'Stabilità, celebrazione, un traguardo condiviso: gioisci di ciò che hai costruito.', reversedSummary: 'La festa sospesa.', reversed: 'Un\'armonia da ritrovare, radici ancora incerte: cura le fondamenta prima di festeggiare.', stem: 'tar_rw_bastoni_04_v1'),
    TarotCard(name: 'Cinque di Bastoni', arcana: TarotArcana.minore, seme: TarotSeme.bastoni, number: 5, uprightSummary: 'La sfida vivace.', upright: 'Attriti, gara, confronto di idee: l\'energia si scontra, usala per crescere, non per ferire.', reversedSummary: 'Il conflitto che stanca.', reversed: 'Tensioni inutili, o evitate: scegli le battaglie, lascia cadere il resto.', stem: 'tar_rw_bastoni_05_v1'),
    TarotCard(name: 'Sei di Bastoni', arcana: TarotArcana.minore, seme: TarotSeme.bastoni, number: 6, uprightSummary: 'La vittoria che sfila.', upright: 'Riconoscimento, successo meritato: il tuo sforzo è visto, accogli l\'onore con misura.', reversedSummary: 'Il merito non visto.', reversed: 'Un riconoscimento che tarda, un dubbio su di te: il valore resta anche quando l\'applauso non arriva.', stem: 'tar_rw_bastoni_06_v1'),
    TarotCard(name: 'Sette di Bastoni', arcana: TarotArcana.minore, seme: TarotSeme.bastoni, number: 7, uprightSummary: 'La posizione difesa.', upright: 'Tenere il punto, coraggio sotto pressione: difendi ciò in cui credi, hai la forza per reggere.', reversedSummary: 'La guardia stanca.', reversed: 'Ti senti sopraffatto, o troppo sulla difensiva: scegli dove vale resistere e dove lasciare.', stem: 'tar_rw_bastoni_07_v1'),
    TarotCard(name: 'Otto di Bastoni', arcana: TarotArcana.minore, seme: TarotSeme.bastoni, number: 8, uprightSummary: 'Le frecce nell\'aria.', upright: 'Velocità, notizie, eventi che accelerano: le cose si muovono in fretta, cavalca il ritmo.', reversedSummary: 'La corsa frenata.', reversed: 'Ritardi, o una fretta mal riposta: rallenta quel tanto che basta per non inciampare.', stem: 'tar_rw_bastoni_08_v1'),
    TarotCard(name: 'Nove di Bastoni', arcana: TarotArcana.minore, seme: TarotSeme.bastoni, number: 9, uprightSummary: 'L\'ultima resistenza.', upright: 'Tenacia, quasi al traguardo: sei stanco ma vicino, non mollare l\'ultimo tratto.', reversedSummary: 'La difesa irrigidita.', reversed: 'Diffidenza, o stanchezza che chiude: abbassa un poco lo scudo, non tutto è minaccia.', stem: 'tar_rw_bastoni_09_v1'),
    TarotCard(name: 'Dieci di Bastoni', arcana: TarotArcana.minore, seme: TarotSeme.bastoni, number: 10, uprightSummary: 'Il peso portato.', upright: 'Responsabilità, carico pesante: hai molto sulle spalle, chiediti cosa puoi posare.', reversedSummary: 'Il carico da alleggerire.', reversed: 'Un fardello che non è tuo: lascia andare ciò che porti per abitudine.', stem: 'tar_rw_bastoni_10_v1'),
    TarotCard(name: 'Fante di Bastoni', arcana: TarotArcana.minore, seme: TarotSeme.bastoni, number: 11, uprightSummary: 'Il messaggero ardente.', upright: 'Curiosità, entusiasmo nuovo: un\'idea giovane bussa, seguila con slancio.', reversedSummary: 'L\'entusiasmo disperso.', reversed: 'Impulsività, o uno slancio che si spegne: dai forma all\'energia prima che svanisca.', stem: 'tar_rw_bastoni_11_v1'),
    TarotCard(name: 'Cavaliere di Bastoni', arcana: TarotArcana.minore, seme: TarotSeme.bastoni, number: 12, uprightSummary: 'La corsa audace.', upright: 'Passione, azione, avventura: parti con coraggio, ma tieni un occhio alla meta.', reversedSummary: 'La foga incauta.', reversed: 'Impazienza, o slancio senza rotta: incanala l\'ardore, non bruciarlo.', stem: 'tar_rw_bastoni_12_v1'),
    TarotCard(name: 'Regina di Bastoni', arcana: TarotArcana.minore, seme: TarotSeme.bastoni, number: 13, uprightSummary: 'Il carisma caldo.', upright: 'Sicurezza, calore, magnetismo: brilla con generosità, la tua fiamma scalda gli altri.', reversedSummary: 'La fiamma insicura.', reversed: 'Un dubbio, o una gelosia che offusca: torna al tuo centro, la tua luce non ha rivali.', stem: 'tar_rw_bastoni_13_v1'),
    TarotCard(name: 'Re di Bastoni', arcana: TarotArcana.minore, seme: TarotSeme.bastoni, number: 14, uprightSummary: 'La visione che guida.', upright: 'Guida, ispirazione, volontà matura: apri strade con l\'esempio, la tua fiamma indica il cammino.', reversedSummary: 'Il comando impaziente.', reversed: 'Autorità rigida, o impulsiva: guida con ascolto, non solo con la forza.', stem: 'tar_rw_bastoni_14_v1'),
    TarotCard(name: 'Asso di Coppe', arcana: TarotArcana.minore, seme: TarotSeme.coppe, number: 1, uprightSummary: 'Il cuore che trabocca.', upright: 'Un amore nuovo, un\'emozione pura: apri il cuore, una fonte di sentimento sgorga.', reversedSummary: 'Il cuore trattenuto.', reversed: 'Emozioni chiuse, o un amore rimandato: concediti di sentire, l\'acqua vuole scorrere.', stem: 'tar_rw_coppe_01_v1'),
    TarotCard(name: 'Due di Coppe', arcana: TarotArcana.minore, seme: TarotSeme.coppe, number: 2, uprightSummary: 'L\'incontro dei cuori.', upright: 'Unione, patto d\'amore, armonia a due: un legame si sigilla, coltivalo con cura.', reversedSummary: 'L\'armonia incrinata.', reversed: 'Un malinteso, un equilibrio da ritrovare: parlatevi con il cuore, il legame si ricuce.', stem: 'tar_rw_coppe_02_v1'),
    TarotCard(name: 'Tre di Coppe', arcana: TarotArcana.minore, seme: TarotSeme.coppe, number: 3, uprightSummary: 'Il brindisi degli amici.', upright: 'Amicizia, festa, comunità: celebra insieme, la gioia condivisa raddoppia.', reversedSummary: 'La festa da riequilibrare.', reversed: 'Eccessi, o un cerchio da curare: torna alle amicizie vere, senza dispersione.', stem: 'tar_rw_coppe_03_v1'),
    TarotCard(name: 'Quattro di Coppe', arcana: TarotArcana.minore, seme: TarotSeme.coppe, number: 4, uprightSummary: 'L\'offerta non vista.', upright: 'Apatia, noia, un dono ignorato: alza lo sguardo, qualcosa di buono ti è teso.', reversedSummary: 'Il risveglio dell\'interesse.', reversed: 'Esci dal torpore, torni a sentire: una nuova apertura ti chiama, accoglila.', stem: 'tar_rw_coppe_04_v1'),
    TarotCard(name: 'Cinque di Coppe', arcana: TarotArcana.minore, seme: TarotSeme.coppe, number: 5, uprightSummary: 'Le coppe versate.', upright: 'Perdita, rimpianto, sguardo al passato: due coppe restano in piedi, voltati e vedile.', reversedSummary: 'Lo sguardo che si rialza.', reversed: 'Accettazione, perdono, ripresa: il dolore lascia posto alla speranza.', stem: 'tar_rw_coppe_05_v1'),
    TarotCard(name: 'Sei di Coppe', arcana: TarotArcana.minore, seme: TarotSeme.coppe, number: 6, uprightSummary: 'Il dono dell\'infanzia.', upright: 'Nostalgia, dolcezza, ricordi cari: un affetto sincero dal passato ti scalda.', reversedSummary: 'Il passato che trattiene.', reversed: 'Vivere di ricordi: onora ciò che è stato, poi torna al presente.', stem: 'tar_rw_coppe_06_v1'),
    TarotCard(name: 'Sette di Coppe', arcana: TarotArcana.minore, seme: TarotSeme.coppe, number: 7, uprightSummary: 'Le coppe dei sogni.', upright: 'Fantasie, molte scelte, illusioni: sogna pure, poi scegli con i piedi a terra.', reversedSummary: 'La nebbia che si dirada.', reversed: 'Chiarezza dopo la confusione: metti a fuoco un desiderio vero e seguilo.', stem: 'tar_rw_coppe_07_v1'),
    TarotCard(name: 'Otto di Coppe', arcana: TarotArcana.minore, seme: TarotSeme.coppe, number: 8, uprightSummary: 'La partenza silenziosa.', upright: 'Lasciare ciò che non nutre più, cercare un senso più alto: parti, il cuore sa dove.', reversedSummary: 'Il piede sulla soglia.', reversed: 'Indecisione tra restare e andare: ascoltati, saprai se è tempo di lasciare.', stem: 'tar_rw_coppe_08_v1'),
    TarotCard(name: 'Nove di Coppe', arcana: TarotArcana.minore, seme: TarotSeme.coppe, number: 9, uprightSummary: 'Il desiderio appagato.', upright: 'Soddisfazione, benessere, un augurio esaudito: goditi ciò che hai ottenuto.', reversedSummary: 'L\'appagamento vuoto.', reversed: 'Piaceri che non colmano: cerca la gioia vera, non solo quella di facciata.', stem: 'tar_rw_coppe_09_v1'),
    TarotCard(name: 'Dieci di Coppe', arcana: TarotArcana.minore, seme: TarotSeme.coppe, number: 10, uprightSummary: 'L\'arcobaleno della famiglia.', upright: 'Armonia affettiva, pienezza condivisa: l\'amore attorno a te è la tua ricchezza.', reversedSummary: 'L\'armonia da ricucire.', reversed: 'Tensioni negli affetti: torna al legame, la casa si ricompone col dialogo.', stem: 'tar_rw_coppe_10_v1'),
    TarotCard(name: 'Fante di Coppe', arcana: TarotArcana.minore, seme: TarotSeme.coppe, number: 11, uprightSummary: 'Il sognatore gentile.', upright: 'Sensibilità, un messaggio d\'amore, creatività: ascolta un\'emozione nuova che affiora.', reversedSummary: 'La sensibilità ferita.', reversed: 'Emotività fragile, o chiusa: proteggi il cuore senza murarlo.', stem: 'tar_rw_coppe_11_v1'),
    TarotCard(name: 'Cavaliere di Coppe', arcana: TarotArcana.minore, seme: TarotSeme.coppe, number: 12, uprightSummary: 'Il cuore in viaggio.', upright: 'Romanticismo, proposta, invito: segui il sentimento con grazia, offri il tuo cuore.', reversedSummary: 'Il sentimento incostante.', reversed: 'Promesse vaghe, o illusioni: verifica che le parole abbiano radici.', stem: 'tar_rw_coppe_12_v1'),
    TarotCard(name: 'Regina di Coppe', arcana: TarotArcana.minore, seme: TarotSeme.coppe, number: 13, uprightSummary: 'La cura profonda.', upright: 'Empatia, intuito, tenerezza: accogli e comprendi, la tua sensibilità è forza.', reversedSummary: 'L\'emozione che sommerge.', reversed: 'Ti perdi negli altri: riporta un poco di cura anche a te stessa.', stem: 'tar_rw_coppe_13_v1'),
    TarotCard(name: 'Re di Coppe', arcana: TarotArcana.minore, seme: TarotSeme.coppe, number: 14, uprightSummary: 'La calma del cuore.', upright: 'Equilibrio emotivo, saggezza affettiva: guida i sentimenti con serenità matura.', reversedSummary: 'L\'onda trattenuta.', reversed: 'Emozioni represse, o instabili: dai voce a ciò che senti, senza temerlo.', stem: 'tar_rw_coppe_14_v1'),
    TarotCard(name: 'Asso di Denari', arcana: TarotArcana.minore, seme: TarotSeme.denari, number: 1, uprightSummary: 'Il seme d\'oro.', upright: 'Un\'opportunità concreta, un inizio prospero: pianta il seme, il terreno è fertile.', reversedSummary: 'L\'occasione trascurata.', reversed: 'Un\'apertura persa, o un rischio mal valutato: guarda meglio ciò che hai davanti.', stem: 'tar_rw_denari_01_v1'),
    TarotCard(name: 'Due di Denari', arcana: TarotArcana.minore, seme: TarotSeme.denari, number: 2, uprightSummary: 'Il gioco d\'equilibrio.', upright: 'Gestire più cose, adattarsi: tieni il ritmo tra gli impegni con leggerezza.', reversedSummary: 'L\'equilibrio perso.', reversed: 'Troppe cose insieme: scegli le priorità prima di far cadere tutto.', stem: 'tar_rw_denari_02_v1'),
    TarotCard(name: 'Tre di Denari', arcana: TarotArcana.minore, seme: TarotSeme.denari, number: 3, uprightSummary: 'L\'opera comune.', upright: 'Collaborazione, competenza, primi risultati: costruisci insieme, il tuo lavoro è apprezzato.', reversedSummary: 'La collaborazione stonata.', reversed: 'Ruoli confusi, o poca sintonia: chiarite i compiti e l\'opera riparte.', stem: 'tar_rw_denari_03_v1'),
    TarotCard(name: 'Quattro di Denari', arcana: TarotArcana.minore, seme: TarotSeme.denari, number: 4, uprightSummary: 'La mano che stringe.', upright: 'Sicurezza, risparmio, controllo: proteggi ciò che hai, senza chiuderti troppo.', reversedSummary: 'La presa da allentare.', reversed: 'Attaccamento, o paura di perdere: apri la mano, il denaro serve per fluire.', stem: 'tar_rw_denari_04_v1'),
    TarotCard(name: 'Cinque di Denari', arcana: TarotArcana.minore, seme: TarotSeme.denari, number: 5, uprightSummary: 'Il freddo fuori dalla porta.', upright: 'Difficoltà, mancanza, senso di esclusione: la luce è vicina, chiedi aiuto senza vergogna.', reversedSummary: 'Il ritorno al caldo.', reversed: 'Ripresa, un sostegno ritrovato: il periodo duro si allenta, riaccogli la fiducia.', stem: 'tar_rw_denari_05_v1'),
    TarotCard(name: 'Sei di Denari', arcana: TarotArcana.minore, seme: TarotSeme.denari, number: 6, uprightSummary: 'La bilancia del dare.', upright: 'Generosità, scambio equo, aiuto: dai e ricevi con giustizia, l\'equilibrio guarisce.', reversedSummary: 'Il dare sbilanciato.', reversed: 'Debiti, o una generosità mal riposta: verifica che lo scambio sia davvero equo.', stem: 'tar_rw_denari_06_v1'),
    TarotCard(name: 'Sette di Denari', arcana: TarotArcana.minore, seme: TarotSeme.denari, number: 7, uprightSummary: 'L\'attesa del raccolto.', upright: 'Pazienza, valutazione, investimento lento: hai coltivato, ora aspetta il tempo giusto.', reversedSummary: 'La fretta del raccolto.', reversed: 'Impazienza, o uno sforzo mal ripagato: rivedi dove metti energia, senza scoraggiarti.', stem: 'tar_rw_denari_07_v1'),
    TarotCard(name: 'Otto di Denari', arcana: TarotArcana.minore, seme: TarotSeme.denari, number: 8, uprightSummary: 'La mano che affina.', upright: 'Impegno, mestiere, dedizione: perfeziona con cura, la maestria nasce dalla pratica.', reversedSummary: 'Il lavoro senz\'anima.', reversed: 'Monotonia, o poca cura: ritrova il senso di ciò che fai, oppure cambia direzione.', stem: 'tar_rw_denari_08_v1'),
    TarotCard(name: 'Nove di Denari', arcana: TarotArcana.minore, seme: TarotSeme.denari, number: 9, uprightSummary: 'Il giardino conquistato.', upright: 'Autonomia, agiatezza, frutti meritati: goditi ciò che hai costruito da te.', reversedSummary: 'L\'indipendenza da curare.', reversed: 'Insicurezza, o eccessi: ritrova l\'equilibrio tra il valore di te e quello del lavoro.', stem: 'tar_rw_denari_09_v1'),
    TarotCard(name: 'Dieci di Denari', arcana: TarotArcana.minore, seme: TarotSeme.denari, number: 10, uprightSummary: 'L\'eredità della casa.', upright: 'Ricchezza duratura, famiglia, radici solide: ciò che costruisci resta e nutre chi verrà.', reversedSummary: 'Le radici da rassodare.', reversed: 'Tensioni su beni, o in famiglia: cura ciò che dura, oltre il guadagno di oggi.', stem: 'tar_rw_denari_10_v1'),
    TarotCard(name: 'Fante di Denari', arcana: TarotArcana.minore, seme: TarotSeme.denari, number: 11, uprightSummary: 'Lo studente diligente.', upright: 'Apprendimento, un progetto concreto, una promessa: coltiva un\'idea nuova con serietà.', reversedSummary: 'La promessa rimandata.', reversed: 'Distrazione, o un progetto fermo: rimettiti al lavoro un passo alla volta.', stem: 'tar_rw_denari_11_v1'),
    TarotCard(name: 'Cavaliere di Denari', arcana: TarotArcana.minore, seme: TarotSeme.denari, number: 12, uprightSummary: 'Il passo costante.', upright: 'Metodo, affidabilità, impegno paziente: avanza con costanza, qui la lentezza è forza.', reversedSummary: 'Il passo bloccato.', reversed: 'Stallo, o eccesso di prudenza: muovi qualcosa, anche piccolo, per ripartire.', stem: 'tar_rw_denari_12_v1'),
    TarotCard(name: 'Regina di Denari', arcana: TarotArcana.minore, seme: TarotSeme.denari, number: 13, uprightSummary: 'La cura concreta.', upright: 'Accoglienza, praticità, abbondanza generosa: nutri chi ami e i tuoi progetti con i piedi a terra.', reversedSummary: 'La cura dispersa.', reversed: 'Ti dimentichi di te per gli altri: rimetti equilibrio tra dare e ricevere.', stem: 'tar_rw_denari_13_v1'),
    TarotCard(name: 'Re di Denari', arcana: TarotArcana.minore, seme: TarotSeme.denari, number: 14, uprightSummary: 'La prosperità sicura.', upright: 'Successo concreto, stabilità, generosità matura: guida con abbondanza e misura.', reversedSummary: 'Il possesso che irrigidisce.', reversed: 'Attaccamento, o rigidità: la vera ricchezza è anche saperla condividere.', stem: 'tar_rw_denari_14_v1'),
    TarotCard(name: 'Asso di Spade', arcana: TarotArcana.minore, seme: TarotSeme.spade, number: 1, uprightSummary: 'La lama della verità.', upright: 'Chiarezza, un\'idea netta, un taglio deciso: vedi con lucidità, è il momento di dire il vero.', reversedSummary: 'La lama confusa.', reversed: 'Idee annebbiate, o parole taglienti: rischiara la mente prima di decidere.', stem: 'tar_rw_spade_01_v1'),
    TarotCard(name: 'Due di Spade', arcana: TarotArcana.minore, seme: TarotSeme.spade, number: 2, uprightSummary: 'La scelta bendata.', upright: 'Indecisione, stallo, equilibrio precario: togli la benda, guarda ciò che eviti.', reversedSummary: 'La verità che riaffiora.', reversed: 'Un blocco che si scioglie: la decisione rimandata torna a chiederti una risposta.', stem: 'tar_rw_spade_02_v1'),
    TarotCard(name: 'Tre di Spade', arcana: TarotArcana.minore, seme: TarotSeme.spade, number: 3, uprightSummary: 'Il cuore trafitto.', upright: 'Dolore, delusione, una ferita: lascia scorrere le lacrime, il dolore attraversato guarisce.', reversedSummary: 'La ferita che rimargina.', reversed: 'Perdono, ripresa, un dolore che sfuma: la pioggia passa, il cuore torna a respirare.', stem: 'tar_rw_spade_03_v1'),
    TarotCard(name: 'Quattro di Spade', arcana: TarotArcana.minore, seme: TarotSeme.spade, number: 4, uprightSummary: 'Il riposo del guerriero.', upright: 'Pausa, recupero, silenzio: fermati e ricarica, la mente ha bisogno di quiete.', reversedSummary: 'Il risveglio dalla sosta.', reversed: 'Tempo di rimettersi in moto: hai riposato, ora torna con calma all\'azione.', stem: 'tar_rw_spade_04_v1'),
    TarotCard(name: 'Cinque di Spade', arcana: TarotArcana.minore, seme: TarotSeme.spade, number: 5, uprightSummary: 'La vittoria amara.', upright: 'Conflitto, orgoglio, un successo che costa: chiediti se vale ciò che perdi per vincere.', reversedSummary: 'La pace da ricucire.', reversed: 'Voglia di riconciliazione: deponi le armi, il perdono libera più della ragione.', stem: 'tar_rw_spade_05_v1'),
    TarotCard(name: 'Sei di Spade', arcana: TarotArcana.minore, seme: TarotSeme.spade, number: 6, uprightSummary: 'La traversata calma.', upright: 'Transizione, allontanarsi dalle acque agitate: verso una sponda più serena, un passo alla volta.', reversedSummary: 'La partenza difficile.', reversed: 'Fatica a lasciare il passato: il viaggio è possibile, anche se il distacco pesa.', stem: 'tar_rw_spade_06_v1'),
    TarotCard(name: 'Sette di Spade', arcana: TarotArcana.minore, seme: TarotSeme.spade, number: 7, uprightSummary: 'La strategia silenziosa.', upright: 'Astuzia, prudenza, agire con tatto: usa l\'ingegno, ma resta onesto con te stesso.', reversedSummary: 'Il gioco da chiarire.', reversed: 'Un inganno che pesa, o che si svela: torna alla trasparenza, libera la coscienza.', stem: 'tar_rw_spade_07_v1'),
    TarotCard(name: 'Otto di Spade', arcana: TarotArcana.minore, seme: TarotSeme.spade, number: 8, uprightSummary: 'La prigione dei pensieri.', upright: 'Sentirsi bloccato, limiti nella mente: le corde sono più larghe di quel che credi, muoviti.', reversedSummary: 'Le corde che cadono.', reversed: 'Liberazione, una via che si apre: riconosci la tua forza e fai il primo passo.', stem: 'tar_rw_spade_08_v1'),
    TarotCard(name: 'Nove di Spade', arcana: TarotArcana.minore, seme: TarotSeme.spade, number: 9, uprightSummary: 'L\'angoscia della notte.', upright: 'Ansia, pensieri cupi, insonnia: le paure crescono al buio, alla luce si ridimensionano.', reversedSummary: 'L\'alba dopo l\'incubo.', reversed: 'La paura che allenta la presa: parlane, condividi, il peso si dimezza.', stem: 'tar_rw_spade_09_v1'),
    TarotCard(name: 'Dieci di Spade', arcana: TarotArcana.minore, seme: TarotSeme.spade, number: 10, uprightSummary: 'La fine e la resa.', upright: 'Un ciclo doloroso che si chiude: hai toccato il fondo, da qui si può solo risalire.', reversedSummary: 'La risalita.', reversed: 'Ripresa, sollievo, il peggio alle spalle: l\'alba torna, rialzati con dolcezza.', stem: 'tar_rw_spade_10_v1'),
    TarotCard(name: 'Fante di Spade', arcana: TarotArcana.minore, seme: TarotSeme.spade, number: 11, uprightSummary: 'La mente curiosa.', upright: 'Vigilanza, idee acute, verità da cercare: osserva e informati, ma scegli le parole.', reversedSummary: 'La parola pungente.', reversed: 'Pettegolezzo, o pensieri sparsi: modera la lingua, verifica prima di parlare.', stem: 'tar_rw_spade_11_v1'),
    TarotCard(name: 'Cavaliere di Spade', arcana: TarotArcana.minore, seme: TarotSeme.spade, number: 12, uprightSummary: 'La carica del pensiero.', upright: 'Determinazione, azione rapida, idee decise: vai dritto allo scopo, senza travolgere.', reversedSummary: 'La foga imprudente.', reversed: 'Fretta, o parole affilate: rallenta, la lucidità vale più della velocità.', stem: 'tar_rw_spade_12_v1'),
    TarotCard(name: 'Regina di Spade', arcana: TarotArcana.minore, seme: TarotSeme.spade, number: 13, uprightSummary: 'La lucidità sincera.', upright: 'Intelligenza, onestà, confini chiari: pensa con nitore, la tua franchezza è un dono.', reversedSummary: 'La freddezza difensiva.', reversed: 'Durezza, o una solitudine scelta: ammorbidisci il giudizio, prima verso te stessa.', stem: 'tar_rw_spade_13_v1'),
    TarotCard(name: 'Re di Spade', arcana: TarotArcana.minore, seme: TarotSeme.spade, number: 14, uprightSummary: 'Il giudizio giusto.', upright: 'Autorità mentale, etica, verità: decidi con equità, la ragione al servizio del cuore.', reversedSummary: 'Il rigore senza cuore.', reversed: 'Freddezza, o autorità dura: unisci alla logica la compassione.', stem: 'tar_rw_spade_14_v1'),
  ];
}

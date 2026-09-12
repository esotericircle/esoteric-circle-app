import '../responsi/filo_della_voce.dart';
import '../rituals/animal_catalog.dart';
import 'vocabolario_del_viaggio.dart';

/// **LA SCENA CHE SI RIPORTA SU.** Ordine DC voce 06, 10 settembre 2026.
///
/// Tre elementi piu' il momento, scelti dal vocabolario chiuso: **il luogo
/// dove l'animale porta, cio' che si trova li', cosa fa l'animale**.
class ScenaDelViaggio {
  const ScenaDelViaggio({
    required this.luogo,
    required this.cosa,
    required this.gesto,
    required this.momento,
    required this.nitidezza,
    this.dalModello = false,
    this.chi = ChiAccompagna.laSagoma,
    this.impronta,
    this.conDomanda = true,
  });

  final PezzoDellaScena luogo;
  final PezzoDellaScena cosa;
  final PezzoDellaScena gesto;
  final PezzoDellaScena momento;

  /// **QUANTO E' NITIDA**, da 0 a 1. Ordine DC voce 08: un animale nutrito
  /// risponde nitido, uno trascurato risponde vago.
  final double nitidezza;

  /// Se i tre elementi li ha scelti il modello o la via deterministica.
  /// **Non si dice mai all'utente**: e' per il registro dei guasti.
  final bool dalModello;

  /// **CHI TI ACCOMPAGNA**, col suo nome dopo il riconoscimento e come
  /// sagoma prima. Ordine DI voce 04.
  final ChiAccompagna chi;

  /// **L'IMPRONTA DELLA DISCESA**: la domanda, il giorno e il numero della
  /// discesa da cui la scena e' nata. Entra nel filo delle parole.
  ///
  /// **Perche' serve, misurato.** La guardia della diversita' dell'ordine DF
  /// ha trovato due discese su cento, con la stessa domanda e lo stesso
  /// giorno, che pescavano gli stessi quattro pezzi: con il filo fatto dei
  /// soli pezzi, **dicevano la stessa frase parola per parola**. La voce del
  /// Mondo di Sotto fa gia' cosi' coi paragrafi, col giorno della discesa;
  /// qui la scena fa lo stesso. La stessa discesa, ricomposta, dice sempre la
  /// stessa cosa.
  final String? impronta;

  /// **SE LA PERSONA E' SCESA CON UNA DOMANDA.** Senza, le chiusure che la
  /// nominano non si usano: *"Tienila accanto alla tua domanda"* a chi e'
  /// sceso soltanto per incontrarlo parla di una domanda che non esiste.
  /// Trovato leggendo i responsi per intero, ordine DI voce 06.
  final bool conDomanda;

  /// **QUANTI ELEMENTI SI VEDONO DAVVERO.** Ordine DC voce 08: *"chi scende
  /// spesso riceve scene precise, con i tre elementi ben leggibili; chi torna
  /// dopo settimane trova nebbia fitta e una scena confusa, con un elemento
  /// solo visibile"*.
  ///
  /// **Non si toglie niente e non si punisce**: gli elementi ci sono tutti e
  /// tre, e quelli oltre la nitidezza si vedono in ombra. Cambia la
  /// leggibilita' della risposta, non il suo contenuto.
  int get quantiSiVedono {
    if (nitidezza >= NitidezzaDellaScena.nitida) return 3;
    if (nitidezza >= NitidezzaDellaScena.velata) return 2;
    return 1;
  }

  /// I pezzi leggibili, in ordine di importanza: **prima il gesto**, che e' la
  /// risposta vera, poi la cosa, poi il luogo.
  ///
  /// **Il gesto viene per primo apposta.** Se si vede un elemento solo, quello
  /// deve essere cio' che l'animale fa: e' la parte che risponde alla domanda.
  /// Un luogo senza gesto e' un paesaggio, non una risposta.
  List<PezzoDellaScena> get leggibili =>
      [gesto, cosa, luogo].take(quantiSiVedono).toList();

  /// **LE OTTO FORME DELLA SCENA INTERA**, con i tre elementi leggibili.
  ///
  /// **Perche' sono otto e prima era una.** Ordine DF voce 05, 11 settembre
  /// 2026: con una frase sola per grado di nitidezza, su cento consultazioni
  /// gli scheletri distinti erano **sei**.
  ///
  /// **RISCRITTE CON L'ORDINE DI, voci 04 e 05, 12 settembre 2026.** Tre
  /// difetti misurati, e tutti e tre stavano qui:
  ///
  /// - **l'animale non aveva nome**: era *"l'animale"* in tutte e otto, e il
  ///   Lupo e il Corvo producevano scene identiche parola per parola. Adesso
  ///   e' `{Chi}`, cioe' il suo nome con l'articolo giusto, e dove tornerebbe
  ///   due volte si alterna col pronome, `{Lui}`, mai con la parola generica;
  /// - **la persona ballava fra singolare e plurale**: *"Vi trovate al ponte.
  ///   Trovi la chiave."* Il plurale non aveva antecedente, perche' nessuno
  ///   aveva detto che l'animale ti accompagna. Adesso tutto e' in seconda
  ///   persona singolare, e l'unico plurale, *"Tu e {chi} siete"*, nomina il
  ///   compagno nella stessa frase;
  /// - **lo stesso verbo due volte**: *"Vi trovate ... Trovi"*. Nessuna forma
  ///   ripete un verbo, e nessuna usa un verbo che sta gia' in un gesto del
  ///   vocabolario (guardare, aspettare, fermarsi, mostrare), perche' il
  ///   gesto entra nella stessa forma. **E nessuna dice *ti porta***: accanto
  ///   alla figura *la porta chiusa* diventava *"ti porta... C'e' la porta
  ///   chiusa"*, e l'ha trovato la guardia della lingua. Adesso *ti guida*.
  ///
  /// **Il vocabolario non si tocca**: le quarantaquattro figure restano
  /// quelle. Cambia la frase che le cuce.
  static const List<String> formeIntere = [
    '{Chi} ti guida {aLuogo} {momento}. C\'è {cosa}. Lì {lui} {gesto}.',
    '{Momento} arrivi {aLuogo} insieme {aChi}. Davanti a te c\'è {cosa}. '
        '{Lui} {gesto}.',
    'La scena si apre {aLuogo}, {momento}. Trovi {cosa}. {Chi} {gesto}.',
    'Segui {chi} fino {aLuogo} {momento}. Ai tuoi piedi c\'è {cosa}. {Lui} '
        '{gesto}.',
    '{Momento} {chi} ti conduce {aLuogo}. C\'è {cosa}. Poi {lui} {gesto}.',
    'Tu e {chi} siete {aLuogo} {momento}, con {cosa} fra voi e il resto. '
        '{Lui} {gesto}.',
    'Ti ritrovi {aLuogo}. {Momento}. Accanto a te c\'è {cosa}. {Chi} {gesto}.',
    'Scendi fino {aLuogo} {momento}, dove incontri {cosa}. {Chi} {gesto}.',
  ];

  /// **LE OTTO FORME DELLA SCENA VELATA**, quando si leggono due elementi.
  ///
  /// **Qui c'era *"Non si capisce dove siete"***, un plurale senza compagno,
  /// e *"Del dove non resta niente. Resta"*, lo stesso verbo due volte.
  static const List<String> formeVelate = [
    '{Chi} ti guida dove c\'è {cosa}, ma il luogo non si distingue. {Lui} '
        '{gesto}.',
    'Del luogo non si vede niente. C\'è {cosa}. {Chi} {gesto}.',
    'La nebbia tiene il luogo per sé. Resta {cosa}. {Chi} {gesto}.',
    'Non capisci dove ti trovi. Distingui {cosa}. {Chi} {gesto}.',
    'Il posto resta indistinto. Quello che arriva è {cosa}. {Chi} {gesto}.',
    '{Chi} ti guida in un luogo che non si lascia vedere. C\'è {cosa}. {Lui} '
        '{gesto}.',
    'Del dove non rimane niente. Resta {cosa}. {Chi} {gesto}.',
    'Davanti a te c\'è {cosa}. Poco oltre {chi} {gesto}. Il luogo no.',
  ];

  /// **LE OTTO FORME DELLA SCENA CONFUSA**, quando si legge solo il gesto.
  ///
  /// **Qui c'era *"Di la' non torna quasi niente. Torna questo"***, lo stesso
  /// verbo a tre parole di distanza.
  static const List<String> formeConfuse = [
    '{Chi} {gesto}. Il resto rimane nella nebbia.',
    'Si vede una cosa sola: {chi} {gesto}.',
    'Della scena arriva soltanto questo: {chi} {gesto}.',
    'Tutto è confuso tranne una cosa. {Chi} {gesto}.',
    '{Chi} {gesto}. Intorno non si distingue niente.',
    'Resta il gesto e basta: {chi} {gesto}.',
    'La nebbia si apre su un attimo solo. {Chi} {gesto}.',
    'Di là non arriva quasi niente. Torna questo: {chi} {gesto}.',
  ];

  /// **LE DODICI APERTURE DELLA SCENA, e sono la seconda fessura.**
  ///
  /// **E SONO CORTE APPOSTA**, ordine DF: una frase di quattro parole non
  /// produce nessuna sequenza di cinque, che e' l'unita' con cui la misura C
  /// conta.
  ///
  /// **NESSUNA FINISCE COI DUE PUNTI, ordine DI voce 05.** Tre lo facevano,
  /// *"Quello che hai riportato su:"*, *"Dal Mondo di Sotto:"* e *"Quello che
  /// e' successo di la':"*, e dentro il blocco *da dove viene*, che finisce
  /// anche lui coi due punti, davano a schermo *"Da dove nasce: Quello che e'
  /// successo di la': Vi trovate al ponte"*. **E nessuna dice *"sei sceso"* o
  /// *"sei arrivato"***: chi legge puo' essere una donna, e il participio al
  /// maschile la cancellava.
  static const List<String> aperture = [
    'La discesa è compiuta.',
    'Di là c\'era questo.',
    'Ecco cosa hai visto.',
    'Questo hai riportato su.',
    'La nebbia si è scostata.',
    'Il tamburo ti ha lasciato qui.',
    'La galleria si è aperta.',
    'Sotto ti aspettava questo.',
    'Viene dal Mondo di Sotto.',
    'Il viaggio ti ha portato qui.',
    'Di là è successo questo.',
    'Sei in fondo alla galleria.',
  ];

  /// **LE DODICI CHIUSURE, e chiudono.** Ordine DI voce 06, 12 settembre 2026.
  ///
  /// **Com'erano.** La maggioranza diceva alla persona di non cercare di
  /// capire: *"Il senso arriva dopo"*, *"Niente da decifrare"*, *"Non
  /// tradurla"*, *"Non chiederle di piu'"*, *"Basta averla vista"*. **Una
  /// risposta che si chiude dicendo di non capirla si autoassolve**, e sono
  /// parole dell'ordine.
  ///
  /// **Adesso una chiusura fa una di tre cose**: riporta la persona alla sua
  /// domanda, consegna la scena come cosa da tenere, oppure dice quando
  /// rileggerla. **Due sole restano sul non decifrare subito**, le ultime,
  /// perche' nella tradizione il non tradurre subito ha un senso: ma sono
  /// l'eccezione, non la regola.
  static const List<String> chiusure = [
    'Tienila accanto alla tua domanda.',
    'Rileggila fra una settimana.',
    'Portala con te fino a stasera.',
    'Ripensaci quando la domanda torna.',
    'Conservala: è tua.',
    'Ci tornerai quando servirà.',
    'Rileggila fra un mese.',
    'Riguardala domattina, a mente fresca.',
    'Mettila vicino a quello che hai chiesto.',
    'Tienila a mente fino alla prossima discesa.',
    'Non tradurla subito: ricordala.',
    'Il senso arriva dopo.',
  ];

  /// **LE CHIUSURE PER CHI E' SCESO SENZA DOMANDA**: tutte tranne quelle che
  /// la nominano.
  static final List<String> chiusureSenzaDomanda = [
    for (final c in chiusure)
      if (!c.contains('domanda') && !c.contains('chiesto')) c,
  ];

  /// **QUANTE CHIUSURE POSSONO DIRE DI NON DECIFRARE**, al massimo. Ordine DI
  /// voce 06: due.
  static const int chiusureSulNonDecifrare = 2;

  /// **IL FILO DI QUESTA SCENA**, dai suoi quattro pezzi.
  FiloDellaVoce get _filo =>
      FiloDellaVoce.da([...idDeiPezzi, if (impronta != null) impronta!]);

  /// **LE TRE SCELTE, DALLO STESSO FILO E NELLO STESSO ORDINE DI SEMPRE**:
  /// la forma, poi l'apertura, poi la chiusura.
  ///
  /// **Il filo avanza a ogni scelta, ed e' il punto.** La prima stesura
  /// dell'ordine DI ricreava il filo per ogni pezzo: ogni scelta partiva dallo
  /// stesso seme, e l'apertura e la chiusura, dodici l'una, uscivano sempre
  /// appaiate. La guardia della diversita' dell'ordine DF l'ha presa subito:
  /// gli scheletri distinti su cento discese erano scesi da novantanove a
  /// sessantasei.
  (String, String, String) get _leTreScelte {
    final filo = _filo;
    final pezzi = leggibili.length;
    final forma = filo.scegli(pezzi == 1
        ? formeConfuse
        : pezzi == 2
            ? formeVelate
            : formeIntere);
    return (
      forma,
      filo.scegli(aperture),
      filo.scegli(conDomanda ? chiusure : chiusureSenzaDomanda),
    );
  }

  /// Il corpo della scena, senza apertura e senza chiusura.
  String _corpo(String forma) {
    String riempi(String forma) => forma
        .replaceAll('{aLuogo}', _a(luogo.nome))
        .replaceAll('{luogo}', luogo.nome)
        .replaceAll('{cosa}', cosa.nome)
        .replaceAll('{gesto}', gesto.nome)
        .replaceAll('{Momento}', _maiuscola(momento.nome))
        .replaceAll('{momento}', momento.nome)
        .replaceAll('{aChi}', _a(chi.conArticolo))
        .replaceAll('{Chi}', _maiuscola(chi.conArticolo))
        .replaceAll('{chi}', chi.conArticolo)
        .replaceAll('{Lui}', _maiuscola(chi.pronome))
        .replaceAll('{lui}', chi.pronome);
    return riempi(forma);
  }

  /// **LA SCENA CHE SI LEGGE DA SOLA**, con apertura e chiusura.
  String get testo {
    final (forma, apertura, chiusura) = _leTreScelte;
    return '$apertura ${_corpo(forma)} $chiusura';
  }

  /// **LA SCENA DENTRO UN'ALTRA FRASE, senza apertura.** Ordine DI voce 05:
  /// *"il testo della scena viene generato senza apertura quando e' destinato
  /// al blocco da dove viene, e le aperture restano solo dove la scena si
  /// legge da sola"*. Il blocco ha gia' la sua frase che introduce: una
  /// seconda introduzione dentro la prima e' il difetto dei due punti
  /// annidati.
  String get testoSenzaApertura {
    final (forma, _, chiusura) = _leTreScelte;
    return '${_corpo(forma)} $chiusura';
  }

  static String _maiuscola(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  /// Gli id dei pezzi, per il Diario e per la memoria.
  List<String> get idDeiPezzi => [luogo.id, cosa.id, gesto.id, momento.id];

  static String _a(String nome) {
    if (nome.startsWith('la ')) return 'alla ${nome.substring(3)}';
    if (nome.startsWith('il ')) return 'al ${nome.substring(3)}';
    if (nome.startsWith('lo ')) return 'allo ${nome.substring(3)}';
    if (nome.startsWith("l'")) return "all'${nome.substring(2)}";
    return 'a $nome';
  }
}

/// **CHI TI ACCOMPAGNA NELLA SCENA, e ha un nome.** Ordine DI voce 04,
/// 12 settembre 2026.
///
/// **Il difetto, misurato dall'ordine:** la composizione non riceveva
/// l'animale in nessuna forma, e nel testo era la parola generica *"l'animale"*.
/// Il Lupo e il Corvo producevano scene identiche parola per parola.
///
/// **PRIMA DEL RICONOSCIMENTO IL NOME NON SI DICE**, e questa non e' una
/// scelta di adesso: e' la regola dell'ordine DG, sorvegliata dalla guardia
/// `l_animale_resta_velato_ovunque`. Il nome arriva alla quarta discesa, e una
/// scena che lo scrivesse alla prima brucerebbe la rivelazione. Fino ad allora
/// l'animale e' **la sagoma**, che e' esattamente cio' che la persona ha visto
/// e seguito nell'incontro: una designazione vera, non la parola generica.
class ChiAccompagna {
  const ChiAccompagna({required this.conArticolo, required this.femminile});

  /// Il nome con il suo articolo: *il Lupo*, *l'Aquila*, *la sagoma*.
  final String conArticolo;

  /// Il genere, per il pronome.
  final bool femminile;

  /// **PRIMA DELLA QUARTA DISCESA**: la sagoma seguita nell'incontro.
  static const ChiAccompagna laSagoma =
      ChiAccompagna(conArticolo: 'la sagoma', femminile: true);

  /// **DOPO LA QUARTA**: l'animale, col suo nome e il suo articolo.
  factory ChiAccompagna.animale(GuideAnimal animale) => ChiAccompagna(
        conArticolo: '${animale.articolo}${animale.name}',
        femminile: animale.femminile,
      );

  /// Il pronome soggetto, per alternarsi col nome.
  String get pronome => femminile ? 'lei' : 'lui';
}

/// **I GESTI CHE NON APPARTENGONO A UN ANIMALE.** Ordine DI voce 04.
///
/// **Nasce dal nome.** Finche' nella scena c'era *"l'animale"*, nessuno
/// leggeva *"l'Aquila mostra i denti"*: con il nome scritto, la stessa figura
/// diventa un errore che si vede. **Il vocabolario non si tocca**, e qui non
/// si toglie niente al vocabolario: la composizione, sapendo chi scende con
/// la persona, non pesca i gesti che il suo corpo non sa fare.
///
/// Gli uccelli non hanno denti, non scavano e non si accucciano; la
/// Tartaruga e il Cervo non mostrano i denti; il Serpente non scava e non si
/// accuccia. Il Cavallo i denti li mostra davvero, e resta.
abstract final class GestiDellAnimale {
  static const Map<String, Set<String>> nonGliAppartengono = {
    'Aquila': {'mostra_i_denti', 'scava', 'si_accuccia'},
    'Corvo': {'mostra_i_denti', 'scava', 'si_accuccia'},
    'Falco': {'mostra_i_denti', 'scava', 'si_accuccia'},
    'Gufo': {'mostra_i_denti', 'scava', 'si_accuccia'},
    'Tartaruga': {'mostra_i_denti'},
    'Cervo': {'mostra_i_denti'},
    'Serpente': {'scava', 'si_accuccia'},
  };

  /// I gesti che [nome] puo' fare, in ordine di vocabolario.
  static List<PezzoDellaScena> di(String? nome) {
    final no = nonGliAppartengono[nome] ?? const <String>{};
    return [
      for (final g in VocabolarioDelViaggio.gesti)
        if (!no.contains(g.id)) g,
    ];
  }
}

/// **QUANTO E' NITIDA UNA SCENA, E DA COSA DIPENDE.** Ordine DC voce 08.
///
/// **La contropartita, che non e' accudimento fine a se' stesso.** Nella
/// tradizione l'animale di potere va onorato o si allontana. Nell'app questo
/// **non toglie niente a nessuno e non punisce**: cambia la **nitidezza della
/// risposta**, e si dichiara apertamente che e' cosi'.
abstract final class NitidezzaDellaScena {
  /// Sopra questa soglia si vedono tutti e tre gli elementi.
  static const double nitida = 0.66;

  /// Sopra questa se ne vedono due.
  static const double velata = 0.33;

  /// **DOPO QUANTI GIORNI L'ANIMALE COMINCIA AD ALLONTANARSI.**
  ///
  /// **Il numero lo propongo io, e la voce 08 lo chiede motivato.** Sette
  /// giorni: e' la settimana, l'unita' di tempo in cui una persona misura le
  /// proprie abitudini, ed e' la stessa soglia che la Meditazione usa per
  /// dire *"erano undici giorni"*. Sotto la settimana non e' trascuratezza,
  /// e' la vita.
  static const int dopoQuantiGiorniSiAllontana = 7;

  /// **E DOPO QUANTI E' COMPLETAMENTE VAGO.**
  ///
  /// Ventotto giorni, cioe' quattro settimane. **La curva scende piano**: chi
  /// manca dieci giorni perde poco, chi manca un mese trova un elemento solo.
  /// Un mese e' anche il tempo oltre il quale una persona ha davvero smesso,
  /// e allora la scena vaga e' la verita' e non una punizione.
  static const int quandoDiventaVago = 28;

  /// La nitidezza di chi non scende da [giorni].
  ///
  /// **Scende in modo lineare fra le due soglie**, invece che a scalini: un
  /// salto brusco al settimo giorno si legge come una punizione, una discesa
  /// continua si legge come una distanza che cresce.
  static double dopoGiorni(int giorni) {
    if (giorni <= dopoQuantiGiorniSiAllontana) return 1.0;
    if (giorni >= quandoDiventaVago) return 0.0;
    const arco = quandoDiventaVago - dopoQuantiGiorniSiAllontana;
    final passati = giorni - dopoQuantiGiorniSiAllontana;
    return (1.0 - passati / arco).clamp(0.0, 1.0);
  }

  /// **E IL NUTRIMENTO LA RIPORTA SU.** Ordine DC voce 08: il gesto breve del
  /// tamburo, sotto il minuto, riavvicina l'animale.
  ///
  /// Un nutrimento vale **sette giorni di vicinanza**, cioe' riporta la
  /// nitidezza dove sarebbe stata se si fosse sceso quel giorno: e' la
  /// contropartita giusta per un gesto da un minuto.
  static const int quantiGiorniValeUnNutrimento = 7;

  /// La riga che lo dichiara alla persona, senza rimproverare.
  static String? laRiga(double nitidezza) {
    if (nitidezza >= nitida) return null;
    if (nitidezza >= velata) {
      return 'La scena è velata: è passato tempo. Il tamburo lo richiama.';
    }
    return 'L\'animale è lontano e la scena resta confusa. '
        'Il tamburo lo richiama.';
  }
}

/// **CHI SCEGLIE I TRE ELEMENTI, quando il modello non risponde.**
/// Ordine DC voce 06.
///
/// **La via principale e' Gemini**, che legge la domanda, il riassunto della
/// memoria e la carta natale e sceglie dal vocabolario chiuso: il modello non
/// genera immagini, sceglie fra quelle che abbiamo disegnato.
///
/// **Questa e' la via di sotto**, e l'ordine la vuole cosi': *"se la scelta
/// del modello non arriva o non e' valida, si cade su una composizione
/// deterministica dal seme del giorno e dalla domanda, dichiarata nel registro
/// e mai all'utente come errore"*.
///
/// **Perche' deterministica e non casuale.** Due persone che scendono lo
/// stesso giorno con la stessa domanda devono trovare la stessa scena: e' la
/// differenza fra un oracolo e una slot machine, ed e' la stessa scelta gia'
/// fatta per l'Arcano del giorno.
/// **IL RICHIAMO: UNA SCENA CHE RIPRENDE UN ELEMENTO DI UNA SCENA PRIMA.**
/// Ordine DE voce 11, 11 settembre 2026.
///
/// *"Quando una scena viene composta, il modello riceve anche gli elementi
/// delle scene precedenti di quella persona, e quando ha senso ne riprende
/// uno: la porta chiusa trovata al ponte un mese fa che oggi e' socchiusa, la
/// ciotola rovesciata che oggi e' piena."*
///
/// **QUANTE SCENE INDIETRO GUARDO, e perche', che l'ordine chiede di
/// dichiarare: CINQUE.**
///
/// **Non novanta**, che e' quanto il Diario ne conserva: un elemento ripreso
/// da tre mesi fa non e' un richiamo, e' una coincidenza che nessuno
/// riconosce. Il richiamo funziona **solo se la persona si ricorda** di aver
/// visto quella cosa, e cio' che una persona ricorda di un'immagine simbolica
/// dura poche settimane.
///
/// **Non una o due**, che sarebbe l'ultima discesa: riprendere sempre
/// l'elemento di ieri farebbe del richiamo **una regola**, e una regola non e'
/// piu' un richiamo. L'ordine e' esplicito: *"il richiamo non e' obbligatorio
/// e non si forza. Una continuita' inventata vale meno di nessuna
/// continuita'."*
///
/// **Cinque discese sono, per chi scende due o tre volte a settimana, due
/// settimane**: dentro quell'arco la persona si ricorda, e l'elemento ripreso
/// si riconosce invece di sembrare pescato.
///
/// **E IL RICHIAMO NON E' OBBLIGATORIO.** Si prende un elemento di prima
/// **solo quando la composizione di oggi lo sceglierebbe comunque**: il seme
/// decide la scena, e il richiamo si limita a **dire** che quell'elemento
/// c'era gia'. Cosi' non si forza niente, e una continuita' inventata non
/// esiste per costruzione.
abstract final class IlRichiamoDelleScene {
  /// **QUANTE SCENE INDIETRO SI GUARDA.** Cinque.
  static const int quanteSceneIndietro = 5;

  /// **LE OTTO FORME DEL RICHIAMO.** `{cosa}` e' l'elemento che torna.
  ///
  /// **Nessuna promette un significato**, e nessuna dice **quante** volte e'
  /// tornato: un conteggio trasformerebbe il richiamo in una statistica, e la
  /// voce DC.04 ha gia' vietato i numeri da videogioco in questo dominio.
  static const List<String> forme = [
    // **RISCRITTE CON L'ORDINE DI VOCE 05.** Qui c'erano *"{Cosa} lo avevi
    // gia' trovato"* e *"Lo hai gia' visto, {cosa}"*: un pronome maschile
    // davanti a qualunque figura, e con *la chiave* diventava *"La chiave lo
    // avevi gia' trovato"*. E *"{Cosa} era gia' comparso"* aveva lo stesso
    // difetto nel participio. Adesso nessuna forma accorda qualcosa con la
    // figura che torna.
    'Di là avevi già trovato {cosa}.',
    'Non è la prima volta che incontri {cosa}.',
    'In una delle tue discese c\'era già {cosa}.',
    'Ti era già capitato di vedere {cosa}.',
    'Torna qualcosa di già noto: {cosa}.',
    '{Cosa} torna.',
    'Riconosci {cosa} da una discesa di prima.',
    'Il Mondo di Sotto ti rimanda {cosa}, un\'altra volta.',
  ];

  /// **LA RIGA DEL RICHIAMO**, oppure nulla quando non c'e' niente da
  /// riprendere.
  ///
  /// [precedenti] sono gli id dei pezzi delle scene di prima, dalla piu'
  /// recente. [oggi] sono gli id di quella appena composta.
  static String? laRiga({
    required List<List<String>> precedenti,
    required List<String> oggi,
    required String nomeDellElemento,
    required int quale,
  }) {
    final visti = <String>{};
    for (final scena in precedenti.take(quanteSceneIndietro)) {
      visti.addAll(scena);
    }
    if (quale < 0 || quale >= oggi.length) return null;
    if (!visti.contains(oggi[quale])) return null;
    final filo = FiloDellaVoce.da([...oggi, 'richiamo']);
    final forma = filo.scegli(forme);
    return forma
        .replaceAll('{Cosa}', _conMaiuscola(nomeDellElemento))
        .replaceAll('{cosa}', nomeDellElemento);
  }

  static String _conMaiuscola(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

abstract final class ScenaSenzaModello {
  /// **PERCHE' LA DISCESA ENTRA NEL SEME.** Ordine DF voce 05, 11 settembre
  /// 2026.
  ///
  /// **Il difetto, misurato con la prova della voce DF.02.** Il seme nasceva
  /// da **la domanda e il giorno**, e da nient'altro. Chi scendeva due volte
  /// nello stesso giorno con la stessa domanda **si riportava su la stessa
  /// identica scena**: stesso luogo, stessa cosa, stesso gesto, stesso
  /// momento, parola per parola. Su cento consultazioni con lo stesso ingresso
  /// le scene distinte erano **una**.
  ///
  /// **E non si poteva difendere con la giornata stabile**, che e' il primo
  /// chiarimento dell'ordine DF: *"la regola della giornata stabile riguarda e
  /// riguardava solo l'oroscopo perche' non c'e' domanda da parte
  /// dell'utente"*. Qui la domanda c'e', quindi ogni discesa e' un evento
  /// nuovo.
  ///
  /// **Il determinismo resta dove serve.** Con [discesa] dichiarata, la stessa
  /// discesa da' sempre la stessa scena: il Diario la rimette insieme dai suoi
  /// id e chi rilegge sei mesi dopo ritrova cio' che aveva letto. Quello che
  /// cambia e' che **due discese diverse sono due eventi diversi**, e il
  /// numero della discesa lo dice.
  ///
  /// **[animale] E [siPuoDire], ordine DI voce 04.** L'animale entra nella
  /// composizione come ingrediente: sceglie i gesti che il suo corpo sa fare,
  /// e dopo il riconoscimento da' il suo nome alla scena. Prima del
  /// riconoscimento la scena lo chiama *la sagoma*, perche' il nome si dice
  /// alla quarta discesa e non prima.
  static ScenaDelViaggio componi({
    required String domanda,
    required DateTime giorno,
    required double nitidezza,
    int discesa = 0,
    GuideAnimal? animale,
    bool siPuoDire = false,
    bool conDomanda = true,
  }) {
    final impronta = '$domanda|${giorno.year}-${giorno.month}-${giorno.day}'
        '|discesa$discesa';
    final seme = _seme(impronta);
    const luoghi = VocabolarioDelViaggio.luoghi;
    const cose = VocabolarioDelViaggio.cose;
    final gesti = GestiDellAnimale.di(animale?.name);
    const momenti = VocabolarioDelViaggio.momenti;
    // **Quattro divisori diversi**, cosi' le quattro scelte non si muovono
    // insieme: con un seme solo e lo stesso modulo, cambiando la domanda si
    // sposterebbero tutte e quattro nello stesso verso.
    final luogo = luoghi[seme % luoghi.length];
    // **E LA COSA NON RIPETE IL LUOGO**: *"ti conduce al cerchio di pietre.
    // C'e' il cerchio tracciato a terra"*, trovato dalla stessa guardia.
    var qualeCosa = (seme ~/ 13) % cose.length;
    for (var giri = 0;
        giri < cose.length && siRipetono(cose[qualeCosa], [luogo]);
        giri++) {
      qualeCosa = (qualeCosa + 1) % cose.length;
    }
    final cosa = cose[qualeCosa];
    final momento = momenti[(seme ~/ 2411) % momenti.length];
    // **IL GESTO NON RIPETE UNA PAROLA DELLE ALTRE FIGURE.** Ordine DI voce
    // 05: *"c'e' l'acqua ferma. Lei si ferma"* lo ha trovato la guardia della
    // lingua componendo le scene vere. Il vocabolario non si tocca, e le due
    // figure sono giuste da sole: e' la loro vicinanza a essere sbagliata, e
    // la vicinanza la decide la composizione. Si passa al gesto dopo.
    var quale = (seme ~/ 197) % gesti.length;
    for (var giri = 0;
        giri < gesti.length &&
            siRipetono(gesti[quale], [luogo, cosa, momento]);
        giri++) {
      quale = (quale + 1) % gesti.length;
    }
    return ScenaDelViaggio(
      luogo: luogo,
      cosa: cosa,
      gesto: gesti[quale],
      momento: momento,
      nitidezza: nitidezza,
      chi: animale != null && siPuoDire
          ? ChiAccompagna.animale(animale)
          : ChiAccompagna.laSagoma,
      impronta: impronta,
      conDomanda: conDomanda,
    );
  }

  /// **SE UNA FIGURA RIPETE UNA PAROLA PIENA DI UN'ALTRA**, da cinque lettere
  /// in su, cioe' quelle che portano il senso. Pubblica perche' la stessa
  /// regola deve valere per la scelta del modello, ordine DI voce 03.
  static bool siRipetono(PezzoDellaScena uno, List<PezzoDellaScena> altri) {
    Set<String> parole(String s) => RegExp(r'[a-zàèéìòù]{5,}')
        .allMatches(s.toLowerCase())
        .map((m) => m.group(0)!)
        .toSet();
    final sue = parole(uno.nome);
    return altri.any((a) => parole(a.nome).intersection(sue).isNotEmpty);
  }

  /// FNV-1a a 32 bit, la stessa famiglia gia' in uso nell'Oroscopo: stabile
  /// fra le versioni e fra i dispositivi, che e' cio' che serve qui.
  static int _seme(String s) {
    var h = 0x811c9dc5;
    for (final c in s.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0x7fffffff;
    }
    return h;
  }
}

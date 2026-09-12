import '../responsi/filo_della_voce.dart';
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
  /// 2026. La scena si componeva con **una frase sola per ogni grado di
  /// nitidezza**, cioe' tre stampi in tutto: su cento consultazioni con lo
  /// stesso ingresso gli scheletri distinti erano **sei**, e il piu' ripetuto
  /// tornava **cinquantasette volte**. Il fondatore: *"NON POSSONO ESSERE
  /// TUTTE UGUALI"*.
  ///
  /// **Il vocabolario non si tocca**: le quarantaquattro figure e le
  /// ottomilaseicentoquaranta combinazioni restano quelle. Quello che cambia
  /// e' **la frase che le cuce**, che prima era una.
  static const List<String> formeIntere = [
    'Ti porta {aLuogo} {momento}. C\'è {cosa}. L\'animale {gesto}.',
    '{Momento}, ti porta {aLuogo}. Lì trovi {cosa}. E l\'animale {gesto}.',
    'La scena si apre {aLuogo}, {momento}. C\'è {cosa}. E l\'animale {gesto}.',
    'Ti conduce {aLuogo} {momento}. Davanti a te {cosa}. L\'animale {gesto}.',
    '{Momento} l\'animale ti porta {aLuogo}. C\'è {cosa}: lui {gesto}.',
    'Siete {aLuogo}, {momento}. Fra voi e il resto c\'è {cosa}. L\'animale '
        '{gesto}.',
    'Ti porta {aLuogo}. {Momento}. E c\'è {cosa}. L\'animale {gesto}.',
    'Vi trovate {aLuogo} {momento}. Trovi {cosa}. E l\'animale {gesto}.',
  ];

  /// **LE OTTO FORME DELLA SCENA VELATA**, quando si leggono due elementi.
  static const List<String> formeVelate = [
    'Ti porta dove c\'è {cosa}. L\'animale {gesto}, ma il luogo non si '
        'distingue.',
    'Del luogo non si vede niente. C\'è {cosa}. E l\'animale {gesto}.',
    'La nebbia tiene il luogo. Resta {cosa}. E l\'animale che {gesto}.',
    'Non si capisce dove siete. Si vede {cosa}. E l\'animale {gesto}.',
    'Il posto resta indistinto. Quello che arriva è {cosa}. E l\'animale '
        '{gesto}.',
    'Ti porta in un luogo che non si lascia guardare. C\'è {cosa}. '
        'L\'animale {gesto}.',
    'Del dove non resta niente. Resta {cosa}. E l\'animale {gesto}.',
    'Si vede {cosa} e si vede l\'animale che {gesto}. Il luogo no.',
  ];

  /// **LE OTTO FORME DELLA SCENA CONFUSA**, quando si legge solo il gesto.
  static const List<String> formeConfuse = [
    'L\'animale {gesto}. Il resto resta nella nebbia.',
    'Si vede una cosa sola: l\'animale {gesto}.',
    'Della scena arriva soltanto questo: l\'animale {gesto}.',
    'Tutto è confuso tranne una cosa. L\'animale {gesto}.',
    'L\'animale {gesto}. E intorno non si distingue niente.',
    'Resta il gesto e basta: l\'animale {gesto}.',
    'La nebbia si apre su un attimo solo. L\'animale {gesto}.',
    'Di là non torna quasi niente. Torna questo: l\'animale {gesto}.',
  ];

  /// **LE OTTO APERTURE DELLA SCENA, e sono la seconda fessura.**
  ///
  /// **Il numero che le ha fatte nascere.** Con una fessura sola, cioe' la
  /// forma della scena, gli scheletri distinti su cento consultazioni erano
  /// **quarantasei**, contro una soglia di novanta: con otto forme non si
  /// possono avere piu' di otto scheletri.
  ///
  /// **E SONO CORTE APPOSTA, che e' la parte interessante.** La prima stesura
  /// le aveva scritte lunghe, una frase intera l'una, e la misura B era
  /// salita a novantotto mentre la misura C era peggiorata dal ventotto al
  /// quarantanove per cento: **piu' impalcatura vuol dire piu' forme e piu'
  /// parole in comune**, e le due misure tirano in versi opposti.
  ///
  /// **La via che le soddisfa tutte e due e' tante forme corte.** Una frase di
  /// quattro parole non produce **nessuna sequenza di cinque**, che e' l'unita'
  /// con cui la misura C conta: due scene che aprono con la stessa apertura
  /// corta non si somigliano per questo. **Dodici per otto per dodici fanno
  /// millecentocinquantadue forme**, e il vocabolario chiuso delle
  /// quarantaquattro figure resta intoccato, com'e' materiale dell'ordine DC
  /// voce 06.
  static const List<String> aperture = [
    'Sei sceso.',
    'Di là c\'era questo.',
    'Ecco cosa hai visto.',
    'Quello che hai riportato su:',
    'La nebbia si è scostata.',
    'Il tamburo ti ha lasciato qui.',
    'La galleria si è aperta.',
    'Sotto ti aspettava questo.',
    'Dal Mondo di Sotto:',
    'Il viaggio ti ha portato qui.',
    'Quello che è successo di là:',
    'Sei arrivato in fondo.',
  ];

  /// **LE DODICI CHIUSURE, corte anche loro, e sono la terza fessura.**
  ///
  /// Nessuna spiega la scena, ed e' voluto: la voce DC.06 vuole che il senso
  /// nasca dalla combinazione, non da una glossa.
  static const List<String> chiusure = [
    'Portala su così com\'è.',
    'Il senso arriva dopo.',
    'Non tradurla: ricordala.',
    'Lasciala posare.',
    'Niente da decifrare.',
    'Vale per come l\'hai vista.',
    'Rileggila fra un mese.',
    'Tienila a mente.',
    'Il resto viene da sé.',
    'Non chiederle di più.',
    'Ci tornerai.',
    'Basta averla vista.',
  ];

  /// **IL FILO DI QUESTA SCENA**, dai suoi quattro pezzi.
  FiloDellaVoce get _filo => FiloDellaVoce.da(idDeiPezzi);

  /// Il testo della scena, con gli elementi che si vedono.
  String get testo {
    final pezzi = leggibili;
    final filo = _filo;
    String riempi(String forma) => forma
        .replaceAll('{aLuogo}', _a(luogo.nome))
        .replaceAll('{luogo}', luogo.nome)
        .replaceAll('{cosa}', cosa.nome)
        .replaceAll('{gesto}', gesto.nome)
        .replaceAll('{Momento}', _maiuscola(momento.nome))
        .replaceAll('{momento}', momento.nome);
    final corpo = pezzi.length == 1
        ? riempi(filo.scegli(formeConfuse))
        : pezzi.length == 2
            ? riempi(filo.scegli(formeVelate))
            : riempi(filo.scegli(formeIntere));
    return '${filo.scegli(aperture)} $corpo ${filo.scegli(chiusure)}';
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
    '{Cosa} lo avevi già trovato di là.',
    'Questa non è la prima volta che incontri {cosa}.',
    '{Cosa} era già comparso in una delle tue discese.',
    'Ti era già capitato di vedere {cosa}.',
    'Non è nuovo: {cosa} lo avevi già incontrato.',
    '{Cosa} torna.',
    'Lo hai già visto, {cosa}.',
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
  static ScenaDelViaggio componi({
    required String domanda,
    required DateTime giorno,
    required double nitidezza,
    int discesa = 0,
  }) {
    final seme = _seme('$domanda|${giorno.year}-${giorno.month}-${giorno.day}'
        '|discesa$discesa');
    const luoghi = VocabolarioDelViaggio.luoghi;
    const cose = VocabolarioDelViaggio.cose;
    const gesti = VocabolarioDelViaggio.gesti;
    const momenti = VocabolarioDelViaggio.momenti;
    // **Quattro divisori diversi**, cosi' le quattro scelte non si muovono
    // insieme: con un seme solo e lo stesso modulo, cambiando la domanda si
    // sposterebbero tutte e quattro nello stesso verso.
    return ScenaDelViaggio(
      luogo: luoghi[seme % luoghi.length],
      cosa: cose[(seme ~/ 13) % cose.length],
      gesto: gesti[(seme ~/ 197) % gesti.length],
      momento: momenti[(seme ~/ 2411) % momenti.length],
      nitidezza: nitidezza,
    );
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

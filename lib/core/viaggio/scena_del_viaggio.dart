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

  /// Il testo della scena, con gli elementi che si vedono.
  String get testo {
    final pezzi = leggibili;
    if (pezzi.length == 1) {
      return 'L\'animale ${gesto.nome}. Il resto resta nella nebbia.';
    }
    if (pezzi.length == 2) {
      return 'Ti porta dove c\'è ${cosa.nome}, e ${gesto.nome}. '
          'Il luogo non si distingue.';
    }
    return 'Ti porta ${_a(luogo.nome)} ${momento.nome}. C\'è ${cosa.nome}, '
        'e l\'animale ${gesto.nome}.';
  }

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
abstract final class ScenaSenzaModello {
  static ScenaDelViaggio componi({
    required String domanda,
    required DateTime giorno,
    required double nitidezza,
  }) {
    final seme = _seme('$domanda|${giorno.year}-${giorno.month}-${giorno.day}');
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

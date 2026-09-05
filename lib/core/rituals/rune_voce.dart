/// LA VOCE DELLA RUNA E IL VERSO DELLE NORNE, deterministici.
///
/// **La lettura non e' la scheda della runa: e' la runa dentro la domanda e
/// dentro il giorno.** Si compone senza AI da quattro dati, persona, giorno,
/// domanda e runa uscita, e si aggancia al cielo VERO che l'app gia' calcola:
/// il segno solare da `NightSky.sunSign` e la Luna da `MoonPhase.forDate`,
/// le porte che esistono, nessuna nuova. Cosi' la stessa runa parla in modo
/// diverso a due persone senza che nulla venga inventato.
///
/// **Vale la lezione dell'Oroscopo: sopra un fatto si apre un ventaglio di
/// DIZIONE, mai di sostanza.** La sostanza e' il verso della runa dal
/// catalogo e la materia attestata dal corpus; il ventaglio e' come la frase
/// si apre, si lega e si chiude, scelto con l'hash FNV che l'Oroscopo gia'
/// usa, mai con un caso vero.
library;

import '../astro/moon_phase.dart';
import '../astro/night_sky.dart';
import 'rune_cast.dart';
import 'rune_lore.g.dart';

/// Il testo per il pannello Fonti e metodo, per quello che questa voce
/// aggiunge: le strofe dei poemi, il loro conto esatto e la Voce della Runa.
const String kRuneFontiPoemi =
    "Le strofe. Il Futhark antico a ventiquattro rune non ha un poema "
    "proprio: i tre poemi runici superstiti coprono i suoi discendenti. "
    "L'Old English Rune Poem (manoscritto Cotton Otho B.x, edizione Bruce "
    "Dickins 1915) copre il Futhorc anglosassone, che continua tutte e "
    "ventiquattro le rune antiche; l'Old Icelandic Rune Poem e l'Old "
    "Norwegian Rune Rhyme coprono il Futhark recente a sedici. Quindici "
    "delle ventiquattro hanno il trittico completo; nove hanno la sola "
    "strofa anglosassone, perché il Futhark recente le aveva perse; per "
    "quelle non si inventa niente. Ogni strofa parla della runa discendente, "
    "col suo nome anglosassone o norreno, non dell'antica. Le traduzioni "
    "italiane sono nostre.\n\n"
    "La Voce della Runa. La lettura personale si compone in modo "
    "deterministico da chi sei, dal giorno e dalla tua domanda, agganciata "
    "al cielo calcolato del giorno. È curatela di Caligo, non tradizione: "
    "sopra lo stesso fatto cambia la dizione, mai la sostanza.";

/// Il motore della Voce.
class RuneVoce {
  const RuneVoce._();

  /// L'hash FNV-1a, lo stesso disegno dell'Oroscopo: stesso dato, stessa
  /// voce, nessun caso vero.
  static int _fnv(String s) {
    var h = 0x811c9dc5;
    for (final c in s.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0x7fffffff;
    }
    return h;
  }

  /// LE APERTURE, e non annunciano piu' la riga della runa. Ordine S voce 24.
  ///
  /// **Il difetto, visto nell'anteprima.** Dicevano "Nel tuo giorno, questa pietra
  /// dice:" e subito dopo la voce ricopiava [RunaGettata.riga], che la scheda mostra
  /// GIA' due centimetri sopra, nella sua bolla. La stessa frase due volte nella
  /// stessa scheda: chi legge la seconda volta pensa di aver perso il segno.
  ///
  /// Adesso l'apertura introduce cio' che la voce AGGIUNGE, cioe' la materia antica e
  /// il cielo di oggi, e la riga resta dove stava, una volta sola.
  static const List<String> _aperture = [
    'Oggi questa pietra viene da lontano:',
    'Nel tuo giorno porta con sé la sua storia:',
    'La sua radice è antica:',
    'Ascolta da dove viene:',
  ];

  static const List<String> _pontiCielo = [
    'Il cielo di oggi le fa eco,',
    'Sopra di te, intanto,',
    'E il cielo accompagna,',
    'Il giorno la sostiene,',
  ];

  static const List<String> _chiuse = [
    'Portala con te fino a sera.',
    'Tienila accesa nel pensiero.',
    'Lasciala lavorare in silenzio.',
    'Torna a guardarla quando esiti.',
  ];

  /// LA VOCE DELLA RUNA: la runa dentro la domanda e dentro il giorno.
  ///
  /// La sostanza viene dal catalogo, [RunaGettata.riga], e dalla materia
  /// attestata del corpus; la domanda entra come eco dichiarata; il cielo
  /// entra dalle porte vere. Due letture con gli stessi dati sono identiche;
  /// cambia il giorno e cambia la voce.
  static String voce({
    required RunaGettata runa,
    required String persona,
    required DateTime giorno,
    required String domanda,
    /// Quale delle rune della gettata e', da zero.
    ///
    /// **Serve perche' l'eco della domanda non si ripeta, ordine CQ voce
    /// 6.16, 4 settembre 2026.** Il fondatore ha mandato gli screenshot di
    /// una gettata a tre rune: la frase *Dentro la tua domanda, e' qui che
    /// guarda* compariva **identica su tutte e tre**, e una formula ripetuta
    /// tre volte in una schermata smette di essere una risposta.
    int indice = 0,
  }) {
    final chiave = '$persona|${giorno.year}-${giorno.month}-${giorno.day}'
        '|$domanda|${runa.rune.name}|${runa.verso.name}';
    final h = _fnv(chiave);

    final apertura = _aperture[h % _aperture.length];
    final ponte = _pontiCielo[(h >> 4) % _pontiCielo.length];
    final chiusa = _chiuse[(h >> 8) % _chiuse.length];

    final lore = kRuneLore[runa.rune.name];
    final materia = lore == null ? '' : ' ${_senzaFonte(lore.materia)}.';

    // IL CIELO VERO, dalle porte che esistono: il segno che il Sole
    // attraversa oggi e la Luna come sta.
    final segno = NightSky.sunSign(giorno);
    final luna = MoonPhase.forDate(giorno);
    // **LA LUNA SI DICE COME SI DICE, ordine CQ voce 6.14.**
    //
    // Qui c'era `luna.italianName.toLowerCase()`, che per l'ultimo quarto
    // da' *ultimo quarto*: attaccato a "e la" usciva a video **"e la ultimo
    // quarto"**, e il fondatore lo ha letto tre volte nello stesso responso.
    //
    // `MoonPhase.comeSiDice` esiste esattamente per questo e dice
    // *all'ultimo quarto*: **la porta giusta c'era e nessuno ci passava.**
    // Cambia anche l'articolo, perche' "e la all'ultimo quarto" sarebbe
    // sgrammaticato quanto prima.
    final cielo = '$ponte col Sole in ${segno.italianName} e la Luna '
        '${MoonPhase.comeSiDice(luna.italianName)}.';

    // **E LA DOMANDA SI NOMINA, UNA VOLTA SOLA. Ordine CQ voce 6.16.**
    //
    // Qui c'era una formula che diceva *dentro la tua domanda* senza mai
    // dire quale, e la ripeteva su ogni runa. Adesso la prima runa riporta
    // **la domanda com'e' stata scritta**, cosi' chi legge vede che e' stata
    // letta; le altre tacciono, perche' l'ha gia' detto la prima.
    final pulita = domanda.trim();
    final eco = pulita.isEmpty || indice != 0
        ? ''
        : ' Tu hai chiesto: «$pulita» ed è lì che questa '
            'runa guarda.';

    // **LA RIGA DELLA RUNA NON SI RIPETE QUI, ordine S voce 24.** La scheda la
    // mostra nella sua bolla, sopra questa voce: ricopiarla faceva leggere la
    // stessa frase due volte nello stesso riquadro. Se la materia manca (una runa
    // senza lore), l'apertura resterebbe appesa, quindi in quel caso si salta.
    final corpo = materia.isEmpty ? '' : '$apertura${materia.trimRight()}';
    return [corpo, '$cielo$eco', chiusa]
        .where((p) => p.trim().isNotEmpty)
        .join(' ');
  }

  /// **LA VOCE IN DUE PEZZI: cio' che risponde e cio' da dove nasce.**
  /// Ordine CQ voce 6.19, 4 settembre 2026.
  ///
  /// **Il fatto, misurato sugli screenshot del fondatore.** Una scheda di
  /// runa porta **611 caratteri**: la gettata a tre ne fa 1833, la Croce
  /// delle Cinque 3055. E' una parete, e il fondatore la legge da tre
  /// ordini.
  ///
  /// **La porta c'era e valeva solo per la runa sola**, per una decisione
  /// che avevo preso io scrivendo che a tre e a cinque quel testo *e' il
  /// corpo della lettura*. Gli screenshot dicono di no.
  ///
  /// **Cosa resta fuori e cosa entra.** Fuori il cielo con la domanda, che
  /// e' la risposta a chi ha chiesto; dentro la materia storica, che e' la
  /// FONTE, e la legge dei testi vuole la fonte breve e in fondo.
  static ({String risposta, String daDoveNasce}) inDuePezzi({
    required RunaGettata runa,
    required String persona,
    required DateTime giorno,
    required String domanda,
    int indice = 0,
  }) {
    final intera = voce(
        runa: runa,
        persona: persona,
        giorno: giorno,
        domanda: domanda,
        indice: indice);
    // La materia comincia con un'apertura del corpus e finisce dove comincia
    // il ponte al cielo: si taglia sul ponte, che e' un dato di questa
    // classe e non una stringa indovinata.
    for (final ponte in _pontiCielo) {
      final dove = intera.indexOf(ponte);
      if (dove < 0) continue;
      return (
        risposta: intera.substring(dove).trim(),
        daDoveNasce: intera.substring(0, dove).trim(),
      );
    }
    // Nessun ponte riconosciuto: **non si indovina un taglio**, si tiene
    // tutto come risposta. Meglio una scheda lunga di una tagliata a caso.
    return (risposta: intera, daDoveNasce: '');
  }

  /// La materia senza la coda della fonte: la fonte sta nel pannello Fonti,
  /// non dentro la frase personale, come la voce dell'ordine chiede.
  static String _senzaFonte(String materia) {
    final taglio = materia.indexOf('. Fonte:');
    var testo = taglio < 0 ? materia : materia.substring(0, taglio);
    if (testo.endsWith('.')) testo = testo.substring(0, testo.length - 1);
    return testo;
  }

  /// LE GIUNTURE DEL VERSO DELLE NORNE.
  ///
  /// Nella stesa a tre le letture non restano tre blocchi staccati: si
  /// legano con connettivi deterministici che variano su giorno E posizione,
  /// mai su un asse solo. Le tre liste sono DISGIUNTE per costruzione:
  /// nella stessa stesa due giunture non possono coincidere.
  static const List<List<String>> _giunture = [
    [
      'Urdhr apre il filo, da ciò che fu:',
      'Il filo parte dal pozzo di ciò che fu:',
      'Prima parla il già vissuto:',
      'Dal fondo del pozzo, ciò che fu:',
    ],
    [
      'E il filo attraversa il tuo adesso:',
      'Da lì il filo entra nel tuo presente:',
      'Verdhandi lo intreccia a ciò che diviene:',
      'Il filo passa per le tue mani, ora:',
    ],
    [
      'Infine Skuld tende il filo in avanti:',
      'E il filo corre verso ciò che sarà:',
      'Il capo del filo tocca il domani:',
      'Skuld lo annoda a ciò che deve ancora venire:',
    ],
  ];

  /// Le tre giunture del giorno, una per posizione.
  static List<String> giuntureNorne(DateTime giorno) {
    return [
      for (var posizione = 0; posizione < 3; posizione++)
        _giunture[posizione][_fnv('${giorno.year}-${giorno.month}-'
                '${giorno.day}|norne|$posizione') %
            _giunture[posizione].length],
    ];
  }
}

/// LA RISPOSTA DEL SIGILLO, dall'intreccio delle rune gettate.
///
/// **Ordine CQ voce 6.17, 4 settembre 2026.** Parole del fondatore: *"anche il
/// sigillo del giorno dovrebbe portare una risposta alla domanda che nasce
/// dall'intreccio delle rune gettate."*
///
/// **Il Sigillo diceva solo cosa E'**: le rune strette in un segno, e cosa ti
/// resta. Vero, e non era una risposta. Le tre rune che si intrecciano sono le
/// stesse tre che hai letto una per una, e messe insieme dicono qualcosa che
/// nessuna dice da sola: **e' questo che il Sigillo puo' rispondere.**
///
/// **Deterministica come tutto il resto di questo motore**: stesse rune, stessa
/// domanda, stesso giorno danno sempre la stessa riga. Nessun modello, nessuna
/// rete: le parole chiave vengono dal corpus delle rune, il legame da un
/// elenco dichiarato qui sotto.
abstract final class SigilloDelGiorno {
  /// I modi in cui tre parole chiave si legano in una riga sola.
  ///
  /// **Sono quattro e non uno**, perche' una formula sola letta ogni giorno
  /// diventa rumore: e' lo stesso motivo per cui la voce della runa ha le sue
  /// aperture. Il numero e' basso di proposito: sotto c'e' il corpus, non
  /// queste righe.
  static const List<String> _legami = [
    'tenute insieme dicono una cosa sola',
    'intrecciate diventano una direzione',
    'lette come un segno solo indicano',
    'strette in un glifo portano',
  ];

  /// La riga che il Sigillo mostra sotto il disegno.
  ///
  /// Senza domanda torna la riga che dice a cosa serve il segno, che resta
  /// giusta: chi non ha chiesto niente non deve leggere una risposta a una
  /// domanda che non ha fatto.
  static String riga({
    required List<String> paroleChiave,
    required String domanda,
    required DateTime giorno,
  }) {
    const senzaDomanda = 'Le rune di questa gettata strette in un segno '
        'solo: è ciò che ti resta quando i testi si dimenticano.';
    final pulita = domanda.trim();
    final chiavi = paroleChiave
        .map((k) => k.trim().toLowerCase())
        .where((k) => k.isNotEmpty)
        .toList();
    if (pulita.isEmpty || chiavi.isEmpty) return senzaDomanda;

    // Lo stesso mescolatore della voce della runa, cosi' il Sigillo e le
    // schede non divergono mai su cosa considerano "lo stesso giorno".
    var h = 0x811c9dc5;
    for (final code in '$pulita|${giorno.year}-${giorno.month}-'
            '${giorno.day}|${chiavi.join("-")}'
        .codeUnits) {
      h = (h ^ code) & 0xFFFFFFFF;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    final legame = _legami[h % _legami.length];
    final elenco = chiavi.length == 1
        ? chiavi.first
        : '${chiavi.take(chiavi.length - 1).join(", ")} e ${chiavi.last}';
    return 'Alla tua domanda, «$pulita», il segno risponde con quello che '
        'le rune portano insieme: $elenco, $legame. È questo che ti resta '
        'quando i testi si dimenticano.';
  }
}

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
    final cielo = '$ponte col Sole in ${segno.italianName} e la '
        '${luna.italianName.toLowerCase()}.';

    final eco = domanda.trim().isEmpty
        ? ''
        : ' Dentro la tua domanda, è qui che guarda.';

    // **LA RIGA DELLA RUNA NON SI RIPETE QUI, ordine S voce 24.** La scheda la
    // mostra nella sua bolla, sopra questa voce: ricopiarla faceva leggere la
    // stessa frase due volte nello stesso riquadro. Se la materia manca (una runa
    // senza lore), l'apertura resterebbe appesa, quindi in quel caso si salta.
    final corpo = materia.isEmpty ? '' : '$apertura${materia.trimRight()}';
    return [corpo, '$cielo$eco', chiusa]
        .where((p) => p.trim().isNotEmpty)
        .join(' ');
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

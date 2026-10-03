import 'dart:math' as math;

import '../maestro/consiglio_finale.dart';
import '../maestro/seguito_della_lettura.dart';

/// Perche' una riga d'oro non arriva a schermo.
enum RigaTolta {
  /// La persona si e' presentata o ha chiesto chi e' il Maestro, o chi sono
  /// gli altri: non c'e' un passo da dare.
  presentazione,

  /// La riga chiede di rifare il passo che la persona ha appena detto di aver
  /// fatto.
  passoGiaFatto,

  /// La riga e' uguale o simile a una gia' data nella conversazione.
  giaData,
}

/// **LA RIGA D'ORO CHE NON VA DATA.** Ordine EQ voce 01, 27 settembre 2026.
///
/// **Il fatto, dalle catture del fondatore della chat di Calìgo.** La stessa
/// riga, *"Scrivi su un foglio di carta bianca tre cose che vorresti
/// realizzare"*, sotto la presentazione (*"Ciao, chi sei? Come puoi
/// aiutarmi?"*), sotto la domanda sull'amore e il lavoro, nel LIVE dopo
/// *"Ok, gli ho scritto adesso."* e sotto *"Ok, le ho scritte e adesso cosa
/// faccio?"*: quattro righe d'oro, tre ripetute, una sotto una presentazione,
/// due che chiedevano di rifare il passo appena fatto.
///
/// **L'istruzione lo diceva gia'.** *"Non ripetere mai una riga con ✦ già
/// scritta"* sta nel consiglio finale dall'ordine EJ voce 05, e l'eccezione
/// per chi chiede chi sono i Maestri dall'ordine EN voce 07: una regola che
/// dipende dal modello regge quasi sempre, e il fondatore ha trovato il
/// quasi. **Qui la si guarda a valle**, come `ChiDiDovere` e `IlCieloDetto`:
/// la riga si toglie e il resto della risposta arriva intero. **Non si chiede
/// di nuovo**, perche' nel LIVE una seconda chiamata e' attesa pura e la riga
/// d'oro non e' la risposta: e' il passo, e un passo sbagliato vale meno di
/// nessun passo.
abstract final class IlPassoDaNonDare {
  /// Perche' la riga d'oro di [risposta] non va data, oppure null se va data.
  ///
  /// [domanda] e' cio' che la persona ha appena scritto o detto, [righeGiaDate]
  /// le righe d'oro delle risposte precedenti della stessa conversazione.
  /// Senza riga d'oro la risposta non ha niente da togliere, e torna null.
  static RigaTolta? perche({
    required String domanda,
    required String risposta,
    required Iterable<String> righeGiaDate,
  }) {
    final riga = ConsiglioFinale.sintesiDa(risposta);
    if (riga == null) return null;
    if (eUnaPresentazione(domanda)) return RigaTolta.presentazione;
    if (chiedeDiRifare(domanda: domanda, riga: riga)) {
      return RigaTolta.passoGiaFatto;
    }
    if (righeGiaDate.any((gia) => simili(riga, gia))) return RigaTolta.giaData;
    return null;
  }

  /// Vero se [risposta] e' soltanto la riga d'oro: tolta quella, non resta
  /// niente da mostrare. Il segno del chiarimento non conta come testo.
  static bool eSoloLaRiga(String risposta) =>
      ConsiglioFinale.sintesiDa(risposta) != null &&
      ConsiglioFinale.corpoDa(risposta)
          .replaceAll(RegExp(r'\[\[[A-Z]+\]\]'), '')
          .trim()
          .isEmpty;

  /// La risposta senza la riga d'oro. **Se senza la riga non resta niente**,
  /// la risposta resta com'e': una riga sola e' meno di una risposta, ma una
  /// bolla vuota e' un guasto.
  static String senzaLaRiga(String risposta) {
    final corpo = ConsiglioFinale.corpoDa(risposta);
    return corpo.trim().isEmpty ? risposta : corpo;
  }

  // --- LE PRESENTAZIONI ------------------------------------------------------

  /// **VERO SE LA PERSONA SALUTA O CHIEDE SOLTANTO CHI E' IL MAESTRO**, che
  /// cosa fa, come puo' aiutarla o chi sono gli altri Maestri.
  ///
  /// **Soltanto** e' la parola che decide, ed e' quella dell'istruzione dal
  /// l'ordine EN voce 07: ogni pezzo della domanda, tagliato alla
  /// punteggiatura e alla "e", deve essere un saluto, un nome o una di queste
  /// domande. *"Come puoi aiutarmi?"* e' una presentazione, *"Come puoi
  /// aiutarmi con il mio ex?"* e' una domanda vera e la sua riga resta.
  ///
  /// **E' un elenco chiuso, e va detto.** Una presentazione detta con parole
  /// che qui non ci sono passa, e la sua riga d'oro la ferma solo
  /// l'istruzione; il contrario, togliere il passo a una domanda vera, non
  /// succede, perche' un pezzo che non si riconosce basta a dire no.
  static bool eUnaPresentazione(String domanda) {
    final pezzi = _norma(domanda)
        .split(RegExp(r'[,.;:!?\n]+|\s+(?:e|ed)\s+'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    if (pezzi.isEmpty) return false;
    for (final p in pezzi) {
      if (!_presentazioni.any((r) => r.hasMatch(p))) return false;
    }
    return true;
  }

  static const _nomi = r'(?:maestro|maestra|maestri|medora|aura|caligo)';

  static final List<RegExp> _presentazioni = [
    // Il saluto, col nome o senza.
    RegExp('^(?:ciao|salve|buongiorno|buonasera|buon pomeriggio|buonanotte|'
        'hey|ehi|ehila|hola|hello)(?: (?:a te|a voi|$_nomi))*(?!.)'),
    RegExp('^$_nomi(?!.)'),
    RegExp(r'^(?:piacere|piacere mio|(?:lieto|lieta|felice) di conoscerti)$'),
    // Chi sei.
    RegExp(r'^(?:ma )?(?:e )?(?:tu )?chi sei(?: tu)?'
        r'(?: di preciso| esattamente| davvero| veramente)?$'),
    RegExp(r'^(?:dimmi|raccontami) chi sei(?: tu)?$'),
    RegExp(r'^(?:presentati|parlami di te|raccontami di te|dimmi di te|'
        r'dimmi qualcosa di te|parlami un po di te)$'),
    // Chi sono gli altri.
    RegExp(r'^(?:e )?chi sono gli altri(?: due)?(?: maestri)?'
        r'(?: oltre a te)?(?: del cerchio)?$'),
    RegExp(r'^(?:e )?chi sono i(?: tre)? maestri(?: del cerchio)?$'),
    RegExp(r'^chi siete(?: voi)?$'),
    RegExp('^(?:e )?chi (?:e|sono) $_nomi(?: (?:e|ed) $_nomi)?(?!.)'),
    // Che cosa fa, come puo' aiutare.
    RegExp(r'^(?:e )?(?:tu )?(?:come|in che modo|in cosa|in che cosa) '
        r'(?:mi )?puoi aiutar(?:mi|e)(?: tu)?$'),
    RegExp(r'^(?:e )?(?:tu )?(?:che )?cosa (?:fai|sai fare|puoi fare|'
        r'puoi fare per me|mi puoi dire di te|insegni)(?: tu)?$'),
    RegExp(r'^(?:e )?(?:tu )?di (?:cosa|che cosa|che) ti occupi(?: tu)?$'),
    RegExp(r'^(?:qual e|quali sono) (?:la tua arte|le tue arti|il tuo ruolo|'
        r'il tuo compito)$'),
  ];

  // --- LE RIGHE SIMILI -------------------------------------------------------

  /// **VERO SE DUE RIGHE D'ORO SONO LA STESSA RIGA**, uguali o dette con altre
  /// parole.
  ///
  /// **La grandezza e' quella di casa**, `SeguitoDellaLettura.somiglianza`
  /// con la sua soglia di 0,32, tarata il 4 agosto 2026 sulle frasi del
  /// seguito. **Con una seconda condizione, e il fatto che l'ha chiesta.**
  /// Nelle 1.202 coppie di righe d'oro dei collaudi degli ordini EJ, EK ed
  /// EN, prese dentro la stessa conversazione, la misura di casa da sola
  /// mette insieme *"Il presagio è un mutamento di soglia, un sentiero si
  /// apre."* e *"Il presagio è un periodo di stasi, non di arresto."*, 0,36,
  /// e *"Osserva un'immagine che ti rasserena, stasera prima di dormire."*
  /// con un elenco di cose riuscite *"prima di dormire"*, 0,32: righe corte
  /// che si somigliano per gli articoli e per un'ora del giorno, non per il
  /// passo. **Due righe sono la stessa riga se dividono anche almeno due
  /// parole piene**, cioe' il gesto e la sua cosa: *"Scrivi su un foglio le
  /// tre cose che ti spingono al cambiamento"* e *"Scrivi su un foglio tre
  /// cose che vorresti trovare nella tua nuova città"*, 0,33, dividono
  /// scrivere e foglio, e la seconda non arriva.
  static bool simili(String a, String b) {
    final ia = SeguitoDellaLettura.impronta(a);
    final ib = SeguitoDellaLettura.impronta(b);
    if (ia.isEmpty || ib.isEmpty) return false;
    if (ia == ib) return true;
    if (SeguitoDellaLettura.somiglianza(a, b) <
        SeguitoDellaLettura.sogliaDiRipetizione) {
      return false;
    }
    final ra = paroleDelPasso(a);
    final rb = paroleDelPasso(b);
    final inComune = ra.intersection(rb).length;
    return inComune >= math.min(2, math.min(ra.length, rb.length));
  }

  /// **LE PAROLE PIENE DI UNA RIGA, ridotte alla radice**: le parole di
  /// quattro lettere o piu', senza quelle che ci sono in ogni riga (i tempi
  /// come *stasera* e *domani*, le preposizioni articolate), senza la vocale
  /// finale e tagliate a quattro lettere. *Mano* e *mani*, *scrivi* e
  /// *scrivere*, *foglio* e *fogli* diventano la stessa radice.
  static Set<String> paroleDelPasso(String riga) => {
        for (final p in _parole(riga))
          if (p.length >= 4 && !_paroleDiOgniRiga.contains(p)) _radice(p),
      };

  static String _radice(String parola) {
    final senza = RegExp(r'[aeiou]$').hasMatch(parola)
        ? parola.substring(0, parola.length - 1)
        : parola;
    return senza.length > 4 ? senza.substring(0, 4) : senza;
  }

  static const Set<String> _paroleDiOgniRiga = {
    'stasera',
    'stanotte',
    'domani',
    'domattina',
    'oggi',
    'adesso',
    'ora',
    'prima',
    'dopo',
    'poi',
    'quando',
    'mentre',
    'ancora',
    'anche',
    'sempre',
    'mai',
    'ogni',
    'quello',
    'quella',
    'quelle',
    'quelli',
    'questo',
    'questa',
    'queste',
    'questi',
    'sulla',
    'sulle',
    'sullo',
    'sugli',
    'nella',
    'nelle',
    'nello',
    'negli',
    'della',
    'delle',
    'dello',
    'degli',
    'dalla',
    'dalle',
    'dallo',
    'dagli',
    'alla',
    'alle',
    'allo',
    'agli',
    'come',
    'cosa',
    'cose',
    'sono',
    'tuoi',
    'tutto',
    'tutta',
    'tutti',
    'tutte',
    'volta',
    'volte',
    'senza',
    'verso',
    'sopra',
    'sotto',
    'dentro',
    'fuori',
    'mattina',
    'sera',
    'giorno',
    'momento',
    'istante',
  };

  // --- IL PASSO GIA' FATTO ---------------------------------------------------

  /// **VERO SE [riga] CHIEDE DI RIFARE CIO' CHE [domanda] DICE FATTO.**
  ///
  /// La persona dice di aver fatto con un ausiliare e un participio (*"le ho
  /// scritte"*, *"gli ho scritto"*, *"ho appena acceso la candela"*), e la
  /// riga comincia un gesto con lo stesso verbo all'imperativo (*"Scrivi su
  /// un foglio..."*). **Solo la prima persona**: *"come mi hai detto"* parla
  /// del Maestro, non di cio' che la persona ha fatto.
  ///
  /// **Fare non conta**, ed e' una scelta: *"ho fatto quello che mi hai
  /// detto"* dice che il passo di prima e' fatto, e un passo nuovo che
  /// comincia con *"Fai"* e' un altro passo. Se il passo nuovo e' lo stesso
  /// di prima, lo prende [simili].
  static bool chiedeDiRifare({required String domanda, required String riga}) {
    final fatti = participiDi(domanda);
    if (fatti.isEmpty) return false;
    final parole = _parole(riga);
    for (final participio in fatti) {
      final imperativo = _imperativoDi(participio);
      if (imperativo == null) continue;
      if (parole.any(imperativo.hasMatch)) return true;
    }
    return false;
  }

  /// I participi che la persona dice suoi: dopo *ho*, *abbiamo*, *sono* o
  /// *siamo*, anche con *già* o *appena* in mezzo.
  static List<String> participiDi(String domanda) {
    final parole = _parole(domanda);
    final fuori = <String>[];
    for (var i = 0; i < parole.length; i++) {
      if (!_ausiliari.contains(parole[i])) continue;
      var j = i + 1;
      while (j < parole.length && _inMezzo.contains(parole[j])) {
        j++;
      }
      if (j < parole.length && RegExp(r'^\w{4,}[oaie]$').hasMatch(parole[j])) {
        fuori.add(parole[j]);
      }
    }
    return fuori;
  }

  static const Set<String> _ausiliari = {'ho', 'abbiamo', 'sono', 'siamo'};

  // **Scritte con l'accento e ridotte da [_norma]**, come la domanda che
  // guardano: una parola italiana si scrive giusta anche in un elenco.
  static final Set<String> _inMezzo = {
    for (final p in const [
      'già',
      'appena',
      'anche',
      'ora',
      'adesso',
      'finalmente',
      'davvero',
      'poi',
      'oggi',
      'stasera',
      'ieri',
      'stamattina',
      'subito',
      'tutto',
      'tutte',
      'tutti',
      'bene',
      'proprio',
    ])
      _norma(p),
  };

  /// I verbi irregolari dei passi, dalla radice del participio a quella
  /// dell'imperativo. **Fare non c'e'**, vedi [chiedeDiRifare].
  static const Map<String, String> _irregolari = {
    'scritt': 'scriv',
    'lett': 'legg',
    'mess': 'mett',
    'acces': 'accend',
    'pres': 'prend',
    'apert': 'apr',
    'chius': 'chiud',
    'tenut': 'tien',
    'bevut': 'bev',
    'sedut': 'sied',
    'spent': 'spegn',
    'scelt': 'scegl',
    'tolt': 'togl',
    'raccolt': 'raccogl',
    'accolt': 'accogl',
    'chiest': 'chied',
    'rispost': 'rispond',
    'dipint': 'diping',
    'rott': 'romp',
    'ripetut': 'ripet',
  };

  static const _pronomi =
      r'(?:lo|la|li|le|gli|glie\w*|ne|ci|mi|ti|si|vi|telo|tela|melo|mela)?';

  static RegExp? _imperativoDi(String participio) {
    final radice = participio.substring(0, participio.length - 1);
    // Detto: l'imperativo "di'" senza apostrofo e' la preposizione, e si
    // riconosce solo coi pronomi attaccati.
    if (radice == 'dett') return RegExp(r'^(?:dillo|dilla|dille|digli|dimmi)$');
    for (final voce in _irregolari.entries) {
      if (!radice.endsWith(voce.key)) continue;
      final prima = radice.substring(0, radice.length - voce.key.length);
      if (prima.length > 3) continue;
      return RegExp('^$prima${voce.value}(?:i|ete)$_pronomi(?!.)');
    }
    // I verbi in -are: chiamato, chiama; bruciato, brucia.
    final inAre = RegExp(r'^(\w{3,})at$').firstMatch(radice);
    if (inAre != null) {
      return RegExp('^${inAre.group(1)}(?:a|ate)$_pronomi(?!.)');
    }
    return null;
  }

  // --- LA FORMA ---------------------------------------------------------------

  /// Minuscole, senza accenti e senza apostrofi, gli spazi semplici. La
  /// punteggiatura che separa i pezzi resta, per [eUnaPresentazione].
  static List<String> _parole(String testo) => _norma(testo)
      .split(RegExp(r'[^a-z0-9]+'))
      .where((p) => p.isNotEmpty)
      .toList();

  static String _norma(String testo) => testo
      .toLowerCase()
      .replaceAll(RegExp('[àá]'), 'a')
      .replaceAll(RegExp('[èé]'), 'e')
      .replaceAll(RegExp('[ìí]'), 'i')
      .replaceAll(RegExp('[òó]'), 'o')
      .replaceAll(RegExp('[ùú]'), 'u')
      .replaceAll(RegExp("['’`]"), ' ')
      .replaceAll(RegExp(r'[^a-z0-9,.;:!?\n ]'), ' ')
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .trim();
}

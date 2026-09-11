// ignore_for_file: avoid_print
import 'dart:math';

/// **IL MOTORE DELLA RIPETIZIONE, UNO SOLO PER TUTTE LE ARTI.**
/// Ordine DF voce 02, 11 settembre 2026.
///
/// **DA DOVE NASCE, e sono parole del fondatore.** *"ho fatto 4 letture di
/// tarocchi con la stessa domanda denaro e fortuna"*, e i primi due paragrafi
/// erano **identici al carattere** in tutte e quattro. *"voglio la sicurezza
/// che su 100 domande uguali, nemmeno una sia uguale o simile."*
///
/// **IL PROBLEMA DELLA PAROLA SIMILE.** *Uguale* si misura: due stringhe o sono
/// la stessa o non lo sono. *Simile* non si misura, finche' non si dichiara in
/// che cosa. Questo motore lo dichiara in tre modi diversi, e sono le prime tre
/// delle quattro misure.
///
/// **LA MISURA CHE CONTA DAVVERO E' LA B**, lo scheletro. Un testo composto
/// infilando nomi diversi dentro la stessa frase ha cento testi distinti e **un
/// solo scheletro**: la misura A lo promuoverebbe, la persona che legge lo
/// boccia. Sui quattro responsi veri del fondatore la B da' **uno scheletro su
/// quattro**.
class MotoreDellaRipetizione {
  const MotoreDellaRipetizione._();

  /// **QUANTE CONSULTAZIONI**, ed e' il numero che il fondatore ha nominato.
  static const int quante = 100;

  /// **A) TESTI DISTINTI.** Soglia: tutti.
  static const int sogliaTestiDistinti = quante;

  /// **B) SCHELETRI DISTINTI.** Soglia: almeno novanta su cento.
  static const int sogliaScheletriDistinti = 90;

  /// **E NESSUNO SCHELETRO PIU' DI TRE VOLTE.**
  static const int sogliaScheletroPiuRipetuto = 3;

  /// **C) SOMIGLIANZA MASSIMA A COPPIE.** Soglia: nessuna coppia sopra il
  /// quaranta per cento.
  ///
  /// **E SI GUARDANO LE COPPIE CHE NON CONDIVIDONO NESSUN SIMBOLO, e la
  /// ragione va scritta per intero perche' e' l'unico punto di questo ordine in
  /// cui la grandezza misurata si restringe.**
  ///
  /// **Il fatto, misurato.** Su cento gettate di tre rune da ventiquattro, la
  /// probabilita' che due gettate qualsiasi condividano **due rune nelle stesse
  /// posizioni** e' circa tre su mille per coppia: su
  /// quattromilanovecentocinquanta coppie fanno **una ventina di casi**, e
  /// capitano sempre. Quando capitano, i due responsi **devono** somigliarsi,
  /// perche' il testo di una runa e' il testo di quella runa: un corpus che
  /// dicesse due cose diverse della stessa runa uscita nella stessa posizione
  /// non sarebbe una tradizione, sarebbe un generatore. Lo stesso vale per le
  /// carte e per le figure della scena.
  ///
  /// **Quindi una soglia sulla coppia peggiore in assoluto non misura il
  /// compositore: misura la probabilita' di ripescare gli stessi simboli**, che
  /// nessuna riscrittura del testo puo' cambiare e che **non deve** cambiare.
  ///
  /// **Cio' che il fondatore ha visto e' un'altra cosa, ed e' esattamente cio'
  /// che questa soglia adesso sorveglia**: quattro letture con **dodici carte
  /// diverse** e i primi due paragrafi identici al carattere. Due consultazioni
  /// che non hanno **nessun simbolo in comune** e che si somigliano lo stesso
  /// sono la prova che il testo non guarda i simboli.
  ///
  /// **La coppia peggiore in assoluto si misura e si riporta lo stesso**, in
  /// [EsitoDellaRipetizione.somiglianzaMassima]: non si nasconde e sta nel
  /// rapporto accanto all'altra.
  static const double sogliaSomiglianza = 0.40;

  /// **D) PARAGRAFO PIU' RIPETUTO.** Soglia: non piu' di due volte su cento.
  static const int sogliaParagrafoPiuRipetuto = 2;

  /// **LO SCHELETRO DI UN TESTO.**
  ///
  /// Si tolgono **i nomi propri usciti in quella consultazione** (le carte, le
  /// rune, i loro significati brevi) e **ogni numero**. Cio' che resta e' la
  /// forma della frase, cioe' la cosa che una persona riconosce alla seconda
  /// lettura anche senza rileggere.
  ///
  /// **I nomi si tolgono dal piu' lungo al piu' corto**, altrimenti togliendo
  /// prima *"Il Mondo"* da *"Il Mondo rovesciato"* resterebbe *"rovesciato"* a
  /// sporcare lo scheletro, e due consultazioni con la stessa forma
  /// sembrerebbero diverse.
  static String scheletro(String testo, List<String> nomiPropri) {
    var s = testo;
    final ordinati = [...nomiPropri]
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final n in ordinati) {
      if (n.trim().isEmpty) continue;
      s = s.replaceAll(n, '§');
    }
    // Ogni numero, in cifra.
    s = s.replaceAll(RegExp(r'\d+'), '#');
    // Gli spazi multipli e i segni rimasti appaiati collassano: togliendo i
    // nomi restano doppi spazi che non dicono niente sulla forma.
    s = s.replaceAll(RegExp(r'(§\s*)+'), '§ ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  /// **LE PAROLE DI UN TESTO**, per la somiglianza.
  static List<String> _parole(String testo) => testo
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-zà-ÿ0-9\s]'), ' ')
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();

  /// **QUANTO E' LUNGA UNA SEQUENZA.** Cinque parole di fila.
  ///
  /// **E' la scelta della grandezza misurata, e va motivata perche' l'ordine
  /// dice *"percentuale di sequenze comuni"* senza imporre la formula.**
  ///
  /// **Non due parole.** Con le coppie, due testi italiani qualsiasi
  /// condividono *"di cui"*, *"che si"*, *"e non"*: c'e' un pavimento di
  /// somiglianza che non dipende da chi ha scritto i testi ma dalla lingua. Su
  /// duecentocinquanta parole quel pavimento vale gia' venti punti, e una
  /// soglia al quaranta finirebbe per misurare **quanto l'italiano somiglia a
  /// se' stesso**.
  ///
  /// **Cinque parole di fila e' una frase riconoscibile.** *"Fai il passo
  /// concreto che rimandi"* e' una sequenza che una persona ricorda di aver
  /// gia' letto; *"e non"* non lo e'. La misura deve dire quello che dice la
  /// persona quando afferma che due responsi sono **simili**, e cio' che
  /// riconosce sono i pezzi di frase, non le congiunzioni.
  ///
  /// **Il pavimento misurato**: fra due testi presi da due arti diverse di
  /// questa app la somiglianza a cinque parole e' **zero**, mentre a due parole
  /// stava fra il quindici e il venticinque per cento. E' la prova che la
  /// grandezza nuova misura il testo e non la lingua.
  static const int quantoELungaUnaSequenza = 5;

  /// **QUANTO SI SOMIGLIANO DUE TESTI, da 0 a 1.**
  ///
  /// Coefficiente di Dice sulle sequenze di [quantoELungaUnaSequenza] parole
  /// consecutive.
  ///
  /// **Perche' Dice e non la sottosequenza comune piu' lunga.** La LCS su
  /// quattromilanovecentocinquanta coppie di testi da mille caratteri e' un
  /// conto quadratico ripetuto cinquemila volte: la prova ci metterebbe minuti.
  /// Dice guarda **le stesse sequenze** e costa lineare.
  ///
  /// **E conta le ripetizioni**, cioe' lavora sul multinsieme: un testo che
  /// ripete tre volte la stessa sequenza non deve somigliare a uno che la usa
  /// una volta sola come se fossero uguali.
  static double somiglianza(String a, String b) {
    const n = quantoELungaUnaSequenza;
    final pa = _parole(a);
    final pb = _parole(b);
    if (pa.length < n || pb.length < n) {
      return pa.join(' ') == pb.join(' ') ? 1 : 0;
    }
    Map<String, int> sequenze(List<String> p) {
      final m = <String, int>{};
      for (var i = 0; i <= p.length - n; i++) {
        final c = p.sublist(i, i + n).join(' ');
        m[c] = (m[c] ?? 0) + 1;
      }
      return m;
    }

    final ca = sequenze(pa);
    final cb = sequenze(pb);
    var comuni = 0;
    for (final e in ca.entries) {
      comuni += min(e.value, cb[e.key] ?? 0);
    }
    final totale = (pa.length - n + 1) + (pb.length - n + 1);
    return totale == 0 ? 0 : 2 * comuni / totale;
  }

  /// **I PARAGRAFI DI UN TESTO**, separati dalla riga vuota, come li vede chi
  /// legge.
  static List<String> paragrafi(String testo) => testo
      .split(RegExp(r'\n\s*\n'))
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();

  /// **MISURA CENTO CONSULTAZIONI.**
  ///
  /// [testi] sono i testi che la persona vede a schermo, uno per consultazione.
  /// [nomiPerTesto] sono i nomi propri usciti in quella consultazione, nello
  /// stesso ordine: carte, rune, significati brevi.
  /// **[testiComposti] e' cio' su cui si conta il paragrafo piu' ripetuto**,
  /// e quando non si dichiara vale [testi].
  ///
  /// **Perche' le due cose possono essere diverse, e la ragione e' di
  /// sostanza.** In una Stesa, a schermo, ci sono due generi di paragrafo. I
  /// primi li **compone l'app**: sono il Consiglio, ed e' li' che vive il
  /// difetto che il fondatore ha visto. I secondi sono **il testo di corpus
  /// della carta uscita**, citato per intero sotto Passato, Presente e Futuro.
  ///
  /// **Se la stessa carta esce due volte in cento letture, il suo testo di
  /// corpus DEVE essere lo stesso**: un corpus che dicesse due cose diverse
  /// della stessa carta non sarebbe una tradizione, sarebbe un generatore. Su
  /// cento estrazioni da settantotto carte quella ripetizione e' matematica,
  /// non e' un difetto, e contarla vorrebbe dire far cadere la guardia su un
  /// fatto che non si puo' e non si deve riparare.
  ///
  /// **Quindi la misura D guarda i paragrafi COMPOSTI**, e le altre tre
  /// guardano il testo intero che la persona legge, come vuole la regola
  /// CINQUE dell'ordine.
  /// [simboliPerTesto] sono i simboli usciti in quella consultazione, cioe' le
  /// carte, le rune o le figure della scena. Quando si dichiarano, la soglia
  /// della misura C guarda **soltanto le coppie che non ne condividono
  /// nessuno**; quando non si dichiarano, guarda tutte le coppie.
  static EsitoDellaRipetizione misura({
    required String funzione,
    required List<String> testi,
    required List<List<String>> nomiPerTesto,
    List<String>? testiComposti,
    List<Set<String>>? simboliPerTesto,
  }) {
    assert(testi.length == nomiPerTesto.length);
    final scheletri = <String>[
      for (var i = 0; i < testi.length; i++)
        scheletro(testi[i], nomiPerTesto[i]),
    ];

    final contoScheletri = <String, int>{};
    for (final s in scheletri) {
      contoScheletri[s] = (contoScheletri[s] ?? 0) + 1;
    }
    var scheletroPiuRipetuto = '';
    var quanteVolteLoScheletro = 0;
    for (final e in contoScheletri.entries) {
      if (e.value > quanteVolteLoScheletro) {
        quanteVolteLoScheletro = e.value;
        scheletroPiuRipetuto = e.key;
      }
    }

    final contoParagrafi = <String, int>{};
    for (final t in testiComposti ?? testi) {
      for (final p in paragrafi(t)) {
        contoParagrafi[p] = (contoParagrafi[p] ?? 0) + 1;
      }
    }
    var paragrafoPiuRipetuto = '';
    var quanteVolteIlParagrafo = 0;
    for (final e in contoParagrafi.entries) {
      if (e.value > quanteVolteIlParagrafo) {
        quanteVolteIlParagrafo = e.value;
        paragrafoPiuRipetuto = e.key;
      }
    }

    // **TUTTE LE COPPIE, non solo quelle consecutive.** Due testi lontani nella
    // sequenza sono comunque due letture che la stessa persona puo' fare.
    var peggiore = 0.0;
    var iPeggiore = 0;
    var jPeggiore = 0;
    var quanteCoppie = 0;
    // La coppia peggiore fra quelle che non condividono nessun simbolo.
    var peggioreFraDiverse = 0.0;
    var iDiverse = 0;
    var jDiverse = 0;
    var quanteCoppieDiverse = 0;
    for (var i = 0; i < testi.length; i++) {
      for (var j = i + 1; j < testi.length; j++) {
        quanteCoppie++;
        final s = somiglianza(testi[i], testi[j]);
        if (s > peggiore) {
          peggiore = s;
          iPeggiore = i;
          jPeggiore = j;
        }
        if (simboliPerTesto == null ||
            simboliPerTesto[i].intersection(simboliPerTesto[j]).isEmpty) {
          quanteCoppieDiverse++;
          if (s > peggioreFraDiverse) {
            peggioreFraDiverse = s;
            iDiverse = i;
            jDiverse = j;
          }
        }
      }
    }

    return EsitoDellaRipetizione(
      funzione: funzione,
      quante: testi.length,
      testiDistinti: testi.toSet().length,
      scheletriDistinti: contoScheletri.length,
      scheletroPiuRipetuto: scheletroPiuRipetuto,
      quanteVolteLoScheletro: quanteVolteLoScheletro,
      somiglianzaMassima: peggiore,
      coppiePeggiori: (iPeggiore, jPeggiore),
      testoPeggioreUno: testi.isEmpty ? '' : testi[iPeggiore],
      testoPeggioreDue: testi.isEmpty ? '' : testi[jPeggiore],
      quanteCoppie: quanteCoppie,
      somiglianzaFraDiverse: peggioreFraDiverse,
      coppieDiverse: (iDiverse, jDiverse),
      testoDiverseUno: testi.isEmpty ? '' : testi[iDiverse],
      testoDiverseDue: testi.isEmpty ? '' : testi[jDiverse],
      quanteCoppieDiverse: quanteCoppieDiverse,
      paragrafoPiuRipetuto: paragrafoPiuRipetuto,
      quanteVolteIlParagrafo: quanteVolteIlParagrafo,
    );
  }
}

/// L'esito delle quattro misure su una funzione.
class EsitoDellaRipetizione {
  const EsitoDellaRipetizione({
    required this.funzione,
    required this.quante,
    required this.testiDistinti,
    required this.scheletriDistinti,
    required this.scheletroPiuRipetuto,
    required this.quanteVolteLoScheletro,
    required this.somiglianzaMassima,
    required this.coppiePeggiori,
    required this.testoPeggioreUno,
    required this.testoPeggioreDue,
    required this.quanteCoppie,
    required this.somiglianzaFraDiverse,
    required this.coppieDiverse,
    required this.testoDiverseUno,
    required this.testoDiverseDue,
    required this.quanteCoppieDiverse,
    required this.paragrafoPiuRipetuto,
    required this.quanteVolteIlParagrafo,
  });

  final String funzione;
  final int quante;
  final int testiDistinti;
  final int scheletriDistinti;
  final String scheletroPiuRipetuto;
  final int quanteVolteLoScheletro;
  final double somiglianzaMassima;
  final (int, int) coppiePeggiori;
  final String testoPeggioreUno;
  final String testoPeggioreDue;
  final int quanteCoppie;

  /// La coppia peggiore fra quelle che **non condividono nessun simbolo**.
  final double somiglianzaFraDiverse;
  final (int, int) coppieDiverse;
  final String testoDiverseUno;
  final String testoDiverseDue;
  final int quanteCoppieDiverse;

  final String paragrafoPiuRipetuto;
  final int quanteVolteIlParagrafo;

  bool get passaA => testiDistinti >= quante;
  bool get passaB =>
      scheletriDistinti >= MotoreDellaRipetizione.sogliaScheletriDistinti &&
      quanteVolteLoScheletro <=
          MotoreDellaRipetizione.sogliaScheletroPiuRipetuto;
  bool get passaC =>
      somiglianzaFraDiverse <= MotoreDellaRipetizione.sogliaSomiglianza;
  bool get passaD =>
      quanteVolteIlParagrafo <=
      MotoreDellaRipetizione.sogliaParagrafoPiuRipetuto;
  bool get passa => passaA && passaB && passaC && passaD;

  /// Quali delle quattro hanno ceduto, per nome.
  List<String> get cedute => [
        if (!passaA) 'A, testi distinti',
        if (!passaB) 'B, scheletri distinti',
        if (!passaC) 'C, somiglianza a coppie',
        if (!passaD) 'D, paragrafo piu ripetuto',
      ];

  /// **IL REFERTO, e si stampa sempre**, passata o no: l'ordine DF voce 07
  /// chiede i numeri di ogni funzione provata, prima e dopo la riparazione.
  String get referto => [
        'ORDINE DF VOCE 02, $funzione, su $quante consultazioni con lo stesso '
            'ingresso:',
        '  A) testi distinti .......... $testiDistinti / $quante '
            '(soglia $quante) ${passaA ? "PASSA" : "CADE"}',
        '  B) scheletri distinti ...... $scheletriDistinti / $quante '
            '(soglia ${MotoreDellaRipetizione.sogliaScheletriDistinti}) '
            '${scheletriDistinti >= MotoreDellaRipetizione.sogliaScheletriDistinti ? "PASSA" : "CADE"}',
        '     lo scheletro piu ripetuto compare $quanteVolteLoScheletro volte '
            '(soglia ${MotoreDellaRipetizione.sogliaScheletroPiuRipetuto}) '
            '${quanteVolteLoScheletro <= MotoreDellaRipetizione.sogliaScheletroPiuRipetuto ? "PASSA" : "CADE"}',
        '  C) somiglianza massima fra consultazioni che NON condividono '
            'nessun simbolo ..... '
            '${(somiglianzaFraDiverse * 100).toStringAsFixed(1)} per cento su '
            '$quanteCoppieDiverse coppie (soglia '
            '${(MotoreDellaRipetizione.sogliaSomiglianza * 100).toStringAsFixed(0)}) '
            '${passaC ? "PASSA" : "CADE"}',
        '     la coppia peggiore fra le diverse e la ${coppieDiverse.$1} con '
            'la ${coppieDiverse.$2}',
        '     e su TUTTE le $quanteCoppie coppie, simboli ripescati compresi, '
            'la peggiore e ${(somiglianzaMassima * 100).toStringAsFixed(1)} '
            'per cento, fra la ${coppiePeggiori.$1} e la ${coppiePeggiori.$2}: '
            'riportata e non sotto soglia, vedi sogliaSomiglianza',
        '  D) paragrafo piu ripetuto .. $quanteVolteIlParagrafo volte '
            '(soglia ${MotoreDellaRipetizione.sogliaParagrafoPiuRipetuto}) '
            '${passaD ? "PASSA" : "CADE"}',
      ].join('\n');

  /// Il referto lungo, con i testi per intero, che l'ordine DF voce 07 chiede
  /// per la coppia peggiore e per il paragrafo piu' ripetuto.
  String get refertoLungo => [
        referto,
        '  LO SCHELETRO PIU RIPETUTO ($quanteVolteLoScheletro volte):',
        '    $scheletroPiuRipetuto',
        '  IL PARAGRAFO PIU RIPETUTO ($quanteVolteIlParagrafo volte):',
        '    $paragrafoPiuRipetuto',
        '  LA COPPIA PEGGIORE FRA LE DIVERSE, testo ${coppieDiverse.$1}:',
        '    ${testoDiverseUno.replaceAll("\n", " / ")}',
        '  LA COPPIA PEGGIORE FRA LE DIVERSE, testo ${coppieDiverse.$2}:',
        '    ${testoDiverseDue.replaceAll("\n", " / ")}',
        '  LA COPPIA PEGGIORE IN ASSOLUTO, testo ${coppiePeggiori.$1}:',
        '    ${testoPeggioreUno.replaceAll("\n", " / ")}',
        '  LA COPPIA PEGGIORE IN ASSOLUTO, testo ${coppiePeggiori.$2}:',
        '    ${testoPeggioreDue.replaceAll("\n", " / ")}',
      ].join('\n');
}

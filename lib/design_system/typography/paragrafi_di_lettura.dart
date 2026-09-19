import 'package:flutter/material.dart';

import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';

/// LA REGOLA DEI PARAGRAFI, IN UN PUNTO SOLO PER TUTTA L'APP.
///
/// **Perche' vive qui e non dentro una schermata.** E' nata nell'Oroscopo,
/// dove il responso era un muro di sei righe, e li' e' rimasta finche' l'ha
/// usata una sola schermata. Dal momento in cui la usano anche gli Angeli, il
/// Test Archetipo, la Costellazione del Viso e le Rune, tenerla in casa
/// dell'Oroscopo vorrebbe dire che la seconda schermata se ne scrive una
/// propria, e due schermate che spezzano il testo con due regole diverse sono
/// la famiglia delle due porte: prima o poi divergono, e nessuno se ne
/// accorge finche' non le si guarda affiancate.

/// La larghezza che il responso ha davvero, sul telefono di riferimento.
///
/// Trecentosessanta punti logici e' la misura su cui si giudica l'app, ed e' la
/// piu' stretta: a 360 il testo va a capo prima che altrove, quindi e' il caso
/// che decide. Dentro ci stanno due volte il margine della lista e due volte il
/// riempimento della scheda, tutti e quattro `SpacingTokens.lg`.
///
/// **La divisione si calcola SEMPRE qui, anche su uno schermo piu' largo, ed e'
/// una scelta.** Spezzare il responso e' un atto editoriale, non un
/// adattamento al pixel: se dipendesse dalla larghezza vera, la stessa lettura
/// avrebbe due blocchi su un telefono e uno su un altro, e la regola non
/// sarebbe piu' verificabile. Su uno schermo largo i blocchi restano quelli, e
/// ciascuno occupa semplicemente meno righe.
const double larghezzaDiRiferimentoDellaLettura = 360 - SpacingTokens.lg * 4;

/// Quante righe occupa [testo] reso con [stile] alla larghezza di riferimento.
///
/// E' la grandezza su cui si decide tutto, e non sono ne' i caratteri ne' le
/// parole: due frasi della stessa lunghezza in caratteri possono occupare righe
/// diverse, perche' a mandare a capo e' la parola che non ci sta. Si misura col
/// motore che dipinge davvero il testo.
int righeRese(
  String testo,
  TextStyle stile, {
  double larghezza = larghezzaDiRiferimentoDellaLettura,
}) {
  if (testo.trim().isEmpty) return 0;
  final tp = TextPainter(
    text: TextSpan(text: testo.trim(), style: stile),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: larghezza);
  return tp.computeLineMetrics().length;
}

/// Le frasi di [testo], con la loro punteggiatura attaccata.
///
/// Si taglia DOPO il punto e mai dentro una frase: un blocco che comincia con
/// un pezzo di frase e' peggio del muro che si voleva evitare.
List<String> frasiDi(String testo) {
  final pulito = testo.trim();
  if (pulito.isEmpty) return const [];
  final frasi = <String>[];
  final corrente = StringBuffer();
  for (var i = 0; i < pulito.length; i++) {
    corrente.write(pulito[i]);
    final fine = pulito[i] == '.' || pulito[i] == '!' || pulito[i] == '?';
    final seguito = i + 1 < pulito.length ? pulito[i + 1] : ' ';
    if (fine && (seguito == ' ' || seguito == '\n')) {
      frasi.add(corrente.toString().trim());
      corrente.clear();
    }
  }
  if (corrente.toString().trim().isNotEmpty) {
    frasi.add(corrente.toString().trim());
  }
  return frasi;
}

/// SI SPEZZA SOLO CIO' CHE E' LUNGO.
///
/// La prima stesura di questa regola divideva a prescindere: contava i
/// caratteri con una costante e chiudeva un blocco appena arrivava a tre righe
/// stimate, quindi un responso di cinque righe usciva in tre piu' due e quel
/// due era una coda, non un paragrafo. Adesso il numero di righe RESE decide
/// prima di tutto se dividere, e poi come.
///
/// Le soglie, in righe rese alla larghezza di riferimento:
///
/// - sotto [sogliaDivisione] (5): un blocco solo, nessuna divisione;
/// - da 5 a [sogliaBlocchiLunghi] (10): al massimo due blocchi, e nessuno dei
///   due sotto [righeMinimeDiBlocco] (3);
/// - oltre 10: blocchi da 4 a 6 righe, nessuno sotto 3.
///
/// E una regola sta PRIMA di tutte: un blocco finale di una o due righe non
/// esiste, si fonde con quello che lo precede. Vale a qualunque lunghezza,
/// perche' una coda corta in fondo a una lettura si legge come un errore di
/// composizione, non come un paragrafo.
const int righeMinimeDiBlocco = 3;
const int sogliaDivisione = 5;
const int sogliaBlocchiLunghi = 10;

List<String> spezzaInParagrafi(
  String testo, {
  required TextStyle stile,
  double larghezza = larghezzaDiRiferimentoDellaLettura,
}) {
  final pulito = testo.trim();
  if (pulito.isEmpty) return const [];

  int righe(String s) => righeRese(s, stile, larghezza: larghezza);
  final totali = righe(pulito);

  // (a) Sotto cinque righe non si divide niente: non c'e' nessun muro da
  // rompere, e dividere due frasi corte fa sembrare la lettura sbriciolata.
  if (totali < sogliaDivisione) return [pulito];

  final frasi = frasiDi(pulito);
  // Una frase sola, per quanto lunga, resta un blocco: spezzarla vorrebbe dire
  // rompere il senso per rispettare un conteggio.
  if (frasi.length < 2) return [pulito];

  // (b) Da cinque a dieci righe: due blocchi, e si sceglie il taglio piu'
  // vicino alla meta' fra quelli che lasciano tre righe da tutte e due le
  // parti. Se nessun taglio le lascia, il testo resta intero: meglio un blocco
  // lungo che un blocco monco.
  if (totali <= sogliaBlocchiLunghi) {
    int? migliore;
    var scarto = double.infinity;
    for (var t = 1; t < frasi.length; t++) {
      final primo = frasi.take(t).join(' ');
      final secondo = frasi.skip(t).join(' ');
      final rp = righe(primo);
      final rs = righe(secondo);
      if (rp < righeMinimeDiBlocco || rs < righeMinimeDiBlocco) continue;
      final d = (rp - rs).abs().toDouble();
      if (d < scarto) {
        scarto = d;
        migliore = t;
      }
    }
    if (migliore == null) return [pulito];
    return [
      frasi.take(migliore).join(' '),
      frasi.skip(migliore).join(' '),
    ];
  }

  // (c) Oltre dieci righe: si accumula fino a quattro righe e si chiude, senza
  // mai superare sei. Una frase che da sola supera il tetto chiude comunque il
  // suo blocco, perche' l'alternativa sarebbe tagliarla.
  //
  // I blocchi si tengono come LISTE DI FRASI e non come stringhe gia' unite,
  // perche' l'ultimo passaggio ha bisogno di spostare una frase da un blocco
  // all'altro: su una stringa unita si potrebbe solo fondere.
  const desiderate = 4;
  const massime = 6;
  final blocchi = <List<String>>[];
  var accumulato = <String>[];
  for (final frase in frasi) {
    final provato = [...accumulato, frase];
    if (accumulato.isNotEmpty && righe(provato.join(' ')) > massime) {
      blocchi.add(accumulato);
      accumulato = [frase];
      continue;
    }
    accumulato = provato;
    if (righe(accumulato.join(' ')) >= desiderate) {
      blocchi.add(accumulato);
      accumulato = [];
    }
  }
  if (accumulato.isNotEmpty) blocchi.add(accumulato);

  // LA CODA CORTA NON ESISTE, ed e' la regola che viene prima di tutte. Si
  // prova PRIMA a travasarle una frase dal blocco che la precede, e solo se il
  // travaso non basta la si fonde.
  //
  // **Fondere e basta produceva blocchi da sette righe**, misurato: la coda
  // finiva dentro un blocco gia' pieno e il tetto delle sei righe saltava
  // proprio nell'ultimo pezzo della lettura, dove la stanchezza e' massima. Col
  // travaso le due regole stanno in piedi insieme, e la fusione resta come
  // ultima risorsa per i casi in cui non c'e' niente da spostare.
  while (blocchi.length > 1 &&
      righe(blocchi.last.join(' ')) < righeMinimeDiBlocco) {
    final penultimo = blocchi[blocchi.length - 2];
    final ultimo = blocchi.last;
    if (penultimo.length > 1) {
      final travasato = [penultimo.last, ...ultimo];
      final restante = penultimo.sublist(0, penultimo.length - 1);
      if (righe(restante.join(' ')) >= righeMinimeDiBlocco &&
          righe(travasato.join(' ')) >= righeMinimeDiBlocco &&
          righe(travasato.join(' ')) <= massime) {
        blocchi[blocchi.length - 2] = restante;
        blocchi[blocchi.length - 1] = travasato;
        break;
      }
    }
    blocchi.removeLast();
    blocchi[blocchi.length - 1] = [...blocchi.last, ...ultimo];
  }

  return blocchi.map((b) => b.join(' ')).toList();
}

/// Un testo narrato reso a blocchi, con la distanza doppia fra l'uno e l'altro.
///
/// E' la porta unica: una schermata che ha un responso da mostrare monta questo
/// widget e non ricompone la regola per conto suo. Chi ha bisogno di scrivere il
/// testo a macchina, come l'Oroscopo, usa direttamente [spezzaInParagrafi],
/// perche' li' i blocchi devono comparire in fila e non tutti insieme.
class ParagrafiDiLettura extends StatelessWidget {
  const ParagrafiDiLettura({
    super.key,
    required this.testo,
    required this.stile,
    this.titolo,
    this.sottotitolo,
    this.stileTitolo,
    this.stileSottotitolo,
    this.oro,
    this.textAlign,
  });

  final String testo;
  final TextStyle stile;

  /// Il titolo sopra il testo, quando il blocco narrato lo porta con se':
  /// cosi' titolo e paragrafi restano una cosa sola e nessuna schermata li
  /// ricompone per conto suo.
  final String? titolo;

  /// La riga sotto il titolo, piu' discreta.
  final String? sottotitolo;

  /// Gli stili di titolo e sottotitolo, coi ruoli come default: chi non li
  /// passa ottiene `titoloScheda` e `didascalia`.
  final TextStyle? stileTitolo;
  final TextStyle? stileSottotitolo;

  /// Il colore dell'ORO per il blocco che porta il senso.
  ///
  /// **Un solo blocco, e solo quando i blocchi sono due o piu'**: con un
  /// blocco solo due pesi nella stessa colonna non sono una gerarchia, sono
  /// un'incertezza, ed e' la stessa regola che l'Oroscopo si porta dall'ordine
  /// B. Il blocco dorato e' il PRIMO, perche' e' quello che apre la lettura e
  /// ne dichiara il senso. Nullo vuol dire nessun oro.
  final Color? oro;

  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final blocchi = spezzaInParagrafi(testo, stile: stile);
    // Il doppio della misura del testo, presa dallo stile e non riscritta a
    // mano: se domani il ruolo cambia misura, la distanza lo segue.
    final distanza = (stile.fontSize ?? 12) * 2;
    final croce = textAlign == TextAlign.center
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    return Column(
      crossAxisAlignment: croce,
      children: [
        if (titolo != null) ...[
          Text(titolo!,
              style: stileTitolo ?? TypographyTokens.titoloScheda(),
              textAlign: textAlign),
          SizedBox(height: (stile.fontSize ?? 12) * 0.5),
        ],
        if (sottotitolo != null) ...[
          Text(sottotitolo!,
              style: stileSottotitolo ?? TypographyTokens.didascalia(),
              textAlign: textAlign),
          SizedBox(height: (stile.fontSize ?? 12) * 0.75),
        ],
        for (var i = 0; i < blocchi.length; i++) ...[
          if (i > 0) SizedBox(height: distanza),
          Text(blocchi[i],
              style: oro != null && blocchi.length >= 2 && i == 0
                  ? stile.copyWith(color: oro)
                  : stile,
              textAlign: textAlign),
        ],
      ],
    );
  }
}

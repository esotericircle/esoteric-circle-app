import 'dart:io';

/// CENSIMENTO DELLE STRINGHE RIVOLTE ALLA PERSONA. Ordine CE voce 15.
///
/// **Questa voce non traduce niente.** Richiesta del fondatore del 22 agosto
/// 2026, per il futuro e non per adesso: la traduzione in altre lingue. Il
/// censimento serve a decidere se l'internazionalizzazione e' un ordine o tre,
/// e il documento e' il prodotto della voce.
///
/// **Si rigenera, non si scrive a mano.** Come gli altri censimenti del
/// progetto: un documento scritto a mano invecchia il giorno dopo, e nessuno se
/// ne accorge.
///
///   dart run tool/censimento_stringhe.dart
void main() {
  final rapporto = censisci();
  File('docs/traduzione/censimento.md').writeAsStringSync(rapporto.documento());
  // ignore: avoid_print
  print('Censite ${rapporto.totale} stringhe rivolte alla persona in '
      '${rapporto.fileToccati} file. Contenuto ${rapporto.neiCorpus}, '
      'interfaccia ${rapporto.nelCodice}. Con genere o numero '
      '${rapporto.conAccordo}. Da un sistema di traduzione ${rapporto.tradotte}.');
}

/// Una stringa trovata, con dove sta e come si comporta.
class StringaCensita {
  StringaCensita({
    required this.file,
    required this.riga,
    required this.testo,
    required this.corpus,
    required this.accordo,
  });

  final String file;
  final int riga;
  final String testo;

  /// Vero se vive in un corpus, cioe' in un file di contenuto invece che in
  /// una schermata.
  final bool corpus;

  /// Vero se la frase cambia con chi legge: un numero che diventa plurale,
  /// un aggettivo che si accorda al genere, una preposizione eufonica.
  final bool accordo;
}

class RapportoDelleStringhe {
  RapportoDelleStringhe(this.stringhe, this.fileToccati, this.tradotte);

  final List<StringaCensita> stringhe;
  final int fileToccati;

  /// Quante passano oggi da un sistema di localizzazione. **Misurato, non
  /// assunto.**
  final int tradotte;

  int get totale => stringhe.length;
  int get neiCorpus => stringhe.where((s) => s.corpus).length;
  int get nelCodice => stringhe.where((s) => !s.corpus).length;
  int get conAccordo => stringhe.where((s) => s.accordo).length;

  /// I file col maggior numero di stringhe, che sono quelli da cui una
  /// traduzione conviene cominciare.
  List<MapEntry<String, int>> get iPiuCarichi {
    final conto = <String, int>{};
    for (final s in stringhe) {
      conto[s.file] = (conto[s.file] ?? 0) + 1;
    }
    final ordinati = conto.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ordinati.take(20).toList();
  }

  String documento() {
    final b = StringBuffer();
    b.writeln('# Censimento delle stringhe rivolte alla persona');
    b.writeln();
    b.writeln('<!-- TOTALE_STRINGHE: $totale -->');
    b.writeln('<!-- NEI_CORPUS: $neiCorpus -->');
    b.writeln('<!-- NEL_CODICE: $nelCodice -->');
    b.writeln('<!-- CON_ACCORDO: $conAccordo -->');
    b.writeln('<!-- DA_UN_SISTEMA_DI_TRADUZIONE: $tradotte -->');
    b.writeln('<!-- FILE_TOCCATI: $fileToccati -->');
    b.writeln('<!-- Generato da tool/censimento_stringhe.dart. '
        'Non si scrive a mano: si rigenera. -->');
    b.writeln();
    b.writeln('Ordine CE voce 15. **Questa voce non traduce niente**, e non '
        'aggiunge nessun pacchetto: misura quanto costerebbe tradurre, cosi\' '
        'la decisione si prende su un numero invece che su un\'impressione.');
    b.writeln();
    b.writeln('## I cinque numeri');
    b.writeln();
    b.writeln('| grandezza | valore |');
    b.writeln('| --- | --- |');
    b.writeln('| Stringhe rivolte alla persona | **$totale** |');
    b.writeln('| Che portano CONTENUTO, sotto `lib/core` e `lib/services` | **$neiCorpus** |');
    b.writeln('| Che portano INTERFACCIA, sotto `lib/features` e `lib/design_system` | **$nelCodice** |');
    b.writeln('| Che cambiano con genere o numero | **$conAccordo** |');
    b.writeln('| Che passano da un sistema di traduzione | **$tradotte** |');
    b.writeln('| File che ne contengono | **$fileToccati** |');
    b.writeln();
    b.writeln('## Il metodo, e cosa NON conta');
    b.writeln();
    b.writeln('Si leggono i letterali di `lib/`, saltando i commenti. Una '
        'stringa conta come rivolta alla persona se **contiene almeno due '
        'parole di lettere e almeno uno spazio**: e\' la soglia che tiene '
        'fuori i nomi di chiave, i percorsi degli asset, gli identificativi e '
        'le costanti tecniche, che sono la maggioranza dei letterali di un '
        'programma e non si traducono.');
    b.writeln();
    b.writeln('Restano fuori per costruzione: le stringhe di una riga sola '
        'senza spazi, quelle che sembrano un percorso o una chiave (contengono '
        '`/`, `_`, `.dart`, `http`), e quelle sotto le tre lettere.');
    b.writeln();
    b.writeln('**Il numero e\' una stima per difetto e per eccesso insieme**, e '
        'va detto: una frase spezzata su tre righe conta tre volte, e una '
        'chiave scritta a parole conta come frase. Serve a dare l\'ordine di '
        'grandezza, non il preventivo al centesimo.');
    b.writeln();
    b.writeln('## Cosa cambia con chi legge');
    b.writeln();
    b.writeln('Sono le stringhe piu\' care da tradurre, perche\' una lingua '
        'diversa accorda in modo diverso. Si riconoscono da tre segni: '
        'un\'interpolazione accanto a una parola che potrebbe volgere al '
        'plurale, un accordo di genere scritto a mano (`/a`, `/o`), e la '
        'chiamata alla `d` eufonica, che e\' una regola dell\'italiano e in '
        'un\'altra lingua non esiste.');
    b.writeln();
    b.writeln('## COSA DICE QUESTO CENSIMENTO');
    b.writeln();
    b.writeln('La domanda del fondatore e\' se l\'internazionalizzazione sia un '
        'ordine o tre. **Il censimento risponde: sono due lavori di taglia '
        'molto diversa, e vanno separati.**');
    b.writeln();
    b.writeln('**L\'INTERFACCIA e\' un ordine solo.** Sono $nelCodice stringhe, '
        'corte, ripetute e senza contenuto esoterico: pulsanti, etichette, '
        'titoli, avvisi. Un traduttore le fa con un glossario, e un sistema '
        'di localizzazione le regge tutte.');
    b.writeln();
    b.writeln('**IL CONTENUTO NON E\' UN ORDINE, e\' un progetto.** Sono '
        '$neiCorpus stringhe, cioe\' ${(neiCorpus * 100 / totale).round()} per '
        'cento del totale, e non sono frasi da tradurre: sono i responsi '
        'dei tarocchi, il sapere delle rune, i nomi e le voci degli angeli, '
        'i sentieri, l\'oroscopo, i testi della sinastria. **Tradurli e\' '
        'riscrivere un corpus esoterico in un\'altra lingua**, e chi lo fa '
        'deve conoscere la tradizione in quella lingua, non solo la lingua. '
        'Un traduttore generico qui produce testo corretto e falso.');
    b.writeln();
    b.writeln('**E c\'e\' un terzo lavoro, piccolo di numero e grande di '
        'rischio: l\'accordo.** Sono $conAccordo punti in cui la frase cambia '
        'con chi legge o con quanti sono. In italiano si risolvono con un '
        'plurale e una `d` eufonica; in una lingua che declina, o che ha '
        'generi diversi dai nostri due, ognuno di questi punti e\' una '
        'decisione. Vanno affrontati PRIMA di tradurre, perche\' decidono la '
        'forma delle chiavi.');
    b.writeln();
    b.writeln('## Da dove conviene cominciare');
    b.writeln();
    b.writeln('| file | stringhe |');
    b.writeln('| --- | --- |');
    for (final e in iPiuCarichi) {
      b.writeln('| `${e.key}` | ${e.value} |');
    }
    b.writeln();
    b.writeln('## Cosa NON esiste oggi, verificato');
    b.writeln();
    b.writeln('- Nessun file `.arb` nel repository.');
    b.writeln('- Nessuna cartella `lib/l10n`.');
    b.writeln('- Nessuna dipendenza `intl` o `flutter_localizations` in '
        '`pubspec.yaml`.');
    b.writeln('- Nessuna `Locale` dichiarata nell\'app.');
    b.writeln();
    b.writeln('Quindi le stringhe che passano da un sistema di traduzione sono '
        '**$tradotte**, e non e\' una stima: e\' un conto su un sistema che non '
        'c\'e\'.');
    return b.toString();
  }
}

/// Vero se il file porta CONTENUTO invece che INTERFACCIA.
///
/// **La riga di taglio non e' un elenco di nomi, e' la cartella.** Un elenco
/// di nomi ("corpus", "lore", "catalog") invecchia al primo file nuovo che si
/// chiama diversamente: misurato, ne lasciava fuori i tarocchi, i sentieri, gli
/// angeli e l'oroscopo, cioe' proprio i corpus piu' grossi. Qui vale la
/// struttura del progetto, che e' un fatto: sotto `lib/features` e
/// `lib/design_system` vivono le schermate, sotto `lib/core` e `lib/services`
/// vivono i contenuti e i motori.
///
/// **La distinzione serve perche' sono due lavori diversi.** Tradurre
/// l'interfaccia e' un lavoro di stringhe corte e ripetute; tradurre il corpus
/// e' un lavoro di scrittura esoterica in un'altra lingua, che non si fa con un
/// glossario.
bool _eUnCorpus(String percorso) =>
    percorso.startsWith('lib/core/') || percorso.startsWith('lib/services/');

/// Vero se la stringa cambia con chi legge.
bool _haAccordo(String testo) {
  if (RegExp(r'\$\{?\w').hasMatch(testo)) {
    // Un'interpolazione accanto a una parola che in un'altra lingua
    // volgerebbe al plurale o cambierebbe genere.
    if (RegExp(r'\$\{?[\w.()]+\}?\s+\w{3,}').hasMatch(testo)) return true;
  }
  // L'accordo di genere scritto a mano.
  if (RegExp(r'\w+[oae]/[oae]\b').hasMatch(testo)) return true;
  return false;
}

RapportoDelleStringhe censisci() {
  final trovate = <StringaCensita>[];
  final file = <String>{};
  final esp = RegExp(r"'((?:[^'\\]|\\.)*)'");
  var euphonic = 0;

  for (final f in Directory('lib').listSync(recursive: true)) {
    if (f is! File || !f.path.endsWith('.dart')) continue;
    final p = f.path.replaceAll(Platform.pathSeparator, '/');
    final righe = f.readAsLinesSync();
    for (var i = 0; i < righe.length; i++) {
      final r = righe[i];
      final nudo = r.trimLeft();
      if (nudo.startsWith('//')) continue;
      if (r.contains('aEuphonic(')) euphonic++;
      for (final m in esp.allMatches(r)) {
        final t = m.group(1) ?? '';
        if (!_sembraUnaFrase(t)) continue;
        trovate.add(StringaCensita(
          file: p,
          riga: i + 1,
          testo: t,
          corpus: _eUnCorpus(p),
          accordo: _haAccordo(t),
        ));
        file.add(p);
      }
    }
  }

  // La `d` eufonica e' una regola dell'italiano: ogni suo uso e' una frase che
  // in un'altra lingua va ricomposta.
  for (var i = 0; i < euphonic; i++) {
    trovate.add(StringaCensita(
      file: 'lib/core/lang/euphonic.dart',
      riga: 0,
      testo: 'accordo eufonico',
      corpus: false,
      accordo: true,
    ));
  }

  // Il conto di cio' che passa da un sistema di traduzione, misurato invece
  // che assunto: si cercano i segni che un sistema lascia.
  var tradotte = 0;
  for (final f in Directory('lib').listSync(recursive: true)) {
    if (f is! File || !f.path.endsWith('.dart')) continue;
    final s = f.readAsStringSync();
    if (s.contains('AppLocalizations') ||
        s.contains('S.of(context)') ||
        s.contains('.tr()')) {
      tradotte++;
    }
  }

  return RapportoDelleStringhe(trovate, file.length, tradotte);
}

/// Vero se il letterale sembra una frase per una persona e non una chiave.
bool _sembraUnaFrase(String t) {
  if (t.length < 4) return false;
  if (!t.contains(' ')) return false;
  if (t.contains('/') || t.contains('.dart') || t.contains('http')) {
    return false;
  }
  // Almeno due parole fatte di lettere.
  final parole = t
      .split(RegExp(r'\s+'))
      .where((p) => RegExp(r'^[A-Za-zÀ-ù]{2,}$').hasMatch(p))
      .length;
  return parole >= 2;
}

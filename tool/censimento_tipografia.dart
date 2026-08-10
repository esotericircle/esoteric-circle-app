/// Il censimento delle misure tipografiche scritte a mano sotto `lib/`.
///
/// Serve a due cose che devono dire lo STESSO numero: genera
/// `docs/tipografia/censimento.md` e alimenta `test/tipografia_nel_dato_test.dart`,
/// che da qui in avanti impedisce a quel numero di crescere. Se l'enumeratore
/// vivesse in due copie, il giorno che una delle due sbaglia il conto nessuno se
/// ne accorgerebbe, perche' sarebbero d'accordo solo per caso.
///
/// COME SI CERCA, e perche' cosi'. Il sorgente si legge INTERO come una stringa
/// sola, non riga per riga: una chiamata come
///
///     style: TypographyTokens.body(
///       size: 14,
///     ),
///
/// e' una misura esplicita esattamente come quella scritta su una riga, ma una
/// ricerca che guardi una riga alla volta non la vede mai. Il test dei minimi lo
/// faceva, ed e' il motivo per cui il conto storico (571 chiamate) era piu'
/// piccolo del vero. Regola generale: si ricompone il testo come lo legge una
/// persona, unendo le righe adiacenti e i frammenti concatenati, e si guardano
/// entrambe le forme di virgolette. Se il numero torna piccolo, la prima ipotesi
/// non e' che il debito sia piccolo: e' che la ricerca sia sbagliata.
library;

import 'dart:io';

/// Una misura di carattere scritta a mano in un punto preciso del sorgente.
class MisuraEsplicita {
  const MisuraEsplicita({
    required this.file,
    required this.riga,
    required this.forma,
    required this.famiglia,
    required this.misura,
    required this.diLettura,
  });

  /// Percorso col separatore normalizzato a barra, cosi' Windows e Linux
  /// producono lo stesso censimento.
  final String file;
  final int riga;

  /// Come e' scritta: `ruolo` (nessuna misura, non e' debito), `token`
  /// (`TypographyTokens.body(size: 14)`), `fontSize` (`TextStyle(fontSize: 14)`
  /// e ogni `copyWith(fontSize: ...)`).
  final String forma;

  /// `display`, `body`, `label` per le chiamate ai token; `ignota` per i
  /// `fontSize` sciolti, dove la famiglia la decide il TextStyle che li ospita.
  final String famiglia;
  final double misura;

  /// Vero quando la misura governa testo che si LEGGE, non un'etichetta: la
  /// famiglia del corpo (`body`) e i `fontSize` sciolti, che nell'app stanno
  /// quasi sempre su testo narrato. Le etichette cerimoniali in maiuscoletto
  /// (`label`) e i titoli (`display`) restano fuori, perche' li' sotto sedici
  /// punti e' una scelta di composizione e non un problema di lettura.
  final bool diLettura;

  @override
  String toString() => '$file:$riga $forma '
      '${famiglia == 'ignota' ? '' : '$famiglia '}${_num(misura)}';
}

/// Le chiamate ai token con misura esplicita: `TypographyTokens.body(size: 14)`,
/// anche spezzata su piu' righe, anche con altri argomenti prima di `size`.
final _chiamataToken = RegExp(
  r'TypographyTokens\.(display|body|label)\s*\(([^()]*)\)',
  multiLine: true,
);

/// I `fontSize:` scritti a mano ovunque: dentro un `TextStyle`, dentro un
/// `copyWith`, dentro un tema. Sono misure esplicite come le altre.
final _fontSize = RegExp(r'fontSize:\s*([0-9]+(?:\.[0-9]+)?)\b');

final _size = RegExp(r'\bsize:\s*([0-9]+(?:\.[0-9]+)?)\b');

String _num(double v) => v == v.roundToDouble()
    ? v.toStringAsFixed(0)
    : v.toString().replaceAll('.', ',');

/// Enumera tutte le misure esplicite sotto [radice].
///
/// Ordina per file e poi per riga, cosi' due esecuzioni sulla stessa base danno
/// lo stesso elenco e il censimento non cambia da solo.
List<MisuraEsplicita> censisci({String radice = 'lib'}) {
  final trovate = <MisuraEsplicita>[];
  final files = Directory(radice)
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList()
    ..sort((a, b) => _norm(a.path).compareTo(_norm(b.path)));

  for (final f in files) {
    final sorgente = f.readAsStringSync();
    final percorso = _norm(f.path);
    final inizioRiga = _indiceDelleRighe(sorgente);

    for (final m in _chiamataToken.allMatches(sorgente)) {
      final argomenti = m.group(2)!;
      final size = _size.firstMatch(argomenti);
      if (size == null) continue; // e' un ruolo, oppure la misura di default
      final famiglia = m.group(1)!;
      trovate.add(MisuraEsplicita(
        file: percorso,
        riga: _rigaDi(inizioRiga, m.start),
        forma: 'token',
        famiglia: famiglia,
        misura: double.parse(size.group(1)!),
        diLettura: famiglia == 'body',
      ));
    }

    for (final m in _fontSize.allMatches(sorgente)) {
      trovate.add(MisuraEsplicita(
        file: percorso,
        riga: _rigaDi(inizioRiga, m.start),
        forma: 'fontSize',
        famiglia: 'ignota',
        misura: double.parse(m.group(1)!),
        diLettura: true,
      ));
    }
  }

  trovate.sort((a, b) {
    final f = a.file.compareTo(b.file);
    return f != 0 ? f : a.riga.compareTo(b.riga);
  });
  return trovate;
}

String _norm(String path) => path.replaceAll(r'\', '/');

List<int> _indiceDelleRighe(String sorgente) {
  final inizi = <int>[0];
  for (var i = 0; i < sorgente.length; i++) {
    if (sorgente.codeUnitAt(i) == 0x0A) inizi.add(i + 1);
  }
  return inizi;
}

int _rigaDi(List<int> inizi, int offset) {
  var basso = 0;
  var alto = inizi.length - 1;
  while (basso < alto) {
    final mezzo = (basso + alto + 1) ~/ 2;
    if (inizi[mezzo] <= offset) {
      basso = mezzo;
    } else {
      alto = mezzo - 1;
    }
  }
  return basso + 1;
}

/// Il totale registrato nel censimento, letto dal documento stesso.
///
/// Il numero vive in un posto solo, dentro `docs/tipografia/censimento.md`: la
/// guardia lo rilegge da li' invece di portarne una copia, cosi' aggiornare il
/// censimento e aggiornare la soglia sono la stessa azione e non due.
int totaleRegistrato({String documento = 'docs/tipografia/censimento.md'}) {
  final testo = File(documento).readAsStringSync();
  final m = RegExp(r'<!-- TOTALE_CENSITO:\s*(\d+)\s*-->').firstMatch(testo);
  if (m == null) {
    throw StateError(
        'In $documento manca la marca <!-- TOTALE_CENSITO: n -->, che e\' il '
        'numero su cui si regge la guardia. Rigenera il censimento con '
        'dart run tool/censimento_tipografia.dart');
  }
  return int.parse(m.group(1)!);
}

void main(List<String> argomenti) {
  final misure = censisci();
  // Con `--elenco` sputa un punto per riga invece di riscrivere il documento:
  // serve a confrontare questa ricerca con un'altra (per esempio un grep) e a
  // capire dove differiscono, invece di fidarsi che i due totali coincidano.
  if (argomenti.contains('--elenco')) {
    for (final m in misure) {
      stdout.writeln('${m.file}:${m.riga} ${m.forma}');
    }
    return;
  }
  final perFile = <String, List<MisuraEsplicita>>{};
  for (final m in misure) {
    perFile.putIfAbsent(m.file, () => []).add(m);
  }
  // ZERO NON E' UNA MISURA TROPPO PICCOLA, e' l'assenza di testo: e' il valore
  // che un calcolo restituisce quando non c'e' niente da scrivere, e trattarlo
  // come una violazione del pavimento vorrebbe dire chiedere una misura
  // leggibile per un carattere che non esiste.
  final sottoIlPavimento =
      misure.where((m) => m.misura > 0 && m.misura < 12).toList();
  final letturaSotto16 =
      misure.where((m) => m.diLettura && m.misura < 16).toList();

  final b = StringBuffer()
    ..writeln('# Censimento delle misure tipografiche scritte a mano')
    ..writeln()
    ..writeln('<!-- TOTALE_CENSITO: ${misure.length} -->')
    ..writeln('<!-- Generato da tool/censimento_tipografia.dart. Non si '
        'scrive a mano: si rigenera. -->')
    ..writeln()
    ..writeln(
        'Ogni riga qui sotto e\' un punto in cui la misura di un carattere e\' '
        'decisa a mano invece di venire da un ruolo. Il numero totale puo\' solo '
        'SCENDERE: `test/tipografia_nel_dato_test.dart` lo rilegge da questo '
        'documento e cade se qualcuno ne aggiunge una.')
    ..writeln()
    ..writeln('## Il metodo di misura')
    ..writeln()
    ..writeln(
        'Si contano due forme, ed e\' la stessa cosa vista da due lati: le '
        'chiamate ai token con misura esplicita (`TypographyTokens.body(size: '
        '14)`) e i `fontSize:` letterali ovunque compaiano, dentro un '
        '`TextStyle`, dentro un `copyWith`, dentro un tema. Le chiamate senza '
        'misura, cioe\' i ruoli, NON sono debito e non si contano: sono la meta.')
    ..writeln()
    ..writeln(
        'Il sorgente si legge INTERO come una stringa sola, non riga per riga, '
        'perche\' una chiamata spezzata su tre righe e\' una misura esplicita '
        'come le altre e una ricerca a righe non la vedrebbe mai. E\' il difetto '
        'della vecchia misura, che si fermava alla riga singola. Se il totale '
        'torna piccolo, la prima ipotesi non e\' che il debito sia piccolo: e\' '
        'che la ricerca sia sbagliata.')
    ..writeln()
    ..writeln(
        'Il guadagno del metodo non e\' dichiarato, e\' misurato: confrontando '
        'questo elenco con quello di una ricerca a righe sulla stessa base, due '
        'punti compaiono solo qui, `lib/design_system/components/guida_del_respiro'
        '.dart:251` e `lib/features/santuario/sky_overview_screen.dart:1130`, '
        'perche\' in tutti e due la misura sta sulla riga sotto al nome del '
        'token. Sono pochi oggi e sarebbero molti il giorno che qualcuno '
        'riformatta il file.')
    ..writeln()
    ..writeln('## I tre numeri')
    ..writeln()
    ..writeln('| Grandezza | Valore |')
    ..writeln('| --- | --- |')
    ..writeln('| Misure esplicite sotto `lib/` | **${misure.length}** |')
    ..writeln('| File che ne contengono | **${perFile.length}** |')
    ..writeln(
        '| Sotto il pavimento assoluto di 12 | **${sottoIlPavimento.length}** |')
    ..writeln('| Sotto 16 in contesto di lettura | '
        '**${letturaSotto16.length}** |')
    ..writeln()
    ..writeln(
        'Contesto di lettura vuol dire testo che si legge e non si guarda: la '
        'famiglia del corpo (`body`) e i `fontSize` sciolti, che nell\'app '
        'stanno quasi sempre su testo narrato. Le etichette cerimoniali in '
        'maiuscoletto e i titoli restano fuori, perche\' li\' sotto sedici punti '
        'e\' una scelta di composizione, non un problema di lettura.')
    ..writeln();

  if (sottoIlPavimento.isNotEmpty) {
    b
      ..writeln('## Sotto il pavimento assoluto di 12')
      ..writeln()
      ..writeln(
          'Queste misure il pavimento le taglia gia\' in release e le fa gridare '
          'in debug. Vanno tolte, non censite per sempre.')
      ..writeln();
    for (final m in sottoIlPavimento) {
      b.writeln('- `${m.file}:${m.riga}` ${m.forma} '
          '${m.famiglia == 'ignota' ? '' : '${m.famiglia} '}${_num(m.misura)}');
    }
    b.writeln();
  }

  b
    ..writeln('## Dove il pavimento NON arriva, e perche\'')
    ..writeln()
    ..writeln(
        'Il pavimento vive dentro i token, quindi governa chi passa da loro. '
        'Un `TextStyle` costruito a mano gli sfugge per costruzione, e le '
        'quattro misure elencate qui sopra sono esattamente quelle: nessun '
        'assert le prende, solo questo censimento. Vanno tolte, e finche\' ci '
        'sono stanno scritte.')
    ..writeln()
    ..writeln(
        'L\'unico punto che ha DIRITTO di scegliere la propria misura e\' '
        'l\'anello curvo della ruota archetipica '
        '(`lib/features/maestri/aura/archetype/archetype_wheel.dart`), dove i '
        'dodici nomi si dispongono lungo una circonferenza e la taglia si '
        'calcola per farceli stare: nessun ruolo puo\' saperlo in anticipo. '
        'Quel punto si costruisce lo stile a mano proprio per questo, e la '
        'ragione sta scritta accanto al codice.')
    ..writeln()
    ..writeln(
        'Le misure PROPORZIONALI a un contenitore (l\'iniziale dentro '
        'l\'avatar, il numero dentro l\'emblema) non sono debito ma non sono '
        'nemmeno libere: si appoggiano al pavimento con un `math.max`, cosi\' '
        'un cerchio piccolo non produce una lettera illeggibile. Se l\'iniziale '
        'non ci sta, il problema e\' il cerchio.')
    ..writeln()
    ..writeln('## Il debito, file per file')
    ..writeln()
    ..writeln('| File | Misure | Sotto 12 | Lettura sotto 16 |')
    ..writeln('| --- | ---: | ---: | ---: |');
  final ordinati = perFile.keys.toList()
    ..sort((a, b) {
      final d = perFile[b]!.length.compareTo(perFile[a]!.length);
      return d != 0 ? d : a.compareTo(b);
    });
  for (final file in ordinati) {
    final righe = perFile[file]!;
    final sotto12 = righe.where((m) => m.misura < 12).length;
    final lettura = righe.where((m) => m.diLettura && m.misura < 16).length;
    b.writeln('| `$file` | ${righe.length} | $sotto12 | $lettura |');
  }
  b.writeln();

  final documento = File('docs/tipografia/censimento.md');
  documento.parent.createSync(recursive: true);
  documento.writeAsStringSync(b.toString());
  stdout.writeln('Censite ${misure.length} misure esplicite in '
      '${perFile.length} file. Sotto 12: ${sottoIlPavimento.length}. '
      'Lettura sotto 16: ${letturaSotto16.length}.');
}

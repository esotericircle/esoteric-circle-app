import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA GUARDIA DELL'ORDINE CM.** 1 settembre 2026.
///
/// Non racconta l'ordine: **lo verifica**. Ogni cosa che il manifesto dichiara
/// fatta viene riaperta sul disco e ricontata, perche' un manifesto e' un
/// documento che si scrive a mano, e cio' che si scrive a mano si puo'
/// scrivere sbagliato.
///
/// **La regola C, applicata a se stessa.** Questo file nasce dalla voce 07
/// dello stesso ordine che sorveglia: se una voce di quest'ordine restasse
/// aperta, la prova qui sotto sarebbe rossa e direbbe quale, invece di
/// lasciare che l'ordine si dica chiuso.
void main() {
  final manifesto = File('docs/ordini/ORDINE_CM_MANIFESTO.md');

  String testoDelManifesto() {
    expect(manifesto.existsSync(), isTrue,
        reason: 'il manifesto dell\'ordine CM non esiste: senza, non c\'e\' '
            'niente da verificare e l\'ordine non e\' consegnato');
    return manifesto.readAsStringSync();
  }

  test('il manifesto nomina tutte e undici le voci', () {
    final testo = testoDelManifesto();
    final mancanti = <String>[];
    for (var i = 1; i <= 11; i++) {
      final numero = i.toString().padLeft(2, '0');
      if (!testo.contains('VOCE $numero')) mancanti.add('VOCE $numero');
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto non nomina queste voci: $mancanti. Una voce che '
            'non compare nel manifesto non e\' una voce chiusa in silenzio, '
            'e\' una voce di cui nessuno sa piu\' niente.');
  });

  test('le premesse hanno tutte un esito dichiarato', () {
    final testo = testoDelManifesto();
    var dichiarate = 0;
    for (var i = 1; i <= 5; i++) {
      final riga = RegExp('\\*\\*P$i\\.[^*]*\\*\\*').firstMatch(testo);
      expect(riga, isNotNull,
          reason: 'la premessa P$i non ha la sua riga nel manifesto');
      final corpo = riga!.group(0)!;
      expect(corpo.contains('VERA') || corpo.contains('FALSA'), isTrue,
          reason: 'la premessa P$i non dice se e\' vera o falsa: $corpo');
      dichiarate++;
    }
    cardinaleMinimo(dichiarate, 5,
        cosa: 'premesse col loro esito',
        perche: 'La regola zero vale solo se le premesse sono state guardate '
            'una per una: se qui non se ne conta nessuna, nessuna e\' stata '
            'verificata.');
  });

  test('CM.02: nessuna prova scopre un insieme di file senza cardinale', () {
    // **NON SI CREDE AL MANIFESTO, SI RICONTA.** Il manifesto dichiara zero:
    // qui si riapre la cartella delle prove e si guarda se e' ancora vero.
    final nudi = <String>[];
    var scoprono = 0;
    for (final f in Directory('test').listSync()) {
      if (f is! File || !f.path.endsWith('_test.dart')) continue;
      final testo = f.readAsStringSync();
      final porta = testo.contains('sorgentiDiLib(') ||
          testo.contains('sorgentiDiCartelle(') ||
          testo.contains('fileScoperti(') ||
          testo.contains('righeDiLib(');
      if (!porta && !testo.contains('.listSync(')) continue;
      scoprono++;
      if (porta || testo.contains('cardinaleMinimo(')) continue;
      final forme = [
        RegExp(r'expect\((quanti|guardati|controllate|usi|trovate|censiti|'
            r'esaminate|contate|scorrono|osservate|[a-zA-Z]+\.length), '
            r'greaterThan'),
        RegExp(r'expect\([a-zA-Z]+\.length, [1-9][0-9]*'),
        RegExp(r'expect\([a-zA-Z]+, isNotEmpty'),
      ];
      if (forme.any((r) => r.hasMatch(testo))) continue;
      nudi.add(f.path.split(Platform.pathSeparator).last);
    }

    cardinaleMinimo(scoprono, 100,
        cosa: 'prove che scoprono un insieme di file',
        perche: 'Il manifesto ne dichiara centoventidue: se qui se ne contano '
            'poche, questa prova sta guardando una cartella sbagliata e il '
            'suo zero non vale niente.');
    expect(nudi, isEmpty,
        reason: 'il manifesto dell\'ordine CM dichiara ZERO prove senza '
            'cardinale, e queste ne hanno: $nudi');
  });

  test('CM.04..07: le tre regole stanno nel protocollo e nella ripresa', () {
    const titoli = [
      'Regola A, una guardia nasce rossa',
      'Regola B, chi tocca una zona la prova rossa prima',
      'Regola C, ogni difetto ha un padre',
    ];
    for (final dove in const ['CLAUDE.md', 'docs/ordini/RIPRESA.md']) {
      final file = File(dove);
      expect(file.existsSync(), isTrue, reason: '$dove non esiste');
      final testo = file.readAsStringSync();
      for (final t in titoli) {
        expect(testo.contains(t), isTrue,
            reason: '$dove non porta "$t". Le tre regole dell\'ordine CM '
                'devono stare in tutti e due i posti: il protocollo si legge '
                'all\'apertura, la ripresa si legge quando si riprende in '
                'mano il lavoro, e una regola che sta in uno solo dei due la '
                'legge meta\' delle volte.');
      }
      expect(testo.contains('PROVENIENZA IGNOTA'), isTrue,
          reason: '$dove non porta la dicitura che la regola C impone quando '
              'un difetto non si riesce ad attribuire');
    }
  });

  test('CM.08: la scala del testo porta il numero e la decisione insieme', () {
    final app = File('lib/app.dart').readAsStringSync();
    expect(app.contains('maxScaleFactor: 1.3'), isTrue,
        reason: 'il tetto della scala del testo non e\' piu\' dove era: se e\' '
            'stato alzato, questa riga va aggiornata insieme al corredo, che '
            'a quel punto va rigirato alla scala nuova');
    expect(app.contains('IL TETTO E\' UNA SCELTA, NON UN VINCOLO DI'), isTrue,
        reason: 'accanto al numero non c\'e\' piu\' la ragione del numero. Un '
            'tetto senza la sua ragione scritta accanto torna a sembrare un '
            'vincolo di sistema, che e\' esattamente l\'errore che l\'ordine '
            'CM ha dovuto correggere.');
  });

  test('CM.10: il terzo cancello e le diciotto righe, col loro prefisso', () {
    final sbarramento = File('tool/sbarramento.sh').readAsStringSync();
    expect(sbarramento.contains('SCALA_DEL_TESTO=1.3'), isTrue,
        reason: 'lo sbarramento non gira piu\' il corredo a scala massima: il '
            'terzo cancello e\' sparito, e con lui l\'unico posto in cui '
            'qualcuno guarda l\'app col testo grande');
    expect(sbarramento.contains(r'SCALA 1,3: $nome [E]'), isTrue,
        reason: 'le cadute a scala massima non portano piu\' il prefisso: '
            'senza, una riga fra i rossi accettati metterebbe a tacere quella '
            'cattura ANCHE alla scala uno');
    expect(sbarramento.contains(r'if [ "$GUARDATE" -lt 150 ]'), isTrue,
        reason: 'il corredo a scala massima non ha piu\' il suo cardinale: un '
            'giro che non monta le schermate non trova difetti, e passerebbe '
            'per verde');

    final accettati = File('tool/rossi_accettati.txt').readAsLinesSync();
    final aScala = accettati.where((r) => r.startsWith('SCALA 1,3: ')).toList();
    cardinaleMinimo(aScala.length, 1,
        cosa: 'schermate dichiarate rotte al testo massimo',
        perche: 'Se questo elenco si svuota di colpo, o sono state riparate '
            'tutte, e allora va tolto anche il numero dal manifesto, oppure '
            'qualcuno ha cancellato le righe invece delle cause.');

    final testo = testoDelManifesto();
    final dichiarate = RegExp(r'RESTANO (\w+) SCHERMATE').firstMatch(testo);
    expect(dichiarate, isNotNull,
        reason: 'il manifesto non dice piu\' quante schermate restano rotte, '
            'che e\' la domanda con cui l\'ordine CM si chiude');
    expect(dichiarate!.group(1), 'DICIOTTO',
        reason: 'il manifesto dice ${dichiarate.group(1)} e il registro dei '
            'rossi ne elenca ${aScala.length}: quando le due non coincidono, '
            'a mentire e\' quasi sempre la parola scritta a mano');
    expect(aScala.length, 18,
        reason: 'il registro elenca ${aScala.length} schermate rotte al testo '
            'massimo, il manifesto ne dichiara diciotto');

    // **OGNI RIGA PORTA LA SUA RAGIONE.** Una riga senza ragione e' un
    // difetto con un permesso.
    for (final r in aScala) {
      expect(r.contains('|'), isTrue,
          reason: 'questa riga non porta nessuna ragione: $r');
      final ragione = r.split('|').last.trim();
      expect(ragione.length, greaterThan(30),
          reason: 'la ragione di questa riga e\' troppo corta per essere una '
              'ragione: $r');
    }
  });

  test('l\'ordine CM non e\' finito finche\' una voce resta aperta', () {
    final testo = testoDelManifesto();
    // Le voci si dicono chiuse col loro titolo in maiuscolo; una voce fermata
    // lo direbbe per esteso, e allora questa prova lo direbbe a chi legge.
    final fermate = RegExp(r'VOCE \d\d[^\n]*FERMATA').allMatches(testo).length;
    expect(fermate, 0,
        reason: 'restano $fermate voci fermate: **questa prova e\' rossa per '
            'legge di consegna** finche\' tutte e undici non hanno uno stato '
            'terminale.');
  });
}

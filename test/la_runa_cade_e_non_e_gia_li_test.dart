import 'dart:io';

import 'package:esoteric_circle/core/rituals/sunset_rune.dart';
import 'package:esoteric_circle/core/rituals/sunset_rune_corpus.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA RUNA DEL TRAMONTO. Ordine AS voce 09.
///
/// **Quattro cose chieste da Mauro, e qui si sorvegliano quelle misurabili sul
/// dato e sul sorgente.** Le altre due, la caduta della pietra e l'avviso della
/// posizione che non lampeggia piu', si vedono a schermo e le chiude il
/// collaudo.
void main() {
  final scena =
      File('lib/features/rituals/sunset_rune_screen.dart').readAsStringSync();
  final soloCodice = scena
      .split(String.fromCharCode(10))
      .where((r) => !r.trimLeft().startsWith('//'))
      .join(String.fromCharCode(10));

  test('la bolla "Gira la pietra" non esiste piu', () {
    expect(soloCodice.contains("Text('Gira la pietra'"), isFalse,
        reason: 'la bolla che chiedeva di girare la pietra e tornata: il '
            'destino ha voluto che la runa cadesse dritta o rovesciata, e '
            'girarla a mano non cambia il responso');
    // **MA IL GESTO RESTA VIVO**: sparisce l'invito, non la possibilita'.
    expect(soloCodice.contains('onDoubleTap: _gira'), isTrue,
        reason: 'e sparito anche il gesto: la pietra non si gira piu nemmeno '
            'a chi ci prova, e quella era una possibilita, non un invito');
  });

  test('in attesa del getto la pietra non e gia li', () {
    // Nella fase del getto la scena non deve montare la pietra: deve mostrare
    // l'invito a gettarla. Il difetto era che la runa della sera si vedeva
    // prima di averla gettata.
    final quandoGetta = soloCodice.substring(
        soloCodice.indexOf('if (_fase == _Fase.getto) {'),
        soloCodice.indexOf("Key('sunset_incisione_gesture')"));
    expect(quandoGetta.contains('_pietraVergine('), isFalse,
        reason: 'in attesa del getto si monta ancora la pietra: la runa si '
            'vede prima di averla gettata, e il rito comincia dalla fine');
    expect(quandoGetta.contains("Key('sunset_getta')"), isTrue,
        reason: 'manca l invito a gettare la runa');
  });

  test('la pietra cade davvero, e non si limita a ingrandirsi', () {
    expect(soloCodice.contains('final caduta = _rimbalzo.isAnimating'), isTrue,
        reason: 'la caduta non esiste: la pietra compare al centro senza '
            'arrivare da nessuna parte');
    expect(soloCodice.contains('offset: Offset(0, salita + caduta)'), isTrue,
        reason: 'la caduta si calcola e non si usa');
  });

  test('l avviso della posizione non si dichiara prima di sapere', () {
    expect(soloCodice.contains('bool _rispostaSullaPosizione = false;'), isTrue,
        reason: 'lo stato che dice se la risposta e arrivata non esiste piu: '
            'l avviso torna a comparire e sparire');
    expect(soloCodice.contains("Key('sunset_ora_in_attesa')"), isTrue,
        reason: 'la riga dell ora non ha piu il suo stato di attesa');
  });

  test('merkstave porta accanto cosa vuol dire', () {
    var osservati = 0;
    final nudi = <String>[];
    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      for (final riga in file.readAsLinesSync()) {
        final nuda = riga.trimLeft();
        if (nuda.startsWith('//') || nuda.startsWith('///')) continue;
        // **SOLO LE STRINGHE, non i nomi in codice.** La prima stesura di
        // questa prova accusava `enum RuneVerso { dritto, merkstave }` e
        // `verso == RuneVerso.merkstave`: sono identificatori, non testi
        // mostrati, e nessuno li legge sullo schermo. Di nuovo la finestra
        // sbagliata: qui si guarda la parola dentro gli apici.
        final dentroUnaStringa =
            RegExp('merkstave', caseSensitive: false).allMatches(riga).any((m) {
          final prima = riga.substring(0, m.start);
          final apici =
              "'".allMatches(prima).length + '"'.allMatches(prima).length;
          return apici.isOdd;
        });
        if (!dentroUnaStringa) continue;
        osservati++;
        // La parola tecnica puo' restare, ma dove si MOSTRA deve avere
        // accanto la traduzione. Le righe che la nominano dentro un discorso
        // piu' lungo (le fonti e il metodo) la spiegano da se'.
        final dentroUnDiscorso = riga.contains("verso d'ombra") ||
            riga.contains('convenzioni moderne') ||
            riga.contains('se asimmetrica');
        if (!riga.contains('(rovesciata)') && !dentroUnDiscorso) {
          nudi.add('${file.path.replaceAll(String.fromCharCode(92), "/")}: '
              '${riga.trim()}');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE AS VOCE 09: righe che nominano merkstave $osservati, senza '
        'traduzione ${nudi.length}');
    expect(osservati, greaterThan(0), reason: 'la ricerca gira a vuoto');
    expect(nudi, isEmpty,
        reason: 'qui merkstave si mostra senza dire cosa vuol dire, e nessuno '
            'lo sa: ${nudi.take(4).join("; ")}');
  });

  test('il gesto della sera esiste, cambia coi giorni e non promette esiti',
      () {
    expect(SunsetRuneCorpus.ritiDellaSera, hasLength(4));
    final visti = <String>{};
    for (var g = 0; g < 8; g++) {
      final quando = DateTime(2026, 8, 1).add(Duration(days: g));
      final e = SunsetRune.estrai(quando,
          dataNascita: DateTime(1975, 11, 2), identita: 'prova');
      visti.add(SunsetRuneCorpus.ritoDellaSera(e));
    }
    // ignore: avoid_print
    print('ORDINE AS VOCE 09: gesti della sera diversi in otto sere '
        '${visti.length} su 4');
    expect(visti.length, greaterThan(1),
        reason: 'il gesto della sera e sempre lo stesso');
    // **NESSUNA PROMESSA**, che e' regola di casa per ogni testo esoterico.
    const promesse = ['proteg', 'guarig', 'fortuna', 'garantis', 'ti dara'];
    for (final rito in SunsetRuneCorpus.ritiDellaSera) {
      for (final p in promesse) {
        expect(rito.toLowerCase().contains(p), isFalse,
            reason: 'questo gesto promette un esito: $rito');
      }
    }
  });
}

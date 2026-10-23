import 'dart:io';

import 'package:esoteric_circle/core/l10n/app_strings.dart';
import 'package:esoteric_circle/core/l10n/la_lingua_del_cerchio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// UNA LINGUA NUOVA NON RIAPRE SEICENTO FILE. Ordine DM voce 06.
///
/// **E' il risultato su cui l'ordine si giudica**, e per giudicarlo serve un
/// numero, non una promessa. Il numero e' **quanti file bisogna aprire per
/// aggiungere una lingua**, e questa prova lo tiene fermo.
///
/// **Come lo tiene fermo.** Ogni punto del codice che DECIDE qualcosa in base
/// alla lingua e' un file da riaprire il giorno della lingua nuova. Finche'
/// quei punti stanno tutti in `lib/core/l10n`, il conto e' quello dichiarato
/// qui sotto; il primo `switch` sulla lingua che nasce in una schermata lo fa
/// salire, e nessuno se ne accorgerebbe.
///
/// **Quello che quest'ordine NON promette**: che i testi siano tradotti. Il
/// corpus editoriale resta italiano, ed e' scritto nel rapporto quanto
/// costerebbe non lasciarlo tale. L'impalcatura e' un'altra cosa dal
/// contenuto, e confonderle sarebbe il modo piu' rapido di non avere ne' l'una
/// ne' l'altro.
void main() {
  tearDown(LaLinguaDelCerchio.dimentica);

  test('I TESTI DELL\'INTERFACCIA SEGUONO LA LINGUA, dalla stessa porta', () {
    expect(AppStrings.navSantuario, 'Il Cerchio');
    LaLinguaDelCerchio.faiValere(LinguaDelCerchio.inglese);
    expect(AppStrings.navSantuario, 'The Circle',
        reason: 'cambiata la lingua, la voce della barra non e cambiata: la '
            'porta dei testi non legge la lingua');
    expect(AppStrings.functionTitle('synastry_vip', fallback: 'X'),
        'VIP Synastry');
  });

  test('e una lingua senza quella voce ripiega sull\'italiano, non sul vuoto',
      () {
    LaLinguaDelCerchio.faiValere(LinguaDelCerchio.inglese);
    expect(
        AppStrings.functionTitle('non_esiste', fallback: 'Ripiego'), 'Ripiego');
  });

  test('CHI DECIDE IN BASE ALLA LINGUA STA TUTTO IN UN POSTO', () {
    // **La grandezza misurata e' il numero di file da riaprire.** Un
    // `switch` sulla lingua, o un confronto col suo codice, e' una decisione
    // presa in base alla lingua: se ne nasce uno in una schermata, quella
    // schermata entra nell'elenco dei file da toccare per ogni lingua nuova.
    const laCasa = 'lib/core/l10n/';
    final fuori = <String>[];
    var guardati = 0;
    final decide = RegExp(
      r'LinguaDelCerchio\.(italiano|inglese)\b'
      r"|LaLinguaDelCerchio\.corrente\.value\s*==",
    );
    for (final f in sorgentiDiLib()) {
      final percorso = f.path.replaceAll('\\', '/');
      guardati++;
      if (percorso.contains(laCasa)) continue;
      for (final riga in f.readAsLinesSync()) {
        final pulita = riga.trim();
        if (pulita.startsWith('//')) continue;
        if (decide.hasMatch(pulita)) fuori.add('$percorso: $pulita');
      }
    }
    expect(guardati, greaterThanOrEqualTo(500),
        reason: 'guardati solo $guardati file: questa prova stava per dire '
            'il vero su niente');
    expect(fuori, isEmpty,
        reason: 'questi file decidono in base a una lingua per nome, e il '
            'giorno della lingua nuova vanno riaperti uno per uno:\n  '
            '${fuori.join("\n  ")}');
  });

  test('IL CONTO DEI FILE DA APRIRE PER UNA LINGUA NUOVA', () {
    // **Il numero, dichiarato.** Per aggiungere una lingua si apre:
    //   1. `la_lingua_del_cerchio.dart`, per **una riga sola**: il valore
    //      nuovo dell'elenco, col suo codice, il suo nome nella sua lingua,
    //      il suo nome in italiano per i prompt e se le tre forme del genere
    //      coincidono;
    //   2. `app_strings.dart`, per le voci dell'interfaccia in quella lingua.
    // E basta. I delegati di sistema, il separatore decimale, la lingua della
    // risposta del modello e la marca del genere **si servono da soli**,
    // perche' leggono l'elenco e non un nome.
    //
    // **E la riga dell'elenco obbliga a dichiarare**: `senzaGenere` non ha
    // un valore di partenza, quindi chi aggiunge una lingua deve decidere.
    // Un ternario scritto fuori dall'elenco avrebbe trattato in silenzio
    // ogni lingua nuova come priva di genere.
    final casa = [
      for (final f in sorgentiDiLib())
        if (f.path.replaceAll('\\', '/').contains('lib/core/l10n/'))
          f.path.replaceAll('\\', '/').split('/').last,
    ]..sort();
    // ignore: avoid_print
    print('ORDINE DM VOCE 06: la casa della lingua ha ${casa.length} file, '
        '$casa');
    expect(casa, contains('la_lingua_del_cerchio.dart'));
    expect(casa, contains('app_strings.dart'));
    // **E la casa resta piccola.** Se un giorno contenesse venti file,
    // "aprirne due" non sarebbe piu' vero: questa riga e' il campanello.
    expect(casa.length, lessThanOrEqualTo(6),
        reason: 'la casa della lingua e cresciuta a ${casa.length} file: '
            'il conto dichiarato nel rapporto non e piu vero');
  });

  test('NESSUNO FA UN CASO PER LINGUA, nemmeno dentro casa', () {
    // **E' l'invariante che rende vera la promessa della riga sola.**
    // Un `switch` sull'elenco, o un `if` che nomina una lingua, e' un posto
    // dove la lingua nuova va aggiunta a mano: finche' non ce n'e' nessuno,
    // **tutto cio' che una lingua sa sta scritto nella sua riga**, cioe' il
    // codice, il nome nella sua lingua, il nome in italiano per i prompt e
    // se le tre forme del genere coincidono.
    //
    // Cercato su TUTTO `lib`, casa della lingua compresa: e' l'unica prova
    // di questo file che non fa eccezioni per `core/l10n`.
    final casi = <String>[];
    var guardati = 0;
    // **I DUE VERSI DEL CONFRONTO, e il secondo l'ha insegnato un innesto.**
    // La prima stesura cercava solo `LinguaDelCerchio.x ==`, cioe' il nome
    // prima dell'operatore. Innestato il difetto nella forma piu' naturale,
    // `corrente.value == LinguaDelCerchio.italiano`, la guardia **non l'ha
    // preso**: guardava un verso solo di una cosa che se ne scrive in due.
    //
    // Non si cerca ogni nomina di una lingua, perche' alcune sono legittime:
    // il valore di partenza dell'elenco e il ripiego di `dalCodice` nominano
    // l'italiano senza decidere niente. Si cerca **la decisione**: un caso,
    // un confronto, una freccia.
    final caso = RegExp(
      r'switch\s*\([^)]*LinguaDelCerchio'
      r'|case\s+LinguaDelCerchio\.'
      r'|LinguaDelCerchio\.(italiano|inglese)\s*(=>|==|!=)'
      r'|(==|!=)\s*LinguaDelCerchio\.(italiano|inglese)',
    );
    for (final f in sorgentiDiLib()) {
      guardati++;
      for (final riga in f.readAsLinesSync()) {
        final pulita = riga.trim();
        if (pulita.startsWith('//')) continue;
        if (caso.hasMatch(pulita)) {
          casi.add('${f.path.replaceAll(r'\', '/')}: $pulita');
        }
      }
    }
    expect(guardati, greaterThanOrEqualTo(500));
    expect(casi, isEmpty,
        reason: 'qui si fa un caso per lingua, e una lingua nuova andrebbe '
            'aggiunta anche qui invece che nella sola riga dell elenco: '
            '${casi.join(" | ")}');
  });

  test('e i delegati di sistema si servono dall\'elenco, non da un nome', () {
    // Aggiungere una lingua all'elenco deve bastare perche' i widget di
    // sistema la parlino: `app.dart` genera `supportedLocales` scorrendo
    // `LinguaDelCerchio.values`, e non elencando codici a mano.
    final app = File('lib/app.dart').readAsStringSync();
    expect(app, contains('for (final l in LinguaDelCerchio.values)'),
        reason: 'app.dart elenca le lingue a mano invece di scorrere '
            'l elenco: una lingua nuova non arriverebbe ai selettori');
  });
}

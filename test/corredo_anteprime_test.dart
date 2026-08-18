import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// IL CORREDO DELLE ANTEPRIME HA UNA PORTA SOLA, E QUELLA PORTA MISURA 360.
///
/// **Cosa e' successo.** In un giro precedente ho dichiarato "cinquantanove
/// anteprime rigenerate" alla misura reale. Dodici avevano impronta identica a
/// prima, quindi non erano passate dalla misura nuova. Fra queste
/// `le-tue-arti.png`, che misurava ancora 390 per 844.
///
/// **Le tre cause, tutte diverse.**
///
/// 1. Una SECONDA PORTA: `mano_anteprima_test.dart` scriveva dritto in
///    `docs/preview` senza passare dal corredo, quindi la sua anteprima non
///    aveva mai visto la misura reale.
/// 2. Tre anteprime ORFANE, nate da prove temporanee poi cancellate: nessuno le
///    rigenerava piu' e restavano ferme all'ultima volta.
/// 3. Due catture ROTTE che nessuno guardava: da quando il lettore audio reale
///    e' il default, aprire la Meditazione tentava di riprodurre e in prova il
///    plugin non c'e'. La cattura cadeva e la sua anteprima smetteva di
///    aggiornarsi in silenzio.
///
/// E' la settima volta che incontro la stessa forma: **una regola messa in una
/// porta quando le porte sono due non e' una regola**. Per questo la regola sta
/// qui, nel dato, e non in un controllo a mano.
/// Il rapporto che ogni anteprima deve dichiarare.
const double rapportoDichiarato = 3.0;

void main() {
  final corredo = File('test/screenshot_capture_test.dart').readAsStringSync();

  test('La misura reale e\' dichiarata, ed e\' la prima', () {
    expect(corredo.contains('schermoReale = Size(360, 797)'), isTrue,
        reason: 'il corredo non dichiara piu\' la misura del telefono su cui '
            'l\'app viene guardata');
    // Le catture che non dicono altro partono da li'.
    expect(corredo.contains('schermo ?? schermoReale'), isTrue,
        reason: 'le catture non partono piu\' dalla misura reale');
  });

  test('Nessuna cattura resta alla larghezza vecchia', () {
    // La larghezza sbagliata era 390. Se ricompare in una cattura, quella
    // anteprima torna a mentire.
    final colpevoli = <String>[];
    final righe = corredo.split('\n');
    for (var i = 0; i < righe.length; i++) {
      final r = righe[i];
      if (r.trimLeft().startsWith('//')) continue;
      // schermoAlto resta come SECONDA misura del corredo, dichiarata.
      if (r.contains('schermoAlto = Size(390')) continue;
      if (r.contains('Size(390')) colpevoli.add('riga ${i + 1}: ${r.trim()}');
    }
    expect(colpevoli, isEmpty,
        reason: 'queste catture usano ancora la larghezza vecchia, quindi le '
            'loro anteprime non mostrano cio\' che si vede sul telefono:\n'
            '${colpevoli.join("\n")}');
  });

  // IL RAPPORTO DI PIXEL E' UN DATO DICHIARATO, MAI IMPLICITO.
  //
  // **Il dato che ha fatto nascere questa prova.** Il corredo impaginava a
  // rapporto UNO e poi ingrandiva l'immagine tre volte in scrittura: il file
  // usciva della misura giusta, ma dipinto come su un telefono che non esiste.
  // A rapporti diversi cambiano la rasterizzazione dei glifi, i tratti sottili
  // e la diffusione delle ombre, quindi un'anteprima a rapporto piu' basso puo'
  // NASCONDERE esattamente i difetti che il corredo esiste per prendere.
  //
  // E c'era di peggio: dentro il corredo TRENTAQUATTRO punti impostavano la
  // misura dello schermo a mano, molti senza dichiarare nessun rapporto, cioe'
  // prendendosi quello lasciato dall'ultima cattura. Portarne tre a rapporto
  // tre e lasciare gli altri ha prodotto subito un overflow di centoquattro
  // pixel, perche' la misura fisica scritta a mano diventava un terzo di
  // schermo. Il rapporto implicito non e' una pedanteria.
  const eccezioniDelRapporto = <String, String>{
    // L'icona dell'app non e' una schermata: si guarda ingrandita per
    // controllare il tratto, non per giudicare come si legge su un telefono.
    'icona_cerchio_capture_test.dart':
        'e\' l\'icona dell\'app, non una schermata, e si cattura a sei per '
            'vedere il tratto da vicino',
  };

  test('Nessuna cattura ha un rapporto di pixel implicito', () {
    final colpe = <String>[];
    for (final f in Directory('test').listSync()) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final nome =
          f.path.replaceAll(Platform.pathSeparator, '/').split('/').last;
      if (nome == 'corredo_anteprime_test.dart') continue;
      final sorgente = f.readAsStringSync();
      // Solo chi SCRIVE un'anteprima: chi usa toImage per contare pixel non
      // produce un'immagine che qualcuno guardera'.
      if (!sorgente.contains('writeAsBytes')) continue;
      if (eccezioniDelRapporto.containsKey(nome)) continue;

      final rapporti = RegExp(r'devicePixelRatio = ([0-9.]+)')
          .allMatches(sorgente)
          .map((m) => m.group(1)!)
          .toSet();
      if (rapporti.isEmpty) {
        // Un rapporto puo' essere dichiarato anche con una COSTANTE. In quel
        // caso e' dichiarato meglio che con un numero scritto: il corredo fa
        // cosi', e la prova qui sotto verifica che quella costante valga tre.
        // Cercare i soli letterali avrebbe bocciato proprio il file che la
        // regola l'ha applicata per primo.
        if (sorgente.contains('rapportoDelCorredo = ')) continue;
        colpe.add('$nome non dichiara nessun rapporto di pixel');
        continue;
      }
      for (final r in rapporti) {
        if (double.parse(r) != rapportoDichiarato) {
          colpe.add('$nome cattura a rapporto $r invece di '
              '$rapportoDichiarato, senza una riga di eccezione');
        }
      }
      // OGNI MISURA HA IL SUO RAPPORTO ACCANTO, non una per file.
      //
      // Guardando il solo INSIEME dei rapporti dichiarati, un file con cinque
      // catture di cui una sola dichiarava il rapporto passava: le altre
      // quattro si prendevano quello lasciato dall'ultima. La prova del rosso
      // lo ha mostrato togliendo un rapporto da un file che ne aveva due, e
      // restando verde. Qui si contano: tante misure, tanti rapporti.
      final misure =
          RegExp(r'tester\.view\.physicalSize = ').allMatches(sorgente).length;
      final dichiarazioni =
          RegExp(r'tester\.view\.devicePixelRatio = ').allMatches(sorgente).length;
      if (misure != dichiarazioni) {
        colpe.add('$nome imposta $misure misure di schermo ma dichiara '
            '$dichiarazioni rapporti: quelle senza si prendono il rapporto '
            'lasciato dalla cattura precedente');
      }
    }
    expect(
      colpe,
      isEmpty,
      reason: 'il rapporto e\' un dato che sta accanto alla misura: se una '
          'cattura non puo\' stare a tre per una ragione tecnica, non si '
          'abbassa in silenzio, si dichiara qui con la ragione accanto.\n'
          '${colpe.join('\n')}',
    );
  });

  test('Il corredo dichiara il rapporto tre, e in un punto solo', () {
    final corredo =
        File('test/screenshot_capture_test.dart').readAsStringSync();
    expect(corredo.contains('const double rapportoDelCorredo = 3.0;'), isTrue,
        reason: 'il rapporto del corredo non e\' piu\' dichiarato');
    // UNA porta sola: se qualcuno rimette un devicePixelRatio a mano, e' un
    // secondo rapporto che puo' divergere dal primo.
    expect(RegExp(r'devicePixelRatio = ').allMatches(corredo).length, 1,
        reason: 'il rapporto si imposta in un punto solo, `montaLoSchermo`');
  });

  test('Il corredo e\' l\'unica porta verso docs/preview', () {
    // Chiunque scriva un\'anteprima fuori da qui crea una seconda porta, e la
    // sua immagine non vedra\' mai la misura reale.
    // UNA SOLA ECCEZIONE, dichiarata: le catture PRIMA e DOPO. Non sono
    // anteprime del corredo, sono la prova visiva di una singola correzione:
    // vivono in `docs/preview/prima_dopo/`, si generano due volte sullo stesso
    // stato con il codice riportato indietro, e non descrivono l'app di oggi.
    // Farle passare dal corredo vorrebbe dire rigenerarle a ogni giro, e la
    // "prima" sparirebbe al primo aggiornamento.
    const eccezioni = {
      'prima_dopo_capture_test.dart',
      // Stessa natura: e' il prima e dopo dell'icona del Cerchio, non
      // un'anteprima dell'app, e la "prima" mostra un'icona che non esiste
      // piu'. Rigenerarla dal corredo la cancellerebbe.
      'icona_cerchio_capture_test.dart',
      // Stessa natura: sono le immagini che l'ordine E ha chiesto per far
      // vedere le sue correzioni, e restano fuori dal corredo perche' mostrano
      // uno stato passato, non l'app di oggi.
      //
      // Qui c'era scritta una DIVERGENZA, ed e' chiusa dal 3 agosto 2026: le
      // catture dell'ordine chiedevano 360 per 797 a rapporto 3, il corredo
      // impaginava a rapporto 1 e ingrandiva in scrittura. Adesso il rapporto
      // e' 3 da entrambe le parti, ed e' lo stesso numero, non due numeri
      // uguali per caso.
      'anteprime_ordine_e_test.dart',
    };
    final fuori = <String>[];
    for (final f in Directory('test').listSync()) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      if (eccezioni.any((e) => f.path.endsWith(e))) continue;
      final nome = f.path.replaceAll(Platform.pathSeparator, '/');
      if (nome.endsWith('screenshot_capture_test.dart')) continue;
      if (nome.endsWith('preview_integrity_test.dart')) continue;
      if (nome.endsWith('corredo_anteprime_test.dart')) continue;
      final t = f.readAsLinesSync()
          .where((r) => !r.trimLeft().startsWith('//'))
          .join('\n');
      // SI CERCA LA SCRITTURA, non la menzione. Il lucchetto guardava se il
      // file nominasse `docs/preview` in qualunque modo, quindi prendeva anche
      // chi quelle immagini si limita a LEGGERLE per misurarle, per esempio il
      // guardiano che verifica se un'anteprima e' stata colta a meta'
      // dissolvenza. Una seconda porta e' chi SCRIVE, non chi guarda.
      final scrive = RegExp(
              r'(writeAsBytes|writeAsString|createSync|copySync)[^;]{0,200}'
              r'docs/preview|docs/preview[^;]{0,200}'
              r'(writeAsBytes|writeAsString|copySync)',
              dotAll: true)
          .hasMatch(t);
      if (!scrive) continue;
      fuori.add(nome);
    }
    expect(fuori, isEmpty,
        reason: 'questi file scrivono anteprime fuori dal corredo: '
            '${fuori.join(", ")}');
  });

  /// LE ANTEPRIME CHE NASCONO FUORI DAL CORREDO, e il loro generatore.
  ///
  /// **Non e' una lista di esenzioni, ed e' la differenza che conta.** Il
  /// corredo e' la porta unica delle CATTURE di schermata, ma non ogni immagine
  /// di `docs/preview/` e' una cattura: l'immagine di verifica degli ancoraggi
  /// (ordine T voce 01) e' l'arte di un Journal con sopra i cinquantacinque
  /// punti trovati, e la produce lo strumento che quei punti li ricava.
  ///
  /// Per ciascuna si dichiara CHI la fa, e la prova va a leggere quel file: se
  /// il generatore sparisce o smette di scrivere quel nome, l'immagine torna
  /// orfana e questa riga cade. **Una riga di esenzione direbbe soltanto "questa
  /// non guardarla"; qui invece si sposta la guardia, non si toglie.**
  const fuoriDalCorredo = <String, List<String>>{
    r'^journal_[a-z]+_[a-z]+\.png$': [
      'tool/anteprime_dei_journal.dart',
      "docs/preview/",
    ],
    r'^festa_[a-z]+_[a-z]+\.png$': [
      'tool/anteprime_delle_feste.dart',
      "docs/preview/festa_",
    ],
    r'^ancoraggi_[a-z]+\.png$': [
      'tool/ancoraggi_dai_sentieri.dart',
      "docs/preview/ancoraggi_",
    ],
    // La mappa delle strozzature (ordine AB voce 01) non e' un'anteprima
    // dell'app: e' la lista della spesa di Mauro per Photoshop, l'arte del Loto
    // attenuata coi sedici punti da ingrossare. La produce lo strumento che quei
    // punti li misura, quindi se un giorno la misura cambia cambia anche
    // l'immagine, e non possono scostarsi.
    r'^strozzature_[a-z]+\.png$': [
      'tool/mappa_delle_strozzature.dart',
      "docs/preview/strozzature_",
    ],
    // La mappa delle perle trovate (ordine AE voce 02): l'arte del Loto coi
    // cinquanta cerchi individuati, colorati per gruppo, cosi' un pallino sul
    // petalo sbagliato si vede in un secondo. La produce lo strumento che le
    // perle le trova, quindi mappa e rilevamento non possono scostarsi.
    r'^loto_perle_trovate\.png$': [
      'tool/trova_le_perle.py',
      "docs/preview/loto_perle_trovate",
    ],
    // La mappa del ritocco (ordine AG voce 01, FERMATA IN ATTESA DI
    // DECISIONE): l'arte del Loto coi dischi rossi che Mauro pulira' in
    // Photoshop e i cerchi, del colore del gruppo, dove il codice posera' le
    // perle a raggio unico. La produce lo strumento che misura, in modalita'
    // --solo-misura, quindi mappa e misura non possono scostarsi.
    r'^loto_ritocco_da_fare\.png$': [
      'tool/perle_uguali_del_loto.py',
      "docs/preview/loto_ritocco_da_fare",
    ],
    // Il quadro delle due vesti della pillola (ordine AI voce 01, FERMATA IN
    // ATTESA DI DECISIONE): velo e oro a 0, 1.000 e 10.000 Eos sui tre fondi,
    // per gli occhi di Mauro. Lo produce il suo strumento, e non possono
    // scostarsi.
    r'^pillola_(due_vesti|tre_momenti)\.png$': [
      'tool/anteprime_della_pillola.dart',
      "docs/preview/pillola_due_vesti",
    ],
    // Il SORGENTE del Loto delle perle (ordine AE): non e' un'anteprima, e' il
    // file di Mauro da cui lo scontorno deriva l'arte, e non si modifica mai
    // sul posto. Il suo custode e' lo strumento che lo consuma: se un giorno lo
    // scontorno smettesse di leggerlo, questo file resterebbe qui senza che
    // nessuno sappia piu' perche', e questa riga lo direbbe.
    r'^journal_loto_nuovo-1\.png$': [
      'tool/scontorna_loto.py',
      "docs/preview/journal_loto_nuovo-1.png",
    ],
    // Le tre feste accostate (ordine AO voce 05): non e' una scena nuova, e'
    // l'accostamento dei tre fotogrammi di meta' festa che lo strumento delle
    // feste ha gia' prodotto dalla scena vera. Serve a rispondere alla
    // domanda di Mauro, che non e' "questa festa e' bella" ma "le tre feste
    // sono diverse", e tre immagini guardate una dopo l'altra non
    // rispondono.
    r'^le-tre-feste-affiancate\.png$': [
      'tool/le_tre_feste_affiancate.py',
      "docs/preview/le-tre-feste-affiancate.png",
    ],
  };

  test('ogni anteprima nata fuori dal corredo ha il suo generatore vivo', () {
    var osservate = 0;
    final morte = <String>[];
    for (final voce in fuoriDalCorredo.entries) {
      osservate++;
      final generatore = File(voce.value[0]);
      if (!generatore.existsSync()) {
        morte.add('${voce.key}: il generatore ${voce.value[0]} non esiste piu\'');
        continue;
      }
      if (!generatore.readAsStringSync().contains(voce.value[1])) {
        morte.add('${voce.key}: ${voce.value[0]} non scrive piu\' '
            '"${voce.value[1]}"');
      }
    }
    // ignore: avoid_print
    print('CORREDO: generatori fuori dal corredo osservati $osservate');
    expect(osservate, greaterThan(0),
        reason: 'la prova non ha guardato nessun generatore: gira a vuoto');
    expect(morte, isEmpty, reason: morte.join(' | '));
  });

  test('Ogni anteprima del repo ha un generatore', () {
    // Un\'anteprima orfana resta ferma all\'ultima volta che qualcuno l\'ha
    // prodotta, e nessuno se ne accorge finche\' non la guarda.
    final orfane = <String>[];
    for (final f in Directory('docs/preview').listSync()) {
      if (f is! File || !f.path.endsWith('.png')) continue;
      final nome = f.uri.pathSegments.last;
      if (corredo.contains(nome)) continue;
      // Diverse catture compongono il nome a runtime: il Maestro davanti, la
      // variante di altezza in coda. Si riconosce la radice.
      final radice = nome
          .replaceFirst(RegExp(r'^(medora|aura|caligo)-'), '')
          .replaceFirst(RegExp(r'-(medora|aura|caligo)'), '')
          .replaceFirst(RegExp(r'-\d{4}\.png$'), '.png')
          .replaceFirst('.png', '');
      if (corredo.contains(radice)) continue;
      // Nata fuori dal corredo, ma con un generatore DICHIARATO e vivo: chi lo
      // presidia e' la prova qui sopra, che va a leggere quel generatore.
      if (fuoriDalCorredo.keys.any((f) => RegExp(f).hasMatch(nome))) continue;
      orfane.add(nome);
    }
    expect(orfane, isEmpty,
        reason: 'queste anteprime non le rigenera nessuno, quindi mostrano uno '
            'stato vecchio: ${orfane.join(", ")}');
  });
}

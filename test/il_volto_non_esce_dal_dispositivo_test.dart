import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

import 'cardinale_minimo.dart';

/// **IL VOLTO NON ESCE DAL DISPOSITIVO.** Ordine CR voce 11, 6 settembre 2026.
///
/// **Cosa chiede l'ordine**: *"Resta e si rafforza quello che la soglia gia'
/// promette: tutto sul dispositivo, nessuna immagine inviata, nessuna immagine
/// salvata. Verificalo nel codice e scrivi nel referto il punto esatto che lo
/// garantisce."*
///
/// **IL PUNTO ESATTO, VERIFICATO E NON PROMESSO.** Nessuno dei file che toccano
/// il volto importa un client di rete. Non e' una dichiarazione di buone
/// intenzioni: **se non c'e' un modo di mandare qualcosa, niente parte**, e un
/// import e' una cosa che si conta.
///
/// **COSA RESTA IN MEMORIA E COSA VA SU DISCO.** I landmark e i coefficienti
/// vivono per la durata della schermata e muoiono con lei. Su disco va
/// `viso.storico`, che contiene per ogni scansione **la data, il nome dei
/// tratti e la loro marcatezza**: nessuna immagine, nessuna coordinata,
/// nessun coefficiente. E vive sotto il prefisso `viso.`, che la cancellazione
/// di `CioCheETuo` porta via.
void main() {
  /// I file che toccano il volto. **L'elenco si scopre**, non si scrive: un
  /// file nuovo che nessuno aggiunge sarebbe una sorveglianza in meno.
  List<File> fileDelVolto() => [
        ...Directory('lib/core/face')
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart')),
        ...Directory('lib/features/maestri/aura/face')
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart')),
      ];

  test('nessun file del volto conosce la rete', () {
    // I modi in cui, in questo progetto, qualcosa parte davvero.
    const dellaRete = [
      'package:http/',
      'dart:io.*HttpClient',
      'package:dio/',
      'cloud_firestore',
      'firebase_storage',
      'package:firebase_functions',
      'FirebaseFunctions',
    ];
    final colpe = <String>[];
    var guardati = 0;
    for (final f in fileDelVolto()) {
      guardati++;
      final testo = f.readAsStringSync();
      for (final r in dellaRete) {
        if (RegExp(r).hasMatch(testo)) {
          colpe.add('${f.path.split(RegExp(r"[\\/]")).last} -> $r');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE CR VOCE 11: file del volto guardati $guardati, che '
        'conoscono la rete ${colpe.length}');
    cardinaleMinimo(guardati, 8,
        cosa: 'file che toccano il volto',
        perche: 'Con pochi file la prova direbbe che nessuno manda niente per '
            'non averne aperti abbastanza.');
    expect(colpe, isEmpty,
        reason: 'questi file del volto conoscono la rete: la promessa che '
            'nulla esce dal dispositivo smette di essere strutturale e diventa '
            'una buona intenzione. ${colpe.join(", ")}');
  });

  test('e sul disco non finiscono ne immagini ne coordinate', () {
    final storico = File('lib/core/face/face_history.dart');
    expect(storico.existsSync(), isTrue,
        reason: 'lo storico del viso non esiste piu');
    final testo = storico.readAsStringSync();

    // Cio' che viene serializzato: si legge il metodo che scrive il JSON.
    final inizio = testo.indexOf('Map<String, dynamic> toJson()');
    expect(inizio, greaterThan(0),
        reason: 'lo storico non ha piu un metodo che scrive il JSON: non si '
            'puo piu sapere cosa finisce su disco');
    final fine = testo.indexOf('};', inizio);
    final serializzato = testo.substring(inizio, fine);

    // **IL PERCORSO DEL RITRATTO E' AMMESSO, I PIXEL NO.** Ordine CX, 8
    // settembre 2026, decisione del fondatore: *"puoi tenerle memorizzate
    // solo sul telefono e dare l'opportunita' all'utente di gestirle?"*.
    //
    // Fino a ieri questa lista vietava anche la parola `foto`, e la sua
    // ragione scritta diceva che lo storico deve contenere *"la data, il
    // tratto e la sua marcatezza, e nient'altro"*. **Non si zittisce una
    // guardia perche' la decisione e' cambiata: si sposta cio' che
    // sorveglia.** Il divieto vero non era il disco, era che il volto
    // uscisse dal telefono, e quello resta intero.
    //
    // Adesso nelle preferenze puo' finire **un percorso**, cioe' una riga di
    // testo che dice dove sta un file. I PIXEL restano vietati: `bytes`,
    // `image`, `base64` dentro il JSON vorrebbero dire il volto dentro le
    // preferenze, che nessuno puo' cancellare file per file.
    const vietati = [
      'image', 'Image', 'bytes', 'base64', 'landmark', 'punti', 'blendshape',
      'espressione', 'contorni', 'dx', 'dy',
    ];
    // **SI CERCANO PAROLE INTERE, NON PEZZI DI PAROLA.** La prima stesura
    // trovava "dy" e accusava lo storico di salvare coordinate: quel
    // "dy" stava dentro `Map<String, dynamic>`. E' la guardia legata al
    // token invece che al fatto, la famiglia che in questo progetto ha gia'
    // prodotto sei cadute, e stavolta l'ho scritta io.
    final trovati = [
      for (final v in vietati)
        if (RegExp('\\b$v\\b').hasMatch(serializzato)) v,
    ];
    // ignore: avoid_print
    print('ORDINE CR VOCE 11: campi vietati trovati in cio che va su disco '
        '${trovati.length}${trovati.isEmpty ? "" : ": ${trovati.join(", ")}"}');
    expect(trovati, isEmpty,
        reason: 'nelle preferenze finiscono dati derivati dal volto oltre al '
            'nome del tratto e al percorso del ritratto: ${trovati.join(", ")}. '
            'Un percorso si cancella, dei pixel dentro le preferenze no');
  });

  test('IL RITRATTO E UN FILE CHE SI PUO CANCELLARE, non dei pixel nascosti',
      () {
    // **LA META CHE RENDE ACCETTABILE LA DECISIONE.** Ordine CX. Conservare
    // una fotografia cambia cosa l app tiene di una persona: e sopportabile
    // solo se quella persona la puo' togliere. Qui si prova che le tre vie
    // esistano, perche' un perimetro scritto in un commento non toglie
    // niente a nessuno.
    final ritratti = File('lib/core/face/ritratti_del_viso.dart');
    expect(ritratti.existsSync(), isTrue,
        reason: 'i ritratti non hanno piu' ' una porta propria: senza, chi '
            'conserva e chi cancella sono due posti diversi');
    final corpo = ritratti.readAsStringSync();
    for (final via in const ['cancella', 'cancellaTutti', 'quanteNeTengono']) {
      expect(corpo.contains(via), isTrue,
          reason: 'manca la via "' '$via' '": conservare senza poter togliere '
              'e una decisione presa al posto della persona');
    }

    final storico = File('lib/core/face/face_history.dart').readAsStringSync();
    for (final via in const ['dimentica', 'dimenticaTutto']) {
      expect(storico.contains(via), isTrue,
          reason: 'lo storico non sa piu' ' togliere una lettura con "' '$via' '"');
    }
    // **E il ritratto non esce dal telefono**, che e' la regola vera: il file
    // dei ritratti non conosce la rete.
    //
    // **SI GUARDA IL CODICE, NON I COMMENTI**, e la prima stesura di questa
    // riga lo ha imparato subito: cadeva sulla parola "Storage" che sta nel
    // commento dove si spiega che Cloud Storage NON c'entra. E'
    // l'asserzione che pesca il proprio commento, la famiglia che questo
    // progetto ha gia' pagato dieci volte, e stavolta l'ho scritta io due
    // minuti prima di leggerne l'esito.
    final soloCodice = senzaCommenti(corpo);
    for (final parola in const ['http', 'Firebase', 'Storage', 'upload']) {
      expect(soloCodice.contains(parola), isFalse,
          reason: 'i ritratti conoscono "' '$parola' '": la fotografia del '
              'volto deve restare su questo telefono');
    }
  });

  test('e lo storico vive sotto il prefisso che la cancellazione porta via',
      () {
    final storico =
        File('lib/core/face/face_history.dart').readAsStringSync();
    final chiave = RegExp(r"_chiave\s*=\s*'([^']+)'").firstMatch(storico);
    expect(chiave, isNotNull,
        reason: 'lo storico non dichiara piu la sua chiave: non si puo sapere '
            'sotto quale prefisso vive');
    final nome = chiave!.group(1)!;

    final cancellazione =
        File('lib/core/identity/cio_che_e_tuo.dart').readAsStringSync();
    final prefisso = nome.split('.').first;
    final coperto = cancellazione.contains("'$prefisso.'");
    // ignore: avoid_print
    print('ORDINE CR VOCE 11: lo storico vive sotto "$nome", il prefisso '
        '"$prefisso." e coperto dalla cancellazione: $coperto');
    expect(coperto, isTrue,
        reason: 'la chiave "$nome" non sta sotto nessun prefisso che la '
            'cancellazione porta via: chi chiede di essere dimenticato si '
            'terrebbe lo storico del proprio volto');
  });
}

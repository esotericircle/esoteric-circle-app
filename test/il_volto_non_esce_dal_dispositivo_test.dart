import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

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

    const vietati = [
      'foto', 'image', 'Image', 'bytes', 'landmark', 'punti', 'blendshape',
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
        reason: 'su disco finiscono dati derivati dal volto oltre al nome del '
            'tratto: ${trovati.join(", ")}. Lo storico deve contenere la data, '
            'il tratto e la sua marcatezza, e nient altro');
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

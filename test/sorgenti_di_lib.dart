import 'dart:io';

import 'cardinale_minimo.dart';

/// I SORGENTI DI `lib`, DA UNA PORTA SOLA. Ordine CL voce 04.
///
/// **Perche' esiste, e perche' e' la stessa medicina che il progetto usa per
/// il codice.** Centootto guardie scorrono `lib` per conto loro, ognuna col
/// suo ciclo scritto a mano. Ognuna di quelle e' esposta alla stessa cecita':
/// **se un giorno quel ciclo non trova piu' niente, la guardia diventa VERDE
/// senza aver controllato nulla**, perche' un ciclo che non gira non trova
/// difetti.
///
/// Instrumentare centootto cicli diversi vorrebbe dire scrivere centootto
/// volte lo stesso controllo, e sbagliarlo da qualche parte. Qui il controllo
/// e' scritto **una volta**: chi passa da questa porta non puo' girare a
/// vuoto, perche' la porta stessa si rifiuta di tornare un elenco troppo
/// corto.
///
/// **Il numero, e da dove viene.** Il 1 settembre 2026 `lib` contiene **525**
/// file Dart, contati sul disco. Il minimo dichiarato e' **400**: un margine
/// di centoventicinque file, che regge una ripulitura seria senza tacere su
/// un elenco che si e' svuotato. Il numero sta QUI e non dentro i cicli,
/// perche' una soglia nascosta dentro un ciclo e' una soglia che nessuno
/// rilegge.
///
/// **Non e' una soglia da abbassare.** Se questa porta cade, o qualcuno ha
/// cancellato meta' progetto, e allora il guasto e' quello; oppure le prove
/// girano da una cartella sbagliata, e allora **tutte le guardie che scorrono
/// i sorgenti stavano per dire il vero su niente**.
List<File> sorgentiDiLib() {
  final file = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList(growable: false);
  cardinaleMinimo(
    file.length,
    quantiFileHaLib,
    cosa: 'file Dart dentro lib',
    perche: 'Ogni guardia che scorre i sorgenti passa di qui: se questo '
        'elenco si svuota, tutte diventano verdi insieme senza aver '
        'guardato niente.',
  );
  return file;
}

/// **QUANTI FILE DEVE AVERE `lib` PERCHE' UNA GUARDIA POSSA DIRE QUALCOSA.**
///
/// 525 contati il 1 settembre 2026, meno un margine dichiarato di 125.
const int quantiFileHaLib = 400;

/// Lo stesso elenco, gia' letto riga per riga, per le guardie che il testo lo
/// devono guardare e non solo elencare.
///
/// Torna coppie di percorso normalizzato e righe: il percorso con le barre
/// dritte, perche' su Windows arrivano rovesciate e mezza dozzina di guardie
/// se lo sono riscritto a mano.
List<({String percorso, List<String> righe})> righeDiLib() => [
      for (final f in sorgentiDiLib())
        (
          percorso: f.path.replaceAll(Platform.pathSeparator, '/'),
          righe: f.readAsLinesSync(),
        ),
    ];

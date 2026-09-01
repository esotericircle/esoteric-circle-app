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

/// **I SORGENTI DI PIU' CARTELLE, DALLA STESSA PORTA.** Ordine CM voce
/// 02.
///
/// Cinque guardie non scorrono soltanto `lib`: guardano anche `test`, e
/// una anche `tool`, perche' la regola che sorvegliano vale su tutto
/// cio' che si scrive, non solo su cio' che si spedisce. Non potevano
/// passare da [sorgentiDiLib], che di cartelle ne conosce una sola, **e
/// per questo erano rimaste fra le ultime senza cardinale.**
///
/// Il minimo lo dichiara chi chiama, perche' cambia con le cartelle
/// chieste, ma **dichiararlo non e' facoltativo**: e' un parametro
/// obbligato, e una guardia che non sa quante cose si aspetta non passa
/// di qui.
List<File> sorgentiDiCartelle(
  List<String> cartelle, {
  required int minimo,
}) {
  final file = <File>[];
  for (final nome in cartelle) {
    final cartella = Directory(nome);
    if (!cartella.existsSync()) {
      throw InsiemeSvuotato(
        'LA CARTELLA $nome NON ESISTE. Le prove non stanno girando dalla '
        'radice del progetto, e ogni guardia che scorre i sorgenti sta '
        'per dire il vero su niente.',
      );
    }
    file.addAll(
      cartella
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart')),
    );
  }
  cardinaleMinimo(
    file.length,
    minimo,
    cosa: 'file Dart dentro ${cartelle.join(", ")}',
    perche: 'Questa guardia guarda piu\' di una cartella: se '
        'l\'elenco si svuota diventa verde senza aver letto una riga.',
  );
  return file;
}

/// **UN INSIEME DI FILE SCOPERTO SUL DISCO, COL SUO MINIMO DICHIARATO.**
/// Ordine CM voce 02.
///
/// **Perche' non bastavano le due porte di sopra.** Quelle conoscono i
/// sorgenti Dart. Ma diciannove guardie scoprono altro: le anteprime,
/// il corredo, gli asset di marca, i flussi di lavoro, le pietre
/// scontornate. **La cecita' non e' una proprieta' della cartella `lib`,
/// e' una proprieta' del gesto**: chiunque chieda al disco cosa c'e'
/// dentro una cartella puo' ricevere una risposta vuota e dirsi verde.
///
/// Anzi, queste sono le piu' esposte: gli asset e le anteprime cambiano
/// molto piu' spesso dei sorgenti, e si rigenerano con strumenti che
/// possono fallire lasciando la cartella a meta'.
///
/// Il minimo lo dichiara chi chiama, perche' solo chi chiama sa quante
/// cose si aspetta. **La cartella che non esiste non e' un insieme
/// vuoto**: e' una prova lanciata dal posto sbagliato, e si dice con
/// parole diverse.
List<File> fileScoperti(
  String cartella, {
  required int minimo,
  bool ricorsiva = true,
  String? estensione,
  String? perche,
}) {
  final radice = Directory(cartella);
  if (!radice.existsSync()) {
    throw InsiemeSvuotato(
      'LA CARTELLA $cartella NON ESISTE. Non e\' un insieme vuoto: e\' una '
      'prova lanciata da un posto che non e\' la radice del progetto, '
      'oppure una cartella che qualcuno ha spostato senza portarsi dietro '
      'la guardia.',
    );
  }
  final file = radice
      .listSync(recursive: ricorsiva)
      .whereType<File>()
      .where((f) => estensione == null || f.path.endsWith(estensione))
      .toList(growable: false);
  cardinaleMinimo(
    file.length,
    minimo,
    cosa: 'file dentro $cartella'
        '${estensione == null ? "" : " che finiscono per $estensione"}',
    perche: perche,
  );
  return file;
}

/// **QUANTI SORGENTI HA `lib/features`.** 182 contati il 1 settembre
/// 2026, meno un margine dichiarato di 42.
///
/// Sette guardie scoprono questa cartella, e il numero sta qui e non
/// dentro le sette: una soglia ripetuta sette volte e' una soglia che
/// sei volte su sette nessuno aggiorna.
const int quantiFileHannoLeFunzioni = 140;

/// **QUANTI SORGENTI HA `test`.** Contati il 1 settembre 2026, meno un
/// margine dichiarato.
///
/// Serve alle poche guardie che leggono le altre guardie: se l'elenco delle
/// prove si svuotasse, quelle direbbero il vero su nessuno.
const int quanteProveCiSono = 600;

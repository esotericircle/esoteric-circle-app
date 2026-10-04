import 'dart:async';
import 'dart:io';

import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Setup globale della suite: carica una sola volta, prima di tutti i test, i
/// font reali del progetto dichiarati nel pubspec (Cinzel per i titoli,
/// EBGaramond per il corpo). Flutter registra i font a livello di processo,
/// quindi da qui valgono per ogni test.
///
/// Senza questo, i test headless renderebbero il testo con il font di ripiego,
/// le cui metriche differiscono da quelle del device: un layout stretto
/// potrebbe sembrare sano nei test e sforare sul telefono, o il contrario. Con
/// i font veri caricati, ogni test di layout misura le stesse metriche del
/// device.
///
/// **Le icone Material si caricano anche loro, e da qui.** Qui c'era scritto
/// che erano gia' disponibili dal pacchetto Flutter, e non e' vero: una
/// cattura fatta senza caricarle mostra quadrati vuoti al posto della freccia
/// indietro e delle scintille. Il corredo se le caricava per conto suo, dentro
/// una funzione privata, e ogni altro file di cattura restava senza. Una porta
/// sola, qui, e valgono per tutti.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> loadFont(String family, String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      // Fallimento forte e chiaro: se il path si rompe in futuro, la suite non
      // deve tornare in silenzio al font di ripiego con metriche diverse dal
      // device. Meglio spezzare subito, con un messaggio che dice quale font e
      // quale path, cosi' l'errore si diagnostica a colpo d'occhio.
      throw StateError(
        'Setup font della suite: font "$family" non trovato al path atteso '
        '"$path" (assoluto: "${file.absolute.path}"). Verifica che l\'asset '
        'esista e che il path corrisponda a quello dichiarato nel pubspec. '
        'Senza questo font i test di layout misurerebbero il ripiego, non il '
        'device.',
      );
    }
    final loader = FontLoader(family);
    final bytes = file.readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }

  await loadFont('Cinzel', 'assets/fonts/Cinzel-variable.ttf');
  await loadFont('EBGaramond', 'assets/fonts/EBGaramond-variable.ttf');

  // Le icone Material stanno nella cache dell'SDK, non nel repo: si risale
  // dall'eseguibile, che puo' essere `dart` oppure `flutter_tester`, e si
  // provano entrambe le forme. Un percorso esplicito via ambiente vince.
  const relIcone = 'artifacts/material_fonts/MaterialIcons-Regular.otf';
  final ambiente = Platform.environment;
  final candidati = <String>[
    if (ambiente['MATERIAL_ICONS_FONT'] != null)
      ambiente['MATERIAL_ICONS_FONT']!,
    if (ambiente['FLUTTER_ROOT'] != null)
      '${ambiente['FLUTTER_ROOT']}/bin/cache/$relIcone',
  ];
  var cartella = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 8; i++) {
    candidati.add('${cartella.path}/$relIcone');
    candidati.add('${cartella.path}/bin/cache/$relIcone');
    cartella = cartella.parent;
  }
  String? trovato;
  for (final c in candidati) {
    if (File(c).existsSync()) {
      trovato = c;
      break;
    }
  }
  if (trovato == null) {
    // Niente ripiego muto: senza questo font ogni icona diventa un quadrato,
    // e un'anteprima con i quadrati sembra un difetto dell'app.
    throw StateError(
      'Setup font della suite: MaterialIcons-Regular.otf non trovato in '
      'nessuno dei percorsi provati. Indica il file con la variabile '
      'MATERIAL_ICONS_FONT. Senza, le icone si disegnano come quadrati vuoti.',
    );
  }
  await loadFont('MaterialIcons', trovato);

  // **IL SEGUITO PREPARATO IN SOTTOFONDO, SPENTO NELLA SUITE.** Ordine EX
  // Aggiunta 4, voce EX.04: dopo una risposta senza seguito l'app chiede il
  // seguito in sottofondo, e le prove che contano le chiamate della risposta
  // (le reti, le correzioni, la strada del tocco) ne vedrebbero una in piu'
  // che non e' loro. La preparazione la sorveglia, riaccesa,
  // `il_seguito_e_gia_pronto_test.dart`.
  MaestroChatController.preparaIlSeguitoDiSerie = false;
  // LAPIDE, ordine FC voce 03: qui la suite spegneva il gesto fuori dal
  // giorno (`InterrogaIlCielo.ancheFuoriDalGiorno`), e le prove dei periodi
  // leggevano la lettura senza toccare. L'interruttore non esiste piu': il
  // responso non compare mai da solo, nemmeno in prova.
  await testMain();
}

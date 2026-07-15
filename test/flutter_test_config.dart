import 'dart:async';
import 'dart:io';

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
/// device. Le icone Material sono gia' disponibili nei test dal pacchetto
/// Flutter, quindi non serve caricarle qui.
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

  await testMain();
}

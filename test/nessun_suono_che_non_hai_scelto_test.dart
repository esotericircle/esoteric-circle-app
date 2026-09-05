import 'dart:io';

import 'package:esoteric_circle/core/sensi/catalogo_suoni.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **NESSUN SUONO CHE IL FONDATORE NON ABBIA SCELTO.**
/// Ordine CQ voce 1.08, 3 settembre 2026.
///
/// **Il fatto, parole del fondatore:** *"togli ogni effetto sonoro che non ho
/// scelto io."*
///
/// **La causa, misurata e non dedotta.** Ogni comando Material chiama
/// `Feedback.forTap` quando lo si preme, e su Android quel richiamo fa suonare
/// al SISTEMA il suo click e vibrare il telefono. **In tutta l'app non c'era
/// un solo `enableFeedback` scritto**, quindi valeva ovunque il vero di
/// fabbrica: trentatre `InkWell` scritti a mano e tutti i pulsanti del tema.
///
/// **Perche' nessuna guardia lo aveva mai visto.** Il catalogo dei suoni e' un
/// dato, e c'e' una guardia che vieta di suonare un file che non sia li'
/// dentro. Ma il click di sistema **non e' un file negli asset**: nasce dalla
/// piattaforma, non passa dalla porta unica dei suoni, non conosce
/// l'interruttore del silenzio del Cerchio. Sorvegliare il catalogo non
/// sorveglia i suoni che non passano dal catalogo, ed e' una cecita' per
/// costruzione, non per distrazione.
///
/// **PROVENIENZA IGNOTA.** E' il comportamento di fabbrica di Flutter: non
/// c'e' una voce che lo abbia introdotto, c'e' un ordine che non lo ha mai
/// spento.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('il tema spegne il ritorno di sistema su tutte le famiglie di comandi',
      () {
    final tema = AppTheme.dark();
    final spenti = <String, bool?>{
      'FilledButton': tema.filledButtonTheme.style?.enableFeedback,
      'ElevatedButton': tema.elevatedButtonTheme.style?.enableFeedback,
      'TextButton': tema.textButtonTheme.style?.enableFeedback,
      'OutlinedButton': tema.outlinedButtonTheme.style?.enableFeedback,
      'IconButton': tema.iconButtonTheme.style?.enableFeedback,
      'SegmentedButton': tema.segmentedButtonTheme.style?.enableFeedback,
      'MenuButton': tema.menuButtonTheme.style?.enableFeedback,
      'ListTile': tema.listTileTheme.enableFeedback,
    };
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.08: il ritorno di sistema per famiglia $spenti');
    cardinaleMinimo(spenti.length, 8,
        cosa: 'famiglie di comandi guardate nel tema',
        perche: 'Se l elenco si accorciasse, la prova direbbe che tutto e '
            'spento avendo guardato meno cose.');
    final accese = spenti.entries.where((e) => e.value != false).toList();
    expect(accese, isEmpty,
        reason: 'queste famiglie fanno ancora suonare il click di sistema a '
            'ogni tocco: ${accese.map((e) => e.key).join(", ")}');
  });

  test('ogni InkWell scritto a mano porta il suo interruttore', () {
    // **IL TEMA NON ARRIVA AGLI INKWELL.** `InkWell` non legge nessun tema per
    // il ritorno di sistema: chi ne scrive uno se lo porta dietro acceso. Si
    // contano tutti, e ognuno deve spegnerlo.
    final scoperti = <String>[];
    var trovati = 0;
    for (final file in sorgentiDiLib()) {
      final testo = file.readAsStringSync();
      for (final apertura in RegExp(r'Ink(?:Well|Response)\(')
          .allMatches(testo)) {
        trovati++;
        final coda = testo.substring(
            apertura.end, (apertura.end + 400).clamp(0, testo.length));
        if (!coda.contains('enableFeedback: false')) {
          scoperti.add('${file.path} al carattere ${apertura.start}');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.08: InkWell trovati $trovati, senza interruttore '
        '${scoperti.length}');
    cardinaleMinimo(trovati, 20,
        cosa: 'InkWell e InkResponse scritti a mano in lib',
        perche: 'Se sparissero dal codice questa prova sarebbe verde senza '
            'aver guardato niente, e il giorno che tornassero nessuno se ne '
            'accorgerebbe.');
    expect(scoperti, isEmpty,
        reason: 'questi InkWell fanno ancora suonare il click di sistema: '
            '${scoperti.take(5).join(" | ")}');
  });

  test('nessuna schermata chiama la piattaforma per suonare o vibrare', () {
    // **LA PORTA E' UNA SOLA.** L'aptica vive dentro `PaletteSensoriale` e i
    // suoni dentro il catalogo: una schermata che chiami `HapticFeedback` o
    // `SystemSound` per conto suo apre una seconda porta, che non conosce
    // l'interruttore del silenzio.
    final fuori = <String>[];
    var guardate = 0;
    for (final file in sorgentiDiLib()) {
      final percorso = file.path.replaceAll(String.fromCharCode(92), '/');
      if (percorso.contains('lib/core/sensi/')) continue;
      guardate++;
      final testo = file.readAsStringSync();
      for (final vietato in const [
        'HapticFeedback.',
        'SystemSound.',
        'Feedback.forTap',
        'Feedback.forLongPress',
      ]) {
        if (testo.contains(vietato)) fuori.add('${file.path}: $vietato');
      }
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.08: sorgenti guardate fuori dai sensi $guardate, '
        'porte di lato ${fuori.length}');
    cardinaleMinimo(guardate, 100,
        cosa: 'sorgenti di lib fuori dalla cartella dei sensi',
        perche: 'Con un insieme vuoto la prova non guarderebbe niente.');
    expect(fuori, isEmpty,
        reason: 'queste sorgenti chiamano la piattaforma per conto loro: '
            '${fuori.join(" | ")}');
  });

  test('i suoni del Cerchio sono quelli del catalogo, e i file esistono', () {
    // **NESSUN SUONO NASCE FUORI DAL CATALOGO**, ed e' la legge che c'era
    // gia'. Qui si aggiunge il verso opposto: **nessun file negli asset senza
    // una voce che lo chiami**, cosi' il fondatore puo' leggere l'elenco vero
    // di cio' che l'app puo' emettere e dire quali toglierebbe.
    final cartella = Directory('assets/audio');
    final file = cartella
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .where((n) => n.endsWith('.mp3'))
        .toSet();
    final dichiarati = SuonoDelCerchio.values.map((s) => s.file).toSet();
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.08: file negli asset ${file.length} '
        '${file.toList()..sort()}');
    cardinaleMinimo(dichiarati.length, 5,
        cosa: 'voci del catalogo dei suoni',
        perche: 'Con un catalogo vuoto i due insiemi sarebbero uguali per '
            'vuoto, e la prova sarebbe verde.');
    expect(file.difference(dichiarati), isEmpty,
        reason: 'ci sono file audio che nessuna voce del catalogo chiama: '
            'peso nell archivio e niente a schermo');
    expect(dichiarati.difference(file), isEmpty,
        reason: 'il catalogo dichiara voci che non hanno un file: quel '
            'momento resta muto e nessuno lo sa');
  });
}

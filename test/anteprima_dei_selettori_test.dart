// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/l10n/la_lingua_del_cerchio.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LE FOTOGRAFIE DEI SELETTORI, PRIMA E DOPO.** Ordine DM voce 02.
///
/// L'ordine chiede le fotografie, non la parola di chi lavora. Qui si dipinge
/// il selettore vero due volte, senza i delegati e con i delegati. Si scrive
/// solo con `ANTEPRIMA_SELETTORI=1`, perche' la suite non deve toccare i file
/// del repository.
///
/// **IL SELETTORE SI DIPINGE COME WIDGET, NON SI APRE COME ROTTA, e la
/// ragione e' misurata.** Aprendolo con `showDatePicker` la prova scriveva
/// l'immagine e poi **non finiva piu'**: il banco stampava *"did not
/// complete"* su tutte e cinque le prove dopo aver scritto la prima. La rotta
/// del dialogo tiene un tempo pendente che il banco aspetta, e chiuderla a
/// mano non bastava. `DatePickerDialog` e `TimePickerDialog` sono gli stessi
/// widget che quella rotta monta: dipingerli direttamente fotografa la stessa
/// cosa senza aprire niente.
///
/// **Il rapporto e' tre**, come per ogni altra anteprima del progetto: la
/// regola sta in `test/corredo_anteprime_test.dart` riga 28, e l'ordine
/// CODEMAGIC1 voce 01 racconta che cosa costa dimenticarsene.
void main() {
  Future<void> scatta(
    WidgetTester tester,
    String nome, {
    required bool coiDelegati,
    required LinguaDelCerchio lingua,
    required bool ora,
  }) async {
    final chiave = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        // **IL TEMA VERO DELL'APP, e non quello di prova.** Guardata la prima
        // fotografia: le lettere erano quadratini neri, perche' il banco
        // senza tema usa il carattere di ripiego che disegna scatole. Con il
        // tema dell'app il selettore si vede come lo vede una persona, ed e'
        // il senso di una fotografia.
        theme: AppTheme.dark(),
        locale: coiDelegati ? Locale(lingua.codice) : null,
        supportedLocales: coiDelegati
            ? [for (final l in LinguaDelCerchio.values) Locale(l.codice)]
            : const [Locale('en')],
        localizationsDelegates: coiDelegati
            ? const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ]
            : null,
        // **IL CONFINE STA DENTRO, non attorno all'app.** Con il confine
        // alla radice la prova scriveva l'immagine e poi non finiva piu'.
        home: RepaintBoundary(
          key: chiave,
          child: Scaffold(
            backgroundColor: const Color(0xFF0A0A14),
            body: Center(
              child: ora
                  ? const TimePickerDialog(
                      initialTime: TimeOfDay(hour: 21, minute: 30))
                  : DatePickerDialog(
                      initialDate: DateTime(1990, 3, 15),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2030),
                    ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final confine =
        chiave.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final immagine = await confine.toImage(pixelRatio: 3);
    // **LA CODIFICA PNG GIRA SUL TEMPO VERO, e questa riga costa tre ore.**
    // Misurato il 16 settembre 2026 togliendo un pezzo per volta: senza la
    // codifica le cinque prove finiscono in due secondi, con la codifica la
    // prima immagine esce e poi il banco non finisce piu'. Dentro un widget
    // test l'orologio e' finto, e la codifica di un'immagine da tre milioni
    // di punti aspetta un tempo che non passa mai. `runAsync` la fa girare
    // sull'orologio vero. L'anteprima della card della rivelazione non ne ha
    // bisogno perche' la sua immagine e' meno di un terzo di questa.
    ui.Image? tenuta = immagine;
    final byte = await tester
        .runAsync(() => tenuta!.toByteData(format: ui.ImageByteFormat.png));
    tenuta = null;
    final cartella = Directory('docs/collaudo/DM')..createSync(recursive: true);
    final file = File('${cartella.path}/$nome.png')
      ..writeAsBytesSync(byte!.buffer.asUint8List());
    print('SCRITTA ${file.path}, ${file.lengthSync()} byte, '
        '${immagine.width}x${immagine.height}');
    // **L'IMMAGINE SI LIBERA.** Un'immagine di tre milioni di punti lasciata
    // viva tiene occupato il motore, e la prova non finisce.
    immagine.dispose();

    // **E IL SELETTORE SI SMONTA.** Misurato: lasciato montato, la prova
    // scriveva l'immagine e poi **non finiva piu'**, e il banco stampava
    // *"did not complete"*. Dentro il selettore vive un tempo periodico, il
    // lampeggio del cursore del campo di testo, e finche' quel tempo esiste
    // il banco aspetta. Smontare l'albero lo cancella. La fotografia e' gia'
    // stata scattata: qui non si perde niente.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }

  const scatti = [
    ('01_data_prima_inglese', false, LinguaDelCerchio.italiano, false),
    ('02_data_dopo_italiano', true, LinguaDelCerchio.italiano, false),
    ('03_ora_prima_inglese', false, LinguaDelCerchio.italiano, true),
    ('04_ora_dopo_italiano', true, LinguaDelCerchio.italiano, true),
    ('05_data_in_inglese_scelto', true, LinguaDelCerchio.inglese, false),
  ];

  for (final (nome, delegati, lingua, ora) in scatti) {
    testWidgets(nome, (tester) async {
      if (Platform.environment['ANTEPRIMA_SELETTORI'] != '1') {
        markTestSkipped('senza ANTEPRIMA_SELETTORI non si scrive niente');
        return;
      }
      // La finestra e' quella di un telefono vero, in punti logici; il
      // rapporto tre lo mette lo scatto.
      tester.view.physicalSize = const Size(1260, 2580);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      await scatta(tester, nome,
          coiDelegati: delegati, lingua: lingua, ora: ora);
    });
  }
}

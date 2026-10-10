import 'dart:io';

import 'package:esoteric_circle/core/l10n/la_lingua_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// I SELETTORI DI SISTEMA PARLANO LA LINGUA GIUSTA. Ordine DM voce 02.
///
/// **Il difetto, e c'era in italiano.** Senza i delegati di localizzazione i
/// widget che Flutter disegna da se' parlano inglese. Nell'app succede in tre
/// punti, contati su tutto `lib` e non a memoria: `showDatePicker` nei dati di
/// nascita e nei pezzi del Sigillo, `showTimePicker` nelle notifiche. Chi
/// sceglieva la propria data di nascita leggeva CANCEL e OK.
///
/// **Come si misura, e perche' non basta cercare i delegati nel sorgente.**
/// Una prova che cercasse `localizationsDelegates` in `app.dart` sarebbe verde
/// anche se i delegati fossero montati male, o se la lingua dichiarata non
/// arrivasse fino al selettore. Qui si **monta il selettore vero** e si legge
/// il testo che stampa: e' la differenza fra guardare il codice e guardare lo
/// schermo.
///
/// **E la prima parte, quella senza delegati, e' la fotografia del PRIMA**: e'
/// scritta apposta per far vedere che cosa leggeva una persona, e sarebbe
/// rossa il giorno in cui qualcuno credesse che l'inglese arrivava da
/// un'altra causa.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Monta un selettore di data dentro un'app fatta come quella vera, e rende
  /// i testi che compaiono a schermo.
  Future<Set<String>> testiDelSelettore(
    WidgetTester tester, {
    required bool coiDelegati,
    required LinguaDelCerchio lingua,
    bool ora = false,
  }) async {
    await tester.pumpWidget(MaterialApp(
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
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () {
            if (ora) {
              showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 9, minute: 0));
            } else {
              showDatePicker(
                context: context,
                initialDate: DateTime(1990, 3, 15),
                firstDate: DateTime(1900),
                lastDate: DateTime(2030),
              );
            }
          },
          child: const Text('apri'),
        ),
      ),
    ));
    await tester.tap(find.text('apri'));
    await tester.pumpAndSettle();
    final testi = <String>{};
    for (final t in tester.widgetList<Text>(find.byType(Text))) {
      final s = t.data ?? t.textSpan?.toPlainText();
      if (s != null && s.trim().isNotEmpty) testi.add(s.trim());
    }
    return testi;
  }

  testWidgets('IL PRIMA: senza delegati il selettore di data parla inglese',
      (tester) async {
    final testi = await testiDelSelettore(tester,
        coiDelegati: false, lingua: LinguaDelCerchio.italiano);
    // ignore: avoid_print
    print('DM.02 PRIMA, data: ${testi.take(12).toList()}');
    expect(testi, contains('Cancel'),
        reason: 'senza delegati il selettore non dice Cancel: allora '
            'l inglese che il fondatore ha visto veniva da un altra causa, e '
            'questa voce sta curando la cosa sbagliata');
    expect(testi.any((t) => t.toUpperCase() == 'OK'), isTrue);
    expect(testi, isNot(contains('Annulla')));
  });

  testWidgets('IL DOPO: coi delegati il selettore di data parla italiano',
      (tester) async {
    final testi = await testiDelSelettore(tester,
        coiDelegati: true, lingua: LinguaDelCerchio.italiano);
    // ignore: avoid_print
    print('DM.02 DOPO, data: ${testi.take(12).toList()}');
    expect(testi, contains('Annulla'),
        reason: 'coi delegati il selettore di data parla ancora inglese');
    expect(testi, isNot(contains('Cancel')));
  });

  testWidgets('IL DOPO: anche il selettore dell\'ora', (tester) async {
    final testi = await testiDelSelettore(tester,
        coiDelegati: true, lingua: LinguaDelCerchio.italiano, ora: true);
    // ignore: avoid_print
    print('DM.02 DOPO, ora: ${testi.take(12).toList()}');
    expect(testi, contains('Annulla'),
        reason: 'il selettore dell ora parla ancora inglese');
    expect(testi, isNot(contains('Cancel')));
  });

  testWidgets('E IN INGLESE PARLA INGLESE, che e\' il punto della voce',
      (tester) async {
    final testi = await testiDelSelettore(tester,
        coiDelegati: true, lingua: LinguaDelCerchio.inglese);
    // ignore: avoid_print
    print('DM.02 in inglese: ${testi.take(12).toList()}');
    expect(testi, contains('Cancel'));
    expect(testi, isNot(contains('Annulla')));
  });

  test('E L\'APP MONTA DAVVERO I DELEGATI, tutti e tre', () {
    // **La prova sopra monta un\'app costruita qui**, quindi direbbe il vero
    // anche se `app.dart` non montasse niente: questa riga chiude quel buco
    // guardando il file che l\'app usa davvero.
    final app = File('lib/app.dart').readAsStringSync();
    for (final d in const [
      'GlobalMaterialLocalizations.delegate',
      'GlobalWidgetsLocalizations.delegate',
      'GlobalCupertinoLocalizations.delegate',
    ]) {
      expect(app, contains(d), reason: 'app.dart non monta $d');
    }
    expect(app, contains('supportedLocales'));
    // E la lingua dichiarata, non quella del telefono.
    expect(app, contains('locale: Locale(lingua.codice)'),
        reason: 'app.dart lascia scegliere la lingua al telefono: chi ha '
            'sempre letto in italiano vedrebbe i selettori in inglese');
  });
}

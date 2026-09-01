import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/onboarding/anteprima_tono.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// La schermata del tono deve far SENTIRE la differenza.
///
/// Prima non mostrava nulla: si sceglieva "Lui", "Lei" o "Neutro" al buio,
/// cioe' si sceglieva un'etichetta grammaticale senza sapere che effetto
/// avrebbe avuto sulle frasi da li' in poi.
void main() {
  test('Ogni tono produce una frase diversa dalle altre', () {
    final frasi = <CourtesyForm, String>{
      for (final f in CourtesyForm.values) f: AnteprimaTono.frasePer(f),
    };
    // Tutte diverse fra loro: se due coincidessero, scegliere non cambierebbe
    // niente e l'anteprima sarebbe una bugia gentile.
    expect(frasi.values.toSet().length, frasi.length,
        reason: 'due toni dicono la stessa identica frase: $frasi');
    for (final f in frasi.values) {
      expect(f.trim(), isNotEmpty);
    }
  });

  test('Il maschile e il femminile si distinguono davvero', () {
    expect(
        AnteprimaTono.frasePer(CourtesyForm.masculine), contains('Bentornato'));
    expect(
        AnteprimaTono.frasePer(CourtesyForm.feminine), contains('Bentornata'));
    // Il neutro non usa nessuna delle due forme secche.
    final neutro = AnteprimaTono.frasePer(CourtesyForm.neutral);
    expect(neutro.contains('Bentornato.'), isFalse);
    expect(neutro.contains('Bentornata.'), isFalse);
  });

  test('Nessuna frase promette un esito', () {
    // Curatela redazionale, non tradizione: niente salute, denaro o eventi
    // garantiti. E' una regola della casa, non un gusto.
    const vietate = [
      'guarir',
      'guadagn',
      'ricchezz',
      'malatt',
      'garanti',
      'sicuramente',
      'vincer',
      'successo assicurato',
      'ti sposerai',
      'soldi',
    ];
    for (final f in CourtesyForm.values) {
      final frase = AnteprimaTono.frasePer(f).toLowerCase();
      for (final v in vietate) {
        expect(frase.contains(v), isFalse,
            reason: 'la frase del tono $f promette qualcosa: "$frase"');
      }
    }
  });

  testWidgets('La frase si scrive, non compare tutta insieme', (tester) async {
    Widget host(CourtesyForm? t) => MaterialApp(
          home: Scaffold(
            body: AnteprimaTono(tono: t, palette: MaestroPalette.neutral),
          ),
        );

    await tester.pumpWidget(host(CourtesyForm.feminine));
    await tester.pump(const Duration(milliseconds: 50));

    int scritte() =>
        (tester.state(find.byType(AnteprimaTono)) as dynamic).scritte as int;

    final piena = AnteprimaTono.frasePer(CourtesyForm.feminine).length;
    final subito = scritte();
    expect(subito, lessThan(piena),
        reason: 'la frase e\' comparsa tutta insieme, senza scriversi');

    await tester.pump(const Duration(milliseconds: 500));
    final aMeta = scritte();
    expect(aMeta, greaterThan(subito), reason: 'la penna non avanza');
    expect(aMeta, lessThan(piena));

    await tester.pump(AnteprimaTono.scrittura);
    expect(scritte(), piena, reason: 'la frase non si e\' mai completata');
  });

  testWidgets('Cambiando scelta la frase si riscrive da capo', (tester) async {
    Widget host(CourtesyForm t) => MaterialApp(
          home: Scaffold(
            body: AnteprimaTono(tono: t, palette: MaestroPalette.neutral),
          ),
        );

    await tester.pumpWidget(host(CourtesyForm.masculine));
    await tester.pump(AnteprimaTono.scrittura + const Duration(seconds: 1));
    int scritte() =>
        (tester.state(find.byType(AnteprimaTono)) as dynamic).scritte as int;
    expect(scritte(), AnteprimaTono.frasePer(CourtesyForm.masculine).length);

    await tester.pumpWidget(host(CourtesyForm.neutral));
    await tester.pump(const Duration(milliseconds: 50));
    expect(scritte(),
        lessThan(AnteprimaTono.frasePer(CourtesyForm.neutral).length),
        reason: 'cambiando tono la frase non si e\' riscritta');
  });

  testWidgets('Senza scelta si invita, senza fingere una frase',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: AnteprimaTono(tono: null, palette: MaestroPalette.neutral),
      ),
    ));
    expect(find.byKey(const Key('anteprima_tono_invito')), findsOneWidget);
    expect(find.byKey(const Key('anteprima_tono')), findsNothing);
  });
}

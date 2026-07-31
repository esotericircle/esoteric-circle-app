import 'dart:io';

import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/features/account/dati_di_nascita_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// "I TUOI DATI DI NASCITA" SI APRE DA OGNI PORTA, E MOSTRA I SUOI CAMPI.
///
/// **Il fatto.** Dall'Area utente la schermata si apre e funziona. Da un'altra
/// strada si apriva COMPLETAMENTE BIANCA, senza contenuto ne barra ne modo di
/// tornare indietro. Due porte verso la stessa schermata, e una rotta.
///
/// **Perche' accadeva.** Le rotte si montano alla RADICE del Navigator, quindi
/// non ereditano gli scope montati sotto: la schermata leggeva la palette del
/// Maestro da un `MaestroScope` che dalla sua rotta non c'era. Chi la apriva da
/// un punto gia' dentro uno scope non se ne accorgeva.
///
/// **Questa prova non guarda la porta rotta: monta la schermata NUDA**, cioe'
/// col minimo indispensabile, che e' la condizione peggiore in cui qualcuno
/// possa aprirla. Se regge cosi', regge da ogni porta.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> posa(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('Aperta dalla sua rotta, senza scope attorno, ha i suoi campi',
      (tester) async {
    // Nessun MaestroScope attorno: e' esattamente cio' che succede a una rotta
    // spinta dalla radice del Navigator.
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (ctx) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () =>
                    Navigator.of(ctx).push(DatiDiNascitaScreen.route()),
                child: const Text('apri'),
              ),
            ),
          ),
        ),
      ),
    ));
    await posa(tester);
    await tester.tap(find.text('apri'));
    await posa(tester);
    await posa(tester);

    expect(find.byKey(const Key('nascita_data')), findsOneWidget,
        reason: 'la schermata si apre vuota: manca il campo del giorno');
    expect(find.byKey(const Key('nascita_ora')), findsOneWidget,
        reason: 'la schermata si apre vuota: manca il campo dell ora');
    expect(find.byKey(const Key('nascita_luogo_field')), findsOneWidget,
        reason: 'la schermata si apre vuota: manca il campo del luogo, che e '
            'l unica strada per accendere la carta natale');
    expect(find.byKey(const Key('nascita_salva')), findsOneWidget,
        reason: 'la schermata si apre senza il pulsante Salva');
  });

  test('La rotta e dichiarata in un punto solo', () {
    // Due MaterialPageRoute scritti a mano in due file sono due schermate che
    // divergono al primo cambio, ed e' la forma che questo progetto ha gia'
    // incontrato dieci volte.
    var costruzioni = 0;
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      for (final r in f.readAsLinesSync()) {
        if (r.trimLeft().startsWith('//')) continue;
        // La dichiarazione del costruttore non e' una costruzione.
        if (r.contains('super.key')) continue;
        if (r.contains('DatiDiNascitaScreen(')) costruzioni++;
      }
    }
    // UNA sola, ed e' dentro la rotta stessa: e' li' che la schermata si
    // costruisce col proprio scope. Se ne compare una seconda, qualcuno la sta
    // montando a mano e quella copia nascera' senza scope, cioe' bianca.
    expect(costruzioni, 1,
        reason: 'la schermata dei dati di nascita si costruisce in '
            '$costruzioni punti: deve avere una rotta sola, e chi la vuole '
            'aprire passa di li');
  });
}

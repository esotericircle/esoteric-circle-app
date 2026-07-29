
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Il colore appartiene alla schermata, non alla strada che ci ha portato.
///
/// Il tema del Maestro veniva applicato dentro la tessera che apre l'arte:
/// quella tessera chiamava selectMaestro prima di navigare. Funzionava solo per
/// chi passava da li'. Chiunque arrivasse alla stessa arte da un'altra strada,
/// dallo scaffale del suo Maestro, da una rotta diretta, dalla chat, entrava
/// col colore di prima, e al primo ingresso nell'app spesso col neutro.
///
/// La correzione mette il proprietario NELLA schermata: il MaestroScope di
/// un'arte dichiara di chi e' quell'arte, quindi il colore c'e' dal primo
/// frame, da qualunque strada si arrivi.
void main() {
  /// Il colore primario visto da dentro la schermata.
  ///
  /// Si confronta il colore e non l'oggetto palette: MaestroPalette non
  /// implementa l'uguaglianza per valore, quindi confrontare gli oggetti
  /// sarebbe sempre falso, e un rosso del genere non misurerebbe il difetto,
  /// misurerebbe l'assenza di un operatore.
  Color dentro(WidgetTester tester, Key chiave) =>
      MaestroScope.of(tester.element(find.byKey(chiave))).primary;

  Future<void> apri(
    WidgetTester tester, {
    required Maestro temaGlobale,
    required Maestro? proprietario,
  }) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MaestroController(initial: ThemeKey.of(temaGlobale)),
        ),
      ],
      child: MaterialApp(
        home: MaestroScope(
          maestro: proprietario,
          child: const Scaffold(
            body: SizedBox(key: Key('dentro'), width: 10, height: 10),
          ),
        ),
      ),
    ));
    await tester.pump();
  }

  testWidgets('Un\'arte di Caligo si apre nel rosso anche col tema su Medora',
      (tester) async {
    await apri(tester, temaGlobale: Maestro.medora, proprietario: Maestro.caligo);

    expect(dentro(tester, const Key('dentro')),
        MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo)).primary,
        reason: 'l\'arte di Caligo si e\' aperta col colore di Medora, cioe\' '
            'col colore di chi la stava guardando prima');
  });

  testWidgets('Un\'arte di Aura si apre nel verde partendo dal neutro',
      (tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MaestroController())],
      child: const MaterialApp(
        home: MaestroScope(
          maestro: Maestro.aura,
          child: Scaffold(
            body: SizedBox(key: Key('dentro'), width: 10, height: 10),
          ),
        ),
      ),
    ));
    await tester.pump();

    expect(dentro(tester, const Key('dentro')),
        MaestroPalette.forKey(const ThemeKey.of(Maestro.aura)).primary,
        reason: 'al primo ingresso, col tema ancora neutro, l\'arte di Aura '
            'non prende il proprio colore');
  });

  testWidgets('Senza proprietario dichiarato si segue il tema globale',
      (tester) async {
    // Le schermate condivise, come il Santuario, non appartengono a nessuno:
    // continuano a seguire il Maestro attivo, come prima.
    await apri(tester, temaGlobale: Maestro.caligo, proprietario: null);

    expect(dentro(tester, const Key('dentro')),
        MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo)).primary);
  });

  testWidgets('Il proprietario non si lascia cambiare dal tema globale',
      (tester) async {
    // Costruito fuori dal provider: con un proprietario dichiarato lo scope non
    // legge piu' il controller, quindi un provider pigro non verrebbe mai
    // creato e il riferimento resterebbe vuoto.
    final controller =
        MaestroController(initial: const ThemeKey.of(Maestro.medora));
    addTearDown(controller.dispose);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<MaestroController>.value(value: controller),
      ],
      child: const MaterialApp(
        home: MaestroScope(
          maestro: Maestro.caligo,
          child: Scaffold(
            body: SizedBox(key: Key('dentro'), width: 10, height: 10),
          ),
        ),
      ),
    ));
    await tester.pump();

    // Qualcosa cambia il tema globale mentre l'arte di Caligo e' aperta: il
    // rosso dell'arte non deve virare sotto i piedi di chi la sta usando.
    controller.selectMaestro(Maestro.aura);
    await tester.pump(const Duration(seconds: 1));

    expect(dentro(tester, const Key('dentro')),
        MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo)).primary,
        reason: 'il colore dell\'arte e\' cambiato per un cambio di tema '
            'avvenuto fuori dall\'arte');
  });
}

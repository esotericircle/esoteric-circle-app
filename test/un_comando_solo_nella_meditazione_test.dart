import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/meditation_audio.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/meditation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **UN COMANDO SOLO NELLA MEDITAZIONE.** Ordine DD voce 17, 10 settembre
/// 2026, e sono tre decisioni del fondatore in una frase sola:
///
/// *"elimina la possibilita' di tenere il dito premuto, solo pulsante play e
/// stop (stesso pulsante). elimina 'preferisco scegliere io', e' ridondante
/// visto che dal pulsante puo' gia' scegliere sintomo e frequenza."*
///
/// **COSA C'ERA, e va scritto perche' non torni per sbaglio.** La schermata
/// aveva **quattro modi** di comandare la stessa cosa:
///
/// 1. il dito **tenuto premuto** sul fiore, che inspirava ed espirava;
/// 2. il **pulsante play**, che accendeva il suono;
/// 3. *"Preferisco scegliere io"*, che apriva le nove frequenze;
/// 4. *"Respiro da solo, senza tenere il dito"*, che spegneva il primo.
///
/// **Il quarto esisteva solo per riparare il primo.** Tolto il dito, e' rimasto
/// un interruttore che porta dove sei gia'.
///
/// **Adesso il comando e' uno**: si preme e parte, si preme e si ferma. Il
/// fiore fa la stessa cosa del pulsante, e non c'e' nessun gesto nascosto.
///
/// **REGOLA H, e sono due meta'.** Che i comandi vecchi siano spariti e' la
/// prima; che quello nuovo **funzioni** e' la seconda, e senza di lei una
/// schermata senza nessun comando passerebbe.
void main() {
  Future<void> apri(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: MaestroScope(
          maestro: Maestro.aura,
          child: MeditationScreen(
              player: const SilentTonePlayer(), now: DateTime(2026, 9, 9)),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('I TRE COMANDI DI TROPPO NON CI SONO PIU', (tester) async {
    await apri(tester);
    final rimasti = <String>[];
    // I due interruttori, cercati per chiave.
    for (final chiave in const [
      'meditation_scegli_tu',
      'meditazione_da_solo',
    ]) {
      if (find.byKey(Key(chiave)).evaluate().isNotEmpty) rimasti.add(chiave);
    }
    // E le loro parole, cercate a video: una chiave si puo' rinominare, le
    // parole no.
    for (final parola in const [
      'Preferisco scegliere io',
      'Respiro da solo, senza tenere il dito',
      'Torno a respirare col dito',
    ]) {
      if (find.text(parola).evaluate().isNotEmpty) rimasti.add('"$parola"');
    }
    // ignore: avoid_print
    print('ORDINE DD VOCE 17: comandi di troppo rimasti ${rimasti.length} '
        '$rimasti');
    expect(rimasti, isEmpty,
        reason: 'questi comandi dovevano sparire e sono ancora a schermo: '
            '${rimasti.join(", ")}');
  });

  testWidgets('IL FIORE NON CHIEDE PIU DI TENERE IL DITO', (tester) async {
    await apri(tester);
    final fiore = find.byKey(const Key('meditation_dito'));
    expect(fiore, findsOneWidget,
        reason: 'il fiore non e a schermo: questa prova non misura niente');
    final gesto = tester.widget<GestureDetector>(fiore);
    // ignore: avoid_print
    print('ORDINE DD VOCE 17: sul fiore onTap '
        '${gesto.onTap != null}, onTapDown ${gesto.onTapDown != null}, '
        'onTapUp ${gesto.onTapUp != null}, onLongPress '
        '${gesto.onLongPress != null}');
    expect(gesto.onTapDown, isNull,
        reason: 'il fiore ascolta ancora il dito che scende: la pressione '
            'prolungata e tornata');
    expect(gesto.onTapUp, isNull,
        reason: 'il fiore ascolta ancora il dito che si alza');
    expect(gesto.onLongPress, isNull,
        reason: 'il fiore ha una pressione lunga: e il gesto che il fondatore '
            'ha tolto');
    // **E il tocco semplice c'e'**, perche' un cerchio grande che ignora il
    // dito e' peggio del difetto da cui quest ordine e nato.
    expect(gesto.onTap, isNotNull,
        reason: 'il fiore non risponde a niente: chi lo tocca non ottiene '
            'nessuna risposta, ed e esattamente "faccio click e non succede '
            'nulla"');
  });

  testWidgets('REGOLA H: IL COMANDO SOLO ACCENDE E SPEGNE, ed e lo stesso',
      (tester) async {
    await apri(tester);
    final play = find.byKey(const Key('meditation_play'));
    final fiore = find.byKey(const Key('meditation_dito'));
    expect(play, findsOneWidget, reason: 'il pulsante play non c e');

    bool inCorso() =>
        find.text('Il respiro è compiuto').evaluate().isEmpty &&
        find.text('Premi play').evaluate().isEmpty;

    // ignore: avoid_print
    print('ORDINE DD VOCE 17: di partenza la sessione gira ${inCorso()}');
    expect(inCorso(), isFalse,
        reason: 'la sessione parte da sola, senza che nessuno abbia premuto');

    // Il pulsante accende.
    await tester.tap(play);
    await tester.pump(const Duration(milliseconds: 200));
    // ignore: avoid_print
    print('ORDINE DD VOCE 17: premuto play, la sessione gira ${inCorso()}');
    expect(inCorso(), isTrue,
        reason: 'premuto play la sessione non parte');

    // **Lo stesso pulsante spegne**, che e' cio' che l ordine chiede per nome.
    await tester.tap(play);
    await tester.pump(const Duration(milliseconds: 200));
    // ignore: avoid_print
    print('ORDINE DD VOCE 17: ripremuto play, la sessione gira ${inCorso()}');
    expect(inCorso(), isFalse,
        reason: 'lo stesso pulsante non ferma la sessione: servono due '
            'comandi diversi per accendere e spegnere');

    // E il fiore fa la stessa identica cosa.
    await tester.tap(fiore, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 200));
    // ignore: avoid_print
    print('ORDINE DD VOCE 17: toccato il fiore, la sessione gira ${inCorso()}');
    expect(inCorso(), isTrue,
        reason: 'toccato il fiore non succede niente: e il difetto da cui '
            'quest ordine e nato');
  });
}

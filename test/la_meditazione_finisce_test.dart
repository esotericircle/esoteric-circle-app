import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/gesti_delle_arti.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/meditation_screen.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/meditation_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'istante_dichiarato.dart';

/// LA MEDITAZIONE HA UNA FINE. Ordine BF voce 05.b, ordine P voce 35.
///
/// La schermata esisteva ma non arrivava a una chiusura: il respiro girava
/// in cerchio per sempre, nessun traguardo si accendeva, e i gradini
/// aur_50 e aur_51 dormivano proprio per questo buco. Adesso la sessione
/// dura dodici cicli di respiro: al compimento il tono si ferma, la scena
/// lo dice, e la regia registra il gesto `meditazione`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('i gradini della meditazione, e chi li tiene addormentati', () {
    // **LA REVISIONE E LI RIMETTE A DORMIRE, ed e' una decisione del corpus che
    // il codice ha gia' superato.** Ordine BS voce 01. I gradini della
    // meditazione nella revisione E sono aur_17 e aur_46, e il corpus li
    // dichiara dormienti tutti e due; la nota di aur_17 dice "la meditazione
    // oggi non ha una fine", **che dall'ordine BF voce 05.b non e' piu' vero**:
    // la sessione dura dodici cicli, si compie, e la regia registra il gesto,
    // come dimostrano le due prove qui sotto che non sono state toccate.
    //
    // **L'ordine BS dice che i dormienti dichiarati dal corpus restano
    // dormienti**, quindi qui non si sveglia niente di nascosto: si scrive che
    // la ragione e' scaduta, e la decisione di svegliarlo e' del fondatore,
    // perche' il corpus e' materia sua.
    final loto = Sentieri.di(Sentiero.loto);
    final dellaMeditazione = [
      for (final t in loto)
        if (t.frase.toLowerCase().contains('meditazione')) t,
    ];
    // ignore: avoid_print
    print('ORDINE BS VOCE 01: i gradini della meditazione sono '
        '${dellaMeditazione.map((t) => "${t.id} dormiente ${t.dormiente}").join(", ")}');
    expect(dellaMeditazione.map((t) => t.id), containsAll(['aur_17', 'aur_46']),
        reason: 'i gradini della meditazione non sono piu\' quelli: il corpus '
            'e\' cambiato ancora');
    expect(dellaMeditazione.every((t) => t.dormiente), isTrue,
        reason: 'un gradino della meditazione si e\' svegliato senza che il '
            'corpus lo dicesse');
    // **IL GESTO PERO' ESISTE E ARRIVA**, ed e' la promessa dell'ordine BF che
    // resta in piedi: il giorno che il corpus toglie la dormienza, quel
    // gradino matura senza toccare una riga di codice.
    expect(GestiDelleArti.di('meditazione'), isNotNull,
        reason: 'il gesto meditazione non e\' piu\' censito: allora la fine '
            'della sessione non arriva a nessuno');
  });

  testWidgets('la sessione si compie, lo dice, e il gesto arriva al diario',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    final player = _LettoreMuto();

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: MaestroScope(child: MeditationScreen(player: player)),
      ),
    ));
    await tester.pump();

    // Si parte: il tono suona e il compimento non c'e' ancora.
    await tester.tap(find.byKey(const Key('meditation_play')));
    await tester.pump();
    expect(player.inSuono, isTrue);
    expect(find.byKey(const Key('meditazione_compiuta')), findsNothing);
    expect(diario.haFatto('meditazione'), isFalse,
        reason: 'il gesto si registra al compimento, non all\'apertura');

    // A meta' sessione non e' compiuta: fermarsi qui non registra niente.
    await tester.pump(const Duration(seconds: 60));
    expect(find.byKey(const Key('meditazione_compiuta')), findsNothing);

    // Dodici cicli da undici secondi: al compimento il tono si ferma, la
    // scena lo dice, e il diario ha il gesto.
    await tester.pump(const Duration(seconds: 80));
    await tester.pump();
    expect(find.byKey(const Key('meditazione_compiuta')), findsOneWidget,
        reason: 'la sessione e\' finita in silenzio: la persona non sa di '
            'essere arrivata');
    expect(player.inSuono, isFalse,
        reason: 'il tono continua a suonare oltre il compimento');
    expect(diario.haFatto('meditazione'), isTrue,
        reason: 'il gesto meditazione non e\' arrivato al diario: aur_50 '
            'non potra\' mai maturare');
  });

  testWidgets('fermarsi a meta\' non e\' compiere', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    final player = _LettoreMuto();

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: MaestroScope(child: MeditationScreen(player: player)),
      ),
    ));
    await tester.pump();

    await tester.tap(find.byKey(const Key('meditation_play')));
    await tester.pump(const Duration(seconds: 30));
    await tester.tap(find.byKey(const Key('meditation_play')));
    await tester.pump(const Duration(seconds: 150));
    expect(find.byKey(const Key('meditazione_compiuta')), findsNothing,
        reason: 'la sessione interrotta si e\' dichiarata compiuta lo '
            'stesso: il timer non e\' stato fermato');
    expect(diario.haFatto('meditazione'), isFalse,
        reason: 'fermarsi a meta\' ha registrato il gesto: chi apre e chiude '
            'farmerebbe i traguardi del respiro');
  });
}

/// Un lettore che non suona davvero ma ricorda se sta suonando.
class _LettoreMuto implements TonePlayer {
  bool inSuono = false;

  @override
  Future<void> play(MeditationPreset preset) async => inSuono = true;

  @override
  Future<void> stop() async => inSuono = false;
}

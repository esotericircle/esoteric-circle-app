import 'package:esoteric_circle/features/intro/sequenza_intro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esoteric_circle/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// L'INTRO DI APERTURA: la sequenza, i suoi tempi, e il tocco che la salta.
///
/// E' provvisoria, per le dimostrazioni, e queste prove valgono finche' c'e'.
///
/// **IL VIDEO NON SI RIPRODUCE IN PROVA HEADLESS**: non c'e' una piattaforma che
/// lo decodifichi. La sequenza prosegue lo stesso, perche' il codice tratta il
/// video che non parte come un video finito, e queste prove misurano tutto il
/// resto: la frase che si scrive, i tempi, il logo, il salto e la destinazione.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silence() {
    final m = binding.defaultBinaryMessenger;
    for (final n in const [
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global',
    ]) {
      m.setMockMethodCallHandler(MethodChannel(n), (c) async => null);
    }
    m.setMockMethodCallHandler(
        const MethodChannel('flutter.io/videoPlayer'), (c) async => null);
  }

  Widget conIntro({bool riduciMovimento = false}) => MaterialApp(
        home: Builder(
          builder: (ctx) => MediaQuery(
            data: MediaQuery.of(ctx)
                .copyWith(disableAnimations: riduciMovimento),
            child: const SequenzaIntro(
              child: Scaffold(
                body: Center(
                  child: Text('DESTINAZIONE', key: Key('destinazione')),
                ),
              ),
            ),
          ),
        ),
      );

  testWidgets('La frase si scrive lettera per lettera, e finisce prima',
      (tester) async {
    silence();
    await tester.pumpWidget(conIntro());
    // La voce si chiede al lettore e la scrittura parte quando la sua durata e'
    // nota: in prova il lettore non c'e', quindi si aspetta che scada il tempo
    // massimo e subentri il ripiego dichiarato.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    Text frase() =>
        tester.widget<Text>(find.byKey(const Key('intro_frase')));

    // All'inizio non c'e' ancora niente di scritto.
    expect(frase().data, isEmpty,
        reason: 'la frase compare tutta insieme invece di scriversi');

    // A meta' della scrittura ce n'e' una parte, e non tutta.
    await tester.pump(SequenzaIntro.cadenzaPer(SequenzaIntro.voceDiRipiego) * 10);
    final aMeta = frase().data!;
    expect(aMeta.length, greaterThan(0));
    expect(aMeta.length, lessThan(SequenzaIntro.frase.length),
        reason: 'la frase e gia tutta scritta a un terzo del tempo');
    expect(SequenzaIntro.frase.startsWith(aMeta), isTrue,
        reason: 'le lettere non arrivano in ordine');

    // LA FRASE FINISCE DI SCRIVERSI CON UN RESPIRO PRIMA DELLA FINE, non allo
    // scadere: e' la cadenza che l'ordine chiede.
    // LA SCRITTURA E' CALIBRATA SULLA VOCE, non sui tre secondi: le lettere
    // finiscono quando la voce finisce di parlare, e la voce dura 2,43 secondi
    // contro i tre del nero, quindi il respiro prima della dissolvenza resta.
    final scrittura = SequenzaIntro.cadenzaPer(SequenzaIntro.voceDiRipiego) *
        SequenzaIntro.frase.length;
    expect((scrittura - SequenzaIntro.voceDiRipiego).inMilliseconds.abs(),
        lessThan(50),
        reason: 'la scrittura dura ${scrittura.inMilliseconds} millisecondi e '
            'la voce ${SequenzaIntro.voceDiRipiego.inMilliseconds}: la scritta '
            'non segue la voce');
    final respiro = SequenzaIntro.duranteIlNero - scrittura;
    expect(respiro.inMilliseconds, greaterThan(400),
        reason: 'il respiro prima della fine e di soli '
            '${respiro.inMilliseconds} millisecondi');

    // Il tempo scorre a passi: qui si aspetta il resto della scrittura, non
    // tutta daccapo, perche' dieci lettere sono gia' passate.
    for (var i = 0; i < SequenzaIntro.frase.length; i++) {
      await tester.pump(SequenzaIntro.cadenzaPer(SequenzaIntro.voceDiRipiego));
    }
    expect(frase().data, SequenzaIntro.frase);

    // Passati i tre secondi si va oltre il nero. Il conto parte da quando la
    // sequenza comincia davvero, cioe' dopo la lettura della voce.
    await tester.pump(SequenzaIntro.duranteIlNero);
    await tester.pump(SequenzaIntro.duranteIlNero);
    await tester.pump(SequenzaIntro.dissolvenza);
    expect(find.byKey(const Key('intro_frase')), findsNothing,
        reason: 'dopo tre secondi si resta sul nero');
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('Riduci Movimento posa la frase invece di scriverla',
      (tester) async {
    silence();
    await tester.pumpWidget(conIntro(riduciMovimento: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
        tester.widget<Text>(find.byKey(const Key('intro_frase'))).data,
        SequenzaIntro.frase,
        reason: 'con Riduci Movimento la frase si scrive lo stesso');
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('Un tocco salta tutto e porta alla destinazione',
      (tester) async {
    silence();
    await tester.pumpWidget(conIntro());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // La destinazione c'e' gia' sotto, coperta: l'intro non decide dove si va.
    expect(find.byKey(const Key('intro_frase')), findsOneWidget);

    await tester.tap(find.byKey(const Key('intro_salta')));
    await tester.pump();
    await tester.pump(SequenzaIntro.dissolvenza);

    expect(find.byKey(const Key('intro_salta')), findsNothing,
        reason: 'il tocco non salta l intro');
    expect(find.byKey(const Key('destinazione')), findsOneWidget,
        reason: 'saltata l intro non si arriva alla destinazione');
  });

  testWidgets('Senza intro si va dritti alla destinazione', (tester) async {
    // E' il caso delle prove e delle anteprime, e prova che la destinazione
    // sotto e' la stessa in tutti e due i casi: l'intro ritarda, non devia.
    silence();
    await tester.pumpWidget(const MaterialApp(
      home: SequenzaIntro(
        mostra: false,
        child: Scaffold(
          body: Center(child: Text('DESTINAZIONE', key: Key('destinazione'))),
        ),
      ),
    ));
    await tester.pump();
    expect(find.byKey(const Key('destinazione')), findsOneWidget);
    expect(find.byKey(const Key('intro_salta')), findsNothing);
  });

  testWidgets('Con Riduci Movimento la voce suona lo stesso', (tester) async {
    // Riduci Movimento tocca il MOVIMENTO, non l'audio: cambia il modo in cui
    // la scritta compare, e la voce resta.
    silence();
    await tester.pumpWidget(conIntro(riduciMovimento: true));
    await tester.pump();
    await tester.pump();
    // La sequenza dura quanto deve: se la voce fosse saltata insieme alla
    // macchina da scrivere, il nero finirebbe prima.
    expect(find.byKey(const Key('intro_frase')), findsOneWidget);
    await tester.pump(SequenzaIntro.duranteIlNero);
    await tester.pump(SequenzaIntro.duranteIlNero);
    await tester.pump(SequenzaIntro.dissolvenza);
    expect(find.byKey(const Key('intro_frase')), findsNothing);
    await tester.pump(const Duration(seconds: 4));
  });

  test('I tempi dichiarati compongono la sequenza che l ordine chiede', () {
    // Tre secondi di nero, mezzo secondo di dissolvenza. I numeri stanno nel
    // DATO e questa prova li legge da li': se qualcuno li cambia, li cambia in
    // un posto solo e questa prova dice se la sequenza regge ancora.
    expect(SequenzaIntro.duranteIlNero, const Duration(seconds: 3));
    expect(SequenzaIntro.dissolvenza, const Duration(milliseconds: 500));
    expect(SequenzaIntro.frase, 'IN PRINCIPIO ERA IL NULLA');
    // La voce dura meno del nero: finisce con un respiro prima della
    // dissolvenza, come l'ordine chiede.
    expect(SequenzaIntro.voceDiRipiego, lessThan(SequenzaIntro.duranteIlNero));
    expect(SequenzaIntro.voce, 'audio/principio.mp3');
  });

  testWidgets('L\'intro copre anche il Risveglio, che si apre con un push',
      (tester) async {
    // IL DIFETTO CHE QUESTA PROVA AVREBBE PRESO, segnalato sulla 2123: si
    // sentiva la voce e si vedeva il Risveglio. L'intro stava dentro `home`,
    // cioe' dentro la route iniziale, e il Risveglio non e' un ramo
    // dell'albero, e' un `push`: una route spinta SOPRA copre chi sta sotto.
    // L'intro era viva e sepolta.
    //
    // Le prove che c'erano montavano la sola SequenzaIntro, quindi non
    // potevano vedere un Navigator che non c'era. Questa monta L'APP INTERA
    // con l'intro accesa, che e' l'unico modo di misurare dove sta davvero.
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EsotericCircleApp());
    // Il tempo che serve al Risveglio per decidersi e spingersi sopra.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byKey(const Key('intro_salta')), findsOneWidget,
        reason: 'l\'intro non e\' piu\' a schermo: qualcosa le e\' passato '
            'davanti, e la voce continuerebbe a suonare sotto');
    // E la frase si vede, cioe' l'intro non e' solo montata, e' VISIBILE.
    expect(
        find.byWidgetPredicate((w) =>
            w is Text &&
            w.data != null &&
            w.data!.isNotEmpty &&
            SequenzaIntro.frase.startsWith(w.data!)),
        findsOneWidget,
        reason: 'la frase dell\'intro non si legge, quindi c\'e\' una '
            'schermata sopra');
  });
}

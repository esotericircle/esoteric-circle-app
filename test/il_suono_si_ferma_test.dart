import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/sensi/guardia_del_suono.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/meditation_audio.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/meditation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// IL SUONO SI FERMA. Sempre, e da un punto solo.
///
/// **La segnalazione.** Avviata la Meditazione col suono, cambiando funzione o
/// tornando alla home o mandando l'app in secondo piano, il suono restava
/// acceso. Il tono viene riprodotto in ciclo continuo, quindi "restava acceso"
/// vuol dire per sempre.
///
/// **Tre cause distinte, non una.**
///
/// A. `MeditationScreen.dispose` chiudeva il respiro e non fermava il lettore.
///    Che fosse una dimenticanza e non una scelta lo diceva lo stesso repo: il
///    Rito del Sogno usa lo stesso TonePlayer e nel suo dispose lo ferma gia'.
/// B. In tutto `lib/` non esisteva un solo osservatore del ciclo di vita. Non
///    e' che l'audio si fermasse male: nessuno gli diceva mai di fermarsi.
/// C. Il motore audio non veniva mai chiuso, e ne convivevano due: quello
///    statico della palette e uno nuovo per ogni apertura della Meditazione.
///
/// Tutte e tre nascono dalla stessa modifica, quando il lettore reale e'
/// diventato il predefinito. Quando cambia un predefinito si cerca chi altro
/// passa da quella strada, prima di chiudere.
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
  }

  Widget conProvider(Widget child) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
        ],
        child: MaterialApp(
          builder: (ctx, c) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: MaestroScope(child: c!),
          ),
          home: child,
        ),
      );

  group('Causa A: chiudendo la schermata il tono si ferma', () {
    testWidgets('Uscire dalla Meditazione ferma il lettore', (tester) async {
      silence();
      final spia = _LettoreSpia();
      await tester.pumpWidget(conProvider(Builder(
        builder: (ctx) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => Navigator.of(ctx).push(MaterialPageRoute<void>(
                builder: (_) => MeditationScreen(player: spia),
              )),
              child: const Text('entra'),
            ),
          ),
        ),
      )));
      await tester.tap(find.text('entra'));
      // Non pumpAndSettle: il respiro della Meditazione gira in ciclo continuo,
      // quindi l'albero non si posa mai e l'attesa scadrebbe.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // SI ACCENDE IL SUONO. Senza questo passo la prova chiudeva una schermata
      // muta, dove lo `stop` mancante non cambiava niente: era verde col
      // difetto e senza, e non perche' misurasse male, perche' non misurava.
      await tester.tap(find.byKey(const Key('meditation_play')));
      await tester.pump();
      expect(spia.avviato, isTrue,
          reason: 'il tono non parte nemmeno, quindi la prova che segue non '
              'sta misurando niente');

      // Si esce, come chi torna alla home o apre un'altra funzione.
      final ctx = tester.element(find.byType(MeditationScreen));
      Navigator.of(ctx).pop();
      // Piu' giri: la rotta si smonta a transizione conclusa, e il dispose
      // arriva dopo. Con due soli pump la schermata e' ancora viva e la prova
      // misurerebbe un momento in cui nessuno ha ancora chiuso niente.
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      expect(spia.fermato, isTrue,
          reason: 'uscendo dalla Meditazione il tono non viene fermato, e '
              'siccome suona in ciclo continuo resta acceso per sempre');

      // E a fermarlo dev'essere il DISPOSE della schermata, non la Guardia del
      // Suono che sorveglia il ciclo di vita: sono due protezioni diverse per
      // due situazioni diverse, chi esce dalla funzione e chi esce dall'app.
      // Se la seconda coprisse la prima, basterebbe togliere la Guardia perche'
      // il difetto tornasse in silenzio.
      expect(spia.chiHaFermato, contains('dispose'),
          reason: 'il tono lo ferma qualcun altro, non il dispose della '
              'Meditazione: la protezione che credi di avere non e\' quella '
              'che sta funzionando');
    });
  });

  group('Causa B: il ciclo di vita governa l\'audio da un punto solo', () {
    test('Esiste un osservatore del ciclo di vita in lib', () {
      // Non basta che la Meditazione si comporti bene: le porte sono tutte le
      // schermate che suonano, oggi due e domani dieci.
      var trovato = false;
      for (final f in Directory('lib').listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        final t = f.readAsStringSync();
        if (t.contains('didChangeAppLifecycleState') ||
            t.contains('AppLifecycleListener')) {
          trovato = true;
          break;
        }
      }
      expect(trovato, isTrue,
          reason: 'in tutto lib non c\'e\' un solo osservatore del ciclo di '
              'vita: nessuno dice all\'audio di fermarsi quando l\'app va in '
              'secondo piano');
    });

    testWidgets('In secondo piano l\'audio si ferma, e al ritorno non riparte',
        (tester) async {
      silence();
      final spia = _MotoreSpia();
      final guardia = GuardiaDelSuono(motore: spia);
      addTearDown(guardia.dispose);

      guardia.avvia();
      // L'app va in secondo piano.
      guardia.cambioStato(AppLifecycleState.paused);
      expect(spia.fermate, 1,
          reason: 'andando in secondo piano l\'audio non si ferma');

      // E anche solo perdendo il primo piano, per esempio con una chiamata.
      guardia.cambioStato(AppLifecycleState.inactive);
      expect(spia.fermate, 2,
          reason: 'perdendo il primo piano l\'audio non si ferma');

      // Tornando davanti NON riparte da solo: chi vuole il suono lo richiede.
      guardia.cambioStato(AppLifecycleState.resumed);
      expect(spia.riprese, 0,
          reason: 'tornando in primo piano l\'audio riparte da solo, e chi '
              'aveva chiuso la funzione se lo ritrova addosso');
    });
  });

  group('Causa C: un motore solo, davvero', () {
    test('La dichiarazione del motore unico e\' vera', () {
      // Il commento della classe dichiarava un motore solo mentre ne
      // convivevano due: quello statico della palette e uno nuovo per ogni
      // apertura della Meditazione. Un commento che mente e' peggio di un
      // difetto, perche' chi legge smette di verificare.
      final costruzioni = <String>[];
      for (final f in Directory('lib').listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        final p = f.path.replaceAll(Platform.pathSeparator, '/');
        final righe = f.readAsLinesSync();
        for (var i = 0; i < righe.length; i++) {
          if (righe[i].trimLeft().startsWith('//')) continue;
          if (righe[i].contains('= MotoreAudio._()')) {
            costruzioni.add('$p riga ${i + 1}');
          }
        }
      }
      expect(costruzioni.length, 1,
          reason: 'il motore audio viene costruito in ${costruzioni.length} '
              'punti ($costruzioni): la classe dichiara di essere una sola');
      // E il costruttore e' privato, cosi' nessuno puo' farne un secondo.
      final motore =
          File('lib/core/sensi/motore_audio.dart').readAsStringSync();
      expect(motore.contains('MotoreAudio._()'), isTrue,
          reason: 'il costruttore resta pubblico, quindi la dichiarazione di '
              'essere uno solo e un auspicio');
    });
  });
}

/// Un lettore che ricorda se gli hanno detto di fermarsi, e CHI gliel'ha detto.
///
/// Il "chi" non e' un lusso. La prima stesura registrava solo che qualcuno
/// avesse fermato, e restava verde anche togliendo lo `stop` dal dispose: nel
/// guscio dell'app vive la Guardia del Suono, che in prova sta nell'albero come
/// nella vita vera e fa il suo mestiere quando l'albero si smonta. La prova
/// vedeva il suono fermo e non sapeva chi l'aveva fermato, quindi la correzione
/// della causa B mascherava la causa A.
class _LettoreSpia implements TonePlayer {
  bool avviato = false;
  bool fermato = false;

  /// Chi ha chiamato `stop`, letto dallo stack di chiamata.
  String? chiHaFermato;

  @override
  Future<void> play(MeditationPreset preset) async => avviato = true;

  @override
  Future<void> stop() async {
    fermato = true;
    chiHaFermato = StackTrace.current.toString();
  }
}

/// Un motore che conta le fermate e le riprese.
class _MotoreSpia implements MotoreSonoro {
  int fermate = 0;
  int riprese = 0;

  @override
  Future<void> fermaTutto() async => fermate++;

  @override
  Future<void> riprendi() async => riprese++;
}

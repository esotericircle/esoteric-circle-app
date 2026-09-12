import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_suggestions.dart';
import 'package:esoteric_circle/features/shell/app_shell.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Intercetta la comparsa di apostrofi al posto degli accenti nei testi
/// italiani (per esempio "volonta'" invece di "volontà", "e'" invece di "è").
///
/// Copre la persona dei Maestri, inviata a Gemini, e i testi visibili della
/// chat. Cosi' la forma sbagliata non puo' rientrare di nascosto.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  // Una vocale seguita da apostrofo di fine parola e' un accento scritto male,
  // salvo i troncamenti legittimi come "po'". L'apostrofo di elisione (l'amore)
  // e' seguito da una lettera e non conta.
  final vowelApostrophe = RegExp("[aeiou]'", caseSensitive: false);
  final letter = RegExp('[a-zA-Zàèéìòù]');

  String? offendingWord(String s) {
    for (final m in vowelApostrophe.allMatches(s)) {
      final apostrophe = m.end - 1;
      if (apostrophe + 1 < s.length && letter.hasMatch(s[apostrophe + 1])) {
        continue; // elisione, per esempio l'amore o c'è
      }
      final vowel = m.start;
      final prev = vowel > 0 ? s[vowel - 1].toLowerCase() : '';
      final pair = '$prev${s[vowel].toLowerCase()}';
      if (pair == 'po' || pair == 'mo' || pair == 'be') continue; // troncamenti
      final start = (vowel - 8).clamp(0, s.length);
      final end = (apostrophe + 2).clamp(0, s.length);
      return s.substring(start, end);
    }
    return null;
  }

  void expectClean(String text, String where) {
    final bad = offendingWord(text);
    expect(
      bad,
      isNull,
      reason: 'Accento scritto con l\'apostrofo in $where, vicino a "$bad".',
    );
  }

  test('La persona dei Maestri usa accenti corretti', () {
    final full = UserProfile(
      displayName: 'Sofia',
      courtesyForm: CourtesyForm.feminine,
    );
    final empty = UserProfile.empty;
    const memoryFull = MaestroMemory(
      facts: ['Segno solare Gemelli', 'Cerca chiarezza sul lavoro'],
      sessionSummary: 'Avete parlato del suo Ascendente e della carriera.',
    );

    for (final maestro in Maestro.values) {
      expectClean(
        MaestroPersona.systemInstruction(
          maestro: maestro,
          profile: full,
          memory: memoryFull,
        ),
        'persona ${maestro.id} (profilo pieno)',
      );
      expectClean(
        MaestroPersona.systemInstruction(
          maestro: maestro,
          profile: empty,
          memory: MaestroMemory.empty,
        ),
        'persona ${maestro.id} (profilo vuoto)',
      );
      expectClean(
        MaestroPersona.distillInstruction(maestro),
        'distillato ${maestro.id}',
      );

      for (final q in SuggestionSets.frequent(maestro)) {
        expectClean(q, 'domanda frequente ${maestro.id}');
      }
      for (final q in SuggestionSets.personal(maestro)) {
        expectClean(q, 'domanda personale ${maestro.id}');
      }
    }

    for (final group in SuggestionGroup.values) {
      expectClean(group.label, 'etichetta del gruppo');
    }
  });

  void silenceSensors() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final name in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(name),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  Future<void> step(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  // Raccoglie il testo visibile della chat e dei suoi fogli (disclaimer,
  // suggerimenti), escludendo la Home dietro la route, che non e' oggetto qui.
  void expectVisibleTextsClean(WidgetTester tester) {
    for (final element in find.byType(Text).evaluate()) {
      var underShell = false;
      element.visitAncestorElements((ancestor) {
        if (ancestor.widget is AppShell) {
          underShell = true;
          return false;
        }
        return true;
      });
      if (underShell) continue;
      final data = (element.widget as Text).data;
      if (data != null) expectClean(data, 'un testo visibile della chat');
    }
  }

  for (final maestro in Maestro.values) {
    testWidgets(
        'I testi visibili della chat di ${maestro.id} usano accenti corretti',
        (tester) async {
      silenceSensors();
      // Finestra da telefono, ordine BD voce 02: vedi la nota estesa in
      // chat_header_test.
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
          EsotericCircleApp(conIntro: false, services: AppServices.offline()));
      await step(tester);
      tester
          .element(find.byType(MaterialApp))
          .read<MaestroController>()
          .selectMaestro(maestro);
      await step(tester);
      // Dal Santuario: entra nel dominio dal busto centrale, poi apre la chat.
      await tester.tap(find.byKey(const Key('santuario_central_bust')));
      await step(tester);
      await step(tester);
      // La carta Consulta puo' stare sotto il bordo: prima la si porta in
      // vista, come fa chat_header_test dalla stessa strada.
      await tester.ensureVisible(find.text('Consulta ${maestro.displayName}'));
      await tester.pump();
      await tester.tap(find.text('Consulta ${maestro.displayName}'));
      await step(tester);

      // Stato vuoto: header, invito, chip d'avvio, avviso di configurazione e
      // il foglio del disclaimer che si apre da solo.
      expectVisibleTextsClean(tester);

      // Accetta il disclaimer e ricontrolla la schermata pulita.
      final accept = find.text('Ho capito, entriamo');
      if (accept.evaluate().isNotEmpty) {
        await tester.tap(accept);
        await step(tester);
      }
      expectVisibleTextsClean(tester);
    });
  }
}

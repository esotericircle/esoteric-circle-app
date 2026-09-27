import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/design_system/components/scena_sopra_la_conversazione.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_composer.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **I MESSAGGI STANNO FRA I CONTATORI E LA CASELLA.** Ordine EQ, voci 08 e
/// 09, 27 settembre 2026.
///
/// Nelle catture del fondatore della chat di Calìgo il testo dei messaggi si
/// vedeva sotto la casella di scrittura e sotto il menu' in basso, con la
/// scritta "ESPLORA" sopra le parole, e scorrendo passava dietro le due righe
/// dei contatori, che non hanno fondo. Il fondatore: *"Unisci tutto
/// all'ordine prossimo credo EQ"*.
///
/// **Si misura dove la lista finisce**, perche' la lista si ritaglia sui suoi
/// bordi: il suo fondo deve stare sopra il bordo alto della casella, la sua
/// cima sotto la fascia dei contatori.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzio() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final n in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Future<void> passo(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// Una conversazione lunga, abbastanza da riempire lo schermo e scorrere.
  Future<AppServices> servizi() async {
    final memoria = InMemoryMaestroMemoryRepository();
    await memoria
        .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
    for (var i = 0; i < 6; i++) {
      await memoria.appendMessage(
          Maestro.caligo,
          ChatMessage(
              role: ChatRole.user,
              text: 'Domanda numero $i, scritta abbastanza lunga da prendere '
                  'due righe nella bolla della persona.'));
      await memoria.appendMessage(
          Maestro.caligo,
          ChatMessage(
              role: ChatRole.maestro,
              text: 'Risposta numero $i. Le rune parlano piano, e la strada '
                  'si vede un passo alla volta: oggi guarda il segno che hai '
                  'davanti, domani quello dopo.'));
    }
    return AppServices(
      ai: const UnavailableMaestroAiProvider(),
      memory: memoria,
      memoryPersistent: true,
      diagnostics: 'Prova offline.',
    );
  }

  Future<void> apriLaConversazione(
      WidgetTester tester, double larghezza) async {
    silenzio();
    // Senza l'archivio finto `SharedPreferences` non risponde mai in prova, e
    // le conversazioni passate non si caricano.
    // Chi e' gia' nel Cerchio, come nelle catture del corredo: niente
    // accoglienza del primo avvio e niente foglio degli avvisi sopra la scena.
    SharedPreferences.setMockInitialValues(const {
      'onboarding.done': true,
      'santuario.greeted': true,
      'cammino.generazione': 2,
      'avvisi.primoGiorno.chiesto': true,
      'settings.effettiSonori': false,
    });
    tester.view.physicalSize = Size(larghezza * 3, 800 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: await servizi()));
    await passo(tester);
    tester
        .element(find.byType(MaterialApp))
        .read<MaestroController>()
        .selectMaestro(Maestro.caligo);
    await passo(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await passo(tester);
    await passo(tester);
    final scheda = find.byKey(const Key('scheda_tocco_consulta_caligo'));
    await tester.ensureVisible(scheda);
    await tester.pump();
    await tester.tap(scheda);
    await tester.pump(const Duration(milliseconds: 500));
    await passo(tester);
    await tester.tap(find.byKey(const Key('chat_menu_della_barra')));
    await passo(tester);
    await tester.tap(find.byKey(const Key('chat_conversazione_passata_0')));
    await passo(tester);
    await passo(tester);
  }

  for (final larghezza in const [360.0, 402.0]) {
    testWidgets(
        'EQ.08 ed EQ.09: la conversazione finisce sopra la casella e sotto i '
        'contatori, a $larghezza punti', (tester) async {
      await apriLaConversazione(tester, larghezza);
      final lista = find.descendant(
          of: find.byType(ScenaSopraLaConversazione),
          matching: find.byType(ListView));
      expect(lista, findsOneWidget, reason: 'la conversazione non c\'e\'');
      final rLista = tester.getRect(lista);
      final rCasella = tester.getRect(find.byType(ChatComposer));
      final rContatori =
          tester.getRect(find.byKey(const Key('chat_contatori_e_dal_vivo')));
      // **IL FONDO VISIBILE, non quello del riquadro.** La lista e' lunga
      // quanto prima e si ritaglia: si misura dove il ritaglio la ferma. Se
      // un ritaglio non c'e', il fondo visibile e' quello della lista.
      var fondoVisibile = rLista.bottom;
      // **E LA CIMA VISIBILE, ordine EQ voce 09.** Il riquadro della lista
      // cominciava sotto i contatori e la prova era verde, mentre sul Realme
      // il ritratto in cima alla conversazione passava dietro le due righe:
      // il ritaglio di EQ.08 lasciava la cima libera. Si misura dove la
      // conversazione puo' davvero dipingere, come per il fondo.
      var cimaVisibile = double.negativeInfinity;
      for (final clip in tester.renderObjectList<RenderClipRect>(
          find.ancestor(of: lista, matching: find.byType(ClipRect)))) {
        final taglio = clip.clipper?.getClip(clip.size);
        if (taglio == null) continue;
        final fondo = clip.localToGlobal(Offset(0, taglio.bottom)).dy;
        if (fondo < fondoVisibile) fondoVisibile = fondo;
        final cima = clip.localToGlobal(Offset(0, taglio.top)).dy;
        if (cima > cimaVisibile) cimaVisibile = cima;
      }
      // ignore: avoid_print
      print('EQ.08 MISURA a $larghezza punti: lista da '
          '${rLista.top.toStringAsFixed(1)} a ${rLista.bottom.toStringAsFixed(1)}, '
          'visibile fino a ${fondoVisibile.toStringAsFixed(1)}, '
          'contatori fino a ${rContatori.bottom.toStringAsFixed(1)}, casella da '
          '${rCasella.top.toStringAsFixed(1)}; sotto il bordo della casella '
          '${(fondoVisibile - rCasella.top).clamp(0, 9999).toStringAsFixed(1)} '
          'punti di conversazione');
      expect(fondoVisibile, lessThanOrEqualTo(rCasella.top + 0.5),
          reason: 'la conversazione si vede sotto la casella di scrittura per '
              '${(fondoVisibile - rCasella.top).toStringAsFixed(1)} punti');
      expect(rLista.top, greaterThanOrEqualTo(rContatori.bottom - 0.5),
          reason: 'la conversazione passa dietro i contatori per '
              '${(rContatori.bottom - rLista.top).toStringAsFixed(1)} punti');
      expect(cimaVisibile, greaterThanOrEqualTo(rContatori.bottom - 0.5),
          reason: 'la conversazione puo\' dipingere dietro i contatori per '
              '${(rContatori.bottom - cimaVisibile).toStringAsFixed(1)} '
              'punti: il ritaglio non la ferma in cima');
      // ignore: avoid_print
      print('EQ.09 MISURA a $larghezza punti: la conversazione si vede da '
          '${cimaVisibile.toStringAsFixed(1)}, i contatori finiscono a '
          '${rContatori.bottom.toStringAsFixed(1)}');

      // **EQ.09: LA FASCIA HA IL FONDO DELLA TESTATA.** La conversazione
      // cominciava gia' sotto i contatori, e la prova qui sopra era verde:
      // cio' che il fondatore vedeva era la fascia senza fondo, con le righe
      // tagliate della conversazione subito sotto le sue parole. Si pretende
      // la tinta della testata, sotto tutta la larghezza e sotto i contatori.
      final fascia = find.byKey(const Key('chat_fondo_dei_contatori'));
      expect(fascia, findsOneWidget,
          reason: 'la fascia dei contatori non ha un fondo');
      final testata = tester.widget<AppBar>(find.descendant(
          of: find.byType(Scaffold), matching: find.byType(AppBar)).last);
      expect(tester.widget<ColoredBox>(fascia).color, testata.backgroundColor,
          reason: 'la fascia non ha la tinta della testata');
      final rFascia = tester.getRect(fascia);
      expect(rFascia.width, closeTo(larghezza, 0.5),
          reason: 'la fascia non e\' larga quanto lo schermo');
      expect(rFascia.top, lessThanOrEqualTo(rContatori.top + 0.5));
      expect(rFascia.bottom, greaterThanOrEqualTo(rContatori.bottom - 0.5));
      // ignore: avoid_print
      print('EQ.09 MISURA a $larghezza punti: fascia da '
          '${rFascia.left.toStringAsFixed(1)} a ${rFascia.right.toStringAsFixed(1)}, '
          'tinta ${tester.widget<ColoredBox>(fascia).color}, come la testata');
    });
  }
}

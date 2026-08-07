import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/shell/barra_del_cerchio.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/features/maestri/widgets/maestro_bust.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LE RIFINITURE DELLA CHAT, ordine 2163 voce 9: tre cose piccole, stesse
/// regole grandi.
///
/// 1. Il benvenuto era grigio su fondale scuro: la prima cosa che si legge
///    entrando era la meno leggibile. Minimo dichiarato per il testo
///    d'apertura: 7 di contrasto, MISURATO con la luminanza relativa.
/// 2. Il ritratto tondo nell'intestazione si sovrapponeva alla freccia e
///    schiacciava il titolo: adesso le distanze si misurano sui rettangoli
///    della resa, anche coi caratteri di sistema ingranditi.
/// 3. Sotto il campo di scrittura c'era mezzo schermo vuoto: era un DOPPIO
///    conteggio, il campo gia' sollevato dal Positioned aggiungeva di nuovo
///    il padding del sistema (che dentro la barra vale la barra intera).
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  const contrastoMinimoBenvenuto = 7.0;

  /// Fra il fondo del campo e la cima della barra al massimo questo respiro.
  const respiroMassimoSottoIlCampo = 24.0;

  void silenzia() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(nome),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  double contrasto(Color a, Color b) {
    final la = a.computeLuminance(), lb = b.computeLuminance();
    return (la > lb ? la + 0.05 : lb + 0.05) /
        (la > lb ? lb + 0.05 : la + 0.05);
  }

  Future<NavigatorState> monta(WidgetTester tester,
      {double scala = 1.0, AppServices? servizi}) async {
    silenzia();
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = scala;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await tester.pumpWidget(EsotericCircleApp(
        conIntro: false, services: servizi ?? AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    return tester.state<NavigatorState>(find.byType(Navigator).last);
  }

  testWidgets('il benvenuto regge il contrasto dichiarato nelle tre case',
      (tester) async {
    final nav = await monta(tester);
    final colpe = <String>[];
    for (final maestro in Maestro.fixedOrder) {
      nav.push(MaestroChatScreen.route(
          maestro: maestro, services: AppServices.offline()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      final benvenuto = find.byKey(const Key('chat_benvenuto'));
      if (benvenuto.evaluate().isEmpty) {
        colpe.add('${maestro.displayName}: manca il benvenuto con la chiave');
      } else {
        final testo = tester.widget<Text>(benvenuto.first);
        final colore = testo.style!.color!;
        // Il fondale peggiore possibile dietro il benvenuto e' il piu'
        // chiaro della casa: surfaceElevated, letto dalla palette vera.
        final fondo =
            MaestroPalette.forKey(ThemeKey.of(maestro)).surfaceElevated;
        final r = contrasto(colore, fondo);
        if (r < contrastoMinimoBenvenuto) {
          colpe.add('${maestro.displayName}: contrasto del benvenuto '
              '${r.toStringAsFixed(2)} sotto il minimo dichiarato '
              '$contrastoMinimoBenvenuto');
        }
      }
      nav.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  testWidgets('freccia, ritratto e titolo non si toccano, anche a caratteri '
      'grandi', (tester) async {
    // COL RITRATTO: il visto di Mauro era a conversazione avviata, quando
    // il tondo del Maestro sta sopra il nome. A chat vuota il tondo non
    // c'e' e la prova non proverebbe niente.
    final servizi = AppServices(
      ai: const _VocePronta(),
      memory: InMemoryMaestroMemoryRepository(),
      memoryPersistent: false,
    );
    final nav = await monta(tester, scala: 1.3, servizi: servizi);
    nav.push(
        MaestroChatScreen.route(maestro: Maestro.caligo, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.enterText(find.byType(TextField).first, 'Ciao');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    for (var i = 0; i < 14; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(find.byType(MaestroBust), findsWidgets,
        reason: 'Il ritratto non e\' comparso: la prova non prova.');
    final ritratto = tester.getRect(find.byType(MaestroBust).first);

    final freccia = tester.getRect(find.byIcon(Icons.arrow_back_rounded));
    expect(freccia.overlaps(ritratto.inflate(2)), isFalse,
        reason: 'Il ritratto tocca la freccia indietro: '
            'freccia $freccia, ritratto $ritratto.');
    final titolo = tester.getRect(find.text('Caligo').first);
    expect(freccia.overlaps(titolo.inflate(2)), isFalse,
        reason: 'Il titolo tocca la freccia indietro: '
            'freccia $freccia, titolo $titolo.');
    final schermo = tester.view.physicalSize.width;
    expect(titolo.left, greaterThanOrEqualTo(freccia.right - 1),
        reason: 'Il titolo comincia prima che la freccia finisca.');
    expect(titolo.right, lessThanOrEqualTo(schermo),
        reason: 'Il titolo esce dal bordo.');
  });

  testWidgets('sotto il campo di scrittura non c\'e\' piu' ' mezzo schermo '
      'vuoto', (tester) async {
    final nav = await monta(tester);
    nav.push(MaestroChatScreen.route(
        maestro: Maestro.medora, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final campo = tester.getRect(find.byKey(const Key('chat_campo')));
    final schermo = tester.view.physicalSize.height;
    final cimaBarra = schermo - BarraDelCerchio.altezza;
    final respiro = cimaBarra - campo.bottom;
    // ignore: avoid_print
    print('RIFINITURE: respiro sotto il campo = '
        '${respiro.toStringAsFixed(1)} punti '
        '(massimo $respiroMassimoSottoIlCampo)');
    expect(respiro, lessThanOrEqualTo(respiroMassimoSottoIlCampo),
        reason: 'Fra il fondo del campo e la cima della barra restano '
            '${respiro.toStringAsFixed(1)} punti vuoti: e\' il doppio '
            'conteggio del padding di sistema dentro il compositore.');
    expect(respiro, greaterThanOrEqualTo(0),
        reason: 'Il campo finisce sotto la cima della barra.');
  });
}

class _VocePronta implements MaestroAiProvider {
  const _VocePronta();

  @override
  bool get isReady => true;

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
    NatalContext natal = NatalContext.none,
    bool insistiSullAncoraggio = false,
    String? rispostaGiaData,
  }) async =>
      'Il cielo osserva con te questa domanda e la tiene aperta.';

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async =>
      throw const MaestroAiUnavailable();

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) async =>
      throw const MaestroAiUnavailable();

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;
}

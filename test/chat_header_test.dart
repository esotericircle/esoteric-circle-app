import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/components/cosmos_background.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/shell/app_shell.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Anti-regressione dell'header della chat.
///
/// In passato il "rettangolo a portale", la costellazione quadrata in alto a
/// destra, e' stato rimosso piu' volte e continuava a tornare. Nella chat il
/// cosmo di sfondo non deve disegnare alcuna costellazione, cosi' quella forma
/// non puo' ricomparire dietro l'header. Questo test lo blinda: se qualcuno
/// riattiva le costellazioni nella chat, il test fallisce.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  // In headless i sensori non esistono: si silenziano per evitare l'eccezione
  // asincrona della parallasse.
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

  Future<void> openChat(WidgetTester tester, Maestro maestro) async {
    await tester.pumpWidget(EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await step(tester);
    // Dal Santuario: porta il Maestro al centro, entra nel dominio dal busto,
    // poi apre la chat.
    final ctx = tester.element(find.byType(MaterialApp));
    ctx.read<MaestroController>().selectMaestro(maestro);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await step(tester);
    await step(tester);
    // DALL'ORDINE I il busto canonico in cima al dominio e' piu' alto della
    // vecchia presenza: sulla finestra di prova la carta Consulta scivola
    // sotto il bordo, e prima di toccarla la si porta in vista.
    await tester.ensureVisible(find.text('Consulta ${maestro.displayName}'));
    await tester.pump();
    await tester.tap(find.text('Consulta ${maestro.displayName}'));
    await step(tester);
  }

  // Le regole dell'header valgono per tutti e tre i Maestri.
  for (final maestro in Maestro.values) {
    testWidgets(
        'Il cosmo della chat di ${maestro.id} non disegna costellazioni',
        (tester) async {
      silenceSensors();
      await openChat(tester, maestro);

      final chatCosmos = tester.widget<CosmosBackground>(
        find.descendant(
          of: find.byType(MaestroChatScreen),
          matching: find.byType(CosmosBackground),
        ),
      );
      expect(
        chatCosmos.showZodiac,
        isFalse,
        reason: 'La chat non deve mostrare la costellazione quadrata '
            '(rettangolo a portale) dietro l\'header.',
      );
    });

    testWidgets(
        'L\'header della chat di ${maestro.id} non mostra il pulsante Messa a '
        'punto', (tester) async {
      silenceSensors();
      await openChat(tester, maestro);
      // Il simbolo a cursori non deve comparire nell'header: nessuno strumento
      // da sviluppatore nella build normale o da Demo.
      expect(find.byIcon(Icons.tune_rounded), findsNothing);
    });

    testWidgets(
        'L\'header di ${maestro.id} e\' centrato e mostra le tre arti',
        (tester) async {
      silenceSensors();
      await openChat(tester, maestro);

      // Il sottotitolo dell'header della chat mostra le tre arti col formato
      // giusto.
      //
      // **La seconda meta' di questa prova non serve piu' dal 5 agosto 2026.**
      // Verificava che non comparisse `domainTitle`, cioe' la forma corta
      // "Astrologia e Destino". Quel campo non esiste piu': due campi che
      // descrivono lo stesso oggetto divergono sempre, quindi il corto e'
      // stato tolto invece che allineato. Che nessuna schermata ne componga
      // uno a mano lo prova `il_consiglio_mostra_tre_voci_test.dart`,
      // scandendo tutto lib.
      expect(
          find.descendant(
              of: find.byType(MaestroChatScreen),
              matching: find.text(maestro.domainArtsPhrase)),
          findsOneWidget);

      // Il titolo dell'AppBar della chat e' centrato.
      final appBar = tester.widget<AppBar>(find.descendant(
        of: find.byType(MaestroChatScreen),
        matching: find.byType(AppBar),
      ));
      expect(appBar.centerTitle, isTrue);
    });
  }


  testWidgets('Nemmeno il Santuario disegna le costellazioni zodiacali',
      (tester) async {
    silenceSensors();
    await tester.pumpWidget(EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await step(tester);

    final homeCosmos = tester.widget<CosmosBackground>(
      find.descendant(
        of: find.byType(AppShell),
        matching: find.byType(CosmosBackground),
      ),
    );
    expect(
      homeCosmos.showZodiac,
      isFalse,
      reason: 'Il Santuario e il Passport non mostrano figure zodiacali: il '
          'segno solare in oro resta solo nel cielo di nascita.',
    );
  });
}

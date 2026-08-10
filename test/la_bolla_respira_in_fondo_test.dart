import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_bubble.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_composer.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// LA BOLLA RESPIRA ANCHE IN FONDO.
///
/// **Il difetto, visto nell'anteprima della build 2148.** L'ultima riga della
/// bolla, "Oggi te ne restano 3 su 3", stava attaccata al bordo inferiore.
/// Misurato sui pixel dell'anteprima: il fondo dei glifi a y=2155 e il bordo
/// della bolla a y=2170 circa, cioe' quindici pixel a densita' tre, cinque
/// punti logici, contro i dodici che il riempimento dichiara.
///
/// **Il riempimento della bolla e' `EdgeInsets.symmetric`**, quindi la stessa
/// costante governa la cima: allargare il fondo alzando quel numero
/// allargherebbe anche la cima di tutte le bolle dell'app. Il fondo si allarga
/// dove il fondo comincia, cioe' sotto l'ultima riga.
///
/// Questa prova misura l'ingombro vero a schermo, col testo piu' lungo che la
/// bolla puo' portare, e non calcola l'atteso da nessuna costante del codice:
/// il numero qui sotto e' scritto a mano e giustificato.
const String _lungo =
    'Il tuo Sole in Cancro chiede riparo prima di chiedere strada, e quello '
    'che senti come confusione è soltanto un confine che si sposta più in là '
    'di dove lo avevi lasciato la settimana scorsa. La runa che ti accompagna '
    'è Laguz, l\'acqua che trova la sua via anche quando la pietra sembra '
    'chiuderla del tutto.\n'
    '✦ Non decidere adesso: guarda dove ti fermi a respirare.';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  /// I SENSORI, MUTI.
  ///
  /// Serve perche' la misura sui pixel gira dentro `runAsync`, e li' i canali
  /// veri della piattaforma partono davvero: senza questo, il plugin dei
  /// sensori solleva `MissingPluginException` e la prova casca per una ragione
  /// che non c'entra niente con l'ingombro della bolla.
  void zittisciISensori() {
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

  Future<void> caricaFont() async {
    for (final f in const [
      ['Cinzel', 'assets/fonts/Cinzel-variable.ttf'],
      ['EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'],
    ]) {
      final l = FontLoader(f[0]);
      l.addFont(
          Future.value(ByteData.view(File(f[1]).readAsBytesSync().buffer)));
      await l.load();
    }
  }

  final chiaveDelloSchermo = GlobalKey();

  Future<void> monta(WidgetTester tester) async {
    tester.view.physicalSize = const Size(360 * 3, 797 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final memoria = InMemoryMaestroMemoryRepository();
    await memoria
        .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
    final servizi = AppServices(
      ai: _VoceLunga(),
      memory: memoria,
      memoryPersistent: false,
      diagnostics: 'prova di ingombro',
    );
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<AppServices>.value(value: servizi),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier1)),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: RepaintBoundary(
        key: chiaveDelloSchermo,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Navigator(
            onGenerateRoute: (_) => MaestroChatScreen.route(
              maestro: Maestro.medora,
              services: servizi,
            ),
          ),
        ),
      ),
    ));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }
    final campo = find.descendant(
      of: find.byType(ChatComposer),
      matching: find.byType(TextField),
    );
    expect(campo, findsOneWidget);
    await tester.enterText(campo, 'devo cambiare lavoro');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.send);
    for (var i = 0; i < 340; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// Il riquadro della bolla che contiene [dentro], cioe' il Container che
  /// porta la superficie dipinta. Non si cerca per tipo: si risale.
  Rect riquadroDellaBolla(WidgetTester tester, Finder dentro) {
    for (final e
        in find.ancestor(of: dentro, matching: find.byType(Container)).evaluate()) {
      final d = (e.widget as Container).decoration;
      if (d is BoxDecoration && d.gradient != null) {
        final r = e.renderObject as RenderBox;
        return r.localToGlobal(Offset.zero) & r.size;
      }
    }
    fail('nessuna bolla dipinta sopra questo widget');
  }

  testWidgets('L\'ultima riga della bolla non tocca il bordo di sotto',
      (tester) async {
    zittisciISensori();
    await caricaFont();
    await monta(tester);

    final residuo = find.byKey(const Key('chat_residuo_confronti'));
    expect(residuo, findsOneWidget,
        reason: 'senza il contatore a video questa prova misura un\'altra '
            'bolla, e il difetto sta proprio sotto quella riga');

    final testo = tester.getRect(residuo);
    final bolla = riquadroDellaBolla(tester, residuo);

    // SI MISURANO I PIXEL, non i riquadri di impaginazione.
    //
    // **Perche' i riquadri dicevano un'altra cosa.** Il fondo del riquadro del
    // testo dista tredici punti dal fondo della bolla, e sembrerebbe tutto a
    // posto. Ma il riquadro di una riga di testo finisce SOTTO i glifi, di
    // quanto vale la discesa del carattere, e quello che una persona vede e'
    // il glifo, non il riquadro. Sui pixel dell'anteprima 2148 la distanza
    // vera fra il fondo dei glifi e il bordo della bolla era di sedici pixel a
    // densita' tre. Qui si misura la stessa cosa, cosi' la prova guarda quello
    // che guarda l'occhio.
    // DENTRO `runAsync`, e non e' un dettaglio: `toImage` e `toByteData`
    // vogliono davvero l'asincrono, e chiamandoli fuori la prova non fallisce,
    // si PIANTA fino al tetto del tempo. La prima stesura ci ha messo dieci
    // minuti a morire, e il numero l'aveva gia' stampato.
    final densita = tester.view.devicePixelRatio;
    late final int fondoDeiGlifi;
    await tester.runAsync(() async {
      final immagine = await _scatta(tester, chiaveDelloSchermo);
      // IL BORDO DELLA BOLLA NON E' UN GLIFO, e la misura lo escludeva solo
      // per fortuna: l'oro al trenta per cento sopra il fondo scuro stava
      // sotto la soglia di luminanza, ma quando la bolla si allunga e il suo
      // fondo passa sopra una superficie chiara (il campo di scrittura), lo
      // stesso bordo la supera e la misura lo scambiava per l'ultima riga di
      // testo, dichiarando 0,33 punti di respiro con l'ultimo glifo a sedici
      // punti dal bordo. Due punti tolti in fondo: lo spessore del bordo piu'
      // l'antialiasing.
      fondoDeiGlifi = await _ultimaRigaConTestoDa(
        immagine,
        da: ((testo.top - 4) * densita).round(),
        a: ((bolla.bottom - 2) * densita).round(),
        // OLTRE IL RAGGIO DEGLI ANGOLI, non sei pixel: il riquadro della
        // bolla e' un rettangolo ma la superficie e' arrotondata, e negli
        // angoli il COSMO resta visibile dentro il rettangolo. Una stella
        // luminosa caduta li' veniva contata come ultima riga di testo, e la
        // prova accusava 2,33 punti di respiro mentre l'ultimo glifo vero
        // stava a tredici dal bordo: guardato sui pixel ritagliati, non
        // dedotto. Ventotto punti sono il raggio della bolla piu' due di
        // antialiasing.
        sinistra: ((bolla.left + 28) * densita).round(),
        destra: ((bolla.right - 28) * densita).round(),
      );
    });
    final respiro = (bolla.bottom * densita - fondoDeiGlifi) / densita;
    stdout.writeln('IL FONDO DELLA BOLLA, misurato sui pixel:');
    stdout.writeln('  riquadro del testo: $testo');
    stdout.writeln('  riquadro della bolla: $bolla');
    stdout.writeln('  fondo dei glifi: riga $fondoDeiGlifi');
    stdout.writeln('  respiro in fondo: $respiro punti');

    // IL GUARDIANO: la bolla deve essere quella lunga davvero, altrimenti si
    // sta misurando un caso che a video non capita mai.
    expect(bolla.height, greaterThan(200),
        reason: 'la bolla di prova e\' alta ${bolla.height} punti: con un '
            'testo corto il fondo non e\' il caso stretto');

    // OTTO PUNTI, e il numero e' scritto qui e non preso da SpacingTokens.
    //
    // **Perche' otto.** Il riempimento verticale della bolla vale dodici ed e'
    // `symmetric`, quindi non si puo' alzare senza alzare anche la cima di
    // ogni bolla dell'app. Otto e' la soglia sotto la quale l'occhio legge
    // "attaccato": nell'anteprima della build 2148 il respiro misurato era
    // cinque, e si vedeva. Chiedere dodici qui vorrebbe dire copiare la
    // costante che questa prova deve sorvegliare, e allora la prova
    // seguirebbe il difetto invece di prenderlo.
    expect(respiro, greaterThanOrEqualTo(8.0),
        reason: 'l\'ultima riga della bolla ha $respiro punti sotto di se\': '
            'a video si legge attaccata al bordo');
  });

  testWidgets('E in cima la bolla respira come prima', (tester) async {
    // Il guardiano dell'altra: la correzione del fondo non deve allargare la
    // cima, perche' quella vale per ogni bolla dell'app e nessuno l'ha
    // chiesta.
    zittisciISensori();
    await caricaFont();
    await monta(tester);
    final corpo = find.descendant(
      of: find.byType(ChatBubble),
      matching: find.textContaining('chiede riparo'),
    );
    expect(corpo, findsWidgets);
    final testo = tester.getRect(corpo.first);
    final bolla = riquadroDellaBolla(tester, corpo.first);
    final cima = testo.top - bolla.top;
    stdout.writeln('respiro in cima: $cima punti');
    // DICIOTTO E NON PIU' QUATTORDICI, dall'ordine H: il riempimento
    // verticale della bolla e' cresciuto da dodici a sedici punti quando il
    // testo della chat e' passato da quattordici a sedici (ordine E), quindi
    // la cima legittima e' sedici piu' l'antialiasing. Il tetto esiste ancora
    // per la stessa ragione di prima: impedire che una correzione del fondo
    // gonfi la cima senza che nessuno se ne accorga.
    expect(cima, lessThanOrEqualTo(18.0),
        reason: 'la cima della bolla si e\' allargata a $cima punti: la '
            'correzione del fondo ha alzato la costante simmetrica, e adesso '
            'ogni bolla dell\'app e\' piu\' alta senza che nessuno lo abbia '
            'chiesto');
  });
}

/// L'immagine di cio' che c'e' a schermo, alla densita' vera.
Future<ui.Image> _scatta(WidgetTester tester, GlobalKey chiave) async {
  final confine =
      chiave.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  return confine.toImage(pixelRatio: tester.view.devicePixelRatio);
}

/// L'ULTIMA RIGA DI PIXEL CHE PORTA DEL TESTO, dentro la fascia data.
///
/// Il testo del contatore e' chiaro sopra il blu della bolla: la soglia
/// separa le due popolazioni con un margine larghissimo, il fondo sta intorno
/// a 29 di luminanza e i glifi intorno a 194, misurati sui pixel
/// dell'anteprima. Centoventi sta in mezzo e non tocca nessuna delle due.
Future<int> _ultimaRigaConTestoDa(ui.Image immagine,
    {required int da,
    required int a,
    required int sinistra,
    required int destra}) async {
  final dati = await immagine.toByteData(format: ui.ImageByteFormat.rawRgba);
  final byte = dati!.buffer.asUint8List();
  final larghezza = immagine.width;
  var ultima = -1;
  for (var y = da.clamp(0, immagine.height - 1);
      y < a.clamp(0, immagine.height);
      y++) {
    for (var x = sinistra.clamp(0, larghezza - 1);
        x < destra.clamp(0, larghezza);
        x++) {
      final i = (y * larghezza + x) * 4;
      final lum =
          0.2126 * byte[i] + 0.7152 * byte[i + 1] + 0.0722 * byte[i + 2];
      if (lum > 120) {
        ultima = y;
        break;
      }
    }
  }
  return ultima;
}

class _VoceLunga implements MaestroAiProvider {
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
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return _lungo;
  }

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async =>
      const MaestroReply(glance: 'g', reading: 'r', invite: 'i');

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) async =>
      's';

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;
}

// NESSUNO DISEGNA UN AVATAR PIU' GRANDE DELLA SUA TELA.
//
// **E' la ragione della tela, tenuta viva.** Gli avatar stanno su una tela di
// 1142x1700 e non su una piu' grande perche' un'immagine decodificata occupa
// larghezza per altezza per 4 byte in RAM: a 2056x3060 i tre tenevano 75,5 MB
// di memoria su un telefono, a 1142x1700 ne tengono 23,3.
//
// Quel numero regge finche' nessuno disegna un avatar piu' grande della tela.
// Se qualcuno ingrandisce un busto o aggiunge una schermata che mostra il
// Maestro piu' in grande, l'asset viene stirato e si vede sfocato: questa
// prova cade prima, e dice di quanto.
//
// Monta l'APP VERA e misura l'altezza a cui ogni avatar viene DISEGNATO, su
// quattro schermi: il riferimento di Mauro, uno piu' alto, uno piu' fitto e il
// peggiore dei due messi insieme. Il massimo misurato il 5 agosto 2026 e' 1633
// px fisici, il busto centrale del Santuario a 360x900 punti con rapporto 4.

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/ask/ask_maestri_screen.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/features/onboarding/maestro_reveal_screen.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gli schermi su cui misurare. Il primo e' il telefono di riferimento di
/// Mauro; gli altri due dicono di quanto cresce il disegno su un telefono piu'
/// alto e su uno con rapporto di pixel 4.
const List<(String, Size, double)> kSchermi = [
  ('riferimento 360x797 r3', Size(360, 797), 3.0),
  ('alto      360x900 r3', Size(360, 900), 3.0),
  ('fitto     360x800 r4', Size(360, 800), 4.0),
  ('peggiore  360x900 r4', Size(360, 900), 4.0),
];

late String schermoCorrente;
late double rapportoCorrente;

/// chiave -> (punti logici, rapporto di pixel)
final Map<String, (double, double)> massimi = {};

void annota(String dove, WidgetTester tester) {
  for (final el in find.byType(Image).evaluate()) {
    final w = el.widget as Image;
    final img = w.image;
    if (img is! AssetImage) continue;
    if (!img.assetName.contains('avatars_webp')) continue;
    final ro = el.renderObject;
    if (ro is! RenderBox || !ro.hasSize) continue;
    final nome = img.assetName.split('/').last;
    final chiave = '$schermoCorrente | $dove | $nome';
    final prec = massimi[chiave]?.$1 ?? 0;
    if (ro.size.height > prec) {
      massimi[chiave] = (ro.size.height, rapportoCorrente);
    }
    // L'asserzione sta QUI e non in una prova finale a parte: una prova che
    // legge quello che hanno lasciato le altre passa verde quando la lanci da
    // sola, e cade per il motivo sbagliato quando la filtri per nome. E'
    // successo mentre si eseguiva il suo rosso.
    final fisici = ro.size.height * rapportoCorrente;
    expect(fisici, lessThanOrEqualTo(kTelaAltezza.toDouble()),
        reason: '$chiave disegna l\'avatar a ${fisici.toStringAsFixed(0)} px '
            'fisici, oltre i $kTelaAltezza della tela. L\'asset viene stirato '
            'e si vede sfocato. O si rimpicciolisce quel disegno, oppure si '
            'alza la tela in tool/normalizza_avatar.py sapendo che ogni '
            'avatar costa larghezza per altezza per 4 byte in RAM.');
  }
}

Future<void> precarica(WidgetTester tester) async {
  await tester.runAsync(() async {
    final el = tester.element(find.byType(MaterialApp).first);
    for (final m in Maestro.values) {
      await precacheImage(AssetImage(m.avatarAsset), el);
    }
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

/// La tela degli asset, la stessa dichiarata in `tool/normalizza_avatar.py` e
/// sorvegliata da `test/avatar_dei_maestri_test.dart`.
const int kTelaAltezza = 1700;

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // I sensori non esistono in prova: senza silenziarli l'accelerometro
    // riporta un guasto e la misura non arriva in fondo.
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
  });

  for (final (etichetta, misura, rapporto) in kSchermi) {
    testWidgets('altezza di disegno degli avatar, $etichetta', (tester) async {
      schermoCorrente = etichetta;
      rapportoCorrente = rapporto;
      tester.view.physicalSize =
          Size(misura.width * rapporto, misura.height * rapporto);
      tester.view.devicePixelRatio = rapporto;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
          EsotericCircleApp(conIntro: false, services: AppServices.offline()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      await precarica(tester);

      final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
      final servizi = AppServices.offline();

      // Le rotte VERE dell'app: la chat e il dominio si aprono con le loro
      // fabbriche, perche' e' li' che nascono i provider di rotta. Un push
      // nudo le fa cadere, ed era il motivo del primo giro a vuoto.
      Future<void> vai(String dove, Route<void> rotta) async {
        nav.push(rotta);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 900));
        await precarica(tester);
        annota(dove, tester);
        nav.pop();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
      }

      await vai(
          'Santuario  ',
          MaterialPageRoute<void>(
              // MaestroScope attorno, come fa `home` in app.dart: lo scope
              // avvolge la home e NON il builder, quindi una rotta spinta a
              // mano ne resta fuori e il Santuario cade sul suo assert.
              builder: (_) => MaestroScope(
                  child: SantuarioScreen(
                      clock: () => DateTime(2026, 7, 30, 21)))));
      await vai('Dominio    ',
          DomainScreen.route(maestro: Maestro.medora, services: servizi));
      await vai('Chat Medora',
          MaestroChatScreen.route(maestro: Maestro.medora, services: servizi));
      await vai('Chat Caligo',
          MaestroChatScreen.route(maestro: Maestro.caligo, services: servizi));
      await vai(
          'Consulta   ',
          AskMaestriScreen.perLaSintesi(
            starter: Maestro.medora,
            tema: 'una scelta',
            lenti: [
              MaestroLens.strati(
                  maestro: Maestro.aura,
                  glance: 'respiro',
                  reading: 'il corpo sa',
                  invite: 'ascolta'),
              MaestroLens.strati(
                  maestro: Maestro.caligo,
                  glance: 'runa',
                  reading: 'il segno parla',
                  invite: 'traccia'),
            ],
          ));

      // La Rivelazione si apre col gesto, non da sola: senza trascinare, la
      // carta col Maestro non compare e la misura nascerebbe cieca.
      nav.push(MaterialPageRoute<void>(
          builder: (_) => MaestroRevealScreen(
              maestro: Maestro.medora, onRevealed: (_) {})));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
      await tester.drag(
          find.byType(MaestroRevealScreen), const Offset(0, 1200));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      await precarica(tester);
      annota('Rivelazione', tester);
      nav.pop();
      await tester.pump();
    });
  }

  tearDownAll(() {
    final righe = massimi.entries.toList()
      ..sort((a, b) =>
          (b.value.$1 * b.value.$2).compareTo(a.value.$1 * a.value.$2));
    // ignore: avoid_print
    print('\n===== ALTEZZA DI DISEGNO DEGLI AVATAR =====');
    for (final r in righe) {
      // ignore: avoid_print
      print('${r.value.$1.toStringAsFixed(1).padLeft(7)} punti  ->  '
          '${(r.value.$1 * r.value.$2).toStringAsFixed(0).padLeft(5)} px '
          'fisici   ${r.key}');
    }
    // ignore: avoid_print
    print('===========================================\n');
  });

  test('le misure sono state raccolte davvero', () {
    // La guardia contro la misura cieca: se il precarico si rompe, le Immagini
    // non hanno dimensioni, non si misura niente e ogni soglia risulterebbe
    // rispettata. Trenta e' il numero di righe raccolte oggi, quattro schermi
    // per le schermate che mostrano un Maestro.
    expect(massimi.length, greaterThanOrEqualTo(24),
        reason: 'Raccolte solo ${massimi.length} misure: la prova sta '
            'nascendo cieca. Controlla il precarico degli avatar.');
  });
}

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/ask/ask_maestri_screen.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/features/passport/cosmic_passport_screen.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/shell/dove_si_vede_la_barra.dart';
import 'package:esoteric_circle/features/shell/navigation_controller.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA PILLOLA E LA PORTA SU OGNI SCHERMATA PRINCIPALE. Ordine AI, voci 01 e 02.
///
/// **I due difetti di Mauro, dalle foto del telefono**: il borsellino deve
/// essere SEMPRE visibile, e il menu' utente si vedeva solo nella home.
///
/// **L'enumerazione non e' scelta qui**: le schermate principali sono quelle
/// dichiarate in `dove_si_vede_la_barra.dart`, la legge delle cinque. Per
/// ciascuna si pretende la pillola del saldo (`borsellino`) e la porta
/// dell'account (`porta_dell_account`), montate dall'app vera coi suoi
/// provider. **Chi dichiara una schermata principale nuova senza darle un
/// collaudo qui viene fermato**: la prova confronta la legge col proprio
/// elenco e cade sulla differenza.
///
/// **Le misure dell'ordine**: la larghezza della pillola e' RISERVATA (con 0,
/// 1.000 e 10.000 Eos il riquadro non si muove di un punto), e il contrasto
/// della cifra sul suo fondo sta sopra 4,5 su ogni schermata enumerata.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(nome), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Future<void> respiro(WidgetTester tester, [int passi = 6]) async {
    for (var i = 0; i < passi; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  testWidgets('le cinque principali portano la pillola e la porta',
      (tester) async {
    silenzia();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 797);
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(
        const {'onboarding.done': true, 'santuario.greeted': true});
    final servizi = AppServices.offline();
    await tester.pumpWidget(EsotericCircleApp(conIntro: false, services: servizi));
    await respiro(tester);
    final contesto = tester.element(find.byType(Navigator).first);

    // Le rotte con cui il collaudo raggiunge ogni schermata principale della
    // LEGGE. Una principale nuova senza rotta qui fa cadere la prova sotto.
    final rotte = <String, Route<void> Function()>{
      'SantuarioScreen': () => MaterialPageRoute(
          builder: (_) => const SizedBox.shrink()), // e' la home: gia' montata.
      // Il Passaporto non e' una rotta: e' l'altra vista del guscio, e ci
      // si va dalla stessa porta della barra. Si gestisce a parte, sotto.
      'CosmicPassport': () => MaterialPageRoute(
          builder: (_) => const SizedBox.shrink()),
      'DomainScreen': () => DomainScreen.route(
          maestro: Maestro.medora, services: servizi),
      'MaestroChatScreen': () =>
          MaestroChatScreen.route(maestro: Maestro.medora, services: servizi),
      // Il Consiglio si apre nell'app dentro il suo MaestroScope (vedi
      // perLaSintesi): una rotta e' una sorella e lo scope va portato.
      'AskMaestriScreen': () => MaterialPageRoute(
          builder: (_) => const MaestroScope(
              maestro: Maestro.medora,
              child: AskMaestriScreen(starter: Maestro.medora))),
    };
    final principali = presenzaPerSchermata.entries
        .where((e) => e.value == PresenzaDellaBarra.presente)
        .map((e) => e.key)
        .toList();
    final senzaCollaudo =
        principali.where((nome) => !rotte.containsKey(nome)).toList();
    expect(senzaCollaudo, isEmpty,
        reason: 'schermate principali NUOVE senza collaudo qui: '
            '$senzaCollaudo. Chi le ha dichiarate nella legge delle cinque '
            'deve darle anche alla pillola e alla porta');

    Future<ui.Image> quadro() async {
      final confine = tester.renderObject<RenderRepaintBoundary>(
          find.byType(RepaintBoundary).first);
      return (await tester.runAsync(() => confine.toImage(pixelRatio: 1.0)))!;
    }

    double contrasto(ByteData dati, int larghezza, Rect zona) {
      double lineare(int canale) {
        final s = canale / 255.0;
        return s <= 0.03928
            ? s / 12.92
            : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
      }

      final luminanze = <double>[];
      for (var y = zona.top.round(); y < zona.bottom.round(); y++) {
        for (var x = zona.left.round(); x < zona.right.round(); x++) {
          final k = (y * larghezza + x) * 4;
          luminanze.add(0.2126 * lineare(dati.getUint8(k)) +
              0.7152 * lineare(dati.getUint8(k + 1)) +
              0.0722 * lineare(dati.getUint8(k + 2)));
        }
      }
      luminanze.sort();
      // Il testo e' la coda chiara (la cifra d'oro), il fondo la mediana
      // bassa del riquadro: e' il contrasto che l'occhio incontra davvero.
      final testo = luminanze[(luminanze.length * 97) ~/ 100];
      final fondo = luminanze[(luminanze.length * 35) ~/ 100];
      return (testo + 0.05) / (fondo + 0.05);
    }

    var osservate = 0;
    final mancanze = <String>[];
    final contrasti = <String, double>{};
    for (final nome in principali) {
      final ePrincipaleGiaMontata = nome == 'SantuarioScreen';
      final eVistaDelGuscio = nome == 'CosmicPassport';
      if (eVistaDelGuscio) {
        contesto.read<NavigationController>().goToPassport();
        await respiro(tester);
      } else if (!ePrincipaleGiaMontata) {
        Navigator.of(contesto).push(rotte[nome]!());
        await respiro(tester);
      }
      osservate++;
      if (find.byKey(const Key('borsellino')).evaluate().isEmpty) {
        mancanze.add('$nome e\' SENZA PILLOLA del saldo');
      }
      if (find.byKey(const Key('porta_dell_account')).evaluate().isEmpty) {
        mancanze.add('$nome e\' SENZA PORTA dell\'account');
      }
      // IL CONTRASTO SUL FONDO VERO di questa schermata.
      if (find.byKey(const Key('borsellino')).evaluate().isNotEmpty) {
        final scatola = tester
            .renderObject<RenderBox>(find.byKey(const Key('borsellino')).first);
        final dove = scatola.localToGlobal(Offset.zero) & scatola.size;
        final resa = await quadro();
        final dati = (await tester.runAsync(
            () => resa.toByteData(format: ui.ImageByteFormat.rawRgba)))!;
        final zona = Rect.fromLTRB(
            dove.left.clamp(0, resa.width - 1),
            dove.top.clamp(0, resa.height - 1),
            dove.right.clamp(1, resa.width.toDouble()),
            dove.bottom.clamp(1, resa.height.toDouble()));
        contrasti[nome] = contrasto(dati, resa.width, zona);
      }
      if (eVistaDelGuscio) {
        contesto.read<NavigationController>().goToSantuario();
        await respiro(tester);
      } else if (!ePrincipaleGiaMontata) {
        Navigator.of(contesto).pop();
        await respiro(tester);
      }
    }
    // **QUANTE OSSERVAZIONI, e cade se non sono le cinque della legge.**
    // ignore: avoid_print
    print('ORDINE AI: schermate principali osservate $osservate su '
        '${principali.length}; contrasti ${contrasti.map((k, v) =>
            MapEntry(k, v.toStringAsFixed(1)))}');
    expect(osservate, principali.length);
    expect(mancanze, isEmpty,
        reason: 'il saldo deve essere sempre visibile e la porta ovunque: '
            '${mancanze.join(" | ")}');
    for (final voce in contrasti.entries) {
      expect(voce.value, greaterThanOrEqualTo(4.5),
          reason: 'sulla ${voce.key} la cifra della pillola ha contrasto '
              '${voce.value.toStringAsFixed(2)}, sotto il 4,5 chiesto '
              'dall\'ordine');
    }

    // **IL TITOLO DEL DOMINIO NON TOCCA NESSUNO DEI DUE CAPI, e la frase
    // entra intera.** Si misura sul dominio di Medora, che ha il sottotitolo
    // piu' lungo, "Astrologia, Cartomanzia e Destino".
    Navigator.of(contesto).push(rotte['DomainScreen']!());
    await respiro(tester);
    final pilastri = tester
        .renderObject<RenderParagraph>(find.byKey(const Key('domain_pillars')));
    final riquadroPilastri =
        tester.getRect(find.byKey(const Key('domain_pillars')));
    final riquadroPillola =
        tester.getRect(find.byKey(const Key('borsellino')).first);
    final riquadroPorta =
        tester.getRect(find.byKey(const Key('porta_dell_account')).first);
    expect(riquadroPilastri.overlaps(riquadroPillola), isFalse,
        reason: 'il sottotitolo del dominio tocca la pillola');
    expect(riquadroPilastri.overlaps(riquadroPorta), isFalse,
        reason: 'il sottotitolo del dominio tocca la porta dell\'account');
    final misuraPilastri = TextPainter(
      text: pilastri.text,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: riquadroPilastri.width);
    // ignore: avoid_print
    print('ORDINE AI: sottotitolo del dominio largo '
        '${riquadroPilastri.width.toStringAsFixed(1)}, sborda: '
        '${misuraPilastri.didExceedMaxLines}');
    expect(misuraPilastri.didExceedMaxLines, isFalse,
        reason: 'il sottotitolo del dominio non entra intero nello spazio '
            'protetto: si troncherebbe coi puntini');
    misuraPilastri.dispose();
    Navigator.of(contesto).pop();
    await respiro(tester);

    // **LA LARGHEZZA E' RISERVATA**: 0, 1.000 e 10.000 Eos, stesso riquadro.
    final borsa = contesto.read<QuestionAllowance>();
    final riquadri = <int, Rect>{};
    for (final saldo in const [0, 1000, 10000]) {
      await tester.runAsync(() => borsa.applicaSaldo(saldo));
      await respiro(tester, 8);
      final scatola = tester
          .renderObject<RenderBox>(find.byKey(const Key('borsellino')).first);
      riquadri[saldo] = scatola.localToGlobal(Offset.zero) & scatola.size;
    }
    // ignore: avoid_print
    print('ORDINE AI: riquadri della pillola $riquadri');
    expect(riquadri[1000], riquadri[0],
        reason: 'da 0 a 1.000 Eos la pillola si e\' mossa o allargata: la '
            'larghezza non e\' riservata');
    expect(riquadri[10000], riquadri[0],
        reason: 'da 0 a 10.000 Eos la pillola si e\' mossa o allargata: la '
            'larghezza non e\' riservata');
  });
}

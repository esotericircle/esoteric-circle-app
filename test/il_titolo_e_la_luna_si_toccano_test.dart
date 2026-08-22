import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:esoteric_circle/features/santuario/widgets/moon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'monta_la_home.dart';

/// IL TITOLO SU UNA RIGA, E LA LUNA SI TOCCA. Ordine BB voce 01.
///
/// **Due richieste del fondatore nello stesso posto.** La prima: "Il cielo
/// sopra di te, adesso" deve stare su una riga sola. La seconda, un fatto:
/// "se tocco sulla luna il click non funziona".
///
/// **La seconda aveva una causa che non era dove si guarda di solito.** Il
/// rilevatore del tocco c'era gia' e avvolgeva la Luna: il difetto era **chi
/// gli stava sopra**. Il carosello dei Maestri viene dopo nella pila, quindi
/// copre, e il suo rilevatore di trascinamento si prendeva i tocchi diretti al
/// cielo. **E' la stessa famiglia del difetto di BA voce 02**: li' i Maestri
/// rubano la vista, qui rubavano il dito.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
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

  /// **TRE MISURE DI SCHERMO, coi rapporti VERI.** L'ordine AX chiedeva la
  /// prova su tre schermi, e il titolo e' proprio la cosa che va a capo dove
  /// lo spazio manca: provarlo solo su uno schermo comodo non proverebbe
  /// niente.
  const schermi = <String, (Size, double)>{
    'alto, 360x797': (Size(1080, 2391), 3.0),
    'medio, 375x667': (Size(750, 1334), 2.0),
    'basso, 320x568': (Size(640, 1136), 2.0),
  };

  for (final voce in schermi.entries) {
    testWidgets('su schermo ${voce.key} il titolo sta su una riga sola',
        (tester) async {
      silenzia();
      await montaLaHomePerLaMisura(tester, voce.value);

      final titolo = find.byKey(const Key('santuario_sky_title_testo'));
      expect(titolo, findsOneWidget,
          reason: 'il titolo del cielo non e a schermo: la prova non sta '
              'misurando quello che crede');

      // **SI CONTANO LE RIGHE DIPINTE, non i caratteri.** Un `maxLines: 1` che
      // taglia col punto e virgola sarebbe una riga sola e una bugia: qui si
      // guarda il rendering vero.
      final ro = tester.renderObject<RenderParagraph>(titolo);
      final righe = ro.getBoxesForSelection(TextSelection(
        baseOffset: 0,
        extentOffset: (ro.text.toPlainText()).length,
      ));
      final cime = righe.map((b) => b.top.round()).toSet();
      // ignore: avoid_print
      print('ORDINE BB VOCE 01: su schermo ${voce.key} il titolo occupa '
          '${cime.length} riga/righe, largo ${ro.size.width.round()} punti');

      expect(cime.length, 1,
          reason: 'il titolo va a capo su ${cime.length} righe: rubando '
              'altezza al blocco del cielo ne toglie ai Maestri sotto');
      // **E NON E' TAGLIATO**: una riga sola ottenuta con i puntini sarebbe
      // peggio di due righe.
      expect(ro.text.toPlainText(), 'Il Cielo Sopra di Te, Adesso');
      expect(ro.didExceedMaxLines, isFalse,
          reason: 'il titolo e stato tagliato per stare su una riga');
    });
  }

  testWidgets('il tocco sulla Luna apre il cielo, e non lo mangia il carosello',
      (tester) async {
    silenzia();
    await montaLaHomePerLaMisura(tester, schermi.values.first);

    // **SI TOCCA DOVE STA LA LUNA, al pixel.** Non la chiave del blocco: il
    // fondatore ha toccato la Luna, e la Luna e' un punto preciso dello
    // schermo.
    final luna = find.byType(MoonWidget);
    expect(luna, findsWidgets,
        reason: 'la Luna non e a schermo: la prova non sta misurando quello '
            'che crede');
    final centro = tester.getCenter(luna.first);

    // **La prova vera: si tocca e si guarda se si apre il cielo.**
    await tester.tapAt(centro);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final apertaLaSchermata =
        find.byKey(const Key('sky_overview_screen')).evaluate().isNotEmpty ||
            find.textContaining('Il cielo').evaluate().isNotEmpty;
    // ignore: avoid_print
    print('ORDINE BB VOCE 01: dopo il tocco sulla Luna, la schermata del '
        'cielo risulta aperta: $apertaLaSchermata');
    expect(apertaLaSchermata, isTrue,
        reason: 'toccando la Luna non si apre niente: il carosello dei Maestri '
            'sta sopra e si prende il tocco, ed e il fatto del fondatore');
  });
}

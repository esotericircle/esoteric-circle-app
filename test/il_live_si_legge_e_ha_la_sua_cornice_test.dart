import 'dart:ui' as ui;

import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/features/maestri/live/la_cornice_della_finestra.dart';
import 'package:esoteric_circle/features/maestri/live/la_scena_del_live.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// **NEL LIVE SI LEGGONO CINQUE RIGHE DI RISPOSTA, E IL VOLTO HA UNA CORNICE
/// VERA.** Ordine EN voci 02 e 03, 25 settembre 2026.
///
/// Il fondatore: *"Per ora leggo solo 3 righe della risposta del maestro, ma
/// possiamo arrivare almeno a 5."* E sulla finestra a cupola: *"è minimal ma
/// troppo semplice, vorrei qualcosa di elegante Senza esagerare e sempre
/// dorato."*
///
/// **Le righe si contano dove la persona le legge**: la finestra del
/// sottotitolo, dopo che una domanda di tre righe ha preso il suo posto, **nella
/// geometria del Realme**: 1080 per 2400 pixel a densita' 480, cioe' 360 per
/// 800 punti, scala del testo 1,0 (letti con adb il 25 settembre 2026), e sopra
/// la scena le due testate, quella dell'app e quella del Maestro, alte 122
/// punti nella cattura `docs/collaudo/EM/em09_em10_ascolto_domanda_risposta.jpg`.
/// **La prima stesura montava la scena a 390 per 844 senza testate**, cioe'
/// piu' alta del telefono vero: con la zona di prima vedeva cinque righe dove
/// il fondatore ne leggeva tre, e a scala 1,0 restava verde sul difetto. **La cornice si guarda nei pixel**: una guardia sull'albero dice
/// che il pittore c'e', non che disegna.
void main() {
  // Una domanda che va su tre righe e una risposta lunga.
  const domanda = 'Medora, ho pescato la Torre e poi l\'Appeso, e non so cosa '
      'fare con mio fratello che non mi parla da mesi: cosa vogliono dire '
      'queste due carte per me, adesso?';
  final risposta = List.filled(
          14, 'La Torre ti chiede di lasciar cadere cio\' che non regge piu\'.')
      .join(' ');

  Future<void> monta(WidgetTester tester, {double scala = 1}) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: MediaQuery(
        data: MediaQueryData(
            size: const Size(360, 800), textScaler: TextScaler.linear(scala)),
        child: Scaffold(
          body: Column(children: [
            // Le due testate sopra la scena, come sul Realme.
            const SizedBox(height: 122),
            Expanded(
              child: LaScenaDelLive(
                volto: const SizedBox.expand(
                    child: ColoredBox(color: Colors.black)),
                domanda: domanda,
                risposta: risposta,
                stato: 'Ti rispondo.',
                tastiera: const SizedBox(height: 72),
              ),
            ),
            // La barra dei tasti di Android sotto la scena.
            const SizedBox(height: 44),
          ]),
        ),
      ),
    ));
    await tester.pump();
  }

  /// Le righe intere di risposta che stanno nella finestra del sottotitolo.
  double righeVisibili(WidgetTester tester) {
    final finestra = tester.getSize(find.ancestor(
        of: find.byKey(const Key('live_sottotitolo')),
        matching: find.byType(SingleChildScrollView)));
    final testo = tester.renderObject<RenderParagraph>(
        find.byKey(const Key('live_sottotitolo')));
    final riga = testo.getFullHeightForCaret(const TextPosition(offset: 0));
    return finestra.height / riga;
  }

  for (final scala in [1.0, 1.3]) {
    testWidgets(
        'EN.02: sotto una domanda di tre righe se ne leggono almeno cinque '
        'di risposta, alla scala $scala', (tester) async {
      await monta(tester, scala: scala);
      // Il caso peggiore: la domanda prende davvero tutte le sue righe.
      final domandaAlta = tester
          .renderObject<RenderParagraph>(find.byKey(const Key('live_domanda')));
      final rigaDellaDomanda =
          domandaAlta.getFullHeightForCaret(const TextPosition(offset: 0));
      expect(domandaAlta.size.height / rigaDellaDomanda,
          greaterThan(LaScenaDelLive.righeDellaDomanda - 0.1),
          reason: 'la domanda di prova non arriva a tre righe: la prova '
              'misurerebbe un caso piu\' facile di quello del fondatore');
      final righe = righeVisibili(tester);
      expect(righe, greaterThanOrEqualTo(LaScenaDelLive.righeDellaRisposta),
          reason: 'nella finestra del sottotitolo stanno '
              '${righe.toStringAsFixed(2)} righe di risposta: il fondatore ne '
              'leggeva tre e ne chiede almeno cinque');
      expect(LaScenaDelLive.righeDellaRisposta, greaterThanOrEqualTo(5));
    });
  }

  testWidgets('EN.03: la cornice disegna oro fuori e sopra la finestra',
      (tester) async {
    // La finestra e' di 200 per 300 punti, al centro di un foglio di 260 per
    // 360: attorno c'e' il posto per il filo, la chiave e il davanzale.
    const finestra = Size(200, 300);
    const margine = 30.0;
    final registratore = ui.PictureRecorder();
    final tela = Canvas(registratore);
    tela.drawColor(Colors.black, BlendMode.src);
    tela.translate(margine, margine);
    const LaCorniceDellaFinestra(fascia: 4, raggioBasso: 6)
        .paint(tela, finestra);
    final immagine = await tester.runAsync(() => registratore
        .endRecording()
        .toImage((finestra.width + 2 * margine).toInt(),
            (finestra.height + 2 * margine).toInt()));
    final dati = await tester.runAsync(
        () => immagine!.toByteData(format: ui.ImageByteFormat.rawRgba));
    final larghezza = immagine!.width;

    // **L'oro si riconosce dalla tinta, non dalla luce.** Un filo di 1,2
    // punti copre due pixel al sessanta per cento, e sul nero arriva a
    // (116, 92, 26): la prima stesura pretendeva il rosso sopra 120 e
    // bocciava un filo che c'era. Oro vuol dire rosso e verde ben sopra il
    // blu, e abbastanza luce da non essere il fondo.
    bool oro(double x, double y) {
      final i = ((y + margine).round() * larghezza + (x + margine).round()) * 4;
      final r = dati!.getUint8(i), g = dati.getUint8(i + 1);
      final b = dati.getUint8(i + 2);
      return r >= 60 && r - b >= 40 && g - b >= 30;
    }

    // La chiave di volta sta sopra l'arco, al centro.
    expect(oro(finestra.width / 2, -4), isTrue,
        reason: 'nessuna chiave di volta sopra l\'arco');
    // Il filo esterno corre a cinque punti dal fianco sinistro, a meta'.
    final filo = [
      for (var dx = -7.0; dx <= -3; dx++) oro(dx, finestra.height * 0.7)
    ];
    expect(filo, contains(true), reason: 'nessun filo esterno sul fianco');
    // Il davanzale esce oltre il fianco destro, sotto il busto.
    expect([
      for (var dy = 3.0; dy <= 7; dy++)
        oro(finestra.width + 6, finestra.height + dy)
    ], contains(true), reason: 'nessun davanzale sotto il busto');
    // E dentro il volto, lontano dai bordi, la cornice non disegna niente.
    expect(oro(finestra.width / 2, finestra.height / 2), isFalse);
    immagine.dispose();
  });
}

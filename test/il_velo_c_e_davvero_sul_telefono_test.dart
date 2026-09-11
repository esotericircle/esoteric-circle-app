import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/dove_sta_la_testa.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/la_lente_che_scopre.dart';

/// **LA GUARDIA CHE GUARDA I PIXEL, ordine DE voce 03.**
///
/// **IL DIFETTO CHE LA FA NASCERE.** L'11 settembre 2026, sul 767f596c, alla
/// **seconda** e alla **terza** discesa l'animale si vedeva **intero, testa
/// compresa**, mentre a schermo c'era scritto *"Passa il dito: la lente scopre
/// solo dove puo', oggi"*. Il velo non era sottile: era **assente**.
///
/// **E DUE GUARDIE ERANO VERDI, tutte e due a ragione.**
///
/// - `la_testa_non_si_vede_prima_della_quarta_test` misura la **geometria**:
///   che il cerchio della lente non tocchi mai il rettangolo della testa. Non
///   lo toccava, e infatti quella prova non aveva niente da dire.
/// - La prima stesura di **questa** guardia misurava **l'albero**: che il velo
///   fosse costruito e opaco. Lo era, anche con le animazioni spente come sul
///   dispositivo.
///
/// **Il velo era costruito, era opaco, e non dipingeva niente.** Fra l'albero
/// e i pixel c'era uno `ShaderMask` con `BlendMode.dstIn`, e quella maschera
/// sul telefono cancellava il velo intero invece del suo cerchio.
///
/// **Percio' la grandezza misurata qui sta nei pixel dipinti**, letti dal
/// fotogramma vero: **quanto e' nitido** il rettangolo della testa, per tutti
/// e dodici gli animali, nelle tre discese in cui deve restare coperto e alla
/// quarta in cui deve vedersi. E' la Regola I applicata a una scena: pixel
/// dipinti, finestra vera.
///
/// **E non la luce media, che qui mente**: sotto il velo il fantasma sfocato
/// si vede, ed e' voluto. Vedi la nota su `quantoENitido`.
void main() {
  /// La scena di prova: un telefono vero, non gli ottocento per seicento di
  /// fabbrica.
  const scena = Size(390, 844);

  /// **DOVE SI METTE LA LENTE**, in frazioni dell'area concessa: il bordo
  /// alto, che e' il lato piu' vicino alla testa e quindi l'unico dove un
  /// difetto si vedrebbe. Il centro dell'area non proverebbe niente.
  const partenze = [Offset(0, 0), Offset(1, 0), Offset(0.5, 0)];

  /// **QUANTO E' NITIDO un rettangolo del fotogramma**, cioe' quanto cambiano
  /// i pixel da un vicino all'altro.
  ///
  /// **E non la luce media, che qui mente.** Sotto il velo il fantasma sfocato
  /// c'e' e si vede, percio' la luce sulla testa del Lupo faceva 57,3 velata
  /// contro 86,0 scoperta: due numeri vicini. Sul Cervo faceva 15,4 velata e
  /// 14,9 scoperta, cioe' **il contrario**, perche' il suo rettangolo della
  /// testa e' largo e in gran parte sfondo trasparente. La nitidezza invece
  /// separa: 4,85 contro 35,63 sul Lupo, 2,03 contro 9,72 sul Cervo.
  double quantoENitido(Uint8List b, int larga, Rect r) {
    double luce(int x, int y) {
      final i = (y * larga + x) * 4;
      if (i < 0 || i + 2 >= b.length) return 0;
      return (b[i] + b[i + 1] + b[i + 2]) / 3;
    }

    var somma = 0.0;
    var quanti = 0;
    for (var y = r.top.toInt(); y < r.bottom.toInt() - 1; y++) {
      for (var x = r.left.toInt(); x < r.right.toInt() - 1; x++) {
        somma += (luce(x + 1, y) - luce(x, y)).abs() +
            (luce(x, y + 1) - luce(x, y)).abs();
        quanti++;
      }
    }
    return quanti == 0 ? 0 : somma / quanti;
  }

  /// La misura vera del file, che serve a sapere dove `BoxFit.contain` mette
  /// l'immagine: i dodici **non hanno la stessa forma**, il gufo e' alto e la
  /// volpe e' larga.
  Future<Size> misuraDi(String percorso) async {
    final dati = await rootBundle.load(percorso);
    final codec = await ui.instantiateImageCodec(dati.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return Size(frame.image.width.toDouble(), frame.image.height.toDouble());
  }

  Rect dentroLaScena(Size sorgente) {
    final k = (scena.width / sorgente.width) < (scena.height / sorgente.height)
        ? scena.width / sorgente.width
        : scena.height / sorgente.height;
    final larga = sorgente.width * k;
    final alta = sorgente.height * k;
    return Rect.fromLTWH((scena.width - larga) / 2, (scena.height - alta) / 2,
        larga, alta);
  }

  Future<Uint8List> fotogramma(
      WidgetTester tester, GuideAnimal animale, int discesa,
      Offset parte) async {
    await tester.pumpWidget(MaterialApp(
      home: RepaintBoundary(
        key: const Key('foglio'),
        child: SizedBox(
          width: scena.width,
          height: scena.height,
          child: LenteCheScopre(
            nome: animale.name,
            immagine: animale.fullPath,
            discesa: discesa,
            doveParte: parte,
          ),
        ),
      ),
    ));
    await precacheImage(
        AssetImage(animale.fullPath), tester.element(find.byType(SizedBox).first));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 1200));
    final foglio = tester
        .renderObject<RenderRepaintBoundary>(find.byKey(const Key('foglio')));
    final immagine = await foglio.toImage();
    final dati = await immagine.toByteData(format: ui.ImageByteFormat.rawRgba);
    return dati!.buffer.asUint8List();
  }

  testWidgets(
      'REGOLA I: nelle prime tre discese la testa non e mai nitida, e alla '
      'quarta lo diventa, per tutti e dodici e con le animazioni spente',
      (tester) async {
    debugSemanticsDisableAnimations = true;
    addTearDown(() => debugSemanticsDisableAnimations = null);
    await tester.binding.setSurfaceSize(scena);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // **IL CARDINALE MINIMO.**
    expect(AnimalCatalog.animals.length, 12);
    expect(DoveStaLaTesta.quantiSono, 12);

    final rapporti = <String, double>{};
    var quanti = 0;
    await tester.runAsync(() async {
      for (final animale in AnimalCatalog.animals) {
        final sorgente = await misuraDi(animale.fullPath);
        final immagine = dentroLaScena(sorgente);
        final testa = DoveStaLaTesta.di(animale.name)!;
        final testaInPunti = Rect.fromLTRB(
          immagine.left + immagine.width * testa.left,
          immagine.top + immagine.height * testa.top,
          immagine.left + immagine.width * testa.right,
          immagine.top + immagine.height * testa.bottom,
        );

        // **IL METRO DI QUESTO ANIMALE: la sua testa alla quarta discesa**,
        // cioe' col velo caduto. Ogni animale porta il proprio, e cosi' la
        // prova non ha dentro nessun numero assoluto.
        final scoperta = quantoENitido(
            await fotogramma(tester, animale, 3, const Offset(0.5, 0.5)),
            scena.width.toInt(),
            testaInPunti);
        expect(scoperta, greaterThan(5),
            reason: '${animale.name}: alla quarta discesa la testa non e '
                'nitida nemmeno col velo caduto, e allora questa prova non '
                'starebbe misurando niente');

        for (var discesa = 0; discesa < 3; discesa++) {
          for (final parte in partenze) {
            final velata = quantoENitido(
                await fotogramma(tester, animale, discesa, parte),
                scena.width.toInt(),
                testaInPunti);
            quanti++;
            final rapporto = velata / scoperta;
            final dove = '${animale.name} d$discesa da $parte';
            if (rapporto > (rapporti[animale.name] ?? 0)) {
              rapporti[animale.name] = rapporto;
            }
            expect(rapporto, lessThan(0.4),
                reason: 'la testa di $dove e nitida quanto quella scoperta '
                    '(${velata.toStringAsFixed(2)} contro '
                    '${scoperta.toStringAsFixed(2)}): il velo non sta '
                    'coprendo, ed e esattamente cio che si e visto sul '
                    'telefono l 11 settembre 2026');
          }
        }
      }
    });

    final peggiore = rapporti.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    // ignore: avoid_print
    print('ORDINE DE VOCE 03, LA NITIDEZZA DELLA TESTA: $quanti fotogrammi, '
        'il rapporto peggiore fra velata e scoperta e '
        '${peggiore.value.toStringAsFixed(3)} (${peggiore.key}); '
        'zero vorrebbe dire coperta del tutto, uno vorrebbe dire scoperta');
  });
}

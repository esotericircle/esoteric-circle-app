import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/features/maestri/widgets/maestro_bust.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Il volto del Maestro che rompe il cerchio: dipinge l'immagine dell'avatar, e
/// mostra l'icona lineare solo quando l'immagine fallisce davvero, mai come
/// fondale mentre il volto c'e'.
///
/// MaestroBust ricava la palette dal proprio Maestro, quindi non serve il
/// MaestroScope: basta il QualityTierController che governa il fermo su Tier
/// basso.
void main() {
  Widget host(Widget child, {bool reduceMotion = false}) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => QualityTierController()),
        ],
        child: MaterialApp(
          builder: (ctx, mqChild) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: reduceMotion),
            child: mqChild!,
          ),
          home: Scaffold(body: Center(child: child)),
        ),
      );

  testWidgets('Dipinge davvero l\'immagine dell\'avatar, senza icona',
      (tester) async {
    await tester.pumpWidget(host(const MaestroBust(maestro: Maestro.medora)));
    // Decodifica l'asset reale, come fa la schermata col precache.
    await tester.runAsync(() async {
      await precacheImage(
        AssetImage(Maestro.medora.avatarAsset),
        tester.element(find.byType(MaestroBust)),
      );
    });
    await tester.pump();
    await tester.pump();

    // Il volto e' in scena: un'immagine con la sorgente dell'avatar, e la sua
    // RawImage porta un'immagine decodificata (dipinge davvero, non e' vuota).
    final immagini = tester.widgetList<Image>(find.byType(Image));
    expect(
      immagini
          .any((i) => i.image == AssetImage(Maestro.medora.avatarAsset)),
      isTrue,
    );
    final raw = tester.widgetList<RawImage>(find.byType(RawImage));
    expect(raw.any((r) => r.image != null), isTrue,
        reason: 'L\'immagine dell\'avatar deve essere dipinta, non solo il ripiego.');

    // Nessuna icona di ripiego mentre il volto c'e'.
    expect(find.byKey(const Key('maestro_bust_icon_medora')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Default: la sorgente e\' l\'avatar del Maestro', (tester) async {
    await tester.pumpWidget(host(const MaestroBust(maestro: Maestro.aura)));
    await tester.pump();
    final immagini = tester.widgetList<Image>(find.byType(Image));
    expect(
      immagini.any((i) => i.image == AssetImage(Maestro.aura.avatarAsset)),
      isTrue,
    );
  });

  testWidgets('Se l\'immagine fallisce, cade sull\'icona lineare del Maestro',
      (tester) async {
    await tester.pumpWidget(host(
      const MaestroBust(maestro: Maestro.caligo, image: _FailingImage()),
    ));
    // Il fallimento arriva sull'ImageStream: qualche pump per processarlo.
    await tester.pump();
    await tester.pump();
    await tester.pump();

    final iconFinder = find.byKey(const Key('maestro_bust_icon_caligo'));
    expect(iconFinder, findsOneWidget);
    expect(tester.widget<Icon>(iconFinder).icon, Maestro.caligo.icon);
    // Col ripiego attivo non resta in scena un'immagine del volto.
    expect(find.byType(Image), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Riduci Movimento: presenza statica anche parlando',
      (tester) async {
    await tester.pumpWidget(host(
      const MaestroBust(maestro: Maestro.medora, speaking: true),
      reduceMotion: true,
    ));
    await tester.pump();
    // Con Riduci Movimento, anche col cenno di speaking, nessun frame in coda:
    // l'aura non pulsa.
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  test('L\'inquadratura del volto e\' la stessa in proporzione a ogni misura',
      () {
    const sizes = [34.0, 44.0, 80.0];
    for (final maestro in Maestro.values) {
      for (final popOut in const [true, false]) {
        final f = [
          for (final r in sizes)
            MaestroBust.framingFor(maestro: maestro, ring: r, popOut: popOut),
        ];

        // La fascia dal capo al collo riempie l'80 per cento del diametro, a
        // ogni misura: mai i soli occhi, mai la figura intera.
        for (var i = 0; i < sizes.length; i++) {
          expect(f[i].bandBottom - f[i].bandTop, closeTo(0.8 * sizes[i], 1e-9),
              reason: 'banda 80% del diametro per $maestro a ${sizes[i]}');
        }

        // Stesso taglio in proporzione: ogni misura assoluta scala col diametro,
        // quindi il rapporto valore su diametro e' costante fra le misure. La
        // correzione orizzontale e' gia' una frazione, quindi identica.
        for (var i = 1; i < sizes.length; i++) {
          expect(f[i].imageHeight / sizes[i],
              closeTo(f[0].imageHeight / sizes[0], 1e-9));
          expect(f[i].verticalOffset / sizes[i],
              closeTo(f[0].verticalOffset / sizes[0], 1e-9));
          expect(
              f[i].bandTop / sizes[i], closeTo(f[0].bandTop / sizes[0], 1e-9));
          expect(f[i].bandBottom / sizes[i],
              closeTo(f[0].bandBottom / sizes[0], 1e-9));
          expect(f[i].boxHeight / sizes[i],
              closeTo(f[0].boxHeight / sizes[0], 1e-9));
          expect(f[i].faceDx, closeTo(f[0].faceDx, 1e-12));
        }
      }
    }
  });

  testWidgets('Disegna i tre Maestri a tre misure senza errori', (tester) async {
    for (final maestro in Maestro.values) {
      for (final ring in const [34.0, 44.0, 80.0]) {
        await tester.pumpWidget(host(MaestroBust(maestro: maestro, ring: ring)));
        await tester.runAsync(() async {
          await precacheImage(
            AssetImage(maestro.avatarAsset),
            tester.element(find.byType(MaestroBust)),
          );
        });
        await tester.pump();
        await tester.pump();
        expect(find.byType(Image), findsOneWidget);
        expect(find.byKey(Key('maestro_bust_icon_${maestro.id}')), findsNothing);
        expect(tester.takeException(), isNull);
      }
    }
  });
}

/// Provider d'immagine che fallisce sempre, per esercitare il ripiego. Non tocca
/// la rete ne' il disco: solleva subito, cosi' l'ImageStream porta un errore.
class _FailingImage extends ImageProvider<_FailingImage> {
  const _FailingImage();

  @override
  Future<_FailingImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<_FailingImage>(this);

  @override
  ImageStreamCompleter loadImage(
      _FailingImage key, ImageDecoderCallback decode) {
    return OneFrameImageStreamCompleter(
      Future<ImageInfo>.error(
        StateError('immagine mancante, di proposito nel test'),
      ),
    );
  }

  @override
  bool operator ==(Object other) => other is _FailingImage;

  @override
  int get hashCode => 0;
}

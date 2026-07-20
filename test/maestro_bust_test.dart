import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/features/maestri/widgets/maestro_bust.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Il mezzo busto che sfonda il cerchio nelle conversazioni dei Maestri: disegna
/// l'asset dell'avatar, e cade sull'icona lineare solo quando l'immagine manca.
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

  testWidgets('Disegna l\'asset dell\'avatar del Maestro', (tester) async {
    await tester.pumpWidget(host(const MaestroBust(maestro: Maestro.medora)));
    await tester.pump();

    // C'e' un'immagine, e la sua sorgente e' l'avatar del Maestro.
    final immagini = tester.widgetList<Image>(find.byType(Image));
    expect(immagini, isNotEmpty);
    expect(
      immagini
          .any((i) => i.image == AssetImage(Maestro.medora.avatarAsset)),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Se l\'immagine manca, cade sull\'icona lineare del Maestro',
      (tester) async {
    await tester.pumpWidget(host(
      const MaestroBust(maestro: Maestro.caligo, image: _FailingImage()),
    ));
    // L'errorBuilder scatta e mostra il vuoto al posto del busto: resta a vista
    // l'icona dietro l'anello.
    await tester.pump();
    await tester.pump();

    final iconFinder = find.byKey(const Key('maestro_bust_icon_caligo'));
    expect(iconFinder, findsOneWidget);
    expect(tester.widget<Icon>(iconFinder).icon, Maestro.caligo.icon);
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
}

/// Provider d'immagine che fallisce sempre, per esercitare il ripiego. Non tocca
/// la rete ne' il disco: solleva subito, cosi' l'errorBuilder scatta.
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

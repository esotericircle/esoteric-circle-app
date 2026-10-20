import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/le_quattro_impronte.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL CAMMINO NON RIVELA L'ANIMALE PRIMA DEL TEMPO.** Il fondatore, 20
/// ottobre 2026, davanti alla soglia del Viaggio alla terza discesa col
/// Cavallo: *"in alto usi la silhouette proprio del cavallo, ma cosi' stai
/// rivelando all'utente in anticipo che si tratta del cavallo. Secondo me
/// dovresti usare l'ombra che l'utente ha scelto"*.
///
/// **Il fatto**: ogni impronta del cammino in alto era la sagoma dorata e
/// nitida dell'animale seguito, presa dal canale alpha della sua
/// illustrazione: tre cavalli d'oro dicevano il nome prima della quarta
/// discesa. Padre: ordine DE voce 09 (*"le impronte sono quelle del suo
/// animale ... e si ricavano dalla stessa immagine"*), scritto quando il
/// Viaggio aveva una sola ombra possibile.
///
/// **Cosa misura**: per tutti e dodici gli animali, prima del riconoscimento
/// ogni impronta lasciata e' l'ombra scura che la persona ha scelto fra le
/// nove (`ani_ombra_*`), e nel cammino non c'e' nessuna immagine
/// dell'animale; dopo, l'impronta d'arrivo puo' essere l'animale.
void main() {
  Future<void> monta(
      WidgetTester tester, List<String> seguiti, bool riconosciuto) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 360,
          child:
              LeQuattroImpronte(seguiti: seguiti, riconosciuto: riconosciuto),
        ),
      ),
    ));
    await tester.pump();
  }

  /// I percorsi delle immagini dentro il cammino.
  Set<String> immaginiNelCammino(WidgetTester tester) => {
        for (final e in find
            .descendant(
                of: find.byType(LeQuattroImpronte),
                matching: find.byType(Image))
            .evaluate())
          if ((e.widget as Image).image is AssetImage)
            ((e.widget as Image).image as AssetImage).assetName,
      };

  testWidgets(
      'PRIMA DEL RICONOSCIMENTO LE IMPRONTE SONO OMBRE, per tutti e dodici: '
      'nessuna immagine dell\'animale nel cammino', (tester) async {
    var guardate = 0;
    for (final animale in AnimalCatalog.animals) {
      await monta(tester, List.filled(3, animale.name), false);
      for (var i = 0; i < 3; i++) {
        expect(find.byKey(Key('viaggio_impronta_ombra_$i')), findsOneWidget,
            reason: '${animale.name}: l\'impronta $i non e\' un\'ombra');
        expect(find.byKey(Key('viaggio_impronta_$i')), findsNothing,
            reason: '${animale.name}: l\'impronta $i e\' la sagoma nitida, '
                'che dice chi e\' prima della quarta');
        guardate++;
      }
      final immagini = immaginiNelCammino(tester);
      expect(immagini, isNot(contains(animale.fullPath)),
          reason: '${animale.name}: nel cammino c\'e\' la sua immagine '
              '${animale.fullPath}');
      expect(immagini, contains(animale.ombraPath),
          reason: '${animale.name}: nel cammino non c\'e\' la sua ombra');
    }
    // **IL CARDINALE**: dodici animali, tre impronte ciascuno.
    expect(guardate, 36);
  });

  testWidgets('DOPO IL RICONOSCIMENTO L\'ARRIVO PUO\' ESSERE L\'ANIMALE',
      (tester) async {
    await monta(tester, List.filled(4, 'Cavallo'), true);
    expect(find.byKey(const Key('viaggio_impronta_3')), findsOneWidget);
  });
}

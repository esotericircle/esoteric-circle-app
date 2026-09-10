import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// **NUMERO E COLORE HANNO LA STESSA ALTEZZA.** Ordine DD voce 09,
/// 10 settembre 2026.
///
/// **Il fatto del fondatore**: nella scheda della Fortuna i due riquadri,
/// *Numero* e *Colore del giorno*, non sono alti uguale, e la coppia si vede
/// storta.
///
/// **La causa.** Le due bolle stanno in una `Row` che non allinea niente:
/// ognuna prende l'altezza del suo contenuto. Il numero e' una cifra in una
/// riga, il colore e' un'etichetta piu' lunga con un pallino accanto, e le due
/// colonne finiscono diverse.
///
/// **IL ROSSO E STATO IL DIFETTO VERO, senza bisogno di innestarne uno**: la
/// bolla NUMERO alta **61,0** punti, quella COLORE DEL GIORNO **84,0**, cioe
/// **ventitre punti di scarto**. Con la cura sono **84,0 e 84,0**.
///
/// **QUESTA GUARDIA MISURA LE DUE ALTEZZE A SCHERMO**, con `getRect` sulla
/// finestra del telefono, dopo aver chiesto il responso: prima del responso la
/// scheda non esiste, e una prova che guardasse la schermata muta sarebbe
/// verde per non aver trovato niente da confrontare.
void main() {
  testWidgets('LE DUE BOLLE DELLA FORTUNA SONO ALTE UGUALE', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
      ],
      child: MaterialApp(
        // **RIDUCI MOVIMENTO ACCESO, e non e una scorciatoia.** E la
        // configurazione del telefono di collaudo 767f596c, che ha le tre
        // scale di animazione a zero: le quattro schede nascono tutte
        // insieme, gia intere, invece di comporsi a cascata. E' lo stato in
        // cui il fondatore guarda questa scheda.
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home:
            OroscopoScreen(userSign: Zodiac.leo, now: DateTime(2026, 7, 10)),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 5));

    // **LE SCHEDE NASCONO IN UN ELENCO PIGRO**: la Fortuna e la quarta, e
    // finche nessuno scorre fin li non viene costruita affatto. Una prova che
    // non scorresse direbbe che le due bolle non ci sono, che e vero e non e
    // il difetto.
    final numero = find.text('NUMERO');
    // Le scorrevoli a schermo sono piu di una, e le file di pasticche in
    // cima sono orizzontali: si scorre quella della pagina, cioe la prima.
    await tester.dragUntilVisible(
        numero, find.byType(Scrollable).first, const Offset(0, -300));
    await tester.pump(const Duration(milliseconds: 600));
    final colore = find.text('COLORE DEL GIORNO');
    expect(numero, findsOneWidget,
        reason: 'la bolla del numero non e a schermo: senza di lei questa '
            'prova non confronta niente');
    expect(colore, findsOneWidget,
        reason: 'la bolla del colore non e a schermo: senza di lei questa '
            'prova non confronta niente');

    // Si misura la BOLLA, non l etichetta: il riquadro che si vede e il
    // Container attorno, e l altezza di quello e cio che il fondatore guarda.
    double altezzaDellaBolla(Finder etichetta) {
      final bolla = find.ancestor(
        of: etichetta,
        matching: find.byType(Container),
      );
      return tester.getRect(bolla.first).height;
    }

    final alta1 = altezzaDellaBolla(numero);
    final alta2 = altezzaDellaBolla(colore);
    final scarto = (alta1 - alta2).abs();
    // ignore: avoid_print
    print('ORDINE DD VOCE 09: la bolla NUMERO e alta '
        '${alta1.toStringAsFixed(1)}, la bolla COLORE DEL GIORNO e alta '
        '${alta2.toStringAsFixed(1)}, scarto ${scarto.toStringAsFixed(1)} '
        'punti');
    expect(scarto, lessThan(0.5),
        reason: 'le due bolle della Fortuna sono alte '
            '${alta1.toStringAsFixed(1)} e ${alta2.toStringAsFixed(1)}, cioe '
            'uno scarto di ${scarto.toStringAsFixed(1)} punti: la coppia si '
            'vede storta');
  });
}

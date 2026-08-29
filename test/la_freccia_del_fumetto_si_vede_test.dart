import 'dart:io';
import 'dart:math' as math;

import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/onboarding/primo_approdo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA FRECCIA DEL FUMETTO SI VEDE. Ordine CC voce 02.
///
/// **Rilievo del fondatore, 29 agosto 2026, verbatim:** "la freccia delle bolle
/// sono poco visibili".
///
/// **LA GRANDEZZA CHE DESCRIVE LA VISIBILITA', dichiarata: il rapporto di
/// contrasto fra il colore della freccia e cio' che le sta dietro.** Non e' un
/// numero inventato per l'occasione: e' la misura che le linee guida di
/// accessibilita' usano per gli oggetti grafici che servono a capire una
/// scena, e la soglia dichiarata e' **3,0 a 1**, la stessa che quelle linee
/// guida pretendono per un oggetto non testuale.
///
/// **Perche' il contrasto e non l'area.** Una freccia grande e scura resta
/// invisibile; una freccia piccola e chiara si vede. Il difetto misurato era
/// esattamente questo: il triangolo era dipinto col colore della CARTA, un
/// viola scuro, sopra un velo quasi nero. Due scuri uno sull'altro.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// La luminanza relativa di un colore, come la definiscono le linee guida.
  double luminanza(Color c) {
    double canale(double v) =>
        v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * canale(c.r) + 0.7152 * canale(c.g) + 0.0722 * canale(c.b);
  }

  /// Il rapporto di contrasto fra due colori, da 1 a 21.
  double contrasto(Color a, Color b) {
    final la = luminanza(a);
    final lb = luminanza(b);
    final alto = math.max(la, lb);
    final basso = math.min(la, lb);
    return (alto + 0.05) / (basso + 0.05);
  }

  /// La soglia dichiarata, e non si tocca: se il rosso non scatta si cambia la
  /// grandezza misurata, mai questo numero.
  const soglia = 3.0;

  test('la freccia batte la soglia su tutte e tre le palette', () {
    // Il velo del tutorial e' il colore piu' profondo della palette all'86 per
    // cento sopra la scena: nel punto peggiore, cioe' sopra il nero, e' quel
    // colore stesso.
    final misure = <String, double>{};
    for (final p in <String, MaestroPalette>{
      'Medora': MaestroPalette.medora,
      'Aura': MaestroPalette.aura,
      'Caligo': MaestroPalette.caligo,
    }.entries) {
      misure[p.key] = contrasto(p.value.gold, p.value.deepest);
    }
    // ignore: avoid_print
    print('ORDINE CC VOCE 02: contrasto della freccia sul velo '
        '${misure.entries.map((e) => "${e.key} ${e.value.toStringAsFixed(2)}").join(", ")}');
    for (final m in misure.entries) {
      expect(m.value, greaterThanOrEqualTo(soglia),
          reason: 'sulla palette ${m.key} la freccia sta a '
              '${m.value.toStringAsFixed(2)} contro una soglia di $soglia');
    }
  });

  test('il colore vecchio non batteva la soglia, ed e\' la prova del prima',
      () {
    // **IL NUMERO PRIMA.** La freccia era dipinta con `palette.surface`. Se
    // qualcuno ci tornasse, questa riga dice quanto valeva.
    final prima = contrasto(MaestroPalette.medora.surface,
        MaestroPalette.medora.deepest);
    final dopo =
        contrasto(MaestroPalette.medora.gold, MaestroPalette.medora.deepest);
    // ignore: avoid_print
    print('ORDINE CC VOCE 02: Medora, prima ${prima.toStringAsFixed(2)}, '
        'dopo ${dopo.toStringAsFixed(2)}, soglia $soglia');
    expect(prima, lessThan(soglia),
        reason: 'il colore vecchio batteva gia\' la soglia: allora la '
            'grandezza misurata non descrive il difetto che il fondatore ha '
            'visto, e va cambiata la grandezza, non la soglia');
    expect(dopo, greaterThan(prima * 2),
        reason: 'la cura non ha nemmeno raddoppiato il contrasto');
  });

  test('il codice dipinge la freccia col colore dichiarato', () {
    // La misura sopra vale solo se il codice usa davvero quei colori: qui si
    // legge la sorgente, cosi' nessuno puo' rimettere il viola lasciando
    // verde una prova che calcola numeri per conto suo.
    final sorgente =
        File('lib/features/onboarding/primo_approdo.dart').readAsStringSync();
    expect(sorgente.contains('colore: palette.gold'), isTrue,
        reason: 'la freccia non e\' piu\' dipinta in oro pieno');
    expect(sorgente.contains('colore: palette.surface'), isFalse,
        reason: 'la freccia e\' tornata del colore della carta, che sul velo '
            'non si vede');
  });

  testWidgets('la freccia e\' cresciuta, e resta attaccata al fumetto',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        {MemoriaDelPrimoApprodo.chiaveArmata: true});
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 797);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(
      home: PrimoApprodo(
        child: Scaffold(
          body: Center(
            child: AncoraDelPrimoApprodo(
              nome: BersagliDelPrimoApprodo.trio,
              child: SizedBox(width: 200, height: 60),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('primo_approdo_avanti')));
    await tester.pumpAndSettle();
    final freccia = find.byType(CustomPaint).evaluate().length;
    // ignore: avoid_print
    print('ORDINE CC VOCE 02: superfici dipinte nella scena $freccia');
    expect(freccia, greaterThan(1),
        reason: 'la freccia non viene piu\' dipinta');
  });
}

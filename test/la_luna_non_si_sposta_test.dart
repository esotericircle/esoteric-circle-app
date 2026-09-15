import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA LUNA STA FERMA PRIMA E DOPO.** Ordine DD voce 06, 10 settembre 2026.
///
/// **Il fatto del fondatore**: *"nella home la Luna si sposta verso destra
/// nell'istante in cui spariscono l'animazione del dito e il testo tocca
/// qui"*.
///
/// **NON E' LA LUNA CHE SI MUOVE, E' LA RIGA CHE SI STRINGE.** La riga del
/// cielo e' fatta di tre celle centrate: un vuoto largo quanto l'invito, la
/// Luna, e l'invito. Con l'invito acceso le due celle laterali si pareggiano
/// e la Luna cade a meta' schermo. Quando l'invito spariva del tutto, il
/// vuoto di sinistra restava e la riga si ricentrava su una larghezza minore.
///
/// **Questa guardia misura lo spostamento in punti**, montando la stessa riga
/// nei due stati e confrontando il centro della Luna. Non guarda il codice
/// dell'invito: guarda dove finisce la Luna.
void main() {
  const lato = 60.0;

  /// La riga del cielo, com'e' composta nel Santuario: vuoto, Luna, invito.
  Widget riga({required bool invitoAcceso}) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 390,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: SkyTapHint.larghezza),
                  Container(
                    key: const Key('la_luna'),
                    width: lato,
                    height: lato,
                    color: const Color(0xFFCCCCCC),
                  ),
                  IgnorePointer(
                    child: SkyTapHint(
                      visible: invitoAcceso,
                      pulse: const AlwaysStoppedAnimation<double>(0),
                      reduceMotion: true,
                      color: const Color(0xFFD9B98A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Future<double> centroDellaLuna(WidgetTester tester,
      {required bool invitoAcceso}) async {
    await tester.pumpWidget(riga(invitoAcceso: invitoAcceso));
    await tester.pump(const Duration(milliseconds: 600));
    return tester.getCenter(find.byKey(const Key('la_luna'))).dx;
  }

  testWidgets('LA LUNA CADE NELLO STESSO PUNTO COL SUGGERIMENTO E SENZA',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final conInvito = await centroDellaLuna(tester, invitoAcceso: true);
    final senzaInvito = await centroDellaLuna(tester, invitoAcceso: false);
    final spostamento = (senzaInvito - conInvito).abs();
    // ignore: avoid_print
    print('ORDINE DD VOCE 06: la Luna cade a '
        '${conInvito.toStringAsFixed(1)} col suggerimento e a '
        '${senzaInvito.toStringAsFixed(1)} senza, cioe uno spostamento di '
        '${spostamento.toStringAsFixed(1)} punti');
    expect(spostamento, lessThan(1.0),
        reason: 'la Luna si sposta di ${spostamento.toStringAsFixed(1)} punti '
            'quando il suggerimento sparisce: e un salto di composizione, e '
            'chi guarda lo vede come un sussulto');
  });

  testWidgets('IL SUGGERIMENTO OCCUPA LA SUA LARGHEZZA ANCHE DA SPENTO',
      (tester) async {
    // **REGOLA H: si prova la presenza e l'assenza.** Che la Luna non si
    // sposti e' l'esito; che la cella tenga la larghezza e' la causa, e se un
    // giorno qualcuno rimettesse `AnimatedSize` la prima riga cadrebbe senza
    // dire perche'.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    for (final acceso in [true, false]) {
      await tester.pumpWidget(riga(invitoAcceso: acceso));
      await tester.pump(const Duration(milliseconds: 600));
      final larga = tester.getSize(find.byType(SkyTapHint)).width;
      // ignore: avoid_print
      print('ORDINE DD VOCE 06: col suggerimento '
          '${acceso ? "acceso" : "spento"} la cella e larga '
          '${larga.toStringAsFixed(1)}');
      expect(larga, SkyTapHint.larghezza,
          reason: 'la cella del suggerimento cambia larghezza fra acceso e '
              'spento: e da li che nasce il salto della Luna');
    }
  });
}

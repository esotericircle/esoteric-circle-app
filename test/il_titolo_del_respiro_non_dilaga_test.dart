import 'package:esoteric_circle/core/rituals/tempi_del_respiro.dart';
import 'package:esoteric_circle/design_system/components/guida_del_respiro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA PILLOLA DEL RESPIRO NON DILAGA SULLO SCHERMO.
///
/// Ordine 2168, voce 3. A decidere la larghezza della pillola e' la parola
/// piu' lunga che ci passa dentro, e quella parola e' "Preparati a
/// respirare": dipinta a ventisei punti, la pillola arrivava a occupare
/// quasi tutta la larghezza del telefono.
///
/// **La misura si prende sul RIQUADRO RESO, non sul carattere.** Cambiare la
/// dimensione del testo e guardare il numero nel codice non dice niente su
/// cosa si vede: qui si monta la guida a 360 punti logici, che e' la misura
/// del telefono del fondatore, e si misura il rettangolo vero della pillola.
///
/// **La regola vale per tutti e tre i riti**, perche' il componente e' uno
/// solo: Soffio, Meditazione e Sigillo del Sogno. Un caso speciale per il
/// Soffio sarebbe un'altra regola messa su una porta sola.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Quanto puo' occupare la pillola, in frazione della larghezza. Oltre
  /// questa quota la parola sola comanda la scena e il mandala le sta
  /// dietro invece che sopra.
  const quotaMassima = 0.72;

  Widget attorno({double larghezza = 360}) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(larghezza, 800),
            disableAnimations: true,
          ),
          child: const Scaffold(
            backgroundColor: Color(0xFFBFD5B2),
            body: Center(
              child: GuidaDelRespiro(
                tempi: TempiDelRespiro(tempi: 4, giri: 3),
                colore: Color(0xFFD8C89B),
              ),
            ),
          ),
        ),
      );

  testWidgets('a 360 punti la pillola resta dentro la quota dichiarata',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(attorno());
    await tester.pump();

    // La parola di apertura e' quella che comanda: e' la piu' lunga.
    expect(find.text(ParoleDelRespiro.preparati), findsOneWidget);
    final velo = tester.getRect(find.byKey(const Key('respiro_velo')));
    final quota = velo.width / 360;
    // ignore: avoid_print
    print('RESPIRO: la pillola e\' larga ${velo.width.toStringAsFixed(1)} '
        'punti su 360, cioe\' il ${(quota * 100).toStringAsFixed(1)} per '
        'cento (massimo ${(quotaMassima * 100).toStringAsFixed(0)})');
    expect(quota, lessThanOrEqualTo(quotaMassima),
        reason: 'La pillola occupa il ${(quota * 100).toStringAsFixed(1)} per '
            'cento della larghezza: la parola sola comanda la scena.');
  });

  testWidgets('la parola resta intera: non si stringe tagliandola',
      (tester) async {
    // **IL PRESIDIO CONTRO LA CORREZIONE SBAGLIATA.** Si potrebbe stringere
    // la pillola lasciando che la parola vada a capo o si tronchi coi
    // puntini: sarebbe stretta e illeggibile. La parola deve stare su una
    // riga sola e intera.
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(attorno());
    await tester.pump();

    final testo = find.text(ParoleDelRespiro.preparati);
    final r = tester.getRect(testo);
    final widget = tester.widget<Text>(testo);
    expect(widget.data, ParoleDelRespiro.preparati,
        reason: 'La parola e\' stata cambiata invece che rimpicciolita.');
    // Una riga sola: l'altezza resta quella di una riga del suo stile.
    final stile = widget.style!;
    final unaRiga = (stile.fontSize ?? 26) * 1.6;
    // ignore: avoid_print
    print('RESPIRO: il titolo e\' alto ${r.height.toStringAsFixed(1)} punti, '
        'una riga ne vale al piu\' ${unaRiga.toStringAsFixed(1)}');
    expect(r.height, lessThanOrEqualTo(unaRiga),
        reason: 'Il titolo e\' andato a capo: stretto cosi\' non si legge '
            'piu\' come un titolo.');
  });
}

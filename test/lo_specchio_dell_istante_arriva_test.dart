import 'package:esoteric_circle/core/face/espressione_dell_istante.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/maestri/aura/face/lo_specchio_dell_istante.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart';

/// **L'ESPRESSIONE ARRIVA A CHI LEGGE, E NON DIAGNOSTICA.** Ordine CR voce 07,
/// 6 settembre 2026.
///
/// **COSA HO MISURATO PRIMA.** `lib/core/face/espressione_dell_istante.dart`
/// esisteva con le sue guardie, e il conto e' stato fatto sul filesystem:
/// **zero file di `lib` lo chiamavano**. Era codice che nessuna persona poteva
/// raggiungere aprendo l'app, cioe' prodotto e non agganciato, e una guardia
/// che avesse interrogato il solo modulo sarebbe stata verde su una funzione
/// invisibile.
///
/// **PERCHE' LE PRETESE STANNO SUL WIDGET E NON SULLA SCHERMATA INTERA.** Il
/// riquadro compare soltanto quando i coefficienti arrivano da una fotocamera
/// viva, e in prova la fotocamera non esiste: il percorso deterministico della
/// schermata passa dal ripiego tattile, dove i coefficienti sono vuoti e il
/// riquadro giustamente non c'e'. Quello che si prova qui e' il riquadro; che
/// la schermata glieli passi lo tiene fermo il compilatore, perche' il valore
/// risale per parametri e non per un canale laterale. **Che si veda davvero su
/// un volto vero resta da verificare a video su un telefono**, ed e' scritto
/// nel referto invece di essere dato per fatto.
void main() {
  final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.aura));

  Widget host(Map<FaceBlendshape, double> c) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: LoSpecchioDellIstante(coefficienti: c, palette: palette),
          ),
        ),
      );

  /// Un volto che alza nettamente le sopracciglia, e nient'altro.
  Map<FaceBlendshape, double> sopraccigliaAlte() => {
        FaceBlendshape.browInnerUp: 0.9,
        FaceBlendshape.browOuterUpLeft: 0.85,
        FaceBlendshape.browOuterUpRight: 0.85,
      };

  testWidgets('senza coefficienti il riquadro non esiste', (tester) async {
    await tester.pumpWidget(host(const {}));
    await tester.pump();
    expect(find.byKey(const Key('face_espressione')), findsNothing,
        reason: 'senza niente da leggere il riquadro inventa comunque '
            'un\'osservazione, ed e\' la bugia del muro in un altro punto');
  });

  testWidgets('un volto a riposo non produce nessuna osservazione',
      (tester) async {
    // Tutti i coefficienti sotto la soglia: un viso fermo.
    final riposo = {
      for (final b in FaceBlendshape.values) b: 0.05,
    };
    await tester.pumpWidget(host(riposo));
    await tester.pump();
    expect(find.byKey(const Key('face_espressione')), findsNothing,
        reason: 'un volto a riposo riceve un\'osservazione: allora la soglia '
            'non filtra niente e il riquadro parla sempre');
  });

  testWidgets('un gesto netto arriva a video con osservazione e specchio',
      (tester) async {
    await tester.pumpWidget(host(sopraccigliaAlte()));
    await tester.pump();

    expect(find.byKey(const Key('face_espressione')), findsOneWidget,
        reason: 'il gesto e\' netto e il riquadro non compare: la lettura '
            'dell\'istante non raggiunge nessuno');

    const atteso = SegnoDelVolto.sopraccigliaAlte;
    expect(find.text(atteso.osservazione), findsOneWidget,
        reason: 'il riquadro non dice cosa il volto sta facendo');
    expect(find.text(atteso.specchio), findsOneWidget,
        reason: 'il riquadro non restituisce la lettura nella voce di Aura');
  });

  testWidgets('la durata della lettura e\' dichiarata a video', (tester) async {
    await tester.pumpWidget(host(sopraccigliaAlte()));
    await tester.pump();

    // **SI CERCA IL FATTO, non una frase esatta.** Pretendere la stringa
    // intera farebbe cadere questa guardia il giorno che si migliora una
    // parola, che e' il difetto della guardia legata al token.
    final adesso = find.textContaining('adesso');
    final nonComeSei = find.textContaining('non parla di come');
    expect(adesso, findsWidgets,
        reason: 'il riquadro non dichiara che vale ADESSO: chi legge porta '
            'via l\'osservazione come se fosse un tratto permanente');
    expect(nonComeSei, findsWidgets,
        reason: 'il riquadro non distingue l\'istante dai tratti');
  });

  test('nessuna frase dell\'espressione diagnostica niente', () {
    // **LE PAROLE VIETATE DALL'ORDINE**, voce 11: mai diagnosi, disturbo,
    // patologia, ne' nomi di condizioni. E si aggiungono le etichette
    // emotive, perche' la voce 07 vieta anche quelle: il motore misura
    // muscoli, non stati d'animo.
    const vietate = [
      'diagnosi',
      'disturbo',
      'patologia',
      'depress',
      'ansios',
      'ansia',
      'sei triste',
      'sei felice',
      'sei arrabbiat',
      'sei preoccupat',
      'sei stanc',
    ];
    for (final s in SegnoDelVolto.values) {
      final testo = '${s.osservazione} ${s.specchio}'.toLowerCase();
      for (final v in vietate) {
        expect(testo.contains(v), isFalse,
            reason: 'il segno ${s.name} contiene «$v»: e\' un verdetto, non '
                'uno specchio. Testo: «$testo»');
      }
    }
  });
}

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/core/chat/immersive_intents.dart';
import 'package:esoteric_circle/features/maestri/maestro_screen.dart';
import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Ogni bolla della striscia porta il colore del Maestro a cui l'arte
/// appartiene.
///
/// Prima erano tutte uguali, nel viola condiviso del cerchio: la striscia
/// diceva a parole di chi era ogni arte, con una scritta piccola sotto il
/// nome, ma non lo mostrava. Il colpo d'occhio visivo viene prima del testo,
/// quindi il proprietario si deve riconoscere senza leggere.
void main() {
  /// Il colore di fondo dominante di una bolla.
  Color fondoDi(WidgetTester tester, String chiave) {
    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byKey(Key(chiave)),
            matching: find.byType(Container),
          )
          .first,
    );
    final d = container.decoration! as BoxDecoration;
    return (d.gradient! as LinearGradient).colors.first;
  }

  Future<void> montaStriscia(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1200, 600);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MaestroController())],
      child: MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              for (final m in Maestro.values)
                CircleArtTile(
                  key: Key('bolla_${m.name}'),
                  // La palette passata e' quella neutra condivisa: se la bolla
                  // seguisse solo questa, le tre uscirebbero identiche.
                  palette: MaestroPalette.neutral,
                  // La tessera prende l'arte dal CATALOGO e il Maestro a
                  // parte: la lista scritta a mano che li teneva insieme era
                  // una seconda fonte di verita' gia' divergente.
                  maestro: m,
                  art: const ArtEntry(
                    id: 'horoscope',
                    title: 'Prova',
                    teaser: 'Prova',
                    icon: Icons.circle,
                    state: ArtState.attiva,
                  ),
                ),
            ],
          ),
        ),
      ),
    ));
    await tester.pump();
  }

  testWidgets('Le bolle di tre Maestri hanno tre colori diversi',
      (tester) async {
    await montaStriscia(tester);

    final colori = {
      for (final m in Maestro.values) m: fondoDi(tester, 'bolla_${m.name}'),
    };

    expect(colori[Maestro.medora], isNot(colori[Maestro.aura]),
        reason: 'la bolla di Medora e quella di Aura hanno lo stesso colore: '
            'il proprietario non si riconosce a colpo d\'occhio');
    expect(colori[Maestro.aura], isNot(colori[Maestro.caligo]),
        reason: 'la bolla di Aura e quella di Caligo hanno lo stesso colore');
    expect(colori[Maestro.medora], isNot(colori[Maestro.caligo]),
        reason: 'la bolla di Medora e quella di Caligo hanno lo stesso colore');
  });

  testWidgets('Il colore di ogni bolla e\' quello del suo Maestro',
      (tester) async {
    await montaStriscia(tester);

    for (final proprietario in Maestro.values) {
      final visto = fondoDi(tester, 'bolla_${proprietario.name}');
      // Il fondo e' il colore del Maestro velato sul viola condiviso, quindi
      // non e' identico al colore pieno: si misura la VICINANZA. Ogni bolla
      // deve stare piu' vicina al proprio Maestro che a ciascuno degli altri
      // due. Chiedere che la componente dominante coincida sarebbe troppo
      // rigido: il verde smeraldo di Aura ha di suo una componente blu alta, e
      // sul viola quel blu passa davanti al verde di un centesimo, pur essendo
      // il colore inequivocabilmente quello di Aura.
      final mia = _distanza(visto, ThemeKey.of(proprietario));
      for (final altro in Maestro.values) {
        if (altro == proprietario) continue;
        expect(mia, lessThan(_distanza(visto, ThemeKey.of(altro))),
            reason: 'la bolla di ${proprietario.displayName} e\' piu\' vicina '
                'al colore di ${altro.displayName} che al proprio: $visto');
      }
    }
  });
}

/// Quanto un colore dista dal primario di una chiave di tema.
double _distanza(Color c, ThemeKey chiave) {
  final t = MaestroPalette.forKey(chiave).primary;
  final dr = c.r - t.r;
  final dg = c.g - t.g;
  final db = c.b - t.b;
  return dr * dr + dg * dg + db * db;
}

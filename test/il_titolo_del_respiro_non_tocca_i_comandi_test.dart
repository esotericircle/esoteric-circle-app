import 'package:esoteric_circle/core/arts/arti_preferite.dart';
import 'package:esoteric_circle/core/lunario/il_dial_a_moon.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/components/titolo_che_non_si_rompe.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/rotta_arte.dart';
import 'package:esoteric_circle/features/respiro_della_luna/il_respiro_della_luna_screen.dart';
import 'package:esoteric_circle/features/respiro_della_luna/la_collana_delle_lune_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL TITOLO NON TOCCA I COMANDI IN ALTO.** Ordine FX aggiunta FXA.04, 16
/// ottobre 2026: "il titolo di ogni schermata del Respiro non si sovrappone
/// ai comandi in alto, a nessuna larghezza fra 320 e 430 punti e col testo
/// ingrandito dal sistema fino a 1,3".
///
/// Si misura dove il titolo e ogni comando della barra finiscono davvero a
/// schermo: nessun rettangolo del testo del titolo puo' intersecare quello
/// di un comando (la freccia indietro, le fonti, "Altro", l'angolo della
/// barra), e il titolo resta dentro la barra in altezza.
///
/// **Il Respiro si monta come lo monta l'app**, dentro [SogliaArte] e con lo
/// scaffale delle arti preferite: e' cosi' che nella barra compare il cuore.
/// La prima stesura della prova lo montava nudo, senza cuore, e diceva 16 su
/// 16; sul Realme, build 2312, il titolo andava a capo in tre righe e "Luna"
/// spariva. Il titolo poi deve stare intero: si pretende che il testo non
/// sia tagliato, non solo che non tocchi i comandi.
void main() {
  IlDialAMoon offline() =>
      IlDialAMoon(client: MockClient((_) async => http.Response('', 503)));

  Widget host(Widget figlia, double scala, ArtiPreferiteController preferite) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider.value(value: preferite),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scala)),
            child: child!,
          ),
          // La rotta indietro esiste, cosi' la freccia automatica c'e'.
          home:
              Builder(builder: (c) => const Scaffold(body: SizedBox.shrink())),
          onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (_) => MaestroScope(child: figlia)),
          initialRoute: '/schermata',
        ),
      );

  final schermate = <String, Widget Function()>{
    'il Respiro': () => SogliaArte(
          id: 'lunology',
          maestro: Maestro.medora,
          child: IlRespiroDellaLunaScreen(
              now: DateTime(2026, 10, 16, 21), dialAMoon: offline()),
        ),
    'la Collana': () =>
        LaCollanaDelleLuneScreen(now: DateTime(2026, 10, 16, 9)),
  };

  for (final voce in schermate.entries) {
    for (final larghezza in [320.0, 360.0, 390.0, 430.0]) {
      for (final scala in [1.0, 1.3]) {
        testWidgets('${voce.key}: largo $larghezza, testo a $scala',
            (tester) async {
          SharedPreferences.setMockInitialValues({});
          tester.view.physicalSize = Size(larghezza, 800);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);
          final preferite =
              ArtiPreferiteController(maestroAssegnato: Maestro.medora);
          await preferite.carica();
          addTearDown(preferite.dispose);
          await tester.pumpWidget(host(voce.value(), scala, preferite));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

          final barra = find.byType(AppBar).last;
          final rettBarra = tester.getRect(barra);
          final titolo = find.descendant(
              of: find.byType(TitoloCheNonSiRompe),
              matching: find.byType(Text));
          expect(titolo, findsOneWidget);
          final rettTitolo = tester.getRect(titolo);
          // Il titolo intero: nessuna riga tagliata dal limite di righe.
          final paragrafo = tester.renderObject<RenderParagraph>(
              find.descendant(of: titolo, matching: find.byType(RichText)));
          expect(paragrafo.didExceedMaxLines, isFalse,
              reason: 'titolo tagliato:${(tester.widget<Text>(titolo)).data}');
          expect(rettTitolo.top >= rettBarra.top - 0.5, isTrue,
              reason: 'il titolo esce dalla barra in alto');
          expect(rettTitolo.bottom <= rettBarra.bottom + 0.5, isTrue,
              reason: 'il titolo esce dalla barra in basso: '
                  '$rettTitolo in $rettBarra');

          // I comandi della barra: la freccia e tutto cio' che sta nelle
          // azioni, presi per tipo dentro la barra.
          final comandi = <Rect>[
            for (final f in [
              find.descendant(of: barra, matching: find.byType(BackButton)),
              find.descendant(of: barra, matching: find.byType(IconButton)),
              find.descendant(of: barra, matching: find.byType(CuorePreferita)),
              find.descendant(
                  of: barra,
                  matching: find.byKey(const Key('respiro_altre_voci'))),
            ])
              for (final e in f.evaluate())
                tester.getRect(find.byWidget(e.widget).first),
          ];
          expect(comandi, isNotEmpty,
              reason: 'nessun comando trovato nella barra: la misura non '
                  'guarda niente');
          for (final c in comandi) {
            expect(rettTitolo.overlaps(c.deflate(0.5)), isFalse,
                reason: 'il titolo $rettTitolo tocca il comando $c');
          }
        });
      }
    }
  }
}

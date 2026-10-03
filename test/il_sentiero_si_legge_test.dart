import 'dart:io';
import 'dart:math' as math;

import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/sentiero_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'istante_dichiarato.dart';

/// IL SENTIERO SI LEGGE, ordine P voci 37 e 39.
///
/// **Voce 37, le opacita' che si moltiplicavano.** Il colore del traguardo non
/// raggiunto era `ColorTokens.textSecondary.withValues(alpha: 0.35)` e l'intera
/// riga era avvolta in `Opacity(opacity: 0.78)`. Le due si moltiplicano:
/// 0,35 per 0,78 fa **0,273** di alfa effettivo, cioe' 1,76 a 1 di contrasto
/// sul fondo reale, meno della meta' della soglia. Il commento accanto al
/// codice diceva che a 0,55 i nomi sparivano e che il grigio era stato reso
/// leggibile: la misura dice il contrario, e vince la misura.
///
/// **Voce 39, la frase tagliata.** Sul gradino acceso si leggeva "Tre gettate
/// di rune: le pietre hanno imparato il peso della" e finiva li': il
/// sottotitolo era a `maxLines: 2` e la frase era piu' lunga. Non si tronca e
/// non si mettono i puntini: una frase tagliata a meta' e' una frase non
/// scritta, e i puntini nasconderebbero il problema invece di chiuderlo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------
  // LA MISURA DEL CONTRASTO, con la formula di luminanza relativa WCAG.
  // ---------------------------------------------------------------------

  double canale(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

  double luminanza(Color c) =>
      0.2126 * canale(c.r) + 0.7152 * canale(c.g) + 0.0722 * canale(c.b);

  /// Il colore che si vede davvero quando un testo semitrasparente sta sopra
  /// un fondo: e' questo che va misurato, non il colore dichiarato.
  Color sopra(Color testo, Color fondo) {
    final a = testo.a;
    return Color.from(
      alpha: 1,
      red: testo.r * a + fondo.r * (1 - a),
      green: testo.g * a + fondo.g * (1 - a),
      blue: testo.b * a + fondo.b * (1 - a),
    );
  }

  double contrasto(Color testo, Color fondo) {
    final composito = sopra(testo, fondo);
    final a = luminanza(composito);
    final b = luminanza(fondo);
    final alto = math.max(a, b);
    final basso = math.min(a, b);
    return (alto + 0.05) / (basso + 0.05);
  }

  MaestroPalette paletteDi(Sentiero sentiero) => switch (sentiero.maestro) {
        Maestro.medora => MaestroPalette.medora,
        Maestro.aura => MaestroPalette.aura,
        Maestro.caligo => MaestroPalette.caligo,
      };

  /// L'OPACITA' EFFETTIVA di un testo: la sua, moltiplicata per quella di
  /// OGNI widget `Opacity` che gli sta sopra nell'albero.
  ///
  /// **E' il cuore della voce 37.** Guardare l'alfa dichiarato nel colore non
  /// bastava: il colore diceva 0,35 e a schermo si vedeva 0,273, perche' una
  /// seconda opacita' avvolgeva la riga. Una misura che legge un solo numero
  /// non puo' vedere un prodotto. Questa risale l'albero e le moltiplica
  /// tutte, che e' quello che fa anche il compositore.
  double alfaEffettivo(WidgetTester tester, Finder testo) {
    final elemento = tester.element(testo);
    var alfa = (elemento.widget as Text).style?.color?.a ?? 1.0;
    elemento.visitAncestorElements((antenato) {
      final w = antenato.widget;
      if (w is Opacity) alfa *= w.opacity;
      if (w is FadeTransition) alfa *= w.opacity.value;
      return true;
    });
    return alfa;
  }

  testWidgets('sul sentiero nessuna coppia testo-fondo sta sotto 4,5 a 1',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final sotto = <String>[];
    for (final sentiero in Sentieri.tutti) {
      final palette = paletteDi(sentiero);
      // I TRE STATI, montati davvero: acceso, il prossimo, e il non
      // raggiunto, che e' quello che non si leggeva.
      for (final (stato, quantiAccesi) in const [
        ('acceso', 1),
        ('il prossimo', 0),
        ('non raggiunto', 0),
      ]) {
        SharedPreferences.setMockInitialValues(const {});
        final diario = DiarioDelCammino(orologio: orologioDelleProve);
        await diario.carica();
        final mini = Sentieri.miniDi(sentiero);
        // Per l'acceso si guarda il primo; per il prossimo, il primo non
        // acceso; per il non raggiunto, uno molto piu' avanti.
        final traguardo = switch (stato) {
          'acceso' => mini[0],
          'il prossimo' => mini[0],
          _ => mini[30],
        };
        if (quantiAccesi > 0) await diario.accendi(mini[0].id);

        await tester.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MaestroController()),
            ChangeNotifierProvider(create: (_) => EntitlementService()),
            ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (ctx, child) => MaestroScope(child: child!),
            home: Scaffold(
              body: GradinoDelSentiero(
                traguardo: traguardo,
                sentiero: sentiero,
                diario: diario,
                piano: Tier.free,
              ),
            ),
          ),
        ));
        await tester.pump();

        for (final (quale, chiave) in [
          ('titolo', 'gradino_nome_${traguardo.id}'),
          ('frase', 'gradino_frase_${traguardo.id}'),
        ]) {
          final finder = find.byKey(Key(chiave));
          final dichiarato = (tester.widget(finder) as Text).style!.color!;
          final reso =
              dichiarato.withValues(alpha: alfaEffettivo(tester, finder));
          // I FONDI VERI, tutti e tre i toni del gradiente del Maestro: il
          // testo deve reggere anche sul piu' chiaro, caso peggiore.
          for (final fondo in palette.backgroundGradient) {
            final misura = contrasto(reso, fondo);
            if (misura < SogliaDelLeggibile.contrastoMinimo) {
              sotto.add('${sentiero.name} / $stato / $quale su '
                  '${fondo.toARGB32().toRadixString(16)}: '
                  '${misura.toStringAsFixed(2)} a 1 '
                  '(alfa effettivo ${reso.a.toStringAsFixed(3)})');
            }
          }
        }
      }
    }
    expect(sotto, isEmpty,
        reason: 'queste coppie del sentiero stanno sotto la soglia di '
            '${SogliaDelLeggibile.contrastoMinimo} a 1 della voce P.12:\n'
            '${sotto.join("\n")}');
  });

  test('lo stato spento e\' governato da UNA sola opacita\'', () {
    // La regola strutturale sotto la misura: due opacita' che si moltiplicano
    // non si vedono in nessun numero scritto nel codice, si vedono solo a
    // schermo. Qui si vieta la seconda.
    // I COMMENTI NON CONTANO: la spiegazione del difetto nomina per forza
    // `Opacity(opacity: 0.78)`, e una prova che accusasse il commento che
    // racconta il difetto costringerebbe a cancellare proprio la memoria di
    // com'era nato. Si guarda il codice.
    final codice = File('lib/features/sigilli/sentiero_screen.dart')
        .readAsLinesSync()
        .where((r) =>
            !r.trimLeft().startsWith('//') && !r.trimLeft().startsWith('///'))
        .join('\n');
    expect(codice.contains('Opacity('), isFalse,
        reason: 'sentiero_screen.dart torna a usare un widget Opacity: era la '
            'SECONDA opacita\', quella che moltiplicandosi con l\'alfa del '
            'colore produceva lo 0,273 effettivo. Lo stato si governa con '
            'l\'alfa del colore, e con quello soltanto');
  });

  // ---------------------------------------------------------------------
  // VOCE 39: nessuna frase resa piu' corta del suo dato.
  // ---------------------------------------------------------------------

  testWidgets('nessuna frase dei 165 traguardi finisce troncata',
      (tester) async {
    // LA LARGHEZZA REALE del telefono, non una comoda: e' li' che la frase
    // andava a capo e veniva tagliata.
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final tagliati = <String>[];
    for (final sentiero in Sentieri.tutti) {
      for (final traguardo in Sentieri.di(sentiero)) {
        SharedPreferences.setMockInitialValues(const {});
        final diario = DiarioDelCammino(orologio: orologioDelleProve);
        await diario.carica();
        // ACCESO: e' lo stato in cui il gradino mostra la frase per intero,
        // ed e' li' che si leggeva "il peso della" e finiva.
        await diario.accendi(traguardo.id);

        await tester.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MaestroController()),
            ChangeNotifierProvider(create: (_) => EntitlementService()),
            ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (ctx, child) => MaestroScope(child: child!),
            home: Scaffold(
              body: Padding(
                // Lo stesso margine orizzontale della schermata vera.
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GradinoDelSentiero(
                  traguardo: traguardo,
                  sentiero: sentiero,
                  diario: diario,
                  piano: Tier.free,
                ),
              ),
            ),
          ),
        ));
        await tester.pump();

        final paragrafo = tester.renderObject<RenderParagraph>(
            find.byKey(Key('gradino_frase_${traguardo.id}')));
        if (paragrafo.didExceedMaxLines) {
          tagliati.add('${sentiero.name} / ${traguardo.id} '
              '"${traguardo.nome}": ${traguardo.frase}');
        }
      }
    }
    expect(tagliati, isEmpty,
        reason: 'queste frasi vengono rese piu'
            ' corte del testo del dato, '
            'cioe\' tagliate a meta\' senza nemmeno i puntini:\n'
            '${tagliati.join("\n")}');
  });
}

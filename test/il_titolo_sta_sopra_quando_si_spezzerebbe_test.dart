// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/i_testi_eu.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/tokens/spacing_tokens.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:esoteric_circle/design_system/typography/il_titolo_col_trattino.dart';
import 'package:esoteric_circle/features/horoscope/answer_depth.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:esoteric_circle/features/horoscope/titolo_della_scheda_del_giorno.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **IL TITOLO STA SOPRA QUANDO ACCANTO SI SPEZZEREBBE.** Visto sul Realme
/// il 1 ottobre 2026 (ordine EU): accanto al selettore della profondita' la
/// colonna del titolo e' stretta, e i titoli dei corpora dell'Architetto
/// andavano a capo col trattino, anche due volte nello stesso titolo
/// ("RICOMIN- / CIARE DAL- / LE STANZE").
///
/// Si misura:
/// - la larghezza del selettore che la scheda calcola prima di disegnarlo
///   ([AnswerDepthSelector.larghezza]) non e' piu' stretta di quella
///   disegnata, e la supera di poco, al carattere normale e a quello massimo;
/// - su tutti i titoli dei dodici corpora, nella larghezza vera della scheda
///   a 360 punti: titoli che a video vanno a capo col trattino, prima (sempre
///   accanto al selettore) e dopo (sopra quando accanto si spezzerebbe);
/// - sull'Oroscopo montato: ogni scheda il cui titolo si spezzerebbe ha il
///   titolo sopra, e nessun titolo a video finisce una riga col trattino.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('la larghezza calcolata del selettore e\' quella disegnata',
      (tester) async {
    final righe = <String>[];
    var misurati = 0;
    for (final scala in const [1.0, 1.3]) {
      for (final (voce, aperta) in const [
        (AnswerDepth.breve, true),
        (AnswerDepth.profonda, true),
        (AnswerDepth.profonda, false),
      ]) {
        await tester.pumpWidget(MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scala)),
            child: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: AnswerDepthSelector(
                  key: const Key('selettore'),
                  current: voce,
                  palette: MaestroPalette.medora,
                  premiumUnlocked: aperta,
                ),
              ),
            ),
          ),
        ));
        final disegnata =
            tester.getSize(find.byKey(const Key('selettore'))).width;
        final calcolata =
            AnswerDepthSelector.larghezza(TextScaler.linear(scala));
        misurati++;
        righe.add('${voce.name} ${aperta ? 'aperta' : 'chiusa'} a $scala: '
            'disegnata ${disegnata.toStringAsFixed(1)}, calcolata '
            '${calcolata.toStringAsFixed(1)}');
        expect(calcolata, greaterThanOrEqualTo(disegnata - 0.5),
            reason: righe.last);
        expect(calcolata, lessThanOrEqualTo(disegnata + 32),
            reason: righe.last);
      }
    }
    cardinaleMinimo(misurati, 6, cosa: 'selettori misurati');
    print('IL TITOLO STA SOPRA: ${righe.join('; ')}');
  });

  Future<void> monta(WidgetTester tester, {double scala = 1.0}) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 5600);
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
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(
              disableAnimations: true, textScaler: TextScaler.linear(scala)),
          child: MaestroScope(child: child!),
        ),
        home: OroscopoScreen(
            userSign: Zodiac.gemini, now: DateTime(2026, 9, 28, 0, 10)),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    await tester.pump();
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(seconds: 3));
    }
  }

  // La larghezza vera della testata di una scheda a 360 punti: dal bordo
  // sinistro del titolo al bordo destro del selettore. Si legge
  // dall'Oroscopo montato e serve alla prova sui corpora.
  double? larghezzaDellaTestata;
  final colpe = <String>[];
  var schedeGuardate = 0;

  for (final scala in const [1.0, 1.3]) {
    testWidgets(
        'sull\'Oroscopo montato alla scala $scala il titolo che si '
        'spezzerebbe sta sopra', (tester) async {
      await monta(tester, scala: scala);
      final stile = TypographyTokens.titoloScheda().copyWith(height: 1.1);
      for (final d in HoroscopeDomain.values) {
        final titolo = find.byKey(Key('oroscopo_titolo_${d.name}'));
        final selettore = find.byKey(Key('oroscopo_depth_${d.name}'));
        expect(titolo, findsOneWidget, reason: 'manca il titolo di ${d.name}');
        final larghezza =
            tester.getRect(selettore).right - tester.getRect(titolo).left;
        if (scala == 1.0) larghezzaDellaTestata ??= larghezza;
        final testo = tester.widget<TitoloDellaSchedaDelGiorno>(titolo).testo;
        final sopra = TitoloDellaSchedaDelGiorno.vaSopra(testo,
            stile: stile,
            larghezza: larghezza,
            accanto: AnswerDepthSelector.larghezza(TextScaler.linear(scala)),
            distanza: SpacingTokens.sm,
            scala: TextScaler.linear(scala));
        final aVideo = tester
            .widget<Text>(
                find.descendant(of: titolo, matching: find.byType(Text)))
            .data!;
        schedeGuardate++;
        final sta = find
            .byKey(Key('oroscopo_titolo_sopra_${d.name}'))
            .evaluate()
            .isNotEmpty;
        print('IL TITOLO STA SOPRA: a $scala, ${d.name} "$testo" '
            '${sta ? 'sopra' : 'accanto'}, a video '
            '"${aVideo.replaceAll('\n', ' / ')}"');
        if (sopra != sta) {
          colpe.add('a $scala ${d.name}: "$testo" dovrebbe stare '
              '${sopra ? 'sopra' : 'accanto'}');
        }
        if (aVideo.split('\n').any((r) => r.endsWith('-')) && !sopra) {
          colpe.add('a $scala ${d.name}: "$aVideo" col trattino accanto al '
              'selettore');
        }
      }
    });
  }

  test('su tutti i titoli dei dodici corpora', () {
    expect(larghezzaDellaTestata, isNotNull,
        reason: 'la testata non e\' stata misurata');
    final titoli = <String>{
      for (final t in TradizioneEu.values)
        for (final p in PeriodoEu.values)
          for (final d in HoroscopeDomain.values)
            for (final f in FasciaEu.values)
              for (final v in ITestiEu.fascia(t, p, d, f)) v.titolo,
    };
    final stile = TypographyTokens.titoloScheda().copyWith(height: 1.1);
    final conti = <String>[];
    for (final scala in const [1.0, 1.3]) {
      final s = TextScaler.linear(scala);
      final accanto = AnswerDepthSelector.larghezza(s);
      var prima = 0, dopo = 0, sopra = 0;
      final esempi = <String>[];
      for (final t in titoli) {
        bool colTrattino(double larghezza) => IlTitoloColTrattino.righe(t,
                stile: stile,
                larghezza: larghezza - TitoloDellaSchedaDelGiorno.margine,
                scala: s,
                maxRighe: 3)
            .any((r) => r.endsWith('-'));
        final stretta = larghezzaDellaTestata! - SpacingTokens.sm - accanto;
        if (colTrattino(stretta)) {
          prima++;
          if (esempi.length < 3) esempi.add(t);
        }
        final vaSopra = TitoloDellaSchedaDelGiorno.vaSopra(t,
            stile: stile,
            larghezza: larghezzaDellaTestata!,
            accanto: accanto,
            distanza: SpacingTokens.sm,
            scala: s);
        if (vaSopra) sopra++;
        if (colTrattino(vaSopra ? larghezzaDellaTestata! : stretta)) dopo++;
      }
      conti.add('a $scala titoli col trattino a video, prima $prima, dopo '
          '$dopo; titoli sopra il selettore $sopra (es. ${esempi.join(', ')})');
      if (scala == 1.0 && dopo > 0) {
        colpe.add('a 1.0 restano $dopo titoli col trattino');
      }
      if (dopo > prima) colpe.add('a $scala piu\' trattini di prima');
    }
    cardinaleMinimo(titoli.length, 500, cosa: 'titoli dei corpora');
    cardinaleMinimo(schedeGuardate, 8, cosa: 'schede guardate');
    print('IL TITOLO STA SOPRA: titoli ${titoli.length}, testata '
        '${larghezzaDellaTestata!.toStringAsFixed(1)} punti; '
        '${conti.join('; ')}');
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });
}

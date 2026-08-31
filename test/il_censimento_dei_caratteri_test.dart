import 'dart:io';

import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:esoteric_circle/features/rituals/breath_destiny_screen.dart';
import 'package:esoteric_circle/features/rituals/dawn_rite_screen.dart';
import 'package:esoteric_circle/features/santuario/daily_strip.dart';
import 'package:esoteric_circle/features/rituals/day_oracle_screen.dart';
import 'package:esoteric_circle/features/rituals/dream_rite_screen.dart';
import 'package:esoteric_circle/features/rituals/sunset_rune_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL CENSIMENTO DEI CARATTERI CHE UNA PERSONA LEGGE. Ordine CF voce 10.
///
/// **Il fatto del fondatore, verbatim**: "Avevo anche chiesto di uniformare
/// tutte le dimensioni del resto e invece i doni e alcune funzionalita' SONO
/// TROPPO PICCOLI I CARATTERI!"
///
/// **UNA PREMESSA DELL'ARCHITETTO E' GIA' CADUTA ALLA MISURA, e sta scritta
/// nell'ordine invece che nascosta**: i testi lunghi di tutti e cinque i Doni
/// stanno a 18 punti, cioe' esattamente alla misura del responso dei
/// Tarocchi, e nessun `fontSize` esplicito li abbassa. Quello che il fondatore
/// vede piccolo e' quindi un'altra cosa.
///
/// **QUESTA PROVA RIPORTA, NON ESEGUE.** Il fondatore, quando gli e' stato
/// chiesto se l'uniformazione dovesse toccare anche i testi brevi, ha risposto
/// A, cioe' solo i testi da leggere. Alzare inviti, sottotitoli, didascalie ed
/// etichette e' materia sua e non si esegue: qui si misura ogni testo che una
/// persona legge davvero, si scrive l'elenco di cio' che sta sotto i sedici
/// punti col suo ruolo, e glielo si porta come fatto.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
    for (final n in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Widget attorno(Widget scena, {Maestro maestro = Maestro.medora}) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => MaestroController(initial: ThemeKey.of(maestro))),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => ArchetypeHistory()..carica()),
        ],
        child: MaterialApp(
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: MaestroScope(child: child!),
          ),
          home: scena,
        ),
      );

  /// I ruoli dichiarati, dalla misura al nome. Serve a dire non solo quanto e'
  /// piccolo un testo, ma CHE COSA e', perche' il fondatore ha deciso sui
  /// ruoli e non sui numeri.
  final ruoli = <double, String>{
    TypographyTokens.lettura().fontSize!: 'lettura',
    TypographyTokens.corpo().fontSize!: 'corpo',
    TypographyTokens.etichetta().fontSize!: 'etichetta (pavimento)',
    TypographyTokens.titoloDiRiga().fontSize!: 'titolo di riga',
    TypographyTokens.titoloScheda().fontSize!: 'titolo di scheda',
    TypographyTokens.titoloDiSchermata().fontSize!: 'titolo di schermata',
    TypographyTokens.titoloSezione().fontSize!: 'titolo di sezione',
    TypographyTokens.cerimoniale().fontSize!: 'cerimoniale',
    TypographyTokens.cerimonialeGrande().fontSize!: 'cerimoniale grande',
  };

  /// **LA SOGLIA E' QUELLA DEL FONDATORE, sedici punti**, che e' la misura a
  /// cui l'ordine H ha portato le didascalie e sotto la quale lui dice di
  /// vedere piccolo.
  const soglia = 16.0;

  /// Una voce del censimento: dove, che ruolo, quanto e' grande, e SOPRATTUTTO
  /// che cosa c'e' scritto. **Senza il testo il documento sarebbe un elenco di
  /// numeri**, e il fondatore deve poter riconoscere sullo schermo la riga che
  /// gli sembra piccola.
  final piccoli = <(String dove, String ruolo, double misura, String testo)>[];

  void censisci(WidgetTester tester, String dove) {
    void scendi(RenderObject r) {
      if (r is RenderParagraph) {
        final misura = r.text.style?.fontSize;
        var testo = r.text.toPlainText().trim().replaceAll('\n', ' ');
        if (testo.length > 48) testo = '${testo.substring(0, 45)}...';
        if (misura != null && misura < soglia && testo.isNotEmpty) {
          final ruolo = ruoli[misura] ?? 'senza ruolo dichiarato';
          final gia = piccoli.any((v) =>
              v.$1 == dove && v.$3 == misura && v.$4 == testo);
          if (!gia) piccoli.add((dove, ruolo, misura, testo));
        }
      }
      r.visitChildren(scendi);
    }

    final radice = tester.binding.rootElement?.renderObject;
    if (radice != null) scendi(radice);
  }

  Future<void> apri(WidgetTester tester, Widget scena, String dove,
      {Maestro maestro = Maestro.medora}) async {
    silenzia();
    SharedPreferences.setMockInitialValues(const {});
    // **LO SCHERMO E' QUELLO VERO, 360 punti**, come l'ordine chiede. Il
    // default della prova e' 800 per 600, cioe' un telefono che non esiste,
    // e li' nessun testo si comporterebbe come sul telefono del fondatore.
    tester.view.physicalSize = const Size(360, 797);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(attorno(scena, maestro: maestro));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    censisci(tester, dove);
    tester.takeException();
  }

  testWidgets('si misura ogni testo dei Doni e se ne scrive il censimento',
      (tester) async {
    await apri(tester, DawnRiteScreen(now: DateTime(2026, 7, 13, 7)),
        'Dono dell\'Alba');
    await apri(tester, const DayOracleScreen(), 'Dono dell\'Arcano');
    await apri(tester, SunsetRuneScreen(now: DateTime(2026, 7, 13, 20)),
        'Dono del Tramonto', maestro: Maestro.caligo);
    await apri(tester, DreamRiteScreen(now: DateTime(2026, 7, 13, 22, 40)),
        'Dono della Notte', maestro: Maestro.caligo);
    await apri(tester, const BreathDestinyScreen(), 'Dono del Soffio',
        maestro: Maestro.aura);
    // **E LA STRISCIA DEI DONI, che e' la prima cosa che il fondatore vede
    // quando dice che "i doni" sono piccoli.** Non e' una schermata di un
    // Dono: e' la fascia in cima al Santuario da cui i cinque si aprono, e i
    // suoi nomi sono la parte che si legge di piu' in tutta l'app.
    await apri(tester, Scaffold(body: DailyStrip(
      clock: () => DateTime(2026, 7, 13, 10, 30),
    )), 'La striscia dei Doni');

    final righe = <String>[
      '# I CARATTERI SOTTO I SEDICI PUNTI, MISURATI',
      '',
      'Censimento dell\'ordine CF voce 10, prodotto da',
      '`test/il_censimento_dei_caratteri_test.dart` a 360 punti logici.',
      '',
      '**Questo documento riporta, non decide.** Il fondatore ha gia\' detto',
      'che l\'uniformazione tocca i soli testi da leggere: alzare i testi',
      'brevi e\' materia sua, e questa e\' la misura su cui decidere.',
      '',
      '| schermata | misura | ruolo | cosa c\'e\' scritto |',
      '| --- | --- | --- | --- |',
    ];
    final ordinati = [...piccoli]
      ..sort((a, b) => a.$3 == b.$3
          ? a.$1.compareTo(b.$1)
          : a.$3.compareTo(b.$3));
    for (final v in ordinati) {
      righe.add('| ${v.$1} | ${v.$3} | ${v.$2} | ${v.$4} |');
    }
    final quanti = ordinati.length;
    righe.addAll([
      '',
      '<!-- TESTI_SOTTO_SEDICI: $quanti -->',
      '',
      'Testi sotto i sedici punti, contati sui pezzi resi: **$quanti**.',
    ]);
    File('docs/tipografia/caratteri_piccoli.md')
        .writeAsStringSync('${righe.join('\n')}\n');

    // ignore: avoid_print
    print('ORDINE CF VOCE 10: testi distinti sotto i $soglia punti $quanti, '
        'su ${piccoli.map((v) => v.$1).toSet().length} schermate');
    expect(piccoli, isNotEmpty,
        reason: 'il censimento non ha trovato nessun testo: le schermate non '
            'si sono montate, e un documento vuoto direbbe che va tutto bene');
  });
}

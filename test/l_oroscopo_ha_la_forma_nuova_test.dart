// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/aspetti_di_oggi.dart';
import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/horoscope/astro_tradition.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/i_testi_eu.dart';
import 'package:esoteric_circle/core/horoscope/il_capodanno_lunare.dart';
import 'package:esoteric_circle/core/horoscope/l_almanacco_cinese.dart';
import 'package:esoteric_circle/core/horoscope/riflessione_del_cielo.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/responsi/i_riti_propiziatori.dart';
import 'package:esoteric_circle/core/responsi/la_forma_del_responso.dart';
import 'package:esoteric_circle/design_system/components/riquadro_arancione.dart';
import 'package:esoteric_circle/design_system/components/riquadro_in_evidenza.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/answer_depth.dart';
import 'package:esoteric_circle/features/horoscope/il_periodo_view.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'cardinale_minimo.dart';
import 'oroscopo_eu_comune.dart';

/// **L'OROSCOPO HA LA FORMA NUOVA.** Ordine GA, voci GA.03, GA.04 e GA.05,
/// 20 ottobre 2026.
///
/// Il fondatore, 19 ottobre 2026 alle 23:08: *"tutte le risposte composte da
/// paragrafi ognuno con tra 40 a 50 parole ognuno. Per le risposte brevi 2
/// paragrafi di cui il secondo messo in evidenza in un riquadro e questo
/// riquadro deve intitolarsi "cosa fare adesso" [...] Per le risposte lunghe
/// aggiungi 2 paragrafi sempre con il primo in riquadro. Sotto sempre il
/// paragrafo in corsivo "da dove viene"."*; 20 ottobre alle 00:10: *"Il
/// secondo riquadro della risposta lunga, quindi il quarto paragrafo con
/// riquadro"*; voce GA.04, il rito della tradizione col pianeta, il graha o
/// l'ufficiale del giorno, e per Settimana, Mese e Anno quello del primo
/// giorno del periodo.
///
/// Si misura, per le tre tradizioni e i quattro periodi, in Breve e in
/// Lunga:
/// - **la forma**: `ResponsoInterpretato.difetti()` vuoto, cioe' ogni
///   paragrafo da 40 a 50 parole, il titolo, il riquadro "Cosa fare
///   adesso", nella Lunga l'approfondimento e il rito, il "Da dove viene";
///   la Breve senza approfondimento e senza rito;
/// - **il rito giusto**: quello del reggente del giorno, o del primo giorno
///   del periodo, calcolato QUI dalla data con le tabelle scritte qui (il
///   martedi' 20 ottobre 2026 e' Marte, Mangala e Zhi), e la sua fonte in
///   coda al "Da dove viene";
/// - **a video**: le schede della Settimana e del Mese montate
///   ([IlPeriodoView]) e le schede del Giorno sull'Oroscopo montato, nelle
///   tre tradizioni: il riquadro "Cosa fare adesso" col suo titolo, nella
///   Lunga il riquadro arancione col titolo del rito della tradizione, il "Da
///   dove viene" in corsivo e sotto ogni paragrafo.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  // Martedi' 20 ottobre 2026.
  final oggi = DateTime(2026, 10, 20);

  // **LE TABELLE DELLA PROVA, scritte qui e non prese dal codice**: un
  // difetto nella tabella del codice non deve spostare anche la misura.
  const pianeti = [
    'Luna', 'Marte', 'Mercurio', 'Giove', 'Venere', 'Saturno', 'Sole', //
  ];
  const graha = [
    'Chandra', 'Mangala', 'Budha', 'Guru', 'Shukra', 'Shani', 'Surya', //
  ];
  const ufficiali = [
    'Jian', 'Chu', 'Man', 'Ping', 'Ding', 'Zhi', //
    'Po', 'Wei', 'Cheng', 'Shou', 'Kai', 'Bi',
  ];
  const titoliDelRito = {
    TradizioneEu.occidentale: 'L\'inno propiziatorio',
    TradizioneEu.vedica: 'Il mantra propiziatorio',
    TradizioneEu.cinese: 'Il gesto propiziatorio',
  };
  const raccolte = {
    TradizioneEu.occidentale: IRitiPropiziatori.inniOrfici,
    TradizioneEu.vedica: IRitiPropiziatori.mantraNavagraha,
    TradizioneEu.cinese: IRitiPropiziatori.gestiTongShu,
  };
  String reggente(TradizioneEu t, DateTime g) => switch (t) {
        TradizioneEu.occidentale => pianeti[g.weekday - 1],
        TradizioneEu.vedica => graha[g.weekday - 1],
        TradizioneEu.cinese => ufficiali[LAlmanaccoCinese.guardiano(g)!],
      };

  test('il martedì 20 ottobre 2026 governano Marte, Mangala e Zhi', () {
    expect(oggi.weekday, DateTime.tuesday);
    expect(reggente(TradizioneEu.occidentale, oggi), 'Marte');
    expect(reggente(TradizioneEu.vedica, oggi), 'Mangala');
    // Zhi: l'8 ottobre 2026 (Han Lu) ripete Zhi, il 9 e' Po, il 17 Man
    // (docs/collaudo/ES/cinese.txt, riscontro sugli almanacchi in linea):
    // dal 17 Man si contano Ping il 18, Ding il 19, Zhi il 20.
    expect(reggente(TradizioneEu.cinese, oggi), 'Zhi');
  });

  final persone = [dodiciPersone[0], dodiciPersone[2], dodiciPersone[4]];
  var responsiGuardati = 0;
  var ritiGuardati = 0;
  final colpe = <String>[];

  /// Il primo giorno del periodo come lo intende la prova: il Giorno e
  /// l'inizio della Settimana e del Mese sono oggi; l'Anno occidentale
  /// comincia al compleanno, il vedico pure, il cinese a Capodanno lunare.
  DateTime primoGiorno(PersonaDiProva p, TradizioneEu t, PeriodoEu periodo) {
    if (periodo != PeriodoEu.anno) return oggi;
    if (t == TradizioneEu.cinese) {
      return IlCapodannoLunare.di(IlCapodannoLunare.annoCinese(oggi)!)!;
    }
    final c = DateTime(oggi.year, p.nascita.month, p.nascita.day);
    return c.isAfter(oggi)
        ? DateTime(oggi.year - 1, p.nascita.month, p.nascita.day)
        : c;
  }

  List<(HoroscopeDomain, ResponsoInterpretato)> responsi(
      PersonaDiProva p, TradizioneEu t, PeriodoEu periodo, bool lunga) {
    switch (periodo) {
      case PeriodoEu.giorno:
        return [
          for (final c in p.giorno(t, oggi, lunga: lunga))
            (c.domain, c.responso!)
        ];
      case PeriodoEu.settimana:
      case PeriodoEu.mese:
        final mese = periodo == PeriodoEu.mese;
        return [
          for (final d in p.periodo(t, oggi, mese: mese).domini)
            (d.dominio, d.responso(t, mese: mese, lunga: lunga))
        ];
      case PeriodoEu.anno:
        return [
          for (final c in p.anno(t, oggi, lunga: lunga)) (c.domain, c.responso!)
        ];
    }
  }

  for (final t in TradizioneEu.values) {
    for (final periodo in PeriodoEu.values) {
      test('la forma e il rito, ${t.name} ${periodo.name}', () {
        for (final p in persone) {
          if (!p.legge(t)) continue;
          for (final lunga in const [false, true]) {
            for (final (d, r) in responsi(p, t, periodo, lunga)) {
              responsiGuardati++;
              final dove = '${p.nome} ${t.name} ${periodo.name} '
                  '${lunga ? 'Lunga' : 'Breve'} ${d.label}';
              for (final difetto in r.difetti()) {
                colpe.add('$dove: $difetto');
              }
              if (!lunga) {
                if (r.approfondimento != null || r.rito != null) {
                  colpe.add('$dove: la Breve porta approfondimento o rito');
                }
                continue;
              }
              if (LaFormaDelResponso.titoloDelRito(r.arte) !=
                  titoliDelRito[t]) {
                colpe.add('$dove: il riquadro del rito si intitola '
                    '"${LaFormaDelResponso.titoloDelRito(r.arte)}"');
              }
              final chiave = [
                reggente(t, primoGiorno(p, t, periodo)),
                d.label,
                periodo == PeriodoEu.giorno ? 'giorno' : 'periodo',
              ];
              final atteso = IRitiPropiziatori.rito(raccolte[t]!, chiave);
              ritiGuardati++;
              if (atteso == null) {
                colpe.add('$dove: la raccolta non ha il rito $chiave');
              } else if (r.rito != atteso) {
                colpe.add('$dove: il rito non e\' quello di $chiave, '
                    '«${(r.rito ?? 'nessuno').split(' ').take(8).join(' ')}»');
              }
              final fonte = IRitiPropiziatori.fonte(raccolte[t]!, chiave)!;
              final coda = fonte.substring(1);
              if (!(r.daDoveViene ?? '').endsWith(coda)) {
                colpe.add('$dove: il "Da dove viene" non chiude con la fonte '
                    'del rito «$fonte»');
              }
            }
          }
        }
      });
    }
  }

  // ---------------------------------------------------------------------------
  // A VIDEO
  // ---------------------------------------------------------------------------

  var schedeAVideo = 0;

  /// Il responso di [chiave] montato: il riquadro "Cosa fare adesso" col suo
  /// titolo, nella Lunga il riquadro del rito col titolo della tradizione,
  /// il "Da dove viene" in corsivo e sotto ogni paragrafo.
  void guardaAVideo(
      WidgetTester tester, String chiave, String dove, TradizioneEu t,
      {required bool lungo, String? ritoAtteso}) {
    schedeAVideo++;
    Finder k(String nome) => find.byKey(Key('${chiave}_$nome'));
    if (k('risposta').evaluate().isEmpty) {
      colpe.add('$dove: a video manca la risposta');
      return;
    }
    final consiglio = k('cosa_fare');
    if (consiglio.evaluate().isEmpty ||
        find
            .ancestor(of: consiglio, matching: find.byType(RiquadroInEvidenza))
            .evaluate()
            .isEmpty) {
      colpe.add('$dove: il secondo paragrafo non sta nel riquadro');
    } else if (tester.widget<Text>(k('titolo_cosa_fare')).data !=
        'Cosa fare adesso') {
      colpe.add('$dove: il riquadro non si intitola "Cosa fare adesso"');
    }
    final paragrafi = [
      k('risposta'),
      consiglio,
      if (lungo) ...[k('approfondimento'), k('rito')],
    ];
    if (lungo) {
      final rito = k('rito');
      if (rito.evaluate().isEmpty ||
          find
              .ancestor(of: rito, matching: find.byType(RiquadroArancione))
              .evaluate()
              .isEmpty) {
        colpe.add('$dove: il rito non sta nel suo riquadro');
      } else {
        final titolo = tester.widget<Text>(k('titolo_rito')).data;
        if (titolo != titoliDelRito[t]) {
          colpe.add('$dove: il riquadro del rito si intitola "$titolo"');
        }
        if (ritoAtteso != null &&
            find
                .descendant(of: rito, matching: find.text(ritoAtteso))
                .evaluate()
                .isEmpty) {
          colpe.add('$dove: a video il rito non e\' quello atteso');
        }
      }
      if (k('approfondimento').evaluate().isEmpty) {
        colpe.add('$dove: a video manca l\'approfondimento');
      }
    } else if (k('rito').evaluate().isNotEmpty) {
      colpe.add('$dove: un rito nella Breve');
    }
    final fonte = k('da_dove_viene');
    if (fonte.evaluate().isEmpty) {
      colpe.add('$dove: a video manca il "Da dove viene"');
      return;
    }
    if (tester.widget<Text>(fonte).style?.fontStyle != FontStyle.italic) {
      colpe.add('$dove: il "Da dove viene" non e\' in corsivo');
    }
    final suo = tester.getRect(fonte).top;
    for (final p in paragrafi) {
      if (p.evaluate().isEmpty) continue;
      if (tester.getRect(p).bottom > suo) {
        colpe.add('$dove: il "Da dove viene" non sta in fondo');
        break;
      }
    }
  }

  for (final t in TradizioneEu.values) {
    for (final mese in const [false, true]) {
      for (final lunga in const [false, true]) {
        final nome = '${t.name} ${mese ? 'Mese' : 'Settimana'} '
            '${lunga ? 'Lunga' : 'Breve'}';
        testWidgets('a video, $nome', (tester) async {
          tester.view.physicalSize = const Size(390, 20000);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);
          final p = persone.first;
          final periodo = p.periodo(t, oggi, mese: mese);
          await tester.pumpWidget(MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                  size: Size(390, 20000), disableAnimations: true),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: IlPeriodoView(
                    periodo: periodo,
                    mese: mese,
                    palette: MaestroPalette.medora,
                    livello: LivelloPersonalizzazione.cartaCompleta,
                    profondita: {
                      for (final d in HoroscopeDomain.values)
                        d: lunga ? AnswerDepth.profonda : AnswerDepth.free,
                    },
                    premiumUnlocked: true,
                    onDepthSelected: (_, __) {},
                    onDepthLocked: (_, __) {},
                  ),
                ),
              ),
            ),
          ));
          await tester.pump();
          expect(tester.takeException(), isNull);
          for (final d in periodo.domini) {
            // Il rito atteso, dalla tabella della prova: il primo giorno
            // della Settimana e del Mese e' oggi.
            final chiave = [reggente(t, oggi), d.dominio.label, 'periodo'];
            guardaAVideo(tester, 'oroscopo_periodo_${d.dominio.name}',
                '$nome ${d.dominio.label}', t,
                lungo: lunga,
                ritoAtteso: IRitiPropiziatori.rito(raccolte[t]!, chiave));
          }
        });
      }
    }
  }

  // L'Oroscopo montato: la scheda del Giorno nelle tre tradizioni, le
  // quattro schede in Breve e la Generale in Lunga. Roma, 15 marzo 1990
  // alle 8:30: la Luna di nascita c'e', la Vedica si legge.
  final nascita = BirthDetails(
    date: DateTime(1990, 3, 15),
    time: const TimeOfDay(hour: 8, minute: 30),
    place: const BirthPlace(
        label: 'Roma',
        latitude: 41.9,
        longitude: 12.5,
        timezone: 'Europe/Rome'),
  );

  Future<void> monta(WidgetTester tester) async {
    // Le preferenze NON si simulano, come nella prova della Vedica a video:
    // con le preferenze vuote la prima apertura di una tradizione mostra la
    // rivelazione del segno, che sta sopra la schermata.
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final name in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(EventChannel(name),
          MockStreamHandler.inline(onListen: (args, events) {}));
    }
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final nascite = BirthIdentityController()..setBirth(nascita, null);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier1)),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider.value(value: nascite),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: OroscopoScreen(
            userSign: Zodiac.pisces,
            now: DateTime(oggi.year, oggi.month, oggi.day, 12)),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> toccaLaTradizione(WidgetTester tester, AstroTradition t) async {
    final riga = find.byKey(const Key('oroscopo_tradition_tabs'));
    await tester.ensureVisible(riga);
    await tester.pump();
    await tester.drag(riga, const Offset(2000, 0));
    await tester.pump(const Duration(milliseconds: 300));
    final chip = find.byKey(Key('oroscopo_tradition_${t.name}'));
    await tester.dragUntilVisible(chip, riga, const Offset(-80, 0));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(chip);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> consulta(WidgetTester tester) async {
    // La storia delle fasce e la lettura vedica si preparano prima del
    // responso (ordine GA voce 14): si lascia loro il tempo.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    final gesto = find.byKey(const Key('oroscopo_interroga'));
    await tester.ensureVisible(gesto);
    await tester.tap(gesto);
    await tester.pump();
    await tester.pump(RiflessioneDelCielo.finoAllUltimaScheda(
        HoroscopeDomain.values.length,
        piena: true));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  Future<void> scorriFino(WidgetTester tester, Finder f,
      {bool dallInizio = false}) async {
    if (dallInizio) {
      // In cima alla lista, poi giu' fino a cio' che si cerca.
      for (var i = 0; i < 12; i++) {
        await tester.drag(
            find.byKey(const Key('oroscopo_list')), const Offset(0, 1200));
        await tester.pump();
      }
    }
    if (f.evaluate().isEmpty) {
      await tester.dragUntilVisible(
          f, find.byKey(const Key('oroscopo_list')), const Offset(0, -300));
      await tester.pump();
    }
    await tester.ensureVisible(f);
    await tester.pump();
  }

  for (final (t, tradizione) in const [
    (AstroTradition.occidentale, TradizioneEu.occidentale),
    (AstroTradition.vedica, TradizioneEu.vedica),
    (AstroTradition.cinese, TradizioneEu.cinese),
  ]) {
    testWidgets('a video, l\'Oroscopo montato, ${t.name} Giorno',
        (tester) async {
      await monta(tester);
      if (t != AstroTradition.occidentale) await toccaLaTradizione(tester, t);
      await consulta(tester);
      for (final d in HoroscopeDomain.values) {
        final chiave = 'oroscopo_responso_${d.name}';
        await scorriFino(tester, find.byKey(Key('${chiave}_da_dove_viene')));
        guardaAVideo(
            tester, chiave, '${t.name} Giorno Breve ${d.label}', tradizione,
            lungo: false);
      }
      // La Generale in Lunga, dal menu della profondita'.
      final menu = find.byKey(const Key('oroscopo_depth_generale'));
      await scorriFino(tester, menu, dallInizio: true);
      await tester.tap(menu);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Lunga').last);
      await tester.pump();
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
      const chiave = 'oroscopo_responso_generale';
      await scorriFino(
          tester, find.byKey(const Key('${chiave}_da_dove_viene')));
      // Il rito del martedi', dalla tabella della prova.
      final chiaveDelRito = [
        reggente(tradizione, oggi),
        HoroscopeDomain.generale.label,
        'giorno'
      ];
      guardaAVideo(
          tester, chiave, '${t.name} Giorno Lunga Generale', tradizione,
          lungo: true,
          ritoAtteso:
              IRitiPropiziatori.rito(raccolte[tradizione]!, chiaveDelRito));
    });
  }

  tearDownAll(() => print('ORDINE GA, L\'OROSCOPO HA LA FORMA NUOVA: '
      'responsi guardati $responsiGuardati, riti guardati $ritiGuardati, '
      'schede a video $schedeAVideo, difetti ${colpe.length}'));

  test('i conti', () {
    // Gira dopo le prove sopra, nello stesso file: le liste sono piene. I
    // numeri sono quelli trovati il 20 ottobre 2026, senza margine: le
    // persone, la data e i periodi sono fissi.
    cardinaleMinimo(responsiGuardati, 288,
        cosa: 'responsi guardati',
        perche: 'tre persone che leggono tutte e tre le tradizioni, quattro '
            'periodi, Breve e Lunga, quattro domini');
    cardinaleMinimo(ritiGuardati, 144,
        cosa: 'riti guardati', perche: 'la meta\' dei responsi, la Lunga');
    cardinaleMinimo(schedeAVideo, 63,
        cosa: 'schede a video',
        perche: 'tre tradizioni, Settimana e Mese, Breve e Lunga, quattro '
            'domini (48), piu\' l\'Oroscopo montato nelle tre tradizioni, '
            'quattro schede in Breve e la Generale in Lunga (15)');
    expect(colpe, isEmpty, reason: colpe.take(12).join('\n'));
  });
}

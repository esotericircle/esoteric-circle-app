import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart' as astro;
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/tokens/spacing_tokens.dart';
import 'package:esoteric_circle/design_system/typography/paragrafi_di_lettura.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter/material.dart';
import 'package:esoteric_circle/core/horoscope/riflessione_del_cielo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// LA RISPOSTA PROFONDA ARRIVA INTERA A SCHERMO, ordine I voce 2.
///
/// La sequenza vista da Mauro sul telefono: si tocca Profonda, il testo viene
/// cancellato, ricompare il SOLO PRIMO PARAGRAFO, e sotto resta un vuoto alto
/// quanto il resto. **La causa, verificata da questa prova PRIMA della
/// correzione:** la Profonda viene generata ed e' piu' lunga, ma la scena che
/// scrive a macchina, al cambio del testo, cancellava il timer del passaggio
/// senza riportarlo a nullo, e la build lo riarmava solo da nullo: il turno
/// restava fermo al primo paragrafo per sempre. I paragrafi successivi
/// stavano in albero trasparenti per tenere il posto, ed erano loro il vuoto.
/// Non era "non generata", non era "troncata nel dato", non era "la breve non
/// completata": era generata e mai mostrata oltre il primo blocco.
void main() {
  final carta = NatalChart(
    sunSign: Zodiac.leo,
    planets: const [
      PlanetPosition(
          id: 'sun',
          name: 'Sole',
          glyph: '☉',
          longitude: 128.4,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'moon',
          name: 'Luna',
          glyph: '☽',
          longitude: 12.7,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'venus',
          name: 'Venere',
          glyph: '♀',
          longitude: 150.2,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'mars',
          name: 'Marte',
          glyph: '♂',
          longitude: 61.9,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'saturn',
          name: 'Saturno',
          glyph: '♄',
          longitude: 300.5,
          sign: Zodiac.leo),
    ],
    ascendantLongitude: 205.0,
    midheavenLongitude: 115.0,
    houses: [
      for (var n = 1; n <= 12; n++)
        HouseCusp(number: n, longitude: (205.0 + (n - 1) * 30.0) % 360.0),
    ],
    hasTime: true,
  );

  final adesso = DateTime.utc(2026, 8, 5, 12);
  // LO STESSO CONTO DELLA SCHERMATA: il giorno ordinale si legge dalla
  // porta di Horoscope, non si riconta a mano, altrimenti la prova confronta
  // due cieli scritti con due calendari.
  final giornoOrdinale = Horoscope.dayOfYear(adesso);

  CieloDiOggi cielo() => CieloDiOggi.perIlGiorno(adesso: adesso, carta: carta);

  test(
      'per ogni scheda la Profonda ha piu\' blocchi e piu\' testo, e '
      'contiene la Breve', () {
    expect(cielo().ceCieloVero, isTrue,
        reason: 'La carta di prova non produce un cielo vero: senza transiti '
            'non c\'e\' niente da misurare, cambiare la carta.');
    final colpe = <String>[];
    for (final dominio in HoroscopeDomain.values) {
      HoroscopeCard di({required bool profonda}) => Horoscope.cardFor(
            sign: Zodiac.leo,
            dayOfYear: giornoOrdinale,
            year: adesso.year,
            domain: dominio,
            cielo: cielo(),
            profonda: profonda,
          );
      final breve = di(profonda: false);
      final profonda = di(profonda: true);
      final blocchiBrevi =
          spezzaInParagrafi(breve.text, stile: stileDelResponso);
      final blocchiProfondi =
          spezzaInParagrafi(profonda.text, stile: stileDelResponso);
      // ignore: avoid_print
      print('${dominio.name}: breve ${breve.text.length} caratteri in '
          '${blocchiBrevi.length} blocchi, profonda '
          '${profonda.text.length} in ${blocchiProfondi.length}');
      if (profonda.text.length <= breve.text.length) {
        colpe.add('${dominio.name}: la Profonda non e\' piu\' lunga '
            '(${profonda.text.length} contro ${breve.text.length})');
      }
      if (blocchiProfondi.length <= blocchiBrevi.length) {
        colpe.add('${dominio.name}: la Profonda non ha piu\' blocchi '
            '(${blocchiProfondi.length} contro ${blocchiBrevi.length})');
      }
      if (!profonda.text.startsWith(breve.text)) {
        colpe.add('${dominio.name}: la Profonda non contiene la Breve per '
            'intero: non aggiunge, sostituisce');
      }
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  testWidgets(
      'toccata Profonda, la scheda Carriera mostra tutto il testo e '
      'sotto non resta vuoto', (tester) async {
    tester.view.physicalSize = const Size(440, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final nascita = BirthIdentityController();
    nascita.setBirth(
      BirthDetails(
        date: DateTime(1990, 8, 10),
        time: const TimeOfDay(hour: 12, minute: 0),
        place: const astro.BirthPlace(
            label: 'Roma',
            latitude: 41.9,
            longitude: 12.5,
            timezone: 'Europe/Rome'),
      ),
      carta,
    );
    // LE ANIMAZIONI RESTANO ACCESE: il difetto vive nella scrittura a
    // macchina, e con Riduci Movimento la scrittura non parte e il difetto
    // non si vede. E' il motivo per cui le prove precedenti non lo prendevano.
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier1)),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider<BirthIdentityController>.value(value: nascita),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: OroscopoScreen(userSign: Zodiac.leo, now: adesso),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Si apre il consulto e si lascia finire l'interrogazione e la scrittura.
    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    await tester.pump();
    // **ORDINE BK: dopo il tocco c'e' la riflessione, poi le schede si
    // compongono a CASCATA.** Prima bastava attendere la scrittura; adesso
    // il responso arriva quando i due momenti sono passati e l'ultima
    // scheda ha finito. Il numero viene dal dato e non e' battuto qui.
    await tester.pump(RiflessioneDelCielo.finoAllUltimaScheda(
        HoroscopeDomain.values.length,
        piena: true));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(seconds: 2));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    // La scheda Carriera, e il suo menu della profondita'.
    final scheda = find.byKey(const Key('oroscopo_card_carriera'));
    await tester.scrollUntilVisible(
        find.byKey(const Key('oroscopo_depth_carriera')), 400,
        scrollable: find.byType(Scrollable).first);
    await tester.pump();
    await tester.tap(find.byKey(const Key('oroscopo_depth_carriera')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Profonda').last);
    await tester.pump();
    // Tutto il tempo che la scrittura potrebbe chiedere, e piu' del doppio.
    for (var i = 0; i < 14; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    await tester.ensureVisible(scheda);
    await tester.pump();

    // Il testo atteso e' quello profondo, composto dalla stessa porta.
    final attesa = Horoscope.cardFor(
      sign: Zodiac.leo,
      dayOfYear: giornoOrdinale,
      year: adesso.year,
      domain: HoroscopeDomain.carriera,
      cielo: cielo(),
      profonda: true,
    );
    final blocchi = spezzaInParagrafi(attesa.text, stile: stileDelResponso);
    expect(blocchi.length, greaterThan(1),
        reason: 'Il testo profondo di prova ha un blocco solo: la misura del '
            'vuoto non distinguerebbe niente, cambiare giorno o carta.');

    // OGNI blocco sta a video, e nessuno e' un fantasma trasparente che
    // tiene il posto: si misura il testo VISIBILE, non quello in albero.
    final visibili = <String, Rect>{};
    for (final e in find
        .descendant(of: scheda, matching: find.byType(Text))
        .evaluate()) {
      final w = e.widget as Text;
      final dato = w.data ?? '';
      if (dato.trim().isEmpty) continue;
      var visibile = true;
      e.visitAncestorElements((a) {
        final aw = a.widget;
        if (aw is Opacity && aw.opacity == 0) {
          visibile = false;
          return false;
        }
        return true;
      });
      if (!visibile) continue;
      final box = e.renderObject! as RenderBox;
      visibili[dato] = box.localToGlobal(Offset.zero) & box.size;
    }

    for (final b in blocchi) {
      expect(visibili.keys.any((t) => t == b), isTrue,
          reason: 'Questo blocco della Profonda non e\' visibile a schermo: '
              '"${b.substring(0, b.length > 60 ? 60 : b.length)}...". La '
              'Profonda arriva a schermo come un pezzo solo.');
    }

    // E sotto il testo non resta vuoto oltre il margine della scheda: il
    // fondo dell'ultimo testo visibile dista dal fondo della scheda al
    // massimo il riempimento dichiarato, con un dito di tolleranza.
    final fondoScheda = tester.getRect(scheda).bottom;
    final fondoTesto =
        visibili.values.map((r) => r.bottom).reduce((a, b) => a > b ? a : b);
    expect(fondoScheda - fondoTesto, lessThanOrEqualTo(SpacingTokens.lg + 8),
        reason: 'Sotto il testo della scheda restano '
            '${(fondoScheda - fondoTesto).toStringAsFixed(1)} punti di '
            'vuoto: la scheda riserva l\'altezza di un testo che non mostra.');
  });
}

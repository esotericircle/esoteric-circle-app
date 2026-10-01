// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/effemeridi.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/l_almanacco_cinese.dart';
import 'package:esoteric_circle/core/horoscope/la_lettura_cinese.dart';
import 'package:esoteric_circle/core/horoscope/la_lettura_vedica.dart';
import 'package:esoteric_circle/core/horoscope/le_ore_del_giorno.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/tokens/color_tokens.dart';
import 'package:esoteric_circle/features/horoscope/le_ore_del_giorno_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LE ORE DEL GIORNO.** Il fondatore, 1 ottobre 2026: *"vorrei
/// infografica a colori anche per oroscopo giornaliero come per
/// settimanale, mensile e annuale, se possibile. Magari inserendo le 24h e
/// indicando le ore migliori oppure una tua idea se migliore e più
/// esplicativa e adatta."*
///
/// Si misura, per una settimana a Roma:
/// - le ventiquattro ore planetarie vanno dall'alba all'alba dopo senza
///   buchi, le dodici del giorno lunghe uguale fra loro (cosi' le dodici
///   della notte), e la prima ha il signore del giorno, poi l'ordine caldeo
///   (Lilly, Christian Astrology, libro I);
/// - il livello di ogni ora e' quello del giorno spostato di un gradino dal
///   pianeta dell'ora, con la regola scritta in [LeOreDelGiorno];
/// - nella Vedica le ore che toccano il Rahu Kalam sono a 2;
/// - le dodici ore doppie cinesi hanno il ramo dell'ora e il tronco della
///   regola dei cinque topi (il giorno Jia apre col Topo Jia, il giorno Bing
///   col Topo Wu);
/// - le barre non sono tutte uguali;
/// - a video, a 360 punti, al carattere normale e massimo: una barra per ora
///   del colore del suo livello e la riga delle ore migliori, nessun pixel che
///   trabocca.
void main() {
  const roma = (41.9028, 12.4964);

  test('le ore planetarie, dall\'alba all\'alba, col signore giusto', () {
    final colpe = <String>[];
    final righe = <String>[];
    var giorni = 0;
    for (var k = 0; k < 7; k++) {
      final g = DateTime(2026, 10, 1 + k);
      final ore = LeOreDelGiorno.planetarie(
          giorno: g,
          livelliDelGiorno: const [3, 3, 3, 3],
          lat: roma.$1,
          lon: roma.$2);
      giorni++;
      if (ore.length != 24) colpe.add('$g: ${ore.length} ore');
      for (var i = 1; i < ore.length; i++) {
        if (ore[i].da != ore[i - 1].a) colpe.add('$g: buco dopo l\'ora $i');
      }
      final diGiorno = ore.take(12).map((o) => o.a.difference(o.da).inMinutes);
      final diNotte = ore.skip(12).map((o) => o.a.difference(o.da).inMinutes);
      if (diGiorno.toSet().length > 2 || diNotte.toSet().length > 2) {
        colpe.add('$g: le ore non sono uguali fra loro');
      }
      final primo = LeOreDelGiorno.signoreDelGiorno[g.weekday]!;
      if (ore.first.signore != primo) {
        colpe
            .add('$g: la prima ora e\' di ${ore.first.signore}, non di $primo');
      }
      final i0 = LeOreDelGiorno.caldeo.indexOf(primo);
      for (var i = 0; i < 24; i++) {
        if (ore[i].signore != LeOreDelGiorno.caldeo[(i0 + i) % 7]) {
          colpe.add('$g: l\'ora $i fuori dall\'ordine caldeo');
        }
      }
      righe.add(
          '${g.day}/${g.month}: alba ${LeOreDelGiornoView.hm(ore.first.da)}, '
          'tramonto ${LeOreDelGiornoView.hm(ore[12].da)}, ore del giorno di '
          '${diGiorno.first} minuti, prima ora di ${ore.first.signore!.nome}');
    }
    cardinaleMinimo(giorni, 7, cosa: 'giorni guardati');
    print('LE ORE DEL GIORNO: difetti ${colpe.length}\n${righe.join('\n')}');
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  test('il livello dell\'ora segue il pianeta dell\'ora', () {
    final ore = LeOreDelGiorno.planetarie(
        giorno: DateTime(2026, 10, 1),
        livelliDelGiorno: const [3, 3, 3, 3],
        lat: roma.$1,
        lon: roma.$2);
    var guardate = 0;
    final distinti = <HoroscopeDomain, Set<int>>{};
    for (final o in ore) {
      for (final d in HoroscopeDomain.values) {
        guardate++;
        expect(o.livelli[d.index],
            (3 + LeOreDelGiorno.spostamento(o.signore!, d)).clamp(1, 5));
        (distinti[d] ??= {}).add(o.livelli[d.index]);
      }
    }
    // Il giovedi' la prima ora e' di Giove: per la Fortuna sale.
    expect(ore.first.signore, CorpoCeleste.giove);
    expect(ore.first.livelli[HoroscopeDomain.fortuna.index], 4);
    cardinaleMinimo(guardate, 96, cosa: 'ore per dominio');
    for (final d in HoroscopeDomain.values) {
      expect(distinti[d]!.length, greaterThanOrEqualTo(2),
          reason: '${d.name}: ventiquattro barre uguali');
    }
    print('LE ORE DEL GIORNO: livelli distinti per dominio '
        '${[for (final d in HoroscopeDomain.values) distinti[d]!.length]}');
  });

  test('nella Vedica il Rahu Kalam porta l\'ora a 2', () {
    const luogo = LuogoDelGiorno(lat: 41.9028, lon: 12.4964, citta: 'Roma');
    final g = DateTime(2026, 10, 1);
    final rahu = LaLetturaVedica.rahuKalam(g, luogo)!;
    final ore = LeOreDelGiorno.planetarie(
        giorno: g,
        livelliDelGiorno: const [5, 5, 5, 5],
        lat: luogo.lat,
        lon: luogo.lon,
        rahu: rahu);
    final nelRahu = ore.where((o) => o.rahu).toList();
    expect(nelRahu, isNotEmpty);
    for (final o in nelRahu) {
      expect(o.livelli, [2, 2, 2, 2]);
    }
    print('LE ORE DEL GIORNO: Rahu Kalam dalle '
        '${LeOreDelGiornoView.hm(rahu.$1.toLocal())} alle '
        '${LeOreDelGiornoView.hm(rahu.$2.toLocal())}, ore a 2: '
        '${nelRahu.length}');
  });

  // **LE ORE MIGLIORI FRA QUELLE CHE DEVONO ANCORA FINIRE.** Visto sul
  // Realme il 1 ottobre 2026 alle 10:00: la Vedica diceva "Le ore migliori:
  // dalle 07:06 alle 08:05 e dalle 09:04 alle 11:01", e la prima era gia'
  // passata. Si guarda ogni mezz'ora dalle 7 alle 22 di una settimana a
  // Roma, nelle quattro schede: nessuna fascia detta e' gia' finita.
  test('le ore migliori non sono gia\' passate', () {
    final colpe = <String>[];
    var guardate = 0;
    for (var k = 0; k < 7; k++) {
      final g = DateTime(2026, 10, 1 + k);
      final ore = LeOreDelGiorno.planetarie(
          giorno: g,
          livelliDelGiorno: const [3, 4, 2, 3],
          lat: roma.$1,
          lon: roma.$2);
      for (var m = 7 * 60; m <= 22 * 60; m += 30) {
        final adesso = DateTime(g.year, g.month, g.day, m ~/ 60, m % 60);
        for (final d in HoroscopeDomain.values) {
          guardate++;
          for (final (da, a)
              in LeOreDelGiorno.migliori(ore, d, adesso: adesso)) {
            if (!a.isAfter(adesso)) {
              colpe.add('${g.day}/${g.month} alle '
                  '${LeOreDelGiornoView.hm(adesso)}, ${d.name}: dalle '
                  '${LeOreDelGiornoView.hm(da)} alle '
                  '${LeOreDelGiornoView.hm(a)}, gia\' finita');
            }
          }
        }
      }
    }
    cardinaleMinimo(guardate, 7 * 31 * 4, cosa: 'momenti guardati');
    print('LE ORE DEL GIORNO: fasce migliori gia\' finite ${colpe.length}, '
        'in $guardate momenti guardati');
    expect(colpe, isEmpty, reason: colpe.take(8).join('\n'));
  });

  test('la didascalia della Vedica dice le ore del Rahu Kalam', () {
    const luogo = LuogoDelGiorno(lat: 41.9028, lon: 12.4964, citta: 'Roma');
    final rahu = LaLetturaVedica.rahuKalam(DateTime(2026, 10, 1), luogo)!;
    final riga = LeOreDelGiornoView.didascaliaVedica(rahu);
    print('LE ORE DEL GIORNO: "$riga"');
    expect(
        riga,
        contains('Dalle ${LeOreDelGiornoView.hm(rahu.$1.toLocal())} '
            'alle ${LeOreDelGiornoView.hm(rahu.$2.toLocal())}'));
    expect(riga, contains('Rahu Kalam'));
    expect(LeOreDelGiornoView.didascaliaVedica(null), isNot(contains('Rahu')));
  });

  test('le dodici ore doppie cinesi, col ramo e coi cinque topi', () {
    var giornoJia = DateTime(2026, 10, 1);
    while (LAlmanaccoCinese.tronco(giornoJia) != 0) {
      giornoJia = giornoJia.add(const Duration(days: 1));
    }
    final giornoBing = giornoJia.add(const Duration(days: 2));
    expect(LAlmanaccoCinese.tronco(giornoBing), 2);
    for (final (g, topo) in [(giornoJia, 0), (giornoBing, 4)]) {
      final ore = LeOreDelGiorno.cinesi(giorno: g, animale: 6, signore: 3);
      expect(ore, hasLength(12));
      expect(ore.first.ramo, 0);
      expect(ore.first.da.hour, 23);
      for (final o in ore) {
        expect(
            o.livelli.first,
            LaLetturaCinese.livelloDelRapporto(
                LAlmanaccoCinese.rapporto(6, o.ramo!)));
        final dio = LAlmanaccoCinese.dio(3, (topo + o.ramo!) % 10);
        expect(o.livelli[HoroscopeDomain.carriera.index],
            LaLetturaCinese.livelloDelDio(HoroscopeDomain.carriera, dio));
      }
    }
  });

  for (final scala in const [1.0, 2.0]) {
    testWidgets('le ventiquattro barre a video alla scala $scala',
        (tester) async {
      final ore = LeOreDelGiorno.planetarie(
          giorno: DateTime(2026, 10, 1),
          livelliDelGiorno: const [3, 4, 2, 3],
          lat: roma.$1,
          lon: roma.$2);
      final adesso = DateTime(2026, 10, 1, 10, 30);
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
              size: const Size(360, 800),
              textScaler: TextScaler.linear(scala),
              disableAnimations: true),
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(32),
              child: SingleChildScrollView(
                child: LeOreDelGiornoView(
                    ore: ore,
                    dominio: HoroscopeDomain.amore,
                    palette: MaestroPalette.medora,
                    didascalia: 'Le ore planetarie.',
                    adesso: adesso),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
      var barre = 0;
      for (var i = 0; i < ore.length; i++) {
        final b = find.byKey(Key('oroscopo_ora_barra_amore_$i'));
        expect(b, findsOneWidget);
        barre++;
        final colore =
            ((tester.widget<Container>(b).decoration as BoxDecoration).color)!;
        expect(colore, ColorTokens.delLivello(ore[i].livelli[1]));
      }
      cardinaleMinimo(barre, 24, cosa: 'barre delle ore');
      final riga = tester
          .widget<Text>(find.byKey(const Key('oroscopo_ore_migliori_amore')))
          .data!;
      print('LE ORE DEL GIORNO A VIDEO, scala $scala: barre $barre, "$riga"');
      expect(riga, startsWith('L'));
      // **LE ORE MIGLIORI SULLE BARRE E L'ORA DI ADESSO** (il fondatore, la
      // stessa sera: "come posso aumentare l'esperienza utente?"): un punto
      // d'oro sopra ogni ora delle fasce dette nella riga, nessuno sulle
      // altre; un segno solo sotto l'ora che contiene adesso.
      final fasce =
          LeOreDelGiorno.migliori(ore, HoroscopeDomain.amore, adesso: adesso);
      var punti = 0, attesi = 0;
      for (var i = 0; i < ore.length; i++) {
        final dentro = fasce
            .any((f) => !ore[i].da.isBefore(f.$1) && !ore[i].a.isAfter(f.$2));
        if (dentro) attesi++;
        final c = find.byKey(Key('oroscopo_ora_migliore_amore_$i'));
        if (c.evaluate().isNotEmpty) punti++;
        expect(c.evaluate().isNotEmpty, dentro, reason: 'ora $i');
      }
      expect(find.byKey(const Key('oroscopo_ora_adesso_amore')), findsOneWidget,
          reason: 'l\'ora di adesso non e\' segnata');
      // E la sua barra ha il bordo chiaro, una sola.
      var conIlBordo = 0;
      for (var i = 0; i < ore.length; i++) {
        final d = tester
            .widget<Container>(find.byKey(Key('oroscopo_ora_barra_amore_$i')))
            .decoration as BoxDecoration;
        if (d.border != null) {
          conIlBordo++;
          expect(
              !adesso.isBefore(ore[i].da) && adesso.isBefore(ore[i].a), isTrue,
              reason: 'il bordo sta su un\'ora che non e\' quella di adesso');
        }
      }
      expect(conIlBordo, 1, reason: 'barre col bordo di adesso: $conIlBordo');
      print('LE ORE DEL GIORNO A VIDEO, scala $scala: punti d\'oro $punti su '
          '$attesi ore migliori, segno di adesso 1');
      expect(attesi, greaterThan(0));
    });
  }
}

// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/astro/l_alba_e_il_tramonto.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/account/notifiche_screen.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/l_ora_d_oro.dart';
import 'package:esoteric_circle/core/horoscope/la_lettura_vedica.dart';
import 'package:esoteric_circle/core/horoscope/le_chiamate_del_cielo.dart';
import 'package:esoteric_circle/core/rituals/avvisi_del_rito.dart';
import 'package:esoteric_circle/core/rituals/scelta_degli_avvisi.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/services/avvisi_locali.dart';
import 'package:esoteric_circle/services/regia_delle_chiamate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';
import 'istante_dichiarato.dart';

/// **L'ORA D'ORO E IL RAHU KALAM CHIAMANO. Ordine ES voce 32, 29 settembre
/// 2026.**
///
/// La voce: *"Mancano le due notifiche (un quarto d'ora prima dell'ora d'oro
/// e il Rahu Kalam del mattino)"*. Qui si prova che partono all'ora giusta,
/// col testo giusto, sul canale giusto, solo quando c'e' cio' che serve, e
/// che nessuna resta orfana quando si riprogramma. Che l'ora d'oro sia
/// quella del cielo lo prova `l_ora_d_oro_e_quella_del_cielo_test.dart`; che
/// il Rahu Kalam sia quello di Drik Panchang, `la_lettura_vedica_test.dart`.
class _Telefono extends ServizioAvvisi {
  final Map<
      int,
      ({
        DateTime quando,
        String titolo,
        String testo,
        String canale,
        String carico
      })> programmati = {};
  final List<int> annullati = [];

  @override
  bool get disponibile => true;
  @override
  Future<bool> chiediPermesso() async => true;
  @override
  Future<bool> permessoConcesso() async => true;
  @override
  Future<void> programma({
    required int id,
    required DateTime quando,
    required String titolo,
    required String testo,
    String canale = 'rito_alba',
    String carico = '',
  }) async {
    programmati[id] = (
      quando: quando,
      titolo: titolo,
      testo: testo,
      canale: canale,
      carico: carico
    );
  }

  @override
  Future<void> annulla(int id) async {
    annullati.add(id);
    programmati.remove(id);
  }

  @override
  Future<List<int>> inAttesa() async => programmati.keys.toList();

  @override
  Future<void> mostraAdesso(
      {required String titolo, required String testo}) async {}
}

String _hhmm(DateTime t) {
  final l = t.toLocal();
  return '${l.hour.toString().padLeft(2, '0')}:'
      '${l.minute.toString().padLeft(2, '0')}';
}

void main() {
  // Una carta dai dieci giorni di controllo dell'ora d'oro: la prima riga
  // con un aspetto.
  final righe = File('docs/collaudo/ES/ore_d_oro.csv')
      .readAsLinesSync()
      .skip(1)
      .where((r) => r.trim().isNotEmpty)
      .map((r) => r.split(','))
      .toList();
  PlanetPosition punto(String id, double l) => PlanetPosition(
      id: id,
      name: id,
      glyph: '',
      longitude: l,
      sign: Zodiac.values[(l ~/ 30) % 12]);
  NatalChart carta(List<String> c) => NatalChart(
        sunSign: Zodiac.values[(double.parse(c[1]) ~/ 30) % 12],
        planets: [
          punto('sun', double.parse(c[1])),
          punto('venus', double.parse(c[2])),
          punto('jupiter', double.parse(c[3])),
        ],
        ascendantLongitude: 0,
        midheavenLongitude: 270,
        houses: const [],
        hasTime: true,
      );
  const roma = LuogoDelGiorno(lat: 41.9, lon: 12.5, citta: 'Roma');

  test(
      'l\'ora d\'oro chiama un quarto d\'ora prima, solo nei giorni in cui '
      'c\'e\'', () async {
    var giorniConLOra = 0;
    var giorniSenza = 0;
    final sbagliate = <String>[];
    for (final c in righe) {
      final g = DateTime.parse(c[0]);
      final adesso = DateTime(g.year, g.month, g.day);
      final tel = _Telefono();
      final fatti = await LeChiamateDelCielo.programma(
        servizio: tel,
        adesso: adesso,
        carta: carta(c),
        oraDOro: true,
        rahuKalam: false,
      );
      for (var i = 0; i < LeChiamateDelCielo.giorni; i++) {
        final giorno = DateTime(g.year, g.month, g.day + i);
        final o = LOraDOro.di(carta(c), giorno);
        final id = LeChiamateDelCielo.primoIdDellOraDOro + i;
        final avviso = tel.programmati[id];
        final atteso =
            o?.istante.toLocal().subtract(const Duration(minutes: 15));
        if (atteso == null || !atteso.isAfter(adesso)) {
          giorniSenza++;
          if (avviso != null) {
            sbagliate.add('${c[0]}+$i: chiama senza ora d\'oro');
          }
          continue;
        }
        giorniConLOra++;
        if (avviso == null) {
          sbagliate.add('${c[0]}+$i: l\'ora d\'oro alle ${_hhmm(o!.istante)} '
              'non chiama');
          continue;
        }
        if (avviso.quando != atteso ||
            avviso.canale != 'ora_d_oro' ||
            avviso.carico != AvvisiDelRito.caricoOroscopo ||
            !avviso.testo.contains('Alle ${_hhmm(o!.istante)} la Luna forma')) {
          sbagliate.add('${c[0]}+$i: ${avviso.quando} ${avviso.canale} '
              '"${avviso.testo}", atteso $atteso');
        }
      }
      expect(fatti.toSet(), tel.programmati.keys.toSet());
    }
    print('ORDINE ES VOCE 32: giorni con l\'ora d\'oro $giorniConLOra, senza '
        '$giorniSenza, avvisi sbagliati o mancanti ${sbagliate.length}: '
        '$sbagliate');
    cardinaleMinimo(giorniConLOra, 20, cosa: 'giorni con l\'ora d\'oro');
    expect(giorniSenza, greaterThan(0),
        reason: 'nessun giorno senza ora d\'oro: la prova non vede i silenzi');
    expect(sbagliate, isEmpty);
  });

  test('il Rahu Kalam chiama all\'alba, prima che cominci, con le sue ore',
      () async {
    final tel = _Telefono();
    // Dalle nove del mattino: l'alba di oggi e' passata e oggi non chiama.
    final adesso = DateTime(2026, 10, 5, 9);
    await LeChiamateDelCielo.programma(
      servizio: tel,
      adesso: adesso,
      luogo: roma,
      oraDOro: true,
      rahuKalam: true,
    );
    final sbagliate = <String>[];
    for (var i = 0; i < LeChiamateDelCielo.giorni; i++) {
      final giorno = DateTime(2026, 10, 5 + i);
      final id = LeChiamateDelCielo.primoIdDelRahuKalam + i;
      final avviso = tel.programmati[id];
      final e = LAlbaEIlTramonto.delGiorno(giorno,
          lat: roma.lat,
          lon: roma.lon,
          offset: DateTime(giorno.year, giorno.month, giorno.day, 12)
              .timeZoneOffset);
      final rk = LaLetturaVedica.rahuKalam(giorno, roma)!;
      if (i == 0) {
        if (avviso != null) sbagliate.add('oggi chiama dopo l\'alba');
        continue;
      }
      if (avviso == null) {
        sbagliate.add('$giorno: non chiama');
        continue;
      }
      if (avviso.quando != e!.alba.toLocal() ||
          !avviso.quando.isBefore(rk.$1.toLocal()) ||
          avviso.canale != 'rahu_kalam' ||
          avviso.testo !=
              'Oggi a Roma il Rahu Kalam va dalle ${_hhmm(rk.$1)} alle '
                  '${_hhmm(rk.$2)}: la tradizione vedica non gli affida gli '
                  'inizi.') {
        sbagliate.add('$giorno: ${avviso.quando} "${avviso.testo}"');
      }
    }
    print('ORDINE ES VOCE 32: Rahu Kalam, avvisi ${tel.programmati.length} in '
        'sette giorni dalle nove, sbagliati $sbagliate');
    expect(sbagliate, isEmpty);
    // Senza carta l'ora d'oro non chiama mai.
    expect(
        tel.programmati.keys
            .where((id) => id < LeChiamateDelCielo.primoIdDelRahuKalam),
        isEmpty);
  });

  test('ogni giro annulla le quattordici di prima, e gli spenti non chiamano',
      () async {
    final tel = _Telefono();
    await LeChiamateDelCielo.programma(
        servizio: tel,
        adesso: DateTime(2026, 10, 5),
        carta: carta(righe[1]),
        luogo: roma,
        oraDOro: true,
        rahuKalam: true);
    expect(tel.programmati, isNotEmpty);
    await LeChiamateDelCielo.programma(
        servizio: tel,
        adesso: DateTime(2026, 10, 5),
        carta: carta(righe[1]),
        luogo: roma,
        oraDOro: false,
        rahuKalam: false);
    expect(tel.annullati.toSet(), LeChiamateDelCielo.tuttiGliId.toSet());
    expect(tel.programmati, isEmpty,
        reason: 'spenti tutti e due, restano chiamate in coda');
    // Gli id non pestano quelli di nessun altro avviso.
    expect(LeChiamateDelCielo.tuttiGliId.toSet().intersection({90001, 90404}),
        isEmpty);
    // E i due canali esistono, col loro nome.
    expect(AvvisiLocali.canali.keys, containsAll(['ora_d_oro', 'rahu_kalam']));
  });

  testWidgets('la regia: il Rahu Kalam solo a chi ha letto la Vedica',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'luogo.attuale': jsonEncode({
        'lat': 41.9,
        'lon': 12.5,
        'nome': 'Roma',
        'origine': 'scelto',
      }),
    });
    final scelta = SceltaDegliAvvisi();
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await tester.runAsync(() async {
      await scelta.carica();
      await diario.carica();
    });
    late BuildContext ctx;
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<SceltaDegliAvvisi>.value(value: scelta),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
      ],
      child: Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      }),
    ));
    final tel = _Telefono();
    List<int> rahu(List<int> ids) => ids
        .where((id) =>
            id >= LeChiamateDelCielo.primoIdDelRahuKalam &&
            id < LeChiamateDelCielo.primoIdDelRahuKalam + 7)
        .toList();
    late List<int> prima;
    await tester.runAsync(() async {
      prima = await RegiaDelleChiamate.riprogramma(ctx, servizio: tel);
    });
    await tester.runAsync(() async {
      await diario.segna('oroscopo',
          dettagli: {'periodo': 'giorno', 'tradizione': 'vedica'});
    });
    late List<int> dopo;
    await tester.runAsync(() async {
      dopo = await RegiaDelleChiamate.riprogramma(ctx, servizio: tel);
    });
    await tester.runAsync(() => scelta.scegliIlRahuKalam(false));
    late List<int> spento;
    await tester.runAsync(() async {
      spento = await RegiaDelleChiamate.riprogramma(ctx, servizio: tel);
    });
    print('ORDINE ES VOCE 32: avvisi del Rahu Kalam prima di leggere la '
        'Vedica ${rahu(prima).length}, dopo ${rahu(dopo).length}, spento '
        '${rahu(spento).length}');
    expect(rahu(prima), isEmpty,
        reason: 'chi non ha mai letto la Vedica riceve il Rahu Kalam');
    expect(rahu(dopo).length, greaterThanOrEqualTo(6),
        reason: 'chi legge la Vedica e ha la citta\' non lo riceve');
    expect(rahu(spento), isEmpty, reason: 'spento, chiama ancora');
  });

  testWidgets('nel menu Notifiche le due chiamate del cielo si spengono',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    // Alta abbastanza da costruire tutta la pagina: le due righe del cielo
    // stanno sotto i Doni, e una lista pigra non costruisce cio' che non si
    // vede.
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final scelta = SceltaDegliAvvisi();
    await tester.runAsync(scelta.carica);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider<SceltaDegliAvvisi>.value(value: scelta),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: NotificheScreen(avvisi: _Telefono()),
      ),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    // Accese di partenza, come i Doni, per la regola del fondatore.
    expect(scelta.chiamaLOraDOro, isTrue);
    expect(scelta.chiamaIlRahuKalam, isTrue);
    final interruttore =
        find.byKey(const Key('notifiche_interruttore_cielo_ora_d_oro'));
    await tester.scrollUntilVisible(interruttore, 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.byKey(const Key('notifiche_cielo_rahu_kalam')), findsOneWidget,
        reason: 'nel menu manca la riga del Rahu Kalam');
    await tester.tap(interruttore);
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    final prefs = await SharedPreferences.getInstance();
    print('ORDINE ES VOCE 32: dopo il tocco l\'ora d\'oro chiama '
        '${scelta.chiamaLOraDOro}, sul disco '
        '${prefs.getBool(SceltaDegliAvvisi.chiaveDellOraDOro)}');
    expect(scelta.chiamaLOraDOro, isFalse,
        reason: 'il tocco non spegne l\'ora d\'oro');
    expect(prefs.getBool(SceltaDegliAvvisi.chiaveDellOraDOro), isFalse);
    expect(scelta.chiamaIlRahuKalam, isTrue,
        reason: 'spegnere l\'ora d\'oro ha spento anche il Rahu Kalam');
  });
}

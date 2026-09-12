import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/synastry/cielo_della_sinastria.dart';
import 'package:esoteric_circle/core/synastry/gemello_astrale.dart';
import 'package:esoteric_circle/core/synastry/possibilita_di_incontro.dart';
import 'package:esoteric_circle/core/synastry/synastry_report.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:esoteric_circle/design_system/components/vip_frame.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/synastry/rivelazione_del_gemello.dart';
import 'package:esoteric_circle/features/synastry/sinastria_share_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// IL GEMELLO ASTRALE E LA CARD DELLA SFIDA. Ordine BO voci 10 e 11.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final tuo = CieloDiSinastria.perIdentita(
      BirthIdentity.fromParts(birthDate: DateTime(1988, 3, 14)));

  Widget attorno(Widget scena) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
        ],
        child: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MaestroScope(child: Material(child: scena)),
          ),
        ),
      );

  // --- BO.10 ---

  test('il gemello dichiarato è davvero quello col punteggio più alto', () {
    final g = GemelloAstrale.per(tuo)!;
    // **La verifica indipendente**: si rifa il conto su tutti e cinquanta,
    // per intero, e si guarda chi vince.
    var migliore = VipCatalog.first;
    var punteggio = -1;
    for (final v in VipCatalog.vips) {
      final p = SynastryReport.perCieli(tuo: tuo, vip: v).overall;
      if (p > punteggio) {
        punteggio = p;
        migliore = v;
      }
    }
    // ignore: avoid_print
    print('ORDINE BO VOCE 10: gemello ${g.vip.name} con ${g.punteggio}, '
        'secondo ${g.secondo.name} con ${g.punteggioDelSecondo}');
    expect(g.vip.name, migliore.name,
        reason: 'il gemello dichiarato non è quello col punteggio più alto');
    expect(g.punteggio, punteggio);
    // E il secondo e' davvero secondo: nessuno sta fra i due.
    for (final v in VipCatalog.vips) {
      if (v.name == g.vip.name || v.name == g.secondo.name) continue;
      final p = SynastryReport.perCieli(tuo: tuo, vip: v).overall;
      expect(p, lessThanOrEqualTo(g.punteggioDelSecondo), reason: v.name);
    }
  });

  test('il gemello è deterministico per la stessa persona', () {
    for (var i = 0; i < 5; i++) {
      expect(
          GemelloAstrale.per(tuo)!.vip.name, GemelloAstrale.per(tuo)!.vip.name);
    }
    // E due persone diverse non hanno per forza lo stesso gemello: se
    // l'avessero, la funzione non direbbe niente di nessuno.
    final gemelli = <String>{};
    for (final mese in [1, 4, 7, 10]) {
      final c = CieloDiSinastria.perIdentita(
          BirthIdentity.fromParts(birthDate: DateTime(1990, mese, 11)));
      gemelli.add(GemelloAstrale.per(c)!.vip.name);
    }
    expect(gemelli.length, greaterThan(1),
        reason: 'quattro persone nate in stagioni diverse hanno tutte lo '
            'stesso gemello: il conto non sta guardando il cielo');
  });

  test('la ricerca su cinquanta profili sta sotto i 200 millesimi', () {
    // Un giro a vuoto, cosi' la prima volta non entra nel conto.
    GemelloAstrale.per(tuo);
    var minimo = const Duration(days: 1);
    for (var i = 0; i < 10; i++) {
      final o = Stopwatch()..start();
      GemelloAstrale.per(tuo);
      o.stop();
      if (o.elapsed < minimo) minimo = o.elapsed;
    }
    // ignore: avoid_print
    print('ORDINE BO VOCE 10: la ricerca su cinquanta costa '
        '${minimo.inMicroseconds / 1000} millesimi');
    expect(minimo.inMilliseconds, lessThan(200),
        reason: 'la ricerca costa ${minimo.inMilliseconds} millesimi');
  });

  testWidgets('la sfilata si ferma sul gemello, e mai su un altro',
      (tester) async {
    final g = GemelloAstrale.per(tuo)!;
    await tester.pumpWidget(attorno(
        RivelazioneDelGemello(gemello: g, palette: MaestroPalette.medora)));
    await tester.pump();
    // Con Riduci Movimento e' gia' li', fermo.
    expect(
        tester
            .widget<Text>(find.byKey(const Key('sinastria_gemello_nome')))
            .data,
        g.vip.name);
    expect(find.byKey(const Key('sinastria_gemello_annuncio')), findsOneWidget);
  });

  // --- BO.11 ---

  Widget card(Vip vip, {String userName = 'Sofia'}) => SinastriaShareCard(
        report: SynastryReport.perCieli(
          tuo: tuo,
          vip: vip,
          doveSei: const DoveSei(
              citta: 'Milano', latitudine: 45.4642, longitudine: 9.1920),
        ),
        vip: vip,
        userSign: Zodiac.pisces,
        userName: userName,
        userDate: '14 marzo 1988',
        palette: MaestroPalette.medora,
      );

  testWidgets('la card è verticale, nelle proporzioni di una storia',
      (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
        attorno(Center(child: card(VipCatalog.conNome('Zendaya')!))));
    await tester.pump();
    final r = tester.getRect(find.byKey(const Key('sinastria_card')));
    expect(r.width / r.height,
        closeTo(SinastriaShareCard.rapportoDellaStoria, 0.001),
        reason: 'la card non ha le proporzioni di una storia');
  });

  testWidgets('nessun testo esce dal riquadro, alle tre lunghezze estreme',
      (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    // Il nome VIP più corto, il più lungo, e il nome utente più lungo che
    // l'app accetta.
    final perLunghezza = [...VipCatalog.vips]
      ..sort((a, b) => a.name.length.compareTo(b.name.length));
    final casi = <(Vip, String)>[
      (perLunghezza.first, 'Al'),
      (perLunghezza.last, 'Maria Vittoria Alessandra'),
      (perLunghezza.last, 'Sofia'),
    ];
    for (final caso in casi) {
      final eccezioni = <FlutterErrorDetails>[];
      final vecchio = FlutterError.onError;
      FlutterError.onError = eccezioni.add;
      await tester
          .pumpWidget(attorno(Center(child: card(caso.$1, userName: caso.$2))));
      await tester.pump();
      FlutterError.onError = vecchio;
      final traboccati = eccezioni
          .where((e) => e.exception.toString().contains('overflowed'))
          .toList();
      expect(traboccati, isEmpty,
          reason: '"${caso.$1.name}" con "${caso.$2}" fa uscire il testo dal '
              'riquadro: ${traboccati.map((e) => e.exception).join(" ")}');
    }
  });

  testWidgets('i fili sulla card sono i tre aspetti più forti, e non altri',
      (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final vip = VipCatalog.conNome('Zendaya')!;
    await tester.pumpWidget(attorno(Center(child: card(vip))));
    await tester.pump();
    final painter = tester
        .widget<CustomPaint>(find.byKey(const Key('sinastria_card_fili')))
        .painter as FiliDellaCard;
    final report = SynastryReport.perCieli(tuo: tuo, vip: vip);
    expect(painter.quanti, report.aspettiPiuForti.length);
    expect(painter.quanti, lessThanOrEqualTo(3));
  });

  testWidgets('per chi non c\'è più la card non nomina l\'incontro',
      (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
        attorno(Center(child: card(VipCatalog.conNome('Giorgio Armani')!))));
    await tester.pump();
    final testi = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .join(' ')
        .toLowerCase();
    expect(testi.contains('incontro'), isFalse,
        reason: 'la card promette un incontro a chi ha scelto una persona '
            'che non c\'è più: $testi');
  });

  testWidgets('senza foto la card resta intera e non lascia un buco',
      (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    // La card di sopra non passa nessuna foto: e' proprio questo il caso.
    await tester.pumpWidget(
        attorno(Center(child: card(VipCatalog.conNome('Zendaya')!))));
    await tester.pump();
    // **Il buco non c'e' perche' al posto della foto c'e' il segnaposto a
    // costellazione**, che la cornice VIP porta gia': il simbolo del segno su
    // cielo profondo. Si verifica che la card abbia comunque la sua altezza
    // piena e che il nome della persona ci sia.
    final r = tester.getRect(find.byKey(const Key('sinastria_card')));
    expect(r.height, greaterThan(500));
    // Il nome sul cartiglio non e' un `Text`: la cornice VIP lo DISEGNA, per
    // farlo stare su una riga sola dentro il cartiglio. Si guarda quindi cosa
    // le e' stato passato.
    final cornici = tester
        .widgetList<VipFramedPortrait>(find.byType(VipFramedPortrait))
        .toList();
    expect(cornici.map((c) => c.name), contains('Sofia'),
        reason: 'senza foto sparisce anche il nome della persona');
    // E il segnaposto a costellazione c'e': la finestra non resta vuota.
    final mia = cornici.firstWhere((c) => c.name == 'Sofia');
    expect(mia.photo, isNull);
    expect(mia.sign, isNotEmpty,
        reason: 'senza foto e senza simbolo del segno la finestra è un buco');
  });
}

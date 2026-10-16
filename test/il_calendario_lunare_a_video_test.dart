import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/lunario/il_giorno_lunare.dart';
import 'package:esoteric_circle/core/lunario/il_segno_del_giorno_tuo.dart';
import 'package:esoteric_circle/core/lunario/le_attivita_del_lunario.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/avvisi_del_rito.dart';
import 'package:esoteric_circle/core/sensi/la_suoneria.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/lunario/calendario_lunare_screen.dart';
import 'package:esoteric_circle/features/lunario/i_promemoria_del_lunario.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sopra_il_filmato.dart';

/// **IL CALENDARIO LUNARE A VIDEO.** Ordine FV voci FV.02, FV.05, FV.06,
/// FV.07, FV.08 e FV.09: la scena col video e il tocco che lo salta, il mese
/// di sette colonne dal lunedi' in italiano con oggi riconoscibile e la
/// cascata, il foglio del giorno, Trova il giorno con una valutazione finta,
/// i giorni tuoi con e senza ora, il promemoria (col permesso e senza) e
/// l'intenzione privata alla Luna nuova.
class _Finta implements LettoreDiScena {
  _Finta({this.fallira = false});
  final bool fallira;
  VoidCallback? _ascolta;
  bool _pronto = false, _fallito = false, _cominciato = false;
  bool _finito = false;
  int aperture = 0, avvii = 0, sospensioni = 0;

  @override
  bool get pronto => _pronto;
  @override
  bool get fallito => _fallito;
  @override
  bool get cominciato => _cominciato;
  @override
  bool get finito => _finito;
  @override
  void ascolta(VoidCallback? q) => _ascolta = q;
  @override
  Future<void> apri() async {
    aperture++;
    fallira ? _fallito = true : _pronto = true;
    _ascolta?.call();
  }

  @override
  Future<void> volume(double q) async {}
  @override
  Future<void> avvia() async => avvii++;
  @override
  Future<void> sospendi() async => sospensioni++;
  @override
  Widget disegna() => const ColoredBox(
      key: Key('finta_del_filmato_lunario'), color: Color(0xFF102030));
  @override
  void chiudi() {}

  void comincia() {
    _cominciato = true;
    _ascolta?.call();
  }

  void finisci() {
    _finito = true;
    _ascolta?.call();
  }
}

/// Il telefono finto degli avvisi: dice se il permesso c'e' e annota.
class _Telefono extends ServizioAvvisi {
  _Telefono({required this.permesso});
  final bool permesso;
  final programmati =
      <({int id, DateTime quando, String testo, String canale})>[];
  final annullati = <int>[];

  @override
  bool get disponibile => true;
  @override
  Future<bool> chiediPermesso() async => permesso;
  @override
  Future<bool> permessoConcesso() async => permesso;
  @override
  Future<void> programma({
    required int id,
    required DateTime quando,
    required String titolo,
    required String testo,
    String canale = 'rito_alba',
    String carico = '',
  }) async =>
      programmati.add((id: id, quando: quando, testo: testo, canale: canale));
  @override
  Future<void> annulla(int id) async => annullati.add(id);
  @override
  Future<List<int>> inAttesa() async => const [];
  @override
  Future<void> mostraAdesso(
      {required String titolo, required String testo}) async {}
  @override
  Future<void> mostraDelDono({
    required int id,
    required String titolo,
    required String testo,
    required String canale,
    String carico = '',
  }) async {}
}

/// Un ottobre 2026 finto e dichiarato: la Luna nuova il 10, la piena il 26;
/// il 20 la Luna entra in Vergine alle 14:32 ed e' fuori corso dalle 3:10
/// alle 5:40; tipo biodinamico frutto nei giorni pari.
List<GiornoLunare> _ottobre(int anno, int mese) {
  final n = DateTime(anno, mese + 1, 0).day;
  return [
    for (var d = 1; d <= n; d++)
      GiornoLunare(
        giorno: DateTime(anno, mese, d),
        elongazione: ((d - 10) * 12.2) % 360,
        illuminazione: 0.5,
        crescente: d >= 10 && d < 26,
        fase: d == 10
            ? FaseLunare.nuova
            : d == 26
                ? FaseLunare.piena
                : FaseLunare.crescente,
        segno: Zodiac.leo,
        cambiDiSegno: d == 20 && mese == 10
            ? [
                CambioDiSegno(
                    istante: DateTime(anno, mese, d, 14, 32),
                    segno: Zodiac.virgo)
              ]
            : const [],
        fuoriCorso: d == 20 && mese == 10
            ? [
                IntervalloFuoriCorso(
                    inizio: DateTime(anno, mese, d, 3, 10),
                    fine: DateTime(anno, mese, d, 5, 40))
              ]
            : const [],
        giornoLunare: ((d - 10) % 30) + 1,
        tipoBiodinamico: d.isEven ? TipoBiodinamico.frutto : null,
        lunaNuova: d == 10,
        lunaPiena: d == 26,
      ),
  ];
}

/// La valutazione finta: oro il 12 e il 20, da evitare il 5 e il 28.
EsitoDelGiorno _valuta(AttivitaDelLunario a, GiornoLunare g) {
  final d = g.giorno.day;
  if (d == 12 || d == 20) {
    return const EsitoDelGiorno(
        grado: GradoDelGiorno.oro,
        perche: ['Luna crescente', 'in Leone'],
        fonti: ['prova']);
  }
  if (d == 5 || d == 28) {
    return const EsitoDelGiorno(
        grado: GradoDelGiorno.evitare,
        perche: ['Luna calante'],
        fonti: ['prova']);
  }
  return const EsitoDelGiorno(
      grado: GradoDelGiorno.neutro, perche: [], fonti: []);
}

/// I quattro giorni tuoi finti di ottobre.
List<SegnoDelGiornoTuo> _giorniTuoi(BirthIdentity b, int anno, int mese) => [
      SegnoDelGiornoTuo(
          giorno: DateTime(anno, mese, 3),
          tipo: TipoDelGiornoTuo.ritornoLunare,
          titolo: 'Torna la tua Luna',
          testo: 'Prova del ritorno.'),
      SegnoDelGiornoTuo(
          giorno: DateTime(anno, mese, 7),
          tipo: TipoDelGiornoTuo.lunaSulTuoSole,
          titolo: 'La Luna sul tuo Sole',
          testo: 'Prova del Sole.'),
      SegnoDelGiornoTuo(
          giorno: DateTime(anno, mese, 8),
          tipo: TipoDelGiornoTuo.lunaNelTuoSegno,
          titolo: 'La Luna nel tuo segno',
          testo: 'Prova del segno.'),
      SegnoDelGiornoTuo(
          giorno: DateTime(anno, mese, 22),
          tipo: TipoDelGiornoTuo.faseDiNascita,
          titolo: 'Torna la fase della tua nascita',
          testo: 'Prova della fase.'),
    ];

Future<void> _monta(
  WidgetTester tester, {
  required List<_Finta> lettori,
  bool conOra = true,
  bool riduci = false,
  ServizioAvvisi? avvisi,
}) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(360, 797);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final finte = List.of(lettori);
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MaestroController()),
      ChangeNotifierProvider(create: (_) => QualityTierController()),
      ChangeNotifierProvider(
          create: (_) => SettingsController(suonoEVibrazione: true)),
      ChangeNotifierProvider(
          create: (_) => EntitlementService(initial: Tier.tier1)),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MediaQuery(
        data: MediaQueryData(
            size: const Size(360, 797), disableAnimations: riduci),
        child: MaestroScope(
          child: CalendarioLunareScreen(
            fabbricaDellaScena: () => finte.removeAt(0),
            adesso: () => DateTime(2026, 10, 15, 10, 5),
            identita: BirthIdentity(
                birthMoment: DateTime(1990, 5, 12, 14, 30),
                hasBirthTime: conOra),
            latitudine: 45.4,
            delMese: _ottobre,
            valuta: _valuta,
            giorniTuoi: _giorniTuoi,
            avvisi: avvisi ?? _Telefono(permesso: true),
          ),
        ),
      ),
    ),
  ));
  await tester.pump(const Duration(milliseconds: 100));
  // Le lune, gli emblemi e i sigilli sono asset veri (ordine FV voce FV.01):
  // senza precaricarli il loro decodificarsi vero resta a meta' nel tempo
  // finto delle prove, e il layout che dipende dalla loro misura non si
  // assesta.
  await tester.runAsync(() async {
    for (final e in find.byType(Image).evaluate()) {
      await precacheImage((e.widget as Image).image, e);
    }
  });
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _attendi(WidgetTester tester, int decimi) async {
  for (var i = 0; i < decimi; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// L'opacita' della Luna del giorno [d]: quella del castone dipinto.
double _accensione(WidgetTester tester, int d) => tester
    .widget<Image>(find
        .descendant(
            of: find.byKey(Key('lunario_luna_$d')),
            matching: find.byType(Image))
        .last)
    .opacity!
    .value;

void main() {
  setUp(() => LaSuoneria.spentaPerLeProve = false);
  tearDown(() => LaSuoneria.spentaPerLeProve = null);

  testWidgets('FV.02: il video parte, un tocco lo salta e il mese compare',
      (tester) async {
    final finta = _Finta();
    await _monta(tester, lettori: [finta]);
    expect(finta.aperture, 1);
    expect(finta.avvii, 1, reason: 'il video non parte all\'apertura');
    finta.comincia();
    await tester.pump();
    expect(find.byKey(const Key('finta_del_filmato_lunario')), findsOneWidget);
    expect(find.byKey(const Key('lunario_mese_titolo')), findsNothing,
        reason: 'col video in corso il mese non c\'e\'');
    await tester.tapAt(const Offset(180, 400));
    await _attendi(tester, 6);
    expect(finta.sospensioni, 1);
    expect(find.text('Ottobre 2026'), findsOneWidget);
    expect(find.byKey(const Key('il_tocco_che_salta')), findsNothing);
  });

  testWidgets(
      'FV.02: il video che non si carica lascia la scena ferma col mese',
      (tester) async {
    await _monta(tester, lettori: [_Finta(fallira: true)]);
    await _attendi(tester, 30);
    expect(find.text('Ottobre 2026'), findsOneWidget);
    expect(find.byKey(const Key('finta_del_filmato_lunario')), findsNothing);
  });

  testWidgets(
      'FV.05: sette colonne dal lunedì in italiano, il primo ottobre 2026 '
      'sotto il giovedì, oggi riconoscibile', (tester) async {
    await _monta(tester, lettori: [_Finta(fallira: true)]);
    await _attendi(tester, 30);
    const nomi = ['Lu', 'Ma', 'Me', 'Gi', 'Ve', 'Sa', 'Do'];
    for (var c = 0; c < 7; c++) {
      expect(
          find.descendant(
              of: find.byKey(Key('lunario_colonna_$c')),
              matching: find.text(nomi[c])),
          findsOneWidget);
    }
    // Il primo ottobre 2026 e' un giovedi': quarta colonna.
    final giovedi =
        tester.getCenter(find.byKey(const Key('lunario_colonna_3')));
    final primo = tester.getCenter(find.byKey(const Key('lunario_giorno_1')));
    expect((primo.dx - giovedi.dx).abs(), lessThan(1));
    final lunedi = tester.getCenter(find.byKey(const Key('lunario_colonna_0')));
    final cinque = tester.getCenter(find.byKey(const Key('lunario_giorno_5')));
    expect((cinque.dx - lunedi.dx).abs(), lessThan(1),
        reason: 'il 5 ottobre 2026 e\' lunedì');
    expect(find.byKey(const Key('lunario_giorno_31')), findsOneWidget);
    // Oggi, il 15: l'alone d'oro dietro la sua Luna e il numero in oro.
    expect(find.byKey(const Key('lunario_oggi_alone')), findsOneWidget);
    expect(
        find.descendant(
            of: find.byKey(const Key('lunario_giorno_15')),
            matching: find.byKey(const Key('lunario_oggi_numero'))),
        findsOneWidget);
  });

  testWidgets(
      'FV.05: le lune si accendono a cascata dalla Luna nuova; con Riduci '
      'Movimento tutte insieme', (tester) async {
    await _monta(tester, lettori: [_Finta(fallira: true)]);
    // A meta' cascata la Luna nuova (il 10) e' accesa, il 9 (l'ultimo
    // dell'ordine) ancora no.
    await _attendi(tester, 6);
    final nuova = _accensione(tester, 10);
    final ultimo = _accensione(tester, 9);
    expect(nuova, greaterThan(0.9));
    expect(ultimo, lessThan(0.1));
    expect(_accensione(tester, 11), greaterThan(_accensione(tester, 20)),
        reason: 'la cascata va dalla Luna nuova in avanti');
    await _attendi(tester, 30);
    expect(_accensione(tester, 9), 1.0);
  });

  testWidgets('FV.05: con Riduci Movimento le lune compaiono tutte insieme',
      (tester) async {
    await _monta(tester, lettori: [_Finta()], riduci: true);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Ottobre 2026'), findsOneWidget,
        reason: 'con Riduci Movimento la scena e\' subito ferma');
    final a = _accensione(tester, 10);
    expect(a, greaterThan(0));
    expect(a, lessThan(1));
    expect(_accensione(tester, 9), a, reason: 'tutte insieme in dissolvenza');
  });

  testWidgets(
      'FV.05: il foglio del giorno dice fase, segno e cambio, fuori corso, '
      'giorno lunare, tipo biodinamico e da dove viene', (tester) async {
    await _monta(tester, lettori: [_Finta(fallira: true)]);
    await _attendi(tester, 30);
    await tester.tap(find.byKey(const Key('lunario_giorno_20')));
    await _attendi(tester, 6);
    expect(find.byKey(const Key('lunario_foglio')), findsOneWidget);
    expect(
        tester
            .widget<Text>(find.byKey(const Key('lunario_foglio_titolo')))
            .data!
            .replaceAll('\n', ' '),
        'Luna crescente in Leone');
    final cielo = find.byKey(const Key('lunario_foglio_cielo'));
    String testo(Finder f) => tester
        .widgetList<RichText>(
            find.descendant(of: f, matching: find.byType(RichText)))
        .map((r) => r.text.toPlainText())
        .join(' ');
    expect(testo(cielo), contains('entra in Vergine alle 14:32'));
    expect(testo(cielo), contains('Fuori corso dalle 3:10 alle 5:40'));
    expect(testo(cielo), contains('giorno lunare 11'));
    expect(testo(cielo), contains('Giorno frutto'));
    expect(
        find.byKey(const Key('lunario_foglio_da_dove_viene')), findsOneWidget);
  });

  testWidgets(
      'FV.06: Trova il giorno accende d\'oro i giorni buoni, spegne quelli da '
      'evitare e al tocco dice il perché', (tester) async {
    await _monta(tester, lettori: [_Finta(fallira: true)]);
    await _attendi(tester, 30);
    expect(find.byKey(const Key('lunario_oro_12')), findsNothing);
    await tester.tap(find.byKey(const Key('lunario_emblema_orto')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('lunario_attivita_semina')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('lunario_scia')), findsOneWidget,
        reason: 'la scia d\'oro non passa sul mese');
    await _attendi(tester, 20);
    expect(find.byKey(const Key('lunario_oro_12')), findsOneWidget);
    expect(find.byKey(const Key('lunario_oro_20')), findsOneWidget);
    expect(find.byKey(const Key('lunario_oro_13')), findsNothing);
    expect(_accensione(tester, 5), closeTo(0.3, 0.01),
        reason: 'il giorno da evitare non si spegne');
    expect(_accensione(tester, 13), 1.0);
    // Orto: sotto le lune il tipo biodinamico.
    final sigilli = find.descendant(
        of: find.byKey(const Key('lunario_sigilli_14')),
        matching: find.byType(Image));
    expect(
        tester
            .widgetList<Image>(sigilli)
            .map((i) => (i.image as AssetImage).assetName),
        contains('assets/img/calendario_lunare/sig_thun_frutto_v1.webp'));
    await tester.tap(find.byKey(const Key('lunario_giorno_12')));
    await _attendi(tester, 6);
    expect(find.text('Giorno d\'oro per semina'), findsOneWidget);
    expect(find.byKey(const Key('lunario_foglio_perche')), findsOneWidget);
  });

  testWidgets(
      'FV.06: con Riduci Movimento niente scia, gli aloni in dissolvenza',
      (tester) async {
    await _monta(tester, lettori: [_Finta()], riduci: true);
    await _attendi(tester, 10);
    await tester.tap(find.byKey(const Key('lunario_emblema_orto')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('lunario_attivita_semina')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byKey(const Key('lunario_scia')), findsNothing);
    expect(find.byKey(const Key('lunario_oro_12')), findsOneWidget);
  });

  testWidgets('FV.07: i quattro giorni tuoi coi sigilli d\'oro',
      (tester) async {
    Iterable<String> sigilliDel(int d) => tester
        .widgetList<Image>(find.descendant(
            of: find.byKey(Key('lunario_sigilli_$d')),
            matching: find.byType(Image)))
        .map((i) => (i.image as AssetImage).assetName);
    await _monta(tester, lettori: [_Finta(fallira: true)]);
    await _attendi(tester, 30);
    expect(sigilliDel(3), contains(TipoDelGiornoTuo.ritornoLunare.sigillo));
    expect(sigilliDel(7), contains(TipoDelGiornoTuo.lunaSulTuoSole.sigillo));
    expect(sigilliDel(8), contains(TipoDelGiornoTuo.lunaNelTuoSegno.sigillo));
    expect(sigilliDel(22), contains(TipoDelGiornoTuo.faseDiNascita.sigillo));
    expect(find.byKey(const Key('lunario_invito_ora')), findsNothing);
  });

  testWidgets(
      'FV.07: senza ora tacciono i due della Luna di nascita e c\'è l\'invito',
      (tester) async {
    Iterable<String> sigilliDel(int d) => tester
        .widgetList<Image>(find.descendant(
            of: find.byKey(Key('lunario_sigilli_$d')),
            matching: find.byType(Image)))
        .map((i) => (i.image as AssetImage).assetName);
    await _monta(tester, lettori: [_Finta(fallira: true)], conOra: false);
    await _attendi(tester, 30);
    expect(sigilliDel(3), isEmpty);
    expect(sigilliDel(22), isEmpty);
    expect(sigilliDel(7), contains(TipoDelGiornoTuo.lunaSulTuoSole.sigillo));
    expect(sigilliDel(8), contains(TipoDelGiornoTuo.lunaNelTuoSegno.sigillo));
    expect(find.byKey(const Key('lunario_invito_ora')), findsOneWidget);
    expect(find.byKey(const Key('lunario_aggiungi_l_ora')), findsOneWidget);
  });

  testWidgets(
      'FV.08: il promemoria si fissa con un tocco, suona alle 20 del giorno '
      'prima, si vede sul mese e si toglie', (tester) async {
    final telefono = _Telefono(permesso: true);
    await _monta(tester, lettori: [_Finta(fallira: true)], avvisi: telefono);
    await _attendi(tester, 30);
    await tester.tap(find.byKey(const Key('lunario_emblema_orto')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('lunario_attivita_semina')));
    await _attendi(tester, 20);
    await tester.tap(find.byKey(const Key('lunario_giorno_20')));
    await _attendi(tester, 6);
    // Il foglio scorre: il pulsante puo' stare sotto la piega, non ancora
    // realizzato dallo scorrevole. Vedi WidgetController.ensureVisible.
    final fissa = find.byKey(const Key('lunario_fissa_promemoria'));
    await tester.scrollUntilVisible(fissa, 200,
        scrollable: find.descendant(
            of: find.byKey(const Key('lunario_foglio_scroll')),
            matching: find.byType(Scrollable)));
    // L'allineamento in cima allo scorrevole puo' spingere il centro del
    // pulsante appena fuori dalla finestra di prova: un centraggio lo
    // riporta dentro.
    await Scrollable.ensureVisible(tester.element(fissa), alignment: 0.5);
    await tester.pump();
    await tester.tap(fissa);
    await _attendi(tester, 3);
    expect(telefono.programmati, hasLength(1));
    expect(telefono.programmati.single.quando, DateTime(2026, 10, 19, 20));
    expect(telefono.programmati.single.canale, IPromemoriaDelLunario.canale);
    expect(telefono.programmati.single.testo,
        startsWith('Domani la Luna è giusta per semina'));
    expect(find.byKey(const Key('lunario_togli_promemoria')), findsOneWidget);
    // Chiuso il foglio, l'emblema piccolo della categoria sta sotto la Luna.
    await tester.tapAt(const Offset(180, 60));
    await _attendi(tester, 6);
    expect(
        tester
            .widgetList<Image>(find.descendant(
                of: find.byKey(const Key('lunario_sigilli_20')),
                matching: find.byType(Image)))
            .map((i) => (i.image as AssetImage).assetName),
        contains(CategoriaDelLunario.orto.emblema));
    // Il pannello scorre: stessa ragione del foglio, qui scorrevole suo.
    final togli = find.byWidgetPredicate((w) =>
        w.key is ValueKey<String> &&
        (w.key! as ValueKey<String>).value.startsWith('lunario_togli_2026'));
    await tester.scrollUntilVisible(togli, 200,
        scrollable: find
            .descendant(
                of: find.byKey(const Key('lunario_pannello_scroll')),
                matching: find.byType(Scrollable))
            .first);
    await Scrollable.ensureVisible(tester.element(togli), alignment: 0.5);
    await tester.pump();
    await tester.tap(togli);
    await _attendi(tester, 3);
    expect(telefono.annullati, hasLength(1));
    expect(togli, findsNothing);
  });

  testWidgets(
      'FV.08: senza permesso il promemoria resta segnato sul mese e l\'app lo '
      'dice', (tester) async {
    final telefono = _Telefono(permesso: false);
    await _monta(tester, lettori: [_Finta(fallira: true)], avvisi: telefono);
    await _attendi(tester, 30);
    await tester.tap(find.byKey(const Key('lunario_emblema_orto')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('lunario_attivita_semina')));
    await _attendi(tester, 20);
    await tester.tap(find.byKey(const Key('lunario_giorno_20')));
    await _attendi(tester, 6);
    await tester
        .ensureVisible(find.byKey(const Key('lunario_fissa_promemoria')));
    await tester.tap(find.byKey(const Key('lunario_fissa_promemoria')));
    await _attendi(tester, 3);
    expect(telefono.programmati, isEmpty);
    expect(find.textContaining('Gli avvisi del telefono sono spenti'),
        findsWidgets);
    await tester.tapAt(const Offset(180, 60));
    await _attendi(tester, 6);
    expect(find.byKey(const Key('lunario_senza_permesso')), findsOneWidget);
    expect(
        tester
            .widgetList<Image>(find.descendant(
                of: find.byKey(const Key('lunario_sigilli_20')),
                matching: find.byType(Image)))
            .map((i) => (i.image as AssetImage).assetName),
        contains(CategoriaDelLunario.orto.emblema));
  });

  testWidgets(
      'FV.09: il seme di luce sulla Luna nuova, l\'intenzione in una riga e '
      'l\'avviso alla Luna piena, senza l\'intenzione nel testo',
      (tester) async {
    final telefono = _Telefono(permesso: true);
    await _monta(tester, lettori: [_Finta(fallira: true)], avvisi: telefono);
    await _attendi(tester, 30);
    expect(find.byKey(const Key('lunario_seme_10')), findsOneWidget);
    expect(find.byKey(const Key('lunario_seme_11')), findsNothing);
    await tester.tap(find.byKey(const Key('lunario_giorno_10')));
    await _attendi(tester, 6);
    await tester.enterText(
        find.byKey(const Key('lunario_intenzione')), 'Ritrovare la calma');
    await tester
        .ensureVisible(find.byKey(const Key('lunario_affida_intenzione')));
    await tester.tap(find.byKey(const Key('lunario_affida_intenzione')));
    await _attendi(tester, 3);
    expect(telefono.programmati, hasLength(1));
    expect(telefono.programmati.single.quando.hour,
        IPromemoriaDelLunario.oraDellIntenzione);
    expect(telefono.programmati.single.testo, isNot(contains('calma')),
        reason: 'l\'intenzione non va sulla schermata di blocco');
    final p = await SharedPreferences.getInstance();
    expect(p.getString('lunario.intenzioni'), contains('Ritrovare la calma'));
  });

  testWidgets(
      'FXA.08: a video in corso sopra il velo si vede solo il video, e il '
      'mese compare in dissolvenza quando finisce', (tester) async {
    final finta = _Finta();
    await _monta(tester, lettori: [finta]);
    finta.comincia();
    await tester.pump(const Duration(milliseconds: 600));
    await soloIlFilmatoFinche(tester,
        scena: 'il Calendario Lunare',
        filmato: find.byKey(const Key('finta_del_filmato_lunario')),
        finisci: finta.finisci);
  });
}

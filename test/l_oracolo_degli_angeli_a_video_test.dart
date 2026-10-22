import 'dart:async';
import 'dart:math';

import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/oracolo_angeli/la_lettura_dell_oracolo.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sensi/la_suoneria.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/angels/oracolo/oracolo_degli_angeli_screen.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'il_giro_dell_oracolo.dart';
import 'sopra_il_filmato.dart';

/// **L'ORACOLO DEGLI ANGELI A VIDEO.** Ordine FU voci FU.02, FU.03, FU.04,
/// FU.06, FU.07 e FU.15: la scena col video e il tocco che lo salta, la
/// domanda, le lettere di luce, le tre carte che si girano, il responso col
/// riquadro e le bolle col Parlane e il rito, la nuova domanda che non rifa'
/// partire il video; ogni domanda, anche sensibile, estrae le tre carte.
///
/// **L'ORDINE GA**, voci GA.03, GA.05 e GA.08, 20 ottobre 2026: all'apertura
/// e dopo una domanda nuova l'altare e' vuoto, nessun dorso in vista finche'
/// la persona non sceglie (il fondatore: "L'oracolo degli angeli non mostra
/// all'inizio, all'apertura, nessuna Carta prima che l'utente le scelga");
/// il responso ha la forma nuova, col titolo del responso principale. Le
/// asserzioni di prima che pretendevano i tre dorsi all'apertura sono
/// rovesciate, con la loro riga accanto.
class _Finta implements LettoreDiScena {
  _Finta({this.fallira = false, this.muta = false});
  final bool fallira;

  /// Un lettore che non risponde mai: `apri` non finisce (FXA.08).
  final bool muta;
  VoidCallback? _ascolta;
  bool _pronto = false, _fallito = false, _cominciato = false;
  bool _finito = false;
  int aperture = 0, avvii = 0, sospensioni = 0;
  final volumi = <double>[];

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
    if (muta) return Completer<void>().future;
    fallira ? _fallito = true : _pronto = true;
    _ascolta?.call();
  }

  @override
  Future<void> volume(double q) async => volumi.add(q);
  @override
  Future<void> avvia() async => avvii++;
  @override
  Future<void> sospendi() async => sospensioni++;
  @override
  Widget disegna() => const ColoredBox(
      key: Key('finta_del_filmato_oracolo'), color: Color(0xFF102030));
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

Future<void> _monta(WidgetTester tester,
    {required List<_Finta> lettori,
    List<String>? richieste,
    bool conOra = true,
    Tier tier = Tier.tier1}) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(390, 844);
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
      ChangeNotifierProvider(create: (_) => EntitlementService(initial: tier)),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MediaQuery(
        data: const MediaQueryData(size: Size(390, 844)),
        child: MaestroScope(
          child: OracoloDegliAngeliScreen(
            fabbricaDellaScena: () => finte.removeAt(0),
            caso: Random(7),
            adesso: () => DateTime(2026, 10, 15, 10, 5),
            identita: BirthIdentity(
                birthMoment: DateTime(1990, 5, 12, 14, 30),
                hasBirthTime: conOra),
            chiamata: (i, r, c) async {
              richieste?.add(r);
              return jsonFintoDellOracolo(c);
            },
          ),
        ),
      ),
    ),
  ));
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Il giro intero, dalla domanda al responso (ordine FY voci FY.15 e FY.16:
/// la persona sceglie le tre carte e avvia la lettura col pulsante).
Future<void> _affida(WidgetTester tester, String domanda) =>
    consultaLOracolo(tester, domanda);

/// Al centro della finestra: in cima starebbe sotto la barra del titolo, che
/// prende il tocco (extendBodyBehindAppBar).
Future<void> _alCentro(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await Scrollable.ensureVisible(tester.element(f), alignment: 0.5);
  await tester.pump();
}

void main() {
  setUp(() {
    LaSuoneria.spentaPerLeProve = false;
    // GC.16: il cosmo dietro l'Oracolo ascolta i sensori.
    silenziaISensoriDelCosmo();
  });
  tearDown(() => LaSuoneria.spentaPerLeProve = null);

  testWidgets(
      'il video parte, un tocco lo salta e l\'altare resta vuoto (GA.08: '
      'prima i tre dorsi comparivano sull\'altare)', (tester) async {
    final finta = _Finta();
    await _monta(tester, lettori: [finta]);
    expect(finta.aperture, 1);
    expect(finta.avvii, 1, reason: 'il video non parte all\'apertura');
    expect(finta.volumi.last, 1.0);
    finta.comincia();
    await tester.pump();
    expect(find.byKey(const Key('finta_del_filmato_oracolo')), findsOneWidget);
    expect(find.byKey(const Key('oracolo_dorso_0')), findsNothing,
        reason: 'col video in corso i dorsi sono nel video');
    // **LA DOMANDA STA SOTTO IL TAVOLO** (GC.09): e' montata nella lista
    // e aspetta la scena ferma dentro `IlRestoDopoLaScena`, trasparente.
    // LAPIDE: "findsNothing", quando la domanda stava sopra la scena.
    double opacitaDellaDomanda() => tester
        .widget<AnimatedOpacity>(find
            .ancestor(
                of: find.byKey(const Key('oracolo_domanda')),
                matching: find.byType(AnimatedOpacity))
            .first)
        .opacity;
    expect(opacitaDellaDomanda(), 0,
        reason: 'la domanda compare a scena ferma');
    await tester.tapAt(const Offset(195, 600));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(finta.sospensioni, 1);
    // GA.08: prima qui i tre dorsi stavano sull'altare (findsOneWidget).
    for (var i = 0; i < 3; i++) {
      expect(find.byKey(Key('oracolo_dorso_$i')), findsNothing,
          reason: 'GA.08: il dorso $i e\' in vista prima della scelta');
    }
    expect(opacitaDellaDomanda(), 1);
    expect(find.byKey(const Key('il_tocco_che_salta')), findsNothing);
  });

  testWidgets(
      'la consultazione: le lettere salgono, le carte si girano, il responso '
      'ha il titolo, il riquadro e una bolla per carta', (tester) async {
    final richieste = <String>[];
    final finta = _Finta(fallira: true);
    await _monta(tester, lettori: [finta], richieste: richieste);
    // Video che non si carica: scena ferma con la domanda e l'altare vuoto
    // (GA.08: prima qui il dorso 1 era in vista, findsOneWidget).
    expect(find.byKey(const Key('oracolo_dorso_1')), findsNothing);
    await affidaLaDomanda(tester, 'Devo cambiare lavoro?');
    await scegliLeTreCarte(tester);
    await Scrollable.ensureVisible(
        tester.element(find.byKey(const Key('oracolo_avvia_la_lettura'))),
        alignment: 0.5);
    await tester.pump();
    await tester.tap(find.byKey(const Key('oracolo_avvia_la_lettura')));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byKey(const Key('oracolo_lettere_di_luce')), findsOneWidget,
        reason: 'la domanda non sale lungo la scala');
    // Dopo le lettere la riflessione di Medora (GC.13) e le carte che si
    // girano una alla volta e si alzano (GC.14): si aspetta il responso.
    for (var i = 0;
        i < 400 &&
            find.byKey(const Key('oracolo_responso')).evaluate().isEmpty;
        i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(richieste, hasLength(1), reason: 'una chiamata sola');
    expect(
        tester
            .widget<Text>(find.byKey(const Key('oracolo_principale_titolo')))
            .data!
            .replaceAll('\n', ' '),
        'Gli angeli ti chiedono un passo lento');
    for (final ruolo in const ['custode', 'cuore', 'intelletto']) {
      await tester.ensureVisible(find.byKey(Key('oracolo_bolla_$ruolo')));
      await tester.pump();
      expect(find.byKey(Key('oracolo_parlane_$ruolo')), findsOneWidget);
    }
    // Le tre carte si sono girate sull'altare: si risale alla scena.
    await tester.drag(find.byType(ListView).first, const Offset(0, 5000));
    await tester.pump(const Duration(milliseconds: 300));
    for (final ruolo in const ['custode', 'cuore', 'intelletto']) {
      expect(find.byKey(Key('oracolo_carta_$ruolo')), findsOneWidget,
          reason: 'la carta $ruolo non si e\' girata sull\'altare');
    }
    // Il rito con Caligo e' chiuso finche' non lo apri.
    expect(find.byKey(const Key('oracolo_rito_aperto_custode')), findsNothing);
    await _alCentro(tester, find.byKey(const Key('oracolo_rito_custode')));
    await tester.tap(find.byKey(const Key('oracolo_rito_custode')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(
        find.byKey(const Key('oracolo_rito_aperto_custode')), findsOneWidget);
    expect(find.textContaining('Il momento: dalle '), findsOneWidget);
    // Una nuova domanda: il video non riparte, e l'altare torna vuoto
    // (GA.08: prima le carte tornavano dorsi sull'altare).
    await _alCentro(tester, find.byKey(const Key('oracolo_nuova_domanda')));
    await tester.tap(find.byKey(const Key('oracolo_nuova_domanda')));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(finta.aperture, 1, reason: 'il video e\' ripartito');
    expect(find.byKey(const Key('oracolo_responso')), findsNothing);
    expect(find.byKey(const Key('oracolo_dorso_2')), findsNothing);
  });

  testWidgets(
      'senza l\'ora di nascita la terza carta resta coperta, con '
      'l\'invito', (tester) async {
    await _monta(tester, lettori: [_Finta(fallira: true)], conOra: false);
    await _affida(tester, 'Sono sulla strada giusta?');
    expect(find.byKey(const Key('oracolo_carta_intelletto')), findsNothing);
    expect(find.byKey(const Key('oracolo_aggiungi_l_ora')), findsOneWidget);
    expect(find.textContaining(LaLetturaDellOracolo.testoDellaCartaCoperta),
        findsOneWidget);
  });

  testWidgets(
      'FVA.01: una domanda sensibile estrae le tre carte e va al modello come '
      'le altre', (tester) async {
    // **LAPIDE, ordine FV aggiunta voce FVA.01.** Qui la domanda delicata
    // non estraeva carte e riceveva la cura col 112 (ordine FU voce FU.04).
    final richieste = <String>[];
    await _monta(tester,
        lettori: [_Finta(fallira: true)], richieste: richieste);
    await _affida(tester, 'Mi sento solo e senza forze, cosa mi dicono?');
    expect(find.byKey(const Key('oracolo_responso')), findsOneWidget);
    expect(richieste, hasLength(1),
        reason: 'la domanda sensibile non e\' andata al modello');
    expect(find.textContaining('112'), findsNothing);
  });

  // **RISCRITTA DALL'ORDINE GC**, voce GC.08, 22 ottobre 2026. Il
  // fondatore: *"all'apertura non si deve vedere la carta o messaggio del
  // momento"*. LAPIDE: "l'angelo dell'ora e il messaggio del giorno si
  // vedono subito". Adesso arrivano solo a lettura fatta, in fondo.
  testWidgets('l\'angelo dell\'ora e il messaggio del giorno arrivano dopo '
      'la lettura, non all\'apertura', (tester) async {
    await _monta(tester, lettori: [_Finta(fallira: true)]);
    expect(find.byKey(const Key('oracolo_angelo_dell_ora')), findsNothing,
        reason: 'all\'apertura si vede il messaggio del momento');
    await consultaLOracolo(tester, 'Devo cambiare lavoro?');
    await tester
        .ensureVisible(find.byKey(const Key('oracolo_angelo_dell_ora')));
    // Alle 10:05 governa l'angelo 31 (minuto 605: 605 / 20 = 30, piu' uno).
    expect(find.byKey(const Key('oracolo_nome_dell_ora')), findsOneWidget);
    expect(find.text('dalle 10:00 alle 10:20'), findsOneWidget);
    expect(
        find.byKey(const Key('oracolo_messaggio_del_giorno')), findsOneWidget);
  });

  testWidgets(
      'FXA.08: a video in corso sopra l\'altare si vede solo il video, e il '
      'resto compare in dissolvenza quando finisce', (tester) async {
    final finta = _Finta();
    await _monta(tester, lettori: [finta]);
    finta.comincia();
    await tester.pump(const Duration(milliseconds: 600));
    await soloIlFilmatoFinche(tester,
        scena: 'l\'Oracolo degli Angeli',
        filmato: find.byKey(const Key('finta_del_filmato_oracolo')),
        finisci: finta.finisci);
  });

  testWidgets(
      'FXA.08: un video che non risponde mai non tiene la schermata vuota: '
      "passata l'attesa massima la scena e' ferma e il resto compare",
      (tester) async {
    await _monta(tester, lettori: [_Finta(muta: true)]);
    final resto = find.byType(IlRestoDopoLaScena);
    expect(tester.widget<IlRestoDopoLaScena>(resto.first).scenaFerma, isFalse,
        reason: 'mentre il video si prepara il resto aspetta');
    for (var t = Duration.zero;
        t < RegiaDellaScena.attesaMassima;
        t += const Duration(milliseconds: 200)) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    await tester.pump(IlFilmatoCheSfuma.dissolvenza);
    expect(tester.widget<IlRestoDopoLaScena>(resto.first).scenaFerma, isTrue,
        reason: 'il video non ha mai risposto e la schermata resta vuota');
    expect(find.byKey(const Key('oracolo_domanda')), findsOneWidget);
  });
}

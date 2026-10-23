// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sensi/la_suoneria.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/cielo_evolutivo.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/il_composito_e_keplero.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/il_corpus_della_sinastria_evolutiva.g.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/la_lettura_evolutiva.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/la_lunga_della_sinastria.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/le_barre_della_sinastria.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/legame_e_eta.dart';
import 'package:esoteric_circle/design_system/components/interruttore_del_cerchio.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:esoteric_circle/features/amici/amici_screen.dart';
import 'package:esoteric_circle/features/cerchio/invita_nel_cerchio_screen.dart';
import 'package:esoteric_circle/features/respiro_della_luna/i_comandi_dipinti.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:esoteric_circle/features/synastry/avvio_sinastria_evolutiva.dart';
import 'package:esoteric_circle/features/synastry/il_grafico_delle_barre.dart';
import 'package:esoteric_circle/features/synastry/la_nascita_dell_altra_persona.dart';
import 'package:esoteric_circle/features/synastry/lo_studio_di_medora.dart';
import 'package:esoteric_circle/features/synastry/sinastria_evolutiva_screen.dart';
import 'package:esoteric_circle/features/tarot/attesa_di_medora.dart';
import 'package:esoteric_circle/features/tarot/tarot_selectors.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';
import 'la_tendina_della_sinastria_aiuto.dart';
import 'porta_finta_del_cerchio_sociale.dart';

/// **LA SINASTRIA EVOLUTIVA RIFATTA, ORDINE GD PARTE D**, 23 ottobre 2026.
/// Il fondatore sulla funzione com'era: *"SEMPLICEMENTE FA CAGARE"*. Una
/// prova per voce, dalla GD.13 alla GD.22 (la GD.20 ha la sua guardia,
/// `gd20_gli_amici_offline_hanno_una_porta_sola_test.dart`, e la GD.21 la sua
/// prova del giro, `gd21_la_sinastria_arriva_all_amico_test.dart`). Nessuna
/// chiamata al modello: la Sinastria evolutiva non ne fa (tutto dal corpus),
/// e le prove usano la finta del video gia' delle prove della Sinastria.
class _Finta implements LettoreDellaScenaSinastria {
  VoidCallback? _ascolta;
  bool _pronto = false;
  bool _cominciato = false;
  bool _finito = false;

  @override
  bool get pronto => _pronto;
  @override
  bool get fallito => false;
  @override
  bool get cominciato => _cominciato;
  @override
  bool get finito => _finito;
  @override
  void ascolta(VoidCallback? quandoCambia) => _ascolta = quandoCambia;
  @override
  Future<void> apri() async {
    _pronto = true;
    _ascolta?.call();
  }

  @override
  Future<void> volume(double quanto) async {}
  @override
  Future<void> avvia() async {}
  @override
  Future<void> sospendi() async {}
  @override
  Widget disegna() => const ColoredBox(
      key: Key('finta_del_filmato_gd'), color: Color(0xFF203040));
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

/// La porta del conto delle coppie nuove, come nella prova del ponte (FT.13):
/// il server conosce il budget, quindi le coppie si contano.
class _PortaDelConto extends PortaDelCerchio {
  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
          {Object? cammino, bool azzeraIlCammino = false}) async =>
      StatoDelCerchio.daMappa({
        'giorno': '2026-10-23',
        'spesi': const {'domande': 0},
        'saldoEos': 1000,
        'listinoDelRiscatto': {
          'domande': 80,
          'stese': 150,
          'sinastrie': 150,
          'sinastrieEvolutive': 150,
        },
      });

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async =>
      850;

  @override
  Future<EsitoDelConsumo?> consuma(
          {required String budget, required String idMovimento}) async =>
      null;

  @override
  Future<bool> scriviLaMemoria({
    required String operazione,
    String? maestro,
    Map<String, Object?> campi = const {},
  }) async =>
      false;

  @override
  Future<bool> cancellaIlCerchio() async => false;
}

final _marco = CieloEvolutivo.perNascita(
    momentoUtc: DateTime.utc(1990, 5, 12, 14, 30), nome: 'Marco');
final _giulia = CieloEvolutivo.perNascita(
    momentoUtc: DateTime.utc(1992, 9, 3, 8, 15), nome: 'Giulia');
final _oggi = DateTime(2026, 10, 23);

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LaSuoneria.spentaPerLeProve = false;
  });
  tearDown(() => LaSuoneria.spentaPerLeProve = null);

  Future<void> schermo(WidgetTester tester, Size s) async {
    silenzia();
    tester.view.physicalSize = s;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  Widget app(Widget home,
          {Tier tier = Tier.free,
          IlCerchioSociale? sociale,
          QuestionAllowance? borsa}) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(
              create: (_) => ProfileController(
                  identity: BirthIdentity(
                      birthMoment: DateTime(1990, 5, 12, 14, 30)))),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
          ChangeNotifierProvider(
              create: (_) => SettingsController(suonoEVibrazione: false)),
          ChangeNotifierProvider(
              create: (_) => EntitlementService(initial: tier)),
          if (sociale != null)
            ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
          if (borsa != null)
            ChangeNotifierProvider<QuestionAllowance>.value(value: borsa),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (c, figlio) => MaestroScope(child: figlio!),
          home: home,
        ),
      );

  Future<void> passa(WidgetTester tester, [int volte = 6]) async {
    for (var i = 0; i < volte; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  SinastriaEvolutivaScreen ingresso({_Finta? finta}) => SinastriaEvolutivaScreen(
        nomeTuo: 'Tu',
        cieloTuo: _marco,
        oggi: _oggi,
        fabbricaDellaScena: finta == null ? null : () => finta,
      );

  Future<void> tocca(WidgetTester tester, Key chiave) async {
    final f = find.byKey(chiave);
    await tester.ensureVisible(f);
    await passa(tester, 2);
    await tester.tap(f);
    await passa(tester, 4);
  }

  // --- GD.13 ---------------------------------------------------------------

  for (final s in const [Size(360, 760), Size(390, 844), Size(430, 932)]) {
    testWidgets(
        'GD.13 a ${s.width.toInt()}x${s.height.toInt()}: il video copre tutto '
        'lo schermo, sopra la domanda sopra la testa di Medora e il solo '
        'pulsante; il testo di prima non c\'e\' piu\'', (tester) async {
      await schermo(tester, s);
      final finta = _Finta();
      await tester.pumpWidget(app(ingresso(finta: finta)));
      await passa(tester, 2);
      finta.comincia();
      await passa(tester, 2);
      final schermata = Offset.zero & s;
      final video = tester.getRect(find.byKey(const Key('studio_filmato')));
      final coperta = video.intersect(schermata);
      final rapporto =
          (coperta.width * coperta.height) / (s.width * s.height);
      print('GD.13 ${s.width.toInt()}x${s.height.toInt()}: video $video, '
          'area coperta ${(coperta.width * coperta.height).toStringAsFixed(0)} '
          'su ${(s.width * s.height).toStringAsFixed(0)} punti quadrati, '
          'rapporto ${rapporto.toStringAsFixed(4)}');
      expect(rapporto, greaterThanOrEqualTo(0.999),
          reason: 'il video copre il ${(rapporto * 100).toStringAsFixed(1)} '
              'per cento dello schermo: e\' tagliato');
      final sfondo = tester.getRect(find.byKey(const Key('studio_sfondo')));
      final sfondoCoperto = sfondo.intersect(schermata);
      expect(sfondoCoperto.width * sfondoCoperto.height,
          closeTo(s.width * s.height, 1),
          reason: 'lo studio dipinto non copre lo schermo');

      // Finito il video: sopra la scena la domanda e il pulsante.
      finta.finisci();
      await tester.pump(const Duration(seconds: 1));
      await passa(tester, 4);
      expect(find.text('Con chi leggo il tuo cielo?'), findsNothing,
          reason: 'resta il titolo di prima sotto la scena');
      expect(find.textContaining('Scrivi la sua nascita'), findsNothing,
          reason: 'resta la riga di prima sotto il titolo');
      final domanda = find.byKey(const Key('sinastria_la_domanda'));
      expect(tester.widget<Text>(domanda).data,
          'Con chi vuoi scoprire la tua compatibilità?');
      expect(find.byType(PulsanteDipinto), findsOneWidget,
          reason: 'sulla scena c\'e\' piu\' di un pulsante');
      final g = GeometriaDelloStudio.aTuttoSchermo(s);
      final testa =
          g.origine.dy + GeometriaDelloStudio.testaDiMedora * g.scala;
      final rDomanda = tester.getRect(domanda);
      print('GD.13 ${s.width.toInt()}x${s.height.toInt()}: domanda da '
          '${rDomanda.top.toStringAsFixed(1)} a '
          '${rDomanda.bottom.toStringAsFixed(1)}, testa di Medora a '
          '${testa.toStringAsFixed(1)}, barra del titolo fino a $kToolbarHeight');
      expect(rDomanda.bottom, lessThanOrEqualTo(testa),
          reason: 'la domanda scende sulla testa di Medora');
      expect(rDomanda.top, greaterThanOrEqualTo(kToolbarHeight),
          reason: 'la domanda finisce sotto la barra del titolo');
      final pulsante =
          tester.getRect(find.byKey(const Key('sinastria_scegli_la_persona')));
      expect(pulsante.bottom, lessThanOrEqualTo(s.height));
      expect(pulsante.top, greaterThan(s.height * 0.75),
          reason: 'il pulsante non sta in basso');
      expect(tester.takeException(), isNull);
    });
  }

  // --- GD.14 ---------------------------------------------------------------

  testWidgets(
      'GD.14: il tocco apre verso l\'alto una tendina semitrasparente, al '
      'primo passo online oppure offline', (tester) async {
    await schermo(tester, const Size(390, 844));
    await tester.pumpWidget(app(ingresso()));
    await passa(tester, 8);
    await tocca(tester, const Key('sinastria_scegli_la_persona'));
    await passa(tester, 4);
    expect(find.byKey(const Key('sinastria_tendina_scelta')), findsOneWidget);
    expect(find.byKey(const Key('sinastria_tendina_online')), findsOneWidget);
    expect(find.byKey(const Key('sinastria_tendina_offline')), findsOneWidget);
    // Un passo alla volta: al primo passo non c'e' ancora nessun elenco.
    expect(find.byKey(const Key('sinastria_tendina_elenco_online')),
        findsNothing);
    expect(find.byKey(const Key('sinastria_modulo')), findsNothing);
    final foglio = tester.widget<BottomSheet>(find.byType(BottomSheet));
    final velo = foglio.backgroundColor!.a;
    final rFoglio = tester.getRect(find.byType(BottomSheet));
    print('GD.14 LA TENDINA: velo ${velo.toStringAsFixed(2)}, da '
        '${rFoglio.top.toStringAsFixed(0)} a ${rFoglio.bottom}');
    expect(velo, lessThan(1), reason: 'la tendina e\' piena, non velata');
    expect(rFoglio.bottom, 844, reason: 'la tendina non sale dal fondo');
    expect(find.byKey(const Key('sinastria_evolutiva_scena')), findsOneWidget,
        reason: 'sotto la tendina la scena non c\'e\' piu\'');
  });

  testWidgets(
      'GD.14: online senza amici la tendina lo dice e offre l\'invito; dalle '
      'schermate di invito la freccia indietro torna nella tendina, dentro '
      'la Sinastria', (tester) async {
    await schermo(tester, const Size(390, 844));
    final porta = PortaFintaDelCerchioSociale(amici: false);
    final sociale = IlCerchioSociale(porta: porta);
    await tester.runAsync(() => sociale.sincronizza(
        identita: BirthIdentity(birthMoment: DateTime(1990, 5, 12, 14, 30)),
        oggi: _oggi));
    await tester.pumpWidget(app(ingresso(), sociale: sociale));
    await passa(tester, 8);
    await tocca(tester, const Key('sinastria_scegli_la_persona'));
    await tocca(tester, const Key('sinastria_tendina_online'));
    await passa(tester, 4);
    expect(find.byKey(const Key('sinastria_tendina_online_vuoto')),
        findsOneWidget,
        reason: 'senza amici nel Cerchio la tendina non lo dice');
    expect(find.text('Non hai ancora amici nel Cerchio.'), findsOneWidget);
    await tocca(tester, const Key('sinastria_tendina_invita'));
    await passa(tester, 6);
    expect(find.byType(InvitaNelCerchioScreen), findsOneWidget,
        reason: 'l\'invito non porta alle schermate di invito del Cerchio');
    await tester.pageBack();
    await passa(tester, 8);
    expect(find.byType(InvitaNelCerchioScreen), findsNothing);
    expect(find.byKey(const Key('sinastria_tendina_online_vuoto')),
        findsOneWidget,
        reason: 'la freccia indietro dall\'invito non torna nella tendina');
    expect(find.byType(SinastriaEvolutivaScreen), findsOneWidget,
        reason: 'tornando dall\'invito si e\' usciti dalla Sinastria');
  });

  testWidgets(
      'GD.14: online con gli amici del Cerchio, l\'elenco; scelto un amico il '
      'modulo porta il suo nome', (tester) async {
    await schermo(tester, const Size(390, 844));
    final sociale = IlCerchioSociale(porta: PortaFintaDelCerchioSociale());
    await tester.runAsync(() => sociale.sincronizza(
        identita: BirthIdentity(birthMoment: DateTime(1990, 5, 12, 14, 30)),
        oggi: _oggi));
    await tester.pumpWidget(app(ingresso(), sociale: sociale));
    await passa(tester, 8);
    await tocca(tester, const Key('sinastria_scegli_la_persona'));
    await tocca(tester, const Key('sinastria_tendina_online'));
    await passa(tester, 4);
    expect(find.byKey(const Key('sinastria_tendina_amico_u-stella')),
        findsOneWidget,
        reason: 'gli amici del Cerchio non sono nell\'elenco');
    await tocca(tester, const Key('sinastria_tendina_amico_u-stella'));
    expect(find.byKey(const Key('sinastria_modulo')), findsOneWidget);
    expect(
        tester
            .widget<TextField>(find.byKey(const Key('sinastria_modulo_nome')))
            .controller!
            .text,
        'Stella Lieve');
  });

  testWidgets(
      'GD.14 e GD.20: offline, gli amici gia\' salvati dall\'Oroscopo e la '
      'persona nuova, che entra nella stessa lista', (tester) async {
    await schermo(tester, const Size(390, 844));
    SharedPreferences.setMockInitialValues({
      'amici_offline': jsonEncode([
        {'id': 'a1', 'nome': 'Marta', 'nascita': '1993-04-02', 'ora': '09:30'},
      ]),
    });
    await tester.pumpWidget(app(ingresso(), tier: Tier.tier1));
    await passa(tester, 8);
    await tocca(tester, const Key('sinastria_scegli_la_persona'));
    await tocca(tester, const Key('sinastria_tendina_offline'));
    expect(find.byKey(const Key('sinastria_tendina_offline_a1')), findsOneWidget,
        reason: 'l\'amica salvata nell\'Oroscopo non e\' nella Sinastria');
    expect(find.byKey(const Key('sinastria_tendina_nuovo')), findsOneWidget);
    // Marta dall'elenco: il modulo arriva gia' compilato.
    await tocca(tester, const Key('sinastria_tendina_offline_a1'));
    expect(find.text('2/4/1993'), findsOneWidget);
    expect(find.text('09:30'), findsOneWidget);
    // Indietro e una persona nuova: alla scoperta entra nella lista.
    // Indietro dal modulo si torna all'elenco offline, da cui si era venuti.
    await tocca(tester, const Key('sinastria_tendina_indietro'));
    expect(find.byKey(const Key('sinastria_tendina_elenco_offline')),
        findsOneWidget);
    await compilaLaTendina(tester,
        nome: 'Bianca', apri: false, giaOffline: true);
    await tester.pump(AttesaDiMedora.durataMinima);
    await passa(tester, 6);
    final grezzo = (await tester.runAsync(SharedPreferences.getInstance))!
        .getString('amici_offline')!;
    print('GD.20 LA LISTA DOPO LA SINASTRIA: $grezzo');
    expect(grezzo, contains('Bianca'),
        reason: 'la persona nuova della Sinastria non e\' nella lista');
    // E l'Oroscopo la vede, dalla sua rubrica.
    await tester.pumpWidget(app(const AmiciScreen(perScegliere: true),
        tier: Tier.tier1));
    await passa(tester, 8);
    expect(find.text('Bianca'), findsOneWidget,
        reason: 'l\'amica creata nella Sinastria non si vede nell\'Oroscopo');
    expect(find.text('Marta'), findsOneWidget);
  });

  // --- GD.15 ---------------------------------------------------------------

  /// Il censimento dei testi di un sottoalbero contro la misura del responso
  /// dei Tarocchi: ogni testo deve avere la famiglia e la misura di uno dei
  /// ruoli tipografici che il responso dei Tarocchi usa.
  ({int testi, List<String> fuori}) censimento(
      WidgetTester tester, Finder radice) {
    final ruoli = [
      TypographyTokens.titoloSezione(),
      TypographyTokens.titoloScheda(),
      TypographyTokens.titoloDiRiga(),
      TypographyTokens.etichetta(),
      TypographyTokens.lettura(),
      TypographyTokens.corpo(),
      TypographyTokens.didascalia(),
    ];
    bool diCasa(TextStyle? st) =>
        st != null &&
        ruoli.any((r) =>
            r.fontFamily == st.fontFamily &&
            (r.fontSize! - (st.fontSize ?? 0)).abs() < 0.01);
    final fuori = <String>[];
    var testi = 0;
    for (final e in find
        .descendant(of: radice, matching: find.byType(Text))
        .evaluate()) {
      final t = e.widget as Text;
      testi++;
      final st = DefaultTextStyle.of(e).style.merge(t.style);
      if (!diCasa(st)) {
        fuori.add('"${t.data}" ${st.fontFamily} ${st.fontSize}');
      }
    }
    for (final e in find
        .descendant(of: radice, matching: find.byType(EditableText))
        .evaluate()) {
      testi++;
      final st = (e.widget as EditableText).style;
      if (!diCasa(st)) fuori.add('campo ${st.fontFamily} ${st.fontSize}');
    }
    return (testi: testi, fuori: fuori);
  }

  testWidgets(
      'GD.15: il modulo chiede nome, data e ora di nascita, coi ruoli '
      'tipografici del responso dei Tarocchi e i riquadri della casa',
      (tester) async {
    await schermo(tester, const Size(390, 844));
    // PRIMA: il modulo di prima, "La sua nascita" (cattura GD_12).
    await tester.pumpWidget(app(Builder(
        builder: (c) => LaNascitaDellAltraPersona(
            palette: MaestroScope.of(c)))));
    await passa(tester, 4);
    final prima = censimento(tester, find.byType(LaNascitaDellAltraPersona));
    print('GD.15 PRIMA, "La sua nascita": ${prima.testi} testi, fuori dalla '
        'misura ${prima.fuori.length}: ${prima.fuori}');
    // DOPO: il modulo della tendina.
    await tester.pumpWidget(app(ingresso()));
    await passa(tester, 8);
    await tocca(tester, const Key('sinastria_scegli_la_persona'));
    await tocca(tester, const Key('sinastria_tendina_offline'));
    await tocca(tester, const Key('sinastria_tendina_nuovo'));
    final modulo = find.byKey(const Key('sinastria_modulo'));
    expect(find.byKey(const Key('sinastria_modulo_nome')), findsOneWidget);
    expect(find.byKey(const Key('sinastria_modulo_data')), findsOneWidget);
    expect(find.byKey(const Key('sinastria_modulo_ora')), findsOneWidget);
    final dopo = censimento(tester, modulo);
    print('GD.15 DOPO, il modulo della tendina: ${dopo.testi} testi, fuori '
        'dalla misura ${dopo.fuori.length}: ${dopo.fuori}');
    cardinaleMinimo(dopo.testi, 15, cosa: 'testi del modulo');
    expect(dopo.fuori, isEmpty,
        reason: 'testi del modulo fuori dalla misura del responso dei '
            'Tarocchi: ${dopo.fuori}');
    // I tre campi stanno nei riquadri della casa.
    for (final k in const [
      'sinastria_modulo_nome',
      'sinastria_modulo_data',
      'sinastria_modulo_ora'
    ]) {
      final dentro = find.ancestor(
          of: find.byKey(Key(k)),
          matching: find.byKey(const Key('paragrafo_in_evidenza')));
      final sotto = find.descendant(
          of: find.byKey(Key(k)),
          matching: find.byKey(const Key('paragrafo_in_evidenza')));
      expect(
          dentro.evaluate().length + sotto.evaluate().length,
          greaterThan(0),
          reason: '$k non sta in un riquadro della casa');
    }
  });

  // --- GD.16 ---------------------------------------------------------------

  testWidgets(
      'GD.16: le quattro icone dipinte, una sola alla volta; l\'Amore resta '
      'chiuso sotto i sedici anni', (tester) async {
    await schermo(tester, const Size(390, 844));
    SharedPreferences.setMockInitialValues({
      'amici_offline': jsonEncode([
        {'id': 'b1', 'nome': 'Nina', 'nascita': '2012-03-01'},
      ]),
    });
    await tester.pumpWidget(app(ingresso(), tier: Tier.tier1));
    await passa(tester, 8);
    await tocca(tester, const Key('sinastria_scegli_la_persona'));
    await tocca(tester, const Key('sinastria_tendina_offline'));
    await tocca(tester, const Key('sinastria_tendina_nuovo'));
    final legami = find.byKey(const Key('sinastria_modulo_legami'));
    final immagini = [
      for (final e in find
          .descendant(of: legami, matching: find.byType(Image))
          .evaluate())
        ((e.widget as Image).image as AssetImage).assetName,
    ];
    expect(immagini, [
      for (final l in Legame.values)
        'assets/img/sinastria/legame_${l.name}_v1.webp',
    ]);
    int scelti() => find
        .descendant(
            of: legami,
            matching: find.byWidgetPredicate(
                (w) => w is Semantics && w.properties.selected == true))
        .evaluate()
        .length;
    expect(scelti(), 0);
    await tocca(tester, const Key('sinastria_legame_amicizia'));
    expect(scelti(), 1);
    await tocca(tester, const Key('sinastria_legame_lavoro'));
    await tocca(tester, const Key('sinastria_legame_famiglia'));
    print('GD.16 LEGAMI SCELTI DOPO TRE TOCCHI: ${scelti()}');
    expect(scelti(), 1, reason: 'due tipologie si scelgono insieme');

    // Nina ha quattordici anni: l'amore resta chiuso, con la riga sobria.
    await tocca(tester, const Key('sinastria_tendina_indietro'));
    await tocca(tester, const Key('sinastria_tendina_offline_b1'));
    expect(find.byKey(const Key('sinastria_amore_chiuso')), findsOneWidget);
    await tocca(tester, const Key('sinastria_modulo_ora_non_nota'));
    await tocca(tester, const Key('sinastria_legame_amore'));
    expect(
        tester
            .widget<PulsanteDipinto>(find.byKey(const Key('sinastria_scopri')))
            .onTap,
        isNull,
        reason: 'con quattordici anni l\'amore si scopre lo stesso');
  });

  testWidgets(
      'GD.16 e GD.22: un\'altra tipologia e\' una sinastria nuova e consuma; '
      'rileggere la stessa coppia col suo legame non consuma niente',
      (tester) async {
    await schermo(tester, const Size(390, 844));
    final borsa = QuestionAllowance(porta: _PortaDelConto());
    await tester.runAsync(borsa.sincronizza);
    await tester.pumpWidget(app(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () =>
                Navigator.of(context).push(AvvioSinastriaEvolutiva.route()),
            child: const Text('apri'),
          ),
        ),
        tier: Tier.tier3,
        borsa: borsa));
    await tester.tap(find.text('apri'));
    await passa(tester, 10);
    final inizio = borsa.sinastrieEvolutiveRimaste(Tier.tier3)!;

    Future<void> leggi(String legame) async {
      await compilaLaTendina(tester, legame: legame);
      await tester.pump(AttesaDiMedora.durataMinima);
      await passa(tester, 6);
    }

    Future<void> unAltra() async {
      final f = find.byKey(const Key('sinastria_un_altra'));
      await tester.scrollUntilVisible(f, 400,
          scrollable: find.byType(Scrollable).last, maxScrolls: 100);
      await tester.ensureVisible(f);
      await passa(tester, 2);
      await tester.tap(f);
      await passa(tester, 6);
    }

    await leggi('amicizia');
    final dopoLaPrima = borsa.sinastrieEvolutiveRimaste(Tier.tier3)!;
    expect(find.byKey(const Key('sinastria_riga_viva')), findsOneWidget,
        reason: 'la scheda della coppia non porta la riga viva di oggi');
    await unAltra();
    await leggi('amicizia');
    final dopoLaRilettura = borsa.sinastrieEvolutiveRimaste(Tier.tier3)!;
    await unAltra();
    await leggi('lavoro');
    final dopoIlLavoro = borsa.sinastrieEvolutiveRimaste(Tier.tier3)!;
    print('GD.16 E GD.22 LE COPPIE NUOVE RIMASTE: all\'inizio $inizio, dopo '
        'la prima $dopoLaPrima, dopo la rilettura $dopoLaRilettura, dopo il '
        'legame lavoro $dopoIlLavoro');
    expect(dopoLaPrima, inizio - 1, reason: 'la coppia nuova non si conta');
    expect(dopoLaRilettura, dopoLaPrima,
        reason: 'rileggere la stessa coppia col suo legame ha consumato');
    expect(dopoIlLavoro, dopoLaRilettura - 1,
        reason: 'un\'altra tipologia non consuma come una coppia nuova');
  });

  // --- GD.17 ---------------------------------------------------------------

  testWidgets(
      'GD.17: senza il piano la Lunga si vede col lucchetto e porta '
      'all\'invito ai piani', (tester) async {
    await schermo(tester, const Size(390, 844));
    await tester.pumpWidget(app(ingresso()));
    await passa(tester, 8);
    await tocca(tester, const Key('sinastria_scegli_la_persona'));
    await tocca(tester, const Key('sinastria_tendina_offline'));
    await tocca(tester, const Key('sinastria_tendina_nuovo'));
    final selettore = tester.widget<TendinaSelettore<ProfonditaDellaSinastria>>(
        find.byType(TendinaSelettore<ProfonditaDellaSinastria>));
    expect(selettore.voci, ProfonditaDellaSinastria.values);
    expect(selettore.bloccata(ProfonditaDellaSinastria.lunga), isTrue,
        reason: 'al Viandante la Lunga non ha il lucchetto');
    expect(selettore.bloccata(ProfonditaDellaSinastria.breve), isFalse);
    await tocca(tester, const Key('sinastria_profondita'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.lock_rounded), findsWidgets);
    await tester.tap(find.text('Lunga').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget,
        reason: 'il lucchetto della Lunga non porta all\'invito ai piani');
  });

  Future<void> rotta(WidgetTester tester,
      {required Tier tier,
      ProfonditaDellaSinastria profondita = ProfonditaDellaSinastria.breve,
      CieloEvolutivo? suo,
      DateTime? oggi}) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app(
        MediaQuery(
          data: const MediaQueryData(
              size: Size(390, 844), disableAnimations: true),
          child: SinastriaEvolutivaScreen(
            nomeTuo: 'Tu',
            cieloTuo: _marco,
            nomeSuo: 'Giulia',
            cieloSuo: suo ?? _giulia,
            legame: Legame.amicizia,
            profondita: profondita,
            oggi: oggi ?? _oggi,
          ),
        ),
        tier: tier));
    await passa(tester, 6);
  }

  Future<void> scorriFino(WidgetTester tester, Finder f) async {
    await tester.scrollUntilVisible(f, 300,
        scrollable: find.byType(Scrollable).first, maxScrolls: 120);
    await Scrollable.ensureVisible(tester.element(f), alignment: 0.5);
    await tester.pump();
  }

  /// I paragrafi del primo capitolo, contati sull'albero.
  int paragrafiDelPrimo(WidgetTester tester) {
    final primo = find.byKey(const Key('sinastria_capitolo_attrazione'));
    return find
        .descendant(
            of: primo,
            matching: find.byWidgetPredicate((w) =>
                w is Text &&
                w.key is ValueKey<String> &&
                ((w.key! as ValueKey<String>).value.startsWith(
                        'responso_paragrafo_') ||
                    (w.key! as ValueKey<String>).value ==
                        'sinastria_lunga_approfondimento' ||
                    (w.key! as ValueKey<String>).value ==
                        'sinastria_lunga_filo')))
        .evaluate()
        .length;
  }

  testWidgets(
      'GD.17: con la Lunga soltanto la prima risposta porta due paragrafi in '
      'piu\', il secondo nel riquadro "Il filo che vi lega"; la Breve no',
      (tester) async {
    await schermo(tester, const Size(390, 844));
    await rotta(tester, tier: Tier.tier1);
    await scorriFino(
        tester, find.byKey(const Key('sinastria_capitolo_attrazione')));
    final breve = paragrafiDelPrimo(tester);
    expect(find.byKey(const Key('sinastria_lunga_riquadro')), findsNothing);

    await rotta(tester,
        tier: Tier.tier1, profondita: ProfonditaDellaSinastria.lunga);
    await scorriFino(tester, find.byKey(const Key('sinastria_lunga_titolo')));
    final lunga = paragrafiDelPrimo(tester);
    print('GD.17 PARAGRAFI DELLA PRIMA RISPOSTA: Breve $breve, Lunga $lunga');
    expect(lunga, breve + 2, reason: 'la Lunga non aggiunge due paragrafi');
    expect(
        find.descendant(
            of: find.byKey(const Key('sinastria_lunga_riquadro')),
            matching: find.text('Il filo che vi lega')),
        findsOneWidget,
        reason: 'il secondo paragrafo non sta nel riquadro col titolo');
    expect(
        find.descendant(
            of: find.byKey(const Key('sinastria_lunga_riquadro')),
            matching: find.byKey(const Key('sinastria_lunga_filo'))),
        findsOneWidget);
    // Solo la prima risposta: nessun altro capitolo porta la Lunga.
    for (final c in Capitolo.values.skip(1)) {
      final f = find.byKey(Key('sinastria_capitolo_${c.name}'));
      await scorriFino(tester, f);
      expect(
          find.descendant(
              of: f, matching: find.byKey(const Key('sinastria_lunga_filo'))),
          findsNothing,
          reason: 'la Lunga entra anche nel capitolo ${c.name}');
    }
    // Il Viandante che chiede la Lunga legge la Breve.
    await rotta(tester,
        tier: Tier.free, profondita: ProfonditaDellaSinastria.lunga);
    await scorriFino(
        tester, find.byKey(const Key('sinastria_capitolo_attrazione')));
    expect(find.byKey(const Key('sinastria_lunga_riquadro')), findsNothing,
        reason: 'senza il piano la Lunga si legge lo stesso');
  });

  test(
      'GD.17: la Lunga non ha un ripiego che la perda, perche\' non viene '
      'dal modello: su quaranta coppie i due paragrafi ci sono sempre, dal '
      'corpus, e nessun sorgente della Sinastria chiama un modello', () {
    var coppie = 0;
    for (var i = 0; i < 40; i++) {
      final suo = CieloEvolutivo.perNascita(
          momentoUtc: DateTime.utc(1960 + i, 1 + i % 12, 1 + (i * 7) % 28,
              (i * 5) % 24, (i * 13) % 60),
          oraNota: i.isEven,
          nome: 'P$i');
      for (final l in Legame.values) {
        final capitoli = LetturaEvolutiva.componi(
            tuo: _marco,
            suo: suo,
            nomeSuo: 'Giulia',
            legame: l,
            corpus: corpusDellaSinastriaEvolutiva);
        final t = LaLungaDellaSinastria.per(
            tuo: _marco,
            suo: suo,
            nomeSuo: 'Giulia',
            legame: l,
            primo: capitoli.first,
            corpus: corpusDellaSinastriaEvolutiva);
        expect(t.approfondimento.trim(), isNotEmpty);
        expect(t.filo.trim(), isNotEmpty);
        expect(capitoli.first.paragrafi, isNot(contains(t.approfondimento)),
            reason: 'la Lunga ripete un paragrafo gia\' letto');
        expect(t.approfondimento, isNot(contains('{nome}')));
        final composito = IlComposito.fra(_marco, suo);
        expect(
            t.filo,
            isNot(corpusDellaSinastriaEvolutiva[
                    'composito|${composito.cella}|testo']!
                .first
                .replaceAll('{nome}', 'Giulia')),
            reason: 'il filo ripete il testo del cielo comune');
        coppie++;
      }
    }
    print('GD.17 LUNGHE COMPOSTE DAL CORPUS: $coppie');
    final sorgenti = [
      ...Directory('lib/core/synastry_evolutiva')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart')),
      for (final n in const [
        'sinastria_evolutiva_screen',
        'la_tendina_della_sinastria',
        'avvio_sinastria_evolutiva',
        'lo_studio_di_medora',
      ])
        File('lib/features/synastry/$n.dart'),
    ];
    cardinaleMinimo(sorgenti.length, 10, cosa: 'sorgenti della Sinastria');
    final modello =
        RegExp(r'AiProvider|firebase_ai|GenerativeModel|generateContent');
    final conModello = [
      for (final f in sorgenti)
        if (modello.hasMatch(f.readAsStringSync())) f.path,
    ];
    expect(conModello, isEmpty,
        reason: 'la Sinastria evolutiva chiama un modello: la Lunga avrebbe '
            'un ripiego da provare ($conModello)');
  });

  // --- GD.18 ---------------------------------------------------------------

  testWidgets(
      'GD.18: il pulsante si accende coi dati completi, la riflessione di '
      'Medora, poi la statua grande e scontornata sul tavolo', (tester) async {
    await schermo(tester, const Size(390, 844));
    await tester.pumpWidget(app(ingresso()));
    await passa(tester, 8);
    await tocca(tester, const Key('sinastria_scegli_la_persona'));
    await tocca(tester, const Key('sinastria_tendina_offline'));
    await tocca(tester, const Key('sinastria_tendina_nuovo'));
    bool acceso() => tester
        .widget<PulsanteDipinto>(find.byKey(const Key('sinastria_scopri')))
        .onTap != null;
    expect(acceso(), isFalse, reason: 'il pulsante e\' acceso senza dati');
    await tester.enterText(
        find.byKey(const Key('sinastria_modulo_nome')), 'Giulia');
    await passa(tester, 2);
    expect(acceso(), isFalse, reason: 'acceso col solo nome');
    await tocca(tester, const Key('sinastria_modulo_data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(acceso(), isFalse, reason: 'acceso senza l\'ora');
    await tocca(tester, const Key('sinastria_modulo_ora_non_nota'));
    expect(acceso(), isFalse, reason: 'acceso senza il legame');
    await tocca(tester, const Key('sinastria_legame_amicizia'));
    expect(acceso(), isTrue, reason: 'i dati ci sono e il pulsante e\' spento');
    await tocca(tester, const Key('sinastria_scopri'));
    await passa(tester, 2);
    expect(find.byKey(const Key('sinastria_riflessione')), findsOneWidget,
        reason: 'al tocco non parte la riflessione di Medora');
    expect(find.byKey(const Key('stesa_attesa')), findsOneWidget,
        reason: 'la riflessione non e\' la stessa famiglia della Stesa');
    final statua = find.byKey(const Key('sinastria_evolutiva_statua'));
    double opacita() => tester
        .widget<AnimatedOpacity>(
            find.ancestor(of: statua, matching: find.byType(AnimatedOpacity)))
        .opacity;
    expect(opacita(), 0, reason: 'la statua compare prima della fine');
    await tester.pump(AttesaDiMedora.durataMinima);
    await tester.pump(LoStudioDiMedora.dissolvenzaDellaStatua);
    await passa(tester, 4);
    expect(find.byKey(const Key('sinastria_riflessione')), findsNothing);
    expect(opacita(), 1);
    final r = tester.getRect(statua);
    final medora = tester.getRect(find.byKey(const Key('studio_medora')));
    final asset =
        ((tester.widget<Image>(statua).image) as AssetImage).assetName;
    print('GD.18 LA STATUA: $asset, alta ${r.height.toStringAsFixed(1)} '
        'punti su 844 (${(r.height / 844 * 100).toStringAsFixed(1)} per '
        'cento), base a ${r.bottom.toStringAsFixed(1)}; Medora da '
        '${medora.top.toStringAsFixed(1)} a ${medora.bottom.toStringAsFixed(1)}');
    expect(r.height / 844, greaterThanOrEqualTo(0.35),
        reason: 'la statua e\' piccola: ${r.height} punti');
    expect(asset, startsWith('assets/img/sinastria/statua_'));
    // Sul tavolo: la base sotto la cintura di Medora, nel piano del tavolo.
    expect(r.bottom, greaterThan(medora.bottom));
    // Scontornata: il file ha un canale alfa con lo sfondo trasparente.
    final dati = File(asset).readAsBytesSync();
    final trasparenti = await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(dati);
      final f = await codec.getNextFrame();
      final px =
          (await f.image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      var zero = 0;
      for (var i = 3; i < px.lengthInBytes; i += 4) {
        if (px.getUint8(i) == 0) zero++;
      }
      return zero / (px.lengthInBytes / 4);
    });
    print('GD.18 PIXEL TRASPARENTI DELLA STATUA: '
        '${(trasparenti! * 100).toStringAsFixed(1)} per cento');
    expect(trasparenti, greaterThan(0.15),
        reason: 'la statua non e\' scontornata');
  });

  // --- GD.19 ---------------------------------------------------------------

  testWidgets(
      'GD.19: le barre subito dopo il titolo coi dati del calcolo, e ogni '
      'bolla ha la sua infografica, dello stesso tipo', (tester) async {
    await schermo(tester, const Size(390, 844));
    await rotta(tester, tier: Tier.tier2);
    final nomi = find.byKey(const Key('sinastria_evolutiva_nomi'));
    await scorriFino(tester, nomi);
    final barre = find.byKey(const Key('sinastria_barre_responso'));
    final rNomi = tester.getRect(nomi);
    final rBarre = tester.getRect(barre);
    print('GD.19 TITOLO fino a ${rNomi.bottom.toStringAsFixed(1)}, BARRE da '
        '${rBarre.top.toStringAsFixed(1)}');
    expect(rBarre.top, greaterThan(rNomi.bottom));
    expect(rBarre.top - rNomi.bottom, lessThan(100),
        reason: 'le barre non stanno subito dopo il titolo');
    final grafico = tester.widget<IlGraficoDelleBarre>(
        find.descendant(of: barre, matching: find.byType(IlGraficoDelleBarre)));
    // I valori, ricalcolati qui dagli aspetti: il contatto piu' stretto di
    // ogni capitolo, con l'orbo del suo tipo.
    final aspetti = AspettiEvolutivi.fra(_marco, _giulia);
    final attesi = [
      for (final c in Capitolo.values)
        aspetti
            .where(c.tocca)
            .map((a) => a.forzaCon(AspettiEvolutivi.orbo[a.tipo]!))
            .fold<double>(0, (m, f) => f > m ? f : m),
    ];
    print('GD.19 LE BARRE DEL RESPONSO: ${grafico.barre}');
    expect([for (final b in grafico.barre) b.valore], attesi);
    expect(grafico.barre.any((b) => b.valore > 0), isTrue);
    // Un'altra coppia, altri numeri: niente scritto a mano.
    final altra = LeBarreDellaSinastria.deiCapitoli(
        _marco,
        CieloEvolutivo.perNascita(
            momentoUtc: DateTime.utc(1975, 2, 20, 6), nome: 'Altra'));
    expect([for (final b in altra) b.valore], isNot(attesi));
    // Ogni bolla, il suo grafico, dello stesso tipo.
    final bolle = [
      'sinastria_barre_oggi',
      for (final c in Capitolo.values) 'sinastria_barre_${c.name}',
      'sinastria_barre_keplero',
      'sinastria_barre_composito',
    ];
    var trovate = 0;
    for (final b in bolle) {
      final f = find.byKey(Key(b));
      await scorriFino(tester, f);
      expect(
          find.descendant(of: f, matching: find.byType(IlGraficoDelleBarre)),
          findsOneWidget,
          reason: 'la bolla $b non ha la sua infografica');
      trovate++;
    }
    cardinaleMinimo(trovate, bolle.length,
        cosa: 'bolle con la loro infografica');
    print('GD.19 BOLLE CON LA LORO INFOGRAFICA: $trovate');
  });

  // --- GD.22 ---------------------------------------------------------------

  testWidgets(
      'GD.22: la scheda della coppia porta la riga viva, che cambia da un '
      'giorno all\'altro', (tester) async {
    await schermo(tester, const Size(390, 844));
    final righe = <String>[];
    for (final g in [DateTime(2026, 10, 23), DateTime(2026, 10, 24)]) {
      await rotta(tester, tier: Tier.free, oggi: g);
      righe.add(tester
          .widget<Text>(find.byKey(const Key('sinastria_riga_viva')))
          .data!);
    }
    print('GD.22 LA RIGA VIVA: 23 ottobre "${righe[0]}"; 24 ottobre '
        '"${righe[1]}"');
    expect(righe[0], isNot(righe[1]),
        reason: 'la riga viva e\' la stessa in due giorni diversi');
    expect(righe.every((r) => r.trim().isNotEmpty), isTrue);
    // La riga sta sulla scena, nella prima schermata.
    expect(tester.getRect(find.byKey(const Key('sinastria_riga_viva'))).bottom,
        lessThanOrEqualTo(844));
    expect(find.byType(InterruttoreDelCerchio), findsNothing);
  });
}

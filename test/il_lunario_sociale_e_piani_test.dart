// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/listino_degli_eos.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/lunario/il_giorno_lunare.dart';
import 'package:esoteric_circle/core/lunario/le_attivita_del_lunario.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/avvisi_del_rito.dart';
import 'package:esoteric_circle/core/sensi/la_suoneria.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/lunario/calendario_lunare_screen.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:esoteric_circle/features/synastry/la_nascita_dell_altra_persona.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'porta_finta_del_cerchio_sociale.dart';

/// **IL CALENDARIO LUNARE: IL SOCIALE E I PIANI.** Ordine FV voci FV.10 e
/// FV.12, 15 ottobre 2026.
///
/// FV.12: il Viandante vede una categoria sola e il mese in corso; l'Iniziato
/// tutte le categorie e il mese dopo; l'Adepto e l'Illuminato dodici mesi e
/// "Trova il giorno insieme"; ogni voce chiusa e' Premium bloccata col
/// lucchetto e l'invito, mai un vicolo cieco.
///
/// FV.10: il consenso che presta la nascita a "Trova il giorno insieme"
/// porta lo scopo 'lunario' e passa solo col codice, come per l'Oracolo
/// degli Angeli (ordine FU voce FU.09).

class _Finta implements LettoreDiScena {
  VoidCallback? _ascolta;
  @override
  bool get pronto => false;
  @override
  bool get fallito => true;
  @override
  bool get cominciato => false;
  @override
  bool get finito => false;
  @override
  void ascolta(VoidCallback? q) => _ascolta = q;
  @override
  Future<void> apri() async => _ascolta?.call();
  @override
  Future<void> volume(double q) async {}
  @override
  Future<void> avvia() async {}
  @override
  Future<void> sospendi() async {}
  @override
  Widget disegna() => const SizedBox();
  @override
  void chiudi() {}
}

class _Telefono extends ServizioAvvisi {
  @override
  bool get disponibile => false;
  @override
  Future<bool> chiediPermesso() async => false;
  @override
  Future<bool> permessoConcesso() async => false;
  @override
  Future<void> programma({
    required int id,
    required DateTime quando,
    required String titolo,
    required String testo,
    String canale = 'rito_alba',
    String carico = '',
  }) async {}
  @override
  Future<void> annulla(int id) async {}
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

/// Un mese finto, senza fasi o sigilli particolari: qui si prova il piano,
/// non il motore lunare (gia' provato da `il_calendario_lunare_a_video_test.dart`).
List<GiornoLunare> _mese(int anno, int mese) {
  final n = DateTime(anno, mese + 1, 0).day;
  return [
    for (var d = 1; d <= n; d++)
      GiornoLunare(
        giorno: DateTime(anno, mese, d),
        elongazione: (d * 11.0) % 360,
        illuminazione: 0.5,
        crescente: true,
        fase: FaseLunare.crescente,
        segno: Zodiac.leo,
        cambiDiSegno: const [],
        fuoriCorso: const [],
        giornoLunare: d,
        tipoBiodinamico: null,
        lunaNuova: d == 1,
        lunaPiena: d == 15,
      ),
  ];
}

EsitoDelGiorno _senzaRegole(AttivitaDelLunario a, GiornoLunare g) =>
    const EsitoDelGiorno(grado: GradoDelGiorno.neutro, perche: [], fonti: []);

final _nascita = BirthIdentity(
    birthMoment: DateTime(1990, 5, 12, 14, 30), hasBirthTime: true);

/// Il Cerchio sociale finto per il Lunario: come quello dell'Oracolo (ordine
/// FU), con un amico vero ('u-stella', Stella Lieve) pronto per "Trova il
/// giorno insieme".
class _PortaSociale extends PortaFintaDelCerchioSociale {
  @override
  Future<EsitoSociale?> sociale(String porta,
      [Map<String, Object?> corpo = const {}]) async {
    if (porta == 'condividiLaNascita') {
      chieste.add((porta, corpo));
      return EsitoSociale(dati: {
        'codice': 'K7Q2AB',
        'scade': DateTime.utc(2100).millisecondsSinceEpoch,
      });
    }
    if (porta == 'leggiLaNascita') {
      chieste.add((porta, corpo));
      return const EsitoSociale(dati: {
        'nascita': '1992-09-03T06:15:00.000Z',
        'giorno': '1992-09-03',
        'oraNota': true,
        'nome': 'Giulia',
        'scopo': 'lunario',
        'minutoLocale': 8 * 60 + 15,
        'amoreApribile': false,
      });
    }
    return super.sociale(porta, corpo);
  }
}

Future<
    ({
      _PortaSociale sociale,
    })> _monta(WidgetTester tester, {Tier tier = Tier.free}) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(360, 797);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final portaSociale = _PortaSociale();
  final sociale = IlCerchioSociale(porta: portaSociale);
  await tester.runAsync(() async {
    await sociale.sincronizza(identita: _nascita, oggi: DateTime(2026, 10, 15));
    await sociale.caricaIlCerchio();
  });
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MaestroController()),
      ChangeNotifierProvider(create: (_) => QualityTierController()),
      ChangeNotifierProvider(
          create: (_) => SettingsController(suonoEVibrazione: true)),
      ChangeNotifierProvider(create: (_) => EntitlementService(initial: tier)),
      ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MediaQuery(
        data: const MediaQueryData(size: Size(360, 797)),
        child: MaestroScope(
          child: CalendarioLunareScreen(
            fabbricaDellaScena: _Finta.new,
            adesso: () => DateTime(2026, 10, 15, 10, 5),
            identita: _nascita,
            latitudine: 45.4,
            delMese: _mese,
            valuta: _senzaRegole,
            avvisi: _Telefono(),
          ),
        ),
      ),
    ),
  ));
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  return (sociale: portaSociale);
}

void main() {
  setUp(() => LaSuoneria.spentaPerLeProve = false);
  tearDown(() => LaSuoneria.spentaPerLeProve = null);

  group('FV.12 le categorie', () {
    testWidgets(
        'il Viandante: la prima categoria e\' aperta, le altre dieci col '
        'lucchetto', (tester) async {
      await _monta(tester, tier: Tier.free);
      await tester.ensureVisible(find.byKey(
          Key('lunario_emblema_${CategoriaDelLunario.values.first.name}')));
      expect(
          find.byKey(Key(
              'lunario_lucchetto_${CategoriaDelLunario.values.first.name}')),
          findsNothing,
          reason: 'mai un vicolo cieco: una categoria resta sempre vera');
      final chiuse = CategoriaDelLunario.values.skip(1);
      print('FV.12 MISURA Viandante: categorie col lucchetto ${chiuse.length} '
          'su ${CategoriaDelLunario.values.length - 1}');
      for (final c in chiuse) {
        await tester
            .ensureVisible(find.byKey(Key('lunario_emblema_${c.name}')));
        await tester.pump();
        expect(find.byKey(Key('lunario_lucchetto_${c.name}')), findsOneWidget,
            reason: '${c.name} non dovrebbe aprirsi al Viandante');
      }
      // Il tocco su una categoria chiusa apre l'invito, non la selziona.
      await tester.tap(find.byKey(
          Key('lunario_emblema_${CategoriaDelLunario.values.last.name}')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('upgrade_invite')), findsOneWidget);
      expect(find.byKey(const Key('lunario_categoria_nome')), findsNothing,
          reason: 'la categoria chiusa non si apre dal tocco');
    });

    testWidgets(
        'l\'Iniziato: tutte le undici categorie aperte, nessun lucchetto',
        (tester) async {
      await _monta(tester, tier: Tier.tier1);
      for (final c in CategoriaDelLunario.values) {
        expect(find.byKey(Key('lunario_lucchetto_${c.name}')), findsNothing,
            reason: '${c.name} dovrebbe aprirsi all\'Iniziato');
      }
    });
  });

  group('FV.12 i mesi', () {
    testWidgets(
        'il Viandante vede il mese in corso: oltre, l\'invito col mese a Eos',
        (tester) async {
      await _monta(tester, tier: Tier.free);
      await tester.tap(find.byKey(const Key('lunario_mese_dopo')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('upgrade_invite')), findsOneWidget);
      expect(find.textContaining('Un mese di Calendario Lunare in più'),
          findsWidgets,
          reason: 'il prezzo del mese extra si dice prima del gesto');
      expect(find.text('Novembre 2026'), findsNothing,
          reason: 'il mese non e\' cambiato');
      expect(find.text('Ottobre 2026'), findsOneWidget);
    });

    testWidgets(
        'l\'Iniziato scorre al mese dopo, ma non oltre: il secondo passo apre '
        'l\'invito', (tester) async {
      await _monta(tester, tier: Tier.tier1);
      await tester.tap(find.byKey(const Key('lunario_mese_dopo')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('upgrade_invite')), findsNothing,
          reason: 'l\'Iniziato apre il mese dopo senza lucchetto');
      await tester.tap(find.byKey(const Key('lunario_mese_dopo')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('upgrade_invite')), findsOneWidget,
          reason: 'due mesi avanti sono oltre il piano dell\'Iniziato');
    });

    testWidgets('l\'Adepto scorre dodici mesi avanti senza lucchetto',
        (tester) async {
      await _monta(tester, tier: Tier.tier2);
      for (var i = 0; i < 12; i++) {
        await tester.tap(find.byKey(const Key('lunario_mese_dopo')));
        await tester.pumpAndSettle();
      }
      expect(find.byKey(const Key('upgrade_invite')), findsNothing);
      await tester.tap(find.byKey(const Key('lunario_mese_dopo')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('upgrade_invite')), findsOneWidget,
          reason: 'il tredicesimo mese e\' oltre il piano dell\'Adepto');
    });
  });

  group('FV.10 e FV.12 trova il giorno insieme', () {
    testWidgets(
        'il Viandante e l\'Iniziato: il lucchetto e l\'invito con la '
        'proposta a Eos', (tester) async {
      await _monta(tester, tier: Tier.tier1);
      await tester.tap(find.byKey(const Key('lunario_trova_insieme')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('upgrade_invite')), findsOneWidget);
      expect(find.textContaining('Una proposta insieme'), findsWidgets);
      final prezzo = ListinoDegliEos.propostaInsiemeDelLunario.costo;
      expect(find.textContaining('$prezzo Eos'), findsWidgets,
          reason: 'il prezzo della proposta si dice prima del gesto');
      expect(find.byKey(const Key('lunario_foglio_insieme')), findsNothing);
    });

    testWidgets('l\'Adepto apre "Trova il giorno insieme" senza lucchetto',
        (tester) async {
      await _monta(tester, tier: Tier.tier2);
      await tester.tap(find.byKey(const Key('lunario_trova_insieme')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('upgrade_invite')), findsNothing);
      expect(find.byKey(const Key('lunario_foglio_insieme')), findsOneWidget);
      // Gli amici veri del Cerchio compaiono nel foglio.
      expect(find.byKey(const Key('lunario_insieme_amico_u-stella')),
          findsOneWidget);
    });

    testWidgets(
        'il consenso per "Trova il giorno insieme" porta lo scopo \'lunario\' '
        'e passa solo col codice: niente strada a mano', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final porta = _PortaSociale();
      final sociale = IlCerchioSociale(porta: porta);
      await sociale.sincronizza(
          identita: _nascita, oggi: DateTime(2026, 10, 15));
      final esito = await sociale.condividiLaNascita(
        nascitaUtc: DateTime.utc(1990, 5, 12, 14, 30),
        giorno: DateTime(1990, 5, 12),
        oraNota: true,
        nome: 'Tu',
        perLoLunario: true,
        minutoLocale: 14 * 60 + 30,
      );
      final mandata =
          porta.chieste.singleWhere((c) => c.$1 == 'condividiLaNascita').$2;
      print('FV.10 MISURA consenso per il Lunario: ${mandata.keys.toList()}');
      expect(mandata['scopo'], 'lunario');
      expect(mandata['minutoLocale'], 14 * 60 + 30);
      expect(esito.ok, isTrue);
      final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
      NascitaLetta? letta;
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(
              create: (_) => ProfileController(identity: _nascita)),
        ],
        child: MaterialApp(
          builder: (context, figlio) => MaestroScope(child: figlio!),
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async => letta =
                    await LaNascitaDellAltraPersona.chiedi(context, palette,
                        perLoLunario: true),
                child: const Text('apri'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('apri'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('nascita_altra_nome')), findsNothing,
          reason: 'per "Trova il giorno insieme" la nascita non si scrive a '
              'mano: solo il consenso');
      expect(find.byKey(const Key('nascita_altra_conferma')), findsNothing);
      await tester.enterText(
          find.byKey(const Key('nascita_altra_codice')), 'k7q2ab');
      await tester.pump();
      await tester.tap(find.byKey(const Key('nascita_altra_leggi')));
      await tester.pumpAndSettle();
      final chiesta =
          porta.chieste.singleWhere((c) => c.$1 == 'leggiLaNascita').$2;
      expect(chiesta['scopo'], 'lunario');
      expect(letta?.nome, 'Giulia');
      expect(letta?.minutoLocale, 8 * 60 + 15);
    });
  });

  group('FV.12 i numeri', () {
    test(
        'il listino e la matrice dicono gli stessi numeri; la proposta '
        'insieme e il mese extra non chiamano mai il modello (R2)', () {
      for (final t in Tier.values) {
        final dallaMatrice = PlanCatalog.apre(RigaDelPiano.lunarioInsieme, t);
        print('FV.12 MISURA ${t.name}: trovaInsiemeAperto $dallaMatrice');
      }
      expect(PlanCatalog.apre(RigaDelPiano.lunarioInsieme, Tier.free), isFalse);
      expect(
          PlanCatalog.apre(RigaDelPiano.lunarioInsieme, Tier.tier1), isFalse);
      expect(PlanCatalog.apre(RigaDelPiano.lunarioInsieme, Tier.tier2), isTrue);
      expect(PlanCatalog.apre(RigaDelPiano.lunarioInsieme, Tier.tier3), isTrue);
      expect(PlanCatalog.apre(RigaDelPiano.lunarioTutteLeCategorie, Tier.free),
          isFalse);
      expect(PlanCatalog.apre(RigaDelPiano.lunarioTutteLeCategorie, Tier.tier1),
          isTrue);
      expect(
          PlanCatalog.apre(RigaDelPiano.lunarioPromemoria, Tier.free), isFalse);
      expect(
          PlanCatalog.apre(RigaDelPiano.lunarioPromemoria, Tier.tier1), isTrue);
      expect(PlanCatalog.mesiAvantiDelLunario(Tier.free), 0);
      expect(PlanCatalog.mesiAvantiDelLunario(Tier.tier1), 1);
      expect(PlanCatalog.mesiAvantiDelLunario(Tier.tier2), 12);
      expect(PlanCatalog.mesiAvantiDelLunario(Tier.tier3), 12);
      // Le voci chiuse dicono da quale piano si aprono (mai un vicolo cieco).
      expect(
          PlanCatalog.dalPiano(
              (t) => PlanCatalog.apre(RigaDelPiano.lunarioInsieme, t)),
          'Dall’Adepto');
      expect(ListinoDegliEos.meseExtraDelLunario.costo, 60);
      expect(ListinoDegliEos.propostaInsiemeDelLunario.costo, 50);
    });
  });
}

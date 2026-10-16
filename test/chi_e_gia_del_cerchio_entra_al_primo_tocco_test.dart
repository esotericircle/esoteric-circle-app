// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/identity/account_del_cerchio.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/account/custodia_del_cielo.dart';
import 'package:esoteric_circle/features/onboarding/custodia_del_cielo_step.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// CHI E' GIA' DEL CERCHIO ENTRA AL PRIMO TOCCO. Ordine FS, 13 ottobre 2026.
///
/// **Il fatto, visto dal fondatore sulla build 2308.** Nella registrazione
/// dopo l'onboarding, "Non perdere il tuo cielo": si spunta la casella, si
/// tocca "Continua con Google", si sceglie l'account. Quell'identita' e' gia'
/// di un altro Cerchio, la porta risponde `giaDiUnAltroCerchio`, e la
/// schermata restava li' AGGIUNGENDO "Continua come", con una SECONDA casella
/// di consenso, e sotto di nuovo le vie della custodia con una terza copia
/// della stessa riga legale e un secondo "Continua con Google". Dal menu'
/// utente lo stesso, senza il blocco sotto (gia' tolto dall'ordine FN).
///
/// **La domanda del fondatore**: si chiede UNA volta; scelto l'account
/// Google, se quell'identita' esiste gia' si entra direttamente in quel
/// Cerchio, senza un'altra schermata praticamente identica e senza ripetere
/// i testi legali.
///
/// **Cosa pretende.** Con una porta che risponde `giaDiUnAltroCerchio` e
/// porta nel rifiuto una credenziale buona: in ogni fotogramma al massimo
/// UNA casella di consenso e al massimo UN "Continua con Google"; il passo
/// finisce (o il foglio si chiude da vincitore) senza un secondo tocco; e la
/// riga che dice cosa succede a Eos e ricordi si legge una volta. Quando la
/// credenziale non entra, la rete "Continua come" compare DA SOLA: nessuna
/// casella, nessun secondo Google.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(const {}));

  /// Pompa a passi e misura in ogni fotogramma quante caselle e quanti
  /// "Continua con Google" ci sono: il difetto era la somma di due scene.
  Future<({int caselle, int google, bool rigaVista})> pompaEContaIlMassimo(
      WidgetTester tester,
      {int passi = 12}) async {
    var caselle = 0;
    var google = 0;
    var rigaVista = false;
    for (var i = 0; i < passi; i++) {
      await tester.pump(const Duration(milliseconds: 120));
      final c = find.byKey(const Key('consenso_casella')).evaluate().length;
      final g = find.byKey(const Key('custodia_google')).evaluate().length;
      if (c > caselle) caselle = c;
      if (g > google) google = g;
      if (find.textContaining('Eos e ricordi restano').evaluate().isNotEmpty) {
        rigaVista = true;
      }
    }
    return (caselle: caselle, google: google, rigaVista: rigaVista);
  }

  Widget conIProvider(AccountDelCerchio account, Widget casa) => MultiProvider(
        providers: [
          ChangeNotifierProvider<AccountDelCerchio>.value(value: account),
          ChangeNotifierProvider(create: (_) => MaestroController()),
        ],
        child: MaterialApp(
          builder: (ctx, child) => MaestroScope(child: child!),
          home: casa,
        ),
      );

  group('il passo del Risveglio, "Non perdere il tuo cielo"', () {
    testWidgets('scelto Google, chi e\' gia\' di un Cerchio entra subito',
        (tester) async {
      final porta = _PortaGiaDiUnAltro(credenzialeEntra: true);
      final account = AccountDelCerchio(porta: porta)..rileggi();
      var fine = 0;
      await tester.pumpWidget(conIProvider(
        account,
        Scaffold(
          body: CustodiaDelCieloStep(
              maestro: Maestro.medora, suFine: () => fine++),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 120));
      await tester.tap(find.byKey(const Key('consenso_casella')),
          warnIfMissed: false);
      await tester.pump();
      await tester.tap(find.byKey(const Key('custodia_google')),
          warnIfMissed: false);
      final misura = await pompaEContaIlMassimo(tester);
      print('ORDINE FS, passo: caselle al massimo ${misura.caselle}, Google '
          'al massimo ${misura.google}, suFine $fine, ingressi diretti '
          '${porta.ingressiDiretti}, tocchi su Continua come '
          '${porta.continuaCome}, riga di Eos e ricordi vista '
          '${misura.rigaVista}');
      expect(misura.caselle, lessThanOrEqualTo(1),
          reason: 'a video ci sono state ${misura.caselle} caselle di '
              'consenso insieme: i testi legali si ripetono');
      expect(misura.google, lessThanOrEqualTo(1),
          reason: 'e\' comparso un secondo "Continua con Google"');
      expect(fine, 1,
          reason: 'il passo non e\' finito: chi e\' gia\' del Cerchio deve '
              'entrare senza un secondo tocco');
      expect(porta.ingressiDiretti, 1,
          reason: 'non si e\' entrati con la credenziale del rifiuto');
      expect(porta.continuaCome, 0,
          reason: 'per entrare e\' servito il tocco su "Continua come"');
      expect(porta.selettoriRiaperti, 0,
          reason: 'il selettore di Google si e\' riaperto');
      expect(misura.rigaVista, isTrue,
          reason: 'chi entra non legge che Eos e ricordi restano quelli del '
              'Cerchio in cui entra: perde gli Eos di questo telefono senza '
              'saperlo');
    });

    testWidgets(
        'se la credenziale non entra, la rete compare da sola, senza '
        'seconda casella', (tester) async {
      final porta = _PortaGiaDiUnAltro(credenzialeEntra: false);
      final account = AccountDelCerchio(porta: porta)..rileggi();
      var fine = 0;
      await tester.pumpWidget(conIProvider(
        account,
        Scaffold(
          body: CustodiaDelCieloStep(
              maestro: Maestro.medora, suFine: () => fine++),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 120));
      await tester.tap(find.byKey(const Key('consenso_casella')),
          warnIfMissed: false);
      await tester.pump();
      await tester.tap(find.byKey(const Key('custodia_google')),
          warnIfMissed: false);
      final misura = await pompaEContaIlMassimo(tester);
      final caselleDopo =
          find.byKey(const Key('consenso_casella')).evaluate().length;
      final googleDopo =
          find.byKey(const Key('custodia_google')).evaluate().length;
      print('ORDINE FS, rete del passo: caselle al massimo '
          '${misura.caselle}, a riposo $caselleDopo; Google a riposo '
          '$googleDopo');
      expect(misura.caselle, lessThanOrEqualTo(1));
      expect(caselleDopo, 0,
          reason: 'la rete monta una seconda casella: il consenso dato '
              'prima del tocco su Google vale');
      expect(googleDopo, 0,
          reason: 'sotto la rete ricompare "Continua con Google"');
      expect(find.byKey(const Key('continua_come')), findsOneWidget,
          reason: 'la rete non c\'e\': e\' il vicolo cieco della 2179');
      expect(find.byKey(const Key('continua_come_riga_onesta')), findsOneWidget,
          reason: 'la rete non dice cosa succede a Eos e ricordi');
      // E la rete entra al primo tocco, senza casella da spuntare.
      await tester.tap(find.byKey(const Key('continua_come')));
      await pompaEContaIlMassimo(tester, passi: 6);
      expect(porta.continuaCome, 1);
      expect(fine, 1,
          reason: 'il tocco su "Continua come" non chiude il passo');
    });
  });

  group('il foglio del menu\' utente, "Registra e conserva il tuo Cerchio"',
      () {
    testWidgets('scelto Google, chi e\' gia\' di un Cerchio entra subito',
        (tester) async {
      final porta = _PortaGiaDiUnAltro(credenzialeEntra: true);
      final account = AccountDelCerchio(porta: porta)..rileggi();
      final chiave = GlobalKey();
      await tester.pumpWidget(
          conIProvider(account, Scaffold(body: SizedBox(key: chiave))));
      bool? chiuso;
      mostraInvitoACustodire(chiave.currentContext!, momenti: 3)
          .then((v) => chiuso = v);
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 120));
      }
      await tester.tap(find.byKey(const Key('consenso_casella')),
          warnIfMissed: false);
      await tester.pump();
      await tester.tap(find.byKey(const Key('custodia_google')),
          warnIfMissed: false);
      final misura = await pompaEContaIlMassimo(tester);
      print('ORDINE FS, foglio: caselle al massimo ${misura.caselle}, Google '
          'al massimo ${misura.google}, chiuso $chiuso, ingressi diretti '
          '${porta.ingressiDiretti}, tocchi su Continua come '
          '${porta.continuaCome}, riga vista ${misura.rigaVista}');
      expect(misura.caselle, lessThanOrEqualTo(1),
          reason: 'a video ci sono state ${misura.caselle} caselle insieme');
      expect(misura.google, lessThanOrEqualTo(1));
      expect(chiuso, isTrue,
          reason: 'il foglio non si e\' chiuso da vincitore: per entrare '
              'serve ancora un secondo tocco');
      expect(porta.ingressiDiretti, 1);
      expect(porta.continuaCome, 0);
      expect(porta.selettoriRiaperti, 0);
      expect(misura.rigaVista, isTrue,
          reason: 'chi entra non legge che Eos e ricordi restano quelli del '
              'Cerchio in cui entra');
    });

    testWidgets('se la credenziale non entra, la rete compare da sola',
        (tester) async {
      final porta = _PortaGiaDiUnAltro(credenzialeEntra: false);
      final account = AccountDelCerchio(porta: porta)..rileggi();
      final chiave = GlobalKey();
      await tester.pumpWidget(
          conIProvider(account, Scaffold(body: SizedBox(key: chiave))));
      bool? chiuso;
      mostraInvitoACustodire(chiave.currentContext!, momenti: 3)
          .then((v) => chiuso = v);
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 120));
      }
      await tester.tap(find.byKey(const Key('consenso_casella')),
          warnIfMissed: false);
      await tester.pump();
      await tester.tap(find.byKey(const Key('custodia_google')),
          warnIfMissed: false);
      await pompaEContaIlMassimo(tester);
      expect(find.byKey(const Key('consenso_casella')), findsNothing,
          reason: 'la rete monta una seconda casella di consenso');
      expect(find.byKey(const Key('custodia_google')), findsNothing);
      expect(find.byKey(const Key('continua_come')), findsOneWidget);
      await tester.tap(find.byKey(const Key('continua_come')));
      await pompaEContaIlMassimo(tester, passi: 6);
      expect(porta.continuaCome, 1);
      expect(chiuso, isTrue,
          reason: 'il tocco su "Continua come" non chiude il foglio');
    });
  });
}

/// La porta di chi sceglie un account Google gia' di un altro Cerchio.
class _PortaGiaDiUnAltro implements PortaDellIdentita {
  _PortaGiaDiUnAltro({required this.credenzialeEntra});

  /// Vero: la credenziale del rifiuto entra. Falso: non entra, e serve la
  /// rete.
  final bool credenzialeEntra;

  int ingressiDiretti = 0;
  int continuaCome = 0;
  int selettoriRiaperti = 0;
  bool entrato = false;
  IdentitaRiconosciuta? _riconosciuta;

  @override
  DateTime? get natoIl => null;

  @override
  String? get uid => entrato ? 'uid-riconosciuto' : 'uid-anonimo';

  @override
  bool get anonimo => !entrato;

  @override
  String? get email => entrato ? 'mauro@esempio.it' : null;

  @override
  List<String> get fornitori => entrato ? const ['google.com'] : const [];

  @override
  Future<String?> assicuraUnAccount() async => uid;

  @override
  Future<void> ricarica() async {}

  @override
  IdentitaRiconosciuta? get riconosciuta => _riconosciuta;

  @override
  Future<EsitoDellaCustodia> eleva(
    ViaDellaCustodia via, {
    String? email,
    String? parola,
  }) async {
    _riconosciuta = IdentitaRiconosciuta(
      nome: 'mauro@esempio.it',
      credenziale: GoogleAuthProvider.credential(
          idToken: 'id-dal-rifiuto', accessToken: 'access-dal-rifiuto'),
      via: via,
      dallErrore: true,
    );
    return EsitoDellaCustodia.giaDiUnAltroCerchio;
  }

  @override
  Future<EsitoDellaCustodia> entraConLaCredenzialeDelRifiuto() async {
    final r = _riconosciuta;
    if (r == null || !r.dallErrore) return EsitoDellaCustodia.nonRiuscita;
    if (!credenzialeEntra) {
      _riconosciuta =
          IdentitaRiconosciuta(nome: r.nome, credenziale: null, via: r.via);
      return EsitoDellaCustodia.nonRiuscita;
    }
    ingressiDiretti++;
    entrato = true;
    _riconosciuta = null;
    return EsitoDellaCustodia.riuscita;
  }

  @override
  Future<EsitoDellaCustodia> entraComeRiconosciuto() async {
    continuaCome++;
    if (_riconosciuta == null) return EsitoDellaCustodia.nonRiuscita;
    entrato = true;
    _riconosciuta = null;
    return EsitoDellaCustodia.riuscita;
  }

  @override
  Future<EsitoDellaCustodia> entraDirettamente(
    ViaDellaCustodia via, {
    String? email,
    String? parola,
  }) async {
    selettoriRiaperti++;
    return EsitoDellaCustodia.nonRiuscita;
  }

  @override
  Future<String?> nomeGiaProposto() async => null;

  @override
  Future<void> esci() async {}

  @override
  bool? get emailVerificata => null;

  @override
  Future<EsitoDellaCustodia> mandaLaViaPerLaParola(String email) async =>
      EsitoDellaCustodia.nonRiuscita;

  @override
  Future<EsitoDellaCustodia> mandaLaVerificaDellEmail() async =>
      EsitoDellaCustodia.nonRiuscita;

  @override
  Future<EsitoDellaCustodia> cambiaLaParola(String nuova) async =>
      EsitoDellaCustodia.nonRiuscita;

  @override
  Future<EsitoDellaCustodia> cambiaLEmail(String nuova) async =>
      EsitoDellaCustodia.nonRiuscita;

  @override
  Future<EsitoDellaCustodia> mandaIlLinkDIngresso(String email) async =>
      EsitoDellaCustodia.nonRiuscita;

  @override
  bool eUnLinkDIngresso(String link) => false;

  @override
  Future<EsitoDellaCustodia> entraColLink(
          {required String link, required String email}) async =>
      EsitoDellaCustodia.nonRiuscita;
}

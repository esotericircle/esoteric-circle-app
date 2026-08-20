import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL SALDO E IL CAMMINO SI CHIEDONO ALL'AVVIO. Ordine AP voce 02.
///
/// **Il fatto**: Mauro reinstalla l'app, rientra con lo stesso account, e il
/// borsellino torna SOLO dopo aver visitato il Passport.
///
/// **La causa, misurata qui e diversa da come la premessa P3 la
/// raccontava.** La premessa diceva che nessuno chiede lo stato all'avvio.
/// Non e' esatto: `lib/app.dart` costruisce `QuestionAllowance` con la
/// cascata `..load()..sincronizza()`, quindi la chiamata C'E' scritta. Il
/// punto e' che quel provider e' PIGRO, come tutti i `create:` di provider:
/// l'oggetto nasce alla PRIMA LETTURA, non all'avvio. Finche' nessuna
/// schermata legge il borsellino, nessuno nasce e nessuno chiede niente; il
/// Passport lo legge, ed e' per questo che il saldo compariva solo di la'.
///
/// **Cosa pretende questa guardia**: che montando l'app e non toccando
/// niente lo stato sia gia' stato chiesto, e che il cammino del telefono sia
/// partito con la richiesta.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(nome), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Future<_PortaCheConta> apri(
    WidgetTester tester, {
    Map<String, Object> prefs = const {
      'onboarding.done': true,
      'santuario.greeted': true,
    },
  }) async {
    silenzia();
    SharedPreferences.setMockInitialValues(prefs);
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 797);
    addTearDown(tester.view.reset);
    final porta = _PortaCheConta();
    await tester.pumpWidget(EsotericCircleApp(
      conIntro: false,
      services: AppServices.offline('prova AP.02', porta),
    ));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    return porta;
  }

  testWidgets('montata l\'app, lo stato e\' gia\' stato chiesto',
      (tester) async {
    final porta = await apri(tester);
    // ignore: avoid_print
    print('ORDINE AP VOCE 02: senza toccare niente, stato chiesto '
        '${porta.quanteVolte} volte');
    expect(porta.quanteVolte, greaterThan(0),
        reason: 'aperta l\'app, nessuno ha chiesto lo stato al Cerchio: il '
            'saldo comparira\' solo quando qualcuno leggera\' il borsellino, '
            'ed e\' il difetto che Mauro ha visto sulla 2183');
  });

  testWidgets('e il cammino del telefono parte insieme alla richiesta',
      (tester) async {
    // Un telefono che ha gia' un cammino: se non lo mandasse, il Cerchio non
    // avrebbe niente da custodire e la fusione non avrebbe due parti.
    final porta = await apri(tester, prefs: const {
      'onboarding.done': true,
      'santuario.greeted': true,
      'cammino.gesti': '{"stesa":3}',
      'cammino.accesi': <String>['med_1'],
      // **LA GENERAZIONE E' GIA' QUELLA, ordine AR voce 06.** Senza questa
      // riga il telefono di questa prova risulterebbe alla sua PRIMA
      // apertura dopo la riprogettazione del Cammino, e il custode
      // azzererebbe tutto prima di raccogliere: il cammino mandato
      // arriverebbe vuoto, e non perche' la sincronia sia rotta.
      'cammino.generazione': 2,
    });
    // ignore: avoid_print
    print('ORDINE AP VOCE 02: cammini mandati ${porta.camminiMandati}, '
        'gesti nell\'ultimo ${porta.ultimoCammino?.gesti}');
    expect(porta.camminiMandati, greaterThan(0),
        reason: 'lo stato e\' stato chiesto senza portare il cammino del '
            'telefono: il Cerchio non ha niente da custodire');
    expect(porta.ultimoCammino?.gesti['stesa'], 3,
        reason: 'il cammino mandato non porta i gesti del telefono');
    expect(porta.ultimoCammino?.sigilli.keys, contains('med_1'),
        reason: 'il cammino mandato non porta i Sigilli accesi');
  });

  testWidgets('senza rete non si mostra un saldo falso e non si cancella '
      'niente', (tester) async {
    final porta = _PortaMuta();
    silenzia();
    SharedPreferences.setMockInitialValues(const {
      'onboarding.done': true,
      'santuario.greeted': true,
      'cammino.gesti': '{"stesa":3}',
      'cammino.accesi': <String>['med_1'],
      // **LA GENERAZIONE E' GIA' QUELLA, ordine AR voce 06.** Senza questa
      // riga il telefono di questa prova risulterebbe alla sua PRIMA
      // apertura dopo la riprogettazione del Cammino, e il custode
      // azzererebbe tutto prima di raccogliere: il cammino mandato
      // arriverebbe vuoto, e non perche' la sincronia sia rotta.
      'cammino.generazione': 2,
    });
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 797);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(EsotericCircleApp(
      conIntro: false,
      services: AppServices.offline('prova AP.02 senza rete', porta),
    ));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    // Il cammino sul telefono e' ancora tutto li'.
    final prefs = await SharedPreferences.getInstance();
    // ignore: avoid_print
    print('ORDINE AP VOCE 02: senza rete, sul disco restano '
        '${prefs.getStringList('cammino.accesi')} e '
        '${prefs.getString('cammino.gesti')}');
    expect(prefs.getStringList('cammino.accesi'), contains('med_1'),
        reason: 'senza rete il Cerchio ha cancellato i Sigilli accesi: '
            'nessuna storia si cancella mai');
    expect(prefs.getString('cammino.gesti'), contains('stesa'),
        reason: 'senza rete i gesti sono spariti dal disco');
  });
}

/// La porta che conta le richieste e ricorda cosa le e' arrivato.
class _PortaCheConta extends PortaDelCerchio {
  int quanteVolte = 0;
  int camminiMandati = 0;
  CamminoDaCustodire? ultimoCammino;

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
          {CamminoDaCustodire? cammino, bool azzeraIlCammino = false}) async {
    quanteVolte++;
    if (cammino != null && !cammino.eVuoto) {
      camminiMandati++;
      ultimoCammino = cammino;
    }
    return StatoDelCerchio(
      giorno: '2026-08-19',
      piano: 'free',
      spesi: const {},
      saldoEos: 250,
      cammino: cammino,
    );
  }

  @override
  Future<EsitoDelConsumo?> consuma(
          {required String budget, required String idMovimento}) async =>
      null;

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async =>
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

/// La porta viva che non risponde: e' la rete che manca.
class _PortaMuta extends _PortaCheConta {
  @override
  Future<StatoDelCerchio?> stato(
          {CamminoDaCustodire? cammino, bool azzeraIlCammino = false}) async {
    quanteVolte++;
    return null;
  }
}

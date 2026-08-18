import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/registro_degli_eos.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sigilli/bonus_della_condivisione.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/celebrazione.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'istante_dichiarato.dart';

/// I TRE PULSANTI DELLA CELEBRAZIONE CONDIVIDONO DAVVERO. Ordine S voce 08.
///
/// **Il difetto, e perche' era il piu' caro.** "Invita qualcuno nel Cerchio",
/// "Condividi pubblicamente" e "Manda a qualcuno" non facevano niente: nessun
/// foglio di sistema si apriva. Un controllo o e' collegato a qualcosa o e'
/// dichiarato inattivo, e non esiste la terza possibilita'. Ed era peggio del
/// solito, perche' quei tre pulsanti sono l'unico posto da cui il bonus di
/// condivisione si incassa: finche' non funzionavano, il bonus graduato non
/// esisteva per nessuno.
///
/// **COME SI MISURA UNA CONDIVISIONE SENZA UN TELEFONO.** Si sostituisce la
/// piattaforma di `share_plus` con una che REGISTRA cio' che le viene chiesto:
/// e' l'unico punto oltre il quale il gesto lascia l'app, e cosi' la prova legge
/// il testo esatto che sarebbe partito. Una prova che cercasse
/// `PortaDellaCondivisione` nel sorgente passerebbe anche con un pulsante
/// scollegato.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // **UNA PIATTAFORMA SOLA PER TUTTO IL FILE, e non e' pigrizia.**
  // `SharePlus.instance` e' un `static final` che CATTURA
  // `SharePlatform.instance` al primo accesso: sostituirla a ogni prova non ha
  // effetto, le chiamate continuano ad arrivare alla prima. La prima stesura lo
  // faceva, e si vedeva bene: la prima delle tre prove passava e le altre due
  // trovavano il registro vuoto, mentre il testo condiviso finiva nel finto
  // della prova precedente. Si tiene un solo finto e si azzera il suo stato.
  final piattaforma = _PiattaformaCheRegistra();
  SharePlatform.instance = piattaforma;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    piattaforma.chiamate.clear();
    piattaforma.rifiuta = false;
  });

  final grande = Sentieri.grandiDi(Sentiero.costellazione).first;

  Future<_PortaCheDaIlBonus> monta(WidgetTester tester) async {
    final porta = _PortaCheDaIlBonus();
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<AppServices>.value(
            value: AppServices.offline('prova della voce S.08', porta)),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance(porta: porta)),
        ChangeNotifierProvider(create: (_) => RegistroDegliEos()),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: CelebrazioneAScermoPieno(
          traguardi: [grande],
          sentieri: const [Sentiero.costellazione],
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 600));
    return porta;
  }

  for (final modo in ModoDellaCondivisione.values) {
    testWidgets('«${modo.etichetta}» apre davvero la condivisione',
        (tester) async {
      final porta = await monta(tester);
      final pulsante = find.text(modo.etichetta);
      expect(pulsante, findsOneWidget,
          reason: 'il pulsante «${modo.etichetta}» non c\'e\' nella '
              'celebrazione grande');

      await tester.tap(pulsante);
      // Il gesto attraversa la porta unica, che e' asincrona: si avanza a passi
      // dichiarati, perche' la celebrazione porta animazioni che non si
      // assestano mai.
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      expect(piattaforma.chiamate, hasLength(1),
          reason: 'toccando «${modo.etichetta}» non e\' partito niente: il '
              'pulsante non e\' collegato a nulla, ed e\' la violazione piu\' '
              'cara che esista in questo progetto');
      final testo = piattaforma.chiamate.single.text ?? '';
      expect(testo, contains(grande.nome),
          reason: 'il testo condiviso non nomina il traguardo acceso: '
              '«$testo»');
      expect(testo, TestoDellaCondivisione.perIlTraguardo(grande, modo),
          reason: 'il testo condiviso non e\' quello del modo scelto: i tre '
              'gesti sono tre, e tre testi diversi');

      // IL BONUS SI INCASSA, e solo dopo la condivisione.
      //
      // **L'INVITO FA ECCEZIONE, ordine AN voce 08, e non e' un
      // allentamento.** Il suo premio arriva quando l'amico SCARICA il
      // Cerchio, e saperlo richiede un'attribuzione dell'installazione che
      // nel progetto non esiste: accreditarlo alla condivisione mentre il
      // pulsante dichiara "quando il tuo amico scarica" sarebbe una bugia a
      // schermo. Resta dichiarato in attesa sulla card. La pretesa qui
      // diventa quindi piu' STRETTA, non piu' larga: si paga esattamente
      // cio' che si e' promesso.
      expect(porta.motivi, modo.subitoPagato ? [modo.motivo] : isEmpty,
          reason: modo.subitoPagato
              ? 'il bonus chiesto al server non e\' quello del modo scelto: '
                  '${porta.motivi}'
              : 'l\'invito e\' stato pagato alla condivisione, ma il suo '
                  'premio dipende dal download dell\'amico e nessuno sa '
                  'ancora se e\' avvenuto: ${porta.motivi}');
    });
  }

  testWidgets('se la condivisione non parte, il bonus NON si incassa',
      (tester) async {
    // **Il contrario, e serve.** Senza questa prova si potrebbe far passare la
    // prima incassando il bonus comunque, che e' un premio per un gesto mai
    // avvenuto: e' precisamente il difetto di prima, con in piu' il danno di un
    // Eos regalato. `false` dalla porta non e' solo un guasto: e' anche la
    // persona che ha aperto il foglio di sistema e ha cambiato idea.
    piattaforma.rifiuta = true;
    final porta = await monta(tester);
    await tester.tap(find.text(ModoDellaCondivisione.socialPubblico.etichetta));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(porta.motivi, isEmpty,
        reason: 'la condivisione non e\' partita e il bonus e\' stato chiesto '
            'comunque: e\' un premio per un gesto mai avvenuto');
  });
}

/// La piattaforma di condivisione che non condivide: REGISTRA.
class _PiattaformaCheRegistra extends SharePlatform {
  final List<ShareParams> chiamate = [];

  /// Come la persona che apre il foglio di sistema e chiude senza mandare.
  bool rifiuta = false;

  @override
  Future<ShareResult> share(ShareParams params) async {
    if (rifiuta) throw Exception('la condivisione non e\' partita');
    chiamate.add(params);
    return const ShareResult('ok', ShareResultStatus.success);
  }
}

/// La porta che concede il bonus e ricorda per quale motivo e' stato chiesto.
class _PortaCheDaIlBonus extends PortaDelCerchio {
  final List<String> motivi = [];
  int saldo = 0;

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato() async => null;

  @override
  Future<EsitoDelConsumo?> consuma({
    required String budget,
    required String idMovimento,
  }) async =>
      null;

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async {
    // Il premio del traguardo non c'entra con questa voce: si guardano solo i
    // bonus di condivisione.
    if (causale == 'bonus_condivisione') {
      motivi.add(motivo);
      saldo += 5;
    }
    return saldo;
  }

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

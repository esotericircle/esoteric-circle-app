import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/libro_degli_accrediti.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/features/sigilli/regia_del_cammino.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// GLI EOS ARRIVANO DAVVERO NEL BORSELLINO. Ordine AL voce 05.
///
/// **Il filo enumerato sulla 2179, passo per passo, con le prove**:
/// il gesto si segna e il Sigillo si accende (vivo, guardie del cammino); la
/// festa promette gli Eos (vivo, il telefono di Mauro la mostra); la chiamata
/// PARTE dal telefono e ARRIVA a Cloud Run (vivo, provato dai log del
/// server); la porta del servizio la RESPINGE con 401 prima che il codice
/// giri (ROTTO: cinque callable su sei avevano la policy IAM vuota, solo
/// natalchart aveva allUsers con run.invoker, ed e' infatti l'unica cosa che
/// funzionava); il client rilancia l'errore, la regia lo registra nei guasti
/// e la pillola resta a zero (vivo ma muto). La cura del server e' il passo
/// manuale guidato di Mauro, dichiarato nel manifesto.
///
/// **La cura del client che questa prova sorveglia**: la promessa "il premio
/// si riprende alla prossima sincronia" non aveva il meccanismo, `accredita`
/// aveva un solo chiamante. Ora esiste il libro degli accrediti riusciti e la
/// sincronia `riprendiIPremiPersi`: i traguardi ACCESI fuori dal libro si
/// riprovano una volta per sessione, il movimento idempotente impedisce il
/// doppio conto e il saldo finale si chiede allo stato intero del server,
/// perche' una risposta ripetuta porta il saldo di allora e applicarla
/// regredirebbe la pillola.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('i premi dei Sigilli accesi e mai pagati si riprendono e la '
      'pillola si aggiorna', (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    RegiaDelCammino.ripresaTentata = false;
    final porta = _PortaCheConta();
    final diario = DiarioDelCammino(orologio: () => DateTime(2026, 8, 18, 9));
    await diario.carica();
    // Tre Sigilli accesi sulla 2179, nessun premio arrivato: il libro e'
    // vuoto, come sul telefono di Mauro.
    await diario.accendi('med_1');
    await diario.accendi('med_2');
    await diario.accendi('cal_1');
    final borsa = QuestionAllowance(porta: porta);
    final chiave = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
        Provider<AppServices>.value(
            value: AppServices.offline('prova', porta)),
        ChangeNotifierProvider<QuestionAllowance>.value(value: borsa),
      ],
      child: MaterialApp(home: Scaffold(body: SizedBox(key: chiave))),
    ));

    await RegiaDelCammino.riprendiIPremiPersi(chiave.currentContext!);
    await tester.pump(const Duration(milliseconds: 100));

    // ignore: avoid_print
    print('ORDINE AL VOCE 05: movimenti chiesti ${porta.movimenti}');
    expect(porta.movimenti.toSet(),
        {'traguardo-med_1', 'traguardo-med_2', 'traguardo-cal_1'},
        reason: 'la sincronia non ha ripreso i premi dei Sigilli accesi: e\' '
            'la promessa senza meccanismo della 2179');
    expect(borsa.saldoEos, 40,
        reason: 'la pillola non porta il saldo sovrano detto dal server');
    expect(await LibroDegliAccrediti.accreditati(),
        {'med_1', 'med_2', 'cal_1'},
        reason: 'il libro non segna cio\' che e\' arrivato: alla prossima '
            'apertura si bussa di nuovo per premi gia\' pagati');

    // La stessa sessione non bussa due volte: il catenaccio tiene.
    porta.movimenti.clear();
    await RegiaDelCammino.riprendiIPremiPersi(chiave.currentContext!);
    expect(porta.movimenti, isEmpty,
        reason: 'la sincronia gira piu\' volte nella stessa sessione');

    // La sessione dopo non riprende cio' che il libro conosce.
    RegiaDelCammino.ripresaTentata = false;
    await RegiaDelCammino.riprendiIPremiPersi(chiave.currentContext!);
    expect(porta.movimenti, isEmpty,
        reason: 'il libro non ferma la ripresa dei premi gia\' arrivati');
  });

  testWidgets('a porta spenta la sincronia non inventa niente',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    RegiaDelCammino.ripresaTentata = false;
    final diario = DiarioDelCammino(orologio: () => DateTime(2026, 8, 18, 9));
    await diario.carica();
    await diario.accendi('med_1');
    final borsa = QuestionAllowance(porta: const PortaSpentaDelCerchio());
    final chiave = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
        Provider<AppServices>.value(value: AppServices.offline()),
        ChangeNotifierProvider<QuestionAllowance>.value(value: borsa),
      ],
      child: MaterialApp(home: Scaffold(body: SizedBox(key: chiave))),
    ));
    await RegiaDelCammino.riprendiIPremiPersi(chiave.currentContext!);
    expect(borsa.saldoEos, 0);
    expect(await LibroDegliAccrediti.accreditati(), isEmpty,
        reason: 'senza server nessun premio puo\' dirsi arrivato');
  });
}

/// La porta finta: risponde come il server vero dopo la cura della policy.
///
/// `muoviGliEos` replica il contratto: risponde il saldo DI ALLORA per ogni
/// movimento (10 Eos a premio, cumulativi), e `stato` dice il saldo sovrano
/// finale. La differenza fra i due e' esattamente il caso che la sincronia
/// deve reggere.
class _PortaCheConta extends PortaDelCerchio {
  _PortaCheConta();

  final List<String> movimenti = [];
  int _saldo = 10;

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato() async => StatoDelCerchio(
      giorno: '2026-08-18', piano: 'free', spesi: const {}, saldoEos: _saldo);

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
  }) async {
    movimenti.add(idMovimento);
    final risposta = _saldo;
    _saldo += 10;
    return risposta;
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

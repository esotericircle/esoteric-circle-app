import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/features/sigilli/regia_del_cammino.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA SINCRONIA DEI PREMI PARTE DA SOLA. Ordine AN voce 04.
///
/// **Il difetto, dal collaudo di Mauro sulla 2181**: aperte le porte del
/// server, al riavvio dell'app il saldo e' rimasto a zero, e l'arretrato e'
/// arrivato solo col traguardo successivo. La sincronia c'era e non e'
/// scattata.
///
/// **La causa, trovata per enumerazione**: dei tre candidati dell'ordine
/// (ordine di avvio del guardiano, catenaccio gia' consumato, errore
/// inghiottito) il colpevole e' il SECONDO, ma per una ragione che nessuno
/// dei tre nominava per intero. Il diario si carica da disco in modo
/// asincrono, `DiarioDelCammino()..carica()` nel provider; il guardiano gira
/// al primo fotogramma utile, quando quel caricamento e' ancora in volo.
/// La sincronia guardava quindi un cammino VUOTO, non trovava nessun premio
/// da riprendere, usciva subito e bruciava il catenaccio "una volta per
/// sessione" per tutta la sessione.
///
/// La cura: il diario dichiara quando e' pronto e la sincronia lo aspetta.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('al primo avvio, coi Sigilli gia\' accesi su disco, i premi '
      'si riprendono senza nessun gesto', (tester) async {
    // IL DISCO DI CHI RIAPRE L'APP: tre Sigilli accesi da ieri, e nessun
    // premio ancora arrivato.
    SharedPreferences.setMockInitialValues({
      'cammino.accesi': ['med_1', 'med_2', 'cal_1'],
    });
    RegiaDelCammino.ripresaTentata = false;
    final porta = _PortaCheConta();
    final borsa = QuestionAllowance(porta: porta);
    // Il diario si carica come lo carica l'app: dal provider, in volo.
    final diario = DiarioDelCammino(orologio: () => DateTime(2026, 8, 18, 9));
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

    // **L'ATTIMO VERO: il caricamento del disco e' IN VOLO.** L'app lancia
    // `carica()` dal provider senza attenderlo, e il guardiano gira al primo
    // fotogramma utile, cioe' adesso. Qui si riproduce quel momento: si
    // lancia la lettura e SUBITO la sincronia, senza lasciar respirare
    // nessuna delle due.
    final lettura = diario.carica();
    // ignore: avoid_print
    print('ORDINE AN VOCE 04: accesi noti alla partenza '
        '${diario.accesi.length}');
    expect(diario.accesi, isEmpty,
        reason: 'la prova non riproduce il caso: se il diario ha gia\' letto '
            'il disco, il difetto della 2181 non si vede');
    final corsa = RegiaDelCammino.riprendiIPremiPersi(chiave.currentContext!);
    await tester.runAsync(() async {
      await lettura;
      await corsa;
    });
    await tester.pump(const Duration(milliseconds: 50));

    // ignore: avoid_print
    print('ORDINE AN VOCE 04: movimenti chiesti al server '
        '${porta.movimenti}');
    expect(porta.movimenti.toSet(),
        {'traguardo-med_1', 'traguardo-med_2', 'traguardo-cal_1'},
        reason: 'al primo avvio la sincronia non ha ripreso niente: e\' il '
            'saldo rimasto a zero che Mauro ha visto sulla 2181, e serviva '
            'un gesto per sbloccarlo');
    expect(borsa.saldoEos, greaterThan(0),
        reason: 'i premi sono stati chiesti ma la pillola resta a zero');
  });
}

/// La porta finta: conta cosa le viene chiesto e risponde come il server.
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

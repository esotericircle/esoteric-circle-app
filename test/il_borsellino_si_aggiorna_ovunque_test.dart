import 'dart:io';

import 'package:esoteric_circle/core/cammino/custode_del_cammino.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// IL BORSELLINO SI AGGIORNA OVUNQUE. Ordine AU voce 11.
///
/// **Il fatto del fondatore**: in home la barra mostra 0 mentre il server ne ha
/// 445, e gli Eos si aggiornano solo entrando nel Passport.
///
/// **La premessa dell'ordine non regge alla misura, e si dichiara.** L'ordine
/// dice che la causa e' che "il saldo si rilegge solo quando il Passport si
/// monta". Cercato nel codice: il Passport **non legge affatto il saldo**, non
/// lo nomina nemmeno; la barra e il borsellino ascoltano tutti e due lo stesso
/// `QuestionAllowance`, che e' l'unica sorgente; e la lettura all'avvio c'e'
/// gia', la fa il Custode del cammino dopo il primo fotogramma. Se ci fosse
/// una copia separata, questa prova la troverebbe.
///
/// **Allora cosa si sorveglia qui.** Le quattro cose che l'ordine chiede,
/// misurate una per una sul flusso vero: il saldo arriva all'avvio senza
/// visitare nessuna schermata; chi mostra il numero ascolta la stessa sorgente
/// di chi lo aggiorna; un accredito cambia il numero nell'istante in cui il
/// server risponde; e **se la rete non risponde resta l'ultimo saldo
/// conosciuto e non uno zero**, che e' la cosa che il fondatore ha visto.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('il censimento: quanti punti leggono il saldo, e chi li chiama', () {
    final punti = <String, int>{};
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final quanti =
          RegExp(r'\.saldoEos\b').allMatches(f.readAsStringSync()).length;
      if (quanti > 0) {
        punti[f.path.split(RegExp(r'[\\/]')).last] = quanti;
      }
    }
    final ordinati = punti.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    // ignore: avoid_print
    print('ORDINE AU VOCE 11: leggono il saldo ${punti.length} file, '
        '${punti.values.fold(0, (a, b) => a + b)} punti in tutto: '
        '${ordinati.map((e) => "${e.key} (${e.value})").join(", ")}');

    // **UNA SORGENTE SOLA.** Il saldo vive in `QuestionAllowance` e nessun
    // altro se lo tiene: se un giorno qualcuno ne facesse una copia sua, la
    // barra e il Passport potrebbero mostrare due numeri diversi.
    final sorgenti = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final nome = f.path.split(RegExp(r'[\\/]')).last;
      if (nome == 'question_allowance.dart') continue;
      // **UN CAMPO, NON UN PARAMETRO**: la prima stesura di questa riga
      // segnalava `ritrovamento.dart`, che non tiene nessuna copia e riceve il
      // saldo come argomento con un valore di partenza. Un censimento che
      // scambia un parametro per uno stato manda a cercare un difetto che non
      // c'e'.
      //
      // **E LO HA SEGNALATO UNA SECONDA VOLTA, il 22 agosto 2026.** Il
      // parametro e' finito su una riga sua, e `[^;]*` **attraversa le
      // righe**: cercava il punto e virgola fino a trovarlo tre righe piu'
      // giu', dentro il corpo del metodo. Adesso il punto e virgola deve
      // stare sulla STESSA riga, che e' come si scrive un campo davvero.
      // **La guardia non e' stata allentata**: e' stata resa esatta, e
      // continua a mordere su un campo vero.
      if (RegExp(r'^[ \t]*(?:final[ \t]+)?int[ \t]+_?saldoEos[ \t]*=[^;\n]*;',
              multiLine: true)
          .hasMatch(f.readAsStringSync())) {
        sorgenti.add(nome);
      }
    }
    expect(sorgenti, isEmpty,
        reason: 'questi file tengono una copia del saldo: $sorgenti. La barra '
            'deve ascoltare la stessa sorgente del Passport');
  });

  test('il saldo arriva all avvio, senza visitare nessuna schermata',
      () async {
    SharedPreferences.setMockInitialValues(const {});
    final porta = _PortaCheHaQuattrocentoQuarantacinque();
    final borsa = QuestionAllowance(porta: porta)..load();
    expect(borsa.saldoEos, 0, reason: 'si parte da zero, come un telefono nuovo');
    await borsa.sincronizza();
    // ignore: avoid_print
    print('ORDINE AU VOCE 11: dopo la sola sincronia d avvio il saldo e '
        '${borsa.saldoEos}');
    expect(borsa.saldoEos, 445,
        reason: 'il saldo non arriva con la sincronia dell avvio: la persona '
            'vede zero in home mentre il server ne ha 445');
  });

  test('senza rete resta l ultimo saldo conosciuto, mai uno zero', () async {
    // **E' LA COSA CHE IL FONDATORE HA VISTO**: uno zero falso e' peggio di un
    // numero vecchio, perche' sembra che il premio non sia mai arrivato.
    SharedPreferences.setMockInitialValues(const {'allowance.saldoEos': 445});
    final borsa = QuestionAllowance(porta: _PortaMuta());
    await borsa.load();
    expect(borsa.saldoEos, 445,
        reason: 'il saldo salvato non si rilegge all avvio');
    await borsa.sincronizza();
    // ignore: avoid_print
    print('ORDINE AU VOCE 11: col server muto il saldo resta '
        '${borsa.saldoEos}');
    expect(borsa.saldoEos, 445,
        reason: 'senza rete il saldo e tornato a zero: uno zero falso e peggio '
            'di un numero vecchio');
  });

  testWidgets('un accredito cambia il numero senza cambiare schermata',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final porta = _PortaCheAccredita();
    final borsa = QuestionAllowance(porta: porta)..load();
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();

    // Una schermata qualunque che mostra il saldo come fa la barra: **si
    // ascolta**, non si legge una volta.
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<QuestionAllowance>.value(value: borsa),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
      ],
      child: MaterialApp(
        home: Builder(builder: (context) {
          final quanti = context.watch<QuestionAllowance>().saldoEos;
          return Scaffold(
              body: Center(
                  child: Text('$quanti', key: const Key('numero_in_barra'))));
        }),
      ),
    ));
    await tester.pump();
    expect(find.text('0'), findsOneWidget);

    // L'accredito arriva, e nessuno cambia schermata.
    final saldo = await porta.muoviGliEos(
        causale: 'traguardo', motivo: 'prova', idMovimento: 'uno');
    await borsa.applicaSaldo(saldo!);
    await tester.pump();
    final mostrato =
        tester.widget<Text>(find.byKey(const Key('numero_in_barra'))).data;
    // ignore: avoid_print
    print('ORDINE AU VOCE 11: dopo l accredito la barra mostra $mostrato '
        'senza che nessuno abbia cambiato schermata');
    expect(mostrato, '10',
        reason: 'la cifra in barra non cambia quando il server risponde: '
            'bisogna andare in un altra schermata per vederla');
  });

  test('il ritorno in primo piano rifa la sincronia', () {
    // **LA DOCUMENTAZIONE DICEVA IL FALSO, e la misura lo ha trovato.** In
    // `QuestionAllowance.sincronizza` sta scritto da sempre "si chiama
    // all'avvio e al ritorno in primo piano": contate le chiamate in tutto
    // `lib`, erano due, tutte e due all'avvio. Se la sincronia dell'avvio non
    // riesce, il saldo resta quello locale finche' l'app non viene riavviata,
    // ed e' il caso del fondatore.
    final app = File('lib/app.dart').readAsStringSync();
    expect(app.contains('didChangeAppLifecycleState'), isTrue,
        reason: 'nessuno ascolta il ritorno in primo piano: se la sincronia '
            'dell avvio fallisce, il saldo resta vecchio fino al riavvio');
    expect(app.contains('WidgetsBinding.instance.addObserver(this)'), isTrue,
        reason: 'l osservatore del ciclo di vita non e registrato: il metodo '
            'c e ma non lo chiama nessuno');
    expect(app.contains('WidgetsBinding.instance.removeObserver(this)'), isTrue,
        reason: 'l osservatore non viene tolto allo smontaggio');
    // ignore: avoid_print
    print('ORDINE AU VOCE 11: il ritorno in primo piano rifa la sincronia');
  });
}

/// Le porte finte di questa prova rispondono solo a cio' che serve: il resto
/// e' dichiarato qui una volta, invece di ripeterlo tre volte.
mixin _PortaQuietaSulResto on PortaDelCerchio {
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

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async =>
      null;
}

class _PortaCheHaQuattrocentoQuarantacinque extends PortaDelCerchio
    with _PortaQuietaSulResto {
  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
          {CamminoDaCustodire? cammino, bool azzeraIlCammino = false}) async =>
      const StatoDelCerchio(
        giorno: '2026-08-22',
        piano: 'free',
        spesi: {},
        saldoEos: 445,
        cammino: null,
      );
}

class _PortaMuta extends PortaDelCerchio with _PortaQuietaSulResto {
  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
          {CamminoDaCustodire? cammino, bool azzeraIlCammino = false}) async =>
      null;
}

class _PortaCheAccredita extends PortaDelCerchio with _PortaQuietaSulResto {
  int saldo = 0;

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
          {CamminoDaCustodire? cammino, bool azzeraIlCammino = false}) async =>
      null;

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async {
    saldo += 10;
    return saldo;
  }
}
